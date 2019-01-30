unit GUIHelperUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, graphics, StdCtrls, ExtCtrls ;

type

tVisualData = class(tObject)

  public
    bgColor:tColor;
    slabel:tLabel;
    sEdit:tEdit;
    sgroupbox:tGroupBox;
    sPanel:tPanel;
    sButton:tButton;
end;


implementation

end.

