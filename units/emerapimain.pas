unit EmerAPIMain;

{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, Crypto, fpjson, jsonparser,
  EmerAPIBlockchainMergedUnit, EmerAPIBlockchainUnit, EmerAPIServerUnit, EmerAPIWalletUnit, UTXOunit, emerapitypes, EmerTX, BlockchainUnit, MemPoolUnit;



type

// tEmerAPI notify list:
// 'update' : after BC info updated
 tEmerAPI = class(tEmerApiNotified)
 private
   fWaitingForupdateUTXO:boolean;
   fWaitingForgetblockchaininfo:boolean;
   fWaitingforUpdateMempool:boolean;

 public
   blockChain:tBlockChain;
   EmerAPIConnetor:tEmerAPIConnectorMerged;
   UTXOList:tUTXOList;
   mempool:tMempool;
   addresses:tStringList;

   function isReady:boolean;

   constructor Create(wConnDataWallet:tWalletConnectionData;wConnDataServer:tEmerApiServerSettings;mNetwork:string='';mWifID:char=#0;mAddressSig:char=#0);
   destructor destroy;

   procedure finalize;
   procedure setAddresses(newAddresses:tStringList);
   procedure setAddress(address:ansistring);
   function update(eapiNotify:tEmerAPINotification):boolean;

   procedure onNotify(sender:tObject);

   //service functions
   function isMyAddress(address:ansistring):boolean; //supports 20,21, code58
 end;


implementation

uses HelperUnit, math {, LazUTF8SysUtils};







{tEmerAPI}
function tEmerAPI.isReady:boolean;
begin
  result:=
     (not fWaitingForupdateUTXO)
     and
     (not fWaitingForgetblockchaininfo)
     and
     (not fWaitingforUpdateMempool)
     and ((EmerAPIConnetor<>nil) and EmerAPIConnetor.testedOk)
     and (BlockChain.isReady)
end;

procedure tEmerAPI.setAddresses(newAddresses:tStringList);
begin
  UTXOList.setAddresses(newAddresses);
  addresses.Assign(newAddresses);
end;



procedure tEmerAPI.setAddress(address:ansistring);
var l:tStringList;
begin
  if blockchain=nil then
     raise exception.Create('tEmerAPI.setAddress: you must set up blockchain first ');
  if not blockchain.addressIsValid(address) then
    raise exception.Create('tEmerAPI.setAddress: address is invalid or wrong network: '+address);

  l:=tStringList.Create;
  try
    l.Append(address);
    setAddresses(l);
  finally
    l.free;
  end;
end;

function tEmerAPI.isMyAddress(address:ansistring):boolean; //supports 20,21, code58
var adr:ansistring;
    i:integer;
begin
  result:=false;
  adr:=addressto20(address);
  for i:=0 to addresses.Count-1 do
    if adr=addressto20(addresses[i]) then begin
      result:=true;
      exit;
    end;

end;

procedure tEmerAPI.onNotify(sender:tObject);
begin
 //waiting for both UTXOList and BlockChain are updated. Call proc after
 //UTXOList.'updateUTXO' BlockChain.'getblockchaininfo'
 //call 'update' notication after

 fWaitingForupdateUTXO:=fWaitingForupdateUTXO and  (not (sender is tUTXOList));
 fWaitingForgetblockchaininfo:=fWaitingForgetblockchaininfo and (not (sender is tBlockChain));

 fWaitingforUpdateMempool:=fWaitingforUpdateMempool and (not (sender is tMemPool));

 if not (fWaitingForupdateUTXO or fWaitingForgetblockchaininfo or fWaitingforUpdateMempool) then
   callNotify('update');



end;

function tEmerAPI.update(eapiNotify:tEmerAPINotification):boolean;
begin
   //notificatiob must be called when ALL requests done.
   addNotify(eapiNotify);

   eapiNotify.proc:=@onNotify;

   fWaitingForupdateUTXO:=true;
   fWaitingForgetblockchaininfo:=true;
   fWaitingforUpdateMempool:=true;

   result:=true;

   eapiNotify.tag:='updateUTXO';
   if not UTXOList.update(eapiNotify) then result:=false;

   eapiNotify.tag:='getblockchaininfo';
   if not BlockChain.update(eapiNotify) then result:=false;

   eapiNotify.tag:='update';
   if not Mempool.update(eapiNotify) then result:=false;


end;

constructor tEmerAPI.Create(wConnDataWallet:tWalletConnectionData;wConnDataServer:tEmerApiServerSettings;mNetwork:string='';mWifID:char=#0;mAddressSig:char=#0);
begin
  inherited create();
  EmerAPIConnetor:=tEmerAPIConnectorMerged.Create(wConnDataWallet,wConnDataServer);
  blockChain:=tblockChain.Create(EmerAPIConnetor,mNetwork,mWifID,mAddressSig);
  UTXOList:=tUTXOList.create(EmerAPIConnetor,blockChain);
  mempool:=tMempool.create(EmerAPIConnetor,blockChain);

  UTXOList.addNotify(EmerAPINotification(@(mempool.updateCalled),'updateUTXO',true)) ;

  addresses:=tStringList.Create;
end;

procedure tEmerAPI.finalize;
begin
  if EmerAPIConnetor<>nil then
    EmerAPIConnetor.finalize;
end;

destructor tEmerAPI.destroy;
begin
  freeandnil(EmerAPIConnetor);
  freeandnil(blockChain);
  freeandnil(mempool);
  freeandnil(UTXOList);
  freeandnil(addresses);
  inherited;
end;

end.

