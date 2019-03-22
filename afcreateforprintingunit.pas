unit AFCreateForPrintingUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, EditBtn, ComCtrls, Spin
  ,EmerAPIBlockchainUnit
  ,fpjson
  ,emerapitypes
  ,NVSRecordUnit
  ,AntifakeHelperUnit
  ,BaseTXUnit
  ;

type

  tSerialIterator = class;
  tSerialIteratorEl = class(tEmerApiNotified)
    private
      parent:tSerialIterator;
      fDone:boolean;
      fExecuteNextStepCounter:integer;
    public
      data:string;

      serial:ansistring;

      nvsName:ansistring;  //needNVSName?
      nvsValue:ansistring;  // nvsValue?
      nvsCreated:boolean; //must create a record in blockchain. nvsCreated := true after. Creation is the first step
      Secret:ansistring; //needSecret?

      brandFromFile:ansistring;

      PrivKey:ansistring; // needAddress?
      PubKey:ansistring; // needAddress?
      Address:ansistring; // needAddress?


      lastSuffix:dword; //max 99999

      nameAbsent:boolean; //we don't have name
      //brandNVSName:ansistring; // NVS name for the brand

      property done:boolean read fDone write fDone;
      constructor create(aParent:tSerialIterator;aData:string {serial or file line});
      procedure executeNextStep; //do all steps
      procedure AsyncDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
  end;

  tSerialIterator = class(tEmerApiNotified)
    //error
    //stepdone
  protected
    fList:tList; //tSerialIteratorEl
    //fTerminate:boolean;

    //iterator data:
    fitrS:ansistring; //current string. Will be cuted

    fNTotal:integer;
    fNPassed:integer;



    fRange:ansistring;

    //for generator:
    fcRange:ansistring; //currentrest range
    fcLastSerial:ansistring; //current last generated serial
    fcRangeEnd:ansistring; //current range part last serial
    fcSecretCodeLength:integer;

    needNVSName:boolean; //tSerialIteratorEl should prepare nvsName
    needNVSValue:boolean; //tSerialIteratorEl should prepare nvsValue
    needToCreate:boolean; //tSerialIteratorEl must create a record in blockchain. nvsCreated := true after. Creation is the first step
    needSecret:boolean;  //tSerialIteratorEl must create Secret
    needAddress:boolean; //tSerialIteratorEl must create PubKey, Address , PrivKey

    //files:
    FilePrivateCSV:string;
    TitlePrivateCSV:ansistring;
    FilePublicCSV:string;
    TitlePublicCSV:ansistring;
    FilePrintCSV:string;
    TitlePrintCSV:ansistring;

    folderQR1:string;
    folderQR2:string;
    templateQR1:ansistring;
    templateQR2:ansistring;
  public
    SimTaskCount:integer;
    Terminated:boolean;

    LastError:string;

    optCheckNameIfFree:boolean;
    optAddRandomSuffix:boolean;
    optBrandName:ansistring;
    optBrandOwner:ansistring; //Address of the brand owner
    optSaveErrorFileName:string; //chLogErrorSerialsToFile

    property Range:ansistring read fRange;

    property nPassed:integer read fNPassed;
    property nTotal:integer read fNTotal;

    function checkFinished:boolean; //check the fList and returns if it is no more tasks to do

    constructor create;
    destructor destroy; override;
    procedure execute; virtual;
    procedure stop; virtual;
    function doNext:boolean; virtual; //execute next serial. returns if it is.
    function getNextSerialFromPool:ansistring; virtual; //returns next serial for fcRange. Do not use it in tSerialIteratorFile

    function createCSVLine(iel:tSerialIteratorEl; title:ansistring):string;

    //for generator:
    procedure cbSetNVSName(Sender:tSerialIteratorEl); virtual; //Set Sender.NVSName . Call Sender.stepNameCreated if done or schedure work for Sender.AsyncDone
    procedure cbSetSecret(Sender:tSerialIteratorEl); virtual; //DO NOT call back
    procedure cbSetKeys(Sender:tSerialIteratorEl); virtual; //DO NOT call back. Sets PrivKey PubKey Address
    procedure cbSetValue(Sender:tSerialIteratorEl); virtual; //OPTIONAL call back. Sets nvsValue. Set nvsValue for callback
    procedure cbCreateNVSRecord(Sender:tSerialIteratorEl); virtual; //CAN BE called back or just passed. Set nvsCreated after created
    procedure cbSetSerial(Sender:tSerialIteratorEl); virtual; //DO NOT call back

    function giveTagValue(iel:tSerialIteratorEl;fld:string):string;
    function fillQRTemplate(Sender:tSerialIteratorEl;template:string):string;

    procedure cbSaveData(Sender:tSerialIteratorEl); virtual; //DO NOT call back!

    procedure cbError(Sender:tSerialIteratorEl;message:string); //stops the process
  end;

  tSerialIteratorRange = class(tSerialIterator)
  private
  public
    constructor create(aRange:string);
  end;

  tSerialIteratorLot = class(tSerialIterator)
    private
    public
      constructor create(lot:tBaseTXO);
  end;
  tSerialIteratorFile = class(tSerialIterator)
    private
      fFile:Text;
      fFilename:string;
      fTitle:string;
      function doNext:boolean; override;
    public
      procedure cbSetSerial(Sender:tSerialIteratorEl); override;

      constructor create(aFilename:string);
      destructor destroy; override;
  end;


  { TAFCreateForPrintingForm }

  TAFCreateForPrintingForm = class(TForm)
    bCreate: TBitBtn;
    bClose: TBitBtn;
    bEditCustomFields: TBitBtn;
    bDemo1: TBitBtn;
    cBrand: TComboBox;
    chAddCustomFields: TCheckBox;
    chCheckNamesIfFree: TCheckBox;
    chCreateBrandField: TCheckBox;
    chCreateNVSrecords: TCheckBox;
    chCreateNVSrecordsOwnedByMe: TCheckBox;
    chCreateParentField: TCheckBox;
    chCreateParentLotField: TCheckBox;
    chCreatePrintCSV: TCheckBox;
    chCreatePrivateCSV: TCheckBox;
    chCreateProductField: TCheckBox;
    chCreatePublicCSV: TCheckBox;
    chCreateQR1: TCheckBox;
    chCreateQR2: TCheckBox;
    chAddRandomSuffix: TCheckBox;
    chFolderPackage: TCheckBox;
    chPrivAddName: TCheckBox;
    chLogErrorSerialsToFile: TCheckBox;
    chPrivAddAddress: TCheckBox;
    chPubAddName: TCheckBox;
    chPrivAddValue: TCheckBox;
    chPrivAddBrand: TCheckBox;
    chPubAddValue: TCheckBox;
    chPubAddBrand: TCheckBox;
    chPubAddAddress: TCheckBox;
    cLot: TComboBox;
    deCreateQR1: TDirectoryEdit;
    deCreateQR2: TDirectoryEdit;
    deFolderPackage: TDirectoryEdit;
    eBrand: TEdit;
    eIteratorRange: TEdit;
    eTextQR1: TEdit;
    eTextQR2: TEdit;
    fnCreatePublicCSV: TFileNameEdit;
    fncreatePrintCSV: TFileNameEdit;
    fnIteraror: TFileNameEdit;
    fnLogErrorSerialsToFile: TFileNameEdit;
    fnCreatePrivateCSV: TFileNameEdit;
    lBrand: TLabel;
    lSecretLength: TLabel;
    lTextQR1: TLabel;
    lBrandManual: TLabel;
    lBrandManualComment: TLabel;
    lInformation: TLabel;
    lInformation1: TLabel;
    lStep1: TLabel;
    lStep2: TLabel;
    lStep3: TLabel;
    lTextQR2: TLabel;
    mDebug: TMemo;
    ProgressBar: TProgressBar;
    pBottom: TPanel;
    pStep1: TPanel;
    pStep2: TPanel;
    pStep3: TPanel;
    rbIterFile: TRadioButton;
    rbIterLot: TRadioButton;
    rbIterRange: TRadioButton;
    ScrollBox1: TScrollBox;
    seSecretCodeLenght: TSpinEdit;
    Splitter1: TSplitter;
    procedure bCloseClick(Sender: TObject);
    procedure bCreateClick(Sender: TObject);
    procedure bEditCustomFieldsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rbIterRangeChange(Sender: TObject);
  private
    //iterator data
    fIterator:tSerialIterator;

    fNVSAddValue:string;

    procedure getBrandCallBack(Sender:tAFRequest);
  public
    procedure itStepDone(Sender: TObject);
    procedure itError(Sender: TObject);

    procedure setEnabledAndView;
    procedure init;

  end;

var
  AFCreateForPrintingForm: TAFCreateForPrintingForm;

  CSVsep:char = ';';


implementation

uses Localizzzeunit, EmerTX
  ,settingsunit
  ,QuestionUnit
  ,MainUnit
  ,NVSValueEdit
  ,QlpIQrCode,QlpQrCode
  ,strutils
  ,CryptoLib4PascalConnectorUnit
  ,crypto
  ;

{$R *.lfm}

const

  tagWords:array[0..5] of string = ('serial', 'secret', 'brand', 'address', 'nvsname', 'nvsvalue');


{
  CleanFileName
  ---------------------------------------------------------------------------

  Given an input string strip any chars that would result
  in an invalid file name.  This should just be passed the
  filename not the entire path because the slashes will be
  stripped.  The function ensures that the resulting string
  does not hae multiple spaces together and does not start
  or end with a space.  If the entire string is removed the
  result would not be a valid file name so an error is raised.

}

function cutPreffix(const pref:ansistring;const v:string):string;
begin
  result:=v;
  if pos(pref,result)=1 then delete(result,1,length(pref));
end;

function CleanFileName(const InputString: string): string;
var
  i: integer;
  ResultWithSpaces: string;
begin

  ResultWithSpaces := InputString;

  for i := 1 to Length(ResultWithSpaces) do
  begin
    // These chars are invalid in file names.
    case ResultWithSpaces[i] of
      '/', '\', ':', '*', '?', '"', '<', '>', '|', ' ', #$D, #$A, #9:
        // Use a * to indicate a duplicate space so we can remove
        // them at the end.
        {$WARNINGS OFF} // W1047 Unsafe code 'String index to var param'
        if (i > 1) and
          ((ResultWithSpaces[i - 1] = ' ') or (ResultWithSpaces[i - 1] = '*')) then
          ResultWithSpaces[i] := '*'
        else
          ResultWithSpaces[i] := ' ';

        {$WARNINGS ON}
    end;
  end;

  // A * indicates duplicate spaces.  Remove them.
  result := ReplaceStr(ResultWithSpaces, '*', '');

  // Also trim any leading or trailing spaces
  result := Trim(Result);

  if result = '' then
  begin
    raise(Exception.Create('Resulting FileName was empty Input string was: '
      + InputString));
  end;
end;


function createQR(filename:string;txt:string):boolean;
var
  LQrCode: IQrCode;
  Png: TPortableNetworkGraphic;
begin
 result:=false;
 if txt='' then exit;

 LQrCode := TQrCode.EncodeText(txt, TQrCode.TEcc.eccMedium, TEncoding.UTF8);
 Png :=  LQrCode.ToPngImage(1, 2);
 try
   Png.SaveToFile(filename);
 except
   try Png.free; except end;
   exit;
 end;

 result:=true;
end;

function unscreen(s:string):string;
var n:integer;
    sl:boolean;
begin
  result:=s;

  n:=1; sl:=false;
  while n<=length(result) do
    if sl then begin
      case result[n] of
        'n':result[n]:=#10;
      end;
      inc(n);
    end else if result[n]='\' then begin sl:=true; delete(result,n,1); end;


end;

function screen(s:string):string;
var n:integer;
begin
 result:=s;

 n:=1;
 while n<=length(result) do
   if result[n]='\' then begin
     result:=copy(result,1,n-1)+'\'+copy(result,n,length(result)-n+1);
     inc(n);inc(n);
   end else inc(n);

 n:=pos('#13#10',result);
 while n>0 do begin
   result:=copy(result,1,n-1)+'\n'+copy(result,n+2,length(result)-n-1);
   n:=pos('#13#10',result);
 end;
 n:=pos('#10',result);
 while n>0 do begin
   result:=copy(result,1,n-1)+'\n'+copy(result,n+1,length(result)-n);
   n:=pos('#10',result);
 end;

end;


function saveLineToFile(fn:string;line:string;rewriteFile:boolean=false):boolean;
var f:text;
begin
 result:=false;
 try
   assignFile(f,fn);
   if rewriteFile then rewrite(f) else append(f);
   writeln(f,line);
   closeFile(f);
 except
   try closeFile(f); except end;
   exit;
 end;

 result:=true;
end;

function getNVSRecordByName(name:ansistring; findInBlockchain:boolean=false):tBaseTXO; //you must free the object if findInBlockchain
var i:integer;
begin
 if findInBlockchain then raise exception.Create('getNVSRecordByName:findInBlockchain is not supported');
 result:=nil;

 if findInBlockchain then begin

 end else
   for i:=0 to emerAPI.UTXOList.Count-1 do
     if name=emerAPI.UTXOList[i].getNVSName then begin
       result:=emerAPI.UTXOList[i];
       exit;
     end;

end;

var
    LastsetSerialCountFromFileFile:string='';
    LastsetSerialCountFromFileTitle:string='';
    LastsetSerialCountFromFileCount:integer=0;
    LastsetSerialCountFromFileFileAge:tDateTime=0;

function setSerialCountFromFile(aFileName:string):integer;
var
  f:text;
  s,title:string;

begin
 if (LastsetSerialCountFromFileFile=aFileName) and (LastsetSerialCountFromFileFileAge=fileAge(aFileName)) then begin
    result:=LastsetSerialCountFromFileCount;
 end else begin

   title:='';
   assignfile(f,aFileName);
   try
     reset(f);
     readln(f,title);

     result:=0;
     while not eof(f) do begin
       readln(f,s);
       result:=result+1;
     end;

   finally
     closefile(f);
   end;
   LastsetSerialCountFromFileFile:=aFileName;
   LastsetSerialCountFromFileCount:=result;
   LastsetSerialCountFromFileFileAge:=fileAge(aFileName);
   LastsetSerialCountFromFileTitle:=title;
end;

end;

function getParameter(text,name:string; allowMultyLine:boolean=true):string;
var s:string;
    n:integer;
begin
 //extract *XXXX= or XXX= parameter. Multiline is possible
 result:='';
 n:=pos(#10,text);
 while n>0 do begin
   s:=copy(text,1,n-1);
   delete(text,1,n);

   if (length(s)>0) and (s[length(s)]=#13) then delete(s,length(s),1);

   if (pos(name+'=',s)=1) or (pos('*'+name+'=',s)=1) then begin
      if s[1]='*' then delete(s,1,1);
      delete(s,1,length(name)+1);
      if result<>'' then result:=result+#10;
      result:=result+s;
      if not allowMultyLine then exit;
   end;
   n:=pos(#10,text);
 end;

end;

function getSerialFromLot(lot:tBaseTXO):string;
begin
  result:=getParameter(lot.getNVSValue,'POOL');
end;

function add1(const s:ansistring):ansistring;
var n:integer;
begin
  n:=length(s);
  result:=s;

  while n>0 do
    if not (result[n] in ['0'..'9','A'..'Z','a'..'z']) then dec(n)
    else if not (result[n] in ['9','Z','z']) then begin
        result[n]:=chr(ord(result[n])+1);
        exit;
      end else begin
        if result[n] = '9' then result[n]:='0'
        else
        if result[n] = 'z' then result[n]:='a'
        else
        if result[n] = 'Z' then result[n]:='A'
        else
        raise exception.Create('add1: internal error 1:"'+s+'"');
        dec(n);
      end;

  raise exception.Create('add1: can''t increment sn:"'+s+'"');
end;

function getRangeSize(range:string):integer;
var i:integer;
    n:integer;
    s1,s2:ansistring;

begin
  result:=0;
  if range='' then exit;

  if pos(':',range)>0 then exit;

  while pos(';',range)>0 do begin
    n:=getRangeSize(copy(range,1,pos(';',range)-1));
    if n<1 then begin result:=0; exit; end;
    result:=result + n;
    delete(range,1,pos(';',range));
  end;
  if range='' then exit;

  if pos('~',range)>1 then begin
     s1:=copy(range,1,pos('~',range)-1);
     delete(range,1,pos('~',range));
     s2:=range;

     if length(s1)<>length(s2) then begin result:=0; exit; end;

     n:=0;
     for i:=1 to length(s1) do begin
       if not (
           ((s1[i] in ['0'..'9']) and (s2[i] in ['0'..'9']))
           or ((s1[i] in ['A'..'Z']) and (s2[i] in ['A'..'Z']))
           or ((s1[i] in ['a'..'z']) and (s2[i] in ['a'..'z']))
          ) then begin result:=0; exit; end;

       if n>0 then begin
         if s1[i] in ['0'..'9'] then n:=n*10 else n:=n*26;
         n:=n + ord(s2[i])-ord(s1[i]);
       end else if s1[i]<>s2[i] then n:=ord(s2[i])-ord(s1[i]);

       if n<0 then begin result:=0; exit; end;
     end;
     result:=result + n + 1;

  end else result:=result + 1;

end;



//////////////////////////////////////////////////////////////
constructor tSerialIteratorEl.create(aParent:tSerialIterator;aData:string {serial or file line});
begin
  inherited create;
  Data:=aData;

  serial:='';

  Parent:=aParent;
  fDone:=false;
  nvsName:='';
  fExecuteNextStepCounter:=0;
  nameAbsent:=false;
end;

procedure tSerialIteratorEl.executeNextStep;
begin
  //1. create nvsName if necessesary
  //  1.1. Create name
  //  1.2. check it if necessesary
  //  call executeNextStep when we have a name
  //2. create data
  //  2.1.
  //  call executeNextStep when we have all tbe data and ready to save out results
  //3. create all
  //  3.1. body
  //  3.1.
  //  3.1.

  inc(fExecuteNextStepCounter);

  if fExecuteNextStepCounter>100 then
    raise exception.Create('circular call in tSerialIteratorEl.executeNextStep');

  if serial='' then parent.cbSetSerial(self);

  if (nvsName='') and (not nameAbsent) then begin
     parent.cbSetNVSName(self); //must call  sender.executeNextStep or schedule name checking
     exit;
  end;


//  we have a name
 //  we have all tbe data and ready to save out results
 //needNVSName?
 if parent.needNVSName and (nvsName='') then begin
   parent.cbError(self,'NVS name not found');
   exit;
 end;

 //Secret:ansistring; //needSecret?
 if parent.needSecret and (Secret='') then parent.cbSetSecret(self); //DO NOT call back

 if (parent.needAddress) and ((PrivKey='') or (PubKey='') or (Address='')) then parent.cbSetKeys(self); //DO NOT call back. Sets PrivKey PubKey Address

 if parent.needNVSValue and (nvsValue='') then begin
   parent.cbSetValue(self); //OPTIONAL call back. Sets nvsValue. Set nvsValue for callback
   if nvsValue='' then exit;
 end;

 if parent.needToCreate and (not nvsCreated) then begin
   parent.cbCreateNVSRecord(self); //CAN BE called back or just passed. Set nvsCreated after created
   if not nvsCreated then exit;
 end;

 parent.cbSaveData(self);

 //all tasks finished!
 fDone:=true;

end;

procedure tSerialIteratorEl.AsyncDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
var e:tJsonData;
    {s:string;
    val,x:double;
    nc,i,n:integer;
    st:ansistring;
    vR,vY,vS:double;
    nameScript:tNameScript;
    amount:integer;
    }
begin

  if sender.id=('checkname:'+trim(NVSname)) then begin
    e:=result.FindPath('result');
    if e<>nil then
       if e.IsNull then begin
         //ok, name is free!
         try
           executeNextStep;
         except
           on e:exception do
             parent.cbError(self,'tSerialIteratorEl.AsyncDone: execution error: '+e.Message);
         end
       end else
       try
         //name exists!
         lastSuffix:=(lastSuffix+1) mod 100000;
         while (length(nvsName)>1) and (nvsName[length(nvsName)]<>':') do delete(nvsName,length(nvsName),1);
         nvsName:=nvsName+inttostr(lastSuffix);
         emerAPI.EmerAPIConnetor.sendWalletQueryAsync('name_show',getJSON('{name:"'+nvsName+'"}'),@(AsyncDone),'checkname:'+nvsName);
       except
         parent.cbError(self,'tSerialIteratorEl.AsyncDone: incorrect name data in: '+result.AsJSON+' tag:'+sender.id);
       end
    else parent.cbError(self,'tSerialIteratorEl.AsyncDone: can''t find result in: '+result.AsJSON+' tag:'+sender.id);

  end else begin
    //raise exception.Create('tSerialIteratorEl.AsyncDone: unknown tag '+sender.id);
    parent.cbError(self,'tSerialIteratorEl.AsyncDone: unknown tag '+sender.id);

  end;
  {
 bViewName.Enabled:=false;
 bSend.Enabled:=false;
 if result=nil then begin
   //showMessageSafe('Error: '+sender.lastError);
   lNameExits.Caption:='checking name error:'+sender.lastError;
   exit;
 end;

 if sender.id=('checkname:'+trim(eName.Text)) then begin
  e:=result.FindPath('result');
  if e<>nil then
     if e.IsNull then begin
       lNameExits.Caption:=localizzzeString('tFrameCreateName.NameIsFree','Name is not registered yet');
       bSend.Enabled:=trim(eName.Text)<>'';
     end else
     try
       lNameExits.Caption:=
         e.FindPath('address').AsString
         + localizzzeString('tFrameCreateName.NameIsDelegated',' has registered the name till ')
         + datetostr(trunc(now() + e.FindPath('expires_in').AsInt64/175 ));
       bViewName.Enabled:=true;
     except
       lNameExits.Caption:='Error: incorrect name data in: '+result.AsJSON;
     end
  else lNameExits.Caption:='Error: can''t find result in: '+result.AsJSON;


 end else begin
   lNameExits.Caption:='checking name...';
   nameCheckTime.Enabled:=true;
 end;
 }
end;



/////////////////////////// tSerialIterator
procedure tSerialIterator.cbError(Sender:tSerialIteratorEl;message:string); //stops the process
var f:text;
begin
  Sender.done:=true;

  if optSaveErrorFileName<>'' then begin
    assignFile(f,optSaveErrorFileName);
    append(f);
    writeln(f,Sender.data+CSVsep+message);
    closefile(f);
  end;

  LastError:=message;
  callNotify('error');

end;

procedure tSerialIterator.cbSetNVSName(Sender:tSerialIteratorEl);
//called by child. Virtual!
//Set Sender.NVSName . Call Sender.executeNextStep if done or schedure work for Sender.AsyncDone
var n:dword;
begin
  //override for file
  //name format:
  //brandname:serial:suffix

  //we CAN NOT create the name if optBrandName is not set
  //set nameAbsent in this case

  if optBrandName='' then  begin
    Sender.nameAbsent:=true;
    Sender.nvsName:='';
    Sender.executeNextStep;
  end else begin
    //optCheckNameIfFree:boolean;
    //optAddRandomSuffix:boolean;
    if optAddRandomSuffix then n:=random(100000) else n:=0;
    Sender.nvsName:=optBrandName+':'+sender.data+':'+inttostr(n);

    Sender.lastSuffix:=n;

    if optCheckNameIfFree then begin
      //schedule name check
      emerAPI.EmerAPIConnetor.sendWalletQueryAsync('name_show',getJSON('{name:"'+Sender.nvsName+'"}'),@(Sender.AsyncDone),'checkname:'+Sender.nvsName);
    end
    else Sender.executeNextStep;

  end;

end;

procedure tSerialIterator.cbSetSerial(Sender:tSerialIteratorEl);
//DO NOT call back
begin
  sender.serial:=sender.data;
end;

procedure tSerialIterator.cbSetSecret(Sender:tSerialIteratorEl);
//DO NOT call back
var i:integer;
    result:ansistring;
begin
  //MUST BE OVERRIDEN FOR FILE
 setLength(result,fcSecretCodeLength);




 for i:=1 to fcSecretCodeLength do
   result[i]:=CT_Base58[cl4pRandom.Next(1,Length(CT_Base58))];

 Sender.Secret:=result;


end;

procedure tSerialIterator.cbSetKeys(Sender:tSerialIteratorEl);
//DO NOT call back. Sets PrivKey PubKey Address
begin
  //MUST BE OVERRIDEN FOR FILE

end;

procedure tSerialIterator.cbSetValue(Sender:tSerialIteratorEl);
//OPTIONAL call back. Sets nvsValue. Set nvsValue for callback
begin
  //MUST BE OVERRIDEN FOR FILE. Maybe we have value?

end;


procedure tSerialIterator.cbCreateNVSRecord(Sender:tSerialIteratorEl);
//CAN BE called back or just passed. Set nvsCreated after created
begin

end;

function tSerialIterator.createCSVLine(iel:tSerialIteratorEl; title:ansistring):string;
var
  fld:ansistring;
  n:integer;
begin
 result:='';
 title:= trim(title);
 if title='' then exit;

 while title<>'' do begin
   n:=pos(CSVsep,title);
   if n>0 then begin
     fld:=lowercase(trim(copy(title,1,n-1)));
     delete(title,1,n);
   end else begin
     fld:=lowercase(trim(title));
     title:='';
   end;


   //serial secret brand address nvsname nvsvalue
   try
     result:=result + giveTagValue(iel,fld);
     if (fld<>'nvsvalue') or (title<>'') then result:=result + CSVsep; //terminate only non-last value
   except
     on e:exception do begin
       result:='';
       lasterror:=e.Message;
       exit;
     end;
   end;
   {
   if fld='serial' then begin
     result:=result + iel.serial + CSVsep;
   end else if fld='secret' then begin
     result:=result + iel.Secret + CSVsep;
   end else if fld='brand' then begin
     result:=result + optBrandName + CSVsep;
   end else if fld='address' then begin
     result:=result + iel.Address + CSVsep;
   end else if fld='nvsname' then begin
     result:=result + iel.nvsName + CSVsep;
   end else if fld='nvsvalue' then begin
     result:=result + screen(iel.NVSValue) {+ CSVsep};
     if title<>'' then result:=result + CSVsep; //terminate only non-last value

   end else begin
     result:='';
     lasterror:='UNKNOWN CSV FIELD: "'+fld+'"';
     exit;
   end;
   }
 end;

end;

function tSerialIterator.giveTagValue(iel:tSerialIteratorEl;fld:string):string;
begin
 if fld='serial' then
   result:=iel.serial
 else if fld='secret' then
   result:=iel.Secret
 else if fld='brand' then
   result:=cutPreffix('dpo:',optBrandName)
 else if fld='address' then
   result:=iel.Address
 else if fld='nvsname' then
   result:=iel.nvsName
 else if fld='nvsvalue' then
   result:=screen(iel.NVSValue)
 else
   raise exception.create('UNKNOWN CSV FIELD: "'+fld+'"');

end;

function tSerialIterator.fillQRTemplate(Sender:tSerialIteratorEl;template:string):string;
var i,n,l:integer;
begin
  result:=template;

  for i:=0 to length(tagWords)-1 do begin
    n:=pos('%'+tagWords[i]+'%',result);
    while n>0 do begin
      l:=length('%'+tagWords[i]+'%');
      result:=copy(result,1,n-1) +giveTagValue(Sender,tagWords[i])+ copy(result,n+l,length(result)-l-n+1);

      n:=pos('%'+tagWords[i]+'%',result)
    end;
  end;

end;

procedure tSerialIterator.cbSaveData(Sender:tSerialIteratorEl);
//DO NOT call back!
var s:string;
begin
  //save all files, create QRs
 {
 FilePrivateCSV:string;
 TitlePrivateCSV:ansistring;
 FilePublicCSV:string;
 TitlePublicCSV:ansistring;
 FilePrintCSV:string;
 TitlePrintCSV:ansistring;

 folderQR1:string;
 folderQR2:string;
 }

 LastError:='';

 if FilePrivateCSV<>'' then begin
   s:=createCSVLine(sender,TitlePrivateCSV);
   if (s='') or (not saveLineToFile(FilePrivateCSV,s)) then begin
      cbError(Sender,LastError);
      exit;
   end;
 end;

 if FilePublicCSV<>'' then begin
   s:=createCSVLine(sender,TitlePublicCSV);
   if (s='') or (not saveLineToFile(FilePublicCSV,s)) then begin
      cbError(Sender,LastError);
      exit;
   end;
 end;

 if FilePrintCSV<>'' then begin
   s:=createCSVLine(sender,TitlePrintCSV);
   if (s='') or (not saveLineToFile(FilePrintCSV,s)) then begin
      cbError(Sender,LastError);
      exit;
   end;
 end;

 if folderQR1<>'' then
   if not createQR(IncludeTrailingPathDelimiter(folderQR1)+'p_'+CleanFileName(Sender.serial)+'.png' , fillQRTemplate(Sender,templateQR1) ) then begin
      cbError(Sender,LastError);
      exit;
   end;

 if folderQR2<>'' then
   if not createQR(IncludeTrailingPathDelimiter(folderQR2)+'p_'+CleanFileName(Sender.serial)+'.png' , fillQRTemplate(Sender,templateQR2) ) then begin
      cbError(Sender,LastError);
      exit;
   end;


 {D!!} AFCreateForPrintingForm.mDebug.lines.append(Sender.data+': '+Sender.NVSName);

end;


function tSerialIterator.getNextSerialFromPool:ansistring; //returns next serial for fcRange. Do not use it in tSerialIteratorFile
var s:ansistring;
begin
  result:='';
  if (fcRange='') and (fcLastSerial='') then exit;

  if fcLastSerial='' then begin
    //take the next part of the range
    //cutting the next part of the range
    if pos(';',fcRange)>0 then begin
      s:=copy(fcRange,1,pos(';',fcRange)-1);
      delete(fcRange,1,pos(';',fcRange));
    end else begin
      s:=fcRange;
      fcRange:='';
    end;
    s:=trim(s);

    fcRangeEnd:='';
    if pos('~',s)>0 then begin
      result:=copy(s,1,pos('~',s)-1);
      delete(s,1,pos('~',s));

      if length(s)<>length(result) then raise exception.Create('incorrect code range: 1: '+result+'~'+s);

      fcRangeEnd:=s;
      fcLastSerial:=result;
    end else result:=s; //left fcLastSerial empty
  end else begin
    //we are inside a subrange
    result:=add1(fcLastSerial);

    if fcRangeEnd=result then
      //it was a last serial from the subrange
      fcLastSerial:=''//start from the range begining
    else
      fcLastSerial:=result;
  end;

end;

procedure tSerialIterator.execute;
begin
  while (not Terminated) and ((SimTaskCount<=fList.Count) or doNext) do begin
     application.ProcessMessages;
     checkFinished;
  end;
  //will exit when the list is full or work done or stopped
end;

function tSerialIterator.doNext:boolean;
var serial:string;
    //name:ansistring;
    sel:tSerialIteratorEl;
begin
  //returns if there is a new serial
  result:=false;
  serial:=getNextSerialFromPool;
  if serial='' then exit;
  result:=true; //we have next code!

  sel:=tSerialIteratorEl.create(self,serial);
  fList.Add(sel);
  sel.executeNextStep;
end;


procedure tSerialIterator.stop;
begin
  Terminated:=true;
end;

function tSerialIterator.checkFinished:boolean; //check the fList and returns if it is no more tasks to do
var i:integer;
begin
  i:=0;
  while i<fList.Count do
    if tSerialIteratorEl(fList[i]).done then begin
       tSerialIteratorEl(fList[i]).Free;
       fList.Delete(i);
    end else inc(i);
  result:=fList.Count=0;
end;

constructor tSerialIterator.create;
begin
  inherited;
  Terminated:=false;
  fList:=tList.Create;

  fNPassed:=0;

  SimTaskCount:=10;

  fcLastSerial:='';
  fcRangeEnd:='';
  fcRange:='';
end;

destructor tSerialIterator.destroy; //override;
var i:integer;
begin
 Terminated:=true;
 i:=0;
 while (not checkFinished) and (i<1000) do begin  //waiting for terminating
   sleep(1);
   inc(i);
   application.ProcessMessages;
 end;

 fList.free;
 inherited;
end;


constructor tSerialIteratorRange.create(aRange:string);
begin
  inherited create;
  fNTotal:=getRangeSize(range);

  fRange:=aRange;
  fcRange:=aRange;
end;

constructor tSerialIteratorLot.create(lot:tBaseTXO);
begin
  inherited create;
  fRange:=getSerialFromLot(lot);
  fcRange:=fRange;
  fNTotal:=getRangeSize(fRange);
end;


procedure tSerialIteratorFile.cbSetSerial(Sender:tSerialIteratorEl);
var
  fld:ansistring;
  title:ansistring;
  s:ansistring;
  value:string;

  function pop(var s:string):string;
  var  n:integer;
  begin
    n:=pos(CSVsep,s);
    if n<1 then begin
      result:=copy(s,1,n-1);
      delete(s,1,n);
    end else begin
      result:=s;
      s:='';
    end;
  end;

begin
  //decode data. set all
  //follow fTitle

  title:=trim(fTitle);

  s:=Sender.data;

  //serial secret brand address nvsname nvsvalue

  while title<>'' do begin
    fld:=lowercase(trim(pop(title)));

    //add the rest part for supporing separators in value
    if (fld='nvsvalue') and (title='')
      then value:=s
      else value:=pop(s);

    //unscreen \n
    if (fld='nvsvalue') then
      value:=unscreen(value);


    if fld='serial' then begin
      Sender.serial:=value;
    end else if fld='secret' then begin
      Sender.Secret:=value;
    end else if fld='brand' then begin
      Sender.brandFromFile:=value;
    end else if fld='address' then begin
      Sender.Address:=value;
    end else if fld='nvsname' then begin
      Sender.nvsName:=value;
    end else if fld='nvsvalue' then begin
      Sender.nvsValue:=value;
    end else begin
      //unknown field
    end;
  end;


end;

constructor tSerialIteratorFile.create(aFilename:string);
begin
  fNTotal:=setSerialCountFromFile(aFilename);
  if fNTotal<1 then raise exception.Create('tSerialIteratorFile.create: no any serials in file');

  inherited create;

  fFilename := aFilename;

  fRange:='';
  fcRange:='';

  assignfile(fFile,aFileName);
  reset(fFile);
  readln(fFile,fTitle);

end;

destructor tSerialIteratorFile.destroy;
begin
 closeFile(fFile);
 inherited;
end;

function tSerialIteratorFile.doNext:boolean;
begin
  //returns if there is a new serial
end;


{ TAFCreateForPrintingForm }
procedure TAFCreateForPrintingForm.init;
var i:integer;
    s:string;
begin
  fNVSAddValue:='';

  //LastSetEnabledAndViewFile:='';
  //LastSetEnabledAndViewFileTitle:='';
  //LastSetEnabledAndViewFileDescription:='';
  //LastSetEnabledAndViewFileAge:=0;

  if fIterator<> nil then fIterator.Terminated:=true;

  mDebug.Visible:=Settings.getValue('Dev_Mode_ON');
  Splitter1.Visible:=Settings.getValue('Dev_Mode_ON');

  //fill combos

  cLot.Items.Clear;
  cBrand.Items.Clear;

  cBrand.Items.Add(localizzzeString('AFCreateForPrintingForm.cBrand.Manual','Manual add'));

  for i:=0 to emerAPI.UTXOList.Count-1 do begin
    s:=emerAPI.UTXOList[i].getNVSName;
    if pos('af:lot:',s)=1 then begin
       //lot
       //cLot.Items.AddObject(copy(s,8,length(s)-7),emerAPI.UTXOList[i]);!
      cLot.Items.Add(copy(s,8,length(s)-7));
    end else
    if (pos('dpo:',s)=1) and (pos(':',copy(s,5,length(s)-4))<1) then begin
       //brand
       //cBrand.Items.AddObject(copy(s,5,length(s)-4),emerAPI.UTXOList[i]);!
      cBrand.Items.Add(copy(s,5,length(s)-4));
    end;
  end;



  chCreateProductField.checked:=true;
  chCreateParentField.checked:=false;
  chCreateParentLotField.checked:=false;
  chCreateNVSrecordsOwnedByMe.checked:=false;
  chCreateBrandField.checked:=false;
  chAddCustomFields.checked:=false;
  cLot.itemIndex:=-1;
  chCreatePrintCSV.checked:=false;
  chCreatePrivateCSV.checked:=false;
  chCreatePublicCSV.checked:=false;
  chCreateQR1.checked:=false;
  chCreateQR2.checked:=false;
  chCreateNVSrecords.checked:=false;
  chLogErrorSerialsToFile.checked:=false;
  eIteratorRange.text:='';
  fnIteraror.filename:='';
  mDebug.text:='';
  ProgressBar.position:=0;

  eBrand.text:='';
  chCheckNamesIfFree.checked:=false;
  chAddRandomSuffix.checked:=false;

  fnLogErrorSerialsToFile.filename:='';

  fnCreatePrivateCSV.FileName:='';
  fnCreatePublicCSV.FileName:='';
  fncreatePrintCSV.FileName:='';
  deCreateQR1.Directory:='';
  deCreateQR2.Directory:='';

  chPubAddName.checked:=false;
  chPubAddValue.checked:=false;
  chPubAddBrand.checked:=false;
  chPubAddAddress.checked:=false;

  chPrivAddName.checked:=false;
  chPrivAddValue.checked:=false;
  chPrivAddBrand.checked:=false;
  chPrivAddAddress.checked:=false;

  chFolderPackage.Checked:=true;
  deFolderPackage.Directory:='';

  eTextQR1.Text:='https://emcdpo.info/v?s=%serial%&b=%brand%';
  eTextQR2.Text:='https://emcdpo.info/v?s=%serial%&p=%secret%&b=%brand%';

  seSecretCodeLenght.Value:=12;

  setEnabledAndView;


end;


procedure TAFCreateForPrintingForm.getBrandCallBack(Sender:tAFRequest);
begin

end;

procedure TAFCreateForPrintingForm.setEnabledAndView;
var n:integer;
    //f:text;
    //s,title:string;
lot : tBaseTXO;
begin
  eIteratorRange.Enabled:= rbIterRange.checked;
  fnIteraror.Enabled := rbIterFile.checked;
  cLot.Enabled := rbIterLot.checked;

  cBrand.Enabled:= rbIterRange.checked or rbIterFile.checked;

  if rbIterRange.checked then begin
     n:=getRangeSize(eIteratorRange.text);
     lInformation1.Caption:=localizzzeString('AFCreateForPrintingForm.lInformation1.SerialVolume','Count: ')+inttostr(n);

  end else
  if rbIterFile.checked then begin
     if not fileexists(fnIteraror.FileName) then lInformation1.Caption:=localizzzeString('AFCreateForPrintingForm.Messages.FileNotExist','file does not exist')
     else begin

       n:=setSerialCountFromFile(fnIteraror.FileName);

       {
       if (LastSetEnabledAndViewFile=fnIteraror.FileName) and (LastSetEnabledAndViewFileAge=fileAge(fnIteraror.FileName)) then begin
          //LastSetEnabledAndViewFile:string;
          //LastSetEnabledAndViewFileTitle:string;
          //LastSetEnabledAndViewFileDescription:string;
          lInformation1.Caption:=LastSetEnabledAndViewFileDescription;
          title:=LastSetEnabledAndViewFileTitle;
       end else begin

         title:='';
         assignfile(f,fnIteraror.FileName);
         try
           reset(f);
           readln(f,title);

           n:=0;
           while not eof(f) do begin
             readln(f,s);
             n:=n+1;
           end;

         finally
           closefile(f);
         end;
         LastSetEnabledAndViewFile:=fnIteraror.FileName;
         LastSetEnabledAndViewFileDescription:=lInformation1.Caption;
         LastSetEnabledAndViewFileAge:=fileAge(fnIteraror.FileName);
         LastSetEnabledAndViewFileTitle:=title;



         lInformation1.Caption:=localizzzeString('AFCreateForPrintingForm.lInformation1.SerialVolume','Count: ')+inttostr(n);


       end;
       }
       lInformation1.Caption:=localizzzeString('AFCreateForPrintingForm.lInformation1.SerialVolume','Count: ')+inttostr(n);
     end;
  end else if rbIterLot.checked then begin
    if cLot.ItemIndex<0 then  lInformation1.Caption:=localizzzeString('AFCreateForPrintingForm.lInformation1.LotNotSelected','Lot not selected')
    else begin
      //lot:=tNVSRecord(cLot.Items.Objects[cLot.ItemIndex] );!
      lot:=getNVSRecordByName('af:lot:'+cLot.Items[cLot.ItemIndex]);

      if lot = nil then raise exception.Create('Internal error 2: lot is nil');

      n:=getRangeSize(getSerialFromLot(lot));

      if n < 1 then
        lInformation1.Caption:=localizzzeString('AFCreateForPrintingForm.lInformation1.WrongLot','Count: ')
      else begin
        lInformation1.Caption:=localizzzeString('AFCreateForPrintingForm.lInformation1.SerialVolume','Count: ')+inttostr(n)
          +#10+localizzzeString('AFCreateForPrintingForm.lInformation1.PleaseWait','Please wait');
        AFGetBrandForObject(lot,@getBrandCallBack);
      end;

    end;
  end else begin
    lInformation1.Caption:='';
  end;

  bEditCustomFields.Enabled:=chAddCustomFields.checked;
  if fNVSAddValue<>''
    then bEditCustomFields.Font.Style:=bEditCustomFields.Font.Style + [fsBold]
    else bEditCustomFields.Font.Style:=bEditCustomFields.Font.Style - [fsBold];

  lBrandManualComment.Enabled:=(cBrand.ItemIndex=0) and cBrand.Enabled;
  lBrandManual.Enabled:=(cBrand.ItemIndex=0) and cBrand.Enabled;
  eBrand.Enabled:=(cBrand.ItemIndex=0) and cBrand.Enabled;

  fnLogErrorSerialsToFile.enabled:=chLogErrorSerialsToFile.Checked and (not chFolderPackage.Checked);

  fnCreatePrivateCSV.Enabled:=chCreatePrivateCSV.checked and (not chFolderPackage.Checked);
  fnCreatePublicCSV.Enabled:=chCreatePublicCSV.Checked and (not chFolderPackage.Checked);
  fncreatePrintCSV.Enabled:=chcreatePrintCSV.Checked and (not chFolderPackage.Checked);
  deCreateQR1.Enabled:=chCreateQR1.Checked and (not chFolderPackage.Checked);
  deCreateQR2.Enabled:=chCreateQR2.Checked and (not chFolderPackage.Checked);

  chPubAddName.enabled:=chCreatePublicCSV.checked;
  chPubAddValue.enabled:=chCreatePublicCSV.checked;
  chPubAddBrand.enabled:=chCreatePublicCSV.checked;
  chPubAddAddress.enabled:=chCreatePublicCSV.checked;

  chPrivAddName.enabled:=chCreatePrivateCSV.checked;
  chPrivAddValue.enabled:=chCreatePrivateCSV.checked;
  chPrivAddBrand.enabled:=chCreatePrivateCSV.checked;
  chPrivAddAddress.enabled:=chCreatePrivateCSV.checked;

  deFolderPackage.Enabled:=chFolderPackage.Checked;

  eTextQR1.Enabled:=chCreateQR1.Checked;
  lTextQR1.Enabled:=chCreateQR1.Checked;
  eTextQR2.Enabled:=chCreateQR2.Checked;
  lTextQR2.Enabled:=chCreateQR2.Checked;

  if fIterator<>nil then
    if fIterator.Terminated then begin
       bCreate.Caption:=localizzzeString('AFCreateForPrintingForm.bCreate.Stopping','Stopping...');
       bCreate.Enabled:=false;
    end else begin
      bCreate.Caption:=localizzzeString('AFCreateForPrintingForm.bCreate.Stop','Stop');
      bCreate.Enabled:=true;
    end
  else begin
    bCreate.Caption:=localizzzeString('AFCreateForPrintingForm.bCreate.Start','Start');
    bCreate.Enabled:=true;
  end;
end;


procedure TAFCreateForPrintingForm.FormShow(Sender: TObject);
var i:integer;
    s:string;
begin
  localizzze(self);

  init;

end;


procedure TAFCreateForPrintingForm.itError(Sender: TObject);
begin
  if mDebug.Visible then
    mDebug.Lines.Append(tSerialIterator(Sender).LastError);
end;

procedure TAFCreateForPrintingForm.itStepDone(Sender: TObject);
begin
  ProgressBar.Position:=trunc(100 * fIterator.nPassed / fIterator.nTotal);
end;

procedure TAFCreateForPrintingForm.bCreateClick(Sender: TObject);
var
  lot,brand: tBaseTXO;
  path:string;

  procedure dieControl(tag:ansistring; control:tWinControl=nil);
  begin
   if control<>nil then
     if control.Enabled then
       control.setFocus;
   with AskQuestionTag(self,nil,tag) do begin
      bOk.Visible:=true;
      Update;
    end;
  end;

begin

   //tSerialIteratorRange
   //tSerialIteratorLot
   //tSerialIteratorFile

  if fIterator=nil then begin
    //check data

    if (not chFolderPackage.Checked) and  chLogErrorSerialsToFile.Checked and (trim(fnLogErrorSerialsToFile.FileName)='') then begin
      fnLogErrorSerialsToFile.SetFocus;
      showMessageSafe(localizzzeString('AFCreateForPrintingForm.msg.PleaseSetFileName','Please select filename'));
      exit;
    end;

    if chFolderPackage.Checked and (deFolderPackage.Directory='') then begin
      dieControl('AFCreateForPrintingForm.msg.PleaseSetFolder',deFolderPackage);
      exit;
    end;

    if (not chFolderPackage.Checked) and chCreatePrivateCSV.checked and (fnCreatePrivateCSV.FileName='') then
    begin
      dieControl('AFCreateForPrintingForm.msg.PleaseSetFileName',fnCreatePrivateCSV);
      exit;
    end;

    if (not chFolderPackage.Checked) and chCreatePublicCSV.checked and (fnCreatePublicCSV.FileName='') then
    begin
      dieControl('AFCreateForPrintingForm.msg.PleaseSetFileName',fnCreatePublicCSV);
      exit;
    end;

    if (not chFolderPackage.Checked) and chCreatePrintCSV.checked and (fnCreatePrintCSV.FileName='') then
    begin
      dieControl('AFCreateForPrintingForm.msg.PleaseSetFileName',fnCreatePrintCSV);
      exit;
    end;

    if (not chFolderPackage.Checked) and chCreateQR1.checked and (deCreateQR1.Directory='') then
    begin
      dieControl('AFCreateForPrintingForm.msg.PleaseSetFolder',deCreateQR1);
      exit;
    end;

    if (not chFolderPackage.Checked) and chCreateQR2.checked and (deCreateQR2.Directory='') then
    begin
      dieControl('AFCreateForPrintingForm.msg.PleaseSetFolder', deCreateQR2);
      exit;
    end;

    //start iterator: setup
    if rbIterRange.checked then begin
      //range of numbers
      fIterator:=tSerialIteratorRange.create(eIteratorRange.text);
    end else if rbIterFile.Checked then begin
      if not fileexists(fnIteraror.FileName) then begin
        dieControl('AFCreateForPrintingForm.Messages.FileNotExist', fnIteraror);
        exit;
      end;
      fIterator:=tSerialIteratorFile.create(fnIteraror.FileName);
    end  else if rbIterLot.Checked then begin
      if cLot.ItemIndex<0 then
        begin
          dieControl('AFCreateForPrintingForm.msg.LotNotSelected',cLot);
          exit;
        end;


      lot:=getNVSRecordByName('af:lot:'+cLot.Items[cLot.ItemIndex]);  //tNVSRecord(cLot.Items.Objects[cLot.ItemIndex] );!
      if lot = nil then raise exception.Create('Internal error: lot is nil');

      fIterator:=tSerialIteratorLot.create(lot);
    end else exit;
    try
      setEnabledAndView();
      fIterator.addNotify(EmerAPINotification(@itStepDone,'stepdone',true));

      fIterator.addNotify(EmerAPINotification(@itError,'error',true));

      fIterator.optCheckNameIfFree := chCheckNamesIfFree.Checked;
      fIterator.optAddRandomSuffix := chAddRandomSuffix.Checked;

      if cBrand.ItemIndex>0 then begin
        brand:=getNVSRecordByName('dpo:'+cBrand.Items[cbrand.ItemIndex]); //tNVSRecord(cBrand.Items.Objects[cbrand.ItemIndex] );!
        if brand = nil then raise exception.Create('Internal error 3: brand is nil');

        fIterator.optBrandName:=brand.getNVSName;
        fIterator.optBrandOwner:=brand.getReceiver;
      end else if cBrand.ItemIndex=0 then begin

        if chCreateNVSrecords.checked then
        begin
          dieControl('AFCreateForPrintingForm.msg.BrandMustBeYour');
          freeandnil(fIterator);
          exit;
        end;
        {
        begin
          with AskQuestionTag(self,nil,'AFCreateForPrintingForm.msg.BrandMustBeYour') do begin
            bOk.Visible:=true;
            Update;
          end;
          freeandnil(fIterator);
          exit;
        end;
        }

        fIterator.optBrandName:=trim(eBrand.Text);
        if pos('dpo:',fIterator.optBrandName) = 1 then delete(fIterator.optBrandName,1,4);
        if pos(':',fIterator.optBrandName)>0 then raise exception.Create('Invalid brand name');
        fIterator.optBrandName:='dpo:'+fIterator.optBrandName;

        fIterator.optBrandOwner:='';
      end else
      //if we will need brand defined
      if chCreatePrintCSV.checked or chCreateQR1.checked or chCreateQR2.checked or chCreateNVSrecords.checked then
      begin
        with AskQuestionTag(self,nil,'AFCreateForPrintingForm.msg.BrandMustBeSet') do begin
          bOk.Visible:=true;
          Update;
        end;
        freeandnil(fIterator);
        exit;
      end;


      //create titles and files
      //0. package folder
      if chFolderPackage.checked then begin

        if not ForceDirectories(deFolderPackage.Directory) then
        begin
          dieControl('AFCreateForPrintingForm.msg.PleaseSetFolder',deFolderPackage);
          freeandnil(fIterator);
          exit;
        end;
        {
        with AskQuestionTag(self,nil,'AFCreateForPrintingForm.msg.PleaseSetFolder') do begin
          bOk.Visible:=true;
          Update;
          freeandnil(fIterator);
          deFolderPackage.setFocus;
          exit;
        end;
        }
      end;

      path:=IncludeTrailingPathDelimiter(deFolderPackage.Directory);

      if chLogErrorSerialsToFile.Checked
        then
          if chFolderPackage.checked
          then fIterator.optSaveErrorFileName:=path+'errors.csv'
          else fIterator.optSaveErrorFileName:=fnLogErrorSerialsToFile.FileName
        else fIterator.optSaveErrorFileName:='';


      //1. chCreatePrivateCSV
      if not chCreatePrivateCSV.checked then fIterator.FilePrivateCSV:='' else begin
        fIterator.TitlePrivateCSV:='serial'+CSVsep+'secret'+CSVsep;
        if chPrivAddBrand.Checked then fIterator.TitlePrivateCSV:= fIterator.TitlePrivateCSV+ 'brand'+CSVsep;
        if chPrivAddAddress.Checked then fIterator.TitlePrivateCSV:= fIterator.TitlePrivateCSV+ 'address'+CSVsep;
        if chPrivAddName.Checked then fIterator.TitlePrivateCSV:= fIterator.TitlePrivateCSV+ 'nvsname'+CSVsep;
        if chPrivAddValue.Checked then fIterator.TitlePrivateCSV:= fIterator.TitlePrivateCSV+ 'nvsvalue'+CSVsep;

        if chFolderPackage.Checked then
         fIterator.FilePrivateCSV:=path+'private.csv'
        else
          fIterator.FilePrivateCSV:=fnCreatePrivateCSV.FileName;
        if not saveLineToFile(fIterator.FilePrivateCSV,fIterator.TitlePrivateCSV,true) then
        begin
          dieControl('AFCreateForPrintingForm.msg.CantSaveFile',fnCreatePrivateCSV);
          freeandnil(fIterator);
          exit;
        end;

        {
        with AskQuestionTag(self,nil,'AFCreateForPrintingForm.msg.CantSaveFile') do begin
          bOk.Visible:=true;
          Update;
          freeandnil(fIterator);
          if fnCreatePrivateCSV.enabled then fnCreatePrivateCSV.setFocus;
          exit;
        end;
        }
      end;

      //2. chCreatePublicCSV
      if not chCreatePublicCSV.checked then fIterator.FilePublicCSV:='' else begin
        fIterator.TitlePublicCSV:='serial'+CSVsep+'secret'+CSVsep;
        if chPubAddBrand.Checked then fIterator.TitlePublicCSV:= fIterator.TitlePublicCSV+ 'brand'+CSVsep;
        if chPubAddAddress.Checked then fIterator.TitlePublicCSV:= fIterator.TitlePublicCSV+ 'address'+CSVsep;
        if chPubAddName.Checked then fIterator.TitlePublicCSV:= fIterator.TitlePublicCSV+ 'nvsname'+CSVsep;
        if chPubAddValue.Checked then fIterator.TitlePublicCSV:= fIterator.TitlePublicCSV+ 'nvsvalue'+CSVsep;

        if chFolderPackage.Checked then
          fIterator.FilePublicCSV:=path+'public.csv'
        else
          fIterator.FilePublicCSV:=fnCreatePublicCSV.FileName;
        if not saveLineToFile(fIterator.FilePublicCSV,fIterator.TitlePublicCSV,true) then
        begin
          dieControl('AFCreateForPrintingForm.msg.CantSaveFile',fnCreatePublicCSV);
          freeandnil(fIterator);
          exit;
        end;
       {
        with AskQuestionTag(self,nil,'AFCreateForPrintingForm.msg.CantSaveFile') do begin
          bOk.Visible:=true;
          Update;
          freeandnil(fIterator);
          if fnCreatePublicCSV.enabled then fnCreatePublicCSV.setFocus;
          exit;
        end;
        }
      end;

      //3. chCreatePrintCSV
      if not chCreatePrintCSV.checked then fIterator.FilePrintCSV:='' else begin
        fIterator.TitlePrintCSV:='serial'+CSVsep+'secret'+CSVsep;
        //if chPrintAddBrand.Checked then fIterator.TitlePrintCSV:= fIterator.TitlePrintCSV+ 'brand;';
        //if chPrintAddAddress.Checked then fIterator.TitlePrintCSV:= fIterator.TitlePrintCSV+ 'address;';
        //if chPrintAddName.Checked then fIterator.TitlePrintCSV:= fIterator.TitlePrintCSV+ 'nvsname;';
        //if chPrintAddValue.Checked then fIterator.TitlePrintCSV:= fIterator.TitlePrintCSV+ 'nvsvalue;';

        if chFolderPackage.Checked then
          fIterator.FilePrintCSV:=path+'print.csv'
        else
          fIterator.FilePrintCSV:=fnCreatePrintCSV.FileName;
        if not saveLineToFile(fIterator.FilePrintCSV,fIterator.TitlePrintCSV,true) then
        begin
          dieControl('AFCreateForPrintingForm.msg.CantSaveFile',fnCreatePrintCSV);
          freeandnil(fIterator);
          exit;
        end;

        {
        with AskQuestionTag(self,nil,'AFCreateForPrintingForm.msg.CantSaveFile') do begin
          bOk.Visible:=true;
          Update;
          freeandnil(fIterator);
          fnCreatePrintCSV.setFocus;
          exit;
        end;
        }
      end;

      //QR1
      if not chCreateQR1.checked then fIterator.folderQR1:='' else begin
        if chFolderPackage.Checked then
          fIterator.folderQR1:=IncludeTrailingPathDelimiter(path+'QR1')
        else
          fIterator.folderQR1:=deCreateQR1.Directory;
        if not ForceDirectories(fIterator.folderQR1) then
        begin
          dieControl('AFCreateForPrintingForm.msg.PleaseSetFolder',deCreateQR1);
          freeandnil(fIterator);
          exit;
        end;

        fIterator.templateQR1:=trim(eTextQR1.Text);
        {
        with AskQuestionTag(self,nil,'AFCreateForPrintingForm.msg.PleaseSetFolder') do begin
          bOk.Visible:=true;
          Update;
          freeandnil(fIterator);
          deCreateQR1.setFocus;
          exit;
        end;
        }
      end;
      //QR2
      if not chCreateQR2.checked then fIterator.folderQR2:='' else begin
        if chFolderPackage.Checked then
          fIterator.folderQR2:=IncludeTrailingPathDelimiter(path+'QR2')
        else
          fIterator.folderQR2:=deCreateQR2.Directory;
        if not ForceDirectories(fIterator.folderQR2) then
        begin
          dieControl('AFCreateForPrintingForm.msg.PleaseSetFolder',deCreateQR2);
          freeandnil(fIterator);
          exit;
        end;
        fIterator.templateQR2:=trim(eTextQR2.Text);
        {
        with AskQuestionTag(self,nil,'AFCreateForPrintingForm.msg.PleaseSetFolder') do begin
          bOk.Visible:=true;
          Update;
          freeandnil(fIterator);
          deCreateQR2.setFocus;
          exit;
        end;
        }
      end;


      fIterator.fcSecretCodeLength :=  seSecretCodeLenght.Value;

      fIterator.needNVSName := chCreateNVSrecords.Checked or (chCreatePrivateCSV.Checked and chPrivAddName.checked) or (chCreatePublicCSV.Checked and chPubAddName.checked);
      fIterator.needNVSValue := chCreateNVSrecords.Checked or (chCreatePrivateCSV.Checked and chPrivAddValue.checked) or (chCreatePublicCSV.Checked and chPubAddValue.checked);
      fIterator.needToCreate := chCreateNVSrecords.Checked;
      fIterator.needSecret := chCreatePrivateCSV.Checked or chCreatePrintCSV.Checked or chCreateQR2.Checked;
      fIterator.needAddress := (chCreatePrivateCSV.Checked and chPrivAddAddress.checked)
                               or (chCreatePublicCSV.Checked and chPubAddAddress.checked)
                               or chCreateNVSrecords.Checked;


      fIterator.execute;  //will lock the exexution but will call application.processmessages
    finally
      freeandnil(fIterator);
    end;
  end else begin
    //stop!
    fIterator.Terminated:=true;
    //freeandnil(fIterator);

  end;
  setEnabledAndView();

end;

procedure TAFCreateForPrintingForm.bCloseClick(Sender: TObject);
begin
  if fIterator=nil then
    FreeAndNil(fIterator);
  close;
end;

procedure TAFCreateForPrintingForm.bEditCustomFieldsClick(Sender: TObject);
begin
  fNVSAddValue:=NVSValueEditModal(fNVSAddValue,'dpo:brand:item:0');
  rbIterRangeChange(nil);
end;

procedure TAFCreateForPrintingForm.FormDestroy(Sender: TObject);
begin
  if fIterator<>nil then fIterator.Terminated:=true; //freeandnil(fIterator);
end;


procedure TAFCreateForPrintingForm.rbIterRangeChange(Sender: TObject);
begin
  setEnabledAndView;
end;


end.

