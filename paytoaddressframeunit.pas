unit PayToAddressFrameUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, ExtCtrls, Buttons,
  FrameSelectAddressunit, GUIHelperUnit;

type

  { TFramePayToAddress }

  TFramePayToAddress = class(TFrame)
    sDevShowTX: TBitBtn;
    bSend: TBitBtn;
    eValue: TEdit;
    FrameSelectAddress1: TFrameSelectAddress;
    lBalance: TLabel;
    lPayee: TLabel;
    lAmount: TLabel;
    pTop: TPanel;
    pAddressFrame: TPanel;
    pTop1: TPanel;
    procedure bSendClick(Sender: TObject);
    procedure sDevShowTXClick(Sender: TObject);
  private
    procedure SendingError(Sender: TObject);
    procedure Sent(Sender: TObject);
  public
    procedure init(visualdata:tVisualData);
  end;

implementation

uses MainUnit, settingsUnit, helperUnit, EmerAPIMain, emertx, CreateRawTXunit, EmerApiTypes, EmerAPITransactionUnit, Localizzzeunit;

{$R *.lfm}

procedure TFramePayToAddress.sDevShowTXClick(Sender: TObject);
var txList:tList;
    v:qword;
    address:ansistring;
    tx:tEmerTransaction;
begin
  //создаем платежную транзакцию
  try
    v:=abs(trunc(1000000*mystrtofloat(eValue.Text)));
  except
    eValue.SetFocus;
    showMessageSafe('Wrong value for send');
  end;

  address:=FrameSelectAddress1.getAddress;




{
  txList:=emerAPI.UTXOList.giveToSpend(v);
  if txList=nil then begin
    eValue.SetFocus;
    showMessageSafe('Недостаточно свободных средств');
  end;
  try
    tx:=createTXbyInputs(list);  //utxo:tlist;txType:TxTypeNormal=1;Time:qword=-1 {подставить Now в линукс}; LockTime:qword=0
  finally
    list.free;
  end;
 }

  tx:=tEmerTransaction.create(emerAPI);
  try
    tx.addOutput(tx.createSpendScript(address),v);
    //ttx addInputs - Добавляет входы по выходам... добавляет желания. может сама добавить сдачу на еще один вход
    //если передан change address
    if tx.makeComplete then begin//add inputs, send change back to myself
     MainForm.miTXClick(nil);
     CreateRawTXForm.LoadbinTX(packTX(tx.getTTX));
   end else showMessageSafe('Can''t create transaction: '+tx.LastError);

  finally
    tx.free;
  end;

    // а для платежа вызовем
  // tx.singAllInputs(PrivKey);


end;

procedure TFramePayToAddress.bSendClick(Sender: TObject);
var
    v:qword;
    address:ansistring;
    tx:tEmerTransaction;
begin
  //создаем платежную транзакцию
  try
    v:=abs(trunc(1000000*mystrtofloat(eValue.Text)));
  except
    eValue.SetFocus;
    showMessageSafe('Wrong value for send');
  end;

  address:=FrameSelectAddress1.getAddress;



  tx:=tEmerTransaction.create(emerAPI,true);
//  try
    tx.addOutput(tx.createSpendScript(address),v);
    //ttx addInputs - Добавляет входы по выходам... добавляет желания. может сама добавить сдачу на еще один вход
    //если передан change address
    if tx.makeComplete then begin
      if tx.signAllInputs(MainForm.PrivKey) then begin
        tx.sendToBlockchain(EmerAPINotification(@Sent,'sent'));
        tx.addNotify(EmerAPINotification(@SendingError,'error'));
        eValue.Text:='';
        FrameSelectAddress1.eAddress.Text:='';
      end else showMessageSafe('Can''t sign all transaction inputs using current key: '+tx.LastError);
    end else showMessageSafe('Can''t create transaction: '+tx.LastError);

//  finally
//    tx.free;
//  end;
end;

procedure TFramePayToAddress.SendingError(Sender: TObject);
begin
  if Sender is tEmerTransaction
    then ShowMessageSafe('Sending error: '+tEmerTransaction(sender).lastError)
    else ShowMessageSafe('Sending error');
end;

procedure TFramePayToAddress.Sent(Sender: TObject);
begin
  ShowMessageSafe('Successfully sent');
end;

procedure TFramePayToAddress.init(visualdata:tVisualData);
begin
   if visualdata<>nil then begin
     color:=visualdata.bgColor;
     eValue.color:=visualdata.sEdit.Color;
     eValue.BorderStyle:=visualdata.sEdit.BorderStyle;
     lPayee.font.Assign(visualdata.slabel.Font);
     //pAddressInfo.Color:=visualdata.sPanel.color;
     bSend.Color:=visualdata.sButton.Color;
   end;

   sDevShowTX.Visible:=Settings.getValue('Dev_Mode_ON');
   eValue.Text:='';
   FrameSelectAddress1.init(visualdata);

   localizzze(self);
   lBalance.Caption:=localizzzeString('TFramePayToAddress.lBalance.startIfBalance','Balance')+' '+MainForm.eBalance.Text+' EMC' ;

end;

end.

