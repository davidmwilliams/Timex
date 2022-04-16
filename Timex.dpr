program Timex;

uses
  Forms,
  frmMain in 'source\frmMain.pas' {Main},
  AboutScrn in 'source\AboutScrn.pas' {AboutDlg},
  QRPreview in '..\Common\QRPreview.pas' {RptPreviewFrm},
  SysInfoForm in '..\Common\SysInfoForm.pas' {SysInfo},
  WinReg in '..\Common\Winreg.pas',
  dlgJobs in 'source\dlgJobs.pas' {Jobs},
  dlgClients in 'source\dlgClients.pas' {Clients},
  dlgConsultants in 'source\dlgConsultants.pas' {Consultants},
  dlgNewClient in 'source\dlgNewClient.pas' {NewClient},
  frmTimeSheetCfg in 'source\frmTimeSheetCfg.pas' {TimeSheetCfg},
  frmInvoiceCfg in 'source\frmInvoiceCfg.pas' {InvoiceCfg},
  rptTimeSheet in 'source\rptTimeSheet.pas' {frmTimeSheetRpt},
  rptInvoice in 'source\rptInvoice.pas' {frmInvoiceRpt},
  UCrypt in '..\Common\UCrypt.pas',
  uRegister in '..\Common\uRegister.pas' {RegisterDlg},
  frmFind in 'source\frmFind.pas' {FindFrm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Consultant''s Assistant';
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TAboutDlg, AboutDlg);
  Application.CreateForm(TRptPreviewFrm, RptPreviewFrm);
  Application.CreateForm(TSysInfo, SysInfo);
  Application.CreateForm(TJobs, Jobs);
  Application.CreateForm(TClients, Clients);
  Application.CreateForm(TConsultants, Consultants);
  Application.CreateForm(TNewClient, NewClient);
  Application.CreateForm(TTimeSheetCfg, TimeSheetCfg);
  Application.CreateForm(TInvoiceCfg, InvoiceCfg);
  Application.CreateForm(TfrmTimeSheetRpt, frmTimeSheetRpt);
  Application.CreateForm(TfrmInvoiceRpt, frmInvoiceRpt);
  Application.CreateForm(TRegisterDlg, RegisterDlg);
  Application.CreateForm(TFindFrm, FindFrm);
  Application.Run;
end.
