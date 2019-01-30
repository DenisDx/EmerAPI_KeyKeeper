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
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    meComment: TMemo;
    pName: TPanel;
    pButtons: TPanel;
    pTitle: TPanel;
    sbAdvCon: TSpeedButton;
    sbClose: TSpeedButton;
    sbHelp: TSpeedButton;
    sbDelete: TSpeedButton;
    sbExecute: TSpeedButton;
    sbDetails: TSpeedButton;
    procedure sbCloseClick(Sender: TObject);
    procedure sbDeleteClick(Sender: TObject);
    procedure sbDetailsClick(Sender: TObject);
    procedure sbExecuteClick(Sender: TObject);
  private

  public
    EmerAPIServerTaskGroup:tEmerAPIServerTaskGroup;
    titleFullText:string;
    function init(mEmerAPIServerTaskGroup:tBaseEmerAPIServerTask):integer;
    procedure refreshView(Sender: TObject);
    procedure down;
  end;

implementation

uses localizzzeunit, MainUnit, HelperUnit, Math, NameViewUnit;

{$R *.lfm}

procedure TFrameServerTask.sbCloseClick(Sender: TObject);
begin
  //hide. Hide the frame for next program start.
  visible:=false;
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

procedure TFrameServerTask.sbExecuteClick(Sender: TObject);
begin
  //execute
  EmerAPIServerTaskGroup.execute;
  pTitle.Color:=getNameColor(ansiuppercase('execution'));
end;

procedure TFrameServerTask.refreshView(Sender: TObject);
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
end;
begin
pTitle.Caption:=adjustName(titleFullText);
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

    pTitle.Color:=getNameColor(ansiuppercase(EmerAPIServerTaskGroup.TaskType));

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
          pTitle.Color:=getNameColor('PAY_TO_MYSELF');
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





    meComment.Text:=EmerAPIServerTaskGroup.Comment;
    meComment.Visible:=trim(meComment.Text)<>'';


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

procedure TFrameServerTask.down;
begin

end;


end.

