unit Crypto;

{$mode objfpc}{$H+}

//В UAccounts сидят функции конвертации и запаковки
interface
uses
  Classes, SysUtils, UOpenSSLdef, CryptoLib4PascalConnectorUnit
    ,ClpIX9ECParameters
  ,ClpIECDomainParameters
  ,ClpECDomainParameters
  ,ClpIECKeyPairGenerator
  ,ClpIECKeyGenerationParameters
  ,ClpBigInteger
  ,ClpCustomNamedCurves
  ,HlpHashFactory
  ,ClpIECInterface
  ;

type
TRawBytes = AnsiString;
PRawBytes = ^TRawBytes;
{
TECDSA_Public = record
   EC_OpenSSL_NID : Word;
   x: TRawBytes;
   y: TRawBytes;
end;
}
{
TECDSA_SIG = record
   r: TRawBytes;
   s: TRawBytes;
end; { record }
}

//PECDSA_Public = ^TECDSA_Public;

const
  CT_NID_secp256k1 = 714;
  TECDSA_Public_empty:TECDSA_Public=(EC_OpenSSL_NID:0;x:'';y:'');

//function GetPublicKey(const PrivateKey:PEC_KEY): TECDSA_Public;
//function CreatePrivateKeyFromHexa(hexa : AnsiString; EC_OpenSSL_NID : Word =CT_NID_secp256k1) : PEC_KEY;
//function CreatePrivateKeyFromStrBuf(buf : AnsiString; EC_OpenSSL_NID : Word =CT_NID_secp256k1) : PEC_KEY;
function CreatePrivateKeyFromStrBuf(buf : AnsiString) : ansistring;
function GetPublicKey(const PrivateKey:ansistring): TECDSA_Public;
function checkPrivKey(const PrivateKey:ansistring):boolean;

function bufToHex(const raw: AnsiString): AnsiString;
function hexToBuf(hex: AnsiString): AnsiString;

function BufToInt(s: AnsiString;LE:boolean=false): qWord;

function octMixToBuf(const s:ansistring):ansistring;


//MOVED TO CryptoLib4PascalConnectorUnit function DoSha256(p : PAnsiChar; plength : Cardinal) : TRawBytes; overload;
//MOVED TO CryptoLib4PascalConnectorUnit function DoSha256(const TheMessage : AnsiString) : TRawBytes; overload;
//MOVED TO CryptoLib4PascalConnectorUnit function DoRipeMD160(p: PAnsiChar; plength: Cardinal): TRawBytes; overload;
//MOVED TO CryptoLib4PascalConnectorUnit function DoRipeMD160(const TheMessage: AnsiString): TRawBytes; overload;

function reverse(buf:ansistring):ansistring;

//function privKeyToCode58(PrivateKey:PEC_KEY;NetID:char=#128;compressed:boolean=false):ansistring;
function privKeyToCode58(PrivateKey:ansistring;NetID:char=#128;compressed:boolean=false):ansistring;
function loadPrivateKeyFromCode58(buf : AnsiString; netID:char=#0) : ansistring;
function loadPrivateKeyFromBuf(buf : AnsiString) : ansistring;

function raw2code58old(raw : TRawBytes): AnsiString;
//function raw2code58(raw : TRawBytes;preffix:AnsiString=''): AnsiString;
function buf2Base58Check(buf:AnsiString):AnsiString;
function buf2Base58(const buf:AnsiString;addLeadingZeros:boolean=true):AnsiString;
function base58ToBuf(data:AnsiString):AnsiString;
function base58ToBufCheck(data:AnsiString):AnsiString;

function base64ToBuf(data:AnsiString):AnsiString;
function bufToBase64(buf:AnsiString):AnsiString;

function publicKey2Address(const pubkey: TECDSA_Public;NetID:char=#33;compressed:boolean=true): AnsiString; overload;
function publicKey2Address(const pubkey64: ansistring;NetID:char=#33;compressed:boolean=true): AnsiString; overload;

function bignumToBuf(bn:PBIGNUM): ansistring;
function bignumToBufZ(bn:PBIGNUM): ansistring;
function bufToBigNum(const Value: ansistring):PBIGNUM;

function addressto20(const address:ansistring):AnsiString;
function addressto21(const address:ansistring;addressSig:ansistring=''):AnsiString;
function addressto58(const address:ansistring;const addressSig:ansistring):AnsiString;

function IsValidPublicKey(PubKey: TECDSA_Public): Boolean;
function yPointFromX(vX:ansistring; odd:boolean; curveName:ansistring='secp256k1'):ansistring;
function pubKeyToBuf(pubKey:TECDSA_Public;compressed:boolean=true):ansistring;
function bufToPubKey(buf:ansistring):TECDSA_Public;
function bufToPubKeyString(buf:ansistring):ansistring;

Procedure InitCrypto;

//function ECDSASign(Key : PEC_KEY; const digest : AnsiString) : TECDSA_SIG;
//function ECDSAVerify(EC_OpenSSL_NID : Word; PubKey : EC_POINT; const digest : AnsiString; Signature : TECDSA_SIG) : Boolean; overload;
//function ECDSAVerify(PubKey : TECDSA_Public; const digest : AnsiString; Signature : TECDSA_SIG) : Boolean; overload;
function bip66encode(r, s:ansistring):ansistring; overload;
function bip66encode(signature65:ansistring):ansistring; overload;
function EncodeSignature(const signature : TECDSA_SIG;hashType:byte) : TRawBytes;
function DecodeSignature(const rawSignature : TRawBytes) : TECDSA_SIG;

function bip66to64(const der : ansistring): ansistring;

//function Encrypt_AES256(Const data, password : AnsiString): AnsiString;
//function Decrypt_AES256(const encryptedData,password: AnsiString) : AnsiString;

function shlbuf(buf:ansistring;ofs:byte;delIfZero:boolean=false):ansistring;
function shrbuf(buf:ansistring;ofs:byte;delIfZero:boolean=false):ansistring;

function hmac_sha512(buf:ansistring;mkey:ansistring):ansistring;

function encrypt_EC2(const data,pubkey:ansistring):ansistring;
function decrypt_EC2(const data,privkey:ansistring):ansistring;

function randomKey:ansistring;

function restorePubKeyFromSign(sign:ansistring;Digest:ansistring):ansistring;

function ECDSAMessageSignature(PrivKey: ansistring; const digest: AnsiString): AnsiString; //sign message

Const CT_Base58 : AnsiString = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

function createDPOPrivKey(const s:string):ansistring;

implementation
uses UOpenSSL, UCryptoCut
  ,HlpIHash
  ,HlpIHashInfo
  ,base64
  ,ClpIECPrivateKeyParameters
  ,ClpISigner
  ,ClpECPrivateKeyParameters
  ,ClpSignerUtilities
  ;

function randomKey:ansistring;
var bytes:TBytes;
    PrivD:tBigInteger;
begin
  setLength(bytes,32);
  repeat
    cl4pRandom.NextBytes(bytes);
    result:=bytes2buf(bytes);
    PrivD:=buf2TBigInteger(result);
  until not ( (PrivD.CompareTo(TBigInteger.Create('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',16))>=0) or (PrivD.CompareTo(TBigInteger.Zero)<=0));
end;


function createDPOPrivKey(const s:string):ansistring;
var i:integer;
begin
  result:=s;
  for i:=0 to 31999 do result:=doSha256(result);

end;

//typedef struct {
//      uint32_t s[8];
//      uint32_t buf[16]; /* In big endian */
//      size_t bytes;
// } secp256k1_sha256;

//function ecdh_hash_function_sha256(unsigned char *output, const unsigned char *x, const unsigned char *y, void *data)
(*
function ecdh_hash_function_sha256(x,y:):
    unsigned char version = (y[31] & 0x01) | 0x02;
    secp256k1_sha256 sha;
    (void)data;

    secp256k1_sha256_initialize(&sha);
    secp256k1_sha256_write(&sha, &version, 1);
    secp256k1_sha256_write(&sha, x, 32);
    secp256k1_sha256_finalize(&sha, output);

    return 1;
 *)

function encrypt_EC2(const data,pubkey:ansistring):ansistring;
var
  rnd:tBigInteger;
  R,S:IECPoint;
var
  Lcurve:IX9ECParameters;
begin
  //preparation
  Lcurve := TCustomNamedCurves.GetByName('secp256k1'{ACurveName});
  System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');

  //1.create rnd
  rnd:=buf2TBigInteger(randomKey);
  //2. R = rnd*G
  R:=Lcurve.G.Multiply(rnd);
  //3. S = rnd*Q
  S:=bufToiecPoint(pubkey).Multiply(rnd);
  //calc result = R + encrypted_data. Compression is used! password = sha256(compressed S)
  result:= iecPointToBuf(R,true) + Encrypt_AES256_CBC(data,dosha256(iecPointToBuf(S,true)));

end;

function decrypt_EC2(const data,privkey:ansistring):ansistring;
var
  rnd:tBigInteger;
  S:IECPoint;
  myData:ansistring;
  R:ansistring;
var
  Lcurve:IX9ECParameters;
begin
  //preparation
  Lcurve := TCustomNamedCurves.GetByName('secp256k1'{ACurveName});
  System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');

  result:='';

  myData:=data;
  //1. Decode R 2. S=d*R
  if length(myData)<33 then exit;
  if myData[1]=#04
    then R:=copy(myData,1,65)
    else R:=copy(myData,1,33);
  S:=bufToiecPoint(R).Multiply(buf2TBigInteger(privkey));
  delete(myData,1,length(R));
  //3. decode

  result:= Decrypt_AES256_CBC(myData,dosha256(iecPointToBuf(S,true)));
end;


function hmac_sha512(buf:ansistring;mkey:ansistring):ansistring;
var bytes:ansistring;
var
  data,  Key: TBytes;
  Hash: IHash;
  hMAC:IHMAC;
begin


   //class function CreateSHA2_512_224(): IHash; static;
   //class function CreateSHA2_512_256(): IHash; static;
   //class function CreateSHA3_512(): IHash; static;


  data := buf2bytes(buf);//TConverters.ConvertStringToBytes('password', TEncoding.UTF8);
  key := buf2bytes(mkey);//TConverters.ConvertStringToBytes('salt', TEncoding.UTF8);
  Hash := THashFactory.TCrypto.CreateSHA2_512();

  hMAC := THashFactory.THMAC.CreateHMAC(Hash);
  hMAC.Key := Key;//TConverters.ConvertStringToBytes(MyKey, TEncoding.UTF8);

  result :=  bytes2buf(hMAC.ComputeBytes(data).GetBytes());

  //result := bytes2buf(TKDF.TPBKDF2_HMAC.CreatePBKDF2_HMAC(Hash, Password, Salt, iterCount).GetBytes(64));

end;

//=========================AES=======================

{ USED: Copyright (c) 2016 by Albert Molina

  Distributed under the MIT software license, see the accompanying file LICENSE
  or visit http://www.opensource.org/licenses/mit-license.php.

  This unit is a part of the PascalCoin Project, an infinitely scalable
  cryptocurrency. Find us here:
  Web: https://pascalcoin.org
  Source: https://github.com/PascalCoin/PascalCoin

  If you like it, consider a donation using Bitcoin:
  16K3HCZRhFUtM8GdWRcfKeaa6KsuyxZaYk

  THIS LICENSE HEADER MUST NOT BE REMOVED.
}
var
  saltSizeDefault:integer=8;
  defaultSignature:ansistring='EmerAPI:';

function shlbuf(buf:ansistring;ofs:byte;delIfZero:boolean=false):ansistring;
var i:integer;
begin
  result:='';
  if length(buf)=0 then exit;

  if ofs>7 then begin
    //delete(buf,length(buf)+1-ofs div 8,ofs div 8);
    buf:=buf+stringOfChar(#0,ofs div 8);
    ofs:=ofs mod 8;
  end;

  if ofs=0 then begin
    result:=buf;
    exit;
  end;

  setLength(result,length(buf)+1); result[1]:=#0;
  for i:=1 to length(result)-1 do begin
     result[i]:=chr(ord(result[i]) + ord(buf[i]) shr (8-ofs) );
     result[i+1]:=chr(ord(buf[i]) shl ofs);
  end;
  if delIfZero then
    if result[1]=#0 then delete(result,1,1);
end;

function shrbuf(buf:ansistring;ofs:byte;delIfZero:boolean=false):ansistring;
var i:integer;
begin
  setLength(result,length(buf));
  if length(buf)=0 then exit;

  if ofs>7 then begin
    delete(buf,length(buf)+1-ofs div 8,ofs div 8);
    buf:=stringOfChar(#0,ofs div 8)+buf;
    ofs:=ofs mod 8;
  end;

  if ofs=0 then begin
    result:=buf;
    exit;
  end;


  result[1]:=chr(ord(buf[1]) shr ofs);
  for i:=2 to length(result) do
     result[i]:=chr(
        ord(buf[i]) shr ofs
        +
        ord(buf[i-1]) shl (8-ofs)
     );

  if delIfZero then
    if result[1]=#0 then delete(result,1,1);
end;




Function EVP_GetKeyIV(password: ansistring; ACipher: PEVP_CIPHER; const salt: ansistring; out Key, IV: ansistring) : Boolean;
var
  pctx: PEVP_MD_CTX;
  {$IFDEF OpenSSL10}
  ctx: EVP_MD_CTX;
  {$ENDIF}
  hash: PEVP_MD;
  mdbuff: TBytes;
  mds: integer;
  nkey, niv: integer;
begin
  Result := false;
  hash := EVP_sha256();
  mds := 0;
  SetLength(mdbuff, EVP_MAX_MD_SIZE);

  nkey := ACipher^.key_len;
  niv := ACipher^.iv_len;
  SetLength(Key, nkey);
  SetLength(IV, nkey);  // Max size to start then reduce it at the end

  Assert(hash^.md_size >= nkey);
  Assert(hash^.md_size >= niv);

  // This is pretty much the same way that EVP_BytesToKey works. But that
  // allows multiple passes through the hashing loop and also allows to
  // choose different hashing methods. We have no need for this. The
  // OpenSSL docs say it is out of date and internet sources suggest using
  // something like PKCS5_v2_PBE_keyivgen and/or PKCS5_PBKDF2_HMAC_SHA1
  // but this method is easy to port to the DEC and DCP routines and easy to
  // use in other environments. Ultimately the Key and IV rely on the password
  // and the salt and can be easily reformed.

  // This method relies on the fact that the hashing method produces a key of
  // the correct size. EVP_BytesToKey goes through muptiple hashing passes if
  // necessary to make the key big enough when using smaller hashes.
  {$IFDEF OpenSSL10}
  EVP_MD_CTX_init(@ctx);
  pctx := @ctx;
  {$ELSE}
  pctx := EVP_MD_CTX_new();
  {$ENDIF}
  try
    // Key first
    If EVP_DigestInit_ex(pctx, hash, nil)<>1 then exit;
    If EVP_DigestUpdate(pctx, @password[1], Length(password))<>1 then exit;
    if (salt <> '') then begin
      if EVP_DigestUpdate(pctx, @salt[1], Length(salt))<>1 then exit;
    end;
    if (EVP_DigestFinal_ex(pctx, @Key[1], mds)<>1) then exit;

    // Derive IV next
    If EVP_DigestInit_ex(pctx, hash, nil)<>1 then exit;
    If EVP_DigestUpdate(pctx, @Key[1], mds)<>1 then exit;
    If EVP_DigestUpdate(pctx, @password[1], Length(password))<>1 then exit;
    if (salt <> '') then begin
      if EVP_DigestUpdate(pctx, @salt[1], Length(salt))<>1 then exit;
    end;
    If EVP_DigestFinal_ex(pctx, @IV[1], mds)<>1 then exit;

    SetLength(IV, niv);
    Result := true;
  finally
    {$IFDEF OpenSSL10}
    EVP_MD_CTX_cleanup(pctx);
    {$ELSE}
    EVP_MD_CTX_free(pctx);
    {$ENDIF}
  end;
end;

function Encrypt_AES256(Const data, password : AnsiString): AnsiString;
var
  cipher: PEVP_CIPHER;
  pctx: PEVP_CIPHER_CTX;
  {$IFDEF OpenSSL10}
  ctx: EVP_CIPHER_CTX;
  {$ENDIF}
  key, iv, salt:ansistring;
  buf: ansistring;
  block_size: integer;
  buf_start, out_len: integer;

  ti:Integer;
begin
  cipher := EVP_aes_256_cbc();

  SetLength(salt, PKCS5_SALT_LEN);
  RAND_pseudo_bytes(@salt[1], PKCS5_SALT_LEN);

  EVP_GetKeyIV(password, cipher, salt, key, iv);

  {$IFDEF OpenSSL10}
  EVP_CIPHER_CTX_init(@ctx);
  pctx := @ctx;
  {$ELSE}
  pctx := EVP_CIPHER_CTX_new();
  {$ENDIF}
  try
    EVP_EncryptInit(pctx, cipher, @key[1], @iv[1]);
    block_size := EVP_CIPHER_CTX_block_size(pctx);

    buf:=defaultSignature+salt;
    ti:=length(buf)+1;

    buf:=buf+stringOfChar(#0,Length(data) + block_size);

    EVP_EncryptUpdate(pctx, @buf[ti], out_len, @data[1], Length(data));
    ti:=ti+out_len;
    EVP_EncryptFinal(pctx, @buf[ti], out_len);
    ti:=ti+out_len;

    SetLength(buf, ti-1);
    result := buf
  finally
    {$IFDEF OpenSSL10}
    EVP_CIPHER_CTX_cleanup(pctx);
    {$ELSE}
    EVP_CIPHER_CTX_free(pctx);
    {$ENDIF}
  end;
end;

function Decrypt_AES256(const encryptedData,password: AnsiString) : AnsiString;
var
  cipher: PEVP_CIPHER;
  pctx: PEVP_CIPHER_CTX;
  {$IFDEF OpenSSL10}
  ctx: EVP_CIPHER_CTX;
  {$ENDIF}
  salt, key, iv, buf: ansistring;
  src_start, buf_start, out_len: integer;
begin
  Result := '';
  cipher := EVP_aes_256_cbc();
  SetLength(salt, PKCS5_SALT_LEN);
  // First read the signature and the salt - if any
  //if (length(encryptedData)>=length(defaultSalt)) AND (AnsiString(TEncoding.ASCII.GetString(encryptedData, 1, length(defaultSalt))) = defaultSalt) then
  if (length(encryptedData)>=length(defaultSignature)) AND (copy(encryptedData, 1, length(defaultSignature)) = defaultSignature) then
  begin
    salt:=copy(encryptedData,length(defaultSignature)+1,PKCS5_SALT_LEN);
    If Not EVP_GetKeyIV(password, cipher, salt, key, iv) then exit;
    src_start := length(defaultSignature) + PKCS5_SALT_LEN+1;{+1 because of string}
  end
  else
  begin
    If Not EVP_GetKeyIV(password, cipher, '', key, iv) then exit;
    src_start := 1;
  end;
  {$IFDEF OpenSSL10}
  EVP_CIPHER_CTX_init(@ctx);
  pctx := @ctx;
  {$ELSE}
  pctx := EVP_CIPHER_CTX_new();
  {$ENDIF}
  try
    If EVP_DecryptInit(pctx, cipher, @key[1], @iv[1])<>1 then exit;
    SetLength(buf, Length(encryptedData));
    buf_start := 1;
    If EVP_DecryptUpdate(pctx, @buf[buf_start], out_len, @encryptedData[src_start], Length(encryptedData) - src_start+1)<>1 then exit;
    Inc(buf_start, out_len);
    If EVP_DecryptFinal(pctx, @buf[buf_start], out_len)<>1 then exit;
    Inc(buf_start, out_len);
    SetLength(buf, buf_start-1);
    Result := buf;
  finally
    {$IFDEF OpenSSL10}
    EVP_CIPHER_CTX_cleanup(pctx);
    {$ELSE}
    EVP_CIPHER_CTX_free(pctx);
    {$ENDIF}
  end;
end;
//========================init====================================
Var _initialized : Boolean = false;

Procedure InitCrypto;
var err : String;
 c : Cardinal;
Begin
  raise exception.Create('Open_SSL deprecated!');
  if Not (_initialized) then begin
    _initialized := true;
    If Not InitSSLFunctions then begin
      err := 'Cannot load OpenSSL library '+SSL_C_LIB;
      //TLog.NewLog(ltError,'OpenSSL',err);
      Raise Exception.Create(err);
    end;
    If Not Assigned(OpenSSL_version_num) then begin
      err := 'OpenSSL library is not v1.1 version: '+SSL_C_LIB;
      //TLog.NewLog(ltError,'OpenSSL',err);
      Raise Exception.Create(err);
    end;
    c := OpenSSL_version_num();
    if (c<$10100000) Or (c>$1010FFFF) then begin
      err := 'OpenSSL library is not v1.1 version ('+IntToHex(c,8)+'): '+SSL_C_LIB;
      //TLog.NewLog(ltError,'OpenSSL',err);
      Raise Exception.Create(err);
    end;
  end;
End;
//=============================sign====================================
(*
function ECDSASign(Key: PEC_KEY; const digest: AnsiString): TECDSA_SIG;
Var PECS : PECDSA_SIG;
  p : PAnsiChar;
  i : Integer;
begin
  PECS := ECDSA_do_sign(PAnsiChar(digest),length(digest),Key);
  Try
    if PECS = Nil then raise Exception.Create('ECDSASign: Error signing');

    i := BN_num_bytes(PECS^._r);
    SetLength(Result.r,i);
    //p := @Result.r[1];
    //i := BN_bn2bin(PECS^._r,p);
    i := BN_bn2bin(PECS^._r,@Result.r[1]);

    i := BN_num_bytes(PECS^._s);
    SetLength(Result.s,i);
    //p := @Result.s[1];
    //i := BN_bn2bin(PECS^._s,p);
    i := BN_bn2bin(PECS^._s,@Result.s[1]);
  Finally
    ECDSA_SIG_free(PECS);
  End;
end;

function ECDSAVerify(EC_OpenSSL_NID : Word; PubKey: EC_POINT; const digest: AnsiString; Signature: TECDSA_SIG): Boolean;
Var PECS : PECDSA_SIG;
  PK : PEC_KEY;
  {$IFDEF OpenSSL10}
  {$ELSE}
  bnr,bns : PBIGNUM;
  {$ENDIF}
begin
  PECS := ECDSA_SIG_new();
  Try
    {$IFDEF OpenSSL10}
    BN_bin2bn(PAnsiChar(Signature.r),length(Signature.r),PECS^._r);
    BN_bin2bn(PAnsiChar(Signature.s),length(Signature.s),PECS^._s);
    {$ELSE}
{    ECDSA_SIG_get0(PECS,@bnr,@bns);
    BN_bin2bn(PAnsiChar(Signature.r),length(Signature.r),bnr);
    BN_bin2bn(PAnsiChar(Signature.s),length(Signature.s),bns);}
    bnr := BN_bin2bn(PAnsiChar(Signature.r),length(Signature.r),nil);
    bns := BN_bin2bn(PAnsiChar(Signature.s),length(Signature.s),nil);
    if ECDSA_SIG_set0(PECS,bnr,bns)<>1 then Raise Exception.Create('Dev error 20161019-1 '+ERR_error_string(ERR_get_error(),nil));
    {$ENDIF}

    PK := EC_KEY_new_by_curve_name(EC_OpenSSL_NID);
    EC_KEY_set_public_key(PK,@PubKey);
    Case ECDSA_do_verify(PAnsiChar(digest),length(digest),PECS,PK) of
      1 : Result := true;
      0 : Result := false;
    Else
      raise Exception.Create('ECDSAVerify:Error on Verify');
    End;
    EC_KEY_free(PK);
  Finally
    ECDSA_SIG_free(PECS);
  End;
end;

function ECDSAVerify(PubKey: TECDSA_Public; const digest: AnsiString; Signature: TECDSA_SIG): Boolean;
Var BNx,BNy : PBIGNUM;
  ECG : PEC_GROUP;
  ctx : PBN_CTX;
  pub_key : PEC_POINT;
begin
  BNx := BN_bin2bn(PAnsiChar(PubKey.x),length(PubKey.x),nil);
  BNy := BN_bin2bn(PAnsiChar(PubKey.y),length(PubKey.y),nil);

  ECG := EC_GROUP_new_by_curve_name(PubKey.EC_OpenSSL_NID);
  pub_key := EC_POINT_new(ECG);
  ctx := BN_CTX_new();
  if EC_POINT_set_affine_coordinates_GFp(ECG,pub_key,BNx,BNy,ctx)=1 then begin
    Result := ECDSAVerify(PubKey.EC_OpenSSL_NID, pub_key^,digest,signature);
  end else begin
    Result := false;
  end;
  {$IFDEF HIGHLOG}
  TLog.NewLog(ltdebug,ClassName,Format('ECDSAVerify %s x:%s y:%s Digest:%s Signature r:%s s:%s',
    [TAccountComp.GetECInfoTxt(PubKey.EC_OpenSSL_NID),ToHexaString(PubKey.x),ToHexaString(PubKey.y),
      ToHexaString(digest),ToHexaString(Signature.r),ToHexaString(Signature.s)]));
  {$ENDIF}
  BN_CTX_free(ctx);
  EC_POINT_free(pub_key);
  EC_GROUP_free(ECG);
  BN_free(BNx);
  BN_free(BNy);
end;
*)

function IsHumanReadable(const ReadableText: TRawBytes): Boolean;
Var i : Integer;
Begin
  Result := true;
  for i := 1 to length(ReadableText) do begin
    if (ord(ReadableText[i])<32) Or (ord(ReadableText[i])>=255) then begin
      Result := false;
      Exit;
    end;
  end;
end;

function wordSerializeAnsiString(s:ansistring):ansistring;
var l:word;
begin
  if length(s)>$FFFF then raise exception.create('wordSerializeAnsiString: too long string');
  l:=length(s);
  setlength(result,l+2);
  move(l,result[1],2);
  move(s[1],result[1+2],l);
end;

function popSerializedAnsiString(var s:ansistring):ansistring;
var l:word;
begin
  if length(s)<2 then raise exception.Create('popSerializedAnsiString: string too short');
  move(s[1],l,2);
  if length(s)<(2+l) then raise exception.Create('popSerializedAnsiString: can''t read string');
  result:=copy(s,3,l);
  delete(s,1,2+l);
end;


function bip66encode(signature65:ansistring):ansistring;
begin
  if length(signature65)<>65 then raise exception.create('bip66encode: signature length must be 65 bytes');
  if (ord(signature65[1])-27)>7 then raise exception.create('bip66encode: wrong signature for 65-bytes sign');

  result:=bip66encode(copy(signature65,2,32),copy(signature65,34,32));
end;

function bip66encode(r, s:ansistring):ansistring;
begin
  if length(r)=0 then raise exception.create('bip66encode: R length is zero');
  if length(s)=0 then raise exception.create('bip66encode: S length is zero');
  if length(r)>33 then raise exception.create('bip66encode: R length is too long');
  if length(s)>33 then raise exception.create('bip66encode: S length is too long');
  if (ord(r[1]) and $80)>0 then raise exception.create('bip66encode: R value is negative');
  if (ord(s[1]) and $80)>0 then raise exception.create('bip66encode: S value is negative');

  if (length(r)>1) and (r[1]=#0) and (ord(r[2]) and $80 <>0) then raise exception.create('bip66encode: R value excessively padded');
  if (length(s)>1) and (s[1]=#0) and (ord(s[2]) and $80 <>0) then raise exception.create('bip66encode: S value excessively padded');

  //setLength(result,6+length(r)+length(s));
  // 0x30 [total-length] 0x02 [R-length] [R] 0x02 [S-length] [S]
  result:=
     chr($30)                     //signature[0] = 0x30
    +chr(6+length(r)+length(s)-2) //signature[1] = signature.length - 2
    +#2                           //signature[2] = 0x02
    +chr(length(r))               //signature[3] = r.length
    +r                            //r.copy(signature, 4)
    +#2                           //signature[4 + lenR] = 0x02
    +chr(length(r))               //signature[5 + lenR] = s.length
    +s                            //s.copy(signature, 6 + lenR)
end;

function EncodeSignature(const signature: TECDSA_SIG;hashType:byte): TRawBytes;
var hashTypeMod:byte;
begin
//  ECSignature.prototype.toScriptSignature = function (hashType)
    {
    var hashTypeMod = hashType & ~0x80
    if (hashTypeMod <= 0 || hashTypeMod >= 4) throw new Error('Invalid hashType ' + hashType)

    var hashTypeBuffer = Buffer.alloc(1)
    hashTypeBuffer.writeUInt8(hashType, 0)

    return Buffer.concat([this.toDER(), hashTypeBuffer])


  ECSignature.prototype.toDER = function () {
    var r = Buffer.from(this.r.toDERInteger())
    var s = Buffer.from(this.s.toDERInteger())

    return bip66.encode(r, s)
  }

  function encode (r, s) {
    var lenR = r.length
    var lenS = s.length
    if (lenR === 0) throw new Error('R length is zero')
    if (lenS === 0) throw new Error('S length is zero')
    if (lenR > 33) throw new Error('R length is too long')
    if (lenS > 33) throw new Error('S length is too long')
    if (r[0] & 0x80) throw new Error('R value is negative')
    if (s[0] & 0x80) throw new Error('S value is negative')
    if (lenR > 1 && (r[0] === 0x00) && !(r[1] & 0x80)) throw new Error('R value excessively padded')
    if (lenS > 1 && (s[0] === 0x00) && !(s[1] & 0x80)) throw new Error('S value excessively padded')

    var signature = Buffer.allocUnsafe(6 + lenR + lenS)

    // 0x30 [total-length] 0x02 [R-length] [R] 0x02 [S-length] [S]
    signature[0] = 0x30
    signature[1] = signature.length - 2
    signature[2] = 0x02
    signature[3] = r.length
    r.copy(signature, 4)
    signature[4 + lenR] = 0x02
    signature[5 + lenR] = s.length
    s.copy(signature, 6 + lenR)

    return signature
  }

  }

  hashTypeMod := hashType and (not $80);
  if (hashTypeMod <= 0) or (hashTypeMod >= 4) then raise exception.Create('EncodeSignature:Invalid hashType ' + inttostr(hashType));

  result:=bip66encode(signature.r, signature.s)+chr(hashType);
end;

function bip66to64(const der : ansistring): ansistring;
var buf,s:ansistring;
    rValue:ansistring;

 function pops(var buf:ansistring):ansistring;
 begin
   if length(buf)<=ord(buf[1]) then raise exception.Create('unexpected end of string');
   result:=copy(buf,2,ord(buf[1]));
   delete(buf,1,ord(buf[1])+1);
 end;

begin
{
  30
   /// 45 --->>>> NO
   02
     21
       00CD7BA1B640639E88BA862CCB146519EFCBBA8381E1F0C1BBCE0A96675FCAB434
   02
     20
       3A3432FFC51902063E6287CAD62BE730F0C6BBD6EB08EC0009D95330CE2B70DB
}
  result:='';
  buf:=der;
  if length(buf)<70 then exit;

  if buf[1]<>#$30 then exit;
  delete(buf,1,1);

  try
     s:=pops(buf);
     if buf<>'' then exit;
     buf:=s;

    //r
    if buf[1]<>#2 then exit; delete(buf,1,1);

    s:=pops(buf);
    if length(s)=33 then
      if s[1]=#0 then delete(s,1,1)
                 else exit;
    if length(s)<>32 then exit;

    rValue:=s;

    //s
    if buf[1]<>#2 then exit; delete(buf,1,1);

    s:=pops(buf);
    if buf<>'' then exit;
    if length(s)=33 then
      if s[1]=#0 then delete(s,1,1)
                 else exit;
    if length(s)<>32 then exit;

    result:=rValue+s;
  except
    result:='';
  end;
end;


function DecodeSignature(const rawSignature : TRawBytes) : TECDSA_SIG;
var s : ansistring;
  CT_TECDSA_SIG_Nul: TECDSA_SIG = (r:'';s:'');
begin
  raise exception.create('DecodeSignature надо полностью переделать' );

  result := CT_TECDSA_SIG_Nul;

  s:=rawSignature;
  result.r:=popSerializedAnsiString(s);
  result.s:=popSerializedAnsiString(s);

  if s<>'' then result := CT_TECDSA_SIG_Nul;

end;

function ECDSAMessageSignature(PrivKey: ansistring; const digest: AnsiString): AnsiString; //sign message
var
  PrivateKey: IECPrivateKeyParameters;
  Lcurve: IX9ECParameters;
  domain: IECDomainParameters;
  Signer: ISigner;
  recovery:byte;

var
  puk,backup:ansistring;
begin
  Lcurve := TCustomNamedCurves.GetByName('secp256k1');
  System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');

  domain := TECDomainParameters.Create(Lcurve.Curve, Lcurve.G, Lcurve.N, Lcurve.H, Lcurve.GetSeed);
  PrivateKey:=TECPrivateKeyParameters.Create('ECDSA', buf2TBigInteger(PrivKey), domain);

  Signer := TSignerUtilities.GetSigner('NONEwithECDSA'{SigningAlgo});

  Signer.Init(True, PrivateKey);
  Signer.BlockUpdate(@digest[1], 0, System.Length(digest));

  result := bytes2buf(Signer.GenerateSignature());

  //der -> 65byte

  //isYEven:=(flagByte and 1) >0;
  //isSecondKey:=(flagByte and 2) >0;

  //if isYEven
  //  then Rpt:=curve.Curve.DecompressPoint(1,x)
  //  else Rpt:=curve.Curve.DecompressPoint(-1,x);

  // 1.1 Compute x
  //if not isSecondKey
  //   then x:=r
  //   else x:=r.Add(n) {.&Mod(p)};


//!  TSignerUtilities.re
//!  PrivateKey.
  backup:=result; //!!!

  recovery:=0;

  recovery:=recovery or 4; //compressed
  recovery:=recovery+27;
  result:=chr(recovery)+bip66to64(result);

  //this is crasy: REDO IT!!!
  puk:=restorePubKeyFromSign(result,digest);
  if puk<>pubKeyToBuf(GetPublicKey(PrivKey),length(puk)<40) then begin
    recovery:=1;

    recovery:=recovery or 4; //compressed
    recovery:=recovery+27;
    result:=chr(recovery)+bip66to64(backup);
  end;
end;

//============================================================
//function DoSha256(p : PAnsiChar; plength : Cardinal) : TRawBytes; overload;
//function DoSha256(const TheMessage : AnsiString) : TRawBytes; overload;
(*
function DoSha256(p: PAnsiChar; plength: Cardinal): TRawBytes;
Var PS : PAnsiChar;
begin
  SetLength(Result,32);
  PS := @Result[1];
  SHA256(p,plength,PS);
end;

function DoSha256(const TheMessage: AnsiString): TRawBytes;
Var PS : PAnsiChar;
begin
  SetLength(Result,32);
  PS := @Result[1];
  SHA256(PAnsiChar(TheMessage),Length(TheMessage),PS);
end;

function DoRipeMD160(const TheMessage: AnsiString): TRawBytes;
Var PS : PAnsiChar;
begin
  SetLength(Result,20);
  PS := @Result[1];
  RIPEMD160(PAnsiChar(TheMessage),Length(TheMessage),PS);
end;
function DoRipeMD160(p: PAnsiChar; plength: Cardinal): TRawBytes;
Var PS : PAnsiChar;
begin
  SetLength(Result,20);
  PS := @Result[1];
  RIPEMD160(p,plength,PS);
end;
*)
//============================================================
function bufToHex(const raw: AnsiString): AnsiString;
Var i : Integer;
  s : AnsiString;
  b : Byte;
begin
  SetLength(Result,length(raw)*2);
  for i := 0 to length(raw)-1 do begin
    b := Ord(raw[i+1]);
    s := IntToHex(b,2);
    Result[(i*2)+1] := s[1];
    Result[(i*2)+2] := s[2];
  end;
end;

function hexToBuf(hex: AnsiString): AnsiString;
Var i : Integer;
  s : AnsiString;
  b : Byte;
begin
  if (length(hex)>0) and (hex[1]='$') then delete(hex,1,1);
  if (length(hex)>1) and ((hex[1]+hex[2])='0x') then delete(hex,1,2);

  if (length(hex) mod 2)=1 then hex:='0'+hex;



  //this don't work in Lazarus???:
  SetLength(Result,length(hex) div 2);
  for i := 0 to length(hex) div 2 - 1 do
    result[i+1]:= chr(strToInt('$'+hex[i*2+1]+hex[i*2+2]));

  //so, we do this:
  //result:='';
  //for i := 0 to length(hex) div 2 - 1 do
  //  result:=result + chr(strToInt('$'+hex[i*2+1]+hex[i*2+2]));


end;

function BufToInt(s: AnsiString;LE:boolean=false): qWord;
var i:integer;
    n:qWord;
begin
 result:=0;

 if LE then n:=$1000000 else n:=1;
 for i:=1 to length(s) do begin
   result:=result + ord(s[i])*n;
   if LE then n:=n shr 8 else n:=n shl 8;
 end;
end;

function octMixToBuf(const s:ansistring):ansistring;
Var i : Integer;
  b : Byte;
begin

  // https://en.wikipedia.org/wiki/Escape_sequences_in_C
  //oct + text line?
  //"\000\000\000\000\000\000\000@\000\000\000\000\000\000\000P\325\340\n\b\000\000"
  //&
{
  \a and \007	07	Alert (Beep, Bell) (added in C89)[1]
  \b	08	Backspace
  \f	0C	Formfeed
  \n	0A	Newline (Line Feed); see notes below
  \r	0D	Carriage Return
  \t	09	Horizontal Tab
  \v	0B	Vertical Tab
  \\	5C	Backslash
  \'	27	Single quotation mark
  \"	22	Double quotation mark
  \?	3F	Question mark (used to avoid trigraphs)
  \nnnnote 1	any	The byte whose numerical value is given by nnn interpreted as an octal number
  \xhh…	any	The byte whose numerical value is given by hh… interpreted as a hexadecimal number
  \e   	1B	escape character (some character sets)
  \Uhhhhhhhh	none	Unicode code point where h is a hexadecimal digit
  \uhhhh	none	Unicode code point below 10000 hexadecimal
}

  result:='';
  i:=1;

  while i<=length(s) do
    if (s[i]='\') and (i<>length(s)) then begin
         case s[i+1] of
           'a': result:=result+chr($07);
           'b': result:=result+chr($08);
           'f': result:=result+chr($0C);
           'n': result:=result+chr($0A);
           'r': result:=result+chr($0D);
           't': result:=result+chr($09);
           'v': result:=result+chr($0B);
           '\': result:=result+chr($5C);
           '''':result:=result+chr($27);
           '"': result:=result+chr($22);
           '?': result:=result+chr($3F);
           'e': result:=result+chr($1B);
           '0'..'7':begin
             result:=result+chr(strtoint('&'+copy(s,i+1,3)));
             inc(i);inc(i);
           end;
           'x':begin
             result:=result+chr(strtoint('$'+copy(s,i+1,2)));
             inc(i);
           end;
           'U':begin
             //result:=result+chr(strtoint64('$'+copy(s,i+1,8)));
             result:=result+chr(strtoint('$'+copy(s,i+1,2)));
             result:=result+chr(strtoint('$'+copy(s,i+3,2)));
             result:=result+chr(strtoint('$'+copy(s,i+5,2)));
             result:=result+chr(strtoint('$'+copy(s,i+7,2)));
             i:=i+7;
           end;
           'u':begin
             //result:=result+chr(strtoint64('$'+copy(s,i+1,8)));
             result:=result+chr(strtoint('$'+copy(s,i+1,2)));
             result:=result+chr(strtoint('$'+copy(s,i+3,2)));
             i:=i+3;
           end;
         else
           raise exception.Create('octMixToBuf: wrong \'+s[i+1]+' symbol');
         end;
         inc(i);inc(i);
       end
    else begin
      //just symbol
      result:=result+s[i]; inc(i);
    end;
end;

function reverse(buf:ansistring):ansistring;
var i:integer;
begin
  setLength(result,length(buf));
  for i:=1 to length(buf) do
    result[length(result)-i+1]:=buf[i];

end;

(*
function CreatePrivateKey(bn : PBIGNUM; EC_OpenSSL_NID : Word =CT_NID_secp256k1) : PEC_KEY;
var
  ctx : PBN_CTX;
  pub_key : PEC_POINT;
begin
   //if Assigned(FPrivateKey) then EC_KEY_free(FPrivateKey);
   //FEC_OpenSSL_NID := EC_OpenSSL_NID;
   result := EC_KEY_new_by_curve_name(EC_OpenSSL_NID);
   If Not Assigned(result) then Exit;
   if EC_KEY_set_private_key(result,bn)<>1 then raise Exception.Create('Invalid num to set as private key');
   //
   ctx := BN_CTX_new();
   pub_key := EC_POINT_new(EC_KEY_get0_group(result));
   try
     if EC_POINT_mul(EC_KEY_get0_group(result),pub_key,bn,nil,nil,ctx)<>1 then raise Exception.Create('Error obtaining public key');
     EC_KEY_set_public_key(result,pub_key);
   finally
     BN_CTX_free(ctx);
     EC_POINT_free(pub_key);
   end;
end;
*)

function loadPrivateKeyFromBuf(buf : AnsiString) : ansistring;
begin
  result:='';
  if ((length(buf)=33) and (buf[33]=#1))
    then delete(buf,33,1)
    else if (length(buf)<>32) then exit;

  if not checkPrivKey(buf) then exit;

  result:=buf;
end;

function loadPrivateKeyFromCode58(buf : AnsiString; netID:char=#0) : ansistring;
begin
  result:='';
  try
    result:=base58ToBufCheck(buf);
  except
    exit;
  end;

  if length(result)<33 then exit;

  if netID<>#0 then
    if result[1]<>netID then begin
      result:='';
      exit;
    end;

  result:=loadPrivateKeyFromBuf(result);
end;

function CreatePrivateKeyFromStrBuf(buf : AnsiString) : ansistring;
begin
  Result := '';

  if ((length(buf)=33) and (buf[33]=#1)) then delete(buf,33,1)
  else if (length(buf)<>32) then raise exception.create('CreatePrivateKeyFromStrBuf: invalid key size');

  if not checkPrivKey(buf) then exit;

  result:=buf;
end;

{
function CreatePrivateKeyFromStrBuf(buf : AnsiString; EC_OpenSSL_NID : Word =CT_NID_secp256k1) : PEC_KEY;
var bn : PBIGNUM;
begin
  Result := nil;

  if ((length(buf)=33) and (buf[33]=#1)) then delete(buf,33,1)
  else if (length(buf)<>32) then raise exception.create('CreatePrivateKeyFromStrBuf: invalid key size');

  bn := BN_new();
  try
   bn := BN_bin2bn(PAnsiChar(buf),length(buf),bn);
   if not assigned(bn) then  Raise Exception.Create('CreatePrivateKeyFromStrBuf : error for '+buf);
   result:= CreatePrivateKey(bn,EC_OpenSSL_NID);
  finally
   BN_free(bn);
  end;
end;
}














function checkPrivKey(const PrivateKey:ansistring):boolean;
var PrivD: TBigInteger;
begin
  PrivD:= buf2TBigInteger(PrivateKey);
  result:= not ( (PrivD.CompareTo(TBigInteger.Create('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',16))>=0) or (PrivD.CompareTo(TBigInteger.Zero)<=0));
end;

function GetPublicKey(const PrivateKey:ansistring): TECDSA_Public;
var PrivD: TBigInteger;
    Q:IECPoint;
    Lcurve: IX9ECParameters;
begin
  result.EC_OpenSSL_NID:=CT_NID_secp256k1;
  result.x:='';
  result.y:='';

  Lcurve := TCustomNamedCurves.GetByName('secp256k1');
  System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');


  PrivD:= buf2TBigInteger(PrivateKey);

  if (PrivD.CompareTo(TBigInteger.Create('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',16))>=0) or (PrivD.CompareTo(TBigInteger.Zero)<=0) then exit;

  Q:=Lcurve.G.Multiply(PrivD).Normalize();
  if not Q.IsValid() then exit;

  result.x:=TBigInteger2buf(Q.XCoord.ToBigInteger());
  result.y:=TBigInteger2buf(Q.YCoord.ToBigInteger());

end;

{
function GetPublicKey(const PrivateKey:PEC_KEY): TECDSA_Public;
var ps : PAnsiChar;
  BNx,BNy : PBIGNUM;
  ctx : PBN_CTX;
begin
  //Result.EC_OpenSSL_NID := FEC_OpenSSL_NID;
  Result.EC_OpenSSL_NID := CT_NID_secp256k1;

  ctx := BN_CTX_new();
  BNx := BN_new();
  BNy := BN_new();
  Try
    EC_POINT_get_affine_coordinates_GFp(EC_KEY_get0_group(PrivateKey),EC_KEY_get0_public_key(PrivateKey),BNx,BNy,ctx);
    SetLength(Result.x,BN_num_bytes(BNx));
    BN_bn2bin(BNx,@Result.x[1]);
    SetLength(Result.y,BN_num_bytes(BNy));
    BN_bn2bin(BNy,@Result.y[1]);
  Finally
    BN_CTX_free(ctx);
    BN_free(BNx);
    BN_free(BNy);
  End;
end;
}

function IsValidPublicKey(PubKey: TECDSA_Public): Boolean;
var //pk:^TECDSA_Public;
    Lcurve: IX9ECParameters;
    //domain: IECDomainParameters;
    PublicKeyBytes: TBytes;
    t:ansistring;
    Q:IECPoint;
begin
  result:=false;
  if PubKey.EC_OpenSSL_NID<>CT_NID_secp256k1 then exit;

  Lcurve := TCustomNamedCurves.GetByName('secp256k1'{ACurveName});
  System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');

  // Set Up Asymmetric Key Pair from known public key ByteArray



//  domain := TECDomainParameters.Create(Lcurve.Curve, Lcurve.G, Lcurve.N, Lcurve.H, Lcurve.GetSeed);

  Q := LCurve.Curve.CreatePoint(buf2TBigInteger(PubKey.x), buf2TBigInteger(PubKey.y));


  result:=Q.IsValid();

  //Q := LCurve.Curve.CreatePoint(buf2TBigInteger(PubKey.x), buf2TBigInteger(PubKey.y));
  //RegeneratedPublicKey := TECPublicKeyParameters.Create(point, domain);

  //result := TECPublicKeyParameters.Create('ECDSA', Lcurve.Curve.DecodePoint(PublicKeyBytes), domain);

  //result:=sadsd
end;

(*
Var BNx,BNy : PBIGNUM;
  ECG : PEC_GROUP;
  ctx : PBN_CTX;
  pub_key : PEC_POINT;
begin
  Result := False;
  BNx := BN_bin2bn(PAnsiChar(PubKey.x),length(PubKey.x),nil);
  if Not Assigned(BNx) then Exit;
  try
    BNy := BN_bin2bn(PAnsiChar(PubKey.y),length(PubKey.y),nil);
    if Not Assigned(BNy) then Exit;
    try
      ECG := EC_GROUP_new_by_curve_name(PubKey.EC_OpenSSL_NID);
      if Not Assigned(ECG) then Exit;
      try
        pub_key := EC_POINT_new(ECG);
        try
          if Not Assigned(pub_key) then Exit;
          ctx := BN_CTX_new();
          try
            Result := EC_POINT_set_affine_coordinates_GFp(ECG,pub_key,BNx,BNy,ctx)=1;
          finally
            BN_CTX_free(ctx);
          end;
        finally
          EC_POINT_free(pub_key);
        end;
      finally
        EC_GROUP_free(ECG);
      end;
    finally
      BN_free(BNy);
    end;
  finally
    BN_free(BNx);
  end;
end;
  *)


function restorePubKeyFromSign(sign:ansistring;Digest:ansistring):ansistring;
var
  r, s: TBigInteger;
  ri,z,n: TBigInteger;

  //v2
  alpha,beta, p, x, y ,p_over_four:TBigInteger;

  t:TBigInteger;
  G,Q: IECPoint;
  Rpt: IECPoint;
  //curve: IECCurve;
  curve: IX9ECParameters;
  //d, X, RLocal: IECFieldElement;
  flagByte:byte;
  compressed:boolean;
//  recovery:byte; //2 bits
  isYEven:boolean;
  isSecondKey:boolean;
begin


  {
    R1=point restored from r (odd)
    R2=point restored from r (even)
    rm=exp(r,-1)  //ModInverse
    z=sha256(message) mod N

    pub1=rm(s*R1- z*G) ; pub2=rm(s*R2-z*G)
  }
 // https://github.com/bitcoin/bitcoin/blob/9af3c3c8249785a0106c14bce1cb72b3afc536e8/src/bitcoinrpc.cpp#L661
 // https://github.com/bitcoin/bitcoin/blob/9af3c3c8249785a0106c14bce1cb72b3afc536e8/src/key.cpp#L323
 // кто-то написал
 // https://github.com/oleganza/bitcoin-duo/blob/master/src/ecwrapper.cpp


  //https://github.com/tuaris/CryptoCurrencyPHP/blob/master/Signature.class.php

  //decode signature
  result:='';
  if (length(sign)<>65) then exit;

  flagByte:=ord(sign[1]) - 27;

  if (flagByte > 7) then exit; //Invalid signature parameter

  //$isYEven = ($recoveryFlags & 1) != 0;
  //$isSecondKey = ($recoveryFlags & 2) != 0;

  r:=buf2TBigInteger(copy(sign, 2,32));
  s:=buf2TBigInteger(copy(sign,34,32));

  //
  compressed := (flagByte and 4) > 0;
  //recovery := (flagByte and 3);
  isYEven:=(flagByte and 1) >0;
  isSecondKey:=(flagByte and 2) >0;

  //init curve data
  curve := TCustomNamedCurves.GetByName('secp256k1');
  System.Assert(curve <> Nil, 'curve Cannot be Nil');
  n:=curve.N;

  //V2 prep:
  p:=buf2TBigInteger(hextoBuf('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F'));
  //p_over_four = gmp_div(gmp_add($p, 1), 4);
  //p_over_four := p.Add(buf2TBigInteger(#1)).Divide(buf2TBigInteger(#4));
  //i've calculated it:
  p_over_four := buf2TBigInteger(hextoBuf('3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFFFFF0C'));


  // r and s should both in the range [1,n-1]
  if ((r.SignValue < 1) or (s.SignValue < 1) or (r.CompareTo(n) >= 0)
    or (s.CompareTo(n) >= 0)) then exit;

  //  if (!$isSecondKey) {
  //   $x = $R;
  //  } else {
  //   $x = gmp_add($R, $n);
  //  }
    //r:=buf2TBigInteger(copy(sign,2,32));


  // 1.1 Compute x
  if not isSecondKey
     then x:=r
     else x:=r.Add(n) {.&Mod(p)};

  // 1.3 Convert x to point
  // $alpha is GMP
  //alpha = gmp_mod(gmp_add(gmp_add(gmp_pow($x, 3), gmp_mul($a, $x)), $b), $p);
//!  alpha:=x.Pow(3).Add(curve.Curve.a.ToBigInteger.Multiply(x)).Add(curve.Curve.b.ToBigInteger).&Mod(p);



  // $beta is DEC String (INT)
  //$beta = gmp_strval(gmp_powm($alpha, $p_over_four, $p));
//!  beta:=alpha.ModPow(p_over_four,p);

  // If beta is even, but y isn't or vice versa, then convert it,
  // otherwise we're done and y == beta.
  {
  if (PointMathGMP::isEvenNumber($beta) == $isYEven) {
  	// gmp_sub function will convert the DEC String "$beta" into a GMP
  	// $y is a GMP
  	$y = gmp_sub($p, $beta);
  } else {
  	// $y is a GMP
  	$y = gmp_init($beta);
  }
  }
//!  if beta.&And(TBigInteger.One).Equals(TBigInteger.One)=isYEven
//!     then y:=p.Subtract(beta)
//!     else y:=beta;
  if isYEven
    then Rpt:=curve.Curve.DecompressPoint(1,x)
    else Rpt:=curve.Curve.DecompressPoint(-1,x);




  // 1.4 Check that nR is at infinity (implicitly done in construtor) -- Not reallly
  // $Rpt is Array(GMP, GMP)
  //$Rpt = array('x' => $x, 'y' => $y);


  {
  // 1.6.1 Compute a candidate public key Q = r^-1 (sR - eG)
  // $rInv is a HEX String
  $rInv = gmp_strval(gmp_invert($R, $n), 16);
  // $eGNeg is Array (GMP, GMP)
  $eGNeg = PointMathGMP::negatePoint(PointMathGMP::mulPoint($e, $G, $a, $b, $p));
  $sR = PointMathGMP::mulPoint($s, $Rpt, $a, $b, $p);
  $sR_plus_eGNeg = PointMathGMP::addPoints($sR, $eGNeg, $a, $p);
  // $Q is Array (GMP, GMP)
  $Q = PointMathGMP::mulPoint($rInv, $sR_plus_eGNeg, $a, $b, $p);
  // Q is the derrived public key
  // $pubkey is Array (HEX String, HEX String)
  // Ensure it's always 64 HEX Charaters
  $pubKey['x'] = str_pad(gmp_strval($Q['x'], 16), 64, 0, STR_PAD_LEFT);
  $pubKey['y'] = str_pad(gmp_strval($Q['y'], 16), 64, 0, STR_PAD_LEFT);
  return $pubKey;
   }

  //Q = r^-1 (sR - eG) = ri (sR - zG)

  //r-1
  ri := r.ModInverse(n);

  //calculate z
  z:=buf2TBigInteger(digest).&Mod(p);

  //calculate Q =rm(s*R1-z*G)
  Q:=Rpt.Multiply(s).Subtract(curve.G.Multiply(z)).Multiply(ri);

  result:=bytes2Buf(Q.GetEncoded(compressed));

/////-====================================================================


  //order = BN_CTX_get(ctx);
  //if (!EC_GROUP_get_order(group, order, ctx)) { ret = -2; goto err; }
  //if (!BN_copy(x, order)) { ret=-1; goto err; }
  //if (!BN_mul_word(x, i)) { ret=-1; goto err; }
  //if (!BN_add(x, x, ecsig->r)) { ret=-1; goto err; }
  //order=curve.N;
 // t:=buf2TBigInteger(chr(recovery) {div 2});   //D!
 // r:=curve.N.Multiply(t).Add(r);               //D!


 (* OLD WAY

  //ok, start calculation
  //1. rm=ModInverse r
  ri := x.ModInverse(n);

  //calculate z
  z:=buf2TBigInteger(digest).&Mod(n);

  //R
  //result.x:=copy(buf,2,32);
  //result.y:=yPointFromX(result.x, buf[1] =#2{, result.EC_OpenSSL_NID});

  if ????{even} then
    R1:=curve.Curve.DecompressPoint(1,r)
  else
    R1:=curve.Curve.DecompressPoint(-1,r)
  //R1:=curve.Curve.DecompressPoint(,r);

  //calculate Q =rm(s*R1-z*G)
  Q:=R1.Multiply(s).Subtract(curve.G.Multiply(z)).Multiply(ri);

  result:=bytes2Buf(Q.GetEncoded(compressed));
*)
end;



function yPointFromX(vX:ansistring; odd:boolean; curveName:ansistring='secp256k1'):ansistring;
var //pk:^TECDSA_Public;
    Lcurve: IX9ECParameters;
    //domain: IECDomainParameters;
    //PublicKeyBytes: TBytes;
    //t:ansistring;
    Q:IECPoint;
    tl:integer;
    bi,Dmax:tBigInteger;
begin
  result:='';
  //if PubKey.EC_OpenSSL_NID<>CT_NID_secp256k1 then exit;

  Lcurve := TCustomNamedCurves.GetByName(curveName);
  System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');

//  if odd then tl:=2 else tl:=3;
  if odd then tl:=-1 else tl:=1;

  Q:=Lcurve.Curve.DecompressPoint(tl,buf2TBigInteger(vX));

//  bi:=Q.AffineYCoord.ToBigInteger();

//  Dmax:=TBigInteger.Create('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',16);
//  if Bi.CompareTo(Dmax)>0 then
//    Bi:=Dmax.Subtract(Bi);

  result:= TBigInteger2Buf(Q.AffineYCoord.ToBigInteger());
end;

(*
function yPointFromX(vX:ansistring; odd:boolean; EC_OpenSSL_NID: Word =CT_NID_secp256k1):ansistring;
Var {BNx,BNy : PBIGNUM;
  ECG : PEC_GROUP;
  pub_key : PEC_POINT;
  key : PEC_KEY;}
  p,x,r,t,t1 : PBIGNUM;
  ctx : PBN_CTX;
  st:ansistring;
begin
{
  import binascii

  p_hex = 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F'
  p = int(p_hex, 16)
  compressed_key_hex = '0250863AD64A87AE8A2FE83C1AF1A8403CB53F53E486D8511DAD8A04887E5B2352'
  x_hex = compressed_key_hex[2:66]
  x = int(x_hex, 16)
  prefix = compressed_key_hex[0:2]

  y_square = (pow(x, 3, p)  + 7) % p
  y_square_square_root = pow(y_square, (p+1)/4, p)
  if (prefix == "02" and y_square_square_root & 1) or (prefix == "03" and not y_square_square_root & 1):
      y = (-y_square_square_root) % p
  else:
      y = y_square_square_root

  computed_y_hex = format(y, '064x')
  computed_uncompressed_key = "04" + x_hex + computed_y_hex

  print computed_uncompressed_key
}

  //BN_exp() raises a to the p-th power and places the result in r (r=a^p). This function is faster than repeated applications of BN_mul().
  //BN_exp: function(r: PBIGNUM; a: PBIGNUM; p: PBIGNUM; ctx: PBN_CTX): TC_INT; cdecl = nil;


  Result := '';
  try
    ctx := BN_CTX_new();
    p:=BN_new();   x:=BN_new();   r:=BN_new();   t:=BN_new(); t1:=BN_new();
    try
      st:=hexToBuf('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F'); //CT_NID_secp256k1
      p := BN_bin2bn(PAnsiChar(st),length(st),p);
      st:=hexToBuf('03'); //secp256k1
      t := BN_bin2bn(PAnsiChar(st),length(st),t);
      x := BN_bin2bn(PAnsiChar(vX),length(vX),x);

      ///if BN_exp(r,x,t,ctx)<>1 then raise exception.Create('yPointFromX: can''t calc x*x*x');
      //if BN_mod_exp(r,x,t,p,ctx)<>1 then raise exception.Create('yPointFromX: can''t x^3');
      if BN_sqr(r, x, ctx)<>1 then raise exception.Create('yPointFromX: can''t calc x*x');
      if BN_nnmod(r,r,p,ctx)<>1 then raise exception.Create('yPointFromX: can''t calc r=r%p');
      if BN_mul(r, r, x, ctx)<>1 then raise exception.Create('yPointFromX: can''t calc x*x*x');



      st:=hexToBuf('07'); //secp256k1
      t := BN_bin2bn(PAnsiChar(st),length(st),t);
      //BN_add: function(r: PBIGNUM; a: PBIGNUM; b: PBIGNUM): TC_INT; cdecl = nil;
      if BN_add(r,r,t)<>1 then raise exception.Create('yPointFromX: can''t calc x*x*x + 7');

      //mod p:
      //  BN_nnmod: function(r: PBIGNUM; m: PBIGNUM; d: PBIGNUM; ctx: PBN_CTX ): TC_INT; cdecl = nil;
      //BN_nnmod() reduces a modulo m and places the non-negative remainder in r.
      if BN_nnmod(r,r,p,ctx)<>1 then raise exception.Create('yPointFromX: can''t calc (x*x*x + 7)%p');

      //sqrt!!!
      st:=hexToBuf('01'); //secp256k1
      t := BN_bin2bn(PAnsiChar(st),length(st),t);
      if BN_add(t,p,t)<>1 then raise exception.Create('yPointFromX: can''t calc t = p + 1');

      st:=hexToBuf('04'); //secp256k1
      t1 := BN_bin2bn(PAnsiChar(st),length(st),t1);
      //BN_div: function(dv: PBIGNUM; rem: PBIGNUM; m: PBIGNUM; d: PBIGNUM; ctx : PBN_CTX): TC_INT; cdecl = nil;
      // int BN_div(BIGNUM *dv, BIGNUM *rem, const BIGNUM *a, const BIGNUM *d,         BN_CTX *ctx);
      //BN_div() divides a by d and places the result in dv and the remainder in rem (dv=a/d, rem=a%d). Either of dv and rem may be NULL, in which case the respective value is not returned.
      if BN_div(t,nil,t,t1,ctx)<>1 then raise exception.Create('yPointFromX: can''t calc t=t/4');

      //sqrt(r)= r^t mod p
      if BN_mod_exp(r,r,t,p,ctx)<>1 then raise exception.Create('yPointFromX: can''t calc sqrt(r)');
      if BN_nnmod(r,r,p,ctx)<>1 then raise exception.Create('yPointFromX: can''t calc r=(r)%p');

      //if (prefix == "02" and y_square_square_root & 1) or (prefix == "03" and not y_square_square_root & 1): y = (-y_square_square_root) % p
      result:=bignumToBuf(r);
      if odd xor (ord(result[length(result)]) mod 2 = 0)
        then begin//r:=p-r
          st:=#0; t := BN_bin2bn(PAnsiChar(st),length(st),t);
          //  BN_sub: function(r: PBIGNUM; a: PBIGNUM; b: PBIGNUM): TC_INT; cdecl = nil;
          if BN_mod_sub(r,t,r,p,ctx)<>1 then raise exception.Create('yPointFromX: can''t calc r=0-r');
          result:=bignumToBuf(r);
        end;
      //result:='';

    finally
      BN_free(p); BN_free(x); BN_free(r); BN_free(t1); // BN_free(t);

    end;
  finally
    BN_CTX_free(ctx);
  end;
  {
  p='FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F' для CT_NID_secp256k1
  x=из буфера
  t:=из буф (#3);
  r=new
  BN_exp(r,x,t)
  t=7
  r=r+t
  r = r mod p

  y_square_square_root = pow(y_square, (p+1)/4, p)
  }

  {
  Result := '';
  BNx := BN_bin2bn(PAnsiChar(x),length(x),nil);
  if Not Assigned(BNx) then Exit;
  try
    ECG := EC_GROUP_new_by_curve_name(EC_OpenSSL_NID);
    if Not Assigned(ECG) then Exit;
    try
      ctx := BN_CTX_new();
      try

        pub_key := EC_POINT_new(ECG);
        //pub_key:=EC_POINT_bn2point( ECG,  BNx, nil, ctx);
        try

          key := EC_KEY_new_by_curve_name(EC_OpenSSL_NID);
          If Not Assigned(key) then Exit;
          if EC_KEY_set_public_key(key,pub_key)<>1 then raise Exception.Create('Invalid num to set as private key');


          result:= bignumToBuf(@pub_key^.Y);
        finally
          EC_POINT_free(pub_key);
        end;

      finally
        BN_CTX_free(ctx);
      end;

      // y = sqrt (x*x*x+7 )
      //: y^2= (x^3) + 7 (mod p)
      //EC_POINT_bn2point: function( group: PEC_GROUP;  b: PBIGNUM;	point: PEC_POINT; ctx: PBN_CTX): PEC_POINT; cdecl = nil;

    finally
      EC_GROUP_free(ECG);
    end;
  finally
    BN_free(BNx);
  end;
  }
 {
  x = new BN(x, 16);
  if (!x.red)
    x = x.toRed(this.red);

  var y2 = x.redSqr().redMul(x).redIAdd(x.redMul(this.a)).redIAdd(this.b);
  var y = y2.redSqrt();
  if (y.redSqr().redSub(y2).cmp(this.zero) !== 0)
    throw new Error('invalid point');

  // XXX Is there any way to tell if the number is odd without converting it
  // to non-red form?
  var isOdd = y.fromRed().isOdd();
  if (odd && !isOdd || !odd && isOdd)
    y = y.redNeg();

  return this.point(x, y);
}

end;

  *)

function bufToPubKey(buf:ansistring):TECDSA_Public;
begin
  result.EC_OpenSSL_NID:=CT_NID_secp256k1;
//  if length(buf)<33 then raise exception.Create('bufToPubKey:wrong length');

  if (length(buf)=33) and (buf[1] in [#2,#3]) then begin
     result.x:=copy(buf,2,32);
     result.y:=yPointFromX(result.x, buf[1] =#2{, result.EC_OpenSSL_NID});
  end else if (length(buf)=65) and (buf[1] in [#4]) then begin
     result.x:=copy(buf,2,32);
     result.y:=copy(buf,34,32);
  end else raise exception.Create('bufToPubKey:wrong length');

end;

function bufToPubKeyString(buf:ansistring):ansistring;
begin
  if (length(buf)=33) and (buf[1] in [#2,#3]) then begin
     result:=copy(buf,2,32)+ yPointFromX(copy(buf,2,32), buf[1] =#2{, result.EC_OpenSSL_NID});
  end else if (length(buf)=65) and (buf[1] in [#4]) then begin
     result:=copy(buf,2,32)+copy(buf,34,32);
  end else raise exception.Create('bufToPubKey:wrong length');
end;

function pubKeyToBuf(pubKey:TECDSA_Public;compressed:boolean=true):ansistring;
begin

  Result := '';
  if (length(pubkey.x)<>32) or (length(pubkey.y)<>32) then raise exception.create('pubKeyToBuf: wrong public key');
  if compressed then begin

//    if (ord(pubkey.y[length(pubkey.y)-1]) mod 2)<>0
    if (ord(pubkey.y[length(pubkey.y)]) mod 2)=0
       then result:=#02 //Even
       else result:=#03;//нечет

    result:=result + pubkey.x;
  end else begin
    result := chr($04) + pubkey.x + pubkey.y;
  end;

    //    var x = keyPair.Q.affineX
    //    var y = keyPair.Q.affineY
    //    var byteLength = keyPair.Q.curve.pLength
    //    var buffer

    //    // 0x02/0x03 | X
    //    if (keyPair.Q.compressed) {
    //      buffer = Buffer.allocUnsafe(1 + byteLength)
    //      buffer.writeUInt8(y.isEven() ? 0x02 : 0x03, 0)
    //
    //    // 0x04 | X | Y
    //    } else {
    //      buffer = Buffer.allocUnsafe(1 + byteLength + byteLength)
    //      buffer.writeUInt8(0x04, 0)

    //      y.toBuffer(byteLength).copy(buffer, 1 + byteLength)
    //    }

    //    x.toBuffer(byteLength).copy(buffer, 1)
end;


//======================================================



{
function publicKey2RawString(const pubkey: TECDSA_Public): TRawBytes;
Var s : TMemoryStream;
begin
  s := TMemoryStream.Create;
  try
    //TStreamOp.WriteAccountKey(s,pubkey);
    s.Write(pubkey.x,pubkey.y);
    SetLength(result,s.Size);
    s.Position := 0;
    s.Read(result[1],s.Size);
  finally
    s.Free;
  end;
end;
}



function bufToBigNum(const Value: ansistring):PBIGNUM;
var p : PBIGNUM;
begin
  result:=BN_new();
  p := BN_bin2bn(PAnsiChar(Value),length(Value),result);
  if (p<>result) Or (p=Nil) then Raise Exception.Create('Error decoding Raw value to BigNum "'+bufToHex(Value)+'" ('+inttostr(length(value))+')'+#10+
    ERR_error_string(ERR_get_error(),nil));
end;

{
function bufToBigNum(const Value: TRawBytes):PBIGNUM;
begin
  result := BN_bin2bn(PAnsiChar(Value),length(Value),nil);
  if (result=Nil) then Raise Exception.Create('Error decoding Raw value to BigNum'+#10+
    ERR_error_string(ERR_get_error(),nil));
end;
}

function bignumToBuf(bn:PBIGNUM): TRawBytes;
Var p : PAnsiChar;
  i : Integer;
begin
  i := BN_num_bytes(bn);
  SetLength(Result,i);
  p := @Result[1];
  i := BN_bn2bin(bn,p);
end;

function bignumToBufZ(bn:PBIGNUM): TRawBytes;
begin
  result:= bignumToBuf(bn);
  if result='' then result:=#0;
end;


function privKeyToCode58(PrivateKey:PEC_KEY;NetID:char=#128;compressed:boolean=false):ansistring;
var BN:PBIGNUM;
    s:ansistring;
begin
  //bs58check.encode(Buffer.concat([Buffer.alloc(1,keyPair.network.wif),keyPair.d.toBuffer(),Buffer.alloc(1,1)]))})
  if compressed then s:=#1 else s:='';
  bn:=EC_KEY_get0_private_key(PrivateKey);
  //try
    result:=buf2Base58Check(
      NetID+bignumToBuf(bn)+s
    );
  //finally
    //BN_free(BN); //DO NOT NEED!!!
  //end;
end;

function privKeyToCode58(PrivateKey:ansistring;NetID:char=#128;compressed:boolean=false):ansistring;
var s:ansistring;
begin
  if compressed then s:=#1 else s:='';
  result:=buf2Base58Check(NetID+PrivateKey+s );

end;

//function encode (payload)
{
  var checksum = checksumFn(payload)

  return base58.encode(Buffer.concat([
    payload,
    checksum
  ], payload.length + 4))
}

function raw2code58old(raw : TRawBytes): AnsiString;
//Converts byte string to code58 bitcoin string
Var
  BN, BNMod, BNDiv : TBigNum;
  i : Integer;
begin
  Result := '';
  BN := TBigNum.Create;
  BNMod := TBigNum.Create;
  BNDiv := TBigNum.Create(Length(CT_Base58));
  try
    BN.HexaValue := '01'+ bufToHex( raw )+bufToHex(Copy(DoSha256(raw),1,4));
    while (Not BN.IsZero) do begin
      BN.Divide(BNDiv,BNMod);
      If (BNMod.Value>=0) And (BNMod.Value<length(CT_Base58)) then Result := CT_Base58[Byte(BNMod.Value)+1] + Result
      else raise Exception.Create('Error converting to Base 58');
    end;
  finally
    BN.Free;
    BNMod.Free;
    BNDiv.Free;
  end;
end;


function base64ToBuf(data:AnsiString):AnsiString;
begin
  result:=DecodeStringBase64(data);
end;

function bufToBase64(buf:AnsiString):AnsiString;
begin
   result:=EncodeStringBase64(buf);
end;

function buf2Base58Check(buf:AnsiString):AnsiString;
begin
  result:=buf2Base58(buf+Copy(DoSha256(DoSha256(buf)),1,4)); //BufToHex(Copy(DoSha256(DoSha256(buf)),1,4));//
end;

function base58ToBuf(data:AnsiString):AnsiString;
Var
  i ,n : Integer;
  s:ansistring;
  bn,BNMul:tBigInteger;

begin
  Result := '';

  if length(data)<1 then exit;
  //add leading zeros
  while data[1]=CT_Base58[1] do begin
    result:=result+#0;
    delete(data,1,1);
  end;


//  if BN_mul(FBN,FBN,BN.FBN,ctx)<>1 then raise Exception.Create('Error on multiply');
  BNMul:= buf2TBigInteger(chr(Length(CT_Base58)));
  bn:=tBigInteger.Zero;
  //readin symbols
  for i:=1 to length(data) do begin
    bn:=bn.Multiply(BNMul);
    n:=pos(data[i],CT_Base58)-1;
    if n<0 then raise exception.create('base58ToBuf: wrong '+data[i]+' character');
    s:=chr(n);
    bn:=bn.Add(buf2TBigInteger(s));
  end;
  result:=result + TBigInteger2Buf(bn);
end;

{
function base58ToBuf(data:AnsiString):AnsiString;
Var
  bn:PBIGNUM;
  ctx : PBN_CTX;
  BNMul :PBIGNUM;
  BNel :PBIGNUM;
  i ,n : Integer;
  //t:ansistring;
  s:ansistring;
begin
  Result := '';

  if length(data)<1 then exit;
  //add leading zeros
  while data[1]=CT_Base58[1] do begin
    result:=result+#0;
    delete(data,1,1);
  end;


//  if BN_mul(FBN,FBN,BN.FBN,ctx)<>1 then raise Exception.Create('Error on multiply');
  BN:=BN_new();
  BNel:=BN_new();
  BNMul:= bufToBigNum(chr(Length(CT_Base58)));

  ctx := BN_CTX_new();
  try
    //readin symbols
    for i:=1 to length(data) do begin
      if BN_mul(BN,BN,BNMul,ctx)<>1 then raise Exception.Create('Error on multiply');

      n:=pos(data[i],CT_Base58)-1;
      if n<0 then raise exception.create('base58ToBuf: wrong '+data[i]+' character');
      s:=chr(n);
      BNel := BN_bin2bn(PAnsiChar(s),1,BNel);

      if BN_add(BN,BN,BNel)<>1 then raise Exception.Create('Error on multiply');
    end;

    result:=result + bignumToBuf(bn);
  finally
    BN_free(BN);
    BN_free(BNel);
    BN_free(BNMul);
    BN_CTX_free(ctx);
  end;
end;
}

function base58ToBufCheck(data:AnsiString):AnsiString;
begin
  result:=base58ToBuf(data);


  if copy(result,length(result)-3,4)<> Copy(DoSha256(DoSha256(copy(result,1,length(result)-4))),1,4)
       then raise exception.create('base58ToBufCheck: Wrong sha256 signature. Must be '+bufToHex(copy(result,length(result)-3,4))+' but calculated '+
         bufToHex(Copy(DoSha256(DoSha256(copy(result,1,length(result)-4))),1,4))
       );
  delete(result,length(result)-3,4);//удаляем CRC

end;

function buf2Base58(const buf:AnsiString;addLeadingZeros:boolean=true):AnsiString;
var
 iMod, iDiv, iNum:tBigInteger;
 i:integer;
begin
  Result := '';

  iDiv := buf2TBigInteger(chr(Length(CT_Base58)));


  iNum := buf2TBigInteger(buf);

  while (iNum.CompareTo(TBigInteger.Zero)>0) do begin
    //BN_div(bn,BNMod,bn,BNDiv,ctx);
    iMod:=iNum.&Mod(iDiv);
    iNum:=iNum.Divide(iDiv);

    result:= CT_Base58[iMod.Int32Value+1] + result
  end;

  //adding leading zeros
  if addLeadingZeros then begin
    i:=1;
    while (i<=length(buf)) and (buf[i]=#0) do begin
      result:=CT_Base58[1]+result;
      inc(i);
    end;
  end;
end;

{
function buf2Base58(const buf:AnsiString;addLeadingZeros:boolean=true):AnsiString;     !!
Var
  bn:PBIGNUM;
  ctx : PBN_CTX;
  BNMod, BNDiv :PBIGNUM;
  i : Integer;
  //t:ansistring;
begin
  Result := '';
  BN:=BN_new();  //will be created in BN_bin2bn(
  BNMod:=BN_new();
  BNDiv := bufToBigNum(chr(Length(CT_Base58)));
  ctx := BN_CTX_new();
  try
    //buf:=buf+Copy(DoSha256(DoSha256(buf)),1,4);
    bn := BN_bin2bn(PAnsiChar(buf),length(buf),bn);
    if not assigned(bn) then  Raise Exception.Create('raw2code58 : error for '+buf);

    while (bignumToBuf(bn)<>'') do begin
      BN_div(bn,BNMod,bn,BNDiv,ctx);
      result:= CT_Base58[ord(bignumToBufZ(BNMod)[1])+1] + result
    end;

    //adding leading zeros
    if addLeadingZeros then begin
      i:=1;
      while (i<=length(buf)) and (buf[i]=#0) do begin
        result:=CT_Base58[1]+result;
        inc(i);
      end;
    end;

  finally
    BN_free(BN);
    BN_free(BNMod);
    BN_free(BNDiv);
    BN_CTX_free(ctx);
  end;
end;
}

{
function raw2code58(raw : TRawBytes;preffix:AnsiString=''): AnsiString;
//Converts byte string to code58 bitcoin string
Var
  //tBN, tBNMod, tBNDiv : TBigNum;
  bn:PBIGNUM;
  ctx : PBN_CTX;
  BNMod, BNDiv :PBIGNUM;
  i : Integer;
  //t:ansistring;
begin
  Result := '';
  BN:=BN_new();  //will be created in BN_bin2bn(
  BNMod:=BN_new();
  BNDiv := bufToBigNum(chr(Length(CT_Base58)));
  ctx := BN_CTX_new();
  try
    //BN.HexaValue := '01'+ bufToHex( raw )+bufToHex(Copy(DoSha256(raw),1,4));
    //raw:=raw+Copy(DoSha256(DoSha256(raw)),1,4);
   raw:=preffix+raw+Copy(DoSha256(DoSha256(raw)),1,4);

    bn := BN_bin2bn(PAnsiChar(raw),length(raw),bn);
    if not assigned(bn) then  Raise Exception.Create('raw2code58 : error for '+raw);

    while (bignumToBuf(bn)<>'') do begin
      //tBN.Divide(BNDiv,BNMod);
      //BN_div: function(dv: PBIGNUM; rem: PBIGNUM; m: PBIGNUM; d: PBIGNUM; ctx : PBN_CTX): TC_INT; cdecl = nil;

      //BN_div(FBN,remainder.FBN,FBN,dividend.FBN,ctx);

      BN_div(bn,BNMod,bn,BNDiv,ctx);
      result:= CT_Base58[ord(bignumToBufZ(BNMod)[1])+1] + result

      //If (tBNMod.Value>=0) And (BNMod.Value<length(CT_Base58)) then Result := CT_Base58[Byte(BNMod.Value)+1] + Result
      //else raise Exception.Create('Error converting to Base 58');
    end;
  finally
    BN_free(BN);
    BN_free(BNMod);
    BN_free(BNDiv);
    BN_CTX_free(ctx);
  end;
//  if result<>raw2code58old(raw) then raise exception.create('result<>raw2code58old(raw):'
//   + 'result="'+result+'"; raw2code58old(raw)="'+ raw2code58old(raw)+'"'
//  );
end;
}


//function publicKey2Address(const pubkey: ansistring;NetID:char=#33;compressed:boolean=true): AnsiString;
//begin
//  result:='';
//end;

function publicKey2Address(const pubkey64: ansistring;NetID:char=#33;compressed:boolean=true): AnsiString;
var mpubkey: TECDSA_Public;
begin
  {
  mpubkey.x:=copy(pubkey64,1,32);
  mpubkey.y:=copy(pubkey64,33,32);

  if lenght(y)=1 then
    mpubkey.y:=asdasd

  mpubkey.EC_OpenSSL_NID:=CT_NID_secp256k1;  }

  mpubkey:=bufToPubKey(pubkey64);

  result:=buf2Base58Check(NetID+DoRipeMD160(DoSha256(pubKeyToBuf(mpubkey,compressed))));
end;

function addressto20(const address:ansistring):AnsiString;
begin
  if length(address)<20 then result:=''
  else if length(address)=20 then result:=address
  else if length(address)=21 then result:=copy(address,2,20)
  else result:=addressto20(base58ToBufCheck(address));
end;

function addressto21(const address:ansistring;addressSig:ansistring=''):AnsiString;
begin
  if addressSig='' then
     if length(address)=21
          then addressSig:=address[1]
          else if length(address)>21 then
             addressSig:=base58ToBufCheck(address)[1];

  if addressSig='' then raise exception.create('addressto21: singature not defined');

  if address='' then result:='' else
    result:=addressSig+addressto20(address);
end;

function addressto58(const address:ansistring;const addressSig:ansistring):AnsiString;
begin
  if address='' then result:='' else
    result:=buf2Base58Check(addressto21(address,addressSig));
end;

function publicKey2Address(const pubkey: TECDSA_Public;NetID:char=#33;compressed:boolean=true): AnsiString;
//https://en.bitcoin.it/wiki/File:PubKeyToAddr.png
//Var raw : TRawBytes;
  //BN, BNMod, BNDiv : TBigNum;
  //i : Integer;
//var t:ansistring;
begin

  //    // 0x02/0x03 | X
  //    if (keyPair.Q.compressed) {
  //      buffer = Buffer.allocUnsafe(1 + byteLength)
  //      buffer.writeUInt8(y.isEven() ? 0x02 : 0x03, 0)
  //
  //    // 0x04 | X | Y
  //    } else {
  //      buffer = Buffer.allocUnsafe(1 + byteLength + byteLength)
  //      buffer.writeUInt8(0x04, 0)

  //      y.toBuffer(byteLength).copy(buffer, 1 + byteLength)
  //    }


  result:=buf2Base58Check(NetID+DoRipeMD160(DoSha256(pubKeyToBuf(pubkey,compressed))));

 {
  Result := '';
  if (length(pubkey.x)<>32) or (length(pubkey.y)<>32) then raise exception.create('publicKey2Address: wrong public key');

  if compressed then begin

    if (ord(pubkey.y[length(pubkey.y)-1]) mod 2)<>0
       then result:=#02 //Even
       else result:=#03;//нечет

    result:=result + pubkey.x;
    result := buf2Base58Check(NetID+DoRipeMD160(DoSha256(result)));
  end else begin
    result := chr($04) + pubkey.x + pubkey.y;
    result := buf2Base58Check(NetID+DoRipeMD160(DoSha256(result)));
  end;
  }










  //!result := NetID+DoRipeMD160(DoSha256(result));
  //!result := result + copy(DoSha256(DoSha256(result)),1,4);
  //result:=buf2Base58Check(NetID+result);

 //!!!  result := buf2Base58Check(NetID+DoRipeMD160(DoSha256(result)));

 //!!!!!!!!!!  result := buf2Base58Check(NetID+DoRipeMD160(DoSha256(result)));

{    t:=result;
    result:=raw2code58old(result);
    if raw2code58old(result)<>raw2code58(result) then
     raise exception.create('raw2code58(result)<>raw2code58old(result):'
       + 'new="'+raw2code58(result)+'"; old="'+ raw2code58old(result)+'"'
     );
  }


end;
{
function publicKey2code58(const pubkey: TECDSA_Public): AnsiString; //УБРАТЬ ЭТОТ БРЕД
Var raw : TRawBytes;
  BN, BNMod, BNDiv : TBigNum;
  i : Integer;
begin
  Result := '';
  raw := pubkey.x + pubkey.y; //publicKey2RawString(pubkey);
  BN := TBigNum.Create;
  BNMod := TBigNum.Create;
  BNDiv := TBigNum.Create(Length(CT_Base58));
  try
    BN.HexaValue := '01'+ bufToHex( raw )+bufToHex(Copy(DoSha256(raw),1,4));
    while (Not BN.IsZero) do begin
      BN.Divide(BNDiv,BNMod);
      If (BNMod.Value>=0) And (BNMod.Value<length(CT_Base58)) then Result := CT_Base58[Byte(BNMod.Value)+1] + Result
      else raise Exception.Create('Error converting to Base 58');
    end;
  finally
    BN.Free;
    BNMod.Free;
    BNDiv.Free;
  end;
end;
}

end.

