UNIT frmMain;

{==============================================================================}
INTERFACE

USES
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ToolWin, Menus, DBTables, Db, StdCtrls, ExtCtrls, Spin,
  Buttons;

const
  Unerase_Msg = 'Un&erase slip';
  Erase_Msg = '&Erase slip';
  App_Name = 'Timex';
  Secret_Name = 'ms-tnef';

type
  TMain = class(TForm)
    StatusBar: TStatusBar;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Tools1: TMenuItem;
    Help1: TMenuItem;
    Contents1: TMenuItem;
    Keyviard1: TMenuItem;
    Index1: TMenuItem;
    Search1: TMenuItem;
    N5: TMenuItem;
    About1: TMenuItem;
    Register1: TMenuItem;
    Newdatabase1: TMenuItem;
    Slips1: TMenuItem;
    Newslip1: TMenuItem;
    Duplicateslip1: TMenuItem;
    Eraseslip1: TMenuItem;
    Report1: TMenuItem;
    Timesheet1: TMenuItem;
    Invoice1: TMenuItem;
    Newconsultant1: TMenuItem;
    Newclient1: TMenuItem;
    Newjob1: TMenuItem;
    tblSlips: TTable;
    gbData: TGroupBox;
    bConsultant: TButton;
    bClient: TButton;
    bJob: TButton;
    eConsultant: TEdit;
    eClient: TEdit;
    eJob: TEdit;
    gbDetails: TGroupBox;
    gbDate: TGroupBox;
    Label1: TLabel;
    eDate: TEdit;
    seHours: TSpinEdit;
    seMinutes: TSpinEdit;
    Label2: TLabel;
    Label3: TLabel;
    Query: TQuery;
    mSlip: TEdit;
    Findslip1: TMenuItem;
    gbSlipNo: TGroupBox;
    FirstBtn: TBitBtn;
    PrevBtn: TBitBtn;
    NextBtn: TBitBtn;
    LastBtn: TBitBtn;
    lblDelFlag: TLabel;
    N1: TMenuItem;
    Exportalldata1: TMenuItem;
    SaveDialog1: TSaveDialog;
    mExport: TMemo;
    lblDirty: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure eConsultantChange(Sender: TObject);
    procedure bConsultantClick(Sender: TObject);
    procedure bClientClick(Sender: TObject);
    procedure bJobClick(Sender: TObject);
    procedure FirstBtnClick(Sender: TObject);
    procedure PrevBtnClick(Sender: TObject);
    procedure NextBtnClick(Sender: TObject);
    procedure LastBtnClick(Sender: TObject);
    procedure Newslip1Click(Sender: TObject);
    procedure Duplicateslip1Click(Sender: TObject);
    procedure Newconsultant1Click(Sender: TObject);
    procedure Newclient1Click(Sender: TObject);
    procedure Newjob1Click(Sender: TObject);
    procedure Eraseslip1Click(Sender: TObject);
    procedure Timesheet1Click(Sender: TObject);
    procedure Invoice1Click(Sender: TObject);
    procedure Register1Click(Sender: TObject);
    procedure Findslip1Click(Sender: TObject);
    procedure Exportalldata1Click(Sender: TObject);
    procedure Newdatabase1Click(Sender: TObject);

  private
    RecNo, MaxRec: integer;
    ClientID: integer;
    JobID: integer;
    New: boolean;
    FDirty: boolean;
    ConsultantsListBoxFilled, ClientsListBoxFilled,
      JobsListBoxFilled: boolean;

    procedure setDirty (Dirty: boolean);
    procedure ShowHint(Sender: TObject);
    procedure CreateNewSlip;
    procedure SaveRec;
    procedure FillListBox (lBox: TListBox; iID: integer;
              tblName, tblField: String; var ListBoxFilled: boolean);
    procedure SetSlipNoCaption (sn: integer);
    procedure SetRegistered (RegName: String);

  protected
    property Dirty: boolean read FDirty write setDirty;

  public
    ConsultantID: integer;

    procedure LoadSlip (Rec: integer);
    function getConsultantStr (cID: integer): String;
    function getClientStr (cID: integer): String;
    function getJobStr (jID: integer): String;
    function Max4 (i1, i2, i3, i4: integer): integer;
    function Max2 (i1, i2: integer): integer;

  end;

var
  Main: TMain;

{==============================================================================}
IMPLEMENTATION

USES
  AboutScrn, WinReg, dlgConsultants, dlgClients, dlgJobs, frmTimeSheetCfg,
  frmInvoiceCfg, uRegister, frmFind;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Reg: TWinRegistry;

begin
  if Dirty then
    SaveRec;
    
  Reg := TWinRegistry.Create ('Software\Timex');

  with Reg do
  begin
    WriteInteger ('LastIDs', 'ConsultantID', ConsultantID);
    WriteInteger ('LastIDs', 'ClientID', ClientID);
    WriteInteger ('LastIDs', 'RecordNo', RecNo);
  end;

  Reg.Free;

  tblSlips.Active := False
end;

//------------------------------------------------------------------------------
procedure TMain.SetDirty (Dirty: boolean);
begin
  FDirty := Dirty;
  lblDirty.Visible := Dirty
end;

//------------------------------------------------------------------------------
procedure TMain.FormCreate(Sender: TObject);
begin
  Session.AddPassword ('timecard');
  Application.OnHint := ShowHint;

  try
    tblSlips.Active := True;
    with Query do
    begin
      SQL.Clear;
      SQL.Add ('select MAX (ID) from SLIPS');
      Active := True;
      MaxRec := Fields [0].AsInteger;
      Active := False
    end;
  except
  end
end;

//------------------------------------------------------------------------------
procedure TMain.ShowHint(Sender: TObject);
begin
  StatusBar.Panels [0].Text := Application.Hint
end;

//------------------------------------------------------------------------------
procedure TMain.FormShow(Sender: TObject);
var
  RegName: String;
  Reg: TWinRegistry;

begin
  if RegisterDlg.isRegistered (App_Name, Secret_Name, RegName) then
    SetRegistered (RegName);

  Reg := TWinRegistry.Create ('Software\Timex');

  with Reg do
  begin
    ConsultantID := ReadInteger ('LastIDs', 'ConsultantID', 1);
    ClientID := ReadInteger ('LastIDs', 'ClientID', 1);
    RecNo := ReadInteger ('LastIDs', 'RecordNo', 1);
  end;

  Reg.Free;

  if not tblSlips.Active then
  begin
    ShowMessage ('A fatal database error has occurred; please ensure the ' +
      'database alias and files are not corrupt.');
    Close
  end;

  New := True;
  Dirty := False;

  ConsultantsListBoxFilled := False;
  ClientsListBoxFilled := False;
  JobsListBoxFilled := False;

  if MessageDlg ('Would you like to create a new slip?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    CreateNewSlip
  else
    LoadSlip (RecNo)
end;

//------------------------------------------------------------------------------
procedure TMain.About1Click(Sender: TObject);
begin
  AboutDlg.Show
end;

//------------------------------------------------------------------------------
procedure TMain.Exit1Click(Sender: TObject);
begin
  Close
end;

//------------------------------------------------------------------------------
procedure TMain.CreateNewSlip;
begin
  if Dirty then
    SaveRec;

  FirstBtn.Enabled := True;
  PrevBtn.Enabled := True;

  gbSlipNo.Caption := 'New slip';
  eConsultant.Text := getConsultantStr (ConsultantID);
  eClient.Text := getClientStr (ClientID);
  eJob.Text := '';
  if eDate.Text = '' then
    eDate.Text := DateToStr (Now);
  seHours.Value := 0;
  seMinutes.Value := 0;
  mSlip.Text := '';
  lblDelFlag.Visible := False;
  Dirty := False;
  New := True
end;

//------------------------------------------------------------------------------
function TMain.getConsultantStr (cID: integer): String;
begin
  getConsultantStr := '';
  with Query do
  begin
    SQL.Clear;
    SQL.Add ('select NAME from CONSULTANTS');
    SQL.Add ('where ID = ' + IntToStr (cID));
    Active := True;
    if not eof then
      getConsultantStr := FieldByName ('NAME').AsString;
    Active := False
  end;
end;

//------------------------------------------------------------------------------
function TMain.getClientStr (cID: integer): String;
begin
  getClientStr := '';
  with Query do
  begin
    SQL.Clear;
    SQL.Add ('select CODE from CLIENTS');
    SQL.Add ('where ID = ' + IntToStr (cID));
    Active := True;
    if not eof then
      getClientStr := FieldByName ('CODE').AsString;
    Active := False
  end;
end;

//------------------------------------------------------------------------------
function TMain.getJobStr (jID: integer): String;
begin
  getJobStr := '';
  with Query do
  begin
    SQL.Clear;
    SQL.Add ('select DESCRIPTION from JOBS');
    SQL.Add ('where ID = ' + IntToStr (jID));
    Active := True;
    if not eof then
      getJobStr := FieldByName ('DESCRIPTION').AsString;
    Active := False
  end;
end;

//------------------------------------------------------------------------------
procedure TMain.eConsultantChange(Sender: TObject);
begin
  Dirty := True
end;

//------------------------------------------------------------------------------
procedure TMain.LoadSlip (Rec: integer);
begin
  if Dirty then
    SaveRec;

  with tblSlips do
  begin
// Load a specific record, using the quickest way based on the current record.
    if Rec < (FieldByName ('ID').AsInteger div 2) then
      First
    else if Rec > (MaxRec - (FieldByName ('ID').AsInteger div 2)) then
      Last;

    while not eof and (Rec > FieldByName ('ID').AsInteger) do
      Next;

    while not bof and (Rec < FieldByName ('ID').AsInteger) do
      Prior;

// Get the slip's information
    if Rec = FieldByName ('ID').AsInteger then
    begin
      SetSlipNoCaption (FieldByName ('ID').AsInteger);
      ConsultantID := FieldByName ('CONSULTANTID').AsInteger;
      eConsultant.Text := getConsultantStr (ConsultantID);
      ClientID := FieldByName ('CLIENTID').AsInteger;
      eClient.Text := getClientStr (ClientID);
      JobID := FieldByName ('JOBID').AsInteger;
      eJob.Text := getJobStr (JobID);
      eDate.Text := DateToStr (FieldByName ('DATE').AsDateTime);
      seHours.Value := FieldByName ('HOURS').AsInteger;
      seMinutes.Value := FieldByName ('MINUTES').AsInteger;
      mSlip.Text := FieldByName ('TEXT').AsString;
      lblDelFlag.Visible := FieldByName ('DELETED').AsBoolean;
    end
  end;

  if lblDelFlag.Visible then
    Eraseslip1.Caption := Unerase_Msg
  else
    Eraseslip1.Caption := Erase_Msg;
    
  New := False;
  Dirty := False
end;

//------------------------------------------------------------------------------
procedure TMain.SaveRec;
begin
  if New then
  begin
    tblSlips.Append;
    Inc (MaxRec);
    RecNo := tblSlips.FieldByName ('ID').AsInteger;
    SetSlipNoCaption (RecNo)
  end
  else
    tblSlips.Edit;

  with tblSlips do
  begin
    FieldByName ('CONSULTANTID').AsInteger := ConsultantID;
    FieldByName ('CLIENTID').AsInteger := ClientID;
    FieldByName ('JOBID').AsInteger := JobID;
    FieldByName ('DATE').AsDateTime := StrToDateTime (eDate.Text);
    FieldByName ('HOURS').AsInteger := seHours.Value;
    FieldByName ('MINUTES').AsInteger := seMinutes.Value;
    FieldByName ('TEXT').AsString := mSlip.Text;
  end;

  tblSlips.Post;

  New := False;
  Dirty := False
end;

//------------------------------------------------------------------------------
procedure TMain.bConsultantClick(Sender: TObject);
begin
  FillListBox (Consultants.lbConsultants, ConsultantID, 'CONSULTANTS',
    'NAME', ConsultantsListBoxFilled);
  if Consultants.ShowModal = mrOk then
  begin
    ConsultantID := Consultants.lbConsultants.ItemIndex + 1;
    eConsultant.Text := getConsultantStr (ConsultantID)
  end
end;

//------------------------------------------------------------------------------
procedure TMain.bClientClick(Sender: TObject);
begin
  FillListBox (Clients.lbClients, ClientID, 'CLIENTS', 'CODE', ClientsListBoxFilled);
  if Clients.ShowModal = mrOk then
  begin
    ClientID := Clients.lbClients.ItemIndex + 1;
    eClient.Text := getClientStr (ClientID)
  end
end;

//------------------------------------------------------------------------------
procedure TMain.bJobClick(Sender: TObject);
begin
  FillListBox (Jobs.lbJobs, JobID, 'JOBS', 'DESCRIPTION', JobsListBoxFilled);
  if Jobs.ShowModal = mrOk then
  begin
    JobID := Jobs.lbJobs.ItemIndex + 1;
    eJob.Text := getJobStr (JobID)
  end
end;

//------------------------------------------------------------------------------
procedure TMain.FillListBox (lBox: TListBox; iID: integer;
          tblName, tblField: String; var ListBoxFilled: boolean);
begin
  if not ListBoxFilled then
  begin
    lBox.Items.Clear;
    with Query do
    begin
      SQL.Clear;
      SQL.Add ('select ' + tblField + ' from ' + tblName);
      Active := True;
      First;
      while not eof do
      begin
        lBox.Items.Add (FieldByName (tblField).AsString);
        Next
      end;
      Active := False
    end;
    ListBoxFilled := True
  end;

  lBox.ItemIndex := iID - 1;
end;

//------------------------------------------------------------------------------
procedure TMain.SetSlipNoCaption (sn: integer);
begin
  gbSlipNo.Caption := 'Record #' + IntToStr (sn) + ' of ' + IntToStr (MaxRec);
  FirstBtn.Enabled := (sn > 1);
  PrevBtn.Enabled := (sn > 1);
  NextBtn.Enabled := (sn < MaxRec);
  LastBtn.Enabled := (sn < MaxRec);
end;

//------------------------------------------------------------------------------
procedure TMain.FirstBtnClick(Sender: TObject);
begin
  RecNo := 1;
  LoadSlip (RecNo)
end;

//------------------------------------------------------------------------------
procedure TMain.PrevBtnClick(Sender: TObject);
begin
  Dec (RecNo);
  LoadSlip (RecNo)
end;

//------------------------------------------------------------------------------
procedure TMain.NextBtnClick(Sender: TObject);
begin
  Inc (RecNo);
  LoadSlip (RecNo)
end;

//------------------------------------------------------------------------------
procedure TMain.LastBtnClick(Sender: TObject);
begin
  RecNo := MaxRec;
  LoadSlip (RecNo)
end;

//------------------------------------------------------------------------------
procedure TMain.Newslip1Click(Sender: TObject);
begin
  CreateNewSlip
end;

//------------------------------------------------------------------------------
procedure TMain.Duplicateslip1Click(Sender: TObject);
begin
  if Dirty then
    SaveRec;

  gbSlipNo.Caption := 'New slip';
  Dirty := False;
  New := True
end;

//------------------------------------------------------------------------------
procedure TMain.Newconsultant1Click(Sender: TObject);
begin
  Consultants.AddBtnClick (Sender)
end;

//------------------------------------------------------------------------------
procedure TMain.Newclient1Click(Sender: TObject);
begin
  Clients.AddBtnClick (Sender)
end;

//------------------------------------------------------------------------------
procedure TMain.Newjob1Click(Sender: TObject);
begin
  Jobs.AddBtnClick (Sender)
end;

//------------------------------------------------------------------------------
procedure TMain.Eraseslip1Click(Sender: TObject);
begin
  if Eraseslip1.Caption = Unerase_Msg then
  with tblSlips do
  begin
    Edit;
    FieldByName ('DELETED').AsBoolean := False;
    lblDelFlag.Visible := False;
    Eraseslip1.Caption := Erase_Msg
  end
  else if MessageDlg ('Are you sure you wish to delete this slip?',
        mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    Dirty := False;
    if not New then
    with tblSlips do
    begin
      Edit;
      FieldByName ('DELETED').AsBoolean := True;
      lblDelFlag.Visible := True;
      Eraseslip1.Caption := Unerase_Msg
    end
    else
      LoadSlip (RecNo)
  end
end;

//------------------------------------------------------------------------------
procedure TMain.Timesheet1Click(Sender: TObject);
begin
  TimeSheetCfg.Show
end;

//------------------------------------------------------------------------------
procedure TMain.Invoice1Click(Sender: TObject);
begin
  InvoiceCfg.Show
end;

//------------------------------------------------------------------------------
procedure TMain.Register1Click(Sender: TObject);
var
  RegName: String;

begin
  if RegisterDlg.Execute (App_Name, Secret_Name, RegName) then
    SetRegistered (RegName)
end;

//------------------------------------------------------------------------------
procedure TMain.SetRegistered (RegName: String);
begin
  Register1.Visible := False;
  AboutDlg.lblReg1.Caption := 'Registered to:';
  AboutDlg.lblReg2.Caption := RegName
end;

//------------------------------------------------------------------------------
procedure TMain.Findslip1Click(Sender: TObject);
begin
  FindFrm.Show
end;

//------------------------------------------------------------------------------
function TMain.Max4 (i1, i2, i3, i4: integer): integer;
begin
  Max4 := Max2 (Max2 (i1, i2), Max2 (i3, i4))
end;

//------------------------------------------------------------------------------
function TMain.Max2 (i1, i2: integer): integer;
begin
  if i1 > i2 then
    Max2 := i1
  else
    Max2 := i2
end;

//------------------------------------------------------------------------------
procedure TMain.Exportalldata1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    mExport.Lines.Clear;
    with Query do
    begin
      SQL.Clear;
      SQL.Add ('select * from SLIPS');
      SQL.Add ('inner join CONSULTANTS');
      SQL.Add ('on CONSULTANTID = CONSULTANTS.ID');
      SQL.Add ('inner join CLIENTS');
      SQL.Add ('on CLIENTID = CLIENTS.ID');
      SQL.Add ('inner join JOBS');
      SQL.Add ('on JOBID = JOBS.ID');
      Active := True;

      First;
      while not eof do
      begin
        mExport.Lines.Add (FieldByName ('DATE').AsString + chr (9) +
          FieldByName ('HOURS').AsString + chr (9) +
          FieldByName ('MINUTES').AsString + chr (9) +
//          FieldByName ('NAME').AsString + chr (9) +
          FieldByName ('CODE').AsString + chr (9) +
          FieldByName ('DESCRIPTION').AsString + chr (9) +
          FieldByName ('TEXT').AsString);
        Next
      end;
      Active := False;
    end;
    mExport.Lines.SaveToFile (SaveDialog1.FileName)
  end
end;

END.
