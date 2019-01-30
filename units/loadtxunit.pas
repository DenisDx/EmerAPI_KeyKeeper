unit LoadTXunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, fpjson, Forms, Controls, Graphics, Dialogs, StdCtrls, EmerAPIBlockchainUnit;

type

  { TLoadTXForm }

  TLoadTXForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    eTxID: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo2: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AsyncAddressInfoDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
  private

  public

  end;

var
  LoadTXForm: TLoadTXForm=nil;

function askUserForTX(txHex:ansistring=''):ansistring;

implementation

{$R *.lfm}
uses Crypto, EmerApiTestUnit, MainUnit;

function askUserForTX(txHex:ansistring=''):ansistring;
begin
  if LoadTXForm=nil
    then Application.CreateForm(TLoadTXForm, LoadTXForm);

  result:='';

  LoadTXForm.memo2.Text:=trim(txHex);
  LoadTXForm.eTxID.Text:='';

  if LoadTXForm.ShowModal = mrOk then

  result:=hexToBuf(trim(LoadTXForm.Memo2.Text ));
end;

{ TLoadTXForm }

procedure TLoadTXForm.Button1Click(Sender: TObject);
begin
  modalresult:=mrOk;
end;

procedure TLoadTXForm.Button2Click(Sender: TObject);
var s,tx:ansistring;
var json:TJSONObject;
    ja,ja1:TJSONArray;
    i,j:integer;
begin
  //Memo1.lines.clear;
  tx:=trim(eTxID.text);
  if length(tx)=0 then exit;
  if tx[1]<>'"' then tx:='"'+tx+'"';

  s:=getEmerRPCAnswer(
    //'query { gettransaction(txid:'+txr[i]+',includeWatchonly:true) { answer }}'
    'query { getrawtransaction(txid:'+tx+',verbose:1) { answer }}'
  );

  if s='' then begin
    //Memo1.Lines.Append('Error obtaining tx info');
    raise exception.Create('Error obtaining tx info');
  end;

  json := TJSONObject(GetJSON(changeNone(changeQuotes(s))));
  //Memo1.lines.append('rec tx:'+tx+':');
  //json.Elements['result'].
  //Memo1.lines.append(json.AsJSON);
  memo2.Text:=TJSONObject(json.Elements['result']).Elements['hex'].asString;


  {
  ja:=TJSONArray(TJSONObject(json.Elements['result']).Elements['vout']);
  for j:=0 to ja.Count-1 do begin
     if TJSONObject(TJSONObject(ja[j]).Elements['scriptPubKey']).IndexOfName('addresses')>=0 then begin
       ja1:=TJSONArray(TJSONObject(TJSONObject(ja[j]).Elements['scriptPubKey']).Elements['addresses']);
       Memo1.lines.append('    tst:'+ja1[0].AsJSON+'');

     end else Memo1.lines.append('    tst: non-transfer tx');

//     if (ja1.Count=1) and (TJSONObject(ja1[0]).AsString=trim(Edit3.Text)) then begin
//
//       Memo1.lines.append('    txo:'+ inttostr(round(1000000*TJSONObject(ja[j]).Elements['value'].AsFloat))+'');
//     end;
  end;
  }
end;

procedure TLoadTXForm.AsyncAddressInfoDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
  var js,e:tJsonData;
      s:string;
      val,x:double;
      nc,i:integer;
      st:ansistring;
begin
 if result=nil then begin
   Memo2.Text:='Error: '+sender.lastError;
   exit;
 end;

 js:=result;

 if js<>nil then begin
   e:=js.FindPath('result');
   if e<>nil then
      try
         Memo2.Text:=e.AsString;
      except
        Memo2.Text:='Error: incorrect result in: '+js.AsJSON;
      end
   else Memo2.Text:='Error: can''t find result in: '+js.AsJSON;
 end else Memo2.Text:='Error: empty result';
end;

procedure TLoadTXForm.Button3Click(Sender: TObject);
begin
  if emerAPI=nil then exit;
  Memo2.Text:='please wait...';

  //e745e0f1f55604cd6377bddfe94c7b6db6a88c4d291fb8facb3c86a6a6eb0e0b
  //blockChain.sendQueryAsync('getrawtransaction',['"txid":"'+eTxID.Text+'"'],@AsyncAddressInfoDone);

  //['"'+eTxID.Text+'"']
  //  ['"txid":"'+eTxID.Text+'"']
 // emerAPI.blockChain.sendQueryAsync('getrawtransaction',GetJSON('"'+eTxID.Text+'"'),@AsyncAddressInfoDone);
  emerAPI.EmerAPIConnetor.sendWalletQueryAsync('getrawtransaction',GetJSON('{"txid":"'+eTxID.Text+'"}'),@AsyncAddressInfoDone);

end;

procedure TLoadTXForm.FormShow(Sender: TObject);
begin

end;

end.

