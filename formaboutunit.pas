unit FormAboutUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons;

type

  { TFormAbout }

  TFormAbout = class(TForm)
    bClose: TBitBtn;
    mAbout: TMemo;
    Panel1: TPanel;
    procedure bCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  FormAbout: TFormAbout;

implementation

{$R *.lfm}
{$IFDEF MSWINDOWS}
  uses windows;

  {$ENDIF}

{ TFormAbout }

procedure TFormAbout.bCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFormAbout.FormShow(Sender: TObject);
var
      ResStream : TResourceStream;
begin
  ResStream := TResourceStream.Create(HInstance, 'README', PChar(RT_RCDATA));
  try
    mAbout.Lines.LoadFromStream(ResStream);
  finally
    FreeAndNil(ResStream);
  end;

end;

end.

