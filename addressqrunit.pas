unit addressQRunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons;

type

  { TAddressQRForm }

  TAddressQRForm = class(TForm)
    BitBtn1: TBitBtn;
    img: TImage;
    Panel1: TPanel;
    procedure BitBtn1Click(Sender: TObject);
  private

  public

  end;

var
  AddressQRForm: TAddressQRForm;

procedure ShowQRCode(txt:string);

implementation

uses QlpIQrCode,QlpQrCode;

{$R *.lfm}

procedure ShowQRCode(txt:string);
var LBitmap:tBitmap;
var
  //LText: String;
  //LErrCorLvl: TQrCode.TEcc;
  LQrCode: IQrCode;
begin
  //AScale, ABorder: Int32;
  //  LEncoding := TEncoding.UTF8;
  //LErrCorLvl := TQrCode.TEcc.eccLow; // Error correction level
  // Make the QR Code symbol
  LQrCode := TQrCode.EncodeText(txt, TQrCode.TEcc.eccLow, TEncoding.UTF8);

  LBitmap := LQrCode.ToBmpImage(1, 2);
  try
    AddressQRForm.img.picture.bitmap.assign(LBitmap);
  finally
    LBitmap.Free;
    //AQrCode.free;
  end;

  AddressQRForm.Caption:=txt;

  if not AddressQRForm.Visible
    then AddressQRForm.Show
    else AddressQRForm.BringToFront;
end;

{ TAddressQRForm }

procedure TAddressQRForm.BitBtn1Click(Sender: TObject);
begin
  close;
end;

end.

