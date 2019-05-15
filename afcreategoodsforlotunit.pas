unit AFCreateGoodsForLotUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, EditBtn, Buttons

  ,NVSRecordUnit
  ,AntifakeHelperUnit
  ;

type

  { TAFCreateGoodsForLot }

  TAFCreateGoodsForLot = class(TForm)
    bCreate: TBitBtn;
    bClose: TBitBtn;
    chCreateInBlockchain: TCheckBox;
    chAdvanced: TCheckBox;
    deDirectory: TDirectoryEdit;
    eProduct: TLabeledEdit;
    eLot: TLabeledEdit;
    eBrand: TLabeledEdit;
    lDirectory: TLabel;
    lMessage1: TLabel;
    lMessage2: TLabel;
    lLotData: TLabel;
    lMessage3: TLabel;
    pBottom: TPanel;
    pTop: TPanel;
    procedure bCreateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

    procedure getBrandCallBack(Sender:tAFRequest);
  public

    procedure init(aLot:string);
  end;

var
  AFCreateGoodsForLot: TAFCreateGoodsForLot;

procedure showGoodsDataCreationWindow(aLot:string); overload;
procedure showGoodsDataCreationWindow(NVSRecord:tNVSRecord); overload;


implementation

uses Localizzzeunit
  ,AFCreateForPrintingUnit

  ;

{$R *.lfm}

procedure showGoodsDataCreationWindow(aLot:string);
begin
  with AFCreateGoodsForLot do begin
    if Visible then Close;
    if aLot='' then exit;

    init(aLot);
    show;
  end;

end;

procedure showGoodsDataCreationWindow(NVSRecord:tNVSRecord);
begin
  showGoodsDataCreationWindow(NVSRecord.NVSName);
{  if AFCreateGoodsForLot.Visible then AFCreateGoodsForLot.Close;

  AFCreateGoodsForLot.Show;
}
end;

{ TAFCreateGoodsForLot }

procedure TAFCreateGoodsForLot.getBrandCallBack(Sender:tAFRequest);
var s:string;
    n:qword;
begin
  if sender=nil then exit;
  if eLot.text='' then exit;


  if Sender.id='getBrandForLot_'+eLot.text then begin
    s:=cutNVSNamePrefix('dpo:',Sender.rNVSName);
    if s='' then begin
      eBrand.Text:=Sender.LastError;
      eProduct.Text:=Sender.LastError;
      bCreate.Enabled:=false;
      lMessage3.Caption:=localizzzeString('AFCreateGoodsForLot.lMessage3.noBrand','Can not create the goods: brand is not detected');
    end else begin
      bCreate.Enabled:=true;
      chCreateInBlockchain.Enabled:=true;

      //lot
      s:=getNVSValueParameter(Sender.cNVSValue,'NAME');
      if s='' then s:=Sender.cNVSName
              else s:=s+' ('+Sender.cNVSName+')';
      lMessage1.Caption:=localizzzeString('AFCreateGoodsForLot.lMessage1','creating goods for ')+s;
      eLot.EditLabel.Caption:=localizzzeString('AFCreateGoodsForLot.eLot','Lot ')+s;;
      eLot.Text:=cutNVSNamePrefix('af:lot:',Sender.cNVSName);

      //lot data: lMessage2
      s:=getNVSValueParameter(Sender.cNVSValue,'POOL');
      n := getLotRangeSize(s);
      if n<1 then begin
        bCreate.Enabled:=false;
        lMessage2.Caption:=localizzzeString('AFCreateGoodsForLot.lMessage2.Empty','Empty pool');
      end else begin

        try
          lMessage2.Caption:=Format(localizzzeString('AFCreateGoodsForLot.lMessage2','%s serials: %s'),[inttostr(n),s]);
        except
          lMessage2.Caption:=localizzzeString('AFCreateGoodsForLot.lMessage2','');
        end;

        if n>1000 then begin
          lMessage2.Caption:=lMessage2.Caption + #10 + localizzzeString('AFCreateGoodsForLot.lMessage2.addTooMany','The series is too big');
          chCreateInBlockchain.Enabled:=false;
          chCreateInBlockchain.Checked:=false;
        end else if n>50 then
          lMessage2.Caption:=lMessage2.Caption + #10 + localizzzeString('AFCreateGoodsForLot.lMessage2.addMany','The series is big');

      end;

      //product
      eProduct.Text:=cutNVSNamePrefix('af:product:',Sender.rFirstProduct);
      s:=getNVSValueParameter(Sender.rNVSValue,'NAME');
      if s<>'' then s:=s+' ('+Sender.rFirstProduct+')'
              else s:=Sender.rFirstProduct;
      eProduct.EditLabel.Caption:=localizzzeString('AFCreateGoodsForLot.eProduct','')+s;

      //brand
      eBrand.Text:=cutNVSNamePrefix('dpo:',Sender.rNVSName);
      s:=getNVSValueParameter(Sender.rNVSValue,'NAME');
      if s<>'' then s:=s+' ('+Sender.rNVSName+')'
              else s:=Sender.rNVSName;
      eBrand.EditLabel.Caption:=localizzzeString('AFCreateGoodsForLot.eBrand','')+s;

      if s='' then begin
        lMessage3.Caption:=localizzzeString('AFCreateGoodsForLot.lMessage3.noBrand','No brand');
        bCreate.Enabled:=false;
      end else begin
       if n>0 then lMessage3.Caption:=localizzzeString('AFCreateGoodsForLot.lMessage3','Press button to create')
              else lMessage3.Caption:=localizzzeString('AFCreateGoodsForLot.lMessage3.poolEmpty','Pool is empty');
      end;

      {
      s:=getNVSValueParameter(Sender.rNVSValue,'NAME');
      if s='' then s:=cutNVSNamePrefix('dpo:',Sender.rNVSName)
              else s:=s+' ('+cutNVSNamePrefix('dpo:',Sender.rNVSName)+')';
      eBrand.Text:=s;

      s:=getNVSValueParameter(Sender.rFirstProductValue,'NAME');
      if s='' then s:=cutNVSNamePrefix('dpo:',Sender.rFirstProduct)
              else s:=s+' ('+cutNVSNamePrefix('dpo:',Sender.rFirstProduct)+')';
      eProduct.Text:=s;
      }
    end;
  end;

end;

procedure TAFCreateGoodsForLot.init(aLot:string);
begin
  if aLot='' then raise exception.Create('TAFCreateGoodsForLot.init: Lot is empty');

  AFGetBrandForObject(aLot,@getBrandCallBack,'getBrandForLot_'+aLot);

  eLot.Text:=aLot;

  lMessage1.Caption:=localizzzeString('AFCreateGoodsForLot.lMessage1','creating goods for ')+aLot;

  eProduct.Text:=localizzzeString('AFCreateGoodsForLot.Messages.PleaseWait','Please wait...');
  eBrand.Text:=localizzzeString('AFCreateGoodsForLot.Messages.PleaseWait','Please wait...');


  lMessage2.Caption:=localizzzeString('AFCreateGoodsForLot.Messages.PleaseWait','Please wait...');
  lMessage3.Caption:=localizzzeString('AFCreateGoodsForLot.Messages.PleaseWait','Please wait...');

end;

procedure TAFCreateGoodsForLot.FormCreate(Sender: TObject);
begin
  localizzze(self);
end;

procedure TAFCreateGoodsForLot.bCreateClick(Sender: TObject);
begin

  with AFCreateForPrintingForm do begin
    if Visible then Close;

    show; //will init it also
    if cLot.Items.IndexOf(eLot.Text)<0 then
      raise exception.Create('Lot "'+eLot.Text+'" not found');
    setEnabledAndView;

    //the brand was requested. But let's set a brand
    //cBrand.Text:=eBrand.Text;
    //cBrand.itemIndex:=cBrand.Items.IndexOf(eBrand.Text);

    {
    if uppercase(mtag)= uppercase('AFCreateForPrintingForm.bDemo1.Desc') then begin
      rbIterRange.Checked:=true;
      chCreateProductField.checked:=false;
      eIteratorRange.Text:='serial1~serial9;serial10';
      chCreateNVSrecords.Checked:=true;
      if cBrand.Items.Count>1 then cBrand.ItemIndex:=1;

      chCheckNamesIfFree.Checked:=true;
      chCreatePrivateCSV.Checked:=true;
      chPrivAddName.Checked:=true;
      chPrivAddValue.Checked:=true;
      deFolderPackage.Directory:='demo1';

      chLogErrorSerialsToFile.Checked:=true;
    end;  }


    rbIterLot.checked := true;
    cLot.ItemIndex:=cLot.Items.IndexOf(eLot.Text);
    deFolderPackage.Directory:=deDirectory.Directory;

    chCreateProductField.Checked:=true;
    cCreateProductField.ItemIndex:=cCreateProductField.Items.IndexOf('af:product:'+eProduct.Text);

    chCreateParentLotField.Checked:=true;
    cCreateParentLotField.ItemIndex:=cCreateParentLotField.Items.IndexOf('af:lot:'+eLot.Text);


    {
    if (uppercase(mtag)= uppercase('AFCreateForPrintingForm.bDemo3.Desc'))  then begin
      rbIterRange.Checked:=true;
      chCreateProductField.checked:=false;
      eIteratorRange.Text:='s1~s9;s10~s99;s100~s999;s1000';
      if cBrand.Items.Count>1 then cBrand.ItemIndex:=1;
      deFolderPackage.Directory:='demo3';
    end;
    }

    chCheckNamesIfFree.Checked:=true;
    chAddRandomSuffix.Checked:=not chCreateInBlockchain.Checked;

    chCreatePrivateCSV.Checked:=true;
    chPrivAddName.Checked:=true;
    chPrivAddValue.Checked:=true;
    chPrivAddBrand.Checked:=true;
    chPrivAddAddress.Checked:=true;

    chCreatePublicCSV.Checked:=true;
    chPubAddName.Checked:=true;
    chPubAddValue.Checked:=true;
    chPubAddBrand.Checked:=true;
    chPubAddAddress.Checked:=true;

    chCreatePrintCSV.Checked:=true;

    chCreateQR1.Checked:=true;
    chCreateQR2.Checked:=true;

    chLogErrorSerialsToFile.Checked:=true;

    chCreateNVSrecords.Checked := chCreateInBlockchain.Checked;
    chCreateNVSrecordsAddCoins.Checked := true;

    setEnabledAndView;
    if not chAdvanced.Checked then
      if bCreate.Enabled then begin
        optStartOnDataReady:=true;
        optCloseOnDone:=true;
        //bCreate.Click;
        //close;
      end;

  end;
end;

end.

