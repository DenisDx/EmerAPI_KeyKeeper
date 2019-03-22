unit jsonrpc;

{$mode objfpc}{$H+}

//https://www.freepascal.org/~michael/articles/webserver1/webserver1.pdf
interface

uses
Classes, SysUtils, FileUtil,fpjson, jsonparser, forms
  {$ifdef unix}
  ,cthreads
  ,cmem // the c memory manager is on some systems much faster for multi-threading
  {$endif}
,fphttpserver, emerapitypes, EmerAPIBlockchainUnit

;

type
TJSONRPCServerThread = class;

TJSONRPCServer = Class(tEmerApiNotified)
  //'error'
   public
     LastError : string;
     JSONRPCServerThread:TJSONRPCServerThread;
     procedure checkState;
     Constructor Create();
     destructor destroy; override;
end;

TJSONRPCServerThread = Class(TThread)
  Private
    FServer : TFPHTTPServer;
    //fonError : tNotifyEvent;
    //fActive : boolean;
    fParent:TJSONRPCServer;
    fRequestDone:boolean; //async access only
    fRequest: TFPHTTPConnectionRequest; //sync / async access
    fResponse : TFPHTTPConnectionResponse; //sync / async access
    //
    fID:ansistring; //sync access
    fMethod:ansistring; //sync access
    fDone:boolean;  //sync access
    fQData:array of ansistring; //sync access. param list

    fTimeout:integer; //Settings.getValue('JSONPRC_timeout')

    procedure asyncJSONRPCHandleRequest(Sender: TObject; Var ARequest: TFPHTTPConnectionRequest; Var AResponse : TFPHTTPConnectionResponse); //THTTPServerRequestHandler
    procedure asyncJSONRPCHandleRequestError(Sender : TObject; E : Exception);
    procedure syncdoRequest; //sync!
    procedure syncRequestClosed; //sync! called on request finalization.
    procedure synccheckRequestDone;  //sync!

    procedure doneResult(result:string); //do not call async. Sets fDone
    procedure doneError(message:string; code:integer=-1); //do not call async. Sets fDone

    procedure AsyncRequestDone(sender:TEmerAPIBlockchainThread;result:tJsonData);//SYNC call!

    procedure TxSent(Sender:tObject);
    procedure TxSendingError(Sender:tObject);
  Public

    Constructor Create(Parent:TJSONRPCServer);
    //destructor destroy; override;
    Procedure Execute; override;
    Procedure DoTerminate; override;
    procedure SyncHandleError;
    //procedure checkState;
    Property Server : TFPHTTPServer Read FServer;
  end;

implementation

uses fpHTTP, fpWeb
  ,SettingsUnit,Localizzzeunit
  ,sockets
  ,MainUnit
  ,DebugConsoleUnit
  ,EmbededSignaturesUnit
  ,crypto
  ,EmerAPITransactionUnit
  ,HelperUnit
  ,EmerTX
;


const
  // Standard JSON-RPC 2.0 errors
        RPC_INVALID_REQUEST  = -32600;
        RPC_METHOD_NOT_FOUND = -32601;
        RPC_INVALID_PARAMS   = -32602;
        RPC_INTERNAL_ERROR   = -32603;
        RPC_PARSE_ERROR      = -32700;

        // General application defined errors
        RPC_MISC_ERROR                  = -1;  // std::exception thrown in command handling
        RPC_FORBIDDEN_BY_SAFE_MODE      = -2;  // Server is in safe mode, and command is not allowed in safe mode
        RPC_TYPE_ERROR                  = -3;  // Unexpected type was passed as parameter
        RPC_INVALID_ADDRESS_OR_KEY      = -5;  // Invalid address or key
        RPC_OUT_OF_MEMORY               = -7;  // Ran out of memory during operation
        RPC_INVALID_PARAMETER           = -8;  // Invalid, missing or duplicate parameter
        RPC_DATABASE_ERROR              = -20; // Database error
        RPC_DESERIALIZATION_ERROR       = -22; // Error parsing or validating structure in raw format

        // P2P client errors
        RPC_CLIENT_NOT_CONNECTED        = -9;  // Bitcoin is not connected
        RPC_CLIENT_IN_INITIAL_DOWNLOAD  = -10; // Still downloading initial blocks

        // Wallet errors
        RPC_WALLET_ERROR                = -4;  // Unspecified problem with wallet (key not found etc.)
        RPC_WALLET_INSUFFICIENT_FUNDS   = -6;  // Not enough funds in wallet or account
        RPC_WALLET_INVALID_ACCOUNT_NAME = -11; // Invalid account name
        RPC_WALLET_KEYPOOL_RAN_OUT      = -12; // Keypool ran out, call keypoolrefill first
        RPC_WALLET_UNLOCK_NEEDED        = -13; // Enter the wallet passphrase with walletpassphrase first
        RPC_WALLET_PASSPHRASE_INCORRECT = -14; // The wallet passphrase entered was incorrect
        RPC_WALLET_WRONG_ENC_STATE      = -15; // Command given in wrong wallet encryption state (encrypting an encrypted wallet etc.)
        RPC_WALLET_ENCRYPTION_FAILED    = -16; // Failed to encrypt the wallet
        RPC_WALLET_ALREADY_UNLOCKED     = -17; // Wallet is already unlocked


procedure pingself(port:word);
Var
  Addr : TInetSockAddr;
  S : Longint;
  sin,sout:TEXT;
begin
  Addr.sin_family:=AF_INET;
  { port in network order }
  Addr.sin_port:=port shl 8 + port shr 8;
  { localhost : 127.0.0.1 in network order }
  Addr.sin_addr.s_addr:=((1 shl 24) or 127);
  S:=fpSocket(AF_INET,SOCK_STREAM,0);


  If Connect (S,ADDR,SIN,SOUT) Then
    fpShutdown(s,2);


  {
  If Not Connect (S,ADDR,SIN,SOUT) Then
    begin
    Writeln ('Couldn''t connect to localhost');
    Writeln ('Socket error : ',strerror(SocketError));
    halt(1);
    end;
  rewrite (sout);
  reset(sin);
  writeln (sout,paramstr(1));
  flush(sout);
  while not eof(sin) do
    begin
    readln (Sin,line);
    writeln (line);
    end;
  fpShutdown(s,2);
  close (sin);
  close (sout);
  }
end;

procedure TJSONRPCServer.checkState;
begin
  //called by owner. Check port and other things!

  if (JSONRPCServerThread<>nil)
    then if JSONRPCServerThread.Finished then
      freeandnil(JSONRPCServerThread);

  if JSONRPCServerThread<>nil then
    if (JSONRPCServerThread.Server.Port<>Settings.getValue('JSONPRC_port'))
       or
       (not Settings.getValue('JSONPRC_allowed'))

    then begin
       {
      JSONRPCServerThread.FreeOnTerminate:=true;
      //JSONRPCServerThread.Server.Active:=false;
      JSONRPCServerThread.Terminate;
      JSONRPCServerThread:=nil;
      }

      //freeandnil(JSONRPCServerThread);


      JSONRPCServerThread.FreeOnTerminate:=true;
      //JSONRPCServerThread.Terminate;
      JSONRPCServerThread.Server.Active:=false;
      //JSONRPCServerThread.Server.Port:=0;
      pingself(JSONRPCServerThread.Server.Port);

      JSONRPCServerThread:=nil;
    end;

  if Settings.getValue('JSONPRC_allowed') and (JSONRPCServerThread=nil) then
     JSONRPCServerThread:=TJSONRPCServerThread.Create(self);

end;


Constructor TJSONRPCServer.Create();
begin
  inherited;
  checkState;
end;

destructor TJSONRPCServer.destroy;
begin

  if (JSONRPCServerThread<>nil) and (JSONRPCServerThread.Server.Active) then begin
    JSONRPCServerThread.FreeOnTerminate:=true;
    JSONRPCServerThread.Server.Active:=false;
    pingself(JSONRPCServerThread.Server.Port);
  end;

  //freeandnil(JSONRPCServerThread);
  inherited;
end;


// TJSONRPCServerThread

constructor TJSONRPCServerThread.Create(Parent:TJSONRPCServer);
begin
  fParent:=parent;

  FServer:=TFPHTTPServer.Create(Nil);
  FServer.OnRequest:=@asyncJSONRPCHandleRequest;
  FServer.OnRequestError:=@asyncJSONRPCHandleRequestError;
  FServer.Port:=Settings.getValue('JSONPRC_port');

  Inherited Create(False);
end;

procedure TJSONRPCServerThread.SyncHandleError;
begin
  if fParent<>nil then try
    fParent.callNotify('error');
  except
  end;
end;

procedure TJSONRPCServerThread.Execute;
begin
  try
     FServer.Active:=true
  except
     Synchronize(@SyncHandleError);
  end;
  FreeAndNil(FServer);
end;
{
destructor TJSONRPCServerThread.destroy;
begin
  if FServer<>nil then FreeAndNil(FServer);
  inherited;
end;
}
procedure TJSONRPCServerThread.DoTerminate;
begin
  inherited DoTerminate;
  if FServer<>nil then FServer.Active:=False;
end;

function isAddressInRange(ip,range:ansistring):boolean;
var s:ansistring;
    n:integer;
    nIP,n1,n2:dword;

    function ip2bytes(ip:ansistring):dword;
    var i:integer; n:integer;
    begin
      result:=0;
      ip:=ip+'.';
      try
        for i:=0 to 3 do begin
          n:=strtoint(copy(ip,1,pos('.',ip)-1)); delete(ip,1,pos('.',ip));
          if (n>255) then begin result:=0; exit; end;
          result:=result * $100;
          result:=result + n;
        end;

        if (ip<>'') then begin result:=0; exit; end;

      except
        result:=0;
      end;
    end;
begin
  // IP | IP | IP - IP | ....
  nIP:=0;
  result:=true;
  ip:=trim(ip);
  range:=trim(ip);
  while pos(' ',ip)>0 do delete(ip,pos(' ',ip),1);

  while range<>'' do begin
    n:=pos('|',range);
    if n>0 then begin
      s:=copy(range,1,n-1);
      delete(range,1,n);
    end else begin
      s:=range;
      range:='';
    end;

    if pos('-',s)>0 then begin
      //range ip-ip
      if nIP=0 then nIP:=ip2bytes(ip);
      n1:=ip2bytes(copy(s,1,pos('-',s)-1));

      if (n1>0) and (nIP>=n1) then begin
         if nIP=n1 then exit;
         delete(s,1,pos('-',s));
         n2:=ip2bytes(s);
         if n2>=nIP then exit;
      end;
    end else if s=ip then exit;


  end;


  result:=false;
end;

procedure TJSONRPCServerThread.doneResult(result:string); //do not call async. Sets fDone
begin
  fResponse.ContentType:='application/json-rpc';
  fResponse.Content:='{"result":'+result+',"error":null,"id":"'+fID+'"}';

  debugConsoleShow('JSON RPC RESULT: '+result+' FOR ' + fRequest.Content);
  fDone:=true; //can be send
end;

procedure TJSONRPCServerThread.doneError(message:string; code:integer=-1); //do not call async. Sets fDone
begin
  {"result":null,"error":{"code":-13,"message":"Error: Please enter the wallet passphrase with walletpassphrase first."},"id":"curltest"}
  //-32700	Parse error	Invalid JSON was received by the server.
//An error occurred on the server while parsing the JSON text.
//-32600	Invalid Request	The JSON sent is not a valid Request object.
//-32601	Method not found	The method does not exist / is not available.
//-32602	Invalid params	Invalid method parameter(s).
//-32603	Internal error	Internal JSON-RPC error.
//-32000 to -32099	Server error	Reserved for implementation-defined server-errors.

{
  https://github.com/bitconnectcoin/bitconnectcoin/blob/master/src/bitcoinrpc.h

  (-10, "Bitcoin is downloading blocks...");
  (-11, "Invalid account name");
  (-12, "Error: Keypool ran out, please call keypoolrefill first");
  (-12, "Error: Keypool ran out, please call topupkeypool first");
  (-13, "Error: Please enter the wallet passphrase with walletpassphrase first.");
  (-14, "Error: The wallet passphrase entered was incorrect.");
  (-15, "Error: running with an encrypted wallet, but encryptwallet was called.");
  (-15, "Error: running with an unencrypted wallet, but walletlock was called.");
  (-15, "Error: running with an unencrypted wallet, but walletpassphrase was called.");
  (-15, "Error: running with an unencrypted wallet, but walletpassphrasechange was called.");
  (-16, "Error: Failed to encrypt the wallet.");
  (-17, "Error: Wallet is already unlocked.");
  (-2, string("Safe mode: ") + strWarning);
  (-3, "Invalid amount");
  (-32600, "Method must be a string");
  (-32600, "Missing method");
  (-32600, "Params must be an array");
  (-32601, "Method not found");
  (-32700, "Parse error");
  (-4, "Error refreshing keypool.");
  (-4, "Transaction commit failed");
  (-4, "Transaction creation failed");
  (-5, "Invalid bitcoin address");
  (-5, "Invalid or non-wallet transaction id");
  (-5, string("Invalid bitcoin address:")+s.name_);
  (-6, "Account has insufficient funds");
  (-6, "Insufficient funds");
  (-7, "Out of memory");
  (-8, "Invalid parameter");
  (-8, string("Invalid parameter, duplicated address: ")+s.name_);
  (-9, "Bitcoin is not connected!");




  // Bitcoin RPC error codes
  enum RPCErrorCode
  {
      // Standard JSON-RPC 2.0 errors
      RPC_INVALID_REQUEST  = -32600,
      RPC_METHOD_NOT_FOUND = -32601,
      RPC_INVALID_PARAMS   = -32602,
      RPC_INTERNAL_ERROR   = -32603,
      RPC_PARSE_ERROR      = -32700,

      // General application defined errors
      RPC_MISC_ERROR                  = -1,  // std::exception thrown in command handling
      RPC_FORBIDDEN_BY_SAFE_MODE      = -2,  // Server is in safe mode, and command is not allowed in safe mode
      RPC_TYPE_ERROR                  = -3,  // Unexpected type was passed as parameter
      RPC_INVALID_ADDRESS_OR_KEY      = -5,  // Invalid address or key
      RPC_OUT_OF_MEMORY               = -7,  // Ran out of memory during operation
      RPC_INVALID_PARAMETER           = -8,  // Invalid, missing or duplicate parameter
      RPC_DATABASE_ERROR              = -20, // Database error
      RPC_DESERIALIZATION_ERROR       = -22, // Error parsing or validating structure in raw format

      // P2P client errors
      RPC_CLIENT_NOT_CONNECTED        = -9,  // Bitcoin is not connected
      RPC_CLIENT_IN_INITIAL_DOWNLOAD  = -10, // Still downloading initial blocks

      // Wallet errors
      RPC_WALLET_ERROR                = -4,  // Unspecified problem with wallet (key not found etc.)
      RPC_WALLET_INSUFFICIENT_FUNDS   = -6,  // Not enough funds in wallet or account
      RPC_WALLET_INVALID_ACCOUNT_NAME = -11, // Invalid account name
      RPC_WALLET_KEYPOOL_RAN_OUT      = -12, // Keypool ran out, call keypoolrefill first
      RPC_WALLET_UNLOCK_NEEDED        = -13, // Enter the wallet passphrase with walletpassphrase first
      RPC_WALLET_PASSPHRASE_INCORRECT = -14, // The wallet passphrase entered was incorrect
      RPC_WALLET_WRONG_ENC_STATE      = -15, // Command given in wrong wallet encryption state (encrypting an encrypted wallet etc.)
      RPC_WALLET_ENCRYPTION_FAILED    = -16, // Failed to encrypt the wallet
      RPC_WALLET_ALREADY_UNLOCKED     = -17, // Wallet is already unlocked
  };



}



  fResponse.ContentType:='application/json-rpc';
  fResponse.Content:='{"result":null,"error":{"code":'+inttostr(code)+',"message":"'+message+'"},"id":"'+fID+'"}';



  debugConsoleShow('JSON RPC EXECUTION ERROR: '+message+' FOR ' + fRequest.Content);
  fDone:=true; //can be send
end;


function decodeValueByType(value:ansistring; valuetype:ansistring):ansistring;
var fs:tFileStream;
begin
  if valuetype='' then
    result:=value
  else if valuetype='hex' then
   try
     result:=hexToBuf(value);
   except
     result:='';
   end
  else if valuetype='base64' then
    result:=base64tobuf(value)
  else if valuetype='filepath' then begin
    try
      fs:=tFileStream.Create(value,fmOpenRead);
      try
        setLength(result,fs.Size);
        if fs.Size>0 then
          fs.Read(result[1],fs.Size);
      finally
        fs.free;
      end;
    except
      result:='';
    end;
  end else result:='';
end;

function isAddressValid(address:ansistring):boolean;
begin
  result:=false;
  address:=base58ToBufCheck(address);

  if length(address)<>21 then exit;
  if address[1]<>MainForm.globals().AddressSig then exit;

  result:=true;
end;

procedure TJSONRPCServerThread.syncRequestClosed;
begin
  if (not Terminated) and (not fRequestDone) then
    //closed by timeout
    doneError('Operation aborted by timeout',-1);
  fDone:=true;
end;

procedure TJSONRPCServerThread.syncDoRequest; //sync!
var js,e:tJsonData;
    par:tJsonArray;
    s,s1:ansistring;

    function extractStrPar(num:integer;name:ansistring):ansistring;
    var e:tJsonData;
    begin
       e:=par.FindPath(name);
       if e<>nil then result:=e.AsString
                 else if num<par.Count
                    then result:=par[num].AsString
                    else result:='';
    end;
    function extractIntPar(num:integer;name:ansistring):integer;
    var e:tJsonData;
    begin
       e:=par.FindPath(name);
       if e<>nil then result:=e.AsInteger
                 else if num<par.Count
                    then result:=par[num].AsInteger
                    else result:=0;
    end;

begin
  //can set fRequestDone if done :-)

  setLength(fQData,0);

  fTimeout:=Settings.getValue('JSONPRC_timeout');

  fDone:=false;
  fRequestDone:=true;
  if Settings.getValue('JSONRPC_Allow_Nonlocal') then begin
     if Settings.getValue('JSONRPC_Allow_Only') then
        if not isAddressInRange(fRequest.RemoteAddress,Settings.getValue('JSONRPC_allow_IPs')) then exit;
  end else if fRequest.RemoteAddress<>'127.0.0.1' then exit;


  fID:='';

  try
    js:=GetJSON(fRequest.Content);
    if js=nil then begin
       debugConsoleShow('JSON RPC INVALID REQUEST: '+ fRequest.Content);
       exit;
    end;
  except
    debugConsoleShow('JSON RPC INVALID REQUEST: '+ fRequest.Content);
    exit;
  end;
  fRequestDone:=false;

  try
    try
      //{ "jsonrpc" : "1.0", "id" : "__1393", "method" : "getblockchaininfo", "params" : [] }
      e:=js.FindPath('id');
      if e<>nil then
        fID:=e.AsString;

      fMethod:='';
      e:=js.FindPath('method');
      if e<>nil then
        fMethod:=trim(e.AsString);

      //checking if the method allowed

      if Settings.getValue('JSONRPC_filter_commands') then
         if pos(uppercase(fMethod),uppercase('|'+Settings.getValue('JSONRPC_allowed_commands')+'|'))<1 then begin
           debugConsoleShow('JSON RPC METHOD "'+fMethod+'" NOT ALLOWED IN REQUEST: '+ js.AsJSON);
           fRequestDone:=true;
         end;


      par:=tJsonArray(js.FindPath('params'));

      if fMethod='getbalance' then begin
        //curl --user 'user' --data-binary '{"jsonrpc":"1.0","id":"curltest","method":"getinfo","params":[]}' -H 'content-type:text/plain;' http://127.0.0.1:6663
        //curl --user 'user' --data-binary '{"jsonrpc":"1.0","id":"curltest","method":"getbalance","params":[]}' -H 'content-type:text/plain;' http://127.0.0.1:6663
         //curl --data-binary '{"jsonrpc":"1.0","id":"curltest","method":"getbalance","params":[]}' -H 'content-type:text/plain;' http://127.0.0.1:6663
        // curl --user 'user' --data-binary "{\"jsonrpc\":\"1.0\",\"id\":\"curltest\",\"method\":\"getbalance\",\"params\":[]}" -H 'content-type:text/plain;' http://127.0.0.1:6663
        //  curl --user user --data-binary "{\"jsonrpc\":\"1.0\",\"id\":\"curltest\",\"method\":\"getbalance\",\"params\":[]}" -H "content-type:text/plain;" http://127.0.0.1:6663
        //{"result":2863.683900,"error":null,"id":"curltest"}

        //fResponse.ContentType:='application/json-rpc';
        //fResponse.Content:='{"result":'+MainForm.eBalance.Text+',"error":null,"id":"'+fID+'"}';
        //MainForm.eBalance.Text
        doneResult({'"'+}MainForm.eBalance.Text{+'"'});
        fRequestDone:=true;
        //debugConsoleShow('JSON RPC REQUEST getbalance: '+ js.AsJSON);
      end else if fMethod='name_new' then begin
        //name_new <name> <value> <days> [toaddress] [valuetype]
        //Creates new key->value pair which expires after specified number of days.
        //Cost is square root of (1% of last PoW + 1% per year of last PoW).
        //Arguments:
        //1. name      (string, required) Name to create.
        //2. value     (string, required) Value to write.
        //3. days      (number, required) How many days this name will be active (1 day~=175 blocks).
        //4. toaddress (string, optional) Address of recipient. Empty string = transaction to yourself.
        //5. valuetype (string, optional) Interpretation of value string. Can be "hex", "base64" or filepath.
        //   not specified or empty - Write value as a unicode string.
        //   "hex" or "base64" - Decode value string as a binary data in hex or base64 string format.
        //   otherwise - Decode value string as a filepath from which to read the data.

         if EmerAPI.blockChain.LastPoWReward=0 then doneError('Blockchain status is not updated. Please wait.',RPC_CLIENT_IN_INITIAL_DOWNLOAD)
         else if (par=nil) or (par.Count<3) or (par.Count>5) then doneError('Wrong parameters count for name_new. Must be ["name","value",days,"toaddress","valuetype"]. Only first 3 required.',RPC_INVALID_PARAMS)
         else begin

           //VAR 1: curl --user user --data-binary "{\"jsonrpc\": \"1.0\", \"id\":\"curltest\", \"method\": \"name_new\", \"params\": [\"testname1\",\"testvalue1\",1] }" -H "content-type: text/plain;" http://127.0.0.1:6662/
           //VAR 2: curl --user user --data-binary "{\"jsonrpc\": \"1.0\", \"id\":\"curltest\", \"method\": \"name_new\", \"params\": {\"name\":\"testname2\",\"value\":\"testvalue2\",\"days\":1} }" -H "content-type: text/plain;" http://127.0.0.1:6662/

           setLength(fQData,5);
           fQData[0]:=extractStrPar(0,'name');
           fQData[1]:=extractStrPar(1,'value');
           fQData[2]:=inttostr(extractIntPar(2,'days'));
           fQData[3]:=extractStrPar(3,'toaddress');
           fQData[4]:=extractStrPar(4,'valuetype');

           s:=decodeValueByType(fQData[1],fQData[4]);

           if (fQData[0]='') or (length(fQData[0])>512) then begin
             doneError('Invalid name for '+fMethod,RPC_INVALID_PARAMS);
             fRequestDone:=true;
           end else if (fQData[4]<>'') and (fQData[4]<>'hex') and (fQData[4]<>'base64') and (fQData[4]<>'filepath') then begin
             doneError('Invalid valuetype for '+fMethod,RPC_INVALID_PARAMS);
             fRequestDone:=true;
           end else if (s='') then begin
             doneError('Invalid value for '+fMethod,RPC_INVALID_PARAMS);
             fRequestDone:=true;
           end else if (length(s)>20480) then begin
             doneError('Too long value. Max len=20480 for '+fMethod,RPC_INVALID_PARAMS);
             fRequestDone:=true;
           end else if (fQData[2]='0') then begin
             doneError('Invalid days '+fMethod,RPC_INVALID_PARAMS);
             fRequestDone:=true;
           end else if (fQData[3]<>'') and (not isAddressValid(fQData[3])) then begin
             doneError('Invalid address for '+fMethod,RPC_INVALID_PARAMS);
             fRequestDone:=true;

           end else if (myStrToFloat(MainForm.eBalance.Text)*1000000)<EmerAPI.blockChain.getNameOpFee(strtoint(fQData[2]),opNum('OP_NAME_NEW'),length(fQData[0])+length(s)) then begin //do we have money enough?
             // RPC_WALLET_INSUFFICIENT_FUNDS   = -6;  // Not enough funds in wallet or account
             doneError('Not enough funds in wallet or account for '+fMethod,RPC_WALLET_INSUFFICIENT_FUNDS);
             fRequestDone:=true;
           end else if EmerAPI.mempool.findName(fQData[0])<>nil then begin //1. Check if the name in memmpool already
             doneError('Name is already in mempool for '+fMethod,RPC_INVALID_PARAMS);
             fRequestDone:=true;
           end else begin
             //2. Query test name_new_step1
             emerAPI.EmerAPIConnetor.sendWalletQueryAsync('name_show',getJSON('{name:"'+fQData[0]+'"}'),@AsyncRequestDone,'name_new_step1:'+trim(fQData[0]));
           end;
         end;


      end else if fMethod='name_show' then begin
        //name_show <name> [valuetype] [filepath]
        //Show values of a name.
        //Arguments:
        //1. name      (string, required).
        //2. valuetype (string, optional) If "hex" or "base64" is specified then it will print value in corresponding format instead of string.
        //3. filepath  (string, optional) save name value in binary format in specified file (file will be overwritten!).

        //VAR 1: curl --user user --data-binary "{\"jsonrpc\": \"1.0\", \"id\":\"curltest\", \"method\": \"name_show\", \"params\": [\"denis\"] }" -H "content-type: text/plain;" http://127.0.0.1:6662/
        //VAR 2: curl --user user --data-binary "{\"jsonrpc\": \"1.0\", \"id\":\"curltest\", \"method\": \"name_show\", \"params\": {\"name\":\"denis\"} }" -H "content-type: text/plain;" http://127.0.0.1:6662/

        {\"result\": {\"name\": \"NAME\", \"value\": \"VALUE\", \"txid\": \"84087514ba286150c315fd7be92d8ead7eb1080b53c61932fbdf0870138d6f39\", \"address\": \"mfkbH3gXdGALNGEneZgcjmzKsYAFdjJDDD\", \"expires_in\": 1720929, \"expires_at\": 1769254, \"time\": 1537250669}, \"error\": null, \"id\": null}
        {"result":{"name":"denis","value":"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDqGRmLH3KF3BIqg5yk3XIK/g/+185hoIHIJ8N8JJadrbfs2x5jbmzE0Td88N+2grOId4pIQQsFTlI30kazYOcpbShDiWY4QN9dMfbHwKbMdGR8mlylKZh2pKq804IYgMljKPJ0G1M1qTuWis99oOP900gtQaDFJbc9uDRq8MS8EO1uYElRzclm2vLIVrdp7v0IGDBZKuTk8KJhvPRu+yEcWvW8Usq6Ji1pArUrab2Dg7mY7GQgbCRw/hgA2HTJwMl1czZjiCt5+keYrHVD/mXoTDznySXHMGA2V5J+u0vqtEzHoHA1SNmPOwwn6IqIDiFQe5yPHUDegFAhT0sy9Ecz Denis main","txid":"84087514ba286150c315fd7be92d8ead7eb1080b53c61932fbdf0870138d6f39","address":"mfkbH3gXdGALNGEneZgcjmzKsYAFdjJDDD","expires_in":1720926,"expires_at":1769254,"time":1537250669},"error":null,"id":"curltest"}

        //extract parameters
        if (par=nil) or (par.Count<1) or (par.Count>3) then doneError('Wrong parameters count for name_show. Must be [\"name\",\"valuetype:hex or base64\",\"filename\"]. Only first required.',RPC_INVALID_PARAMS)
        else begin
          setLength(fQData,3);
          fQData[0]:=extractStrPar(0,'name');
          fQData[1]:=extractStrPar(1,'valuetype');
          fQData[2]:=extractStrPar(2,'filepath');

          s:='';

          if (fQData[1]<>'') and (fQData[1]<>'hex') and (fQData[1]<>'base64') then begin
            //!!!! if fQData[1]<>'' then s:=',valuetype:"'+fQData[1]+'"';
            if fQData[2]<>'' then
              s:=',valuetype:"'+fQData[1]+'"';
            if fQData[3]<>'' then
              s:=',valuetype:"base64"'; //we will save the file!

            emerAPI.EmerAPIConnetor.sendWalletQueryAsync('name_show',getJSON('{name:"'+fQData[0]+'"'+s+'}'),@AsyncRequestDone,'name_show:'+trim(fQData[0]));

          end else begin
            doneError('Invalid valuetype for '+fMethod,RPC_INVALID_PARAMS);
            fRequestDone:=true;
          end;
        end;

      end else if fMethod='signmessage' then begin
        // curl --user user --data-binary "{\"jsonrpc\": \"1.0\", \"id\":\"curltest\", \"method\": \"signmessage\", \"params\": [\"1D1ZrZNe3JUo7ZycKEYQQiQAWd9y54F4XX\", \"my message\"] }" -H "content-type: text/plain;" http://127.0.0.1:6663/
        // curl --user user --data-binary "{\"jsonrpc\": \"1.0\", \"id\":\"curltest\", \"method\": \"signmessage\", \"params\": [\"mg6GJZTbxEEVcBJwoAen5VogRuVAK1a8t1\", \"line1\nline2\"] }" -H "content-type: text/plain;" http://127.0.0.1:6662/
        //NOT SUPPORTED BY CORE:  curl --data-binary "{\"jsonrpc\": \"1.0\", \"id\":\"curltest\", \"method\": \"signmessage\", \"params\": [\"\", \"my message\"] }" -H "content-type: text/plain;" http://127.0.0.1:6663/

        // {"result":"IDb4BsMzfui5TcRW6o/hX4pVwHnvmyONxV+XhB7ipNKRPCGKvweoeczga3FAF4Dd7RPyaqnIFusmcOMKfbaecuM=","error":null,"id":"curltest"}
        //we support also "" address for default address

        //WARNING! ORIGINAL WALLET SUPPORTS ONLY ARRAY (named parameters can not be used)!!!

        if (par=nil) or (par.Count<>2) then doneError('Wrong parameters count for signmessage. Must be [\"address or empty for default address or `default`\",\"message\"]',RPC_INVALID_PARAMS)
        else begin


          //e:=par.FindPath('address');
          //if e<>nil then s:=e.AsString
          //          else s:=par[0].AsString;
          s:=extractStrPar(0,'address');

          if (s='') or (uppercase(s)='DEFAULT') then s:=MainForm.getMainPrivKey
          else s:=MainForm.getPrivKey(s);

          {
          //if we has been waiting for too long time for the password, it will be fDone
          if fDone then begin
            debugConsoleShow('JSON RPC: closed by timeout');
            fRequestDone:=true;
            exit;
          end;
          }

          //e:=par.FindPath('message');
          //if e<>nil then s1:=e.AsString
          //          else s1:=par[1].AsString;
          s1:=extractStrPar(1,'message');

          if s='' then doneError('Wrong address for signmessage. Must be \"address or empty for default address or `default`\"',RPC_INVALID_ADDRESS_OR_KEY)
          else begin
             doneResult('"'+bufTobase64(signMessage(s1,s))+'"');
          end;
        end;

        fRequestDone:=true;
      end else begin
        //debugConsoleShow('JSON RPC UNKNOWN METHOD "'+fMethod+'" IN REQUEST: '+ js.AsJSON);
        //fResponse.ContentType:='application/json-rpc';
        //fResponse.Content:='{"result":null,"error":"Unknown or unsupported method '+fMethod+'","id":"'+fID+'"}';
        doneError('Unknown or unsupported method '+fMethod,-32601);
        fRequestDone:=true;
      end;

    except
      debugConsoleShow('JSON RPC REQUEST PARSING ERROR: '+ js.AsJSON);
      fRequestDone:=true;
    end;
  finally
    js.free;
  end;
end;

procedure TJSONRPCServerThread.syncCheckRequestDone;  //sync!
begin
  //sync!
  //sets fRequestDone if done
  fRequestDone:=fDone;
end;

procedure TJSONRPCServerThread.asyncJSONRPCHandleRequest(Sender: TObject;
      Var ARequest: TFPHTTPConnectionRequest;
      Var AResponse : TFPHTTPConnectionResponse); //THTTPServerRequestHandler

var
  i:integer;
  sleepTime:integer;
begin
  {
  mainForm.mLog.lines.append('REQUEST RECEIVED:');
  for i:=0 to ARequest.FieldCount-1 do
    mainForm.mLog.lines.append(inttostr(i)+':'+ARequest.FieldNames[i]+'='+ARequest.FieldValues[i]);
  mainForm.mLog.lines.append('Command='+ ARequest.Command);
  mainForm.mLog.lines.append('QueryString='+ ARequest.QueryString);
  mainForm.mLog.lines.append('CommandLine='+ ARequest.CommandLine);
  mainForm.mLog.lines.append('ContentRange='+ ARequest.ContentRange);
  mainForm.mLog.lines.append('HeaderLine='+ ARequest.HeaderLine);
  mainForm.mLog.lines.append('Content='+ ARequest.Content);
  mainForm.mLog.lines.append('Method='+ ARequest.Method);
  mainForm.mLog.lines.append('Query='+ ARequest.Query);
  mainForm.mLog.lines.append('URL='+ ARequest.URL);
  mainForm.mLog.lines.append('RemoteAddr='+ ARequest.RemoteAddr);
  mainForm.mLog.lines.append('RemoteAddress='+ ARequest.RemoteAddress);
  }
  //ARequest.Content
  //ARequest.RemoteAddress
  fRequest := ARequest;
  fResponse := AResponse;

  fRequestDone:=false;
  synchronize(@syncDoRequest);
  if not fRequestDone then begin
    sleepTime:=1;
    repeat
      sleep(sleepTime);
      sleepTime:=round(sleepTime*1.5);
      synchronize(@syncCheckRequestDone);
    until (sleepTime>(750*fTimeout)) or Terminated or fRequestDone;
  end;
  synchronize(@syncRequestClosed);
end;

procedure TJSONRPCServerThread.asyncJSONRPCHandleRequestError(Sender : TObject; E : Exception);
begin
  debugConsoleShow('JSON RPC SOCKET ERROR: '+E.Message+'');
end;

procedure TJSONRPCServerThread.TxSent(Sender:tObject);
begin
  if Sender is tEmerTransaction then begin
    {"result":"ab7a3a08bd77c7fb4031c79070e98f8d10dc493edc31f004413c053ff078634d","error":null,"id":"curltest"}
    doneResult('"'+lowercase(buftohex((Sender as tEmerTransaction).getTXID))+'"');
  end else
    doneError('Unknown error in TxSent ',-1);

  fDone:=true;
end;

procedure TJSONRPCServerThread.TxSendingError(Sender:tObject);
begin
  if Sender is tEmerTransaction then
    doneError('TX error: '+tEmerTransaction(sender).lastError,-1)
  else
    doneError('Unknown error in TxSendingError ',-1);

  fDone:=true;
end;


procedure TJSONRPCServerThread.AsyncRequestDone(sender:TEmerAPIBlockchainThread;result:tJsonData);//SYNC CALL!!!
var e,ee:tJsonData;
    s:ansistring;
    fs:tFileStream;
var
    address,nName,nValue:ansistring;
    tx:tEmerTransaction;
begin
  if result=nil then begin
    //error
    //LastError:=sender.lastError;
    //if assigned(fOnError) then fOnError(self);
    //callNotify('error');
    doneError('Unknown or connection error: '+sender.lastError,-1);
    fDone:=true;
    exit;
  end;



  //'name_show:'+trim(fQData[0])
  if (sender.id=('name_show:'+trim(fQData[0]))) then begin
    e:=result.FindPath('result');
    //just return the result, but make changes for valuetype. We requested it in base64 for filename type
    //fQData[0]:=extractStrPar(0,'name');
    //fQData[1]:=extractStrPar(1,'valuetype');
    //fQData[2]:=extractStrPar(2,'filepath');

    if e<>nil then begin

      {"result":{"name":"NAME","value":"VALUE","txid":"TXID","address":"OWNERADDR","expires_in":1720926,"expires_at":1769254,"time":1537250669},"error":null,"id":"curltest"}
      if fQData[2]<>'' then begin
        //it was a file!
        //we have requested it as base64
        ee:=e.FindPath('value');
        if ee=nil then begin
          doneError('Invalid result: no value: '+result.AsJSON,-1);
          fDone:=true;
          exit;
        end;
        try
          s:=base64tobuf(ee.AsString);
          fs:=tFileStream.Create(fQData[2],fmCreate);
          try
            fs.Write(s[1],length(s));
          finally
            fs.free;
          end;
        except
          on e:exception do begin
            doneError('Cant save data to file \"'+fQData[2]+'\"',-1);
            fDone:=true;
            exit;
          end;
        end;
        ee.AsString:=fQData[2];
      end;

      doneResult(e.AsJSON);
      fDone:=true;
    end else begin
      //unknown error
      doneError('Unknown response: '+result.AsJSON,-1);
      fDone:=true;
    end;


  end else if (sender.id=('name_new_step1:'+trim(fQData[0])))  then begin
    //if the name is exist: create error, otherwise call step 2
    e:=result.FindPath('result');
    if e<>nil then
       if e.IsNull then begin
         //create the name!!! if we don't have enough money?

         //fQData[0]:=extractStrPar(0,'name');
         //fQData[1]:=extractStrPar(1,'value');
         //fQData[2]:=inttostr(extractIntPar(2,'days'));
         //fQData[3]:=extractStrPar(3,'toaddress');
         //fQData[4]:=extractStrPar(4,'valuetype');

         if fQData[3]=''
            then address:=base58ToBufCheck(MainForm.eAddress.Text)
            else address:=fQData[3];
         nName:=fQData[0];

         nValue:=decodeValueByType(fQData[1],fQData[4]);

         tx:=tEmerTransaction.create(emerAPI,true);

         try
           tx.addOutput(tx.createNameScript(address,nName,nValue,strtoint(fQData[2]),True),emerAPI.blockChain.MIN_TX_FEE);
           if tx.makeComplete then begin
             if tx.signAllInputs(MainForm.PrivKey) then begin
               //if we has been waiting for too long time for the password, it will be fDone
               if fDone then begin
                 debugConsoleShow('JSON RPC: closed by timeout');
                 fRequestDone:=true;
                 exit;
               end;

               tx.sendToBlockchain(EmerAPINotification(@TxSent,'sent'));
               tx.addNotify(EmerAPINotification(@TxSendingError,'error'));
             end else begin fDone:=true;  doneError('\"'+tx.LastError+'\"',-1);  end; //Can''t sign all transaction inputs using current key
           end else begin fDone:=true;  doneError('\"'+tx.LastError+'\"',-1);  end; //Can''t create transaction:
         except
           on e:exception do begin
             doneError('AsyncRequestDone: name_new error: \"'+e.Message+'\"',-1);
             fDone:=true;
           end;
         end;


         //hexToBuf(e.FindPath('txid').AsString);
         //e.FindPath('name').AsString;
         //e.FindPath('value').AsString;
         //fDaysLeft:=trunc({now() +} e.FindPath('expires_in').AsInt64/175); //LEFT
         //fOwnerAddress:=base58ToBufCheck(e.FindPath('address').AsString); delete(fOwnerAddress,1,1)


       end else begin //name exists
         doneError('Name already exists',-1);
         fDone:=true;
       end
     else begin
        //unknown error
       doneError('Unknown response: '+result.AsJSON,-1);
       fDone:=true;
     end;
//  end else if (sender.id=('name_new_step2:'+trim(fQData[0])))  then begin
//    !!
  end else begin
    //wrong response
    //raise exception.Create('');
    fParent.LastError:='Unknown data for request:'+fRequest.Content;
    fParent.callNotify('error');
  end;
end;

end.

