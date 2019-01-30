unit FrameBaseNVSUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, NVSRecordUnit,
  GUIHelperUnit, UTXOUnit;

type

  { TFrameBaseNVS }

  TFrameBaseNVS = class(TFrame)
  private
  protected
    fNVSRecord:tNVSRecord;
    fTerminateOnDown:boolean;

  public
    property NVSRecord:tNVSRecord read fNVSRecord;
    procedure updateView(sender:tObject); virtual; abstract;
    function init(visualdata:tVisualData;nvs:tNVSRecord=nil):integer; virtual; overload;
    function init(visualdata:tVisualData;nvsName:ansistring):integer; virtual; overload;
    function init(visualdata:tVisualData;utxo:tUTXO):integer; virtual; overload;
    procedure down;
  end;

implementation

uses MainUnit, emerapitypes;

{$R *.lfm}
function TFrameBaseNVS.init(visualdata:tVisualData;nvs:tNVSRecord=nil):integer;
begin
   if visualdata<>nil then begin
     color:=visualdata.bgColor;
     //eValue.color:=visualdata.sEdit.Color;
     //eValue.BorderStyle:=visualdata.sEdit.BorderStyle;
     //lPayee.font.Assign(visualdata.slabel.Font);
     //pAddressInfo.Color:=visualdata.sPanel.color;
     //bSend.Color:=visualdata.sButton.Color;
   end;
   fNVSRecord:=nvs;

   fNVSRecord.addNotify(EmerAPINotification(@updateView,'update',true));

   fTerminateOnDown:=true;
   //sDevShowTX.Visible:=Settings.getValue('Dev_Mode_ON');
   //eValue.Text:='';
   //FrameSelectAddress1.init(visualdata);
   if not fNVSRecord.isLoaded then
     fNVSRecord.readFromBlockchain()
   else updateView(nil);
   result:=1;
end;


function TFrameBaseNVS.init(visualdata:tVisualData;nvsName:ansistring):integer;
var myNVSRecord:tNVSRecord;
begin
  inherited;
  myNVSRecord:=tNVSRecord.create(emerAPI,nvsName,true);
  result:=init(visualdata,myNVSRecord);
end;

function TFrameBaseNVS.init(visualdata:tVisualData;utxo:tUTXO):integer;
var myNVSRecord:tNVSRecord;
begin
  myNVSRecord:=tNVSRecord.create(emerAPI,utxo);
  result:=init(visualdata,myNVSRecord);
end;


procedure TFrameBaseNVS.down;
begin
  if fTerminateOnDown then begin
    //if fNVSRecord<>nil then
    //  fNVSRecord.removeNotify(EmerAPINotification(@updateView,'update',true));
    freeandNil(fNVSRecord);
  end;
end;



end.

