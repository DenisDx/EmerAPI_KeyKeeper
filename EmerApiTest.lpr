program EmerApiTest;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Unit1, PodbiralkaUnit, unitCryptoTest, EmerApiTestUnit, tsttransactionUnit,
  EmerTX, CreateRawTXunit, LoadTXunit, SettingsUnit, Localizzzeunit
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TPodbiralkaForm, PodbiralkaForm);
  Application.CreateForm(TcryptoTestForm, cryptoTestForm);
  Application.CreateForm(TEmerApiTestForm, EmerApiTestForm);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TCreateRawTXForm, CreateRawTXForm);
  Application.CreateForm(TLoadTXForm, LoadTXForm);
//  Application.CreateForm(TSettingsFrom, SettingsFrom);
//  Application.CreateForm(TForm5, Form5);
  Application.Run;
end.

