unit WalletBasicsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, PayToAddressFrameUnit, frameCreateNameUnit;

type

  { TWalletBasicsForm }

  TWalletBasicsForm = class(TForm)
    FrameCreateName1: TFrameCreateName;
    FramePayToAddress1: TFramePayToAddress;
    PageControl1: TPageControl;
    pBottom: TPanel;
    tsNameControl: TTabSheet;
    tsCreateName: TTabSheet;
    tsPay: TTabSheet;
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  WalletBasicsForm: TWalletBasicsForm;

implementation

{$R *.lfm}

{ TWalletBasicsForm }

procedure TWalletBasicsForm.FormShow(Sender: TObject);
begin
  FramePayToAddress1.init(nil);
  FrameCreateName1.init(nil);
end;



end.

