UNIT rptInvoice;

{==============================================================================}
INTERFACE

USES
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, quickrpt;

type
  TfrmInvoiceRpt = class(TForm)
    qrInvoice: TQuickRep;
    procedure qrInvoicePreview(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmInvoiceRpt: TfrmInvoiceRpt;

{==============================================================================}
IMPLEMENTATION

USES
  QRPreview, QRPrntr;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TfrmInvoiceRpt.qrInvoicePreview(Sender: TObject);
begin
  with RptPreviewFrm do
  begin
    RptPreview.QRPrinter := TQRPrinter (Sender);
    Show;
    pgbReport.Visible := False
  end
end;

END.
