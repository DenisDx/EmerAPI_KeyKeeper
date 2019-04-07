unit HelpRedirector;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson,  jsonparser, forms;

function showHelpTag(tag:string='';ParentForm:tForm=nil;addData:string='';level:integer=0):boolean;
function getHelpServerAddress():string;

var helpTagsString:string ='{root:"https://emerapi.info",keeper_passwords_general:"https://emerapi.info/article/5ca467343666ac304f4beff4"'
   +',MainForm:{_:"",eAddress:"http://emercoin.com"}'
   +',MessageAskForCreateOrEnterMPNow:"help://keeper_passwords_general"'

  +'}';
    helpTags:tJsonData;

implementation
uses MainUnit, SettingsUnit, QuestionUnit, LCLIntf, localizzzeUnit;

function getHelpServerAddress():string;
begin
  result:='http://emcdpo.info';
end;

function showHelpTag(tag:string='';ParentForm:tForm=nil;addData:string='';level:integer=0):boolean;
//show help using
// Settings.getValue('Language');
//if the tag is unknow shows message
function haveDoc(s:ansistring):boolean;
begin
  result:=localizzzeString(s,'')<>'';
end;

procedure showDoc(s:ansistring);
begin
  if haveDoc(s) then
    if ParentForm<> nil then
      with AskQuestionTag(ParentForm,nil,s) do begin
        bOk.Visible:=true;
        Update;
      end;
end;

var e:tJsonData;
    s:string;
begin
  if level>10 then begin
    raise exception.Create('Help system: too long or circle redirection');
    exit;
  end;

  if ParentForm=nil then ParentForm:=Screen.ActiveForm;

  if (ParentForm=nil) and (tag='') then exit;

  if tag='' then begin//just press f1
    tag:=ParentForm.Name;
    if addData='' then
      if ParentForm.ActiveControl<>nil then addData:=ParentForm.ActiveControl.Name;
  end;

  if tag<>'' then
    if addData<>'' then begin
      e:=helpTags.FindPath(tag+'.'+addData);
      if e=nil then e:=helpTags.FindPath(tag);
    end else e:=helpTags.FindPath(tag);

  if e<>nil then begin
    if e.FindPath('_')<>nil then e:=e.FindPath('_'); //general topic
    s:=trim(e.AsString);

    if pos('help:',lowercase(s))=1 then begin
       delete(s,1,5);
       while (length(s)>0) and (s[1]='/') do delete(s,1,1);
       showHelpTag(s,ParentForm,addData,level+1);
    end
    else
    if pos('http',lowercase(s))=1 then
       OpenURL(s)
    else
    if pos('doc:',lowercase(s))=1 then begin
      delete(s,1,4);
      while (length(s)>0) and (s[1]='/') do delete(s,1,1);
      if haveDoc(s)
        then showDoc(s)
        else showDoc('MessageHelpTopicIsNotFound');
    end
    else begin
      while (length(s)>0) and (s[1]='/') do delete(s,1,1);
      if haveDoc(s) then showDoc(s)
      else begin
        s:=getHelpServerAddress+'/'+s;
        OpenURL(s);
      end;
   end;
    //if pos('http',lowercase(s))=1 then
    //  OpenDocument(s);
  end
  else
  showDoc('MessageHelpTopicIsNotFound');
end;

initialization
  helpTags:=getJSON(helpTagsString);

finalization
  if helpTags<>nil then helpTags.Free;
end.

