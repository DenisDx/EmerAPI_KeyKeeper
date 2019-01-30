unit FrameNVSRecordUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, ComCtrls, ExtCtrls,
  NVSRecordUnit, GUIHelperUnit, UTXOUnit, FrameBaseNVSUnit;

type

  { TFrameNVSRecord }

  TFrameNVSRecord = class(TFrameBaseNVS)
    PageControl1: TPageControl;
    pTools: TPanel;
    pTitle: TPanel;
    tsName: TTabSheet;
    tsRawNVS: TTabSheet;
  private

  public
    procedure updateView(sender:tObject); override;
  end;

implementation

{$R *.lfm}
procedure TFrameNVSRecord.updateView(sender:tObject);
begin
  //update

end;



end.

