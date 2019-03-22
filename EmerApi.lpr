program EmerApi;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  cmem,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, HlpIHash, MainUnit, settingsunit, MasterPasswordWizardUnit,
  QuestionUnit, Localizzzeunit, HelperUnit, localwalletunit, setupunit,
  PasswordHelper, CreatePasswordUnit, passrateunit, entermasterpasswordunit,
  askformpunit, AskForUPUnit, FrameSelectAddressunit, PayToAddressFrameUnit,
  WalletBasicsUnit, FrameAtomunit, BlockchainUnit, frameCreateNameUnit,
  FrameNVSRecordUnit, FrameBaseNVSUnit, MempoolViewerUnit, memPoolUnit,
  EmerAPITransactionUnit, BaseTXUnit, FrameServerTaskUnit, MempoolViewerUnit2,
  HDNodeUnit, masssendingunit, FrameDigitalAssetUnit, AtomFormUnit,
  FormAboutUnit, SplashFormUnit, SignMessageUnit, CheckSignatureUnit,
  x509devUnit, addressQRunit, AFCreateForPrintingunit{, unit1} , NVSValueEdit;
{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSplashForm, SplashForm);

  Application.CreateForm(TSettingsForm, SettingsForm);
  Application.CreateForm(TMasterPasswordWizardForm, MasterPasswordWizardForm);
  Application.CreateForm(TQuestionForm, QuestionForm);
  Application.CreateForm(TLocalizzzeForm, LocalizzzeForm);
  Application.CreateForm(TsetUPForm, setUPForm);
  Application.CreateForm(TaskForMPForm, askForMPForm);
  Application.CreateForm(TAskForUPForm, AskForUPForm);
  Application.CreateForm(TWalletBasicsForm, WalletBasicsForm);
  Application.CreateForm(TMassSendingForm, MassSendingForm);
  Application.CreateForm(TAtomForm, AtomForm);
  Application.CreateForm(TFormAbout, FormAbout);
  Application.CreateForm(TSignMessageForm, SignMessageForm);
  Application.CreateForm(TCheckSignatureForm, CheckSignatureForm);
  Application.CreateForm(TAddressQRForm, AddressQRForm);
  Application.CreateForm(TAFCreateForPrintingForm, AFCreateForPrintingForm);
  Application.CreateForm(TNVSValueEditForm, NVSValueEditForm);
  //Application.CreateForm(Tx509devform, x509devform);
  //Application.CreateForm(TNameViewForm, NameViewForm);
  Application.Run;

end.

