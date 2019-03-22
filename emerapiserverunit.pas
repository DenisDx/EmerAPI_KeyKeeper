unit EmerAPIServerUnit;

{$mode objfpc}{$H+}
interface

uses Classes, SysUtils , fpjson, EmerAPIBlockchainUnit{Classes}
{$ifdef unix}
,cthreads
,cmem // the c memory manager is on some systems much faster for multi-threading
{$endif}
;




type
tEmerApiServerSettings=record
  //EMERAPI_SERVER_ADDRESS=https://emcdpo.info
  address:string;
  //EMERAPI_SERVER_USER_NAME=
  userName:string;
  //EMERAPI_SERVER_PASSWORD=
  userPass:string;
  //EMERAPI_SERVER_GUEST_ONLY=1
  guest_only:boolean;
  //EMERAPI_SERVER_ADV_LOGIN_SUFFIX=/user/login
  login_suffix:string;
  //EMERAPI_SERVER_ADV_DATA_SUFFIX=/graphql
  data_suffix:string;
  //EMERAPI_SERVER_ADV_LOGIN_FORM_NAME=uname
  login_field_name:string;
  //EMERAPI_SERVER_ADV_PASSWORD_FORM_NAME=ups
  password_field_name:string;
  //EMERAPI_SERVER_ADV_COOKIE_NAME=_yum_l
  cookie_name:string;
  //ssiEmerAPI_Max_simultaneous_connections
  maxSimConn:integer;
  //sssEmerAPI_Server_adv_Query_Field_Name
  queryFieldName:string;
  //
  reconnectTimeOut:integer;
  timeOut:integer;
  networkSig:ansistring;
  //
  pubKey:ansistring; //public key for ECDH exchange
  AESKey:ansistring; //for encripted exchange
  connectUsingUsername:boolean; //use username/pass for connect?
end;

type
 tServerData=record
   serverSettings:tEmerApiServerSettings;
   cookie:ansistring;
 end;
 tpServerData=^tServerData;

 tDecodeDataResult=(ddrSuccesseful,ddrWrongData,ddrWrongPrivKey,ddrWrongAESKey, ddrWrongDatatype);

 tonNeedPrivateKey=function(address:ansistring=''):ansistring of object;

 tEmerApiServer=class;
 tonServerMessage=procedure(sender:tEmerApiServer;data:tJsonData)of object;

 tEmerAPIServerQueryType=(esqUnknown,esqWallet,esqServer);
   //esqWallet : wallet questions
   //esqServer : related to server work (user sequrity, registration...)
 tpServerThreadUserData=^tServerThreadUserData;
 tServerThreadUserData=record
    EmerAPIServerQueryType:tEmerAPIServerQueryType;
 end;


//Performs request. Keeps creds
tEmerApiServer=class(TEmerAPIBlockchain)
private
    //fSessionCookie:ansistring;  //set '' on lost error. fServerData
    //fSessionCookieAsync:ansistring; //async ver set '' on lost error. Set only in SYNC!
    //fServerSettings:tEmerApiServerSettings; //wryte it only if all the thread are stopped... Not so big deal actually
    fServerData:tServerData;
    fWentToPrep:tDateTime;

    fLastServerLoginSalt:ansistring;

    fonNeedPrivateKey: tonNeedPrivateKey;

    fonServerMessage:tonServerMessage;

    procedure setServerSettings(ServerSettings:tEmerApiServerSettings);

    //async
    //procedure writeCookie; //copy fSessionCookieAsync to fSessionCookie. Called using Synconize
    //procedure readCookie; //copy fSessionCookieAsync to fSessionCookie. Called using Synconize
    procedure checkStatus(forceRestore:boolean=false;syncMode:boolean=false); override;
    function login():TEmerAPIBlockchainThread; //adds login  task
    procedure myGetServerData(pdata:pointer{pServerData:tpServerData});
protected
    procedure ThreadError(Thread:TEmerAPIBlockchainThread;error:string); override; //CALLED BY THREAD //caller must handle errors //fOnBlockchainError call
    //for catch login error and others
    procedure ThreadHasData(Thread:TEmerAPIBlockchainThread;var data:string); override; //a handler for thread onAsyncQueryRawDone. CALLED BY THREAD //caller must handle errors
    //for catch login data
    procedure ThreadTerminated(Sender:tObject); override;
public
    property connData:tEmerApiServerSettings read fServerData.ServerSettings write setServerSettings;
    property onNeedPrivateKey:tonNeedPrivateKey read  fonNeedPrivateKey write fonNeedPrivateKey;
    property LastServerLoginSalt:ansistring read fLastServerLoginSalt;

    //property onKeyDataChanged:tNotifyEvent read fonKeyDataChanged write fonKeyDataChanged;
    //property onServerNotifyAddressChanged:tNotifyEvent read fonServerNotifyAddressChanged write fonServerNotifyAddressChanged;
    property onServerMessage:tonServerMessage read fonServerMessage write fonServerMessage;

    procedure throwErrorStatus;

    //tonAsyncQueryDone= procedure(sender:TEmerAPIBlockchainThread;result:tJsonData) of object; //called even have a error(result = nil  then)
    procedure myAddressLoginQueryDone(sender:TEmerAPIBlockchainThread;result:tJsonData); virtual;

    function connectUsingPublicKey(callbackresolver:tonAsyncQueryDone=nil):TEmerAPIBlockchainThread;
    function decodeDataJSON(data:ansistring;out res:tJSONData):tDecodeDataResult; //Decode server data following signature. returns nil if it is not a JSON or can't decrypt
    function decodeData(data:ansistring;out res:ansistring):tDecodeDataResult;
    function decodeResponse(data:ansistring;out res:ansistring):tDecodeDataResult;

    procedure setCookie(cookie:ansistring);

    function sendWalletQueryAsync(method:ansistring;params:tJSONData;callBack:tonAsyncQueryDone=nil;id:string='';forceRecheck:boolean=false):TEmerAPIBlockchainThread; override;

    procedure asyncDoRawRequest(Thread:TEmerAPIBlockchainThread); override;
    constructor Create(serverSettings:tEmerApiServerSettings);
end;



implementation

//uses classesh;
uses fphttpclient, HelperUnit {,Iphttpbroker}, CryptoLib4PascalConnectorUnit, crypto ;

function makeUpMethod(s:ansistring):ansistring;
begin
  result:=lowercase(trim(s));
  while pos('_',result) > 0 do delete(result,pos('_',result),1);
end;


procedure tEmerApiServer.setCookie(cookie:ansistring);
begin
   fServerData.cookie:=cookie;
end;


procedure tEmerApiServer.myAddressLoginQueryDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
var e,js:tJsonData;
    ddr:tDecodeDataResult;
    dData:ansistring;
begin
  fServerData.cookie:='';
  if result=nil then exit;

  e:=result.FindPath('data.userlogin.response');
  if e=nil then exit;


  //{ "data" : { "userlogin" : { "response" : "EmerHEJ_041617d.....4337512d0a326" } } }
  //decode
  ddr:=decodeDataJSON(e.AsString,js);
  try
    if ddr<>ddrSuccesseful then begin
      case ddr of
        //ddrWrongPrivKey: tsServerLoginPanelLabel.Caption:=localizzzeString('MasterPasswordWizardForm.tsServerLoginPanelLabel.WrongPrivKey','Error: wrong private key. Cannot decode server response');
        //ddrWrongAESKey: tsServerLoginPanelLabel.Caption:=localizzzeString('MasterPasswordWizardForm.tsServerLoginPanelLabel.WrongAESKey','Error: wrong AES key. Cannot decode server response');
        ddrWrongPrivKey: fLastError:='AddressLogin:Wrong private key. Cannot decode server response: '+e.AsString;
        ddrWrongAESKey: fLastError:='AddressLogin: Wrong AES key. Cannot decode server response: '+e.AsString;
      else
        //fLastError:=localizzzeString('MasterPasswordWizardForm.tsServerLoginPanelLabel.UnknownResponse','Error: Unknown server response');
        fLastError:='Unknown server response: '+e.AsString;
      end;
    end else begin
        //OK!!!
       //showMessageSafe(js.AsJson);
       { "sid" : "0B033E4C5BB1A9ED", "url" : "https://emcdpo.info/sign-up?token=", "token" : "5c1e26adf3a60864cd8d64c8" }

       //check sid
       e:=js.FindPath('sid');
       if (e=nil) or (e.AsString<>bufToHex(LastServerLoginSalt)) then begin
        fLastError:='AddressLogin: Wrong server response (sid not found): '+js.AsJSON;
        exit;
       end;

       e:=js.FindPath('session_key');
       if e<>nil then fServerData.serverSettings.AESKey:=e.AsString;

       e:=js.FindPath('cookies._yum_l');
       if e<>nil then fServerData.cookie:= '_yum_l='+ansistring(e.AsString);


      if assigned(fonServerMessage) then fonServerMessage(self,js);
    end;

  finally
    if js<>nil then js.free;
  end;

end;

function tEmerApiServer.connectUsingPublicKey(callbackresolver:tonAsyncQueryDone=nil):TEmerAPIBlockchainThread;
//var ud:tpServerThreadUserData;
begin
  result:=nil;
  //start attempt to the server in order to receive encryption key, _yum_l and other data
  fLastServerLoginSalt:=GetRandomChars(8);

  if fServerData.serverSettings.pubKey='' then begin
    fLastError:='public key is not set.';
    exit;
  end;
//    raise exception.create('tEmerApiServer.connectUsingPublicKey: public key is not set.');

  //if callbackresolver=nil then
  //    callbackresolver:=@(self.myAddressLoginQueryDone);
//
  result:=createThread(
   'query { userlogin(request:"'+bufToHex(fLastServerLoginSalt+ fServerData.serverSettings.pubKey {MainForm.getPubKey})+'") { response }}'//method
   ,nil//params
   ,callbackresolver//callBack
   ,'__addresslogin__'+getNextID//id
   );
 //fTasksList.AddObject(result.id,result);
 //checkForReadyToStart;

  {
  result:= sendQueryAsync(
    'query { userlogin(request:"'+bufToHex(fLastServerLoginSalt+ fServerData.serverSettings.pubKey {MainForm.getPubKey})+'") { response }}',
    nil,
    callbackresolver
  );
  }
  if result.userData<>nil then tpServerThreadUserData(result.userData)^.EmerAPIServerQueryType:=esqServer;

end;

function tEmerApiServer.decodeResponse(data:ansistring;out res:ansistring):tDecodeDataResult;
//decode server responce. It could be
//1. Emer**** packet
//2. js.FindPath('data.data.answer'); with Emer**** inside
//3. else just this data , do not decode
var
   js,e:tJSONData;
begin
  res:=data;
  result:=ddrSuccesseful;
  if length(data)<8 then  exit;
  if uppercase(copy(data,1,4))='Emer' then
     result:=decodeData(data,res)
  else begin
    try
      js:=GetJSON(data);
      try
        e:=js.FindPath('data.data.response');
        if e<>nil then
           result:=decodeData(e.AsString,res);
      finally
        js.free;
      end;
    except
      res:=data;
    end;
  end;


end;

function tEmerApiServer.decodeData(data:ansistring;out res:ansistring):tDecodeDataResult;
//decode buffer. Uses first two bytes from the signature.
var
  sData:ansistring;
begin
  res:=data;
  result:=ddrSuccesseful;
  if length(data)<8 then
    exit;
  if (copy(data,1,4))='Emer' then begin
  {
  EmerXxxx
    H: hex data
    C:code64 data
    B:binary data
  EmerxXxx
    E:ECDH + AES-CBC
    A:AES (using session key)
    R:unencrypted
  EmerxxXx
    J:JSON inside
    B: Binary data inside
    T: Plain text inside
    H: Hex-encoded
    C: Base64 encoded
   }
    //(ddrSuccesseful,ddrWrongData,ddrWrongPrivKey,ddrWrongAESKey,ddrBinaryData);

   try
    case data[5] of
      'H':sData:=hexToBuf(copy(data,9,length(data)-8));
      'C':sData:=base64ToBuf(copy(data,9,length(data)-8));
      'B':sData:=copy(data,9,length(data)-8);
    else
      raise exception.Create('tEmerApiServer.decodeData: unsupported signature '+copy(data,1,8));
    end;
   except
     result:= ddrWrongData;
     res:='';
     exit;
   end;

  //decrypt

    if uppercase(copy(data,6,1))='A' then begin
      // use fServerData.serverSettings.AESKey to decrypt JSONM
      if fServerData.serverSettings.AESKey='' then begin
        result:=ddrWrongAESKey;
        res:='';
      end else
      try
        res:=Decrypt_AES256_CBC(sData,fServerData.serverSettings.AESKey);
        result:=ddrSuccesseful;
      except
        result:=ddrWrongAESKey;
        res:='';
      end;
    end else
    if uppercase(copy(data,6,1))='E' then begin
       //encrypted using private key. Call fonNeedPrivateKey
      if assigned(fonNeedPrivateKey) then try
        res:=Decrypt_EC2(sData,fonNeedPrivateKey());
        result:=ddrSuccesseful;
      except
        result:=ddrWrongPrivKey;
        res:='';
      end
      else result:=ddrWrongPrivKey;

    end else
    if uppercase(copy(data,6,1))='R' then begin
       //binary
      res:=sData;
      result:=ddrSuccesseful;
    end else begin
      //raise exception.Create('tEmerApiServer.decodeData: unsupported signature '+copy(data,1,8));
      res:='';
      result:=ddrWrongDatatype;
    end;
  end;

end;

function tEmerApiServer.decodeDataJSON(data:ansistring;out res:tJSONData):tDecodeDataResult;
  //Decode server data following signature. returns nil if it is not a JSON or can't decrypt
  //Emerxxxx
  //;Or json
  //returns nil if error
 //(ddrSuccesseful,ddrWrongData,ddrWrongPrivKey,ddrWrongAESKey,ddrBinaryData);
 var
   dData:ansistring;
begin
  {
  EmerXxxx
    H: hex data
    C:code64 data
    B:binary data
  EmerxXxx
    E:ECDH + AES-CBC
    A:AES (using session key)
    R:unencrypted
  EmerxxXx
    J:JSON inside
    B: Binary data inside
    T: Plain text inside
    H: Hex-encoded binary
    C: Base64 encoded binary
   }
  result:=ddrWrongData;
  res:=nil;

  result:=decodeData(data,dData);

  if dData='' then begin
    result:=ddrWrongData;
    exit;
  end;

  if (copy(data,1,4))='Emer' then
    if uppercase(copy(data,7,1))<>'J' then
    //  raise exception.Create('tEmerApiServerJSON.decodeData: unsupported datatype '+copy(data,1,8));
    begin
      result:=ddrWrongDatatype;
      res:=nil;
      exit;
    end;


  try
    res:=getJSON(dData);
    result:=ddrSuccesseful;
  except
    try
      res:=getJSON(changeNone(dData));
      result:=ddrSuccesseful;
    except
      res:=nil;
      result:=ddrWrongData;
    end;
  end;

end;


function tEmerApiServer.sendWalletQueryAsync(method:ansistring;params:tJSONData;callBack:tonAsyncQueryDone=nil;id:string='';forceRecheck:boolean=false):TEmerAPIBlockchainThread;
var
  ud:tpServerThreadUserData;
begin
  //call Wallet-type query
  result:=sendQueryAsync(method,params,callBack,id,forceRecheck);

  //if self=nil then exit; //D!!?
  if result=nil then exit;

  new(ud);
  ud^.EmerAPIServerQueryType:=esqWallet;
  result.userData:=ud;
end;

function tEmerApiServer.login():TEmerAPIBlockchainThread;
var
  tt:TEmerAPIBlockchainThread;
begin
  //create a TEmerAPIBlockchainThread object
  fServerData.Cookie:='';

  if fServerData.serverSettings.connectUsingUsername
     then result:=createThread('__login__',nil,nil,'__login__'+getNextID)
     else result:=connectUsingPublicKey();
  if result<>nil then
    result.EmerAPIBlockchainThreadType:=ebtPreparation;
end;

procedure tEmerApiServer.throwErrorStatus;
begin
  if fEmerAPIBlockchainStatus=ebsError then fEmerAPIBlockchainStatus:=ebsUnknown;
end;


procedure tEmerApiServer.checkStatus(forceRestore:boolean=false;syncMode:boolean=false); //override;
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
var
   tt:TEmerAPIBlockchainThread;
begin

  if fEmerAPIBlockchainStatus in [ebsNeedPreparation,ebsInPreparation,ebsNeedFinalization,ebsInFinalization] then
    if (now() - fWentToPrep) > (fServerData.serverSettings.reconnectTimeOut/24/60/60)
       then begin//too long time for prep or finalization
         fEmerAPIBlockchainStatus:=ebsError;
         ThreadError(nil,'FROZEN STATUS');
       end;

  if fEmerAPIBlockchainStatus=ebsUnknown then
    if (fServerData.serverSettings.guest_only) or (fServerData.Cookie<>'')
       then fEmerAPIBlockchainStatus:=ebsReady
       //else if fServerData.serverSettings.connectUsingUsername and fServerData.serverSettings.
       else begin
         fEmerAPIBlockchainStatus:=ebsNeedPreparation;
         fWentToPrep:=now();
        end;

  if (fEmerAPIBlockchainStatus=ebsError) then
    if forceRestore then begin
      fEmerAPIBlockchainStatus:=ebsNeedPreparation;
      fWentToPrep:=now();
      //clear all
      fServerData.Cookie:='';
    end else exit;

   if (fEmerAPIBlockchainStatus=ebsNeedPreparation) then begin
     //queueing login
     //ebtPreparation thread must be queued
     tt:=login;
     if tt=nil then begin
        fEmerAPIBlockchainStatus:=ebsError;
        exit;
     end;

     fEmerAPIBlockchainStatus:=ebsInPreparation;
     if syncMode then begin
         tt.Resume;
         tt.FreeOnTerminate:=false; //we need to keeep it in sync mode to have an ability to obtain result
         try
           tt.WaitFor;
           if tt.Result<>'' then try
             fServerData.cookie:=tt.Result;
           except
             on e:exception do fLastError:=e.message;
           end;
         finally
           if tt.Finished then tt.Free else tt.FreeOnTerminate:=true;
         end;
     end else begin
       fTasksList.AddObject(tt.id,tt);
       checkForReadyToStart;

     end;
   end;
end;

procedure tEmerApiServer.setServerSettings(ServerSettings:tEmerApiServerSettings);
begin
 fServerData.serverSettings:=ServerSettings;
end;

procedure tEmerApiServer.ThreadError(Thread:TEmerAPIBlockchainThread;error:string); //CALLED BY THREAD //caller must handle errors //fOnBlockchainError call
begin
  //set cookie='' for login errors
  //changing state
 inherited;
 if (pos('{"errors":[{"message":"User not logged",',error)=1)
    or
    (pos('User session not found',error)=1)
 then begin
   fEmerAPIBlockchainStatus:=ebsNeedPreparation;
   fWentToPrep:=now();
   fServerData.cookie:='';
   if (not fServerData.serverSettings.connectUsingUsername) and (not fServerData.serverSettings.guest_only) {and (not fServerData.serverSettings.)}
     then login();
 end;
 if fEmerAPIBlockchainStatus = ebsInPreparation then
   fEmerAPIBlockchainStatus:=ebsError;
   //    fEmerAPIBlockchainStatus:=ebsNeedPreparation ; ?

 if fEmerAPIBlockchainStatus = ebsInFinalization then
    fEmerAPIBlockchainStatus:=ebsError;



end;

procedure tEmerApiServer.ThreadTerminated(Sender:tObject);
begin
  inherited;
  if not (Sender is TEmerAPIBlockchainThread) then raise exception.Create('tEmerApiServer.ThreadTerminated: internal error 1');
  if (Sender as TEmerAPIBlockchainThread).userData=nil then exit;

  dispose(tpServerThreadUserData((Sender as TEmerAPIBlockchainThread).userData));
end;

procedure tEmerApiServer.ThreadHasData(Thread:TEmerAPIBlockchainThread;var data:string); //a handler for thread onAsyncQueryRawDone. CALLED BY THREAD //caller must handle errors
var ud:tpServerThreadUserData;
    js,e:tJsonData;

    function stripcslashes(s:ansistring):ansistring;
    var i,n:integer;
        sf:boolean;
    begin
      result:='';
      sf:=false;
      setLength(result,length(s));
      n:=1;
      for i:=1 to length(s) do begin
        if (sf) or (s[i]<>'\') then begin
          result[n]:=s[i]; inc(n);
          sf:=false;
        end else sf:=true;
      end;
      setLength(result,n-1);
    end;

    var ddr:tDecodeDataResult;
        dData:ansistring;
begin

  //!!if trim(data)='' then exit;  '' means error. But we will call onDone

  if data<>'' then begin

    ddr:=decodeResponse(data,dData);
    if ddr<>ddrSuccesseful then begin
      //if js<>nil then js.free;
      case ddr of
        ddrWrongPrivKey: raise exception.Create('wrong private key. Cannot decode server response');
        ddrWrongAESKey: raise exception.Create('wrong AES key. Cannot decode server response');
        //ddrBinaryData: raise exception.Create('binary data received. Cannot decode server JSON response');
      else
        raise exception.Create('unknown server response');
      end;
    end;
    data:=dData;


    ud:=tpServerThreadUserData(Thread.userData);
    if ud<>nil then
       if ud^.EmerAPIServerQueryType=esqWallet then begin
         //unpack data
         try
           /// !!!  data:=changeNone(data); //TODO:JSON
           //js:=GetJSON(data);
           // tDecodeDataResult=(ddrSuccesseful,ddrWrongData,ddrWrongPrivKey,ddrWrongAESKey, ddrBinaryData);
           (*
           ddr:=decodeDataJSON(data,js);
           if ddr<>ddrSuccesseful then begin
             if js<>nil then js.free;
             case ddr of
               ddrWrongPrivKey: raise exception.Create('wrong private key. Cannot decode server response');
               ddrWrongAESKey: raise exception.Create('wrong AES key. Cannot decode server response');
               ddrBinaryData: raise exception.Create('binary data received. Cannot decode server JSON response');
             else
               raise exception.Create('unknown server response');
             end;
           end; *)
           js:=GetJSON(data);
           try
             // {"data":{"getblockchaininfo":{"answer":" ......
             //e:=js.FindPath('data.'+makeUpMethod(Thread.method)+'.answer');
             e:=js.FindPath('data.callwalletfunction.answer');
             if e<>nil then
                data:=e.AsString//!!!TEST stripcslashes(e.AsString)
             else begin
               if pos('{"errors":',data)=1 then begin
                 e:=js.FindPath('errors[0].message');
                 if e<>nil then
                    Thread.lastError:=e.AsString
                 else
                    Thread.lastError:='tEmerApiServer.ThreadHasData: Can''t parse error: '+data;
               end else
                 Thread.lastError:='tEmerApiServer.ThreadHasData: Can''t find result in JSON data: '+data;
               ThreadError(Thread,Thread.lastError);
               data:='';
             end;
           //data:=
           finally
             js.Free;
           end;
         except
           Thread.lastError:= 'tEmerApiServer.ThreadHasData: Can''t unpack JSON data: '+data;
           ThreadError(Thread,Thread.lastError);
           data:='';
         end;
       end else begin
           Thread.result:=data;
       end;

  end else begin//if data<>''
   Thread.lastError:= 'tEmerApiServer.ThreadHasData: No data received: ';
   ThreadError(Thread,Thread.lastError);
  end;

  //for catch login data
  if Thread.EmerAPIBlockchainThreadType=ebtPreparation then  begin

    if fServerData.serverSettings.connectUsingUsername
      then fServerData.cookie:=data
      else begin
        try
         js:=GetJSON(data);
         try
           if assigned(Thread.callbackProc) then
              Thread.callbackProc(Thread,js)
           else
              myAddressLoginQueryDone(Thread,js);
           data:=fServerData.cookie;
         except
         end;
         if js<>nil then js.free;
        except
          if js<>nil then js.free;
        end;
        //inherited;
        data:=fServerData.cookie;
      end;
    if data<>'' then
      fEmerAPIBlockchainStatus:= ebsReady
    else
       fEmerAPIBlockchainStatus:= ebsError;
  end else
    inherited;


end;

procedure tEmerApiServer.myGetServerData(pdata:pointer{pServerData:tpServerData});
var pServerData:tpServerData;
begin
  pServerData:=tpServerData(pdata);

  pServerData^.cookie:= fServerData.cookie;

  pServerData^.serverSettings.address:=fServerData.serverSettings.address;
  pServerData^.serverSettings.userName:=fServerData.serverSettings.userName;
  pServerData^.serverSettings.userPass:=fServerData.serverSettings.userPass;
  pServerData^.serverSettings.guest_only:=fServerData.serverSettings.guest_only;
  pServerData^.serverSettings.login_suffix:=fServerData.serverSettings.login_suffix;
  pServerData^.serverSettings.data_suffix:=fServerData.serverSettings.data_suffix;
  pServerData^.serverSettings.login_field_name:=fServerData.serverSettings.login_field_name;
  pServerData^.serverSettings.password_field_name:=fServerData.serverSettings.password_field_name;
  pServerData^.serverSettings.cookie_name:=fServerData.serverSettings.cookie_name;
  pServerData^.serverSettings.maxSimConn:=fServerData.serverSettings.maxSimConn;
  pServerData^.serverSettings.queryFieldName:=fServerData.serverSettings.queryFieldName;

  pServerData^.serverSettings.reconnectTimeOut:=fServerData.serverSettings.reconnectTimeOut;
  pServerData^.serverSettings.timeOut:=fServerData.serverSettings.timeOut;

  pServerData^.serverSettings.networkSig:=fServerData.serverSettings.networkSig;


end;

procedure tEmerApiServer.asyncDoRawRequest(Thread:TEmerAPIBlockchainThread);
var url:string;
    resp:TStringList;
    FormData:TStringList;

    i:integer;
    s:ansistring;
    myServerData:tServerData;

    ud:tpServerThreadUserData;


    function prepareParams(params:tJSONData):ansistring;
    var i,j,n:integer;
        fc:boolean;
        fq:boolean;
    begin
      result:='';
      if params=nil then exit;
      result:=trim(params.asJSON);
      if length(result)<2 then exit;
      if (result[1]='{') and  (result[length(result)]='}') then begin
        delete(result,length(result),1);
        delete(result,1,1);
      end;
      //now unquote names. it means we unquote all    "xxx" :  outside of ""
      i:=1; fc:=false; fq:=false;
      while i<=length(result) do begin
        //looking for ':'. after go back and unquote
        if (result[i]=':') and (not fq) then begin
          //go back
          n:=0;
          j:=i-1;
          while (n<2) and (j>0) do begin
            if result[j]='"' then begin delete(result,j,1); inc(n); end;
            dec(j);
          end;
          i:=i-n;
        end;
        if result[i]='"' then
          if not fq
            then fq:=true
            else if not fc then fq:=false;
          if fq and (not fc) and (result[i]='\')
             then fc:=true
             else fc:=false;
        inc(i);
      end;
    end;
    function prepareParamsNew(params:tJSONData):ansistring;
    var i:integer;
        s:ansistring;
    begin
      result:='';
      if params=nil then exit;
      result:=trim(params.asJSON);
      if length(result)<2 then exit;
      //if (result[1]='{') and  (result[length(result)]='}') then begin
      //  delete(result,length(result),1);
      //  delete(result,1,1);
      //end;
      s:=result; result:='';
      for i:=1 to length(s) do
       if s[i] in ['"','\'] then result:=result+'\'+s[i] else  result:=result+s[i];
    end;

    var myTType:tEmerAPIBlockchainThreadType;
begin
  //ASYNC function!!!
  Thread.Result:='';
  {
  tThread.Synchronize(Thread,@readCookie);  так нельзя! Надо метод потока вызывать!
  видимо надо сделать способ передачи информации owner'у (мы ж его owner!)
  }
  ////////////////////////////////////// go go go //////////////////

  ud:=tpServerThreadUserData(Thread.userData);
  try
    FormData:=TStringList.create;
    resp:=TStringList.create;
    Thread.doSyncCall(@myGetServerData,@myServerData);
    with TFPHTTPClient.Create(nil) do
    try
      //KeepConnection:=false;
      myTType:=Thread.EmerAPIBlockchainThreadType;

      //if it is address login we just use normal way !!!TEMP!!!
      if (myTType=ebtPreparation) and
         (pos('__addresslogin__',Thread.id)=1)
          then myTType:=ebtNormal;


      case myTType of
        ebtNormal:begin
          //building request
          //receiving fSessionCookie to fSessionCookie cookie using syncCall

          url:=myServerData.serverSettings.address+myServerData.serverSettings.data_suffix;

          s:='';

        (*
          query {
           callWalletFunction (method:"method" ,data:"большой json с экранированием"  [,network:"emc:main" | "emc:test"]) {
              answer
            }
          }
         *)

          if (pos('mutation {',trim(Thread.method))<>1) and (pos('query {',trim(Thread.method))<>1) and ((ud=nil) or (ud^.EmerAPIServerQueryType = esqWallet)) then begin
            {
            for i:=0 to length(Thread.params)-1 do
               s:=s+Thread.params[i]+',';
            if length(s)>0 then setLength(s,Length(s)-1);
            }

            //old:
            (*
            if Thread.params<>nil then
              s:=prepareParams(Thread.params);
            if s<>'' then s:='('+s+')';
            s:='query { '+makeUpMethod(Thread.method)+s+' { answer }}';
            *)
            //new:
            if Thread.params<>nil then
              s:=prepareParamsNew(Thread.params);

            if s<>'' then s:=',data:"'+s+'"';

            s:='method:"'+lowercase(trim(Thread.method))+'" '+ s;
            if myServerData.serverSettings.networkSig<>'' then
               s:=s+', network:"'+myServerData.serverSettings.networkSig+'"';

            s:='query { callwalletfunction ('+s+') { answer }}';

          end else s:=trim(Thread.method);


          Cookies.Append(myServerData.Cookie);
          FormData.values[myServerData.serverSettings.queryFieldName] := trim(s);
          FormPost(url,FormData,resp);
          //sleep(10000);
          s:=resp.text;

          if  (pos('{"errors":[{"message":"User not logged",',s)=1) then
              //error!
              Thread.asyncError(s)
          else begin
             Thread.result:=s;
             {if ud=nil then Thread.result:=s
             else begin
               if ud^.EmerAPIServerQueryType=esqWallet then begin
                 sadsad
               end;
             end;
             }
          end;
        end;
        ebtPreparation:begin
          //login
          //parameers:
          //url,uname,ups,cookie

          url:=myServerData.serverSettings.address+myServerData.serverSettings.login_suffix;


          formdata.values[myServerData.serverSettings.login_field_name] := trim(myServerData.serverSettings.userName);
          formdata.values[myServerData.serverSettings.password_field_name] := trim(myServerData.serverSettings.userPass);

          FormPost(url,FormData,resp);
          {for i:=0 to Cookies.Count-1 do
             if pos(myServerData.serverSettings.cookie_name+'=',Cookies[i])>0 then begin
                 result:=Cookies[i];
                 break;
             end;}
          //if true and (result='') then
             for i:=0 to responseheaders.Count-1 do
              if (pos('SET-COOKIE:',ansiuppercase(responseheaders[i]))>0)
                 and
                 (pos(myServerData.serverSettings.cookie_name+'=',responseheaders[i])>0) then begin
                     s:=responseheaders[i];
                     system.delete(s,1,pos(myServerData.serverSettings.cookie_name+'=',s)-1);
                     if pos(';',s)>0 then
                        s:=copy(s,1,pos(';',s)-1);
                     Thread.result:=s;
                 end;
             if Thread.result='' then
               Thread.asyncError('EmerAPIBlockchainThreadType: can''t find cookie in request: Headers:'#10+responseheaders.Text+#10#10'Body:'#10+resp.text);
        end;
      else
        Thread.asyncError('EmerAPIBlockchainServer: is not supported');
      end;
    finally
      Free;
      resp.free;
      formdata.free;
    end;

  except
    on e:exception do begin
      Thread.asyncError(e.Message);
      Thread.result:='';
    end;
  end;
end;

constructor tEmerApiServer.Create(serverSettings:tEmerApiServerSettings);
begin
  inherited Create();
  maxSimConn:=serverSettings.maxSimConn;
  fServerData.serverSettings:=serverSettings;
  fServerData.cookie:='';
end;

(*

function tEmerApiServer.login(Thread:TEmerAPIBlockchainThread):boolean; //called ASYNC!!! Return if success. calls Thread.asyncError(e.Message); on error
var url:string;
    resp:TStringList;
    FormData:TStringList;
    i:integer;
    s:ansistring;
begin

 //.set('Content-Type','application/x-www-form-urlencoded')
 //.set('Access-Control-Allow-Origin','*')
 //.accept('application/json')
 //.send({ 'uname': this.userName, 'ups': this.password})

  url:=trim(Edit1.text)+trim(Edit4.text);

  FormData:=TStringList.create;
  resp:=TStringList.create;
  with TFPHTTPClient.Create(nil) do
  try
    //Post(url,resp);
    //Procedure FormPost(const URL : string; FormData:  TStrings; const Response: TStrings);

    //formdata.values['_token'] := token;
    formdata.values['uname'] := trim(Edit2.Text);
    formdata.values['ups'] := trim(Edit3.Text);

    FormPost(url,FormData,resp);

    Memo1.lines.assign(resp);

    Memo1.lines.append('=========Headers:========');
    Memo1.lines.append(responseheaders.text);
//    edit5.Text:=GetHeader('set-cookie');  //Set-Cookie
//    edit5.Text:=inttostr(IndexOfHeader(responseheaders,'Set-Cookie'));
    //edit5.Text:=GetHeader(responseheaders,'Set-Cookie');
    for i:=0 to Cookies.Count-1 do
       if pos('_yum_l=',Cookies[i])>0 then begin
           edit5.Text:=Cookies[i] ;
           break;
       end;
    if true and (edit5.Text='') then
       for i:=0 to responseheaders.Count-1 do
        if (pos('SET-COOKIE:',ansiuppercase(responseheaders[i]))>0)
           and
           (pos('_yum_l=',responseheaders[i])>0) then begin
               s:=responseheaders[i];
               system.delete(s,1,pos('_yum_l=',s)-1);
               if pos(';',s)>0 then
                  s:=copy(s,1,pos(';',s)-1);
               edit5.Text:=s;
           end;





  finally
    Free;
    resp.free;
  end;
end;

function tEmerApiServer.doEmerApiRequest(Thread:TEmerAPIBlockchainThread;request:ansistring):ansistring;
var url:string;
    resp:TStringList;
    FormData:TStringList;
    waslogged:boolean;
begin
  //Это прототип, потом мы ее перепишем с учетом всего-всего
  waslogged:=sid()<>'';
  if not waslogged then
    if not login() then raise exception.create('There is a problem with login. Please check EmerAPI server settings');


  FormData:=TStringList.create;
  resp:=TStringList.create;

  with TFPHTTPClient.Create(nil) do
  try
    Cookies.Append(sid());
    FormData.values['query'] := trim(request);
    FormPost(getEmerApiUrl('query'),FormData,resp);
    result:=resp.text;
    if waslogged and (pos('{"errors":[{"message":"User not logged",',result)=1) then begin
        //try to relogin
        setsid('');
        result:=doEmerApiRequest(request);
    end;

    //debug:
    if EmerApiTestForm.Visible then begin
      EmerApiTestForm.Memo1.lines.assign(resp);
      EmerApiTestForm.showJson(resp);
      EmerApiTestForm.Memo2.Lines.Text:=request;
    end;

  finally
    Free;
    resp.free;
  end;
end;
*)

end.

