unit NameViewUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynCompletion, SynHighlighterAny,
  SynHighlighterIni, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  NVSRecordUnit, EmerAPIServerTasksUnit, LMessages, ComCtrls, Buttons, StdCtrls,
  Spin, EmerAPIBlockchainUnit, fpjson, jsonparser, SynEmerNVS;

type

  { TNameViewForm }

  TNameViewForm = class(TForm)
    bShowHistory: TBitBtn;
    BitBtn1: TBitBtn;
    bAtom: TBitBtn;
    bUpdateName: TBitBtn;
    eName: TLabeledEdit;
    eOwner: TLabeledEdit;
    lCost: TLabel;
    lDaysAdded: TLabel;
    lOwnerWarning: TLabel;
    lDaysLeft: TLabel;
    lInfo: TLabel;
    PageControl: TPageControl;
    Panel1: TPanel;
    pBottom: TPanel;
    pTop: TPanel;
    seDaysLeft: TSpinEdit;
    SuicideTimer: TTimer;
    seValue: TSynEdit;
    SynAnySyn1: TSynAnySyn;
    tsState: TTabSheet;
    tsRaw: TTabSheet;
    tsDecoded: TTabSheet;
    procedure bAtomClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure bShowHistoryClick(Sender: TObject);
    procedure bUpdateNameClick(Sender: TObject);
    procedure eOwnerChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure seValueChange(Sender: TObject);
    procedure SuicideTimerTimer(Sender: TObject);
    procedure updateControls(sender:tObject);
    procedure nvsSent(Sender: TObject);
    procedure nvsError(Sender: TObject);
  private
    SynEmerNVSSyn:tSynEmerNVSSyn;
    procedure updateView(sender:tObject);
    procedure myQueryDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
  public
    NVSRecord:tNVSRecord;
    BaseEmerAPIServerTask:tBaseEmerAPIServerTask;
    FreeOnClose:boolean;

  end;

var
  //NameViewForm: TNameViewForm;
  NameViewFormList:tStringList;


function ShowNameViewForm(NVSRecord:tNVSRecord; freeNVSRecordOnClose:boolean=false):TNameViewForm; overload;
function ShowNameViewForm(name:ansistring):TNameViewForm; overload;
function ShowNameViewForm(BaseEmerAPIServerTask:tBaseEmerAPIServerTask):TNameViewForm; overload;

implementation

{$R *.lfm}
uses MainUnit, Localizzzeunit, emerapitypes, crypto, EmerTX, helperUnit, math, AtomFormUnit, QuestionUnit;

var LastActivatedNameViewForm:TNameViewForm=nil;

procedure setFormPosition(NameViewForm:tNameViewForm);
 function found:boolean;
 var i:integer;
 begin
   result:=true;
   for i:=0 to NameViewFormList.Count-1 do
     if NameViewFormList.Objects[i]<>NameViewForm then
        if (
           abs(tNameViewForm(NameViewFormList.Objects[i]).Top-NameViewForm.Top)
           +
           abs(tNameViewForm(NameViewFormList.Objects[i]).Left-NameViewForm.Left)
           )<5 then exit;

   result:=false;
 end;

begin
  if LastActivatedNameViewForm<>nil then begin
    NameViewForm.Top:=LastActivatedNameViewForm.Top;
    NameViewForm.Left:=LastActivatedNameViewForm.Left+LastActivatedNameViewForm.Width;
    NameViewForm.Height:=LastActivatedNameViewForm.Height;
    NameViewForm.Width:=LastActivatedNameViewForm.Width;

    if NameViewForm.Left>(screen.Width - NameViewForm.Width) then begin
     NameViewForm.Top:=LastActivatedNameViewForm.Top+LastActivatedNameViewForm.Height+24;
     NameViewForm.Left:=0;//LastActivatedNameViewForm.left;
    end
  end else begin
    if screen.ActiveForm<>nil then begin
      NameViewForm.Top:=0;//screen.ActiveForm.Top+20;
      NameViewForm.Left:=0;//=screen.ActiveForm.Left+20;
    end;
  end;

  while found do begin
    NameViewForm.Top:=NameViewForm.Top+20;
    NameViewForm.Left:=NameViewForm.Left+20;
  end;


  if (NameViewForm.Top>(screen.Height - NameViewForm.Height)) then
    NameViewForm.Top:=(screen.Height - NameViewForm.Height);
  if (NameViewForm.Top<0) then  NameViewForm.Top:=0;

  if (NameViewForm.Left>(screen.Width - NameViewForm.Width)) then NameViewForm.Left:=(screen.Width - NameViewForm.Width);
  if (NameViewForm.Left<0) then NameViewForm.Left:=0;


end;

function ShowNameViewForm(BaseEmerAPIServerTask:tBaseEmerAPIServerTask):TNameViewForm;
var  i:integer;
     NameViewForm: TNameViewForm;
begin
  if BaseEmerAPIServerTask=nil then exit;
  i:=NameViewFormList.IndexOf(BaseEmerAPIServerTask.NVSName);
  if i>=0 then begin
     if not TNameViewForm(NameViewFormList.Objects[i]).Visible
        then TNameViewForm(NameViewFormList.Objects[i]).Show;
     TNameViewForm(NameViewFormList.Objects[i]).BringToFront;
     result:=TNameViewForm(NameViewFormList.Objects[i]);
     exit;
  end;

  Application.CreateForm(TNameViewForm, NameViewForm);
  NameViewFormList.AddObject(BaseEmerAPIServerTask.NVSName,NameViewForm);
  NameViewForm.BaseEmerAPIServerTask:=BaseEmerAPIServerTask;

  if BaseEmerAPIServerTask.TaskType='NEW_NAME' then
    NameViewForm.Caption:=localizzzeString('NameViewForm.Caption.TaskNewName','Create asset: ') + BaseEmerAPIServerTask.NVSName
  else
    NameViewForm.Caption:=BaseEmerAPIServerTask.NVSName;

  setFormPosition(NameViewForm);

  NameViewForm.Show;
  result:=NameViewForm;

end;

function ShowNameViewForm(NVSRecord:tNVSRecord; freeNVSRecordOnClose:boolean=false):TNameViewForm; overload;
var  i:integer;
     NameViewForm: TNameViewForm;
begin
  if NVSRecord=nil then exit;
  i:=NameViewFormList.IndexOf(NVSRecord.NVSName);
  if i>=0 then begin
     if not TNameViewForm(NameViewFormList.Objects[i]).Visible
        then TNameViewForm(NameViewFormList.Objects[i]).Show;
     TNameViewForm(NameViewFormList.Objects[i]).BringToFront;
     result:=TNameViewForm(NameViewFormList.Objects[i]);
     if freeNVSRecordOnClose then
       freeAndNil(NVSRecord)
     else
       NVSRecord.removeNotify(EmerAPINotification(@(result.updateView),'',true));
     exit;
  end;

  Application.CreateForm(TNameViewForm, NameViewForm);
  NameViewFormList.AddObject(NVSRecord.NVSName,NameViewForm);
  NameViewForm.Caption:=NVSRecord.NVSName;


  NameViewForm.NVSRecord:=NVSRecord;

  NVSRecord.addNotify(EmerAPINotification(@(NameViewForm.updateView),'update',true));

  if not NVSRecord.isLoaded then
    NVSRecord.readFromBlockchain;

  setFormPosition(NameViewForm);

  NameViewForm.Show;
  result:=NameViewForm;

end;

function ShowNameViewForm(name:ansistring):TNameViewForm;
var NVSRecord:tNVSRecord;
    i:integer;
begin
  //create
  i:=NameViewFormList.IndexOf(name);
  if i>=0 then begin
     if not TNameViewForm(NameViewFormList.Objects[i]).Visible
        then TNameViewForm(NameViewFormList.Objects[i]).Show;
     TNameViewForm(NameViewFormList.Objects[i]).BringToFront;
     exit;
  end;

  NVSRecord:=tNVSRecord.create(emerAPI,name,true);
  result:=ShowNameViewForm(NVSRecord,true);
end;




{ TNameViewForm }
procedure TNameViewForm.updateControls(sender:tObject);
var iAmOwner:boolean;
    dchanged:boolean;
    c:qword;
begin
  dchanged:=false;
  iAmOwner:=false;
  try
    c:=0;
    if NVSRecord<>nil then begin
       iAmOwner:=EmerAPI.addresses.IndexOf(buf2Base58Check(mainForm.globals.AddressSig+NVSRecord.ownerAddress))>=0;
       //if not iAmOwner then exit;

       dchanged:=dchanged or (eOwner.Text<>buf2Base58Check(mainForm.globals.AddressSig+NVSRecord.ownerAddress));
       lOwnerWarning.Visible:=dchanged;

       dchanged:=dchanged or (seDaysLeft.Value<>NVSRecord.DaysLeft);

       lDaysAdded.visible:=(seDaysLeft.Value<>NVSRecord.DaysLeft);
       if lDaysAdded.visible then
         lDaysAdded.caption:= localizzzeString('NameViewForm.lDaysAdded','Days added: ') + inttostr(seDaysLeft.Value-NVSRecord.DaysLeft);
       //!seValue.MarkTextAsSaved;

       c:=EmerAPI.blockChain.getNameOpFee(max(0,seDaysLeft.Value-NVSRecord.DaysLeft),opNum('OP_NAME_UPDATE'),length(eName.Text)+length(seValue.Text));

    end else if BaseEmerAPIServerTask<>nil then begin
       //iAmOwner:=EmerAPI.addresses.IndexOf(buf2Base58Check(mainForm.globals.AddressSig+BaseEmerAPIServerTask.ownerAddress))>=0;
       //if not iAmOwner then exit;

       dchanged:=dchanged or (eOwner.Text<>buf2Base58Check(mainForm.globals.AddressSig+addressto20(BaseEmerAPIServerTask.ownerAddress)));
       lOwnerWarning.Visible:=dchanged;

       dchanged:=true; iAmOwner:=true; //any time can create the task!

       lDaysAdded.visible:=false;

    end;

    dchanged:=dchanged or seValue.Modified;

  finally
    eOwner.ReadOnly:=not iAmOwner;
    if iAmOwner
      then eOwner.color:=clDefault
      else eOwner.color:=clBtnFace;
    bUpdateName.Enabled:=(iAmOwner and dchanged) and (seValue.Text<>'') and (length(seValue.Text)<=20480) {and ((NVSRecord=nil) or (NVSRecord.DaysLeft>0)){}};
    seDaysLeft.Enabled:=iAmOwner;

    if bUpdateName.Enabled and (c>0) then
       lCost.caption := 'Update cost: '#10+myFloatToStr(c/1000000)+' EMC ('+inttostr(c div 100)+' subcents)'
    else lCost.caption := '';

  end;

  if (pos(':',eName.Text)>0) then begin
    setSynHighliterByName(SynEmerNVSSyn,eName.Text);
    seValue.Highlighter:=SynEmerNVSSyn;
  end
  else
    seValue.Highlighter:=nil;

end;

procedure TNameViewForm.updateView(sender:tObject);
begin
  //info updated
  if NVSRecord<>nil then begin
    eName.Text:=NVSRecord.NVSName;
    seValue.Text:=NVSRecord.NVSValue;



    if EmerAPI.addresses.IndexOf(buf2Base58Check(mainForm.globals.AddressSig+NVSRecord.ownerAddress))>=0 then
      lInfo.Caption:=localizzzeString('NameViewForm.lInfo.myNVS','NVS asset (owned by you):')
    else
      lInfo.Caption:=localizzzeString('NameViewForm.lInfo.NVS','NVS asset (owned by other):');

    if (NVSRecord.DaysLeft<1) then begin
       lInfo.Caption:= localizzzeString('NameViewForm.lInfo.Expired','NAME EXPIRED: ') + lInfo.Caption;
       lInfo.Font.Color:=clRed;
    end else lInfo.Font.Color:=clDefault;


    eOwner.Text:=buf2Base58Check(mainForm.globals.AddressSig+NVSRecord.ownerAddress);

    seDaysLeft.Value:=NVSRecord.DaysLeft;
    seDaysLeft.MinValue:=seDaysLeft.Value;
  end else if BaseEmerAPIServerTask<>nil then begin
     eName.Text:=BaseEmerAPIServerTask.NVSName;
     seValue.Text:=BaseEmerAPIServerTask.NVSValue;

     if EmerAPI.addresses.IndexOf(buf2Base58Check(mainForm.globals.AddressSig+addressto20(BaseEmerAPIServerTask.ownerAddress)))>=0 then
       lInfo.Caption:=localizzzeString('NameViewForm.lInfo.myTask','Task for create an asset (owned by you):')
     else
       lInfo.Caption:=localizzzeString('NameViewForm.lInfo.myTask','Task for create an asset (owned by other(s)):');

     if (BaseEmerAPIServerTask.ownerAddress<>'') and (BaseEmerAPIServerTask.ownerAddress<>'undefined') then
       eOwner.Text:=buf2Base58Check(mainForm.globals.AddressSig+addressto20(BaseEmerAPIServerTask.ownerAddress))
     else
       eOwner.Text:=mainForm.eAddress.text{+localizzzeString('NameViewForm.eOwner.myTask',' (your address)')};

     seDaysLeft.Value:=BaseEmerAPIServerTask.NVSDays;
     seDaysLeft.MinValue:=0;
  end;
  tsDecoded.Visible:=false;
  //PageControl.ShowTabs:=tsDecoded.Visible;

  updateControls(sender);
end;

procedure TNameViewForm.eOwnerChange(Sender: TObject);
begin

end;

procedure TNameViewForm.BitBtn1Click(Sender: TObject);
begin
  Close;
end;

procedure TNameViewForm.myQueryDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
var s:string;
    e:tJsonData;
begin
  s:='';

  if sender=nil then s:='INTERNAL ERROR'
  else
    if ('name_history:'+eName.Text)=sender.id
    then
    if result=nil then begin
         s:='ERROR: '+sender.lastError;
      end else begin
         //e:=result.FindPath('data.callwalletfunction.answer.result');
         e:=result.FindPath('result');
         if e<>nil then begin
            s:=e.FormatJSON;
         end else s:='ERROR: "result" field not found ';
       //s:=result.AsJSON;
    end
  else s:='';


  if s<>'' then begin
    AskQuestionInit();
    QuestionForm.bOk.Visible:=true;

    QuestionForm.Caption:=eName.Text;
    //QuestionForm.bHelp.Visible:=true;
    //QuestionForm.cLanguage.Visible:=true;

    AskQuestion(s);
  end;

end;

procedure TNameViewForm.bShowHistoryClick(Sender: TObject);
begin
  emerAPI.EmerAPIConnetor.sendWalletQueryAsync('name_history',getJSON('{name:"'+eName.Text+'"}'),@myQueryDone,'name_history:'+eName.Text);
end;

procedure TNameViewForm.bAtomClick(Sender: TObject);
begin
  if NVSRecord<>nil then ShowAtomForm(NVSRecord.NVSName);
end;

procedure TNameViewForm.nvsSent(Sender: TObject);
begin
  seValue.MarkTextAsSaved;
  updateControls(sender);
  showMessageSafe(localizzzeString('NameViewForm.msgSendToBC','Your Changes have been sent to blockchain'));
  MainForm.removeNameAndUpdate(NVSRecord.NVSName);
  close;
end;

procedure TNameViewForm.nvsError(Sender: TObject);
begin
  if Sender is tNVSRecord then
    showMessageSafe(
     localizzzeString('NameViewForm.msgNVSUpdateError','NVS record update error: ')
    +(Sender as tNVSRecord).LastError+'');
end;


procedure TNameViewForm.bUpdateNameClick(Sender: TObject);
var ow:ansistring;
begin
  if NVSRecord<>nil then begin

     NVSRecord.newOwner:='';
     if eOwner.Text<>buf2Base58Check(mainForm.globals.AddressSig+NVSRecord.ownerAddress) then begin
       try
         ow:=Base58toBufCheck(eOwner.Text);
       except
         showMessageSafe(localizzzeString('NameViewForm.msgWrongAddress','New owner address is wrong'));
         exit;
       end;

       if ow='' then exit;
       if ow[1]<>mainForm.globals.AddressSig then begin
         showMessageSafe(localizzzeString('NameViewForm.msgWrongAddressSig','New owner address is belong to another network'));
         exit;
       end;
       delete(ow,1,1);

       NVSRecord.newOwner:=ow;
     end;



     NVSRecord.DaysAdd:=max(0,seDaysLeft.Value-NVSRecord.DaysLeft);

     if seValue.Modified then
       NVSRecord.newValue:=clear13(seValue.Text)
     else
       NVSRecord.newValue:='';

     NVSRecord.addNotify(EmerAPINotification(@nvsSent,'sent',true));
     NVSRecord.addNotify(EmerAPINotification(@nvsError,'error',true));

     NVSRecord.saveToBlockchain();

  end else if BaseEmerAPIServerTask<>nil then begin
     //TODO:сделать
  end;
end;

procedure TNameViewForm.FormActivate(Sender: TObject);
begin
  LastActivatedNameViewForm:=self;
end;


procedure TNameViewForm.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  SuicideTimer.Enabled:=true;
end;

procedure TNameViewForm.FormCreate(Sender: TObject);
begin

if SynEmerNVSSyn=nil then SynEmerNVSSyn:=tSynEmerNVSSyn.Create(self);
end;

procedure TNameViewForm.FormDestroy(Sender: TObject);
begin
  if LastActivatedNameViewForm=self then
    LastActivatedNameViewForm:=nil;

  if SynEmerNVSSyn<>nil then
    freeandnil(SynEmerNVSSyn);
end;


procedure TNameViewForm.FormShow(Sender: TObject);
begin
  localizzze(self);
  updateView(Sender);
end;

procedure TNameViewForm.seValueChange(Sender: TObject);
begin
  updateControls(Sender);
end;

procedure TNameViewForm.SuicideTimerTimer(Sender: TObject);
var i:integer;
begin
   SuicideTimer.Enabled:=false;
   for i:=0 to NameViewFormList.Count-1 do
     if NameViewFormList.Objects[i]=self then begin
        NameViewFormList.Delete(i);
        break;
     end;
   if NVSRecord<>nil then
     if freeOnClose then
       freeAndNil(NVSRecord)
     else try
       if NVSRecord<>nil then
         NVSRecord.removeNotify(EmerAPINotification(@updateView,'',true));
     except
     end;

   free;
end;

//var i:integer;

INITIALIZATION
 NameViewFormList:=tStringList.Create;
 NameViewFormList.CaseSensitive:=true;

FINALIZATION
//  for i:=0 to NameViewFormList.Count-1 do
//    TNameViewForm(NameViewFormList.Objects[i]).Free;
  NameViewFormList.Free;
end.

