unit TakePossessionUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  StdCtrls, ExtCtrls, EnterMasterPasswordUnit, UTXOunit;

type

  { TTakePossessionForm }

  TTakePossessionForm = class(TForm)
    bClose: TBitBtn;
    bRequestAssets: TBitBtn;
    bTakePossession: TBitBtn;
    chShowInTxViewer: TCheckBox;
    EnterMasterPasswordFrame1: TEnterMasterPasswordFrame;
    ePassword: TEdit;
    ePrivateKey: TEdit;
    eSerial: TEdit;
    lPassword: TLabel;
    lPrivateKey: TLabel;
    lSerial: TLabel;
    lTakePossession: TLabel;
    lTakePossession1: TLabel;
    lTakePossession2: TLabel;
    lTakePossession3: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    rbTakeMasterPassword: TRadioButton;
    rbTakePrivateKey: TRadioButton;
    rbTakeSerialPassword: TRadioButton;
    sbAssets: TScrollBox;
    timerUpdate: TTimer;
    procedure bCloseClick(Sender: TObject);
    procedure bRequestAssetsClick(Sender: TObject);
    procedure bTakePossessionClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure refreshView(Sender:TObject);
    procedure timerUpdateTimer(Sender: TObject);
    procedure updateAddress;
  private
    lastRequestNo:integer;
    lastRequestData:ansistring;
    lastPrivKey:ansistring;
    lastAddress:ansistring;
    //lastAssetsAddress:ansistring; //the address used for last assets list creation

    fTargetUTXOList:tUTXOList;

    fNotSentCounter:integer;
    //fTargetUTXOListAddress:ansistring;
    procedure utxoUpdated(Sender:tObject);
    procedure SendingError(Sender: TObject);
    procedure Sent(Sender: TObject);
    procedure checkIfFinished;

  public
    procedure clearAssetList;
    procedure fillAssetList; //by lastAddress. set lastAssetsAddress after all finished
  end;

var
  TakePossessionForm: TTakePossessionForm;

implementation

uses SettingsUnit,Localizzzeunit, questionUnit
  ,Crypto
  ,MainUnit
  ,FrameBaseNVSUnit
  ,FrameDigitalAssetUnit
  ,CryptoLib4PascalConnectorUnit
  ,emerapitypes
  ,HelperUnit
  ,EmerAPITransactionUnit
  ,CreateRawTXunit
  ,EmerTX
  ;

{$R *.lfm}

procedure TTakePossessionForm.updateAddress;
begin
  timerUpdate.Enabled:=false;
  if rbTakeSerialPassword.Checked then begin
    lastRequestNo:=0;
    lastRequestData:=trim(eSerial.Text)+trim(ePassword.Text);
  end else
  if rbTakePrivateKey.Checked then begin
    lastRequestNo:=1;
    try
      lastRequestData:=base58ToBufCheck(trim(ePrivateKey.Text));
      if not checkPrivKey(lastRequestData) then lastRequestData:='';
    except
      lastRequestData:='';
    end;

    if lastRequestData='' then begin
      lastRequestNo:=-1;
      lTakePossession1.Caption:=localizzzeString('TakePossessionForm.lTakePossession1.InvalidPrivateKey','');
      lTakePossession2.Caption:=localizzzeString('TakePossessionForm.lTakePossession1.InvalidPrivateKey','');
      lTakePossession3.Caption:=localizzzeString('TakePossessionForm.lTakePossession1.InvalidPrivateKey','');
      bTakePossession.Enabled:=false;
      bRequestAssets.Enabled:=false;
    end;
  end else
  if rbTakeMasterPassword.Checked then begin
    lastRequestData:=EnterMasterPasswordFrame1.getPrivKey;
    lastRequestNo:=2;
  end else begin
    lastRequestNo:=-1;
    lTakePossession1.Caption:='';
    lTakePossession2.Caption:='';
    lTakePossession3.Caption:='';
    bTakePossession.Enabled:=false;
    bRequestAssets.Enabled:=false;
  end;

  //clear assets list if changed

  if (lastRequestNo>=0) and (lastRequestData<>'')
    then begin
      lTakePossession1.Caption:=localizzzeString('TakePossessionForm.lTakePossession1','')+''+localizzzeString('PleaseWait','');
      lTakePossession2.Caption:=localizzzeString('TakePossessionForm.lTakePossession2','')+''+localizzzeString('PleaseWait','');
      lTakePossession3.Caption:=localizzzeString('TakePossessionForm.lTakePossession3','')+''+localizzzeString('PleaseWait','');
      bTakePossession.Enabled:=false;
      bRequestAssets.Enabled:=false;
      timerUpdate.Enabled:=true;
    end else begin
      clearAssetList;
      lastRequestNo:=-1;
      lTakePossession1.Caption:='';
      lTakePossession2.Caption:='';
      lTakePossession3.Caption:='';
      bRequestAssets.Enabled:=false;
      bTakePossession.Enabled:=false;
    end;


  //localizzzeString('MainForm.sbPK.UNLOCKED','UNLOCKED')

end;

procedure TTakePossessionForm.refreshView(Sender:TObject);
begin
 // if rbTakeSerialPassword.Checked;


  lSerial.Enabled:=rbTakeSerialPassword.Checked;
  eSerial.Enabled:=rbTakeSerialPassword.Checked;
  lPassword.Enabled:=rbTakeSerialPassword.Checked;
  ePassword.Enabled:=rbTakeSerialPassword.Checked;

  lPrivateKey.Enabled:=rbTakePrivateKey.Checked;
  ePrivateKey.Enabled:=rbTakePrivateKey.Checked;

  EnterMasterPasswordFrame1.Enabled:=rbTakeMasterPassword.Checked;

  bTakePossession.Enabled:= (fTargetUTXOList<>nil) and (fTargetUTXOList.Count>0) and (lastAddress=fTargetUTXOList.tagString);

  updateAddress;


end;

procedure TTakePossessionForm.clearAssetList;
begin
  //if fTargetUTXOList<>nil then  memo1.Lines.Append('clearAssetList: '+fTargetUTXOList.tagString);
  //fTargetUTXOList:=nil;
  if (fTargetUTXOList<>nil) then freeAndNil(fTargetUTXOList);

  while sbAssets.ControlCount>0 do
    if sbAssets.Controls[0] is TFrameBaseNVS
       then begin
          (sbAssets.Controls[0] as TFrameBaseNVS).down;
          (sbAssets.Controls[0] as TFrameBaseNVS).Free;
       end else sbAssets.Controls[0].Free;
end;

procedure TTakePossessionForm.utxoUpdated(Sender:tObject);
  function findControl(nvsname:ansistring):TFrameBaseNVS;
  var i:integer;
  begin
    result:=nil;
    for i:=0 to sbAssets.ControlCount-1 do
      if (sbAssets.Controls[i] is TFrameBaseNVS)
        then if (sbAssets.Controls[i] as TFrameBaseNVS).NVSRecord.NVSName=nvsname then begin
          result:=(sbAssets.Controls[i] as TFrameBaseNVS);
          exit;
        end;

  end;

var i:integer;
    frame:TFrameDigitalAsset;
begin
  //Memo1.Lines.Append('utxoUpdated: ' +tUTXOList(Sender).tagString +'; fTargetUTXOList.tagString='+fTargetUTXOList.tagString+'; lastAddress='+lastAddress);
  for i:=0 to fTargetUTXOList.Count-1 do begin
    if fTargetUTXOList[i].getNVSName<>'' then
      if findControl(fTargetUTXOList[i].getNVSName)=nil then
      begin
        frame:=TFrameDigitalAsset.Create(self);
        frame.Name:='fr'+bufToHex(dosha256(fTargetUTXOList[i].getNVSName));
        frame.Parent:=sbAssets;
        frame.Align:=alTop;
        frame.Height:=frame.Init(nil,fTargetUTXOList[i]);
        frame.updateView(nil);
        //hasNew:=true;
      end;
    application.ProcessMessages;
  end;

  //,'TakePossessionForm.lTakePossession1':{en:'Associated address:',ru:'Связанный с указанными данными адрес: '}
  // ,'TakePossessionForm.lTakePossession2':{en:'Address balance:',ru:'Баланс на адресе: '}
  // ,'TakePossessionForm.lTakePossession3':{en:'Digital assets on the address:',ru:'Цифровых активов на адресе: '}


  //lTakePossession1.Caption:=localizzzeString('TakePossessionForm.lTakePossession1','')+''+localizzzeString('PleaseWait','');
  //lTakePossession2.Caption:=localizzzeString('TakePossessionForm.lTakePossession2','')+''+myfloattostr;
  //lTakePossession3.Caption:=localizzzeString('TakePossessionForm.lTakePossession3','')+''+localizzzeString('PleaseWait','');!

   with fTargetUTXOList.getStat do begin
     lTakePossession1.Caption:=localizzzeString('TakePossessionForm.lTakePossession1','')+''+fTargetUTXOList.tagString;
     lTakePossession2.Caption:=localizzzeString('TakePossessionForm.lTakePossession2','') + myFloatToStr(spendable/1000000);
     lTakePossession3.Caption:=localizzzeString('TakePossessionForm.lTakePossession3','') + intToStr(nameCount);
     bTakePossession.Enabled:= (fTargetUTXOList<>nil) and (fTargetUTXOList.Count>0) and (lastAddress=fTargetUTXOList.tagString);
     bRequestAssets.Enabled:=false;
   end;

end;

procedure TTakePossessionForm.fillAssetList;
//by lastAddress. set lastAssetsAddress after all finished
begin
 fTargetUTXOList:=tUTXOList.create(EmerAPI.EmerAPIConnetor,EmerAPI.blockChain,addressto58(lastAddress,  EmerAPI.blockChain.AddressSig ));
 fTargetUTXOList.tagString:=lastAddress;

 //fTargetUTXOList.addNotify(EmerAPINotification(@utxoUpdated,'updateUTXO',true));
 fTargetUTXOList.update(EmerAPINotification(@utxoUpdated,'updateUTXO',true));
 //Memo1.Lines.Append('fillAssetList: ' +lastAddress);
end;


procedure TTakePossessionForm.timerUpdateTimer(Sender: TObject);
begin
  //follow
  timerUpdate.Enabled:=false;
  if lastRequestNo<0 then exit;

  lastAddress:='';
  lastPrivKey:='';

  case lastRequestNo of
    0:lastPrivKey:=createDPOPrivKey(lastRequestData);
      //if pubKeyValid
      //if (length(pubkey.x)<>32) or (length(pubkey.y)<>32) then begin
    1: lastPrivKey:=lastRequestData;
    2: lastPrivKey:=lastRequestData;
  else
      lastPrivKey:='';
  end;

  if (lastPrivKey<>'') then begin
    lastAddress:=publicKey2Address(GetPublicKey(lastPrivKey),globals.AddressSig,true);
    if {lastAssetsAddress<>lastAddress} (fTargetUTXOList=nil) or (lastAddress<>fTargetUTXOList.tagString) then begin
      lTakePossession1.Caption:=localizzzeString('TakePossessionForm.lTakePossession1','')+''+lastAddress;

      lTakePossession2.Caption:=localizzzeString('TakePossessionForm.lTakePossession2.PressButton','');
      lTakePossession3.Caption:=localizzzeString('TakePossessionForm.lTakePossession2.PressButton','');

      bTakePossession.Enabled:=false;
      clearAssetList;

      bRequestAssets.Enabled:=true;
      //Memo1.Lines.Append('fillAssetList: ' +lastAddress);
    end{ else Memo1.Lines.Append('fillAssetList: <><>: ' +lastAddress)};
  end else begin
    //undetected
    lTakePossession1.Caption:=localizzzeString('TakePossessionForm.lTakePossession1.InvalidCred','');
    lTakePossession2.Caption:=localizzzeString('TakePossessionForm.lTakePossession1.InvalidCred','');
    lTakePossession3.Caption:=localizzzeString('TakePossessionForm.lTakePossession1.InvalidCred','');
    bTakePossession.Enabled:=false;
    //Memo1.Lines.Append('fillAssetList stopall: ' +lastAddress);
    clearAssetList;
    bRequestAssets.Enabled:=false;
  end;

end;

procedure TTakePossessionForm.FormShow(Sender: TObject);
begin
  chShowInTxViewer.Visible:=Settings.getValue('Dev_Mode_ON');

  eSerial.Text:='';
  ePassword.Text:='';
  ePrivateKey.Text:='';
  //EnterMasterPasswordFrame1.eAddress.Text:='';
  rbTakeSerialPassword.Checked:=true;

  EnterMasterPasswordFrame1.init;
  EnterMasterPasswordFrame1.onPasswordChanged:=@refreshView;
  EnterMasterPasswordFrame1.lAssignedAddress.Visible:=false;
  EnterMasterPasswordFrame1.eAddress.Visible:=false;
  EnterMasterPasswordFrame1.lAddressInfo.Visible:=false;

  localizzze(self);

  lTakePossession1.Caption:='';
  lTakePossession2.Caption:='';
  lTakePossession3.Caption:='';
  bTakePossession.Enabled:=false;
  bRequestAssets.Enabled:=false;

  refreshView(nil);
end;

procedure TTakePossessionForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  EnterMasterPasswordFrame1.down;
  clearAssetList;
  lTakePossession1.Caption:='';
  lTakePossession2.Caption:='';
  lTakePossession3.Caption:='';
  bTakePossession.Enabled:=false;
  bRequestAssets.Enabled:=false;
end;

procedure TTakePossessionForm.checkIfFinished;
begin
  if fNotSentCounter=0 then begin
    ShowMessageSafe(localizzzeString('TakePossessionForm.messageTransferDone',''));
  end;
end;

procedure TTakePossessionForm.SendingError(Sender: TObject);
begin
 if Sender is tEmerTransaction
   then ShowMessageSafe(localizzzeString('TakePossessionForm.messageTransferError','')+tEmerTransaction(sender).lastError)
   else ShowMessageSafe(localizzzeString('TakePossessionForm.messageTransferError',''));
 dec(fNotSentCounter);
 checkIfFinished;
end;

procedure TTakePossessionForm.Sent(Sender: TObject);
begin
  dec(fNotSentCounter);
  checkIfFinished;
end;


procedure TTakePossessionForm.bTakePossessionClick(Sender: TObject);
var i,j:integer;
    coinsSent:boolean;
    ftx:tEmerTransaction;
    value:qword;
begin
  if fTargetUTXOList=nil then exit;

  if fTargetUTXOList.getStat.lastUpdateTime=0 then begin
    showMessageSafe('internal error: UTXO not loaded'); //  mContract.Text:=localizzzeString('AtomForm.mContract.UTXONotLoaded','***LOADING BUYER WALLET, PLEASE WAIT***');
    exit;
  end;

  coinsSent:=false;

  fNotSentCounter:=0;


  for i:=0 to fTargetUTXOList.Count-1 do begin
    if fTargetUTXOList[i].getNVSName<>'' then
      if false then begin //D!! TODO: : check name expiration
        //name expired

      end else begin
        //transfer name
         ftx:=tEmerTransaction.create(EmerAPI,true);

         ftx.addInput(fTargetUTXOList[i].txid,fTargetUTXOList[i].nOut,fTargetUTXOList[i].value,fTargetUTXOList[i].Script);

         if not coinsSent then begin
           for j:=0 to fTargetUTXOList.Count-1 do
              if fTargetUTXOList[j].getNVSName='' then
                ftx.addInput(fTargetUTXOList[j].txid,fTargetUTXOList[j].nOut,fTargetUTXOList[j].value,fTargetUTXOList[j].Script);

           coinsSent:=true;
         end;

         ftx.addOutput(ftx.createNameScript(base58ToBufCheck(trim(EmerAPI.addresses[0])),fTargetUTXOList[i].getNVSName,fTargetUTXOList[i].getNVSValue,0,false),emerAPI.blockChain.MIN_TX_FEE);

         if ftx.makeComplete{(BuyerAddress,buyerUTXO)} then begin
           if (not ftx.Sign(lastAddress,lastPrivKey)) or (not ftx.Sign(EmerAPI.addresses[0],MainForm.getPrivKey(EmerAPI.addresses[0]))) then begin
             showMessageSafe('internal error: Error signing tx');
           end else begin
             if chShowInTxViewer.Checked and Settings.getValue('Dev_Mode_ON') then begin
               MainForm.miTXClick(nil);
               CreateRawTXForm.LoadbinTX(packTX(ftx.getTTX));
               ftx.free;
             end else begin;
               ftx.sendToBlockchain(EmerAPINotification(@Sent,'sent'));
               ftx.addNotify(EmerAPINotification(@SendingError,'error'));
               fNotSentCounter:=fNotSentCounter+1;
               bTakePossession.Enabled:=false;
             end;
           end;
         end else begin showMessageSafe(localizzzeString('TakePossessionForm.messageTransferError','')+ftx.LastError); ftx.free; end;


      end;
    application.ProcessMessages;
  end;

  if (not coinsSent) and (fTargetUTXOList.Count>0) then begin
     //don't have any name? just take all the money :-)
     ftx:=tEmerTransaction.create(EmerAPI,true);

     value:=0;
     for j:=0 to fTargetUTXOList.Count-1 do
        if fTargetUTXOList[j].getNVSName='' then begin
          ftx.addInput(fTargetUTXOList[j].txid,fTargetUTXOList[j].nOut,fTargetUTXOList[j].value,fTargetUTXOList[j].Script);
          value:=value+fTargetUTXOList[j].value;
        end;

     if value=0 then begin
       showMessageSafe('Internal error: zero value');
       ftx.free;
       exit;
     end;


     ftx.addOutput(ftx.createSpendScript(addressto21(EmerAPI.addresses[0])),value-emerAPI.blockChain.MIN_TX_FEE);

     if ftx.makeComplete{(BuyerAddress,buyerUTXO)} then begin
       if (not ftx.Sign(lastAddress,lastPrivKey)) or (not ftx.Sign(EmerAPI.addresses[0],MainForm.getPrivKey(EmerAPI.addresses[0]))) then begin
         showMessageSafe('internal error: Error signing tx');
         ftx.free;
       end else begin
         if chShowInTxViewer.Checked and Settings.getValue('Dev_Mode_ON') then begin
           MainForm.miTXClick(nil);
           CreateRawTXForm.LoadbinTX(packTX(ftx.getTTX));
           ftx.free;
         end else begin;
           ftx.sendToBlockchain(EmerAPINotification(@Sent,'sent'));
           ftx.addNotify(EmerAPINotification(@SendingError,'error'));
           fNotSentCounter:=fNotSentCounter+1;
         end;
       end;
     end else showMessageSafe(localizzzeString('TakePossessionForm.messageTransferError','')+ftx.LastError);
  end;

end;

procedure TTakePossessionForm.bRequestAssetsClick(Sender: TObject);
begin
  fillAssetList; //by lastAddress. set lastAssetsAddress after all finished
end;

procedure TTakePossessionForm.bCloseClick(Sender: TObject);
begin
  close
end;

end.

