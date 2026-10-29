using System.Text;
using Timex.Data;
using Timex.Models;

namespace Timex.Forms;

public sealed class MainForm : Form
{
    private readonly TimexDatabase _database;
    private readonly ComboBox _consultant = CreateCombo();
    private readonly ComboBox _client = CreateCombo();
    private readonly ComboBox _job = CreateCombo();
    private readonly DateTimePicker _date = new() { Format = DateTimePickerFormat.Short, Dock = DockStyle.Left };
    private readonly NumericUpDown _hours = new() { Minimum = 0, Maximum = 24, Width = 100 };
    private readonly NumericUpDown _minutes = new() { Minimum = 0, Maximum = 59, Width = 100 };
    private readonly TextBox _description = new() { Multiline = true, ScrollBars = ScrollBars.Vertical };
    private readonly Label _recordCaption = new() { AutoSize = true, Font = new Font(SystemFonts.DefaultFont, FontStyle.Bold) };
    private readonly ToolStripStatusLabel _status = new() { Text = "Ready", Spring = true };
    private Button? _firstButton;
    private Button? _previousButton;
    private Button? _nextButton;
    private Button? _lastButton;
    private readonly ToolStripMenuItem _deleteMenuItem = new("Erase slip");
    private int? _currentId;
    private bool _isDeleted;
    private bool _isDirty;
    private bool _loading;

    public MainForm(TimexDatabase database)
    {
        _database = database;
        Text = "Timex - Consultant's assistant";
        Width = 820;
        Height = 620;
        MinimumSize = new Size(680, 520);
        StartPosition = FormStartPosition.CenterScreen;

        BuildMenu();
        BuildContent();
        HookDirtyEvents();
        Load += (_, _) => StartApplication();
        FormClosing += MainFormClosing;
    }

    private void BuildMenu()
    {
        var menu = new MenuStrip { Dock = DockStyle.Top };
        var file = new ToolStripMenuItem("&File");
        file.DropDownItems.Add("Export all data...", null, (_, _) => ExportAllData());
        file.DropDownItems.Add(new ToolStripSeparator());
        file.DropDownItems.Add("E&xit", null, (_, _) => Close());

        var slips = new ToolStripMenuItem("&Slips");
        slips.DropDownItems.Add("&New slip", null, (_, _) => CreateNewSlip());
        slips.DropDownItems.Add("&Duplicate slip", null, (_, _) => DuplicateSlip());
        slips.DropDownItems.Add("&Save", null, (_, _) => SaveCurrent());
        slips.DropDownItems.Add(_deleteMenuItem);
        _deleteMenuItem.Click += (_, _) => ToggleDeleted();
        slips.DropDownItems.Add("&Find slip...", null, (_, _) => FindSlip());

        var lists = new ToolStripMenuItem("&Lists");
        AddLookupMenu(lists, "Consultants", LookupKind.Consultant);
        AddLookupMenu(lists, "Clients", LookupKind.Client);
        AddLookupMenu(lists, "Jobs", LookupKind.Job);

        var reports = new ToolStripMenuItem("&Reports");
        reports.DropDownItems.Add("&Timesheet...", null, (_, _) => OpenReport(ReportKind.Timesheet));
        reports.DropDownItems.Add("&Invoice...", null, (_, _) => OpenReport(ReportKind.Invoice));

        menu.Items.AddRange([file, slips, lists, reports]);
        MainMenuStrip = menu;
        Controls.Add(menu);
    }

    private void BuildContent()
    {
        var layout = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 2,
            RowCount = 9,
            Padding = new Padding(18),
            AutoSize = false
        };
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 115));
        layout.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 38));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 44));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 44));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 44));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 44));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 44));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 44));
        layout.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 48));

        _recordCaption.Text = "New slip";
        layout.Controls.Add(_recordCaption, 0, 0);
        layout.SetColumnSpan(_recordCaption, 2);
        AddField(layout, "Consultant", _consultant, 1);
        AddField(layout, "Client", _client, 2);
        AddField(layout, "Job", _job, 3);
        AddField(layout, "Date", _date, 4);
        AddField(layout, "Hours", _hours, 5);
        AddField(layout, "Minutes", _minutes, 6);
        AddField(layout, "Details", _description, 7);

        var navigation = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            FlowDirection = FlowDirection.LeftToRight,
            WrapContents = false,
            Padding = new Padding(0, 7, 0, 0)
        };
        _firstButton = AddNavigationButton(navigation, "|<", "First slip", (_, _) => NavigateTo(_database.GetBoundarySlipId(false)));
        _previousButton = AddNavigationButton(navigation, "<", "Previous slip", (_, _) => NavigateTo(CurrentAdjacent(false)));
        _nextButton = AddNavigationButton(navigation, ">", "Next slip", (_, _) => NavigateTo(CurrentAdjacent(true)));
        _lastButton = AddNavigationButton(navigation, ">|", "Last slip", (_, _) => NavigateTo(_database.GetBoundarySlipId(true)));
        AddNavigationButton(navigation, "New", "New slip", (_, _) => CreateNewSlip());
        AddNavigationButton(navigation, "Duplicate", "Duplicate slip", (_, _) => DuplicateSlip());
        AddNavigationButton(navigation, "Save", "Save slip", (_, _) => SaveCurrent());
        AddNavigationButton(navigation, "Erase / Restore", "Erase or restore slip", (_, _) => ToggleDeleted());
        layout.Controls.Add(navigation, 0, 8);
        layout.SetColumnSpan(navigation, 2);

        var status = new StatusStrip { Dock = DockStyle.Bottom };
        status.Items.Add(_status);
        Controls.Add(layout);
        Controls.Add(status);
    }

    private void HookDirtyEvents()
    {
        _consultant.SelectedIndexChanged += (_, _) => MarkDirty();
        _client.SelectedIndexChanged += (_, _) => MarkDirty();
        _job.SelectedIndexChanged += (_, _) => MarkDirty();
        _date.ValueChanged += (_, _) => MarkDirty();
        _hours.ValueChanged += (_, _) => MarkDirty();
        _minutes.ValueChanged += (_, _) => MarkDirty();
        _description.TextChanged += (_, _) => MarkDirty();
    }

    private void StartApplication()
    {
        RefreshLookups();
        var consultantId = ReadPreferenceId("last-consultant");
        var clientId = ReadPreferenceId("last-client");
        SelectLookup(_consultant, consultantId);
        SelectLookup(_client, clientId);

        var lastSlipId = ReadPreferenceId("last-slip");
        if (lastSlipId.HasValue && LoadSlip(lastSlipId.Value))
        {
            return;
        }

        CreateNewSlipWithoutPrompt();
    }

    private void RefreshLookups()
    {
        var wasLoading = _loading;
        _loading = true;
        try
        {
            BindLookup(_consultant, LookupKind.Consultant);
            BindLookup(_client, LookupKind.Client);
            BindLookup(_job, LookupKind.Job);
        }
        finally
        {
            _loading = wasLoading;
        }
    }

    private void BindLookup(ComboBox comboBox, LookupKind kind)
    {
        var current = (comboBox.SelectedItem as LookupItem)?.Id;
        comboBox.DataSource = _database.GetLookupItems(kind).ToList();
        comboBox.DisplayMember = nameof(LookupItem.Name);
        comboBox.ValueMember = nameof(LookupItem.Id);
        SelectLookup(comboBox, current);
    }

    private static void SelectLookup(ComboBox comboBox, int? id)
    {
        if (id.HasValue && comboBox.DataSource is IEnumerable<LookupItem> items)
        {
            comboBox.SelectedItem = items.FirstOrDefault(item => item.Id == id.Value);
        }
        else
        {
            comboBox.SelectedIndex = -1;
        }
    }

    private bool LoadSlip(int id)
    {
        var slip = _database.GetSlip(id);
        if (slip is null)
        {
            return false;
        }

        _loading = true;
        try
        {
            _currentId = slip.Id;
            _isDeleted = slip.Deleted;
            SelectLookup(_consultant, slip.ConsultantId);
            SelectLookup(_client, slip.ClientId);
            SelectLookup(_job, slip.JobId);
            _date.Value = slip.Date.ToDateTime(TimeOnly.MinValue);
            _hours.Value = slip.Hours;
            _minutes.Value = slip.Minutes;
            _description.Text = slip.Text;
            _isDirty = false;
            _recordCaption.Text = $"Record #{slip.Id}";
            _deleteMenuItem.Text = slip.Deleted ? "Un&erase slip" : "&Erase slip";
            _status.Text = slip.Deleted ? "Deleted slip" : "Saved";
            UpdateNavigation();
        }
        finally
        {
            _loading = false;
        }

        return true;
    }

    private void CreateNewSlip()
    {
        if (ConfirmLeaveCurrent())
        {
            CreateNewSlipWithoutPrompt();
        }
    }

    private void CreateNewSlipWithoutPrompt()
    {
        _loading = true;
        try
        {
            _currentId = null;
            _isDeleted = false;
            _date.Value = DateTime.Today;
            _hours.Value = 0;
            _minutes.Value = 0;
            _description.Clear();
            SelectLookup(_job, null);
            _isDirty = false;
            _recordCaption.Text = "New slip";
            _deleteMenuItem.Text = "&Erase slip";
            _status.Text = "New slip";
            UpdateNavigation();
        }
        finally
        {
            _loading = false;
        }
    }

    private void DuplicateSlip()
    {
        if (!ConfirmLeaveCurrent())
        {
            return;
        }

        _currentId = null;
        _isDeleted = false;
        _recordCaption.Text = "New slip (duplicate)";
        _deleteMenuItem.Text = "&Erase slip";
        _status.Text = "New slip";
        UpdateNavigation();
    }

    private bool SaveCurrent()
    {
        if (_consultant.SelectedItem is not LookupItem consultant ||
            _client.SelectedItem is not LookupItem client ||
            _job.SelectedItem is not LookupItem job)
        {
            MessageBox.Show(this, "Add and select a consultant, client, and job before saving a slip.",
                Text, MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return false;
        }

        try
        {
            var slip = new TimeSlip(
                _currentId ?? 0,
                consultant.Id,
                client.Id,
                job.Id,
                DateOnly.FromDateTime(_date.Value),
                Decimal.ToInt32(_hours.Value),
                Decimal.ToInt32(_minutes.Value),
                _description.Text,
                _isDeleted);
            var id = _database.SaveSlip(slip);
            LoadSlip(id);
            return true;
        }
        catch (Microsoft.Data.Sqlite.SqliteException exception)
        {
            MessageBox.Show(this, $"The slip could not be saved.\n\n{exception.Message}",
                Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
            return false;
        }
        catch (InvalidOperationException exception)
        {
            MessageBox.Show(this, $"The slip could not be saved.\n\n{exception.Message}",
                Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
            return false;
        }
    }

    private bool ConfirmLeaveCurrent()
    {
        if (!_isDirty)
        {
            return true;
        }

        var answer = MessageBox.Show(this, "Save changes to this slip before continuing?",
            Text, MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question);
        return answer switch
        {
            DialogResult.Yes => SaveCurrent(),
            DialogResult.No => true,
            _ => false
        };
    }

    private void ToggleDeleted()
    {
        if (!_currentId.HasValue)
        {
            return;
        }

        if (!ConfirmLeaveCurrent())
        {
            return;
        }

        if (!_isDeleted && MessageBox.Show(this, "Erase this slip? It can be restored later.",
                Text, MessageBoxButtons.YesNo, MessageBoxIcon.Warning) != DialogResult.Yes)
        {
            return;
        }

        _database.SetSlipDeleted(_currentId.Value, !_isDeleted);
        LoadSlip(_currentId.Value);
    }

    private void NavigateTo(int? id)
    {
        if (id.HasValue && ConfirmLeaveCurrent())
        {
            LoadSlip(id.Value);
        }
    }

    private int? CurrentAdjacent(bool forward) =>
        _currentId.HasValue ? _database.GetAdjacentSlipId(_currentId.Value, forward) : null;

    private void UpdateNavigation()
    {
        var hasRecord = _currentId.HasValue;
        var hasPrevious = hasRecord && _database.GetAdjacentSlipId(_currentId!.Value, false).HasValue;
        var hasNext = hasRecord && _database.GetAdjacentSlipId(_currentId!.Value, true).HasValue;
        _firstButton!.Enabled = hasPrevious;
        _previousButton!.Enabled = hasPrevious;
        _nextButton!.Enabled = hasNext;
        _lastButton!.Enabled = hasNext;
    }

    private void FindSlip()
    {
        if (!ConfirmLeaveCurrent())
        {
            return;
        }

        using var search = new SearchForm(_database);
        if (search.ShowDialog(this) == DialogResult.OK && search.SelectedSlipId.HasValue)
        {
            LoadSlip(search.SelectedSlipId.Value);
        }
    }

    private void OpenLookupManager(LookupKind kind)
    {
        using var dialog = new LookupManagementForm(_database, kind);
        dialog.ShowDialog(this);
        RefreshLookups();
    }

    private void OpenReport(ReportKind kind)
    {
        using var report = new ReportForm(_database, kind);
        report.ShowDialog(this);
    }

    private void ExportAllData()
    {
        using var dialog = new SaveFileDialog
        {
            Filter = "Tab-delimited files (*.tsv)|*.tsv|Text files (*.txt)|*.txt|All files (*.*)|*.*",
            DefaultExt = "tsv",
            FileName = "timex-export.tsv"
        };
        if (dialog.ShowDialog(this) != DialogResult.OK)
        {
            return;
        }

        try
        {
            var lines = new List<string>
            {
                "Date\tHours\tMinutes\tConsultant\tClient\tJob\tDetails\tDeleted"
            };
            lines.AddRange(_database.SearchSlips().Select(slip =>
                string.Join("\t", new[]
                {
                    slip.Date.ToString("yyyy-MM-dd"),
                    slip.Hours.ToString(),
                    slip.Minutes.ToString(),
                    EscapeTsv(slip.Consultant),
                    EscapeTsv(slip.Client),
                    EscapeTsv(slip.Job),
                    EscapeTsv(slip.Text),
                    slip.Deleted ? "Yes" : "No"
                })));
            File.WriteAllText(dialog.FileName, string.Join(Environment.NewLine, lines), new UTF8Encoding(true));
        }
        catch (Exception exception) when (
            exception is IOException or UnauthorizedAccessException or Microsoft.Data.Sqlite.SqliteException)
        {
            MessageBox.Show(this, $"The export failed.\n\n{exception.Message}",
                Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void MainFormClosing(object? sender, FormClosingEventArgs e)
    {
        if (!ConfirmLeaveCurrent())
        {
            e.Cancel = true;
            return;
        }

        try
        {
            if (_currentId.HasValue)
            {
                _database.SetPreference("last-slip", _currentId.Value.ToString());
            }

            if (_consultant.SelectedItem is LookupItem consultant)
            {
                _database.SetPreference("last-consultant", consultant.Id.ToString());
            }

            if (_client.SelectedItem is LookupItem client)
            {
                _database.SetPreference("last-client", client.Id.ToString());
            }
        }
        catch (Microsoft.Data.Sqlite.SqliteException exception)
        {
            MessageBox.Show(this, $"The slip was saved, but the last-used selection could not be stored.\n\n{exception.Message}",
                Text, MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private void MarkDirty()
    {
        if (_loading)
        {
            return;
        }

        _isDirty = true;
        _status.Text = "Modified";
        if (!_recordCaption.Text.EndsWith(" *", StringComparison.Ordinal))
        {
            _recordCaption.Text += " *";
        }
    }

    private int? ReadPreferenceId(string key)
    {
        var value = _database.GetPreference(key);
        return int.TryParse(value, out var id) ? id : null;
    }

    private void AddLookupMenu(ToolStripMenuItem parent, string label, LookupKind kind) =>
        parent.DropDownItems.Add(label, null, (_, _) => OpenLookupManager(kind));

    private static void AddField(TableLayoutPanel layout, string label, Control control, int row)
    {
        layout.Controls.Add(new Label { Text = label, AutoSize = true, Anchor = AnchorStyles.Left }, 0, row);
        control.Dock = DockStyle.Fill;
        layout.Controls.Add(control, 1, row);
    }

    private static Button AddNavigationButton(
        FlowLayoutPanel panel,
        string text,
        string accessibleName,
        EventHandler click)
    {
        var button = new Button
        {
            Text = text,
            AutoSize = true,
            AccessibleName = accessibleName,
            Margin = new Padding(0, 0, 5, 0)
        };
        button.Click += click;
        panel.Controls.Add(button);
        return button;
    }

    private static ComboBox CreateCombo() =>
        new() { Dock = DockStyle.Fill, DropDownStyle = ComboBoxStyle.DropDownList };

    private static string EscapeTsv(string value)
    {
        if (value.IndexOfAny(['\t', '\r', '\n', '"']) < 0)
        {
            return value;
        }

        return $"\"{value.Replace("\"", "\"\"", StringComparison.Ordinal)
            .Replace("\r", " ", StringComparison.Ordinal)
            .Replace("\n", " ", StringComparison.Ordinal)}\"";
    }
}
