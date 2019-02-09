unit x509devUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, Buttons, StdCtrls
  ,X509cert
  ,ClpAsn1Object
  ;

type

  { Tx509devform }

  Tx509devform = class(TForm)
    bCreateFromSeed: TBitBtn;
    BitBtn1: TBitBtn;
    bLoadfromfile: TBitBtn;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    se: TSynEdit;
    Splitter1: TSplitter;
    tw: TTreeView;
    procedure BitBtn1Click(Sender: TObject);
    procedure bLoadfromfileClick(Sender: TObject);
  private

    fClpAsn1Object:TAsn1Object;
  public
    procedure clear;

  end;

var
  x509devform: Tx509devform;

implementation

{$R *.lfm}
uses crypto, CryptoLib4PascalConnectorUnit,

  ClpIAsn1StreamParser,
  ClpAsn1StreamParser,
  ClpIAsn1SequenceParser,

  ClpIDerInteger,
  ClpIDerObjectIdentifier,

  fpcunit,

  ClpIAsn1TaggedObjectParser,
  ClpIProxiedInterface,

  MainUnit
  ;

{ Tx509devform }
procedure Tx509devform.clear;
begin


end;

procedure Tx509devform.bLoadfromfileClick(Sender: TObject);
var st:tFileStream;
    fn:string;
    tx:tStringList;
    s:ansistring;
begin
  if OpenDialog1.Execute then fn:=OpenDialog1.FileName;

  if fClpAsn1Object<>nil then freeandnil(fClpAsn1Object);

  tx:=tStringList.create;
  tx.LoadFromFile(fn);
  s:=tx.Text;
  tx.free;
  s:=base64tobuf(s);

  clear;
  st:=tFileStream.Create(fn,fmOpenRead);
  try
    fClpAsn1Object := TAsn1Object.Create;
//    TAsn1Object.GetDerEncoded();
    //fClpAsn1Object.FromStream(st);
    fClpAsn1Object.FromByteArray(buf2bytes(s));
  finally
    st.Free;
  end;
end;

procedure Tx509devform.BitBtn1Click(Sender: TObject);
var
  aIn: IAsn1StreamParser;
  seq, s: IAsn1SequenceParser;
  //!o: IInterface;
  count: Int32;

  o:IAsn1Convertible;

  tx:tStringList;
  buf:ansistring;
  fn:tFileName;
begin

  if OpenDialog1.Execute then fn:=OpenDialog1.FileName;
  try
    tx:=tStringList.create;
    tx.LoadFromFile(fn);
    tx.Delete(0);
    tx.Delete(tx.Count-1);
    buf:=tx.Text;
  finally
    tx.free;
  end;
  //====================================

  aIn := TAsn1StreamParser.Create(buf2bytes(base64tobuf(buf)));
  seq := aIn.ReadObject() as IAsn1SequenceParser;

  count := 0;

  //CheckNotNull(seq, 'null sequence returned');
  //
  TAssert.AssertNotNull('null sequence returned', seq);

  se.Lines.Clear;
  o := seq.ReadObject();
  while (o <> Nil) do begin

    try
      {
      se.Lines.Append(
        //inttostr((o as IAsn1TaggedObjectParser).TagNo)
        //buftohex(bytes2buf(o.ToAsn1Object().GetEncoded()))
        //o.
        //inttostr(o.ToAsn1Object().Asn1GetHashCode() )

        buftohex(bytes2buf(o.ToAsn1Object().GetDerEncoded()))
      );
      }

      //o.ToAsn1Object();
      se.Lines.Append(
        IDerObjectIdentifier(o).ToString()
      );

      se.Lines.Append('ok');
    except
      on e:exception do
        se.Lines.Append(e.message);
    end;
    o := seq.ReadObject();

  end;

  {
  while (o <> Nil) do
  begin
    case count of

      0:
        begin
          if not Supports(o, IDerInteger) then raise exception.Create('IDerInteger is not supported');
          //CheckTrue(Supports(o, IDerInteger));
        end;
      1:
        begin
          //CheckTrue(Supports(o, IDerObjectIdentifier));
          if not Supports(o, IDerObjectIdentifier) then raise exception.Create('IDerObjectIdentifier is not supported');
        end;
      2:
        begin
          //CheckTrue(Supports(o, IAsn1SequenceParser));
          if not Supports(o, IDerObjectIdentifier) then raise exception.Create('IDerObjectIdentifier is not supported');

          s := o as IAsn1SequenceParser;

          // NB: Must exhaust the nested parser
          while (s.ReadObject() <> Nil) do
          begin
            // Ignore
          end;

        end;
    end;

    System.Inc(count);
    o := seq.ReadObject();
  end;

  //CheckEquals(3, count, 'wrong number of objects in sequence');
  if count<>3 then raise exception.Create('wrong number of objects in sequence');
  }

end;

end.

