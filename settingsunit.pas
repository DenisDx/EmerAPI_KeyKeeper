unit settingsunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, ComboEx, CheckLst, Spin, mainUnit,lazfileutils;


type
  tSettingsRecord = class(tObject)
    private
      fControl:tWinControl;
      fName:ansistring;
      fHint:ansistring;
      fValue:variant;
      fValueType:tVarType;
      fListValues:tStringList;
    protected
      function getValue:variant;
      procedure setValue(v:variant);
    public
      LastReadFromControlError:string;
      property value:variant read getValue write setValue;
      property hint:ansistring read fHint;
      constructor create(ctrl:tWinControl); overload;
      destructor destroy;
      procedure writeToControl();
      function readFromControl():boolean;
      function asAnsiString:ansistring;
  end;

type

  TSettings = class(TObject)
    private
      fLoaded:boolean;
      ffilename:string;
      fPrivKeyEncripted:boolean;
      fSettings:tStringList;
    public
      saveDev:boolean; //will save options started on DEV_ preffix
      libFilename:string;
      PubKey:ansiString;
      PrivKey:ansiString;
      LastloadFromGUIErrors:string;
      property Loaded:boolean read fLoaded;
      constructor Create(form:tform=nil;Const filename:string='');
      destructor Destroy(); override;
      function load(Const filename:string=''):boolean;
      procedure save(filename:string='');
      procedure buildSettingByForm(form:tForm);
      function loadFromGUI:boolean;
      procedure writeToGUI;
      function hasSetting(name:ansistring):boolean;
      function getValue(name:ansistring):variant;
      procedure setValue(name:ansistring;v:variant);
      procedure saveParams(names:array of ansistring);
  end;

  { TSettingsForm }


  TSettingsForm = class(TForm)
    bCloseAndSave: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    bReRead: TBitBtn;
    bCloseNoSave: TBitBtn;
    bSetEmerAPIDefault: TBitBtn;
    bRestoreKeypair: TBitBtn;
    bConfigureWallet: TButton;
    Button2: TButton;
    lJSONPRC_timeout: TLabel;
    ssiJSONPRC_timeout: TSpinEdit;
    sssJSONRPC_allow_IPs: TEdit;
    sssJSONRPC_allowed_commands: TEdit;
    ssbJSONRPC_Allow_Only: TCheckBox;
    ssbJSONRPC_filter_commands: TCheckBox;
    lJSONPRC_port: TLabel;
    ssbJSONRPC_Allow_Nonlocal: TCheckBox;
    ssiJSONPRC_port: TSpinEdit;
    ssbJSONPRC_allowed: TCheckBox;
    gJSONRPC: TGroupBox;
    ssbHide_To_Tray: TCheckBox;
    lssiEMERAPI_SERVER_Refresh_period: TLabel;
    XXssbEmerAPI_Server_Login_Username: TRadioButton;
    ssbEmerAPI_Server_Login_Address: TRadioButton;
    ssbEmerAPI_Server_Save_yum_l: TCheckBox;
    ssiEMERAPI_SERVER_Refresh_period: TSpinEdit;
    ssiSpending_Optimization_Mode: TComboBox;
    Label6: TLabel;
    ssiKeep_Amount_Threshold: TLabeledEdit;
    ssbAdd_One_Cent_To_Name_Tx_Fee: TCheckBox;
    gPaySettings: TGroupBox;
    sssDev_Bip32_salt: TLabeledEdit;
    sssDev_Bip32_SigPrivate: TLabeledEdit;
    ssiDev_Bip32_Iter_Count: TLabeledEdit;
    sssDev_Bip32_SigPublic: TLabeledEdit;
    sssDev_Bip32_Master_Secret: TLabeledEdit;
    sssDev_Server_Network: TLabeledEdit;
    sssDev_WIF: TLabeledEdit;
    sssDev_SIG: TLabeledEdit;
    ssbDev_Mode_ON: TCheckBox;
    gDevSettings: TGroupBox;
    lMaxSimConWallet: TLabel;
    lMaxSimConServer: TLabel;
    ssiEMERAPI_SERVER_Max_simultaneous_connections: TSpinEdit;
    ssbEmerAPI_Server_Use: TCheckBox;
    ssbLockKPAfter: TCheckBox;
    lLockPKTime: TLabel;
    ssiLOCAL_WALLET_RPC_Max_simultaneous_connections: TSpinEdit;
    ssiLockKPAfterMin: TSpinEdit;
    ssbLocal_Wallet_RPC_Use_SSL: TCheckBox;
    Label4: TLabel;
    Label5: TLabel;
    ssbKeep_Private_Key: TCheckBox;
    ssbPrefer_Using_Local_Wallet: TCheckBox;
    ssbEmerAPI_Server_Connect_After_Start: TCheckBox;
    ssbEmerAPI_Server_Guest_Only: TCheckBox;
    ssbUse_Local_Wallet: TCheckBox;
    sssDev_Bip32_path: TLabeledEdit;
    sssEmerAPI_Server_adv_Query_Field_Name: TLabeledEdit;
    sssEmerAPI_Server_adv_yum_l: TLabeledEdit;
    sssEmerAPI_Server_adv_SessionKey: TLabeledEdit;
    sssLocal_Wallet_RPC_Address: TLabeledEdit;
    sssLanguage: TComboBox;
    gMainSettings: TGroupBox;
    GroupBox2: TGroupBox;
    gLocalWallet: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    lWarningRPC: TLabel;
    Label3: TLabel;
    ssiLocal_Wallet_RPC_Port: TLabeledEdit;
    sssLocal_Wallet_RPC_User_Name: TLabeledEdit;
    sssLocal_Wallet_RPC_Password: TLabeledEdit;
    sssEmerAPI_server_address: TLabeledEdit;
    sssEmerAPI_Server_User_Name: TLabeledEdit;
    sssEmerAPI_Server_Password: TLabeledEdit;
    sssEmerAPI_Server_adv_Login_Suffix: TLabeledEdit;
    sssEmerAPI_Server_adv_Data_suffix: TLabeledEdit;
    sssEmerAPI_Server_adv_Login_Form_Name: TLabeledEdit;
    sssEmerAPI_Server_adv_Password_Form_Name: TLabeledEdit;
    sssEmerAPI_Server_adv_Cookie_Name: TLabeledEdit;
    Panel1: TPanel;
    ScrollBox1: TScrollBox;
    procedure bCloseAndSaveClick(Sender: TObject);
    procedure bCloseNoSaveClick(Sender: TObject);
    procedure bReReadClick(Sender: TObject);
    procedure bRestoreKeypairClick(Sender: TObject);
    procedure bSetEmerAPIDefaultClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure ssbDev_Mode_ONChange(Sender: TObject);
    procedure ssbEmerAPI_Server_Save_yum_lChange(Sender: TObject);
    procedure XXssbEmerAPI_Server_Login_UsernameChange(Sender: TObject);
    procedure ssbKeep_Private_KeyChange(Sender: TObject);
    procedure sssLanguageChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
{    procedure RebuildLanguageCombo();}
  private

  public

  end;

var
  Settings: TSettings = nil;
  SettingsForm: TSettingsForm;


function MakeConfigName(pname:string='emerapi';verifyname:boolean=true):string;

//default settings for dev section
const
  defSsettings_Dev_Bip32_salt='witnesskey';
  defSsettings_Dev_Bip32_Iter_Count=2048;
  defSsettings_Dev_Bip32_Master_Secret='Bitcoin seed';
  defSsettings_Dev_Bip32_SigPrivate=$0488ADE4;
  defSsettings_Dev_Bip32_SigPublic=$0488B21E;

implementation

{$R *.lfm}

uses localizzzeUnit, HelperUnit, Variants, crypto, CryptoLib4PascalConnectorUnit, QuestionUnit, lclintf, askformpunit, UOpenSSL, setupunit, passwordHelper, lazUTF8;

const
  NamePrefix = 'ss';

function nullToBool(v:variant):boolean;
begin
  if varIsNull(v) then result:=false
                  else result:=v;
end;

function MakeConfigName(pname:string='emerapi';verifyname:boolean=true):string;
begin
  //Возвращает имя файла с конфигом
  if verifyname
     then result:=getDefaultPath+ChangeFileExt(CleanFileName(pname),'.cfg')
     else result:=getDefaultPath+ChangeFileExt(pname,'.cfg');
end;



{tSettingsRecord}

constructor tSettingsRecord.create(ctrl:tWinControl);
var name:ansistring;
begin
  if ctrl=nil then raise exception.Create('tSettingsRecord.create:Wrong guide control!');
  fControl:=ctrl;
  name:=ctrl.Name;
  fValue:=null;
  fListValues:=nil;

  if length(name)<4 then raise exception.Create('tSettingsRecord.create:wrong component name:'+name);
  if copy(name,1,2)='ss' then delete(name,1,2);

  case name[1] of  //varDouble varString varBoolean varQWord varInteger
    'b':fValueType:=varBoolean;
    'd':fValueType:=varDouble;
    'q':fValueType:=varQWord;
    'i':fValueType:=varInteger;
    's':fValueType:=varString;
  else
   raise exception.Create('tSettingsRecord.create:wrong type in component name:'+ctrl.Name);
  end;

  if (fControl is tCombobox) or (fControl is tListBox) or (fControl is tCheckListBox) then begin
    fListValues:=tStringList.Create;
    if (fControl is tCombobox) then  fListValues.Assign((fControl as tCombobox).Items);
    if (fControl is tListBox) then  fListValues.Assign((fControl as tListBox).Items);
    if (fControl is tCheckListBox) then  fListValues.Assign((fControl as tCheckListBox).Items);
  end;

  delete(name,1,1);
  fName:=name;
  fHint:=trim(ctrl.Hint);
end;

destructor tSettingsRecord.destroy;
begin
  if fListValues<>nil then freeAndNil(fListValues);
  inherited;
end;

function tSettingsRecord.getValue:variant;
begin
  result:=fValue;
end;

function tSettingsRecord.asAnsiString():ansistring;
begin
  case fValueType of
      varSingle,varDouble,varDecimal,varCurrency,varDate: result:=myFloatToStr(fValue);
      varString:result:=fValue;
      varBoolean:if fValue then result:='1' else result:='0';
      varShortInt,varSmallint,varInteger,varInt64,varByte,varWord,varLongWord,varQWord: result:=inttostr(fValue);
  else
    raise exception.Create('tSettingsRecord.asAnsiString: unsupported variant type');
  end;
end;

{
procedure ProcessVariant(v : Variant);
begin

 // Example of how to determine the contents of a Variant type:
 Case varType(v) of
    varEmpty:
        Writeln('Empty');
    varNull:
        Writeln('Null');
    varSingle:
        Writeln('Datatype: Single');
    varDouble:
        Writeln('Datatype: Double');
    varDecimal:
        Writeln('Datatype: Decimal');
    varCurrency:
        Writeln('Datatype: Currency');
    varDate:
        Writeln('Datatype: Date');
    varOleStr:
        Writeln('Datatype: UnicodeString');
    varStrArg:
        Writeln('Datatype: COM-compatible string');
    varString:
        Writeln('Datatype: Pointer to a dynamic string');
    varDispatch:
        Writeln('Datatype: Pointer to an Automation object');
    varBoolean:
        Writeln('Datatype: Wordbool');
    varVariant:
        Writeln('Datatype: Variant');
    varUnknown:
        Writeln('Datatype: unknown');
    varShortInt:
        Writeln('Datatype: ShortInt');
    varSmallint:
        Writeln('Datatype: Smallint');
    varInteger:
        Writeln('Datatype: Integer');
    varInt64:
        Writeln('Datatype: Int64');
    varByte:
        Writeln('Datatype: Byte');
    varWord:
        Writeln('Datatype: Word');
    varLongWord:
        Writeln('Datatype: LongWord');
    varQWord:
        Writeln('Datatype: QWord');
    varError:
        Writeln('ERROR determining variant type');
 else
   Writeln('Unable to determine variant type');
 end;
end;
}

{
varSingle,varDouble,varDecimal,varCurrency,varDate:
varString:
varBoolean:
varShortInt,varSmallint,varInteger,varInt64,varByte,varWord,varLongWord,varQWord:
}

procedure tSettingsRecord.setValue(v:variant);
var ext:double;
begin
  //checking the type
  if varIsNull(v) then raise exception.Create('tSettingsRecord.setValue: value can not be null');
  if fValueType<2 { in [varempty,varnull]} then raise exception.Create('tSettingsRecord.setValue: internal error: wrong type of '+fName);
//  if varIsNull(fValue) then begin
//    fValue:=v;
    //fValueType:=varType(v); NO!!!
//  end else
    Case varType(v) of
      varSingle,varDouble,varDecimal,varCurrency,varDate:
         case fValueType of
             varSingle,varDouble,varDecimal,varCurrency,varDate: fValue:=v;
             varString:fValue:=myFloatToStr(v);
             varBoolean:fValue:=v<>0;
             varShortInt,varSmallint,varInteger,varInt64,varByte,varWord,varLongWord,varQWord: begin ext:=v; fValue:=trunc(ext) end;
             varempty,varnull: fValue:=0;
         else
           raise exception.Create('tSettingsRecord.setValue: unsupported variant type');
         end;
      varString:
        case fValueType of
            varSingle,varDouble,varDecimal,varCurrency,varDate: if trim(v)='' then fValue:=0 else fValue:=myStrToFloat(v);
            varString:fValue:=v;
            varBoolean:fValue:=(uppercase(v)='TRUE') or (v='1') or (v='-1');
            varShortInt,varSmallint,varInteger,varInt64,varByte,varWord,varLongWord,varQWord: if trim(v)='' then fValue:=0 else fValue:=strtoint64(v);
        else
          raise exception.Create('tSettingsRecord.setValue: unsupported variant type '+inttostr(fValueType));
        end;
      varBoolean:
        case fValueType of
            varSingle,varDouble,varDecimal,varCurrency,varDate: raise exception.Create('tSettingsRecord.setValue: can''t convert boolean to float');
            varString: if v then fValue:='1' else fValue:='0';
            varBoolean:fValue:=v;
            varShortInt,varSmallint,varInteger,varInt64,varByte,varWord,varLongWord,varQWord: if v then fValue:=1 else fValue:=0;
        else
          raise exception.Create('tSettingsRecord.setValue: unsupported variant type');
        end;

      varShortInt,varSmallint,varInteger,varInt64,varByte,varWord,varLongWord,varQWord:
        case fValueType of
            varSingle,varDouble,varDecimal,varCurrency,varDate: fValue:=v;
            varString:fValue:=intToStr(v);
            varBoolean:fValue:=v<>0;
            varShortInt,varSmallint,varInteger,varInt64,varByte,varWord,varLongWord,varQWord: fValue:=v;
        else
          raise exception.Create('tSettingsRecord.setValue: unsupported variant type');
        end;
    else
      raise exception.Create('tSettingsRecord.setValue: unsupported variant type for v');
    end;
end;

procedure tSettingsRecord.writeToControl();
var s:string;
begin
       if fControl is tCheckBox then tCheckBox(fControl).Checked:=fValue
  else if fControl is tRadioButton then tRadioButton(fControl).Checked:=fValue
  else if fControl is tSpinEdit then tSpinEdit(fControl).Value:=fValue
  else if (fControl is tEdit) or (fControl is tLabeledEdit) then begin
     s:='';
     case fValueType of
         varSingle,varDouble,varDecimal,varCurrency: s:=myFloatToStr(fValue);
         varDate: s:=dateToStr(fValue);
         varString:s:=fValue;
         varBoolean:if fValue then s:='1' else s:='0';
         varShortInt,varSmallint,varInteger,varInt64,varByte,varWord,varLongWord,varQWord: s:=intToStr(fValue);
     else
       raise exception.Create('tSettingsRecord.readFromControl: unsupported variant type for '+fControl.Name);
     end;
     if (fControl is tEdit) then (fControl as tEdit).Text:=s else (fControl as tLabeledEdit).Text:=s;
  end
  else
    if fControl is tComboBox then begin
      if fListValues=nil then raise exception.Create('tSettingsRecord.writeToControl: fListValues=nil for list item '+fControl.Name+'!');
      if fValueType=varInteger then
         if (fListValues.Count>fValue) and (fValue>=-1)
           then (fControl as tComboBox).ItemIndex:=fValue
           else raise exception.Create('tSettingsRecord.writeToControl: wrong index for '+fControl.Name+'! ')
      else
        if fListValues.IndexOf(fValue)<0
          then (fControl as tComboBox).Text:=fValue
          else
             if fListValues.Count<>(fControl as tComboBox).Items.Count
               then raise exception.Create('tSettingsRecord.writeToControl: items count changes for '+fControl.Name+'! ')
               else (fControl as tComboBox).ItemIndex:=fListValues.IndexOf(fValue);

  end else raise exception.Create('tSettingsRecord.readFromControl: class not supported for '+fControl.Name)
  ;


end;

function tSettingsRecord.readFromControl():boolean;
var s:string;
  procedure MakeError(mTag:string);
  begin
    LastReadFromControlError:=fName+':'+localizzzeString(uppercase(mTag),'Invalid value');
    if fControl.Owner<>nil then
      if fControl.Owner is tCustomForm then
        if tCustomForm(fControl.Owner).Visible then
          fControl.SetFocus;
    result:=false;
  end;

begin
  LastReadFromControlError:='';
  result:=true;

       if fControl is tCheckBox then fValue:=tCheckBox(fControl).Checked
  else if fControl is tRadioButton then fValue:=tRadioButton(fControl).Checked
  else if fControl is tSpinEdit then fValue:=tSpinEdit(fControl).Value
  else if (fControl is tEdit) or (fControl is tLabeledEdit) then begin
     if (fControl is tEdit) then s:= (fControl as tEdit).Text else s:= (fControl as tLabeledEdit).Text;
     case fValueType of
         varSingle,varDouble,varDecimal,varCurrency: try fValue:=myStrToFloat(trim(s)); except MakeError('mTagInvalidFloat'); end;
         varDate: try fValue:=strToDate(trim(s)); except MakeError('mTagInvalidDate'); end;
         varString:fValue:=s;
         varBoolean:fValue:=(trim(uppercase(s))='TRUE') or (trim(s)='1') or (trim(s)='-1');
         varShortInt,varSmallint,varInteger,varInt64,varByte,varWord,varLongWord,varQWord:try fValue:=strtoint64(trim(s));  except MakeError('mTagInvalidInt'); end;
     else
       raise exception.Create('tSettingsRecord.readFromControl: unsupported variant type for '+fControl.Name);
     end;
  end
  else if fControl is tComboBox then
    if fValueType=varInteger then
      fValue:=(fControl as tComboBox).ItemIndex
    else
      if (fControl as tComboBox).ItemIndex<0
      then fValue:=(fControl as tComboBox).Text
      else
        if fListValues=nil then raise exception.Create('tSettingsRecord.readFromControl: fListValues=nil for list item '+fControl.Name+'!')
           else if fListValues.Count<>(fControl as tComboBox).Items.Count then raise exception.Create('tSettingsRecord.readFromControl: items count changes for '+fControl.Name+'! ')
           else fValue:= fListValues[(fControl as tComboBox).ItemIndex]
  else raise exception.Create('tSettingsRecord.readFromControl: class not supported for '+fControl.Name)
  ;


end;

{ /tSettingsRecord }


{ TSettings }
constructor TSettings.Create(form:tform=nil;Const filename:string='');
begin
  fLoaded:=false;
  saveDev:=false;
  fSettings:=tStringList.Create;


  if form<>nil then begin
    buildSettingByForm(form);
    if filename<>'' then fLoaded:=load(filename);
  end;
end;

destructor TSettings.Destroy();
var i:integer;
begin
  for i:=0 to fSettings.Count-1 do tSettingsRecord(fSettings.Objects[i]).free;
  fSettings.Free;
  inherited;
end;

procedure TSettings.saveParams(names:array of ansistring);
var tmpSettings:TSettings;
    i:integer;
begin
  //1. load file for temp object
  //2. change
  //3. save it
  tmpSettings:=TSettings.Create(SettingsForm,ffilename);
  try
    //tmpSettings.load();
    try
      tmpSettings.saveDev:=nullToBool(tmpSettings.getValue('DEV_MODE_ON'));
    except
      tmpSettings.saveDev:=false;
    end;
    for i:=0 to length(names)-1 do
      if trim(uppercase(names[i]))='DEV_MODE_ON' then begin
        try
          tmpSettings.saveDev:=nullToBool(Settings.getValue('DEV_MODE_ON'));
          tmpSettings.setValue('DEV_MODE_ON',nullToBool(Settings.getValue('DEV_MODE_ON')));
        except
          tmpSettings.saveDev:=false;
        end;
        break;
      end;

    for i:=0 to length(names)-1 do
      tmpSettings.setValue(names[i],getValue(names[i]));
    tmpSettings.save();

  finally
    tmpSettings.free;
  end;

end;

procedure TSettings.save(filename:string='');
var l:tStringList;
    f:string;
    i:integer;
    pk:ansistring;
    s:ansistring;
begin
  if filename='' then f:=fFilename
                 else f:=filename;
  if f='' then f:=MakeConfigName();


  //Формируем текст настроек. вид ИМЯ=ЗНАЧЕНИЕ\n
  l:=tStringList.create;
  try
    l.Add(';EmerAPI client configuration file. ";" or "#" can be used for make comment line.');
    l.Add(';You can change all the settings using settings window.');
    l.Add(';THIS FILE WILL BE OVERWRITTEN AFTER ANY SETTING''S CHANGE');

    l.Add('');
    l.Add(';SSL_C_LIB: Open ssl library filename. Left empty for default.');
    l.Add('SSL_C_LIB='+libFilename+'');

    l.Add('');
    if PubKey<>'' then s:=bufToHex(PubKey) else s:='';
    l.Add(';Pub_Key: Public key (compressed HEX).');
    l.Add('Pub_Key='+s+'');

    if (PrivKey<>'') and (fSettings.IndexOf('KEEP_PRIVATE_KEY')>=0)
     then if (getValue('KEEP_PRIVATE_KEY'))
       then s:=bufToHex(PrivKey)
       else s:='';

    l.Add('');
    l.Add(';Private key (hex, AES encription using pin).');
    l.Add(';WARNING! Storing a private key on the computer is safe only when:');
    l.Add(';1. Long user''s password is used (at least 14 characters are recommended)');
    l.Add(';2. A dedicated computer stored in a safe place is using.');
    l.Add(';3. The computer has data encryption, including swap sections, with a strong password.');
    l.Add('Priv_Key='+s+'');

    for i:=0 to fSettings.Count-1 do
      if saveDev or (pos('DEV_',uppercase(fSettings[i]))<>1) then
        if not varIsNull(tSettingsRecord(fSettings.Objects[i]).value) then
        begin
          l.Add('');
          if tSettingsRecord(fSettings.Objects[i]).hint<>'' then
             l.Add('; '+tSettingsRecord(fSettings.Objects[i]).hint);
          try
            l.Add(fSettings[i]+'='+tSettingsRecord(fSettings.Objects[i]).asAnsiString());
          except
            //can't convert -> do not save. Do nothing
          end;
        end;

    if (not DirectoryExistsUTF8(ExcludeTrailingPathDelimiter(ExtractFileDir(f))))
        then
        ForceDirectoriesUTF8(ExcludeTrailingPathDelimiter(ExtractFileDir(f)));
    l.SaveToFile(f);
  finally
    l.free;
  end;

  fLoaded:=true;
  fFilename:=f;

end;

function TSettings.load(Const filename:string=''):boolean;
var l:tStringList;
    i,n:integer;
    s,v:string;
    p:ansistring;
    f:string;
begin
  result:=false;

  if filename='' then f:=fFilename
                 else f:=filename;
  if f='' then f:=MakeConfigName();

  if not FileExistsUTF8(f) then exit;

   l:=tStringList.create;
   try
     l.LoadFromFile(f);

     for i:=0 to l.count-1 do begin
       try
         s:=l[i];
         n:=pos('=',s);
         if n<1 then continue;
         if (pos(';',s)>0) and (pos(';',s)<n) then continue;
         if (pos('#',s)>0) and (pos('#',s)<n) then continue;

         v:=trim(copy(s,n+1,length(s)-n));
         p:=ansiuppercase(trim(copy(s,1,n-1)));



              if p='SSL_C_LIB' then libFilename:=v
         else if p='PUB_KEY' then if v<>'' then PubKey:=hexToBuf(v) else PubKey:=''
         else if p='PRIV_KEY' then if v<>'' then PrivKey:=hexToBuf(v) else PrivKey:=''
         else setValue(p,v);


       except
         on e:exception do
           ShowLogErrorMessage('Error reading config file line '+inttostr(i)+': par:'+p+' Error: '+e.Message);
         //raise exception.create('Rrror reading config file line '+inttostr(i));
         //exit;
       end;

     end;
   finally
     l.free;
   end;

  fLoaded:=true;
  result := fLoaded;
  if fLoaded then fFilename:=f;
end;

function TSettings.loadFromGUI:boolean;
var i:integer;
    b:boolean;
begin
  result:=true;
  LastloadFromGUIErrors:='';
  for i:=0 to fSettings.Count-1 do begin

    b:=TSettingsRecord(fSettings.Objects[i]).readFromControl();
    if not b then
       LastloadFromGUIErrors:=LastloadFromGUIErrors+ TSettingsRecord(fSettings.Objects[i]).LastReadFromControlError +#10;
    result:=result and b;
  end;
end;

procedure TSettings.writeToGUI;
var i:integer;
begin
  for i:=0 to fSettings.Count-1 do
    TSettingsRecord(fSettings.Objects[i]).writeToControl();
end;

procedure TSettings.buildSettingByForm(form:tForm);
  procedure scan(ctrl:tWinControl);
  var i:integer;
      name:string;
      sr:tSettingsRecord;
  begin
    for i:=0 to TWinControl(ctrl).ControlCount-1 do
      if (TWinControl(ctrl).Controls[i] is tWinControl) then
         scan(TWinControl(ctrl).Controls[i] as tWinControl);

    name:=ctrl.Name;
    if copy(name,1,2)='ss' then begin
      sr:=tSettingsRecord.create(ctrl);
      fSettings.AddObject(ansiuppercase(sr.fName),sr);
    end;
  end;
begin


  //Add all controls with name prefix = ss
  if fSettings.Count>0 then raise exception.Create('TSettings.buildSettingByForm: settings list already filled');
  scan(form);
end;

function TSettings.hasSetting(name:ansistring):boolean;
begin
  result:=(fSettings.IndexOf(ansiuppercase(name))>=0)
         or (ansiuppercase(name)='SSL_C_LIB')
         or (ansiuppercase(name)='PUB_KEY')
         or (ansiuppercase(name)='PRIV_KEY')
         ;
end;

function TSettings.getValue(name:ansistring):variant;
var n:integer;
begin
  n:=fSettings.IndexOf(ansiuppercase(name));

  if n<0
  then if ansiuppercase(name)='SSL_C_LIB' then result:=libFilename
  else if ansiuppercase(name)='PUB_KEY' then result:=PubKey
  else if ansiuppercase(name)='PRIV_KEY' then result:=PrivKey
  else raise exception.Create('Cant find settings: "'+name+'"')
  else
  result:=tSettingsRecord(fSettings.Objects[n]).value;

end;

procedure TSettings.setValue(name:ansistring;v:variant);
var n:integer;
begin
  n:=fSettings.IndexOf(ansiuppercase(name));

  if n<0
  then if ansiuppercase(name)='SSL_C_LIB' then libFilename:=v
       else if ansiuppercase(name)='PUB_KEY' then PubKey:=v
       else if ansiuppercase(name)='PRIV_KEY' then PrivKey:=v
       else raise exception.Create('Cant find settings: "'+name+'"')
  else
       tSettingsRecord(fSettings.Objects[n]).value:=v;

end;

{ TSettingsForm }

procedure TSettingsForm.bCloseAndSaveClick(Sender: TObject);
begin
  if Settings.loadFromGUI then begin
    Settings.saveDev:=nullToBool(Settings.getValue('DEV_MODE_ON'));
    Settings.save();
    Close;
  end else begin
   //     LastReadFromControlError:=localizzzeString(uppercase(mTag),'Invalid value');
    AskQuestionInit();
    QuestionForm.bOk.Visible:=true;
    QuestionForm.bHelp.Visible:=true;
    AskQuestion(localizzzeString(uppercase('mTagInvalidValue'),'Some fields have invalid values:')+#10#10+ Settings.LastloadFromGUIErrors);
  end;
end;

procedure TSettingsForm.bCloseNoSaveClick(Sender: TObject);
begin
  Close;
end;

procedure TSettingsForm.bReReadClick(Sender: TObject);
begin
  Settings.writeToGUI;
end;

procedure TSettingsForm.bRestoreKeypairClick(Sender: TObject);
var s,ss:ansistring;
    st:string;
    r:double;
begin
  //Спросим о вводе мастер-пароля

  s:=trim(askForMP());
  if s='' then exit;
  r:=ratePassword(s);
  if r<30 then begin
    AskQuestionInit();
    QuestionForm.bOk.Visible:=true;
    QuestionForm.bHelp.Visible:=true;

    AskQuestionTag('MessageInfoWeakMasterPassword');
  end;



  {if MainForm.PrivKey<>nil then} MainForm.deletePrivKey; //EC_KEY_free(MainForm.PrivKey);
  //MainForm.PrivKey:=CreatePrivateKeyFromStrBuf(DoSha256(s));

  st:=smartExtractBIP32pass(s);



  if (MainForm.loadHDNodeFromBip(st)) then begin
    Settings.PrivKey:=''; //remove old one
    Settings.PubKey:='';
  end;

  MainForm.showWalletInfo;
  //Попросим ввести пароль пользователя (новый), если требуется сохранение пароля?
  //Может, пользователь захочет шифрануть сразу?
  if ssbKeep_Private_Key.Checked then
    ssbKeep_Private_KeyChange(nil);



end;

procedure TSettingsForm.bSetEmerAPIDefaultClick(Sender: TObject);
begin

end;

procedure TSettingsForm.FormCreate(Sender: TObject);
begin

  if pos('KEYKEEPER',uppercase(ExtractFileName(application.ExeName)))=1 then
    sssEmerAPI_server_address.Text:='http://emcdpo.info';

  if pos('EMERAPI',uppercase(ExtractFileName(application.ExeName)))=1 then
    sssEmerAPI_server_address.Text:='http://EmerAPI.info';

end;

procedure TSettingsForm.Label5Click(Sender: TObject);
begin
  OpenURL('http://EmerAPI.info');
end;


procedure TSettingsForm.ssbDev_Mode_ONChange(Sender: TObject);
begin
  if ssbDev_Mode_ON.Checked and Visible then begin
      AskQuestionInit();

      QuestionForm.bOk.Visible:=true;
      QuestionForm.bCancel.Visible:=true;
      QuestionForm.bHelp.Visible:=true;
      QuestionForm.Edit.Visible:=true;

      if AskQuestionTag('SettingsForm.askForConfim_developing_mode') = mrOk then begin
        ssbDev_Mode_ON.Checked:=
          UTF8uppercase(localizzzeString('SettingsForm.askForConfim_Wished_Text',''))=UTF8uppercase(trim(QuestionForm.Edit.Text));
      end else ssbDev_Mode_ON.Checked:=false;


  end;
  gDevSettings.Visible:=ssbDev_Mode_ON.Checked;

end;

procedure TSettingsForm.ssbEmerAPI_Server_Save_yum_lChange(Sender: TObject);
begin
  if not ssbEmerAPI_Server_Save_yum_l.checked then begin
    sssEmerAPI_Server_adv_yum_l.Text:='';
    sssEmerAPI_Server_adv_SessionKey.Text:='';
  end
end;

procedure TSettingsForm.XXssbEmerAPI_Server_Login_UsernameChange(Sender: TObject);
begin
  if not (
   XXssbEmerAPI_Server_Login_Username.Checked
   or
   ssbEmerAPI_Server_Login_Address.Checked
  ) then begin
    XXssbEmerAPI_Server_Login_Username.Checked:=true;
    exit;
  end;
  sssEmerAPI_Server_User_Name.Enabled:=XXssbEmerAPI_Server_Login_Username.Checked;
  sssEmerAPI_Server_Password.Enabled:=XXssbEmerAPI_Server_Login_Username.Checked;
end;

procedure TSettingsForm.ssbKeep_Private_KeyChange(Sender: TObject);
var s:ansistring;
     pubKey:TECDSA_Public;
begin
  if ssbKeep_Private_Key.Checked and (Settings.PrivKey='') then if (MainForm.PrivKey<>'')  then begin
     s:=createUP('SettingsForm.msgSetUPnow');
     if s<>'' then begin
       Settings.PrivKey:=Encrypt_AES256(privKeyToCode58(MainForm.PrivKey, globals.WifID,true),s);
       pubKey:=GetPublicKey(MainForm.PrivKey);
       Settings.PubKey:=pubKeyToBuf(pubKey);

       MainForm.showWalletInfo();
     end;
  end;


end;

procedure TSettingsForm.sssLanguageChange(Sender: TObject);
begin
  if (languages.Count>sssLanguage.ItemIndex) and (sssLanguage.ItemIndex>=0) and (CurrentLanguage<>languages[sssLanguage.ItemIndex]) then begin
    //CurrentLanguage:=languages[sssLanguage.ItemIndex];
    if Settings<>nil then Settings.setValue('Language',languages[sssLanguage.ItemIndex]);
    sssLanguage.Items.assign(languages);
    sssLanguage.ItemIndex:=languages.IndexOf(CurrentLanguage);
    localizzze(self);
    //RebuildLanguageCombo();
  end;
end;

procedure TSettingsForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    localizzze(MainForm);
    MainForm.SetAndCheckBlockchain();
    MainForm.miDevTools.Visible:=nullToBool(Settings.getValue('Dev_Mode_ON'));
    MainForm.updateInfoTimer.Interval:=Settings.getValue('EMERAPI_SERVER_Refresh_period')*1000;
    MainForm.showWalletInfo();
    MainForm.checkJSONRPCserver();
end;

{
procedure TSettingsForm.RebuildLanguageCombo();
var i:integer;
    idx:integer;
begin
  QuestionForm.cLanguage.Items.Clear;
  for i:=0 to languages.Count-1 do begin
      idx:=-1;
      if uppercase(languages[i])='EN' then idx:=0;
      if uppercase(languages[i])='RU' then idx:=1;
      QuestionForm.cLanguage.ItemsEx.AddItem(localizzzeString('QUESTIONFORM.CLANGUAGE.'+ansiuppercase(languages[i]),languages[i]),idx);
  end;

  if languages.IndexOf(CurrentLanguage)>=0 then
    QuestionForm.cLanguage.ItemIndex:=languages.IndexOf(CurrentLanguage);
end;  }

procedure TSettingsForm.FormShow(Sender: TObject);
begin
  localizzze(self);
  gDevSettings.Visible:=ssbDev_Mode_ON.Checked;
  XXssbEmerAPI_Server_Login_UsernameChange(nil);
end;

end.

