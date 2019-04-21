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
function changeQuotesSafe(const s:string):string;

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

function changeQuotesSafe(const s:string):string;
var i:integer;
    inq:boolean;
    ins:boolean;
    havesingle:boolean;
    issingle:boolean;
begin
  //we analize if the ' used as quotes and do the changes only in this case

  //"...." ; "  '  "  ignore \"  but not \\"
  result:=s;

  inq:=false; ins:=false; havesingle:=false; issingle:=false;
  for i:=1 to length(result) do
     if not ins then //not screened.
        if not inq then begin
          //not in quotes
          if result[i] = '''' then begin
              //have ' :-(
             havesingle:=true;
             result[i]:='"';
             inq:=true;
             issingle:=true;
          end else if result[i] = '"' then begin inq:=true; issingle:=false; end;
        end else begin
           //we are in quotes... and current symbol is not screened
           if issingle and (result[i] = '''') then begin
             //end of the string
             result[i]:='"';
             inq:=false;
           end else
           if (not issingle) and (result[i] = '"') then
             //end of the string
             inq:=false
           else if (result[i] = '\') then ins:=true;

        end
     else ins:=false; //we are in quotes and the symbol is screened. just do nothing.
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
var FormatSettings: TFormatSettings;
begin
  //DefaultFormatSettings.DecimalSeparator := '.' ;
  FormatSettings:=DefaultFormatSettings;
  FormatSettings.DecimalSeparator := '.' ;
  FormatSettings.ThousandSeparator:=#0;
  //result:=floatToStr(v,FormatSettings);
  result:=FormatFloat('0.######',v,FormatSettings);

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

