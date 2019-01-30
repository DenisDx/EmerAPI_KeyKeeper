unit CheckSignatureUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons;

type

  { TCheckSignatureForm }

  TCheckSignatureForm = class(TForm)
    bClose: TButton;
    bRemoveSign: TBitBtn;
    bSign: TBitBtn;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    chUnixEOL: TCheckBox;
    eSignature: TEdit;
    lbResult: TListBox;
    lResult: TLabel;
    lDoISign: TLabel;
    lText: TLabel;
    lSignature: TLabel;
    seMessage: TSynEdit;
    procedure bCloseClick(Sender: TObject);
    procedure bRemoveSignClick(Sender: TObject);
    procedure bSignClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure checkSignature(Sender: TObject);
  private

  public

  end;

var
  CheckSignatureForm: TCheckSignatureForm;

implementation

{$R *.lfm}
uses Localizzzeunit, EmbededSignaturesUnit , crypto {, CryptoLib4PascalConnectorUnit, emertx}

   ,MainUnit{for isMyAddress};


{ TCheckSignatureForm }


procedure TCheckSignatureForm.checkSignature(Sender: TObject);
var sList:tStringList;
  s:string;
  pubkey,sigtype,ClaimedAddress,sign:ansistring;
  i:integer;
  res:tdecodeEmbededSignatureResult;
  theText,message:string;
  signedByMe:boolean;
begin
  //sList:=tStringList.Create;
  theText:=seMessage.Text;
  signedByMe:=false;

  if chUnixEOL.Checked then
    while pos(#13#10,theText)>0 do delete(theText,pos(#13#10,theText),1);

  if decodeBitcoinStandartSignature(theText,message,ClaimedAddress,sign) then begin
     //standart btc signature
     lbResult.Items.Clear;
     if ClaimedAddress='' then begin
         s:=localizzzeString('CheckSignatureForm.lbResult.errorBtcAddress','ERROR');
         lDoISign.Caption:=localizzzeString('CheckSignatureForm.lDoISign.NotSigned','');
     end else begin
       res:=checkAddressSignature(magicSignHash(Message,'Bitcoin Signed Message:'#10),sign,ClaimedAddress,pubkey);

       s:=addressto58(addressto20(ClaimedAddress),#0);
       if isMyAddress(addressto58(addressto20(ClaimedAddress),globals.AddressSig))
          then begin
             s:=s+' '+localizzzeString('CheckSignatureForm.lbResult.yourAddress','(YOUR ADDRESS)');
             if ((res=desrPassed) or (res=desrPubkey))
               then lDoISign.Caption:=localizzzeString('CheckSignatureForm.lDoISign.Signed','')
               else lDoISign.Caption:=localizzzeString('CheckSignatureForm.lDoISign.SignedIncorrect','');
          end else
            lDoISign.Caption:=localizzzeString('CheckSignatureForm.lDoISign.NotSigned','');

       case res of
         desrError:s:=s+' '+localizzzeString('CheckSignatureForm.lbResult.error','ERROR');
         desrPassed:s:=s+' '+localizzzeString('CheckSignatureForm.lbResult.passed','PASSED');
         desrFailed:s:=s+' '+localizzzeString('CheckSignatureForm.lbResult.failed','FAILED');
         desrPubkey:s:=s+' '+localizzzeString('CheckSignatureForm.lbResult.noaddress','');
       end;
     end;

     lbResult.Items.Append(s);
     eSignature.Color:=clGray;
     bRemoveSign.Enabled:=false;
     bSign.Enabled:=false;
     exit;
  end;


  res:=desrError;
  sList:=extractSignatures(theText);

  //remove last eol if sList.count=0
  if sList.Count=0 then //did not have any signatures. Remove last eol!
    //erase last \n
    if (length(theText)>2) and (copy(theText,length(theText)-1,2)=#13#10) then
       delete(theText,length(theText)-1,2)
    else
       if (theText<>'') and (theText[length(theText)]=#10) then delete(theText,length(theText),1);



  try
    if length(trim(eSignature.Text))>80 then
      try
        //sList.Append(base64ToBuf(trim(eSignature.Text)));
        sList.Append('-----EMSIGN='+trim(eSignature.Text)+'-----');
        eSignature.Color:=clWhite;
      except
        eSignature.Color:=$CCCCFF;
      end else eSignature.Color:=clDefault;

    lbResult.Items.Clear;
    for i:=0 to sList.Count-1 do begin

        //signatures could have different format
        res:=decodeEmbededSignature(sList[i],theText,pubkey,sigtype,ClaimedAddress);
        if res<>desrError then
          if ClaimedAddress<>''
             then s:=ClaimedAddress
             else s:=publicKey2Address(pubkey,globals.AddressSig)
        else
          s:='';

        if isMyAddress(s) then begin
           if (res=desrPassed) or (res=desrFailed)
              or (
               (res=desrPubkey)
               and
               (isMyAddress(s))
              )
           then signedByMe:=true;
           s:=s+' '+localizzzeString('CheckSignatureForm.lbResult.yourAddress','(YOUR ADDRESS)');
           if ((res=desrPassed) or (res=desrPubkey))
             then lDoISign.Caption:=localizzzeString('CheckSignatureForm.lDoISign.Signed','')
             else lDoISign.Caption:=localizzzeString('CheckSignatureForm.lDoISign.SignedIncorrect','');
        end;

        case res of
          desrError:s:=s+' '+localizzzeString('CheckSignatureForm.lbResult.error','ERROR');
          desrPassed:s:=s+' '+localizzzeString('CheckSignatureForm.lbResult.passed','PASSED');
          desrFailed:s:=s+' '+localizzzeString('CheckSignatureForm.lbResult.failed','FAILED');
          desrPubkey:s:=s+' '+localizzzeString('CheckSignatureForm.lbResult.noaddress','');
        end;


        {
        //! PubKey:=HexToBuf('03F5D6B29C47B1616AF30C632FAF495A132C9B4EDC2175B674FD1E4D9A084BECF3');//D!!!
        try
          if ECDSAVerify(PubKey,digest,bip66encode(sList[i]))
          then
            s:=s+' '+localizzzeString('CheckSignatureForm.lbResult.passed','PASSED')
          else
            s:=s+' '+localizzzeString('CheckSignatureForm.lbResult.failed','FAILED');

        except
          s:=s+' INTERNAL ERROR';
        end;
        }
        lbResult.Items.Append(s);
    end;
  finally
    sList.Free;
  end;

  if not signedByMe then
    lDoISign.Caption:=localizzzeString('CheckSignatureForm.lDoISign.NotSigned','');

   //(res=desrFailed)?
  bSign.Enabled:=not signedByMe;
  bRemoveSign.Enabled:=signedByMe;
end;

procedure TCheckSignatureForm.FormShow(Sender: TObject);
begin
  localizzze(self);
  eSignature.Text:='';
  seMessage.Text:='';
  checkSignature(sender);
end;

procedure TCheckSignatureForm.Button2Click(Sender: TObject);
begin
//  seMessage.Text:='';
  seMessage.Text:='test message6'#10'-----BTSIGN=Hx2+vpYFH80XjwDVvyFa+3gd2oLklkV/BHsnCdP6Ww2JbgtCPI5CMzit0Kai/U+tCcEgtRZLfoXOiac0cgyE2zo=-----';
  checkSignature(sender);
end;

procedure TCheckSignatureForm.bSignClick(Sender: TObject);
var message:string;
  sList:TStringList;
begin
  //1. Extract the message
  message:=seMessage.Text;
  bSign.Enabled:=false;

  if chUnixEOL.Checked then
    while pos(#13#10,message)>0 do delete(message,pos(#13#10,message),1);


  try
    sList:=extractSignatures(message);
    if sList.Count=0 then //did not have any signatures. Remove last eol!
      //erase last \n
      if (length(message)>2) and (copy(message,length(message)-1,2)=#13#10) then
         delete(message,length(message)-1,2)
      else
         if (message<>'') and (message[length(message)]=#10) then delete(message,length(message),1);
  finally
    sList.free;
    checkSignature(Sender);
  end;
  if message='' then exit;

  seMessage.Lines.Append('-----EMSIGN='+MainForm.eAddress.text+':'+bufTobase64(signMessage(message,MainForm.getPrivKey()))+'-----');
  checkSignature(Sender);
end;

procedure TCheckSignatureForm.bCloseClick(Sender: TObject);
begin
  close;
end;

procedure TCheckSignatureForm.bRemoveSignClick(Sender: TObject);
var sList:tStringList;
  s:string;
  pubkey,sigtype,ClaimedAddress,sign:ansistring;
  i:integer;
  res:tdecodeEmbededSignatureResult;
  theText,message:string;
begin

  //find 1-line signature
  theText:=seMessage.Text;
  if chUnixEOL.Checked then
    while pos(#13#10,theText)>0 do delete(theText,pos(#13#10,theText),1);

  bRemoveSign.Enabled:=false;
  sList:=extractSignatures(theText);
  try
    //finding our signature. Delete it, rebuild the text and exit;
    for i:=0 to sList.Count-1 do begin

        //signatures could have different format
        res:=decodeEmbededSignature(sList[i],theText,pubkey,sigtype,ClaimedAddress);
        if res<>desrError then
          if ClaimedAddress<>''
             then s:=ClaimedAddress
             else s:=publicKey2Address(pubkey,globals.AddressSig)
        else
          s:='';

        if isMyAddress(s) then begin
           if (res=desrPassed) or (res=desrFailed)
              or (
               (res=desrPubkey)
               and
               (isMyAddress(s))
              )
           then  begin
             //remove this line, rebuild and exit
             sList.Delete(i);
             seMessage.Text:=theText;
             seMessage.Lines.AddStrings(sList);
             exit;
           end;
        end;
    end;
  finally
    sList.Free;
    checkSignature(sender);
  end;
end;

procedure TCheckSignatureForm.Button3Click(Sender: TObject);
begin
  seMessage.Text:='test message s'#10'-----EMSIGN=Hzxp/keuswdnrQIoapMohKQ+BbhzRfcKJBf85lhDAdyAYc5bXPg3sv3DTJ5q1H3Tyb/mw6jixjRRn0MWkCwj8iI=-----';
  checkSignature(sender);

end;

procedure TCheckSignatureForm.Button4Click(Sender: TObject);
begin
  //L2YLzmpTWskzD86ScNnrWcE9kJx97CZTBjuAfsrYwAbcVEsMHaxj
  seMessage.Text:=
'-----BEGIN BITCOIN SIGNED MESSAGE-----'#10+
'This is an example of a signed message.'#10+
'-----BEGIN SIGNATURE-----'#10+
'1BCbGFZU8Q2bb7XBE7MCeRBhgAqtDg8A6A'#10+
'IND2MxJFIPNDKYFAl2xRCkkP9T2gTB4LtmKBj7UceO4W8DTIxCX+4205uT6sVu2sxL5aG8d081DohF4FsyCOkoE='#10+
'-----END BITCOIN SIGNED MESSAGE-----';
  checkSignature(sender);

end;

end.

