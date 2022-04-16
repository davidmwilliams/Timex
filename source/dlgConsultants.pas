UNIT dlgConsultants;

{==============================================================================}
INTERFACE

USES
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TConsultants = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    lbConsultants: TListBox;
    AddBtn: TButton;
    procedure AddBtnClick(Sender: TObject);
    procedure lbConsultantsDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Consultants: TConsultants;

{==============================================================================}
IMPLEMENTATION

USES
  frmMain, Dialogs;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TConsultants.AddBtnClick(Sender: TObject);
var
  s: String;

begin
  s := InputBox (Application.Title, 'Enter the name of the new consultant', '');
  if s <> '' then
  with Main.Query do
  begin
    SQL.Clear;
    SQL.Add ('insert into CONSULTANTS (NAME) VALUES (''' + s + ''')');
    ExecSQL;
    Active := False;
    lbConsultants.Items.Add (s);
    lbConsultants.ItemIndex := lbConsultants.Items.Count - 1
  end;
end;

procedure TConsultants.lbConsultantsDblClick(Sender: TObject);
var
  s: String;

begin
  if lbConsultants.ItemIndex < lbConsultants.Items.Count then
  begin
    s := InputBox (Application.Title, 'Enter the new name for this consultant',
        lbConsultants.Items [lbConsultants.ItemIndex]);
    if (s <> lbConsultants.Items [lbConsultants.ItemIndex]) and (s <> '') then
    with Main.Query do
    begin
      SQL.Clear;
      SQL.Add ('update CONSULTANTS set NAME = ''' + s + '''');
      SQL.Add ('where ID = ' + IntToStr (lbConsultants.ItemIndex + 1));
      ExecSQL;
      Active := False;
      lbConsultants.Items [lbConsultants.ItemIndex] := s;
    end
  end
end;

END.
