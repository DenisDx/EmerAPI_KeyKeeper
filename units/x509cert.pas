unit X509cert;

{$mode objfpc}{$H+}
{$modeswitch ADVANCEDRECORDS}

interface

uses
  Classes, SysUtils, fpjson,


  jsonparser;

type



  tASNObject=record
    //private
      //fBinData:ansistring;
      //fTag
    //private
    public
      var
        tag:ansistring;
        data:ansistring;

      //property tag:byte read fTag
      function readFromBuf(const buf:ansistring;var cpos: integer):boolean;
  end;


  tX509certDataFormat=(x509autodetectorunknown,x509cer,x509der,x509pem{,x509p7b},x509p7,x509p12,x509pfx,x509ppk);
  tX509cert=class(tObject)
    private
      fdata:tJsonData;
      fseed:ansistring; //'' if not used
      fseedsalt:ansistring; //'' if not used
      fSourceFormat:tX509certDataFormat;
    public
      property data:tJsonData read fdata write fdata;
      class function detectFormat(const buf:ansistring):tX509certDataFormat;
      function loadFromBuf(adata:ansistring; format:tX509certDataFormat=x509autodetectorunknown):boolean;
      constructor create(adata:ansistring; format:tX509certDataFormat=x509autodetectorunknown); overload;
      constructor create(aSeed:ansistring; aSeedSalt:ansistring); overload;
         //create a new certificate object from the seed
      constructor create(st:tStream; format:tX509certDataFormat=x509autodetectorunknown); overload;
      constructor create; overload;
      destructor destroy;
      procedure init;
  end;

const defaultCertExt:array[0..7] of ansistring=(
  '',//x509autodetectorunknown
  'crt',//x509cer
  'der',//x509der
  'pem',//x509pem //code64 encoded der between "----- BEGIN CERTIFICATE -----" and "----- END CERTIFICATE -----"
  'p7b',//x509p7
  'p12',//x509p12
  'pfx',//x509pfx
  'ppk' //x509ppk  "PuTTY-User-Key-File-2:"
);



implementation

{-----------------tASNObject-----------------------}
function tASNObject.readFromBuf(const buf:ansistring;var cpos: integer):boolean;
var t:byte;
    l:integer;
  function readLength():integer;
  begin
    //If the constructed bit is set in the type then the length includes all the items in the construction (for example, a SEQUENCE). Nominally the Value part of a constructed item is regarded as all the items in the construction.
    //Items whose value part (See note 1 above) is <= 127 (7F hex) can be encoded in a single octet. Length greater than 129 will be two or more octets (all but the last having ITU Bit 8 set) as decribed in X.690 section 8.1.3.5.

    result:=ord(buf[cpos]);
    //if result>

  end;
  function readType():integer;
  begin


  end;

begin
  result:=false;
  //TLV
  if (cpos+1)> length(buf) then exit;

  l:=readLength();
  if l=0 then exit;

  t:=ord(buf[cpos]);

end;

{-----------------tX509cert-----------------------}


procedure tX509cert.init;
begin
  //remove all and empty all
  fseed:='';
  fseedSalt:='';
  fSourceFormat:=x509autodetectorunknown;
end;

class function tX509cert.detectFormat(const buf:ansistring):tX509certDataFormat;
begin
  //  tX509certDataFormat=(x509autodetectorunknown,x509cer,x509der,x509pem{,x509p7b},x509p7,x509p12,x509pfx,x509ppk);
  result:=x509autodetectorunknown;
  if copy(trim(buf),1,12)='Certificate:' then begin
    result:=x509cer;
    exit;
  end;
end;

function tX509cert.loadFromBuf(adata:ansistring; format:tX509certDataFormat=x509autodetectorunknown):boolean;
begin
  result:=false;
  init;

  if format=x509autodetectorunknown then
    format:=detectFormat(adata);
  if format=x509autodetectorunknown then exit;

  //loading. Set result.
  case format of
    x509cer:begin

    end;
    x509der:begin

    end;
    x509pem:begin
      //result:=
    end;
    x509p7:begin

    end;
    x509p12:begin

    end;
    x509pfx:begin

    end;
    x509ppk:begin
      //PuTTY-User-Key-File-2: ssh-rsa
      //Encryption: none
      //Comment: imported-openssh-key
      //Public-Lines: 6
      //AAAAB3....
      //...
      //....
      //....
      //....
      //..........sy9Ecz
      //Private-Lines: 14
      //.....
      //.....
      //.....==
      //Private-MAC: b6b03a3c3ded43e67aff189824e93ecd6c9d49ad
    end;

  else
    exit;
  end;
  if not result then exit;

  fSourceFormat:=format;
end;

constructor tX509cert.create(adata:ansistring; format:tX509certDataFormat=x509autodetectorunknown);
begin
  create;
  if not loadFromBuf(adata,format) then begin
    raise exception.Create('Wrong format');
    destroy;
  end;
end;

constructor tX509cert.create(aSeed:ansistring; aSeedSalt:ansistring);
//create a new certificate object from the seed
begin
  create;
  fSeed:=aSeed;
  fSeedSalt:=aSeedSalt;
end;

constructor tX509cert.create(st:tStream; format:tX509certDataFormat=x509autodetectorunknown);
var buf:ansistring;
begin
  create;
  setLength(buf,st.Size-st.Position);
  st.Read(buf[1],st.Size-st.Position);
  if not loadFromBuf(buf,format) then begin
    raise exception.Create('Wrong format');
    destroy;
  end;
end;

constructor tX509cert.create;
begin
  inherited;
  fdata:=tJsonData.Create;
  init;
end;

destructor tX509cert.destroy;
begin
  if fdata<>nil then fdata.free;
  inherited;
end;

end.

