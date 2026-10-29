using Timex.Data;
using Timex.Models;

namespace Timex.Forms;

public sealed class SearchForm : Form
{
    private readonly TimexDatabase _database;
    private readonly ComboBox _consultant = CreateCombo();
    private readonly ComboBox _client = CreateCombo();
    private readonly CheckBox _limitDates = new() { Text = "Limit dates", AutoSize = true };
    private readonly DateTimePicker _from = CreateDatePicker();
    private readonly DateTimePicker _to = CreateDatePicker();
    private readonly NumericUpDown _startId = new() { Minimum = 1, Maximum = int.MaxValue, Value = 1, Width = 110 };
    private readonly ListBox _results = new();

    public SearchForm(TimexDatabase database)
    {
        _database = database;
        Text = "Find slips";
        Width = 850;
        Height = 570;
        MinimumSize = new Size(700, 450);
        StartPosition = FormStartPosition.CenterParent;

        ConfigureFilter(_consultant, LookupKind.Consultant);
        ConfigureFilter(_client, LookupKind.Client);
        _from.Enabled = false;
        _to.Enabled = false;
        _limitDates.CheckedChanged += (_, _) =>
        {
            _from.Enabled = _limitDates.Checked;
            _to.Enabled = _limitDates.Checked;
        };

        var searchButton = new Button { Text = "Find", AutoSize = true };
        searchButton.Click += (_, _) => Search();
        var closeButton = new Button { Text = "Close", AutoSize = true, DialogResult = DialogResult.Cancel };
        _results.Dock = DockStyle.Fill;
        _results.DoubleClick += (_, _) => OpenSelected();

        var filters = new TableLayoutPanel
        {
            Dock = DockStyle.Top,
            AutoSize = true,
            ColumnCount = 4,
            RowCount = 4,
            Padding = new Padding(12)
        };
        filters.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        filters.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50));
        filters.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        filters.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50));
        AddFilter(filters, "Consultant", _consultant, 0, 0);
        AddFilter(filters, "Client", _client, 2, 0);
        AddFilter(filters, "Starting slip ID", _startId, 0, 1);
        filters.Controls.Add(_limitDates, 2, 1);
        filters.Controls.Add(_from, 1, 2);
        filters.Controls.Add(new Label { Text = "through", AutoSize = true, Anchor = AnchorStyles.Left }, 2, 2);
        filters.Controls.Add(_to, 3, 2);
        filters.Controls.Add(searchButton, 2, 3);
        filters.Controls.Add(closeButton, 3, 3);

        var layout = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 2,
            Padding = new Padding(8)
        };
        layout.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        layout.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        layout.Controls.Add(filters, 0, 0);
        layout.Controls.Add(_results, 0, 1);
        Controls.Add(layout);
    }

    public int? SelectedSlipId { get; private set; }

    private void ConfigureFilter(ComboBox comboBox, LookupKind kind)
    {
        var options = new List<FilterOption> { new(null, "All") };
        options.AddRange(_database.GetLookupItems(kind).Select(item => new FilterOption(item.Id, item.Name)));
        comboBox.DataSource = options;
        comboBox.DisplayMember = nameof(FilterOption.Name);
        comboBox.ValueMember = nameof(FilterOption.Id);
    }

    private void Search()
    {
        if (_limitDates.Checked && _from.Value.Date > _to.Value.Date)
        {
            MessageBox.Show(this, "The start date must not be after the end date.", Text,
                MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        var consultantId = (_consultant.SelectedItem as FilterOption)?.Id;
        var clientId = (_client.SelectedItem as FilterOption)?.Id;
        DateOnly? from = _limitDates.Checked ? DateOnly.FromDateTime(_from.Value) : null;
        DateOnly? to = _limitDates.Checked ? DateOnly.FromDateTime(_to.Value) : null;
        _results.DataSource = _database.SearchSlips(
            consultantId,
            clientId,
            from,
            to,
            Decimal.ToInt32(_startId.Value)).ToList();
    }

    private void OpenSelected()
    {
        if (_results.SelectedItem is not SlipListItem item)
        {
            return;
        }

        SelectedSlipId = item.Id;
        DialogResult = DialogResult.OK;
        Close();
    }

    private static void AddFilter(TableLayoutPanel layout, string label, Control control, int column, int row)
    {
        layout.Controls.Add(new Label { Text = label, AutoSize = true, Anchor = AnchorStyles.Left }, column, row);
        control.Dock = DockStyle.Fill;
        layout.Controls.Add(control, column + 1, row);
    }

    private static ComboBox CreateCombo() =>
        new() { DropDownStyle = ComboBoxStyle.DropDownList, MinimumSize = new Size(150, 0) };

    private static DateTimePicker CreateDatePicker() =>
        new() { Format = DateTimePickerFormat.Short, Value = DateTime.Today };

    private sealed record FilterOption(int? Id, string Name);
}
