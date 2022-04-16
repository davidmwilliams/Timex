UNIT rptTimeSheet;

{==============================================================================}
INTERFACE

USES
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, quickrpt, Qrctrls, Grids;

const
  Indent = 4;
  DetailGap = 4;
  TitleRowGap = 8;
  RowGap = 4;

type
  TfrmTimeSheetRpt = class(TForm)
    qrTimeSheet: TQuickRep;
    qrbTitle: TQRBand;
    qrbColHead: TQRBand;
    qrbDetail: TQRBand;
    qrbPgFooter: TQRBand;
    sdPageNo: TQRSysData;
    FooterImage: TQRImage;
    qrlTitle: TQRLabel;
    LogoImage: TQRImage;
    chDate: TQRLabel;
    chHours: TQRLabel;
    chClient: TQRLabel;
    chJob: TQRLabel;
    chDetails: TQRLabel;
    dDate: TQRLabel;
    dHours: TQRLabel;
    dClient: TQRLabel;
    dJob: TQRLabel;
    dDetails: TQRLabel;
    sgList: TStringGrid;
    procedure qrTimeSheetPreview(Sender: TObject);
    procedure qrTimeSheetNeedData(Sender: TObject; var MoreData: Boolean);
    procedure qrTimeSheetBeforePrint(Sender: TCustomQuickRep;
      var PrintReport: Boolean);

  private
    ListIndex: integer;
    fConsultant: integer;

  public

  property
    Consultant: integer read fConsultant write fConsultant;

  end;

var
  frmTimeSheetRpt: TfrmTimeSheetRpt;

{==============================================================================}
IMPLEMENTATION

USES
  frmMain, QRPreview, QRPrntr, Printers, frmTimeSheetCfg;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TfrmTimeSheetRpt.qrTimeSheetPreview(Sender: TObject);
begin
  with RptPreviewFrm do
  begin
    RptPreview.QRPrinter := TQRPrinter (Sender);
    Show;
    pgbReport.Visible := False
  end
end;

//------------------------------------------------------------------------------
procedure TfrmTimeSheetRpt.qrTimeSheetBeforePrint(Sender: TCustomQuickRep;
  var PrintReport: Boolean);
var
  i, MaxFontSize: integer;

begin
// Set up the printer
  qrTimeSheet.PrinterSettings.PrinterIndex := TimeSheetCfg.cbPrinters.ItemIndex;

// Set up the page
  if TimeSheetCfg.rgOrientation.ItemIndex = 0 then
    qrTimeSheet.Page.Orientation := poPortrait
  else
    qrTimeSheet.Page.Orientation := poLandscape;

  case TimeSheetCfg.rgPaperSizes.ItemIndex of
    0: qrTimeSheet.Page.PaperSize := A4;
    1: qrTimeSheet.Page.PaperSize := A3;
    2: qrTimeSheet.Page.PaperSize := B5;
    3: qrTimeSheet.Page.PaperSize := Letter;
  end;

  if TimeSheetCfg.rgUnits.ItemIndex = 0 then
    qrTimeSheet.Page.Units := MM
  else
    qrTimeSheet.Page.Units := Inches;

  try
    qrTimeSheet.Page.TopMargin := StrToFloat (TimeSheetCfg.eTop.Text)
  except
  end;
  try
    qrTimeSheet.Page.BottomMargin := StrToFloat (TimeSheetCfg.eBottom.Text)
  except
  end;
  try
    qrTimeSheet.Page.LeftMargin := StrToFloat (TimeSheetCfg.eLeft.Text)
  except
  end;
  try
    qrTimeSheet.Page.RightMargin := StrToFloat (TimeSheetCfg.eRight.Text)
  except
  end;

// Set up the title
  qrlTitle.Caption := TimeSheetCfg.HdngText.Text + ' - ' +
    Main.getConsultantStr (fConsultant);
  qrlTitle.Font.Assign (TimeSheetCfg.HdngText.Font);

  LogoImage.Picture.Assign (TimeSheetCfg.LogoImage.Picture);
  if LogoImage.Picture <> nil then
  begin
    LogoImage.Height := TimeSheetCfg.HeightEdit.Value;
    LogoImage.Width := TimeSheetCfg.WidthEdit.Value;

    case TimeSheetCfg.AlignGrp.ItemIndex of
      0: begin
           LogoImage.Left := Indent;
           qrlTitle.Left := qrbTitle.Width - Indent - qrlTitle.Width;
         end;
      1: begin
           LogoImage.Left := (qrbTitle.Width - LogoImage.Width) div 2;
           qrlTitle.Left := Indent;
         end;
      2: begin
           LogoImage.Left := qrbTitle.Width - Indent - LogoImage.Width;
           qrlTitle.Left := Indent;
         end
    end
  end
  else
  begin
    LogoImage.Height := 0;
    qrlTitle.Left := Indent;
  end;

  if qrlTitle.Height > LogoImage.Height then
    qrbTitle.Height := qrlTitle.Height + (TitleRowGap * 2)
  else
    qrbTitle.Height := LogoImage.Height + (TitleRowGap * 2);

// Set up the page footer
  FooterImage.Picture.Assign (TimeSheetCfg.FooterImage.Picture);
  if FooterImage.Picture <> nil then
  begin
    FooterImage.Height := TimeSheetCfg.FooterHeightEdit.Value;
    FooterImage.Width := TimeSheetCfg.FooterWidthEdit.Value;
    case TimeSheetCfg.FooterAlignGrp.ItemIndex of
      0: begin
           FooterImage.Left := Indent;
           sdPageNo.Left := qrbPgFooter.Width - Indent - sdPageNo.Width;
         end;
      1: begin
           FooterImage.Left := (qrbPgFooter.Width - FooterImage.Width) div 2;
           sdPageNo.Left := qrbPgFooter.Width - Indent - sdPageNo.Width;
         end;
      2: begin
           FooterImage.Left := qrbPgFooter.Width - Indent - FooterImage.Width;
           sdPageNo.Left := Indent;
         end
    end
  end
  else
  begin
    FooterImage.Height := 0;
    sdPageNo.Left := qrbPgFooter.Width - Indent - sdPageNo.Width
  end;

  if sdPageNo.Height > FooterImage.Height then
    qrbPgFooter.Height := sdPageNo.Height + (RowGap * 2)
  else
    qrbPgFooter.Height := FooterImage.Height + (RowGap * 2);

// Set up the column header band
  chDate.Font.Assign (TimeSheetCfg.Dates.Font);
  chHours.Font.Assign (TimeSheetCfg.Dates.Font);
  chClient.Font.Assign (TimeSheetCfg.ClientDetails.Font);
  chJob.Font.Assign (TimeSheetCfg.JobDetails.Font);
  chDetails.Font.Assign (TimeSheetCfg.EntryText.Font);

  chDate.Width := 65;
  chHours.Width := 50;
  chClient.Width := 80;
  chJob.Width := 85;

  MaxFontSize := Main.Max4 (chDate.Font.Size, chClient.Font.Size,
        chJob.Font.Size, chDetails.Font.Size);
  chDate.Height := Trunc (MaxFontSize * 1.7);
  chHours.Height := chDate.Height;
  chClient.Height := chDate.Height;
  chJob.Height := chDate.Height;
  chDetails.Height := chDate.Height;
  qrbColHead.Height := chDate.Height + (RowGap * 2);

  chDate.Left := Indent;
  chHours.Left := chDate.Left + chDate.Width + DetailGap;
  chClient.Left := chHours.Left + chHours.Width + DetailGap;
  chJob.Left := chClient.Left + chClient.Width + DetailGap;
  chDetails.Left := chJob.Left + chJob.Width + DetailGap;
  chDetails.Width := qrbColHead.Width - chDetails.Left - Indent;

// Set up the detail band
  dDate.Font.Assign (chDate.Font);
  dDate.Left := chDate.Left;
  dDate.Height := chDate.Height;
  dDate.Width := chDate.Width;
  dHours.Font.Assign (chDate.Font);
  dHours.Left := chHours.Left;
  dHours.Height := chHours.Height;
  dHours.Width := chHours.Width;
  dClient.Font.Assign (chClient.Font);
  dClient.Left := chClient.Left;
  dClient.Height := chClient.Height;
  dClient.Width := chClient.Width;
  dJob.Font.Assign (chJob.Font);
  dJob.Left := chJob.Left;
  dJob.Height := chJob.Height;
  dJob.Width := chJob.Width;
  dDetails.Font.Assign (chDetails.Font);
  dDetails.Left := chDetails.Left;
  dDetails.Height := chDetails.Height;
  dDetails.Width := chDetails.Width;
  qrbDetail.Height := qrbColHead.Height;

// Tidy the StringGrid used to hold data ...
  sgList.RowCount := 2;
  sgList.ColCount := 5;
  for i := 0 to 4 do
  begin
    sgList.Cells [i, 0] := '';
    sgList.Cells [i, 1] := ''
  end;

// Get all the data ...
  i := 0;
  with Main.Query do
  begin
    SQL.Clear;
    SQL.Add ('select * from SLIPS');
    SQL.Add ('inner join CLIENTS');
    SQL.Add ('on SLIPS.CLIENTID = CLIENTS.ID');
    SQL.Add ('inner join JOBS');
    SQL.Add ('on SLIPS.JOBID = JOBS.ID');
    SQL.Add ('where CONSULTANTID = ' + IntToStr (fConsultant));
    Active := True;

    First;
    while not eof do
    begin
      if (FieldByName ('DATE').AsDateTime >= StrToDate (TimeSheetCfg.eStartDate.Text))
        and (FieldByName ('DATE').AsDateTime <= StrToDate (TimeSheetCfg.eLastDate.Text)) then
      begin
        if sgList.RowCount < i then
          sgList.RowCount := sgList.RowCount + 1;
        sgList.Cells [0, i] := FieldByName ('DATE').AsString;
        sgList.Cells [1, i] := FieldByName ('HOURS').AsString + ':' +
            FieldByName ('MINUTES').AsString;
        sgList.Cells [2, i] := FieldByName ('CODE').AsString;         // Client
        sgList.Cells [3, i] := FieldByName ('DESCRIPTION').AsString;  // Job
        sgList.Cells [4, i] := FieldByName ('TEXT').AsString;
        Inc (i)
      end;
      Next
    end;

    Active := False
  end;

  ListIndex := 0;
  RptPreviewFrm.pgbReport.Max := sgList.RowCount
end;

//------------------------------------------------------------------------------
procedure TfrmTimeSheetRpt.qrTimeSheetNeedData(Sender: TObject;
  var MoreData: Boolean);
begin
  MoreData := False;

  if ListIndex < sgList.RowCount - 1 then
  begin
    dDate.Caption := sgList.Cells [0, ListIndex];
    dHours.Caption := sgList.Cells [1, ListIndex];
    dClient.Caption := sgList.Cells [2, ListIndex];
    dJob.Caption := sgList.Cells [3, ListIndex];
    dDetails.Caption := sgList.Cells [4, ListIndex];
    MoreData := True
  end;

  Inc (ListIndex);

  if not MoreData then
    RptPreviewFrm.Finish
  else
    RptPreviewFrm.pgbReport.Position := ListIndex
end;

END.
