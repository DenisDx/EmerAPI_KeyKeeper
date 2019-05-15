unit CryptoLib4PascalConnectorUnit;

{ss  $I ..\..\Include\CryptoLib.inc}
{$mode objfpc}{$H+}

interface




//uses
  //ClpDerObjectIdentifier,
  //ClpIDerObjectIdentifier;

//ClpIanaObjectIdentifiers !!!
// property HmacSha1: IDerObjectIdentifier read GetHmacSha1;

uses
  Classes, SysUtils ,

  ClpIDigest,

  ClpIMac,
  ClpDigestUtilities,
  ClpMacUtilities,
  ClpBigInteger,
  ClpSecureRandom,
  ClpISecureRandom,
  ClpIX9ECParameters,
  ClpIECDomainParameters,
  ClpECDomainParameters,
  ClpIECKeyPairGenerator,
  ClpECKeyPairGenerator,
  ClpIECKeyGenerationParameters,
  ClpECKeyGenerationParameters,
  ClpIAsymmetricCipherKeyPair,
  ClpAsymmetricCipherKeyPair,
  ClpIECPrivateKeyParameters,
  ClpIECPublicKeyParameters,
  ClpECPublicKeyParameters,
  ClpECPrivateKeyParameters,
  ClpIAsymmetricKeyParameter,
  ClpIECInterface,
  ClpECPoint,
  ClpISigner,
  ClpSignerUtilities,
  ClpParametersWithIV,
  ClpIParametersWithIV,
  ClpIBufferedCipher,
  ClpIBufferedBlockCipher,
  // ClpIIESEngine,
  // ClpIESEngine,
  ClpPascalCoinIESEngine,
  ClpIPascalCoinIESEngine,
  ClpIIESWithCipherParameters,
  ClpIESWithCipherParameters,
  ClpIAesEngine,
  ClpAesEngine,
  ClpICbcBlockCipher,
  ClpCbcBlockCipher,
  ClpIZeroBytePadding,
  ClpZeroBytePadding,
  ClpIIESCipher,
  ClpIESCipher,
  ClpIECDHBasicAgreement,
  ClpECDHBasicAgreement,
  ClpIPascalCoinECIESKdfBytesGenerator,
  ClpPascalCoinECIESKdfBytesGenerator,
  ClpPaddedBufferedBlockCipher,
  ClpParameterUtilities,
  ClpCipherUtilities,
  ClpGeneratorUtilities,
  ClpIAsymmetricCipherKeyPairGenerator,
  ClpArrayUtils,
  ClpHex,
  // ClpSecNamedCurves,
  ClpCustomNamedCurves,

  ClpConverters
  ;

type
TECDSA_Public = record
   EC_OpenSSL_NID : Word;
   x: ansistring;
   y: ansistring;
end;

PECDSA_Public = ^TECDSA_Public;

TECDSA_SIG = record
 r: ansistring;
 s: ansistring;
end; { record }


function dosha256(buf:ansistring):ansistring;
function DoRipeMD160(buf:ansistring): ansistring;

function BigNum_2_IECPrivateKeyParameters(bignum: ansistring):IECPrivateKeyParameters;
function tmpTECDSA_SIG_2_Signature(psignature:pointer):ansistring;
function tmpTECDSA_Public_2_IECPublicKeyParameters(ppubKey:pointer):IECPublicKeyParameters; overload;
function tmpTECDSA_Public_2_IECPublicKeyParameters(pubKey:ansistring):IECPublicKeyParameters; overload;

function ECDSAVerify(PubKey : IECPublicKeyParameters; const digest : AnsiString; Signature : AnsiString) : Boolean; overload;
function ECDSAVerify(PubKey : ansistring; const digest : AnsiString; Signature : AnsiString) : Boolean; overload;
function ECDSASign(PrivateKey: IECPrivateKeyParameters; const digest: AnsiString; less0x80:boolean=true; only32:boolean=true): AnsiString; overload;
function ECDSASign(PrivateKey: ansistring; const digest: AnsiString; less0x80:boolean=true; only32:boolean=true): AnsiString; overload;

function Encrypt_AES256(Const data, password : AnsiString): AnsiString;
function Encrypt_AES256_CBC(Const data, password : AnsiString): AnsiString;
function Decrypt_AES256(const encryptedData,password: AnsiString) : AnsiString;
function Decrypt_AES256_CBC(const encryptedData,password: AnsiString) : AnsiString;

function Encrypt_AES256_CTR(Const data, password : AnsiString): AnsiString;

function encrypt_EC(const data,pubkey:ansistring):ansistring;
function decrypt_EC(const data,privkey:ansistring):ansistring;

function buf2TBigInteger(buf:ansistring):TBigInteger;
function TBigInteger2buf(d:TBigInteger):ansistring;

function iecPointToBuf(p:IECPoint;compress:boolean=false):ansistring;
function bufToiecPoint(buf:ansistring):IECPoint;

function buf2bytes(buf:ansistring):tBytes;
function bytes2Buf(ar:tBytes):ansistring;

function EVP_GetSalt(saltlen:integer=0): TBytes;
function GetRandomChars(saltlen:integer=0): ansistring;

var
  cl4pRandom: ISecureRandom;

implementation

uses HlpHashFactory, ClpIIESEngine;

function buf2bytes(buf:ansistring):tBytes;
begin
  setLength(result,length(buf));
  move(buf[1],result[0],length(buf));
end;

function bytes2Buf(ar:tBytes):ansistring;
begin
  setLength(result,length(ar));
  move(ar[0],result[1],length(ar));
end;


function iecPointToBuf(p:IECPoint;compress:boolean=false):ansistring;
begin
  result:=bytes2Buf(p.GetEncoded(compress));
end;

function bufToiecPoint(buf:ansistring):IECPoint;
var
  Lcurve:IX9ECParameters;
begin
  Lcurve := TCustomNamedCurves.GetByName('secp256k1'{ACurveName});
  System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');
  result:=Lcurve.Curve.DecodePoint(buf2bytes(buf));
end;


function TBigInteger2buf(d:TBigInteger):ansistring;
var ar:array of byte;
begin
  ar:=d.ToByteArray();
  //setLength(result,length(ar));
  //move(ar[0],result[1],length(ar));
  result:=bytes2Buf(ar);
  while (length(result)>1) and (result[1]=#0) do delete(result,1,1);
end;

function buf2TBigInteger(buf:ansistring):TBigInteger;
var ar:array of byte;
begin
  //setLength(ar,length(buf));
  //move(buf[1],ar[0],length(buf));
  ar:=buf2bytes(buf);
  result:=TBigInteger.Create(1,ar);
end;


function tmpTECDSA_SIG_2_Signature(psignature:pointer):ansistring;
var ps:^TECDSA_SIG;
begin
  ps:=psignature;

  result:=#30+ps^.r+ps^.s;

//  result:=
end;



function tmpTECDSA_Public_2_IECPublicKeyParameters(pubKey:ansistring):IECPublicKeyParameters;
var pk:^TECDSA_Public;
    Lcurve: IX9ECParameters;
    domain: IECDomainParameters;
    PublicKeyBytes: TBytes;
    t:ansistring;
begin

  t:=pubKey;
  setLength(PublicKeyBytes, length(t));
  move(t[1],PublicKeyBytes[0],length(t));

  Lcurve := TCustomNamedCurves.GetByName('secp256k1'{ACurveName});
  System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');

  // Set Up Asymmetric Key Pair from known public key ByteArray

  domain := TECDomainParameters.Create(Lcurve.Curve, Lcurve.G, Lcurve.N, Lcurve.H, Lcurve.GetSeed);

  result := TECPublicKeyParameters.Create('ECDSA', Lcurve.Curve.DecodePoint(PublicKeyBytes), domain);

end;


function BigNum_2_IECPrivateKeyParameters(bignum: ansistring):IECPrivateKeyParameters;
var PrivD: TBigInteger;
    PrivateKeyBytes:TBytes;
    Lcurve: IX9ECParameters;
    domain: IECDomainParameters;
begin

  setLength(PrivateKeyBytes, length(bignum));
  move(bignum[1],PrivateKeyBytes[0],length(bignum));

  Lcurve := TCustomNamedCurves.GetByName('secp256k1'{ACurveName});
  System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');

  // Set Up Asymmetric Key Pair from known private key ByteArray

  domain := TECDomainParameters.Create(Lcurve.Curve, Lcurve.G, Lcurve.N, Lcurve.H, Lcurve.GetSeed);

  PrivD := TBigInteger.Create(1, PrivateKeyBytes);
  result := TECPrivateKeyParameters.Create('ECDSA', PrivD, domain);
end;


function tmpTECDSA_Public_2_IECPublicKeyParameters(ppubKey:pointer):IECPublicKeyParameters;
var pk:^TECDSA_Public;
    Lcurve: IX9ECParameters;
    domain: IECDomainParameters;
    PublicKeyBytes: TBytes;
    t:ansistring;
begin

  pk:=ppubKey;

  t:=pk^.x+pk^.y;
  setLength(PublicKeyBytes, length(t));
  move(t[1],PublicKeyBytes[0],length(t));

  Lcurve := TCustomNamedCurves.GetByName('secp256k1'{ACurveName});
  System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');

  // Set Up Asymmetric Key Pair from known public key ByteArray

  domain := TECDomainParameters.Create(Lcurve.Curve, Lcurve.G, Lcurve.N, Lcurve.H, Lcurve.GetSeed);

  result := TECPublicKeyParameters.Create('ECDSA', Lcurve.Curve.DecodePoint(PublicKeyBytes), domain);


end;

{!!!!!!!!!!!!!!REMOVE IT!!!!!!!!!!!!!!!!!!}
function readSerializedAnsiString(const s:ansistring; var pos:integer):ansistring;
var l:word;
begin
  if length(s)<(pos+1) then raise exception.Create('readSerializedAnsiString: string too short');
  l:=ord(s[pos]); inc(pos);
  if length(s)<(pos+l-1) then raise exception.Create('popSerializedAnsiString: can''t read string');
  result:=copy(s,pos,l);
  pos:=pos+l;
end;

function DecodeSignature(const rawSignature : AnsiString) : TECDSA_SIG;
var s : ansistring;
  CT_TECDSA_SIG_Nul: TECDSA_SIG = (r:'';s:'');
  pos:integer;
begin
  //setLength(result,6+length(r)+length(s));
  // 0x30 [total-length] 0x02 [R-length] [R] 0x02 [S-length] [S]
  {
  result:=
     chr($30)                     //signature[0] = 0x30
    +chr(6+length(r)+length(s)-2) //signature[1] = signature.length - 2
    +#2                           //signature[2] = 0x02
    +chr(length(r))               //signature[3] = r.length
    +r                            //r.copy(signature, 4)
    +#2                           //signature[4 + lenR] = 0x02
    +chr(length(r))               //signature[5 + lenR] = s.length
    +s;
  }
  pos:=1;
  if rawSignature[pos]<>chr($30) then raise exception.Create('DecodeSignature: wrong signature');
  inc(pos);


  result := CT_TECDSA_SIG_Nul;

  s:=readSerializedAnsiString(rawSignature,pos);
  if pos<>(length(rawSignature)+1) then result := CT_TECDSA_SIG_Nul;

  pos:=1;

  if s[pos]<>#2 then begin result := CT_TECDSA_SIG_Nul; exit; end else inc(pos);
  result.r:=readSerializedAnsiString(s,pos);
  if s[pos]<>#2 then begin result := CT_TECDSA_SIG_Nul; exit; end else inc(pos);
  result.s:=readSerializedAnsiString(s,pos);

  if pos<>(length(s)+1) then result := CT_TECDSA_SIG_Nul;

end;

{/!!!!!!!!!!!!!!REMOVE IT!!!!!!!!!!!!!!!!!!}



function ECDSASign(PrivateKey: ansistring; const digest: AnsiString; less0x80:boolean=true; only32:boolean=true): AnsiString;
var
    Lcurve: IX9ECParameters;
    domain: IECDomainParameters;
begin
  Lcurve := TCustomNamedCurves.GetByName('secp256k1'{ACurveName});
  System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');

  // Set Up Asymmetric Key Pair from known private key ByteArray

  domain := TECDomainParameters.Create(Lcurve.Curve, Lcurve.G, Lcurve.N, Lcurve.H, Lcurve.GetSeed);

  result:=ECDSASign(TECPrivateKeyParameters.Create('ECDSA', buf2TBigInteger(PrivateKey), domain),digest,less0x80,only32);
end;

function ECDSASign(PrivateKey: IECPrivateKeyParameters; const digest: AnsiString; less0x80:boolean=true; only32:boolean=true): AnsiString;
var
  Signer: ISigner;
  {&message,} sigBytes: TBytes;
  i:integer;
  sig:TECDSA_SIG;
  D,Dmax: TBigInteger;
  ti:integer;
  myBytes:TBytes;
begin
  //Writeln('Caller Method Is ' + CallerMethod + sLineBreak);
                                      //'SHA-1withECDSA' 'NONEwithECDSA'
  Signer := TSignerUtilities.GetSigner('NONEwithECDSA'{SigningAlgo});
  ///Writeln('Signer Name is: ' + Signer.AlgorithmName + sLineBreak);

  ///&message := TConverters.ConvertStringToBytes(TextToSign, TEncoding.UTF8);
  //setLength(message,length(digest));
  //Move(digest[1],message[0],length(digest));

  //i:=0;
  repeat
    // Sign
    Signer.Init(True, PrivateKey);

    Signer.BlockUpdate({&message}@digest[1], 0, System.Length(digest{&message}));

    sigBytes := Signer.GenerateSignature();

    setLength(result,length(sigBytes));
    Move(sigBytes[0],result[1],length(sigBytes));

    sig:=DecodeSignature(result);
    inc(i);
  {
    //n = int("FFFFFFFF FFFFFFFF FFFFFFFF FFFFFFFE BAAEDCE6 AF48A03B BFD25E8C D0364141".replace
    Dmax:=TBigInteger.Create('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',16);
    setLength(myBytes, length(sig.s));
    move(sig.s[1],myBytes[0],length(sig.s));
    D := TBigInteger.Create(1, myBytes);

    ti:=length(sig.s);
    if D.CompareTo(Dmax)>0 then
      Dmax.Subtract(D);
   }
    ti:=length(sig.s);
  until (i>1000)  or (
          ((not only32) or (ti=32))
            and
          ((not less0x80) or ((ord(sig.r[1])<128 )  and  (ord(sig.s[1]) <128)) )
        );


   //or (((ord(sig.r[1])<128 )) and ((ord(sig.s[1]) <128)) and (ti<$80));






end;



function ECDSAVerify(PubKey : ansistring; const digest : AnsiString; Signature : AnsiString) : Boolean;
var myPubKey:IECPublicKeyParameters;
begin
  myPubKey:=tmpTECDSA_Public_2_IECPublicKeyParameters(PubKey);
  result:=ECDSAVerify(myPubKey,digest,Signature);
end;

function ECDSAVerify(PubKey : IECPublicKeyParameters; const digest : AnsiString; Signature : AnsiString) : Boolean;
var
  Signer: ISigner;
 sigBytes: TBytes;
begin
 {
  setLength(message,length(digest));
  Move(digest[1],message[0],length(digest));

  setLength(message,length(digest));
  Move(digest[1],message[0],length(digest));
  }
    // Verify
  Signer := TSignerUtilities.GetSigner( 'NONEwithECDSA'{'NONEwithECDSA' 'SHA-1withECDSA'{SigningAlgo}});

  Signer.Init(False, PubKey);

  Signer.BlockUpdate({&message} @digest[1], 0, System.Length({&message}digest));

  setLength(sigBytes,length(Signature));
  Move(Signature[1],sigBytes[0],length(Signature));

  result:= Signer.VerifySignature(sigBytes);

end;


function DoRipeMD160(buf:ansistring): ansistring;
var a:array of byte;
begin
  setLength(a,length(buf));
  move(buf[1],a[0],length(buf));
  a:=THashFactory.TCrypto.CreateRIPEMD160().ComputeBytes(a).GetBytes();
  setLength(result,length(a));
  move(a[0],result[1],length(a));
end;

function dosha256(buf:ansistring):ansistring;
var a:array of byte;
begin
  setLength(a,length(buf));
  move(buf[1],a[0],length(buf));

  //a:=THashFactory.TCrypto.CreateSHA2_256().ComputeString(buf, TEncoding.ASCII).GetBytes();
  a:=THashFactory.TCrypto.CreateSHA2_256().ComputeBytes(a).GetBytes();
  setLength(result,length(a));
  move(a[0],result[1],length(a));
  {
  result:=
    TConverters.ConvertBytesToString(  //CreateSHA2_256
     THashFactory.TCrypto.CreateSHA2_256().ComputeString(buf, TEncoding.ASCII).GetBytes();
    ,
      TEncoding.ASCII
    );
}


  {

  for i := 0 to System.Pred(System.Length(Fmessages)) do
  begin
    m := TConverters.ConvertStringToBytes(Fmessages[i], TEncoding.ASCII);
    if (TStringUtils.BeginsWith(Fmessages[i], '0x', True)) then
    begin
      m := THex.Decode(System.Copy(Fmessages[i], 3,
        System.Length(Fmessages[i]) - 2));
    end;
    hmac.Init(TKeyParameter.Create(THex.Decode(Fkeys[i])));
    hmac.BlockUpdate(m, 0, System.Length(m));
    hmac.DoFinal(resBuf, 0);

    if (not TArrayUtils.AreEqual(resBuf, THex.Decode(Fdigests[i]))) then
    begin
      Fail('Vector ' + IntToStr(i) + ' failed');
    end;
  end;

  // test reset
  vector := 0; // vector used for test
  m2 := TConverters.ConvertStringToBytes(Fmessages[vector], TEncoding.ASCII);

  if (TStringUtils.BeginsWith(Fmessages[vector], '0x', True)) then
  begin
    m2 := THex.Decode(System.Copy(Fmessages[vector], 3,
      System.Length(Fmessages[vector]) - 2));
  end;

  hmac.Init(TKeyParameter.Create(THex.Decode(Fkeys[vector])));
  hmac.BlockUpdate(m2, 0, System.Length(m2));
  hmac.DoFinal(resBuf, 0);
  hmac.Reset();
  hmac.BlockUpdate(m2, 0, System.Length(m2));
  hmac.DoFinal(resBuf, 0);

  if (not TArrayUtils.AreEqual(resBuf, THex.Decode(Fdigests[vector]))) then
  begin
    Fail('Reset with vector ' + IntToStr(vector) + ' failed');
  end;
  }
end;

var
  saltSizeDefault:integer=8; //SALT_MAGIC_LEN
  defaultSignature:ansistring='EmerAPI:';  //SALT_MAGIC
  PKCS5_SALT_LEN:integer=8;



function EVP_GetKeyIV(PasswordBytes, SaltBytes: TBytes;
  out KeyBytes, IVBytes: TBytes): Boolean;
var
  LKey, LIV: integer;
  LDigest: IDigest;
begin
  LKey := 32; // AES256 CBC Key Length
  LIV := 16; // AES256 CBC IV Length
  System.SetLength(KeyBytes, LKey);
  System.SetLength(IVBytes, LKey);
  // Max size to start then reduce it at the end
  LDigest := TDigestUtilities.GetDigest('SHA-256'); // SHA2_256
  System.Assert(LDigest.GetDigestSize >= LKey);
  System.Assert(LDigest.GetDigestSize >= LIV);
  // Derive Key First
  LDigest.BlockUpdate(PasswordBytes, 0, System.Length(PasswordBytes));
  if SaltBytes <> Nil then
  begin
    LDigest.BlockUpdate(SaltBytes, 0, System.Length(SaltBytes));
  end;
  LDigest.DoFinal(KeyBytes, 0);
  // Derive IV Next
  LDigest.Reset();
  LDigest.BlockUpdate(KeyBytes, 0, System.Length(KeyBytes));
  LDigest.BlockUpdate(PasswordBytes, 0, System.Length(PasswordBytes));
  if SaltBytes <> Nil then
  begin
    LDigest.BlockUpdate(SaltBytes, 0, System.Length(SaltBytes));
  end;
  LDigest.DoFinal(IVBytes, 0);

  System.SetLength(IVBytes, LIV);
  Result := True;
end;

function EVP_GetSalt(saltlen:integer=0): TBytes;
begin
  if saltlen=0 then saltlen:=PKCS5_SALT_LEN;
  System.SetLength(Result, saltlen);
  cl4pRandom.NextBytes(Result);
end;

function GetRandomChars(saltlen:integer=0): ansistring;
begin
  result:=bytes2Buf(EVP_GetSalt(saltlen));
end;



{
Okay, so after investigating the provided restore tool (thanks Lohoris for pointing it out!), I arrived at the following answers to my questions:

The input key for the AES decryption is 32 bytes (256 bits)
The block size used is 16 bytes (MCRYPT_RIJNDAEL_128 for PHP mcrypt functions)
The initialization vector (IV) for the AES decryption is the first 16 bytes (one block size) of the encrypted string. The remaining encrypted string is the encrypted message.
The user's password is expanded by using 10 rounds of PBKDF2 hashing, using SHA1 hashing, and the IV as salt (the "No salt is used for single pass encryption" note seems to just mean no salt for the AES encryption. For the PBKDF2 hashing, there is a salt).
Note, if using PHP mcrypt extension functions (like I was trying to), you need to use the mdecrypt_generic() method rather than mcrypt_decrypt(), since Blockchain using ISO10126 padding, and the mcrypt extension will only use "zero padding". You then have to un-pad the result separately.
}
function Encrypt_AES256_CTR(Const data, password : AnsiString): AnsiString;
var
  PlainText, PasswordBytes: TBytes;

  SaltBytes, KeyBytes, IVBytes, Buf: TBytes;
  KeyParametersWithIV: IParametersWithIV;
  cipher: IBufferedCipher;
  LBlockSize, LBufStart, Count: Int32;
begin
  //nonce 8 байт

  //  PlainText, PasswordBytes
  PlainText:=buf2Bytes(data);
  PasswordBytes:=buf2Bytes(password);

  SaltBytes := EVP_GetSalt; //8 bytes
  //solt : 87ca5c20a5b749ad -> iv:

  //1.Делаем Initial Vector IVBytes и KeyBytes
  //EVP_GetKeyIV(PasswordBytes, SaltBytes, KeyBytes, IVBytes);
//  IVBytes:=buf2Bytes(hexToBuf('0000000000000000'));
  KeyBytes:=PasswordBytes;
  IVBytes:=SaltBytes;

  //2. Инициализируем объект для шифрования
  cipher := TCipherUtilities.GetCipher('AES/CTR');
  KeyParametersWithIV := TParametersWithIV.Create(TParameterUtilities.CreateKeyParameter('AES', KeyBytes), IVBytes);
  cipher.Init(True, KeyParametersWithIV); // init encryption cipher
  LBlockSize := cipher.GetBlockSize;

  //записываем буфер
  System.SetLength(Buf, System.Length(PlainText) + LBlockSize + saltSizeDefault {SALT_MAGIC_LEN} + PKCS5_SALT_LEN);

  LBufStart := 0;

  System.Move(TConverters.ConvertStringToBytes(defaultSignature {SALT_MAGIC}, TEncoding.UTF8)[0],
    Buf[LBufStart], saltSizeDefault {SALT_MAGIC_LEN} * System.SizeOf(Byte));
  System.Inc(LBufStart, saltSizeDefault {SALT_MAGIC_LEN});
  System.Move(SaltBytes[0], Buf[LBufStart],
    PKCS5_SALT_LEN * System.SizeOf(Byte));
  System.Inc(LBufStart, PKCS5_SALT_LEN);

  //засоввывваем байты в шифровальщик
  Count := cipher.ProcessBytes(PlainText, 0, System.Length(PlainText), Buf,  LBufStart);
  System.Inc(LBufStart, Count);
  Count := cipher.DoFinal(Buf, LBufStart);
  System.Inc(LBufStart, Count);

  System.SetLength(Buf, LBufStart);

  //Result := Buf;
  Result:=Bytes2Buf(Buf);
end;

function Encrypt_AES256_CBC(Const data, password : AnsiString): AnsiString;
var
  PlainText, PasswordBytes: TBytes;

  SaltBytes, KeyBytes, IVBytes, Buf: TBytes;
  KeyParametersWithIV: IParametersWithIV;
  cipher: IBufferedCipher;
  LBlockSize, LBufStart, Count: Int32;
begin
  //  PlainText, PasswordBytes

  PlainText:=buf2Bytes(data);
  PasswordBytes:=buf2Bytes(password);

  SaltBytes := EVP_GetSalt(16);
  //setLength(SaltBytes, length(defaultSignature));
  //move(defaultSignature[1],SaltBytes[0],length(defaultSignature));


  //EVP_GetKeyIV(PasswordBytes, SaltBytes, KeyBytes, IVBytes);
  IVBytes:=SaltBytes;
  KeyBytes:=PasswordBytes;

  cipher := TCipherUtilities.GetCipher('AES/CBC/PKCS7PADDING');
  KeyParametersWithIV := TParametersWithIV.Create
    (TParameterUtilities.CreateKeyParameter('AES', KeyBytes), IVBytes);

  cipher.Init(True, KeyParametersWithIV); // init encryption cipher
  LBlockSize := cipher.GetBlockSize;

  System.SetLength(Buf, System.Length(PlainText) + LBlockSize + 16 {saltSizeDefault {SALT_MAGIC_LEN} + PKCS5_SALT_LEN});

  LBufStart := 0;

  //System.Move(TConverters.ConvertStringToBytes(defaultSignature {SALT_MAGIC}, TEncoding.UTF8)[0],
  //  Buf[LBufStart], saltSizeDefault {SALT_MAGIC_LEN} * System.SizeOf(Byte));
  //System.Inc(LBufStart, saltSizeDefault {SALT_MAGIC_LEN});

  System.Move(SaltBytes[0], Buf[LBufStart],
    {PKCS5_SALT_LEN} 16 * System.SizeOf(Byte));
  System.Inc(LBufStart, 16 {PKCS5_SALT_LEN});

  Count := cipher.ProcessBytes(PlainText, 0, System.Length(PlainText), Buf,
    LBufStart);
  System.Inc(LBufStart, Count);
  Count := cipher.DoFinal(Buf, LBufStart);
  System.Inc(LBufStart, Count);

  System.SetLength(Buf, LBufStart);

  Result:=Bytes2Buf(Buf);
end;

function Encrypt_AES256(Const data, password : AnsiString): AnsiString;
var
  PlainText, PasswordBytes: TBytes;

  SaltBytes, KeyBytes, IVBytes, Buf: TBytes;
  KeyParametersWithIV: IParametersWithIV;
  cipher: IBufferedCipher;
  LBlockSize, LBufStart, Count: Int32;
begin
  //  PlainText, PasswordBytes
  setLength(PlainText, length(data));
  move(data[1],PlainText[0],length(data));

  setLength(PasswordBytes, length(password));
  move(password[1],PasswordBytes[0],length(password));

  SaltBytes := EVP_GetSalt;
  //setLength(SaltBytes, length(defaultSignature));
  //move(defaultSignature[1],SaltBytes[0],length(defaultSignature));


  EVP_GetKeyIV(PasswordBytes, SaltBytes, KeyBytes, IVBytes);
  cipher := TCipherUtilities.GetCipher('AES/CBC/PKCS7PADDING');
  KeyParametersWithIV := TParametersWithIV.Create
    (TParameterUtilities.CreateKeyParameter('AES', KeyBytes), IVBytes);

  cipher.Init(True, KeyParametersWithIV); // init encryption cipher
  LBlockSize := cipher.GetBlockSize;

  System.SetLength(Buf, System.Length(PlainText) + LBlockSize + saltSizeDefault {SALT_MAGIC_LEN} +
    PKCS5_SALT_LEN);

  LBufStart := 0;

  System.Move(TConverters.ConvertStringToBytes(defaultSignature {SALT_MAGIC}, TEncoding.UTF8)[0],
    Buf[LBufStart], saltSizeDefault {SALT_MAGIC_LEN} * System.SizeOf(Byte));
  System.Inc(LBufStart, saltSizeDefault {SALT_MAGIC_LEN});
  System.Move(SaltBytes[0], Buf[LBufStart],
    PKCS5_SALT_LEN * System.SizeOf(Byte));
  System.Inc(LBufStart, PKCS5_SALT_LEN);

  Count := cipher.ProcessBytes(PlainText, 0, System.Length(PlainText), Buf,
    LBufStart);
  System.Inc(LBufStart, Count);
  Count := cipher.DoFinal(Buf, LBufStart);
  System.Inc(LBufStart, Count);

  System.SetLength(Buf, LBufStart);

  //Result := Buf;
  setLength(Result, length(Buf));
  move(Buf[0],Result[1],length(Buf));

end;

function Decrypt_AES256_CBC(const encryptedData,password: AnsiString) : AnsiString;

var
  CipherText,
  PasswordBytes: TBytes;
var
  SaltBytes, KeyBytes, IVBytes, Buf, Chopped: TBytes;
  KeyParametersWithIV: IParametersWithIV;
  cipher: IBufferedCipher;
  LBufStart, LSrcStart, Count: Int32;
begin
  result:='';

  //setLength(CipherText, length(encryptedData));
  //move(encryptedData[1],CipherText[0],length(encryptedData));
  CipherText := buf2Bytes(encryptedData);

  //setLength(PasswordBytes, length(password));
  //move(password[1],PasswordBytes[0],length(password));
  PasswordBytes := buf2Bytes(password);

  {
  System.SetLength(SaltBytes, 16{PKCS5_SALT_LEN {SALT_SIZE}});
  // First read the magic text and the salt - if any
  Chopped := System.Copy(CipherText, 0, 16 {saltSizeDefault} {SALT_MAGIC_LEN});
  if (System.Length(CipherText) >= 16{saltSizeDefault} {SALT_MAGIC_LEN}) and
    (TArrayUtils.AreEqual(Chopped, TConverters.ConvertStringToBytes(defaultSignature {SALT_MAGIC},
    TEncoding.UTF8))) then
  begin
    System.Move(CipherText[saltSizeDefault {SALT_MAGIC_LEN}], SaltBytes[0], PKCS5_SALT_LEN {SALT_SIZE});
    If not EVP_GetKeyIV(PasswordBytes, SaltBytes, KeyBytes, IVBytes) then
    begin
      Exit;
    end;
    LSrcStart := saltSizeDefault {SALT_MAGIC_LEN} + PKCS5_SALT_LEN {SALT_SIZE};
  end
  else
  begin
    If Not EVP_GetKeyIV(PasswordBytes, Nil, KeyBytes, IVBytes) then
    begin
      Exit;
    end;
    LSrcStart := 0;
  end;
  }
  KeyBytes:=PasswordBytes;

  System.SetLength(IVBytes, 16);
  IVBytes := System.Copy(CipherText, 0, 16 );

//?  LSrcStart := 16;
  LSrcStart:=16;
                                                //NOPADDING  //PKCS7PADDING
  cipher := TCipherUtilities.GetCipher('AES/CBC/PKCS7PADDING');
  KeyParametersWithIV := TParametersWithIV.Create
    (TParameterUtilities.CreateKeyParameter('AES', KeyBytes), IVBytes);

  cipher.Init(False, KeyParametersWithIV); // init decryption cipher

  System.SetLength(Buf, System.Length(CipherText));

  LBufStart := 0;

  Count := cipher.ProcessBytes(CipherText, LSrcStart, System.Length(CipherText)
    - LSrcStart, Buf, LBufStart);
  System.Inc(LBufStart, Count);
  Count := cipher.DoFinal(Buf, LBufStart);
  System.Inc(LBufStart, Count);

  System.SetLength(Buf, LBufStart);

  //PlainText := System.Copy(Buf);
  //Result := True;
  //setLength(Result, length(Buf));
  //move(Buf[0],Result[1],length(Buf));
  result:=bytes2Buf(Buf);

end;

function Decrypt_AES256(const encryptedData,password: AnsiString) : AnsiString;

var
  CipherText,
  PasswordBytes: TBytes;
var
  SaltBytes, KeyBytes, IVBytes, Buf, Chopped: TBytes;
  KeyParametersWithIV: IParametersWithIV;
  cipher: IBufferedCipher;
  LBufStart, LSrcStart, Count: Int32;
begin
  result:='';

  setLength(CipherText, length(encryptedData));
  move(encryptedData[1],CipherText[0],length(encryptedData));

  setLength(PasswordBytes, length(password));
  move(password[1],PasswordBytes[0],length(password));

  System.SetLength(SaltBytes, PKCS5_SALT_LEN {SALT_SIZE});
  // First read the magic text and the salt - if any
  Chopped := System.Copy(CipherText, 0, saltSizeDefault {SALT_MAGIC_LEN});
  if (System.Length(CipherText) >= saltSizeDefault {SALT_MAGIC_LEN}) and
    (TArrayUtils.AreEqual(Chopped, TConverters.ConvertStringToBytes(defaultSignature {SALT_MAGIC},
    TEncoding.UTF8))) then
  begin
    System.Move(CipherText[saltSizeDefault {SALT_MAGIC_LEN}], SaltBytes[0], PKCS5_SALT_LEN {SALT_SIZE});
    If not EVP_GetKeyIV(PasswordBytes, SaltBytes, KeyBytes, IVBytes) then
    begin
      Exit;
    end;
    LSrcStart := saltSizeDefault {SALT_MAGIC_LEN} + PKCS5_SALT_LEN {SALT_SIZE};
  end
  else
  begin
    If Not EVP_GetKeyIV(PasswordBytes, Nil, KeyBytes, IVBytes) then
    begin
      Exit;
    end;
    LSrcStart := 0;
  end;

  cipher := TCipherUtilities.GetCipher('AES/CBC/PKCS7PADDING');
  KeyParametersWithIV := TParametersWithIV.Create
    (TParameterUtilities.CreateKeyParameter('AES', KeyBytes), IVBytes);

  cipher.Init(False, KeyParametersWithIV); // init decryption cipher

  System.SetLength(Buf, System.Length(CipherText));

  LBufStart := 0;

  Count := cipher.ProcessBytes(CipherText, LSrcStart, System.Length(CipherText)
    - LSrcStart, Buf, LBufStart);
  System.Inc(LBufStart, Count);
  Count := cipher.DoFinal(Buf, LBufStart);
  System.Inc(LBufStart, Count);

  System.SetLength(Buf, LBufStart);

  //PlainText := System.Copy(Buf);
  //Result := True;
  setLength(Result, length(Buf));
  move(Buf[0],Result[1],length(Buf));


end;

//****************************EC crypt/decrypr
function GetIESCipherParameters: IIESWithCipherParameters;
var
  Derivation, Encoding, IVBytes: TBytes;
  MacKeySizeInBits, CipherKeySizeInBits: Int32;
  UsePointCompression: Boolean;
begin
  // Set up  IES Cipher Parameters For Compatibility With PascalCoin Current Implementation

  // The derivation and encoding vectors are used when initialising the KDF and MAC.
  // They're optional but if used then they need to be known by the other user so that
  // they can decrypt the ciphertext and verify the MAC correctly. The security is based
  // on the shared secret coming from the (static-ephemeral) ECDH key agreement.
  Derivation := Nil;

  Encoding := Nil;

  System.SetLength(IVBytes, 16); // using Zero Initialized IV for compatibility

  MacKeySizeInBits := 32 * 8;

  // Since we are using AES256_CBC for compatibility
  CipherKeySizeInBits := 32 * 8;

  // whether to use point compression when deriving the octets string
  // from a point or not in the EphemeralKeyPairGenerator
  UsePointCompression := True; // for compatibility

  Result := TIESWithCipherParameters.Create(Derivation, Encoding,
    MacKeySizeInBits, CipherKeySizeInBits, IVBytes, UsePointCompression);
end;

function GetECIESEngine: IIESEngine;
var
  cipher: IBufferedBlockCipher;
  AesEngine: IAesEngine;
  blockCipher: ICbcBlockCipher;
  ECDHBasicAgreementInstance: IECDHBasicAgreement;
  KDFInstance: IPascalCoinECIESKdfBytesGenerator;
  DigestMACInstance: IMac;

begin
  // Set up IES Cipher Engine For Compatibility With PascalCoin

  ECDHBasicAgreementInstance := TECDHBasicAgreement.Create();

  KDFInstance := TPascalCoinECIESKdfBytesGenerator.Create
    (TDigestUtilities.GetDigest('SHA-512'));

  DigestMACInstance := TMacUtilities.GetMac('HMAC-MD5');

  // Set Up Block Cipher
  AesEngine := TAesEngine.Create(); // AES Engine

  blockCipher := TCbcBlockCipher.Create(AesEngine); // CBC

  cipher := TPaddedBufferedBlockCipher.Create(blockCipher,
    TZeroBytePadding.Create() as IZeroBytePadding); // ZeroBytePadding

  Result := TPascalCoinIESEngine.Create(ECDHBasicAgreementInstance, KDFInstance,
    DigestMACInstance, cipher);
end;

function encrypt_EC(const data,pubkey:ansistring):ansistring;
var
  thePublicKey: IAsymmetricKeyParameter;
  CipherEncrypt: IIESCipher;
  Lcurve: IX9ECParameters;
  domain: IECDomainParameters;

begin
  Lcurve := TCustomNamedCurves.GetByName('secp256k1'{ACurveName});
  System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');

  // Set Up Asymmetric Key Pair from known public key ByteArray
  domain := TECDomainParameters.Create(Lcurve.Curve, Lcurve.G, Lcurve.N, Lcurve.H, Lcurve.GetSeed);
  thePublicKey:=TECPublicKeyParameters.Create('ECDSA', Lcurve.Curve.DecodePoint(buf2bytes(pubkey)), domain);
  // Encryption
  CipherEncrypt := TIESCipher.Create(GetECIESEngine);
  CipherEncrypt.Init(True, thePublicKey, GetIESCipherParameters, cl4pRandom);
  Result := bytes2Buf( CipherEncrypt.DoFinal(buf2Bytes(data)) );
end;

function decrypt_EC(const data,privkey:ansistring):ansistring;
var
  CipherDecrypt: IIESCipher;
  thePrivateKey : IAsymmetricKeyParameter;
  {
 class function TUsageExamples.ECIESPascalCoinDecrypt(const PrivateKey
  : IAsymmetricKeyParameter; CipherText: TBytes; out PlainText: TBytes)
  : Boolean;
  }
var
    Lcurve: IX9ECParameters;
    domain: IECDomainParameters;
begin
  Lcurve := TCustomNamedCurves.GetByName('secp256k1'{ACurveName});
  System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');
  domain := TECDomainParameters.Create(Lcurve.Curve, Lcurve.G, Lcurve.N, Lcurve.H, Lcurve.GetSeed);

  thePrivateKey:=TECPrivateKeyParameters.Create('ECDSA', buf2TBigInteger(privkey), domain);

  // Decryption
  CipherDecrypt := TIESCipher.Create(GetECIESEngine);
  CipherDecrypt.Init(False, thePrivateKey, GetIESCipherParameters, cl4pRandom);
  Result := bytes2buf(CipherDecrypt.DoFinal(buf2bytes(data)));

end;

//  /****************************EC crypt/decrypr

function CreateKeyPairFromStrBuf(buf : AnsiString; ACurveName : ansistring ='secp256k1') : IAsymmetricCipherKeyPair;
var
  Lcurve: IX9ECParameters;
  domain: IECDomainParameters;
  generator: IECKeyPairGenerator;
  keygenParams: IECKeyGenerationParameters;
  //KeyPair: IAsymmetricCipherKeyPair;
  //privParams, RegeneratedPrivateKey: IECPrivateKeyParameters;
  //pubParams, RegeneratedPublicKey: IECPublicKeyParameters;
  //PublicKeyByteArray, PrivateKeyByteArray: TBytes;
  //PrivD: TBigInteger;


begin

  Lcurve := TCustomNamedCurves.GetByName(ACurveName);
  System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');
  domain := TECDomainParameters.Create(Lcurve.Curve, Lcurve.G, Lcurve.N, Lcurve.H, Lcurve.GetSeed);

  generator := TECKeyPairGenerator.Create('ECDSA');
  keygenParams := TECKeyGenerationParameters.Create(domain, cl4pRandom);
  generator.Init(keygenParams);

  result := generator.GenerateKeyPair();
  (*
  privParams := KeyPair.Private as IECPrivateKeyParameters; // for signing
  pubParams := KeyPair.Public as IECPublicKeyParameters; // for verifying

  Writeln('Algorithm Name is: ' + pubParams.AlgorithmName + sLineBreak);

  Writeln('Public Key Normalized XCoord is: ' +
    pubParams.Q.Normalize.AffineXCoord.ToBigInteger.ToString(16) + sLineBreak);
  Writeln('Public Key Normalized YCoord is: ' +
    pubParams.Q.Normalize.AffineYCoord.ToBigInteger.ToString(16) + sLineBreak);

  Writeln('Private Key D Parameter is: ' + privParams.D.ToString(16) +
    sLineBreak);

  PublicKeyByteArray := pubParams.Q.GetEncoded;
  // using ToByteArray here because bytes are unsigned in Pascal
  PrivateKeyByteArray := privParams.D.ToByteArray;

  RegeneratedPublicKey := TECPublicKeyParameters.Create('ECDSA',
    FCurve.Curve.DecodePoint(PublicKeyByteArray), domain);

  if pubParams.Equals(RegeneratedPublicKey) then
  begin
    Writeln('Public Key Recreation Match With Original Public Key' +
      sLineBreak);
  end
  else
  begin
    Writeln('Public Key Recreation DOES NOT Match With Original Public Key' +
      sLineBreak);
  end;

  PrivD := TBigInteger.Create(1, PrivateKeyByteArray);
  RegeneratedPrivateKey := TECPrivateKeyParameters.Create('ECDSA',
    PrivD, domain);

  if privParams.Equals(RegeneratedPrivateKey) then
  begin
    Writeln('Private Key Recreation Match With Original Private Key' +
      sLineBreak);
  end
  else
  begin
    Writeln('Private Key Recreation DOES NOT Match With Original Private Key' +
      sLineBreak);
  end;


  // Do Signing and Verifying to Assert Proper Recreation Of Public Key

  DoSigningAndVerifying(RegeneratedPublicKey, privParams, MethodName,
    'PascalECDSA');

  // Do Signing and Verifying to Assert Proper Recreation Of Private Key

  DoSigningAndVerifying(pubParams, RegeneratedPrivateKey, MethodName,
    'PascalECDSA');
  *)
end;


initialization
cl4pRandom := TSecureRandom.Create(); //FRandom: ISecureRandom;

finalization
//FRandom.free;

end.

