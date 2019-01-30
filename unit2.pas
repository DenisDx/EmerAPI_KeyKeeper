unit PodbiralkaUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TPodbiralkaForm }

  TPodbiralkaForm = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private

  public

  end;

var
  PodbiralkaForm: TPodbiralkaForm;

implementation

{$R *.lfm}
uses USha256, crypto, UOpenSSLdef, UOpenSSL;

{ TPodbiralkaForm }

var
  inProgress:boolean=false;

const
  CHARACTERS : AnsiString = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';


procedure TPodbiralkaForm.Button1Click(Sender: TObject);
var
  d:tdatetime;
  found:boolean;
  c:cardinal;
  a,s:ansistring;
  cc:byte;
  ini:ansistring;
  i:byte;
  PrivateKey:PEC_KEY;
  pubKey:TECDSA_Public;
  savedPrivKey:ansistring;
begin
  if inProgress then begin
    inProgress:=false;
    exit;
  end else inProgress:=true;

  if not LoadSSLCrypt() then exit;
  InitCrypto;

  Edit4.text:='';
  Edit5.text:='';
  Edit6.text:='';

  savedPrivKey:='';

  d:=now();
  found:=false;
  c:=0; cc:=1;
  ini:=Edit3.text;
  a:=#0;
  while (not found) and (inProgress) do begin
    if cc>length(CHARACTERS) then begin
      //move to length(ini)
      i:=length(a)-1;
      while (i>0) and (a[i]=CHARACTERS[length(CHARACTERS)]) do dec(i);
      if i>0 then begin
        //не нужно добавлять новый разряд
        a[i]:=CHARACTERS[pos(a[i],CHARACTERS)+1];
        inc(i);
        while i<=length(a) do begin
          a[i]:=CHARACTERS[1];
          inc(i);
        end;
      end else
        //нужно добавлять новый разряд : 999 -> 0000
        a:=stringofchar(CHARACTERS[1],length(a)+1);
      cc:=1;
    end else a[length(a)]:=CHARACTERS[cc];

    PrivateKey:=CreatePrivateKeyFromStrBuf(DoSha256(trim(ini+a)));
    pubKey:=GetPublicKey(PrivateKey);

     if (length(pubkey.x)<>32) or (length(pubkey.y)<>32)
       then s:= 'WRONG KEY'
       else s:= publicKey2Address(pubKey,chr(strtoint(edit13.text)),checkbox1.checked);

    found:=(copy(s,2,length(trim(Edit1.text)))=trim(Edit1.text))
           and
           (copy(s,length(s)+1-length(trim(Edit2.text)),length(trim(Edit2.text)))=trim(Edit2.text));

    if (c mod 100)=0 then begin
      label1.Caption:=inttostr(c)+ ' passed; '+ floattostr(round( c/(1+(now()-d)*24*60*60 ) ))+' address per second; Checking "'+ini+a+'" ';
      application.ProcessMessages;
    end;

    if found then
      savedPrivKey:=privKeyToCode58(PrivateKey, chr(strtoint(edit12.text)),CheckBox1.checked);

    if Assigned(PrivateKey) then EC_KEY_free(PrivateKey);
    inc(c); inc(cc);
  end;
  inProgress:=false;
  if found then begin
    Edit4.text:=s;
    Edit5.text:=trim(ini+a);
    Edit6.text:=savedPrivKey;
  end;
end;

procedure TPodbiralkaForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  inProgress:=false;
end;

end.

