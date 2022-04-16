UNIT frmInvoiceCfg;

{==============================================================================}
INTERFACE

USES
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Spin, ExtCtrls, StdCtrls, ComCtrls, ExtDlgs;

type
  TInvoiceCfg = class(TForm)
    pgInvoice: TPageControl;
    tsData: TTabSheet;
    gbDates: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    eStartDate: TEdit;
    eLastDate: TEdit;
    gbPrinterSettings: TGroupBox;
    gbPrinter: TGroupBox;
    cbPrinters: TComboBox;
    rgOrientation: TRadioGroup;
    rgPaperSizes: TRadioGroup;
    tsPage: TTabSheet;
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
    bCancel: TButton;
    PrinterSetupDialog1: TPrinterSetupDialog;
    FontDialog1: TFontDialog;
    OpenPictureDialog1: TOpenPictureDialog;
    procedure bOKClick(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure bPreviewClick(Sender: TObject);
    procedure bPrintClick(Sender: TObject);
    procedure bPrtSetupClick(Sender: TObject);
    procedure HdngFntBtnClick(Sender: TObject);
    procedure fbDatesClick(Sender: TObject);
    procedure fbEntryTextClick(Sender: TObject);
    procedure fbClientDetailsClick(Sender: TObject);
    procedure fbJobDetailsClick(Sender: TObject);
    procedure ImBrwseBtnClick(Sender: TObject);
    procedure ImClearBtnClick(Sender: TObject);
    procedure FtBrwseBtnClick(Sender: TObject);
    procedure FtClearBtnClick(Sender: TObject);
    procedure ImageNameExit(Sender: TObject);
    procedure FooterImageNameExit(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private

    procedure SaveInvoice;

  public

  end;

var
  InvoiceCfg: TInvoiceCfg;

{==============================================================================}
IMPLEMENTATION

USES
  WinReg, Printers, rptInvoice;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TInvoiceCfg.bOKClick(Sender: TObject);
begin
  SaveInvoice;
  Close
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.bCancelClick(Sender: TObject);
begin
  Close
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.bPrintClick(Sender: TObject);
begin
  frmInvoiceRpt.qrInvoice.Print
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.bPreviewClick(Sender: TObject);
begin
  frmInvoiceRpt.qrInvoice.Preview
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.bPrtSetupClick(Sender: TObject);
begin
  PrinterSetupDialog1.Execute
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.ImBrwseBtnClick(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
    ImageName.Text := OpenPictureDialog1.FileName;

  try
    LogoImage.Picture.LoadFromFile (ImageName.Text)
  except
  end
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.ImClearBtnClick(Sender: TObject);
begin
  ImageName.Text := '';
  LogoImage.Picture.Bitmap := nil
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.FtBrwseBtnClick(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
    FooterImageName.Text := OpenPictureDialog1.FileName;

  try
    FooterImage.Picture.LoadFromFile (FooterImageName.Text)
  except
  end
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.FtClearBtnClick(Sender: TObject);
begin
  FooterImageName.Text := '';
  FooterImage.Picture.Bitmap := nil
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.HdngFntBtnClick(Sender: TObject);
begin
  FontDialog1.Font.Assign (HdngText.Font);
  if FontDialog1.Execute then
    HdngText.Font.Assign (FontDialog1.Font)
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.fbDatesClick(Sender: TObject);
begin
  FontDialog1.Font.Assign (Dates.Font);
  if FontDialog1.Execute then
    Dates.Font.Assign (FontDialog1.Font)
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.fbEntryTextClick(Sender: TObject);
begin
  FontDialog1.Font.Assign (EntryText.Font);
  if FontDialog1.Execute then
    EntryText.Font.Assign (FontDialog1.Font)
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.fbJobDetailsClick(Sender: TObject);
begin
  FontDialog1.Font.Assign (JobDetails.Font);
  if FontDialog1.Execute then
    JobDetails.Font.Assign (FontDialog1.Font)
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.fbClientDetailsClick(Sender: TObject);
begin
  FontDialog1.Font.Assign (ClientDetails.Font);
  if FontDialog1.Execute then
    ClientDetails.Font.Assign (FontDialog1.Font)
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.ImageNameExit(Sender: TObject);
begin
  try
    LogoImage.Picture.LoadFromFile (ImageName.Text)
  except
  end
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.FooterImageNameExit(Sender: TObject);
begin
  try
    FooterImage.Picture.LoadFromFile (FooterImageName.Text)
  except
  end
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.SaveInvoice;
var
    Reg: TWinRegistry;

begin
  Reg := TWinRegistry.Create ('Software\Timex');

  with Reg do
  begin
    WriteInteger ('Invoice', 'PrinterIndex', cbPrinters.ItemIndex);
    WriteInteger ('Invoice', 'PaperSize', rgPaperSizes.ItemIndex);
    WriteInteger ('Invoice', 'Orientation', rgOrientation.ItemIndex);
    WriteString ('Invoice', 'LastDate', eLastDate.Text);

    WriteString ('Invoice', 'LogoImageFile', ImageName.Text);
    WriteInteger ('Invoice', 'LogoImageAlign', AlignGrp.ItemIndex);
    WriteInteger ('Invoice', 'LogoHeight', HeightEdit.Value);
    WriteInteger ('Invoice', 'LogoWidth', WidthEdit.Value);

    WriteString ('Invoice', 'FooterImageFile', FooterImageName.Text);
    WriteInteger ('Invoice', 'FooterImageAlign', FooterAlignGrp.ItemIndex);
    WriteInteger ('Invoice', 'FooterHeight', FooterHeightEdit.Value);
    WriteInteger ('Invoice', 'FooterWidth', FooterWidthEdit.Value);

    WriteString ('Invoice', 'ReportHeading', HdngText.Text);
    WriteString ('Invoice', 'ReportHeadingFont', HdngText.Font.Name);
    WriteInteger ('Invoice', 'ReportHeadingFontSize', HdngText.Font.Size);
    WriteInteger ('Invoice', 'ReportHeadingFontColour', HdngText.Font.Color);
    WriteBool ('Invoice', 'ReportHeadingFontBold', (fsBold in HdngText.Font.Style));
    WriteBool ('Invoice', 'ReportHeadingFontItalics', (fsItalic in HdngText.Font.Style));
    WriteBool ('Invoice', 'ReportHeadingFontUnderline', (fsUnderline in HdngText.Font.Style));
    WriteBool ('Invoice', 'ReportHeadingFontStrikeout', (fsStrikeout in HdngText.Font.Style));

    WriteString ('Invoice', 'DatesFont', Dates.Font.Name);
    WriteInteger ('Invoice', 'DatesFontSize', Dates.Font.Size);
    WriteInteger ('Invoice', 'DatesFontColour', Dates.Font.Color);
    WriteBool ('Invoice', 'DatesFontBold', (fsBold in Dates.Font.Style));
    WriteBool ('Invoice', 'DatesFontItalics', (fsItalic in Dates.Font.Style));
    WriteBool ('Invoice', 'DatesFontUnderline', (fsUnderline in Dates.Font.Style));
    WriteBool ('Invoice', 'DatesFontStrikeout', (fsStrikeout in Dates.Font.Style));

    WriteString ('Invoice', 'ClientDetailsFont', ClientDetails.Font.Name);
    WriteInteger ('Invoice', 'ClientDetailsFontSize', ClientDetails.Font.Size);
    WriteInteger ('Invoice', 'ClientDetailsFontColour', ClientDetails.Font.Color);
    WriteBool ('Invoice', 'ClientDetailsFontBold', (fsBold in ClientDetails.Font.Style));
    WriteBool ('Invoice', 'ClientDetailsFontItalics', (fsItalic in ClientDetails.Font.Style));
    WriteBool ('Invoice', 'ClientDetailsFontUnderline', (fsUnderline in ClientDetails.Font.Style));
    WriteBool ('Invoice', 'ClientDetailsFontStrikeout', (fsStrikeout in ClientDetails.Font.Style));

    WriteString ('Invoice', 'EntryTextFont', EntryText.Font.Name);
    WriteInteger ('Invoice', 'EntryTextFontSize', EntryText.Font.Size);
    WriteInteger ('Invoice', 'EntryTextFontColour', EntryText.Font.Color);
    WriteBool ('Invoice', 'EntryTextFontBold', (fsBold in EntryText.Font.Style));
    WriteBool ('Invoice', 'EntryTextFontItalics', (fsItalic in EntryText.Font.Style));
    WriteBool ('Invoice', 'EntryTextFontUnderline', (fsUnderline in EntryText.Font.Style));
    WriteBool ('Invoice', 'EntryTextFontStrikeout', (fsStrikeout in EntryText.Font.Style));

    WriteString ('Invoice', 'JobDetailsFont', JobDetails.Font.Name);
    WriteInteger ('Invoice', 'JobDetailsFontSize', JobDetails.Font.Size);
    WriteInteger ('Invoice', 'JobDetailsFontColour', JobDetails.Font.Color);
    WriteBool ('Invoice', 'JobDetailsFontBold', (fsBold in JobDetails.Font.Style));
    WriteBool ('Invoice', 'JobDetailsFontItalics', (fsItalic in JobDetails.Font.Style));
    WriteBool ('Invoice', 'JobDetailsFontUnderline', (fsUnderline in JobDetails.Font.Style));
    WriteBool ('Invoice', 'JobDetailsFontStrikeout', (fsStrikeout in JobDetails.Font.Style));
  end;

  Reg.Free
end;

//------------------------------------------------------------------------------
procedure TInvoiceCfg.FormShow(Sender: TObject);
var
    Reg: TWinRegistry;

begin
  pgInvoice.ActivePage := tsData;
  cbPrinters.Clear;
  cbPrinters.Items := Printer.Printers;
  eLastDate.Text := DateToStr (Now);

  Reg := TWinRegistry.Create ('Software\Timex');

  with Reg do
  begin
    cbPrinters.ItemIndex := ReadInteger ('Invoice', 'PrinterIndex', Printer.PrinterIndex);
    rgPaperSizes.ItemIndex := ReadInteger ('Invoice', 'PaperSize', 0);
    rgOrientation.ItemIndex := ReadInteger ('Invoice', 'Orientation', 0);
    eStartDate.Text := ReadString ('Invoice', 'LastDate', DateToStr (0));

    ImageName.Text := ReadString ('Invoice', 'LogoImageFile', '');
    AlignGrp.ItemIndex := ReadInteger ('Invoice', 'LogoImageAlign', 2);
    HeightEdit.Value := ReadInteger ('Invoice', 'LogoHeight', 120);
    WidthEdit.Value := ReadInteger ('Invoice', 'LogoWidth', 120);

    FooterImageName.Text := ReadString ('Invoice', 'FooterImageFile', '');
    FooterAlignGrp.ItemIndex := ReadInteger ('Invoice', 'FooterImageAlign', 2);
    FooterHeightEdit.Value := ReadInteger ('Invoice', 'FooterHeight', 120);
    FooterWidthEdit.Value := ReadInteger ('Invoice', 'FooterWidth', 120);

    HdngText.Text := ReadString ('Invoice', 'ReportHeading', 'Invoice');
    HdngText.Font.Name := ReadString ('Invoice', 'ReportHeadingFont', 'Arial');
    HdngText.Font.Size := ReadInteger ('Invoice', 'ReportHeadingFontSize', 18);
    HdngText.Font.Color := ReadInteger ('Invoice', 'ReportHeadingFontColour', clBlack);
    if ReadBool ('Invoice', 'ReportHeadingFontBold', false) then
      HdngText.Font.Style := HdngText.Font.Style + [fsBold]
    else
      HdngText.Font.Style := HdngText.Font.Style - [fsBold];
    if ReadBool ('Invoice', 'ReportHeadingFontItalics', false) then
      HdngText.Font.Style := HdngText.Font.Style + [fsItalic]
    else
      HdngText.Font.Style := HdngText.Font.Style - [fsItalic];
    if ReadBool ('Invoice', 'ReportHeadingFontUnderline', false) then
      HdngText.Font.Style := HdngText.Font.Style + [fsUnderline]
    else
      HdngText.Font.Style := HdngText.Font.Style - [fsUnderline];
    if ReadBool ('Invoice', 'ReportHeadingFontStrikeout', false) then
      HdngText.Font.Style := HdngText.Font.Style + [fsStrikeout]
    else
      HdngText.Font.Style := HdngText.Font.Style - [fsStrikeout];

    Dates.Font.Name := ReadString ('Invoice', 'DatesFont', 'Arial');
    Dates.Font.Size := ReadInteger ('Invoice', 'DatesFontSize', 14);
    Dates.Font.Color := ReadInteger ('Invoice', 'DatesFontColour', clBlack);
    if ReadBool ('Invoice', 'DatesFontBold', false) then
      Dates.Font.Style := Dates.Font.Style + [fsBold]
    else
      Dates.Font.Style := Dates.Font.Style - [fsBold];
    if ReadBool ('Invoice', 'DatesFontItalics', false) then
      Dates.Font.Style := Dates.Font.Style + [fsItalic]
    else
      Dates.Font.Style := Dates.Font.Style - [fsItalic];
    if ReadBool ('Invoice', 'DatesFontUnderline', false) then
      Dates.Font.Style := Dates.Font.Style + [fsUnderline]
    else
      Dates.Font.Style := Dates.Font.Style - [fsUnderline];
    if ReadBool ('Invoice', 'DatesFontStrikeout', false) then
      Dates.Font.Style := Dates.Font.Style + [fsStrikeout]
    else
      Dates.Font.Style := Dates.Font.Style - [fsStrikeout];

    ClientDetails.Font.Name := ReadString ('Invoice', 'ClientDetailsFont', 'Arial');
    ClientDetails.Font.Size := ReadInteger ('Invoice', 'ClientDetailsFontSize', 14);
    ClientDetails.Font.Color := ReadInteger ('Invoice', 'ClientDetailsFontColour', clBlack);
    if ReadBool ('Invoice', 'ClientDetailsFontBold', false) then
      ClientDetails.Font.Style := ClientDetails.Font.Style + [fsBold]
    else
      ClientDetails.Font.Style := ClientDetails.Font.Style - [fsBold];
    if ReadBool ('Invoice', 'ClientDetailsFontItalics', false) then
      ClientDetails.Font.Style := ClientDetails.Font.Style + [fsItalic]
    else
      ClientDetails.Font.Style := ClientDetails.Font.Style - [fsItalic];
    if ReadBool ('Invoice', 'ClientDetailsFontUnderline', false) then
      ClientDetails.Font.Style := ClientDetails.Font.Style + [fsUnderline]
    else
      ClientDetails.Font.Style := ClientDetails.Font.Style - [fsUnderline];
    if ReadBool ('Invoice', 'ClientDetailsFontStrikeout', false) then
      ClientDetails.Font.Style := ClientDetails.Font.Style + [fsStrikeout]
    else
      ClientDetails.Font.Style := ClientDetails.Font.Style - [fsStrikeout];

    EntryText.Font.Name := ReadString ('Invoice', 'EntryTextFont', 'Arial');
    EntryText.Font.Size := ReadInteger ('Invoice', 'EntryTextFontSize', 14);
    EntryText.Font.Color := ReadInteger ('Invoice', 'EntryTextFontColour', clBlack);
    if ReadBool ('Invoice', 'EntryTextFontBold', false) then
      EntryText.Font.Style := EntryText.Font.Style + [fsBold]
    else
      EntryText.Font.Style := EntryText.Font.Style - [fsBold];
    if ReadBool ('Invoice', 'EntryTextFontItalics', false) then
      EntryText.Font.Style := EntryText.Font.Style + [fsItalic]
    else
      EntryText.Font.Style := EntryText.Font.Style - [fsItalic];
    if ReadBool ('Invoice', 'EntryTextFontUnderline', false) then
      EntryText.Font.Style := EntryText.Font.Style + [fsUnderline]
    else
      EntryText.Font.Style := EntryText.Font.Style - [fsUnderline];
    if ReadBool ('Invoice', 'EntryTextFontStrikeout', false) then
      EntryText.Font.Style := EntryText.Font.Style + [fsStrikeout]
    else
      EntryText.Font.Style := EntryText.Font.Style - [fsStrikeout];

    JobDetails.Font.Name := ReadString ('Invoice', 'JobDetailsFont', 'Arial');
    JobDetails.Font.Size := ReadInteger ('Invoice', 'JobDetailsFontSize', 14);
    JobDetails.Font.Color := ReadInteger ('Invoice', 'JobDetailsFontColour', clBlack);
    if ReadBool ('Invoice', 'JobDetailsFontBold', false) then
      JobDetails.Font.Style := JobDetails.Font.Style + [fsBold]
    else
      JobDetails.Font.Style := JobDetails.Font.Style - [fsBold];
    if ReadBool ('Invoice', 'JobDetailsFontItalics', false) then
      JobDetails.Font.Style := JobDetails.Font.Style + [fsItalic]
    else
      JobDetails.Font.Style := JobDetails.Font.Style - [fsItalic];
    if ReadBool ('Invoice', 'JobDetailsFontUnderline', false) then
      JobDetails.Font.Style := JobDetails.Font.Style + [fsUnderline]
    else
      JobDetails.Font.Style := JobDetails.Font.Style - [fsUnderline];
    if ReadBool ('Invoice', 'JobDetailsFontStrikeout', false) then
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

END.
