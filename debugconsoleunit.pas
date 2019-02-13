unit DebugConsoleUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons;

type

  { TDebugConsoleForm }

  TDebugConsoleForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Button1: TButton;
    chCutLong: TCheckBox;
    chFilter: TCheckBox;
    chShowOnly: TCheckBox;
    chTime: TCheckBox;
    meDebugConsole: TMemo;
    meFilter: TMemo;
    Panel1: TPanel;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  DebugConsoleForm: TDebugConsoleForm;

procedure debugConsoleShow(msg:string);

implementation

{$R *.lfm}

procedure debugConsoleShow(msg:string);
var
  i:integer;
  f:boolean;
  const MaxLen = 4096;
begin
  if DebugConsoleForm<>nil then
    if DebugConsoleForm.visible then begin

      msg:=trim(msg);
      if DebugConsoleForm.chFilter.checked then begin
        f:=false;
        for i:=0 to DebugConsoleForm.meFilter.lines.count-1 do
          if trim(DebugConsoleForm.meFilter.lines[i])<>'' then
            f:=f or (pos(trim(DebugConsoleForm.meFilter.lines[i]),msg)>0);
        if f xor DebugConsoleForm.chShowOnly.Checked then
          exit;

      end;

      if DebugConsoleForm.chTime.checked then
        msg:=timeToStr(now)+': '+msg;
      if DebugConsoleForm.chCutLong.checked then if length(msg)>MaxLen then begin
          SetLength(msg,MaxLen);
          msg:=msg+'...';
      end;
      DebugConsoleForm.meDebugConsole.Lines.Append(msg);
    end;
end;

{ TDebugConsoleForm }

procedure TDebugConsoleForm.BitBtn1Click(Sender: TObject);
begin
  meDebugConsole.Lines.Clear;
end;

procedure TDebugConsoleForm.BitBtn2Click(Sender: TObject);
begin
  chFilter.Checked:=true;
  meFilter.Text:='[getblock]'#10'[getblockhash]'#10'[scantxoutset'#10'[getrawmempool'#10'getblockchaininfo'#10'[getrawtransactionPull'#10'Data received: [__'#10;
end;

procedure TDebugConsoleForm.Button1Click(Sender: TObject);
begin
  meDebugConsole.WordWrap:=not meDebugConsole.WordWrap;
end;

end.

