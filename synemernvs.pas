unit SynEmerNVS;

{$mode objfpc}{$H+}
{ $I synedit.inc}

interface

uses
  SysUtils,
  LCLIntf,
  Classes, Controls, Graphics,
  {SynEditTypes,} SynEditHighlighter, SynEditStrConst;



  type
  {
  TtkTokenKind = (tkAmpersand, tkASP, tkCDATA, tkComment, tkIdentifier, tkKey, tkNull,
    tkSpace, tkString, tkSymbol, tkText, tkUndefKey, tkValue, tkDOCTYPE);

  TRangeState = (rsAmpersand, rsASP, rsCDATA, rsComment, rsKey, rsParam, rsText,
    rsUnKnown, rsValue, rsDOCTYPE);
  }

  tSynEmerNVSMode=(senmAny
    ,senmDNS
    ,senmSSH
    ,senmSSL
    ,senmENUMER
    ,senmDPORoot
    ,senmDPO
    ,senmDOC
    ,senmCERT
   );

  TtkTokenKind = (tkKey,tkSpace,tkSymbol,tkString,tkSeparator,tkNull,tkValue, tkWarning, tkUknownKey, tkUndefKey,tkInvalidValue);
  TRangeState = (
    rsKey,  //before =
    rsUnKnown, //unknown
    rsValue, //value after =
    rtSeparator, //separator
    rsText,  //reserved
    rsParam  //reserved
  );

  setofchar=set of char;

  TProcTableProc = procedure of object;
  TIdentFuncTableFunc = function: TtkTokenKind of object;

  TSynEmerNVSSyn = class(TSynCustomHighlighter)
  private
    //fCommentAttri: TSynHighlighterAttributes;
    //fDirecAttri: TSynHighlighterAttributes;
    //fIdentifierAttri: TSynHighlighterAttributes;
    fInvalidValueAttri: TSynHighlighterAttributes;
    fKeyAttri: TSynHighlighterAttributes;
    fWarningAttri: TSynHighlighterAttributes;
    //fValueAttri: TSynHighlighterAttributes;
    //fNumberAttri: TSynHighlighterAttributes;
    fSpaceAttri: TSynHighlighterAttributes;
    fUndefKeyAttri: TSynHighlighterAttributes;
    fUknownKeyAttri: TSynHighlighterAttributes;
    fStringAttri: TSynHighlighterAttributes;
    fSymbolAttri: TSynHighlighterAttributes;
    FTokenID: TtkTokenKind;
    Run: Longint;
    fLine: PChar;
    fTokenPos: Integer;
    fRange: TRangeState;
    fProcTable: array[#0..#255] of TProcTableProc;
    fIdentFuncTable: array[0..1] of TIdentFuncTableFunc;
    fLineNumber: Integer;
    fToIdent: PChar;
    fStringLen: Integer;
    Temp: PChar;

    fKey:ansistring;
{
    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(const aKey: string): Boolean;
    function Func1: TtkTokenKind;
    function AltFunc: TtkTokenKind;
 }
    //function IdentKind(MayBe: PChar): TtkTokenKind;

    procedure MakeMethodTables;
    procedure CRProc;
    //procedure EqualProc;
    procedure IdentProc;
    procedure LFProc;
    procedure NullProc;
    procedure SpaceProc;
    //procedure InitIdent;

    procedure keyProc;
    procedure ValueProc;

    function checkKey(key:ansistring):TtkTokenKind;
    function checkValue(value:ansistring):TtkTokenKind;
    function checkText(value:ansistring):TtkTokenKind;

    function isNameValueValue:boolean;

    function getStopSet:setofchar;

  protected
    //function GetIdentChars: TSynIdentChars; override;
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes; override;
  public
    class function GetCapabilities: TSynHighlighterCapabilities; override;
    class function GetLanguageName: string; override;
  public
    mode:tSynEmerNVSMode;
    function GetEol: Boolean; override;
    function GetToken: String; override;
    procedure GetTokenEx(out TokenStart: PChar; out TokenLength: integer); override;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenKind: integer; override;
    function GetTokenPos: Integer; override; // 0-based
    procedure Next; override;

    function GetTokenID: TtkTokenKind;

    procedure SetLine(const NewValue: String; LineNumber:Integer); override;
    constructor Create(AOwner: TComponent); override;

    class function findKey(key:ansistring;karray:array of String;adv:boolean=false):boolean;

 {   constructor Create(AOwner: TComponent); override;
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes; override;
    function GetEol: Boolean; override;
    function GetRange: Pointer; override;
    //function GetTokenID: TtkTokenKind;
    procedure SetLine(const NewValue: String; LineNumber:Integer); override;
    function GetToken: String; override;
    procedure GetTokenEx(out TokenStart: PChar; out TokenLength: integer); override;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenKind: integer; override;
    function GetTokenPos: Integer; override;
    procedure Next; override;
    procedure SetRange(Value: Pointer); override;
    procedure ResetRange; override;
    function UseUserSettings(settingIndex: integer): boolean; override;
    procedure EnumUserSettings(settings: TStrings); override;
    property ExtTokenID: TxtkTokenKind read GetExtTokenID;
    }
  published
  end;

implementation

var
  mHashTable: array[#0..#255] of Integer;


function TSynEmerNVSSyn.GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
begin
  case Index of
    //SYN_ATTR_COMMENT: Result := fCommentAttri;
    //SYN_ATTR_COMMENT: Result := fCommentAttri;
    //SYN_ATTR_IDENTIFIER: Result := fIdentifierAttri;
    SYN_ATTR_KEYWORD: Result := fKeyAttri;
    SYN_ATTR_WHITESPACE: Result := fSpaceAttri;
    SYN_ATTR_STRING: Result := fStringAttri;
    else Result := nil;
     {
    SYN_ATTR_IDENTIFIER: Result := fIdentifierAttri;
    SYN_ATTR_KEYWORD: Result := fKeyAttri;
    SYN_ATTR_STRING: Result := fStringAttri;
    SYN_ATTR_WHITESPACE: Result := fSpaceAttri;
    SYN_ATTR_NUMBER: Result := fNumberAttri;
    SYN_ATTR_DIRECTIVE: Result := fDirecAttri;
    SYN_ATTR_ASM: Result := fAsmAttri;
    else Result := nil;
    }
  end;
end;

class function TSynEmerNVSSyn.GetLanguageName: string;
begin
  Result := 'EmerNVS';
end;

class function TSynEmerNVSSyn.GetCapabilities: TSynHighlighterCapabilities;
begin
  Result := inherited GetCapabilities + [hcUserSettings];
end;

function TSynEmerNVSSyn.GetEol: Boolean;
begin
  Result := fTokenID = tkNull;
end;

{
function TSynEmerNVSSyn.GetRange: Pointer;
begin
  Result := Pointer(PtrInt(fRange));
end;
 }

function TSynEmerNVSSyn.GetToken: String;
var
  Len: LongInt;
begin
  Result := '';
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

procedure TSynEmerNVSSyn.GetTokenEx(out TokenStart: PChar;
  out TokenLength: integer);
begin
  TokenLength:=Run-fTokenPos;
  TokenStart:=FLine + fTokenPos;
end;

function TSynEmerNVSSyn.GetTokenAttribute: TSynHighlighterAttributes;
begin
  case fTokenID of
    //tkAsm: Result := fAsmAttri;
    //tkComment: Result := fCommentAttri;
    //tkDirective: Result := fDirecAttri;
    //tkIdentifier: Result := fIdentifierAttri;
    tkKey: Result := fKeyAttri;
    //tkNumber: Result := fNumberAttri;
    //tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkSymbol: Result := fSymbolAttri;
    tkUndefKey: Result := fUndefKeyAttri;
    tkUknownKey: Result := fUknownKeyAttri;
    tkInvalidValue: Result := fInvalidValueAttri;
    tkWarning: Result := fWarningAttri;

    else Result := nil;
  end;
end;

function TSynEmerNVSSyn.GetTokenKind: integer;
begin
  Result := Ord(GetTokenID);
end;

function TSynEmerNVSSyn.GetTokenPos: Integer;
begin
  Result := fTokenPos;
end;

procedure TSynEmerNVSSyn.Next;
begin
  fTokenPos := Run;

  {
  case fRange of
    rsKey: KeyProc;
    rsValue: ValueProc;
  else
    fProcTable[fLine[Run]];
  end;
  }
  fProcTable[fLine[Run]];
end;

function TSynEmerNVSSyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

procedure TSynEmerNVSSyn.SetLine(const NewValue: string; LineNumber:Integer);
begin
  inherited;
  fLine := PChar(NewValue);
  Run := 0;
  fLineNumber := LineNumber;

  fRange:=rsUnKnown;
  Next;
end;

procedure TSynEmerNVSSyn.MakeMethodTables;
var
  i: Char;
begin
  For i:=#0 To #255 do begin
    case i of
    #0:
      begin
        fProcTable[i] := @NullProc;
      end;
    #10:
      begin
        fProcTable[i] := @LFProc;
      end;
    #13:
      begin
        fProcTable[i] := @CRProc;
      end;
    #1..#9, #11, #12, #14..#32:
      begin
        fProcTable[i] := @SpaceProc;
      end;
{    '&':
      begin
        fProcTable[i] := @AmpersandProc;
      end;
    '"':
      begin
        fProcTable[i] := @StringProc;
      end;
    '<':
      begin
        fProcTable[i] := @BraceOpenProc;
      end;
    '>':
      begin
        fProcTable[i] := @BraceCloseProc;
      end;

    '=':
      begin
        fProcTable[i] := @EqualProc;
      end;
      }
    else
      fProcTable[i] := @IdentProc;
    end;
  end;
end;

constructor TSynEmerNVSSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
 {
  fASPAttri := TSynHighlighterAttributes.Create(@SYNS_AttrASP, SYNS_XML_AttrASP);
  fASPAttri.Foreground := clBlack;
  fASPAttri.Background := clYellow;
  AddAttribute(fASPAttri);

  fCDATAAttri := TSynHighlighterAttributes.Create(@SYNS_AttrCDATA, SYNS_XML_AttrCDATA);
  fCDATAAttri.Foreground := clGreen;
  AddAttribute(fCDATAAttri);

  fDOCTYPEAttri := TSynHighlighterAttributes.Create(@SYNS_AttrDOCTYPE, SYNS_XML_AttrDOCTYPE);
  fDOCTYPEAttri.Foreground := clBlack;
  fDOCTYPEAttri.Background := clYellow;
  fDOCTYPEAttri.Style := [fsBold];
  AddAttribute(fDOCTYPEAttri);
  }
  //fCommentAttri := TSynHighlighterAttributes.Create(@SYNS_AttrComment, SYNS_XML_AttrComment);
  //AddAttribute(fCommentAttri);


  //fIdentifierAttri := TSynHighlighterAttributes.Create(@SYNS_AttrIdentifier, SYNS_XML_AttrIdentifier);
  //fIdentifierAttri.Style := [fsBold];
  //AddAttribute(fIdentifierAttri);

  fKeyAttri := TSynHighlighterAttributes.Create(@SYNS_AttrReservedWord, SYNS_XML_AttrReservedWord);
  fKeyAttri.Style := [fsBold];
  fKeyAttri.Foreground := $00ff0080;
  AddAttribute(fKeyAttri);

  fSpaceAttri := TSynHighlighterAttributes.Create(@SYNS_AttrSpace, SYNS_XML_AttrSpace);
  AddAttribute(fSpaceAttri);

  fSymbolAttri := TSynHighlighterAttributes.Create(@SYNS_AttrSymbol, SYNS_XML_AttrSymbol);
  fSymbolAttri.Style := [fsBold];
  AddAttribute(fSymbolAttri);


//  fTextAttri := TSynHighlighterAttributes.Create(@SYNS_AttrText, SYNS_XML_AttrText);
//  AddAttribute(fTextAttri);

  fUndefKeyAttri := TSynHighlighterAttributes.Create(@SYNS_AttrUnknownWord, SYNS_XML_AttrUnknownWord);
  fUndefKeyAttri.Style := [fsBold];
  fUndefKeyAttri.Foreground := clRed;
  AddAttribute(fUndefKeyAttri);

  fUknownKeyAttri := TSynHighlighterAttributes.Create(@SYNS_AttrText, SYNS_XML_AttrText);
  AddAttribute(fUknownKeyAttri);


  fInvalidValueAttri := TSynHighlighterAttributes.Create(@SYNS_AttrInvalidSymbol, SYNS_XML_AttrInvalidSymbol);
  //fUndefKeyAttri.Style := [fsBold];
  fInvalidValueAttri.Foreground := clRed;
  AddAttribute(fInvalidValueAttri);

  fStringAttri := TSynHighlighterAttributes.Create(@SYNS_AttrString, SYNS_XML_AttrString);
  fStringAttri.Foreground := clMaroon;//$00208020;
  AddAttribute(fStringAttri);


  //fValueAttri := TSynHighlighterAttributes.Create(@SYNS_AttrValue, SYNS_XML_AttrValue);
  //fValueAttri.Foreground := $00ff8000;
 // AddAttribute(fValueAttri);

  fWarningAttri := TSynHighlighterAttributes.Create(@SYNS_AttrValue, SYNS_XML_AttrValue);
  fWarningAttri.Style:=[fsBold];
  fWarningAttri.Background:=clYellow;
  AddAttribute(fWarningAttri);
  {
  fAndAttri := TSynHighlighterAttributes.Create(@SYNS_AttrEscapeAmpersand, SYNS_XML_AttrEscapeAmpersand);
  fAndAttri.Style := [fsBold];
  fAndAttri.Foreground := $0000ff00;
  AddAttribute(fAndAttri);
  }
  SetAttributesOnChange(@DefHighlightChange);

  //InitIdent;
  MakeMethodTables;
  fRange := rsUnknown; //rsText;
  fDefaultFilter := ''; //SYNS_FilterHTML;
end;

procedure TSynEmerNVSSyn.CRProc;
begin
  fTokenID := tkSpace;
  Inc(Run);
  if fLine[Run] = #10 then Inc(Run);
end;

{
procedure TSynEmerNVSSyn.EqualProc;
begin
  fRange := rsValue;
  fTokenID := tkSymbol;
  Inc(Run);
end;
}
{
function TSynEmerNVSSyn.IdentKind(MayBe: PChar): TtkTokenKind;
var
  hashKey: Integer;
begin
  fToIdent := MayBe;
  hashKey := KeyHash(MayBe);
  if (hashKey <= 255) then begin
    Result := fIdentFuncTable[hashKey]();
  end else begin
    Result := tkIdentifier;
  end;
end;
 }


function TSynEmerNVSSyn.isNameValueValue:boolean;
begin
  result:=mode in [senmAny,senmSSL,senmDNS,senmENUMER,senmDPORoot,senmDPO,senmDOC,senmCERT];
end;

var
  //* means MUST have *
  //? means COULD have *
  //? at the end means could have suffix
  //?? at the end means could have 2 suffixes

  dnsKeys:array[0..9] of string=('A','AAAA','CNAME','MX','SOA','TXT','NS','SRV'{,'CAA'},'TTL','SD'); //TTL=<сек> //SD=
  dpoKeys:array[0..0] of string=('Signature');
  docKeys:array[0..14] of string=('?TITLE','?DESCRIPTION?','?REV','?SHA256','?SHA512','?TEXT','?AUTHOR','?URL','?UNSIGN','?EMSIGN','?BTSIGN','?ETSIGN','?ADSIGN','?PARENT','?RCERT');
  certKeys:array[0..21] of string=('*LIST','*ISSUER','*EXDATE','SIGN','*SIGNER','*TAG','*N'
    ,'?ASIGN','*NAME','*PUBKEY','*CNAME','*VALUE','RCERT','*DETAILS?','*DESC?','*ISDATE','?CSIGN','*CDATA','*DOCNAME','*DOCSHA256','*DOCSHA512','?DOCURL');



class function TSynEmerNVSSyn.findKey(key:ansistring;karray:array of String;adv:boolean=false):boolean;
var i:integer;
    rest:ansistring;
    scount:integer;
    starred:boolean;

    tk:ansistring;
    tkscount:integer;
begin
  result:=true;
  starred:=false;
  scount:=0;
  if adv then begin
    i:=pos(':',key);
    if i>0 then begin
      rest:=copy(key,i+1,length(key)-i);
      key:=copy(key,1,i-1);
      scount:=1;
      i:=pos(':',rest);
      while i>0 do begin
        scount:=scount+1;
        delete(rest,1,i);
        i:=pos(':',rest);
      end;
    end;
    if (key<>'') and (key[1]='*') then begin
      starred:=true;
      delete(key,1,1);
    end;
  end;

  for i:=0 to length(karray)-1 do
    if adv
      then begin
        if length(karray[i])<1 then continue;
        tk:=karray[i];

        if (tk[1] in ['?','*']) then begin
          if (tk[1]='*') and (not starred) then continue;
          delete(tk,1,1);
        end else if (starred) then continue;

        if scount>0 then begin
          tkscount:=0;
          while (tk<>'') and (tk[length(tk)]='?') do begin
            tkscount:=tkscount+1;
            delete(tk,length(tk),1);
          end;

          if tkscount<scount then continue;
        end;

        if tk=key then exit;
      end else begin
        if karray[i]=key then exit;
      end;


  result:=false;
end;

//"name" : "enum:12027139373:0"     формат E164, без плюса
//"value" : "SIG=ver:enum|HxQY4nUHtf+nK/btxa0jT4UuPQPKk0pyxrJuXlF8YVVFDKhY6PVcE1XiSvTOxlQryzfA1GIH2IRYk7uGHrZIbP4= E2U+sip=100|10|!.*$!sip:17772328716@in.callcentric.com
//SIG=verifier|signature E2U+sip=PRI1|PRI2|RegExp                 multiline!

function TSynEmerNVSSyn.checkKey(key:ansistring):TtkTokenKind;
begin
  result := tkKey; //tkUndefKey  tkUknownKey
  //if mode = senmAny then exit;
  case mode of
    senmDNS:
      if not findKey(key,dnsKeys) then result := tkUndefKey;
    //senmSSH:
    senmSSL: if key<>'sha256' then result := tkUknownKey;
    senmENUMER: if key<>'SIG' then result := tkUknownKey;
    senmDPORoot: result := tkUknownKey;
    senmDPO: if not findKey(key,dpoKeys) then result := tkUknownKey;
    senmDOC: if not findKey(key,docKeys,true) then result := tkUknownKey;
    senmCERT: if not findKey(key,certKeys,true) then result := tkUknownKey;
  end;

end;

function TSynEmerNVSSyn.checkValue(value:ansistring):TtkTokenKind;
var i,c:integer;
begin
  result := tkValue;
  if mode=senmDNS then begin
     if (fKey='A') then
       if trim(value)='127.0.0.1' then result := tkWarning;
     if (fKey='TTL') then
        try
          strtoint(value)
        except
          result := tkInvalidValue;
        end;
  end;
  if mode=senmSSL then begin
     if (fKey='sha256') then
        if (length(value)>2) and (value[1]='*') and (value[length(value)]='*') then result := tkWarning
        else
        for i:=1 to length(value) do
          if not (value[i] in ['0'..'9','a'..'f']) then begin
             result := tkInvalidValue;
             exit;
          end;

  end;
  if mode=senmSSH then begin
    //@ or ssh-rsa AA9Ecz ...
    value:=trim(value);
    if value<>'' then
      if (value[1]<>'@') and (copy(value,1,8)<>'ssh-rsa ') then
        if (length(value)>2) and (value[1]='*') and (value[length(value)]='*') then result := tkWarning
  end;
  if mode=senmENUMER then begin
     if (fKey='SIG') then
       //verifier|signature E2U+sip=PRI1|PRI2|RegExp
       c:=0;
       for i:=1 to length(value) do
         if value[i]='|' then inc(c);

        if c<>3 then
        if (length(value)>2) and (value[1]='*') and (value[length(value)]='*') then result := tkWarning
                                                                               else result := tkInvalidValue;

  end;

  //if value='xxx' then result:=tkInvalidValue;
end;

function TSynEmerNVSSyn.checkText(value:ansistring):TtkTokenKind;
begin
  result:=tkString;

end;

function TSynEmerNVSSyn.getStopSet:setofchar;
begin
  case mode of
    senmDNS: result:=[#0..#31,'|'];

  else
    result:=[#0..#31];
  end;

end;

procedure TSynEmerNVSSyn.IdentProc;
var
  R: LongInt;
var StopSet:set of char;
begin
  StopSet := getStopSet;
  {
  fTokenID := IdentKind((fLine + Run));
  inc(Run, fStringLen);
  //while Identifiers[fLine[Run]] do inc(Run);
//  while Identifiers[fLine[Run]] do inc(Run);

 repeat
   Inc(Run);
 until (fLine[Run] In [#0..#32, '=']);

   }

  R:=Run;

  case fRange of
  rsUnknown{,rsKey}:
    begin
      fKey:='';

      if isNameValueValue then begin
        repeat
          Inc(Run);
        until (fLine[Run] In (StopSet + ['='])) ;

        if fLine[Run]='=' then begin
          fRange := rsKey;
          fTokenID :=checkKey(copy(fLine,R+1,Run-R));
          if fTokenID=tkKey then fKey:=copy(fLine,R+1,Run-R);
          {
          if checkKey(copy(fLine,R,Run-R))
            then begin
               fTokenID := tkKey;
               fKey:=copy(fLine,R,Run-R);
            end else fTokenID := tkUndefKey;
          }
        end else begin
          fTokenID := checkText(copy(fLine,R,Run-R));
          fRange := rsText;
        end;
      end else begin
        repeat
          Inc(Run);
        until (fLine[Run] In StopSet);
        fRange := rsValue;
        fTokenID := checkValue(copy(fLine,R,Run-R+1));
      end;
    end;
  rsKey:
    begin
      repeat
        Inc(Run);
      //until (fLine[Run] In [#0..#31]); //end of tag
      until not ((fLine[Run] In ['='])); //end of tag
      fRange := rsValue;
      fTokenID := tkSymbol;
    end;
  rtSeparator: begin
    repeat
      Inc(Run);
    until (not (fLine[Run] In StopSet)) or (fLine[Run]=#0);
    fTokenID := tkSeparator;// checkValue(copy(fLine,R+1,Run-R));
    fKey:='';
    fRange:=rsUnknown;
  end
  else
    //read value
    repeat
      Inc(Run);
    until (fLine[Run] In StopSet);

    fTokenID := checkValue(copy(fLine,R+1,Run-R));
    fKey:='';

    fRange:=rtSeparator;
  end;

end;

procedure TSynEmerNVSSyn.LFProc;
begin
  fTokenID := tkSpace;
  Inc(Run);
end;

procedure TSynEmerNVSSyn.NullProc;
begin
  fTokenID := tkNull;
end;

procedure TSynEmerNVSSyn.SpaceProc;
begin
  Inc(Run);
  fTokenID := tkSpace;
  while fLine[Run] <= #32 do begin
    if fLine[Run] in [#0, #9, #10, #13] then break;
    Inc(Run);
  end;
end;

procedure TSynEmerNVSSyn.keyProc;
//const StopSet = [#0..#31, '='];
var StopSet:set of char;
begin
  StopSet := getStopSet+['='];

  if fLine[Run] in (StopSet) then begin
    fProcTable[fLine[Run]];
    exit;
  end;

  fTokenID := tkKey;

  while not (fLine[Run] in StopSet) do Inc(Run);
end;

procedure TSynEmerNVSSyn.ValueProc;
//const StopSet = [#0..#31];
var
  i: Integer;
  StopSet:set of char;
begin
  StopSet := getStopSet;

  if fLine[Run] in (StopSet) then begin
    fProcTable[fLine[Run]];
    exit;
  end;

  fTokenID := tkValue;

  while not (fLine[Run] in StopSet) do Inc(Run);
end;



{
procedure TSynEmerNVSSyn.TextProc;
const StopSet = [#0..#31, '<', '&'];
var
  i: Integer;
begin
  if fLine[Run] in (StopSet - ['&']) then begin
    fProcTable[fLine[Run]];
    exit;
  end;

  fTokenID := tkText;
  While True do begin
    while not (fLine[Run] in StopSet) do Inc(Run);

    if (fLine[Run] = '&') then begin
      For i:=Low(EscapeAmps) To High(EscapeAmps) do begin
        if (StrLIComp((fLine + Run), PChar(EscapeAmps[i]), StrLen(EscapeAmps[i])) = 0) then begin
          fAndCode := i;
          fRange := rsAmpersand;
          Exit;
        end;
      end;

      Inc(Run);
    end else begin
      Break;
    end;
  end;

end;
}
{!
procedure TSynEmerNVSSyn.InitIdent;
var
  i: Integer;
begin
  for i := 0 to 2 do
    case i of
      1:   fIdentFuncTable[i] := @Func1;
    {  2:   fIdentFuncTable[i] := @Func2;
      8:   fIdentFuncTable[i] := @Func8;
      9:   fIdentFuncTable[i] := @Func9;
      10:  fIdentFuncTable[i] := @Func10;
      11:  fIdentFuncTable[i] := @Func11;
      12:  fIdentFuncTable[i] := @Func12;
      13:  fIdentFuncTable[i] := @Func13;
      14:  fIdentFuncTable[i] := @Func14;
      15:  fIdentFuncTable[i] := @Func15;
      16:  fIdentFuncTable[i] := @Func16;
      17:  fIdentFuncTable[i] := @Func17;
      18:  fIdentFuncTable[i] := @Func18;
      19:  fIdentFuncTable[i] := @Func19;
      20:  fIdentFuncTable[i] := @Func20;
      21:  fIdentFuncTable[i] := @Func21;
      23:  fIdentFuncTable[i] := @Func23;
      24:  fIdentFuncTable[i] := @Func24;
      25:  fIdentFuncTable[i] := @Func25;
      26:  fIdentFuncTable[i] := @Func26;
      27:  fIdentFuncTable[i] := @Func27;
      28:  fIdentFuncTable[i] := @Func28;
      29:  fIdentFuncTable[i] := @Func29;
      30:  fIdentFuncTable[i] := @Func30;
      31:  fIdentFuncTable[i] := @Func31;
      32:  fIdentFuncTable[i] := @Func32;
      33:  fIdentFuncTable[i] := @Func33;
      34:  fIdentFuncTable[i] := @Func34;
      35:  fIdentFuncTable[i] := @Func35;
      37:  fIdentFuncTable[i] := @Func37;
      38:  fIdentFuncTable[i] := @Func38;
      39:  fIdentFuncTable[i] := @Func39;
      40:  fIdentFuncTable[i] := @Func40;
      41:  fIdentFuncTable[i] := @Func41;
      42:  fIdentFuncTable[i] := @Func42;
      43:  fIdentFuncTable[i] := @Func43;
      46:  fIdentFuncTable[i] := @Func46;
      47:  fIdentFuncTable[i] := @Func47;
      48:  fIdentFuncTable[i] := @Func48;
      49:  fIdentFuncTable[i] := @Func49;
      50:  fIdentFuncTable[i] := @Func50;
      52:  fIdentFuncTable[i] := @Func52;
      53:  fIdentFuncTable[i] := @Func53;
      55:  fIdentFuncTable[i] := @Func55;
      56:  fIdentFuncTable[i] := @Func56;
      57:  fIdentFuncTable[i] := @Func57;
      58:  fIdentFuncTable[i] := @Func58;
      60:  fIdentFuncTable[i] := @Func60;
      61:  fIdentFuncTable[i] := @Func61;
      62:  fIdentFuncTable[i] := @Func62;
      63:  fIdentFuncTable[i] := @Func63;
      64:  fIdentFuncTable[i] := @Func64;
      65:  fIdentFuncTable[i] := @Func65;
      66:  fIdentFuncTable[i] := @Func66;
      67:  fIdentFuncTable[i] := @Func67;
      68:  fIdentFuncTable[i] := @Func68;
      70:  fIdentFuncTable[i] := @Func70;
      76:  fIdentFuncTable[i] := @Func76;
      78:  fIdentFuncTable[i] := @Func78;
      79:  fIdentFuncTable[i] := @Func79;
      80:  fIdentFuncTable[i] := @Func80;
      81:  fIdentFuncTable[i] := @Func81;
      82:  fIdentFuncTable[i] := @Func82;
      83:  fIdentFuncTable[i] := @Func83;
      84:  fIdentFuncTable[i] := @Func84;
      85:  fIdentFuncTable[i] := @Func85;
      86:  fIdentFuncTable[i] := @Func86;
      87:  fIdentFuncTable[i] := @Func87;
      89:  fIdentFuncTable[i] := @Func89;
      90:  fIdentFuncTable[i] := @Func90;
      91:  fIdentFuncTable[i] := @Func91;
      92:  fIdentFuncTable[i] := @Func92;
      93:  fIdentFuncTable[i] := @Func93;
      94:  fIdentFuncTable[i] := @Func94;
      100: fIdentFuncTable[i] := @Func100;
      105: fIdentFuncTable[i] := @Func105;
      107: fIdentFuncTable[i] := @Func107;
      110: fIdentFuncTable[i] := @Func110;
      113: fIdentFuncTable[i] := @Func113;
      114: fIdentFuncTable[i] := @Func114;
      117: fIdentFuncTable[i] := @Func117;
      121: fIdentFuncTable[i] := @Func121;
      123: fIdentFuncTable[i] := @Func123;
      124: fIdentFuncTable[i] := @Func124;
      128: fIdentFuncTable[i] := @Func128;
      130: fIdentFuncTable[i] := @Func130;
      131: fIdentFuncTable[i] := @Func131;
      132: fIdentFuncTable[i] := @Func132;
      133: fIdentFuncTable[i] := @Func133;
      134: fIdentFuncTable[i] := @Func134;
      135: fIdentFuncTable[i] := @Func135;
      136: fIdentFuncTable[i] := @Func136;
      137: fIdentFuncTable[i] := @Func137;
      138: fIdentFuncTable[i] := @Func138;
      139: fIdentFuncTable[i] := @Func139;
      140: fIdentFuncTable[i] := @Func140;
      141: fIdentFuncTable[i] := @Func141;
      143: fIdentFuncTable[i] := @Func143;
      145: fIdentFuncTable[i] := @Func145;
      146: fIdentFuncTable[i] := @Func146;
      149: fIdentFuncTable[i] := @Func149;
      150: fIdentFuncTable[i] := @Func150;
      152: fIdentFuncTable[i] := @Func152;
      153: fIdentFuncTable[i] := @Func153;
      154: fIdentFuncTable[i] := @Func154;
      155: fIdentFuncTable[i] := @Func155;
      156: fIdentFuncTable[i] := @Func156;
      157: fIdentFuncTable[i] := @Func157;
      159: fIdentFuncTable[i] := @Func159;
      160: fIdentFuncTable[i] := @Func160;
      161: fIdentFuncTable[i] := @Func161;
      162: fIdentFuncTable[i] := @Func162;
      163: fIdentFuncTable[i] := @Func163;
      164: fIdentFuncTable[i] := @Func164;
      165: fIdentFuncTable[i] := @Func165;
      168: fIdentFuncTable[i] := @Func168;
      169: fIdentFuncTable[i] := @Func169;
      170: fIdentFuncTable[i] := @Func170;
      171: fIdentFuncTable[i] := @Func171;
      172: fIdentFuncTable[i] := @Func172;
      174: fIdentFuncTable[i] := @Func174;
      175: fIdentFuncTable[i] := @Func175;
      177: fIdentFuncTable[i] := @Func177;
      178: fIdentFuncTable[i] := @Func178;
      179: fIdentFuncTable[i] := @Func179;
      180: fIdentFuncTable[i] := @Func180;
      182: fIdentFuncTable[i] := @Func182;
      183: fIdentFuncTable[i] := @Func183;
      185: fIdentFuncTable[i] := @Func185;
      186: fIdentFuncTable[i] := @Func186;
      187: fIdentFuncTable[i] := @Func187;
      188: fIdentFuncTable[i] := @Func188;
      190: fIdentFuncTable[i] := @Func190;
      192: fIdentFuncTable[i] := @Func192;
      198: fIdentFuncTable[i] := @Func198;
      200: fIdentFuncTable[i] := @Func200;
      201: fIdentFuncTable[i] := @Func201;
      202: fIdentFuncTable[i] := @Func202;
      203: fIdentFuncTable[i] := @Func203;
      204: fIdentFuncTable[i] := @Func204;
      205: fIdentFuncTable[i] := @Func205;
      207: fIdentFuncTable[i] := @Func207;
      208: fIdentFuncTable[i] := @Func208;
      209: fIdentFuncTable[i] := @Func209;
      211: fIdentFuncTable[i] := @Func211;
      212: fIdentFuncTable[i] := @Func212;
      213: fIdentFuncTable[i] := @Func213;
      214: fIdentFuncTable[i] := @Func214;
      215: fIdentFuncTable[i] := @Func215;
      216: fIdentFuncTable[i] := @Func216;
      222: fIdentFuncTable[i] := @Func222;
      227: fIdentFuncTable[i] := @Func227;
      229: fIdentFuncTable[i] := @Func229;
      232: fIdentFuncTable[i] := @Func232;
      235: fIdentFuncTable[i] := @Func235;
      236: fIdentFuncTable[i] := @Func236;
      239: fIdentFuncTable[i] := @Func239;
      243: fIdentFuncTable[i] := @Func243;
      250: fIdentFuncTable[i] := @Func250; }
      else fIdentFuncTable[i] := @AltFunc;
    end;
end;

function TSynEmerNVSSyn.KeyHash(ToHash: PChar): Integer;
begin
  Result := 0;
  While (ToHash^ In ['a'..'z', 'A'..'Z', '!', '/']) do begin
    Inc(Result, mHashTable[ToHash^]);
    Inc(ToHash);
  end;
  While (ToHash^ In ['0'..'9']) do begin
    Inc(Result, (Ord(ToHash^) - Ord('0')) );
    Inc(ToHash);
  end;
  fStringLen := (ToHash - fToIdent);
end;

function TSynEmerNVSSyn.KeyComp(const aKey: string): Boolean;
var
  i: Integer;
begin
  Temp := fToIdent;
  if (Length(aKey) = fStringLen) then begin
    Result := True;
    For i:=1 To fStringLen do begin
      if (mHashTable[Temp^] <> mHashTable[aKey[i]]) then begin
        Result := False;
        Break;
      end;
      Inc(Temp);
    end;
  end else begin
    Result := False;
  end;
end;


function TSynEmerNVSSyn.Func1: TtkTokenKind;
begin
  //NOT USED
  if KeyComp('A') then begin
    Result := tkKey;
  end else begin
    Result := tkUndefKey;
  end;
end;

function TSynEmerNVSSyn.AltFunc: TtkTokenKind;
begin
  Result := tkUndefKey;
end;
}
end.

