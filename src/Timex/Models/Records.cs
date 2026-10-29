namespace Timex.Models;

public enum LookupKind
{
    Consultant,
    Client,
    Job
}

public sealed record LookupItem(int Id, string Name)
{
    public override string ToString() => Name;
}

public sealed record TimeSlip(
    int Id,
    int ConsultantId,
    int ClientId,
    int JobId,
    DateOnly Date,
    int Hours,
    int Minutes,
    string Text,
    bool Deleted);

public sealed record SlipListItem(
    int Id,
    int ConsultantId,
    string Consultant,
    int ClientId,
    string Client,
    int JobId,
    string Job,
    DateOnly Date,
    int Hours,
    int Minutes,
    string Text,
    bool Deleted)
{
    public override string ToString() =>
        $"{Id}  {Date:yyyy-MM-dd}  {Client}  {Job}  {Hours}:{Minutes:00}  {Text}";
}
