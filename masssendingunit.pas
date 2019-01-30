unit masssendingunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, StdCtrls, SynEdit;

type

  { TMassSendingForm }

  TMassSendingForm = class(TForm)
    bTest: TBitBtn;
    bSend: TBitBtn;
    BitBtn2: TBitBtn;
    chSendSameAmount: TCheckBox;
    eAmountToAll: TEdit;
    lInfo: TLabel;
    Panel1: TPanel;
    SynEdit1: TSynEdit;
    procedure BitBtn2Click(Sender: TObject);
    procedure bSendClick(Sender: TObject);
    procedure bTestClick(Sender: TObject);
    function fillToSend():tStringList;
    procedure SendingError(Sender: TObject);
    procedure Sent(Sender: TObject);

  private


  public
    LastError:string;
  end;

var
  MassSendingForm: TMassSendingForm;

implementation

{$R *.lfm}
uses helperUnit, crypto, MainUnit, EmerAPITransactionUnit, emerapitypes;

{ TMassSendingForm }

function TMassSendingForm.fillToSend:tStringList;
var i:integer;
    s,adr:ansistring;
    v:double;
    n:integer;
begin

  n:=0;
  if chSendSameAmount.Checked then begin
    try
      v:=myStrToFloat(eAmountToAll.text);
    except
      LastError:=LastError+'Amount to send is incorrect ';
      exit;
    end;
    if v<=0 then begin
      LastError:=LastError+'Amount to send is wrong';
      exit;
    end;
    n:=round(v*1000000);
  end;


  result:=tStringList.create;
  for i:=0 to SynEdit1.lines.count-1 do begin
     s:=trim(SynEdit1.lines[i]);
     if s<>'' then begin
        if (pos(' ',s)<1) and (not chSendSameAmount.Checked) then begin
          LastError:=LastError+'Line '+inttostr(i)+': wrong format "address value"'#13#10;
          continue;
        end;
        if (pos('',s)>0) and (chSendSameAmount.Checked) then begin
          LastError:=LastError+'Line '+inttostr(i)+': wrong format: value found?'#13#10;
          continue;
        end;

        if chSendSameAmount.Checked then begin
          adr:=s;
        end else begin
          adr:=copy(s,1,pos(' ',s)-1);
          delete(s,1,pos(' ',s));
          s:=trim(s);
          try
            v:=myStrToFloat(s);
          except
            LastError:=LastError+'Line '+inttostr(i)+': wrong value'#13#10;
            continue;
          end;
          if v<=0 then begin
            LastError:=LastError+'Line '+inttostr(i)+': wrong value'#13#10;
            continue;
          end;
          n:=round(v*1000000);
        end;

        try
          adr:= base58ToBufCheck(adr);
        except
          LastError:=LastError+'Line '+inttostr(i)+': wrong address'#13#10;
          continue;
        end;
        if (length(adr)>0) and (adr[1]<>MainForm.globals.AddressSig) then begin
          LastError:=LastError+'Line '+inttostr(i)+': wrong address or wrong network'#13#10;
          continue;
        end;

        if result.IndexOf(adr)>=0 then begin
          LastError:=LastError+'Line '+inttostr(i)+': address dublicated'#13#10;
          continue;
        end;

        result.AddObject(adr,tObject(pointer(n)));
     end;
  end;
end;

procedure TMassSendingForm.bSendClick(Sender: TObject);
begin
  Close;
end;

procedure TMassSendingForm.SendingError(Sender: TObject);
begin
  if Sender is tEmerTransaction
    then ShowMessageSafe('Sending error: '+tEmerTransaction(sender).lastError)
    else ShowMessageSafe('Sending error');
end;

procedure TMassSendingForm.Sent(Sender: TObject);
begin
  ShowMessageSafe('Successfully sent');
end;

procedure TMassSendingForm.BitBtn2Click(Sender: TObject);
var i:integer;
    lAddress:tStringList;
var
    v:qword;
    address:ansistring;
    tx:tEmerTransaction;

begin
  LastError:='';
  lAddress:=fillToSend;
  try
    if LastError<>'' then begin
      ShowMessageSafe(LastError);
      exit;
    end;


    //создаем платежную транзакцию
    tx:=tEmerTransaction.create(emerAPI,true);


    for i:=0 to lAddress.Count-1 do begin
      v:=integer(pointer(lAddress.Objects[i]));
      address:=lAddress[i];
      tx.addOutput(tx.createSpendScript(address),v);


    end;

    if tx.makeComplete then begin
      if tx.signAllInputs(MainForm.PrivKey) then begin
        tx.sendToBlockchain(EmerAPINotification(@Sent,'sent'));
        tx.addNotify(EmerAPINotification(@SendingError,'error'));

      end else showMessageSafe('Can''t sign all transaction inputs using current key: '+tx.LastError);
    end else showMessageSafe('Can''t create transaction: '+tx.LastError);

  finally
    lAddress.free;
  end;


end;

procedure TMassSendingForm.bTestClick(Sender: TObject);
var i:integer;
    lAddress:tStringList;
    n:dword;
begin
  lInfo.Caption:='';
  LastError:='';
  lAddress:=fillToSend;
  try
    if LastError<>'' then begin
      ShowMessageSafe(LastError);
      lInfo.Caption:='Error';
    end else begin
      n:=0;
      for i:=0 to lAddress.Count-1 do
        n:=n+ integer(pointer(lAddress.Objects[i]));
      lInfo.Caption:='Send '+myFloatToStr(n/1000000)+' EMC to '+ inttostr(lAddress.Count)+ ' addresses';
    end;
  finally
    lAddress.free;
  end;

end;

end.

