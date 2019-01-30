unit FrameDigitalAssetUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons
   ,NVSRecordUnit, GUIHelperUnit, UTXOUnit, FrameBaseNVSUnit;

type

  { TFrameDigitalAsset }

  TFrameDigitalAsset = class(TFrameBaseNVS)
    pAdv: TPanel;
    pTitle: TPanel;
    sbDetails: TSpeedButton;
    sbAdvCon: TSpeedButton;
    sbCert: TSpeedButton;
    sbHelp: TSpeedButton;
    procedure sbAdvConClick(Sender: TObject);
    procedure sbDetailsClick(Sender: TObject);
  private

  public
    function init(visualdata:tVisualData;nvs:tNVSRecord=nil):integer; override;
    procedure updateView(sender:tObject); override;
  end;

implementation

{$R *.lfm}
uses MainUnit, Localizzzeunit, NameViewUnit;

procedure TFrameDigitalAsset.updateView(sender:tObject);
var h:integer;
    function adjustName(s:string):string;
    var n:integer;
    begin
      result:=s;
      if pTitle.Canvas.TextWidth(result)>(pTitle.Width-(sbDetails.Width*4+3)) then begin
        while (length(result)>5) and (pTitle.Canvas.TextWidth(result+'..')>(pTitle.Width-(sbDetails.Width*4+3))) do
        begin
         n:=(pTitle.Canvas.TextWidth(result+'..') - (pTitle.Width-(sbDetails.Width*4+3))) div pTitle.Canvas.TextWidth('W');
         if n<1 then n:=1;
         if n>length(result) then n:=length(result)-5;
         delete(result,length(result)-n+1,n)
        end;
        result:=result + '..';
      end;
    end;
var s:ansistring;
    st:string;
begin

  s:=fNVSRecord.NVSName;
    st:=s;
    if pos(':',s)>0
      then s:=copy(s,1,pos(':',s)-1)
      else s:='';

    if s<>'' then
      delete(st,1,length(s)+1);

    pTitle.Color:=getNameColor(s);

    if s='' then begin
      pTitle.Caption:=adjustName(
        localizzzeString('FrameDigitalAsset.Title.Empty','ALIAS OR UNKNOWN: ')
        +st
      );

    end else
    if s='af' then begin


    end else
    if s='ssl' then begin
      pTitle.Caption:=adjustName(
        localizzzeString('FrameDigitalAsset.Title.ssl','SSL: ')
        +st
      );

    end else

    if s='dns' then begin
      pTitle.Caption:=adjustName(
        localizzzeString('FrameDigitalAsset.Title.dns','DNS: ')
        +st
      );

    end else
    if s='blog' then begin
      pTitle.Caption:=adjustName(
        localizzzeString('FrameDigitalAsset.Title.blog','Blog: ')
        +st
      );

    end else
    if s='cert' then begin
      pTitle.Caption:=adjustName(
        localizzzeString('FrameDigitalAsset.Title.cert','CERTIFICATE: ')
        +st
      );

    end else
    begin//raw nve
      pTitle.Caption:=adjustName(
        localizzzeString('FrameDigitalAsset.Title.Undetected','UNKNOWN: ')
        +s+':'+st
      );
    end;

  h:=pTitle.Height;
  if pAdv.Visible then h:=h+pAdv.Height;
  Height:= h;
end;

procedure TFrameDigitalAsset.sbAdvConClick(Sender: TObject);
begin
  pAdv.Visible:=not pAdv.Visible;
  updateView(nil);
end;

procedure TFrameDigitalAsset.sbDetailsClick(Sender: TObject);
begin
  ShowNameViewForm(fNVSRecord,false);
end;

function  TFrameDigitalAsset.init(visualdata:tVisualData;nvs:tNVSRecord=nil):integer;
begin
  pAdv.Visible:=false;
  inherited;



  updateView(nil);
  result:=Height;
end;

end.

