using System.Globalization;
using Microsoft.Data.Sqlite;
using Timex.Models;

namespace Timex.Data;

public sealed class TimexDatabase
{
    private readonly string _connectionString;

    public TimexDatabase(string databasePath)
    {
        var directory = Path.GetDirectoryName(databasePath);
        if (!string.IsNullOrEmpty(directory))
        {
            Directory.CreateDirectory(directory);
        }

        _connectionString = new SqliteConnectionStringBuilder
        {
            DataSource = databasePath,
            ForeignKeys = true,
            DefaultTimeout = 5
        }.ToString();

        Initialize();
    }

    public IReadOnlyList<LookupItem> GetLookupItems(LookupKind kind)
    {
        var (table, field) = GetLookupTable(kind);
        using var connection = OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = $"SELECT id, {field} FROM {table} ORDER BY {field} COLLATE NOCASE, id;";

        using var reader = command.ExecuteReader();
        var items = new List<LookupItem>();
        while (reader.Read())
        {
            items.Add(new LookupItem(reader.GetInt32(0), reader.GetString(1)));
        }

        return items;
    }

    public int AddLookupItem(LookupKind kind, string name)
    {
        var (table, field) = GetLookupTable(kind);
        using var connection = OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = $"INSERT INTO {table} ({field}) VALUES (@name);";
        command.Parameters.AddWithValue("@name", name.Trim());
        command.ExecuteNonQuery();
        using var idCommand = connection.CreateCommand();
        idCommand.CommandText = "SELECT last_insert_rowid();";
        return Convert.ToInt32(idCommand.ExecuteScalar(), CultureInfo.InvariantCulture);
    }

    public void RenameLookupItem(LookupKind kind, int id, string name)
    {
        var (table, field) = GetLookupTable(kind);
        using var connection = OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = $"UPDATE {table} SET {field} = @name WHERE id = @id;";
        command.Parameters.AddWithValue("@name", name.Trim());
        command.Parameters.AddWithValue("@id", id);
        command.ExecuteNonQuery();
    }

    public TimeSlip? GetSlip(int id)
    {
        using var connection = OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = """
            SELECT id, consultant_id, client_id, job_id, slip_date, hours, minutes, text, deleted
            FROM slips
            WHERE id = @id;
            """;
        command.Parameters.AddWithValue("@id", id);
        using var reader = command.ExecuteReader();
        return reader.Read() ? ReadSlip(reader) : null;
    }

    public int? GetAdjacentSlipId(int id, bool forward)
    {
        using var connection = OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = forward
            ? "SELECT id FROM slips WHERE id > @id ORDER BY id LIMIT 1;"
            : "SELECT id FROM slips WHERE id < @id ORDER BY id DESC LIMIT 1;";
        command.Parameters.AddWithValue("@id", id);
        var value = command.ExecuteScalar();
        return value is null or DBNull ? null : Convert.ToInt32(value, CultureInfo.InvariantCulture);
    }

    public int? GetBoundarySlipId(bool last)
    {
        using var connection = OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = last
            ? "SELECT id FROM slips ORDER BY id DESC LIMIT 1;"
            : "SELECT id FROM slips ORDER BY id LIMIT 1;";
        var value = command.ExecuteScalar();
        return value is null or DBNull ? null : Convert.ToInt32(value, CultureInfo.InvariantCulture);
    }

    public int SaveSlip(TimeSlip slip)
    {
        using var connection = OpenConnection();
        using var command = connection.CreateCommand();
        if (slip.Id == 0)
        {
            command.CommandText = """
                INSERT INTO slips
                    (consultant_id, client_id, job_id, slip_date, hours, minutes, text, deleted)
                VALUES
                    (@consultant_id, @client_id, @job_id, @slip_date, @hours, @minutes, @text, @deleted);
                """;
        }
        else
        {
            command.CommandText = """
                UPDATE slips
                SET consultant_id = @consultant_id,
                    client_id = @client_id,
                    job_id = @job_id,
                    slip_date = @slip_date,
                    hours = @hours,
                    minutes = @minutes,
                    text = @text,
                    deleted = @deleted
                WHERE id = @id;
                """;
        }

        AddSlipParameters(command, slip);
        if (slip.Id == 0)
        {
            command.ExecuteNonQuery();
            using var idCommand = connection.CreateCommand();
            idCommand.CommandText = "SELECT last_insert_rowid();";
            return Convert.ToInt32(idCommand.ExecuteScalar(), CultureInfo.InvariantCulture);
        }

        command.Parameters.AddWithValue("@id", slip.Id);
        if (command.ExecuteNonQuery() != 1)
        {
            throw new InvalidOperationException($"Slip {slip.Id} no longer exists.");
        }

        return slip.Id;
    }

    public void SetSlipDeleted(int id, bool deleted)
    {
        using var connection = OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = "UPDATE slips SET deleted = @deleted WHERE id = @id;";
        command.Parameters.AddWithValue("@deleted", deleted ? 1 : 0);
        command.Parameters.AddWithValue("@id", id);
        command.ExecuteNonQuery();
    }

    public IReadOnlyList<SlipListItem> SearchSlips(
        int? consultantId = null,
        int? clientId = null,
        DateOnly? from = null,
        DateOnly? to = null,
        int startId = 1,
        bool includeDeleted = true)
    {
        using var connection = OpenConnection();
        using var command = connection.CreateCommand();
        var conditions = new List<string> { "s.id >= @start_id" };
        command.Parameters.AddWithValue("@start_id", Math.Max(1, startId));

        if (consultantId.HasValue)
        {
            conditions.Add("s.consultant_id = @consultant_id");
            command.Parameters.AddWithValue("@consultant_id", consultantId.Value);
        }

        if (clientId.HasValue)
        {
            conditions.Add("s.client_id = @client_id");
            command.Parameters.AddWithValue("@client_id", clientId.Value);
        }

        if (from.HasValue)
        {
            conditions.Add("s.slip_date >= @from");
            command.Parameters.AddWithValue("@from", FormatDate(from.Value));
        }

        if (to.HasValue)
        {
            conditions.Add("s.slip_date <= @to");
            command.Parameters.AddWithValue("@to", FormatDate(to.Value));
        }

        if (!includeDeleted)
        {
            conditions.Add("s.deleted = 0");
        }

        command.CommandText = SlipDetailsQuery + " WHERE " + string.Join(" AND ", conditions) +
                              " ORDER BY s.slip_date, s.client_id, s.job_id, s.id;";
        using var reader = command.ExecuteReader();
        var results = new List<SlipListItem>();
        while (reader.Read())
        {
            results.Add(ReadSlipListItem(reader));
        }

        return results;
    }

    public string? GetPreference(string key)
    {
        using var connection = OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = "SELECT value FROM preferences WHERE key = @key;";
        command.Parameters.AddWithValue("@key", key);
        return command.ExecuteScalar() as string;
    }

    public void SetPreference(string key, string value)
    {
        using var connection = OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = """
            INSERT INTO preferences (key, value) VALUES (@key, @value)
            ON CONFLICT(key) DO UPDATE SET value = excluded.value;
            """;
        command.Parameters.AddWithValue("@key", key);
        command.Parameters.AddWithValue("@value", value);
        command.ExecuteNonQuery();
    }

    private void Initialize()
    {
        using var connection = OpenConnection();
        using var command = connection.CreateCommand();
        command.CommandText = """
            PRAGMA journal_mode = WAL;

            CREATE TABLE IF NOT EXISTS consultants (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL COLLATE NOCASE UNIQUE
            );

            CREATE TABLE IF NOT EXISTS clients (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                code TEXT NOT NULL COLLATE NOCASE UNIQUE
            );

            CREATE TABLE IF NOT EXISTS jobs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                description TEXT NOT NULL COLLATE NOCASE UNIQUE
            );

            CREATE TABLE IF NOT EXISTS slips (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                consultant_id INTEGER NOT NULL REFERENCES consultants(id),
                client_id INTEGER NOT NULL REFERENCES clients(id),
                job_id INTEGER NOT NULL REFERENCES jobs(id),
                slip_date TEXT NOT NULL,
                hours INTEGER NOT NULL CHECK (hours >= 0),
                minutes INTEGER NOT NULL CHECK (minutes BETWEEN 0 AND 59),
                text TEXT NOT NULL DEFAULT '',
                deleted INTEGER NOT NULL DEFAULT 0 CHECK (deleted IN (0, 1))
            );

            CREATE INDEX IF NOT EXISTS ix_slips_date ON slips(slip_date, id);
            CREATE INDEX IF NOT EXISTS ix_slips_consultant ON slips(consultant_id, slip_date);
            CREATE INDEX IF NOT EXISTS ix_slips_client ON slips(client_id, slip_date);

            CREATE TABLE IF NOT EXISTS preferences (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
            );
            """;
        command.ExecuteNonQuery();
    }

    private SqliteConnection OpenConnection()
    {
        var connection = new SqliteConnection(_connectionString);
        connection.Open();
        return connection;
    }

    private static void AddSlipParameters(SqliteCommand command, TimeSlip slip)
    {
        command.Parameters.AddWithValue("@consultant_id", slip.ConsultantId);
        command.Parameters.AddWithValue("@client_id", slip.ClientId);
        command.Parameters.AddWithValue("@job_id", slip.JobId);
        command.Parameters.AddWithValue("@slip_date", FormatDate(slip.Date));
        command.Parameters.AddWithValue("@hours", slip.Hours);
        command.Parameters.AddWithValue("@minutes", slip.Minutes);
        command.Parameters.AddWithValue("@text", slip.Text);
        command.Parameters.AddWithValue("@deleted", slip.Deleted ? 1 : 0);
    }

    private static TimeSlip ReadSlip(SqliteDataReader reader) =>
        new(
            reader.GetInt32(0),
            reader.GetInt32(1),
            reader.GetInt32(2),
            reader.GetInt32(3),
            DateOnly.ParseExact(reader.GetString(4), "yyyy-MM-dd", CultureInfo.InvariantCulture),
            reader.GetInt32(5),
            reader.GetInt32(6),
            reader.GetString(7),
            reader.GetInt32(8) != 0);

    private static SlipListItem ReadSlipListItem(SqliteDataReader reader) =>
        new(
            reader.GetInt32(0),
            reader.GetInt32(1),
            reader.GetString(2),
            reader.GetInt32(3),
            reader.GetString(4),
            reader.GetInt32(5),
            reader.GetString(6),
            DateOnly.ParseExact(reader.GetString(7), "yyyy-MM-dd", CultureInfo.InvariantCulture),
            reader.GetInt32(8),
            reader.GetInt32(9),
            reader.GetString(10),
            reader.GetInt32(11) != 0);

    private static string FormatDate(DateOnly date) =>
        date.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

    private static (string Table, string Field) GetLookupTable(LookupKind kind) =>
        kind switch
        {
            LookupKind.Consultant => ("consultants", "name"),
            LookupKind.Client => ("clients", "code"),
            LookupKind.Job => ("jobs", "description"),
            _ => throw new ArgumentOutOfRangeException(nameof(kind))
        };

    private const string SlipDetailsQuery = """
        SELECT s.id, s.consultant_id, c.name, s.client_id, cl.code, s.job_id, j.description,
               s.slip_date, s.hours, s.minutes, s.text, s.deleted
        FROM slips s
        JOIN consultants c ON c.id = s.consultant_id
        JOIN clients cl ON cl.id = s.client_id
        JOIN jobs j ON j.id = s.job_id
        """;
}
