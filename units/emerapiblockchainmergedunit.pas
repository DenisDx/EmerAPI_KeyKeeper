unit EmerAPIBlockchainMergedUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, EmerAPIBlockchainUnit, EmerAPIWalletUnit, EmerAPIServerUnit, fpjson;

type
tEmerAPIConnectorMerged= class(TEmerAPIBlockchainProto)
  private
    procedure setConnDataWallet(v:tWalletConnectionData);
    procedure setConnDataServer(v:tEmerApiServerSettings);
    function getConnDataWallet:tWalletConnectionData;
    function getconnDataServer:tEmerApiServerSettings;
    function getTestedOk:boolean;

    //handler proxy:
    procedure onAsyncQueryRawDoneHandler(sender:TEmerAPIBlockchainThread;result:string);
    procedure onAsyncQueryDoneHandler(sender:TEmerAPIBlockchainThread;result:tJsonData);
    procedure onBlockchainErrorHandler(sender:TEmerAPIBlockchainThread;error:string);
    //fonBeforeSend
    procedure onBeforeSendHandler(sender:TEmerAPIBlockchainThread;data:string);

  public
    useWallet,useServer:boolean;
    prefferWallet:boolean;
    walletAPI:tEmerApiLocalWallet;
    serverAPI:tEmerApiServer;
    property testedOk:boolean read getTestedOk;
    property connDataWallet:tWalletConnectionData read getConnDataWallet write setConnDataWallet;
    property connDataServer:tEmerApiServerSettings read getconnDataServer write setConnDataServer;
    constructor Create(wConnDataWallet:tWalletConnectionData;wConnDataServer:tEmerApiServerSettings); overload;
    destructor destroy(); override;
    //procedure sendQueryAsync(methodAndParams:ansistring;callBack:tonAsyncQueryDone=nil;id:string=''); overload; override;
    function sendQueryAsync(method:ansistring;params:tJSONData;callBack:tonAsyncQueryDone=nil;id:string='';forceRecheck:boolean=false):TEmerAPIBlockchainThread; overload; override; //returns ID
    function sendWalletQueryAsync(method:ansistring;params:tJSONData;callBack:tonAsyncQueryDone=nil;id:string='';forceRecheck:boolean=false):TEmerAPIBlockchainThread; override; //returns ID

    function checkConnectionSync:boolean; overload;

    procedure finalize; override;
end;

implementation

procedure tEmerAPIConnectorMerged.onAsyncQueryRawDoneHandler(sender:TEmerAPIBlockchainThread;result:string);
begin
  if assigned(onAsyncQueryRawDone) then
    onAsyncQueryRawDone(sender,result);
end;

procedure tEmerAPIConnectorMerged.onBeforeSendHandler(sender:TEmerAPIBlockchainThread;data:string);
begin
  if assigned(onBeforeSend) then
    onBeforeSend(sender,data);
end;

procedure tEmerAPIConnectorMerged.onAsyncQueryDoneHandler(sender:TEmerAPIBlockchainThread;result:tJsonData);
begin
  if assigned(onAsyncQueryDone) then
    onAsyncQueryDone(sender,result);

end;

procedure tEmerAPIConnectorMerged.onBlockchainErrorHandler(sender:TEmerAPIBlockchainThread;error:string);
begin
  if assigned(onBlockchainError) then
    onBlockchainError(sender,error);

end;

function tEmerAPIConnectorMerged.getTestedOk:boolean;
begin
  result:=useWallet or useServer;
  if useWallet then result:=result and walletAPI.testedOk;
  if useServer then result:=serverAPI.testedOk or result;

  //result:= (useWallet and walletAPI.testedOk) or (useServer and serverAPI.testedOk);
end;

function tEmerAPIConnectorMerged.checkConnectionSync:boolean; overload;
var b:boolean;
begin

  result:=walletAPI.checkConnectionSync;
  b:= serverAPI.checkConnectionSync;
  result:= result or b;
end;

function tEmerAPIConnectorMerged.sendWalletQueryAsync(method:ansistring;params:tJSONData;callBack:tonAsyncQueryDone=nil;id:string='';forceRecheck:boolean=false):TEmerAPIBlockchainThread; //returns ID
begin
  result:=nil;
  //check if ok
  if useWallet then
    if (not walletAPI.testedOk) then walletAPI.checkConnection(forceRecheck);


  if useServer then if (serverAPI.testedOk) then serverAPI.checkConnection(forceRecheck);

  if useWallet and walletAPI.testedOk and (prefferWallet or (not useServer) or (not serverAPI.testedOk)) then
    result:=walletAPI.sendWalletQueryAsync(method,params,callBack,id,forceRecheck)
  else if useServer and serverAPI.testedOk then
    result:=serverAPI.sendWalletQueryAsync(method,params,callBack,id,forceRecheck)
  else //can't request
    ;//lastError:='tEmerAPIBlockchainMerged.sendQueryAsync: not connected or enabled';
end;

function tEmerAPIConnectorMerged.sendQueryAsync(method:ansistring;params:tJSONData;callBack:tonAsyncQueryDone=nil;id:string='';forceRecheck:boolean=false):TEmerAPIBlockchainThread;
begin

   result:=nil;
   //check if ok
   if useServer then if (serverAPI.testedOk) then serverAPI.checkConnection(forceRecheck);

  //! if (lowercase(method)='query') or  (lowercase(method)='mutation') then begin
   if not (
        (pos(' ',method+' ')<pos('query',lowercase(method+' '))) and (pos(' ',method+' ')<pos('mutation',lowercase(method+' ')))
        and
        (pos('(',method+'(')<pos('query',lowercase(method+'('))) and (pos('(',method+'(')<pos('mutation',lowercase(method+'(')))
       )
   then begin
     if useServer and serverAPI.testedOk then
       result:=serverAPI.sendQueryAsync(method,params,callBack,id,forceRecheck);
     exit;
   end;

   if useWallet then if (not walletAPI.testedOk) then walletAPI.checkConnection(forceRecheck);


   if useWallet and walletAPI.testedOk and (prefferWallet or (not useServer) or (not serverAPI.testedOk)) then
     result:=walletAPI.sendQueryAsync(method,params,callBack,id,forceRecheck)
   else if useServer and serverAPI.testedOk then
     result:=serverAPI.sendQueryAsync(method,params,callBack,id,forceRecheck)
   else //can't request
     ;//raise exception.Create('tEmerAPIBlockchainMerged.sendQueryAsync: not connected or enabled');

end;

procedure tEmerAPIConnectorMerged.setConnDataWallet(v:tWalletConnectionData);
begin
  if walletAPI=nil then begin
    walletAPI:=tEmerApiLocalWallet.create(v);
    walletAPI.onAsyncQueryRawDone:=@onAsyncQueryRawDoneHandler;
    walletAPI.onAsyncQueryDone:=@onAsyncQueryDoneHandler;
    walletAPI.onBlockchainError:=@onBlockchainErrorHandler;
    walletAPI.onBeforeSend:=@onBeforeSendHandler;
  end else
    walletAPI.connData:=v;
end;

procedure tEmerAPIConnectorMerged.setConnDataServer(v:tEmerApiServerSettings);
begin
  if serverAPI=nil then begin
    serverAPI:=tEmerApiServer.create(v);
    serverAPI.onAsyncQueryRawDone:=@onAsyncQueryRawDoneHandler;
    serverAPI.onAsyncQueryDone:=@onAsyncQueryDoneHandler;
    serverAPI.onBlockchainError:=@onBlockchainErrorHandler;
    serverAPI.onBeforeSend:=@onBeforeSendHandler;

  end else
    serverAPI.connData:=v;
end;

function tEmerAPIConnectorMerged.getConnDataWallet:tWalletConnectionData;
begin
 result:=walletAPI.connData;
end;

function tEmerAPIConnectorMerged.getconnDataServer:tEmerApiServerSettings;
begin
  result:=serverAPI.connData;
end;

constructor tEmerAPIConnectorMerged.Create(wConnDataWallet:tWalletConnectionData;wConnDataServer:tEmerApiServerSettings);
begin
  inherited create();
  setConnDataWallet(wConnDataWallet);
  setConnDataServer(wConnDataServer)
end;

destructor tEmerAPIConnectorMerged.destroy();
begin
  if not serverAPI.finalized then serverAPI.finalize;
  if not walletAPI.finalized then walletAPI.finalize;
  serverAPI.Free;
  walletAPI.Free;
  inherited;
end;

procedure tEmerAPIConnectorMerged.finalize;
begin
  ServerAPI.finalize;
  walletAPI.finalize;
end;

end.

