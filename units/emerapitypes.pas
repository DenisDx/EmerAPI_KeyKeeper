unit emerapitypes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  DEFAULT_SEQUENCE=$FFFFFFFE;
  //TOSHI_IN_COIN=1000000;
  {
  static const CAmount COIN    = 1000000;
  static const CAmount CENT    = 10000;
  static const CAmount SUBCENT = 100;
   }
   COIN  = 1000000;
   CENT    = 10000;
   SUBCENT = 100;


type

 tpEmerAPINotification=^tEmerAPINotification;
 tEmerAPINotification=record
   proc:tNotifyEvent;
   tag:string;
   permanent:boolean; //delete after call
 end;

const
 emptyEmerAPINotification:tEmerAPINotification=(proc:nil;tag:'';permanent:false);

function EmerAPINotification(proc:tNotifyEvent;tag:string='';permanent:boolean=false):tEmerAPINotification;

type
tEmerApiNotified = class(tObject)
  private
    fNotifyList:tList;
  protected
    procedure callNotify(tag:string); virtual;
  public
    procedure addNotify(eapiNotify:tEmerAPINotification); virtual;
    procedure removeNotify(eapiNotify:tEmerAPINotification); virtual;
    constructor create;
    destructor destroy; override;
end;

implementation

constructor tEmerApiNotified.create;
begin
  fNotifyList:=tList.Create;

end;

destructor tEmerApiNotified.destroy;
var i:integer;
begin
  for i:=0 to fNotifyList.Count-1 do
     dispose(tpEmerAPINotification(fNotifyList[i]));
  fNotifyList.free;
end;

procedure tEmerApiNotified.callNotify(tag:string);
var i:integer;
begin
  i:=0;
  while i<fNotifyList.count do begin
    if
       (tpEmerAPINotification(fNotifyList[i])^.tag='')
       or
       (tpEmerAPINotification(fNotifyList[i])^.tag=tag)
    then begin
      tpEmerAPINotification(fNotifyList[i])^.proc(self);
      if tpEmerAPINotification(fNotifyList[i])^.permanent
        then inc(i)
        else begin
          dispose(tpEmerAPINotification(fNotifyList[i]));
          fNotifyList.Delete(i);
        end;

    end else  inc(i);
  end;
end;

procedure tEmerApiNotified.removeNotify(eapiNotify:tEmerAPINotification);
var i:integer;
begin
  if eapiNotify.proc=nil then exit;
  i:=0;
  while i<fNotifyList.Count do
    if
      //(tpEmerAPINotification(fNotifyList[i])^.permanent = eapiNotify.permanent)
      //and
      ((tpEmerAPINotification(fNotifyList[i])^.proc = eapiNotify.proc) or (eapiNotify.proc=nil))
      and
      ((tpEmerAPINotification(fNotifyList[i])^.tag = eapiNotify.tag) or (eapiNotify.tag=''))
      then begin
         dispose(tpEmerAPINotification(fNotifyList[i]));
         fNotifyList.Delete(i);
      end else inc(i);

end;

procedure tEmerApiNotified.addNotify(eapiNotify:tEmerAPINotification);
var i:integer;
    p:tpEmerAPINotification;
begin
  if eapiNotify.proc=nil then exit;

  for i:=0 to fNotifyList.Count-1 do
    if
      (tpEmerAPINotification(fNotifyList[i])^.permanent = eapiNotify.permanent)
      and
      (tpEmerAPINotification(fNotifyList[i])^.proc = eapiNotify.proc)
      and
      (tpEmerAPINotification(fNotifyList[i])^.tag = eapiNotify.tag)
      then exit;
  new(p);
  p^.permanent:=eapiNotify.permanent;
  p^.proc:=eapiNotify.proc;
  p^.tag:=eapiNotify.tag;
  fNotifyList.Add(p);

end;


function EmerAPINotification(proc:tNotifyEvent;tag:string='';permanent:boolean=false):tEmerAPINotification;
begin
  result.proc:=proc;
  result.tag:=tag;
  result.permanent:=permanent;
end;

end.

