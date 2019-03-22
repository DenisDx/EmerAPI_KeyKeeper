unit FormAboutUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Buttons;

type

  { TFormAbout }

  TFormAbout = class(TForm)
    bClose: TBitBtn;
    Panel1: TPanel;
    seInfo: TSynEdit;
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
      //s:string;
begin
  ResStream := TResourceStream.Create(HInstance, 'README', PChar(RT_RCDATA));
  try

    seInfo.Lines.LoadFromStream(ResStream);

    {
    //ResStream.Position:=0;
    setLength(s,ResStream.Size);
    ResStream.Read(s[1],length(s));
    mAbout.ReadOnly:=false;
    mAbout.Text:='!!!!';//trim(s);
    mAbout.ReadOnly:=true;
    //mAbout.Lines.LoadFromStream(ResStream);
    }
  finally
    FreeAndNil(ResStream);
  end;

end;

end.

