unit AskForUPUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IpHtml, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type

  { TAskForUPForm }

  TAskForUPForm = class(TForm)
    bOk: TBitBtn;
    ePassword: TEdit;
    IpHtmlPanel1: TIpHtmlPanel;
    lPassword: TLabel;
    Panel1: TPanel;
    procedure bOkClick(Sender: TObject);
    procedure ePasswordKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    msgTag:ansistring;
    pHTML :TIpHtml;
    procedure myOnGetImageXHandler(Sender: TIpHtmlNode; const URL: string;
          var Picture: TPicture);
  public

  end;

var
  AskForUPForm: TAskForUPForm;

function askForUP(msgTag:ansistring='AskForUPForm.pHTML'):ansistring;

implementation

uses PasswordHelper, Localizzzeunit
  {$IFDEF MSWINDOWS}
  , Windows
    {$ENDIF}
  ;
{$R *.lfm}
function askForUP(msgTag:ansistring='AskForUPForm.pHTML'):ansistring;
begin
  result:='';
  AskForUPForm.ePassword.Text:='';
  AskForUPForm.msgTag:=msgTag;
  if AskForUPForm.ShowModal=mrOk then
    result:=decodePassword(AskForUPForm.ePassword.Text);
end;

{ TAskForUPForm }


procedure TAskForUPForm.myOnGetImageXHandler(Sender: TIpHtmlNode;
  const URL: string; var Picture: TPicture);
var
  ResStream: TResourceStream;
begin
  Picture := TPicture.Create;
  ResStream := TResourceStream.Create(HInstance, URL, PChar(RT_RCDATA));
  try
    Picture.LoadFromStream(ResStream);
  finally
    ResStream.Free;
  end;
end;

procedure TAskForUPForm.bOkClick(Sender: TObject);
begin
  modalResult:=mrOk;
end;

procedure TAskForUPForm.ePasswordKeyPress(Sender: TObject; var Key: char);
begin
  if key=#13 then bOk.Click;
end;

type
  myTIpHtml = class(TIpHtml)
  end;

procedure TAskForUPForm.FormCreate(Sender: TObject);
begin
  pHTML := TIpHtml.Create; // Beware: Will be freed automatically by IpHtmlPanel1
  IpHtmlPanel1.SetHtml(pHTML);
  myTIpHtml(pHTML).OnGetImageX := @(myOnGetImageXHandler);

end;

procedure TAskForUPForm.FormShow(Sender: TObject);
var fs :TStringStream;
begin
  localizzze(self);

  fs := TStringStream.Create(localizzzeString(msgTag,'Enter User Password'));
  try
    pHTML.LoadFromStream(fs);
  finally
    fs.Free;
  end;
  AskForUPForm.ePassword.SetFocus;
end;

end.

