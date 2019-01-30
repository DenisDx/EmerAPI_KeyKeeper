unit MemPoolUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils //, EmerAPIMain
  ,emerapitypes, EmerAPIBlockchainUnit, fpjson, jsonparser
  ,BaseTXUnit  //instead of NVSRecordUnit
  //low=level API
  ,BlockchainUnit
  ,EmerTX
  ;


type
//Notifications:
//update :after any change
//error : after any error
tMempool=class(tEmerApiNotified)
  private
    fEmerApiConnector:TEmerAPIBlockchainProto;
    tBlockChain:tBlockChain;
    fTXlist:tStringList;// TXID or TX body resolved
    fLastUpdateTime:tDateTime;
    fNeedLoadTX:boolean;
    procedure clearTXList;

    function GetItem(index : Integer):tbaseTX;
  protected
    procedure onBlockchainData(sender:TEmerAPIBlockchainThread;result:tJsonData);
  public
    lastError:string;

    function Count:integer;
    property Items[index : Integer] : tbaseTX read GetItem; default; //nil if not resolved
    property LastUpdateTime:tDateTime read fLastUpdateTime;

    procedure updateCalled(sender:tObject);

    procedure update(eapiNotify:tEmerAPINotification; forceUpdate:boolean=false);overload;
    procedure update;overload;
    function findName(NVSname:ansistring):tbaseTXO;//:tNVSRecord; //finding LAST tx with the name. Returns tTXO object or nil. DO NOT free it
    function indexOf(txid:ansistring):integer;
    //function indexOfName(NVSname:ansistring):integer;
    constructor create(mEmerAPIConnector:TEmerAPIBlockchainProto;mBlockChain:TBlockchain;mNeedLoadTX:boolean=true);
    destructor destroy; override;
end;

implementation

uses crypto, CryptoLib4PascalConnectorUnit;

procedure tMempool.updateCalled(sender:tObject);
begin
  fEmerApiConnector.sendWalletQueryAsync('getrawmempool',
   nil  //GetJSON('{"action":"start",scanobjects:['+s+']}')
  ,@onBlockchainData,'getrawmempool_'+fEmerApiConnector.getNextID);
end;


procedure tMempool.update(eapiNotify:tEmerAPINotification; forceUpdate:boolean=false);
begin
  addNotify(eapiNotify);
  updateCalled(nil);
end;

procedure tMempool.update;
begin
  updateCalled(nil);
end;

function tMempool.Count:integer;
begin
  result:=fTXlist.Count;
end;

function tMempool.GetItem(index : Integer):tbaseTX;
begin
  //nil is fopp
  if (index<0) or (index>=fTXlist.Count) then raise exception.Create('tMempool.GetItem: index out of bounds');
  result:=tBaseTX(fTXlist.Objects[index]);
end;

function tMempool.findName(NVSname:ansistring):tbaseTXO; //finding LAST tx with the name. Returns tNVSRecord object or nil
var n:integer;
    bestTime:dword;
    tn:tbaseTXO;
begin
  result:=nil;
  bestTime:=0;
  for n:=0 to fTXlist.Count-1 do
    if items[n]<>nil then begin
       tn:=items[n].findNameOut(NVSname);
       if tn<>nil then
          if items[n].Time>=bestTime then
          begin
            bestTime:=items[n].Time;
            result:=tn;
          end;
    end;
end;

function tMempool.indexOf(txid:ansistring):integer;
var n:integer;
begin
  result:=fTXlist.IndexOf(uppercase(txid));
end;

{
function tMempool.indexOfName(NVSname:ansistring):integer;
var n:integer;
begin
  result:=-1;
  for n:=0 to fTXlist.Count-1 do
    if items[n]<>nil then begin
       result:=items[n].findName
       if items[n].isName then
          if items[n].getNVSName=NVSname then begin
            result:=n;
            exit;
          end;
    end;
end;
}


procedure tMempool.onBlockchainData(sender:TEmerAPIBlockchainThread;result:tJsonData);
var js,e:tJsonData;
    //s:string;
    //x:double;
    i,n,m:integer;
    //st:ansistring;
    l:tStringList;
    //tx:ttx;
    f:boolean;
    //NameScript:tNameScript;
begin
  if result=nil then begin
   lastError:=sender.lastError;
   callNotify('error');
   exit;
 end;



  js:=result;
  if pos('getrawmempool_',sender.id+'_')=1 then begin
   if js<>nil then begin
    e:=js.FindPath('result');
    if (e<>nil) then begin
      fLastUpdateTime:=now;
      if (not e.IsNull) then begin
         //If some transanction was dissapeared, we must rebild all

        l:=tStringList.Create;
        try
          for i:=0 to tJSONArray(e).Count-1 do
            l.Append(UPPERCASE(tJSONArray(e)[i].AsString));
          // need cleaning?
          for n:=0 to fTXlist.Count-1 do
            if l.IndexOf(fTXlist[n])<0 then begin
              clearTXList;
              break;
            end;

          for i:=0 to l.Count-1 do begin
            if fTXlist.IndexOf(l[i])<0 then
            begin
               fTXlist.AddObject(l[i],nil);
               //step 2. receiving all tx from the mempool
               if fNeedLoadTX then
                 if fEmerAPIConnector<>nil then
                   fEmerAPIConnector.sendWalletQueryAsync('getrawtransaction',
                     getJSON('{txid:"'+l[i]+'"}')
                    ,@onBlockchainData,'getrawtransactionPull_'+fEmerAPIConnector.getNextID);

            end;
          end;

          if l.Count=0 then callNotify('update');

        finally
          l.Free;
        end;
      end else begin lastError:='mempool: result not found in '+result.AsJSON; callNotify('error'); end;
    end;
   end;
  end else
  if pos('getrawtransactionPull_',sender.id)=1 then begin
   if (js<>nil) then begin
    e:=js.FindPath('result');
    if (e<>nil) and (not e.IsNull) then begin
      //we have received a raw tx.
      n:=fTXlist.IndexOf(UPPERCASE(bufToHex(reverse(dosha256(dosha256(hexToBuf(e.asString)))))));
      if n>=0 then begin
        if Items[n]<>nil then tBaseTX(fTXlist.Objects[n]).Free;
        fTXlist.Objects[n]:=tBaseTX.create(hexToBuf(e.asString));
      end;
    end;
   end;
  end;

  //call callNotify('update') if all tx are updated
  f:=true;
  for n:=0 to fTXlist.Count-1 do
    if Items[n]=nil then begin
      f:=false;
      break;
    end;
  if f then callNotify('update');

end;


procedure tMempool.clearTXList;
var i:integer;
begin
  for i:=0 to fTXlist.Count-1 do
    if fTXlist.Objects[i]<>nil then
      tBaseTX(fTXlist.Objects[i]).free;
  fTXlist.Clear;
end;

destructor tMempool.destroy;
begin
  clearTXList;
  fTXlist.Free;
  inherited;
end;

constructor tMempool.create(mEmerAPIConnector:TEmerAPIBlockchainProto;mBlockChain:TBlockchain;mNeedLoadTX:boolean=true);
begin
  //cleanGrid;
  inherited create;

  fNeedLoadTX:=mNeedLoadTX;

  //updateCalled(nil);
  fTXlist:=tStringList.Create;

  fEmerApiConnector:=mEmerAPIConnector;
  tBlockChain:=mBlockChain;


end;

end.

