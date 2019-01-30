unit EmerAPIBlockchainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil,fpjson, jsonparser, forms
  {$ifdef unix}
  ,cthreads
  ,cmem // the c memory manager is on some systems much faster for multi-threading
  {$endif}
  ;

type

  tdoSyncCallProc=procedure(pdata:pointer) of object;

  tEmerAPIBlockchainStatus=(ebsUnknown,ebsReady,ebsNeedPreparation,ebsInPreparation,ebsNeedFinalization,ebsInFinalization,ebsError);
  //ebsUnknown: unknow status. Preparation needed
  //ebsReady: Ready to perform orders  .Tasks will be queued and started
  //ebsNeedPreparation: preparation procedures need to be called (login , etc). Queue will be created but not runned until Thread with preaparion flag done. New tasks will be queues but not runned
  //    preparation will be runned automaticaly if autoRunPrep set.
  //ebsInPreparation: preparation in process
  //ebsError: error happened. Can't perform queries or make preparation. New task will be rejected
  //ebsNeedFinalization,ebsInFinalization need to finishing session.
  //queue must be cleaned on ebsNeedFinalization,ebsInFinalization,ebsError ?

  tEmerAPIBlockchainThreadType=(ebtNormal,ebtPreparation,ebtFinalization);


  //params is tJSONData object. It will be destroyed by thread, so, don't need to free it.


  TEmerAPIBlockchainThread=class;

  tonAsyncQueryRawDone= procedure(sender:TEmerAPIBlockchainThread;result:string) of object; //called even have a error(result = nil  then)
  tonAsyncQueryDone= procedure(sender:TEmerAPIBlockchainThread;result:tJsonData) of object; //called even have a error(result = nil  then)
  tOnBlockchainError= procedure(sender:TEmerAPIBlockchainThread;error:string) of object; //called only if have error

  //base interface class
  TEmerAPIBlockchainProto = class(tObject)
    protected
      FOnConnect:TNotifyEvent; //Connection has been verified
      FOnDisconnect:TNotifyEvent; //Connection loss has been registered
      fonAsyncQueryRawDone:tonAsyncQueryRawDone; //just from thread
      fonAsyncQueryDone:tonAsyncQueryDone;
      fOnBlockchainError:tOnBlockchainError;
      fonBeforeSend:tonAsyncQueryRawDone;
      ftestedOk:boolean; //last attempt was successed
      fLastCheckConnectionTime:tDateTime;
      fLastID:integer;                           //last internal ID issued by
      flastError:string;
      fTimeOut:integer; //in seconds
      fEmerAPIBlockchainStatus:tEmerAPIBlockchainStatus;
      fcleanQueueOnError:boolean;
      fonFinalization:boolean;
      fFinalized:boolean;
      procedure setTestOk(v:boolean);
      //procedure asyncDoRawRequest(Thread:TEmerAPIBlockchainThread); Virtual; //Called by Thread in async mode.
      procedure checkStatus(forceRestore:boolean=false;syncMode:boolean=false); virtual;
          //Sets fEmerAPIBlockchainStatus . does all preparation and checking work if ncessesary
          //in the proto class just sets ebsReady
          //In child classes:
          //     ebsUnknown/ebsNeedPreparation -> (lunch login):ebsInPreparation -> ebsReady/ebsError
          // or  ebsUnknown/ebsNeedPreparation -> (test) -> ebsReady/ebsError
          // or  ebsUnknown/ebsNeedPreparation -> (lunch login):ebsInPreparation -> (test):ebsInPreparation -> ebsReady/ebsError

          // ibsInPreparation


          //tEmerAPIBlockchainStatus=(ebsUnknown,ebsReady,ebsNeedPreparation,ebsError);
          //ebsUnknown: unknow status. Preparation needed
          //ebsReady: Ready to perform orders  .Tasks will be queued and started
          //ebsNeedPreparation: preparation procedures need to be called (login , etc). Queue will be created but not runned until Thread with preaparion flag done. New tasks will be queues but not runned
          //    preparation will be runned automaticaly if autoRunPrep set.
          //ebsError: error happened. Can't perform queries or make preparation. New task will be rejected

      procedure setCleanQueueOnError(v:boolean); virtual; //children must override it if they need to clean queue
    public
      procedure finalize; virtual; abstract; //stop all threads

      property finalized:boolean read fFinalized;
      //connData:tWalletConnectionData;
      property EmerAPIBlockchainStatus:tEmerAPIBlockchainStatus read fEmerAPIBlockchainStatus;
      property lastError:ansistring read flastError;
      property testedOk:boolean read ftestedOk;
      property onConnect: TNotifyEvent read FOnConnect write FOnConnect;
      property onDisconnect: TNotifyEvent read FOnDisconnect write FOnDisconnect;
      property timeOut:integer read fTimeOut write fTimeOut;

      property cleanQueueOnError:boolean read fcleanQueueOnError write setCleanQueueOnError;

      //function prepate

      function getNextID:string; //fLastID
      function checkConnection(forceRecheck:boolean=false):TEmerAPIBlockchainThread; virtual;
      procedure checkConnCallBack(sender:TEmerAPIBlockchainThread;result:tJsonData); virtual;

      //async functions
      property onAsyncQueryRawDone:tonAsyncQueryRawDone read fonAsyncQueryRawDone write fonAsyncQueryRawDone;
      property onAsyncQueryDone:tonAsyncQueryDone read fonAsyncQueryDone write fonAsyncQueryDone;
      property onBlockchainError:tOnBlockchainError read fOnBlockchainError write fOnBlockchainError;
      property onBeforeSend:tonAsyncQueryRawDone read fonBeforeSend write fonBeforeSend;
      //procedure sendQueryAsync(methodAndParams:ansistring;callBack:tonAsyncQueryDone=nil;id:string=''); overload;
      function sendQueryAsync(method:ansistring;params:tJSONData;callBack:tonAsyncQueryDone=nil;id:string='';forceRecheck:boolean=false):TEmerAPIBlockchainThread; virtual; abstract;

      //call wallet commands. Must be defined in successor
      function sendWalletQueryAsync(method:ansistring;params:tJSONData;callBack:tonAsyncQueryDone=nil;id:string='';forceRecheck:boolean=false):TEmerAPIBlockchainThread; virtual;

      //sync requests
      function sendQuerySync(method:ansistring;params:tJSONData):tJsonData; virtual;abstract; //Better not to use it
      function requestString(method:ansistring;params:tJSONData;findString:string):string; //Better not to use it
      function checkConnectionSync(forceRecheck:boolean=false):boolean; virtual;//Better don't use it

      constructor Create(); //fTimeOut  Can remove
     //destructor destroy; override; //free fSyncQueue. if conut>0 then delete assignes JSON objects
  end;


  tEmerApiServerInterface = class (tObject)
    protected
  end;

  TEmerAPIBlockchain = class;
  //TEmerAPIBlockchainThread does not decode JSON, parent must do it. So, it just calls  tonAsyncQueryRawDone and tOnBlockchainError.. and OnTerminate, ofcs
  //Children must implement doRawRequest and add it owns connData
  //doRawRequest must call sync:  requestDone (set Result before) and syncError (set fError before ,or just use asyncError) ;
  TEmerAPIBlockchainThread = class(TThread)
  private
    //fonThreadHasData: procedure(data:string) of object;
    //fonAsyncQueryRawDone:tonAsyncQueryRawDone; CALL FROM OWNER
    fLastError:string;//async write
    fOwner:TEmerAPIBlockchain;

    //syncCall:
    fdoSyncCallData:pointer;
    fdoSyncCallProc:tdoSyncCallProc;

    procedure requestDone;  //sync!! call events
    //procedure beforeRequest; //sync!! sets fconnData
  protected

    procedure Execute; override;
    //function doRawRequest(q:ansistring):ansistring; virtual; //Child must implement it using it's own connection data
    //No! we will call owner's overriden method asyncDoRawRequest
  public
    EmerAPIBlockchainThreadType:tEmerAPIBlockchainThreadType;
    //for outer usage only:

    Result:ansistring; // set by parent in asyncDoRawRequest (async). uses in requestDone

    lastError:string; //sync read!

    callbackProc:tonAsyncQueryDone;
    id:string;
    method:ansistring;
    params:tJSONData;
    //inner:
    userData:pointer;
    //connData:tWalletConnectionData; //SYNC ACCESS <----must be implemented by children

    //syncCall:
    procedure doSyncCallSync; //calls proc(data) in sync in async mode
    procedure doSyncCall(proc:tdoSyncCallProc;data:pointer); //calls proc(data) in sync in async mode

    //property OnError:tOnWalletError read fOnError write fOnError;
    //property onAsyncQueryRawDone:tonAsyncQueryRawDone read fonAsyncQueryRawDone write fonAsyncQueryRawDone;
    Constructor Create(Owner:TEmerAPIBlockchain;CreateSuspended : boolean);
    destructor destroy; override; //destroy params
    procedure syncError; //sync on error. used in asyncDoRawRequest
    procedure asyncError(msg:string); //async on error used in asyncDoRawRequest
  end;


  //Children must define asyncDoRawRequest. It must
  //1. call sync:  requestDone (set Result before) and syncError (set fError before ,or just use asyncError) ;
  //2. request the data using connData

  //thread- based implementation
  TEmerAPIBlockchain = class(TEmerAPIBlockchainProto)
    private

    protected
      fTasksList:tStringList; //a list of TEmerAPIBlockchainThread objects added in sendRawQuerySync
      procedure checkForReadyToStart; virtual;
      procedure ThreadHasData(Thread:TEmerAPIBlockchainThread;var data:string); virtual;//a handler for thread onAsyncQueryRawDone. CALLED BY THREAD //caller must handle errors
      procedure ThreadError(Thread:TEmerAPIBlockchainThread;error:string); virtual; //CALLED BY THREAD //caller must handle errors //fOnBlockchainError call
      procedure ThreadTerminated(Sender:tObject); virtual; //TNotifyEvent //CALLED BY THREAD //remove it from the fTasksList
      procedure asyncDoRawRequest(Thread:TEmerAPIBlockchainThread); virtual;abstract; //Called by Thread in async mode. //CALLED BY THREAD //Must set Result if there is a result, can call asyncError(msg) in case of errors
      function createThread(method:ansistring;params:tJSONData;callBack:tonAsyncQueryDone=nil;id:string=''):TEmerAPIBlockchainThread; virtual;
      procedure finalize; override;
    public
      //async functions: need to be defined
      maxSimConn:integer;
      function sendQueryAsync(method:ansistring;params:tJSONData;callBack:tonAsyncQueryDone=nil;id:string='';forceRecheck:boolean=false):TEmerAPIBlockchainThread; override; //returns ID

      //sync requests
      function sendQuerySync(method:ansistring;params:tJSONData):tJsonData; virtual; //Better not to use it


      constructor create(); //we have to create fTasksList
      destructor destroy; override;//we have to empty and free fTasksList
  end;

//function createJSONFromStrings(sa: array of string)

implementation

uses  {sockets,}helperUnit;

function checkParam(s:ansistring):ansistring;
begin
  if length(s)=0 then s:='""' else
  if (pos('[',s)<1) and (pos('{',s)<1) and (pos('"',s)<1) and (pos('''',s)<1) then
    //if not a digit or bool then add quotes
    if (not (s[1] in ['+','-','0'..'9'])) and (trim(ansiuppercase(s))<>'TRUE') and (trim(ansiuppercase(s))<>'FALSE')
      then s:='"'+s+'"';
  result:=s;
end;


{TEmerAPIBlockchainThread}

constructor TEmerAPIBlockchainThread.Create(Owner:TEmerAPIBlockchain;CreateSuspended : boolean);
begin
  inherited Create(CreateSuspended); // because this is black box in OOP and can reset inherited to the opposite again...
  FreeOnTerminate := True;  // better code...
  fOwner:=Owner;
  Result:='';
  fLastError:='';
  EmerAPIBlockchainThreadType:=ebtNormal;
  userData:=nil;
end;

destructor TEmerAPIBlockchainThread.destroy; //destroy params
begin
  //if self=nil then exit;
  if params<>nil then params.free;
end;

{
procedure TEmerAPIBlockchainThread.StatusChanged(); //sync!!
// this method is executed by the mainthread and can therefore access all GUI elements.
begin
  fStatusSync:=fstatus;
  if assigned(fonStatusChanged) then fonStatusChanged(fstatus);
end;
}
{
procedure TWalletThread.requestDone; //sync!!!
var js:tJsonData;
    data:ansistring;
begin
  //called syncroniosly when the request has been done.
  //result is in the fLastData
  try
    if assigned(fCurrentTaskData.proc) then
      try
        data:=fLastData;
        data:=changeNone(data);
        js:=GetJSON(data);
        fCurrentTaskData.proc(self,js);
      finally
        fCurrentTaskData.proc:=nil;
        fCurrentTaskData.id:='';
        if js<> nil then js.Free;
      end;
    if assigned(fonThreadHasData) then
       fonThreadHasData(fLastData);
  except
    //we don't want to die even they create an exception
    on e:exception do try
      fLastError:=e.Message;
      syncError();
    except
    end;
  end;
  fLastData:='';

end;
}
{
procedure TEmerAPIBlockchainThread.beforeRequest; //sync!! sets fconnData
begin
  //fconnData:=connData;
end;
}


procedure TEmerAPIBlockchainThread.requestDone();
begin
  //request has been done. Perhaps it is a error, then send empty string as the result
  fOwner.ThreadHasData(self,Result);
end;

procedure TEmerAPIBlockchainThread.syncError(); //sync on error
begin
  //
  lastError:= fLastError;
  fOwner.ThreadError(self,fLastError);

end;

procedure TEmerAPIBlockchainThread.asyncError(msg:string); //async on error
begin
  fLastError:=msg;
  try
    Synchronize(@syncError);
  except
  end;
end;


procedure TEmerAPIBlockchainThread.doSyncCallSync; //calls proc(data) in sync in async mode
begin
  if assigned(fdoSyncCallProc) then fdoSyncCallProc(fdoSyncCallData);

end;

procedure TEmerAPIBlockchainThread.doSyncCall(proc:tdoSyncCallProc;data:pointer); //calls proc(data) in sync in async mode
begin
 fdoSyncCallData:=data;
 fdoSyncCallProc:=proc;
 Synchronize(@doSyncCallSync)
end;

{
procedure TWalletThread.setStatus(newStatus:TWalletThreadStatus);//async!!!
begin
  if fStatus=newStatus then exit;
  fStatus := newStatus;
  Synchronize(@StatusChanged);
end;
}
procedure TEmerAPIBlockchainThread.Execute;
begin
  if Terminated then exit;
  try
    fOwner.asyncDoRawRequest(self);
  except
    on e:exception do asyncError(e.message)
  end;
  if Terminated then exit;
  try
    Synchronize(@requestDone);
  except
    on e:exception do asyncError(e.message)
  end;

 { try
    setStatus(wtsWork);
    while (not Terminated) {and (fTasksList.count>0)} do
      if (fTasksList.count>0) then
      begin
        if fTasksList.Objects[0]<>nil then
          fCurrentTaskData:=pTaskData(fTasksList.Objects[0])^ //@tonAsyncQueryDone(pointer(fTasksList.Objects[0]));
        else
          fillchar(fCurrentTaskData,sizeof(fCurrentTaskData),0);
        try
          Synchronize(@beforeRequest);
          fLastData:=doRawRequest(fTasksList[0]);
        except
          fLastData:='';
        end;
        dispose(pTaskData(fTasksList.Objects[0]));
        fTasksList.Delete(0);
        Synchronize(@requestDone);
      end else begin
         //idle
         setStatus(wtsIdle);
         sleep(50);
      end;
  finally
    setStatus(wtsTerminated);
  end;
  }
end;

{
function tWalletThread.doRawRequest(q:ansistring):ansistring;
var url:string;
    resp:TStringList;
    FormData:TStringList;
    mycookies:TStringList;
    client:TFPHTTPClient;
    ms:tMemoryStream;
begin
 try
  if fconnData.UseHTTPS then url:='https://' else url:='http://';

  if trim(fconnData.address) = '' then url:=url+'localhost' else url:=url+trim(fconnData.address);

  url:=url+':'+inttostr(fconnData.port);


  FormData:=TStringList.create;
  resp:=TStringList.create;
  mycookies:=TStringList.create;
  client:=TFPHTTPClient.Create(nil);
  try

    client.username := trim(fconnData.userName);
    client.password := trim(fconnData.userPass);

    client.AddHeader('Set-Type','application/json-rpc');

    ms:=tMemoryStream.Create;
    try
      ms.Write(q[1],length(q));
      ms.Position:=0;
      client.Requestbody:=ms;
      try
        client.Post(url,resp);
      except
        on e:exception do begin
          result:='';
          ftestOk:=false;
          asyncError(e.Message);
        end;
      end;
    finally
      ms.Free;
    end;

    {"jsonrpc":"1.0","id":"livetext","method":"getblockchaininfo","params":[]}
    {"jsonrpc": "1.0", "id":"curltest", "method":"scantxoutset","params":["start", [{"script" : "76A914CED2436C4D0169B69E8E71C413DC5C5B20F5376388AC" }]]}

    result:=resp.Text;
  finally
    client.Free;
    resp.free;
    mycookies.free;
  end;


 except
   on e:exception do
     asyncError(e.Message);
 end;
end;
}

{/TEmerAPIBlockchainThread}
//================================================================================================================================================================
{TEmerAPIBlockchainProto}
function TEmerAPIBlockchainProto.sendWalletQueryAsync(method:ansistring;params:tJSONData;callBack:tonAsyncQueryDone=nil;id:string='';forceRecheck:boolean=false):TEmerAPIBlockchainThread;
begin
  result:=sendQueryAsync(method,params,callBack,id,forceRecheck);
end;

procedure TEmerAPIBlockchainProto.checkConnCallBack(sender:TEmerAPIBlockchainThread;result:tJsonData);
var ok:boolean;
begin
  ok:=false;
  if result<>nil then
    ok:=result.FindPath('result.chain')<>nil;

  setTestOk(ok);
  fLastCheckConnectionTime:=now;
end;

function TEmerAPIBlockchainProto.checkConnection(forceRecheck:boolean=false):TEmerAPIBlockchainThread;
begin
  if forceRecheck or ((now - fLastCheckConnectionTime)*24*60*60>fTimeout)  then
     result:=sendWalletQueryAsync('getblockchaininfo',nil,@checkConnCallBack,'',forceRecheck);

end;

function TEmerAPIBlockchainProto.checkConnectionSync(forceRecheck:boolean=false):boolean;
begin
  //{"jsonrpc":"1.0","id":"curltext","method":"getinfo","params":[]}
  //'{"jsonrpc": "1.0", "id":"curltest", "method":"scantxoutset","params":["start", [{"script" : "76A914CED2436C4D0169B69E8E71C413DC5C5B20F5376388AC" }]]}'
  {"jsonrpc":"1.0","id":"curltext","method":"getblockchaininfo","params":[]}

  if forceRecheck or ((now - fLastCheckConnectionTime)*24*60*60>fTimeout) then begin
    result:=false;
    result:=requestString('getblockchaininfo',nil,'result.chain')<>'';
    setTestOk(result);
  end else result:=ftestedOk;
end;

function TEmerAPIBlockchainProto.requestString(method:ansistring;params:tJSONData;findString:string):string;
var js,e:tJsonData;
begin
  result:='';
  js:=sendQuerySync(method,params);
  if js<>nil then
  try
    e:=js.FindPath(findString);
    if e<>nil then
      result:=e.AsString;
  finally
    js.free;
  end;
end;

procedure TEmerAPIBlockchainProto.setCleanQueueOnError(v:boolean);//children must overload it if they need to clean queue
begin
  fCleanQueueOnError:=v;
end;

procedure TEmerAPIBlockchainProto.setTestOk(v:boolean);
begin
  if v=ftestedOk then exit;
  ftestedOk:=v;
  if ftestedOk and assigned(fOnConnect) then fonConnect(self)
  else
  if (not ftestedOk) and assigned(fOnDisconnect) then fOnDisconnect(self);
end;

procedure TEmerAPIBlockchainProto.checkStatus(forceRestore:boolean=false;syncMode:boolean=false);
    //Sets fEmerAPIBlockchainStatus . does all preparation and checking work if ncessesary
    //in the proto class just sets ebsReady
    //In child classes:
    //     ebsUnknown/ebsNeedPreparation -> (lunch login):ebsInPreparation -> ebsReady/ebsError
    // or  ebsUnknown/ebsNeedPreparation -> (test) -> ebsReady/ebsError
    // or  ebsUnknown/ebsNeedPreparation -> (lunch login):ebsInPreparation -> (test):ebsInPreparation -> ebsReady/ebsError

    // ibsInPreparation


    //tEmerAPIBlockchainStatus=(ebsUnknown,ebsReady,ebsNeedPreparation,ebsError);
    //ebsUnknown: unknow status. Preparation needed
    //ebsReady: Ready to perform orders  .Tasks will be queued and started
    //ebsNeedPreparation: preparation procedures need to be called (login , etc). Queue will be created but not runned until Thread with preaparion flag done. New tasks will be queues but not runned
    //    preparation will be runned automaticaly if autoRunPrep set.
    //ebsError: error happened. Can't perform queries or make preparation. New task will be rejected
begin
  fEmerAPIBlockchainStatus:=ebsReady;
end;

function TEmerAPIBlockchainProto.getNextID:string; //fLastID
begin
  inc(fLastID);
  result:='__'+inttostr(fLastID);
end;


function TEmerAPIBlockchain.sendQuerySync(method:ansistring;params:tJSONData):tJsonData;
var s:ansistring;
    id:ansistring;
    i:integer;
var
  tt:TEmerAPIBlockchainThread;
begin

  result:=nil;

  checkStatus(false,true);

  if fEmerAPIBlockchainStatus<>ebsReady then exit;

  tt:=createThread(method,params);

  //send asinc and wait
  (*
  tt:=TEmerAPIBlockchainThread.create(self,true);
  if Assigned(tt.FatalException) then
     raise tt.FatalException;

  dasd check if we can do : fEmerAPIBlockchainStatus:tEmerAPIBlockchainStatus  = estReady?
  tt.EmerAPIBlockchainThreadType:=???ebtPreparation;

  //tt.OnTerminate:=@ThreadTerminated;
  tt.id:=getNextID;
  //tt.callbackProc:=mySyncCallBackDone;
  tt.method:=method;
  setLength(tt.params,length(params));
  for i:=0 to length(params)-1 do
      tt.params[i]:=params[i];
  *)
  if params<>nil then method:=method+': '+params.asJson;
  if assigned(fonBeforeSend) then fonBeforeSend(tt,method);
  tt.Start;
  tt.FreeOnTerminate:=false; //we need to keeep it in sync mode to have an ability to obtain result
  try
    tt.WaitFor;
    if tt.Result<>'' then try
      s:=changeNone(tt.Result);
      result:=GetJSON(s);
    except
      on e:exception do fLastError:=e.message;
    end;
  finally
    if tt.Finished then tt.Free else tt.FreeOnTerminate:=true;
  end;
end;


constructor TEmerAPIBlockchainProto.Create();  //creates fSyncQueue  fTimeOut
begin
  inherited;
  //fSyncQueue:=tStringList.create;
  fTimeOut:=60; //default timeout 1 min
  fLastID:=0;
  fLastCheckConnectionTime:=0;
end;
(*
destructor TEmerAPIBlockchainProto.destroy; //free fSyncQueue. if conut>0 then delete assignes JSON objects
begin
  //while fSyncQueue.Count>0 do begin
 //   tJsonData(fSyncQueue.Objects[0]).Free;;
 //   fSyncQueue.Delete(0);
 // end;

 // freeAndNil(fSyncQueue);
  inherited;
end;
*)
{/TEmerAPIBlockchainProto}


{TEmerAPIBlockchain}
constructor TEmerAPIBlockchain.create(); //we have to create fTasksList
begin
  inherited;
{  connData.port:=wPort;
  connData.userName:=wUserName;
  connData.userPass:=wUserPass;
  connData.UseHTTPS:=wUseHTTPS;
  connData.address:=waddress;

! }
  maxSimConn:=1;
  fTasksList:=tStringList.Create;

end;


destructor TEmerAPIBlockchain.destroy;  //we have to empty and free fTasksList
var i:integer;
begin
  //a list of TEmerAPIBlockchainThread objects added in sendRawQuerySync

  //don't need to do it, I guess
  for i:=fTasksList.Count-1 downto 0 do
    if fTasksList.Objects[i]<>nil
      then TEmerAPIBlockchainThread(fTasksList.Objects[i]).Terminate;


  //I don't think we really need to wait them. Just check if fTasksList is nil and owner is nil?
  //let's avoid calling waitFor()

  freeAndNil(fTasksList);
  inherited;
end;


procedure TEmerAPIBlockchain.ThreadError(Thread:TEmerAPIBlockchainThread;error:string);
var i:integer;
begin
  //CALLED BY THREAD //caller must handle errors //fOnBlockchainError call
  //fLastError:=error;
  try //??
    setTestOk(false);
  except end;

  if assigned(fOnBlockchainError) then fOnBlockchainError(Thread,error);

  if (fCleanQueueOnError) and (fEmerAPIBlockchainStatus = ebsError) then
    for i:=0 to fTasksList.Count-1 do
      if (TEmerAPIBlockchainThread(fTasksList.Objects[i]).Suspended)
          then TEmerAPIBlockchainThread(fTasksList.Objects[i]).Terminate;

end;


procedure TEmerAPIBlockchain.checkForReadyToStart;
var i:integer;
    n:integer;
begin
 //resume awaiting threads
 if fonFinalization then begin
   for i:=0 to fTasksList.Count-1 do begin
    if (TEmerAPIBlockchainThread(fTasksList.Objects[i]).Suspended)
          then TEmerAPIBlockchainThread(fTasksList.Objects[i]).Resume;
     TEmerAPIBlockchainThread(fTasksList.Objects[i]).Terminate;
   end;
   exit;
 end;


 n:=0;

  for i:=0 to fTasksList.Count-1 do begin
   if n >= maxSimConn then exit;
   if (not TEmerAPIBlockchainThread(fTasksList.Objects[i]).Finished) then
     if ((fEmerAPIBlockchainStatus = ebsReady) and (TEmerAPIBlockchainThread(fTasksList.Objects[i]).EmerAPIBlockchainThreadType=ebtNormal))
         or
        ((fEmerAPIBlockchainStatus in [ebsNeedPreparation, ebsInPreparation]) and (TEmerAPIBlockchainThread(fTasksList.Objects[i]).EmerAPIBlockchainThreadType=ebtPreparation))
         or
        ((fEmerAPIBlockchainStatus in [ebsNeedFinalization, ebsInFinalization]) and (TEmerAPIBlockchainThread(fTasksList.Objects[i]).EmerAPIBlockchainThreadType=ebtFinalization))
        then begin
           if (TEmerAPIBlockchainThread(fTasksList.Objects[i]).Suspended)
              then TEmerAPIBlockchainThread(fTasksList.Objects[i]).Resume;
           inc(n);
        end;
     //calc

  end;

end;

procedure TEmerAPIBlockchain.ThreadTerminated(Sender:tObject);
begin

  //TNotifyEvent //CALLED BY THREAD //remove it from the fTasksList
  if not (Sender is TEmerAPIBlockchainThread) then raise exception.Create('TEmerAPIBlockchainThread.ThreadTerminated: internal error 1');

  if fTasksList.indexOf((Sender as TEmerAPIBlockchainThread).id)>=0 then
    fTasksList.delete(fTasksList.indexOf((Sender as TEmerAPIBlockchainThread).id));


 checkForReadyToStart;


end;



function TEmerAPIBlockchain.createThread(method:ansistring;params:tJSONData;callBack:tonAsyncQueryDone=nil;id:string=''):TEmerAPIBlockchainThread;
var
  tt:TEmerAPIBlockchainThread;
  i:integer;
begin
 result:=nil;
 tt:=TEmerAPIBlockchainThread.create(self,true);
 tt.params:=params;

 if Assigned(tt.FatalException) then
    raise tt.FatalException;

 tt.OnTerminate:=@ThreadTerminated;
 if id='' then tt.id:=getNextID else tt.id:=id;
 tt.callbackProc:=callBack;
 tt.method:=method;
 {
 setLength(tt.params,length(params));
 for i:=0 to length(params)-1 do
   tt.params[i]:=params[i];
 }


 result:=tt;
end;

procedure TEmerAPIBlockchain.finalize;
var t:tDateTime;
begin
 fonFinalization:=true;
 t:=now;
 checkForReadyToStart;
 while (fTasksList.Count>0) and  ((now - t)*60*24*60<100) do begin
    sleep(100);
    application.ProcessMessages;
 end;
 fFinalized:=true;
end;

function TEmerAPIBlockchain.sendQueryAsync(method:ansistring;params:tJSONData;callBack:tonAsyncQueryDone=nil;id:string='';forceRecheck:boolean=false):TEmerAPIBlockchainThread; //overrride!
//var s:ansistring;
//    i:integer;
var
  //tt:TEmerAPIBlockchainThread;
  i:integer;
begin
  if fonFinalization then exit;
  //create a TEmerAPIBlockchainThread object
  checkStatus(forceRecheck);

  result:=createThread(method,params,callBack,id);
  fTasksList.AddObject(result.id,result);

  if params<>nil then method:=method+': '+params.asJson;
  if assigned(fonBeforeSend) then fonBeforeSend(result,method);

  checkForReadyToStart;

end;
{
function tLocalWallet.sendQuerySync(methodAndParams:ansistring):tJsonData;
var s:ansistring;
begin
  if pos(',',methodAndParams)<1 then //it's single method
    //"method":"getblockchaininfo","params":[]
    methodAndParams:='"method":'+checkParam(methodAndParams)+',"params":[]';
  s:=sendRawQuerySync('{"jsonrpc":"1.0","id":"'+getNextID+'",'+methodAndParams+'}');
  s:=changeNone(s);
  result:=GetJSON(s);

end;
}

{
procedure tLocalWallet.sendQueryAsync(methodAndParams:ansistring;callBack:tonAsyncQueryDone=nil;id:string='');
var s:ansistring;
    var pt:PTaskData;
begin
  if id='' then id:=getNextID;

  if pos(',',methodAndParams)<1 then //it's single method
    methodAndParams:='"method":'+checkParam(methodAndParams)+',"params":[]';

  //addTaskToThread
  pt:=nil;
  if callBack<>nil then begin
    new(pt);
    pt^.id:=id;
    pt^.proc:=callBack;
  end;

  //also update fThread.connData. I don't want to make connData as a property
  fThread.connData:=connData;
  fThread.fTasksList.addObject('{"jsonrpc":"1.0","id":"livetext",'+methodAndParams+'}',tObject(pt));
  if fThread.status = wtsStopped then fThread.Start;

end;
}

{
function tLocalWallet.sendRawQuerySync(q:ansistring):ansistring; //Must be removed by tWalletThread.sendRawQuerySync
var url:string;
    resp:TStringList;
    FormData:TStringList;
    mycookies:TStringList;
    client:TFPHTTPClient;
    ms:tMemoryStream;
begin

  if connData.UseHTTPS then url:='https://' else url:='http://';

  if trim(connData.address) = '' then url:=url+'localhost' else url:=url+trim(connData.address);

  url:=url+':'+inttostr(connData.port);


  FormData:=TStringList.create;
  resp:=TStringList.create;
  mycookies:=TStringList.create;
  client:=TFPHTTPClient.Create(nil);
  try

    client.username := trim(connData.userName);
    client.password := trim(connData.userPass);

    client.AddHeader('Set-Type','application/json-rpc');

    ms:=tMemoryStream.Create;
    try
      ms.Write(q[1],length(q));
      ms.Position:=0;
      client.Requestbody:=ms;
      try
        client.Post(url,resp);
      except
        on e:exception do begin
          result:='';
          lastError:=e.Message;
          setTestOk(false);
        end;
      end;
    finally
      ms.Free;
    end;

    {"jsonrpc":"1.0","id":"livetext","method":"getblockchaininfo","params":[]}
    {"jsonrpc": "1.0", "id":"curltest", "method":"scantxoutset","params":["start", [{"script" : "76A914CED2436C4D0169B69E8E71C413DC5C5B20F5376388AC" }]]}

    result:=resp.Text;
  finally
    client.Free;
    resp.free;
    mycookies.free;
  end;

end;
 }


procedure TEmerAPIBlockchain.ThreadHasData(Thread:TEmerAPIBlockchainThread;var data:string); //a handler for thread onAsyncQueryRawDone. CALLED BY THREAD
var js:tJsonData;
begin
  //called by thread
  //caller must handle errors
  if assigned(fonAsyncQueryRawDone) then fonAsyncQueryRawDone(Thread,data);
  if assigned(fonAsyncQueryDone) or assigned(Thread.callbackProc) then begin
    try
      data:=changeNone(data);
      js:=GetJSON(data);
    except
      on e:exception do begin
        js:=nil;
        flastError:=e.Message;
      end;
    end;
    if assigned(Thread.callbackProc) then
      try
        Thread.callbackProc(Thread,js);
      except
      end;
    if assigned(fonAsyncQueryDone) then
      try
        fonAsyncQueryDone(Thread,js);
      except
      end;
    if js<>nil then
      js.Free;;
  end;
end;



end.


