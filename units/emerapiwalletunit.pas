unit EmerAPIWalletUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, EmerAPIBlockchainUnit, fphttpclient;

type
tWalletConnectionData=record
  port:integer;
  userName:ansistring;
  userPass:ansistring;
  UseHTTPS:boolean;
  address:ansistring;
  maxSimConn:integer;
end;

//Performs request. Keeps creds
tEmerApiLocalWallet=class(TEmerAPIBlockchain)
private
    fWalletSettings:tWalletConnectionData;
    procedure setWalletSettings(WalletSettings:tWalletConnectionData);
public
    property connData:tWalletConnectionData read fWalletSettings write setWalletSettings;
    procedure asyncDoRawRequest(Thread:TEmerAPIBlockchainThread); override;
    constructor Create(WalletSettings:tWalletConnectionData);
end;



implementation
procedure tEmerApiLocalWallet.setWalletSettings(WalletSettings:tWalletConnectionData);
begin
  fWalletSettings:=WalletSettings;
end;

function checkParam(s:ansistring):ansistring;
begin
  if length(s)=0 then s:='""' else
  if (pos('[',s)<1) and (pos('{',s)<1) and (pos('"',s)<1) and (pos('''',s)<1) then
    //if not a digit or bool then add quotes
    if (not (s[1] in ['+','-','0'..'9'])) and (trim(ansiuppercase(s))<>'TRUE') and (trim(ansiuppercase(s))<>'FALSE')
      then s:='"'+s+'"';
  result:=s;
end;


procedure tEmerApiLocalWallet.asyncDoRawRequest(Thread:TEmerAPIBlockchainThread);
var url:string;
    resp:TStringList;
 //   FormData:TStringList;
    //mycookies:TStringList;
    client:TFPHTTPClient;
    ms:tMemoryStream;
    s:ansistring;
    i:integer;
begin
  //ASYNC function!!!
  Thread.Result:='';

  s:='';

  //if the param
  {for i:=0 to length(Thread.params) -1 do
    s:=s+checkParam(Thread.params[i])+',';
  if length(s)>0 then delete(s,length(s),1); //last comma
  }
  if Thread.params<>nil then
    s:=Thread.params.AsJSON;

   if s='' then s:='[]';
   s:='"method":"'+trim(Thread.method)+'","params":'+s+'';

  //if pos(',',methodAndParams)<1 then //it's single method
  //  //"method":"getblockchaininfo","params":[]
  //  methodAndParams:='"method":'+checkParam(methodAndParams)+',"params":[]';
  s:='{"jsonrpc":"1.0","id":"'+getNextID+'",'+s+'}';


//===sending request s================


  if connData.UseHTTPS then url:='https://' else url:='http://';

  if trim(connData.address) = '' then url:=url+'localhost' else url:=url+trim(connData.address);

  url:=url+':'+inttostr(connData.port);


 // FormData:=TStringList.create;
  resp:=TStringList.create;
  //mycookies:=TStringList.create;
  client:=TFPHTTPClient.Create(nil);
  try

    client.username := trim(connData.userName);
    client.password := trim(connData.userPass);

    client.AddHeader('Set-Type','application/json-rpc');

    ms:=tMemoryStream.Create;
    try
      ms.Write(s[1],length(s));
      ms.Position:=0;
      client.Requestbody:=ms;
      try
        client.Post(url,resp);
      except
        on e:exception do begin
          Thread.result:='';
          Thread.asyncError(e.Message);
          //!setTestOk(false);
        end;
      end;
    finally
      ms.Free;
    end;

    {"jsonrpc":"1.0","id":"livetext","method":"getblockchaininfo","params":[]}
    {"jsonrpc": "1.0", "id":"curltest", "method":"scantxoutset","params":["start", [{"script" : "76A914CED2436C4D0169B69E8E71C413DC5C5B20F5376388AC" }]]}

    s:=resp.Text;

    //call
    Thread.Result:=s;
    //s:=changeNone(s);
    //Thread.result:=GetJSON(s);

  finally
 //   FormData.free;
    client.Free;
    resp.free;
    //mycookies.free;
  end;

end;

constructor tEmerApiLocalWallet.Create(WalletSettings:tWalletConnectionData);
begin
  inherited Create();
  fWalletSettings:=WalletSettings;
  maxSimConn:=WalletSettings.maxSimConn;
end;

end.

