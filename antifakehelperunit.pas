unit AntifakeHelperUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils
  ,NVSRecordUnit
  ,BaseTXUnit
  ;

type

  tAFRequest = class;
  tAntifakeCallback=procedure (Sender:tAFRequest) of object;
  tAFRequest = class(tObject)
    private
    public
      id:string;
  end;

function AFGetProductForObject(obj:ansistring;callback:tAntifakeCallback;id:string=''):boolean; overload;
function AFGetProductForObject(obj:tNVSRecord;callback:tAntifakeCallback;id:string=''):boolean; overload;
function AFGetBrandForObject(obj:ansistring;callback:tAntifakeCallback;id:string=''):boolean; overload;
function AFGetBrandForObject(obj:tBaseTXO;callback:tAntifakeCallback;id:string=''):boolean; overload;

implementation

var
  AFRequests:tList;

function AFGetProductForObject(obj:ansistring;callback:tAntifakeCallback;id:string=''):boolean;
begin

end;

function AFGetProductForObject(obj:tNVSRecord;callback:tAntifakeCallback;id:string=''):boolean;
begin

end;

function AFGetBrandForObject(obj:ansistring;callback:tAntifakeCallback;id:string=''):boolean;
begin

end;

function AFGetBrandForObject(obj:tBaseTXO;callback:tAntifakeCallback;id:string=''):boolean;
begin

end;




initialization
  AFRequests:=tList.create;
finalization
  while AFRequests.count>0 do begin
    tAFRequest(AFRequests[0]).free;
    AFRequests.delete(0);
  end;
  AFRequests.free;
end.

