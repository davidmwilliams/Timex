UNIT dlgJobs;

{==============================================================================}
INTERFACE

USES
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TJobs = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    lbJobs: TListBox;
    AddBtn: TButton;
    procedure AddBtnClick(Sender: TObject);
    procedure lbJobsDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Jobs: TJobs;

{==============================================================================}
IMPLEMENTATION

USES
  frmMain, Dialogs;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TJobs.AddBtnClick(Sender: TObject);
var
  s: String;

begin
  s := InputBox (Application.Title, 'Enter the name of the new job', '');
  if s <> '' then
  with Main.Query do
  begin
    SQL.Clear;
    SQL.Add ('insert into JOBS (DESCRIPTION) VALUES (''' + s + ''')');
    ExecSQL;
    Active := False;
    lbJobs.Items.Add (s);
    lbJobs.ItemIndex := lbJobs.Items.Count - 1
  end;
end;

//------------------------------------------------------------------------------
procedure TJobs.lbJobsDblClick(Sender: TObject);
var
  s: String;

begin
  if lbJobs.ItemIndex < lbJobs.Items.Count then
  begin
    s := InputBox (Application.Title, 'Enter the new name for this job',
        lbJobs.Items [lbJobs.ItemIndex]);
    if (s <> lbJobs.Items [lbJobs.ItemIndex]) and (s <> '') then
    with Main.Query do
    begin
      SQL.Clear;
      SQL.Add ('update JOBS set DESCRIPTION = ''' + s + '''');
      SQL.Add ('where ID = ' + IntToStr (lbJobs.ItemIndex + 1));
      ExecSQL;
      Active := False;
      lbJobs.Items [lbJobs.ItemIndex] := s;
    end
  end
end;

END.
