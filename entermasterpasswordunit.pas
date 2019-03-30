unit EnterMasterPasswordUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, ButtonPanel, fpjson, jsonparser, ExtCtrls, EmerAPIBlockchainUnit, HDNodeUnit;

type

  { TEnterMasterPasswordFrame }

  TEnterMasterPasswordFrame = class(TFrame)
    chLegacyMode: TCheckBox;
    chShowMasterPassword: TCheckBox;
    eMasterPassword: TEdit;
    eAddress: TEdit;
    lMasterPassword: TLabel;
    lComment: TLabel;
    lAssignedAddress: TLabel;
    lAddressInfo: TLabel;
    pBip39Helper: TPanel;
    procedure chShowMasterPasswordChange(Sender: TObject);
    procedure eMasterPasswordChange(Sender: TObject);
    procedure eMasterPasswordKeyPress(Sender: TObject; var Key: char);
    procedure onBipButtonClick(sender: TObject);
    procedure setButtons(l:tStringList);
    procedure myTimerTimer(Sender: TObject);
    procedure blinkTimerTimer(Sender: TObject);
    procedure clearButtonTimerTimer(Sender: TObject);
    procedure onHelpButtonPress(Sender: TObject);
  private
    lHelpButtons:tList;
    myTimer:tTimer;
    blinkTimer:tTimer;
    clearButtonTimer:tTimer;
    hd:tHDNode;
    procedure AsyncDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
  public
    onPasswordChanged:tNotifyEvent;
    procedure init;
    procedure down;
    function getPrivKey:string;
  end;

implementation

uses PasswordHelper, crypto, CryptoLib4PascalConnectorUnit, UOpenSSLdef, UOpenSSL, MainUnit,  HelperUnit, localizzzeUnit, Graphics, settingsunit;

{$R *.lfm}

{ TEnterMasterPasswordFrame }
function TEnterMasterPasswordFrame.getPrivKey:string;
begin
  result:='';
  if eMasterPassword.text='' then exit;
  if MasterPasswordValid(eMasterPassword.text,Settings.getValue('Dev_Mode_ON') and chlegacyMode.checked)
    then

      if Settings.getValue('Dev_Mode_ON') and chlegacyMode.checked then begin
         result:=DoSha256(trim(eMasterPassword.Text)); //eMasterPassword.text
      end else begin
        mainForm.loadHDNodeFromBip(hd,smartExtractBIP32pass(trim(eMasterPassword.Text)));
        if hd.isValid then begin
          result:=hd.getPrivateKey;
        end;
      end
    else begin
      eMasterPassword.Color:=clRed;
      eAddress.Color:=clRed;
      eMasterPassword.Font.Color:=clBlack;
      eAddress.Font.Color:=clBlack;
      BlinkTimer.enabled:=true;
    end;
end;

procedure TEnterMasterPasswordFrame.init;
begin
 if myTimer=nil then begin
   myTimer:=tTimer.Create(owner);
   myTimer.Enabled:=false;
   myTimer.Interval:=100;
   myTimer.OnTimer:=@myTimerTimer;
 end;
 if blinkTimer=nil then begin
   blinkTimer:=tTimer.Create(owner);
   blinkTimer.Enabled:=false;
   blinkTimer.Interval:=333;
   blinkTimer.OnTimer:=@blinkTimerTimer;
 end;

 if clearButtonTimer=nil then begin
   clearButtonTimer:=tTimer.Create(owner);
   clearButtonTimer.Enabled:=false;
   clearButtonTimer.Interval:=1;
   clearButtonTimer.OnTimer:=@clearButtonTimerTimer;
 end;

 if lHelpButtons=nil then
    lHelpButtons:=tList.Create
 else
   while lHelpButtons.Count>0 do begin
     tButton(lHelpButtons[0]).Free;
     lHelpButtons.Delete(0);
   end;
 eMasterPassword.Text:='';

 chLegacyMode.Visible:= Settings.getValue('Dev_Mode_ON');
end;

procedure TEnterMasterPasswordFrame.down;
begin
 if lHelpButtons<>nil then freeandnil(lHelpButtons);
 if clearButtonTimer<>nil then freeandnil(clearButtonTimer);
 if myTimer<>nil then freeandnil(myTimer);
 if blinkTimer<>nil then freeandnil(blinkTimer);
end;

procedure TEnterMasterPasswordFrame.onHelpButtonPress(Sender: TObject);
var s:string;
    n:integer;
begin
 s:=eMasterPassword.Text;
 n:=length(s);

 while (s[n]<>' ') and (n>1) do n:=n-1;


 s:=copy(s,1,n)+tButton(sender).Caption+' ';

 eMasterPassword.setFocus;
 eMasterPassword.Text:=s;
end;

procedure TEnterMasterPasswordFrame.onBipButtonClick(Sender: TObject);
var s:string;
    i:integer;
begin
  if Sender=nil then exit;
  if not (sender is tButton) then exit;

  //change last word to caption
  s:=eMasterPassword.Text;
  i:=length(s);
  while (i>0) and (s[i]<>' ') do dec(i);

  eMasterPassword.Text:=copy(s,1,i) + (sender as tButton).Caption+' ';
  //eMasterPassword.SelStart:=length(eMasterPassword.Text)-1;
  eMasterPassword.SetFocus;
  eMasterPassword.SelStart := high(Integer);

end;



procedure TEnterMasterPasswordFrame.setButtons(l:tStringList);
var x,i:integer;
    sep:integer = 5;
    bw:integer = 60;
    btn:tButton;
begin
  if l=nil then begin
    while pBip39Helper.ControlCount>0 do
      pBip39Helper.Controls[0].free;
    exit;
  end;
  //1. check existing buttons
  x:=0{sep}; i:=0;
  while i<pBip39Helper.ControlCount do
    if pBip39Helper.Controls[i] is tButton then
      if l.IndexOf(tButton(pBip39Helper.Controls[i]).Caption)>=0 then begin
        l.Delete(l.IndexOf(tButton(pBip39Helper.Controls[i]).Caption));
        tButton(pBip39Helper.Controls[i]).Left:=x;
        x:=x+sep+tButton(pBip39Helper.Controls[i]).Width;
        inc(i);
      end
      else
      begin
       tButton(pBip39Helper.Controls[i]).Free;
      end;

  //add
  i:=0;
  while ((bw+x{+sep})<pBip39Helper.Width) and (i<l.Count) do begin
    btn:=tButton.Create(pBip39Helper.Owner);
    btn.Width:=bw; btn.Height:=pBip39Helper.Height-sep*2;
    btn.Left:=x; x:=x+sep+bw;
    btn.Caption:=l[i];
    btn.onClick:=@onBipButtonClick;
    btn.Parent:=pBip39Helper;
    inc(i);
  end
end;

procedure TEnterMasterPasswordFrame.eMasterPasswordChange(Sender: TObject);
var s:string;
    pwd:string;
    //lWord:string;
  var l:tStringlist;
      i:integer;
  var PrivateKey:ansistring;
      pubKey:TECDSA_Public;

  procedure setAddress(s:string);
  begin
    if s<>eAddress.Text then
       if assigned(onPasswordChanged) then begin
          eAddress.Text:=s;
          onPasswordChanged(self);
       end else eAddress.Text:=s;
  end;

begin
  //pbiphelper
  //if we have a word at the beginnging, and all the words except last one is a BIP then show help
  s:=eMasterPassword.Text;
  if (length(s)>0) and (s[length(s)]<>' ') then begin
    s:=trim(s);
    pwd:='';
    if pos(' ',s)>0 then
      //cut the last word
      while (pos(' ',s)>0) do begin
        pwd:=pwd+copy(s,1,pos(' ',s));
        delete(s,1,pos(' ',s));
      end;

    l:=tStringlist.create;
    try
      if (s<>'') and (bip39tobytes(trim(pwd))<>'') then
        for i:=0 to length(bip0039english)-1 do begin
          //don''t need to scan all... but we will
          if pos(s,bip0039english[i])=1 then
            l.append(bip0039english[i]);
        end;
      setButtons(l);
    finally
      l.free;
    end;
  end else
    clearButtonTimer.Enabled:=true;



  if trim(eMasterPassword.Text)<>'' then begin
    //try
    //show address
    if Settings.getValue('Dev_Mode_ON') and chlegacyMode.checked then begin
      //PrivateKey:=CreatePrivateKeyFromStrBuf(DoSha256(trim(eMasterPassword.Text)));
      PrivateKey:=getPrivKey; //DoSha256(trim(eMasterPassword.Text))
      pubKey:=GetPublicKey(PrivateKey);
      //if pubKeyValid
      if (length(pubkey.x)<>32) or (length(pubkey.y)<>32) then begin
        lAddressInfo.caption:='';
        setAddress(localizzzeString('msgMasterPasswordHasWrongPK','THERE IS NO POSSIBLE ADDRESS'));
        exit;
      end;

      setAddress(publicKey2Address(pubKey,globals.AddressSig,true));
    end else begin

      PrivateKey:=getPrivKey; //will set hd.getAddressCode58
      if PrivateKey<>'' then setAddress(hd.getAddressCode58) else begin
        lAddressInfo.caption:='';
        setAddress(localizzzeString('msgMasterPasswordHasWrongPK','THERE IS NO POSSIBLE ADDRESS'));
        exit;
      end;
      {
      mainForm.loadHDNodeFromBip(hd,smartExtractBIP32pass(trim(eMasterPassword.Text)));
      if hd.isValid then begin
        setAddress(hd.getAddressCode58);
      end else begin
        lAddressInfo.caption:='';
        setAddress(localizzzeString('msgMasterPasswordHasWrongPK','THERE IS NO POSSIBLE ADDRESS'));
        exit;
      end;}

    end;


    lAddressInfo.caption:='';
    myTimer.Enabled:=false;
    myTimer.Enabled:=true;

    //Is a local wallet conncted, try to show info
    //finally
    //  if Assigned(PrivateKey) then EC_KEY_free(PrivateKey);
    //end
  end else begin
    lAddressInfo.caption:='';
    eAddress.Text:='';
  end;
end;

procedure TEnterMasterPasswordFrame.eMasterPasswordKeyPress(Sender: TObject;
  var Key: char);
begin
  if key=#13 then
    if pBip39Helper.ControlCount>0 then
      onBipButtonClick(pBip39Helper.Controls[0]);

end;

procedure TEnterMasterPasswordFrame.AsyncDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
  var js,e:tJsonData;
      s:string;
      val,x:double;
      nc,i:integer;
      st:ansistring;
begin
  if result=nil then exit;
  js:=result;

 if js<>nil then
   //e:=js.FindPath('result.total_amount');
   e:=js.FindPath('result.unspents');
   if e<>nil then begin
     nc:=0;
     val:=0;

     for i:=0 to TJSONArray(e).Count-1 do begin
       st:=e.Items[i].FindPath('scriptPubKey').AsString;
       x:=myStrToFloat(e.Items[i].FindPath('amount').AsString);
       if length(st)=0 then exit;
       if (copy(st,1,2)='51') or (copy(st,1,2)='52') then begin
         nc:=nc+1;
       end else val:=val+x;

     {
       "success": 1,
       "searched_items": 35037,
       "unspents": [
         {
           "txid": "e745e0f1f55604cd6377bddfe94c7b6db6a88c4d291fb8facb3c86a6a6eb0e0b",
           "vout": 1,
           "scriptPubKey": "76a914251b4e68724a3226606cfb307cac0656d04a529588ac",
           "amount": 23.000000,
           "height": 22700
         },
         {
           "txid": "e50ad2ea1c1e6348203278686523e0a39ede850a67485e85a3dc7681cd1c0a42",
           "vout": 1,
           "scriptPubKey": "76a914251b4e68724a3226606cfb307cac0656d04a529588ac",
           "amount": 100.000000,
           "height": 22699
         },
         {
           "txid": "ca6fafb6eec3d5947975a30de535ee188b277b670a4c2f5f8de1c3e458d65574",
           "vout": 1,
           "scriptPubKey": "5175057465737431011e6d0574657374317576a914251b4e68724a3226606cfb307cac0656d04a529588ac",
           "amount": 0.000100,
           "height": 22700
         }
       ],
       "total_amount": 123.000100
     }
     end;


     lAddressInfo.caption:=
       'Spendable balance: '+myFloatToStr(val)+#10
       +'Names : '+intToStr(nc);

   end;
end;

procedure TEnterMasterPasswordFrame.myTimerTimer(Sender: TObject);
  var s:string;
begin
  myTimer.Enabled:=false;
  lAddressInfo.caption:='';
  if emerAPI<>nil then
  if emerAPI.EmerAPIConnetor.walletAPI.testedOk then begin
     //'{"jsonrpc": "1.0", "id":"curltest", "method":"scantxoutset","params":["start", [{"script" : "76A914CED2436C4D0169B69E8E71C413DC5C5B20F5376388AC" }]]}'

     //s:=LocalWallet.requestString('scantxoutset',['start','[{"address" : "'+eAddress.Text+'" }]'],'result.total_amount');
     //lAddressInfo.caption:=s;

    //['start','[{"address" : "'+eAddress.Text+'" }]']


    if Settings.getValue('Dev_Mode_ON') and chlegacyMode.checked
      then s:=eAddress.Text
      else s:=hd.getAddressCode58;


    //emerAPI.EmerAPIConnetor.walletAPI.sendQueryAsync('scantxoutset',GetJSON('"start",[{"address" : "'+s+'" }]'),@AsyncDone)
    emerAPI.EmerAPIConnetor.walletAPI.sendQueryAsync('scantxoutset',GetJSON('{"action":"start",scanobjects:[{"address" : "'+s+'" }]}'),@AsyncDone)
    //emerAPI.EmerAPIConnector.walletAPI.sendWalletQueryAsync('scantxoutset',
    //  GetJSON('{"action":"start",scanobjects:['+s+']}')
    // ,@AsyncDone);


  end;

end;

procedure TEnterMasterPasswordFrame.clearButtonTimerTimer(Sender: TObject);
begin
  clearButtonTimer.enabled:=false;
  setButtons(nil);
end;

procedure TEnterMasterPasswordFrame.blinkTimerTimer(Sender: TObject);
begin
  BlinkTimer.enabled:=false;
  eMasterPassword.Color:=clDefault;
  eAddress.Color:=clBtnFace;
  eMasterPassword.Font.Color:=clDefault;
  eAddress.Font.Color:=clDefault;
end;

procedure TEnterMasterPasswordFrame.chShowMasterPasswordChange(Sender: TObject);
begin
  if chShowMasterPassword.Checked
   then eMasterPassword.PasswordChar:=#0
   else eMasterPassword.PasswordChar:='*'
   ;
end;

end.

