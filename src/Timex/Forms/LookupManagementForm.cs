using Timex.Data;
using Timex.Models;

namespace Timex.Forms;

public sealed class LookupManagementForm : Form
{
    private readonly TimexDatabase _database;
    private readonly LookupKind _kind;
    private readonly ListBox _items = new();
    private readonly TextBox _name = new();

    public LookupManagementForm(TimexDatabase database, LookupKind kind)
    {
        _database = database;
        _kind = kind;
        Text = $"{KindName} list";
        Width = 430;
        Height = 430;
        StartPosition = FormStartPosition.CenterParent;
        MinimumSize = new Size(360, 320);

        _items.Dock = DockStyle.Fill;
        _items.DisplayMember = nameof(LookupItem.Name);
        _items.SelectedIndexChanged += (_, _) =>
        {
            if (_items.SelectedItem is LookupItem item)
            {
                _name.Text = item.Name;
            }
        };
        _items.DoubleClick += (_, _) => RenameSelected();

        _name.Dock = DockStyle.Fill;
        _name.PlaceholderText = $"Enter {KindName.ToLowerInvariant()} name";

        var addButton = new Button { Text = "Add", AutoSize = true };
        addButton.Click += (_, _) => AddItem();
        var renameButton = new Button { Text = "Rename selected", AutoSize = true };
        renameButton.Click += (_, _) => RenameSelected();
        var closeButton = new Button { Text = "Close", AutoSize = true, DialogResult = DialogResult.OK };
        AcceptButton = addButton;
        CancelButton = closeButton;

        var actions = new FlowLayoutPanel
        {
            Dock = DockStyle.Fill,
            AutoSize = true,
            FlowDirection = FlowDirection.LeftToRight,
            Padding = new Padding(0, 6, 0, 0)
        };
        actions.Controls.AddRange([addButton, renameButton, closeButton]);

        var layout = new TableLayoutPanel
        {
            Dock = DockStyle.Fill,
            ColumnCount = 1,
            RowCount = 3,
            Padding = new Padding(12)
        };
        layout.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        layout.RowStyles.Add(new RowStyle(SizeType.Absolute, 34));
        layout.RowStyles.Add(new RowStyle(SizeType.AutoSize));
        layout.Controls.Add(_items, 0, 0);
        layout.Controls.Add(_name, 0, 1);
        layout.Controls.Add(actions, 0, 2);
        Controls.Add(layout);

        RefreshItems();
    }

    private string KindName => _kind switch
    {
        LookupKind.Consultant => "Consultant",
        LookupKind.Client => "Client",
        LookupKind.Job => "Job",
        _ => throw new ArgumentOutOfRangeException()
    };

    private void AddItem()
    {
        var value = _name.Text.Trim();
        if (value.Length == 0)
        {
            return;
        }

        try
        {
            var id = _database.AddLookupItem(_kind, value);
            RefreshItems(id);
            _name.Clear();
        }
        catch (Microsoft.Data.Sqlite.SqliteException exception)
        {
            var message = exception.SqliteErrorCode == 19
                ? $"A {KindName.ToLowerInvariant()} with that name already exists."
                : $"The {KindName.ToLowerInvariant()} could not be added.\n\n{exception.Message}";
            MessageBox.Show(this, message,
                Text, MessageBoxButtons.OK,
                exception.SqliteErrorCode == 19 ? MessageBoxIcon.Information : MessageBoxIcon.Error);
        }
    }

    private void RenameSelected()
    {
        if (_items.SelectedItem is not LookupItem item || string.IsNullOrWhiteSpace(_name.Text))
        {
            return;
        }

        try
        {
            _database.RenameLookupItem(_kind, item.Id, _name.Text.Trim());
            RefreshItems(item.Id);
        }
        catch (Microsoft.Data.Sqlite.SqliteException exception)
        {
            var message = exception.SqliteErrorCode == 19
                ? $"A {KindName.ToLowerInvariant()} with that name already exists."
                : $"The {KindName.ToLowerInvariant()} could not be renamed.\n\n{exception.Message}";
            MessageBox.Show(this, message,
                Text, MessageBoxButtons.OK,
                exception.SqliteErrorCode == 19 ? MessageBoxIcon.Information : MessageBoxIcon.Error);
        }
    }

    private void RefreshItems(int? selectedId = null)
    {
        var items = _database.GetLookupItems(_kind).ToList();
        _items.DataSource = items;
        if (selectedId.HasValue)
        {
            _items.SelectedItem = items.FirstOrDefault(item => item.Id == selectedId.Value);
        }
    }
}
