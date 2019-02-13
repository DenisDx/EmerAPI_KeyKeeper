unit BaseTXUnit;

{$mode objfpc}{$H+}

interface


uses
  Classes, SysUtils
  ,EmerTX
  ,crypto , CryptoLib4PascalConnectorUnit
  ,UOpenSSL, UOpenSSLdef
  ,emerapitypes;

//abstract TX output.
//This is ancestor of the tUTXO and tNVSRecord

type
tbaseTX=class;

tBaseTXI=class(tObject)
private
  fLastHashToSign:ansistring;
public
  //we don't have a constructor because there are no dynamic elements
  //created only y parent
  Owner:tbaseTX;
  txHash:ansistring;
  nOut:integer;
  signature:ansistring;
  redeemScript:ansistring;
  sequence:dword;
  witness:tStringList;
  value:qword;
  //function isSigned:boolean; //moved to TX
  //function sign(privKey:PEC_KEY):boolean; //moved to TX
  function isName:boolean;
  function getNVSName:ansistring;
  function getAddress:ansistring;
  destructor destroy; //destroy witness if it was created
end;

//abstract TX output.
//This is ancestor of the tUTXO and tNVSRecord
tBaseTXO=class(tEmerApiNotified)
  private
  protected
    //fDeepness:integer;
    //fSpending:boolean;
    fOwner:tbaseTX;
    ftxid:ansistring;          //DO NOT CHANGE DIRECTLY keep consistency
    fnOut:integer;             //DO NOT CHANGE DIRECTLY keep consistency USED ONLY IF fOwner=nil
    fScript:ansistring;  //DO NOT CHANGE DIRECTLY keep consistency
    fvalue:qword;              //DO NOT CHANGE DIRECTLY keep consistency
    fHeight:dword; //=0 for unknown; = dword(-1) for mempool
    fGetNameCached:string;
    function getnOut:integer;
  public
    property owner:tbaseTX read fOwner;
    property txid:ansistring read ftxid;
    property nOut:integer read getnOut;//fnOut;
    property value:qword read fvalue write fvalue;
    property Height:dword read fHeight;
    property Script:ansistring read fScript;
    function isSpendable:boolean;
    function isName:boolean;
    function isValidName:boolean;
    function getNVSName:ansistring; //'' if not a name tx
    function getReceiver:ansistring; //who is receiver?
    function getType:ansichar;
    constructor create;
end;

tbaseTX=class (tEmerApiNotified)
  private
    fLockTime:dword;
    fTime:dword;
    fVersion:dword; //loaded version. ZERO -> AUTODETECT
  protected
    fIns:tList;
    fOuts:tList;
    procedure clearInOut(cleanIns:boolean=true;cleanOuts:boolean=true);

    function getInsCount:integer;
    function getOutsCount:integer;
    function getIn(index: integer):tBaseTXI;
    function getOut(index: integer):tBaseTXO;

  public
    lastError:string;
    property LockTime:dword read fLockTime write fLockTime;
    property Time:dword read fTime write fTime;
    property Version:dword read fVersion;

    property insCount:integer read getInsCount;
    property outsCount:integer read getOutsCount;
    property ins[index: integer]:tBaseTXI read getIn;
    property outs[index: integer]:tBaseTXO read getOut;

    function createSpendScript(address:ansistring):ansistring; virtual; abstract;
    function createNameScript(address:ansistring;Name,Value:ansistring;Days:dword;nameNew:boolean):ansistring;
    function createNameSubScript(Name,Value:ansistring;Days:dword;nameNew:boolean):ansistring;

    function isValid():boolean;
    function isNameTx():boolean;

    procedure loadFromBuffer(buf:ansiString);
    function getTXID:ansistring;
    procedure loadFromTTX(tx:ttx);
    function getTTX:ttx;
    function getBuf(addRedeemScriptIfNotSigned:boolean=true):ansistring;

    function getFullSpend:qword;
    function addInput(txid:ansistring;n:integer;value:qword; redeemScript:ansistring='';signature:ansistring='';sequence:dword=DEFAULT_SEQUENCE;witness:tStringList=nil):tBaseTXI; //adds one input.
    function addOutput(script:ansistring;v:qword):tBaseTXO;

    function findNameIn(NVSName:ansistring):tBaseTXI;
    function findNameOut(NVSName:ansistring):tBaseTXO;//nil if not found

    function isInputSigned(nIn:integer):boolean;
    function signIn(nIn:integer;privKey:ansistring):boolean;

    function isSigned(address:ansistring=''):boolean; //'' for all
    function Sign(address:ansistring;privKey:ansistring):boolean;

    constructor create(buf:ansistring); overload;
    constructor create(tx:ttx); overload;
    constructor create(); overload;
    destructor destroy; override;
end;

implementation

uses math, LazUTF8SysUtils;

const
  TX_NAME_ID=$666;
  TX_NORMAL_ID=$2;


{tBaseTXI}

destructor tBaseTXI.destroy;
begin
  if witness<>nil then witness.Free;
  inherited;
end;

function tBaseTXI.isName:boolean;
begin
  //not name tx, just paypent
  //or minting
  result:=false;

  if redeemScript='' then exit;
  //exclude only names. ignore time?
  if (length(redeemScript)>10) then
     result:=redeemScript[1] in [#$51,#$52];

end;

function tBaseTXI.getNVSName:ansistring;
var NameScript:tNameScript;
begin
  result:='';
  if not isName then exit;

  NameScript:=nameScriptDecode(redeemScript);
  result:=NameScript.Name;
end;


function tBaseTXI.getAddress:ansistring;
begin
  result:=nameScriptDecode(redeemScript).Owner;
end;

{
procedure tEmerTransactionIn.loadFromUTXO(SourceUTXO:tUTXO);
begin
  txHash:=
  n:integer;
  signature:ansistring;
  redeemScript:ansistring;
  sequence:dword;
  witness:tStringList;
  value:dword;

  fLastHashToSign:='';

end;

constructor tEmerTransactionIn.create(owner:tEmerTransaction;SourceUTXO:tUTXO); overload;
begin
  create(owner);
  loadFromUTXO(SourceUTXO);
end;
}



{tBaseTXO}



function tbaseTXO.isValidName:boolean;
var NameScript:tNameScript;
begin
  result:=false;
  if not isName then exit;


  NameScript:=nameScriptDecode(fScript);
  result:=true;
  result:=result and (length(NameScript.Name)<=512);
  result:=result and (length(NameScript.Value)<=20480);
end;

//function tbaseTXO.index:integer; //fOwner.fOuts.IndexOf(self)  SIGNING MOVED TO TX
//begin
//  result:=fOwner.fOuts.IndexOf(self);
//end;

function tbaseTXO.getNVSName:ansistring; //'' if not-name
var NameScript:tNameScript;
begin
  result:='';

  if fGetNameCached<>'' then begin
    result:=fGetNameCached;
    exit;
  end;

  if not isName then fGetNameCached:=''
  else begin
    NameScript:=nameScriptDecode(fScript);
    result:=NameScript.Name;
    fGetNameCached:=result;
  end;
end;

function tbaseTXO.getnOut:integer;
var i:integer;
begin
  result:=-1;
  if fOwner=nil then begin
    result:=fnOut;
    exit;
  end;
  for i:=0 to fOwner.outsCount-1 do
    if fOwner.outs[i]=self then begin
      result:=i;
      exit;
    end;
end;

function tbaseTXO.isSpendable:boolean;
begin
  //not name tx, just paypent
  //or minting
  result:=false;

  if fScript='' then exit;
  //exclude only names. ignore time?
  result:=not (fScript[1] in [#$51,#$52,#$53]);
end;

function tbaseTXO.isName:boolean;
begin
  //not name tx, just paypent
  //or minting
  result:=false;

  if fScript='' then exit;
  //exclude only names. ignore time?
  if (length(fScript)>10) then
     result:=fScript[1] in [#$51,#$52,#$53];

end;

function tbaseTXO.getReceiver:ansistring; //who is receiver?
begin
  result:=nameScriptDecode(Script).Owner;
end;

function tbaseTXO.getType:ansichar; //who is receiver?
begin
  result:=nameScriptDecode(Script).TXtype;
end;

constructor tbaseTXO.create;
begin
  inherited create;
  fnOut:=-1;
end;

procedure tbaseTX.clearInOut(cleanIns:boolean=true;cleanOuts:boolean=true);
var i:integer;
begin
  if cleanIns then begin
    for i:=0 to fins.count-1 do
      tBaseTXI(fins[i]).free;
    fins.Clear;
  end;
  if cleanOuts then begin
    for i:=0 to fOuts.count-1 do
      tBaseTXO(fOuts[i]).free;
    fOuts.Clear;
  end;

end;

function tbaseTX.findNameIn(NVSName:ansistring):tBaseTXI;
var i:integer;
begin
  result:=nil;

  for i:=0 to fins.count-1 do
    if tBaseTXI(fins[i]).isName then
      if tBaseTXI(fins[i]).getNVSName=NVSName then
      begin
        result:=tBaseTXI(fins[i]);
        exit;
      end;
end;

function tbaseTX.findNameOut(NVSName:ansistring):tBaseTXO; //nil if not found
var i:integer;
begin
  result:=nil;
  for i:=0 to fOuts.count-1 do
    if tBaseTXO(fOuts[i]).getNVSName = NVSName then begin
      result:=tBaseTXO(fOuts[i]);
      exit;
    end;
end;

constructor tbaseTX.create(buf:ansistring);
begin
  create(unpackTX(buf));
end;


constructor tbaseTX.create(tx:ttx);
begin
  create;
  loadFromTTX(tx);
end;

constructor tbaseTX.create();
begin
  inherited create;
  fIns:=tList.create;
  fOuts:=tList.create;
end;

destructor tbaseTX.destroy;
begin
  clearInOut();
  fIns.Free;
  fOuts.Free;

  inherited;
end;

procedure tbaseTX.loadFromBuffer(buf:ansiString);
var tx:ttx;
begin
  tx:=unpackTX(buf);
  loadFromTTX(tx);
end;

function tbaseTX.getTXID:ansistring;
begin
  result:=reverse(dosha256(dosha256( packTX(getTTX) )))
end;

procedure tbaseTX.loadFromTTX(tx:ttx);
var i,j:integer;
    witness:tStringList;
    signature,redeemScript:ansistring;
begin
  //re-init transaction
  fLockTime:=tx.locktime;
  fTime:=tx.time;
  fVersion:=tx.version;
  clearInOut(true,true);

  //tx.ins[i].script is redeem script, so, fill it. Overwise fill signature
  for i:=0 to length(tx.ins)-1 do begin//if tx.ins[i].script
    redeemScript:='';
    signature:='';
    if isOutputScript(tx.ins[i].script)
        then redeemScript:=tx.ins[i].script
        else signature:=tx.ins[i].script;
    witness:=nil;
    if tx.ins[i].witness<>nil then begin
       witness:=tStringList.Create;
       for j:=0 to length(tx.ins[i].witness)-1 do
         witness.Append(tx.ins[i].witness[j]);
    end;
    try
      addInput(reverse(tx.ins[i].hash),tx.ins[i].index,0{value:dword}, redeemScript,signature,tx.ins[i].sequence, witness); //adds one input. Prevent to add more than one name script
    finally
      if witness<> nil then witness.Free;
    end;
  end;

  for i:=0 to length(tx.outs)-1 do
    addOutput(tx.outs[i].script,tx.outs[i].value);


end;

function tbaseTX.getTTX:ttx;
var i,j:integer;
begin
  if isNameTx() then begin
     fVersion:=TX_NAME_ID;
     result.version:=TX_NAME_ID;
  end
  else
    if fVersion=0
       then result.version:=TX_NORMAL_ID
       else result.version:=fVersion;

  result.locktime:=fLockTime;
  result.time:=fTime;
  if result.time=0 then begin
    fTime:=winTimeToUnixTime(nowUTC());
    result.time:=fTime;
  end;

  setLength(result.Ins,fIns.Count);
  for i:=0 to fIns.Count-1 do begin
    result.ins[i].hash:=tBaseTXI(fIns[i]).txHash;
    result.ins[i].index:=tBaseTXI(fIns[i]).nOut;
    if tBaseTXI(fIns[i]).signature<>''
       then result.ins[i].script:=tBaseTXI(fIns[i]).signature
       else result.ins[i].script:=tBaseTXI(fIns[i]).redeemScript;
    result.ins[i].sequence:=tBaseTXI(fIns[i]).sequence;
    if tBaseTXI(fIns[i]).witness = nil
       then setLength(result.ins[i].witness,0)
       else begin
          setLength(result.ins[i].witness,tBaseTXI(fIns[i]).witness.Count);
          for j:=0 to tBaseTXI(fIns[i]).witness.Count-1 do
              result.ins[i].witness[j]:=tBaseTXI(fIns[i]).witness[j];
       end;
  end;

  //add zero-input of no
  if fIns.Count=0 then begin
    setLength(result.Ins,1);
    result.Ins[0].index:=0;
    result.Ins[0].hash:=#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
    result.Ins[0].script:='';
    result.Ins[0].sequence:=DEFAULT_SEQUENCE;
    setLength(result.Ins[0].witness,0);
  end;

  setLength(result.outs,fOuts.Count);
  for i:=0 to fOuts.Count-1 do begin
    result.outs[i].script:=tBaseTXO(fOuts[i]).Script;
    result.outs[i].value:=tBaseTXO(fOuts[i]).value;;
  end;



end;

function tbaseTX.getBuf(addRedeemScriptIfNotSigned:boolean=true):ansistring;
begin
  result:=packTX(getTTX,true,addRedeemScriptIfNotSigned);
end;

function tbaseTX.getFullSpend:qword;
var i:integer;
begin
  result:=0;
  for i:=0 to fIns.Count-1 do
    result:=result+ tBaseTXI(fIns[i]).value;
end;

function tbaseTX.addInput(txid:ansistring;n:integer;value:qword; redeemScript:ansistring='';signature:ansistring='';sequence:dword=DEFAULT_SEQUENCE;witness:tStringList=nil):tBaseTXI; //adds one input.
begin
  //do not add the same txid: n twice
  result:=tBaseTXI.create({self});
  fIns.Add(result);

  result.txHash:=reverse(txid);
  result.nOut:=n;
  result.value:=value;
  result.redeemScript:=redeemScript;
  result.signature:=signature;
  result.sequence:=sequence;
  if witness<>nil then begin
    result.witness:=tStringList.create;
    result.witness.assign(witness);
  end;
end;

function tbaseTX.addOutput(script:ansistring;v:qword):tBaseTXO; //adds one output. DONT Prevent to add more than one name script
begin
  result:=tBaseTXO.create({self});
  result.fOwner:=self;
  fOuts.Add(result);
  result.fScript:=script;
    result.fGetNameCached:='';
  result.fValue:=v;
end;

function tbaseTX.createNameScript(address:ansistring;Name,Value:ansistring;Days:dword;nameNew:boolean):ansistring;
begin
  result:=
    createNameSubScript(Name,Value,Days,nameNew)
    +
    createSpendScript(address);
end;

function tbaseTX.createNameSubScript(Name,Value:ansistring;Days:dword;nameNew:boolean):ansistring;
begin
  result:='';
  if Name='' then
    raise exception.Create('tEmerTransaction.createNameSubScript: Empty Name ');


  if nameNew
      then result:=opNum('OP_NAME_NEW')
      else result:=opNum('OP_NAME_UPDATE');

  result:=result + opNum('OP_DROP'); //OP_NAME_NEW OP_DROP

  //OP_NAME_NEW OP_DROP [747374]
  result:=result + writeScriptData(Name);

  result:=result + writeScriptIntBuf(days);

   //OP_NAME_NEW OP_DROP [747374] [0F27]

  result:=result + opNum('OP_2DROP'); //OP_NAME_NEW OP_DROP OP_2DROP


  result:=result + writeNameData(Value);
end;

function tbaseTX.isValid():boolean;
var i:integer;
    nameFound:boolean;
begin
  //only one name :(
  result:=true;
  nameFound:=false;
  if fOuts=nil then exit;
  for i:=0 to fOuts.Count-1 do
    if tBaseTXO(fOuts[i]).isName then
      if nameFound then begin
        result:=false;
        exit;
      end else begin
        nameFound:=true;
        result:=tBaseTXO(fOuts[i]).isValidName;

        if not result then exit;
      end;
end;

function tbaseTX.isNameTx():boolean;
var i:integer;
begin
  result:=false;
  if fOuts=nil then exit;
  for i:=0 to fOuts.Count-1 do
    if tBaseTXO(fOuts[i]).isName then begin
      result:=true;
      exit;
    end;
end;


function tBaseTX.getInsCount:integer;
begin
  result:=fIns.Count;
end;

function tBaseTX.getOutsCount:integer;
begin
  result:=fOuts.Count;
end;

function tBaseTX.getIn(index: integer):tBaseTXI;
begin
  if (index<0) or (index>=fIns.Count) then raise exception.Create('tBaseTX.getIn: index out of bounds');
  result:=tBaseTXI(fIns[index]);

end;

function tBaseTX.getOut(index: integer):tBaseTXO;
begin
  if (index<0) or (index>=fOuts.Count) then raise exception.Create('tBaseTX.getOut: index out of bounds');
  result:=tBaseTXO(fOuts[index]);

end;


function tBaseTX.isInputSigned(nIn:integer):boolean;
var
  tx:ttx;
  hts:ansistring;
begin
  result:=false;

  if (nIn<0) or (nIn>(fIns.Count-1)) then exit;


  result:= tBaseTXI(fIns[nIn]).signature<>'';
  if result then begin //check if fLastHashToSign was changed.
    tx:=getTTX;

    if tBaseTXI(fIns[nIn]).fLastHashToSign<>'' then begin
      hts:=hashForSignature(tx, tBaseTXI(fIns[nIn]).nOut, tBaseTXI(fIns[nIn]).redeemScript{, hashType});
      result:=(hts=tBaseTXI(fIns[nIn]).fLastHashToSign) and (tBaseTXI(fIns[nIn]).fLastHashToSign<>'');
    end else
      //full signature verification
      result:=checkSignatureForTX(tBaseTXI(fIns[nIn]).signature,tx,tBaseTXI(fIns[nIn]).nOut,tBaseTXI(fIns[nIn]).fLastHashToSign,tBaseTXI(fIns[nIn]).redeemScript);
  end;

end;

function tBaseTX.isSigned(address:ansistring=''):boolean; //'' for all
var i:integer;
    add:ansistring;
begin
  result:=false;
  if address=''
      then add:=''
      else add:=addressto20(address);

  for i:=0 to fIns.Count-1 do
    if (add='') or (Ins[i].getAddress=add) then
      if not isInputSigned(i) then
        exit;

  result:=true;
end;

function tBaseTX.Sign(address:ansistring;privKey:ansistring):boolean;
var i:integer;
    add:ansistring;
begin
  result:=false;
  add:=addressto20(address);
  if add='' then exit;
  result:=true;
  for i:=0 to fIns.Count-1 do
    if Ins[i].getAddress=add then
      if not isInputSigned(i) then
        result:=signIn(i,privKey) and result;
end;

function tBaseTX.signIn(nIn:integer;privKey:ansistring):boolean;
var
  tx:ttx;
  input:ttxin;

var signatureHash:ansistring;
     kpPubKey:ansistring;
     sig:TECDSA_SIG;
     s:ansistring;
     pubKey:TECDSA_Public;
     i:integer;

     myredeemScript:ansistring;

     hashType:byte;
     vin:integer;
begin
  result:=false;
  if privKey='' then exit;
  if (nIn<0) or (nIn>(fIns.Count-1)) then exit;

  if tBaseTXI(fIns[nIn]).redeemScript='' then exit;


  //TODO: create ONE universal proc for sign and call it from here, receiving signatureHash

  hashType:=0;
  tx:=getTTX;

  vin:= nIn;

  if (length(tx.ins)<=vin) or (vin<0) then begin
    LastError:='tEmerTransactionIn.sign : Wrong input for sign ';
    exit;// raise exception.create('signIn: No input at index: ' + inttostr(vin));
  end;

  myredeemScript:=tBaseTXI(fIns[nIn]).redeemScript;
  if trim(myredeemScript)='' then //Build standard redeem script to out key: use compression
     myredeemScript:= #118#169 + writeScriptData(DoRipeMD160(DoSha256(kpPubKey))) + #136#172 ;  //OP_DUP OP_HASH160 [address] OP_EQUALVERIFY OP_CHECKSIG


  pubkey:=GetPublicKey(privKey);


  hashType := hashType or SIGHASH_ALL;

  input := tx.ins[vin];
  kpPubKey := pubKeyToBuf(pubKey,{keyCompressed}true);

  //check if the privkey matched to address : CANCELED because we don't have such a parent anymore
 // if address<>(fOwner.fEmerAPI.blockChain.AddressSig+DoRipeMD160(DoSha256(kpPubKey))) then begin
//    result:=false;
//    fOwner.lastError:='Private key does not matched to script-to-sign: '+bufToHex(address)+' <> '+bufToHex((fOwner.fEmerAPI.blockChain.AddressSig+DoRipeMD160(DoSha256(kpPubKey))));
//    exit;
//  end;

  signatureHash:=hashForSignature(tx, vin, myredeemScript{, hashType});

  // ready to sign

   if (length(input.witness)>0) then begin
     //signatureHash = this.tx.hashForWitnessV0(this, vin, input.signScript, input.value, hashType)
     raise exception.Create('Witness is not supported now');
   end else begin
       signatureHash := hashForSignature(tx, vin, myredeemScript, hashType);
   end;

   if (length(kpPubKey) <> 33)
        then raise exception.Create('signIn: BIP143 rejects uncompressed public keys in P2WPKH or P2WSH');

   {!!! IMPLEMENT NEW
   i:=0;
   repeat
     sig:=ECDSASign(privKey, signatureHash);
   until (i>1000) or ((ord(sig.r[1]) and $80)=0) and ((ord(sig.s[1]) and $80)=0);

   s:=EncodeSignature(sig,hashType);
   !!!}





   s:=ECDSASign(
     //tmpPEC_KEY_2_IECPrivateKeyParameters(privKey)
     //BigNum_2_IECPrivateKeyParameters(bignumToBuf(EC_KEY_get0_private_key(privKey)))
     privKey
     , signatureHash)+chr(hashType);

   tBaseTXI(fIns[nIn]).signature:=writeScriptData(s) + writeScriptData(kpPubKey);

   tBaseTXI(fIns[nIn]).fLastHashToSign:=signatureHash;
   result:=true;
end;


end.

