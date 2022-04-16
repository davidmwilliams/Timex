UNIT uSlip;

{==============================================================================}
INTERFACE

USES
  Classes, SysUtils;

type
  TSlipRec = class (TObject)

  private

  public
    Date: TDateTime;
    Hours: integer;
    Minutes: integer;
    ClientId: integer;
    JobId: integer;
    Text: String;
  end;

  
  TSlipList = class (TObject)

  private
    aList: TList;

  public
    procedure kill;
    procedure add (slip: TSlipRec);
    procedure sort;
    function count: integer;
    function get (i: integer): TSlipRec;
  end;

  function srCompare (Item1, Item2: Pointer): Integer;
  function Max4 (i1, i2, i3, i4: integer): integer;
  function Max2 (i1, i2: integer): integer;

{==============================================================================}
IMPLEMENTATION

//------------------------------------------------------------------------------
function Max4 (i1, i2, i3, i4: integer): integer;
begin
  Max4 := Max2 (Max2 (i1, i2), Max2 (i3, i4))
end;

//------------------------------------------------------------------------------
function Max2 (i1, i2: integer): integer;
begin
  if i1 > i2 then
    Max2 := i1
  else
    Max2 := i2
end;

{------------------------------------------------------------------------------}
procedure TSlipList.kill;
var
  i: integer;
  aRec: TSlipRec;

begin
  if aList <> nil then
  begin
    for i := aList.Count - 1 downto 0 do
    begin
      aRec := get (i);
      aRec.Free
    end;
    aList.Free
  end
end;

{------------------------------------------------------------------------------}
procedure TSlipList.add (slip: TSlipRec);
begin
  if aList = nil then
    aList := TList.Create;
  aList.Add (slip)
end;

{------------------------------------------------------------------------------}
procedure TSlipList.sort;
begin
  if aList <> nil then
    aList.Sort (srCompare)
end;

{------------------------------------------------------------------------------}
function srCompare (Item1, Item2: Pointer): Integer;
var
  i1, i2: TSlipRec;

begin
  i1 := TSlipRec (Item1);
  i2 := TSlipRec (Item2);

  if i1.Date < i2.Date then
    Result := -1
  else if i1.Date > i2.Date then
    Result := 1
  else {if i1.Date = i2.Date then}
  begin
    if i1.ClientID < i2.ClientID then
      Result := -1
    else if i1.ClientID > i2.ClientID then
      Result := 1
    else {if i1.ClientID = i2.ClientID then}
    begin
      if i1.JobID < i2.JobID then
        Result := -1
      else if i1.JobID > i2.JobID then
        Result := 1
      else {if i1.JobID = i2.JobID then}
        Result := 0
    end // if i1.ClientID
  end // if i1.Date
end;

{------------------------------------------------------------------------------}
function TSlipList.get (i: integer): TSlipRec;
begin
  if aList <> nil then
    get := TSlipRec (aList.List [i])
  else
    get := nil
end;

{------------------------------------------------------------------------------}
function TSlipList.count: integer;
begin
  if aList <> nil then
    count := aList.count
  else
    count := 0
end;

END.
