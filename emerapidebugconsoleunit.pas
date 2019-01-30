unit EmerAPIDebugConsoleUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Buttons, fpjson, EmerAPIBlockchainUnit, SynEditMarkupSpecialLine;

type

  { TEmerAPIDebugConsoleForm }

  TEmerAPIDebugConsoleForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn10: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    BitBtn9: TBitBtn;
    bSend: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    chDecodeJSON: TCheckBox;
    cWay: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    mRequest: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    seAnswer: TSynEdit;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    twAnswer: TTreeView;
    procedure BitBtn10Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure BitBtn9Click(Sender: TObject);
    procedure bSendClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure seAnswerClick(Sender: TObject);
    procedure seAnswerKeyPress(Sender: TObject; var Key: char);
    procedure seAnswerKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure seAnswerSpecialLineColors(Sender: TObject; Line: integer;
      var Special: boolean; var FG, BG: TColor);
    procedure showTW(j:tJsonData;RootName:string='root'); overload;
    procedure showTW(s:string); overload;
  private
    procedure myQueryDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
  public

  end;

var
  EmerAPIDebugConsoleForm: TEmerAPIDebugConsoleForm;

implementation

uses MainUnit, UOpenSSL, UOpenSSLdef, Crypto, jsonparser, EmerAPIBlockchainMergedUnit, EmerAPIServerUnit, math;

{$R *.lfm}

{ TEmerAPIDebugConsoleForm }
procedure TEmerAPIDebugConsoleForm.showTW(j:tJsonData;RootName:string='root');
  function cutLong(s:ansistring):ansistring;
  begin
    if length(s)>1003
      then result:=copy(s,1,1000)+'...'
      else result:=s;
  end;

  procedure showTree(node:TTreeNode;obj:TJSONData);
  var i:integer;
      n:tTreeNode;
      s:ansistring;
      j:TJSONData;
  begin
    for i:=0 to obj.Count-1 do begin
       s:=obj.Items[i].AsJSON+' ';
       try
         if s[1]='{'
           then n:=node.TreeView.Items.AddChild(node,inttostr(i))
           else
             if obj is TJSONObject
               then n:=node.TreeView.Items.AddChild(node,TJSONObject(obj).Names[i]+'='+cutLong(obj.Items[i].AsJSON))
               else n:=node.TreeView.Items.AddChild(node,obj.Items[i].AsJSON)
       except
         n:=node.TreeView.Items.AddChild(node,'***ERROR***')
       end;
       try
         if obj.Items[i].Count>0
           then showTree(n,obj.Items[i])
           else if (chDecodeJSON.Checked) and (not obj.Items[i].IsNull) then begin
             s:=obj.Items[i].AsString;
             if (pos('{',s)=1) then begin
               try
                 j:=nil;
                 j:=GetJSON(s);
                 if j<>nil then
                   showTree(n,j);
               except
                 if j<>nil then
                   j.free;
               end;
             end;
           end;
       except
         n.Text:='***ERRONEOUS***'+n.Text;
       end;
    end;
    node.Expand(true);
  end;
begin
  twAnswer.Items.Clear;
  if j=nil then exit;
  showTree(twAnswer.Items.Add(nil,RootName),j);
end;

procedure TEmerAPIDebugConsoleForm.showTW(s:string);
var js:tJsonData;
    RootName:string;
begin
  js:=nil;
  RootName:='root';
  if pos('Error',s)=1 then begin
    RootName:='ERROR';
    if pos('{',s)>0
       then delete(s,1,pos('{',s)-1)
    else
       s:='';
  end;

  if s<>'' then begin
    js:=GetJSON(s);
    try
      showTW(js,RootName);
    finally
      js.free;
    end;
  end else showTW(nil);

end;

procedure TEmerAPIDebugConsoleForm.myQueryDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
begin
  twAnswer.Items.Clear;
  if result=nil then begin
    seAnswer.Lines.Append('Error: '+sender.lastError);
    showTW(sender.lastError);
  end else begin
    //show JSON everywhere
    seAnswer.Lines.Append(result.AsJSON);
    showTW(result);
  end;

end;

procedure TEmerAPIDebugConsoleForm.bSendClick(Sender: TObject);
var
    method:ansistring;
    params:tJSONData;
    qType:tEmerAPIServerQueryType;

  procedure decodeParams;
  var s:string;

    function nc(s:ansistring):boolean;
    var i,n:integer;
    begin
      //finished string?
      result:=false;
      if length(s)=0 then exit;
      //s[length(s)]
      //going back and calc '\'
      n:=0;
      for i:=length(s)-1 downto 1 do
         if s[i]='\' then inc(n) else break;
      result:=n mod 2 = 0;
    end;

    function popParam():ansistring;
    var c:ansichar;
        n,m:integer;
        splitter:ansichar=' ';
    begin
      //splitters are ' ',',' but not inside ANY quotes
      s:=trim(s);
      if s[length(s)]=')' then delete(s,length(s),1);
      if s[1]='(' then delete(s,1,1);
      if s[1]=',' then delete(s,1,1);

      //if s[length(s)]=']' then delete(s,length(s),1);
      //if s[1]='[' then delete(s,1,1);
      //if s[length(s)]='}' then delete(s,length(s),1);
      //if s[1]='{' then delete(s,1,1);
      s:=trim(s);

      result:='';
      if length(s)<1 then exit;
      repeat
        if (s[1]='"') {or (s[1]='''')} then begin
          c:=s[1];
          result:=result+c; delete(s,1,1);
          //return quoted string
          //but ignore \"
          n:=pos(c,s);
          while (length(s)>0) do begin
            result:=result+copy(s,1,n);
            delete(s,1,n);
            if nc(result) then break;
            n:=pos(c,s);
          end;

        end else
        if {(s[1]='"') or} (s[1]='''') then begin
          c:=s[1];
          result:=result+''; delete(s,1,1);
          //return quoted string
          //but ignore \"
          n:=pos(c,s);
          while (length(s)>0) do begin
            result:=result+copy(s,1,n);
            delete(s,1,n);
            if nc(result) then begin
              if result<>'' then delete(result,length(result),1);
              break;
            end;
            n:=pos(c,s);
          end;

        end else
        begin
           //till splitter
           n:=pos(' ',s+' ');
           m:=pos('''',s+' '); if (m>0) and (m<n) then n:=m;
           m:=pos('"',s+' '); if (m>0) and (m<n) then n:=m;
           m:=pos(',',s+' '); if (m>0) and (m<n) then n:=m;
           m:=pos('(',s+' '); if (m>0) and (m<n) then n:=m;
           result:=result+trim(copy(s,1,n-1));
           delete(s,1,n-1);
           //Удалили все до символа разделителя.
        end;
      //Теперь нам надо определить, вышли ли мы из параметра
      //Елси s='', то вышли
      //Если s[1]= ',', то вышли
      //Если s[1]= ' ' И result[length(result)]<>':' то вышли
      //И если (, то тоже конец
      //иначе - не вышли. продолжаем читать этот параметр
      until (trim(s)='') or ((s+' ')[1]='(') or ((s+' ')[1]=',') or (((s+'_')[1]=' ') and ((' '+result)[length(result)+1]<>':'));
      s:=trim(s);
    end;
  begin
    s:=trim(mRequest.Text);
    //walletf param1:param1 param3:papam4
    //walletf param1 param2 param3:papam3
    //walletf param1 [{ --- param2 ...)]
    //walletf(param1:param2,param3:papam4)
    //walletf(param1,param2,param3:papam4)

    //OR

    //query { }
    //mutation }
    if //(pos(' ',s+' ')<pos('query',lowercase(s+' '))) and (pos(' ',s+' ')<pos('mutation',lowercase(s+' ')))
       //and
       //(pos('(',s+'(')<pos('query',lowercase(s+'('))) and (pos('(',s+'(')<pos('mutation',lowercase(s+'(')))
      not(
       ((pos('mutation',lowercase(s))>0) and (pos(' ',s+' ')<pos('mutation',lowercase(s+' '))) and (pos('(',s+'(')<pos('mutation',lowercase(s+'('))))
       or
       ((pos('query',lowercase(s))>0) and (pos(' ',s+' ')<pos('query',lowercase(s+' '))) and (pos('(',s+'(')<pos('query',lowercase(s+'('))))
      )
    then begin
       //wallet query
      qType:=esqWallet;
      {method:=popParam();
      while length(s)>0 do begin
         setLength(params,Length(params)+1);
         params[Length(params)-1]:=popParam();
      end; }
      method:=copy(s,1,pos(' ',s+' ')-1);
      if pos(' ',s)>0 then begin
        delete(s,1,pos(' ',s));
        params:=getJSON(s);
      end;
    end else begin
       //server query
      method:=s;
      qType:=esqServer;
    end;
  end;

  var ud:tpServerThreadUserData;
begin
  qType:=esqWallet;

  seAnswer.Lines.Append('>>'+trim(mRequest.Text));

  method:='';
  params:=nil;

//  Autodetect
//Wallet: autoselect way
//Local wallet (wallet request)
//EmerAPI Server: raw
//EmerAPI Server: wallet request

  case cWay.ItemIndex of
    1: begin
      decodeParams;
      emerAPI.EmerAPIConnetor.sendWalletQueryAsync(method,params,@myQueryDone);
    end;
    2: begin //Local wallet (wallet request)
      decodeParams;
      //EmerAPI.EmerAPIConnetor.sendWalletQueryAsync('sendrawtransaction',getJSON('{hexstring:"'+bufToHex(packTX(getTTX))+'"}'),@AsyncAddressInfoDone,'sendTX')
      emerAPI.EmerAPIConnetor.walletAPI.sendWalletQueryAsync(method,params,@myQueryDone);
    end;
    3: begin //EmerAPI Server: raw
       //decodeParams;
       method:=mRequest.Text;
       ud:=tpServerThreadUserData(emerAPI.EmerAPIConnetor.serverAPI.sendQueryAsync(method,params,@myQueryDone).userData);
       if ud<>nil then ud^.EmerAPIServerQueryType:=esqServer;
    end;
    4: begin //EmerAPI Server: wallet request
       decodeParams;
       emerAPI.EmerAPIConnetor.serverAPI.sendWalletQueryAsync(method,params,@myQueryDone);
    end;
    else begin
      //autodetect
      decodeParams;
      //if qType=esqWallet then begin
        emerAPI.EmerAPIConnetor.sendQueryAsync(method,params,@myQueryDone);
      //end;
    end;
  end;
end;

procedure TEmerAPIDebugConsoleForm.Button1Click(Sender: TObject);
begin
  mRequest.lines.Clear;
  mRequest.lines.append(
  'query {'#13#10+
  '  transactiongrouplist {'#13#10+
  '    address #: String'#13#10+
  '    amount #: Float'#13#10+
  '    comment #: String'#13#10+
  '    id #: ID'#13#10+
  '    name #: String'#13#10+
  '    time #: Int'#13#10+
  '    type #: String'#13#10+
  '    user {'#13#10+
//  '	     #ссылка на модель пользователя, т.е. тут можно запрашивать его поля'#13#10+
  '	    name'#13#10+
  '	    username'#13#10+
  '    }'#13#10+
  '    value #: String'#13#10+
  '  }'#13#10+
  '}'
  );
end;

procedure TEmerAPIDebugConsoleForm.Button2Click(Sender: TObject);
begin
   mRequest.lines.Clear;
   mRequest.lines.append(

   '   query {'#13#10+
   '     transactionlist(group:String) {'#13#10+
   '       address #: String '#13#10+
   '       amount #: Float'#13#10+
   '       comment #: String'#13#10+
//   '       dpo #: String'#13#10+
   '       id #: ID'#13#10+
   '       name #: String'#13#10+
   '       time #: Int'#13#10+
   '       type #: String'#13#10+
   '       #user {'#13#10+
   '   	   # ссылка на модель пользователя, т.е. тут можно запрашивать его поля'#13#10+
   '       #}'#13#10+
   '       value #: String'#13#10+
   '       #group {'#13#10+
   '   	    #ссылка на модель группы, т.е. тут можно запрашивать её поля'#13#10+
   '   	   #}'#13#10+
   '     }'#13#10+
   '   }'


(*
'  query {'#13#10+
'  transactiongroupitem(id: String) {'#13#10+
'        address #: String'#13#10+
'    amount #: Float'#13#10+
'    comment #: String'#13#10+
'    id #: ID'#13#10+
'    name #: String'#13#10+
'    time #: Int'#13#10+
'    type #: String'#13#10+
'    user {'#13#10+
'	    #ссылка на модель пользователя, т.е. тут можно запрашивать его поля'#13#10+
'	    name'#13#10+
'	    username'#13#10+
'    }'#13#10+
'    value  #: String'#13#10+
'  }'#13#10+
'}'
*)
   );
end;

procedure TEmerAPIDebugConsoleForm.seAnswerClick(Sender: TObject);
var s:string;
    js:tJsonData;
begin
  s:=seAnswer.Lines[seAnswer.LogicalCaretXY.y-1];
  if (pos('>>',s)<>1) {and (pos('Error:',s)<>1)} then begin
    try
      showTW(s);
    except
      showTW(nil);
    end;
  end else showTW(nil);

end;

procedure TEmerAPIDebugConsoleForm.seAnswerKeyPress(Sender: TObject;
  var Key: char);
begin

end;

procedure TEmerAPIDebugConsoleForm.seAnswerKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   seAnswerClick(Sender);
end;



procedure TEmerAPIDebugConsoleForm.seAnswerSpecialLineColors(Sender: TObject;
  Line: integer; var Special: boolean; var FG, BG: TColor);
var s:string;
begin
  s:=seAnswer.Lines[Line-1];
  Special:=pos('>>',s)=1;
  if Special then fg:=clBlue;
end;

procedure TEmerAPIDebugConsoleForm.BitBtn1Click(Sender: TObject);
begin
  mRequest.Text:='getblockchaininfo';
  //cWay.ItemIndex:=0;
  bSend.Click;
end;

procedure TEmerAPIDebugConsoleForm.BitBtn10Click(Sender: TObject);
begin
  mRequest.text:='query { transactionlist { address   id  amount } }';


end;

procedure TEmerAPIDebugConsoleForm.BitBtn2Click(Sender: TObject);
begin


//  mRequest.Text:='scantxoutset(action:"start",scanobjects:["{\"address\":\"'+MainForm.eAddress.Text+'\"}"])';

//  mRequest.Text:='scantxoutset (''action:"start",scanobjects:["{\"address\":\"'+MainForm.eAddress.Text+'\"}"]'')';

  mRequest.Text:='scantxoutset {action:"start", "scanobjects":[{"address":"'+MainForm.eAddress.Text+'"}]}';
 // mRequest.Text:='scantxoutset [''start'',''[{"address" : "'+MainForm.eAddress.Text+'" }]'']';

  //cWay.ItemIndex:=0;
  bSend.Click;

end;

procedure TEmerAPIDebugConsoleForm.BitBtn3Click(Sender: TObject);
begin
  mRequest.Text:='name_show {name:"denis"}';

  //cWay.ItemIndex:=0;
  bSend.Click;


end;

procedure TEmerAPIDebugConsoleForm.BitBtn4Click(Sender: TObject);
begin
  seAnswer.Text:='';
end;

procedure TEmerAPIDebugConsoleForm.BitBtn5Click(Sender: TObject);
begin
  mRequest.Text:='getrawtransaction {txid:"b1fd3e1cea613261efa1d2ba4746da93e0b53d6008ac5793f60aafe8175acb94",verbose:2}';

  //cWay.ItemIndex:=0;
  bSend.Click;
end;

procedure TEmerAPIDebugConsoleForm.BitBtn6Click(Sender: TObject);
begin
  mRequest.lines.Clear;
  mRequest.lines.append('query {          ');
  mRequest.lines.append('userconfig(name: "test") {          ');
  mRequest.lines.append('    name    ');
  mRequest.lines.append('    jsonvalue ');
  mRequest.lines.append('  }         ');
  mRequest.lines.append('}           ');
end;


procedure TEmerAPIDebugConsoleForm.BitBtn7Click(Sender: TObject);
begin
  mRequest.lines.Clear;
  mRequest.lines.append('mutation {          ');
  mRequest.lines.append('updateuserconfig(name: "test", jsonvalue: "{\"a\":{\"b1\": \"c2\"}}") { ');
  mRequest.lines.append('    name    ');
  mRequest.lines.append('    jsonvalue ');
  mRequest.lines.append('  }         ');
  mRequest.lines.append('}           ');
end;

procedure TEmerAPIDebugConsoleForm.BitBtn8Click(Sender: TObject);
begin
  mRequest.lines.Clear;
  mRequest.lines.append('mutation {          ');
  mRequest.lines.append('deleteuserconfig(name: "test") { ');
  mRequest.lines.append('    name    ');
  mRequest.lines.append('  }         ');
  mRequest.lines.append('}           ');
end;

procedure TEmerAPIDebugConsoleForm.BitBtn9Click(Sender: TObject);
begin
  mRequest.lines.Clear;
  mRequest.lines.append('mutation {          ');
  mRequest.lines.append('createuserconfig(name: "test", jsonvalue: "{\"a\":{\"b\": \"c\"}}") {          ');
  mRequest.lines.append('    name                                                                       ');
  mRequest.lines.append('  }          ');
  mRequest.lines.append('}          ');
end;

end.

