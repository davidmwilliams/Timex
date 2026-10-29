# Timex

Timex is a consultant time tracker originally written in Delphi (1998–2000). The original Delphi project and forms remain in the repository. A C#/.NET 10 Windows Forms version is in `src/Timex`.

The replacement keeps the original core workflows: create and duplicate time slips, browse and soft-delete/restore them, maintain consultants/clients/jobs, search by consultant/client/date, export tab-delimited data, and preview or print timesheets and invoices. Invoice output contains time entries only: the original data model has no rate, currency, or amount fields.

## Run the .NET version

Install the .NET 10 SDK on Windows, then run:

```powershell
dotnet restore Timex.sln
dotnet run --project src/Timex/Timex.csproj
```

The app creates its SQLite database on first run at `%LOCALAPPDATA%\Timex\timex.sqlite`. It requires no database server. SQLite tables and indexes are initialized automatically.

## Data migration

The new app does not read Paradox files. The checked-in `emptydb` directory contains the legacy Paradox database artifacts; preserve any populated Paradox database separately before replacing or retiring an old installation. A Paradox-to-SQLite importer is not included.

The SQLite schema mirrors the original logical data:

* `consultants`: `id`, `name`
* `clients`: `id`, `code`
* `jobs`: `id`, `description`
* `slips`: `id`, `consultant_id`, `client_id`, `job_id`, `slip_date`, `hours`, `minutes`, `text`, `deleted`

## Development

The Windows Forms UI targets `net10.0-windows`. The repository can be built with `dotnet build Timex.sln` on Windows or with the Windows targeting pack enabled on a supported non-Windows development host. The generated SQLite database is local application data and should be backed up like any other user data.
