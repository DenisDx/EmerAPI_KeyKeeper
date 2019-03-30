unit EmerAPITransactionUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UOpenSSL, UOpenSSLdef, Crypto, fpjson, jsonparser,
  EmerAPIBlockchainMergedUnit, EmerAPIBlockchainUnit, EmerAPIServerUnit, EmerAPIWalletUnit, UTXOunit, emerapitypes, EmerTX, BlockchainUnit, EmerAPIMain, BaseTXUnit;

type
tEmerTransaction=class;

{
tEmerTransactionInOut = class(tObject)
  private
    fOwner: tEmerTransaction;
  public
    constructor create(owner:tEmerTransaction);
end;
}

tEmerTransactionIn = class({tEmerTransactionInOut,}tBaseTXI)
//private
//  fOwner:tEmerTransaction;
public
//  constructor create(owner:tEmerTransaction;SourceUTXO:tUTXO); overload;
//  procedure loadFromUTXO(SourceUTXO:tUTXO);
  function address:ansistring;
//  constructor create(mOwner:tEmerTransaction); // call constructor for the both ancestors
end;

tEmerTransactionOut = class({tEmerTransactionInOut,}tBaseTXO)

  //public
  //  property owner:tEmerTransaction read fOwner;
    //function isName:boolean;
    //function isValidName:boolean;
    //function getNVSName:ansistring; //'' if not-name
    //function index:integer; //fOwner.fOuts.IndexOf(self)
end;

//tEmerTransaction notify:
// 'sent' :after send
// 'error' : generic error
//
tEmerTransaction = class(tBaseTX)
  private
    fEmerAPI:tEmerAPI;

    procedure AsyncAddressInfoDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
  public
    //LastError:string;
    destroyOnSent:boolean; //must be destroyed on AsyncAddressInfoDone for SendTX
    function createSpendScript(address:ansistring):ansistring; override; //address in code58check. Check sing with blockchain.pube
    //moved function createNameSubScript(Name,Value:ansistring;Days:dword;nameNew:boolean):ansistring;
    //moved function createNameScript(address:ansistring;Name,Value:ansistring;Days:dword;nameNew:boolean):ansistring;
    constructor create(emerAPI:tEmerAPI;freeOnSend:boolean=false); overload;
    constructor create(emerAPI:tEmerAPI;tx:ttx); overload;
    constructor create(emerAPI:tEmerAPI;buf:ansistring); overload;
    //destructor destroy;

    //moved function isValid():boolean;
    //moved function isNameTx():boolean;
    //moved function findNameOut(name:ansistring):tEmerTransactionOut;//nil if not found

    function getFee():qword;

    //moved function addOutput(script:ansistring;v:dword):tEmerTransactionOut; //adds one input. Prevent to add more than one name script
    //moved function addInput(txid:ansistring;n:integer;value:dword; redeemScript:ansistring='';signature:ansistring='';sequence:dword=DEFAULT_SEQUENCE;witness:tStringList=nil):tEmerTransactionIn; //adds one input. Prevent to add more than one name script
    function makeComplete(changeToAddress:ansistring='';UTXOList:tUTXOList=nil):boolean; //add inputs, send change back to myself
    function signAllInputs(PrivKey:ansistring=''):boolean; //returns if all the inputs are signed
    function sendToBlockchain:boolean; overload;
    function sendToBlockchain(eapiNotify:tEmerAPINotification):boolean; overload;

    //moved function getFullSpend:dword;

    //moved function getTTX:ttx;
    //moved procedure setTTX(tx:ttx);
    //moved procedure setAsBuffer(buf:ansiString);
    //moved function getTXID:ansistring;
end;





implementation

uses HelperUnit;

{tEmerTransaction ins and outs}
{
constructor tEmerTransactionInOut.create(owner:tEmerTransaction);
begin
    fOwner:= owner;
end;
}

function tEmerTransactionIn.address:ansistring;
begin
  if not (Owner is tEmerTransaction) then raise exception.Create('tEmerTransactionIn.address: not (Owner is tEmerTransaction)');

  result:='';
  if redeemScript='' then exit;

  result:=getInScriptAddress(redeemScript);

  if result<>'' then result:=tEmerTransaction(Owner).fEmerAPI.blockChain.AddressSig +result;
end;

{tEmerTransaction}


function tEmerTransaction.getFee():qword;
var NameScript:tNameScript;
    i:integer;
begin

  result:=0;
  for i:=0 to fOuts.Count-1 do
    if tEmerTransactionOut(fOuts[i]).isName then begin
      //MULTINAME !!!
      NameScript:=nameScriptDecode(tEmerTransactionOut(fOuts[i]).script);
      result:=result+fEmerAPI.blockChain.getNameOpFee(NameScript.Days,NameScript.TXtype,length(NameScript.Name)+length(NameScript.Value));
    end;
  if result<fEmerAPI.blockChain.MIN_TX_FEE then
    result:=fEmerAPI.blockChain.MIN_TX_FEE;

end;



function tEmerTransaction.makeComplete(changeToAddress:ansistring='';UTXOList:tUTXOList=nil):boolean; //add inputs, send change back to myself
var amount:int64;
    i:integer;
    NameScript:tNameScript;
    lTxExclude:tStringList;
    s:ansistring;
    lUTXO:tList;
begin
  //returns if successeful (have coins enough, etc)
  //Takes inputs from EmerAPI.UTXOList pool
  result:=false;

  //1. calc full cost : all outs + comission
  //2. calc how much do we have, make lTxExclude list
  //3. obtain more inputs if necessesary from EmerAPI.UTXOList. Check lTxExclude list!
  //4. send change to address (use first EmerAPI address if not selected)

  //return true if money enough

  if not isValid then begin
    LastError:='Invalid transaction';
    exit;
  end;

  if fOuts.Count<1 then begin
    LastError:='Transaction does not have outputs';
    exit;
  end;

  amount:=0;
  for i:=0 to fOuts.Count-1 do
     amount:=amount-tEmerTransactionOut(fOuts[i]).value;


  lTxExclude:=tStringList.Create;
  try

    //calc how much do we have, make lTxExclude list
    //lTxExclude  в формате имени Олега: два байта номер входа + номер транзакции
    for i:=0 to fIns.Count-1 do begin
      amount:=amount+tEmerTransactionIn(fIns[i]).value;
      setLength(s,sizeof(tEmerTransactionIn(fIns[i]).nOut));
      move(tEmerTransactionIn(fIns[i]).nOut,s[1],sizeof(tEmerTransactionIn(fIns[i]).nOut));
      s:=s+tEmerTransactionIn(fIns[i]).txHash;
      lTxExclude.Append(s);
    end;



    //adding fee
    amount:=amount - getFee();

    //ok,let's add UTXO if amount < 0

    if amount<0 then begin
      if UTXOList=nil
        then lUTXO:=fEmerAPI.UTXOList.giveToSpend(-amount,lTxExclude)
        else lUTXO:=UTXOList.giveToSpend(-amount,lTxExclude);
      try
        for i:=0 to lUTXO.Count-1 do begin
          addInput(tUTXO(lUTXO[i]).txid,tUTXO(lUTXO[i]).nOut,tUTXO(lUTXO[i]).value,tUTXO(lUTXO[i]).Script); //adds one input.
          amount:=amount+tUTXO(lUTXO[i]).value;
        end;
      finally
        if lUTXO<>nil then lUTXO.Free;
      end;
    end;
    result:=  true;
    //send change to address (use first EmerAPI address if not selected)
    if amount>0 then begin
      if changeToAddress='' then
        if fEmerAPI.addresses.Count=0
          then raise exception.Create('There is no any address for change')
          else begin
            try changeToAddress:=base58ToBufCheck(trim(fEmerAPI.addresses[0])); except changeToAddress:=''; end;
            if (length(changeToAddress)>0) and (changeToAddress[1]<>fEmerAPI.blockChain.AddressSig) then
              raise exception.Create('tEmerTransaction.makeComplete: main address signature is not mached to the current network');
          end;
      addOutput(createSpendScript(changeToAddress),amount);
    end else
    if amount<0 then begin
      result:=false;
      LastError:='balance not enough: '+myfloattostr(amount/COIN);
    end;
  finally
    lTxExclude.free;
  end;
end;

function tEmerTransaction.signAllInputs(PrivKey:ansistring=''):boolean; //returns if all the inputs are signed
var i:integer;
begin
  result:=true;
  {$B+}
  for i:=0 to fIns.Count-1 do
    if not isInputSigned(i)//tEmerTransactionIn(fins[i]).isSigned
      then result:= signIn(i,PrivKey) and result;//tEmerTransactionIn(fins[i]).sign(PrivKey) and result;
  {$B-}
end;

procedure tEmerTransaction.AsyncAddressInfoDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
var e:tJsonData;
begin
  if result=nil then begin
    //showMessageSafe('Error: '+sender.lastError);
    callNotify('error');
    exit;
  end;
  if sender.id='sendTX' then begin
     //delete used inputs... better to refresh
    if fEmerAPI<>nil then
       //fEmerAPI.update();
      if fEmerAPI.UTXOList<>nil then
        fEmerAPI.UTXOList.update(emptyEmerAPINotification);

    e:=result.FindPath('result');
    if e=nil then begin
      lastError:='Sending TX: there is no Result answer: '+result.ASjson;
      callNotify('error');
    end else if e.IsNull then begin
      lastError:='Sending TX: error on sending';

      e:=result.FindPath('error');
      if e<>nil
        then lastError:=lastError+' : '+e.asJSON
        else lastError:=lastError+': result: '+result.ASjson;
      callNotify('error');
    end else
      callNotify('sent');
    if destroyOnSent then free;
  end;
end;

function tEmerTransaction.sendToBlockchain(eapiNotify:tEmerAPINotification):boolean;
begin
  addNotify(eapiNotify); // sendToBlockchain
  result:=false;
  if fEmerAPI<>nil then
    fEmerAPI.EmerAPIConnetor.sendWalletQueryAsync('sendrawtransaction',getJSON('{hexstring:"'+bufToHex(packTX(getTTX))+'"}'),@AsyncAddressInfoDone,'sendTX')
  else lastError:='EmerAPIConnetor is absent';
end;

function tEmerTransaction.sendToBlockchain:boolean;
begin
  result:=sendToBlockchain(emptyEmerAPINotification);
end;

{class }function tEmerTransaction.createSpendScript(address:ansistring):ansistring;
begin
  //check address;
  result:='';
  if address='' then exit;
  if address[1]<>fEmerAPI.blockChain.AddressSig then
    raise exception.Create('tEmerTransaction.createSpendScript: Wrong address signature');
  //result:=  #118#169 + writeScriptData(copy(address,2,length(address)-1)) + #136#172;  //OP_DUP OP_HASH160 [address] OP_EQUALVERIFY OP_CHECKSIG
  result:=  opNum('OP_DUP') + opNum('OP_HASH160') + writeScriptData(copy(address,2,length(address)-1)) + opNum('OP_EQUALVERIFY') + opNum('OP_CHECKSIG');
end;



constructor tEmerTransaction.create(emerAPI:tEmerAPI;tx:ttx); //overload;
begin
  create(emerAPI,false);
  loadFromTTX(tx);
end;

constructor tEmerTransaction.create(emerAPI:tEmerAPI;buf:ansistring); //overload;
var tx:ttx;
begin
  tx:=unpackTX(buf);
  create(emerAPI,tx);
end;


constructor tEmerTransaction.create(emerAPI:tEmerAPI;freeOnSend:boolean=false);
begin
  inherited create;
  inherited create;
  femerAPI:=emerAPI;
  destroyOnSent:=freeOnSend;
end;





{/tEmerTransaction}

end.

