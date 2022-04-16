# Timex
A consultant's time tracker for projects, activities, etc.

This is a Delphi project I wrote from 1998 to 2000, used for time tracking. It provided a fast user interface to allow users to easily and efficiently record time against different projects.

It should still compile fine in modern versions of Delphi, except these things will need to be changed:

## Database
The database was Paradox and will need to be recreated in something else now. From the 'emptydb' folder we can see there are four tables: consultants, clients, jobs, slips - the "slips" being timeslip entries that tie together a consultant's time against a job for a client. Looking at the code now (22 years later ...) I can see these are the tables and fields I used:

* consultants - id, name
* jobs - id, description
* clients - id, code
* slips - id, consultantid, clientid, jobid, date, hours, minutes, text, deleted

## Reports
I used QuickReports at the time, which used to be bundled with Delphi. There are reports for timesheets and invoices (the latter being interesting, given I don't see a field for consultant rate in the above tables). The reports would need to be migrated to something else.

## Other notes
I like my Delphi style, if I am allowed to say that, and I hope anybody looking at the code will see a tidy approach to separating methods, to indentation and general formatting, etc.

There's a curious thing in the main form where I seem to save the latest record numbers to the registry instead of using max(...) from the database. I don't know now why I did that.
