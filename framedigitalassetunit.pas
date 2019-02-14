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
var s,s2:ansistring;
    st:string;
    pref:string;
begin


  pref:='';
  s:=fNVSRecord.NVSName;
  if not verifyNVSName(s) then pref:=localizzzeString('FrameDigitalAsset.Title.Erroneous','ERROR: ');

    st:=s;
    if pos(':',s)>0
      then s:=copy(s,1,pos(':',s)-1)
      else s:='';

    if s<>'' then
      delete(st,1,length(s)+1);

    pTitle.Color:=getNameColor(s);

    if s='' then begin
      pTitle.Caption:=adjustName(pref+
        localizzzeString('FrameDigitalAsset.Title.Empty','ALIAS OR UNKNOWN: ')
        +st
      );

    end else
    if s='af' then begin
      if pos(':',st)>0
            then s2:=copy(st,1,pos(':',st)-1)
            else s2:='';
      if s2<>'' then
        delete(st,1,length(s2)+1);

      //af:owner:<name>[:<N>]
      //af:product:<name>:[<N>]
      //af:lot:<name>:[<N>]
      if s2='owner' then begin
        pTitle.Caption:=adjustName(pref+
         localizzzeString('FrameDigitalAsset.Title.afOwner','Antifake OWNER: ')
          +st
        );
      end else
      if s2='product' then begin
        pTitle.Caption:=adjustName(pref+
         localizzzeString('FrameDigitalAsset.Title.afProduct','Antifake PRODUCT: ')
          +st
        );
      end else
      if s2='lot' then begin
        pTitle.Caption:=adjustName(pref+
         localizzzeString('FrameDigitalAsset.Title.afLot','Antifake LOT: ')
          +st
        );
      end else begin
        pTitle.Caption:=adjustName(pref+
          localizzzeString('FrameDigitalAsset.Title.afUnknown','Antifake unknown: ')
           +st
         );
      end;

    end else
    if s='dpo' then begin
      if pos(':',st)>0 then begin
        //item
        pTitle.Caption:=adjustName(pref+
         localizzzeString('FrameDigitalAsset.Title.dpo','DPO ITEM: ')
          +st
        );
      end else begin
         pTitle.Caption:=adjustName(pref+
          localizzzeString('FrameDigitalAsset.Title.dpoBrand','DPO BRAND: ')
           +st
         );
      end;

    end else
    if s='ssl' then begin
      pTitle.Caption:=adjustName(pref+
        localizzzeString('FrameDigitalAsset.Title.ssl','SSL: ')
        +st
      );

    end else

    if s='dns' then begin

      pTitle.Caption:=adjustName(pref+
        localizzzeString('FrameDigitalAsset.Title.dns','DNS: ')
        +st
      );

    end else
    if s='blog' then begin
      pTitle.Caption:=adjustName(pref+
        localizzzeString('FrameDigitalAsset.Title.blog','Blog: ')
        +st
      );

    end else
    if s='doc' then begin
      pTitle.Caption:=adjustName(
        localizzzeString('FrameDigitalAsset.Title.doc','DOCUMENT: ')
        +st
      );

    end else
    if s='cert' then begin
      pTitle.Caption:=adjustName(pref+
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

