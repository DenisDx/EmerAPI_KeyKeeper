unit BlockchainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, emerapitypes, EmerAPIBlockchainUnit, fpjson, jsonparser //UOpenSSL, UOpenSSLdef, Crypto, fpjson, jsonparser,

  ;

type
  tBlockChain = class(tEmerApiNotified)
   private
    fEmerAPIConnetor:TEmerAPIBlockchainProto;
    fWifID:char;
    fAddressSig:char;
    fNetwork:string;

    fLastUpdateTime:tDateTime;
    //updateable data:
    fPoWDif:double;
    fHeight:dword;
    fLastPoWReward:dword; //PoW reward for name cost calculation
    fLastPoWRewardBlock:dword;
    fchain:string;

    fListForUpdateBits:dword;//bits: 0: fHeight.fPoWDif 1: fLastPoWReward, fLastPoWRewardBlock

    procedure AsyncAddressInfoDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
    function getUpdated:boolean;
   public

    AddOneCentToNameTxFee:boolean;

    property updated:boolean read getUpdated;
    property PoWDif:double read fPoWDif;
    property Height:dword read fHeight;
    property LastPoWReward:dword read fLastPoWReward;
    property LastPoWRewardBlock:dword read fLastPoWRewardBlock;
    property Chain:string read fchain;

    function addressIsValid(address:ansistring):boolean;

    procedure update(eapiNotify:tEmerAPINotification; forceUpdate:boolean=false);
    function MIN_TX_FEE:dword;
    property WifID:char read fWifID;
    property AddressSig:char read fAddressSig;
    property Network:string read fNetwork;
    property LastUpdateTime:tDateTime read fLastUpdateTime;
    procedure setNetworkParams(mNetwork:string;mWifID:char;mAddressSig:char);
    function getNameOpFee(nRentalDays:int64;op:char;txtLen:integer;BlockIndex:integer=0):int64;
    constructor create(EmerAPIConnetor:TEmerAPIBlockchainProto;mNetwork:string='';mWifID:char=#0;mAddressSig:char=#0);
 end;


implementation

uses HelperUnit, EmerTX, Math, crypto;

{tBlockChain}
constructor tBlockChain.create(EmerAPIConnetor:TEmerAPIBlockchainProto;mNetwork:string='';mWifID:char=#0;mAddressSig:char=#0);
begin
  inherited create;
  fEmerAPIConnetor:=EmerAPIConnetor;
  setNetworkParams(mNetwork,mWifID,mAddressSig);
end;

procedure tBlockChain.setNetworkParams(mNetwork:string;mWifID:char;mAddressSig:char);
begin
  if (mNetwork<>fnetwork) or (mWifID<>fWifID) or (mAddressSig<>fAddressSig) then
     if fEmerAPIConnetor<>nil then begin
        //fEmerAPIConnetor. может, надо что-то сделать?
     end;
  fNetwork:=mNetwork;
  fWifID:=mWifID;
  fAddressSig:=mAddressSig;

end;

function tBlockChain.MIN_TX_FEE:dword;
begin
  result:=100;
end;

procedure tBlockChain.AsyncAddressInfoDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
var e:tJsonData;
    hash:string;
    blockn:integer;
begin
  if result=nil then begin
    //showMessageSafe('Error: '+sender.lastError);
    exit;
  end;

  {
  getblockhash номер блока
  getblock Хеш
  ."difficulty": 0.1157537016986394,
  ."mint": 4529.950000,
  "flags": "proof-of-work"

  .blocks
  .chain  -> network test
  fListForUpdateBits:=0;//bits: 0: fHeight.fPoWDif 1: fLastPoWReward, fLastPoWRewardBlock . query chain: //getblockchaininfo.blocks (blocks->fHeight,fchain, PoWDif) -> [getblockhash height:fheight (hash) -> getblock  blockhash:hash (?"flags": "proof-of-work" =>)
   }

  // fPoWDif:double;
  // fHeight:dword;
  // fLastPoWReward:dword; //PoW reward for name cost calculation
  // fLastPoWRewardBlock:dword;
  // fchain:string;



  if sender.id='getblockchaininfo' then begin
    e:=result.FindPath('result.difficulty');
    if e=nil then begin
      callNotify('updateError');
      fListForUpdateBits:=0;
      exit;
    end;
    fPoWDif:=myStrToFloat(e.AsString); //PoW reward for name cost calculation
    //blocks chain
    e:=result.FindPath('result.blocks');
    if e<>nil then fHeight:=e.AsInteger else fHeight:=0;
    e:=result.FindPath('result.chain');
    if e<>nil then fchain:=e.asString else fchain:='';

    fListForUpdateBits:=fListForUpdateBits or 1;
    if (fListForUpdateBits and 2)=0 then //next step!
        fEmerAPIConnetor.sendWalletQueryAsync('getblockhash',GetJSON('{"height":'+inttostr(fheight)+'}'),@AsyncAddressInfoDone,'getblockhash');

    callNotify('getblockchaininfo');
  end else
  //[getblockhash height:fheight (hash) -> getblock  blockhash:hash (?"flags": "proof-of-work" =>)
  if sender.id='getblockhash' then begin
    //1-st cycle stage
    e:=result.FindPath('result');
    if (e=nil) or (e.IsNull) then begin
      callNotify('updateError');
      fListForUpdateBits:=0;
      exit;
    end;
    hash:=e.AsString;

    //fListForUpdateBits:=fListForUpdateBits or 1;
    if (fListForUpdateBits and 2)=0 then //next step!
       fEmerAPIConnetor.sendWalletQueryAsync('getblock',GetJSON('{"blockhash":"'+hash+'"}'),@AsyncAddressInfoDone,'getblock');

    callNotify('getblockhash');
  end else
  if sender.id='getblock' then begin
    //2-nd cycle stage
    e:=result.FindPath('result.flags');
    if e=nil then begin
      callNotify('updateError');
      fListForUpdateBits:=0;
      exit;
    end;
    if e.AsString='proof-of-work' then begin
      //PoW block found!

      e:=result.FindPath('result.mint');
      if e<>nil then fLastPoWReward:=trunc(myStrToFloat(e.AsString)*COIN) else fLastPoWReward:=0;
      e:=result.FindPath('result.height');
      if e<>nil then fLastPoWRewardBlock:=e.asInteger else fLastPoWRewardBlock:=0;

      if fLastPoWReward*fLastPoWRewardBlock>0 then begin
        fLastUpdateTime:=now;
        fListForUpdateBits:=fListForUpdateBits or 2;
        callNotify('update');
      end else begin
        fListForUpdateBits:=0;
        callNotify('updateError');
      end;
    end else begin
      //must dig dipper
      e:=result.FindPath('result.height');
      if e=nil then begin
        callNotify('updateError');
        fListForUpdateBits:=0;
        exit;
      end;
      blockn:=e.AsInteger-1;
      if (fListForUpdateBits and 2)=0 then //next step!
        fEmerAPIConnetor.sendWalletQueryAsync('getblockhash',GetJSON('{"height":'+inttostr(blockn)+'}'),@AsyncAddressInfoDone,'getblockhash');
    end;

    callNotify('getblock');
  end else raise exception.Create('tBlockChain.AsyncAddressInfoDone: not supported sender.id: '+sender.id);



end;

function tBlockChain.getUpdated:boolean;
begin
  result:=
   ((now - fLastUpdateTime)<5/60/24)//fLastUpdateTime:tDateTime;

   //updateable data:
   and (fPoWDif>0)//fPoWDif:double;
   and (fHeight>0)//fHeight:dword;
   and (fLastPoWReward>0)//fLastPoWReward:dword; //PoW reward for name cost calculation
   and (fLastPoWRewardBlock>0)//fLastPoWRewardBlock:dword;
   and (fchain<>'')//fchain:string;

   and ((fListForUpdateBits and 3) = 3)//fListForUpdateBits:dword;//bits: 0: fHeight.fPoWDif 1: fLastPoWReward, fLastPoWRewardBlock
   ;
end;

procedure tBlockChain.update(eapiNotify:tEmerAPINotification; forceUpdate:boolean=false);
begin
  addNotify(eapiNotify);
  fListForUpdateBits:=0;//bits: 0: fHeight.fPoWDif 1: fLastPoWReward, fLastPoWRewardBlock . query chain: //getblockchaininfo.blocks (blocks->fHeight,fchain, PoWDif) -> [getblockhash height:fheight (hash) -> getblock  blockhash:hash (?"flags": "proof-of-work" =>)
  fEmerAPIConnetor.sendWalletQueryAsync('getblockchaininfo',nil,@AsyncAddressInfoDone,'getblockchaininfo');
end;


function tBlockChain.addressIsValid(address:ansistring):boolean;
var s:string;
begin
  result:=false;
  if length(address)>21 then
    s:=base58ToBufCheck(trim(address))
  else
    s:=address;
  if length(s)<20 then exit;

  result:=(length(s)=20) or (s[1]=AddressSig);
end;

//emerAPI.GetNameOpFee(nRentalDays:integer;op:char;txtLen:integer;BlockIndex:integer=0):dword;
function tBlockChain.getNameOpFee(nRentalDays:int64;op:char;txtLen:integer;BlockIndex:integer=0):int64;
//call update first!!!
var nMint:dword;
    CENT:dword;
begin
  {

  m: Last PoW block reward
  d: days
  1. x= (m*d) div (365*100)
  2. x += m div 100 if name_new
  3. x = sqrt(x div 10000)*10000
  4. x = x + l div 128 * 10000
  5. x = x + 9999
  6. x = x div 100
  7. x = max (x, 100)
  8. x = x + 100

  -------simplified:

  x = sqrt( m * (d/365 + 1<if new>)) + 100 * (l div 128) + 100

  упрощенное вычисление по русски

    корень(награда_за_последний_PoS_блок*лет_аренды_плюс_один_если_новое) + 100 монет за каждые 128 байт имени+значение

  }


 if (op = opNum('OP_NAME_DELETE')) then begin
   result:=MIN_TX_FEE;
   exit;
 end;

 result:=0;

 CENT:=10000; //???
 //const CBlockIndex* lastPoW = GetLastBlockIndex(pindex, false);
 // result:=
 //?! nMint:=trunc(5020*fPoWDifficulty);
 //OLD : nMint:=round((5020 / (sqrt(sqrt(fPoWDifficulty))))*100*100);

 nMint:=fLastPoWReward;

 //CAmount txMinFee = nRentalDays * lastPoW->nMint / (365 * 100); // 1% PoW per 365 days
 result:=(nMint*nRentalDays) div (365 * 100);

 //if (op == OP_NAME_NEW)
 //    txMinFee += lastPoW->nMint / 100; // +1% PoW per operation itself
 if op=opNum('OP_NAME_NEW') then
   result:=result + nMint div 100;

 //txMinFee = sqrt(txMinFee / CENT) * CENT; // square root is taken of the number of cents.
 //txMinFee += (int)((name.size() + value.size()) / 128) * CENT; // 1 cent per 128 bytes
 result:=trunc(sqrt(result div CENT)+1) * CENT;
 result:= result + txtLen div 128 * CENT;


 // Round up to CENT
 //txMinFee += CENT - 1;
 //txMinFee = (txMinFee / CENT) * CENT;
 result:=result+CENT-1;
 result:= (result div CENT) * CENT;

 // reduce fee by 100 in 0.7.0emc
 //txMinFee = txMinFee / 100;
 result:=result div 100;

 // Fee should be at least MIN_TX_FEE
 // txMinFee = max(txMinFee, MIN_TX_FEE);
 result:= max(result, MIN_TX_FEE);

//!! if (op = opNum('OP_NAME_NEW')) then
//!!   result:=result+MIN_TX_FEE;

 if AddOneCentToNameTxFee then
   result:=result+MIN_TX_FEE;

{

   // Returns minimum name operation fee rounded down to cents. Should be used during|before transaction creation.
   // If you wish to calculate if fee is enough - use IsNameFeeEnough() function.
   // Generaly:  GetNameOpFee() > IsNameFeeEnough().
   CAmount GetNameOpFee(const CBlockIndex* pindex, const int nRentalDays, int op, const CNameVal& name, const CNameVal& value)


   if (op == OP_NAME_DELETE)
       return MIN_TX_FEE;

   const CBlockIndex* lastPoW = GetLastBlockIndex(pindex, false);

   CAmount txMinFee = nRentalDays * lastPoW->nMint  / (365 * 100); // 1% PoW per 365 days

   if (op == OP_NAME_NEW)
       txMinFee += lastPoW->nMint / 100; // +1% PoW per operation itself

   txMinFee = sqrt(txMinFee / CENT) * CENT; // square root is taken of the number of cents.
   txMinFee += (int)((name.size() + value.size()) / 128) * CENT; // 1 cent per 128 bytes

   // Round up to CENT
   txMinFee += CENT - 1;
   txMinFee = (txMinFee / CENT) * CENT;

   // reduce fee by 100 in 0.7.0emc
   txMinFee = txMinFee / 100;

   // Fee should be at least MIN_TX_FEE
   txMinFee = max(txMinFee, MIN_TX_FEE);

   return txMinFee;


   }
//edit12.Text:= inttostr(emerAPI.GetNameOpFee(nameScript.Days,ord(nameScript.TXtype),length(nameScript.Value) + length(nameScript.Name)));
(*
  e:=result.FindPath('result.difficulty');
  if e=nil then begin
    showMessageSafe('Blockchain info incorrect: '+result.asJson);
    exit;
  end;
  x:=myStrToFloat(e.AsString); //difficulty
  vR:= (5020 / (sqrt(sqrt(x))))*100*100;

  //looking for the name...
  //
  vY:=0;
  vS:=0;
  for i:=1 to StringGrid2.RowCount-1 do begin
    nameScript:=nameScriptDecode(hexToBuf(trim(StringGrid2.Cells[2,i])));
    case ord(nameScript.TXtype) of
      81:begin
           vY:=nameScript.Days/365 {+ 1}; //!!! +1 for a new name
           vS:=(length(nameScript.Value) + length(nameScript.Name)) div 128;
        break;
      end;
      82:begin
        vY:=nameScript.Days/365;
        vS:=(length(nameScript.Value) + length(nameScript.Name)) div 128;
        break;
      end;
      83:begin
          vY:=0;
          vS:=0;
        break;
      end;
    end;
  end;

  if (vS>0) or (vY>0) then
    if CheckBox6.Checked then
       //edit12.Text:= inttostr(100*round(( sqrt(0.0005 * vR * vy) + vS / 128 ) /100 *100 ))
      edit12.Text:= inttostr(100*round(( sqrt(0.0005 * vR * (vy+1)) + (vS) {/ 128} ) {/100 *100} ))
    else
      edit12.Text:= inttostr(100*round(( sqrt(0.0005 * vR * vy) + (vS) {/ 128} ) {/100 *100} ))
  else
   edit12.Text:= '100';

*)

end;


end.

