unit CreatePasswordUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, ExtCtrls;

type

  { TcreatePassword }

  TcreatePassword = class(TFrame)
    cBipSet: TComboBox;
    chNoRude: TCheckBox;
    eExample2: TLabel;
    Label5: TLabel;
    lPasswordType: TLabel;
    Panel1: TPanel;
    rbBIP0039: TRadioButton;
    lExample1: TLabel;
    Label3: TLabel;
    lExample3: TLabel;
    Label7: TLabel;
    rbCharSet: TRadioButton;
    rbCode3: TRadioButton;
    rgSymbolSet: TRadioGroup;
    procedure rbBIP0039Change(Sender: TObject);
  private
    fonChange:tNotifyEvent;
  public
    property onChange:tNotifyEvent read fonChange write fonChange;
    procedure Init();
    function createPassword(d:double):string;

  end;

implementation

uses passwordHelper {, crypto CT_Base58};

{$R *.lfm}
function TcreatePassword.createPassword(d:double):string;
var i:integer;
begin
  if rbBIP0039.Checked then
     case cBipSet.ItemIndex of
       0:result:=makeBIP39RandomPassword(d,bip0039english,' ');
       1:result:=makeBIP39RandomPassword(d,bip0039chinese,'');
     else
       raise exception.Create('Not spported BIP0039 set');
     end
  else if rbCode3.Checked then begin
    result:='NOT APPLIED YET';
    //for i:=33 to 126 do result:=result+chr(i);
  end else
    case rgSymbolSet.ItemIndex of
      0:result:=makeCharRandomPassword(d,'0123456789abcdefghijklmnopqrstuvwxyz');
      1:result:=makeCharRandomPassword(d,'123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz');
      2:result:=makeCharRandomPassword(d,'!"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~');
    end;

end;

procedure TcreatePassword.rbBIP0039Change(Sender: TObject);
begin
  if assigned(fonChange) then fonChange(rbBIP0039);
  chNoRude.Enabled:=rbCode3.Checked;
  rgSymbolSet.Enabled:=rbCharSet.Checked;
  cBipSet.Enabled:=rbBIP0039.Checked;
end;


procedure TcreatePassword.Init();
begin
  //localizze(self);
  rbBIP0039Change(nil);
end;

end.

