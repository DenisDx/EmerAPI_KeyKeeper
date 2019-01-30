unit SplashFormUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TSplashForm }

  TSplashForm = class(TForm)
    Image1: TImage;
  private

  public

  end;

var
  SplashForm: TSplashForm;

implementation

{$R *.lfm}

end.

