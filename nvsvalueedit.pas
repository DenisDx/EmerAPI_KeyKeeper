unit NVSValueEdit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, SynEmerNVS;

type

  { TNVSValueEditForm }

  TNVSValueEditForm = class(TForm)
    bClose: TBitBtn;
    bSave: TBitBtn;
    Panel1: TPanel;
    seValue: TSynEdit;
    procedure bCloseClick(Sender: TObject);
    procedure bSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public
    SynEmerNVSSyn:tSynEmerNVSSyn;
  end;

var
  NVSValueEditForm: TNVSValueEditForm;

function NVSValueEditModal(value:string;HighlighterName:ansistring=''):string;

implementation

uses Localizzzeunit
  ,MainUnit
  ;

{$R *.lfm}

{ TNVSValueEditForm }
function NVSValueEditModal(value:string;HighlighterName:ansistring=''):string;
begin

  if (pos(':',HighlighterName)>0) then begin
    setSynHighliterByName(NVSValueEditForm.SynEmerNVSSyn,HighlighterName);
    NVSValueEditForm.seValue.Highlighter:=NVSValueEditForm.SynEmerNVSSyn;
  end
  else
    NVSValueEditForm.seValue.Highlighter:=nil;

  NVSValueEditForm.seValue.Text:=value;
  //NVSValueEditForm.seValue.MarkTextAsSaved;


  if NVSValueEditForm.ShowModal = mrOk
    then result:=trim(NVSValueEditForm.seValue.Text)
    else result:=value;
end;

procedure TNVSValueEditForm.FormShow(Sender: TObject);
begin
  localizzze(self);
end;

procedure TNVSValueEditForm.FormCreate(Sender: TObject);
begin
  if SynEmerNVSSyn=nil then SynEmerNVSSyn:=tSynEmerNVSSyn.Create(self);
end;

procedure TNVSValueEditForm.bSaveClick(Sender: TObject);
begin
  ModalResult:=mrOk;
end;

procedure TNVSValueEditForm.bCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TNVSValueEditForm.FormDestroy(Sender: TObject);
begin
  if SynEmerNVSSyn<>nil then
    freeandnil(SynEmerNVSSyn);
end;

end.

