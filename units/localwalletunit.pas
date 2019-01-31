unit localwalletunit;


//DEPRECATED!!!!!

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  Buttons, ExtCtrls, StdCtrls, fphttpclient, fpjson, jsonparser
  {$ifdef unix}
  ,cthreads
  ,cmem // the c memory manager is on some systems much faster for multi-threading
  {$endif}
  ;

type

  TWalletThreadStatus=(wtsStopped,wtsWork,wtsIdle,wtsTerminated);

  tonAsyncQueryRawDone= procedure(sender:tObject;result:string) of object;
  tonAsyncQueryDone= procedure(sender:tObject;result:tJsonData) of object;
  tOnWalletError= procedure(sender:tObject;error:string) of object;

  tWalletConnectionData=record
    port:integer;
    userName:ansistring;
    userPass:ansistring;
    UseHTTPS:boolean;
    address:ansistring;
    maxSimConn:integer;
  end;

  pTaskData=^tTaskData;
  tTaskData=record
    proc:tonAsyncQueryDone;
    id:string;
  end;

  TWalletThread = class(TThread)
  private
    fStatus : TWalletThreadStatus;
    fStatusSync : TWalletThreadStatus;
    fonThreadHasData: procedure(data:string) of object;
    fonStatusChanged: procedure(newStatus:TWalletThreadStatus) of object;
    fTasksList:tStringList; //syncronizes access only
    fLastData:string; //read only in sync! write async
    fCurrentTaskData:tTaskData; //read only in sync! write async
    fconnData:tWalletConnectionData; //async acceess! write in beforeRequest
    flastError:string;//async write
    ftestOk:boolean; //async
    fOnError: tOnWalletError;
    procedure setStatus(newStatus:TWalletThreadStatus);//async!!!
    procedure StatusChanged; //sync!! call events
    procedure requestDone; //sync!! call events
    procedure beforeRequest; //sync!! sets fconnData
    procedure syncError(); //sync on error
    procedure asyncError(msg:string); //async on error
  protected
    procedure Execute; override;
    function doRawRequest(q:ansistring):ansistring;
  public
    connData:tWalletConnectionData; //SYNC ACCESS
    property status:TWalletThreadStatus read fStatusSync;
    property TasksList:tStringList read fTasksList;
    property OnError:tOnWalletError read fOnError write fOnError;
    Constructor Create(CreateSuspended : boolean);
    destructor destroy; overload;
  end;


  tLocalWallet = class(tObject)
    private
      FOnConnect:TNotifyEvent;
      FOnDisconnect:TNotifyEvent;
      ftestedOk:boolean;
      fonAsyncQueryRawDone:tonAsyncQueryRawDone;
      fonAsyncQueryDone:tonAsyncQueryDone;
      fThread:TWalletThread;
      fLastID:integer;
      procedure setTestOk(v:boolean);
      procedure ThreadHasData(data:string);
      procedure ThreadStatusChanged(newStatus:TWalletThreadStatus);
    public
      connData:tWalletConnectionData;
      lastError:ansistring;
      function getNextID:string; //fLastID
      property testedOk:boolean read ftestedOk;
      property onConnect: TNotifyEvent read FOnConnect write FOnConnect;
      property onDisconnect: TNotifyEvent read FOnDisconnect write FOnDisconnect;

      //async functions
      property onAsyncQueryRawDone:tonAsyncQueryRawDone read fonAsyncQueryRawDone write fonAsyncQueryRawDone;
      property onAsyncQueryDone:tonAsyncQueryDone read fonAsyncQueryDone write fonAsyncQueryDone;
      procedure sendQueryAsync(methodAndParams:ansistring;callBack:tonAsyncQueryDone=nil;id:string=''); overload;
      procedure sendQueryAsync(method:ansistring;params:array of ansistring;callBack:tonAsyncQueryDone=nil;id:string=''); overload;

      constructor create(wPort:integer;wUserName,wUserPass:ansistring;waddress:ansistring='';wUseHTTPS:boolean=false); overload;
      destructor destroy;
      function checkConnection:boolean;
      function sendRawQuerySync(q:ansistring):ansistring;
      function sendQuerySync(methodAndParams:ansistring):tJsonData; overload;
      function sendQuerySync(method:ansistring;params:array of ansistring):tJsonData; overload;
      function requestString(method:ansistring;params:array of ansistring;findString:string):string;

  end;

  { TLocalWalletConsoleForm }

  TLocalWalletConsoleForm = class(TForm)
    bClose: TBitBtn;
    bClose1: TBitBtn;
    GroupBox1: TGroupBox;
    mConsole: TMemo;
    mTextToSend: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    procedure bClose1Click(Sender: TObject);
    procedure bCloseClick(Sender: TObject);
  private

  public
    LocalWallet:tLocalWallet;

  end;

var
  LocalWalletConsoleForm: TLocalWalletConsoleForm;

implementation

{$R *.lfm}

uses  sockets,helperUnit;

{tWalletThread}

constructor TWalletThread.Create(CreateSuspended : boolean);
begin
  inherited Create(CreateSuspended); // because this is black box in OOP and can reset inherited to the opposite again...
  FreeOnTerminate := True;  // better code...
  fTasksList:=tStringList.Create;
end;

destructor TWalletThread.destroy;
var i:integer;
begin
  for i:=0 to fTasksList.Count do
    if fTasksList.Objects[i]<>nil
      then dispose(pTaskData(fTasksList.Objects[i]));

  fTasksList.free;
  inherited Destroy;
end;

procedure TWalletThread.StatusChanged(); //sync!!
// this method is executed by the mainthread and can therefore access all GUI elements.
begin
  fStatusSync:=fstatus;
  if assigned(fonStatusChanged) then fonStatusChanged(fstatus);
end;

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

procedure TWalletThread.beforeRequest; //sync!! sets fconnData
begin
  fconnData:=connData;
end;

procedure TWalletThread.syncError(); //sync on error
begin
  if assigned(fOnError) then fOnError(self,fLastError);
end;

procedure TWalletThread.asyncError(msg:string); //async on error
begin
  fLastError:=msg;
  Synchronize(@syncError);
end;

procedure TWalletThread.setStatus(newStatus:TWalletThreadStatus);//async!!!
begin
  if fStatus=newStatus then exit;
  fStatus := newStatus;
  Synchronize(@StatusChanged);
end;

procedure TWalletThread.Execute;
begin
  try
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
end;

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

{/tWalletThread}


{
var
    sizeofSockAdr:longint;
    Addr: TInetSockAddr;
    socket:Integer;
    SBufer:ansistring;
begin
     //create socket
     socket:=fpSocket(AF_INET,SOCK_STREAM,0);
     if SocketError=0 then
     begin

       Addr.sin_family:=AF_INET;
       Addr.sin_port:=htons(Port);
       Addr.sin_addr.s_addr:=HostToNet((127 shl 24) or 1); //127.0.0.1

       sizeofSockAdr:=sizeof(Addr);

       if fpBind(socket,@Addr,sizeofSockAdr)=-1 then
       begin
         writeln('127.0.0.1:8000 уже занят! Стоп.');
       end
       else
         if fpListen(socket,1)=-1 then
          writeln('Ошибка ожидания')
         else
         begin
           writeln('Ожидание клиентов 127.0.0.1:8000');

           socket:=fpaccept(socket,@Addr, @sizeofSockAdr);

           if (socket=-1) then writeln('ошибка соединения')
                        else writeln('клиент подсоеденился');

            setlength(SBufer,1024);
           while (socket<>-1) do
              writeln(fprecv(socket,@SBufer[1],1024,0));
              writeln('End of message');
              sleep(5000);
           end;


          sockets.CloseSocket(socket);
          writeln('Сокет закрыт');
         end;
end;



function tLocalWallet.sendQuerySync(q:ansistring):ansistring;
Var
  SAddr    : TInetSockAddr;
  Buffer   : string [255];
  S        : Longint;
  Sin,Sout : Text;
  i        : integer;
begin
  result:='';
  S:=fpSocket (AF_INET,SOCK_STREAM,0);
  if s=-1 then begin
     lastError:='can''t create a socket';
     exit;
  end;

  SAddr.sin_family:=AF_INET;
  { port }
  SAddr.sin_port:=htons(Port);
  { localhost : 127.0.0.1 in network order }
  SAddr.sin_addr.s_addr:=HostToNet((127 shl 24) or 1);
  if not Connect (S,SAddr,Sin,Sout) then begin
     lastError:='can''t connect to the wallet';
     exit;
  end;
  Reset(Sin);
  ReWrite(Sout);
  Buffer:=q;
  for i:=1 to 10 do
    Writeln(Sout,Buffer);
  Flush(Sout);
  Readln(SIn,Buffer);
  result:=Buffer;
  Close(sout);
end;
}

function checkParam(s:ansistring):ansistring;
begin
  if length(s)=0 then s:='""' else
  if (pos('[',s)<1) and (pos('{',s)<1) and (pos('"',s)<1) and (pos('''',s)<1) then
    //if not a digit or bool then add quotes
    if (not (s[1] in ['+','-','0'..'9'])) and (trim(ansiuppercase(s))<>'TRUE') and (trim(ansiuppercase(s))<>'FALSE')
      then s:='"'+s+'"';
  result:=s;
end;

function tLocalWallet.sendQuerySync(method:ansistring;params:array of ansistring):tJsonData;
var s:ansistring;
    i:integer;
begin
  //"method":"getblockchaininfo","params":[]

  //"params":["start", [{"script" : "76A914CED2436C4D0169B69E8E71C413DC5C5B20F5376388AC" }]]
  s:='';

  //if the param
  for i:=0 to length(params) -1 do
    s:=s+checkParam(params[i])+',';
  if length(s)>0 then delete(s,length(s),1); //last comma

  result:=sendQuerySync('"method":"'+trim(method)+'","params":['+s+']');
end;

procedure tLocalWallet.sendQueryAsync(method:ansistring;params:array of ansistring;callBack:tonAsyncQueryDone=nil;id:string='');
var s:ansistring;
    i:integer;
begin
  s:='';
  //if the param
  for i:=0 to length(params) -1 do
    s:=s+checkParam(params[i])+',';
  if length(s)>0 then delete(s,length(s),1); //last comma

  sendQueryAsync('"method":"'+trim(method)+'","params":['+s+']',callBack,id);
end;

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


{tLocalWallet}

constructor tLocalWallet.create(wPort:integer;wUserName,wUserPass:ansistring;waddress:ansistring='';wUseHTTPS:boolean=false);
begin
  connData.port:=wPort;
  connData.userName:=wUserName;
  connData.userPass:=wUserPass;
  connData.UseHTTPS:=wUseHTTPS;
  connData.address:=waddress;
  fLastID:=0;
  fThread:=TWalletThread.Create(true);
  fThread.fonThreadHasData:=@ThreadHasData;
  fThread.fonStatusChanged:=@ThreadStatusChanged;
  fThread.connData:=connData;
  if Assigned(fThread.FatalException) then
    raise fThread.FatalException;
end;

procedure tLocalWallet.ThreadStatusChanged(newStatus:TWalletThreadStatus);
begin

end;

procedure tLocalWallet.ThreadHasData(data:string);
var js:tJsonData;
begin
  //called by thread

  if assigned(fonAsyncQueryRawDone) then fonAsyncQueryRawDone(self,data);
  if assigned(fonAsyncQueryDone) then begin
    data:=changeNone(data);
    js:=GetJSON(data);
    fonAsyncQueryDone(self,js);
    if js<>nil then
      js.Free;;
  end;

end;


function tLocalWallet.getNextID:string; //fLastID
begin
  inc(fLastID);
  result:='__'+inttostr(fLastID);
end;

procedure tLocalWallet.setTestOk(v:boolean);
begin
  if v=ftestedOk then exit;
  ftestedOk:=v;
  if ftestedOk and assigned(fOnConnect) then fonConnect(self)
  else
  if (not ftestedOk) and assigned(fOnDisconnect) then fOnDisconnect(self);
end;

destructor tLocalWallet.destroy;
begin
  fThread.free;
  inherited;
end;

function tLocalWallet.checkConnection:boolean;
var js,e:tJsonData;
begin

  //{"jsonrpc":"1.0","id":"curltext","method":"getinfo","params":[]}
  //'{"jsonrpc": "1.0", "id":"curltest", "method":"scantxoutset","params":["start", [{"script" : "76A914CED2436C4D0169B69E8E71C413DC5C5B20F5376388AC" }]]}'
  {"jsonrpc":"1.0","id":"curltext","method":"getblockchaininfo","params":[]}

  result:=false;



  js:=sendQuerySync('getblockchaininfo');
  if js<>nil then
  try
    e:=js.FindPath('result.chain');
    result:=e<>nil;
  finally
    js.free;
  end;

//!!  E:=D.FindPath('Children[1].Names.FirstName');
  //LocalWalletConsoleForm.mConsole.text:=s;
  setTestOk(result);
end;

function tLocalWallet.requestString(method:ansistring;params:array of ansistring;findString:string):string;
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

{/tLocalWallet}

{ TLocalWalletConsoleForm }

procedure TLocalWalletConsoleForm.bCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TLocalWalletConsoleForm.bClose1Click(Sender: TObject);
var s:ansistring;
begin
  s:=LocalWallet.sendRawQuerySync(trim(mTextToSend.Text));
  LocalWalletConsoleForm.mConsole.Append('>>'+trim(mTextToSend.Text));
  LocalWalletConsoleForm.mConsole.Append(s);
  mTextToSend.Text:='';

end;

end.

