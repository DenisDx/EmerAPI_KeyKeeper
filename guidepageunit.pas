unit GuidePageUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Graphics, StdCtrls, Forms, Controls
  , Ipfilebroker, IpHtml;

type
  tGuidePage = class(tPanel)
  private
    procedure myOnGetImageXHandler(Sender: TIpHtmlNode; const URL: string;
      var Picture: TPicture);
    procedure HotClickHandler(Sender: TObject);
  public
    pHTML: TIpHtml;
    IpHtmlPanel: tIpHtmlPanel;
    txt: string;
    mTag: ansistring;
    procedure setText(aText: string);
    procedure setTextByTag(aTag: ansistring='');
    constructor Create(aParent: tWinControl; aTag:ansistring=''; aText: string='');
    destructor Destroy();
  end;

//procedure createGuidePage(ParentControl:tWinControl);
//procedure destroyGuidePage(ParentControl:tWinControl);

implementation

uses
  ComCtrls, Buttons,  Localizzzeunit, Math, LCLIntf, HelpRedirector
  {$IFDEF MSWINDOWS}
  , Windows
    {$ENDIF}  ;


 {
procedure tHTMLHandler.ControlClick2({Sender:TIpHtmlCustomPanel; frame:TIpHtmlFrame;} html:TIpHtml;Node: TIpHtmlNodeControl;var handled:Boolean);
begin
  if Node is TIpHtmlNodeCore { TIpHtmlNodeLINK} then
    if (Node as TIpHtmlNodeCore) is TIpHtmlNodeLINK then
      OpenDocument(TIpHtmlNodeLINK((Node as TIpHtmlNodeCore)).HRef)

end;

procedure tHTMLHandler.ControlClick({Sender:TIpHtmlCustomPanel; frame:TIpHtmlFrame;} html:TIpHtml;Node: TIpHtmlNodeControl);
begin

  if Node is TIpHtmlNodeCore { TIpHtmlNodeLINK} then
    if (Node as TIpHtmlNodeCore) is TIpHtmlNodeLINK then
      OpenDocument(TIpHtmlNodeLINK((Node as TIpHtmlNodeCore)).HRef)

end;
}
procedure tGuidePage.HotClickHandler(Sender: TObject);
var s:string;
begin

  if Sender is TIpHtmlPanel then
    if (Sender as TIpHtmlPanel).HotURL <> '' then begin
      s:=(Sender as TIpHtmlPanel).HotURL;

      if copy(lowercase(s),1,5)='help:' then begin
        delete(s,1,5);
        while (length(s)>0) and (s[1]='/') do delete(s,1,1);
        showHelpTag(trim(s));
      end
      else
      if copy(lowercase(s),1,4)='http' then
         OpenURL((Sender as TIpHtmlPanel).HotURL);
    end;

end;

{
procedure destroyGuidePage(ParentControl:tWinControl);
begin
  if ParentControl is TWinControl then
    while TWinControl(ParentControl).ControlCount>0 do
      TWinControl(ParentControl).Controls[0].Free;
end;
}

procedure tGuidePage.myOnGetImageXHandler(Sender: TIpHtmlNode;
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

destructor tGuidePage.Destroy();
begin
  FreeAndNil(IpHtmlPanel);
  inherited Destroy;
end;

procedure tGuidePage.setText(aText: string);
var
  fs: TStringStream;
begin
  fs := TStringStream.Create(aText);
  //fs := TStringStream.Create( '<HTML><BODY><H1>Test</H1></BODY></HTML>' );
  try
    pHTML.LoadFromStream(fs);
  finally
    fs.Free;
  end;
  //IpHtmlPanel.SetHtml(pHTML);

end;

procedure tGuidePage.setTextByTag(aTag: ansistring='');
var st:string;
begin
  if aTag='' then  aTag:=mTag;
  if aTag<>'' then
     st:=localizzzeString(aTag, txt)
  else
     st:=txt;
  setText(st);
end;

type
  myTIpHtml = class(TIpHtml)
  end;

constructor tGuidePage.Create(aParent: tWinControl; aTag:ansistring=''; aText: string='');
begin
  if aParent = nil then
    exit;
  inherited Create(aParent{.Owner});

  mTag:=aTag;
  Text:=aText;

  //destroyGuidePage(ParentControl);

  IpHtmlPanel := tIpHtmlPanel.Create(self{aParent}{.Owner});
  IpHtmlPanel.Parent := self;

  IpHtmlPanel.Align := alClient;

  //  IpHtmlPanel.on
  //memo.ReadOnly:=true;
  //memo.BorderStyle:=bsNone;
  //memo.Color:=ParentControl.Color;
  //memo.ScrollBars:=ssAutoBoth;
  IpHtmlPanel.TabStop := False;

  pHTML := TIpHtml.Create; // Beware: Will be freed automatically by IpHtmlPanel1
  IpHtmlPanel.SetHtml(pHTML);

  if mTag='' then mTag:='GuidePages.' + aParent.Name;
  setTextByTag();

  //myOnGetImageXHandler(Sender: TIpHtmlNode; const URL: string; var Picture: TPicture)
  IpHtmlPanel.OnHotClick := @(HotClickHandler);

  myTIpHtml(pHTML).OnGetImageX := @(myOnGetImageXHandler);
  //myTIpHtml(pHTML).OnControlClick2:=@(HTMLHandler.ControlClick2);
  //myTIpHtml(pHTML).OnControlClick:=@(HTMLHandler.ControlClick);
  //  myTIpHtml(pHTML).
  //IpHtmlPanel.OnControlClick2:=@(HTMLHandler.ControlClick2);
  Parent := aParent;
end;

end.
