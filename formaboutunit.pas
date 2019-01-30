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
  private

  public

  end;

var
  FormAbout: TFormAbout;

implementation

{$R *.lfm}

{ TFormAbout }

procedure TFormAbout.bCloseClick(Sender: TObject);
begin
  Close;
end;

end.

