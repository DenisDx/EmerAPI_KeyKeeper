unit TranslationHelperUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils  ,fpjson, jsonparser;

function readTranslationFile:boolean;
function readTranslationFolder(shrinkHTML:boolean=false):tJsonData;
function reriteTranslationFolder(js:tJsonData;bhtml:boolean=false):boolean;

function packHTML(html:string):string;
function unpackHTML(data:string):string;

implementation

uses
  Forms
  ,Dialogs
  ,HelperUnit
  ,localizzzeUnit
  ,LazFileUtils
  ,FileUtil
  ,LConvEncoding
  ,math
  ;


function isHTML(html:string):boolean;
begin
  html:=lowercase(html);

  result:=0< (0
     +pos('<br>',html)
     +pos('<h1>',html)
     +pos('<h2>',html)
     +pos('<h3>',html)
     +pos('<h4>',html)
     +pos('<p>',html)
     +pos('<img ',html)

     +pos('<html>',html)
     +pos('<body>',html)
     +pos('<li>',html)
    );

end;

function readTranslationFile:boolean;
var i,j:integer;
    s:string;
    t:TJSONData;
    //ResStream : TResourceStream;
    fs:tFileStream;

    newLocalizzzeData :TJSONObject;
begin
  result:=false;

  if FileExistsUTF8(extractFilePath(application.ExeName)+'translation.txt') then
    try
      fs:=tFileStream.Create(extractFilePath(application.ExeName)+'translation.txt',fmOpenRead);
      setLength(s,fs.Size);
      fs.Read(s[1],length(s));
    finally
      FreeAndNil(fs);
    end
  else begin
   showMessage('You must put translation.txt file into the program''s folder');
   exit;
  end;


 //  mLanguageData.Lines.Clear;
  try
   t := GetJSON(changeQuotes(s));
   try
     newLocalizzzeData := TJSONObject.Create;

     for i:=0 to t.Count-1 do begin
       tJsonObject(newLocalizzzeData).Add(
        trim(AnsiUpperCase(tJsonObject(t).Names[i]))
        ,
        t.Items[i].Clone
       );
       for j:=0 to tJsonObject(t.Items[i]).Count-1 do
          if languages.IndexOf(tJsonObject(t.Items[i]).Names[j])<0
             then languages.add(tJsonObject(t.Items[i]).Names[j]);
     end;

   finally
     t.Free;
   end;

   LocalizzzeData.Free;
   LocalizzzeData:=newLocalizzzeData;

   result:=true;
  except
    on e: exception do
      showMessage('Incorrect JSON file: '+e.message);
  end;
end;


function deleteBOM(s:string):string;
var n:integer;
begin
  result:=s;
  n:=pos(UTF8BOM,result);
  while n>0 do begin
    delete(result,n,3);
    n:=pos(UTF8BOM,result);
  end;
end;

function loadCSV(fn:string):tStringList;
var n:integer;
    //f:file of byte;
    fs:tFileStream;
    s:string;
begin
  result:=nil;

  {
  assignFile(f,fn);
  reset(f,fn);
  try
    result:=tStringList.Create;
    setLength(s,FileSize(f));
    blockRead(f,s[1],length(s));
  finally
    closeFile(f);
  end;
  }

  fs:=tFileStream.Create(fn,fmShareDenyNone or fmOpenRead);
  try
    setLength(s,fs.Size);
    fs.Read(s[1],fs.Size);
  finally
    fs.free;
  end;

  result:=tStringList.Create;

  s:= deleteBOM(UTF8BOMToUTF8(UCS2LEToUTF8(s)));

  n:=pos(#13#10,s);
  while n>0 do begin
    result.append(copy(s,1,n-1));
    delete(s,1,n+1);
    n:=pos(#13#10,s);
  end;
  if s<>'' then result.append(s);
end;

function readTranslationFolder(shrinkHTML:boolean=false):tJsonData;
var dir:string;
    //j:tJsonData;
    fn:string;
    langs,csv:tStringList;
    line:tStringList;
    delimiter:char;
    i,j,n:integer;
    t:tJsonObject;

    procedure readCols(l:tStringList;s:string);
    var n:integer;
    begin
      l.Clear;
      n:=pos(delimiter,s);
      while n>0 do begin
        l.Append(copy(s,1,n-1));
        delete(s,1,n);
        n:=pos(delimiter,s);
      end;
      if s<>'' then l.Append(s);
    end;

    function getFile(fn:string):string;
    var fs:tFileStream;
    begin
      fs:=tFileStream.Create(fn,fmOpenRead);
      try
        setLength(result,fs.Size);
        fs.Read(result[1],fs.Size);
      finally
        fs.free;
      end;
      if shrinkHTML then
        result:=packHTML(result);
    end;

    function decodeLineData(linepos:integer):string;
    var fn:string;
    begin
      result:=line[linepos];
      if (trim(result)<>'') and (result[1]<>'@') then exit;
      if (trim(result)<>'') and (result[1]='@') then begin
        fn:=IncludeTrailingPathDelimiter(extractFilePath(application.ExeName)+'TRANSLATION')+copy(result,2,length(result)-1);
        if fileexists(fn) then begin
          result:=getFile(fn);
          exit;
        end;
      end;
      //file empty or not foung
      //fn:=langs[linepos]+'-'{+inttostr(csv.Count+1)+'-'}+line[0]+'.html';
      fn:=IncludeTrailingPathDelimiter(extractFilePath(application.ExeName)+'TRANSLATION')+langs[linepos]+'-'{+inttostr(csv.Count+1)+'-'}+line[0]+'.html';
      if fn<>result then //we did not check it before
         if fileexists(fn) then begin
           result:=getFile(fn);
           exit;
         end;
      result:='';
    end;
    var s:string;
begin
  result:=nil;

  delimiter:=#9;
  //if pos(',',floattostr(1.1))>0 then delimiter:=';';

  dir:=extractFilePath(application.ExeName)+'TRANSLATION';

  if not DirectoryExistsUTF8(dir) then
     begin
        showMessage('Can''t find directory: '+dir);
        exit;
     end;

  fn:=IncludeTrailingPathDelimiter(extractFilePath(application.ExeName)+'TRANSLATION')+'translation.csv';

  if not fileexists(fn) then begin
      showMessage('Can''t find file: '+fn);
      exit;
    end;

  csv:=loadCSV(fn);
  if csv=nil then exit;

  if csv.Count<2 then exit;


  result:=tJsonObject.Create;

  //read title
  langs:=tStringList.Create; line:=tStringList.Create;
  try
    readCols(langs,csv[0]);
    if langs.Count<2 then exit;

    for i:=1 to csv.Count-1 do begin
       readCols(line,csv[i]);
       //add param line[0]
       t:=tJsonObject.Create();
       for j:=1 to min(langs.Count,line.Count)-1 do begin
         //if trim(line[j])<>'' then  -->>> maybe we have file
         s:=decodeLineData(j);
         if s<>'' then
            t.Add(langs[j],s);
       end;

       tJsonObject(result).Add(
               trim(line[0])
               ,
               t
              );
    end;

  finally
    langs.Free; line.free;
  end;
end;

procedure saveCSV(csv:tStringList;fn:string);
var i:integer;
    f:file of byte;
    s:string;
begin

  assignFile(f,fn);
  rewrite(f);
  try
    for i:=0 to csv.Count-1 do begin
      s:=UTF8ToUCS2LE(UTF8ToUTF8BOM(csv[i]+#13#10));
      blockWrite(f,s[1],length(s));
    end;
  finally
    closeFile(f);
  end;

end;

function reriteTranslationFolder(js:tJsonData;bhtml:boolean=false):boolean;
var dir:string;
    //j:tJsonData;
    langs,csv:tStringList;
    line:tStringList;
    delimiter:char;
    i,j,n:integer;


  function packData(linepos:integer):string; //pack data to csv
  var fn,s:string;
      f:tFileStream;
  begin
    s:=line[linepos];
    if  (pos('@',s)=1) or (pos(',',s)>0) or (pos(#10,s)>0) or (isHTML(s) and (length(s)>100)) then begin
      //save to file and make a link
      fn:=langs[linepos]+'-'{+inttostr(csv.Count+1)+'-'}+line[0]+'.html';

      f:=tFileStream.Create(IncludeTrailingPathDelimiter(extractFilePath(application.ExeName)+'TRANSLATION')+fn,fmCreate);
      try
        if bhtml then s:=unpackHTML(s);
        f.Write(s[1],length(s));
      finally
        f.Free;
      end;

      result:='@'+fn;
    end else result:=s;
  end;

  procedure writeLine;
  var s:string;
      i:integer;
  begin
    s:='';
    {
    for i:=0 to line.Count-1 do
      s:=s+packData(i)+delimiter;
    delete(s,length(s),1);
    csv.Add(UTF8ToUTF8BOM(s));
    }
    for i:=0 to line.Count-1 do
      s:=s+packData(i)+delimiter;
    delete(s,length(s),1);
    //csv.Add(UTF8ToUCS2LE(UTF8ToUTF8BOM(s)));
    csv.Add(s);

    //s:=UTF8ToUCS2LE(UTF8ToUTF8BOM(s));
  end;

begin
  result:=false;

  delimiter:=#9;
  //if pos(',',floattostr(1.1))>0 then delimiter:=';';

  dir:=extractFilePath(application.ExeName)+'TRANSLATION';

  if DirectoryExistsUTF8(dir) then
     if DeleteDirectory(dir,True) then begin
       {if not RemoveDirUTF8(dir) then begin
        showMessage('Can''t remove directory: '+dir);
        exit;
       end
       }
     end else begin
        showMessage('Can''t empty directory: '+dir);
        exit;
     end;

  if not ForceDirectoriesUTF8(dir) then begin
      showMessage('Can''t create directory: '+dir);
      exit;
    end;


  application.ProcessMessages;

  langs:=tStringList.Create;
  try
    //determine languages list
    langs.Append('ID');
    for i:=0 to js.Count-1 do begin
      for j:=0 to tJsonObject(js.Items[i]).Count-1 do
         if langs.IndexOf(tJsonObject(js.Items[i]).Names[j])<0
            then langs.add(tJsonObject(js.Items[i]).Names[j]);
    end;

    if langs.Count<2 then begin
      showMessage('No language data found ');
      exit;
    end;

    //build csv
    csv:=tStringList.Create; line:=tStringList.Create;
    try
      line.Assign(langs);

      writeLine;
      //create all lines
      for i:=0 to js.Count-1 do begin
        for j:=0 to line.Count-1 do line[j]:='';

        //id:
        line[0]:=tJsonObject(js).Names[i];

        for j:=0 to tJsonObject(js.Items[i]).Count-1 do begin
          n:=langs.IndexOf(tJsonObject(js.Items[i]).Names[j]);
          line[n]:=tJsonObject(js.Items[i]).Items[j].AsString;
        end;
        writeLine;
      end;
      {j:=js.Clone;
      try

       //uppackHTML
      finally
        j.free;
      end;
      }

      //recording file
      //csv.SaveToFile( IncludeTrailingPathDelimiter(extractFilePath(application.ExeName)+'TRANSLATION')+'translation.csv');
      saveCSV(csv,IncludeTrailingPathDelimiter(extractFilePath(application.ExeName)+'TRANSLATION')+'translation.csv');

    finally
      csv.free;
      line.free;
    end;
  finally
    langs.free;
  end;


  result:=true;
end;

function packHTML(html:string):string;
var i:integer;
    n:integer;
    inspace:boolean;
    fullcut:boolean;
    spaceStart:integer;
begin
  //remove '  ' and #10 #13
  result:='';

  //check if it IS html:
  if not isHTML(html) then begin
    result:=html;
    exit;
  end;

  n:=1; inspace:=false; fullcut:=true; spaceStart:=1;
  for i:=1 to length(html) do
    if inspace then begin
       if not (html[i] in [' ',#13,#10,#9]) then begin
         inspace:=false;

         fullcut:=fullcut or (html[i]='<');
         if fullcut then
           result:=result+copy(html,n,spaceStart-n)
         else
           result:=result+copy(html,n,spaceStart-n+1);
           //result:=result+copy(html,n,i-n);


         n:=i;
       end
    end else begin
      inspace:=html[i] in [' ',#13,#10,#9];
      if inspace then begin
         spaceStart:=i;
      end else //
        fullcut:=html[i] in ['>'];
    end;
  if n<=length(html) then
    result:=result+copy(html,n,length(html)-n+1);

  {
  i:=pos(#13#10,result);
  while i>0 do begin
    delete(result,i,1);
    i:=pos(#13#10,result);
  end;

  i:=pos(#10,result);
  while i>0 do begin
    result:=copy(result,1,i=1) + '\n'+ copy(result,i+1,length(result)-i)
    i:=pos(#10,result);
  end;
  }

{
  result:=StringReplace(result,'\','\\',[rfReplaceAll, rfIgnoreCase]);
  result:=StringReplace(result,#13#10,#10,[rfReplaceAll, rfIgnoreCase]);
  result:=StringReplace(result,#10,'\n',[rfReplaceAll, rfIgnoreCase]);
  result:=StringReplace(result,'"','\"',[rfReplaceAll, rfIgnoreCase]);
  result:=StringReplace(result,'''','\''',[rfReplaceAll, rfIgnoreCase]);

{  for i:=0 to length(brakeTags)-1 do
    result:=StringReplace(result,brakeTags[i],'\n',[rfReplaceAll, rfIgnoreCase]);}
}
end;

function unpackHTML(data:string):string;

const
  nAfter:array[0..8] of string=('</h1>','</h2>','</h3>','</h4>','<br>','<body>','</head>','</ul>','</ol>');
  nBefore:array[0..9] of string=('<h1>','<h2>','<h3>','<h4>','<p>','</body>','</html>','<li>','<ul>','<ol>');
  nonbrset=[' ',#13,#10,#9];

  var i,n,j:integer;
      inbr:boolean;
      brpos:integer;
      brlen:integer;

  ldata:string;

  function needInsertBr(pos:integer):integer;
  var i:integer;
  begin
    result:=0;
    for i:=0 to length(nBefore)-1 do
      if copy(ldata,pos,length(nBefore[i]))=nBefore[i] then begin
         result:=length(nBefore[i]);
         brpos:=pos;
         exit;
      end;
    for i:=0 to length(nAfter)-1 do
      if copy(ldata,pos,length(nAfter[i]))=nAfter[i] then begin
         result:=length(nAfter[i]);
         brpos:=pos+length(nAfter[i]);
         exit;
      end;
  end;

begin
  //Make HTML looking better
  ldata:=lowercase(data);
  result:='';
  n:=1;
  i:=2; //don't need to insert br BEFORE
  for j:=0 to length(nAfter)-1 do
    if copy(ldata,1,length(nAfter[j]))=nAfter[j] then begin
      i:=1;
      break;
    end;

  inbr:=false;
  brpos:=0;
  while i<=length(data) do
    if inbr then begin
      brlen:=needInsertBr(i);
      if brlen>0 then
         i:=i+brlen
      else
        if data[i] in nonbrset then inc(i)
        else begin
          //insert break and copy data
          inbr:=false;

          if brpos>0 then begin
            result:=result+
              copy(data,n,brpos-n)+#10+copy(data,brpos,i-brpos);
          end else begin
            result:=result+copy(data,n,i-n)+#10;
          end;

          n:=i;
          brpos:=0;
          inbr:=false;
          inc(i);
        end;
    end else begin
      brlen:=needInsertBr(i);
      if brlen>0 then begin
        inbr:=true;
        i:=i+brlen;
      end else inc(i);
    end;

    if n<=length(data) then
       result:=result+copy(data,n,length(data)-n+1);
end;

{
var i: integer;
    ins:boolean;
    n:integer;
begin
  result:='';
  // \n -> #10
  // \\ -> \
  // \" -> "
  // \' -> '
  i:=1; ins:=false; n:=1;
  while i<length(data) do begin
   if ins then begin
     //is special
     ins:=false;
     case data[i] of
       'n':result:=result + #10;
       'r':result:=result + #13;
     else
       result:=result + data[i];
     end;

   end else
     if data[i]='\' then begin
        //copy rest part to result
       if i>n then
         result:=result+copy(data,n,i-n);
       n:=i+2;
       ins:=true;
     end;

    inc(i);
  end;
  //rest part
  if n<=length(data) then
    result:=result+copy(data,n,length(data)-n+1);

end;
}


end.

