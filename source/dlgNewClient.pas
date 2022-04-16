UNIT dlgNewClient;

{==============================================================================}
INTERFACE

USES
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TNewClient = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    Label1: TLabel;
    eCode: TEdit;

  private

  public
    NewClientCode: String;

    function Execute: boolean;
  end;

var
  NewClient: TNewClient;

{==============================================================================}
IMPLEMENTATION

{$R *.DFM}

//------------------------------------------------------------------------------
function TNewClient.Execute: boolean;
begin
  if ShowModal = mrOk then
  begin
    NewClientCode := eCode.Text;
    Execute := True
  end
  else
    Execute := False
end;

END.
