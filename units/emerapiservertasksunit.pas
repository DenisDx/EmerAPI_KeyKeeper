unit EmerAPIServerTasksUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, EmerAPIMain, emerapitypes, EmerAPIBlockchainUnit, fpjson;

type
tEmerAPIServerTaskList=class;

tBaseEmerAPIServerTask=class(tObject)
  protected
    fEmerAPI:tEmerAPI;
    fExecuted:boolean; //sent to BC. Will be removed by parent
    fExecutionDatetime:tDatetime;
    fOwner:tEmerAPIServerTaskList;
    function execute:boolean; virtual; abstract;
    function getExecuted:boolean; virtual; abstract; //for task: it was send. for group: all the tasks were sent
  public
    fUpdated:boolean; //set true on data loaded. One time.

    userObj1:tObject;
    Comment:string;  //comment: String
    id:ansistring; //id: ID
    NVSName:ansistring; //name: String
    NVSValue:ansistring; //value
    NVSDays:qword;
    amount:qword;   //amount: Float
    ownerAddress:ansistring; //address
    time:dword;
    LockTime:dword;
    //  dpo: String
    //  time: Int
    TaskType: String; //type

    //
    function getDescription:string;  virtual; abstract;
    function fIsKnownName:boolean; virtual; abstract; //рекурсивно вызывает всех детей, если есть. Возвращает типировано ли имя
    function getTitle:string;  virtual; abstract;
    function getNameType:ansistring; virtual; abstract;//Возвращает имя с сигнатурой, например 'dns' или 'af:brand'

    //  group: ссылка на группу, при запросе можно получать поля, например id
    property Executed:boolean read getExecuted;
    constructor create(mOwner:tEmerAPIServerTaskList);
end;

tEmerAPIServerTask=class(tBaseEmerAPIServerTask)
 private
   procedure onAsyncQueryDoneHandler(sender:TEmerAPIBlockchainThread;result:tJsonData);
 public
   function execute:boolean; override;
   function getExecuted:boolean; override;
end;

tEmerAPIServerTaskGroup=class(tBaseEmerAPIServerTask)
 private
  function getCount:integer;
  function getItem(Index: integer):tBaseEmerAPIServerTask;
 protected
   Tasks:tEmerAPIServerTaskList;
 public
   property Count:integer read getCount;
   property Items[Index: integer]:tBaseEmerAPIServerTask read getItem; default;
   function execute:boolean; override;
   function getExecuted:boolean; override;
   constructor create(mOwner:tEmerAPIServerTaskList);
   destructor destroy;
end;

//update
//error
//newtask
//taskremoved
tEmerAPIServerTaskList=class(tEmerApiNotified)
private
  fOwnerTask:tBaseEmerAPIServerTask;
  fEmerAPI:tEmerAPI;
  fLastUpdateTime:tDatetime;
  fItems:tList;
  function getItem(Index: integer):tBaseEmerAPIServerTask;
  function getCount:integer;
  procedure clearList;
  procedure onAsyncQueryDoneHandler(sender:TEmerAPIBlockchainThread;result:tJsonData);
  procedure myUpdate(sender:tObject);
  procedure myError(sender:tObject);
  procedure myNewTask(sender:tObject);
  procedure myTaskRemoved(sender:tObject);
public
  property Count:integer read getCount;
  property Items[Index: integer]:tBaseEmerAPIServerTask read getItem; default;
  procedure delete(Index: integer);
  procedure updateFromServer(groupID:ansistring='');
  constructor create(mEmerAPI:tEmerAPI);
  destructor destroy;
end;


implementation

uses HelperUnit;

{tBaseEmerAPIServerTask}
constructor tBaseEmerAPIServerTask.create(mOwner:tEmerAPIServerTaskList);
begin
 inherited create;
 fOwner:=mOwner;
end;


{tEmerAPIServerTask}
function tEmerAPIServerTask.execute:boolean;
begin

end;

function tEmerAPIServerTask.getExecuted:boolean;
begin
 result:=fExecuted;
end;

procedure tEmerAPIServerTask.onAsyncQueryDoneHandler(sender:TEmerAPIBlockchainThread;result:tJsonData);
begin
  //set fExecuted!
end;

{tEmerAPIServerTaskGroup}
function tEmerAPIServerTaskGroup.getCount:integer;
begin
 result:=0;
 if Tasks=nil then exit;
 result:=Tasks.Count;
end;

function tEmerAPIServerTaskGroup.getItem(Index: integer):tBaseEmerAPIServerTask;
begin
 result:=nil;
 if Tasks=nil then exit;
 result:=Tasks[Index];
end;

function tEmerAPIServerTaskGroup.execute:boolean;
begin

end;

function tEmerAPIServerTaskGroup.getExecuted:boolean;
var i:integer;
begin
  result:=false;
  for i:=0 to Tasks.Count-1 do
    if not tBaseEmerAPIServerTask(Tasks[i]).Executed
      then exit;
  result:=true;
end;

constructor tEmerAPIServerTaskGroup.create(mOwner:tEmerAPIServerTaskList);
begin
 inherited create(mOwner);
 Tasks:=tEmerAPIServerTaskList.create(fOwner.fEmerApi);

 Tasks.fOwnerTask:=self;
 //update
//error
//newtask
//taskremoved
 Tasks.addNotify(EmerAPINotification(@(fOwner.myUpdate),'update',true));
 Tasks.addNotify(EmerAPINotification(@(fOwner.myError),'error',true));
 Tasks.addNotify(EmerAPINotification(@(fOwner.myNewTask),'newtask',true));
 Tasks.addNotify(EmerAPINotification(@(fOwner.myTaskRemoved),'taskremoved',true));

end;

destructor tEmerAPIServerTaskGroup.destroy;
begin
  Tasks.Free;
  inherited;
end;


{tEmerAPIServerTaskList}
procedure tEmerAPIServerTaskList.myUpdate(sender:tObject);
var i:integer;
begin
  //if ALL tasks are updated, call Update notify
  for i:=0 to Count-1 do
    if not Items[i].fUpdated then exit;;


  //set parent group task updated = true
  if fOwnerTask<>nil then
     fOwnerTask.fUpdated:=true;

  //call notification
  callNotify('update');

end;

procedure tEmerAPIServerTaskList.myError(sender:tObject);
begin
  callNotify('error');
end;

procedure tEmerAPIServerTaskList.myNewTask(sender:tObject);
begin
  callNotify('newtask')
end;

procedure tEmerAPIServerTaskList.myTaskRemoved(sender:tObject);
begin
 callNotify('taskremoved')
end;

procedure tEmerAPIServerTaskList.onAsyncQueryDoneHandler(sender:TEmerAPIBlockchainThread;result:tJsonData);
var js,e:tJsonData;
    ja:tJSONArray;
    s:string;
    x:double;
    i,j:integer;
    st:ansistring;

    groupID:ansistring;
    taskID:ansistring;

    task:tEmerAPIServerTask;
    group:tEmerAPIServerTaskGroup;
    q:qword;

    function safeString(e:tJsonData):string;
    begin
     if e<>nil then
        if e.IsNull
         then result:=''
         else result:=e.asString
     else result:='';
    end;


begin
  if result=nil then begin
   fEmerAPI.EmerAPIConnetor.checkConnection();
   exit;
  end;

  js:=result;
  if pos('transactiongrouplist_',sender.id+'_')=1 then begin
    //this is a main list
   //{ "data" : { "transactiongrouplist" : [{ "address" : "address", "amount" : 1. ......
    if js<>nil then begin
     e:=js.FindPath('data.transactiongrouplist');
     if (e<>nil) and (e is tJSONArray) then begin
        ja:=tJSONArray(e);
        for i:=0 to ja.Count-1 do begin
          //group. Do we have it?
          groupID:=ja[i].FindPath('id').AsString;
          group:=nil;
          for j:=0 to Count-1 do
            if items[j] is tEmerAPIServerTaskGroup then
               if uppercase(tEmerAPIServerTaskGroup(items[j]).id) =uppercase(groupID) then begin
                  group:=tEmerAPIServerTaskGroup(items[j]);
                  break;
               end;

          if group = nil then begin
            group:=tEmerAPIServerTaskGroup.create(self);
            fItems.add(group);
            //Comment:string;  //comment: String
            group.Comment:=safeString(ja[i].FindPath('comment'));
            //id:ansistring; //id: ID
            group.id:=groupID;
            //NVSName:ansistring; //name: String
            group.NVSName:=safeString(ja[i].FindPath('name'));
            //NVSValue:ansistring; //value
            group.NVSValue:=safeString(ja[i].FindPath('value'));

            try
              q:=365;
              s:=safeString(ja[i].FindPath('days'));
              if s<>'' then q:=myStrToInt(s) else q:=365;
            except
              q:=365;
            end;
            group.NVSDays:=q;

            //amount:dword;   //amount: Float
            s:=safeString(ja[i].FindPath('amount'));
            if s<>'' then group.amount:=trunc(1000000*myStrToFloat(s))
                     else group.amount:=0;
            //ownerAddress:ansistring; //address
            group.ownerAddress:=safeString(ja[i].FindPath('address'));
            //time:dword;
            //LockTime:dword;
            //  dpo: String
            //  time: Int
            //TaskType: String; //type
            group.TaskType:=safeString(ja[i].FindPath('type'));
            //  group: ссылка на группу, при запросе можно получать поля, например id

            group.Tasks.updateFromServer(groupID);
            group.fUpdated:=false;
            callNotify('newtask');
          end;
        end;
     end;
     //fLastUpdateTimeTX:=now;
     //callNotify
     myUpdate(self);
    end;
  end else
  if pos('transactionlist_',sender.id+'_')=1 then begin
   //this is a tasks list
   //{ "data" : { "transactionlist" : [{ "address" : "address", "amount" : 1.000
   // ... , "group" : { "id" : "5bd87ebef3a6087e32ee70b6" }
   if js<>nil then begin
    e:=js.FindPath('data.transactionlist');
    if (e<>nil) and (e is tJSONArray) then begin
           ja:=tJSONArray(e);
           for i:=0 to ja.Count-1 do begin
             //Task. Do we have it?
             taskID:=ja[i].FindPath('id').AsString;
             task:=nil;
             for j:=0 to Count-1 do
               if items[j] is tEmerAPIServerTask then
                  if uppercase(tEmerAPIServerTask(items[j]).id) =uppercase(taskID) then begin
                     task:=tEmerAPIServerTask(items[j]);
                     break;
                  end;

             groupID:='';
             e:=ja[i].FindPath('group.id');
             if e<>nil then groupID:=e.AsString;

             if task = nil then begin
               task:=tEmerAPIServerTask.create(self);
               fItems.add(task);

               //Comment:string;  //comment: String
               task.Comment:=safeString(ja[i].FindPath('comment'));
               //id:ansistring; //id: ID
               //task.id:=groupID;
               //NVSName:ansistring; //name: String
               task.NVSName:=safeString(ja[i].FindPath('name'));
               //NVSValue:ansistring; //value
               task.NVSValue:=safeString(ja[i].FindPath('value'));

               try
                 q:=365;
                 s:=safeString(ja[i].FindPath('days'));
                 if s<>'' then q:=myStrToInt(s) else q:=365;
               except
                 q:=365;
               end;
               task.NVSDays:=q;

               //amount:dword;   //amount: Float
               s:=safeString(ja[i].FindPath('amount'));
               if s<>'' then task.amount:=trunc(1000000*myStrToFloat(s))
                        else task.amount:=0;
               //ownerAddress:ansistring; //address
               task.ownerAddress:=safeString(ja[i].FindPath('address'));
               //time:dword;
               //LockTime:dword;
               //  dpo: String
               //  time: Int
               //TaskType: String; //type
               task.TaskType:=safeString(ja[i].FindPath('type'));
               task.fUpdated:=true;
               callNotify('newtask');
             end;
           end;
        end;
      myUpdate(self);
   end;
  end;

  fLastUpdateTime:=now;
end;

procedure tEmerAPIServerTaskList.updateFromServer(groupID:ansistring='');
begin
  //read tasks
  if fEmerAPI=nil then raise exception.Create('tEmerAPIServerTaskList.updateFromServer: fEmerAPI=nil');



//  if fEmerAPI.EmerAPIConnetor.sendQueryAsync();
 if groupID='' then
   //this is a main list
   fEmerAPI.EmerAPIConnetor.sendQueryAsync(
     'query { transactiongrouplist {'#13#10+
     '  address'#13#10+
     '  amount'#13#10+
     '  comment'#13#10+
     '  id'#13#10+
     '  name'#13#10+
     '  time'#13#10+
     '  type'#13#10+
     '  value'#13#10+
     '}}'
    , nil  //GetJSON('{"action":"start",scanobjects:['+s+']}')
    ,@onAsyncQueryDoneHandler,'transactiongrouplist_'+fEmerAPI.EmerAPIConnetor.getNextID)
  else
    //this is a task list for a group groupID
    fEmerAPI.EmerAPIConnetor.sendQueryAsync(
    'query {transactionlist (group:"'+groupID+'") {'#13#10+
    '    address'#13#10+
    '    amount'#13#10+
    '    comment'#13#10+
//    '    dpo'#13#10+
    '    id'#13#10+
    '    name'#13#10+
    '    time'#13#10+
    '    type'#13#10+
    '    value'#13#10+
    '    group {'#13#10+
    '	    id'#13#10+
    '	  }'#13#10+
    '  }}'
   , nil  //GetJSON('{"action":"start",scanobjects:['+s+']}')
   ,@onAsyncQueryDoneHandler,'transactionlist_'+groupID+'_'+fEmerAPI.EmerAPIConnetor.getNextID)
   ;
end;

constructor tEmerAPIServerTaskList.create(mEmerAPI:tEmerAPI);
begin
 inherited create();
 fEmerAPI:=mEmerAPI;
 fItems:=tList.Create;
end;

procedure tEmerAPIServerTaskList.clearList;
var i:integer;
begin
 for i:=0 to fItems.Count-1 do
   tBaseEmerAPIServerTask(fItems[i]).Free;
 fItems.Clear;
end;

procedure tEmerAPIServerTaskList.delete(Index: integer);
begin
  if (index<0) or (index>=fItems.count) then raise exception.Create('tEmerAPIServerTaskList.delete: index out of bounds');
  tBaseEmerAPIServerTask(fItems[index]).Free;
  fItems.Delete(index);
end;

destructor tEmerAPIServerTaskList.destroy;
begin
  clearList;
  fItems.Free;
  inherited;
end;

function tEmerAPIServerTaskList.getItem(Index: integer):tBaseEmerAPIServerTask;
begin
  if (Index<0) or (Index>=Count) then raise exception.Create('tEmerAPIServerTaskList.getItem: index out of bounds');
  result:=tBaseEmerAPIServerTask(fItems[Index]);
end;

function tEmerAPIServerTaskList.getCount:integer;
begin
  result:=fItems.Count;
end;


end.

