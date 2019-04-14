unit FrameServerTaskUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, StdCtrls, Buttons
  ,EmerAPIServerTasksUnit;

type

  { TFrameServerTask }

  TFrameServerTask = class(TFrame)
    bDelete: TBitBtn;
    bExecute: TBitBtn;
    bDetails: TBitBtn;
    chDebug: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    eTotalNames: TEdit;
    eTotalCost: TEdit;
    eTotalOwners: TEdit;
    eOwnedCount: TEdit;
    ilAdvCon: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    lOwnedCount: TLabel;
    lTotalNames: TLabel;
    lTotalCost: TLabel;
    lTotalOwners: TLabel;
    meComment: TMemo;
    pAdvanced: TPanel;
    pStat: TPanel;
    pName: TPanel;
    pButtons: TPanel;
    pTitle: TPanel;
    sbAdvCon: TSpeedButton;
    sbClose: TSpeedButton;
    sbHelp: TSpeedButton;
    sbDelete: TSpeedButton;
    sbExecute: TSpeedButton;
    sbDetails: TSpeedButton;
    sbTasks: TScrollBox;
    Splitter1: TSplitter;
    procedure sbAdvConClick(Sender: TObject);
    procedure sbCloseClick(Sender: TObject);
    procedure sbDeleteClick(Sender: TObject);
    procedure sbDetailsClick(Sender: TObject);
    procedure sbExecuteClick(Sender: TObject);
  private

    fTaskDefColorText:ansistring;
  public
    Advanced:boolean;
    EmerAPIServerTaskGroup:tEmerAPIServerTaskGroup;
    titleFullText:string;
    procedure taskExecuted(Sender: TObject);
    procedure setAdvanced(newAdvanced:boolean);
    procedure TasksUpdated(sender: tObject);
    function init(mEmerAPIServerTaskGroup:tBaseEmerAPIServerTask):integer;
    procedure refreshView(Sender: TObject);
    procedure showAdvancedInfo;
    procedure down;
  end;

implementation

uses localizzzeunit, MainUnit, HelperUnit, Math, NameViewUnit, emerapitypes, SettingsUnit;

{$R *.lfm}

procedure TFrameServerTask.sbCloseClick(Sender: TObject);
begin
  //hide. Hide the frame for next program start.
  visible:=false;
end;

procedure TFrameServerTask.setAdvanced(newAdvanced:boolean);
var h,th:integer;
begin

  if EmerAPIServerTaskGroup=nil then exit;

  if Advanced
  then
    meComment.Visible:=trim(EmerAPIServerTaskGroup.Comment)<>''
  else
    meComment.Visible:=false;

  if Advanced=newAdvanced then exit;
  Advanced:=newAdvanced;

  pName.Visible:=false;
  pButtons.Visible:=Advanced;
  pStat.Visible:=Advanced;

  sbTasks.Visible:=Advanced;
  Splitter1.Visible:=sbTasks.Visible and meComment.Visible;

  pAdvanced.Visible:=sbTasks.Visible or meComment.Visible;

  if Splitter1.Visible then Splitter1.Top:=meComment.Height+1;

  h:=pTitle.Height;

  if pName.Visible then h:=h+pName.Height;

  if pButtons.Visible then h:=h+pButtons.Height;

  if pStat.Visible then h:=h+pStat.Height;

  th:=0;
  if sbTasks.Visible then
     th:=min(28*7+10,EmerAPIServerTaskGroup.Count*28);
  if Splitter1.Visible then th:=th+Splitter1.Height;
  if meComment.Visible then th:=th+meComment.Height;
  //pAdvanced.Height:=th;

  if pAdvanced.Visible then h:=h+th{pAdvanced.Height};

  height:=h;


  if Advanced
    then ilAdvCon.GetBitmap(1,sbAdvCon.Glyph)
    else ilAdvCon.GetBitmap(0,sbAdvCon.Glyph);

  if advanced then showAdvancedInfo;
end;

procedure TFrameServerTask.sbAdvConClick(Sender: TObject);
begin
  setAdvanced(not Advanced);
end;


procedure TFrameServerTask.sbDeleteClick(Sender: TObject);
begin
  //cancel the task
  raise exception.Create('Not implemented');
end;

procedure TFrameServerTask.sbDetailsClick(Sender: TObject);
begin
  ShowNameViewForm(EmerAPIServerTaskGroup);
end;

procedure TFrameServerTask.taskExecuted(Sender: TObject);
begin
  if not (Sender is tEmerAPIServerTaskGroup) then exit;
  if (Sender as tEmerAPIServerTaskGroup).Executed
    then
      if (Sender as tEmerAPIServerTaskGroup).Successful
        then visible:=false
        else begin pTitle.Color:=getNameColor(ansiuppercase('executionFailed')); pTitle.Hint:= (Sender as tEmerAPIServerTaskGroup).LastError; pTitle.ShowHint:=true;  end
    else begin pTitle.Color:=getNameColor(ansiuppercase('executionFailed')); pTitle.Hint:= (Sender as tEmerAPIServerTaskGroup).LastError; pTitle.ShowHint:=true; end;


end;

procedure TFrameServerTask.sbExecuteClick(Sender: TObject);
begin
  //execute
  EmerAPIServerTaskGroup.ShowInTXVieverDontCreate:=Settings.getValue('Dev_Mode_ON') and chDebug.checked;

  EmerAPIServerTaskGroup.execute(@taskExecuted);
  pTitle.Color:=getNameColor(ansiuppercase('execution'));
end;

procedure TFrameServerTask.refreshView(Sender: TObject);
{
function adjustName(s:string):string;
var n:integer;
begin
  result:=s;
  if pTitle.Canvas.TextWidth(result)>(pTitle.Width-(sbDetails.Width*6+3)) then begin
    while (length(result)>5) and (pTitle.Canvas.TextWidth(result+'..')>(pTitle.Width-(sbDetails.Width*4+3))) do
    begin
     n:=(pTitle.Canvas.TextWidth(result+'..') - (pTitle.Width-(sbDetails.Width*6+3))) div pTitle.Canvas.TextWidth('I');
     if n<1 then n:=1;
     delete(result,length(result)-n+1,n)
    end;
    result:=result + '..';
  end;
end;}
function adjustName(s:string):string;
var n:integer;
    const bcount=6;
begin
  result:=s;
  if pTitle.Canvas.TextWidth(result)>(pTitle.Width-(sbDetails.Width*bcount+7)) then begin
    while (length(result)>5) and (pTitle.Canvas.TextWidth(result+'..')>(pTitle.Width-(sbDetails.Width*bcount+7))) do
    begin
     n:=(pTitle.Canvas.TextWidth(result+'..') - (pTitle.Width-(sbDetails.Width*4+3))) div pTitle.Canvas.TextWidth('W');
     if n<1 then n:=1;
     if n>length(result) then n:=length(result)-5;
     delete(result,length(result)-n+1,n)
    end;
    result:=result + '..';
  end;
end;

begin
  pTitle.Caption:=adjustName(titleFullText);

  chDebug.Visible:=Settings.getValue('Dev_Mode_ON');

  sbExecute.Enabled:=false;
  case EmerAPIServerTaskGroup.getValid of
    eptvUnknown:pTitle.Color:=getNameColor('TASK_VALID_UNKNOWN');
    eptvValid:begin pTitle.Color:=getNameColor(fTaskDefColorText); sbExecute.Enabled:=true; end;
    eptvInvalid:pTitle.Color:=getNameColor('TASK_INVALID');
    eptvPart:begin pTitle.Color:=getNameColor('TASK_PARTIAL_VALID'); sbExecute.Enabled:=true; end;
  end;

  if EmerAPIServerTaskGroup.getValid<>eptvValid
     then begin pTitle.Hint:=EmerAPIServerTaskGroup.LastError; pTitle.ShowHint:=true; end
     else begin pTitle.Hint:=''; pTitle.ShowHint:=false; end;


end;


procedure TFrameServerTask.TasksUpdated(sender: tObject);
begin
  refreshView(sender);
end;

function TFrameServerTask.init(mEmerAPIServerTaskGroup:tBaseEmerAPIServerTask):integer;
var s:string;
    oaddrc58:ansistring;
    i,h,j:integer;
    transferTotal:dword;
    addlist:tStringList;

    function analize(s:ansistring):string;
    begin
      result:='';
      if pos('af:',s)=1 then begin
        result:=s; //!!!
        delete(s,1,3);

         //result:=localizzzeString(uppercase('TFrameServerTask.Create_Unknown_Name'),'Name: ') + s;
      end else
      if pos('dpo:',s)=1 then begin
        delete(s,1,4);
        result:=localizzzeString(uppercase('TFrameServerTask.Create_DPO_record'),'DPO record: ') + s;
      end else
        result:=localizzzeString(uppercase('TFrameServerTask.Create_Unknown_Name'),'Name: ') + s;

    end;

begin
  if not (mEmerAPIServerTaskGroup is tEmerAPIServerTaskGroup) then raise exception.Create('TFrameServerTask.init: argument must be a tEmerAPIServerTaskGroup object');


  EmerAPIServerTaskGroup:=tEmerAPIServerTaskGroup(mEmerAPIServerTaskGroup);

  if (EmerAPIServerTaskGroup<>nil) and (EmerAPIServerTaskGroup.getTasks<>nil)
    then EmerAPIServerTaskGroup.getTasks.addNotify(EmerAPINotification(@TasksUpdated,'taskUpdated',true));

  //PAY - платежная
  //NEW_NAME - новое имя
  //UPDATE_NAME - апдейт существующего
  //TRANSFER_NAME - передача имени
  //DELETE_NAME - удаление имени
  //PROLONG_NAME - продлить аренду имени


  //1. Тип
  //2. Каммент
//    Comment:string;  //comment: String
//    id:ansistring; //id: ID
//    NVSName:ansistring; //name: String
//    NVSValue:ansistring; //value
//    amount:dword;   //amount: Float
//    ownerAddress:ansistring; //address
//    time:dword;
//    LockTime:dword;

  localizzze(self);
  chDebug.Checked:=false;

  addlist:=tStringList.Create;

  try
    oaddrc58:=trim(EmerAPIServerTaskGroup.ownerAddress); //received code58 address. '' if different
    if oaddrc58<>'' then addlist.Append(oaddrc58);
    if oaddrc58='' then
       for i:=0 to EmerAPIServerTaskGroup.Count-1 do
         if addlist.IndexOf(EmerAPIServerTaskGroup[i].ownerAddress)<0 then
            addlist.append(EmerAPIServerTaskGroup[i].ownerAddress);

    if addlist.Count>1 then oaddrc58:=''
    else if addlist.Count=1 then oaddrc58:=addlist[0];

    fTaskDefColorText:=ansiuppercase(EmerAPIServerTaskGroup.TaskType);
    //pTitle.Color:=fTaskDefColor;

    if ansiuppercase(EmerAPIServerTaskGroup.TaskType)='PAY' then begin
       transferTotal:=0;
       for i:=0 to EmerAPIServerTaskGroup.Count-1 do
          transferTotal:=transferTotal + EmerAPIServerTaskGroup[i].amount;

       //address if not me; receiver if one; count overwise
       //Total amount

       label1.Visible:=true;
       label2.Visible:=true;
       Edit1.Visible:=true;
       Edit2.Visible:=true;

       //PAY TO <MYSELF>/<ADDRESS>
       if oaddrc58='' then
          s:=inttostr(addlist.Count)+localizzzeString(uppercase('TFrameServerTask.PAY_TO_MULTI'),' addresses')
       else
       if isMyAddress(oaddrc58) then begin
          s:=localizzzeString(uppercase('TFrameServerTask.PAY_TO_MYSELF'),' myself');
          fTaskDefColorText:='PAY_TO_MYSELF';
       end
       else
         s:=oaddrc58;

       titleFullText:=localizzzeString(uppercase('TFrameServerTask.PAY'),'PAY TO: ')+s;
//       pTaskType.Caption:=!titleFullText;

       label1.Caption:=localizzzeString(uppercase('TFrameServerTask.PAY_TO_label1'),' Pay ');
       label2.Caption:=localizzzeString(uppercase('TFrameServerTask.PAY_TO_label2'),' EMC to ');
       edit1.Text:=myFloatToStr(transferTotal/1000000);
       edit2.Text:=s;
       edit1.Width:=60;
       edit1.Align:=alLeft;

       edit2.Width:=60;
       edit2.Align:=alClient;
    end else
    if ansiuppercase(EmerAPIServerTaskGroup.TaskType)='NEW_NAME' then begin
      //show name only if we have one name, overwise count
      // create XXX name{s} <if 1 name: show>
      s:='';
      if EmerAPIServerTaskGroup.Count>0
        then s:=EmerAPIServerTaskGroup[0].NVSName;
      for i:=1 to EmerAPIServerTaskGroup.Count-1 do begin
        //looking for the same-beginning line
        setLength(s,min(length(s),length(EmerAPIServerTaskGroup[i].NVSName)));
        for j:=1 to length(s) do
           if s[j]<>EmerAPIServerTaskGroup[i].NVSName[j] then begin
             setLength(s,j-1);
             break;
           end;
      end;

      if (EmerAPIServerTaskGroup.Count<1) then
          s:=localizzzeString(uppercase('TFrameServerTask.EmptyGroup'),' *ERROR: Empty task''s group* ')
      else
      if s='' then s:=localizzzeString(uppercase('TFrameServerTask.Name_different'),' *completely different* ')
              else if (EmerAPIServerTaskGroup.Count>1) then s:=s+'...';

      if EmerAPIServerTaskGroup.Count>1 then
        titleFullText:=localizzzeString(uppercase('TFrameServerTask.OP_NAMENEW_1'),'Create ')+
                         inttostr(EmerAPIServerTaskGroup.Count)+
                         localizzzeString(uppercase('TFrameServerTask.OP_NAMENEW_2'),' name(s); template: ')+
                         analize(s)
      else
        titleFullText:=localizzzeString(uppercase('TFrameServerTask.OP_NAMENEW_ONE'),'Create: ')+
                       analize(s)
      ;
      //pTaskType.Caption:=!titleFullText;
       pName.Visible:=false;
    end;



    advanced:=false;

    meComment.Text:=EmerAPIServerTaskGroup.Comment;
    meComment.Visible:=trim(meComment.Text)<>'';

    pStat.Visible:=false;

    pButtons.Visible:=false;

    h:=pTitle.Height;
    if pName.Visible then h:=h+pName.Height;

    if meComment.Visible then
       if (length(meComment.Text)<40) and (pos(#10,trim(meComment.Text))<1)
         then h:=h+16 else h:=h+33;

    if pButtons.Visible then h:=h+pButtons.Height;

    result:=h;
    //setting height

  finally
    addlist.free;
  end;
  refreshView(nil);
end;

procedure TFrameServerTask.showAdvancedInfo;
begin
  if not advanced then exit;

  if EmerAPIServerTaskGroup=nil then exit;


  eTotalNames.text:=inttostr(EmerAPIServerTaskGroup.count);
  eTotalOwners.text:=inttostr(EmerAPIServerTaskGroup.getUniOwnerCount);
  eTotalCost.text:=myfloattostr(EmerAPIServerTaskGroup.getCost/1000000);
  eOwnedCount.text:=inttostr(EmerAPIServerTaskGroup.getOwnerByCount()+ EmerAPIServerTaskGroup.getOwnerByCount(MainForm.eAddress.Text));
end;


procedure TFrameServerTask.down;
begin
  if (EmerAPIServerTaskGroup<>nil) and (EmerAPIServerTaskGroup.getTasks<>nil)
    then EmerAPIServerTaskGroup.getTasks.removeNotify(EmerAPINotification(@TasksUpdated,'taskUpdated',true));
      //EmerAPIServerTaskGroup.getTasks.addNotify(EmerAPINotification(@TasksUpdated,'taskUpdated',true));

end;


end.

