unit passrateunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, ComCtrls, ExtCtrls

  {$IFDEF WINDOWS}
  ,LCLintf,  commctrl
  {$ELSE}
  {$ENDIF}
  ;

type

  { TPassRate }

  TPassRate = class(TFrame)
    lExplanation: TLabel;
    lPasswordRate: TLabel;
    mInfo: TMemo;
    pbRate: TProgressBar;
  private
    fCurrentPass:string;
  public
    procedure init();
    procedure UpdateStat(password:string);

  end;

implementation

uses localizzzeUnit, PasswordHelper, math ,Graphics;

{$R *.lfm}
procedure TPassRate.UpdateStat(password:string);
var rate:double;

  function safebyte(x:integer):byte;
  begin
    if x<0 then result:=0
    else if x>255 then result:=255
    else result:=x;
  end;
  procedure setProgressColor(r:double);
  var
    c:tColor;
    lmax:double;
  begin
    //pbRate.Brush.Color:= c;

    lmax:=50;
    // r: 255 -> 0 g: 128 ->255 b: 128 -> 0
    c:=RGBToColor(safebyte(trunc(255*(1 - rate/lmax))),safebyte(trunc(255*(0.5+rate/lmax/2))),safebyte(trunc(255*(1 - rate/lmax))) div 2 );
    lPasswordRate.Font.Color:=c;
    {$IFDEF WINDOWS}
      SendMessage(pbRate.Handle, PBM_SETSTATE, PBST_NORMAL, 0);
      if r<20 then SendMessage(pbRate.Handle, PBM_SETSTATE, PBST_ERROR, 0)
      else if r<30 then SendMessage(pbRate.Handle, PBM_SETSTATE, PBST_PAUSED, 0)
      ;//else SendMessage(pbRate.Handle, PBM_SETSTATE, PBST_NORMAL, 0);

      pbRate.Position:=pbRate.Position+1;
      pbRate.Position:=pbRate.Position-1;
      pbRate.Position:=pbRate.Position+1;
    {$ELSE}
    {$ENDIF}

  end;


begin
  fcurrentPass:=password;
  rate:=ratePassword(fCurrentPass);
  mInfo.Text:=''
   +localizzzeString('setUPForm.txtPenalties','Penalties:'#10)
   +lastRatePasswordPenalties.text
   +#10
   +localizzzeString('setUPForm.txtBonuses','Bonuses:'#10)
   +lastRatePasswordBonuses.text
  ;

  pbRate.Position:=trunc(rate);

  setProgressColor(rate);

{  if rate<20 then setProgressColor(clRed)
  else if rate<30 then pbRate.Color:=clYellow
  else if rate<1025 then pbRate.Color:=clGreen
  else pbRate.Color:=clBlack;
 }

  if fCurrentPass='' then lPasswordrate.Caption:=localizzzeString('setUPForm.lpmt.EnterPassword','Please enter password')
  else if rate<7.5 then lPasswordrate.Caption:=localizzzeString('setUPForm.lpmt.Terrible','Terrible password, it is not acceptable ( rate ')+inttostr(trunc(rate))+')'
  else if rate<15 then lPasswordrate.Caption:=localizzzeString('setUPForm.lpmt.VeryBad','Very bad password, use it only for protect from strangers ( rate ')+inttostr(trunc(rate))+')'
  else if rate<20 then lPasswordrate.Caption:=localizzzeString('setUPForm.lpmt.Bad','Bad password, better to make it stronger ( rate ')+inttostr(trunc(rate))+')'
  else if rate<25 then lPasswordrate.Caption:=localizzzeString('setUPForm.lpmt.Avg','Less or more acceptable, but better to stronger it ( rate ')+inttostr(trunc(rate))+')'
  else if rate<30 then lPasswordrate.Caption:=localizzzeString('setUPForm.lpmt.Good','Quite good password ( rate ')+inttostr(trunc(rate))+')'
  else if rate<40 then lPasswordrate.Caption:=localizzzeString('setUPForm.lpmt.VeryGood','Very good password ( rate ')+inttostr(trunc(rate))+')'
  else if rate<50 then lPasswordrate.Caption:=localizzzeString('setUPForm.lpmt.Excelent','Excelent password ( rate ')+inttostr(trunc(rate))+')!'
  else if rate<128 then lPasswordrate.Caption:=localizzzeString('setUPForm.lpmt.MoreExcelent','More than excelent password ( rate ')+inttostr(trunc(rate))+')'
  else if rate<1025 then lPasswordrate.Caption:=localizzzeString('setUPForm.lpmt.Crazy','Crazy hacker-conspirologist''s password. Can you remember it for sure? ( rate ')+inttostr(trunc(rate))+')'
  else lPasswordrate.Caption:=localizzzeString('setUPForm.lpmt.Kidding','Are you kidding? ( rate ')+inttostr(trunc(rate))+')';

{  application.ProcessMessages;;
  //pbRate.Position:=trunc(rate);
  tRefresh2.Enabled:=true;
  pbRate.tag:=trunc(rate); //fix tb}
end;


procedure TPassRate.init();
begin
  mInfo.text:='';
  fcurrentPass:='';
end;

end.

