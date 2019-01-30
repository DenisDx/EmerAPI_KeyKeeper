unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button7: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses USha256, crypto, UOpenSSLdef, UOpenSSL, PodbiralkaUnit, unitCryptoTest, EmerApiTestUnit, tsttransactionUnit, CreateRawTXunit;

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  if Not LoadSSLCrypt then
    raise Exception.Create('Cannot load '+SSL_C_LIB+#10+'To use this software make sure this file is available on you system or reinstall the application');
  InitCrypto;

  cryptoTestForm.show;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  EmerApiTestForm.show;
end;


procedure TForm1.Button3Click(Sender: TObject);
begin
 // Start OpenSSL dll
  if Not LoadSSLCrypt then
    raise Exception.Create('Cannot load '+SSL_C_LIB+#10+'To use this software make sure this file is available on you system or reinstall the application');
  InitCrypto;

end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Button3Click(nil);
  form4.show;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  if Not LoadSSLCrypt then
    raise Exception.Create('Cannot load '+SSL_C_LIB+#10+'To use this software make sure this file is available on you system or reinstall the application');
  InitCrypto;

  CreateRawTXform.show;
  CreateRawTXform.Button26.Click;
end;


procedure TForm1.Button7Click(Sender: TObject);
begin
  PodbiralkaForm.show;
end;


{ TForm1 }

////
//  less useful https://github.com/ciyam/ciyam/blob/master/src/crypto_keys.cpp

//about crypto
//https://eng.paxos.com/blockchain-101-elliptic-curve-cryptography


end.

