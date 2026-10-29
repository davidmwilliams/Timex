using System.Drawing.Printing;
using Timex.Data;
using Timex.Models;

namespace Timex.Forms;

public enum ReportKind
{
    Timesheet,
    Invoice
}

public sealed class ReportForm : Form
{
    private readonly TimexDatabase _database;
    private readonly ReportKind _kind;
    private readonly ComboBox _subject = new() { DropDownStyle = ComboBoxStyle.DropDownList, Dock = DockStyle.Fill };
    private readonly DateTimePicker _from = new() { Format = DateTimePickerFormat.Short, Value = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1) };
    private readonly DateTimePicker _to = new() { Format = DateTimePickerFormat.Short, Value = DateTime.Today };
    private readonly Label _message = new() { AutoSize = true };
    private readonly PrintDocument _printDocument = new();
    private IReadOnlyList<SlipListItem> _rows = [];
    private int _printIndex;

    public ReportForm(TimexDatabase database, ReportKind kind)
    {
        _database = database;
        _kind = kind;
        Text = kind == ReportKind.Timesheet ? "Timesheet report" : "Invoice report";
        Width = 560;
        Height = 230;
        StartPosition = FormStartPosition.CenterParent;
        FormBorderStyle = FormBorderStyle.FixedDialog;
        MaximizeBox = false;

        var subjectKind = kind == ReportKind.Timesheet ? LookupKind.Consultant : LookupKind.Client;
        var subjectLabel = kind == ReportKind.Timesheet ? "Consultant" : "Client";
        var allLabel = kind == ReportKind.Timesheet ? "All consultants" : "All clients";
        var options = new List<ReportOption> { new(null, allLabel) };
        options.AddRange(database.GetLookupItems(subjectKind).Select(item => new ReportOption(item.Id, item.Name)));
        _subject.DataSource = options;
        _subject.DisplayMember = nameof(ReportOption.Name);
        _subject.ValueMember = nameof(ReportOption.Id);

        var filters = new TableLayoutPanel
        {
            Dock = DockStyle.Top,
            AutoSize = true,
            ColumnCount = 4,
            RowCount = 2,
            Padding = new Padding(12)
        };
        filters.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        filters.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50));
        filters.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
        filters.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50));
        filters.Controls.Add(new Label { Text = subjectLabel, AutoSize = true, Anchor = AnchorStyles.Left }, 0, 0);
        filters.Controls.Add(_subject, 1, 0);
        filters.Controls.Add(new Label { Text = "From", AutoSize = true, Anchor = AnchorStyles.Left }, 0, 1);
        _from.Dock = DockStyle.Fill;
        filters.Controls.Add(_from, 1, 1);
        filters.Controls.Add(new Label { Text = "To", AutoSize = true, Anchor = AnchorStyles.Left }, 2, 1);
        _to.Dock = DockStyle.Fill;
        filters.Controls.Add(_to, 3, 1);

        var previewButton = new Button { Text = "Preview", AutoSize = true };
        previewButton.Click += (_, _) => Preview();
        var printButton = new Button { Text = "Print...", AutoSize = true };
        printButton.Click += (_, _) => Print();
        var closeButton = new Button { Text = "Close", AutoSize = true, DialogResult = DialogResult.Cancel };
        var actions = new FlowLayoutPanel
        {
            Dock = DockStyle.Bottom,
            AutoSize = true,
            FlowDirection = FlowDirection.RightToLeft,
            Padding = new Padding(12)
        };
        actions.Controls.AddRange([closeButton, printButton, previewButton]);

        var content = new Panel { Dock = DockStyle.Fill, Padding = new Padding(12) };
        content.Controls.Add(_message);
        content.Controls.Add(filters);
        content.Controls.Add(actions);
        Controls.Add(content);

        _printDocument.DocumentName = kind == ReportKind.Timesheet ? "Timex timesheet" : "Timex invoice";
        _printDocument.BeginPrint += (_, _) => _printIndex = 0;
        _printDocument.PrintPage += PrintPage;
    }

    private void Preview()
    {
        if (!LoadRows())
        {
            return;
        }

        using var preview = new PrintPreviewDialog
        {
            Document = _printDocument,
            Width = 1000,
            Height = 750
        };
        preview.ShowDialog(this);
    }

    private void Print()
    {
        if (!LoadRows())
        {
            return;
        }

        using var dialog = new PrintDialog { Document = _printDocument, UseEXDialog = true };
        if (dialog.ShowDialog(this) == DialogResult.OK)
        {
            _printDocument.Print();
        }
    }

    private bool LoadRows()
    {
        if (_from.Value.Date > _to.Value.Date)
        {
            MessageBox.Show(this, "The start date must not be after the end date.", Text,
                MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return false;
        }

        var selectedId = (_subject.SelectedItem as ReportOption)?.Id;
        _rows = _database.SearchSlips(
            consultantId: _kind == ReportKind.Timesheet ? selectedId : null,
            clientId: _kind == ReportKind.Invoice ? selectedId : null,
            from: DateOnly.FromDateTime(_from.Value),
            to: DateOnly.FromDateTime(_to.Value));

        _message.Text = _kind == ReportKind.Invoice
            ? "Invoice output lists time only; the original data contains no rates or amounts. Erased slips are included."
            : $"{_rows.Count} slip(s), including erased entries, in this date range.";
        return true;
    }

    private void PrintPage(object? sender, PrintPageEventArgs e)
    {
        var graphics = e.Graphics;
        var bounds = e.MarginBounds;
        using var titleFont = new Font("Arial", 16, FontStyle.Bold);
        using var headerFont = new Font("Arial", 9, FontStyle.Bold);
        using var bodyFont = new Font("Arial", 9);
        using var smallFont = new Font("Arial", 8);
        using var linePen = new Pen(Color.DimGray);

        var subjectName = (_subject.SelectedItem as ReportOption)?.Name ?? string.Empty;
        var title = _kind == ReportKind.Timesheet ? "Timesheet" : "Invoice";
        graphics.DrawString(title, titleFont, Brushes.Black, bounds.Left, bounds.Top);
        var subjectPrefix = _kind == ReportKind.Timesheet ? "Consultant: " : "Client: ";
        graphics.DrawString($"{subjectPrefix}{subjectName}", bodyFont, Brushes.Black, bounds.Left, bounds.Top + 30);
        graphics.DrawString($"{_from.Value:d} to {_to.Value:d}", bodyFont, Brushes.Black, bounds.Left, bounds.Top + 48);
        var y = bounds.Top + 78;

        var widths = new[]
        {
            74,
            58,
            _kind == ReportKind.Timesheet ? 85 : 0,
            _kind == ReportKind.Timesheet ? 100 : 86
        };
        var detailsWidth = bounds.Width - widths.Sum();
        var columns = _kind == ReportKind.Timesheet
            ? new[] { "Date", "Time", "Client", "Job", "Details" }
            : new[] { "Date", "Time", "Job", "Details" };
        var columnWidths = _kind == ReportKind.Timesheet
            ? new[] { widths[0], widths[1], widths[2], widths[3], detailsWidth }
            : new[] { widths[0], widths[1], widths[3], detailsWidth };
        var x = bounds.Left;
        for (var index = 0; index < columns.Length; index++)
        {
            graphics.DrawString(columns[index], headerFont, Brushes.Black, x, y);
            x += columnWidths[index];
        }

        y += 20;
        graphics.DrawLine(linePen, bounds.Left, y, bounds.Right, y);
        y += 5;

        if (_rows.Count == 0)
        {
            graphics.DrawString("No slips were found for this report.", bodyFont, Brushes.Black, bounds.Left, y);
        }
        else
        {
            while (_printIndex < _rows.Count)
            {
                var row = _rows[_printIndex];
                var detailHeight = graphics.MeasureString(row.Text, bodyFont, Math.Max(50, detailsWidth)).Height;
                var rowHeight = Math.Max(18, detailHeight + 4);
                if (y + rowHeight > bounds.Bottom - 38)
                {
                    e.HasMorePages = true;
                    return;
                }

                var values = _kind == ReportKind.Timesheet
                    ? new[]
                    {
                        row.Date.ToString("d"),
                        $"{row.Hours}:{row.Minutes:00}",
                        row.Client,
                        row.Job,
                        row.Text
                    }
                    : new[]
                    {
                        row.Date.ToString("d"),
                        $"{row.Hours}:{row.Minutes:00}",
                        row.Job,
                        row.Text
                    };
                x = bounds.Left;
                for (var index = 0; index < values.Length; index++)
                {
                    graphics.DrawString(values[index], bodyFont, Brushes.Black,
                        new RectangleF(x, y, columnWidths[index] - 4, rowHeight));
                    x += columnWidths[index];
                }

                y += rowHeight;
                _printIndex++;
            }

            var totalMinutes = _rows.Sum(row => (long)row.Hours * 60 + row.Minutes);
            var totalHours = Math.DivRem(totalMinutes, 60, out var remainingMinutes);
            y += 8;
            graphics.DrawLine(linePen, bounds.Left, y, bounds.Right, y);
            graphics.DrawString($"Total time: {totalHours}:{remainingMinutes:00}",
                headerFont, Brushes.Black, bounds.Left, y + 5);
        }

        graphics.DrawString("Timex", smallFont, Brushes.Gray, bounds.Left, bounds.Bottom - 16);
        e.HasMorePages = false;
    }

    private sealed record ReportOption(int? Id, string Name);
}
