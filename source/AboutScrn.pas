UNIT AboutScrn;

{==============================================================================}
INTERFACE

USES
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls, Dialogs;

type
  TAboutDlg = class(TForm)
    Bevel1: TBevel;
    okBtn: TBitBtn;
    SysInfoBtn: TBitBtn;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lblReg1: TLabel;
    lblReg2: TLabel;
    procedure SysInfoBtnClick(Sender: TObject);
    procedure okBtnClick(Sender: TObject);

  private

  public

  end;

var
  AboutDlg: TAboutDlg;

{==============================================================================}
IMPLEMENTATION

USES
  SysInfoForm, WinReg;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TAboutDlg.SysInfoBtnClick(Sender: TObject);
begin
  SysInfo.Show
end;

//------------------------------------------------------------------------------
procedure TAboutDlg.okBtnClick(Sender: TObject);
begin
  Close
end;

END.
