unit HelperUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, strutils
  {$IFDEF LCLCarbon}
  ,MACOSall
  {$ENDIF}
  ;

function getDefaultPath:string;
function checkPath(fname:string):string;
function CleanFileName(const InputString: string): string;
function myFloatToStr(v:double):ansistring;
function myStrToFloat(v:ansistring):double;
function changeNone(const s:string):string;
function changeQuotes(const s:string):string;

function myStrToInt(s:string):int64;

function clear13(s:ansistring):ansistring;

implementation

function clear13(s:ansistring):ansistring;
begin
  result:=s;

  while (pos(#13#10,result)>0) do
    delete(result,pos(#13#10,result),1);
end;

function changeNone(const s:string):string;
var i:integer;
    ic:boolean;
begin
  //{'result': 17155, 'error': None, 'id': None}
 //сканим вне кавычек (двойных)
 //меняем ': None,' и ': None}'
  ic:=false;
  result:=s;
  for i:=1 to length(result)-5 do
     if result[i]='"' then ic:=not ic
     else if not ic then
        if copy(result,i,7)=': None,' then result:=copy(result,1,i-1)+': Null,'+copy(result,i+7,length(result)-7-i+1)
        else
        if copy(result,i,7)=': None}' then result:=copy(result,1,i-1)+': Null}'+copy(result,i+7,length(result)-7-i+1)
        ;

end;

function changeQuotes(const s:string):string;
var i:integer;
begin
//  if pos('"',s)>0 then raise exception.Create('changeQuotes: " present in the string');
  result:=s;
  for i:=1 to length(result) do if result[i]='''' then result[i]:='"';
end;

function myStrToInt(s:string):int64;
begin
  if pos('0x',s)=1 then begin
    delete(s,1,1);
    s[1]:='$';
  end;
  result:=strToInt64(s);
end;

function myStrToFloat(v:ansistring):double;
begin
  DefaultFormatSettings.DecimalSeparator := '.' ;

  if pos('.',v)>0 then
    while pos(',',v)>0 do delete(v,pos(',',v),1)
  else
    while pos(',',v)>0 do v[pos(',',v)]:='.';
  result:=strToFloat(v);

end;

function myFloatToStr(v:double):ansistring;
begin
  DefaultFormatSettings.DecimalSeparator := '.' ;
  result:=floatToStr(v);
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

function getDefaultPath:string;
const
  kMaxPath = 1024;
var
  {$IFDEF LCLCarbon}
  theError: OSErr;
  theRef: FSRef;
  {$ENDIF}
  pathBuffer: PChar;
  Global:boolean;
begin
  //Возвращает путь для хранения данных. Обязательно с дополнением в конце
  //Для виндоуса это будет рабочий каталог
  Result := ExtractFilePath(Application.ExeName);
  {$IFDEF LCLCarbon}
    //Result := LeftStr(Result, Pos('myapp.app', Result)-1);
    //Result := ExtractFileDir(Paramstr(0));

    Global:=false;
    try
      pathBuffer := Allocmem(kMaxPath);
    except on exception do exit;
    end;
    try
      Fillchar(pathBuffer^, kMaxPath, #0);
      Fillchar(theRef, Sizeof(theRef), #0);
      if Global then   // kLocalDomain
        theError := FSFindFolder(kLocalDomain, kApplicationSupportFolderType, kDontCreateFolder, theRef)
      else
        theError := FSFindFolder(kUserDomain , kApplicationSupportFolderType, kDontCreateFolder, theRef);
      if (pathBuffer <> nil) and (theError = noErr) then
      begin
        theError := FSRefMakePath(theRef, pathBuffer, kMaxPath);
        if theError = noErr then result := UTF8ToAnsi(StrPas(pathBuffer)) + '/';
      end;
    finally
      Freemem(pathBuffer);
    end;
    Result:=IncludeTrailingPathDelimiter(Result)+'EmerAPIKeeper';
  {$ELSE}
  result := GetAppConfigDir(false);
  {$ENDIF}

  Result:=IncludeTrailingPathDelimiter(Result);

end;


function checkPath(fname:string):string;
begin
  //Если пути нет, то добавляет defaultpath

  if ExtractFileDir(fname)='' then
    result:=getDefaultPath+fname
  else
    result:=fname;
end;

end.

