unit FrameSelectAddressunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, graphics, StdCtrls, ExtCtrls,GUIHelperUnit, EmerAPIBlockchainUnit, fpjson, jsonparser, EmerTX;

type

  { TFrameSelectAddress }

  TFrameSelectAddress = class(TFrame)
    chDecodeAddress: TCheckBox;
    chRefresh: TCheckBox;
    eAddress: TEdit;
    lAddressInfo: TLabel;
    lPayments: TLabel;
    lCert: TLabel;
    pAddressInfo: TPanel;
    procedure eAddressChange(Sender: TObject);
    procedure updateTimerTimer(Sender: TObject);

  private
    updateTime:tTimer;
    fPrevAddressCorrect:boolean;
    fonAddressChanged:tNotifyEvent;
    fLastAddressFromAlias:ansistring;
  public
    function initialized:boolean;
    property onAddressChanged:tNotifyEvent read fonAddressChanged write fonAddressChanged;
    function getAddress:ansistring;
    procedure init(visualdata:tVisualData);
    procedure down;
    procedure AsyncAddressInfoDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
  end;

implementation

{$R *.lfm}
uses crypto, mainUnit, localizzzeUnit;

procedure TFrameSelectAddress.AsyncAddressInfoDone(sender:TEmerAPIBlockchainThread;result:tJsonData);
var js,e:tJsonData;
    s:string;
    val,x:double;
    nc,i,n:integer;
    st:ansistring;
    vR,vY,vS:double;
    nameScript:tNameScript;
    amount:integer;

begin

 if result=nil then begin
   //lNameExits.Caption:='checking name error:'+sender.lastError;
   if fprevaddresscorrect then if assigned(fonAddressChanged) then fonAddressChanged(self); fprevaddresscorrect:=false;
   exit;
 end;

 if sender.id=('checkname:'+trim(eAddress.Text)) then begin
  e:=result.FindPath('result');
  if e<>nil then
     if e.IsNull then begin
       lAddressInfo.Caption:=localizzzeString('TFrameSelectAddress.lAddressInfo','Address information: ');
       fLastAddressFromAlias:='';
       if fprevaddresscorrect then if assigned(fonAddressChanged) then fonAddressChanged(self); fprevaddresscorrect:=false;
     end else
     try
       lAddressInfo.Caption:=localizzzeString('TFrameSelectAddress.lAddressInfo.Found','Address: ')+e.FindPath('address').AsString;
       fLastAddressFromAlias:=e.FindPath('address').AsString;
       if assigned(fonAddressChanged) then fonAddressChanged(self); fprevaddresscorrect:=true;
{       lNameExits.Caption:=
         e.FindPath('address').AsString
         + localizzzeString('FrameCreateName.NameIsDelegated',' has registered the name till ')
         + datetostr(trunc(now() + e.FindPath('expires_in').AsInt64/175 ));
       bViewName.Enabled:=true;}
     except
       lAddressInfo.Caption:=localizzzeString('TFrameSelectAddress.lAddressInfo','Address information: ');
       fLastAddressFromAlias:='';
       if fprevaddresscorrect then if assigned(fonAddressChanged) then fonAddressChanged(self); fprevaddresscorrect:=false;
     end
  else begin
    lAddressInfo.Caption:=localizzzeString('TFrameSelectAddress.lAddressInfo','Address information: ');
    fLastAddressFromAlias:='';
    if fprevaddresscorrect then if assigned(fonAddressChanged) then fonAddressChanged(self); fprevaddresscorrect:=false;
  end;


 end else begin
   //lNameExits.Caption:='checking name...';
   //nameCheckTime.Enabled:=true;
 end;

end;

procedure TFrameSelectAddress.eAddressChange(Sender: TObject);
var
  ac:boolean;
begin
   lAddressInfo.Caption:=localizzzeString('TFrameSelectAddress.lAddressInfo','Address information: ');
   fLastAddressFromAlias:='';

   ac:=EmerAPI.blockChain.addressIsValid(eAddress.Text);

   if updateTime<>nil then
     updateTime.Enabled:=false;

   if (not ac) and (chDecodeAddress.Checked) then if updateTime<>nil then updateTime.Enabled:=true;

   if not (fPrevAddressCorrect or ac) then exit;
   fPrevAddressCorrect:=ac;
   if ac then begin
     if chRefresh.Checked then begin
        lPayments.Caption:=localizzzeString('TFrameSelectAddress.lPayments.wait','Please wait...');
        lCert.Caption:=localizzzeString('TFrameSelectAddress.lCert.wait','Please wait...');
        if updateTime<>nil then updateTime.Enabled:=true;
     end else begin
         lPayments.Caption:=localizzzeString('TFrameSelectAddress.lPayments.NoUpdate','*Online update turned off*');
         lCert.Caption:=localizzzeString('TFrameSelectAddress.lCert.NoUpdate','*Online update turned off*');
     end;
   end else begin
     lPayments.Caption:=localizzzeString('TFrameSelectAddress.lPayments.InvalidAddress','*Address you entered is not valid*');
     lCert.Caption:=localizzzeString('TFrameSelectAddress.lCert.InvalidAddress','*Address you entered is not valid*');
   end;
   if assigned(fonAddressChanged) then fonAddressChanged(self);
end;

procedure TFrameSelectAddress.updateTimerTimer(Sender: TObject);
var
  ac:boolean;
begin
  updateTime.Enabled:=false;
  ac:=EmerAPI.blockChain.addressIsValid(eAddress.Text);

  if (not ac) and (chDecodeAddress.Checked) and (trim(eAddress.Text)<>'') then
     emerAPI.EmerAPIConnetor.sendWalletQueryAsync('name_show',getJSON('{name:"'+trim(eAddress.Text)+'"}'),@AsyncAddressInfoDone,'checkname:'+trim(eAddress.Text));

  if trim(eAddress.Text)='' then fLastAddressFromAlias:='';

  if not ac then exit;
  if not chRefresh.Checked then exit;
  //update history and certs
  //emerAPI.EmerAPIConnetor.sendWalletQueryAsync('name_show',getJSON('{name:"'+trim(eAddress.Text)+'"}'),@AsyncAddressInfoDone,'checkname:'+trim(eAddress.Text));
end;

function TFrameSelectAddress.getAddress:ansistring;
var add:ansistring;
begin
   if fLastAddressFromAlias<>''
      then add:=fLastAddressFromAlias
      else add:=trim(eAddress.text);

   if length(add)<20 then result:=''
   else
   try
     result:=base58ToBufCheck(add);
   except
     result:='';
   end;
   if (length(result)>0) and (result[1]<>MainForm.globals.AddressSig) then begin
     showMessageSafe('The address is belong to another network');
     result:='';
     exit;
   end;
end;

procedure TFrameSelectAddress.down;
begin
   freeandnil(updateTime);
end;

function TFrameSelectAddress.initialized:boolean;
begin
   result:=updateTime<>nil;
end;

procedure TFrameSelectAddress.init(visualdata:tVisualData);
begin
   if visualdata<>nil then begin
     color:=visualdata.bgColor;
     eAddress.color:=visualdata.sEdit.Color;
     eAddress.BorderStyle:=visualdata.sEdit.BorderStyle;
     pAddressInfo.Color:=visualdata.sPanel.color;
   end;
   eAddress.Text:='';
   if updateTime=nil then begin
     updateTime:=tTimer.create(owner);
     updateTime.Interval:=50;
     updateTime.OnTimer:=@updateTimerTimer;
   end;
   fLastAddressFromAlias:='';
   localizzze(self);
end;

end.

