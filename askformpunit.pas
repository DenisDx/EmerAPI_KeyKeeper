unit askformpunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  ExtCtrls, EnterMasterPasswordUnit;

type

  { TaskForMPForm }

  TaskForMPForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    bHelp: TBitBtn;
    EnterMasterPasswordFrame1: TEnterMasterPasswordFrame;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  askForMPForm: TaskForMPForm;

function askForMP():ansistring;

implementation
uses passwordHelper, Localizzzeunit;

{$R *.lfm}
function askForMP():ansistring;
begin
  //Must convert string to acsii array!
  result:='';
  askForMPForm.EnterMasterPasswordFrame1.eAddress.Text:='';

  askForMPForm.Top:=Screen.ActiveForm.Top + (Screen.ActiveForm.Height-askForMPForm.Height) div 2;
  if askForMPForm.Top<Screen.ActiveForm.Top then askForMPForm.Top:=Screen.ActiveForm.Top;

  askForMPForm.Left:=Screen.ActiveForm.Left+(Screen.ActiveForm.Width-askForMPForm.Width) div 2;
  if askForMPForm.Left<Screen.ActiveForm.Left then askForMPForm.Left:=Screen.ActiveForm.Left;


  askForMPForm.EnterMasterPasswordFrame1.init;

  if askForMPForm.ShowModal=mrOk then
    //result:=decodePassword(askForMPForm.EnterMasterPasswordFrame1.eMasterPassword.Text);
     result:=trim(askForMPForm.EnterMasterPasswordFrame1.eMasterPassword.Text);

  //decode
  //1. bip
  //2. ....


end;

{ TaskForMPForm }

procedure TaskForMPForm.BitBtn1Click(Sender: TObject);
begin
  if EnterMasterPasswordFrame1.getPrivKey<>''
   then modalResult:=mrOk;
end;

procedure TaskForMPForm.BitBtn2Click(Sender: TObject);
begin
  modalResult:=mrCancel;
end;

procedure TaskForMPForm.FormDestroy(Sender: TObject);
begin
     EnterMasterPasswordFrame1.down;
end;

procedure TaskForMPForm.FormShow(Sender: TObject);
begin
  localizzze(self);
  EnterMasterPasswordFrame1.init;
end;


end.

