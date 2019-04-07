unit UTXOunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, EmerAPIBlockchainUnit, {EmerAPIWalletUnit, EmerAPIServerUnit,} fpjson, emerapitypes, BlockchainUnit, BaseTXUnit {,ttxoUnit};


type
  tUTXOOptimization=(uxoSaveCoinDaysOptimized,uxoMinimizeUtxoCount,uxoSpendRandom); //Save coin/days /  Minimize TX count in the wallet / Spend random


  tUTXOList = class;



  tUTXO = class (tbaseTXO)
   private
     fOwnerList:tUTXOList;
   public
     property owner:tUTXOList read fOwnerList;
     property ownerTX:tbaseTX read fOwner;
     constructor create(mowner:tUTXOList;mtxid:ansistring;mnOut:integer;mscriptToSign:ansistring;mvalue:qword;mheight:qword);
  end;

  tUTXOListStat=record
     spendable:qword;
     //spendableInMemPool:qword;
     //spendableLockedInMemPool:qword;
     spendableinNames:qword;
     nameCount:integer;
     //expiredNameCount:integer;
     utxoCount:integer;

     lastUpdateTime:tDateTime;
  end;

  //Notifications:
  //updateUTXO : UTXOs updated
  tUTXOList = class(tEmerApiNotified)
  private
    fAddresses:tStringList;
    fUTXOlist:tStringList; //list of tUTXO objects
    femerAPIConnector:TEmerAPIBlockchainProto;
    fBlockchain:tBlockchain;
    fLastUpdateTimeTX:tDateTime;
    fLastUpdateTimePool:tDateTime;
    jsLastscantxoutset:tJSONData;
    //jsLastgetrawmempool:tJSONData;
    fMempoolTXIDLlst:tStringList;
    procedure onBlockchainData(sender:TEmerAPIBlockchainThread;result:tJsonData);
    procedure internalUpdate();
    function memPoolTXReady:boolean;
    procedure updateUTXOByMempool();
  protected
    function updateBlockchain:boolean;
    function updateMempool:boolean;
    procedure clearUTXO();
    function getCount:integer;
    function getItem(Index:integer):tUTXO;
  public
    keepAmountThreshold:qword; //minimal amout to keep the transaction in uxoSaveCoinDaysOptimized mode
    UTXOOptimization:tUTXOOptimization;

    property Count:integer read GetCount;
    property Items[Index:integer]:tUTXO read getItem; default;
    //procedure addNotify(eapiNotify:tEmerAPINotification);
    function update(eapiNotify:tEmerAPINotification):boolean;
    property blockChain:tBlockchain read fblockChain write fblockChain;
    property emerAPIConnector:TEmerAPIBlockchainProto read femerAPIConnector write femerAPIConnector;
    function giveToSpend(value:qword;lTxExclude:tStringList=nil;canUseMempool:boolean=true;optimization:tUTXOOptimization=uxoSaveCoinDaysOptimized):tList; //returns UTXO list to spend
    function addUTXO(txid:ansistring;n:integer;scriptToSign:ansistring;value:qword;height:qword):tUTXO;
    procedure deleteUTXO(txid:ansistring;nOut:integer); //used if spent
    function findUTXO(txid:ansistring;n:integer):tUTXO;
    function findName(NVSname:ansistring):tUTXO;
    constructor create(mEmerAPIConnector:TEmerAPIBlockchainProto;mBlockChain:TBlockchain;addresses:tStringList=nil); overload;
    constructor create(mEmerAPIConnector:TEmerAPIBlockchainProto;mBlockChain:TBlockchain;address:ansistring); overload;
    destructor destroy; override;
    procedure setAddresses(newAddresses:tStringList);
    function getStat:tUTXOListStat;
    function hasAddress(address:ansistring):boolean; overload;
    function hasAddress(addresses:tStringList):boolean; overload; //THE SAME
  end;

implementation

uses HelperUnit, crypto, CryptoLib4PascalConnectorUnit, math, EmerTX;

{tUTXO}

constructor tUTXO.create(mowner:tUTXOList;mtxid:ansistring;mnOut:integer;mscriptToSign:ansistring;mvalue:qword;mheight:qword);
begin
  inherited create;
  //fDeepness:=-1;
  //fSpending:=false;
  ftxid:=mtxid;
  fnOut:=mnOut;
  fScript:=mscriptToSign;
  fOwnerList:=mowner;
  fvalue:=mvalue;
  fHeight:=mheight;
end;


{/tUTXO}
{tUTXOList}

{fLastUpdateTimeTX:tDateTime;
fLastUpdateTimePool:tDateTime;
jsLastscantxoutset:tJSONData;
jsLastgetrawmempool:tJSONData;
 }
 type
    tptx=^ttx;
 //TListSortCompare = function (Item1, Item2: Pointer): Integer;
 function myCompare(Item1, Item2: Pointer): Integer;
 begin
    Result := tptx(Item1)^.time - tptx(Item2)^.time;  //Job2.StartTime - Job1.StartTime;
 end;

procedure tUTXOList.updateUTXOByMempool();

var ptx:tptx;
    ltx:tList;

  function ourtx(tx:ttx):boolean;
    var i,j:integer;
        s:ansistring;
        nameScript:tNameScript;
  begin
    result:=true;        exit;
    //if this is a spending of our UTXOs?
    for i:=0 to length(tx.ins)-1 do
      if fUTXOlist.IndexOf(chr(tx.ins[i].index div 256)+chr(tx.ins[i].index mod 256)+reverse(tx.ins[i].hash))>=0 then exit;
    //if we are receiver?
    for j:=0 to fAddresses.Count-1 do begin
      s:=base58ToBufCheck(fAddresses[j]);
      //check signature? Да ну, в задницу! Сколько можно?
      delete(s,1,1);
      for i:=0 to length(tx.outs)-1 do begin
        nameScript:=nameScriptDecode(tx.outs[i].script);
        if s=nameScript.Owner then
          exit;
      end;
    end;
    result:=false;
  end;


  procedure checkTxAdd(tx:ttx);
    var i,j:integer;
        s:ansistring;
        nameScript:tNameScript;
  begin
    //if we are receiver?
    for j:=0 to fAddresses.Count-1 do begin
      s:=base58ToBufCheck(fAddresses[j]);
      //check signature? Да ну, в задницу! Сколько можно?
      delete(s,1,1);
      for i:=0 to length(tx.outs)-1 do begin
        nameScript:=nameScriptDecode(tx.outs[i].script);
        if s=nameScript.owner then begin
           //new UTXO!
           addUTXO(reverse(dosha256(dosha256(packTX(tx)))),i,tx.outs[i].script,tx.outs[i].value,fBlockchain.Height);
         end;
      end;
    end;

   { //if this is a spending of our UTXOs?
    for i:=0 to length(tx.ins)-1 do
      if fUTXOlist.IndexOf(chr(tx.ins[i].index div 256)+chr(tx.ins[i].index mod 256)+reverse(tx.ins[i].hash))>=0 then begin
         //remobe the UTXO
        deleteUTXO(reverse(tx.ins[i].hash),tx.ins[i].index);
      end;
    }
  end;
  procedure checkTxDelete(tx:ttx);
    var i,j:integer;
        s:ansistring;
        nameScript:tNameScript;
  begin
   { //if we are receiver?
    for j:=0 to fAddresses.Count-1 do begin
      s:=base58ToBufCheck(fAddresses[j]);
      //check signature? Да ну, в задницу! Сколько можно?
      delete(s,1,1);
      for i:=0 to length(tx.outs)-1 do begin
        nameScript:=nameScriptDecode(tx.outs[i].script);
        if s=nameScript.owner then begin
           //new UTXO!
           addUTXO(reverse(dosha256(dosha256(packTX(tx)))),i,tx.outs[i].script,tx.outs[i].value,fBlockchain.Height);
         end;
      end;
    end;
    }
    //if this is a spending of our UTXOs?
    for i:=0 to length(tx.ins)-1 do
      if fUTXOlist.IndexOf(chr(tx.ins[i].index div 256)+chr(tx.ins[i].index mod 256)+reverse(tx.ins[i].hash))>=0 then begin
         //remobe the UTXO
        deleteUTXO(reverse(tx.ins[i].hash),tx.ins[i].index);
      end;
  end;

  var i:integer;
begin
  //
  //    tx:ttx;
  //1. order all tx by time
  //2. check inpust: perhaps we should delete the UTXO
  //3. check outs: if we are a receiver, add it. Add blockChain.Height as height

  ltx:=tList.Create;
  try
    for i:=0 to fMempoolTXIDLlst.Count-1 do begin
      new(ptx);
      ptx^:=unpacktx(fMempoolTXIDLlst[i]);
      if ourtx(ptx^)
         then ltx.Add(ptx)
         else dispose(ptx);
    end;
    //order
    ltx.Sort(@myCompare);

    //check one-by-one
    for i:=0 to ltx.Count-1 do
      checktxAdd(tptx(ltx[i])^);

    for i:=0 to ltx.Count-1 do
      checktxDelete(tptx(ltx[i])^);


  finally
    for i:=0 to ltx.Count-1 do
      if ltx[i]<>nil then
        dispose(tptx(ltx[i]));
    ltx.Free;
  end;

end;

function tUTXOList.memPoolTXReady:boolean;
var i:integer;
begin
  result:=false;
  if fMempoolTXIDLlst=nil then exit;
  for i:=0 to fMempoolTXIDLlst.Count-1 do
    if length(fMempoolTXIDLlst[i])<=33 then exit; //this is a hash not resolved

  result:=true;
end;

procedure tUTXOList.internalUpdate();
var i:integer;
begin
  if (jsLastscantxoutset=nil) or (not memPoolTXReady)  then exit;
  clearUTXO();

 for i:=0 to TJSONArray(jsLastscantxoutset).Count-1 do
    addUTXO(
      hexToBuf(jsLastscantxoutset.Items[i].FindPath('txid').AsString)
      ,jsLastscantxoutset.Items[i].FindPath('vout').AsInteger
      ,hexToBuf(jsLastscantxoutset.Items[i].FindPath('scriptPubKey').AsString)
      ,trunc(myStrToFloat(jsLastscantxoutset.Items[i].FindPath('amount').AsString)*1000000)
      ,jsLastscantxoutset.Items[i].FindPath('height').AsInteger
    );
 //mempool

  updateUTXOByMempool();

  callNotify('updateUTXO');
end;



procedure tUTXOList.onBlockchainData(sender:TEmerAPIBlockchainThread;result:tJsonData);
var js,e:tJsonData;
    s:string;
    x:double;
    i:integer;
    st:ansistring;
begin
  if result=nil then begin
   EmerAPIConnector.checkConnection();
   exit;
  end;

  js:=result;
  if pos('scantxoutset_',sender.id+'_')=1 then begin
    if js<>nil then begin
     e:=js.FindPath('result.unspents');
     if e<>nil then begin
       jsLastscantxoutset:=e.Clone;
       fLastUpdateTimeTX:=now;
       internalUpdate;
     end;
     //fLastUpdateTimeTX:=now;
    end;
  end else
  if pos('getrawmempool_',sender.id+'_')=1 then begin
   if js<>nil then begin
    e:=js.FindPath('result');
    if (e<>nil) then begin
        //result=["5563aa42ebfb20333b0c52108d45e0d7fa8f6376af9fdc8c451552df4ce2161e", "f83338ef7b9149dde00c0cb806b8f97de29aa7acfe6dc5cae3b63256822c1b50", "efe31bd29f5bdfc30ab4e77c8fa95799c01c4d98d82dabaeb4f83506161e1850"]
       //1. deleting our tx
       //2. requesting all the TX getrawtransaction - и проверяем - наши ли.
       if fMempoolTXIDLlst<>nil then fMempoolTXIDLlst.Clear
       else fMempoolTXIDLlst:=tStringList.Create;

       fLastUpdateTimePool:=now;

       if (not e.IsNull) then
       for i:=0 to tJSONArray(e).Count-1 do begin
         fMempoolTXIDLlst.Append(hexToBuf(tJSONArray(e)[i].AsString));
         //step 2. receiving all tx from the mempool
          if fEmerAPIConnector<>nil then
          fEmerAPIConnector.sendWalletQueryAsync('getrawtransaction',
             getJSON('{txid:"'+tJSONArray(e)[i].AsString+'"}')
            ,@onBlockchainData,'getrawtransactionPull_'+fEmerAPIConnector.getNextID);
       end;
       if fMempoolTXIDLlst.Count=0 then
         internalUpdate;
    end;
   end;
  end else
  if pos('getrawtransactionPull_',sender.id)=1 then begin
   if js<>nil then begin
    e:=js.FindPath('result');
    if (e<>nil) and (not e.IsNull) then begin
      //we have received a raw tx. check if
      //1. we have an UTXO spent in it. delete our tx
      //2. we have a new UTXO (chech the receiver address)
      if fMempoolTXIDLlst=nil then exit;
      try
        i:=fMempoolTXIDLlst.IndexOf(reverse(dosha256(dosha256(hexToBuf(e.asString)))));
      except
        exit;
      end;
      if i>=0 then
        fMempoolTXIDLlst[i]:=hexToBuf(e.asString);
      internalUpdate;
    end;
   end;
  end;

end;



function tUTXOList.update(eapiNotify:tEmerAPINotification):boolean;
begin
  addNotify(eapiNotify);

  result:=true;
  if not updateBlockchain then result:=false;
  if not updateMempool then result:=false;
end;

function tUTXOList.giveToSpend(value:qword;lTxExclude:tStringList=nil;canUseMempool:boolean=true;optimization:tUTXOOptimization=uxoSaveCoinDaysOptimized):tList; //returns UTXO list to spend

type
  tfrec=record
     utxo:tUTXO;
     cost:qword;
  end;
var
  ar:array of tfrec;
  i:integer;

  procedure sortAr;
  type
    pel=^tel;
    tel=record
       l,r:pel;
       data:tfrec;
    end;
    procedure addToTree(root:pel;data:tfrec);
    begin
      if ((uxoSaveCoinDaysOptimized=UTXOOptimization) and (data.cost<root^.data.cost))  //first spend less- coindays
         or
         ((uxoMinimizeUtxoCount=UTXOOptimization) and (data.utxo.value<root^.data.utxo.value)) //first spent small TX for less-tx
        then if root^.l=nil then begin
               new(root^.l); fillchar(root^.l^,sizeOf(root^.l^),0); root^.l^.data:=data;
             end else
                addToTree(root^.l,data)
        else  if root^.r=nil then begin
               new(root^.r); fillchar(root^.r^,sizeOf(root^.r^),0); root^.r^.data:=data;
             end else
                addToTree(root^.r,data);
    end;
    var n:integer;
    procedure pullTree(root:pel); //l->root->r
    begin
      if root^.l<>nil then pullTree(root^.l);
      ar[n]:=root^.data; inc(n);
      if root^.r<>nil then pullTree(root^.r);
      dispose(root);
    end;
  var i:integer;
      tree:pel;
  begin
    new(tree); fillchar(tree^,sizeOf(tree^),0); tree^.data:=ar[0];
    for i:=1 to length(ar)-1 do
       addToTree(tree,ar[i]);
    n:=0;
    pullTree(tree); //l->root->r
  end;


  var
  bestAr,curAr:array of tfrec; curN,bestN,bestC:qword; tcount:integer;
  procedure createSpendPool(n:integer;v,c:qword);
  var myCurN,i:integer;
  begin //starting from ar[n], spend v, current cost c
    //work with ar[n]
    if (uxoSpendRandom=UTXOOptimization) and (bestN>0) then exit; //for random: stop finding if found
    if tcount=0 then exit else dec(tcount);
    myCurN:=CurN;
    curAr[curN]:=ar[n];
    if (v+ar[n].utxo.value)>value then begin
      //line finished
      if (c+ar[n].cost)<bestC then begin
        bestN:=curN; bestC:=c+ar[n].cost;
        for i:=0 to curN do bestAr[i]:= curAr[i];
      end;
    end else
    if n<(length(ar)-1) then
      begin
        //continue finding adding this element
        curN:=curN+1;
        createSpendPool(n+1,v+ar[n].utxo.value,c+ar[n].cost);
      end;
    //continue finding NOT adding this element
    curN:=myCurN;
    if n<(length(ar)-1) then createSpendPool(n+1,v,c);
  end;
  var nc:integer;
begin
  result:=tList.create;
  //keepAmountThreshold - ниже этого не храним транзакции
  //UTXOOptimization - режим
  //tUTXOOptimization=(uxoSaveCoinDaysOptimized,uxoMinimizeUtxoCount,uxoSpendRandom); //Save coin/days /  Minimize TX count in the wallet / Spend random

  if fUTXOList.count=0 then exit;

  setLength(ar,fUTXOList.count);
  nc:=0;
  for i:=0 to fUTXOList.count-1 do
    if (tUTXO(fUTXOList.Objects[i]).isSpendable) and ((lTxExclude=nil) or (lTxExclude.IndexOf(tUTXO(fUTXOList.Objects[i]).ftxid)<0)) then
    begin
      ar[nc].utxo:=tUTXO(fUTXOList.Objects[i]);
      case UTXOOptimization of
        uxoSaveCoinDaysOptimized:ar[i].cost:=(tUTXO(fUTXOList.Objects[i]).value*(blockChain.Height -tUTXO(fUTXOList.Objects[i]).Height)) div 1000000;
        uxoMinimizeUtxoCount:ar[i].cost:=1;
        uxoSpendRandom:ar[i].cost:=tUTXO(fUTXOList.Objects[i]).value;
      end;
      inc(nc);
    end;

  if nc<1 then exit;//nothing to spend
  setLength(ar,nc);

  //собираем список транзакций, закрывающий v , с минимальной cost
  //сначала отсортируем список для того, что бы при раннем прекращении поиска решение было лучше.
  if UTXOOptimization<>uxoSpendRandom then
    sortAr;
  //выбираем оптимальноъ
  setLength(bestAr,length(ar));
  setLength(curAr,length(ar));
  bestC:=-1; tcount:=10000; bestN:=0; curN:=0;
  createSpendPool(0,0,0);
  //the best pool found in bestAr with the cost bestC
  if bestC=qword(-1) then exit; //there is no any
  for i:=0 to bestN do
     result.Add(bestAr[i].utxo);
end;

function tUTXOList.getCount:integer;
begin
   result:=fUTXOList.count;
end;

function tUTXOList.getItem(Index:integer):tUTXO;
begin
   if (Index<0) or (Index>=fUTXOList.count) then
     raise exception.Create('tUTXOList.getItem: index out of bounds');
   result:=tUTXO(fUTXOList.Objects[Index]);
end;


procedure tUTXOList.deleteUTXO(txid:ansistring;nOut:integer); //used if spent
var i:integer;
begin
  //raise exception.Create('tUTXOList.deleteUTXO : function is not implemented');
  for i:=0 to fUTXOList.count-1 do
    if (tUTXO(fUTXOList.Objects[i]).txid=txid) and (tUTXO(fUTXOList.Objects[i]).nOut=nOut) then
    begin
      fUTXOList.Delete(i);
      exit;
    end;

end;

function tUTXOList.findUTXO(txid:ansistring;n:integer):tUTXO;
var i:integer;
begin
  result:=nil;
  i:=fUTXOlist.IndexOf(chr(n div 256)+chr(n mod 256)+txid);
  if i>=0 then result:=tUTXO(fUTXOlist.objects[i]);

end;

function tUTXOList.findName(NVSname:ansistring):tUTXO;
var i:integer;
    nameScript:tNameScript;
begin
 result:=nil;
 for i:=0 to fUTXOlist.Count-1 do begin
   if tUTXO(fUTXOlist.objects[i]).getNVSName=NVSname then begin
       result:=tUTXO(fUTXOlist.objects[i]);
       exit;
     end;
  { nameScript:=nameScriptDecode(tUTXO(fUTXOlist.objects[i]).Script);
   if nameScript.TXtype in [#$51,#$52] then
     if nameScript.Name=NVSname then begin
       result:=tUTXO(fUTXOlist.objects[i]);
       exit;
     end;
   }
 end;

end;

function tUTXOList.addUTXO(txid:ansistring;n:integer;scriptToSign:ansistring;value:qword;height:qword):tUTXO;
var utxo:tUTXO;
begin
 result:=findUTXO(txid,n);
 if result<>nil then exit;

 utxo:=tUTXO.create(
   self
   ,txid
   ,n
   ,scriptToSign
   ,value
   ,height
 );
 fUTXOlist.AddObject(chr(n div 256)+chr(n mod 256)+txid,utxo);

end;

constructor tUTXOList.create(mEmerAPIConnector:TEmerAPIBlockchainProto;mBlockChain:TBlockchain;addresses:tStringList=nil); //overload;
begin
  inherited create;
  fAddresses:=addresses;
  if fAddresses=nil then fAddresses:=tStringList.Create;
  fUTXOlist:=tStringList.Create;
  fUTXOlist.CaseSensitive:=true;
  fblockChain:=mblockChain;
  fEmerAPIConnector:=mEmerAPIConnector;

  //fLateUpdateTime:=0;
end;

constructor tUTXOList.create(mEmerAPIConnector:TEmerAPIBlockchainProto;mBlockChain:TBlockchain;address:ansistring); //overload;
var l:tStringList;
begin
  l:=tStringList.Create;
  l.Add(address);
  self:=tUTXOList.create(mEmerAPIConnector,mblockChain,l);
end;

destructor tUTXOList.destroy;

begin
{  for i:=0 to fUTXOlist.Count-1 do
    tUTXO(fUTXOlist.Objects[i]).free;
 }
 setAddresses(nil);
 fUTXOlist.free;
 fAddresses.Free;

  if jsLastscantxoutset<>nil then freeandnil(jsLastscantxoutset);
  //if jsLastgetrawmempool<>nil then freeandnil(jsLastgetrawmempool);

  if fMempoolTXIDLlst<>nil then freeandnil(fMempoolTXIDLlst);


  inherited destroy;
end;

function tUTXOList.hasAddress(address:ansistring):boolean;
var adr:ansistring;
    i:integer;
begin
  result:=false;
  adr:=addressto20(address);
  for i:=0 to faddresses.Count-1 do
    if adr=addressto20(faddresses[i]) then begin
      result:=true;
      exit;
    end;
end;

function tUTXOList.hasAddress(addresses:tStringList):boolean; //THE SAME
var i:integer;
begin
  result:=false;
  if addresses=nil then exit;
  if addresses.Count<>fAddresses.Count then exit;

  for i:=0 to addresses.Count-1 do
    if not hasAddress(addresses[i]) then exit;

  result:=true;
end;


function tUTXOList.getStat:tUTXOListStat;
var i:integer;
begin
 fillchar(result,sizeof(result),0);
 if fEmerAPIConnector=nil then exit;
{
   tUTXOListStat=record
     spendable:qword;
     spendableInMemPool:qword;
     spendableLockedInMemPool:qword;
     nameCount:integer;
     utxoCount:integer;

     lastUpdateTime:tDateTime;
  end;
}

 for i:=0 to fUTXOlist.Count-1 do begin
   if tUTXO(fUTXOlist.Objects[i]).isSpendable then begin
     result.spendable:=result.spendable +
        tUTXO(fUTXOlist.Objects[i]).fvalue;
     result.utxoCount:=result.utxoCount+1;
   end;
   if tUTXO(fUTXOlist.Objects[i]).isName then begin

     //if tUTXO(fUTXOlist.Objects[i]).isValidName then begin
       result.nameCount:=result.nameCount+1;
       if fBlockchain<>nil then
         result.spendableinNames:=result.spendableinNames+max(0,tUTXO(fUTXOlist.Objects[i]).value-fBlockchain.MIN_TX_FEE);
     //end;
   end;
 end;

 result.lastUpdateTime:=min(fLastUpdateTimeTX,fLastUpdateTimePool)

end;

procedure tUTXOList.clearUTXO();
var i:integer;
begin
  //if fUTXOlist=nil then exit;
  for i:=0 to fUTXOlist.Count-1 do
    tUTXO(fUTXOlist.Objects[i]).free;
    //freeandnil(tUTXO(fUTXOlist.Objects[i]));
  fUTXOlist.Clear;
end;

procedure tUTXOList.setAddresses(newAddresses:tStringList);
var i:integer;
begin
  //if the same then exit;
  if newAddresses<>nil then
    if newAddresses.Count=fAddresses.Count then
      for i:=0 to newAddresses.Count-1 do
        if fAddresses.IndexOf(newAddresses[i])<0
         then break
         else if (i=newAddresses.Count-1) then exit;

  fAddresses.Clear;

  clearUTXO();
  if newAddresses=nil then exit;
  fAddresses.Assign(newAddresses);

  updateBlockchain;

end;

function tUTXOList.updateBlockchain:boolean;
var i:integer; s:AnsiString;
begin
 result:=false;
 if fEmerAPIConnector=nil then exit;

 if jsLastscantxoutset<>nil then freeandnil(jsLastscantxoutset);

 s:='';
 //{ "address" : "<address>" },
 for i:=0 to fAddresses.Count-1 do
   s:=s+'{ "address" : "'+fAddresses[i]+'" },';
 if length(s)>0 then delete(s,length(s),1);


 result:=EmerAPIConnector.sendWalletQueryAsync('scantxoutset',
      GetJSON('{"action":"start",scanobjects:['+s+']}')
   ,@onBlockchainData,'scantxoutset_'+fEmerAPIConnector.getNextID)<>nil;

end;

function tUTXOList.updateMempool():boolean;
begin
 result:=false;
 if fEmerAPIConnector=nil then exit;
 //if jsLastgetrawmempool<>nil then freeandnil(jsLastgetrawmempool);
 if fMempoolTXIDLlst<>nil then freeandnil(fMempoolTXIDLlst);

 //step 1. receiving mempool
 result:=fEmerAPIConnector.sendWalletQueryAsync('getrawmempool',
    nil  //GetJSON('{"action":"start",scanobjects:['+s+']}')
   ,@onBlockchainData,'getrawmempool_'+fEmerAPIConnector.getNextID)<>nil;


end;

{/tUTXOList}

end.

