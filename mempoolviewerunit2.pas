unit MempoolViewerUnit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, Grids, StdCtrls, fpjson, jsonparser, EmerAPIBlockchainUnit;

type

  { TMempoolViewerForm2 }

  TMempoolViewerForm2 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    CheckBox1: TCheckBox;
    Panel1: TPanel;
    StringGrid1: TStringGrid;
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure updateCalled(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    fLastUpdateTimePool:tDateTime;
    procedure cleanGrid;
  public

  end;

var
  MempoolViewerForm2: TMempoolViewerForm2;

implementation

{$R *.lfm}
uses MainUnit, settingsUnit, helperUnit, EmerAPIMain, emertx, CreateRawTXunit, crypto, emerapitypes;

{ TMempoolViewerForm2 }
procedure TMempoolViewerForm2.updateCalled(Sender: TObject);
var {js,e:tJsonData;
    s:string;
    x:double;
    i,n,m:integer;
    st:ansistring;
    l:tStringList;
    tx:ttx;
    NameScript:tNameScript;
    }
  i,n,m,j:integer;
  s:string;
begin

   if emerAPI=nil then exit;
   if emerAPI.EmerAPIConnetor=nil then exit;

   //1. do we need to clear?
   for n:=1 to StringGrid1.RowCount-1 do
     if emerAPI.mempool.IndexOf(StringGrid1.Cells[1,n])<0 then begin
       cleanGrid;
       break;
     end;
   //2. checking for adding
   n:=StringGrid1.RowCount;
   if (n=2) and (StringGrid1.Cells[1,1]='') then n:=1;
   for i:=0 to emerAPI.mempool.Count-1 do
     if StringGrid1.Cols[1].IndexOf(uppercase(bufToHex(emerAPI.mempool[i].getTXID)))<0 then
     begin
       //add
       if n>1 then StringGrid1.RowCount:=StringGrid1.RowCount+1;

       StringGrid1.Cells[1,n]:=uppercase(bufToHex(emerAPI.mempool[i].getTXID));
       //Adding tx data
       //tx:=unpackTX(hexToBuf(e.asString));
       //StringGrid1.Cells[2,0]:='Type';
       case emerAPI.mempool[i].version of
         $666:StringGrid1.Cells[2,n]:='Name'
       else
         StringGrid1.Cells[2,n]:=inttostr(emerAPI.mempool[i].version);
       end;
       //StringGrid1.Cells[3,0]:='DateTime';
       StringGrid1.Cells[3,n]:=datetimetostr(unixTimeToWinTime(emerAPI.mempool[i].time));
       //StringGrid1.Cells[4,0]:='LockTime';
       if emerAPI.mempool[i].locktime<1000000 then
         StringGrid1.Cells[4,n]:='blk '+inttostr(emerAPI.mempool[i].locktime)
       else
         StringGrid1.Cells[4,n]:=datetimetostr(unixTimeToWinTime(emerAPI.mempool[i].locktime));
       //StringGrid1.Cells[5,0]:='Ins';
       StringGrid1.Cells[5,n]:=inttostr(emerAPI.mempool[i].insCount);


       m:=0;
       s:='';
       for j:=0 to emerAPI.mempool[i].outsCount-1 do begin
         m:=m+emerAPI.mempool[i].Outs[j].value;
         //NameScript:=nameScriptDecode(tx.Outs[i].script);
         s:=s+' '+inttostr(j);

         case  emerAPI.mempool[i].Outs[j].getType of
           #$51:s:=s+': NEW NAME:"'+scriptDataBufToText(emerAPI.mempool[i].Outs[j].getNVSName,true)+'"';
           #$52:s:=s+': NAME UPDATE:"'+scriptDataBufToText(emerAPI.mempool[i].Outs[j].getNVSName,true)+'"';
           #$53:s:=s+': NAME DELETE:"'+scriptDataBufToText(emerAPI.mempool[i].Outs[j].getNVSName,true)+'"';
         end;
         s:=s+': '+buf2Base58Check(mainForm.globals.AddressSig+emerAPI.mempool[i].Outs[j].getReceiver)+'['+inttostr(emerAPI.mempool[i].Outs[j].value)+']';
       end;

       s:=inttostr(emerAPI.mempool[i].outsCount)+': ['+inttostr(m)+']:'+s;
       StringGrid1.Cells[6,n]:=s;

       inc(n);
     end;




 (*
  //rebuild
  js:=result;
  if pos('getrawmempool_',sender.id+'_')=1 then begin
   if js<>nil then begin
    e:=js.FindPath('result');
    if (e<>nil) then begin
        //result=["5563aa42ebfb20333b0c52108d45e0d7fa8f6376af9fdc8c451552df4ce2161e", "f83338ef7b9149dde00c0cb806b8f97de29aa7acfe6dc5cae3b63256822c1b50", "efe31bd29f5bdfc30ab4e77c8fa95799c01c4d98d82dabaeb4f83506161e1850"]
       fLastUpdateTimePool:=now;

       if (not e.IsNull) then begin
         //If some transanction was dissapeared, we must rebild all

        l:=tStringList.Create;
        try
          for i:=0 to tJSONArray(e).Count-1 do
            l.Append(UPPERCASE(tJSONArray(e)[i].AsString));
          // need cleaning?
          for n:=1 to StringGrid1.RowCount-1 do
            if l.IndexOf(StringGrid1.Cells[1,n])<0 then begin
              cleanGrid;
              break;
            end;
           n:=StringGrid1.RowCount;
           if (n=2) and (StringGrid1.Cells[1,1]='') then n:=1;

           for i:=0 to l.Count-1 do begin
             if (not CheckBox1.Checked) {or (emerAPI.UTXOList.)} then
             if StringGrid1.Cols[1].IndexOf(l[i])<0 then
             begin
               if n>1 then StringGrid1.RowCount:=StringGrid1.RowCount+1;
               StringGrid1.Cells[1,n]:=l[i];
               //step 2. receiving all tx from the mempool
               if CheckBox2.Checked then
                 emerAPI.EmerAPIConnetor.sendWalletQueryAsync('getrawtransaction',
                     getJSON('{txid:"'+l[i]+'"}')
                    ,@onBlockchainData,'getrawtransactionPull_'+emerAPI.EmerAPIConnetor.getNextID);

               inc(n);
             end;
           end;
        finally
          l.Free;
        end;
       end;
    end;
   end;
  end else
  if pos('getrawtransactionPull_',sender.id)=1 then begin
   if CheckBox2.Checked and (js<>nil) then begin
    e:=js.FindPath('result');
    if (e<>nil) and (not e.IsNull) then begin
      //we have received a raw tx.
      s:=UPPERCASE(bufToHex(reverse(dosha256(dosha256(hexToBuf(e.asString))))));//txid
      n:=StringGrid1.Cols[1].IndexOf(s);
      if n>0 then begin
        tx:=unpackTX(hexToBuf(e.asString));
        //StringGrid1.Cells[2,0]:='Type';
        case tx.version of
          $666:StringGrid1.Cells[2,n]:='Name'
        else
          StringGrid1.Cells[2,n]:=inttostr(tx.version);
        end;
        //StringGrid1.Cells[3,0]:='DateTime';
        StringGrid1.Cells[3,n]:=datetimetostr(unixTimeToWinTime(tx.time));
        //StringGrid1.Cells[4,0]:='LockTime';
        if tx.locktime<1000000 then
          StringGrid1.Cells[4,n]:='blk '+inttostr(tx.locktime)
        else
          StringGrid1.Cells[4,n]:=datetimetostr(unixTimeToWinTime(tx.locktime));
        //StringGrid1.Cells[5,0]:='Ins';
        StringGrid1.Cells[5,n]:=inttostr(length(tx.ins));
        //StringGrid1.Cells[6,0]:='Outs: [count] total_spend : details ';

        m:=0;
        s:='';
        for i:=0 to length(tx.Outs)-1 do begin
          m:=m+tx.Outs[i].value;
          NameScript:=nameScriptDecode(tx.Outs[i].script);
          s:=s+' '+inttostr(i);
          case NameScript.TXtype of
            #$51:s:=s+': NEW NAME:"'+scriptDataBufToText(NameScript.Name,true)+'"';
            #$52:s:=s+': NAME UPDATE:"'+scriptDataBufToText(NameScript.Name,true)+'"';
            #$53:s:=s+': NAME DELETE:"'+scriptDataBufToText(NameScript.Name,true)+'"';
          end;
          s:=s+': '+buf2Base58Check(mainForm.globals.AddressSig+NameScript.Owner)+'['+inttostr(tx.Outs[i].value)+']';
        end;

        s:=inttostr(length(tx.Outs))+': ['+inttostr(m)+']:'+s;
        StringGrid1.Cells[6,n]:=s;

      end;
    end;
   end;
  end;
  *)
end;

procedure TMempoolViewerForm2.BitBtn2Click(Sender: TObject);
var s:ansistring;
begin
  if StringGrid1.Selection.Top>0 then
   s:= trim(StringGrid1.Cells[1,StringGrid1.Selection.Top])
  else exit;
  if s='' then exit;


  MainForm.MenuItem21Click(nil);
  CreateRawTXForm.Edit6.text:=s;
  CreateRawTXForm.Button8Click(nil);

end;

procedure TMempoolViewerForm2.BitBtn3Click(Sender: TObject);
begin
 cleanGrid;

 BitBtn1.Click;
end;

procedure TMempoolViewerForm2.FormCreate(Sender: TObject);
begin
   while StringGrid1.ColCount<7 do
     StringGrid1.Columns.Add;

   StringGrid1.Columns[1].Title.Caption:='Type';
   StringGrid1.ColWidths[2]:=40;

   StringGrid1.Columns[2].Title.Caption:='DateTime';
   StringGrid1.ColWidths[3]:=110;

   StringGrid1.Columns[3].Title.Caption:='LockTime';
   StringGrid1.ColWidths[4]:=110;

   StringGrid1.Columns[4].Title.Caption:='Ins';
   StringGrid1.ColWidths[5]:=20;

   StringGrid1.Columns[5].Title.Caption:='Outs: [count] total_spend : details ';
   StringGrid1.ColWidths[6]:=600;
end;

procedure TMempoolViewerForm2.cleanGrid;
var i:integer;
begin
   StringGrid1.RowCount:=2;
   for i:=1 to StringGrid1.ColCount-1 do StringGrid1.cells[i,1]:='';
end;



procedure TMempoolViewerForm2.BitBtn1Click(Sender: TObject);
begin
   //cleanGrid;
  updateCalled(nil);

   //sign for UTXO update notification
   if emerAPI.UTXOList<>nil then
     emerAPI.UTXOList.addNotify(EmerAPINotification(@updateCalled,'updateUTXO',true)) ;
   if emerAPI.memPool<>nil then
     emerAPI.memPool.addNotify(EmerAPINotification(@updateCalled,'update',true)) ;

end;

end.

