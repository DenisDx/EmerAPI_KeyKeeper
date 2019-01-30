unit EmerApiTestUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Iphttpbroker, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls;

type

  { TEmerApiTestForm }

  TEmerApiTestForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TreeView1: TTreeView;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure showJson(resp:TStringList);
  private

  public

  end;

var
  EmerApiTestForm: TEmerApiTestForm;

  function doEmerApiRequest(request:ansistring):ansistring;
  function getEmerRPCAnswer(request:ansistring):ansistring;

  function changeQuotes(const s:ansistring):ansistring;
  function changeNone(const s:ansistring):ansistring;

implementation

{$R *.lfm}

uses FPHTTPClient
     ,fpjson, jsonparser;

{ TEmerApiTestForm }
function changeNone(const s:ansistring):ansistring;
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

function changeQuotes(const s:ansistring):ansistring;
var i:integer;
begin
  if pos('"',s)>0 then raise exception.Create('changeQuotes: " present in the string');
  result:=s;
  for i:=1 to length(result) do if result[i]='''' then result[i]:='"';
end;

function sid():ansistring;
begin
  result:= trim(EmerApiTestForm.Edit5.text);
end;

procedure setsid(sid:ansistring);
begin
  EmerApiTestForm.Edit5.text:=trim(sid);
end;

function login():boolean;
begin
  result:= false;
  EmerApiTestForm.Edit5.text:='';
  EmerApiTestForm.Button1Click(nil);
  result:=sid()<>'';
end;

function getEmerApiUrl(utype:ansistring=''):ansistring;
begin
  if uppercase(trim(utype))='QUERY' then result:=trim(EmerApiTestForm.Edit1.text)+trim(EmerApiTestForm.Edit6.text)
  else
  if uppercase(trim(utype))='LOGIN' then result:=trim(EmerApiTestForm.Edit1.text)+trim(EmerApiTestForm.Edit2.text)
  else
  result:=trim(EmerApiTestForm.Edit1.text);
end;

function doEmerApiRequest(request:ansistring):ansistring;
var url:string;
    resp:TStringList;
    FormData:TStringList;
    waslogged:boolean;
begin
  //Это прототип, потом мы ее перепишем с учетом всего-всего
  waslogged:=sid()<>'';
  if not waslogged then
    if not login() then raise exception.create('There is a problem with login. Please check EmerAPI server settings');


  FormData:=TStringList.create;
  resp:=TStringList.create;

  with TFPHTTPClient.Create(nil) do
  try
    Cookies.Append(sid());
    FormData.values['query'] := trim(request);
    FormPost(getEmerApiUrl('query'),FormData,resp);
    result:=resp.text;
    if waslogged and (pos('{"errors":[{"message":"User not logged",',result)=1) then begin
        //try to relogin
        setsid('');
        result:=doEmerApiRequest(request);
    end;

    //debug:
    if EmerApiTestForm.Visible then begin
      EmerApiTestForm.Memo1.lines.assign(resp);
      EmerApiTestForm.showJson(resp);
      EmerApiTestForm.Memo2.Lines.Text:=request;
    end;

  finally
    Free;
    resp.free;
  end;
end;

function getEmerRPCAnswer(request:ansistring):string;
var json:TJSONData;
begin
  result:='';
  json := GetJSON(doEmerApiRequest(request));
  try
    //errors":[{"message"
    if TJSONObject(json).Names[0]='errors' then exit;


    //TJSONObject(obj).Names[i]+'='+obj.Items[i].AsJSON
    //{"data":{"getblockcount":{"answer":"{'result': 17148, 'error': None, 'id': None}"}}}
    //result:=json.Find('answer').value;
    //if json.Find('answer',js) then result:=js.value;
    //result:=TJSONObject(json.items[0].items[0]).Objects['answer'].Objects['result'].AsString;
    //result:=json.
    //result:=TJSONObject(json.items[0].items[0].items[0]).Objects['result'].asString;
    if TJSONObject(json.items[0].items[0]).Names[0]='answer' then begin
        //j:=TJSONObject(json.items[0].items[0]).Elements['answer'];
        //j:=TJSONObject(json.items[0].items[0]).Objects['answer'];
        //j:=j.Elements['answer']);
        //j.JSONType;  //jtArray, jtObject
        //j:=j.items[0];
        //if j.JSONType=jtObject then
        //   result:='jtObject';
        result:=TJSONObject(json.items[0].items[0]).Elements['answer'].value;
    end;


  finally
    json.free;
  end;
end;

procedure TEmerApiTestForm.Button1Click(Sender: TObject);
var url:string;
    resp:TStringList;
    FormData:TStringList;
    i:integer;
    s:ansistring;
begin

 //.set('Content-Type','application/x-www-form-urlencoded')
 //.set('Access-Control-Allow-Origin','*')
 //.accept('application/json')
 //.send({ 'uname': this.userName, 'ups': this.password})

  url:=trim(Edit1.text)+trim(Edit4.text);

  FormData:=TStringList.create;
  resp:=TStringList.create;
  with TFPHTTPClient.Create(nil) do
  try
    //Post(url,resp);
    //Procedure FormPost(const URL : string; FormData:  TStrings; const Response: TStrings);

    //formdata.values['_token'] := token;
    formdata.values['uname'] := trim(Edit2.Text);
    formdata.values['ups'] := trim(Edit3.Text);

    FormPost(url,FormData,resp);

    Memo1.lines.assign(resp);

    Memo1.lines.append('=========Headers:========');
    Memo1.lines.append(responseheaders.text);
//    edit5.Text:=GetHeader('set-cookie');  //Set-Cookie
//    edit5.Text:=inttostr(IndexOfHeader(responseheaders,'Set-Cookie'));
    //edit5.Text:=GetHeader(responseheaders,'Set-Cookie');
    for i:=0 to Cookies.Count-1 do
       if pos('_yum_l=',Cookies[i])>0 then begin
           edit5.Text:=Cookies[i] ;
           break;
       end;
    if true and (edit5.Text='') then
       for i:=0 to responseheaders.Count-1 do
        if (pos('SET-COOKIE:',ansiuppercase(responseheaders[i]))>0)
           and
           (pos('_yum_l=',responseheaders[i])>0) then begin
               s:=responseheaders[i];
               system.delete(s,1,pos('_yum_l=',s)-1);
               if pos(';',s)>0 then
                  s:=copy(s,1,pos(';',s)-1);
               edit5.Text:=s;
           end;





  finally
    Free;
    resp.free;
  end;
end;

procedure TEmerApiTestForm.showJson(resp:TStringList);
var
  jData : TJSONData;
  jObject : TJSONObject;
  jArray : TJSONArray;
  s : String;
  procedure showTree(node:TTreeNode;obj:TJSONData);
  var i:integer;
      n:tTreeNode;
      s:ansistring;
  begin
    for i:=0 to obj.Count-1 do begin
       s:=obj.Items[i].AsJSON+' ';
       if s[1]='{'
         then n:=node.TreeView.Items.AddChild(node,inttostr(i))
         else n:=node.TreeView.Items.AddChild(node,TJSONObject(obj).Names[i]+'='+obj.Items[i].AsJSON);
       if obj.Items[i].Count>0 then showTree(n,obj.Items[i]);
    end;
    node.Expand(true);
  end;
begin
  // create from string
    jData := GetJSON(resp.Text);
    //jObject := TJSONObject(jData);
    try
      TreeView1.Items.Clear;
      showTree(TreeView1.Items.Add(nil,'root'),jData)
    finally
      jData.Free;
      //jObject.Free;
    end;
{
    // output as a flat string
    s := jData.AsJSON;

    // output as nicely formatted JSON
    s := jData.FormatJSON;

    // cast as TJSONObject to make access easier
    jObject := TJSONObject(jData);

    // retrieve value of Fld1
    s := jObject.Get('Fld1');

    // change value of Fld2
    jObject.Integers['Fld2'] := 123;

    // retrieve the second color
    s := jData.FindPath('Colors[1]').AsString;

    // add a new element
    jObject.Add('Happy', True);

    // add a new sub-array
    jArray := TJSONArray.Create;
    jArray.Add('North');
    jArray.Add('South');
    jArray.Add('East');
    jArray.Add('West');
    jObject.Add('Directions', jArray);  }

end;

procedure TEmerApiTestForm.Button2Click(Sender: TObject);
var url:string;
    resp:TStringList;
    FormData:TStringList;
    mycookies:TStringList;
begin


  url:=trim(Edit1.text)+trim(Edit6.text);

  FormData:=TStringList.create;
  resp:=TStringList.create;
  mycookies:=TStringList.create;
  with TFPHTTPClient.Create(nil) do
  try
    //Post(url,resp);
    //Procedure FormPost(const URL : string; FormData:  TStrings; const Response: TStrings);

    if trim(edit5.Text)<>'' then begin
        //AddHeader('Set-Cookie',trim(Edit5.Text));
        //formdata.values['Set-Cookie'] := trim(Edit5.Text);
        //formdata.values['_yum_l'] := trim(Edit5.Text);
        mycookies.append(trim(Edit5.Text));
        Cookies:=mycookies;
    end;


    //this.emertechAPI.doJSONrequest({query:'query { nameShow(name: "denis") { answer }}'})
    //formdata.values['_token'] := token;
    FormData.values['query'] := trim(Memo2.Lines.Text);



    FormPost(url,FormData,resp);

    Memo1.lines.assign(resp);

    Memo1.lines.append('=========Headers:========');
    Memo1.lines.append(responseheaders.text);
//    edit5.Text:=GetHeader('set-cookie');  //Set-Cookie
//    edit5.Text:=inttostr(IndexOfHeader(responseheaders,'Set-Cookie'));
    //edit5.Text:=GetHeader(responseheaders,'Set-Cookie');
    showJson(resp);

  finally
    Free;
    resp.free;
    mycookies.free;
  end;

end;

procedure TEmerApiTestForm.Button3Click(Sender: TObject);
begin
  Memo2.lines.Text:='query { nameshow(name: "denis") { answer }}';
end;

procedure TEmerApiTestForm.Button4Click(Sender: TObject);
begin
  Memo2.lines.Clear;
  Memo2.lines.append('mutation {          ');
  Memo2.lines.append('createuserconfig(name: "test", jsonvalue: "{\"a\":{\"b\": \"c\"}}") {          ');
  Memo2.lines.append('    name                                                                       ');
  Memo2.lines.append('  }          ');
  Memo2.lines.append('}          ');

end;

procedure TEmerApiTestForm.Button5Click(Sender: TObject);
begin

  Memo2.lines.Clear;
  Memo2.lines.append('query {          ');
  Memo2.lines.append('userconfig(name: "test") {          ');
  Memo2.lines.append('    name    ');
  Memo2.lines.append('    jsonvalue ');
  Memo2.lines.append('  }         ');
  Memo2.lines.append('}           ');
end;

procedure TEmerApiTestForm.Button6Click(Sender: TObject);
begin

//  mutation {
//    updateuserconfig(name: "", jsonvalue: "") {
//        name
//        jsonvalue
//    }
//  }
  Memo2.lines.Clear;
  Memo2.lines.append('mutation {          ');
  Memo2.lines.append('updateuserconfig(name: "test", jsonvalue: "{\"a\":{\"b1\": \"c2\"}}") { ');
  Memo2.lines.append('    name    ');
  Memo2.lines.append('    jsonvalue ');
  Memo2.lines.append('  }         ');
  Memo2.lines.append('}           ');
end;

procedure TEmerApiTestForm.Button7Click(Sender: TObject);
begin
  Memo2.lines.Clear;
  Memo2.lines.append('mutation {          ');
  Memo2.lines.append('deleteuserconfig(name: "test") { ');
  Memo2.lines.append('    name    ');
  Memo2.lines.append('  }         ');
  Memo2.lines.append('}           ');
end;

end.

