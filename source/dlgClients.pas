UNIT dlgClients;

{==============================================================================}
INTERFACE

USES
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TClients = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    lbClients: TListBox;
    AddBtn: TButton;
    procedure AddBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Clients: TClients;

{==============================================================================}
IMPLEMENTATION

USES
  dlgNewClient;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TClients.AddBtnClick(Sender: TObject);
begin
  if NewClient.Execute then
  begin
    lbClients.Items.Add (NewClient.NewClientCode);
    lbClients.ItemIndex := lbClients.Items.Count - 1
  end
end;

END.
