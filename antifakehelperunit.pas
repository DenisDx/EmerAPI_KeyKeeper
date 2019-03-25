unit AntifakeHelperUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils
  ,NVSRecordUnit
  ,BaseTXUnit
  ,EmerAPIBlockchainUnit
  ,fpjson
  ,emerapitypes

  ;

type
  tAFRequestType=(afrtLot,afrtProduct,afrtBrand,afrtRoot,afrtRootCert,afrtParent);

  tAFRequest = class;
  tAntifakeCallback=procedure (Sender:tAFRequest) of object;
  tAFRequest = class(tObject)
    private
    public
      LastError:string;

      cNVSName:ansistring; //current
      cNVSValue:string;    //current

      rtype:tAFRequestType;
      callback:tAntifakeCallback;
      rNVSName:ansistring;  //result
      rNVSValue:ansistring; //result

      rFirstProduct:ansistring; //result

      id:string;
      finished:boolean;
      constructor create(aType:tAFRequestType;aCallback:tAntifakeCallback;aId:ansistring='');
      procedure resolve; //next step
      procedure AsyncDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
  end;

function AFGetProductForObject(obj:ansistring;callback:tAntifakeCallback;id:string=''):boolean; overload;
function AFGetProductForObject(obj:tNVSRecord;callback:tAntifakeCallback;id:string=''):boolean; overload;
function AFGetBrandForObject(obj:ansistring;callback:tAntifakeCallback;id:string=''):boolean; overload;
function AFGetBrandForObject(obj:tBaseTXO;callback:tAntifakeCallback;id:string=''):boolean; overload;

function addNVSValueParameter(const text,name,value:string):string;
function cutNVSValueParameter(text,name:string):string;
function getNVSValueParameter(text,name:string; allowMultyLine:boolean=true):string;
function getTextToSign(name:ansistring;value:string;SignFieldPreffix:string='*'):string;

//function getOwnerForName(name:ansistring):ansistring; //returns code58 address

function unscreenNVSValueParam(s:string):string;
function screenNVSValueParam(s:string):string;

implementation

uses MainUnit
     ,Localizzzeunit


    ;

var
  AFRequests:tList;

{
function getOwnerForName(name:ansistring):ansistring; //returns code58 address
begin
  //looking in the UTXOs first

end;
}

function unscreenNVSValueParam(s:string):string;
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
    end else if result[n]='\' then begin sl:=true; delete(result,n,1); end else inc(n);


end;

function screenNVSValueParam(s:string):string;
var n:integer;
begin
 result:=s;

 n:=1;
 while n<=length(result) do
   if result[n]='\' then begin
     result:=copy(result,1,n-1)+'\'+copy(result,n,length(result)-n+1);
     inc(n);inc(n);
   end else inc(n);

 n:=pos(#13#10,result);
 while n>0 do begin
   result:=copy(result,1,n-1)+'\n'+copy(result,n+2,length(result)-n-1);
   n:=pos(#13#10,result);
 end;
 n:=pos(#10,result);
 while n>0 do begin
   result:=copy(result,1,n-1)+'\n'+copy(result,n+1,length(result)-n);
   n:=pos(#10,result);
 end;

end;


function getPrefix(name:string):ansistring;
var //s:ansistring;
    n:integer;
begin
  result:='';

  n:=pos(':',name);
  if n<1 then exit;

  result:=copy(name,1,n-1);

  if result<>'af' then exit; //not chain
  delete(name,1,n);

  n:=pos(':',name);
  if n<1 then exit;

  result:=result+':' + copy(name,1,n-1);

end;

function getTextToSign(name:ansistring;value:string;SignFieldPreffix:string='*'):string;
var s:string;
    n:integer;
begin
  result:=trim(name)+#10;

  n:=pos(#10,value);
  while n>0 do begin
    s:=copy(value,1,n-1);
    delete(value,1,n);

    if (length(s)>0) and (s[length(s)]=#13) then delete(s,length(s),1);

    //if (pos(name+'=',s)=1) or (pos('*'+name+'=',s)=1) then begin
    if (pos('=',s)>1) and (pos(SignFieldPreffix,s)=1) then begin
       result:=result+s+#10;
    end;
    n:=pos(#10,value);
  end;


  if (length(result)>0) then delete(result,length(result),1); //cut last #10

end;

function addNVSValueParameter(const text,name,value:string):string;
begin
  result:=text;
  if (length(result)>0) and (result[length(result)]<>#10) then result:=result+#10;
  result:=result+name+'='+screenNVSValueParam(value);
end;

function cutNVSValueParameter(text,name:string):string;
var s:string;
    n:integer;
begin
 //extract *XXXX= or XXX= parameter. Multiline is possible
 result:='';
 n:=pos(#10,text);
 while n>0 do begin
   //s:=copy(text,1,n-1);
   s:=copy(text,1,n);
   delete(text,1,n);

   if (pos(name+'=',s)=1) or (pos('*'+name+'=',s)=1) then begin
      //if (length(s)>0) and (s[length(s)]=#13) then delete(s,length(s),1);
      //found
   end else result:=result+s;
   n:=pos(#10,text);
 end;

end;

function getNVSValueParameter(text,name:string; allowMultyLine:boolean=true):string;
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


procedure cleanupRequests;
var i:integer;
begin
  //free finished requests
  i:=0;
  while i<AFRequests.Count do
    if tAFRequest(AFRequests[i]).finished then begin
      tAFRequest(AFRequests[i]).Free;
      AFRequests.Delete(i);
    end else inc(i);
end;

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
var r:tAFRequest;
begin

  r:=tAFRequest.Create(afrtBrand,callback,id);
  AFRequests.Add(r);
  r.cNVSName:=obj.getNVSname;
  r.cNVSValue:=obj.getNVSValue;
  r.resolve;

  cleanupRequests;
end;


//tAFRequest
constructor tAFRequest.create(aType:tAFRequestType;aCallback:tAntifakeCallback;aId:ansistring='');
begin
  finished := false;
  rType:=aType;
  callback:=aCallback;

  rNVSName:='';
  rNVSValue:='';
  rFirstProduct:='';

  id:=aId;
end;

procedure tAFRequest.resolve;
var s:string;
begin
  //set finished and call callback if finished
  //afrtLot,afrtProduct,afrtBrand,afrtRoot,afrtRootCert,afrtParent
  case rtype of
    afrtBrand:begin
      //brand.   PARENTLOT -> PRODUCT -> BRAND
      if cNVSName='' then begin
        //erroneous
        finished:=true;
        LastError:='cNVSName=''''';
        callback(self);
      end else if cNVSValue='' then begin
        //we should request value
        emerAPI.EmerAPIConnetor.sendWalletQueryAsync('name_show',getJSON('{name:"'+cNVSName+'"}'),@(AsyncDone),'getname:'+cNVSName);
      end else if getPrefix(cNVSName)='af:lot' then begin
         //lot. Requset PARENTLOT if have; PRODUCT overwise
         s:=getNVSValueParameter(cNVSValue,'PARENTLOT');
         if s<>'' then emerAPI.EmerAPIConnetor.sendWalletQueryAsync('name_show',getJSON('{name:"'+s+'"}'),@(AsyncDone),'getname:'+s)
         else begin
           s:=getNVSValueParameter(cNVSValue,'PRODUCT'); if rFirstProduct='' then rFirstProduct:=s;
           if s<>'' then emerAPI.EmerAPIConnetor.sendWalletQueryAsync('name_show',getJSON('{name:"'+s+'"}'),@(AsyncDone),'getname:'+s)
           else begin
             s:=getNVSValueParameter(cNVSValue,'PARENT');
             if s<>'' then emerAPI.EmerAPIConnetor.sendWalletQueryAsync('name_show',getJSON('{name:"'+s+'"}'),@(AsyncDone),'getname:'+s)
             else begin
               finished:=true;
               LastError:= localizzzeString('AFCreateForPrintingForm.tAFRequest.CantResolve','tAFRequest.resolve: afrtBrand: resolving path not found for lot: ')+'"'+cNVSName+'"';
               callback(self);
             end;
           end;
         end;
      end else if getPrefix(cNVSName)='af:product' then begin
         //PRODUCT -> BRAND
        //1. Check if BRAND field defined
        //2. overwise check if PRODUCT defined (parent product)
        //3. overwise chekc ParengetTextToSign(t. It could be a product or brand
        //s:=getNVSValueParameter(cNVSValue,'BRAND');

        s:=getNVSValueParameter(cNVSValue,'BRAND');
        if s<>'' then begin
          finished:=true;
          rNVSName:=s;
          rNVSValue:='';
          callback(self);
        end else begin
          s:=getNVSValueParameter(cNVSValue,'PRODUCT');
          if s<>'' then begin
            emerAPI.EmerAPIConnetor.sendWalletQueryAsync('name_show',getJSON('{name:"'+s+'"}'),@(AsyncDone),'getname:'+s)
          end else begin
            s:=getNVSValueParameter(cNVSValue,'PARENT');
            if getPrefix(s)='dpo' then begin
               //it is a brand!
               finished:=true;
               rNVSName:=s;
               rNVSValue:='';
               callback(self);
            end else if getPrefix(s)='af:product' then begin
              emerAPI.EmerAPIConnetor.sendWalletQueryAsync('name_show',getJSON('{name:"'+s+'"}'),@(AsyncDone),'getname:'+s)
            end else begin
              finished:=true;
              //LastError:='tAFRequest.resolve: afrtBrand: resolving path not found for lot "'+cNVSName+'"';  !
              LastError:= localizzzeString('AFCreateForPrintingForm.tAFRequest.CantResolve','tAFRequest.resolve: afrtBrand: resolving path not found for lot: ')+'"'+cNVSName+'"';
              callback(self);
            end;
          end;
        end;

        if s<>'' then emerAPI.EmerAPIConnetor.sendWalletQueryAsync('name_show',getJSON('{name:"'+s+'"}'),@(AsyncDone),'getname:'+s)
        else begin
          finished:=true;
          //LastError:='tAFRequest.resolve: afrtBrand: resolving path not found for product "'+cNVSName+'"';  !
          LastError:= localizzzeString('AFCreateForPrintingForm.tAFRequest.CantResolve','tAFRequest.resolve: afrtBrand: resolving path not found for lot: ')+'"'+cNVSName+'"';
          callback(self);
        end;
//      end else if getPrefix(cNVSValue)='dpo' then begin
      end else begin
        //erroneous
        finished:=true;
        LastError:='tAFRequest.resolve: unknow situation for afrtBrand';
        callback(self);
      end;


    end

  else
    raise exception.Create('tAFRequest.resolve: type '+inttostr(integer(rtype))+' not supported yet');
  end;
end;

procedure tAFRequest.AsyncDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
var e:tJsonData;

    function safeString(e:tJsonData):string;
    begin
     if e<>nil then
        if e.IsNull
         then result:=''
         else result:=e.asString
     else result:='';
    end;

begin

  //if sender.id=('getname:'+trim(lastRequestedNVSname)) then begin
  if pos('getname:',sender.id)=1 then begin
    e:=result.FindPath('result');
    if e<>nil then
       if e.IsNull then begin
         //name is free :-/
         finished:=true;
         LastError:='tAFRequest: name not found:"'+sender.id+'"';
         callback(self);
       end else
       try
         //name exists!
         cNVSName:=safeString(e.FindPath('name'));
         cNVSValue:=safeString(e.FindPath('value'));

         if (cNVSName='') or (cNVSValue='') then begin
           finished:=true;
           LastError:='tAFRequest: incorrect name data in: '+result.AsJSON+' tag:'+sender.id;
           callback(self);
         end else resolve;
       except
         on e:exception do begin
           finished:=true;
           LastError:='tAFRequest: resolving exception "'+e.message+'" in: '+result.AsJSON+' tag:'+sender.id;
           callback(self);
         end;
       end
    else begin
      finished:=true;
      LastError:='tAFRequest: can''t find result in: '+result.AsJSON+' tag:'+sender.id;
      callback(self);
    end;

  end else begin
    finished:=true;
    LastError:='tAFRequest: unknown tag in: '+result.AsJSON+' tag:'+sender.id;
    callback(self);
  end;

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

