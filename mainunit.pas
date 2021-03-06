unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynHighlighterAny, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Menus, ExtCtrls, Buttons, ComCtrls, Spin, CheckLst, // UOpenSSL, UOpenSSLdef,
  Crypto, fpjson, jsonparser, EmerAPIBlockchainMergedUnit,
  EmerAPIBlockchainUnit, EmerAPIMain, emerapitypes,
  CryptoLib4PascalConnectorUnit, EmerAPIServerTasksUnit, FrameServerTaskUnit,
  HDNodeUnit, EmerAPIServerUnit, SynEditHighlighter, SynHighlighterHTML,
  synhighlighterunixshellscript, SynEmerNVS

  ,jsonrpc
  ;

type
  tglobals=record
    WifID:char;
    AddressSig:char;
  end;

  pDebugRecord=^tDebugRecord;
  tDebugRecord=record
    count:integer;
    lastStart:dword;
    value:dword;
  end;

  { TMainForm }

  TMainForm = class(TForm)
    bCopyAddress: TBitBtn;
    bAssetsFilterRebuild: TBitBtn;
    bRegisterServer1: TBitBtn;
    bPay: TBitBtn;
    BitBtn1: TBitBtn;
    bRefreshBalance: TBitBtn;
    bRefreshTasks: TBitBtn;
    bRegisterServer2: TBitBtn;
    bRegisterMasterPassword: TBitBtn;
    bShowQR: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button5: TButton;
    Button6: TButton;
    bViewTX: TBitBtn;
    bViewTasks: TBitBtn;
    bCreateAsset: TBitBtn;
    chAssetsFilterShowExpired: TCheckBox;
    chDevBeautyJSON: TCheckBox;
    chDevBeautyHTML: TCheckBox;
    ilAdvCon: TImageList;
    miSetOpenNic: TMenuItem;
    pAssetsFilterNames: TCheckListBox;
    eAddress: TEdit;
    eBalance: TEdit;
    eNamesCount: TEdit;
    eTasksCount: TEdit;
    gbHint: TGroupBox;
    gbLog: TGroupBox;
    gbTest: TGroupBox;
    ilLamps: TImageList;
    imLW: TImage;
    imPK: TImage;
    imServer: TImage;
    lAssetsFilter: TLabel;
    lAssetsFilterShowFirst: TLabel;
    lRegisterOnServer: TLabel;
    lEmerAPIServer: TLabel;
    lPrivateKey: TLabel;
    lLocalWallet: TLabel;
    lAddress: TLabel;
    lBalance: TLabel;
    lNames: TLabel;
    lRegisterMasterPassword: TLabel;
    lRegisterServerComment1: TLabel;
    lRegisterServerComment2: TLabel;
    lRegisterOnServerCmt: TLabel;
    lRegisterOnServer2: TLabel;
    lTasks: TLabel;
    MainMenu: TMainMenu;
    imAFCreateForPrinting: TMenuItem;
    miBecomeOwner: TMenuItem;
    miCreatePubLotFile: TMenuItem;
    miCreatePrivateLotFile: TMenuItem;
    miLotFiles: TMenuItem;
    miSystem: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    miExit: TMenuItem;
    miEncryption: TMenuItem;
    miTX: TMenuItem;
    miLog: TMenuItem;
    miConsole: TMenuItem;
    miOpenWeb: TMenuItem;
    miMemPool: TMenuItem;
    miWalletMassSend: TMenuItem;
    miWalletAtom: TMenuItem;
    miAbout: TMenuItem;
    miWalletName: TMenuItem;
    miSimulateAction: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem32: TMenuItem;
    MenuItem33: TMenuItem;
    MenuItem34: TMenuItem;
    miCheckSignature: TMenuItem;
    miSignMessage: TMenuItem;
    MenuItem9: TMenuItem;
    miDevTools: TMenuItem;
    miAntifake: TMenuItem;
    miSettings: TMenuItem;
    miServer: TMenuItem;
    miTools: TMenuItem;
    miWallet: TMenuItem;
    miWalletTransfer: TMenuItem;
    MenuItem8: TMenuItem;
    mLog: TMemo;
    Panel1: TPanel;
    pAssetsFilterTop: TPanel;
    pAssetsFilterDetails: TPanel;
    pAssetsFilter: TPanel;
    pRegisterMasterPassword: TPanel;
    pRegisterOnServer: TPanel;
    pcMain: TPageControl;
    pMain: TPanel;
    pTop: TPanel;
    sbActions: TScrollBox;
    sbAssetsFilterAdCon: TSpeedButton;
    sbLW: TSpeedButton;
    sbPK: TSpeedButton;
    sbAssets: TScrollBox;
    sbServer: TSpeedButton;
    ScrollBox2: TScrollBox;
    seAssetsFilterShowFirst: TSpinEdit;
    Splitter1: TSplitter;
    realignTimer: TTimer;
    RebuildAssetsListTimer: TTimer;
    TimerEmerAPIServerTasksUpdated: TTimer;
    TimerStatusUpdate: TTimer;
    tsAssets: TTabSheet;
    tsActions: TTabSheet;
    tShowMessageSafe: TTimer;
    tLockMP: TTimer;
    timerAskForMP: TTimer;
    timerAskForLib: TTimer;
    updateInfoTimer: TTimer;
    procedure bAssetsFilterRebuildClick(Sender: TObject);
    procedure bCopyAddressClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure bRefreshBalanceClick(Sender: TObject);
    procedure bRefreshTasksClick(Sender: TObject);
    procedure bRegisterMasterPasswordClick(Sender: TObject);
    procedure bRegisterServer1Click(Sender: TObject);
    procedure bRegisterServer2Click(Sender: TObject);
    procedure bShowQRClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure bViewTasksClick(Sender: TObject);
    procedure bViewTXClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    function FormHelp(Command: Word; Data: PtrInt; var CallHelp: Boolean
      ): Boolean;
    procedure imAFCreateForPrintingClick(Sender: TObject);
    procedure KeyUpAppHandler(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure JSONRPCServerThreadErrorHandler(Sender:tObject);
    procedure checkJSONRPCserver;
    procedure miBecomeOwnerClick(Sender: TObject);
    procedure miLotFilesClick(Sender: TObject);
    procedure miEncryptionClick(Sender: TObject);
    procedure miSetOpenNicClick(Sender: TObject);
    procedure miTXClick(Sender: TObject);
    procedure miLogClick(Sender: TObject);
    procedure miConsoleClick(Sender: TObject);
    procedure miOpenWebClick(Sender: TObject);
    procedure miMemPoolClick(Sender: TObject);
    procedure miWalletMassSendClick(Sender: TObject);
    procedure miWalletAtomClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miWalletNameClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure MenuItem32Click(Sender: TObject);
    procedure MenuItem33Click(Sender: TObject);
    procedure MenuItem34Click(Sender: TObject);
    procedure miWalletTransferClick(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure miCheckSignatureClick(Sender: TObject);
    procedure miSettingsClick(Sender: TObject);
    procedure miSignMessageClick(Sender: TObject);
    procedure pcMainChange(Sender: TObject);
    procedure realignTimerTimer(Sender: TObject);
    procedure RebuildAssetsListTimerTimer(Sender: TObject);
    procedure sbAssetsFilterAdConClick(Sender: TObject);
    procedure sbLWClick(Sender: TObject);
    procedure sbPKClick(Sender: TObject);
    procedure sbServerClick(Sender: TObject);
    procedure timerAskForLibTimer(Sender: TObject);
    procedure timerAskForMPTimer(Sender: TObject);
    function SetAndCheckBlockchain(local:boolean=true;server:boolean=true;forceRecheck:boolean=false):boolean;
    procedure onWalletDisconnected(sender:tObject);
    procedure onWalletConnected(sender:tObject);
    procedure onServerDisconnected(sender:tObject);
    procedure onBlockchainUpdated(sender:tObject);
    procedure onServerConnected(sender:tObject);
    procedure EmerAPIServerTasksUpdated(sender:tObject);
    procedure TimerEmerAPIServerTasksUpdatedTimer(Sender: TObject);
    procedure TimerStatusUpdateTimer(Sender: TObject);
    procedure UTXOUpdated(sender:tObject);
    procedure tLockMPTimer(Sender: TObject);
    procedure tShowMessageSafeTimer(Sender: TObject);
    procedure updateInfoTimerTimer(Sender: TObject);
    procedure updatePKstate(sender:tObject);
    function getPubKey(compressed:boolean=true):ansistring;
    procedure showWalletInfo();
    procedure RebuildAssetsList(Sender: TObject);
  private
    //fPrivKey:PEC_KEY;
    EmerAPIServerTasks:tEmerAPIServerTaskList;  //userObj1
    //fPrivKey:ansistring;
    fHDNode:tHDNode;

    fLastOpenURLLing:string;

    fonAnswerDataWif:ansistring;
    fonAnswerDataSig:ansistring;
    fonAnswerDataNet:ansistring;

    emerAPIisReadyWaitCounter:integer;

    pAssetsFilterDetailsHeight:integer;

    needShowInvalidNamesUTXOCache:tStringList; //list of the UTXOs names knows as valid

    //!!procedure setPrivKey(value:ansistring);
    procedure onAnswer(sender:tObject;mr:tModalResult;mtag:ansistring);
    procedure onAnswerTools(sender:tObject;mr:tModalResult;mtag:ansistring);
    procedure clearPrivKey;
    procedure AsyncAddressInfoDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
    procedure blockChainonAsyncQueryRawDone(sender:TEmerAPIBlockchainThread;result:string);
    procedure serverMessageReceived(sender:tEmerApiServer;data:tJsonData);
    procedure BlockchainErrorHandler(sender:TEmerAPIBlockchainThread;error:string);
    procedure BlockchainBeforeSendHandler(sender:TEmerAPIBlockchainThread;data:string);
    procedure walletInformationUpdated(Sender:tObject);

  public
    debugMeasures:tStringList;
    JSONRPCServer:TJSONRPCServer;
    procedure debugCleanMeasures;
    procedure debugShowLastMeasure;
    procedure debugStart(atag:string);
    procedure debugStop(atag:string);

    procedure queryForNetworkSettings(wif,adrsig:byte; netstr:string);

    function removeNameAndUpdate(NVSname:ansistring):boolean;
    function getPrivKey(address:ansistring=''):ansistring;
    function getMainPrivKey:ansistring;
    function loadHDNodeFromBip(bip39:string):boolean; overload; //success?
    function loadHDNodeFromBip(var hdNode:tHDNode;bip39:string):boolean; overload; //success?
    function globals():tglobals;
    function getNetwork:tNetworkData;
    procedure deletePrivKey;
    property PrivKey:ansistring read getMainPrivKey; //write setPrivKey;
    procedure CheckAdvices(Sender:tObject);
  end;

var
  MainForm: TMainForm;
  //LocalWallet:tLocalWallet=nil;
  //blockChain:tEmerAPIBlockchainMerged=nil;
  emerAPI:tEmerAPI;


function globals: tglobals;
procedure ShowLogErrorMessage(msg:string);
procedure ShowLogMessage(msg:string);

procedure showMessageSafe(msg:string);

function getNameColor(op:ansistring):tColor;

function isMyAddress(Address:ansistring):boolean;

procedure setSynHighliterByName(SynEmerNVSSyn:TSynEmerNVSSyn;name:ansistring);

function MasterPasswordValid(s:string;legacy:boolean=false):boolean;

implementation

{$R *.lfm}
uses SettingsUnit,Localizzzeunit, questionUnit, MasterPasswordWizardUnit, setUPUnit, askForUPUnit, HelperUnit, EmerAPIWalletUnit, DebugConsoleUnit

   ,createRawTXUnit,unitcryptotest, EmerAPIDebugConsoleUnit, WalletBasicsUnit, UTXOunit, MempoolViewerUnit, MempoolViewerUnit2, passwordHelper
   , LCLIntf
   ,masssendingunit
   ,FrameBaseNVSUnit,FrameDigitalAssetUnit
   ,AtomFormUnit
   ,FormAboutUnit
   ,Clipbrd
   ,HelpRedirector
   ,SignMessageUnit
   ,CheckSignatureUnit
   ,x509devunit
   ,addressQRunit
   ,AFCreateForPrintingUnit
   ,TakePossessionUnit
   ,NVSRecordUnit,BaseTXUnit
   ,math
   ,AntifakeHelperUnit
   ,TranslationHelperUnit
   ,LCLType
   ,RunCmdUnit
   ,fphttpclient //,fasthtmlparser
   {$IFDEF Windows}
   ,ShellApi
   {$ENDIF Windows}

   ;

function MasterPasswordValid(s:string;legacy:boolean=false):boolean;
  var PrivateKey:ansistring;
      pubKey:TECDSA_Public;
      hd:tHDNode;
begin
  if legacy then begin
    result:=false;
    PrivateKey:='';
    if trim(s)<>'' then
    PrivateKey:=DoSha256(trim(s));
    pubKey:=GetPublicKey(PrivateKey);
    result:= not ((length(pubkey.x)<>32) or (length(pubkey.y)<>32));
  end else begin
    result:=mainForm.loadHDNodeFromBip(hd,smartExtractBIP32pass(trim(s)))
  end;
end;


procedure setSynHighliterByName(SynEmerNVSSyn:TSynEmerNVSSyn;name:ansistring);
var pref:ansistring;
    i:integer;
begin
  if SynEmerNVSSyn=nil then exit;

  i:=pos(':',name);
  if i<1 then pref:=''
  else begin
    pref:=copy(name,1,i-1);
    delete(name,1,i);
  end;

  if pref='dns' then
    SynEmerNVSSyn.Mode:=senmDNS
  else if pref='ssh' then
    SynEmerNVSSyn.Mode:=senmSSH
  else if pref='ssl' then
    SynEmerNVSSyn.Mode:=senmSSL
  else if pref='enum' then
    SynEmerNVSSyn.Mode:=senmENUMER
  else if (pref='dpo') and (pos(':',name)<1) then
    SynEmerNVSSyn.Mode:=senmDPORoot
  else if pref='dpo' then
    SynEmerNVSSyn.Mode:=senmDPO
  else if pref='doc' then
    SynEmerNVSSyn.Mode:=senmDOC
  else if pref='cert' then
    SynEmerNVSSyn.Mode:=senmCERT
  else
    SynEmerNVSSyn.Mode:=senmAny;



end;


var taskCounterCounter:integer=1;
function taskCounter:string;
begin
  result:=inttostr(taskCounterCounter); inc(taskCounterCounter);
end;

function isMyAddress(Address:ansistring):boolean;
begin
  //check my addresses list
  result:=addressTo58(Address,globals.AddressSig)=MainForm.eAddress.text;
end;

function getNameColor(op:ansistring):tColor;
begin

  //it can be full name of just prefix
  if pos('af:',op)=1 then begin
    delete(op,1,3);
    if pos(':',op)>0 then op:=copy(op,1,pos(':',op)-1);
    op:='af:'+op;
  end else if pos(':',op)>0 then begin
    //not af. Just cut all
    op:=copy(op,1,pos(':',op)-1);
  end;


  result:=clWhite;
  if      uppercase(trim(op))='PAY'         then result:=RGBToColor($F0,$F0,$A0)
  else if uppercase(trim(op))='PAY_TO_MYSELF'    then result:=RGBToColor($A0,$F0,$A0)
  else if uppercase(trim(op))='NEW_NAME'    then result:=RGBToColor($A0,$F0,$E0)
  else if uppercase(trim(op))='UPDATE_NAME'    then result:=RGBToColor($A0,$C0,$F0)
  else if uppercase(trim(op))='TRANSFER_NAME'    then result:=RGBToColor($A0,$F0,$F0)
  else if uppercase(trim(op))='DELETE_NAME'    then result:=RGBToColor($F0,$E0,$E0)
  else if uppercase(trim(op))='PROLONG_NAME'    then result:=RGBToColor($F0,$F0,$C0)

  else if uppercase(trim(op))='EXECUTION'    then result:=RGBToColor($C0,$C0,$C0)
  else if uppercase(trim(op))='EXECUTIONFAILED'    then result:=RGBToColor($D0,$20,$20)

  //PAY - платежная
  //NEW_NAME - новое имя
  //UPDATE_NAME - апдейт существующего
  //TRANSFER_NAME - передача имени
  //DELETE_NAME - удаление имени
  //PROLONG_NAME - продлить аренду имени

  //Asset colors
  else if trim(op)='dns'    then result:=RGBToColor($C0,$D0,$F0)
  else if trim(op)='ssh'    then result:=RGBToColor($F0,$C0,$F0)
  else if trim(op)='ssl'    then result:=RGBToColor($F0,$F0,$C0)
  else if trim(op)='dpo'    then result:=RGBToColor($E0,$F0,$E0)
  else if trim(op)='doc'    then result:=RGBToColor($D0,$C0,$F0)
  else if trim(op)='cert'    then result:=RGBToColor($A0,$F0,$D0)
  else if trim(op)='blog'    then result:=RGBToColor($80,$D0,$A0)
  else if trim(op)='enum'    then result:=RGBToColor($A0,$D0,$80)

  //af objects
  else if trim(op)='af:lot'    then result:=RGBToColor($E0,$E0,$F0)
  else if trim(op)='af:product'    then result:=RGBToColor($F0,$E0,$E0)
  else if trim(op)='af:owner'    then result:=RGBToColor($E0,$F0,$F0)

  //AF
  else if uppercase(trim(op))='AF_UNKNOWN'    then result:=RGBToColor($C0,$C0,$C0)
  else if uppercase(trim(op))='AF_BRAND'    then result:=RGBToColor($FF,$C0,$E0)
  else if uppercase(trim(op))='AF_PRODUCER'    then result:=RGBToColor($D0,$F0,$C0)
  else if uppercase(trim(op))='AF_DISTRIBUTOR'    then result:=RGBToColor($F0,$D0,$C0)
  else if uppercase(trim(op))='AF_PRODUCT'    then result:=RGBToColor($C0,$E0,$C0)
  else if uppercase(trim(op))='AF_LOT'    then result:=RGBToColor($E0,$E0,$F0)

  //else if trim(op)=''    then result:=RGBToColor($A0,$A0,$A0)

  else if trim(op)='TASK_VALID_UNKNOWN' then result:=RGBToColor($A0,$A0,$A0)
  else if trim(op)='TASK_INVALID' then result:=RGBToColor($F0,$20,$20)
  else if trim(op)='TASK_PARTIAL_VALID' then result:=RGBToColor($A0,$80,$80)

  else if trim(op)='*expired*' then result:=RGBToColor($C0,$A0,$A0)
  else if trim(op)='*expiresoon*' then result:=RGBToColor($C0,$C0,$A0)


end;



var showMessagePool:array of String = nil;
procedure showMessageSafe(msg:string);
begin
  setLength(showMessagePool,length(showMessagePool)+1);
  showMessagePool[length(showMessagePool)-1]:=msg;
  MainForm.tShowMessageSafe.enabled:=true;
end;

function globals():tglobals;
begin
  result:=MainForm.globals;
end;

function TMainForm.globals():tglobals;
begin
   //! брать из blockchain
  if emerAPI<>nil then begin
    result.WifID:=emerAPI.blockChain.WifID;
    result.AddressSig:=emerAPI.blockChain.AddressSig;
    exit;
  end;
  result.WifID:=#$80;
  result.AddressSig:=#$21;
end;

function TMainForm.getNetwork:tNetworkData;
begin
  result.wif:=#$80;
  result.pubKeySig:=#$21;
  result.bip32.VerPrivate:=defSsettings_Dev_Bip32_SigPrivate;
  result.bip32.VerPublic:=defSsettings_Dev_Bip32_SigPublic;

  if Settings.getValue('Dev_Mode_ON') then begin
    result.wif:=chr(strToInt(settings.getValue('Dev_WIF')));
    result.pubKeySig:=chr(strToInt(settings.getValue('Dev_SIG')));
    result.bip32.VerPrivate:=myStrToInt(settings.getValue('Dev_Bip32_SigPrivate'));
    result.bip32.VerPublic:=myStrToInt(settings.getValue('Dev_Bip32_SigPublic'));
  end;

end;

procedure ShowLogErrorMessage(msg:string);
begin
  MainForm.mLog.Lines.Append('ERROR: '+datetimetostr(now())+': '+msg);
end;

procedure ShowLogMessage(msg:string);
begin
  MainForm.mLog.Lines.Append(datetimetostr(now())+': '+msg);
end;


{ TMainForm }

function TMainForm.loadHDNodeFromBip(bip39:string):boolean; //success?
begin
  result:=loadHDNodeFromBip(fHDNode,bip39);
end;

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

function TMainForm.getMainPrivKey:ansistring;
begin
  result:=getPrivKey();
end;

function TMainForm.getPrivKey(address:ansistring=''):ansistring;
var s,ss:ansistring;
    decKey:ansistring;
begin

  //TODO: сделать возврат не только m/0/0, но и других ключей по адресу. Можем просто перебором фигачить на крайняк, например, 100 шагов макс
  result:='';
  tLockMP.Enabled:=false;
  if fHDNode.isValid then begin
    result:=fHDNode.getPrivateKey;
    tLockMP.Interval:=Settings.getValue('LockKPAfterMin')*60*1000;
    tLockMP.Enabled:=Settings.getValue('LockKPAfter');
    exit;
  end;
  if Settings.PrivKey<>'' then begin
      s:=askForUP();
      while s<>'' do
      begin
        try
          decKey:=Decrypt_AES256(Settings.PrivKey,s);
        except
          s:='';
        end;

        if s='' then s:=askForUP('AskForUPForm.WrongPassword')
        else
        begin
          try
            s:=base58ToBufCheck(decKey);
          except
            exit;
          end;


          //extended key m: 78 bytes or short key: len 33
          if length(s)=78 then begin
            //hd key
            fHDNode.loadFromCode58(decKey,getNetwork);

            //check network
            //if getNetwork.wif<>fHDNode.Network.wif
            //  then raise exception.create('Wrong wif signature.');

            if fHDNode.depth=0 then begin
               ss:='m/0/0';
               if Settings.getValue('Dev_Mode_ON') then ss:=Settings.getValue('Dev_Bip32_path');
               fHDNode:=fHDNode.derive(ss);
            end;
            result:=fHDNode.getPrivateKey;
          end else
          if length(s) in [32,33,34] then begin
              if (s[1]<>globals.WifID) and (not Settings.getValue('Dev_Mode_ON')) //Allow network changing for dev mode
                then raise exception.create('Wrong wif signature.');
              delete(s,1,1);//удаляем сингатуру

              if not (((length(s)=33) and (s[33]=#1)) or (length(s)=32))
                 then raise exception.create('wrong private key size');

              if not ((length(s)=33) and (s[33]=#1)) then raise exception.Create('Only compressed private keys supported');

              fHDNode.loadFromKey(copy(s,1,32)+stringOfChar(#0,32),getNetwork,0,0,0);
                //fPrivKey:=CreatePrivateKeyFromStrBuf(s);
              result:=fHDNode.getPrivateKey;
          end else fHDNode.clear;
          updatePKstate(nil);
          tLockMP.Interval:=Settings.getValue('LockKPAfterMin')*60*1000;
          tLockMP.Enabled:=Settings.getValue('LockKPAfter');

          s:='';//for exit
        end;

      end;
  end;

end;

procedure TMainForm.clearPrivKey;
begin
  fHDNode.clear;
  updatePKstate(self);
end;
{
procedure TMainForm.setPrivKey(value:ansistring);
begin
  fPrivKey:=value;

  updatePKstate(self);

end;
}

procedure TMainForm.deletePrivKey;
var i:integer;
begin
  //!  if fPrivKey='' then exit;
  //BN_clear(fPrivKey^.priv_key);
  //EC_KEY_free(fPrivKey);
  //!  for i:=1 to length(fPrivKey) do fPrivKey[i]:=chr(i mod 123);

  clearPrivKey;

//!  setPrivKey('');
 // updatePKstate(nil);
end;

procedure TMainForm.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.MenuItem32Click(Sender: TObject);
begin
  queryForNetworkSettings(
  $80,      //wif
  $21,      //address
  'emc:main'  //net sign
  )
end;

procedure TMainForm.MenuItem33Click(Sender: TObject);
begin
  queryForNetworkSettings(
  $EF, //wif
  $6F, //address
  'emc:test'//net sign
  )

end;

procedure TMainForm.MenuItem34Click(Sender: TObject);
begin
  if x509devform=nil then
    Application.CreateForm(Tx509devform, x509devform);

  x509devform.Show;
end;

procedure TMainForm.miWalletTransferClick(Sender: TObject);
begin
  WalletBasicsForm.PageControl1.PageIndex:=0;
  if not WalletBasicsForm.Visible
     then WalletBasicsForm.Show
     else WalletBasicsForm.SetFocus;
end;

procedure TMainForm.MenuItem9Click(Sender: TObject);
begin
  if MempoolViewerForm=nil then
    Application.CreateForm(TMempoolViewerForm, MempoolViewerForm);

  try
    MempoolViewerForm.BitBtn1.Click;
  except end;

  if not MempoolViewerForm.visible then
    MempoolViewerForm.Show;

end;

procedure TMainForm.miCheckSignatureClick(Sender: TObject);
begin
  CheckSignatureForm.show;
end;

procedure TMainForm.walletInformationUpdated(Sender:tObject);
begin
  //
  if Sender=emerAPI then
    with emerAPI.UTXOList.getStat do begin
       eBalance.Text:=myFloatToStr(spendable/1000000);
       eNamesCount.Text:=intToStr(nameCount);
       UTXOUpdated(sender);
    end;

end;

procedure TMainForm.AsyncAddressInfoDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
  var js,e:tJsonData;
      s:string;
      val,x:double;
      nc,i:integer;
      st:ansistring;
begin
 if result=nil then begin
   emerAPI.EmerAPIConnetor.checkConnection();
   exit;
 end;

 js:=result;

 if js<>nil then begin
   e:=js.FindPath('result.unspents');
   if e<>nil then begin
     nc:=0;
     val:=0;

     for i:=0 to TJSONArray(e).Count-1 do begin
       st:=e.Items[i].FindPath('scriptPubKey').AsString;
       x:=myStrToFloat(e.Items[i].FindPath('amount').AsString);
       if length(st)=0 then exit;
       if (copy(st,1,2)='51') or (copy(st,1,2)='52') then begin
         nc:=nc+1;
       end else
         if (copy(st,1,2)<>'53') then
           val:=val+x;
       // "scriptPubKey": "5175057465737431011e6d0574657374317576a914251b4e68724a3226606cfb307cac0656d04a529588ac",
       // "amount": 0.000100,


     end;

     eBalance.Text:=myFloatToStr(val);
     eNamesCount.Text:=intToStr(nc);

   end;
 end;
end;


function TMainForm.getPubKey(compressed:boolean=true):ansistring;
begin
 result:='';
 if fHDNode.isValid then begin
   result:=fHDNode.getPublicKey(compressed); //GetPublicKey(fPrivKey);
 end else if Settings.PubKey<>'' then
   result:=iecPointToBuf(bufToiecPoint(Settings.PubKey),compressed)//bufToPubKeyString(Settings.PubKey)
 else begin
   //Can't show info
 end;
end;

procedure TMainForm.showWalletInfo();
var //pubKey:TECDSA_Public;
    pubKey:ansistring;

 procedure setEn(e:boolean);
 begin
   bCopyAddress.Enabled:=e;
   bShowQR.Enabled:=e;
   lAddress.Enabled:=e;
   lBalance.Enabled:=e;
   eBalance.Enabled:=e;
   lNames.Enabled:=e;
   eNamesCount.Enabled:=e;
   bRefreshBalance.Enabled:=e;
   bViewTX.Enabled:=e;
   bCreateAsset.Enabled:=e;
   bRefreshTasks.Enabled:=e;
   eTasksCount.Enabled:=e;
   bViewTasks.Enabled:=e;
   lTasks.Enabled:=e;

   bPay.Enabled:=e;
   miAntifake.Enabled:=e;
   miWallet.Enabled:=e;
   miCheckSignature.Enabled:=e;
   miServer.Enabled:=e;
 end;

 var cap:string;
begin
  {if fHDNode.isValid then begin
    pubKey:=fHDNode.getPublicKey(); //GetPublicKey(fPrivKey);
  end else if Settings.PubKey<>'' then
    pubKey:=Settings.PubKey//bufToPubKeyString(Settings.PubKey)
  else begin
    //Can't show info
    setEn(false);
    exit;
  end;}
  pubKey:=getPubKey();
  if pubKey='' then begin
    //Can't show info
    setEn(false);
    exit;
  end;


  setEn(true);
  eAddress.Text:= publicKey2Address(pubkey,globals.AddressSig);

  //eBalance.Text:='';
  //eNamesCount.Text:='';

  if emerAPI<>nil then
    emerAPI.setAddress(eAddress.Text);
  //Attempt to request current UTXO list


  cap:=caption;
  while pos(' TESTNET OR UNKNOWN NETWORK',cap)>0 do
    delete(cap,pos(' TESTNET OR UNKNOWN NETWORK',cap), length(' TESTNET OR UNKNOWN NETWORK'));
  if globals.WifID<>#$80 then
    cap:=cap+' TESTNET OR UNKNOWN NETWORK';
  caption:=cap;


  if emerAPI<>nil then
    if emerAPI.EmerAPIConnetor.testedOk then
    begin
       //emerAPI.UTXOList.update(EmerAPINotification(@walletInformationUpdated,'',true));
       //emerAPI.blockChain.update(EmerAPINotification(@walletInformationUpdated,'',true));

      if emerAPI.isReady or (emerAPIisReadyWaitCounter>10) or (emerAPIisReadyWaitCounter<0) then begin
        if emerAPI.update(EmerAPINotification(@walletInformationUpdated,'',true))
        //if emerAPI.EmerAPIConnetor.testedOk
            then emerAPIisReadyWaitCounter:=0
            else emerAPIisReadyWaitCounter:=-1; //do not wait if not connected
        //emerAPIisReadyWaitCounter:=0;
      end else inc(emerAPIisReadyWaitCounter);

      {emerAPI.blockChain.sendWalletQueryAsync('scantxoutset',
       //['start','[{"address" : "'+eAddress.Text+'" }]']
       //GetJSON('[{"action":"start"},[{"address" : "'+eAddress.Text+'" }]]')
       //scantxoutset {action:"start", "scanobjects":[{"address":"miuA1RdPgyzrBLyTfe8AWzZRwJux1Zptst"}]}
       GetJSON('{"action":"start",scanobjects:[{"address" : "'+eAddress.Text+'" }]}')
      ,@AsyncAddressInfoDone);}
    end;
  if emerAPI<>nil then
    if emerAPI.EmerAPIConnetor.serverAPI<>nil then
      if not Settings.getValue('EMERAPI_SERVER_GUEST_ONLY') then
        if emerAPI.EmerAPIConnetor.serverAPI.testedOk then
          EmerAPIServerTasks.updateFromServer;


end;

procedure TMainForm.updatePKstate(sender:tObject);
begin
  //
  if fHDNode.isValid then begin
    //opened
    sbPK.Caption:=localizzzeString('MainForm.sbPK.UNLOCKED','UNLOCKED');
    ilLamps.GetBitmap(2,imPK.Picture.Bitmap);
  end else if Settings.getValue('Priv_Key')<>'' then begin
     //encripted
    sbPK.Caption:=localizzzeString('MainForm.sbPK.LOCKED','LOCKED');
    ilLamps.GetBitmap(1,imPK.Picture.Bitmap);
  end else begin
    //unset
    sbPK.Caption:=localizzzeString('MainForm.sbPK.ABSENT','ABSENT');
    ilLamps.GetBitmap(0,imPK.Picture.Bitmap);
  end;
end;

procedure TMainForm.onWalletConnected(sender:tObject);
begin
  //sbLW.Caption:=localizzzeString('MainForm.sbLW.ACTIVE','ACTIVE');
  onBlockchainUpdated(sender);
  ilLamps.GetBitmap(2,imLW.Picture.Bitmap);
  showWalletInfo;
end;

procedure TMainForm.TimerStatusUpdateTimer(Sender: TObject);
begin
  if Settings.getValue('EmerAPI_Server_Use') and EmerAPI.EmerAPIConnetor.serverAPI.testedOk then
    if not Settings.getValue('EMERAPI_SERVER_GUEST_ONLY') then
      if EmerAPI.isReady then sbServer.Caption:=localizzzeString('MainForm.sbServer.ACTIVE','ACTIVE')
                         else sbServer.Caption:=localizzzeString('MainForm.sbServer.LOADING','LOADING')
    else
      if EmerAPI.isReady then sbServer.Caption:=localizzzeString('MainForm.sbServer.GuestMODE','GUEST MODE')
                         else sbServer.Caption:=localizzzeString('MainForm.sbServer.LOADING','LOADING')
  else
     sbServer.Caption:='NOT CONNECTED';

  if Settings.getValue('USE_LOCAL_WALLET') and EmerAPI.EmerAPIConnetor.walletAPI.testedOk then
    if EmerAPI.isReady then
       sbLW.Caption:=localizzzeString('MainForm.sbLW.ACTIVE','ACTIVE')
    else
      sbLW.Caption:=localizzzeString('MainForm.sbLW.Loading','LOADING')
   else
      sbLW.Caption:='NOT CONNECTED';
   CheckAdvices(nil);

   TimerStatusUpdate.Enabled:=(not EmerAPI.isReady) and (EmerAPI.EmerAPIConnetor.serverAPI.testedOk or EmerAPI.EmerAPIConnetor.walletAPI.testedOk);
end;


procedure TMainForm.onBlockchainUpdated(sender:tObject);
begin
  TimerStatusUpdateTimer(nil);
 //TimerStatusUpdate.Enabled:=true;
{
 if Settings.getValue('EmerAPI_Server_Use') and EmerAPI.EmerAPIConnetor.serverAPI.testedOk then
   if not Settings.getValue('EMERAPI_SERVER_GUEST_ONLY') then
     if EmerAPI.isReady then sbServer.Caption:=localizzzeString('MainForm.sbServer.ACTIVE','ACTIVE')
                        else sbServer.Caption:=localizzzeString('MainForm.sbServer.LOADING','LOADING')
   else
     if EmerAPI.isReady then sbServer.Caption:=localizzzeString('MainForm.sbServer.GuestMODE','GUEST MODE')
                        else sbServer.Caption:=localizzzeString('MainForm.sbServer.LOADING','LOADING')
 else
    sbServer.Caption:='NOT CONNECTED';

 if Settings.getValue('USE_LOCAL_WALLET') and EmerAPI.EmerAPIConnetor.walletAPI.testedOk then
   if EmerAPI.isReady then
      sbLW.Caption:=localizzzeString('MainForm.sbLW.ACTIVE','ACTIVE')
   else
     sbLW.Caption:=localizzzeString('MainForm.sbLW.Loading','LOADING')
  else
     sbLW.Caption:='NOT CONNECTED';
  CheckAdvices(nil);
  }
end;

procedure TMainForm.onServerConnected(sender:tObject);
begin
  onBlockchainUpdated(sender);
  ilLamps.GetBitmap(2,imServer.Picture.Bitmap);
  showWalletInfo;
end;

procedure TMainForm.tLockMPTimer(Sender: TObject);
begin
  if Settings.getValue('LockKPAfter') then
     deletePrivKey;
end;


function TMainForm.removeNameAndUpdate(NVSname:ansistring):boolean;
var i:integer;
begin

  for i:=0 to sbAssets.ControlCount-1 do
    if sbAssets.Controls[i] is TFrameBaseNVS
       then
         if (sbAssets.Controls[i] as TFrameBaseNVS).NVSRecord.NVSName=NVSname
         then begin
           (sbAssets.Controls[i] as TFrameBaseNVS).enabled:=false;
         end

  {
  i:=0;
  while i<sbAssets.ControlCount do
    if sbAssets.Controls[i] is TFrameBaseNVS
       then
         if (sbAssets.Controls[i] as TFrameBaseNVS).NVSRecord.NVSName=name
         then begin
           (sbAssets.Controls[i] as TFrameBaseNVS).down;
           (sbAssets.Controls[i] as TFrameBaseNVS).Free;
         end else inc(i)
       else inc(i);

  //!emerAPI.update(EmerAPINotification(@walletInformationUpdated,'',true));
  emerAPI.update(EmerAPINotification(@walletInformationUpdated,'',true));
  }
end;

procedure TMainForm.debugCleanMeasures;
 var i:integer;
begin
  for i:=0 to debugMeasures.Count-1 do
    dispose(pDebugRecord(debugMeasures.Objects[i]));
  debugMeasures.Clear;
end;

procedure TMainForm.debugShowLastMeasure;
 var i:integer;
begin
  for i:=0 to debugMeasures.Count-1 do
    if pDebugRecord(debugMeasures.Objects[i])^.count>0 then
      ShowLogMessage(
       'MEASURE("'+debugMeasures[i]+'"): '+
       inttostr(round(pDebugRecord(debugMeasures.Objects[i])^.value/pDebugRecord(debugMeasures.Objects[i])^.count))
       +'; total:'+inttostr(pDebugRecord(debugMeasures.Objects[i])^.value)
      );
end;

procedure TMainForm.debugStart(atag:string);
var
  pdr:pDebugRecord;
  i:integer;
begin
  i:=debugMeasures.IndexOf(atag);
  if i>=0 then pdr:=pDebugRecord(debugMeasures.Objects[i]) else begin
    new(pdr);
    fillchar(pdr^,sizeof(pdr^),0);
    debugMeasures.AddObject(aTag,tObject(pdr));
  end;
  pdr^.lastStart:=GetTickCount;

end;

procedure TMainForm.debugStop(atag:string);
var i:integer;
begin
  i:=debugMeasures.IndexOf(atag);
  if i>=0 then begin
    pDebugRecord(debugMeasures.Objects[i])^.count:=pDebugRecord(debugMeasures.Objects[i])^.count+1;
    pDebugRecord(debugMeasures.Objects[i])^.value:=pDebugRecord(debugMeasures.Objects[i])^.value+GetTickCount-pDebugRecord(debugMeasures.Objects[i])^.lastStart;
    pDebugRecord(debugMeasures.Objects[i])^.lastStart:=0;
  end;
end;


procedure TMainForm.UTXOUpdated(sender:tObject);
begin
  RebuildAssetsListTimer.Enabled:=false;
  RebuildAssetsListTimer.Enabled:=true;
  //RebuildAssetsList(sender);
end;

procedure TMainForm.EmerAPIServerTasksUpdated(sender:tObject);
var i:integer;
begin
  //rebuild EmerAPIServerTasks?

  //we can't delete tasks here because it can be called from the task.
  //Use timer for schedule
  TimerEmerAPIServerTasksUpdated.Enabled:=true;
end;

procedure TMainForm.RebuildAssetsList(Sender: TObject);
const
  knownPrefixesArray:array[0..12] of ansistring =
    (''
      ,'af:owner','af:product','af:lot'
      ,'dpo:','dpo:::','dns:','ssh:'
      ,'ssl:','tts:','doc','cert'
      ,'enum'
    );

var i:integer;
    fCounter:integer;
    allowedPrefixes:ansistring;
    knownPrefixes:ansistring;

function findControl(nvsname:ansistring):TFrameBaseNVS;
var i:integer;
begin
  result:=nil;
  for i:=0 to sbAssets.ControlCount-1 do
    if (sbAssets.Controls[i] is TFrameBaseNVS)
      then if (sbAssets.Controls[i] as TFrameBaseNVS).NVSRecord.NVSName=nvsname then begin
        result:=(sbAssets.Controls[i] as TFrameBaseNVS);
        exit;
      end;

end;
var
frame:TFrameDigitalAsset;

function findnamet:boolean;
begin
 //debugStart('UTXOList.findName');
 result:=emerAPI.UTXOList.findName((sbAssets.Controls[i] as TFrameBaseNVS).NVSRecord.NVSName)<>nil;
 //debugStop('UTXOList.findName');
end;

function needShow(NVSRecord:tBaseTXO {tUTXO tNVSRecord}):boolean;
var i:integer;
    name,prefix:ansistring;
    found:boolean;
begin
 //do we need show (sbAssets.Controls[i] as TFrameBaseNVS).NVSRecord ?
 result:=false;
 if not chAssetsFilterShowExpired.Checked then
   if (NVSRecord is tNVSRecord)
      then begin
        if (NVSRecord as tNVSRecord).DaysLeft=0 then begin
          if needShowInvalidNamesUTXOCache.IndexOf((NVSRecord as tNVSRecord).NVSName)<0 then
            needShowInvalidNamesUTXOCache.Append((NVSRecord as tNVSRecord).NVSName);
          exit;
        end;
      end else if (NVSRecord is tUTXO) then begin
        //max(0,trunc(Days -  (fEmerAPI.blockChain.Height-fHeight)/175 ))
        //(NVSRecord as tUTXO).getNVSName;
        //if (NVSRecord as tUTXO).Height;
        //we don't know if the name is over. We will know it later.
        //BUT maybe we KNEW it before.
        //use needShowInvalidNamesUTXOCache
        //validNamesUTXOCache
        if needShowInvalidNamesUTXOCache.IndexOf((NVSRecord as tUTXO).getNVSName)>=0 then exit;
      end;



 if (fCounter>=seAssetsFilterShowFirst.Value) then exit;


 if pAssetsFilterNames.Checked[0] or (allowedPrefixes<>' ') then begin
   name:='';
   if (NVSRecord is tNVSRecord) then name:=(NVSRecord as tNVSRecord).NVSName
   else if (NVSRecord is tUTXO) then name:=(NVSRecord as tUTXO).getNVSName;

   prefix:=namePrefixExtract(name);

   //known prefix and not selected?
   if (pos(' '+prefix+' ',knownPrefixes)>0) and (pos(' '+prefix+' ',allowedPrefixes)<1) then exit;

   //unknow prefixes are not allowed
   if (pos(' '+prefix+' ',knownPrefixes)<1) and (not pAssetsFilterNames.Checked[0]) then exit;

   //check structure
   if (pos(' '+prefix+' ',allowedPrefixes)>0) then begin
     //finding real prefix

     found:=false;

     for i:=1 to min(length(knownPrefixesArray),pAssetsFilterNames.Count)-1 do //first is undetected
       if pAssetsFilterNames.Checked[i] then
         if namePrefixMatched(knownPrefixesArray[i],name) then begin
           found:=true;
           break;
         end;
     if not found then exit;
   end;
 end;


 result:=true;
end;

//var hasNew:boolean;
begin
 //emerAPI.UTXOList
//  hasNew:=false;
 if emerAPI=nil then exit;
 if emerAPI.UTXOList=nil then exit;

 //build prefixes
 allowedPrefixes:=' ';
 knownPrefixes:=' ';
 for i:=1 to min(length(knownPrefixesArray),pAssetsFilterNames.Count)-1 do //first is undetected
 begin
   if pAssetsFilterNames.Checked[i] then
     allowedPrefixes:=allowedPrefixes+namePrefixExtract(knownPrefixesArray[i])+' ';
   knownPrefixes:=knownPrefixes+namePrefixExtract(knownPrefixesArray[i])+' ';
 end;


 //1. Remove hiden items
 fCounter:=0;
 i:=0;
 //debugCleanMeasures;
 //!!!
 //debugStart('cicle1');
 while i<sbAssets.ControlCount do
   if sbAssets.Controls[i] is TFrameBaseNVS
      then begin
        application.ProcessMessages;
        if findnamet and needShow((sbAssets.Controls[i] as TFrameBaseNVS).NVSRecord) then begin inc(i); inc(fCounter); end
        else begin
          (sbAssets.Controls[i] as TFrameBaseNVS).down;
          (sbAssets.Controls[i] as TFrameBaseNVS).Free;
          //application.ProcessMessages;
          //EmerAPIServerTasks.delete(i);
        end;
      end
      else inc(i);
 //debugStop('cicle1');
 //2. Add
 if (fCounter>=seAssetsFilterShowFirst.Value) then exit;

 //debugStart('cicle2');
 for i:=0 to emerAPI.UTXOList.Count-1 do begin
   if emerAPI.UTXOList[i].getNVSName<>'' then
     if (findControl(emerAPI.UTXOList[i].getNVSName)=nil) and needShow(emerAPI.UTXOList[i]) then
     begin
       frame:=TFrameDigitalAsset.Create(self);
       frame.Name:='fr'+bufToHex(dosha256(emerAPI.UTXOList[i].getNVSName));
       frame.Parent:=sbAssets;
       frame.Top:=10+frame.Height*sbAssets.ControlCount;
       frame.Align:=alTop;
       frame.Height:=frame.Init(nil,emerAPI.UTXOList[i]);
       frame.updateView(nil);
       //hasNew:=true;
       inc(fCounter);
     end;
   application.ProcessMessages;
 end;
 //debugStop('cicle2');
 //debugShowLastMeasure;
//  if hasNew then realignTimer.Enabled:=true;
end;


procedure TMainForm.TimerEmerAPIServerTasksUpdatedTimer(Sender: TObject);
var i:integer;
begin
  //rebuild EmerAPIServerTasks?

  TimerEmerAPIServerTasksUpdated.Enabled:=false;

  //1. Remove excecuted items and recheck statuses
  i:=0;
  while i<EmerAPIServerTasks.Count do
    if EmerAPIServerTasks[i].Executed
       then begin
         //DO NOT REMOVE executed tasks because they will appear again
         //But let's hide it
         if (EmerAPIServerTasks[i].userObj1 <> nil) and (EmerAPIServerTasks[i].userObj1 is TFrameServerTask) then begin
           TFrameServerTask(EmerAPIServerTasks[i].userObj1).down;
           TFrameServerTask(EmerAPIServerTasks[i].userObj1).Free;
           EmerAPIServerTasks[i].userObj1:=nil;
         end;
         {//DO NOT REMOVE executed tasks because they will appear again
         EmerAPIServerTasks.delete(i);
         } inc(i);
       end
       else begin
         //recheck status
         if (EmerAPIServerTasks[i].userObj1 <> nil) and (EmerAPIServerTasks[i].userObj1 is TFrameServerTask) then
           (EmerAPIServerTasks[i].userObj1 as TFrameServerTask).refreshView(nil);
         inc(i);
       end;

  //2. Add
  for i:=0 to EmerAPIServerTasks.Count-1 do
    if (not EmerAPIServerTasks[i].Executed) and (EmerAPIServerTasks[i].userObj1=nil) then begin
       EmerAPIServerTasks[i].userObj1:=TFrameServerTask.Create(self);

       TFrameServerTask(EmerAPIServerTasks[i].userObj1).Name:='FrameServerTask'+taskCounter;
       TFrameServerTask(EmerAPIServerTasks[i].userObj1).Parent:=sbActions;
       TFrameServerTask(EmerAPIServerTasks[i].userObj1).Align:=alTop;
       TFrameServerTask(EmerAPIServerTasks[i].userObj1).Height := TFrameServerTask(EmerAPIServerTasks[i].userObj1).init(EmerAPIServerTasks[i]);
    end;
  eTasksCount.Text:=inttostr(EmerAPIServerTasks.Count);
end;

procedure TMainForm.tShowMessageSafeTimer(Sender: TObject);
var msg:string;
begin
  tShowMessageSafe.Enabled:=false;
  while length(showMessagePool)>0 do begin
    msg:=showMessagePool[length(showMessagePool)-1];
    setLength(showMessagePool,length(showMessagePool)-1);
    //!ShowMessage(msg);
    ShowLogMessage(msg);
    if length(msg)>250 then
       msg:=copy(msg,1,255)+'...';
    ShowMessage(msg);
  end;
end;

procedure TMainForm.updateInfoTimerTimer(Sender: TObject);
begin
  showWalletInfo;
end;

procedure TMainForm.onWalletDisconnected(sender:tObject);
begin
  sbLW.Caption:='NOT CONNECTED';
  ilLamps.GetBitmap(1,imLW.Picture.Bitmap);
end;

procedure TMainForm.onServerDisconnected(sender:tObject);
begin
  sbServer.Caption:='NOT CONNECTED';
  ilLamps.GetBitmap(1,imServer.Picture.Bitmap);
end;

procedure TMainForm.queryForNetworkSettings(wif,adrsig:byte; netstr:string);
var nd:tNetworkData;
    sn:ansistring;
begin
  nd:=getNetwork;
  if not Settings.getValue('Dev_Mode_ON')
     then sn:='emc:main'
     else sn:=trim(settings.getValue('DEV_SERVER_NETWORK'));

  if (wif<>ord(nd.wif))
     or (adrsig<>ord(nd.pubKeySig))
     or (trim(netstr)<>sn) then
  begin

    fonAnswerDataWif:='$'+intToHex(wif,2);
    fonAnswerDataSig:='$'+intToHex(adrsig,2);
    fonAnswerDataNet:=trim(netstr);

    with AskQuestionTag(self,@onAnswer,'msgServerNetworkSettingsDifferent') do begin
      bYes.Visible:=true;
      bNo.Visible:=true;
      bHelp.Visible:=true;
      bNo.setFocus;
      Update;
    end;


  end;
end;

procedure TMainForm.serverMessageReceived(sender:tEmerApiServer;data:tJsonData);
var e:tJsonData;
    a:array of ansistring;
    s:string;
begin
  //Emerapi server sends a message

  e:=data.FindPath('session_key');
  if e<>nil then begin
    //we have session key
    //confuguring access
   Settings.setValue('EmerAPI_Server_adv_SessionKey',bufToHex(HexToBuf(e.AsString)));//hex to hex
   setLength(a,length(a)+1);a[length(a)-1]:='EmerAPI_Server_adv_SessionKey';
  end;

  e:=data.FindPath('cookies._yum_l');
  if e<>nil then begin
    Settings.setValue('EmerAPI_Server_adv_yum_l',ansistring(e.AsString));
    setLength(a,length(a)+1);a[length(a)-1]:='EmerAPI_Server_adv_yum_l';
  end;

  //'network':{'wif':'EF','adrsig':'6F','netstr':'emc:test'}
  e:=data.FindPath('network');
  if e<>nil then begin
     queryForNetworkSettings(
      strToInt('$'+e.FindPath('wif').AsString),
      strToInt('$'+e.FindPath('adrsig').AsString),
      e.FindPath('netstr').AsString
     );
  end;


  if length(a)>0 then
     Settings.saveParams(a)
  else
  begin
    e:=data.FindPath('url');
    if e<>nil then begin
      //URL received
      s:=e.AsString;
      e:=data.FindPath('token');
      if e<>nil then s:=s+e.AsString;
      fLastOpenURLLing:=s;
      //show server auth message
      with AskQuestionTag(self,@onAnswer,'MessageAskForLoginToServer') do begin
        bYes.Visible:=true;
        bNo.Visible:=true;
        bHelp.Visible:=true;
        bYes.setFocus;
        Update;
      end;
    end else begin
      //Incorrect report
      //tsServerLoginPanelLabel.Caption:=localizzzeString('MasterPasswordWizardForm.tsServerLoginPanelLabel.UnknownResponse','Error: Unknown server response');
      //something unkown... just ignore it
    end;
  end;

end;

procedure TMainForm.blockChainonAsyncQueryRawDone(sender:TEmerAPIBlockchainThread;result:string);
begin
  //TEmerAPIBlockchainProto(sender)
  debugConsoleShow('Data received: ['+sender.id+']: ' +result);
end;

procedure TMainForm.BlockchainErrorHandler(sender:TEmerAPIBlockchainThread;error:string);
begin
  if sender <> nil then
    debugConsoleShow('ERROR: ['+sender.id+']: '+error);
end;

procedure TMainForm.BlockchainBeforeSendHandler(sender:TEmerAPIBlockchainThread;data:string);
begin
  debugConsoleShow('Send: ['+sender.id+']: '+data);
end;

function TMainForm.SetAndCheckBlockchain(local:boolean=true;server:boolean=true;forceRecheck:boolean=false):boolean;
var ConnDataWallet:tWalletConnectionData;
    ConnDataServer:tEmerApiServerSettings;
    f:boolean;

    mNetwork:string='';
    //mWifID:char=#0;
    //mAddressSig:char=#0;
    x:double;
    n:integer;
begin
  result:=false;
  if (Settings=nil) {or (not Settings.Loaded)} then begin sbLW.Caption:='NOT SET'; ilLamps.GetBitmap(0,imLW.Picture.Bitmap); exit; end;

  if not Settings.getValue('USE_LOCAL_WALLET') then begin sbLW.Caption:='NOT SET'; ilLamps.GetBitmap(0,imLW.Picture.Bitmap); end;


  ConnDataWallet.port:=Settings.getValue('LOCAL_WALLET_RPC_PORT');
  ConnDataWallet.address:=Settings.getValue('LOCAL_WALLET_RPC_ADDRESS');
  ConnDataWallet.UseHTTPS:=Settings.getValue('LOCAL_WALLET_RPC_USE_SSL');
  ConnDataWallet.userName:=Settings.getValue('LOCAL_WALLET_RPC_USER_NAME');
  ConnDataWallet.userPass:=Settings.getValue('LOCAL_WALLET_RPC_PASSWORD');
  ConnDataWallet.maxSimConn:=Settings.getValue('LOCAL_WALLET_RPC_Max_simultaneous_connections');


  ConnDataServer.address:=Settings.getValue('EMERAPI_SERVER_ADDRESS');
  ConnDataServer.userName:=Settings.getValue('EMERAPI_SERVER_USER_NAME');
  ConnDataServer.guest_only:=Settings.getValue('EMERAPI_SERVER_GUEST_ONLY');
  ConnDataServer.userPass:=Settings.getValue('EMERAPI_SERVER_PASSWORD');

  ConnDataServer.cookie_name:=Settings.getValue('EMERAPI_SERVER_ADV_COOKIE_NAME');;
  ConnDataServer.data_suffix:=Settings.getValue('EMERAPI_SERVER_ADV_DATA_SUFFIX');;

  ConnDataServer.login_field_name:=Settings.getValue('EMERAPI_SERVER_ADV_LOGIN_FORM_NAME');
  ConnDataServer.password_field_name:=Settings.getValue('EMERAPI_SERVER_ADV_PASSWORD_FORM_NAME');
  ConnDataServer.login_suffix:=Settings.getValue('EMERAPI_SERVER_ADV_LOGIN_SUFFIX');
  ConnDataServer.maxSimConn:=Settings.getValue('EMERAPI_SERVER_Max_simultaneous_connections');

  ConnDataServer.queryFieldName:=Settings.getValue('EmerAPI_Server_adv_Query_Field_Name');

  ConnDataServer.networkSig :=Settings.getValue('Dev_Server_Network');



  ConnDataServer.reconnectTimeOut:=60;
  ConnDataServer.timeOut:=60;

  ConnDataServer.pubKey:=getPubKey;
  ConnDataServer.connectUsingUsername:=not Settings.getValue('EmerAPI_Server_Login_Address');
  ConnDataServer.AESKey:=Settings.getValue('EmerAPI_Server_adv_SessionKey');


  if Settings.getValue('Dev_Mode_ON') then begin
    mNetwork:=settings.getValue('DEV_SERVER_NETWORK');
    //mWifID:=chr(strToInt(settings.getValue('Dev_WIF')));
    //mAddressSig:=chr(strToInt(settings.getValue('Dev_SIG')));
  end else begin
    mNetwork:='emc:main';
    //mWifID:=#$80;
    //mAddressSig:=#$21;
  end;


  if emerAPI=nil then begin
     //blockChain:=tEmerAPIBlockchainMerged.Create(ConnDataWallet,ConnDataServer)
    emerAPI:=temerAPI.Create(ConnDataWallet,ConnDataServer,mNetwork,getNetwork.wif, getNetwork.pubKeySig);
    emerAPIisReadyWaitCounter:=-1;
  end else begin
    emerAPI.EmerAPIConnetor.connDataServer:=ConnDataServer;
    emerAPI.EmerAPIConnetor.connDataWallet:=connDataWallet;
    emerAPI.blockChain.setNetworkParams(mNetwork,getNetwork.wif, getNetwork.pubKeySig);
  end;

  if Settings.getValue('EmerAPI_Server_adv_yum_l')<>'' then
    emerAPI.EmerAPIConnetor.serverAPI.setCookie('_yum_l='+Settings.getValue('EmerAPI_Server_adv_yum_l'));

  emerAPI.EmerAPIConnetor.onAsyncQueryRawDone:=@blockChainonAsyncQueryRawDone;
  emerAPI.EmerAPIConnetor.onBlockchainError:=@BlockchainErrorHandler;
  emerAPI.EmerAPIConnetor.onBeforeSend:=@BlockchainBeforeSendHandler;
  emerAPI.EmerAPIConnetor.serverAPI.onNeedPrivateKey:=@getPrivKey;
  emerAPI.EmerAPIConnetor.serverAPI.onServerMessage:=@serverMessageReceived;



  emerAPI.blockChain.AddOneCentToNameTxFee:=Settings.getValue('Add_One_Cent_To_Name_Tx_Fee');
  n:=Settings.getValue('Spending_Optimization_Mode');
  emerAPI.UTXOList.UTXOOptimization:=tUTXOOptimization(n);
  x:=Settings.getValue('Keep_Amount_Threshold')*COIN;
  emerAPI.UTXOList.keepAmountThreshold:=trunc(x);



  emerAPI.EmerAPIConnetor.prefferWallet:=Settings.getValue('PREFER_USING_LOCAL_WALLET');
  emerAPI.EmerAPIConnetor.useServer:=Settings.getValue('EmerAPI_Server_Use');
  emerAPI.EmerAPIConnetor.useWallet:=Settings.getValue('USE_LOCAL_WALLET');

  emerAPI.EmerAPIConnetor.walletAPI.onConnect:=@onWalletConnected;
  emerAPI.EmerAPIConnetor.walletAPI.onDisconnect:=@onWalletDisconnected;

  emerAPI.EmerAPIConnetor.serverAPI.onConnect:=@onServerConnected;
  emerAPI.EmerAPIConnetor.serverAPI.onDisconnect:=@onServerDisconnected;

  emerAPI.blockChain.addNotify(EmerAPINotification(@onBlockchainUpdated,'update',true));
  emerAPI.blockChain.addNotify(EmerAPINotification(@onBlockchainUpdated,'updateError',true));

 result:=true;



 if local and Settings.getValue('USE_LOCAL_WALLET') then begin
   if not emerAPI.EmerAPIConnetor.walletAPI.testedOk then onWalletDisconnected(nil);
   emerAPI.EmerAPIConnetor.walletAPI.checkConnection(forceRecheck);
 end;
 if server and Settings.getValue('EmerAPI_Server_Use') then begin
   if not emerAPI.EmerAPIConnetor.serverAPI.testedOk then onServerDisconnected(nil);
   emerAPI.EmerAPIConnetor.serverAPI.checkConnection(forceRecheck);
   //Settings.getValue('EMERAPI_SERVER_CONNECT_AFTER_START') then
 end;

 if (EmerAPIServerTasks=nil) and (not Settings.getValue('EMERAPI_SERVER_GUEST_ONLY')) then begin
   EmerAPIServerTasks:=tEmerAPIServerTaskList.create(emerAPI);
   EmerAPIServerTasks.addNotify(EmerAPINotification(@EmerAPIServerTasksUpdated,'update',true));

 end;

  {if local then begin
   f:=blockChain.walletAPI.checkConnection;
   if not f then onWalletDisconnected(nil);
   result := result and f;
 end;
 if server and Settings.getValue('EMERAPI_SERVER_CONNECT_AFTER_START') then begin     //EMERAPI_SERVER_CONNECT_AFTER_START
   f:=blockChain.serverAPI.checkConnection;
   if not f then onServerDisconnected(nil);
   result := result and f;
 end
  }
  {
  if local then begin
    if LocalWallet=nil then begin
      LocalWallet:=tLocalWallet.create(
        Settings.getValue('LOCAL_WALLET_RPC_PORT')
        ,Settings.getValue('LOCAL_WALLET_RPC_USER_NAME')
        ,Settings.getValue('LOCAL_WALLET_RPC_PASSWORD')
      );
      blockChain.walletAPI.onConnect:=@onWalletConnected;
      blockChain.walletAPI.onDisconnect:=@onWalletDisconnected;

    end else begin
      LocalWallet.connData.Port:=Settings.getValue('LOCAL_WALLET_RPC_PORT');
      LocalWallet.connData.UserName:=Settings.getValue('LOCAL_WALLET_RPC_USER_NAME');
      LocalWallet.connData.UserPass:=Settings.getValue('LOCAL_WALLET_RPC_PASSWORD');
    end;

    result:=LocalWallet.checkConnection;
    if not result then onWalletDisconnected(nil);
  end;  }

end;


procedure TMainForm.FormCreate(Sender: TObject);
begin
  ///
  DefaultFormatSettings.DecimalSeparator := '.' ;
  fHDNode.clear; //fPrivKey:='';
  KeyPreview:=True;
  debugMeasures:=tStringList.create;

  application.AddOnKeyDownHandler(@KeyUpAppHandler);

  sbAssetsFilterAdConClick(nil);
  //SynEmerNVSSyn:=tSynEmerNVSSyn.create(self);

  needShowInvalidNamesUTXOCache:=tStringList.Create;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if emerAPI<>nil then emerAPI.free;
  if EmerAPIServerTasks<>nil then EmerAPIServerTasks.Free;

  debugCleanMeasures;
  if debugMeasures<>nil then debugMeasures.free;

  Settings.free;

  if JSONRPCServer<>nil then freeandnil(JSONRPCServer); //JSONRPCServerThread.Terminate;
  //SynEmerNVSSyn.free;
  needShowInvalidNamesUTXOCache.free;
end;

function TMainForm.FormHelp(Command: Word; Data: PtrInt; var CallHelp: Boolean
  ): Boolean;
begin
  showHelpTag();
end;

procedure TMainForm.imAFCreateForPrintingClick(Sender: TObject);
begin
  AFCreateForPrintingForm.show;
end;

procedure TMainForm.KeyUpAppHandler(Sender: TObject; var Key: Word; Shift: TShiftState
  );
var parentForm:tForm;
begin
  parentForm:=Screen.ActiveForm;
  if parentForm=nil then parentForm:=self;


  //if (key=68) and ((shift=[ssAlt, ssCtrl]) or (shift=[ssAlt, ssCtrl, ssShift])) then begin
  if (key=68) and (ssAlt in shift) and (ssCtrl in shift) then begin
    Settings.setValue('Dev_Mode_ON',not Settings.getValue('Dev_Mode_ON'));
    if Settings.getValue('Dev_Mode_ON')
    then
      with AskQuestion(parentForm,nil,'Developer Mode ON','','MainForm.DevModeOn') do begin
        bOk.Visible:=true;
        bOk.setFocus;
        Update;
      end
    else
      with AskQuestion(parentForm,nil,'Developer Mode OFF','','MainForm.DevModeOff') do begin
        bOk.Visible:=true;
        bOk.setFocus;
        Update;
      end;
    miDevTools.Visible:=Settings.getValue('Dev_Mode_ON');
    gbLog.Visible:=Settings.getValue('Dev_Mode_ON');
  end;
  if (key=112) then
     showHelpTag();
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  realignTimer.Enabled:=false;
  realignTimer.Enabled:=true;
end;


procedure TMainForm.bViewTasksClick(Sender: TObject);
begin
    pcMain.ActivePage:=tsActions;
end;

procedure TMainForm.bViewTXClick(Sender: TObject);
begin
  pcMain.ActivePage:=tsAssets;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //terminate threads
 if emerAPI<>nil then
   emerAPI.finalize;

end;

procedure TMainForm.bRefreshBalanceClick(Sender: TObject);
begin
  emerAPIisReadyWaitCounter:=-1;
  showWalletInfo();
end;

procedure TMainForm.bRefreshTasksClick(Sender: TObject);
begin
  if emerAPI<>nil then
   if not Settings.getValue('EMERAPI_SERVER_GUEST_ONLY') then
    if emerAPI.EmerAPIConnetor.serverAPI<>nil then
      if emerAPI.EmerAPIConnetor.serverAPI.testedOk then
        EmerAPIServerTasks.updateFromServer;

end;

procedure TMainForm.bRegisterMasterPasswordClick(Sender: TObject);
begin
  ShowWizardForm('domp');
  CheckAdvices(nil);
end;

procedure TMainForm.bRegisterServer1Click(Sender: TObject);
begin
  Settings.setValue('EMERAPI_SERVER_ADDRESS','http://EmerAPI.info');
  ShowWizardForm('doServerConnect');
  CheckAdvices(nil);
end;

procedure TMainForm.bRegisterServer2Click(Sender: TObject);
begin
 Settings.setValue('EMERAPI_SERVER_ADDRESS','http://emcdpo.info');
 ShowWizardForm('doServerConnect');
 CheckAdvices(nil);
end;

procedure TMainForm.bShowQRClick(Sender: TObject);
begin
  ShowQRCode('emercoin:'+eAddress.text);
end;

procedure TMainForm.Button1Click(Sender: TObject);
var i:integer;
begin
  //D!!!
  for i:=0 to 99 do
    emerAPI.EmerAPIConnetor.walletAPI.sendWalletQueryAsync('getblockchaininfo',nil,{@myQueryDone}nil);
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  TimerStatusUpdateTimer(nil);
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  if readTranslationFile then begin
    localizzze(self);
    localizzze(MainMenu);
  end;
end;

procedure TMainForm.Button5Click(Sender: TObject);
var
    s:string;
    t:TJSONData;
    fs:tFileStream;
begin

  if IDYES <> Application.MessageBox('Warning! TRANSLATION directory will be erased! Are you sure you want to delete the directory?', 'WARNING', MB_ICONQUESTION + MB_YESNO) then exit;

  if fileexists(extractFilePath(application.ExeName)+'translation.txt') then
    try
      fs:=tFileStream.Create(extractFilePath(application.ExeName)+'translation.txt',fmOpenRead);
      setLength(s,fs.Size);
      fs.Read(s[1],length(s));

      t := GetJSON(changeQuotesSafe(s));
      try
        reriteTranslationFolder(t,chDevBeautyHTML.Checked);
      finally
        t.Free;
      end;

    finally
      FreeAndNil(fs);
    end
  else
   showMessageSafe('You must put translation.txt file into the program''s folder');
end;

procedure TMainForm.Button6Click(Sender: TObject);
var fs:tFileStream;
    js:tJsonData;
    s:string;
begin
  js:=readTranslationFolder(chDevBeautyHTML.Checked);

  if js<>nil then
    try
      fs:=tFileStream.Create(extractFilePath(application.ExeName)+'translation.txt',fmOpenWrite);
      try
        if chDevBeautyJSON.checked
           then begin
             s:=js.FormatJSON();
             fs.Write(s[1],length(s));
           end else js.DumpJSON(fs);
      finally
        fs.Free;
      end;
      Button3Click(nil);
    finally
      js.Free;
    end;
end;


procedure TMainForm.BitBtn1Click(Sender: TObject);
var tmp:TFrameServerTask;
begin
 //   EmerAPIServerTasks:tEmerAPIServerTaskList;  //userObj1
 tmp:=TFrameServerTask.Create(self);
 tmp.Name:='FrameServerTask';
 tmp.Parent:=sbActions;
 tmp.Align:=alTop;
 //tmp.init();


end;


procedure TMainForm.bCopyAddressClick(Sender: TObject);
begin
 Clipboard.AsText:=eAddress.Text;

// eAddress.CopyToClipboard;
end;

procedure TMainForm.bAssetsFilterRebuildClick(Sender: TObject);
begin
  RebuildAssetsList(Sender);
end;



procedure TMainForm.FormShow(Sender: TObject);
begin
  // Application.OnHelp := @FormHelp;

  //1. Attempt to load settings
  mLog.Text:='';
  ShowLogMessage('Application started. Locale Language: '+GetLocaleLanguage());
  //we must set languages list in advance
  SettingsForm.sssLanguage.Items.assign(languages);
  //Now building settings structure
  Settings:=TSettings.Create(SettingsForm);

  Settings.LoadFromGUI();
  Settings.setValue('Language',GetLocaleLanguageTag());
  try
    Settings.load();
  except
    //can show error message for wrong cfg
  end;


  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  //Settings.setValue('Dev_Mode_ON',true);

  updateInfoTimer.Interval:=Settings.getValue('EMERAPI_SERVER_Refresh_period')*1000;

  localizzze(self);
  localizzze(MainMenu);
  SetAndCheckBlockchain();
  updatePKstate(nil);

  //2. Attempt to load library. If there are settings, use them, overwise try default location
  {
  //if Settings.Loaded and (trim(Settings.libFilename)<>'') then
    SSL_C_LIB:=Settings.libFilename;

  //3. If failed to load the cryptolib, try to ask user. Keep this settings for the future using.
  if Not LoadSSLCrypt then
    timerAskForLib.enabled:=true
  else begin
     InitCrypto;
     //4. Attempt to obtain PrivKey or PubKey
     if (Settings.PubKey='') and (PrivKey='') then timerAskForMP.enabled:=true;
  end;
   }

  miDevTools.Visible:=Settings.getValue('Dev_Mode_ON');
  gbLog.Visible:=Settings.getValue('Dev_Mode_ON');
  showWalletInfo;

  gbTest.Visible:=  Settings.getValue('Dev_Mode_ON');
  gbLog.Visible:=  Settings.getValue('Dev_Mode_ON');
  Splitter1.Visible:=  Settings.getValue('Dev_Mode_ON');

  if (Settings.PubKey='') and (PrivKey='') then timerAskForMP.enabled:=true;

  //fphttpserver, fpHTTP, fpWeb
  checkJSONRPCserver;
  CheckAdvices(nil);
end;

procedure TMainForm.JSONRPCServerThreadErrorHandler(Sender:tObject);
begin
  if Sender is TJSONRPCServer then
    showMessageSafe(localizzzeString('MainForm.JSONRPC_CANT_START_MESSAGE','JSON RPC Server can not be started: ')+(Sender as TJSONRPCServer).LastError);
end;

procedure TMainForm.checkJSONRPCserver;
begin
  if Settings.getValue('JSONPRC_allowed') then
    if JSONRPCServer=nil then begin
       JSONRPCServer:=TJSONRPCServer.Create();
       JSONRPCServer.addNotify(EmerAPINotification(@JSONRPCServerThreadErrorHandler,'error',true));
    end;

  if JSONRPCServer<>nil then
    JSONRPCServer.checkState;

end;

procedure TMainForm.miBecomeOwnerClick(Sender: TObject);
begin
  TakePossessionForm.Show;
end;

procedure TMainForm.miLotFilesClick(Sender: TObject);
begin

end;

procedure TMainForm.miEncryptionClick(Sender: TObject);
begin

  if cryptoTestForm=nil then
    Application.CreateForm(TcryptoTestForm, cryptoTestForm);

  cryptoTestForm.CheckBox1.Checked:=true;
  cryptoTestForm.Edit12.Text:='$'+inttohex(ord(globals.WifID),2);
  cryptoTestForm.Edit13.Text:='$'+inttohex(ord(globals.AddressSig),2);

  try
    cryptoTestForm.Edit28.Text:=bufToHex(fHDNode.getPublicKey());
    cryptoTestForm.Edit29.Text:=fHDNode.getShortPrivateKeyCode58;
  except
  end;

  cryptoTestForm.Show;

end;

procedure TMainForm.miSetOpenNicClick(Sender: TObject);
begin
  {$IFDEF Unix}
  showMessageSafe('Not supported');
  exit;
  {$ENDIF Unix}


  with AskQuestionTag(self,@onAnswerTools,'msgSetOpenNicDNS') do begin
    bYes.Visible:=true;
    bNo.Visible:=true;
    bHelp.Visible:=true;
    bYes.setFocus;
    Update;
  end;

end;

procedure TMainForm.miTXClick(Sender: TObject);
begin
  if CreateRawTXForm=nil then
    Application.CreateForm(TCreateRawTXForm, CreateRawTXForm);

  CreateRawTXForm.ComboBox1.text:='$'+inttohex(ord(globals.AddressSig),2);

  if fHDNode.isValid then begin
    CreateRawTXForm.Edit14.Text:=fHDNode.getShortPrivateKeyCode58; //privKeyToCode58(fPrivKey,getNetwork.wif,true) ;
    CreateRawTXForm.Button28.Click;
  end;

  try
    CreateRawTXForm.Button26Click(nil);
  except end;

  if not CreateRawTXForm.visible then
    CreateRawTXForm.Show;
end;

procedure TMainForm.miLogClick(Sender: TObject);
begin
  if DebugConsoleForm=nil then
    Application.CreateForm(TDebugConsoleForm, DebugConsoleForm);
  DebugConsoleForm.show;
end;

procedure TMainForm.miConsoleClick(Sender: TObject);
begin
  if EmerAPIDebugConsoleForm=nil then
    Application.CreateForm(TEmerAPIDebugConsoleForm, EmerAPIDebugConsoleForm);
  EmerAPIDebugConsoleForm.Show;
end;

procedure TMainForm.miOpenWebClick(Sender: TObject);
begin
  //OpenDocument(Settings.getValue('EMERAPI_SERVER_ADDRESS'));
  OpenURL(Settings.getValue('EMERAPI_SERVER_ADDRESS'));
end;

procedure TMainForm.miMemPoolClick(Sender: TObject);
begin
  if MempoolViewerForm2=nil then
  Application.CreateForm(TMempoolViewerForm2, MempoolViewerForm2);

  try
    MempoolViewerForm2.BitBtn1.Click;
  except end;

  if not MempoolViewerForm2.visible then
    MempoolViewerForm2.Show;
end;

procedure TMainForm.miWalletMassSendClick(Sender: TObject);
begin
  MassSendingForm.show;
end;

procedure TMainForm.miWalletAtomClick(Sender: TObject);
begin
  ShowAtomForm(nil);
end;

procedure TMainForm.miAboutClick(Sender: TObject);
begin
  FormAbout.show;
end;

procedure TMainForm.miWalletNameClick(Sender: TObject);
begin
  WalletBasicsForm.PageControl1.PageIndex:=1;
  if not WalletBasicsForm.Visible
     then WalletBasicsForm.Show
     else WalletBasicsForm.SetFocus;
end;


procedure TMainForm.miSettingsClick(Sender: TObject);
begin
  Settings.writeToGUI;
  SettingsForm.show;
end;

procedure TMainForm.miSignMessageClick(Sender: TObject);
begin
  SignMessageForm.show;
end;

procedure TMainForm.pcMainChange(Sender: TObject);
begin
  realignTimer.Enabled:=true;
end;

procedure TMainForm.realignTimerTimer(Sender: TObject);
var i:integer;
begin
  realignTimer.Enabled:=false;

  if EmerAPIServerTasks<>nil then
    for i:=0 to EmerAPIServerTasks.Count -1 do
      if (EmerAPIServerTasks[i].userObj1 <> nil) and (EmerAPIServerTasks[i].userObj1 is TFrameServerTask) then
          TFrameServerTask(EmerAPIServerTasks[i].userObj1).refreshView(Sender);

  if emerAPI<>nil then if emerAPI.UTXOList<>nil then
    for i:=0 to sbAssets.ControlCount-1 do
      if sbAssets.Controls[i] is TFrameBaseNVS then
        (sbAssets.Controls[i] as TFrameBaseNVS).updateView(Sender);
end;

procedure TMainForm.RebuildAssetsListTimerTimer(Sender: TObject);
begin
  RebuildAssetsListTimer.Enabled:=false;;
  RebuildAssetsList(self);
end;

procedure TMainForm.sbAssetsFilterAdConClick(Sender: TObject);
begin
  if pAssetsFilterDetailsHeight=0 then pAssetsFilterDetailsHeight:=pAssetsFilterDetails.Height;

  if pAssetsFilterDetails.Visible then begin
    pAssetsFilter.Height:=pAssetsFilterTop.Height;
    pAssetsFilterDetails.Visible:=false;
    ilAdvCon.GetBitmap(0,sbAssetsFilterAdCon.Glyph);
    RebuildAssetsList(Sender);
  end else begin
    pAssetsFilterDetails.Visible:=true;
    pAssetsFilter.Height:=pAssetsFilterTop.Height+pAssetsFilterDetailsHeight;
    ilAdvCon.GetBitmap(1,sbAssetsFilterAdCon.Glyph)
  end;

end;

procedure TMainForm.sbLWClick(Sender: TObject);
begin

  if not Settings.getValue('Use_Local_Wallet')
    then ShowWizardForm('doWalletConnect')
    else SetAndCheckBlockchain(true,false,true);
 CheckAdvices(nil);
end;


procedure TMainForm.sbPKClick(Sender: TObject);
begin
  if fHDNode.isValid then begin
    //opened: closing!
     deletePrivKey;
     if Settings.PubKey='' then begin
       eAddress.Text:='';
       eBalance.Text:='';
       eNamesCount.Text:='';
     end;
  end else if Settings.getValue('Priv_Key')<>'' then begin
     //encripted: decript
     getPrivkey;

  end else begin
    //unset: set!
    //MasterPasswordWizardForm.show;
    ShowWizardForm('domp');
    CheckAdvices(nil);
  end;
  updatePKstate(nil);
end;

procedure TMainForm.sbServerClick(Sender: TObject);
begin
  if (Settings.getValue('EMERAPI_SERVER_GUEST_ONLY') and  emerAPI.EmerAPIConnetor.serverAPI.testedOk)
     or
     (
       (not Settings.getValue('EMERAPI_SERVER_GUEST_ONLY')) and  //emerAPI.EmerAPIConnetor.serverAPI.testedOk
       (emerAPI.EmerAPIConnetor.serverAPI.EmerAPIBlockchainStatus=ebsError)
     )
    then ShowWizardForm('doServerConnect')
    else SetAndCheckBlockchain(false,true,true);
  CheckAdvices(nil);
end;

procedure TMainForm.timerAskForLibTimer(Sender: TObject);
var newPath:string;
begin

  timerAskForLib.Enabled:=false;
  exit; //!!!!!!!!
  {
  //CurrentLanguage:='en';
  AskQuestionInit();
  QuestionForm.FileNameEdit.Visible:=true;
  QuestionForm.FileNameEdit.Text:=SSL_C_LIB;
  {$IFDEF UNIX}
    {$IF not (Defined(LINUX) or Defined(DARWIN))}
      {$ERROR 'unsupported target'}
    {$IFEND}
    {$IFDEF OpenSSL10}
    {$IFDEF LINUX}
    QuestionForm.FileNameEdit.DefaultExt:='';
    QuestionForm.FileNameEdit.Filter:='All files(*.*)|*.*';
    {$ELSE}
    QuestionForm.FileNameEdit.DefaultExt:='dylib';
    QuestionForm.FileNameEdit.Filter:='Libraries(*.dylib)|*.dylib|All files(*.*)|*.*';
    {$ENDIF}
    {$ELSE}
    {$IFDEF LINUX}
    QuestionForm.FileNameEdit.DefaultExt:='';
    QuestionForm.FileNameEdit.Filter:='All files(*.*)|*.*';
    {$ELSE}
    QuestionForm.FileNameEdit.DefaultExt:='dylib';
    QuestionForm.FileNameEdit.Filter:='Libraries(*.dylib)|*.dylib|All files(*.*)|*.*';
    {$ENDIF}
    {$ENDIF}
  {$ELSE}
    QuestionForm.FileNameEdit.DefaultExt:='dll';
    QuestionForm.FileNameEdit.Filter:='Libraries(*.dll)|*.dll|All files(*.*)|*.*';
  {$ENDIF}



  QuestionForm.bOk.Visible:=true;
  QuestionForm.bCancel.Visible:=true;
  QuestionForm.bHelp.Visible:=true;
  QuestionForm.cLanguage.Visible:=true;
  QuestionForm.bOk.setFocus;

  if AskQuestionTag('MessageAskForLibPath') = mrOk then begin
    localizzze(self);
    localizzze(MainMenu);
    newPath:=trim(QuestionForm.FileNameEdit.Text);
  end else Close;

  if trim(newPath)='' then newPath:=SSL_C_LIB;

  if fileexists(newPath) then
     SSL_C_LIB:=newPath;

  if Not LoadSSLCrypt then begin
    AskQuestionTag('MessageCantOpenLib');
    Close;
  end else begin
     InitCrypto;
     Settings.setValue('SSL_C_LIB',newPath);
     Settings.save;
     //4. Attempt to obtain PrivKey or PubKey
     if (Settings.PubKey='') and (PrivKey='') then timerAskForMP.enabled:=true;
  end;
  }
end;

procedure TMainForm.onAnswer(sender:tObject;mr:tModalResult;mtag:ansistring);
begin
  //CurrentLanguage:='en';
  //if AskQuestionTag('MessageAskForCreateOrEnterMPNow')=mrYes
  if (mr=mrYes) and (mtag='MessageAskForCreateOrEnterMPNow')
    then begin ShowWizardForm('domp'); CheckAdvices(nil); end;

  if (mr=mrYes) and (mtag='MessageAskForLoginToServer')
    then openURL(fLastOpenURLLing);

  if (mr=mrYes) and (mtag='msgServerNetworkSettingsDifferent')
    then
    begin
      Settings.setValue('Dev_Mode_ON',true);
      Settings.setValue('Dev_WIF',fonAnswerDataWif);
      Settings.setValue('Dev_SIG',fonAnswerDataSig);
      Settings.setValue('DEV_SERVER_NETWORK',fonAnswerDataNet);
      Settings.saveParams(['Dev_Mode_ON','Dev_WIF','Dev_SIG','DEV_SERVER_NETWORK']);

      //reencrypt address
      {
      if Settings.getValue('KEEP_PRIVATE_KEY') then
      !Settings.PrivKey:=Encrypt_AES256(privKeyToCode58(MainForm.PrivKey, globals.WifID,true),tsSetUserPassEdit1.Text);
      !Settings.PubKey:=pubKeyToBuf(GetPublicKey(MainForm.PrivKey));
      !Settings.save();
      } //canceled

      //refresh view
      Update;
      SetAndCheckBlockchain();
      showWalletInfo();
    end;



  localizzze(self);
  localizzze(MainMenu);
end;

procedure TMainForm.onAnswerTools(sender:tObject;mr:tModalResult;mtag:ansistring);
var str,s:string;
    NetConnectionID:string;

 {$IFDEF Windows}
 function RunAsAdmin(const Handle: Hwnd; const Path, Params: string): Boolean;
 var
   sei: TShellExecuteInfoA;
   Ret: DWORD;
 begin
   FillChar(sei, SizeOf(sei), 0);
   sei.cbSize := SizeOf(sei);
   sei.Wnd := Handle;
   sei.fMask :=  SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI; //SEE_MASK_FLAG_NO_UI or SEE_MASK_NOCLOSEPROCESS; //          SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI    or SEE_MASK_NOCLOSEPROCESS;
   sei.lpVerb := 'runas';
   sei.lpFile := PAnsiChar(Path);
   sei.lpParameters := PAnsiChar(Params);
   sei.nShow := SW_HIDE;
   //sei.nShow := SW_SHOWNORMAL;
   Result := ShellExecuteExA(@sei);

   //sleep(1000);
   {
   if sei.hProcess <> 0 then
    try
      repeat
        Ret := MsgWaitForMultipleObjects(1, sei.hProcess, False, INFINITE, QS_ALLINPUT);
        if Ret = (WAIT_OBJECT_0+1) then Application.ProcessMessages
        else if Ret = WAIT_FAILED then RaiseLastOSError;
      until Ret = WAIT_OBJECT_0;
    finally
      CloseHandle(sei.hProcess);
    end;
    }
{
   if sei.hProcess <> 0 then begin
       while WaitForSingleObject(sei.hProcess, 50) = WAIT_TIMEOUT do
         Application.ProcessMessages;
       CloseHandle(sei.hProcess);
     end;
 }
 end;
 {$ENDIF Windows}

begin

  //http://www.supportrix.com/kb/how-to-change-the-dns-servers-via-terminal-on-a-mac/
  //route get example.com | grep interface
  //interface: en8

  if (mr=mrYes) and (mtag='msgSetOpenNicDNS') then begin

    if sender is TQuestionPanel then TQuestionPanel(sender).Enabled:=false;

    NetConnectionID:='';
    {$IFDEF Windows}
      //NetConnectionID:=trim(executeAndReturn(['nic where "NetConnectionStatus=2" get NetConnectionID'],false,'wmic.exe'));
      NetConnectionID:=trim(executeAndReturn(['nic where "NetConnectionStatus=2" get InterfaceIndex'],false,'wmic.exe'));
      if pos(#10,NetConnectionID)<1 then NetConnectionID:=''
      else begin
        delete(NetConnectionID,1,pos(#10,NetConnectionID));
        NetConnectionID:=trim(NetConnectionID);
        //NetConnectionID:='!Беспроводная сеть'
        //NetConnectionID:=#31#$80#$90#$FF
      end;

    {$ENDIF Windows}

    {$IFDEF Unix}
    {$ENDIF Unix}

    if NetConnectionID='' then with AskQuestionTag(self,nil,'MainForm.msgSetOpenNicDNSWrongNetId') do begin
         bOk.Visible:=true;
         bOk.setFocus;
         Update;
         exit;
       end;

    {
    //uses simpleinternet;
    with TFPHTTPClient.Create(nil) do try
      //str := get('https://api.opennic.org/geoip/?jsonp&res=4&ipv=4');
      str := trim(get('https://api.opennic.org/geoip/?bare&res=4&ipv=4'));
    finally
      Free;
    end;
    }
    str := trim(executeAndReturn(['"https://api.opennic.org/geoip/?bare&res=4&ipv=4"'],false,'curl'));

    //str := retrieve('https://www.opennic.org/');
    //opennic([{"host":"ns1.jp.dns.opennic.glue","short":"ns1.jp","ip":"108.61.161.119","loc":"JP","miles":1793,"kilometers":2883,"stat":"96.69","manager":"palinuro"},{"host":"ns5.nsw.au.dns.opennic.glue","short":"ns5.nsw.au","ip":"207.148.83.241","loc":"NSW, AU","miles":4491,"kilometers":7221,"stat":"99.97","manager":"connorw600"},{"host":"ns5.ru.dns.opennic.glue","short":"ns5.ru","ip":"91.217.137.37","loc":"RU","miles":4442,"kilometers":7141,"stat":"99.96","manager":"virus_net"},{"host":"ns1.in.dns.opennic.glue","short":"ns1.in","ip":"139.59.6.115","loc":"IN","miles":2487,"kilometers":3998,"stat":"98.53","manager":"palinuro"}]);
    if str='' then
       with AskQuestionTag(self,nil,'MainForm.msgSetOpenNicDNSWrongAnswer') do begin
         bOk.Visible:=true;
         bOk.setFocus;
         Update;
         exit;
       end;

    str:=str+#10;


    {$IFDEF Windows}
    //netsh interface ip add dns "!Беспроводная сеть" 8.8.8.8 index=1 & netsh interface ip add dns "!Беспроводная сеть" 8.8.4.4 index=1
     s:='';
     while pos(#10,str)>0 do begin
      if s<>'' then s:=s+' & ';
      s:=s +
       'netsh interface ip add dns '+NetConnectionID+' '+trim(copy(str,1,pos(#10,str)-1))+' index=1';
      delete(str,1,pos(#10,str));
      //str:='';
     end;
     if not RunAsAdmin(Handle, 'cmd', '/K '+s) then str:='error';
    {$ENDIF Windows}

    {
    while pos(#10,str)>0 do begin
      s:=trim(copy(str,1,pos(#10,str)-1));
      {$IFDEF Windows}
        //netsh interface ip add dns "NetConnectionID" 169.239.202.202 index=1
        //netsh interface ip add dns "NetConnectionID" 5.132.191.104 index=1
        //if trim(executeAndReturn(['interface ip add dns "'+NetConnectionID+'" '+s+' index=1'],true,'netsh'))='' then delete(str,1,pos(#10,str)) else break;
        if RunAsAdmin(Handle, 'netsh', 'interface ip add dns "'+NetConnectionID+'" '+s+' index=1') then delete(str,1,pos(#10,str)) else break;
        //if RunAsAdmin(Handle, 'cmd', '/K echo interface ip add dns '+NetConnectionID+' '+s+' index=1 & pause') then delete(str,1,pos(#10,str)) else break;



      {$ENDIF Windows}

      {$IFDEF Unix}
      {$ENDIF Unix}

      //showMessageSafe(str);


    end;
    }


    if str='' then
      with AskQuestionTag(self,nil,'MainForm.msgSetOpenNicDNSSuccess') do begin
             bOk.Visible:=true;
             bOk.setFocus;
             Update;
           end
    else
      with AskQuestionTag(self,nil,'MainForm.msgSetOpenNicDNSFail') do begin
             bOk.Visible:=true;
             bOk.setFocus;
             Update;
           end

  end;
end;

procedure TMainForm.timerAskForMPTimer(Sender: TObject);
begin
  timerAskForMP.Enabled:=false;



  with AskQuestionTag(self,@onAnswer,'MessageAskForCreateOrEnterMPNow') do begin
    //QuestionForm.Caption:=localizzzeString('QuestionForm.AskForMPTitle','Do you want to set up Master Password now?');
    bYes.Visible:=true;
    bNo.Visible:=true;
    bHelp.Visible:=true;
    cLanguage.Visible:=true;
    bYes.setFocus;

    Update;
  end;


  exit;

  AskQuestionInit();
  QuestionForm.Caption:=localizzzeString('QuestionForm.AskForMPTitle','Do you want to set up Master Password now?');
  QuestionForm.bYes.Visible:=true;
  QuestionForm.bNo.Visible:=true;
  QuestionForm.bHelp.Visible:=true;
  QuestionForm.cLanguage.Visible:=true;

  QuestionForm.bYes.setFocus;

  //CurrentLanguage:='en';
  if AskQuestionTag('MessageAskForCreateOrEnterMPNow')=mrYes
    then ShowWizardForm('domp');
  localizzze(self);
  localizzze(MainMenu);
  CheckAdvices(nil);
end;

procedure TMainForm.CheckAdvices(Sender:tObject);
begin
  //shows advices
  //1. if we have a private key, but guest mode, advice pRegisterOnServer
  if (Settings=nil) or (EmerAPI=nil) then exit;


  pRegisterMasterPassword.visible := Settings.getValue('Priv_Key')='';

  pRegisterOnServer.visible := (Settings.getValue('Priv_Key')<>'') and Settings.getValue('EmerAPI_Server_Use') {and EmerAPI.EmerAPIConnetor.serverAPI.testedOk} and Settings.getValue('EMERAPI_SERVER_GUEST_ONLY');


end;

end.

