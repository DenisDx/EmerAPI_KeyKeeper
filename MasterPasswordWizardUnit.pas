unit MasterPasswordWizardUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IpHtml, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, Buttons, StdCtrls, EnterMasterPasswordUnit,
  QuestionUnit, CreatePasswordUnit, passrateunit, Types, EmerAPIBlockchainUnit, fpjson, jsonparser;

type

  { TMasterPasswordWizardForm }

  TMasterPasswordWizardForm = class(TForm)
    createPassword1: TcreatePassword;
    EnterMasterPasswordFrame1: TEnterMasterPasswordFrame;
    EnterMasterPasswordFrame2: TEnterMasterPasswordFrame;
    tsConnectServerPanelCombobox: TComboBox;
    Panel12: TPanel;
    tsServerConnected: TTabSheet;
    tsConnectServerPanelChSelectServer: TCheckBox;
    tsServerLoginPanelLabel: TLabel;
    tsServerLoginBOpen: TBitBtn;
    tsServerLoginBRecheck: TBitBtn;
    tsServerConnectedPanel: TPanel;
    tsServerLoginBLinkToBuffer: TBitBtn;
    tsServerSelectBTest: TBitBtn;
    bShowUserPasswordGenerator: TBitBtn;
    bHelp: TBitBtn;
    bFinish: TBitBtn;
    bGenerateUserPass: TBitBtn;
    bNext: TBitBtn;
    bPrev: TBitBtn;
    bClose: TBitBtn;
    tsServerConnectedChDontSave: TCheckBox;
    tsServerSelectEdit1: TEdit;
    InlineMessageTimer: TTimer;
    lServerAddress: TLabel;
    Panel11: TPanel;
    tsServerLoginPanel: TPanel;
    Panel13: TPanel;
    tsServerSelectPanel: TPanel;
    tsServerLogin: TTabSheet;
    tsServerSelect: TTabSheet;
    tsConnectServerPanel: TPanel;
    Panel6: TPanel;
    PassRate2: TPassRate;
    tsServerSelectChAdv: TCheckBox;
    tsSetUserPassTimer: TTimer;
    tsSetPassDoneContinuePanel: TPanel;
    tsSetPassDoneFinishPanel: TPanel;
    tsSetUserPasschShowPassword: TCheckBox;
    tsCreateMasterPassFreeFormchShowPassword: TCheckBox;
    tsCreateMasterPassFreeFormEdit2: TEdit;
    tsCreateMasterPassFreeFormlPassword2: TLabel;
    tsCreateMasterPassFreeFormEdit1: TEdit;
    lPassword3: TLabel;
    Panel10: TPanel;
    Panel9: TPanel;
    tsCreateMasterPassFreeFormTimer: TTimer;
    tsSetUserPassTrackBar: TTrackBar;
    tsSetPassDoneContinueCSetupServer: TCheckBox;
    tsSetPassDoneFinish: TTabSheet;
    tsSetPassDoneContinue: TTabSheet;
    tsCreateMasterPass12wEditW1: TEdit;
    tsSetUserPassEdit1: TEdit;
    tsSetUserPassEdit2: TEdit;
    tsCreateMasterPass12wEditW10: TEdit;
    tsCreateMasterPass12wEditW11: TEdit;
    tsCreateMasterPass12wEditW12: TEdit;
    tsCreateMasterPass12wEditW2: TEdit;
    tsCreateMasterPass12wEditW3: TEdit;
    tsCreateMasterPass12wEditW4: TEdit;
    tsCreateMasterPass12wEditW5: TEdit;
    tsCreateMasterPass12wEditW6: TEdit;
    tsCreateMasterPass12wEditW7: TEdit;
    tsCreateMasterPass12wEditW8: TEdit;
    tsCreateMasterPass12wEditW9: TEdit;
    tsCreateMasterPass12wlW1: TLabel;
    lPassword1: TLabel;
    tsSetUserPasslPassword2: TLabel;
    Panel3: TPanel;
    tsSetUserPassGeneratorPanel: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    PassRate1: TPassRate;
    tsCreateMasterPass12wlW10: TLabel;
    tsCreateMasterPass12wlW11: TLabel;
    tsCreateMasterPass12wlW12: TLabel;
    tsCreateMasterPass12wlW2: TLabel;
    tsCreateMasterPass12wlW3: TLabel;
    tsCreateMasterPass12wlW4: TLabel;
    tsCreateMasterPass12wlW5: TLabel;
    tsCreateMasterPass12wlW6: TLabel;
    tsCreateMasterPass12wlW7: TLabel;
    tsCreateMasterPass12wlW8: TLabel;
    tsCreateMasterPass12wlW9: TLabel;
    tsCreateMasterPass12wPanel: TPanel;
    tsCreateMasterPassFreeFormPanel: TPanel;
    tsCheckMasterPassPanel: TPanel;
    tsSetUserPassPanel: TPanel;
    tsSetUserPass: TTabSheet;
    MainPageControl: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel5: TPanel;
    tsRestoreMasterPassPanel: TPanel;
    tsCreateNewMasterPass1Panel: TPanel;
    Panel4: TPanel;
    tsAskForMasterPassPanel: TPanel;
    tsCreateNewMasterPass1RB1: TRadioButton;
    tsCreateNewMasterPass1RB2: TRadioButton;
    tsAskForMasterPassRB1: TRadioButton;
    tsAskForMasterPassRB2: TRadioButton;
    tsConnectAllDone: TTabSheet;
    tsConnectServer: TTabSheet;
    tsConnectLocalWallet: TTabSheet;
    tsConnectionSelect: TTabSheet;
    tsKeepMasterPass: TTabSheet;
    tsCheckMasterPass: TTabSheet;
    tsCreateMasterPass12w: TTabSheet;
    tsCreateMasterPassFreeForm: TTabSheet;
    tsCreateNewMasterPass1: TTabSheet;
    tsAskForMasterPass: TTabSheet;
    tsRestoreMasterPass: TTabSheet;
    tsSetUserPassPanel1: TPanel;
    tsSetUserPassPanelCDoNotSave: TCheckBox;
    procedure bCloseClick(Sender: TObject);
    procedure bClick(Sender: TObject);
    procedure bGenerateUserPassClick(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
    procedure tsServerConnectedHide(Sender: TObject);
    procedure tsServerConnectedShow(Sender: TObject);
    procedure bShowUserPasswordGeneratorClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InlineMessageTimerTimer(Sender: TObject);
    procedure tsCheckMasterPassShow(Sender: TObject);
    procedure tsConnectServerPanelChSelectServerClick(Sender: TObject);
    procedure tsConnectServerShow(Sender: TObject);
    procedure tsCreateMasterPass12wShow(Sender: TObject);
    procedure tsCreateMasterPassFreeFormEdit1Change(Sender: TObject);
    procedure tsCreateMasterPassFreeFormchShowPasswordChange(
      Sender: TObject);
    procedure tsCreateMasterPassFreeFormEdit2Change(Sender: TObject);
    procedure tsCreateMasterPassFreeFormTimerTimer(Sender: TObject);
    procedure tsServerLoginBLinkToBufferClick(Sender: TObject);
    procedure tsServerLoginBOpenClick(Sender: TObject);
    procedure tsServerLoginBRecheckClick(Sender: TObject);
    procedure tsServerLoginHide(Sender: TObject);
    procedure tsServerLoginShow(Sender: TObject);
    procedure tsServerLoginPanelTryToConnect;
    procedure tsSetPassDoneContinueHide(Sender: TObject);
    procedure tsSetPassDoneContinueShow(Sender: TObject);
    procedure tsSetPassDoneFinishHide(Sender: TObject);
    procedure tsSetPassDoneFinishShow(Sender: TObject);
    procedure tsSetUserPasschShowPasswordChange(Sender: TObject);
    procedure tsSetUserPassEdit1Change(Sender: TObject);
    procedure tsSetUserPassEdit2Change(Sender: TObject);
    procedure tsSetUserPassHide(Sender: TObject);
    procedure tsSetUserPassPanelCDoNotSaveChange(Sender: TObject);
    procedure tsSetUserPassShow(Sender: TObject);
    procedure tsAskForMasterPassHide(Sender: TObject);
    procedure tsAskForMasterPassShow(Sender: TObject);
    procedure tsCheckMasterPassHide(Sender: TObject);
    procedure tsConnectAllDoneHide(Sender: TObject);
    procedure tsConnectionSelectHide(Sender: TObject);
    procedure tsConnectLocalWalletHide(Sender: TObject);
    procedure tsConnectServerHide(Sender: TObject);
    procedure tsCreateMasterPass12wHide(Sender: TObject);
    procedure tsCreateMasterPassFreeFormHide(Sender: TObject);
    procedure tsCreateMasterPassFreeFormShow(Sender: TObject);
    procedure tsCreateNewMasterPass1Hide(Sender: TObject);
    procedure tsCreateNewMasterPass1Show(Sender: TObject);
    procedure tsKeepMasterPassHide(Sender: TObject);
    procedure tsSetPassDoneContinueCSetupServerChange(Sender: TObject);
    procedure tsRestoreMasterPassHide(Sender: TObject);
    procedure EnterMasterPasswordFrame1PasswordChanged(Sender: TObject);
    procedure EnterMasterPasswordFrame2PasswordChanged(Sender: TObject);
    procedure tsRestoreMasterPassShow(Sender: TObject);
    procedure goBack; //lHistoryStack
    procedure goNext(ts:tTabSheet); //lHistoryStack
    procedure setButtonsDefault;
    procedure tsRestoreMasterPassAnswer1(sender:tObject;aModalResult:tModalResult;atag:ansistring);
    procedure ShowInlineMessage(aTag:ansistring;aMessage:string='';ahelpURL:ansistring='');
    function AskInlineYesNo(answerProc:tAskQuestionOnAnswer;aTag:ansistring;aMessage:string='';ahelpURL:ansistring='';YesByDefault:boolean=false):boolean;
    procedure tsSetUserPassTimerTimer(Sender: TObject);
    procedure tsSetUserPassTrackBarChange(Sender: TObject);
  private
    tsRestoreMasterPassLastSavedPass:string;
    tsCreateMasterPassLastSavedPass:string;
    lHistoryStack:tList;

    tsServerLoginAddress:string;
    //tsServerLoginSalt:ansistring;

    fLastServerLoginLink:ansistring;

    InlineMessageaMessage:string;
    InlineMessageaHelpURL:ansistring;
    InlineMessageaTag:ansistring;

    procedure myQueryDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
  public
    wizardID:ansistring;
  end;


{ Логотип (с) работы.

1. Вопрос о наличии МП. Рассказ о том, что такое МП. Если есть - то идем сразу на ввод имеющегося МП (там по набираемому парлю сразу показывают адрес)

2. Выбор способа задания МП: фраза из слов, рандомные символы, готовая фраза из слов
Показывают устойчивость пароля, показывают предупреждения (нет групп символов), показывают получившийся адрес.

3. Сохранение МП. Рассказ про сохранения (технология круга, разбиение на пары)
  - разбивалка МП на части. Предлагает печать.
  - шифровалка МП?
  - Показывает QR код MP. Предлагает печать.

4. Ввод МП для подтверждения. Переход на п.6


5. () Восстановление ключевой пары (КП) по МП. Рассказываем о том, что если у вас НОВЫЙ пароль - переходите на экран 2. Показываем по вводимому МП соотвествующие адреса.

6. Хотим ли мы сохранить КП на компьютере? Объясняем нюансы, здесь же кнопка задания пароля пользователя (открывается окно смены/задания пароля пользователя)
устанавливаются настройки хранения КП, сейвим настройки.

----процесс соединения с сервером-----
1. Пользователь говорит что хочет настроить подлючение к серверу и выбирает сервер из списка (или вводит свой)
если есть логин и пароль - можно ввести или исправить их (берутся из настроек) здесь же.

Пользователь посылает серверу свой адрес . Север либо опознает этот адрес , либо нет - в любом случае он отвечает запросом. сообщая, узнал ли он пользователя, и просит подтвердить подлинность, зашифровав криптосообщениие
для случая что пользователь опознан - просто сообщаем что адрес серверу уже известен, связь установлена. если нет - то показываем второй экран

2. Пользователю говорят, что сервер не знает такой адрес, или что его логин и пароль не распознаны или не соответствуют адресу (или иной ответ от сервера)
Для случаев, когда продолжение возможно, пользователь подтвержает регистрацию на сервере. При этом отправляется публичный ключ и сделанная приватником
(!требуется ввод пин на этом этапе)
подпись присланной сервером последовательности байтов.
Если сервер ее проверил и она совпала - он возвращает ссылку на страницу регистрации, и дальше все идет на сервере.













}



var
  MasterPasswordWizardForm: TMasterPasswordWizardForm;

function ShowWizardForm(wizardID:ansistring):boolean;

implementation

{$R *.lfm}

uses  Localizzzeunit,GuidePageUnit, PasswordHelper, MainUnit, settingsunit, ClpSecureRandom, CryptoLib4PascalConnectorUnit,
  Crypto, EmerAPIServerUnit, Clipbrd, LCLIntf
  ,HelpRedirector

  ;

{ TMasterPasswordWizardForm }

procedure destroyGuidePage(panel:tPanel);
begin
  while TWinControl(panel).ControlCount>0 do
    TWinControl(panel).Controls[0].Free;
end;

procedure createGuidePage(panel:tPanel);
begin
  tGuidePage.create(panel).Align:=alClient;
end;

function ShowWizardForm(wizardID:ansistring):boolean;
var i:integer;
begin
  result:=false;

  try

  if MasterPasswordWizardForm.MainPageControl.ActivePage<>nil then
    if assigned(MasterPasswordWizardForm.MainPageControl.ActivePage.OnHide)
      then MasterPasswordWizardForm.MainPageControl.ActivePage.OnHide(nil);

  MasterPasswordWizardForm.MainPageControl.ActivePage:=nil;
  application.ProcessMessages;
  for i:=0 to MasterPasswordWizardForm.MainPageControl.PageCount-1 do
    MasterPasswordWizardForm.MainPageControl.Pages[i].Visible:=false;

  if MasterPasswordWizardForm.lHistoryStack<>nil then MasterPasswordWizardForm.lHistoryStack.clear;

  MasterPasswordWizardForm.MainPageControl.PageIndex:=-1;
  if lowercase(wizardID)='doall' then begin
    result:=true;
    result:=ShowWizardForm('domp');  if not result then exit;
    result:=ShowWizardForm('doServerConnect');  if not result then exit;
    result:=ShowWizardForm('doWalletConnect');  if not result then exit;
    exit;
  end else
  if lowercase(wizardID)='domp' then begin
    MasterPasswordWizardForm.MainPageControl.PageIndex:=0;
    MasterPasswordWizardForm.wizardID:='domp';
    if assigned(MasterPasswordWizardForm.MainPageControl.ActivePage.OnShow)
       then MasterPasswordWizardForm.MainPageControl.ActivePage.OnShow(nil);
  end

  else if lowercase(wizardID)='doserverconnect' then begin
    MasterPasswordWizardForm.wizardID:='doserverconnect';
    MasterPasswordWizardForm.MainPageControl.ActivePage:=MasterPasswordWizardForm.tsConnectServer;
    if assigned(MasterPasswordWizardForm.MainPageControl.ActivePage.OnShow)
       then MasterPasswordWizardForm.MainPageControl.ActivePage.OnShow(nil);
  end

  else exit;


 finally
    MainForm.CheckAdvices(MasterPasswordWizardForm);
 end;
 MasterPasswordWizardForm.MainPageControl.ShowTabs:=false;
 result:=MasterPasswordWizardForm.ShowModal=mrOk;
end;


procedure TMasterPasswordWizardForm.setButtonsDefault;
begin
  bFinish.Enabled:=true;
  bNext.Enabled:=true;
  bPrev.Enabled:=true;

  bFinish.Visible:=false;
  bNext.Visible:=true;
  bPrev.Visible:=lHistoryStack.Count>0;
end;

procedure TMasterPasswordWizardForm.goBack; //lHistoryStack
var ts: TTabSheet;
begin
  if lHistoryStack.Count>0 then begin
    ts:=TTabSheet(lHistoryStack[lHistoryStack.Count-1]);
    lHistoryStack.Delete(lHistoryStack.Count-1);
    MainPageControl.ActivePage:=ts;
  end;
end;

procedure TMasterPasswordWizardForm.goNext(ts:tTabSheet); //lHistoryStack
begin
 lHistoryStack.Add(MainPageControl.ActivePage);
 application.processmessages;
 MainPageControl.ActivePage:=ts;
end;

procedure TMasterPasswordWizardForm.tsAskForMasterPassHide(Sender: TObject);
begin
  if sender=bNext then begin
    if tsAskForMasterPassRB1.Checked then
      goNext(tsRestoreMasterPass)
    else if tsAskForMasterPassRB2.Checked then
      goNext(tsCreateNewMasterPass1)
    else exit;
    //lHistoryStack.Add(tsAskForMasterPass);
  end else
  if sender=bPrev then begin

  end else
  if sender=bFinish then begin

  end else
  if sender=bHelp then begin

  end else
    destroyGuidePage(tsAskForMasterPassPanel);
end;

procedure TMasterPasswordWizardForm.bCloseClick(Sender: TObject);
begin
  bClick(Sender);
  if visible then
    Close;
end;


procedure TMasterPasswordWizardForm.bClick(Sender: TObject);
begin
  if assigned(MainPageControl.ActivePage.OnHide) then
     MainPageControl.ActivePage.OnHide(Sender);
end;

procedure TMasterPasswordWizardForm.bGenerateUserPassClick(Sender: TObject);
var s:string;
begin
  s:=createPassword1.createPassword(tsSetUserPassTrackBar.Position);
  tsSetUserPassEdit1.Text:=s;
  tsSetUserPassEdit2.Text:='';
  if not tsSetUserPasschShowPassword.Checked then begin
    tsSetUserPasschShowPassword.Checked:=true;
    tsSetUserPasschShowPasswordChange(nil);
  end;
end;

procedure TMasterPasswordWizardForm.bHelpClick(Sender: TObject);
begin

  showHelpTag('MasterPasswordWizardForm',nil,MainPageControl.ActivePage.Name);
  //if assigned(MainPageControl.ActivePage.OnHide) then
  //   MainPageControl.ActivePage.OnHide(Sender);


end;

procedure TMasterPasswordWizardForm.tsServerConnectedHide(Sender: TObject);
var s1,s2:ansistring;
begin
  if sender=bNext then begin
     goNext(tsServerConnected);
  end else
  if sender=bPrev then begin
     if lHistoryStack.Count>1 then begin
       lHistoryStack.Delete(lHistoryStack.Count-1);
       goBack;
     end;
  end else
  if sender=bFinish then begin
    if not tsServerConnectedChDontSave.Checked then begin
      Settings.setValue('EmerAPI_Server_Save_yum_l',true);
      Settings.setValue('EMERAPI_SERVER_GUEST_ONLY',false);

      if tsConnectServerPanelChSelectServer.Checked then
         Settings.setValue('EMERAPI_SERVER_ADDRESS',tsServerLoginAddress);

      Settings.saveParams(['EMERAPI_SERVER_ADDRESS','EmerAPI_Server_adv_SessionKey','EmerAPI_Server_Login_Address','EmerAPI_Server_adv_yum_l','EmerAPI_Server_Save_yum_l','EMERAPI_SERVER_GUEST_ONLY']);

    end else begin
      //erase info
      s1:=Settings.getValue('EmerAPI_Server_adv_SessionKey');
      s2:=Settings.getValue('sssEmerAPI_Server_adv_yum_l');
      Settings.setValue('EmerAPI_Server_Save_yum_l',false);
      Settings.setValue('EmerAPI_Server_adv_SessionKey','');
      Settings.setValue('sssEmerAPI_Server_adv_yum_l','');
      Settings.saveParams(['EmerAPI_Server_adv_SessionKey','EmerAPI_Server_Login_Address','EmerAPI_Server_adv_yum_l','EmerAPI_Server_Save_yum_l']);
      Settings.setValue('EmerAPI_Server_adv_SessionKey',s1);
      Settings.setValue('sssEmerAPI_Server_adv_yum_l',s2);
    end;
    emerAPI.EmerAPIConnetor.serverAPI.throwErrorStatus;
    MainForm.SetAndCheckBlockchain(false,true,true);
    MainForm.onServerConnected(nil);
    modalResult:=mrOk;
    //close;
  end else
  if sender=bHelp then begin

  end else
    destroyGuidePage(tsServerLoginPanel);
end;

procedure TMasterPasswordWizardForm.tsServerConnectedShow(Sender: TObject);
begin
  createGuidePage(tsServerConnectedPanel);
  setButtonsDefault;
  bNext.Visible:=false;
  bFinish.Visible:=true;
end;

procedure TMasterPasswordWizardForm.bShowUserPasswordGeneratorClick(
  Sender: TObject);
begin
  tsSetUserPassGeneratorPanel.Visible:=not tsSetUserPassGeneratorPanel.Visible;
end;


procedure TMasterPasswordWizardForm.FormCreate(Sender: TObject);
begin
  lHistoryStack:=tList.create;
  KeyPreview:=True;
end;

procedure TMasterPasswordWizardForm.FormDestroy(Sender: TObject);
begin
  lHistoryStack.free;
end;


procedure TMasterPasswordWizardForm.FormShow(Sender: TObject);
begin
  localizzze(self);
end;


procedure TMasterPasswordWizardForm.tsCheckMasterPassShow(Sender: TObject);
begin
  createGuidePage(tsCheckMasterPassPanel);
  setButtonsDefault;
  bNext.Enabled:=false;

  EnterMasterPasswordFrame2.eAddress.Text:='';
  EnterMasterPasswordFrame2.init;
  EnterMasterPasswordFrame2.onPasswordChanged:=@EnterMasterPasswordFrame2PasswordChanged;
  if EnterMasterPasswordFrame2.eMasterPassword.CanSetFocus then
    EnterMasterPasswordFrame2.eMasterPassword.SetFocus;

  EnterMasterPasswordFrame2.lAssignedAddress.Visible:=false;
  EnterMasterPasswordFrame2.eAddress.Visible:=false;

end;

procedure TMasterPasswordWizardForm.tsConnectServerPanelChSelectServerClick(
  Sender: TObject);
begin
  tsConnectServerPanelCombobox.Visible:=tsConnectServerPanelChSelectServer.Checked;
end;

procedure TMasterPasswordWizardForm.tsConnectServerShow(Sender: TObject);
begin
  createGuidePage(tsConnectServerPanel);
  setButtonsDefault;
  bPrev.Visible:=lHistoryStack.Count>0;
  tsConnectServerPanelChSelectServerClick(nil);
end;


procedure TMasterPasswordWizardForm.tsCreateMasterPass12wShow(Sender: TObject);
var FRandom :TSecureRandom;
    Bytes:TBytes;

    hash,buf:ansistring;
    res:ansistring;
    crc:byte;
    i:integer;
    s:string;

    function pop(var s:string;spacer:string=' '):string;
    var n:integer;
    begin
       n:=pos(spacer,s);
       if n<1 then begin
          result:=s;
          s:='';
          exit;
       end;
       result:=copy(s,1,n-1);
       delete(s,1,n+length(spacer)-1);
    end;

begin

  if tsCreateMasterPassLastSavedPass='' then begin
    FRandom := TSecureRandom.Create();
    FRandom.Boot();

    setLength(Bytes,16);
    FRandom.NextBytes(Bytes);
    buf:=bytes2buf(Bytes);

    hash:=dosha256(buf);
    crc:=ord(hash[1]) shr (8 - length(buf) div 4);

    res:=shlbuf(buf,length(buf) div 4);

    res[length(res)]:=chr(ord(res[length(res)]) + crc);

    tsCreateMasterPassLastSavedPass:=bytesToBIP39(res,bip0039english,' ');
  end;
  s:=tsCreateMasterPassLastSavedPass;

  tsCreateMasterPass12wEditW1.Text:=pop(s,' ');
  tsCreateMasterPass12wEditW2.Text:=pop(s,' ');
  tsCreateMasterPass12wEditW3.Text:=pop(s,' ');
  tsCreateMasterPass12wEditW4.Text:=pop(s,' ');
  tsCreateMasterPass12wEditW5.Text:=pop(s,' ');
  tsCreateMasterPass12wEditW6.Text:=pop(s,' ');
  tsCreateMasterPass12wEditW7.Text:=pop(s,' ');
  tsCreateMasterPass12wEditW8.Text:=pop(s,' ');
  tsCreateMasterPass12wEditW9.Text:=pop(s,' ');
  tsCreateMasterPass12wEditW10.Text:=pop(s,' ');
  tsCreateMasterPass12wEditW11.Text:=pop(s,' ');
  tsCreateMasterPass12wEditW12.Text:=pop(s,' ');


  createGuidePage(tsCreateMasterPass12wPanel);
  setButtonsDefault;
end;

procedure TMasterPasswordWizardForm.tsCreateMasterPassFreeFormEdit1Change(
  Sender: TObject);
begin
   tsCreateMasterPassFreeFormTimer.Enabled:=false;
   tsCreateMasterPassFreeFormTimer.Enabled:=true;

   tsCreateMasterPassFreeFormEdit2Change(nil);
end;

procedure TMasterPasswordWizardForm.tsCreateMasterPassFreeFormchShowPasswordChange
  (Sender: TObject);
begin
  tsCreateMasterPassFreeFormEdit2.Enabled:=not tsCreateMasterPassFreeFormchShowPassword.checked;
  if not tsCreateMasterPassFreeFormEdit2.Enabled then tsCreateMasterPassFreeFormEdit2.Text:='';
  tsCreateMasterPassFreeFormlPassword2.Enabled:=tsCreateMasterPassFreeFormEdit2.Enabled;

  if tsCreateMasterPassFreeFormchShowPassword.Checked
    then tsCreateMasterPassFreeFormEdit1.PasswordChar:=#0
    else tsCreateMasterPassFreeFormEdit1.PasswordChar:='*';
end;

procedure TMasterPasswordWizardForm.tsCreateMasterPassFreeFormEdit2Change(
  Sender: TObject);
begin

  bNext.Enabled:= (tsCreateMasterPassFreeFormEdit2.Text=tsCreateMasterPassFreeFormEdit1.Text) or tsCreateMasterPassFreeFormchShowPassword.Checked;

  if (tsCreateMasterPassFreeFormEdit2.Text<>tsCreateMasterPassFreeFormEdit1.Text) and (tsCreateMasterPassFreeFormEdit2.Text<>'') and tsCreateMasterPassFreeFormEdit2.enabled
    then tsCreateMasterPassFreeFormEdit2.Color:=clRed
    else tsCreateMasterPassFreeFormEdit2.Color:=clDefault;

end;

procedure TMasterPasswordWizardForm.tsCreateMasterPassFreeFormTimerTimer(
  Sender: TObject);
begin
  tsCreateMasterPassFreeFormTimer.Enabled:=false;
  PassRate2.UpdateStat(tsCreateMasterPassFreeFormEdit1.Text);

  bNext.Enabled:=(bNext.Enabled and (PassRate2.pbRate.Position>30)) or Settings.getValue('Dev_Mode_ON');
end;

procedure TMasterPasswordWizardForm.tsServerLoginBLinkToBufferClick(
  Sender: TObject);
begin
  Clipboard.AsText:=fLastServerLoginLink;
end;

procedure TMasterPasswordWizardForm.tsServerLoginBOpenClick(Sender: TObject);
begin
  OpenURL(fLastServerLoginLink);
end;

procedure TMasterPasswordWizardForm.tsServerLoginBRecheckClick(Sender: TObject);
begin
  tsServerLoginPanelTryToConnect();
end;

procedure TMasterPasswordWizardForm.tsServerLoginHide(Sender: TObject);
begin
  if sender=bNext then begin
     goNext(tsServerConnected);
  end else
  if sender=bPrev then begin
     goBack;
  end else
  if sender=bFinish then begin

  end else
  if sender=bHelp then begin

  end else
    destroyGuidePage(tsServerLoginPanel);
end;

procedure TMasterPasswordWizardForm.myQueryDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
var e,js:tJsonData;
    ddr:tDecodeDataResult;
    dData:ansistring;
begin

  if result=nil then begin
      tsServerLoginPanelLabel.Caption:=localizzzeString('MasterPasswordWizardForm.tsServerLoginPanelLabel.ConnError','');
      tsServerLoginBRecheck.Enabled:=true;
      tsServerLoginBOpen.Enabled:=false;
      tsServerLoginBLinkToBuffer.Enabled:=false;
  end else begin
    //show JSON everywhere
    //{ "data" : { "userlogin" : { "response" : "EmerHEJ_041617d.....4337512d0a326" } } }

    //showMessageSafe(result.AsJSON);
    e:=result.FindPath('data.userlogin.response');
    if e=nil then begin
      bNext.Enabled:=false;
      tsServerLoginBRecheck.Enabled:=true;
      tsServerLoginBOpen.Enabled:=false;
      tsServerLoginBLinkToBuffer.Enabled:=false;
      tsServerLoginPanelLabel.Caption:=localizzzeString('MasterPasswordWizardForm.tsServerLoginPanelLabel.ConnError','');
    end else begin
      //decode
      ddr:=emerAPI.EmerAPIConnetor.serverAPI.decodeDataJSON(e.AsString,js);
      try
        if ddr<>ddrSuccesseful then begin
          tsServerLoginBRecheck.Enabled:=true;
          tsServerLoginBOpen.Enabled:=false;
          tsServerLoginBLinkToBuffer.Enabled:=false;

          case ddr of
            ddrWrongPrivKey: tsServerLoginPanelLabel.Caption:=localizzzeString('MasterPasswordWizardForm.tsServerLoginPanelLabel.WrongPrivKey','Error: wrong private key. Cannot decode server response');
            ddrWrongAESKey: tsServerLoginPanelLabel.Caption:=localizzzeString('MasterPasswordWizardForm.tsServerLoginPanelLabel.WrongAESKey','Error: wrong AES key. Cannot decode server response');
            //ddrBinaryData: raise exception.Create('binary data received. Cannot decode server JSON response');

          else
            //raise exception.Create('unknown server response');
            tsServerLoginPanelLabel.Caption:=localizzzeString('MasterPasswordWizardForm.tsServerLoginPanelLabel.UnknownResponse','Error: Unknown server response');
          end;
        end else begin
            //OK!!!
           //showMessageSafe(js.AsJson);
           { "sid" : "0B033E4C5BB1A9ED", "url" : "https://emcdpo.info/sign-up?token=", "token" : "5c1e26adf3a60864cd8d64c8" }

           //check sid
           e:=js.FindPath('sid');
           if (e=nil) or (e.AsString<>bufToHex(emerAPI.EmerAPIConnetor.serverAPI.LastServerLoginSalt)) then begin
            tsServerLoginPanelLabel.Caption:=localizzzeString('MasterPasswordWizardForm.tsServerLoginPanelLabel.WorngResponse','Error: Wrong server response');
            tsServerLoginBRecheck.Enabled:=true;
            tsServerLoginBOpen.Enabled:=false;
            tsServerLoginBLinkToBuffer.Enabled:=false;
            exit;
           end;


           e:=js.FindPath('session_key');
           if e<>nil then begin
             //we have session key
             //confuguring access
            //ConnDataServer.connectUsingUsername:=not Settings.getValue('EmerAPI_Server_Login_Address');
            //ConnDataServer.AESKey:=Settings.getValue('EmerAPI_Server_adv_SessionKey');
            //showMessageSafe('session_key='+e.AsString);
            Settings.setValue('EmerAPI_Server_adv_SessionKey',bufToHex(HexToBuf(e.AsString)));//hex to hex
            //Settings.setValue('EmerAPI_Server_adv_SessionKey',bufToHex(e.AsString));//D!!!
            Settings.setValue('EmerAPI_Server_Login_Address',true);
            //Settings.saveParams(['EmerAPI_Server_adv_SessionKey','EmerAPI_Server_Login_Address','EmerAPI_Server_adv_yum_l']);

            e:=js.FindPath('cookies._yum_l');
            if e<>nil then
              Settings.setValue('EmerAPI_Server_adv_yum_l',ansistring(e.AsString));

            try
              e:=js.FindPath('network');
              if e<>nil then begin
                 MainForm.queryForNetworkSettings(
                  strToInt('$'+e.FindPath('wif').AsString),
                  strToInt('$'+e.FindPath('adrsig').AsString),
                  e.FindPath('netstr').AsString
                 );
              end;
            except
            end;

            tsServerLoginPanelLabel.Caption:='';
            bNext.Enabled:=true;

            if assigned(MainPageControl.ActivePage.OnHide) then
               MainPageControl.ActivePage.OnHide(bNext);
           end else begin
             e:=js.FindPath('url');
             if e<>nil then begin
               //URL received
               tsServerLoginPanelLabel.Caption:=localizzzeString('MasterPasswordWizardForm.tsServerLoginPanelLabel.NotRegistered','Server has not recognized your address. You must login/sign in');
               tsServerLoginBRecheck.Enabled:=true;
               tsServerLoginBOpen.Enabled:=true;
               tsServerLoginBLinkToBuffer.Enabled:=true;
               fLastServerLoginLink:=e.AsString;

               e:=js.FindPath('token');
               if e<>nil then
                 fLastServerLoginLink:=fLastServerLoginLink+e.AsString;

             end else begin
               //Incorrect report
               tsServerLoginPanelLabel.Caption:=localizzzeString('MasterPasswordWizardForm.tsServerLoginPanelLabel.UnknownResponse','Error: Unknown server response');
               tsServerLoginBRecheck.Enabled:=true;
               tsServerLoginBOpen.Enabled:=false;
               tsServerLoginBLinkToBuffer.Enabled:=false;
             end;
           end;

        end;

      finally
        if js<>nil then js.free;
      end;


    end;
  end;

end;


procedure TMasterPasswordWizardForm.tsServerLoginPanelTryToConnect;
var ud:tpServerThreadUserData;
    ss:tEmerApiServerSettings;
begin
  tsServerLoginPanelLabel.Caption:=localizzzeString('MasterPasswordWizardForm.tsServerLoginPanelLabel.Connect','Trying to connect to the server ...');

  if tsServerLoginAddress<>'' then begin
    //EmerAPI.EmerAPIConnetor.connDataServer.address:=tsServerLoginAddress;
    ss:=EmerAPI.EmerAPIConnetor.serverAPI.connData;
    if ss.address<>tsServerLoginAddress then begin
      ss.address:=tsServerLoginAddress;
      EmerAPI.EmerAPIConnetor.serverAPI.connData:=ss;
    end;
  end;

  // /user/bywallet
//  query {
//  userlogin(request: <salt 16 b><public_key compressed>) {
//  	response
//  }
//  }

  try
     emerAPI.EmerAPIConnetor.serverAPI.connectUsingPublicKey(@myQueryDone).Resume;
     //fTasksList.AddObject(result.id,result);
     //checkForReadyToStart;

  except
    tsServerLoginPanelLabel.Caption:=localizzzeString('MasterPasswordWizardForm.tsServerLoginPanelLabel.WrongPublicKey','Error: Wrong public key');
    tsServerLoginBRecheck.Enabled:=true;
    tsServerLoginBOpen.Enabled:=false;
    tsServerLoginBLinkToBuffer.Enabled:=false;
    exit;
  end;
//  getRandomChars();

  tsServerLoginBRecheck.Enabled:=false;
  tsServerLoginBOpen.Enabled:=false;
  tsServerLoginBLinkToBuffer.Enabled:=false;

end;

procedure TMasterPasswordWizardForm.tsServerLoginShow(Sender: TObject);
begin
  createGuidePage(tsServerLoginPanel);
  setButtonsDefault;
  bNext.Enabled:=false;
  tsServerLoginPanelTryToConnect;
end;

procedure TMasterPasswordWizardForm.tsSetPassDoneContinueHide(Sender: TObject);
begin
  if sender=bNext then begin
     goNext(tsConnectServer);
  end else
  if sender=bPrev then begin
     goBack;
  end else
  if sender=bFinish then begin
     modalResult:=mrOk;
     //close;
  end else
  if sender=bHelp then begin

  end else begin
    destroyGuidePage(tsSetPassDoneContinuePanel);
  end;
end;

procedure TMasterPasswordWizardForm.tsSetPassDoneContinueShow(Sender: TObject);
begin
  createGuidePage(tsSetPassDoneContinuePanel);
  setButtonsDefault;
  //bNext.Visible:=false;
  //bFinish.Visible:=true;
  tsSetPassDoneContinueCSetupServer.Checked:=true;
  tsSetPassDoneContinueCSetupServerChange(nil);
end;

procedure TMasterPasswordWizardForm.tsSetPassDoneFinishHide(Sender: TObject);
begin
   if sender=bNext then begin

   end else
   if sender=bPrev then begin
      goBack;
   end else
   if sender=bFinish then begin
      modalResult:=mrOk;
      //close;
   end else
   if sender=bHelp then begin

   end else begin
     destroyGuidePage(tsSetPassDoneFinishPanel);
   end;
end;

procedure TMasterPasswordWizardForm.tsSetPassDoneFinishShow(Sender: TObject);
begin
  createGuidePage(tsSetPassDoneFinishPanel);
  setButtonsDefault;
  bNext.Visible:=false;
  bFinish.Visible:=true;
end;

procedure TMasterPasswordWizardForm.tsSetUserPasschShowPasswordChange(
  Sender: TObject);
begin
  tsSetUserPassEdit2.Enabled:= not tsSetUserPasschShowPassword.Checked;

  if not tsSetUserPassEdit2.Enabled then tsSetUserPassEdit2.Text:='';

  tsSetUserPasslPassword2.Enabled:= not tsSetUserPasschShowPassword.Checked;
  if tsSetUserPasschShowPassword.Checked
    then tsSetUserPassEdit1.PasswordChar:=#0
    else tsSetUserPassEdit1.PasswordChar:='*';
end;

procedure TMasterPasswordWizardForm.tsSetUserPassEdit1Change(Sender: TObject);
begin
  tsSetUserPassTimer.Enabled:=false;
  tsSetUserPassTimer.Enabled:=true;

  tsSetUserPassEdit2Change(nil);

end;

procedure TMasterPasswordWizardForm.tsSetUserPassEdit2Change(Sender: TObject);
begin
 bNext.Enabled:= (tsSetUserPassEdit2.Text=tsSetUserPassEdit1.Text) or tsSetUserPasschShowPassword.Checked;

 if (tsSetUserPassEdit2.Text<>tsSetUserPassEdit1.Text) and (tsSetUserPassEdit2.Text<>'') and tsSetUserPassEdit2.enabled
      then tsSetUserPassEdit2.Color:=clRed
      else tsSetUserPassEdit2.Color:=clDefault;


end;


procedure TMasterPasswordWizardForm.tsSetUserPassHide(Sender: TObject);
var r:double;
begin

   if sender=bNext then begin
      //
     if (not tsSetUserPasschShowPassword.Checked) and (tsSetUserPassEdit1.Text<>tsSetUserPassEdit2.text)
        then begin
          ShowInlineMessage('MasterPasswordWizardForm.PasswordsNotTheSame','The passwords you entered are not the same');
          exit;
        end;

     r:=ratePassword(tsSetUserPassEdit1.Text);
     if r<20 then begin
       ShowInlineMessage('MessageInfoWeakUserPassword','Password you entered is too short. Move all assets to a stronger password');
       if not Settings.getValue('Dev_Mode_ON') then exit;
     end;

     //set up the UP and save PrK
     //Settings.PrivKey:=Encrypt_AES256(privKeyToCode58(MainForm.PrivKey, globals.WifID,true),tsSetUserPassEdit1.Text);
     Settings.setValue('KEEP_PRIVATE_KEY',true);
     Settings.PrivKey:=Encrypt_AES256(privKeyToCode58(MainForm.PrivKey, globals.WifID,true),tsSetUserPassEdit1.Text);
     Settings.PubKey:=pubKeyToBuf(GetPublicKey(MainForm.PrivKey));

     Settings.save();
     MainForm.SetAndCheckBlockchain();
     MainForm.showWalletInfo();


     if wizardID='domp' then
        goNext(tsSetPassDoneFinish)
     else
     if wizardID='doall' then
        goNext(tsSetPassDoneContinue);


   end else
   if sender=bPrev then begin
      goBack;
   end else
   if sender=bFinish then begin

   end else
   if sender=bHelp then begin

   end else begin
     //PassRate1.down();
     //createPassword1.down();

     destroyGuidePage(tsSetUserPassPanel);
   end;



end;

procedure TMasterPasswordWizardForm.tsSetUserPassPanelCDoNotSaveChange(
  Sender: TObject);
begin

end;



procedure TMasterPasswordWizardForm.tsSetUserPassShow(Sender: TObject);
begin

  createGuidePage(tsSetUserPassPanel);
  setButtonsDefault;
  bNext.Enabled:=false;

  PassRate1.init();
  createPassword1.Init();
  CreatePassword1.onChange:=@bGenerateUserPassClick;


  PassRate1.mInfo.Visible:=false;
  PassRate1.lExplanation.Visible:=false;

  tsSetUserPassGeneratorPanel.Visible:=false;
  tsSetUserPassPanelCDoNotSaveChange(nil);



  //bNext.Enabled:=false;
  tsSetUserPassEdit1.Text:='';
  tsSetUserPassEdit2.Text:='';
  tsSetUserPasschShowPasswordChange(nil);

  tsSetUserPassEdit1Change(nil);

  if tsSetUserPassEdit1.CanSetFocus then tsSetUserPassEdit1.SetFocus;

end;


procedure TMasterPasswordWizardForm.tsAskForMasterPassShow(Sender: TObject);
begin
  createGuidePage(tsAskForMasterPassPanel);
  setButtonsDefault;
  bPrev.Visible:=false;
end;

procedure TMasterPasswordWizardForm.tsCheckMasterPassHide(Sender: TObject);
var s:string;
    //r:double;
    st:string;
begin
  if sender=bNext then begin
    //tsCheckMasterPassPanel

    st:=smartExtractBIP32pass(tsCreateMasterPassLastSavedPass);


    MainForm.deletePrivKey;
    if (MainForm.loadHDNodeFromBip(st)) then begin
      Settings.PrivKey:=''; //remove old one
      Settings.PubKey:='';
    end;
    MainForm.showWalletInfo;
    MainForm.updatePKstate(nil);
    goNext(tsSetUserPass);
  end else
  if sender=bPrev then begin
     goBack;
  end else
  if sender=bFinish then begin

  end else
  if sender=bHelp then begin

  end else
    destroyGuidePage(tsCheckMasterPassPanel);

end;


procedure TMasterPasswordWizardForm.tsConnectAllDoneHide(Sender: TObject);
begin
  if sender=bNext then begin

  end else
  if sender=bPrev then begin

  end else
  if sender=bFinish then begin

  end else
  if sender=bHelp then begin

  end {else
    destroyGuidePage();
      }
end;

procedure TMasterPasswordWizardForm.tsConnectionSelectHide(Sender: TObject);
begin
    if sender=bNext then begin

  end else
  if sender=bPrev then begin

  end else
  if sender=bFinish then begin

  end else
  if sender=bHelp then begin

  end {else
    destroyGuidePage();
      }
end;

procedure TMasterPasswordWizardForm.tsConnectLocalWalletHide(Sender: TObject);
begin
    if sender=bNext then begin

  end else
  if sender=bPrev then begin

  end else
  if sender=bFinish then begin

  end else
  if sender=bHelp then begin

  end {else
    destroyGuidePage();
      }
end;

procedure TMasterPasswordWizardForm.tsConnectServerHide(Sender: TObject);
begin
  if sender=bNext then begin
     if tsConnectServerPanelChSelectServer.Checked
       then tsServerLoginAddress:=trim(tsConnectServerPanelCombobox.text)
       else tsServerLoginAddress:=Settings.getValue('EMERAPI_SERVER_ADDRESS');//use current/default
     goNext(tsServerLogin);
  end else
  if sender=bPrev then begin
     goBack;
  end else
  if sender=bFinish then begin

  end else
  if sender=bHelp then begin

  end else
    destroyGuidePage(tsConnectServerPanel);

end;

procedure TMasterPasswordWizardForm.tsCreateMasterPass12wHide(Sender: TObject);
begin
  if sender=bNext then begin
    goNext(tsCheckMasterPass);
  end else
  if sender=bPrev then begin
    //MainPageControl.ActivePage:= tsCreateNewMasterPass1;
    goBack;
  end else
  if sender=bFinish then begin

  end else
  if sender=bHelp then begin

  end else
    destroyGuidePage(tsCreateMasterPass12wPanel);

end;

procedure TMasterPasswordWizardForm.tsCreateMasterPassFreeFormHide(
  Sender: TObject);
begin
  if sender=bNext then begin
    if tsCreateMasterPassFreeFormchShowPassword.Checked or
        (tsCreateMasterPassFreeFormEdit1.Text=tsCreateMasterPassFreeFormEdit2.Text) then begin
           tsCreateMasterPassLastSavedPass:=tsCreateMasterPassFreeFormEdit1.Text;
           goNext(tsCheckMasterPass);
    end else
      ShowInlineMessage('MasterPasswordWizardForm.PasswordsNotTheSame','The passwords you entered are not the same');

  end else
  if sender=bPrev then begin
    goBack;
  end else
  if sender=bFinish then begin

  end else
  if sender=bHelp then begin

  end else
    destroyGuidePage(tsCreateMasterPassFreeFormPanel);

end;

procedure TMasterPasswordWizardForm.tsCreateMasterPassFreeFormShow(
  Sender: TObject);
begin
  createGuidePage(tsCreateMasterPassFreeFormPanel);
  setButtonsDefault;
  bNext.Enabled:=false;

  tsCreateMasterPassFreeFormEdit1.Text:=tsCreateMasterPassLastSavedPass;
  tsCreateMasterPassFreeFormEdit2.Text:=tsCreateMasterPassLastSavedPass;

  tsCreateMasterPassFreeFormchShowPasswordChange(nil);

  //bNext.Enabled:=false;
  tsCreateMasterPassFreeFormEdit1.Text:='';
  tsCreateMasterPassFreeFormEdit2.Text:='';

  tsCreateMasterPassFreeFormEdit1Change(nil);
  //bPrev.Visible:=false;

  PassRate2.init();
  PassRate2.mInfo.Text:='Please enter your Master Password';
  //PassRate2.mInfo.Visible:=false;
  //PassRate2.lExplanation.Visible:=false;
  if tsCreateMasterPassFreeFormEdit1.CanSetFocus then
    tsCreateMasterPassFreeFormEdit1.SetFocus;

end;


procedure TMasterPasswordWizardForm.tsCreateNewMasterPass1Hide(Sender: TObject);
begin
  if sender=bNext then begin
     tsCreateMasterPassLastSavedPass:='';

     if tsCreateNewMasterPass1RB1.Checked then
       goNext(tsCreateMasterPass12w);

     if tsCreateNewMasterPass1RB2.Checked then
       goNext(tsCreateMasterPassFreeForm);

  end else
  if sender=bPrev then begin
     goNext(tsAskForMasterPass);
  end else
  if sender=bFinish then begin

  end else
  if sender=bHelp then begin

  end else
    destroyGuidePage(tsCreateNewMasterPass1Panel);


end;

procedure TMasterPasswordWizardForm.tsCreateNewMasterPass1Show(Sender: TObject);
begin
  createGuidePage(tsCreateNewMasterPass1Panel);
  setButtonsDefault;
end;

procedure TMasterPasswordWizardForm.tsKeepMasterPassHide(Sender: TObject);
begin
    if sender=bNext then begin

  end else
  if sender=bPrev then begin

  end else
  if sender=bFinish then begin

  end else
  if sender=bHelp then begin

  end {else
    destroyGuidePage();
      }
end;

procedure TMasterPasswordWizardForm.tsSetPassDoneContinueCSetupServerChange(
  Sender: TObject);
begin
  //bNext.Visible:=tsSetPassDoneContinueCSetupServer.Checked;
  //bFinish.Visible:=not bNext.Visible;
  bNext.Visible:=tsSetPassDoneContinueCSetupServer.Checked;
  bFinish.Visible:=not tsSetPassDoneContinueCSetupServer.Checked;
end;

procedure TMasterPasswordWizardForm.InlineMessageTimerTimer(Sender: TObject);
begin
  InlineMessageTimer.Enabled:=false;
  with AskQuestion(self,nil,InlineMessageaMessage,InlineMessageaHelpURL,InlineMessageaTag) do begin
    bOk.Visible:=true;
    bOk.setFocus;
    Update;
  end;
end;


procedure TMasterPasswordWizardForm.ShowInlineMessage(aTag:ansistring;aMessage:string='';ahelpURL:ansistring='');
begin
  InlineMessageaMessage:=aMessage;
  InlineMessageaHelpURL:=aHelpURL;
  InlineMessageaTag:=aTag;

  InlineMessageTimer.Enabled:=true;
end;

function TMasterPasswordWizardForm.AskInlineYesNo(answerProc:tAskQuestionOnAnswer;aTag:ansistring;aMessage:string='';ahelpURL:ansistring='';YesByDefault:boolean=false):boolean;
begin
  with AskQuestion(self,answerProc,aMessage,aHelpURL,aTag) do begin
    bYes.Visible:=true;
    bNo.Visible:=true;
    if YesByDefault
      then bYes.SetFocus
      else bNo.SetFocus;
    Update;
  end;
end;

procedure TMasterPasswordWizardForm.tsSetUserPassTimerTimer(Sender: TObject);
begin
  tsSetUserPassTimer.Enabled:=false;
  PassRate1.UpdateStat(tsSetUserPassEdit1.Text);
  bNext.Enabled:=(bNext.Enabled and (PassRate1.pbRate.Position>20)) or Settings.getValue('Dev_Mode_ON');
end;

procedure TMasterPasswordWizardForm.tsSetUserPassTrackBarChange(Sender: TObject
  );
begin
  bGenerateUserPass.Click;
end;

procedure TMasterPasswordWizardForm.tsRestoreMasterPassAnswer1(sender:tObject;aModalResult:tModalResult;atag:ansistring);
begin
  if aModalResult<>mrYes then exit;

  MainForm.deletePrivKey;
  if (MainForm.loadHDNodeFromBip(smartExtractBIP32pass(tsRestoreMasterPassLastSavedPass))) then begin
    Settings.PrivKey:=''; //remove old one
    Settings.PubKey:='';
  end;
  MainForm.showWalletInfo;
  MainForm.updatePKstate(nil);
  goNext(tsSetUserPass);

  if ratePassword(tsRestoreMasterPassLastSavedPass)<30 then
    ShowInlineMessage('MessageInfoWeakMasterPassword','Password you entered is too short. Move all assets to a stronger password');
end;

procedure TMasterPasswordWizardForm.tsRestoreMasterPassHide(Sender: TObject);
var s:string;
    //r:double;
    //st:string;
begin
  if sender=bNext then begin
     s:=trim(EnterMasterPasswordFrame1.eMasterPassword.Text);//decodePassword(EnterMasterPasswordFrame1.eMasterPassword.Text);

    if s='' then begin
       ShowInlineMessage('MasterPasswordWizardForm.PasswordIsEmpty','Password can not be empty');
       exit;
    end;



    //st:=smartExtractBIP32pass(s);

    tsRestoreMasterPassLastSavedPass:=s;

    if smartExtractBIP32pass(tsRestoreMasterPassLastSavedPass)<>normalizeBip(s) then
        AskInlineYesNo(@tsRestoreMasterPassAnswer1,'MessageInfoMasterPasswordIsNotABIP39Password','Password you entered is not a standard BIP32 password. Are you sure it is correct and you want to continue with it?')
     else begin
      MainForm.deletePrivKey;
      if (MainForm.loadHDNodeFromBip(smartExtractBIP32pass(tsRestoreMasterPassLastSavedPass))) then begin
        Settings.PrivKey:=''; //remove old one
        Settings.PubKey:='';
      end;
      MainForm.showWalletInfo;
      MainForm.updatePKstate(nil);
      goNext(tsSetUserPass);
      if ratePassword(tsRestoreMasterPassLastSavedPass)<30 then
         ShowInlineMessage('MessageInfoWeakMasterPassword','Password you entered is too short. Move all assets to a stronger password');
     end;
  end else
  if sender=bPrev then begin
    goBack;
  end else
  if sender=bFinish then begin

  end else
  if sender=bHelp then begin

  end else begin
    EnterMasterPasswordFrame1.down;
    destroyGuidePage(tsRestoreMasterPassPanel);
    bNext.Enabled:=true;
  end;

end;

procedure TMasterPasswordWizardForm.EnterMasterPasswordFrame1PasswordChanged(Sender: TObject);
begin
  if EnterMasterPasswordFrame1=nil then exit;
  if MainPageControl.ActivePage<>tsRestoreMasterPass then exit;

  bNext.Enabled:=trim(EnterMasterPasswordFrame1.eAddress.Text)<>'';
end;

procedure TMasterPasswordWizardForm.EnterMasterPasswordFrame2PasswordChanged(Sender: TObject);
begin
  if EnterMasterPasswordFrame2=nil then exit;
  if MainPageControl.ActivePage<>tsCheckMasterPass then exit;

  //!!! bNext.Enabled:=normalizeBip(EnterMasterPasswordFrame2.eMasterPassword.Text)=tsCreateMasterPass12wLastSavedPass;
  bNext.Enabled:=smartExtractBIP32pass(EnterMasterPasswordFrame2.eMasterPassword.Text)=smartExtractBIP32pass(tsCreateMasterPassLastSavedPass);
  EnterMasterPasswordFrame2.lAssignedAddress.Visible:=bNext.Enabled;
  EnterMasterPasswordFrame2.eAddress.Visible:=bNext.Enabled;
end;


procedure TMasterPasswordWizardForm.tsRestoreMasterPassShow(Sender: TObject);
begin
  createGuidePage(tsRestoreMasterPassPanel);
  setButtonsDefault;

  EnterMasterPasswordFrame1.eAddress.Text:='';
  EnterMasterPasswordFrame1.init;
  EnterMasterPasswordFrame1.onPasswordChanged:=@EnterMasterPasswordFrame1PasswordChanged;
  if EnterMasterPasswordFrame1.eMasterPassword.CanSetFocus then
    EnterMasterPasswordFrame1.eMasterPassword.SetFocus;
end;

end.

