unit AtomFormUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, Spin, FrameSelectAddressunit, NVSRecordUnit, EmerTX, EmerAPIMain, emerapitypes,UTXOunit, fpjson, jsonparser, EmerAPIBlockchainUnit, EmerAPITransactionUnit;

type

  { TAtomForm }

  TAtomForm = class(TForm)
    bCopyToBuffer: TBitBtn;
    bClose: TBitBtn;
    bSignSend: TBitBtn;
    bViewName: TBitBtn;
    bPasteFromBuffer: TBitBtn;
    chAddScript: TCheckBox;
    eName: TEdit;
    FrameSelectAddress1: TFrameSelectAddress;
    lYouAreBuyer: TLabel;
    sePrice: TFloatSpinEdit;
    lContractResume: TLabel;
    lState: TLabel;
    lContractSigned: TLabel;
    lAddress: TLabel;
    lContractText: TLabel;
    lName: TLabel;
    lPrice: TLabel;
    lNameInfo: TLabel;
    lNameInfo1: TLabel;
    lNameInfo2: TLabel;
    mContract: TMemo;
    procedure bCloseClick(Sender: TObject);
    procedure bCopyToBufferClick(Sender: TObject);
    procedure bPasteFromBufferClick(Sender: TObject);
    procedure bSignSendClick(Sender: TObject);
    procedure chAddScriptChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure clearNVSRecord;
    procedure FormShow(Sender: TObject);
    procedure sePriceChange(Sender: TObject);
  private
    fNVSRecord:tNVSRecord; //loaded from contract if nil
    ftx:tEmerTransaction;
    freeNVSRecordOnClose:boolean;
    fbuyerUTXOList:tUTXOList;
    fBuyerUTXOListAddress:ansistring;
    procedure updateView(sender:tObject);
    procedure updateContract(sender:tObject);
    procedure AddressChanged(sender:tObject);
    function getBuyerAddress:ansistring;
    function getSellerAddress:ansistring;
    function GetNameOwnerTXID:ansistring;
    function getPrice:qword;
    function askForChangeConfirmation:boolean;
    procedure SendingError(Sender: TObject);
    procedure Sent(Sender: TObject);
    procedure onBlockchainData(sender:TEmerAPIBlockchainThread;result:tJsonData);
  public
    lastGuideIsContract:boolean; //guided by contract?
    function contractLoaded:boolean;
    function buyerUTXO(address:ansistring='';updateContractAfter:boolean=false):tUTXOList;
    function isSigned(address:ansistring=''):boolean; //address='' meanth by both sides
    procedure freeTx;
    function amIBuyer:boolean;
    function loadContract(aContract:ansistring):boolean;
    function finishContractLoading:boolean;
    procedure loadName(theName:ansistring);
  end;

var
  AtomForm: TAtomForm;

procedure ShowAtomForm(NVSname:ansistring); overload;
procedure ShowAtomForm(NVSrecord:tNVSRecord; freeNVSRecordOnClose:boolean=false); overload;
procedure ShowAtomFormForContract(contract:ansistring);

implementation

{$R *.lfm}

uses Clipbrd, Localizzzeunit, MainUnit, LazUTF8SysUtils, helperUnit, crypto, QuestionUnit, CryptoLib4PascalConnectorUnit;

procedure ShowAtomFormForContract(contract:ansistring);
begin
  if AtomForm.loadContract(contract) then begin
    AtomForm.updateView(nil);
    AtomForm.sePrice.Value:=0;
    AtomForm.FrameSelectAddress1.eAddress.Text:='';
    if not AtomForm.visible then AtomForm.show;
  end else
     showMessageSafe(localizzzeString('AtomForm.WrongContractFormat','The data you''ve tried to load is not a valid atom contract'));


end;

procedure ShowAtomForm(NVSname:ansistring);
var NVSRecord:tNVSRecord;
  //  i:integer;
begin
  //create
{  i:=NameViewFormList.IndexOf(lName);
  if i>=0 then begin
     if not TNameViewForm(NameViewFormList.Objects[i]).Visible
        then TNameViewForm(NameViewFormList.Objects[i]).Show;
     TNameViewForm(NameViewFormList.Objects[i]).BringToFront;
     exit;
  end;
 }
  NVSRecord:=tNVSRecord.create(emerAPI,NVSname,true,true);
  ShowAtomForm(NVSRecord,true);
end;

procedure ShowAtomForm(NVSrecord:tNVSRecord; freeNVSRecordOnClose:boolean=false);
begin
  AtomForm.fNVSRecord:=NVSrecord;
  AtomForm.freeNVSRecordOnClose:=freeNVSRecordOnClose;

  //NameViewForm.Caption:=NVSRecord.NVSName;
  if NVSRecord<>nil then begin
    NVSRecord.addNotify(EmerAPINotification(@(AtomForm.updateView),'update',true));

    if not NVSRecord.isLoaded then
      NVSRecord.readFromBlockchain;
  end;

  if NVSRecord<> nil then
    if not NVSRecord.readTXAfterLoad then
      if NVSRecord.nOut<0 then
          NVSRecord.readInputTxInfo();

  AtomForm.freeTx;
  AtomForm.updateView(nil);
  AtomForm.sePrice.Value:=0;
  AtomForm.FrameSelectAddress1.eAddress.Text:='';
  AtomForm.mContract.Text:='';
  AtomForm.Show;
end;

{ TAtomForm }

procedure TAtomForm.SendingError(Sender: TObject);
begin
 if Sender is tEmerTransaction
   then ShowMessageSafe('Sending error: '+tEmerTransaction(sender).lastError)
   else ShowMessageSafe('Sending error');
end;

procedure TAtomForm.Sent(Sender: TObject);
begin
  ShowMessageSafe('Successfully sent');
  close;
end;

function TAtomForm.amIBuyer:boolean;
begin
  //is address mine?
  result:=false;
  if fNVSRecord<>nil then
    result:=not EmerAPI.isMyAddress(fNVSRecord.ownerAddress);
end;

procedure TAtomForm.bCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TAtomForm.bCopyToBufferClick(Sender: TObject);
begin
  Clipboard.AsText:=trim(mContract.Text);
end;

procedure TAtomForm.bPasteFromBufferClick(Sender: TObject);
begin
  loadContract(Clipboard.AsText);
end;

procedure TAtomForm.bSignSendClick(Sender: TObject);
begin
 if ftx=nil then raise exception.Create('Transaction is not created');
 if isSigned then begin
    ftx.sendToBlockchain(EmerAPINotification(@Sent,'sent'));
    ftx.addNotify(EmerAPINotification(@SendingError,'error'));

    lContractSigned.Caption:=localizzzeString('AtomForm.lContractSigned.Sending','The contract is now sending to blockchain');
    bSignSend.Caption:=localizzzeString('AtomForm.bSignSend.Send','Send to blockchain');
    bSignSend.Enabled:=false;
  end else begin
    if amIBuyer then begin
       if not ftx.Sign(getBuyerAddress,mainForm.getPrivKey(getBuyerAddress)) then
         raise exception.Create('bSignSendClick: Error signing tx');
    end else begin
      //i am a seller.
      if not ftx.Sign(getSellerAddress,mainForm.getPrivKey(getSellerAddress)) then
          raise exception.Create('bSignSendClick: Error signing tx');
    end;
    updateView(sender);
  end;
end;

procedure TAtomForm.chAddScriptChange(Sender: TObject);
begin
  if lastGuideIsContract then
    if not askForChangeConfirmation then begin
      chAddScript.OnChange:=nil;
      chAddScript.Checked:=not chAddScript.Checked;
      chAddScript.OnChange:=@chAddScriptChange;
      exit;
    end;

  updateContract(Sender);
end;

procedure TAtomForm.clearNVSRecord;
begin
  if (fNVSRecord<>nil) then
    if freeNVSRecordOnClose
       then freeandnil(fNVSRecord)
       else fNVSRecord.removeNotify(EmerAPINotification(@updateView,'',true));
  fNVSRecord:=nil;
end;

procedure TAtomForm.FormShow(Sender: TObject);
begin
  if lastGuideIsContract
     then updateView(sender)
     else updateContract(sender);
  localizzze(self);
end;

procedure TAtomForm.sePriceChange(Sender: TObject);
begin
  if not lastGuideIsContract then
    updateContract(Sender)
  else if askForChangeConfirmation then updateContract(Sender);
end;

procedure TAtomForm.freeTx;
begin
  lastGuideIsContract:=false;
  freeAndNil(ftx);
end;

procedure TAtomForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  clearNVSRecord;
  freeTx;
  if (fbuyerUTXOList<>nil) then freeAndNil(fbuyerUTXOList);
end;

procedure TAtomForm.loadName(theName:ansistring);
begin
  clearNVSRecord;

  fNVSRecord:=tNVSRecord.create(emerAPI,theName,true);
  fNVSRecord.addNotify(EmerAPINotification(@updateView,'update',true));
  freeNVSRecordOnClose:=true;

end;

function TAtomForm.loadContract(aContract: ansistring): boolean;
var
  i:integer;

begin
  clearNVSRecord;
  eName.Text:=localizzzeString('AtomForm.NameNotLoaded','PLEASE WAIT');
  freeTx;




  result:=false;

  mContract.Text:=localizzzeString('AtomForm.mContract.Loading','***Loading contract information...***');

  try
    ftx:=tEmerTransaction.create(EmerAPI,hexToBuf(aContract));
  except
    mContract.Text:=localizzzeString('AtomForm.mContract.NameNotSelected','***PLEASE PASTE CONTRACT FROM BUFFER***');
    showMessageSafe(localizzzeString('AtomForm.WrongContract','Invalid contract'));
    exit;
  end;

  if (ftx.time<(winTimeToUnixTime(nowUTC())-5000)) or (ftx.time>(10000 + winTimeToUnixTime(nowUTC()))) then begin
    showMessageSafe(localizzzeString('AtomForm.WrongTime','Invalid time'));
    mContract.Text:=localizzzeString('AtomForm.mContract.NameNotSelected','***PLEASE PASTE CONTRACT FROM BUFFER***');
    freeTx;
    updateView(nil);
    exit;
  end;

  if ftx.Version<>$666 then begin
    showMessageSafe(localizzzeString('AtomForm.WrongVersion','Invalid contract TX version'));
    mContract.Text:=localizzzeString('AtomForm.mContract.NameNotSelected','***PLEASE PASTE CONTRACT FROM BUFFER***');
    freeTx;
    updateView(nil);
    exit;
  end;

  if ftx.LockTime>0 then begin
    showMessageSafe(localizzzeString('AtomForm.LocktimeNotAllowed','LockTime does not allowed for ATOM'));
    mContract.Text:=localizzzeString('AtomForm.mContract.NameNotSelected','***PLEASE PASTE CONTRACT FROM BUFFER***');
    freeTx;
    updateView(nil);
    exit;
  end;

  if ftx.insCount<2 then begin
    showMessageSafe(localizzzeString('AtomForm.NotEnougnIns','Wrong ATOM contract: inputs not enough'));
    mContract.Text:=localizzzeString('AtomForm.mContract.NameNotSelected','***PLEASE PASTE CONTRACT FROM BUFFER***');
    freeTx;
    updateView(nil);
    exit;
  end;


  //we have to load all redeemScript
  for i:=0 to ftx.insCount-1 do begin
     ftx.ins[i].redeemScript:='';

     EmerAPI.EmerAPIConnetor.sendWalletQueryAsync('getrawtransaction',
         getJSON('{txid:"'+bufToHex(reverse(ftx.ins[i].txHash))+'"}')
        ,@onBlockchainData,'getrawtransaction_'+EmerAPI.EmerAPIConnetor.getNextID);
  end;
  updateView(nil);
  mContract.Text:=localizzzeString('AtomForm.mContract.Loading','***Loading contract information...***');
  result:=true;
end;


function TAtomForm.getPrice:qword;
var //inValue,outValueSeller,outValueBuyer:qword;
    //sellerAddress,buyerAddress:ansistring;
    i:integer;
    sellerAddress:ansistring;
begin
{  inValue:=0;
  outValueSeller:=0;
  outValueBuyer:=0;

  sellerAddress:=getSellerAddress;
  buyerAddress:=getBuyerAddress;

  //calculate Ins values excepnt names. All the ins must e from one source.
  for i:=0 to ftx.insCount-1 do
    inValue:=inValue+ftx.ins[i].value;

  //we must have only sellerAddress,buyerAddress
  for i:=0 to ftx.outsCount-1 do
    if ftx.outs[i].getReceiver=sellerAddress
      then outValueSeller:=outValueSeller+ftx.outs[i].value
    else
    if ftx.outs[i].getReceiver=buyerAddress
      then outValueBuyer:=outValueBuyer+ftx.outs[i].value
    else
      raise exception.Create('Only one buyer and seller can receive coins');
 }
  sellerAddress:=getSellerAddress;
  result:=0;
  for i:=0 to ftx.outsCount-1 do
    if ftx.outs[i].getReceiver=sellerAddress
      then result:=result+ftx.outs[i].value;

  for i:=0 to ftx.insCount-1 do
    if not (ftx.ins[i].isName) then
      if ftx.ins[i].getAddress=SellerAddress then
        result:=result-ftx.ins[i].value;

end;


function TAtomForm.finishContractLoading:boolean;
var
  theName:ansistring;
  i:integer;
  sellerAddress,buyerAddress:ansistring;
  inValue,outValueSeller,outValueBuyer:qword;
begin
  inValue:=0;
  outValueSeller:=0;
  outValueBuyer:=0;
  sellerAddress:='';
  buyerAddress:='';

  result:=false;

  try
    //check lName in. It must be only one

    //getSellerAddress
    //getBuyerAddress


    for i:=0 to ftx.insCount-1 do
      if ftx.ins[i].isName then
        if theName=''
           then begin
             theName:=ftx.ins[i].getNVSName;
             sellerAddress:=ftx.ins[i].getAddress;
           end
           else begin
             //Two lName inputs
             raise exception.Create('two TX ins');
           end;

    //calculate Ins values excepnt names. All the ins must e from one source.
    for i:=0 to ftx.insCount-1 do begin
      inValue:=inValue+ftx.ins[i].value;
      if not (ftx.ins[i].isName) then
        if buyerAddress=''
           then buyerAddress:=ftx.ins[i].getAddress
           else if ftx.ins[i].getAddress<>buyerAddress then
              raise exception.Create('Only one buyer address allowed');
    end;

    //calulate outs.
    //we must have only sellerAddress,buyerAddress
    for i:=0 to ftx.outsCount-1 do
      if ftx.outs[i].getReceiver=sellerAddress
        then outValueSeller:=outValueSeller+ftx.outs[i].value
      else
      if ftx.outs[i].getReceiver=buyerAddress
        then outValueBuyer:=outValueBuyer+ftx.outs[i].value
      else
        raise exception.Create('Only one buyer and seller can receive coins');

    loadName(theName);
    result:=true;
    lastGuideIsContract:=true;
  except
    showMessageSafe(localizzzeString('AtomForm.WrongContract','Invalid contract'));
    freeTx;
  end;
  updateView(nil);
end;


procedure TAtomForm.onBlockchainData(sender:TEmerAPIBlockchainThread;result:tJsonData);
var js,e:tJsonData;
    s:string;
    x:double;
    i:integer;
    st:ansistring;
    txHash:ansistring;
    tx:ttx;
begin
  if result=nil then begin
   EmerAPI.EmerAPIConnetor.checkConnection();
   exit;
  end;

  js:=result;

  if pos('getrawtransaction_',sender.id)=1 then begin
   if ftx=nil then exit;
   if js<>nil then begin
    e:=js.FindPath('result');
    if (e<>nil) and (not e.IsNull) then begin
      //we have received a raw tx. check if
        txHash:=dosha256(dosha256(hexToBuf(e.asString)));

         for i:=0 to ftx.insCount-1 do
           if ftx.ins[i].txHash=txHash then begin
              //loading redeemScript
              tx:=unpackTX(hexToBuf(e.asString));
              if ftx.ins[i].nOut>=length(tx.outs) then begin
                 freeandnil(ftx);
                 mContract.Text:=localizzzeString('AtomForm.mContract.nOutNotLoaded','***THE CONTRACT IS INVALID***');
                 exit;
              end;
              ftx.ins[i].redeemScript:=tx.outs[ftx.ins[i].nOut].script;
           end;
        if contractLoaded then finishContractLoading;
    end;
   end;
  end;

end;

function TAtomForm.GetNameOwnerTXID:ansistring;
var i:integer;
begin
  result:='';
  if ftx=nil then exit;
  for i:=0 to ftx.insCount-1 do
    if ftx.ins[i].isName then
      if result=''
         then begin
           result:=reverse(ftx.ins[i].txHash);
         end
         else begin
           //Two lName inputs
           raise exception.Create('two TX ins');
         end;
end;


function TAtomForm.getSellerAddress:ansistring;
var i:integer;
begin
  result:='';
  if ftx=nil then exit;
  for i:=0 to ftx.insCount-1 do
    if ftx.ins[i].isName then
      if result=''
         then begin
           result:=ftx.ins[i].getAddress;
         end
         else begin
           //Two lName inputs
           raise exception.Create('two TX ins');
         end;
end;

function TAtomForm.getBuyerAddress:ansistring;
var   i:integer;
begin
  result:='';
  if ftx=nil then exit;

  for i:=0 to ftx.insCount-1 do
    if not (ftx.ins[i].isName) then
      if result=''
         then result:=ftx.ins[i].getAddress
         else if ftx.ins[i].getAddress<>result then
            raise exception.Create('Only one buyer address allowed');

end;

function TAtomForm.isSigned(address:ansistring=''):boolean; //address='' meanth by both sides
begin
  result:=false;
  if ftx=nil then exit;
  if (address='') and ((getSellerAddress='') or (getBuyerAddress='')) then exit;

  if address='' then
    result:=isSigned(getSellerAddress) and  isSigned(getBuyerAddress)
  else
    result:=ftx.isSigned(address);

end;

function TAtomForm.contractLoaded:boolean;
var   i:integer;
begin
  result:=false;
  if ftx=nil then exit;

  for i:=0 to ftx.insCount-1 do
    if ftx.ins[i].redeemScript='' then
       exit;
  result:=true;
end;

procedure TAtomForm.updateView(sender:tObject);
var badr:string;
begin
  //info updated
  if fNVSRecord<>nil then begin

    //checking txid ownership
    if (ftx<>nil) and (contractLoaded) then

     if (fNVSRecord.txid<>'') and (GetNameOwnerTXID<>'') then
      if fNVSRecord.txid<>GetNameOwnerTXID then begin
         mContract.Text:=localizzzeString('AtomForm.mContract.TXIDviolation','***THE CONTRACT IS INCORRECT. WRONG NAME TXID. PERHAPS THE NVS RECORD IS SOLD***');
         freeandnil(ftx);
      end;

    eName.Text:=fNVSRecord.NVSName;
    if amIBuyer then begin
      FrameSelectAddress1.down;
      FrameSelectAddress1.Visible:=false;
    end else begin
      if (not FrameSelectAddress1.visible) or (not FrameSelectAddress1.initialized) then begin
        FrameSelectAddress1.onAddressChanged:=nil;
        FrameSelectAddress1.init(nil);
        FrameSelectAddress1.onAddressChanged:=@AddressChanged;
        FrameSelectAddress1.Visible:=true;
      end;
      //if (ftx<>nil) and (not FrameSelectAddress1.eAddress.Focused) then
      if lastGuideIsContract then begin
        //if addressto20(getBuyerAddress)<>addressto20(FrameSelectAddress1.getAddress) then
        FrameSelectAddress1.onAddressChanged:=nil;
        FrameSelectAddress1.eAddress.Text:=addressto58(getBuyerAddress,EmerAPI.blockChain.AddressSig);
        FrameSelectAddress1.onAddressChanged:=@AddressChanged;
      end;
    end;

    //fBuyerUTXOListAddress:=FrameSelectAddress1.getAddress;

    if buyerUTXO<>nil then
      if buyerUTXO.getStat.lastUpdateTime>0 then begin
            lState.Caption:=localizzzeString('AtomForm.BuyerBalance','Available funds in the buyer wallet: ')+myFloatToStr(buyerUTXO.getStat.spendable/1000000)+' EMC';

      end else begin
          lState.Caption:=localizzzeString('AtomForm.PleaseWait','PLEASE WAIT');
      end
    else
      lState.Caption:=localizzzeString('AtomForm.NoBuyerAddress','NO BUYER ADDRESS');

    if amIBuyer then
      lNameInfo1.Caption:=localizzzeString('AtomForm.YouBuyTheName','You are buying a digital asset')+': "'+fNVSRecord.NVSName+'"'
    else
      lNameInfo1.Caption:=localizzzeString('AtomForm.YouSellTheName','You are selling a digital asset')+': "'+fNVSRecord.NVSName+'"';

    if amIBuyer then
      if fNVSRecord.ownerAddress=''
        then lNameInfo2.Caption:=localizzzeString('AtomForm.lNameInfo2.EmptyBuyer','**buyer address not set/loaded**')
        else lNameInfo2.Caption:=format(localizzzeString('AtomForm.lNameInfo2.Buy','You pay %n EMC to %s'),[sePrice.Value,addressto58(fNVSRecord.ownerAddress,EmerAPI.blockChain.AddressSig)])
    else begin
      badr:=addressto58(getBuyerAddress,EmerAPI.blockChain.AddressSig);
      if badr='' then
        badr:=addressto58(FrameSelectAddress1.getAddress,EmerAPI.blockChain.AddressSig);
      if badr<>'' then
        lNameInfo2.Caption:=format(localizzzeString('AtomForm.lNameInfo2.Sell','%s will pay you %n EMC'),[badr,sePrice.Value])
      else
        lNameInfo2.Caption:=format(localizzzeString('AtomForm.lNameInfo2.SellNoBuyerAddress','Buyer for pay you %n EMC is not selected.'),[sePrice.Value]);
    end;

    if isSigned then begin
      lContractSigned.Caption:=localizzzeString('AtomForm.lContractSigned.both','The contract was signed completely');
      bSignSend.Caption:=localizzzeString('AtomForm.bSignSend.Send','Send to blockchain');
      bSignSend.Enabled:=true;
    end else
      if amIBuyer then begin
         if isSigned(getBuyerAddress) then begin
           lContractSigned.Caption:=localizzzeString('AtomForm.lContractSigned.SignedByYou','The contract has been signed by you. Send it to your counterparty');
           bSignSend.Caption:=localizzzeString('AtomForm.bSignSend.Sign','Sign');
           bSignSend.Enabled:=false;
         end else begin
           if not EmerAPI.isMyAddress(getBuyerAddress) then begin
             lContractSigned.Caption:=localizzzeString('AtomForm.lContractSigned.NotInvolved','You are neither a buyer nor a seller in this contract.');
             bSignSend.Caption:=localizzzeString('AtomForm.bSignSend.Sign','Sign');
             bSignSend.Enabled:=false;
           end else begin
             if isSigned(getSellerAddress)
               then lContractSigned.Caption:=localizzzeString('AtomForm.lContractSigned.SignedByOther','The contract has been signed by your counterparty. You can sign it.')
               else lContractSigned.Caption:=localizzzeString('AtomForm.lContractSigned.NotSigned','The contract was not signed. You can sign it.');
             bSignSend.Caption:=localizzzeString('AtomForm.bSignSend.Sign','Sign');
             bSignSend.Enabled:=true;

           end;
         end;
      end else begin
        //i am a seller.
         if isSigned(getSellerAddress) then begin
            lContractSigned.Caption:=localizzzeString('AtomForm.lContractSigned.SignedByYou','The contract has been signed by you. Send it to your counterparty');
            bSignSend.Caption:=localizzzeString('AtomForm.bSignSend.Sign','Sign');
            bSignSend.Enabled:=false;
          end else begin
            if isSigned(getBuyerAddress)
              then lContractSigned.Caption:=localizzzeString('AtomForm.lContractSigned.SignedByOther','The contract has been signed by your counterparty. You can sign it.')
              else lContractSigned.Caption:=localizzzeString('AtomForm.lContractSigned.NotSigned','The contract was not signed. You can sign it.');
            bSignSend.Caption:=localizzzeString('AtomForm.bSignSend.Sign','Sign');
            bSignSend.Enabled:=true;
          end;
      end;
  end else begin
    eName.Text:=localizzzeString('AtomForm.NameNotLoaded','PLEASE WAIT');
    FrameSelectAddress1.down;
    FrameSelectAddress1.Visible:=false;
    bSignSend.Caption:=localizzzeString('AtomForm.bSignSend.Sign','Sign');
    bSignSend.Enabled:=false;
  end;

  if (sender=fNVSRecord) and (sender<>nil) and (not lastGuideIsContract) then
    updateContract(nil);

  if ftx<>nil then
   if (fNVSRecord=nil) //or (not fNVSRecord.isLoaded)
    then
      mContract.Text:=localizzzeString('AtomForm.mContract.nOutNotLoaded','***LOADING NAME INFORMATION, PLEASE WAIT***')
    else
    begin
      mContract.Text:=bufToHex(ftx.getBuf(chAddScript.checked));
      if lastGuideIsContract then begin
         sePrice.OnChange:=nil;
         sePrice.Value:=getPrice/1000000;
         sePrice.OnChange:=@sePriceChange;
      end else begin

      end;
    end;

end;

procedure TAtomForm.AddressChanged(sender:tObject);
begin
  //rebuild UTXO
  if amIBuyer
     then raise exception.Create('YOU CAN''T CHANGE ADDRESS IF YOU ARE BUYER')
     else buyerUTXO(FrameSelectAddress1.getAddress,true);

  if not lastGuideIsContract then updateContract(Sender)
  else
    if addressto20(getBuyerAddress)<>addressto20(FrameSelectAddress1.getAddress) then
      if askForChangeConfirmation then
        updateContract(Sender);

  if not lastGuideIsContract then updateView(nil);
  //updateView(nil);
  //if not lastGuideIsContract then updateContract(sender);
  //if lastGuideIsContract
  //   then updateView(sender)
  //   else updateContract(sender);

end;

function TAtomForm.askForChangeConfirmation:boolean;
begin
  AskQuestionInit();
  QuestionForm.Caption:=localizzzeString('AtomForm.askForChangeConfirmation.Title','The contract will be changed, all existing signatires will be lost. Do you wish to rebuild the contract?');
  QuestionForm.bYes.Visible:=true;
  QuestionForm.bNo.Visible:=true;
  QuestionForm.bHelp.Visible:=true;

  //CurrentLanguage:='en';
  result := AskQuestionTag('AtomForm.askForChangeConfirmation.Message')=mrYes;

end;

procedure TAtomForm.updateContract(sender:tObject);
var cost:qword;
    BuyerAddress,SellerAddress:ansistring;
begin
 lastGuideIsContract:=false;

 if amIBuyer and (EmerAPI.addresses.Count=0) then begin
    mContract.Text:=localizzzeString('AtomForm.mContract.NoAddress','***YOU DONT HAVE ADDRESS***');
    exit;
 end;

  freeAndNil(ftx);
  if fNVSRecord<>nil then begin
    if amIBuyer then begin
      BuyerAddress:=base58ToBufCheck(trim(EmerAPI.addresses[0]));
      if fNVSRecord.ownerAddress='' then begin
        mContract.Text:=localizzzeString('AtomForm.mContract.LoadingSellerAddress','***LOADING SELLER''S ADDRESS, PLEASE WAIT...***');
        exit;
      end;
      SellerAddress:=EmerAPI.blockChain.AddressSig + fNVSRecord.ownerAddress;
    end else begin
      BuyerAddress:=FrameSelectAddress1.getAddress;
      SellerAddress:=EmerAPI.blockChain.AddressSig + fNVSRecord.ownerAddress;
    end;

    if not EmerAPI.blockChain.addressIsValid(BuyerAddress) then begin
      mContract.Text:=localizzzeString('AtomForm.mContract.BuyerAddressInvalid','***INVALID BUYER''S ADDRESS***');
      exit;
    end;
    if not EmerAPI.blockChain.addressIsValid(SellerAddress) then begin
      mContract.Text:=localizzzeString('AtomForm.mContract.SellerAddressInvalid','***INVALID SELLER''S ADDRESS***');
      exit;
    end;

    if EmerAPI.isMyAddress(BuyerAddress) and EmerAPI.isMyAddress(SellerAddress) then begin
      mContract.Text:=localizzzeString('AtomForm.mContract.SellerAndBuyerAreMine','***THE SELLER''S AND THE BUYER''S ADDRESSES ARE YOURS***');
      exit;
    end;

   if buyerUTXO<>nil then begin
    if buyerUTXO.getStat.lastUpdateTime>0 then begin
       cost:=trunc(sePrice.Value*1000000)+emerAPI.blockChain.MIN_TX_FEE;
       if cost<=buyerUTXO.getStat.spendable then begin
         if fNVSRecord.nOut>=0 then
         begin
             ftx:=tEmerTransaction.create(EmerAPI);
              //addInput(txid:ansistring;n:integer;value:qword; redeemScript:ansistring='';signature:ansistring='';sequence:dword=DEFAULT_SEQUENCE;witness:tStringList=nil):tBaseTXI; //adds one input.
             //ftx.addInput(fNVSRecord.txid,fNVSRecord.nOut,fNVSRecord.value,fNVSRecord.Script,'','',fNVSRecord.s);
             //if chAddScript.Checked
             //  then ftx.addInput(fNVSRecord.txid,fNVSRecord.nOut,fNVSRecord.value,fNVSRecord.Script)
             //  else ftx.addInput(fNVSRecord.txid,fNVSRecord.nOut,fNVSRecord.value);
             ftx.addInput(fNVSRecord.txid,fNVSRecord.nOut,fNVSRecord.value,fNVSRecord.Script);

             ftx.addOutput(ftx.createNameScript(BuyerAddress,fNVSRecord.NVSName,fNVSRecord.NVSvalue,0,false),emerAPI.blockChain.MIN_TX_FEE);
             ftx.addOutput(ftx.createSpendScript(SellerAddress),cost);
                //EmerAPI.blockChain.getNameOpFee(seDays.Value,opNum('OP_NAME_NEW'),length(nName)+length(nValue))
             if ftx.makeComplete(BuyerAddress,buyerUTXO) then begin
                mContract.Text:=bufToHex(ftx.getBuf(chAddScript.checked));
  //           begin
  //             if tx.signAllInputs(MainForm.PrivKey) then begin
  //               tx.sendToBlockchain(EmerAPINotification(@Sent,'sent'));
  //               tx.addNotify(EmerAPINotification(@SendingError,'error'));
  //             end else showMessageSafe('Can''t sign all transaction inputs using current key: '+tx.LastError);
  //           end else showMessageSafe('Can''t create transaction: '+tx.LastError);
                updateView(nil);

             end else mContract.Text:=localizzzeString('AtomForm.mContract.CantCreate','***CANT CREATE CONTRACT***')+#10+ftx.LastError;
         end else begin
           fNVSRecord.readInputTxInfo();
           mContract.Text:=localizzzeString('AtomForm.mContract.nOutNotLoaded','***LOADING NAME INFORMATION, PLEASE WAIT***');
         end;
       end else mContract.Text:=localizzzeString('AtomForm.mContract.UTXONotEnough','***BUYER WALLET DOES NOT HAVE COINS ENOUGH***');
    end else mContract.Text:=localizzzeString('AtomForm.mContract.UTXONotLoaded','***LOADING BUYER WALLET, PLEASE WAIT***');
   end else mContract.Text:=localizzzeString('AtomForm.mContract.UTXONotLoaded','***LOADING BUYER WALLET, PLEASE WAIT***');
  end else mContract.Text:=localizzzeString('AtomForm.mContract.NameNotSelected','***PLEASE PASTE CONTRACT FROM BUFFER***');


end;

function TAtomForm.buyerUTXO(address:ansistring='';updateContractAfter:boolean=false):tUTXOList;
//var addresses:tStringList;
//Возвращает текущее UTXO. Если задан адрес, отличный от текущего (не '') - вызывает перестроение
begin

  result:=nil;

  if amIBuyer and ((address='') or (EmerAPI.isMyAddress(address))) then begin
     result:=EmerAPI.UTXOList;
     exit;
  end;

  if (fBuyerUTXOListAddress='') and (address='') then exit; //No address


  //We don't want to change address or the address is the same to before
  if ((address='') or (addressto20(address)=addressto20(fBuyerUTXOListAddress)))
     and (fbuyerUTXOList<>nil) and (fbuyerUTXOList.hasAddress(fBuyerUTXOListAddress)) then begin
    result:=fbuyerUTXOList;
    exit;
  end;

  //ok, we need change the address and fbuyerUTXOList
  if address<>'' then
     fBuyerUTXOListAddress:=address;

  if (fbuyerUTXOList<>nil) then freeAndNil(fbuyerUTXOList);

  //fBuyerUTXOListAddress:=getBuyerAddress;
  fbuyerUTXOList:=tUTXOList.create(EmerAPI.EmerAPIConnetor,EmerAPI.blockChain,addressto58(fBuyerUTXOListAddress,  EmerAPI.blockChain.AddressSig ));


  //fbuyerUTXOList.addNotify(EmerAPINotification(@updateView,'updateUTXO',true)) ;
{
  addresses:=tStringList.Create;
  try
    addresses.Add(addressto58(fBuyerUTXOListAddress,  EmerAPI.blockChain.AddressSig ));
    fbuyerUTXOList.setAddresses(addresses);
  finally
    addresses.free;
  end;
  }
  if updateContractAfter
    then fbuyerUTXOList.update(EmerAPINotification(@updateContract,'updateUTXO',false))
    else fbuyerUTXOList.update(EmerAPINotification(@updateView,'updateUTXO',false));
  result:=fbuyerUTXOList;
end;

end.

