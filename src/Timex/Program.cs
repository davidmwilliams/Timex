using Timex.Data;
using Timex.Forms;
using Microsoft.Data.Sqlite;

namespace Timex;

internal static class Program
{
    [STAThread]
    private static void Main()
    {
        ApplicationConfiguration.Initialize();
        var databasePath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "Timex",
            "timex.sqlite");
        TimexDatabase database;
        try
        {
            database = new TimexDatabase(databasePath);
        }
        catch (Exception exception) when (
            exception is SqliteException or IOException or UnauthorizedAccessException)
        {
            MessageBox.Show(
                $"Timex could not open its local database at:\n{databasePath}\n\n{exception.Message}",
                "Timex",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error);
            return;
        }

        Application.Run(new MainForm(database));
    }
}
