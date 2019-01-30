unit MasterPasswordWizardUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, Buttons, StdCtrls;

type

  { TMasterPasswordWizardForm }

  TMasterPasswordWizardForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    PageControl1: TPageControl;
    Panel1: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
  private

  public

  end;

var
  MasterPasswordWizardForm: TMasterPasswordWizardForm;

implementation

{$R *.lfm}

end.

