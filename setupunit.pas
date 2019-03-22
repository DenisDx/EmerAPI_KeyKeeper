unit setupunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,


  StdCtrls, ComCtrls, Buttons, passrateunit, CreatePasswordUnit;

type

  { TsetUPForm }

  TsetUPForm = class(TForm)
    bCreatePassword: TBitBtn;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    chShowRate: TCheckBox;
    chShowGenerator: TCheckBox;
    chShowPassword: TCheckBox;
    createPassword1: TcreatePassword;
    ePassword1: TEdit;
    ePassword2: TEdit;
    gbGenerator: TGroupBox;
    lTitle: TLabel;
    lPassword1: TLabel;
    lPassword2: TLabel;
    mMessage: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    PassRate1: TPassRate;
    tbDif: TTrackBar;
    tbRandomizer: TTimer;
    tBlink: TTimer;
    tRefresh: TTimer;

    procedure bCreatePasswordClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure chShowGeneratorChange(Sender: TObject);
    procedure chShowPasswordChange(Sender: TObject);
    procedure ePassword1Change(Sender: TObject);
    procedure ePassword2Change(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure Init(titleTag:string='';messageTag:string='');
    procedure tbDifChange(Sender: TObject);
    procedure tBlinkTimer(Sender: TObject);
    procedure tbRandomizerTimer(Sender: TObject);
    procedure tRefreshTimer(Sender: TObject);
    procedure reshape;
  private

  public

  end;

var
  setUPForm: TsetUPForm;

function createUP(messageTag:string=''):ansistring;

implementation

{$R *.lfm}
uses localizzzeUnit, PasswordHelper, math;

{ TsetUPForm }

function createUP(messageTag:string=''):ansistring;
begin
  //Encode unicode symbols as seq

  setUPForm.Init('',messageTag);
  if setUPForm.ShowModal=mrOk then
    result:=setUPForm.ePassword1.Text;
end;

procedure TsetUPForm.Init(titleTag:string='';messageTag:string='');
begin

  if messageTag ='' then messageTag:='newUserPass.defaultTitle';
  if titleTag ='' then messageTag:='newUserPass.defaultMessage';
  localizzze(self);
  lTitle.Caption:=localizzzeString(titleTag,'Please enter a new User Password');
  mMessage.Text:=localizzzeString(messageTag,'');

  chShowGenerator.Checked:=false;
  chShowPassword.Checked:=false;
  ePassword1.Text:='';
  ePassword2.Text:='';
  chShowPasswordChange(nil);


  PassRate1.init;
  CreatePassword1.Init;
  CreatePassword1.onChange:=@bCreatePasswordClick;
end;

procedure TsetUPForm.tbDifChange(Sender: TObject);
begin
  bCreatePassword.Click;
end;

procedure TsetUPForm.tBlinkTimer(Sender: TObject);
begin
  tBlink.Enabled:=false;
  ePassword1.Color:=clDefault;
  ePassword1.Font.Color:=clDefault;
  ePassword2.Font.Color:=clDefault;
  ePassword2Change(nil);
end;

procedure TsetUPForm.tbRandomizerTimer(Sender: TObject);
begin
  RndGen.doRandomize(0);

  tbRandomizer.Enabled:=not RndGen.rndReady;
end;

procedure TsetUPForm.tRefreshTimer(Sender: TObject);
begin
  tRefresh.Enabled:=false;
  PassRate1.UpdateStat(ePassword1.Text);
end;


procedure TsetUPForm.reshape;
//var sw:boolean;
begin
  chShowRate.Enabled:=not chShowGenerator.Checked;
  chShowPassword.Enabled:= not chShowGenerator.Checked;

  if chShowGenerator.Checked then begin
    chShowPassword.Checked:=true;
    //chShowRate.Checked:=true;
  end;

  if chShowPassword.Checked then begin
    ePassword1.PasswordChar:=#0;
    ePassword2.PasswordChar:=#0;
    ePassword2.Text:='';
    ePassword2.Enabled:=false;
    lPassword2.Enabled:=false;
  end else begin
    ePassword1.PasswordChar:='*';
    ePassword2.PasswordChar:='*';
    ePassword2.Enabled:=true;
    lPassword2.Enabled:=true;
  end;

  //reshape
  //sw := gbGenerator.Visible<>chShowGenerator.Checked;
  if (gbGenerator.Visible<>chShowGenerator.Checked) then begin
    if windowState=wsMaximized then begin
      if gbGenerator.Visible
          then Constraints.minWidth:=Constraints.minWidth - gbGenerator.Width
          else Constraints.minWidth:=Constraints.minWidth + gbGenerator.Width;
      gbGenerator.Visible:=chShowGenerator.Checked;
    end else begin
      if gbGenerator.Visible
          then begin gbGenerator.Visible:=chShowGenerator.Checked; Constraints.minWidth:=Constraints.minWidth - gbGenerator.Width; width:=width - gbGenerator.Width;      end
          else begin width:=width + gbGenerator.Width; Constraints.minWidth:=Constraints.minWidth + gbGenerator.Width;     gbGenerator.Visible:=chShowGenerator.Checked; end;

    end;
  end;


  //gbGenerator.Visible:=chShowGenerator.Checked;
  //PassRate1.Visible:=chShowGenerator.Checked or chShowRate.Checked;
end;

procedure TsetUPForm.chShowPasswordChange(Sender: TObject);
begin
  if chShowPassword.Enabled then
    reshape;
end;

procedure TsetUPForm.BitBtn1Click(Sender: TObject);
begin
  if (trim(ePassword1.Text)<>'') and
    (
      (not ePassword2.Enabled)
      or
      (ePassword1.text=ePassword2.text)
    )
  then ModalResult:=mrOk
  else begin
    ePassword1.Color:=clRed;
    ePassword1.Font.Color:=clBlack;
    if ePassword2.Enabled then begin
      ePassword2.Color:=clRed;
      ePassword2.Font.Color:=clBlack;
    end;
    tBlink.Enabled:=true;
  end;
end;

procedure TsetUPForm.bCreatePasswordClick(Sender: TObject);
var s:string;
begin
  s:=createPassword1.createPassword(tbDif.Position);
  ePassword1.Text:=s;
  ePassword2.Text:='';
  if not chShowPassword.Checked then begin
    chShowPassword.Checked:=true;
    chShowPasswordChange(nil);
  end;
end;

procedure TsetUPForm.BitBtn2Click(Sender: TObject);
begin
  ModalResult:=mrCancel;
end;

procedure TsetUPForm.chShowGeneratorChange(Sender: TObject);
begin
  reshape;
end;


procedure TsetUPForm.ePassword1Change(Sender: TObject);
begin
  //PassRate1.UpdateStat(ePassword1.Text);
  tRefresh.Enabled:=false;
  tRefresh.Enabled:=true;
  ePassword2Change(nil);
end;

procedure TsetUPForm.ePassword2Change(Sender: TObject);
begin
  if (ePassword2.Text<>ePassword1.Text) and (ePassword2.Text<>'') and ePassword2.enabled
    then begin ePassword2.Color:=clRed; ePassword2.Font.Color:=clBlack; end
    else begin ePassword2.Color:=clDefault; ePassword2.Font.Color:=clDefault; end;
end;

procedure TsetUPForm.FormKeyPress(Sender: TObject; var Key: char);
begin
    RndGen.doRandomize(ord(Key));
end;

procedure TsetUPForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  RndGen.doRandomize(X + Y*$100000000);
end;

procedure TsetUPForm.FormShow(Sender: TObject);
begin
  tbRandomizer.Enabled:=true;

  reshape;
end;


end.

