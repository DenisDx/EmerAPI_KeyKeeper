unit frameCreateNameUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterAny, Forms, Controls,
  ExtCtrls, StdCtrls, Buttons, Spin, GUIHelperUnit, fpjson,
  EmerAPIBlockchainUnit, CryptoLib4PascalConnectorUnit, SynEditMarkupSpecialLine, Graphics, SynEditMiscClasses, SynEmerNVS;

type

  { TFrameCreateName }

  TFrameCreateName = class(TFrame)
    bSend: TBitBtn;
    bDevShowTX: TBitBtn;
    bViewName: TBitBtn;
    cLoadTemplate: TComboBox;
    eName: TEdit;
    lValue: TLabel;
    lName: TLabel;
    lDays: TLabel;
    lLoadTemplate: TLabel;
    lFullStat: TLabel;
    lNameStat: TLabel;
    lNameExits: TLabel;
    lValueStat: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    seDays: TSpinEdit;
    seValue: TSynEdit;
    procedure bDevShowTXClick(Sender: TObject);
    procedure bSendClick(Sender: TObject);
    procedure bViewNameClick(Sender: TObject);
    procedure cLoadTemplateClick(Sender: TObject);
    procedure nameCheckTimeTimer(Sender: TObject);
    procedure updateStat(Sender: TObject);
  private
    nameCheckTime:tTimer;
    SynEmerNVSSyn:tSynEmerNVSSyn;
    procedure SendingError(Sender: TObject);
    procedure Sent(Sender: TObject);
    procedure AsyncAddressInfoDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
  public
    procedure init(visualdata:tVisualData);
    procedure down();
  end;

implementation

{$R *.lfm}
uses MainUnit, settingsUnit, helperUnit, EmerAPIMain, emertx, CreateRawTXunit, crypto, emerapitypes, EmerAPITransactionUnit, Localizzzeunit

   ,NameViewUnit
   ,NVSRecordUnit
   ;

{ TFrameCreateName }

procedure TFrameCreateName.bDevShowTXClick(Sender: TObject);
var //txList:tList;
    address,nName,nValue:ansistring;
    tx:tEmerTransaction;
begin
  //создаем имя

  address:=base58ToBufCheck(MainForm.eAddress.Text);
  nName:=trim(eName.text);
  if length(nName)>512 then begin
    eName.SetFocus;
    showMessageSafe('Name too long');
    exit;
  end;

  nValue:=trim(clear13(seValue.text));
  if length(nValue)>20480 then begin
    seValue.SetFocus;
    showMessageSafe('Value too long');
    exit;
  end;

  {
  if seDays.Value>65535 then begin
    seDays.SetFocus;
    showMessageSafe('Time too long');
    exit;
  end;

  }


  tx:=tEmerTransaction.create(emerAPI);
  try
    tx.addOutput(tx.createNameScript(address,nName,nValue,seDays.Value,True),emerAPI.blockChain.MIN_TX_FEE);
       //EmerAPI.blockChain.getNameOpFee(seDays.Value,opNum('OP_NAME_NEW'),length(nName)+length(nValue))


    //ttx addInputs - Добавляет входы по выходам... добавляет желания. может сама добавить сдачу на еще один вход
    //если передан change address
    if tx.makeComplete then begin//add inputs, send change back to myself
     MainForm.miTXClick(nil);
     CreateRawTXForm.LoadbinTX(packTX(tx.getTTX));
     CreateRawTXForm.Edit13.Text:=inttostr(tx.getFullSpend);
   end else showMessageSafe('Can''t create transaction: '+tx.LastError);
  finally
    tx.free;
  end;

end;

procedure TFrameCreateName.bSendClick(Sender: TObject);
var //txList:tList;
    address,nName,nValue:ansistring;
    tx:tEmerTransaction;
begin
  //создаем имя

  address:=base58ToBufCheck(MainForm.eAddress.Text);
  nName:=trim(eName.text);
  if length(nName)>512 then begin
    eName.SetFocus;
    showMessageSafe('Name too long');
    exit;
  end;

  nValue:=trim(clear13(seValue.text));
  if length(nValue)>20480 then begin
    seValue.SetFocus;
    showMessageSafe('Value too long');
    exit;
  end;

  if length(nValue)<1 then begin
    seValue.SetFocus;
    showMessageSafe('Value cannot be empty');
    exit;
  end;

{
  if seDays.Value>65535 then begin
    seDays.SetFocus;
    showMessageSafe('Time too long');
    exit;
  end;
}

  tx:=tEmerTransaction.create(emerAPI,true);
//  try
    tx.addOutput(tx.createNameScript(address,nName,nValue,seDays.Value,True),emerAPI.blockChain.MIN_TX_FEE);
       //EmerAPI.blockChain.getNameOpFee(seDays.Value,opNum('OP_NAME_NEW'),length(nName)+length(nValue))
    if tx.makeComplete then begin
      if tx.signAllInputs(MainForm.PrivKey) then begin
        tx.sendToBlockchain(EmerAPINotification(@Sent,'sent'));
        tx.addNotify(EmerAPINotification(@SendingError,'error'));

        eName.Text:='';
        //meValue.Text:='';

      end else showMessageSafe('Can''t sign all transaction inputs using current key: '+tx.LastError);
    end else showMessageSafe('Can''t create transaction: '+tx.LastError);

//  finally
//    tx.Free;
//  end;


end;

procedure TFrameCreateName.bViewNameClick(Sender: TObject);
begin
  ShowNameViewForm(trim(eName.Text));
end;

procedure TFrameCreateName.cLoadTemplateClick(Sender: TObject);
begin
  case cLoadTemplate.ItemIndex of
    1:begin//EmerDNS
       eName.Text:=localizzzeString('tFrameCreateName.Templates.dnsName','dns:yourname.emc');
       seValue.Text:=localizzzeString('tFrameCreateName.Templates.dnsValue','A=127.0.0.1');
    end;
    2:begin//EmerSSH
       eName.Text:=localizzzeString('tFrameCreateName.Templates.sshName','ssh:YourName');
       seValue.Text:=localizzzeString('tFrameCreateName.Templates.sshValue','insert you ssh cert');
    end;
    3:begin//EmerSSL
       eName.Text:=localizzzeString('tFrameCreateName.Templates.sslName','ssl:YourName');
       seValue.Text:=localizzzeString('tFrameCreateName.Templates.sslValue','sha256=insert certificate hash');
    end;
    4:begin//ENUMER
       //"name" : "enum:12027139373:0"
       //"value" : "SIG=ver:enum|HxQY4nUHtf+nK/btxa0jT4UuPQPKk0pyxrJuXlF8YVVFDKhY6PVcE1XiSvTOxlQryzfA1GIH2IRYk7uGHrZIbP4= E2U+sip=100|10|!.*$!sip:17772328716@in.callcentric.com
       //SIG=verifier|signature E2U+sip=PRI1|PRI2|RegExp
       eName.Text:=localizzzeString('tFrameCreateName.Templates.enumName','enum:yourphone:0');
       seValue.Text:=localizzzeString('tFrameCreateName.Templates.enumValue','SIG=verifier|signature E2U+sip=PRI1|PRI2|RegExp');
    end;
    5:begin//EmerDPO:brand
       eName.Text:=localizzzeString('tFrameCreateName.Templates.dpoBrandName','dpo:BrandName');
       seValue.Text:=localizzzeString('tFrameCreateName.Templates.dpoBrandValue','');
    end;
    6:begin//EmerDPO:record
       eName.Text:=localizzzeString('tFrameCreateName.Templates.dpoName','dpo:BrabdName:Serial:N');
       seValue.Text:=localizzzeString('tFrameCreateName.Templates.dpoValue','');
    end;
    7:begin//EmerDOC
       eName.Text:=localizzzeString('tFrameCreateName.Templates.docName','doc:DocNameOrHash');
       seValue.Text:=localizzzeString('tFrameCreateName.Templates.docValue','');
    end;
    8:begin//EMCERT
       eName.Text:=localizzzeString('tFrameCreateName.Templates.certName','cert:addreddor&name:type:N');
       seValue.Text:=localizzzeString('tFrameCreateName.Templates.certValue','');
    end;
  end;
  updateStat(Sender);
end;


procedure TFrameCreateName.AsyncAddressInfoDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
var js,e:tJsonData;
    s:string;
    val,x:double;
    nc,i,n:integer;
    st:ansistring;
    vR,vY,vS:double;
    nameScript:tNameScript;
    amount:integer;

begin

 bViewName.Enabled:=false;
 bSend.Enabled:=false;
 if result=nil then begin
   //showMessageSafe('Error: '+sender.lastError);
   lNameExits.Caption:='checking name error:'+sender.lastError;
   exit;
 end;

 if sender.id=('checkname:'+trim(eName.Text)) then begin
  e:=result.FindPath('result');
  if e<>nil then
     if e.IsNull then begin
       lNameExits.Caption:=localizzzeString('tFrameCreateName.NameIsFree','Name is not registered yet');
       bSend.Enabled:=trim(eName.Text)<>'';
     end else
     try
       lNameExits.Caption:=
         e.FindPath('address').AsString
         + localizzzeString('tFrameCreateName.NameIsDelegated',' has registered the name till ')
         + datetostr(trunc(now() + e.FindPath('expires_in').AsInt64/175 ));
       bViewName.Enabled:=true;
     except
       lNameExits.Caption:='Error: incorrect name data in: '+result.AsJSON;
     end
  else lNameExits.Caption:='Error: can''t find result in: '+result.AsJSON;


 end else begin
   lNameExits.Caption:='checking name...';
   nameCheckTime.Enabled:=true;
 end;

end;

procedure TFrameCreateName.nameCheckTimeTimer(Sender: TObject);
var s:ansistring;
begin
  nameCheckTime.Enabled:=false;

  s:=trim(eName.Text);
  //name_show {name:"ssl:Denis"}
  emerAPI.EmerAPIConnetor.sendWalletQueryAsync('name_show',getJSON('{name:"'+s+'"}'),@AsyncAddressInfoDone,'checkname:'+s);
end;



procedure TFrameCreateName.SendingError(Sender: TObject);
begin
 if Sender is tEmerTransaction
   then ShowMessageSafe('Sending error: '+tEmerTransaction(sender).lastError)
   else ShowMessageSafe('Sending error');
end;

procedure TFrameCreateName.Sent(Sender: TObject);
begin
  ShowMessageSafe('Successfully sent');
end;


procedure TFrameCreateName.UpdateStat(Sender: TObject);
var
  c:dword;
  nName,nValue:ansistring;
begin
  if EmerAPI=nil then exit;

  bSend.Enabled:=false;

  nName:=trim(eName.text);
  lNameStat.Caption:=inttostr(length(nName))+' chars ('+inttostr(round(length(nName)/512))+'%)';
  if length(nName)>512 then
    lNameStat.Caption:=lNameStat.Caption+ ' maximum length exceeded! Max Len = 512';

  nValue:=trim(seValue.text);
  lValueStat.Caption:=inttostr(length(nValue))+' chars ('+inttostr(round(length(nValue)/20480))+'%)';
  if length(nValue)>20480 then
    lValueStat.Caption:=lValueStat.Caption+ ' maximum length exceeded! Max Len = 20480';

  if EmerAPI.blockChain.LastPoWReward=0
      then lFullStat.Caption:=localizzzeString('PleaseWait','Please wait')
      else begin
        c:=EmerAPI.blockChain.getNameOpFee(seDays.Value,opNum('OP_NAME_NEW'),length(nName)+length(nValue));
        lFullStat.Caption:='name cost: '+myFloatToStr(c/1000000)+' EMC ('+inttostr(c div 100)+' subcents)';
      end;

  if nameCheckTime<>nil then begin
    bViewName.Enabled:=false;
    lNameExits.Caption:='checking name...';
    nameCheckTime.Enabled:=false;
    nameCheckTime.Enabled:=true;
  end;

    
  if (pos(':',eName.Text)>0) then begin
    setSynHighliterByName(SynEmerNVSSyn,eName.Text);
    seValue.Highlighter:=SynEmerNVSSyn;
  end
  else
    seValue.Highlighter:=nil;

  if verifyNVSName(eName.Text)
      then begin eName.Color:=clDefault; eName.Font.Color:=clDefault end
      else begin eName.Color:=clYellow; eName.Color:=clBlack; end;

end;

procedure TFrameCreateName.down();
begin
  if nameCheckTime<>nil then
    freeandnil(nameCheckTime);
  if SynEmerNVSSyn<>nil then
    freeandnil(SynEmerNVSSyn);
end;

procedure TFrameCreateName.init(visualdata:tVisualData);
begin
  if SynEmerNVSSyn=nil then SynEmerNVSSyn:=tSynEmerNVSSyn.Create(owner);

  if visualdata<>nil then begin
    color:=visualdata.bgColor;
    //eValue.color:=visualdata.sEdit.Color;
    //eValue.BorderStyle:=visualdata.sEdit.BorderStyle;
    //lPayee.font.Assign(visualdata.slabel.Font);
    //pAddressInfo.Color:=visualdata.sPanel.color;
    bSend.Color:=visualdata.sButton.Color;
  end;

  bDevShowTX.Visible:=Settings.getValue('Dev_Mode_ON');
  seValue.text:='';
  seValue.Highlighter:=nil;
  eName.Text:='';
  lNameStat.Caption:='';
  lValueStat.Caption:='';
  lFullStat.Caption:='';
  seDays.Value:=365;
  //FrameSelectAddress1.init(visualdata);

  localizzze(self);

  if nameCheckTime=nil then begin
    nameCheckTime:=tTimer.Create(owner);
    nameCheckTime.Enabled:=false;


    if Settings.getValue('USE_LOCAL_WALLET') and emerAPI.EmerAPIConnetor.walletAPI.testedOk
        then nameCheckTime.Interval:=5
        else nameCheckTime.Interval:=100;
    nameCheckTime.onTimer:=@nameCheckTimeTimer;
  end;

  lNameExits.Caption:='';
  bViewName.Enabled:=false;
  bSend.Enabled:=false;
end;

end.

