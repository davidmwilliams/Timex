UNIT frmFind;

{==============================================================================}
INTERFACE

USES
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Spin, ExtCtrls, checklst, Menus;

type
  TFindFrm = class(TForm)
    bFindNow: TButton;
    bNewSearch: TButton;
    aviFind: TAnimate;
    pgFind: TPageControl;
    tsSlipDetails: TTabSheet;
    tsDates: TTabSheet;
    rbAllDates: TRadioButton;
    rbSpecificDates: TRadioButton;
    Panel1: TPanel;
    lbAnd: TLabel;
    lbMonths: TLabel;
    lbDays: TLabel;
    rbBetween: TRadioButton;
    eFrom: TEdit;
    eTo: TEdit;
    seMonths: TSpinEdit;
    rbMonths: TRadioButton;
    rbDays: TRadioButton;
    seDays: TSpinEdit;
    gbConsultants: TGroupBox;
    gbClients: TGroupBox;
    clbConsultants: TCheckListBox;
    clbClients: TCheckListBox;
    PopupMenu1: TPopupMenu;
    Selectall1: TMenuItem;
    Deselectall1: TMenuItem;
    Invertselection1: TMenuItem;
    PopupMenu2: TPopupMenu;
    Selectall2: TMenuItem;
    Deselectall2: TMenuItem;
    Invertselection2: TMenuItem;
    bClose: TButton;
    lbResults: TListBox;
    tsAdvanced: TTabSheet;
    Label1: TLabel;
    seStartSlip: TSpinEdit;
    procedure FormShow(Sender: TObject);
    procedure rbAllDatesClick(Sender: TObject);
    procedure rbSpecificDatesClick(Sender: TObject);
    procedure rbBetweenClick(Sender: TObject);
    procedure rbMonthsClick(Sender: TObject);
    procedure rbDaysClick(Sender: TObject);
    procedure Selectall1Click(Sender: TObject);
    procedure Deselectall1Click(Sender: TObject);
    procedure Invertselection1Click(Sender: TObject);
    procedure Selectall2Click(Sender: TObject);
    procedure Deselectall2Click(Sender: TObject);
    procedure Invertselection2Click(Sender: TObject);
    procedure bCloseClick(Sender: TObject);
    procedure bNewSearchClick(Sender: TObject);
    procedure bFindNowClick(Sender: TObject);
    procedure lbResultsDblClick(Sender: TObject);

  private
    procedure Invert (clb: TCheckListBox);
    procedure SetAll (clb: TCheckListBox; b: boolean);
    procedure FillListBox (clbBox: TCheckListBox; tblName, tblField: String);
    function ValidateDate (aDate: TDateTime): boolean;

  public

  end;

var
  FindFrm: TFindFrm;

{==============================================================================}
IMPLEMENTATION

uses frmMain;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TFindFrm.FormShow(Sender: TObject);
begin
  bNewSearchClick (Sender)
end;

//------------------------------------------------------------------------------
procedure TFindFrm.bNewSearchClick(Sender: TObject);
var
  Year, Month, Day: Word;

begin
  pgFind.ActivePage := tsSlipDetails;
  FillListBox (clbConsultants, 'CONSULTANTS', 'NAME');
  FillListBox (clbClients, 'CLIENTS', 'CODE');
  rbBetween.Checked := True;
  rbAllDates.Checked := True;
  rbAllDatesClick (Sender);
  eTo.Text := DateToStr (Now);
  DecodeDate (Now, Year, Month, Day);
  eFrom.Text := DateToStr (EncodeDate (Year, Month, 1));
  seMonths.Value := 1;
  seDays.Value := 1;
  seStartSlip.Value := 1;
  aviFind.Visible := False;
  lbResults.Items.Clear
end;

//------------------------------------------------------------------------------
procedure TFindFrm.rbAllDatesClick(Sender: TObject);
begin
  if rbAllDates.Checked then
  begin
    rbBetween.Enabled := False;
    rbMonths.Enabled := False;
    rbDays.Enabled := False;
    eFrom.Enabled := False;
    eTo.Enabled := False;
    seMonths.Enabled := False;
    seDays.Enabled := False;
    lbAnd.Enabled := False;
    lbMonths.Enabled := False;
    lbDays.Enabled := False;
  end
end;

//------------------------------------------------------------------------------
procedure TFindFrm.rbSpecificDatesClick(Sender: TObject);
begin
  if rbSpecificDates.Checked then
  begin
    rbBetween.Enabled := True;
    rbMonths.Enabled := True;
    rbDays.Enabled := True;

    if rbBetween.Checked then
      rbBetweenClick (Sender)
    else if rbMonths.Checked then
      rbMonthsClick (Sender)
    else if rbDays.Checked then
      rbDaysClick (Sender)
  end
end;

//------------------------------------------------------------------------------
procedure TFindFrm.rbBetweenClick(Sender: TObject);
begin
  if rbBetween.Checked then
  begin
    eFrom.Enabled := True;
    eTo.Enabled := True;
    seMonths.Enabled := False;
    seDays.Enabled := False;
    lbAnd.Enabled := True;
    lbMonths.Enabled := False;
    lbDays.Enabled := False;
  end
end;

//------------------------------------------------------------------------------
procedure TFindFrm.rbMonthsClick(Sender: TObject);
begin
  if rbMonths.Checked then
  begin
    eFrom.Enabled := False;
    eTo.Enabled := False;
    seMonths.Enabled := True;
    seDays.Enabled := False;
    lbAnd.Enabled := False;
    lbMonths.Enabled := True;
    lbDays.Enabled := False;
  end
end;

//------------------------------------------------------------------------------
procedure TFindFrm.rbDaysClick(Sender: TObject);
begin
  if rbDays.Checked then
  begin
    eFrom.Enabled := False;
    eTo.Enabled := False;
    seMonths.Enabled := False;
    seDays.Enabled := True;
    lbAnd.Enabled := False;
    lbMonths.Enabled := False;
    lbDays.Enabled := True;
  end
end;

//------------------------------------------------------------------------------
procedure TFindFrm.FillListBox (clbBox: TCheckListBox; tblName, tblField: String);
var
  i: integer;

begin
  clbBox.Items.Clear;
  with Main.Query do
  begin
    SQL.Clear;
    SQL.Add ('select ' + tblField + ' from ' + tblName);
    Active := True;
    i := 0;
    First;
    while not eof do
    begin
      clbBox.Items.Add (FieldByName (tblField).AsString);
      clbBox.Checked [i] := True;
      Inc (i);
      Next
    end;
    Active := False
  end;
end;

//------------------------------------------------------------------------------
procedure TFindFrm.Selectall1Click(Sender: TObject);
begin
  SetAll (clbConsultants, True)
end;

//------------------------------------------------------------------------------
procedure TFindFrm.Deselectall1Click(Sender: TObject);
begin
  SetAll (clbConsultants, False)
end;

//------------------------------------------------------------------------------
procedure TFindFrm.Invertselection1Click(Sender: TObject);
begin
  Invert (clbConsultants)
end;

//------------------------------------------------------------------------------
procedure TFindFrm.Selectall2Click(Sender: TObject);
begin
  SetAll (clbClients, True)
end;

//------------------------------------------------------------------------------
procedure TFindFrm.Deselectall2Click(Sender: TObject);
begin
  SetAll (clbClients, False)
end;

//------------------------------------------------------------------------------
procedure TFindFrm.Invertselection2Click(Sender: TObject);
begin
  Invert (clbClients)
end;

//------------------------------------------------------------------------------
procedure TFindFrm.SetAll (clb: TCheckListBox; b: boolean);
var
  i: integer;

begin
  for i := 0 to clb.Items.Count - 1 do
    clb.Checked [i] := b
end;

//------------------------------------------------------------------------------
procedure TFindFrm.Invert (clb: TCheckListBox);
var
  i: integer;

begin
  for i := 0 to clb.Items.Count - 1 do
    clb.Checked [i] := not clb.Checked [i]
end;

//------------------------------------------------------------------------------
procedure TFindFrm.bCloseClick(Sender: TObject);
begin
  Close
end;

//------------------------------------------------------------------------------
procedure TFindFrm.bFindNowClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  aviFind.Active := True;
  aviFind.Visible := True;
  lbResults.Items.Clear;

  with Main.Query do
  begin
    SQL.Clear;
    SQL.Add ('select * from SLIPS');
    SQL.Add ('where ID >= ' + IntToStr (seStartSlip.Value));
    Active := True;
    
    First;
    while not eof do
    begin
      if clbConsultants.Checked [FieldByName ('CONSULTANTID').AsInteger - 1] and
        clbClients.Checked [FieldByName ('CLIENTID').AsInteger - 1] and
        ValidateDate (FieldByName ('DATE').AsDateTime) then
      begin
        lbResults.Items.Add (FieldByName ('ID').AsString + ' - ' +
          FieldByName ('TEXT').AsString);
      end;
      Next
    end;

    Active := False
  end;

  aviFind.Visible := False;
  aviFind.Active := False;
  Screen.Cursor := crDefault;
end;

//------------------------------------------------------------------------------
function TFindFrm.ValidateDate (aDate: TDateTime): boolean;
var
  Day, Month, Year: Word;
  FromDate, ToDate: TDateTime;

begin
  ValidateDate := False;

  if rbAllDates.Checked then
    ValidateDate := True
  else
  begin
    if rbBetween.Checked then
    begin
      FromDate := StrToDate (eFrom.Text);
      ToDate := StrToDate (eTo.Text);
    end
    else
    begin
      ToDate := Now;

      if rbMonths.Checked then
      begin
        DecodeDate (Now, Year, Month, Day);
        if Month in [1, 3, 5, 7, 8, 10, 12] then
          FromDate := Now - 31
        else if Month in [4, 6, 9, 11] then
          FromDate := Now - 30
        else
          FromDate := Now - 28
      end
      else
        FromDate := Now - 1
    end;

    if (aDate >= FromDate) and (aDate <= ToDate) then
      ValidateDate := True
  end
end;

//------------------------------------------------------------------------------
procedure TFindFrm.lbResultsDblClick(Sender: TObject);
var
  i, j: integer;
  s: String;

begin
  if lbResults.ItemIndex < lbResults.Items.Count then
  begin
    s := lbResults.Items [lbResults.ItemIndex];
    i := pos (' - ', s);
    j := StrToInt (copy (s, 1, i - 1));
    Main.LoadSlip (j)
  end
end;

END.
