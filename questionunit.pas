unit QuestionUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IpHtml, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, ComboEx, ButtonPanel, StdCtrls, EditBtn, GuidePageUnit;

type

  { TQuestionForm }

  TQuestionForm = class(TForm)
    bOk: TBitBtn;
    bYes: TBitBtn;
    bNo: TBitBtn;
    bCancel: TBitBtn;
    bHelp: TBitBtn;
    cLanguage: TComboBoxEx;
    Edit: TEdit;
    FileNameEdit: TFileNameEdit;
    ilLanguages: TImageList;
    mQuestion: TMemo;
    Panel: TPanel;
    QuestionPanelKillTimer: TTimer;
    procedure bCancelClick(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
    procedure bOkClick(Sender: TObject);
    procedure bNoClick(Sender: TObject);
    procedure bYesClick(Sender: TObject);
    procedure cLanguageChange(Sender: TObject);
    procedure QuestionPanelKillTimerTimer(Sender: TObject);
    procedure RebuildLanguageCombo();
    procedure FormShow(Sender: TObject);
  private

  public
    qTag:ansistring;
    helpTag:ansistring;

  end;

type
  tAskQuestionOnAnswer=procedure(sender:tObject;ModalResult:tModalResult;tag:ansistring) of Object;

  TQuestionPanel = class (tPanel)
    private
      fOnAnswer:tAskQuestionOnAnswer;
      eList:tlist;
      procedure bCancelClick(Sender: TObject);
      procedure bHelpClick(Sender: TObject);
      procedure bOkClick(Sender: TObject);
      procedure bNoClick(Sender: TObject);
      procedure bYesClick(Sender: TObject);
    public
      fText:string;
      qTag:ansistring;
      helpTag:ansistring;
      bOk: TBitBtn;
      bYes: TBitBtn;
      bNo: TBitBtn;
      bCancel: TBitBtn;
      bHelp: TBitBtn;
      //IpHtmlPanel: TIpHtmlPanel;
      gpPanel: tGuidePage;
      FileNameEdit:tFileNameEdit;
      Edit:tEdit;
      cLanguage:tComboBox;
      //capImage:tImage;
      constructor create(aOwner:tForm;onAnswer:tAskQuestionOnAnswer;Message:string;ahelpTag:ansistring=''; aTag:ansistring='');
      destructor destroy(); override;
      procedure close;
      procedure Update();
      procedure cLanguageChange(Sender: TObject);
      procedure RebuildLanguageCombo();
      procedure setText(aText:string='');
  end;


var
  QuestionForm: TQuestionForm;

function AskQuestionTag(Parent:tForm;onAnswer:tAskQuestionOnAnswer;qTag:ansistring;helpTag:ansistring=''):TQuestionPanel; overload;
function AskQuestion(Parent:tForm;onAnswer:tAskQuestionOnAnswer;Message:string;helpTag:ansistring=''; Tag:ansistring=''):TQuestionPanel; overload;


function AskQuestionTag(qTag:ansistring;helpTag:ansistring=''):tModalResult; overload;
function AskQuestion(Message:string;helpTag:ansistring=''):tModalResult;  overload;
procedure AskQuestionInit();
procedure AskQuestionUpdate();

procedure wipeAskQuestion(Parent:tForm);

implementation

uses localizzzeUnit, lclintf, settingsunit, math, HelpRedirector;

{$R *.lfm}
var
  QuestionPanelKillList:tList;

{TQuestionPanel}
procedure TQuestionPanel.close;
var i:integer;
begin
  for i:=0 to eList.Count-1 do
    if eList[i]<>nil then
      try
        tWinControl(eList[i]).enabled:=true;
        if tWinControl(eList[i]) is TQuestionPanel then
          tWinControl(eList[i]).BringToFront;
      except
      end;

  QuestionPanelKillList.Add(self);
  QuestionForm.QuestionPanelKillTimer.Enabled:=true;
end;

procedure TQuestionPanel.bCancelClick(Sender: TObject);
begin
  if assigned(fOnAnswer) then
     fOnAnswer(self,mrCancel,qTag);
  close;
end;

procedure TQuestionPanel.bHelpClick(Sender: TObject);
begin
  if helpTag=''
  then
    showHelpTag(qTag)
  else
    showHelpTag(helpTag);
  //if helpURL=''
  //  then OpenDocument('http://EmerAPI.info')
  //  else OpenDocument(helpURL);
end;

procedure TQuestionPanel.bOkClick(Sender: TObject);
begin
  if assigned(fOnAnswer) then
     fOnAnswer(self,mrOk,qTag);
  close;
end;

procedure TQuestionPanel.bNoClick(Sender: TObject);
begin
  if assigned(fOnAnswer) then
     fOnAnswer(self,mrNo,qTag);
  close;
end;

procedure TQuestionPanel.bYesClick(Sender: TObject);
begin
  if assigned(fOnAnswer) then
     fOnAnswer(self,mrYes,qTag);
  close;
end;


procedure TQuestionPanel.RebuildLanguageCombo();
var i:integer;
  //  idx:integer;
begin
  cLanguage.Items.Clear;
  for i:=0 to languages.Count-1 do begin
      //idx:=-1;
      //if uppercase(languages[i])='EN' then idx:=0;
      //if uppercase(languages[i])='RU' then idx:=1;
      cLanguage.Items.Add(localizzzeString('QUESTIONFORM.CLANGUAGE.'+ansiuppercase(languages[i]),languages[i]){,idx});
  end;

  if languages.IndexOf(CurrentLanguage)>=0 then
    cLanguage.ItemIndex:=languages.IndexOf(CurrentLanguage);
end;

procedure TQuestionPanel.cLanguageChange(Sender: TObject);
begin
  if (languages.Count>cLanguage.ItemIndex) and (cLanguage.ItemIndex>=0) and (CurrentLanguage<>languages[cLanguage.ItemIndex]) then begin
    //CurrentLanguage:=languages[cLanguage.ItemIndex];
    if Settings<>nil then Settings.setValue('Language',languages[cLanguage.ItemIndex]);
    localizzze(self);
    //mQuestion.Text:=localizzzeString(uppercase(qTag),'');
    setText;
    RebuildLanguageCombo();
  end;
end;

procedure TQuestionPanel.setText(aText:string='');
var
  //fs: TStringStream;
  //pHTML: TIpHtml;
  s:string;
  //IpHtmlPanel:tIpHtmlPanel;
begin
  if aText='' then
    if qTag<>''
      then aText:=localizzzeString(qTag,fText)
      else aText:=fText;

  if pos('<HTML>',trim(uppercase(aText)))<>1 then begin
     s:='';
     if CurrentLanguage='ru' then s:='<head><meta http-equiv=\"content-type\" content=\"text/html; charset=windows-1251\" /></head>';
     aText:='<HTML>'+s+'<BODY>'+aText+'</BODY></HTML>';
  end;

  gpPanel.setText(aText);
{
  fs := TStringStream.Create( aText );
  //fs := TStringStream.Create( '<HTML><BODY><H1>Test</H1></BODY></HTML>' );
  try
    pHTML:=TIpHtml.Create; // Beware: Will be freed automatically by IpHtmlPanel1
    pHTML.LoadFromStream(fs);
  finally
    fs.Free;
  end;

  IpHtmlPanel.SetHtml( pHTML );
}
end;

constructor TQuestionPanel.create(aOwner:tForm;onAnswer:tAskQuestionOnAnswer;Message:string;ahelpTag:ansistring=''; aTag:ansistring='');
var i:integer;
begin

  fOnAnswer:=onAnswer;
{  capImage:=tImage.Create(aOwner); capImage.Parent:=aOwner;
  capImage.Left:=0; capImage.Top:=0;
  capImage.Width:=aOwner.ClientWidth;
  capImage.Height:=aOwner.ClientHeight;
  capImage.Anchors:=[akBottom,akLeft, akRight, akTop];
  capImage.BringToFront;
  capImage.Picture.Bitmap.Clear;
  capImage.Picture.Bitmap.Canvas.Brush.Color:=tColor($88888888);
  capImage.Picture.Bitmap.Canvas.FillRect(0,0,capImage.Width-1,capImage.Height-1);
  //capImage.Picture.Bitmap.Canvas.FloodFill(1,1,tColor($808080),fsBorder{fsSurface});
 }

  eList:=tList.Create;
  if aOwner is TWinControl then
    for i:=0 to TWinControl(aOwner).ControlCount-1 do
       //!if not (TWinControl(aOwner).Controls[i] is TQuestionPanel) then
        if TWinControl(aOwner).Controls[i].Visible then
          if TWinControl(aOwner).Controls[i].Enabled then begin
             TWinControl(aOwner).Controls[i].Enabled:=false;
             eList.Add(TWinControl(aOwner).Controls[i]);
          end;


  inherited create(aOwner);

  Width:=min(aOwner.ClientWidth-10,max(aOwner.ClientWidth div 2,600));
  Height:=min(aOwner.ClientHeight-10,min((Width * 2) div 3, 400));

  Left:=(aOwner.ClientWidth-Width) div 2;
  Top:=(aOwner.ClientHeight-Height) div 2;
  BevelOuter:=bvRaised;
  BevelInner:=bvLowered;//bvNone;
  //ControlStyle := ControlStyle + [csOpaque] - [csParentBackground];
  //Anchors:=[akBottom,akLeft, akRight, akTop];
  Anchors:=[];
  //alphablended := true;

  qTag:=aTag;
  helpTag:=ahelpTag;

  fText:=Message;

  //IpHtmlPanel:= TIpHtmlPanel.Create(self); IpHtmlPanel.Parent:=self;
  //IpHtmlPanel.Left:=5; IpHtmlPanel.Top:=5; IpHtmlPanel.Width:=Width-10; IpHtmlPanel.Height:=Height-205;
  //IpHtmlPanel.Anchors:=[akBottom,akLeft, akRight, akTop];

  FileNameEdit:= tFileNameEdit.Create(self); FileNameEdit.Parent:=self;
  FileNameEdit.Left:=5; FileNameEdit.Width:=Width-10;
  FileNameEdit.Anchors:=[akBottom,akLeft, akRight];
  FileNameEdit.Top:=5{IpHtmlPanel.Top}+{IpHtmlPanel.Height}Height-205+5;

  Edit:= tEdit.Create(self); Edit.Parent:=self;
  Edit.Left:=5; Edit.Width:=Width-10;
  Edit.Anchors:=[akBottom,akLeft, akRight];
  Edit.Top:=FileNameEdit.Top+FileNameEdit.Height+5;

  bOk:= TBitBtn.Create(self); bOk.Parent:=self; bOk.Anchors:=[akBottom,akRight]; bOk.Caption:='Ok'; bOk.Top:=Height-bOk.Height-5;
  bOk.Width:=120; bOk.Height:=40;
  bYes:= TBitBtn.Create(self); bYes.Parent:=self; bYes.Anchors:=[akBottom,akRight]; bYes.Caption:='Yes'; bYes.Top:=Height-bYes.Height-5;
  bYes.Width:=120; bYes.Height:=40;
  bNo:= TBitBtn.Create(self); bNo.Parent:=self;  bNo.Anchors:=[akBottom,akRight]; bNo.Caption:='No'; bNo.Top:=Height-bNo.Height-5;
  bNo.Width:=120; bNo.Height:=40;
  bHelp:= TBitBtn.Create(self); bHelp.Parent:=self; bHelp.Anchors:=[akBottom,akLeft]; bHelp.Caption:='Help'; bHelp.Top:=Height-bHelp.Height-5;
  bHelp.Width:=120; bHelp.Height:=40;
  bCancel:= TBitBtn.Create(self); bCancel.Parent:=self; bCancel.Anchors:=[akBottom,akRight]; bCancel.Caption:='Cancel'; bCancel.Top:=Height-bCancel.Height-5;
  bCancel.Width:=120; bCancel.Height:=40;



  cLanguage:= tCombobox.Create(self); cLanguage.Parent:=self;
  cLanguage.Height:=bCancel.Height;
  cLanguage.Style:=csDropDownList;
  cLanguage.Left:=5; cLanguage.Width:=120;
  cLanguage.Anchors:=[akBottom,akLeft];
  cLanguage.Top:=Edit.Top+Edit.Height+5;


  bOk.Name:='bOk';
  bYes.Name:='bYes';
  bNo.Name:='bNo';
  bHelp.Name:='bHelp';
  bCancel.Name:='bCancel';
  cLanguage.Name:='cLanguage';

  bOk.Font.Size:=12;
  bYes.Font.Size:=12;
  bNo.Font.Size:=12;
  bHelp.Font.Size:=12;
  bCancel.Font.Size:=12;
  cLanguage.Font.Size:=12;

  bCancel.OnClick:=@bCancelClick;
  bOk.OnClick:=@bOkClick;
  bYes.OnClick:=@bYesClick;
  bNo.OnClick:=@bNoClick;
  bHelp.OnClick:=@bHelpClick;


  cLanguage.OnChange:=@cLanguageChange;

  localizzze(self);


  //init

  //top->bottom
  FileNameEdit.Visible:=False;
  Edit.Visible:=false;

  //r->l
  bOk.Visible:=false;
  bYes.Visible:=false;
  bNo.Visible:=false;
  bCancel.Visible:=false;

  //l->r
  bHelp.Visible:=false;
  cLanguage.Visible:=false;

  Edit.text:='';
  Edit.PasswordChar:=#0;
  FileNameEdit.Text:='';
  FileNameEdit.Filter:='*.*|*.*';
  FileNameEdit.DefaultExt:='';

  gpPanel:=tGuidePage.Create(self,qTag,fText);
  gpPanel.Left:=5; gpPanel.Top:=5; gpPanel.Width:=Width-10; gpPanel.Height:=Height-205;
  gpPanel.Anchors:=[akBottom,akLeft, akRight, akTop];

  setText();


  bOk.TabOrder:=8;
  bYes.TabOrder:=7;
  bNo.TabOrder:=6;
  bCancel.TabOrder:=5;
  cLanguage.TabOrder:=4;
  bHelp.TabOrder:=3;
  Edit.TabOrder:=2;
  FileNameEdit.TabOrder:=1;
  gpPanel.TabOrder:=0;

  parent:=aOwner;

end;

destructor TQuestionPanel.destroy();
begin
  if bOk<>nil then freeAndNil(bOk);
  if bYes<>nil then freeAndNil(bYes);
  if bNo<>nil then freeAndNil(bNo);
  if bCancel<>nil then freeAndNil(bCancel);
  if bHelp<>nil then freeAndNil(bHelp);

  //IpHtmlPanel: TIpHtmlPanel;
  if FileNameEdit<>nil then freeAndNil(FileNameEdit);
  if Edit<>nil then freeAndNil(Edit);
  if cLanguage<>nil then freeAndNil(cLanguage);

  //if capImage<>nil then freeandnil(capImage);
  if eList<>nil then freeandnil(eList);

  if gpPanel<>nil then freeandnil(gpPanel);

  inherited;
end;


procedure TQuestionPanel.Update();
var x,y:integer;
  const sep=10;
begin

    y:=Height-sep;
    x:=sep;


    //bottom->top
    y:= y - bYes.Height;
    bYes.Top:=y; bNo.Top:=y; bCancel.Top:=y; bOk.Top:=y;
    bHelp.Top:=y; cLanguage.Top:=y + (bHelp.Height - cLanguage.Height) div 2;


    if FileNameEdit.Visible then begin
       y:= y - sep - FileNameEdit.Height;
       FileNameEdit.Top:=y;
    end;
    if Edit.Visible then begin
      y:= y - sep - Edit.Height;
      Edit.Top:=y;
    end;

    //r->l
    x:=Width;//-sep;
    if bYes.Visible then begin x:=x-bYes.Width-sep; bYes.Left:=x; end;
    if bOk.Visible then begin x:=x-bOk.Width-sep; bOk.Left:=x; end;
    if bNo.Visible then begin x:=x-bNo.Width-sep; bNo.Left:=x; end;
    if bCancel.Visible then begin x:=x-bCancel.Width-sep; bCancel.Left:=x; end;

    //l->r
    x:=sep;
    if bHelp.Visible then begin bHelp.Left:=x; x:=x+bHelp.Width+sep; end;
    if cLanguage.Visible then begin cLanguage.Left:=x; x:=x+cLanguage.Width+sep; end;


    //y:=y+bYes.Height+sep;

    //IpHtmlPanel.Height:=y-sep - IpHtmlPanel.top;
    gpPanel.Height:=y-sep - gpPanel.top;

    //Panel.Height:=y;

    if cLanguage.Visible then RebuildLanguageCombo();

    self.BringToFront;

end;

procedure AskQuestionInit();
begin
  QuestionForm.caption:='Question';

  //top->bottom
  QuestionForm.FileNameEdit.Visible:=False;
  QuestionForm.Edit.Visible:=false;

  //r->l
  QuestionForm.bOk.Visible:=false;
  QuestionForm.bYes.Visible:=false;
  QuestionForm.bNo.Visible:=false;
  QuestionForm.bCancel.Visible:=false;

  //l->r
  QuestionForm.bHelp.Visible:=false;
  QuestionForm.cLanguage.Visible:=false;

  QuestionForm.Edit.text:='';
  QuestionForm.Edit.PasswordChar:=#0;
  QuestionForm.FileNameEdit.Text:='';
  QuestionForm.FileNameEdit.Filter:='*.*|*.*';
  QuestionForm.FileNameEdit.DefaultExt:='';

end;

procedure AskQuestionUpdate();
var x,y:integer;
  const sep=5;
begin
  with QuestionForm do begin
    y:=sep;
    x:=sep;

    //top->bottom
    if FileNameEdit.Visible then begin FileNameEdit.Top:=y; y:=y+FileNameEdit.Height +sep; end;
    if Edit.Visible then begin Edit.Top:=y; y:=y+Edit.Height +sep; end;

    //r->l
    x:=Panel.Width-sep;
    bYes.Top:=y; bNo.Top:=y; bCancel.Top:=y; bOk.Top:=y;

    if bYes.Visible then begin x:=x-bYes.Width; bYes.Left:=x; end;
    if bOk.Visible then begin x:=x-bOk.Width; bOk.Left:=x; end;
    if bNo.Visible then begin x:=x-bNo.Width; bNo.Left:=x; end;
    if bCancel.Visible then begin x:=x-bCancel.Width; bCancel.Left:=x; end;

    //l->r
    x:=sep;
    bHelp.Top:=y; cLanguage.Top:=y;
    if bHelp.Visible then begin bHelp.Left:=x; x:=x+bHelp.Width+sep; end;
    if cLanguage.Visible then begin cLanguage.Left:=x; x:=x+cLanguage.Width+sep; end;

    y:=y+bYes.Height+sep;

    Panel.Height:=y;
  end;
end;


function AskQuestion(Message:string;helpTag:ansistring=''):tModalResult;
begin
  if helpTag='' then QuestionForm.helpTag:='' else QuestionForm.helpTag:=helpTag; //genuis!

  QuestionForm.mQuestion.Text:=Message;

  if QuestionForm.cLanguage.Visible then
     QuestionForm.RebuildLanguageCombo();

  AskQuestionUpdate();
  result:=QuestionForm.ShowModal;

end;

function AskQuestionTag(qTag:ansistring;helpTag:ansistring=''):tModalResult;
begin
  QuestionForm.qTag:=qTag;
  QuestionForm.mQuestion.Text:=localizzzeString(uppercase(qTag),'');

  result:=AskQuestion(QuestionForm.mQuestion.Text,helpTag);
  QuestionForm.qTag:='';

end;

function AskQuestionTag(Parent:tForm;onAnswer:tAskQuestionOnAnswer;qTag:ansistring;helpTag:ansistring=''):TQuestionPanel;
var Text:string;
begin
  //QuestionForm.qTag:=qTag;
  Text:=localizzzeString(uppercase(qTag),'');


  result:=AskQuestion(parent,onAnswer,Text,helpTag,qTag);
  //QuestionForm.qTag:='';
end;

function AskQuestion(Parent:tForm;onAnswer:tAskQuestionOnAnswer;Message:string;helpTag:ansistring=''; Tag:ansistring=''):TQuestionPanel;
//var fQuestionPanel:TQuestionPanel;
begin

  //if helpURL='' then QuestionForm.helpURL:='www.emerAPI.info' else QuestionForm.helpURL:=helpURL;
  QuestionForm.helpTag:=helpTag;

  result:=TQuestionPanel.create(Parent,onAnswer,Message,helpTag,Tag);

  result.BringToFront;
//!  QuestionForm.mQuestion.Text:=Message;

//!  if QuestionForm.cLanguage.Visible then
//!   QuestionForm.RebuildLanguageCombo();

//!  AskQuestionUpdate();
//!  result:=QuestionForm.ShowModal;


end;


{ TQuestionForm }

procedure TQuestionForm.FormShow(Sender: TObject);
begin
  localizzze(self);
end;

procedure TQuestionForm.RebuildLanguageCombo();
var i:integer;
    idx:integer;
begin
  QuestionForm.cLanguage.Items.Clear;
  for i:=0 to languages.Count-1 do begin
      idx:=-1;
      if uppercase(languages[i])='EN' then idx:=0;
      if uppercase(languages[i])='RU' then idx:=1;
      QuestionForm.cLanguage.ItemsEx.AddItem(localizzzeString('QUESTIONFORM.CLANGUAGE.'+ansiuppercase(languages[i]),languages[i]),idx);
  end;

  if languages.IndexOf(CurrentLanguage)>=0 then
    QuestionForm.cLanguage.ItemIndex:=languages.IndexOf(CurrentLanguage);
end;

procedure TQuestionForm.cLanguageChange(Sender: TObject);
begin
  if (languages.Count>cLanguage.ItemIndex) and (cLanguage.ItemIndex>=0) and (CurrentLanguage<>languages[cLanguage.ItemIndex]) then begin
    //CurrentLanguage:=languages[cLanguage.ItemIndex];
    if Settings<>nil then Settings.setValue('Language',languages[cLanguage.ItemIndex]);
    localizzze(self);
    QuestionForm.mQuestion.Text:=localizzzeString(uppercase(qTag),'');
    QuestionForm.RebuildLanguageCombo();
  end;
end;

procedure wipeAskQuestion(Parent:tForm);
var i:integer;
begin
  i:=0;
  //while i<Parent.ControlCount do ;
  while i<QuestionPanelKillList.Count do
    if TQuestionPanel(QuestionPanelKillList[i]).Parent=Parent
      then QuestionPanelKillList.Delete(i)
      else inc(i);

end;

procedure TQuestionForm.QuestionPanelKillTimerTimer(Sender: TObject);
begin
  while QuestionPanelKillList.Count>0 do begin
    try
      TQuestionPanel(QuestionPanelKillList[0]).free;
    except
    end;
    QuestionPanelKillList.delete(0);
  end;

  QuestionPanelKillTimer.Enabled:=true;
end;

procedure TQuestionForm.bYesClick(Sender: TObject);
begin
  ModalResult:=mrYes;
end;

procedure TQuestionForm.bOkClick(Sender: TObject);
begin
  ModalResult:=mrOk;
end;

procedure TQuestionForm.bCancelClick(Sender: TObject);
begin
  ModalResult:=mrCancel;
end;

procedure TQuestionForm.bHelpClick(Sender: TObject);
begin
  //OpenURL?
  if helpTag=''
  then
    showHelpTag(qTag)
  else
    showHelpTag(helpTag);
  {
  if helpURL=''
    then OpenDocument('http://EmerAPI.info')
    else OpenDocument(helpURL);
  }
end;

procedure TQuestionForm.bNoClick(Sender: TObject);
begin
  ModalResult:=mrNo;
end;

INITIALIZATION
QuestionPanelKillList:=tList.create;

FINALIZATION
QuestionPanelKillList.free;


end.

