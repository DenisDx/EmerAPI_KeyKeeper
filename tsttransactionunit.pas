unit tsttransactionUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ValEdit, Grids, EmerTX;

type

  { TForm4 }

  TForm4 = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    Memo5: TMemo;
    Memo6: TMemo;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure StringGrid2SelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
  private
    function addId():ansistring;

  public

  end;





var
  Form4: TForm4;



implementation

{$R *.lfm}
uses USha256, crypto, CryptoLib4PascalConnectorUnit, UOpenSSLdef, UOpenSSL, PodbiralkaUnit
  ,fpjson, jsonparser
  ,EmerApiTestUnit
  ;

{ TForm4 }

procedure TForm4.Button1Click(Sender: TObject);
var s,tx:ansistring;
var json:TJSONObject;
    ja,ja1:TJSONArray;
    i,j:integer;
begin
  Memo1.lines.clear;
  tx:=trim(edit1.text);
  if length(tx)=0 then exit;
  if tx[1]<>'"' then tx:='"'+tx+'"';

  s:=getEmerRPCAnswer(
    //'query { gettransaction(txid:'+txr[i]+',includeWatchonly:true) { answer }}'
    'query { getrawtransaction(txid:'+tx+',verbose:1) { answer }}'
  );

  if s='' then begin
    Memo1.Lines.Append('Error obtaining tx info');
  end;

  json := TJSONObject(GetJSON(changeNone(changeQuotes(s))));
  Memo1.lines.append('rec tx:'+tx+':');
  //json.Elements['result'].
  //Memo1.lines.append(json.AsJSON);
  memo2.Text:=TJSONObject(json.Elements['result']).Elements['hex'].asString;


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

end;

procedure TForm4.Button10Click(Sender: TObject);
var s:ansistring;
var json:TJSONObject;

begin
  //fill work data
  memo4.lines.clear;
  Edit10.Text:='';
  Edit11.Text:='';

  s:=trim(Edit6.text);
  if length(s)=0 then exit;
  if s[1]<>'"' then s:='"'+s+'"';

  s:=getEmerRPCAnswer(
    'query { getrawtransaction(txid:'+s+',verbose:1) { answer }}'
  );
  if s='' then begin
    Memo1.Lines.Append('Error obtaining tx info');
    exit;
  end;


  json := TJSONObject(GetJSON(changeNone(changeQuotes(s))));


  memo4.Text:=TJSONObject(json.Elements['result']).Elements['hex'].asString;

  json.free;
end;


function TForm4.addId():ansistring;
begin

  result:='';
  if trim(Combobox1.Text)<>'' then
    if pos(' ',trim(Combobox1.Text))>0
        then result:=chr(strtoint(
           copy(
              trim(Combobox1.Text)
              ,1
              ,pos(' ',trim(Combobox1.Text))-1
              )))
        else result:=chr(strtoint(trim(Combobox1.Text)));
end;

procedure TForm4.Button11Click(Sender: TObject);
var tx:ttx;
//    i:integer;
begin
  tx:=unpacktx(hexToBuf(trim(Memo4.text)));
//  for i:=0 to length(tx.outs)-1 do
//    if tx.outs[i].;
  if strtoint(Edit9.Text)>=length(tx.outs) then raise exception.Create('There is no output '+Edit9.Text);
  Edit10.Text:=bufToHex(tx.outs[strtoint(Edit9.Text)].script);
  Edit11.Text:=scriptExplain(tx.outs[strtoint(Edit9.Text)].script,addId());
end;

procedure TForm4.Button13Click(Sender: TObject);
var tx:ttx;
begin
  tx:=unpacktx(hexToBuf(trim(memo2.Text)));


  Edit14.Text:=bufToHex(hashForSignature(tx, strtoint(trim(Edit9.Text)) ,hexToBuf(trim(Edit10.Text)), 0));
end;

procedure TForm4.Button14Click(Sender: TObject);
begin
  //fill all
  //Transaction ID: 86e811babe494d181ce3abd3fc68116da85bd3bc49426e16a6dddc052b808238
  // hex: 0100000029ed835b01bbfcbcd97c8a6d9a81f078c120f3fb24b3677e095eee081a99d4e3d4de2e68fb000000006b483045022100ab804e30ff27da7d36426dabb6e7d106c871a4bb4901cb35d4d59a23e91745740220437398aa4d7d8d483909c7a24a0875e8112aae1e34650146cf04a0b066a32059012102d873e50696be65983a1058a92fbc69fbb7763ddf4471ef8da9d52c5f347f9fd1feffffff025c1bc1b2000000001976a9145a81a5f4262396cda59c3f0e24f21636be1faf2d88ac40420f00000000001976a9145ec7f2d15a1f20eab67d60f09effca58b43eee9f88ac383c0000
  //1 input for  mpgyT6deSNSPNc1kmySvEiSHryfdzNGJ7c PK: cT4Swqnt3Aaj15T8e53FqEv6p6ZhSpczKQn3LR3FM9PuBd4zbB2e
  //  input TX info:fb682eded4e3d4991a08ee5e097e67b324fbf320c178f0819a6d8a7cd9bcfcbb Vout=0
  //  script for sign:
  //  scriptSig  "asm": "3045022100ab804e30ff27da7d36426dabb6e7d106c871a4bb4901cb35d4d59a23e91745740220437398aa4d7d8d483909c7a24a0875e8112aae1e34650146cf04a0b066a32059[ALL] 02d873e50696be65983a1058a92fbc69fbb7763ddf4471ef8da9d52c5f347f9fd1"
  //  hex: 483045022100ab804e30ff27da7d36426dabb6e7d106c871a4bb4901cb35d4d59a23e91745740220437398aa4d7d8d483909c7a24a0875e8112aae1e34650146cf04a0b066a32059012102d873e50696be65983a1058a92fbc69fbb7763ddf4471ef8da9d52c5f347f9fd1
  //  script for sign: "OP_DUP OP_HASH160 649e41b014a856eb56af9098696e8aaf5904b103 OP_EQUALVERIFY OP_CHECKSIG",
  //      "hex": "76a914649e41b014a856eb56af9098696e8aaf5904b10388ac",
  //        "reqSigs": 1,
  //        "type": "pubkeyhash",
  //        "addresses": [
  //          "mpgyT6deSNSPNc1kmySvEiSHryfdzNGJ7c"

  //2 outs:
  // 1. send 2999 to momWRSLBtjZHZYHhLLb9CCnbLdcC3cbRBd
  //   script:76a9145a81a5f4262396cda59c3f0e24f21636be1faf2d88ac = OP_DUP OP_HASH160 5a81a5f4262396cda59c3f0e24f21636be1faf2d OP_EQUALVERIFY OP_CHECKSIG
  // 2. send 1 to mpA7LkZe8TKNMgTPJVbn5StQ6Yh28fXg1d
  //   script: 76a9145ec7f2d15a1f20eab67d60f09effca58b43eee9f88ac

  Memo6.Text:='0100000029ed835b01bbfcbcd97c8a6d9a81f078c120f3fb24b3677e095eee081a99d4e3d4de2e68fb000000006b483045022100ab804e30ff27da7d36426dabb6e7d106c871a4bb4901cb35d4d59a23e91745740220437398aa4d7d8d483909c7a24a0875e8112aae1e34650146cf04a0b066a32059012102d873e50696be65983a1058a92fbc69fbb7763ddf4471ef8da9d52c5f347f9fd1feffffff025c1bc1b2000000001976a9145a81a5f4262396cda59c3f0e24f21636be1faf2d88ac40420f00000000001976a9145ec7f2d15a1f20eab67d60f09effca58b43eee9f88ac383c0000';
  Edit12.Text:='cT4Swqnt3Aaj15T8e53FqEv6p6ZhSpczKQn3LR3FM9PuBd4zbB2e';
  Edit9.Text:='0';
  //Edit10.Text:='76a914649e41b014a856eb56af9098696e8aaf5904b10388ac';
  Edit10.Text:='FB682EDED4E3D4991A08EE5E097E67B324FBF320C178F0819A6D8A7CD9BCFCBB';   // ->eb6dbd6ca13c3af624c467b5c5145d50fa53f17f0fd0ed4cd4e4aac8b1703df8
  Memo5.Text:='';


  //-------------------------------------
  //Name:Transaction ID: b795325df1d7584d56501a961cc595d22822cc0f9e84a44099ba2630969c35f1
  //hex:
  // 66060000f20e995b015cb420782caf458f74cec7b6c2b328f51d2795212664e046c85f4055231638c2000000006b483045022100d0b0fe6c6f730598365914f13d597df4c2e522bb4af9f03ae50742c69e842428022072a5ddc48ffeef17c1ac27db9f451bbbc5ecd46e4b16ceaf486d42af1d65707e012102f123349e17d9e42947115b494edc9c03ab30fb7b6c6428a032d2da95dc53f361feffffff02640000000000000033517503747374020f276d0e747374310a747374320a747374337576a9141499229323159c6f91e04e7d00ae34b2991e43b788ac5cb80e00000000001976a914ced2436c4d0169b69e8e71c413dc5c5b20f5376388ac30480000

  //1 Input: 483045022100d0b0fe6c6f730598365914f13d597df4c2e522bb4af9f03ae50742c69e842428022072a5ddc48ffeef17c1ac27db9f451bbbc5ecd46e4b16ceaf486d42af1d65707e012102f123349e17d9e42947115b494edc9c03ab30fb7b6c6428a032d2da95dc53f361
  // = 3045022100d0b0fe6c6f730598365914f13d597df4c2e522bb4af9f03ae50742c69e842428022072a5ddc48ffeef17c1ac27db9f451bbbc5ecd46e4b16ceaf486d42af1d65707e[ALL] 02f123349e17d9e42947115b494edc9c03ab30fb7b6c6428a032d2da95dc53f361
  // выход 0 tx = c238162355405fc846e064262195271df528b3c2b6c7ce748f45af2c7820b45c
  //выходы:
  //0: 1 OP_DROP 7631732 9999 OP_2DROP 747374310a747374320a74737433 OP_DROP OP_DUP OP_HASH160 1499229323159c6f91e04e7d00ae34b2991e43b7 OP_EQUALVERIFY OP_CHECKSIG
  // 517503747374020f276d0e747374310a747374320a747374337576a9141499229323159c6f91e04e7d00ae34b2991e43b788ac
  // to add mhPsFuD6srgjVXMR2VdP45tpco3C5GStst

  //инфо по c238162355405fc846e064262195271df528b3c2b6c7ce748f45af2c7820b45c , выход 0:
  // mzpTMamszmAMcUmTab8vF6HuPgPHwSSUyo
  // pk=  cNKkQg9qi7Akg2LJB1uQfLCXa5beKRoidRPdjojcod2pzyYMGxhY

end;


function serial2test():ansistring;
//void Serialize(S &s) const {
var s:string;
begin

{
mystart
56944c5d3f98413ef45cf54545538103cc9f298e0575820ad3591376e2e0f65d
nVersion=1
d9b7ee180ad76601acf71f538628cf78f88f9e07684d7cb459ef682b8fc02108
nTime=1537286472
ddf29b2289f64d3dced7af47cb1a8ffd7840b960bcabadd79f0a3c8c9012841c
nInput=0
fb8363c7a2a717e19b840cc471b062eb3dcde43f59536af025540562f2ec11f6
nOutput=0
5983c91e0ee34c25151ea5213cae186c180156417b31b1f2bb7653820d4f2907
nOutput=1
57d8b4b5844e79413d5a99817bb16e4aa46e23a6d8ce61927851df389836fa28
nOutput=2
1a28fb33aaa33bb2f20c98765b195cb87997985b163438fd1bf752d422dcd297
nLockTime=0
25b8ded6a8ddc3d093c9b67f2f5659150d3328c20750138c7e8791d3b0e66cd5
}
  result:='';
  s:='';

  //cout << "mystart" << endl;
  result:= result + 'mystart'+#13#10;
  //cout << s.GetHash().ToString() << endl;
  result:=result + bufToHex(dosha256(s))+#13#10;

  // Serialize nVersion
  //::Serialize(s, txTo.nVersion);
  //cout << "nVersion=" << txTo.nVersion << endl;
  //cout << s.GetHash().ToString() << endl;
  result:= result + 'nVersion=1'+#13#10;
  s:=s+#0#0#0#1;
  result:=result + bufToHex(dosha256(s))+#13#10;


  // Serialize nTime
  //::Serialize(s, txTo.nTime);
  //cout << "nTime=" << txTo.nTime << endl;
  //cout << s.GetHash().ToString() << endl;
  result:= result + 'nTime=1537286472'+#13#10;
  s:=s+hexToBuf('5BA12148');
  result:=result + bufToHex(dosha256(s))+#13#10;


(*
  // Serialize vin
  unsigned int nInputs = fAnyoneCanPay ? 1 : txTo.vin.size();
  ::WriteCompactSize(s, nInputs);
  for (unsigned int nInput = 0; nInput < nInputs; nInput++) {
       SerializeInput(s, nInput);
       cout << "nInput=" << nInput << endl;
       cout << s.GetHash().ToString() << endl;
  }
  // Serialize vout
  unsigned int nOutputs = fHashNone ? 0 : (fHashSingle ? nIn+1 : txTo.vout.size());
  ::WriteCompactSize(s, nOutputs);
  for (unsigned int nOutput = 0; nOutput < nOutputs; nOutput++) {
       SerializeOutput(s, nOutput);
       cout << "nOutput=" << nOutput << endl;
       cout << s.GetHash().ToString() << endl;
  }
  // Serialize nLockTime
  ::Serialize(s, txTo.nLockTime);
  cout << "nLockTime=" << txTo.nLockTime << endl;
  cout << s.GetHash().ToString() << endl;
 *)
end;
procedure TForm4.Button15Click(Sender: TObject);
begin
  memo1.text:=serial2test();
end;

procedure TForm4.Button16Click(Sender: TObject);
begin
  Memo6.Text:='020000005601a25b018ec686e5ab29ed8a8639c87f096ec8c227f250e16982c77145d0fc085a0c69d40000000000ffffffff01dc410f00000000001976a914649e41b014a856eb56af9098696e8aaf5904b10388ac00000000';
  Edit12.Text:='cT4Swqnt3Aaj15T8e53FqEv6p6ZhSpczKQn3LR3FM9PuBd4zbB2e';
  Edit9.Text:='0';
 // Edit10.Text:='d4690c5a08fcd04571c78269e150f227c2c86e097fc839868aed29abe586c68e';
  Edit10.Text:='76A914649E41B014A856EB56AF9098696E8AAF5904B10388AC'; //Предыдущий out скрипт

  Memo5.Text:='';
end;





procedure TForm4.Button2Click(Sender: TObject);
var
    txhex:ansistring;
    txbin:ansistring;
    tx:ttx;
    i,j:integer;


begin
  //unpack tx
  txhex:=trim(memo2.Text);
  txbin:=hexToBuf(txhex);

  tx:=unpacktx(txbin);


  edit2.Text:=inttostr(tx.version);
  edit3.Text:=inttostr(tx.time);
  edit4.Text:=inttostr(tx.locktime);

  StringGrid1.Cells[0,0]:='#';
  StringGrid1.Cells[1,0]:='Hash';
  StringGrid1.Cells[2,0]:='index';
  StringGrid1.Cells[3,0]:='script';
  StringGrid1.Cells[4,0]:='sequence';
  StringGrid1.Cells[5,0]:='witness';
  StringGrid1.Cells[6,0]:='Script decode (read only)';

  StringGrid1.ColWidths[0]:=20;
  StringGrid1.RowCount:=length(tx.ins)+1;

  for i:=0 to length(tx.ins)-1 do begin
    StringGrid1.Cells[0,i+1]:=inttostr(i);
    StringGrid1.Cells[1,i+1]:=bufToHex(tx.ins[i].hash);
    StringGrid1.Cells[2,i+1]:=inttostr(tx.ins[i].index);
    StringGrid1.Cells[3,i+1]:=bufToHex(tx.ins[i].script);
    StringGrid1.Cells[4,i+1]:=inttostr(tx.ins[i].sequence);

    if length(tx.ins[i].witness)>0 then begin
      StringGrid1.Cells[5,i+1]:='';
      for j:=0 to length(tx.ins[i].witness) -1 do
        StringGrid1.Cells[5,i+1]:=StringGrid1.Cells[5,i+1] + bufToHex(tx.ins[i].witness[j]) + ' ';
      StringGrid1.Cells[5,i+1]:=trim(StringGrid1.Cells[5,i+1]);
    end else StringGrid1.Cells[5,i+1]:='';

    StringGrid1.Cells[6,i+1]:=decodeInScript(tx.ins[i].script);

  end;

  StringGrid2.Cells[0,0]:='#';
  StringGrid2.Cells[1,0]:='Value';
  StringGrid2.Cells[2,0]:='Script';
  StringGrid2.Cells[3,0]:='Explain (read only)';

  StringGrid2.ColWidths[0]:=20;
  StringGrid2.ColWidths[1]:=100;
  StringGrid2.RowCount:=length(tx.outs)+1;

  for i:=0 to length(tx.outs)-1 do begin
    StringGrid2.Cells[0,i+1]:=inttostr(i);
    StringGrid2.Cells[1,i+1]:=inttostr(tx.outs[i].value);
    StringGrid2.Cells[2,i+1]:=bufToHex(tx.outs[i].script);
    StringGrid2.Cells[3,i+1]:=scriptExplain(tx.outs[i].script,addId);
  end;

  Button3.Click;

end;

procedure TForm4.Button3Click(Sender: TObject);
var tx:ttx;
    i:integer;
    s:ansistring;
begin
  tx.version:=strtoint64(edit2.Text);
  tx.time:=strtoint64(edit3.Text);
  tx.locktime:=strtoint64(edit4.Text);


  setLength(tx.ins,StringGrid1.RowCount-1);

  for i:=0 to StringGrid1.RowCount-1-1 do begin
    tx.ins[i].hash:=hexToBuf(StringGrid1.Cells[1,i+1]);
    tx.ins[i].index:=strtoint64(StringGrid1.Cells[2,i+1]);
    tx.ins[i].script:=hexToBuf(StringGrid1.Cells[3,i+1]);
    tx.ins[i].sequence:=strtoint64(StringGrid1.Cells[4,i+1]);
    if trim(StringGrid1.Cells[5,i+1])<>'' then begin
      //then raise exception.create('whitness is not supported here')
      s:=trim(StringGrid1.Cells[5,i+1])+' ';
      while trim(s)<>'' do begin
        setLength(tx.ins[i].witness,length(tx.ins[i].witness)+1);
        tx.ins[i].witness[length(tx.ins[i].witness)-1]:=hexToBuf(trim(copy(s,1,pos(' ',s))));
        delete(s,1,pos(' ',s));
        s:=trim(s)+' ';
      end;
    end else tx.ins[i].witness:=nil;
  end;


  setLength(tx.outs,StringGrid2.RowCount-1);

  for i:=0 to StringGrid2.RowCount-1-1 do begin
    tx.outs[i].value:=strtoint64(StringGrid2.Cells[1,i+1]);
    tx.outs[i].script:=hexToBuf(StringGrid2.Cells[2,i+1]);
  end;


  memo3.Text:=bufToHex(packtx(tx));

  Button4.Click;
end;

procedure TForm4.Button4Click(Sender: TObject);
begin

  edit5.text:=bufToHex(
    reverse(getTxHash(unPackTX(hexToBuf(trim(memo3.Text)))))
  );
end;

procedure TForm4.Button5Click(Sender: TObject);
begin
  Edit1.Text:=Edit6.text;
  Button1.Click;
  Button2.Click;
end;

procedure TForm4.Button6Click(Sender: TObject);
var tx:ttx;
    PrivateKey:ansistring;
    s:ansistring;
    pubKey:TECDSA_Public;
begin


  tx:=unpacktx(hexToBuf(trim(Memo6.text)));

  //function signIn(this:ttx;vin:integer; privKey:PEC_KEY; pubKey:TECDSA_Public; redeemScript:ansistring;hashType:dword; witnessValue:qword=VALUE_UINT64_MAX; witnessScript:ansistring='';keyCompressed:boolean=true):ansistring;

  //Edit14.Text

  s:=trim(Edit12.Text);
  try
    PrivateKey:=CreatePrivateKeyFromStrBuf(s);
  except
    s:=base58ToBufCheck(trim(edit12.text));
    delete(s,1,1);//удаляем сингатуру

    if not (((length(s)=33) and (s[33]=#1)) or (length(s)=32))
       then raise exception.create('wrong private key size');

    if not (((length(s)=33) and (s[33]=#1))) then raise exception.Create('Key must be compressed');

    PrivateKey:=CreatePrivateKeyFromStrBuf(s);
  end;


//!  if s[1]<>hexToBuf( trim(edit12.text))
//!    then raise exception.create('Wrong wif signature. Must be '+bufToHex(hexToBuf( trim(edit12.text)))+' but found '+bufToHex(s[1]));

//function    signTxIn(this:ttx;vin:integer;                privKey:PEC_KEY; pubKey:TECDSA_Public; redeemScript:ansistring;hashType:dword; witnessValue:qword=VALUE_UINT64_MAX; witnessScript:ansistring='';keyCompressed:boolean=true):ansistring;

  Memo1.Lines.Add('HFS='+
    bufToHex(hashForSignature(
     tx//this:ttx;
     ,0 // inIndex:integer;
     ,hexToBuf(trim(Edit10.text))   // prevOutScript:ansistring;
     , 0 or SIGHASH_ALL))
  );


  pubKey.x:='';
  Memo5.Text:=bufToHex(signTxIn(tx      ,strToInt(trim(Edit9.Text)), PrivateKey,      @pubKey               ,hexToBuf(trim(Edit10.text)),      0          ) );
end;

procedure TForm4.Button7Click(Sender: TObject);
begin

end;

procedure TForm4.Button8Click(Sender: TObject);
begin
  edit1.Text:='C238162355405FC846E064262195271DF528B3C2B6C7CE748F45AF2C7820B45C';
end;

procedure TForm4.Button9Click(Sender: TObject);
begin
  edit1.Text:='b795325df1d7584d56501a961cc595d22822cc0f9e84a44099ba2630969c35f1';
end;

procedure TForm4.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  Edit6.text:=bufToHex(reverse(hexToBuf(StringGrid1.Cells[1,aRow])));

  Edit7.text:=StringGrid1.Cells[3,aRow];

  Edit9.Text:=StringGrid1.Cells[2,aRow];

end;

procedure TForm4.StringGrid2SelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  Edit8.Text:=scriptDecompile(hexToBuf(StringGrid2.Cells[2,aRow]),addId);
end;


end.

