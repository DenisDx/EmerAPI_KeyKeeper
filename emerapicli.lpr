program emerapicli;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp
  ,emerapitypes
  ,Crypto
  ,CryptoLib4PascalConnectorUnit
  ,HDNodeUnit
  ,ClpIX9ECParameters
  ,ClpIECInterface
  ,ClpBigInteger

  ,ClpIAsymmetricCipherKeyPair
  ,ClpIECDomainParameters
  ,ClpECDomainParameters
  ,ClpIECKeyPairGenerator
  ,ClpIECKeyGenerationParameters
  ,ClpCustomNamedCurves
  ,HlpHashFactory
  ,PasswordHelper
  //,ClpSecureRandom
  //,ClpISecureRandom
  ,helperUnit
  ,EmerTX
  ,dateutils
  ,EmerAPITransactionUnit, EmerAPIBlockchainUnit
  { you can add units after this };

type

  { TKeyKeeperCli }

  TKeyKeeperCli = class(TCustomApplication)
  protected
    //data
    netID:char;
    privateKey:ansistring;

    cmdParams:array of string;
    procedure DoRun; override;
  public
    procedure obtainPrivateKey;

    procedure doGetPossessTx(firstPar:integer=1);
    procedure doError(ErrorMsg:string);

    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ TKeyKeeperCli }


procedure TKeyKeeperCli.doError(ErrorMsg:string);
begin
 ShowException(Exception.Create(ErrorMsg));
 Terminate;
end;

procedure TKeyKeeperCli.doGetPossessTx(firstPar:integer=1);
  var getNextParN:integer;
  function getNextPar:ansistring;
  begin
    //if argc
    if length(cmdParams)>getNextParN
       then result:=cmdParams[getNextParN]
       else result:='';
    inc(getNextParN);
  end;

var
  s:ansistring;
  //ftx:tEmerTransaction;
  tx,newtx:ttx;
  i,nOut:integer;
  script:tNameScript;

  newAddress:ansistring;
  newValue:ansistring;

  address:ansistring;
  q:int64;

begin
  //getpossesstx tx [nOut or Name] [newAddress] [newValue]
  getNextParN:=firstPar;

  if privateKey='' then begin doError('getpossesstx: You must set private key'); exit;  end;


  address:= DoRipeMD160(DoSha256(pubKeyToBuf(GetPublicKey(privateKey),true)));
  if address='' then begin doError('getpossesstx: Cant restore address'); exit;  end;



  {//secret
  s:=getNextPar;
  if s='' then begin
    doError('doGetPossessTx: empty secret');
    exit;
  end;

  s:=createDPOPrivKey(s);
  writeln(privKeyToCode58(s));
  }
  s:=getNextPar;
  try
    s:=hexToBuf(s);
  except
    doError('doGetPossessTx: wrong tx data');
    exit;
  end;

  if length(s)<100 then begin doError('doGetPossessTx: wrong tx data'); exit; end;

  //create tx
  try
    tx := unpackTX(s);
  except
    doError('doGetPossessTx: wrong tx data');
    exit;
  end;

  //nOut or name
  s:=getNextPar;
  if s='' then begin
    //autodetect
    nOut:=-1;
    for i:=0 to length(tx.outs)-1 do begin
       script:= nameScriptDecode(tx.outs[i].script);
       if (script.Name<>'') and (address=script.Owner) then begin
         nOut:=i;
         break;
       end;
    end;
    if nOut<0 then begin doError('doGetPossessTx: no names owned by address in this transaction');  exit; end;
  end else begin
    val(s,nOut,i);
    if (i<>0) or (nOut<0) or (nOut>1000) then begin
        //name!
        nOut:=-1;
        for i:=0 to length(tx.outs)-1 do begin
           script:= nameScriptDecode(tx.outs[i].script);
           if script.Name=s then begin
             nOut:=i;
             break;
           end;
        end;
        if nOut<0 then begin doError('doGetPossessTx: no name "'+s+'" in this transaction');  exit; end;
    end;
  end;


  script:= nameScriptDecode(tx.outs[nOut].script);
  if script.Name='' then begin doError('doGetPossessTx: the TXO selected is not a name');  exit; end;

  //ok, we have nOut
  newAddress:=getNextPar;
  if newAddress=''
    then newAddress:=script.Owner
    else newAddress:=addressto20(newAddress);
  if newAddress='' then begin doError('doGetPossessTx: new owner address is not defined or invalid');  exit; end;

  newValue:=getNextPar;
  if newValue='' then newValue:=script.Value;

  //------------build new tx-----------

  if address<>script.Owner then begin doError('doGetPossessTx: wrong name owner');  exit; end;

  q:=tx.outs[nOut].value-100-100;

  //q:=q+100;//!!

  if q<0 then begin doError('doGetPossessTx: The name has no fund for transfer');  exit; end;

  setLength(newtx.ins,1);
  setLength(newtx.outs,1);




  newtx.locktime:=0;
  newtx.time:=winTimeToUnixTime(LocalTimeToUniversal(now()));
  newtx.version:=$666;

  newtx.ins[0].script:='';
  newtx.ins[0].hash:=getTxHash(tx);
  newtx.ins[0].index:=nOut;
  newtx.ins[0].sequence:=DEFAULT_SEQUENCE;
  setLength(newtx.ins[0].witness,0);
  {
      ttxin=packed record
      hash:ansistring;
      index:dword;
      script:ansistring;
      sequence:dword;
      witness: array of ansistring;
  }


  newtx.outs[0].script:=
    opNum('OP_NAME_UPDATE')
    +opNum('OP_DROP')
    + writeScriptData(script.Name)
    +writeScriptIntBuf(0)
    +opNum('OP_2DROP')
    + writeNameData(newValue)
    //spending
    +opNum('OP_DUP') + opNum('OP_HASH160') + writeScriptData(newAddress) + opNum('OP_EQUALVERIFY') + opNum('OP_CHECKSIG');

  newtx.outs[0].value:=100+q;

  newtx.ins[0].script:=signTxIn(newtx,0, privateKey, nil, tx.outs[nOut].script);

  s:=bufToHex(packTX(newtx));
  writeln(s);
end;

{
function TMainForm.loadHDNodeFromBip(var hdNode:tHDNode;bip39:string):boolean; //success?
var s:ansistring;
    mSalt:ansistring;
    mIterCount:dword;
    mSecret:ansistring;
begin
  result:=false;
  HDNode.clear;

  mSalt:=defSsettings_Dev_Bip32_salt;
  mIterCount:=defSsettings_Dev_Bip32_Iter_Count;
  mSecret:=defSsettings_Dev_Bip32_Master_Secret;


  if Settings.getValue('Dev_Mode_ON') then begin
    mSalt := Settings.getValue('Dev_Bip32_salt');
    mIterCount := Settings.getValue('Dev_Bip32_Iter_Count');
    mSecret := Settings.getValue('Dev_Bip32_Master_Secret');
  end;

  s:=createBIP32seed(bip39,mSalt, mIterCount);

  if (length(s)>64) or (length(s)<16) then exit
  else begin

    s:= hmac_sha512(s,mSecret);

    HDNode.loadFromKey(s,getNetwork,0,0,0);
  end;


  if HDNode.depth=0 then begin
     s:='m/0/0';
     if Settings.getValue('Dev_Mode_ON') then s:=Settings.getValue('Dev_Bip32_path');
     HDNode:=HDNode.derive(s);
  end;
  result:=HDNode.isValid;
end;

}

procedure TKeyKeeperCli.obtainPrivateKey;
var hdNode:tHDNode;
    Lcurve :IX9ECParameters;
    Q:IECPoint;
    PrivD,Dmax: TBigInteger;
    ss:ansistring;
    networkData:tnetworkData;
begin
  privateKey:='';

  if HasOption('m', 'master') then begin
    Lcurve := TCustomNamedCurves.GetByName('secp256k1');
    System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');

    Dmax:=TBigInteger.Create('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',16);

    Q:=Lcurve.G;

    {
    ss:=createBIP32seed(myGetBip(myThread.Task),trim(combobox1.Text), strtoint(Edit17.Text));
    if ((length(ss)>64) or (length(ss)<16)) then continue;

    ss:= hmac_sha512(ss,trim(Edit18.Text));


    hdNode.clear;

    networkData.pubKeySig:=chr(strToInt(Edit13.Text));
    networkData.wif:=chr(strToInt(Edit12.Text));
    networkData.bip32.VerPrivate:=myStrToInt(Edit22.Text);
    networkData.bip32.VerPublic:=myStrToInt(Edit23.Text);

    HDNode.loadFromKey(ss,networkData,0,0,0);
    if not HDNode.isValid then !!!;

    HDNode:=HDNode.derive(Edit8.Text); //s/0/0
    if not myThread.HDNode.isValid then continue;
    }
    doError('bip39 not supported');
  end else
  if HasOption('p', 'private') then begin
    try
      privateKey:=base58ToBufCheck(GetOptionValue('p', 'private'));
    except
      doError('Wrong private key');
    end;

    if length(privateKey)<33 then doError('Wrong private key');

    if netID<>#0 then
      if netID<>privateKey[1] then doError('Wrong private key network');

    privateKey:=loadPrivateKeyFromBuf(privateKey);

    if privateKey='' then doError('Wrong private key');
  end else
  if HasOption('s', 'secret') then
    privateKey:=doSha256(GetOptionValue('s', 'secret'))
  else
  if HasOption('a', 'afsecret') then
    privateKey:=createDPOPrivKey(GetOptionValue('a', 'afsecret'));


  if not checkPrivKey(privateKey) then doError('Wrong private key');
end;

procedure TKeyKeeperCli.DoRun;
var
  ErrorMsg: String;
  dellme:tEmerTransaction;
const
  loptShort='hs:a:p:m:';
  loptLong : array [1..5] of string = ('help', 'secret:', 'afsecret:', 'private:', 'master:');
begin
  // quick check parameters
  ErrorMsg:=CheckOptions(loptShort, loptLong);
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  cmdParams:=GetNonOptions(loptShort,loptLong);

  { add your program here }
  if length(cmdParams)=0 then doError('no commands. see -h --help the see the list');

  //detect privateKey
  obtainPrivateKey;


  if lowercase(cmdParams[0])='getpossesstx' then doGetPossessTx()

  ;
   //doError('test'); exit;

  // stop program loop
  Terminate;
end;

constructor TKeyKeeperCli.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;

  netID:=#0;
end;

destructor TKeyKeeperCli.Destroy;
begin
  //sleep(3000);
  inherited Destroy;
end;

procedure TKeyKeeperCli.WriteHelp;
begin
  { add your help code here }
  writeln('Help usage: ', ExeName, ' -h');
  writeln('-------------commands------------');
  writeln(ExeName,' getpossesstx tx [nOut or Name] [newAddress] [newValue]', ' : returns TX changing the name created by nOut output of the tx. Use -a|-s|-p to obtain private key. nOut is first name utxo by default');
  writeln('-------------private key restore options------------');
  writeln('-s <secret> | --secret <secret> : obtain the private key as sha256 hash of the secret');
  writeln('-a <secret> | --af_secret <secret> : obtain the private key as 32k sha256 hashes of the secret');
  writeln('-p <privkey> | --private_key <privkey> : set the privkey');
  writeln('-m <masterpass> | --master <masterpass> : set the privkey based on the master password');
end;

var
  Application: TKeyKeeperCli;
begin
  //{$IFDEF WINDOWS}
  //SetConsoleOutputCP(CP_UTF8);
  //{$ENDIF}
  Application:=TKeyKeeperCli.Create(nil);
  Application.Title:='EmerAPI KeyKeeper Console Client';
  Application.Run;
  Application.Free;
end.

