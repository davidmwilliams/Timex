UNIT frmTimeSheetCfg;

{==============================================================================}
INTERFACE

USES
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Spin, ExtCtrls, ExtDlgs, checklst, Menus;

type
  TTimeSheetCfg = class(TForm)
    pgTimesheet: TPageControl;
    tsData: TTabSheet;
    tsPage: TTabSheet;
    gbDates: TGroupBox;
    gbPrinterSettings: TGroupBox;
    GroupBox4: TGroupBox;
    HdngText: TEdit;
    HdngFntBtn: TButton;
    GroupBox6: TGroupBox;
    EntryText: TEdit;
    fbEntryText: TButton;
    JobDetails: TEdit;
    fbJobDetails: TButton;
    Dates: TEdit;
    fbDates: TButton;
    ClientDetails: TEdit;
    fbClientDetails: TButton;
    GroupBox2: TGroupBox;
    LogoImage: TImage;
    ImageName: TEdit;
    ImBrwseBtn: TButton;
    ImClearBtn: TButton;
    AlignGrp: TRadioGroup;
    GroupBox11: TGroupBox;
    HeightEdit: TSpinEdit;
    GroupBox3: TGroupBox;
    WidthEdit: TSpinEdit;
    GroupBox18: TGroupBox;
    FooterImage: TImage;
    FooterImageName: TEdit;
    FtBrwseBtn: TButton;
    FtClearBtn: TButton;
    FooterAlignGrp: TRadioGroup;
    GroupBox21: TGroupBox;
    FooterHeightEdit: TSpinEdit;
    GroupBox23: TGroupBox;
    FooterWidthEdit: TSpinEdit;
    bPrtSetup: TButton;
    bPrint: TButton;
    bPreview: TButton;
    bOK: TButton;
    PrinterSetupDialog1: TPrinterSetupDialog;
    FontDialog1: TFontDialog;
    OpenPictureDialog1: TOpenPictureDialog;
    gbPrinter: TGroupBox;
    cbPrinters: TComboBox;
    eStartDate: TEdit;
    eLastDate: TEdit;
    rgOrientation: TRadioGroup;
    bCancel: TButton;
    rgPaperSizes: TRadioGroup;
    Label1: TLabel;
    Label2: TLabel;
    gbMargins: TGroupBox;
    rgUnits: TRadioGroup;
    Image1: TImage;
    eTop: TEdit;
    eLeft: TEdit;
    eBottom: TEdit;
    eRight: TEdit;
    clbConsultants: TCheckListBox;
    PopupMenu1: TPopupMenu;
    Selectall1: TMenuItem;
    Unselectall1: TMenuItem;
    Toggleselection1: TMenuItem;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure bPrtSetupClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImBrwseBtnClick(Sender: TObject);
    procedure ImClearBtnClick(Sender: TObject);
    procedure FtBrwseBtnClick(Sender: TObject);
    procedure FtClearBtnClick(Sender: TObject);
    procedure HdngFntBtnClick(Sender: TObject);
    procedure fbDatesClick(Sender: TObject);
    procedure fbEntryTextClick(Sender: TObject);
    procedure fbJobDetailsClick(Sender: TObject);
    procedure fbClientDetailsClick(Sender: TObject);
    procedure ImageNameExit(Sender: TObject);
    procedure FooterImageNameExit(Sender: TObject);
    procedure bOKClick(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure bPrintClick(Sender: TObject);
    procedure bPreviewClick(Sender: TObject);
    procedure Selectall1Click(Sender: TObject);
    procedure Unselectall1Click(Sender: TObject);
    procedure Toggleselection1Click(Sender: TObject);

  private

    procedure SaveTimeSheet;

  public

  end;

var
  TimeSheetCfg: TTimeSheetCfg;

{==============================================================================}
IMPLEMENTATION

USES
  WinReg, Printers, rptTimeSheet, frmMain;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.bOKClick(Sender: TObject);
begin
  SaveTimeSheet;
  Close
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.bCancelClick(Sender: TObject);
begin
  Close
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.bPrintClick(Sender: TObject);
var
  i: integer;
  
begin
  for i := 0 to clbConsultants.Items.Count - 1 do
    if clbConsultants.Checked [i] then
    begin
      frmTimeSheetRpt.Consultant := i + 1;
      frmTimeSheetRpt.qrTimeSheet.Print
    end
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.bPreviewClick(Sender: TObject);
var
  i: integer;

begin
  for i := 0 to clbConsultants.Items.Count - 1 do
    if clbConsultants.Checked [i] then
    begin
      frmTimeSheetRpt.Consultant := i + 1;
      frmTimeSheetRpt.qrTimeSheet.Preview
    end
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.bPrtSetupClick(Sender: TObject);
begin
  PrinterSetupDialog1.Execute
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.ImBrwseBtnClick(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
    ImageName.Text := OpenPictureDialog1.FileName;

  try
    LogoImage.Picture.LoadFromFile (ImageName.Text)
  except
  end
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.ImClearBtnClick(Sender: TObject);
begin
  ImageName.Text := '';
  LogoImage.Picture.Bitmap := nil
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.FtBrwseBtnClick(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
    FooterImageName.Text := OpenPictureDialog1.FileName;

  try
    FooterImage.Picture.LoadFromFile (FooterImageName.Text)
  except
  end
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.FtClearBtnClick(Sender: TObject);
begin
  FooterImageName.Text := '';
  FooterImage.Picture.Bitmap := nil
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.HdngFntBtnClick(Sender: TObject);
begin
  FontDialog1.Font.Assign (HdngText.Font);
  if FontDialog1.Execute then
    HdngText.Font.Assign (FontDialog1.Font)
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.fbDatesClick(Sender: TObject);
begin
  FontDialog1.Font.Assign (Dates.Font);
  if FontDialog1.Execute then
    Dates.Font.Assign (FontDialog1.Font)
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.fbEntryTextClick(Sender: TObject);
begin
  FontDialog1.Font.Assign (EntryText.Font);
  if FontDialog1.Execute then
    EntryText.Font.Assign (FontDialog1.Font)
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.fbJobDetailsClick(Sender: TObject);
begin
  FontDialog1.Font.Assign (JobDetails.Font);
  if FontDialog1.Execute then
    JobDetails.Font.Assign (FontDialog1.Font)
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.fbClientDetailsClick(Sender: TObject);
begin
  FontDialog1.Font.Assign (ClientDetails.Font);
  if FontDialog1.Execute then
    ClientDetails.Font.Assign (FontDialog1.Font)
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.ImageNameExit(Sender: TObject);
begin
  try
    LogoImage.Picture.LoadFromFile (ImageName.Text)
  except
  end
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.FooterImageNameExit(Sender: TObject);
begin
  try
    FooterImage.Picture.LoadFromFile (FooterImageName.Text)
  except
  end
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.SaveTimeSheet;
var
    Reg: TWinRegistry;

begin
  Reg := TWinRegistry.Create ('Software\Timex');

  with Reg do
  begin
    WriteInteger ('Timesheet', 'PrinterIndex', cbPrinters.ItemIndex);
    WriteInteger ('Timesheet', 'PaperSize', rgPaperSizes.ItemIndex);
    WriteInteger ('Timesheet', 'Orientation', rgOrientation.ItemIndex);
    WriteString ('Timesheet', 'LastDate', eLastDate.Text);

    WriteInteger ('Timesheet', 'Units', rgUnits.ItemIndex);
    WriteString ('Timesheet', 'TopMargin', eTop.Text);
    WriteString ('Timesheet', 'BottomMargin', eBottom.Text);
    WriteString ('Timesheet', 'LeftMargin', eLeft.Text);
    WriteString ('Timesheet', 'RightMargin', eRight.Text);

    WriteString ('Timesheet', 'LogoImageFile', ImageName.Text);
    WriteInteger ('Timesheet', 'LogoImageAlign', AlignGrp.ItemIndex);
    WriteInteger ('Timesheet', 'LogoHeight', HeightEdit.Value);
    WriteInteger ('Timesheet', 'LogoWidth', WidthEdit.Value);

    WriteString ('Timesheet', 'FooterImageFile', FooterImageName.Text);
    WriteInteger ('Timesheet', 'FooterImageAlign', FooterAlignGrp.ItemIndex);
    WriteInteger ('Timesheet', 'FooterHeight', FooterHeightEdit.Value);
    WriteInteger ('Timesheet', 'FooterWidth', FooterWidthEdit.Value);

    WriteString ('Timesheet', 'ReportHeading', HdngText.Text);
    WriteString ('Timesheet', 'ReportHeadingFont', HdngText.Font.Name);
    WriteInteger ('Timesheet', 'ReportHeadingFontSize', HdngText.Font.Size);
    WriteInteger ('Timesheet', 'ReportHeadingFontColour', HdngText.Font.Color);
    WriteBool ('Timesheet', 'ReportHeadingFontBold', (fsBold in HdngText.Font.Style));
    WriteBool ('Timesheet', 'ReportHeadingFontItalics', (fsItalic in HdngText.Font.Style));
    WriteBool ('Timesheet', 'ReportHeadingFontUnderline', (fsUnderline in HdngText.Font.Style));
    WriteBool ('Timesheet', 'ReportHeadingFontStrikeout', (fsStrikeout in HdngText.Font.Style));

    WriteString ('Timesheet', 'DatesFont', Dates.Font.Name);
    WriteInteger ('Timesheet', 'DatesFontSize', Dates.Font.Size);
    WriteInteger ('Timesheet', 'DatesFontColour', Dates.Font.Color);
    WriteBool ('Timesheet', 'DatesFontBold', (fsBold in Dates.Font.Style));
    WriteBool ('Timesheet', 'DatesFontItalics', (fsItalic in Dates.Font.Style));
    WriteBool ('Timesheet', 'DatesFontUnderline', (fsUnderline in Dates.Font.Style));
    WriteBool ('Timesheet', 'DatesFontStrikeout', (fsStrikeout in Dates.Font.Style));

    WriteString ('Timesheet', 'ClientDetailsFont', ClientDetails.Font.Name);
    WriteInteger ('Timesheet', 'ClientDetailsFontSize', ClientDetails.Font.Size);
    WriteInteger ('Timesheet', 'ClientDetailsFontColour', ClientDetails.Font.Color);
    WriteBool ('Timesheet', 'ClientDetailsFontBold', (fsBold in ClientDetails.Font.Style));
    WriteBool ('Timesheet', 'ClientDetailsFontItalics', (fsItalic in ClientDetails.Font.Style));
    WriteBool ('Timesheet', 'ClientDetailsFontUnderline', (fsUnderline in ClientDetails.Font.Style));
    WriteBool ('Timesheet', 'ClientDetailsFontStrikeout', (fsStrikeout in ClientDetails.Font.Style));

    WriteString ('Timesheet', 'EntryTextFont', EntryText.Font.Name);
    WriteInteger ('Timesheet', 'EntryTextFontSize', EntryText.Font.Size);
    WriteInteger ('Timesheet', 'EntryTextFontColour', EntryText.Font.Color);
    WriteBool ('Timesheet', 'EntryTextFontBold', (fsBold in EntryText.Font.Style));
    WriteBool ('Timesheet', 'EntryTextFontItalics', (fsItalic in EntryText.Font.Style));
    WriteBool ('Timesheet', 'EntryTextFontUnderline', (fsUnderline in EntryText.Font.Style));
    WriteBool ('Timesheet', 'EntryTextFontStrikeout', (fsStrikeout in EntryText.Font.Style));

    WriteString ('Timesheet', 'JobDetailsFont', JobDetails.Font.Name);
    WriteInteger ('Timesheet', 'JobDetailsFontSize', JobDetails.Font.Size);
    WriteInteger ('Timesheet', 'JobDetailsFontColour', JobDetails.Font.Color);
    WriteBool ('Timesheet', 'JobDetailsFontBold', (fsBold in JobDetails.Font.Style));
    WriteBool ('Timesheet', 'JobDetailsFontItalics', (fsItalic in JobDetails.Font.Style));
    WriteBool ('Timesheet', 'JobDetailsFontUnderline', (fsUnderline in JobDetails.Font.Style));
    WriteBool ('Timesheet', 'JobDetailsFontStrikeout', (fsStrikeout in JobDetails.Font.Style));
  end;

  Reg.Free
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.FormShow(Sender: TObject);
var
  i: integer;
  Reg: TWinRegistry;

begin
  i := 0;
  clbConsultants.Items.Clear;
  with Main.Query do
  begin
    SQL.Clear;
    SQL.Add ('select NAME from CONSULTANTS');
    Active := True;
    while not eof do
    begin
      clbConsultants.Items.Add (FieldByName ('NAME').AsString);
      clbConsultants.Checked [i] := True;
      Inc (i);
      Next
    end;
    Active := False
  end;

  pgTimesheet.ActivePage := tsData;
  cbPrinters.Clear;
  cbPrinters.Items := Printer.Printers;
  eLastDate.Text := DateToStr (Now);

  Reg := TWinRegistry.Create ('Software\Timex');

  with Reg do
  begin
    cbPrinters.ItemIndex := ReadInteger ('Timesheet', 'PrinterIndex', Printer.PrinterIndex);
    rgPaperSizes.ItemIndex := ReadInteger ('Timesheet', 'PaperSize', 0);
    rgOrientation.ItemIndex := ReadInteger ('Timesheet', 'Orientation', 0);
    eStartDate.Text := ReadString ('Timesheet', 'LastDate', '01/01/01');

    rgUnits.ItemIndex := ReadInteger ('Timesheet', 'Units', 0);
    eTop.Text := ReadString ('Timesheet', 'TopMargin', '10.0');
    eBottom.Text := ReadString ('Timesheet', 'BottomMargin', '15.0');
    eLeft.Text := ReadString ('Timesheet', 'LeftMargin', '10.0');
    eRight.Text := ReadString ('Timesheet', 'RightMargin', '10.0');

    ImageName.Text := ReadString ('Timesheet', 'LogoImageFile', '');
    AlignGrp.ItemIndex := ReadInteger ('Timesheet', 'LogoImageAlign', 2);
    HeightEdit.Value := ReadInteger ('Timesheet', 'LogoHeight', 120);
    WidthEdit.Value := ReadInteger ('Timesheet', 'LogoWidth', 120);

    FooterImageName.Text := ReadString ('Timesheet', 'FooterImageFile', '');
    FooterAlignGrp.ItemIndex := ReadInteger ('Timesheet', 'FooterImageAlign', 1);
    FooterHeightEdit.Value := ReadInteger ('Timesheet', 'FooterHeight', 120);
    FooterWidthEdit.Value := ReadInteger ('Timesheet', 'FooterWidth', 400);

    HdngText.Text := ReadString ('Timesheet', 'ReportHeading', 'Timesheet');
    HdngText.Font.Name := ReadString ('Timesheet', 'ReportHeadingFont', 'Arial Black');
    HdngText.Font.Size := ReadInteger ('Timesheet', 'ReportHeadingFontSize', 24);
    HdngText.Font.Color := ReadInteger ('Timesheet', 'ReportHeadingFontColour', clBlack);
    if ReadBool ('Timesheet', 'ReportHeadingFontBold', true) then
      HdngText.Font.Style := HdngText.Font.Style + [fsBold]
    else
      HdngText.Font.Style := HdngText.Font.Style - [fsBold];
    if ReadBool ('Timesheet', 'ReportHeadingFontItalics', false) then
      HdngText.Font.Style := HdngText.Font.Style + [fsItalic]
    else
      HdngText.Font.Style := HdngText.Font.Style - [fsItalic];
    if ReadBool ('Timesheet', 'ReportHeadingFontUnderline', false) then
      HdngText.Font.Style := HdngText.Font.Style + [fsUnderline]
    else
      HdngText.Font.Style := HdngText.Font.Style - [fsUnderline];
    if ReadBool ('Timesheet', 'ReportHeadingFontStrikeout', false) then
      HdngText.Font.Style := HdngText.Font.Style + [fsStrikeout]
    else
      HdngText.Font.Style := HdngText.Font.Style - [fsStrikeout];

    Dates.Font.Name := ReadString ('Timesheet', 'DatesFont', 'Arial');
    Dates.Font.Size := ReadInteger ('Timesheet', 'DatesFontSize', 10);
    Dates.Font.Color := ReadInteger ('Timesheet', 'DatesFontColour', clBlack);
    if ReadBool ('Timesheet', 'DatesFontBold', false) then
      Dates.Font.Style := Dates.Font.Style + [fsBold]
    else
      Dates.Font.Style := Dates.Font.Style - [fsBold];
    if ReadBool ('Timesheet', 'DatesFontItalics', false) then
      Dates.Font.Style := Dates.Font.Style + [fsItalic]
    else
      Dates.Font.Style := Dates.Font.Style - [fsItalic];
    if ReadBool ('Timesheet', 'DatesFontUnderline', false) then
      Dates.Font.Style := Dates.Font.Style + [fsUnderline]
    else
      Dates.Font.Style := Dates.Font.Style - [fsUnderline];
    if ReadBool ('Timesheet', 'DatesFontStrikeout', false) then
      Dates.Font.Style := Dates.Font.Style + [fsStrikeout]
    else
      Dates.Font.Style := Dates.Font.Style - [fsStrikeout];

    ClientDetails.Font.Name := ReadString ('Timesheet', 'ClientDetailsFont', 'Arial');
    ClientDetails.Font.Size := ReadInteger ('Timesheet', 'ClientDetailsFontSize', 10);
    ClientDetails.Font.Color := ReadInteger ('Timesheet', 'ClientDetailsFontColour', clBlack);
    if ReadBool ('Timesheet', 'ClientDetailsFontBold', true) then
      ClientDetails.Font.Style := ClientDetails.Font.Style + [fsBold]
    else
      ClientDetails.Font.Style := ClientDetails.Font.Style - [fsBold];
    if ReadBool ('Timesheet', 'ClientDetailsFontItalics', false) then
      ClientDetails.Font.Style := ClientDetails.Font.Style + [fsItalic]
    else
      ClientDetails.Font.Style := ClientDetails.Font.Style - [fsItalic];
    if ReadBool ('Timesheet', 'ClientDetailsFontUnderline', false) then
      ClientDetails.Font.Style := ClientDetails.Font.Style + [fsUnderline]
    else
      ClientDetails.Font.Style := ClientDetails.Font.Style - [fsUnderline];
    if ReadBool ('Timesheet', 'ClientDetailsFontStrikeout', false) then
      ClientDetails.Font.Style := ClientDetails.Font.Style + [fsStrikeout]
    else
      ClientDetails.Font.Style := ClientDetails.Font.Style - [fsStrikeout];

    EntryText.Font.Name := ReadString ('Timesheet', 'EntryTextFont', 'Arial');
    EntryText.Font.Size := ReadInteger ('Timesheet', 'EntryTextFontSize', 9);
    EntryText.Font.Color := ReadInteger ('Timesheet', 'EntryTextFontColour', clBlack);
    if ReadBool ('Timesheet', 'EntryTextFontBold', false) then
      EntryText.Font.Style := EntryText.Font.Style + [fsBold]
    else
      EntryText.Font.Style := EntryText.Font.Style - [fsBold];
    if ReadBool ('Timesheet', 'EntryTextFontItalics', false) then
      EntryText.Font.Style := EntryText.Font.Style + [fsItalic]
    else
      EntryText.Font.Style := EntryText.Font.Style - [fsItalic];
    if ReadBool ('Timesheet', 'EntryTextFontUnderline', false) then
      EntryText.Font.Style := EntryText.Font.Style + [fsUnderline]
    else
      EntryText.Font.Style := EntryText.Font.Style - [fsUnderline];
    if ReadBool ('Timesheet', 'EntryTextFontStrikeout', false) then
      EntryText.Font.Style := EntryText.Font.Style + [fsStrikeout]
    else
      EntryText.Font.Style := EntryText.Font.Style - [fsStrikeout];

    JobDetails.Font.Name := ReadString ('Timesheet', 'JobDetailsFont', 'Arial');
    JobDetails.Font.Size := ReadInteger ('Timesheet', 'JobDetailsFontSize', 9);
    JobDetails.Font.Color := ReadInteger ('Timesheet', 'JobDetailsFontColour', clBlack);
    if ReadBool ('Timesheet', 'JobDetailsFontBold', false) then
      JobDetails.Font.Style := JobDetails.Font.Style + [fsBold]
    else
      JobDetails.Font.Style := JobDetails.Font.Style - [fsBold];
    if ReadBool ('Timesheet', 'JobDetailsFontItalics', true) then
      JobDetails.Font.Style := JobDetails.Font.Style + [fsItalic]
    else
      JobDetails.Font.Style := JobDetails.Font.Style - [fsItalic];
    if ReadBool ('Timesheet', 'JobDetailsFontUnderline', false) then
      JobDetails.Font.Style := JobDetails.Font.Style + [fsUnderline]
    else
      JobDetails.Font.Style := JobDetails.Font.Style - [fsUnderline];
    if ReadBool ('Timesheet', 'JobDetailsFontStrikeout', false) then
      JobDetails.Font.Style := JobDetails.Font.Style + [fsStrikeout]
    else
      JobDetails.Font.Style := JobDetails.Font.Style - [fsStrikeout];
  end;

  Reg.Free;

  LogoImage.Picture.Bitmap := nil;
  try
    if FileExists (ImageName.Text) then
      LogoImage.Picture.LoadFromFile (ImageName.Text)
  except
  end;

  FooterImage.Picture.Bitmap := nil;
  try
    if FileExists (FooterImageName.Text) then
      FooterImage.Picture.LoadFromFile (FooterImageName.Text)
  except
  end;
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.Selectall1Click(Sender: TObject);
var
  i: integer;

begin
  for i := 0 to clbConsultants.Items.Count - 1 do
    clbConsultants.Checked [i] := True
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.Unselectall1Click(Sender: TObject);
var
  i: integer;

begin
  for i := 0 to clbConsultants.Items.Count - 1 do
    clbConsultants.Checked [i] := False
end;

//------------------------------------------------------------------------------
procedure TTimeSheetCfg.Toggleselection1Click(Sender: TObject);
var
  i: integer;

begin
  for i := 0 to clbConsultants.Items.Count - 1 do
    clbConsultants.Checked [i] := not clbConsultants.Checked [i]
end;

END.
