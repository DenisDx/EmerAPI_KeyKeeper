unit HDNodeUnit;

{$mode objfpc}{$H+}
{$modeswitch ADVANCEDRECORDS}

interface

uses
  Classes, SysUtils

  ,EmerTX
  , ClpBigInteger
  , ClpECPoint
  //, ClpIX9ECPoint
  ,ClpIECInterface
  ;

type
{ tHDNode }

tBip32=record
  VerPrivate:dword;
  VerPublic:dword;
end;

tNetworkData=record
  wif:char;
  pubKeySig:char;
  bip32:tBip32;
end;


tHDNode=record
  private
   const
    HIGHEST_BIT:dword = $80000000;
    DATALENGTH:byte = 78;
   var
    fData:ansistring; //length = 64 = privkey + chain / 65 for pubkey only = pubkey + chain
    fnetwork:tNetworkData;
    fdepth:byte;
    fparentFingerprint:dword;
    findex:dword;
    //fPrivate:boolean;
    //fPublicKey:ansistring;  //uncompressed, xy
    fPublicKeyCache:IECPoint; //cached!!!

    function getPrivate:boolean;
  public
    //property version:dword read fversion;
    compressed:boolean;
    property isPrivate:boolean read getPrivate;

    property network:tNetworkData read fnetwork write fnetwork;
    property depth:byte read fdepth;

    function chainCode:ansistring;

    function derive(index:dword):tHDNode; overload;
    function derive(path:ansistring):tHDNode; overload;

    procedure clear;

    function isValid:boolean;

    function loadFromKey(buf:ansistring;mnetwork:tNetworkData;mdepth:byte;mparentFingerprint:dword;mindex:dword;mcompressed:boolean=true):boolean;
    function loadFromCode58(code58:ansistring;mnetwork:tNetworkData):boolean;
    function asCode58:ansistring;
    function getPrivateKey:ansistring;
    function getPublicKey(getCompressed:boolean=true):ansistring;
    function Q:IECPoint;
    function D:tBigInteger;


    function getPublicKeyBuffer:ansistring;
    function getIdentifier():ansistring;
    function getFingerprint():dword;

    function getShortPrivateKeyCode58:ansistring;
    function getAddressCode58:ansistring;
end;


implementation

uses
  crypto, CryptoLib4PascalConnectorUnit
  ,ClpCustomNamedCurves
  ,ClpIX9ECParameters
  ;
//========================================= HD ===================================

//HDNode.prototype.toBase58 = function (__isPrivate)
{
  if (__isPrivate !== undefined) throw new TypeError('Unsupported argument in 2.0.0')

  // Version
  var network = this.keyPair.network
  var version = (!this.isNeutered()) ? network.bip32.private : network.bip32.public
  var buffer = Buffer.allocUnsafe(78)

  // 4 bytes: version bytes
  buffer.writeUInt32BE(version, 0)

  // 1 byte: depth: 0x00 for master nodes, 0x01 for level-1 descendants, ....
  buffer.writeUInt8(this.depth, 4)

  // 4 bytes: the fingerprint of the parent's key (0x00000000 if master key)
  buffer.writeUInt32BE(this.parentFingerprint, 5)

  // 4 bytes: child number. This is the number i in xi = xpar/i, with xi the key being serialized.
  // This is encoded in big endian. (0x00000000 if master key)
  buffer.writeUInt32BE(this.index, 9)

  // 32 bytes: the chain code
  this.chainCode.copy(buffer, 13)

  // 33 bytes: the public key or private key data
  if (!this.isNeutered()) {
    // 0x00 + k for private keys
    buffer.writeUInt8(0, 45)
    this.keyPair.d.toBuffer(32).copy(buffer, 46)

  // 33 bytes: the public key
  } else {
    // X9.62 encoding for public keys
    this.keyPair.getPublicKeyBuffer().copy(buffer, 45)
  }

  return base58check.encode(buffer)
}

//HDNode.prototype.derive = function (index)


function tHDNode.getShortPrivateKeyCode58:ansistring;
 var s:ansistring;
begin
  if compressed then s:=#1 else s:='';
  result:=buf2Base58Check(fnetwork.wif+getPrivateKey+s);
end;

function tHDNode.getAddressCode58:ansistring;
begin
  result:=buf2Base58Check(fNetwork.pubKeySig+getIdentifier);
end;


function tHDNode.getPublicKeyBuffer:ansistring;
begin
  result:=getPublicKey(compressed);
  //getpubkeyduffer (compressed?)
end;

function tHDNode.getIdentifier():ansistring;
begin
  //result:= bcrypto.hash160(this.keyPair.getPublicKeyBuffer())
  result:=DoRipeMD160(dosha256(getPublicKeyBuffer));
end;

function tHDNode.getFingerprint():dword;
var s:ansistring;
begin
  result:=0;
  s:=getIdentifier;
  if length(s)>4 then begin
    move(s[1],result,4);
    result:=swapEndian(result);
  end;
  //return this.getIdentifier().slice(0, 4)
end;

function tHDNode.derive(path:ansistring):tHDNode;
var s,ss:ansistring;
    i:integer;
    Hardened:boolean;
begin

 //  m/n'/n'.....
 //  /n'/'
 //  n'/'
 s:=trim(path);
 if lowercase(s[1])='m' then begin
  //cut steps to fdepth
  if fdepth=0 then delete(s,1,1)
    else raise exception.Create('tHDNode.derive: absolute deepth not supported for non-root node')
 end;

 s:=trim(s);
 if s='' then raise exception.Create('tHDNode.derive: wrong path');

 if s[1]='/' then begin
   delete(s,1,1);
   s:=trim(s);
 end;
 ss:='';
 while (s<>'') and (s[1] in ['0'..'9']) do begin
     ss:=ss+s[1];
     delete(s,1,1);
 end;
 if ss='' then raise exception.Create('tHDNode.derive: wrong path');
 i:=strtoint(ss);
 s:=trim(s);

 if (s<>'') and (s[1]='''') then begin
   delete(s,1,1);
   i:=i+HIGHEST_BIT;
 end;
 s:=trim(s);

 result:=self.derive(i);

 if s<>'' then
   result:=result.derive(s);

end;

function tHDNode.derive(index:dword):tHDNode;
var isHardened:boolean;
    data:ansistring;
    I:ansistring;
    pIL:tBigInteger;
    Ki:IECPoint;
    //newPrivKey,newPubKey:ansistring;

    curve: IX9ECParameters;
begin
  curve := TCustomNamedCurves.GetByName('secp256k1'{ACurveName});
  System.Assert(curve <> Nil, 'Lcurve Cannot be Nil');

  //typeforce(types.UInt32, index)

  //var isHardened = index >= HDNode.HIGHEST_BIT
  //var data = Buffer.allocUnsafe(37)
  isHardened := index >= HIGHEST_BIT;
  //data := stringOfChar(#0,37);
  data := '';

  // Hardened child
  //if (isHardened) {
  if isHardened then begin
    //if (this.isNeutered()) throw new TypeError('Could not derive hardened child key')
    if not isPrivate then raise exception.create('Could not derive hardened child key');

    // data = 0x00 || ser256(kpar) || ser32(index)
    data := data + #$00;
    //this.keyPair.d.toBuffer(32).copy(data, 1)
    //data.writeUInt32BE(index, 33)
    data:=data + getPrivatekey;
    data:=data + uInt32BEtoBuf(index);

  end else begin
  // Normal child
  //} else {
    // data = serP(point(kpar)) || ser32(index)
    //      = serP(Kpar) || ser32(index)
    //this.keyPair.getPublicKeyBuffer().copy(data, 0)
    //data.writeUInt32BE(index, 33)
    data:=data+getPublicKey(true);
    data:=data + uInt32BEtoBuf(index);
  end;

  //var I = createHmac('sha512', this.chainCode).update(data).digest()
  //var IL = I.slice(0, 32)
  //var IR = I.slice(32)
  I:= hmac_sha512(data,chainCode);

  //if right then
  //   I:=copy(I,33,32)+copy(I,1,32);

  //var pIL = BigInteger.fromBuffer(IL)
  pIL := buf2TBigInteger(copy(I,1,32));


  /// In case parse256(IL) >= n, proceed with the next value for i
  //if (pIL.compareTo(curve.n) >= 0) {
  //  return this.derive(index + 1)
  //}                         !!
  {
  if not checkPrivKey(copy(I,1,32)) then begin
    result:=derive(index + 1);
    exit;
  end;
  }
  if (pIL.compareTo(curve.N) >= 0) then begin
    result:=derive(index + 1);
    exit;
  end;



  // Private parent key -> private child key
  //var derivedKeyPair

  //if (!this.isNeutered()) {

  if isPrivate then begin
    /// ki = parse256(IL) + kpar (mod n)
    //var ki = pIL.add(this.keyPair.d).mod(curve.n)
    //pIL:=pIL.Add(buf2TBigInteger(getPrivateKey)).&Mod(TBigInteger.Create('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',16));
    pIL:=pIL.Add(buf2TBigInteger(getPrivateKey)).&Mod(curve.N);


    /// In case ki == 0, proceed with the next value for i
    //if (ki.signum() === 0) {
    //  return this.derive(index + 1)
    //}
    if pIL.SignValue=0 then begin
      result:=derive(index + 1);
      exit;
    end;

    //derivedKeyPair = new ECPair(ki, null, {
    //  network: this.keyPair.network
    //})

    if not result.loadFromKey(tBigInteger2buf(pIL)+copy(I,33,32),fnetwork,fdepth+1,getFingerprint,findex,compressed) then
      result:=derive(index + 1);
      //result.clear;
  end else begin
  // Public parent key -> public child key
  //} else {
    /// Ki = point(parse256(IL)) + Kpar
    ///    = G*IL + Kpar
    //var Ki = curve.G.multiply(pIL).add(this.keyPair.Q)

    //denis: curve.G.multiply(pIL) is a public key, created from pIL
    Ki:= curve.G.multiply(pIL).Add(Q).Normalize();

    // In case Ki is the point at infinity, proceed with the next value for i
    //if (curve.isInfinity(Ki)) {
    //  return this.derive(index + 1)
    //}
    if Ki.IsInfinity then begin
      result:=derive(index + 1);
      exit;
    end;

    //derivedKeyPair = new ECPair(null, Ki, {
    //  network: this.keyPair.network
    //})
    if not result.loadFromKey(iecPointToBuf(Ki)+copy(I,33,32),fnetwork,fdepth+1,getFingerprint,findex,compressed) then
      result:=derive(index + 1);
//      result.clear;
  end; //}

  //var hd = new HDNode(derivedKeyPair, IR)
  //hd.depth = this.depth + 1
  //hd.index = index
  //hd.parentFingerprint = this.getFingerprint().readUInt32BE(0)


  //return hd
end;

function tHDNode.isValid:boolean;
begin
  result:=length(fData) in [64,65,96];
end;

function tHDNode.getPrivate:boolean;
begin
  result:=(length(fData)=64);
end;

procedure tHDNode.clear;
var i:integer;
begin
  if fPublicKeyCache<>nil
    then fPublicKeyCache.Detach();
  //fPublicKeyCache.XCoord:=0;
  //fPublicKeyCache.YCoord:=0;
  fdepth:=0;
  fparentFingerprint:=0;
  findex:=0;

  for i:=1 to length(fData) do fData[i]:=#0;
  fData:='';
end;

function tHDNode.loadFromKey(buf:ansistring;mnetwork:tNetworkData;mdepth:byte;mparentFingerprint:dword;mindex:dword;mcompressed:boolean=true):boolean;
begin
 result:=false;

 // if  length(buf)=64 => private : private + IR
 //    length(buf)=65 => public compressed: pub[33] + IR
 //    length(buf)=96 => public uncompressed : X[32] y[32] IR[32]

 //fPublicKeyCache.XCoord:=0;
 //fPublicKeyCache.YCoord:=0;
 if fPublicKeyCache<>nil
   then fPublicKeyCache.Detach();

 if not (length(buf) in [64,65,96]) then exit;

 if length(buf)=64 then begin
   if not checkPrivKey(copy(buf,1,32)) then exit;
   fData:=buf;
 end else begin
   //fdata:65
   fPublicKeyCache:=bufToiecPoint(copy(buf,1,length(buf)-32));
   fData:=iecPointToBuf(fPublicKeyCache,true);
 end;

 fnetwork:=mNetwork;
 fdepth:= mdepth;
 fparentFingerprint:= mparentFingerprint;
 findex:=mindex;
 compressed:=mcompressed;

 result:=true;
end;



function tHDNode.loadFromCode58(code58:ansistring;mnetwork:tNetworkData):boolean;
//HDNode.fromBase58 = function (string, networks)
var buffer:ansistring;
    Ver:dword;
    mychainCode,s:ansistring;
begin
 result:=false;
 clear;
 fnetwork:=mnetwork;
 //var buffer = base58check.decode(string)
  //if (buffer.length !== 78) throw new Error('Invalid buffer length')
 buffer:=base58tobufCheck(code58);
 if length(buffer)<>DATALENGTH then exit;

 Compressed:=true;

 // 4 bytes: version bytes
 //var version = buffer.readUInt32BE(0)
 //var network
 Ver := readUInt32BE(buffer,1);

 (*
  // list of networks?
  if (Array.isArray(networks)) {
    network = networks.filter(function (x) {
      return version === x.bip32.private ||
             version === x.bip32.public
    }).pop()

    if (!network) throw new Error('Unknown network version')

  // otherwise, assume a network object (or default to bitcoin)
  } else {
    network = networks || NETWORKS.bitcoin
  }
 *)

 // if (version !== network.bip32.private &&
 //   version !== network.bip32.public) throw new Error('Invalid network version')
 if (ver <> fnetwork.bip32.VerPrivate) and (ver <> fnetwork.bip32.VerPublic) then exit;


  // 1 byte: depth: 0x00 for master nodes, 0x01 for level-1 descendants, ...
  //var depth = buffer[4]
  fdepth := ord(buffer[5]);

  // 4 bytes: the fingerprint of the parent's key (0x00000000 if master key)
  //var parentFingerprint = buffer.readUInt32BE(5)
  //if (depth === 0) {
  //  if (parentFingerprint !== 0x00000000) throw new Error('Invalid parent fingerprint')
  //}
  fparentFingerprint := readUInt32BE(buffer,6);
  if (fdepth=0) and (fparentFingerprint<>0) then exit;

  /// 4 bytes: child number. This is the number i in xi = xpar/i, with xi the key being serialized.
  /// This is encoded in MSB order. (0x00000000 if master key)
  //var index = buffer.readUInt32BE(9)
  //if (depth === 0 && index !== 0) throw new Error('Invalid index')
  fIndex:=readUInt32BE(buffer,10);
  if (fdepth=0) and (fIndex<>0) then exit;


  /// 32 bytes: the chain code
  //var chainCode = buffer.slice(13, 45)
  //var keyPair
  mychainCode:=copy(buffer,14,32);

  /// 33 bytes: private key data (0x00 + k)
  //if (version === network.bip32.private) {
  if ver=fnetwork.bip32.VerPrivate then begin
    //if (buffer.readUInt8(45) !== 0x00) throw new Error('Invalid private key')
    if buffer[46]<>#0 then exit;

    //var d = BigInteger.fromBuffer(buffer.slice(46, 78))
    //keyPair = new ECPair(d, null, { network: network })
    s:=copy(buffer,47,32);
    if not checkPrivKey(s) then exit;
    fData:=s+mychainCode;
  end else begin
  /// 33 bytes: public key data (0x02 + X or 0x03 + X)
  //} else {
    //var Q = ecurve.Point.decodeFrom(curve, buffer.slice(45, 78))
    /// Q.compressed is assumed, if somehow this assumption is broken, `new HDNode` will throw

    fPublicKeyCache:=bufToiecPoint(copy(buffer,46,33));

    // Verify that the X coordinate in the public point corresponds to a point on the curve.
    // If not, the extended public key is invalid.
    //curve.validate(Q)
    if not fPublicKeyCache.IsValid() then exit;

    //keyPair = new ECPair(null, Q, { network: network })

    fData:=iecPointToBuf(fPublicKeyCache,true)+mychainCode;
  end;

  //var hd = new HDNode(keyPair, chainCode)
  //hd.depth = depth
  //hd.index = index
  //hd.parentFingerprint = parentFingerprint

  //return hd
  result:=true;
end;

function tHDNode.getPrivateKey:ansistring;
begin
  result:='';
  if not isPrivate then exit;
  if length(fData)<>64 then exit;
  result:=copy(fData,1,32);
end;

function tHDNode.getPublicKey(getCompressed:boolean=true):ansistring;
begin
  result:= bytes2Buf(Q.GetEncoded(getCompressed));  //iecPointToBuf(Q,getCompressed);
end;

function tHDNode.Q:IECPoint;
var
  curve: IX9ECParameters;
begin
  //if not fPublicKeyCache.IsValid() then
  if (fPublicKeyCache=nil) or fPublicKeyCache.IsValid() then
    if not isPrivate
      then raise exception.Create('tHDNode.Q: private nor publick not set')
      else begin
        curve := TCustomNamedCurves.GetByName('secp256k1'{ACurveName});
        System.Assert(curve <> Nil, 'Lcurve Cannot be Nil');
        fPublicKeyCache:= curve.G.multiply(D).Normalize();
      end;

  result:=fPublicKeyCache;

end;

function tHDNode.D:tBigInteger;
begin
  if isPrivate and (length(fData)=64) then
      result:=buf2tBigInteger(copy(fData,1,32))
  else
    raise exception.Create('tHDNode.D: not private key');
end;



function tHDNode.chainCode:ansistring;
begin
  result:='';
  if length(fData)<>64 then exit;
  result:=copy(fData,33,32);
end;

function tHDNode.asCode58:ansistring;
var buffer:ansistring;
    s:ansistring;
    ver:dword;
begin

  result:='';
  if length(fData)<>64 then exit;
  if isPrivate then
    if not checkPrivKey(copy(fData,1,32)) then exit;
  // Version
  //var network = this.keyPair.network
  //var version = (!this.isNeutered()) ? network.bip32.private : network.bip32.public
  //var buffer = Buffer.allocUnsafe(78)
  setLength(buffer,DATALENGTH);

   // 4 bytes: version bytes
  //buffer.writeUInt32BE(version, 0)
  if isPrivate then ver:=fnetwork.bip32.VerPrivate
               else ver:=fnetwork.bip32.VerPublic;
  writeUInt32BE(ver,buffer,1);

  // 1 byte: depth: 0x00 for master nodes, 0x01 for level-1 descendants, ....
  //buffer.writeUInt8(this.depth, 4)
  buffer[5]:=chr(fdepth);


  // 4 bytes: the fingerprint of the parent's key (0x00000000 if master key)
  //buffer.writeUInt32BE(this.parentFingerprint, 5)
  writeUInt32BE(fparentFingerprint,buffer,6);

  // 4 bytes: child number. This is the number i in xi = xpar/i, with xi the key being serialized.
  // This is encoded in big endian. (0x00000000 if master key)
  //buffer.writeUInt32BE(this.index, 9)
  writeUInt32BE(fIndex,buffer,10);

  // 32 bytes: the chain code
  //this.chainCode.copy(buffer, 13)
  s:=chainCode;
  if s<>'' then move(s[1],buffer[14],32)
           else exit;

  // 33 bytes: the public key or private key data
  //if (!this.isNeutered()) {
  if isPrivate then begin
    // 0x00 + k for private keys
    //buffer.writeUInt8(0, 45)
    //this.keyPair.d.toBuffer(32).copy(buffer, 46)
    buffer[46]:=#0;
    s:=getPrivateKey;
    if length(s)=32 then move(s[1],buffer[47],32)
             else exit;
  end else begin //} else {
    // 33 bytes: the public key
    // X9.62 encoding for public keys
    // this.keyPair.getPublicKeyBuffer().copy(buffer, 45)
    s:=getPublicKey;
    if length(s)=33 then move(s[1],buffer[46],33)
             else exit;
  end;

  //return base58check.encode(buffer)
  result:= buf2Base58Check(buffer);
end;



//=================================== / HD ====================================

end.

