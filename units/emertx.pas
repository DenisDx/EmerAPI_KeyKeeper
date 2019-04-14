unit EmerTX;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UOpenSSLdef, Crypto, CryptoLib4PascalConnectorUnit;


///**
// * Hash transaction for signing a specific input.
// *
// * Bitcoin uses a different hash for each signed transaction input.
// * This method copies the transaction, makes the necessary changes based on the
// * hashType, and then hashes the result.
// * This hash can then be used to sign the provided transaction input.
// */
//Transaction.prototype.hashForSignature = function (inIndex, prevOutScript, hashType)
{
  typeforce(types.tuple(types.UInt32, types.Buffer, /* types.UInt8 */ types.Number), arguments)

  // https://github.com/bitcoin/bitcoin/blob/master/src/test/sighash_tests.cpp#L29
  if (inIndex >= this.ins.length) return ONE

  // ignore OP_CODESEPARATOR
  var ourScript = bscript.compile(bscript.decompile(prevOutScript).filter(function (x) {
    return x !== opcodes.OP_CODESEPARATOR
  }))

  var txTmp = this.clone()

  // SIGHASH_NONE: ignore all outputs? (wildcard payee)
  if ((hashType & 0x1f) === Transaction.SIGHASH_NONE) {
    txTmp.outs = []

    // ignore sequence numbers (except at inIndex)
    txTmp.ins.forEach(function (input, i) {
      if (i === inIndex) return

      input.sequence = 0
    })

  // SIGHASH_SINGLE: ignore all outputs, except at the same index?
  } else if ((hashType & 0x1f) === Transaction.SIGHASH_SINGLE) {
    // https://github.com/bitcoin/bitcoin/blob/master/src/test/sighash_tests.cpp#L60
    if (inIndex >= this.outs.length) return ONE

    // truncate outputs after
    txTmp.outs.length = inIndex + 1

    // "blank" outputs before
    for (var i = 0; i < inIndex; i++) {
      txTmp.outs[i] = BLANK_OUTPUT
    }

    // ignore sequence numbers (except at inIndex)
    txTmp.ins.forEach(function (input, y) {
      if (y === inIndex) return

      input.sequence = 0
    })
  }

  // SIGHASH_ANYONECANPAY: ignore inputs entirely?
  if (hashType & Transaction.SIGHASH_ANYONECANPAY) {
    txTmp.ins = [txTmp.ins[inIndex]]
    txTmp.ins[0].script = ourScript

  // SIGHASH_ALL: only ignore input scripts
  } else {
    // "blank" others input scripts
    txTmp.ins.forEach(function (input) { input.script = EMPTY_SCRIPT })
    txTmp.ins[inIndex].script = ourScript
  }

  // serialize and hash
  var buffer = Buffer.allocUnsafe(txTmp.__byteLength(false) + 4)
  buffer.writeInt32LE(hashType, buffer.length - 4)
  txTmp.__toBuffer(buffer, 0, false)

  return bcrypto.hash256(buffer)
}

//Transaction.prototype.hashForWitnessV0 = function (inIndex, prevOutScript, value, hashType)
{
  typeforce(types.tuple(types.UInt32, types.Buffer, types.Satoshi, types.UInt32), arguments)

  var tbuffer, toffset
  function writeSlice (slice) { toffset += slice.copy(tbuffer, toffset) }
  function writeUInt32 (i) { toffset = tbuffer.writeUInt32LE(i, toffset) }
  function writeUInt64 (i) { toffset = bufferutils.writeUInt64LE(tbuffer, i, toffset) }
  function writeVarInt (i) {
    varuint.encode(i, tbuffer, toffset)
    toffset += varuint.encode.bytes
  }
  function writeVarSlice (slice) { writeVarInt(slice.length); writeSlice(slice) }

  var hashOutputs = ZERO
  var hashPrevouts = ZERO
  var hashSequence = ZERO

  if (!(hashType & Transaction.SIGHASH_ANYONECANPAY)) {
    tbuffer = Buffer.allocUnsafe(36 * this.ins.length)
    toffset = 0

    this.ins.forEach(function (txIn) {
      writeSlice(txIn.hash)
      writeUInt32(txIn.index)
    })

    hashPrevouts = bcrypto.hash256(tbuffer)
  }

  if (!(hashType & Transaction.SIGHASH_ANYONECANPAY) &&
       (hashType & 0x1f) !== Transaction.SIGHASH_SINGLE &&
       (hashType & 0x1f) !== Transaction.SIGHASH_NONE) {
    tbuffer = Buffer.allocUnsafe(4 * this.ins.length)
    toffset = 0

    this.ins.forEach(function (txIn) {
      writeUInt32(txIn.sequence)
    })

    hashSequence = bcrypto.hash256(tbuffer)
  }

  if ((hashType & 0x1f) !== Transaction.SIGHASH_SINGLE &&
      (hashType & 0x1f) !== Transaction.SIGHASH_NONE) {
    var txOutsSize = this.outs.reduce(function (sum, output) {
      return sum + 8 + varSliceSize(output.script)
    }, 0)

    tbuffer = Buffer.allocUnsafe(txOutsSize)
    toffset = 0

    this.outs.forEach(function (out) {
      writeUInt64(out.value)
      writeVarSlice(out.script)
    })

    hashOutputs = bcrypto.hash256(tbuffer)
  } else if ((hashType & 0x1f) === Transaction.SIGHASH_SINGLE && inIndex < this.outs.length) {
    var output = this.outs[inIndex]

    tbuffer = Buffer.allocUnsafe(8 + varSliceSize(output.script))
    toffset = 0
    writeUInt64(output.value)
    writeVarSlice(output.script)

    hashOutputs = bcrypto.hash256(tbuffer)
  }

  tbuffer = Buffer.allocUnsafe(156 + varSliceSize(prevOutScript))
  toffset = 0

  var input = this.ins[inIndex]
  writeUInt32(this.version)
  writeSlice(hashPrevouts)
  writeSlice(hashSequence)
  writeSlice(input.hash)
  writeUInt32(input.index)
  writeVarSlice(prevOutScript)
  writeUInt64(value)
  writeUInt32(input.sequence)
  writeSlice(hashOutputs)
  writeUInt32(this.locktime)
  writeUInt32(hashType)
  return bcrypto.hash256(tbuffer)
}

type

  //hash: readSlice(32),
  //index: readUInt32(),
  //script: readVarSlice(),
  //sequence: readUInt32(),
  //witness: EMPTY_WITNESS
  ttxin=packed record
    hash:ansistring;
    index:dword;
    script:ansistring;
    sequence:dword;
    witness: array of ansistring;
  end;

  //value: readUInt64(),
  //script: readVarSlice()
  touts=packed record
    value:qword;
    script:ansistring;
  end;

  //this.version = 0x0666
  //this.locktime = 0
  //this.time = 0
  //this.ins = []
  //this.outs = []

  ttx=packed record
        version:word; //= 0x0666
        time:cardinal;
        ins:array of ttxin;
        outs:array of touts;
        locktime:cardinal;
      end;

const
  DEFAULT_SEQUENCE = $ffffffff;
  SIGHASH_ALL = $01;
  SIGHASH_NONE = $02;
  SIGHASH_SINGLE = $03;
  SIGHASH_ANYONECANPAY = $80;
  ADVANCED_TRANSACTION_MARKER = $00;
  ADVANCED_TRANSACTION_FLAG = $01;

  EMPTY_SCRIPT : ansistring = '';
  EMPTY_WITNESS : array of ansistring = nil;

  buf_ZERO:ansistring =#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
            //Buffer.from('0000000000000000000000000000000000000000000000000000000000000000', 'hex')
  buf_ONE:ansistring =#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#1;
      //Buffer.from('0000000000000000000000000000000000000000000000000000000000000001', 'hex')

  //VALUE_UINT64_MAX:ansistring = #255#255#255#255#255#255#255#255;
  VALUE_UINT64_MAX=$ffffffffffffffff;
    //Buffer.from('ffffffffffffffff', 'hex')

      //var BLANK_OUTPUT = {
      //  script: EMPTY_SCRIPT,
      //  valueBuffer: VALUE_UINT64_MAX
      //}

  BLANK_OUTPUT:touts = (
    value:VALUE_UINT64_MAX;
    script : '';
  );
  {
            //  script: EMPTY_SCRIPT,
            //  valueBuffer: VALUE_UINT64_MAX
            //}

  type
  tNameScript=record
     TXtype:char; //51,52,53
     Name:ansistring;
     Value:ansistring;
     Days:integer;
     Owner:ansistring;
  end;

  function unpackTX(buf:ansistring):ttx;
  function packTX(tx:ttx;addWitness:boolean=true;addRedeemScriptIfNotSigned:boolean=true):ansistring;
  function scriptExplain(buf:ansistring;addID:ansistring=''):ansistring;
  function getTxHash(tx:ttx):ansistring;


  function scriptDecompile(buf:ansistring;addID:ansistring='';decodeText:boolean=false):ansistring;
  function scriptParseToList(buf:ansistring):tStringList;
  function scriptCompile(script:ansistring):ansistring;

  function nameScriptDecode(buf:ansistring):tNameScript; //Name='' for non-name


  function dupeTx(tx:ttx):ttx;
  function hashForSignature(const this:ttx; inIndex:integer; prevOutScript:ansistring; hashType:dword=SIGHASH_ALL):ansistring;
//  function hashForSignature2(this:ttx; inIndex:integer; prevOutScript:ansistring; hashType:dword):ansistring;
  function checkSignatureForTX(const buf:ansistring;const tx:ttx;vIn:integer; out HashToSign:ansistring; redeemScript:ansistring=''):boolean; overload;
  function checkSignatureForTX(const buf:ansistring;const tx:ttx;vIn:integer):boolean; overload;
  function decodeInScript(const buf:ansistring;NetId:ansistring=''):ansistring;
  function getInScriptAddress(const buf:ansistring):ansistring;
  function isOutputScript(buf:ansistring):boolean;

  function winTimeToUnixTime(t:tDatetime):qword;
  function unixTimeToWinTime(t:qword):tDatetime;

  function decodeHRtext(s:ansistring):ansistring;

  function readNameScriptData(const buf:ansistring; var position:integer):ansistring;
  function readScriptData(const buf:ansistring; var position:integer):ansistring;
  function writeNameData(const buf:ansistring):ansistring;  // split value in 520 bytes chunks and add it to script
  function writeScriptData(const buf:ansistring):ansistring;
  function writeScriptVarInt(x:qword):ansistring;
  function writeScriptIntBuf(x:int64):ansistring; //writes varInt length + int as buf

  function uInt32BEtoBuf(x:dword):ansistring;
  function uInt32LEtoBuf(x:dword):ansistring;
  procedure writeUInt32BE(x:dword;var buf:ansistring;position:integer);
  procedure writeUInt32LE(x:dword;var buf:ansistring;position:integer);

  function readUInt32BE(buf:ansistring;position:integer):dword;
  function readUInt32LE(buf:ansistring;position:integer):dword;



  function signTxIn(this:ttx;vin:integer; privKey:ansistring; ppubKey:PECDSA_Public=nil; redeemScript:ansistring='';hashType:dword=0; witnessValue:qword=VALUE_UINT64_MAX; witnessScript:ansistring='';keyCompressed:boolean=true):ansistring;

  function scriptDataBufToText(buf:ansistring;decodeText:boolean=false):ansistring;

  var
    opcodes :tStringList;

  function opNum(opcode:ansistring):ansichar;


implementation

uses USha256, UOpenSSL, PodbiralkaUnit
  ,fpjson, jsonparser
  ,EmerApiTestUnit
  ,EmerAPIDebugConsoleUnit{debug};

function scriptDataBufToText(buf:ansistring;decodeText:boolean=false):ansistring;
var i,n:integer;
const symbols  = [' ','!','@','$','%','^','&','*','(',')','-','_','=','+','"',';',':','\','|','/','?','.',',','>','<','~','''','{','}','[',']','a'..'z','A'..'Z','0'..'9'{,#10,#13}]; //'A'..'Я','а'..'я',
begin
  if decodeText then begin
    n:=0;
    for i:=1 to length(buf) do if not (buf[i] in (symbols + [#10,#13])) then inc(n);

    if (length(buf)>1) and (n/length(buf)<0.3) then begin
      result:='';
      for i:=1 to length(buf) do
        if buf[i] in symbols
            then result:=result + buf[i]
            else result:=result + '#'+inttohex(ord(buf[i]),2);
      result:='`'+result+'`';
    end else result:='['+bufToHex(buf)+']';
  end else
    result:='['+bufToHex(buf)+']';
end;


function opNum(opcode:ansistring):ansichar;
var n:integer;
begin
 result:=#0;
 n:=opcodes.IndexOf(ansiUpperCase(trim(opcode)));
 if n>=0 then result:=char(integer(pointer(opcodes.Objects[n])));

end;

function unixTimeToWinTime(t:qword):tDatetime;
//const UNIX_TIME_START:qword = $019DB1DED53E8000; //January 1, 1970 (start of Unix epoch) in "ticks"
//const TICKS_PER_SECOND = 10000000; //a tick is 100ns
//const TICKS_PER_DAY = TICKS_PER_SECOND*60*60*24;
const
  TICKS_PER_SECOND = 1;
  UNIX_TICKS_PER_DAY = TICKS_PER_SECOND * 60 * 60 * 24;
  UNIX_ZEDO_DATE = 25569;

begin
 result:=UNIX_ZEDO_DATE + t/UNIX_TICKS_PER_DAY;
end;

function winTimeToUnixTime(t:tDatetime):qword;
  //const UNIX_TIME_START:qword = $019DB1DED53E8000; //January 1, 1970 (start of Unix epoch) in "ticks"
//  const TICKS_PER_SECOND = 10000000; //a tick is 100ns
const TICKS_PER_SECOND = 1;
//  const TICKS_PER_DAY = TICKS_PER_SECOND*60*60*24;
const
  UNIX_TICKS_PER_DAY = TICKS_PER_SECOND * 60 * 60 * 24;
  UNIX_ZEDO_DATE = 25569;
begin
    //Convert ticks since 1/1/1970 into seconds
   //return (li.QuadPart - UNIX_TIME_START) / TICKS_PER_SECOND;
   result:=trunc((t - UNIX_ZEDO_DATE)*UNIX_TICKS_PER_DAY);
end;

function checkSignatureForTX(const buf:ansistring;const tx:ttx;vIn:integer):boolean;
var hfs:ansistring;
begin
  result:=checkSignatureForTX(buf,tx,vIn,hfs)
end;

function checkSignatureForTX(const buf:ansistring;const tx:ttx;vIn:integer; out HashToSign:ansistring; redeemScript:ansistring=''):boolean;
var c:integer;
    n:integer;
    pos:integer;
    sig,key,sigb,r,s:ansistring;
    pubKey:TECDSA_Public;
    len,pos1:integer;
    Signature: TECDSA_SIG;
    digest: AnsiString;
    hashType:byte;
    {redeemScript,}tmp:AnsiString;
begin
  HashToSign:='';

  Signature.r:='';
  Signature.s:='';

  result:=false;

  if buf='' then exit;

  hashType:=0;

  pos:=1;
  sig:=readScriptData(buf,pos);

  key:='';
  if pos<length(buf) then key:=readScriptData(buf,pos);

  tmp:=sig;
  if (length(sig)<7) then exit else begin
    if sig[1] <> chr($30) then exit;

    pos1:=2;
    sigb:=readScriptData(sig,pos1);
    if (pos1<>length(sig)) or (length(sigb)<4) then exit
    else begin
      //sigb=<integer = 0x02><len_r><r_value><integer 0x02><len_s><s_value>
      pos1:=1;

      if sigb[pos1]<>#02 then exit; inc(pos1);
      r:=readScriptData(sigb,pos1);

      if pos1>=(length(sigb)-1) then  exit;

      if sigb[pos1]<>#02 then exit; inc(pos1);
      s:=readScriptData(sigb,pos1);

      if pos1<>(length(sigb)+1) then  exit;

      if copy(r,1,1)=#0 then delete(r,1,1);

      Signature.r:=r;
      Signature.s:=s;
    end;

    hashType:=ord(sig[length(sig)]);
    if (sig[length(sig)]<>chr(SIGHASH_ALL)) then
      exit;
  end;




  //key info
  if key='' then exit;

  pubKey:=bufToPubKey(key);
  if not(IsValidPublicKey(pubKey)) then exit;


  //check signature
  if redeemScript='' then
    redeemScript:= #118#169 + writeScriptData(DoRipeMD160(DoSha256(pubKeyToBuf(PubKey)))) + #136#172 ;  //OP_DUP OP_HASH160 [address] OP_EQUALVERIFY OP_CHECKSIG

  digest:=hashForSignature(tx,vIn,redeemScript,hashType);
  HashToSign:=digest;
  //unit1.Form1.Memo1.lines.Append('checkSignatureForTX digest='+bufToHex(digest));
  //unit1.Form1.Memo1.lines.Append('checkSignatureForTX sig=(r:'+bufToHex(Signature.r)+' s='+bufToHex(Signature.s)+')');
  //unit1.Form1.Memo1.lines.Append('checkSignatureForTX PubKey='+bufToHex(pubKeyToBuf(PubKey))+'');

  //result:= ECDSAVerify(PubKey,digest,Signature);

  delete(tmp,length(tmp),1); //cut hashType
 // delete(tmp,length(tmp),1); //cut again?!?
  //tmp:=tmp+#0;

  result:= ECDSAVerify(
     //tmpTECDSA_Public_2_IECPublicKeyParameters(@PubKey)
     tmpTECDSA_Public_2_IECPublicKeyParameters(key)
    ,digest,

    tmp
    //tmpTECDSA_SIG_2_Signature(@Signature)

    );


end;

function getInScriptAddress(const buf:ansistring):ansistring;
var NameScript:tNameScript;
begin
  result:='';
  if (length(buf)<24) then exit;

  if (length(buf)>2) and (copy(buf,length(buf)-1,2)<>#$88#$ac) then exit;

  NameScript:=nameScriptDecode(buf);

  result:=NameScript.Owner;
end;

function isOutputScript(buf:ansistring):boolean;
var pos:integer;
    s:ansistring;
begin
  //not a signature
  result:=(length(buf)>2) and (copy(buf,length(buf)-1,2)=#$88#$ac);
  if result then exit;
  //is it valid-structure signature?
  //signature is two buffers.
  if length(buf)<40 then exit; //too short
  if ord(buf[1])>81 then exit; //opcode found

  pos:=1;
  s:=readScriptData(buf,pos);
  if length(s)<7 then exit;

  if pos>=length(buf) then exit;
  if ord(buf[pos])>81 then exit; //opcode found

  s:=readScriptData(buf,pos);
  if length(buf)<33 then exit;
  if pos<>length(buf)+1 then exit;

  //valid signature structure
  result:=false;
end;

function decodeInScript(const buf:ansistring;NetId:ansistring=''):ansistring;
var c:integer;
    n:integer;
    pos:integer;
    sig,key,sigb,r,s:ansistring;
    pubKey:TECDSA_Public;
    len,pos1:integer;
    Signature: TECDSA_SIG;
    digest: AnsiString;
    hashType:byte;
begin

  if isOutputScript(buf) then begin
    result:='NOT SIGNED (scriptPubKey)';
    exit;
  end;

  // DER signature
  //https://bitcointalk.org/index.php?topic=653313.0

 //<Len_sig><sequence = 0x30><len_rs><integer = 0x02><len_r><r_value><integer 0x02><len_s><s_value><sighash>
{
All elements are 1 byte except r & s which will be 32 or 33 bytes.  Also be sure to read up carefully on sighash because it is "moved" (for reasons that are beyond me).  Another Satoshi-ism I guess.

r_value = Convert r into a little endian byte array.  If the leading bit is not zero then prepend a zero value byte.
s_value = Convert s into a little endian byte array.  If the leading bit is not zero then prepend a zero value byte.
r_len = number of bytes for  r (always 20 or 21)
s_len = number of bytes for s (always 20 or 21)
sequence = always 0x30
integer = always 0x02
len_rs = r_len + s_len + 2 (two extra bytes for the two integer bytes)
len_sig = len_rs + 3 (three extra bytes for the len_rs byte, the sequence byte and the sighash byte

What follows next is whatever is needed to complete the script which is encumbering the outputs.  The PubKey then follows when redeeming Pay2PubKeyHash outputs but is not universally present in other output types (i.e. Pay2PubKey).
}


  result:='';


  Signature.r:='';
  Signature.s:='';

  if buf='' then exit;

  hashType:=0;

  pos:=1;
  sig:=readScriptData(buf,pos);

  key:='';
  if pos<length(buf) then key:=readScriptData(buf,pos);


  //show signature
  //<Len_sig><sequence = 0x30><len_rs><integer = 0x02><len_r><r_value><integer 0x02><len_s><s_value><sighash>
  {
    48
    ECDSA Signature (X.690 DER-encoded):
        ASN.1 tag identifier (20h = constructed + 10h = SEQUENCE and SEQUENCE OF):
        30
        DER length octet, definite short form (45h = 69 bytes) (Signature r+s length)
        45
        ASN.1[/url] tag identifier (02 = INTEGER):
        02
         Signature r length (DER length octet):
         20
         Signature r (unsigned binary int, big-endian):
         263325fcbd579f5a3d0c49aa96538d9562ee41dc690d50dcc5a0af4ba2b9efcf
        ASN.1[/url] tag identifier (02 = INTEGER):
        02
         Signature s length (DER length octet):
         21
         Signature s (first byte is 00 pad to protect MSB 1 unsigned int):
         00fd8d53c6be9b3f68c74eed559cca314e718df437b5c5c57668c5930e14140502
    Signature end byte (SIGHASH_ALL):
    01 }
  if (length(sig)<7) then result:=result+' INCORRECT SIGNATURE: ['+bufToHex(sig)+']' else begin
    if sig[1] = chr($30)
        then result:=' tag:[30]'
        else result:=' WRONG tag:['+inttoHex(ord(sig[1]),2)+']';

    pos1:=2;
    sigb:=readScriptData(sig,pos1);
    if (pos1<>length(sig)) or (length(sigb)<4) then result:=' WRONG_SIG_LEN'
    else begin
      //sigb=<integer = 0x02><len_r><r_value><integer 0x02><len_s><s_value>
      pos1:=1;

      if sigb[pos1]<>#02 then result:=result + ' WRONG R TAG '; inc(pos1);
      r:=readScriptData(sigb,pos1);
      result:=result+' r='+bufToHex(r);
      if pos1>=(length(sigb)-1) then  result:=result + ' WRONG R DATA ';

      if sigb[pos1]<>#02 then result:=result + ' WRONG S TAG '; inc(pos1);
      s:=readScriptData(sigb,pos1);
      result:=result+' s='+bufToHex(s);
      if pos1<>(length(sigb)+1) then  result:=result + ' WRONG  DATA ';

      Signature.r:=r;
      Signature.s:=s;
    end;

    hashType:=ord(sig[length(sig)]);
    if (sig[length(sig)]<>chr(SIGHASH_ALL)) then
      result:=result+' WRONG TYPE:['+inttoHex(ord(sig[length(sig)]),2)+']'
    else
      result:=result+' Type=SIGHASH_ALL'
  end;




  //key info
  if key<>'' then begin
    result:=result + ' PubKey: '+bufToHex(key);

    pubKey:=bufToPubKey(key);
    if IsValidPublicKey(pubKey) then begin
        if length(NetId)>0 then
          // result:=result + ' <'+publicKey2Address(pubKey,NetId[1],length(key)=33)+'>'
            result:=result + ' <'+ buf2Base58Check(NetID+DoRipeMD160(DoSha256(key)))+'>'


        else
          result:=result + ' (choose NetID for show the address)'

          {
        hashForSignature(this, vin, txID, hashType);

        digest:=hashForSignature
        if ECDSAVerify(PubKey: TECDSA_Public; const digest: AnsiString; Signature: TECDSA_SIG)
           then result:='=correct= '
           else result:='=INCORRECT= '
           }

    end else
      result:=result + ' (INCORRECT)'


  end;



{
  sig



  if
  result:=result+
  }
 {

  c:=1;

  //sign + type (last byte)
  n:=ord(s[c]);
///  if(c+n)>(length(s)) then begin result:='wrong length'; exit; end;
  c:=c+1;
  result:=result+'signature type '+inttostr(ord(s[c+n-1]))+'= '+bufToHex(copy(s,c,n-1))+'; ';
  c:=c+n;

  if c<=length(s) then begin
    n:=ord(s[c]);
    ///if(c+n)>(length(s)-1) then begin result:='wrong length'; exit; end;
    c:=c+1;
    result:=result+' to address [' +bufToHex(copy(s,c,n))+'];';
    c:=c+n;

    //n:=ord(s[c]);
    //c:=c+1;
    //result:=result+inttostr(n);

    ///if c<>length(s) then result:=result+' WRONG SCRIPT LEN!';

  end;
  }
  result:=trim(result);
end;

function signTxIn(this:ttx;vin:integer; privKey:ansistring; ppubKey:PECDSA_Public=nil; redeemScript:ansistring='';hashType:dword=0; witnessValue:qword=VALUE_UINT64_MAX; witnessScript:ansistring='';keyCompressed:boolean=true):ansistring;
//send 0 pubKey for calculate
var
  input:ttxin;

  //function canSign (input)
  {
    return input.prevOutScript !== undefined &&
      input.signScript !== undefined &&
      input.pubKeys !== undefined &&
      input.signatures !== undefined &&
      input.signatures.length === input.pubKeys.length &&
      input.pubKeys.length > 0 &&
      (
        input.witness === false ||
        (input.witness === true && input.value !== undefined)
      )
  }
  //function canSign (input:ttxin):boolean;
  //begin

  //end;

var signatureHash:ansistring;
    kpPubKey:ansistring;
    sig:TECDSA_SIG;
    s:ansistring;
    pubKey:TECDSA_Public;
    i:integer;
begin
//check for pubKey
 if (ppubKey=nil) or ((ppubKey^.x='') or (ppubKey^.y=''))
   then pubkey:=GetPublicKey(privKey)
   else pubkey:=ppubKey^;


 if length(this.ins)<=vin then  raise exception.create('signIn: No input at index: ' + inttostr(vin));

 hashType := hashType or SIGHASH_ALL;

 input := this.ins[vin];

 // if redeemScript was previously provided, enforce consistency
 //if (input.redeemScript !== undefined &&
 //    redeemScript &&
 //    !input.redeemScript.equals(redeemScript)) {
 //  throw new Error('Inconsistent redeemScript')
 //}

 //var kpPubKey = keyPair.publicKey || keyPair.getPublicKeyBuffer()
 kpPubKey := pubKeyToBuf(pubKey,keyCompressed);

 //if (!canSign(input))
 {
   if (witnessValue !== undefined) {
     if (input.value !== undefined && input.value !== witnessValue) throw new Error('Input didn\'t match witnessValue')
     typeforce(types.Satoshi, witnessValue)
     input.value = witnessValue
   }

   if (!canSign(input)) prepareInput(input, kpPubKey, redeemScript, witnessValue, witnessScript)
   if (!canSign(input)) throw Error(input.prevOutType + ' not supported')
 }



 if trim(redeemScript)='' then //Build standard redeem script to out key: use compression
   redeemScript:= #118#169 + writeScriptData(DoRipeMD160(DoSha256(kpPubKey))) + #136#172 ;  //OP_DUP OP_HASH160 [address] OP_EQUALVERIFY OP_CHECKSIG
 // ready to sign

 if (length(input.witness)>0) then begin
   //signatureHash = this.tx.hashForWitnessV0(this, vin, input.signScript, input.value, hashType)
 end else begin
   //signatureHash = hashForSignature(this, vin, input.signScript, hashType)
     signatureHash := hashForSignature(this, vin, redeemScript, hashType);
 end;

  if (length(kpPubKey) <> 33)
       //and  (input.signType = scriptTypes.P2WPKH)
      then raise exception.Create('signIn: BIP143 rejects uncompressed public keys in P2WPKH or P2WSH');



//  result:=signatureHash;

  //ECDSASign(key.PrivateKey, GetDigestToSign(current_protocol));

  //unit1.Form1.Memo1.lines.Append('                       signTxIn digest='+bufToHex(signatureHash));

  {!!!  NEW
  i:=0;
  repeat
    sig:=ECDSASign(privKey, signatureHash);
  until (i>1000) or ((ord(sig.r[1]) and $80)=0) and ((ord(sig.s[1]) and $80)=0);

  s:=EncodeSignature(sig,hashType);
  !!!}
  //s:=ECDSASign(BigNum_2_IECPrivateKeyParameters(bignumToBuf(EC_KEY_get0_private_key(privKey))), signatureHash) + chr(hashType);
  s:=ECDSASign(privKey, signatureHash) + chr(hashType);

  //unit1.Form1.Memo1.lines.Append('                       signTxIn sig=(r:'+bufToHex(sig.r)+' s='+bufToHex(sig.s)+')');

  //unit1.Form1.Memo1.lines.Append('                       signTxIn PubKey='+bufToHex(pubKeyToBuf(PubKey))+'');
  //toScriptSignature(,hashType);

  //Add SigVer =1
  // s:=s+chr(1);  ADDED

  //Add pubkey
  result:=writeScriptData(s) + writeScriptData(kpPubKey);




  //var signature = keyPair.sign(signatureHash)
  // if (Buffer.isBuffer(signature)) signature = ECSignature.fromRSBuffer(signature)

  // input.signatures[i] = signature.toScriptSignature(hashType)
  // return true



 // enforce in order signing of public keys
 (*
 var signed = input.pubKeys.some(function (pubKey, i)
 {
   if (!kpPubKey.equals(pubKey)) return false
   if (input.signatures[i]) throw new Error('Signature already exists')
   if (kpPubKey.length !== 33 &&
     input.signType === scriptTypes.P2WPKH) throw new Error('BIP143 rejects uncompressed public keys in P2WPKH or P2WSH')

   var signature = keyPair.sign(signatureHash)
   if (Buffer.isBuffer(signature)) signature = ECSignature.fromRSBuffer(signature)

   input.signatures[i] = signature.toScriptSignature(hashType)
   return true
 })
 *)
 //if (!signed) throw new Error('Key pair cannot sign for this input')

end;

function signTX(tx:ttx):ttx;
begin
    //  перед подписыванием мы сначала считаем вот такой хэш:
    //  https://github.com/emercoin/emercoin/blob/master/src/script/interpreter.cpp#L1180
    //и вот в этой функции мы делаем подпись с этим хэшем
    //https://github.com/emercoin/emercoin/blob/master/src/script/sign.cpp#L23

    //вот самое важное:
    //  uint256 hash = SignatureHash(scriptCode, *txTo, nIn, nHashType, amount, sigversion);
    //  if (!key.Sign(hash, vchSig))
   //      return false;

    //что касается деталей функции Sign(), то это помоему вызов к какой-то стандартной OpenSSL функции



  (*
    TransactionBuilder.prototype.sign = function (vin, keyPair, redeemScript, hashType, witnessValue, witnessScript) {
      // TODO: remove keyPair.network matching in 4.0.0
      if (keyPair.network && keyPair.network !== this.network) throw new TypeError('Inconsistent network')
      if (!this.inputs[vin]) throw new Error('No input at index: ' + vin)
      hashType = hashType || Transaction.SIGHASH_ALL

      var input = this.inputs[vin]

      // if redeemScript was previously provided, enforce consistency
      if (input.redeemScript !== undefined &&
          redeemScript &&
          !input.redeemScript.equals(redeemScript)) {
        throw new Error('Inconsistent redeemScript')
      }

      var kpPubKey = keyPair.publicKey || keyPair.getPublicKeyBuffer()
      if (!canSign(input)) {
        if (witnessValue !== undefined) {
          if (input.value !== undefined && input.value !== witnessValue) throw new Error('Input didn\'t match witnessValue')
          typeforce(types.Satoshi, witnessValue)
          input.value = witnessValue
        }

        if (!canSign(input)) prepareInput(input, kpPubKey, redeemScript, witnessValue, witnessScript)
        if (!canSign(input)) throw Error(input.prevOutType + ' not supported')
      }

      // ready to sign
      var signatureHash
      if (input.witness) {
        signatureHash = this.tx.hashForWitnessV0(vin, input.signScript, input.value, hashType)
      } else {
        signatureHash = this.tx.hashForSignature(vin, input.signScript, hashType)
      }

      // enforce in order signing of public keys
      var signed = input.pubKeys.some(function (pubKey, i) {
        if (!kpPubKey.equals(pubKey)) return false
        if (input.signatures[i]) throw new Error('Signature already exists')
        if (kpPubKey.length !== 33 &&
          input.signType === scriptTypes.P2WPKH) throw new Error('BIP143 rejects uncompressed public keys in P2WPKH or P2WSH')

        var signature = keyPair.sign(signatureHash)
        if (Buffer.isBuffer(signature)) signature = ECSignature.fromRSBuffer(signature)

        input.signatures[i] = signature.toScriptSignature(hashType)
        return true
      })

      if (!signed) throw new Error('Key pair cannot sign for this input')
    }

    *)
        (*
    45d7ff7cb349f57a926fa12d3846b5c08ccbed851c37adf2c8cffbf264c330c6

    scriptCode "v\251\024\326\375\002\211\354S,J=_\005t\206\337\212!y\033s\313\210\254\177\000",
    _size = 25,

    tx:
    nVersion = 2,
    nTime = 1537334145,


    (gdb) p txTmp
    $13 = {
      txTo = @0x7fffde7ebd00,
      scriptCode = @0x7fffde7e8768,
      nIn = 0,
      fAnyoneCanPay = false,
      fHashSingle = false,
      fHashNone = false
    }

    ////////////////////////////
    Empty hash "65929515b933068ef998108a114ba4251c60d454a089db33eadd90aaefaef4bc"
     _data = "\000\000\000\000\000\000\000@\000\000\000\000\000\000\000P\325\340\n\b\000\000"
     000000000000005000000000000000P\325\340\n\b\000\000


     "\242\020|S\357\033\210\062\317\016\001_N\357\234+\250w.\266]\366\370\367\361\272\254\004Q7\200~\200", '\000' <repeats 29 times>, "\001",


     результат после транзакции 794350888f55c8bf07f1ad589fc45dfd97420affa73f7d0fdbe99d8769e534ea
     *)
 (*
  createrawtransaction [{"txid":"id","vout":n},...] {"address":amount,"data":"hex",...} ( locktime )
  createrawtransaction "[{\"txid\":\"myid\",\"vout\":0}]" "{\"data\":\"00010203\"}"

  Arguments:
  1. "inputs"                (array, required) A json array of json objects
       [
         {
           "txid":"id",    (string, required) The transaction id
           "vout":n,         (numeric, required) The output number
           "sequence":n      (numeric, optional) The sequence number
         }
         ,...
       ]
  2. "outputs"               (object, required) a json object with outputs
      {
        "address": x.xxx,    (numeric or string, required) The key is the emercoin address, the numeric value (can be string) is the EMC amount
        "data": "hex"      (string, required) The key is "data", the value is hex encoded data
        ,...
      }
  3. locktime                  (numeric, optional, default=0) Raw locktime. Non-0 value also locktime-activates inputs


  createrawtransaction "[{\"txid\":\"myid\",\"vout\":0}]" "{\"data\":\"00010203\"}"


  Вход:
  d4690c5a08fcd04571c78269e150f227c2c86e097fc839868aed29abe586c68e   #0
  {
       "value": 1.000000,
       "n": 0,
       "scriptPubKey": {
         "asm": "OP_DUP OP_HASH160 649e41b014a856eb56af9098696e8aaf5904b103 OP_EQUALVERIFY OP_CHECKSIG",
         "hex": "76a914649e41b014a856eb56af9098696e8aaf5904b10388ac",
         "reqSigs": 1,
         "type": "pubkeyhash",
         "addresses": [
           "mpgyT6deSNSPNc1kmySvEiSHryfdzNGJ7c"
         ]
       }
     }
  //tx:  0200000041ffa15b011250af8fc1e02d18ec555b4c53e5da9cd7ccce438dd51a344c1b8604b5bc5058010000006b483045022100b8e0d27ca65693a3a423402da2f48cb7ac03504ad9f52cf4a6dda0dbfd7e902a0220409b41f42b2f862545783cbc14805e2d78169a16a3b3cf3a894c6ff853ee255f012102bb23560e0a1257ac6bd85b7ae1432d8301379c7398741b7d3b95ab6bf11707f4feffffff0240420f00000000001976a914649e41b014a856eb56af9098696e8aaf5904b10388ac6860b1b2000000001976a914ae68349c4e1efd1970ecf44a7e2b84d9d303af9788aca94c0000


  createrawtransaction [{"txid":"id","vout":n},...] {"address":amount,"data":"hex",...} ( locktime )
  createrawtransaction "[{\"txid\":\"myid\",\"vout\":0}]" "{\"address\":0.01}"

//
  createrawtransaction "[{\"txid\":\"d4690c5a08fcd04571c78269e150f227c2c86e097fc839868aed29abe586c68e\",\"vout\":0}]" "{\"mpgyT6deSNSPNc1kmySvEiSHryfdzNGJ7c\":0.9999}" 0
    >>020000005601a25b018ec686e5ab29ed8a8639c87f096ec8c227f250e16982c77145d0fc085a0c69d40000000000ffffffff01dc410f00000000001976a914649e41b014a856eb56af9098696e8aaf5904b10388ac00000000
  signrawtransaction 020000005601a25b018ec686e5ab29ed8a8639c87f096ec8c227f250e16982c77145d0fc085a0c69d40000000000ffffffff01dc410f00000000001976a914649e41b014a856eb56af9098696e8aaf5904b10388ac00000000
  >>020000005601a25b018ec686e5ab29ed8a8639c87f096ec8c227f250e16982c77145d0fc085a0c69d4000000006b4830450221009984b8e5089ff3bf457e048f84747e7cb06ab240cba4cd6d0601ad3d0d5f6eab022001fd13c70ce24d142ab4bd17aad260644b2eb8b0ac7c56c8b46753e532a28a80012102d873e50696be65983a1058a92fbc69fbb7763ddf4471ef8da9d52c5f347f9fd1ffffffff01dc410f00000000001976a914649e41b014a856eb56af9098696e8aaf5904b10388ac00000000
    020000005601a25b01d4690c5a08fcd04571c78269e150f227c2c86e097fc839868aed29abe586c68e000000006a473044022060d29152dbdd1da4dc74587ca135453fa5e5c1f9bd32ec6297be7da8da82204f02201426889a29095ddc805d58e8a4ff56733f7c703bf6bdb3f64b81c6800b1672e9012102d873e50696be65983a1058a92fbc69fbb7763ddf4471ef8da9d52c5f347f9fd1ffffffff01dc410f00000000001976a914649e41b014a856eb56af9098696e8aaf5904b10388ac00000000

  JS:
  TX:
  js:tx:BFS:020000005601a25b018ec686e5ab29ed8a8639c87f096ec8c227f250e16982c77145d0fc085a0c69d40000000000ffffffff01dc410f00000000001976a914649e41b014a856eb56af9098696e8aaf5904b10388ac0000000001000000
  hashForSignature(0) = d49e6a5161685cc950b2c44f45e9b1890d575a4ca0de2a6cefd75fc510523e8f
  manual tx:
  js:ma:BFS:020000005601a25b01d4690c5a08fcd04571c78269e150f227c2c86e097fc839868aed29abe586c68e000000001976a914649e41b014a856eb56af9098696e8aaf5904b10388acffffffff01dc410f00000000001976a914649e41b014a856eb56af9098696e8aaf5904b10388ac0000000001000000

  pas:
 soft: 0 tx
  pasca:ВFS=020000005601A25B018EC686E5AB29ED8A8639C87F096EC8C227F250E16982C77145D0FC085A0C69D400000000201F690C5A08FCD04571C78269E150F227C2C86E097FC839868AED29ABE586C68EFFFFFFFF01DC410F00000000001976A914649E41B014A856EB56AF9098696E8AAF5904B10388AC0000000000000001
  HFS=D2FFC0C7E84F18CC345F85D7BA3FA3F78469FC7814C669BA5BCE02838D0234EC

 js:tx:BFS:020000005601a25b01 8ec686e5ab29ed8a8639c87f096ec8c227f250e16982c77145d0fc085a0c69d4 00000000 00                                                                 ffffffff01dc410f00000000001976a914649e41b014a856eb56af9098696e8aaf5904b10388ac 00000000 01000000
 js:ma:BFS:020000005601a25b01 d4690c5a08fcd04571c78269e150f227c2c86e097fc839868aed29abe586c68e 00000000 1976a914649e41b014a856eb56af9098696e8aaf5904b10388ac               ffffffff01dc410f00000000001976a914649e41b014a856eb56af9098696e8aaf5904b10388ac 00000000 01000000
 pasca:ВFS=020000005601A25B01 8EC686E5AB29ED8A8639C87F096EC8C227F250E16982C77145D0FC085A0C69D4 00000000 201F690C5A08FCD04571C78269E150F227C2C86E097FC839868AED29ABE586C68E FFFFFFFF01DC410F00000000001976A914649E41B014A856EB56AF9098696E8AAF5904B10388AC 00000000 00000001


*)
end;



{
function writeScriptInt(n:dword):ansistring;
begin
  dsfsdf
   result:=inttohex(n,4);
   if copy(result,1,2)<>'00'
     then result:=hexToBuf(copy(result,3,2)+copy(result,1,2))
     else result:=hexToBuf(copy(result,3,2));
   result:=writeScriptData(result);

end;
}

function writeScriptUInt64(x:UInt64):ansistring; begin
  setLength(result,8);
  Move(x,result[1],8);
end;

function readUInt32BE(buf:ansistring;position:integer):dword;
begin
 result:=swapEndian(readUInt32LE(buf,position));
end;

function readUInt32LE(buf:ansistring;position:integer):dword;
begin
  move(buf[position],result,4);
end;


function uInt32BEtoBuf(x:dword):ansistring;
begin
  setLength(result,4);
  writeUInt32BE(x,result,1);
end;

function uInt32LEtoBuf(x:dword):ansistring;
begin
 setLength(result,4);
 writeUInt32LE(x,result,1);
end;

procedure writeUInt32BE(x:dword;var buf:ansistring;position:integer);
begin
  x:=SwapEndian(x);
  move(x,buf[position],4);
end;

procedure writeUInt32LE(x:dword;var buf:ansistring;position:integer);
begin
 //SwapEndian(x);
 move(x,buf[position],4);
end;


function writeScriptVarInt(x:qword):ansistring;
var n:byte;
begin
 result:='';
 if x<$fd then begin
   result:=result+chr(x);
 end else if x<$010000 then begin
   //2 byte
   result:=result+chr($FD)
   + chr(x mod $100) + chr(x div $100);
 end else if x<$0100000000 then begin
   //4 byte
   result:=result+chr($FE); //Yes, I know what 'for' means
   result:=result + chr(x mod $100); x:=x shr 8;
   result:=result + chr(x mod $100); x:=x shr 8;
   result:=result + chr(x mod $100); x:=x shr 8;
   result:=result + chr(x mod $100);
 end else begin
   //8 byte
   result:=result+chr($FF);
   x:=SwapEndian(x);
   result:=result+writeScriptUInt64(x);
 end;
end;

{
static std::vector<unsigned char> serialize(const int64_t& value)

        if(value == 0)
            return std::vector<unsigned char>();

        std::vector<unsigned char> result;
        const bool neg = value < 0;
        uint64_t absvalue = neg ? -value : value;

        while(absvalue)
        {
            result.push_back(absvalue & 0xff);
            absvalue >>= 8;
        }

//    - If the most significant byte is >= 0x80 and the value is positive, push a
//    new zero-byte to make the significant byte < 0x80 again.

//    - If the most significant byte is >= 0x80 and the value is negative, push a
//    new 0x80 byte that will be popped off when converting to an integral.

//    - If the most significant byte is < 0x80 and the value is negative, add
//    0x80 to it, since it will be subtracted and interpreted as a negative when
//    converting to an integral.

        if (result.back() & 0x80)
            result.push_back(neg ? 0x80 : 0);
        else if (neg)
            result.back() |= 0x80;

        return result;
    }

function ScriptSerialize(value:int64):ansistring;
var neg:boolean;
begin
 if value=0 then begin
   result:=#0;
   exit;
 end;

 result:='';
 neg:=value<0;
 if neg then value:=-value;
 while value>0 do begin
    result:=result + chr(value and $FF);
    value:=value shr 8;
 end;
 //    - If the most significant byte is >= 0x80 and the value is positive, push a
 //    new zero-byte to make the significant byte < 0x80 again.

 //    - If the most significant byte is >= 0x80 and the value is negative, push a
 //    new 0x80 byte that will be popped off when converting to an integral.

 //    - If the most significant byte is < 0x80 and the value is negative, add
 //    0x80 to it, since it will be subtracted and interpreted as a negative when
 //    converting to an integral.

 if ord(result[length(result)])>=$80
    then if neg then result:=result + #$80 else result:=result + #$0
    else if neg then result[length(result)]:=chr(ord(result[length(result)]) or $80);
end;

function writeScriptIntBuf(x:int64):ansistring; //writes varInt length + int as buf
var i:integer;
begin
 {setLength(result,8);
 //x:=swapEndian(x);
 move(x,result[1],8);
 i:=length(result)-1;
 while (i>1) and (result[i]=#0) do dec(i);
 setLength(result,i);
 }
 result:=ScriptSerialize(x);
 result:=writeScriptVarInt(length(result)) + result;

end;

function writeScriptData(const buf:ansistring):ansistring;
//CScript& operator<<(const std::vector<unsigned char>& b)
var n:dword;
begin
  //if (b.size() < OP_PUSHDATA1)
  result:='';
  if length(buf)<ord(opNum('OP_PUSHDATA1')) then
    result:=chr(length(buf))+buf
  else if length(buf)<=$ff then
    result:=opNum('OP_PUSHDATA1')+chr(length(buf))+buf
  else if length(buf)<=$ffff then //LE
    result:=opNum('OP_PUSHDATA2')+chr(length(buf) mod $100) + chr(length(buf) div $100)+buf
  else
    result:=opNum('OP_PUSHDATA4')
      + chr(length(buf) mod $100)
      + chr((length(buf) mod $10000) div $100)
      + chr((length(buf) mod $1000000) div $10000)
      + chr(length(buf) div $1000000)
      + buf
  ;
 (*
        {
            insert(end(), (unsigned char)b.size());
        }
        else if (b.size() <= 0xff)
        {
            insert(end(), OP_PUSHDATA1);
            insert(end(), (unsigned char)b.size());
        }
        else if (b.size() <= 0xffff)
        {
            insert(end(), OP_PUSHDATA2);
            uint8_t data[2];
            WriteLE16(data, b.size());
            insert(end(), data, data + sizeof(data));
        }
        else
        {
            insert(end(), OP_PUSHDATA4);
            uint8_t data[4];
            WriteLE32(data, b.size());
            insert(end(), data, data + sizeof(data));
        }
        insert(end(), b.begin(), b.end());
        return *this;
*)
end;



function writeNameData(const buf:ansistring):ansistring;  // split value in 520 bytes chunks and add it to script
//nameScript << op << OP_DROP << name << vchRentalDays << OP_2DROP;
var i,n:integer;
    nChunks:integer;
begin
  result:='';
  i:=1;
  nChunks:=0;
  while i<length(buf) do begin
     n:=length(buf)-i+1;
     if n>520 then n:=520;

     result:=result+writeScriptData(copy(buf,i,n));

     i:=i+n;
     nChunks:=nChunks+1;
  end;

  for i:=0 to nChunks div 2 - 1 do result:=result+ opNum('OP_2DROP');
  if (nChunks mod 2)=1 then result:=result+ opNum('OP_DROP');


(*
    // split value in 520 bytes chunks and add it to script
    {
        unsigned int nChunks = ceil(value.size() / 520.0);

        for (unsigned int i = 0; i < nChunks; i++)
        {   // insert data
            vector<unsigned char>::const_iterator sliceBegin = value.begin() + i*520;
            vector<unsigned char>::const_iterator sliceEnd = min(value.begin() + (i+1)*520, value.end());
            vector<unsigned char> vchSubValue(sliceBegin, sliceEnd);
            nameScript << vchSubValue;
        }

            //insert end markers
        for (unsigned int i = 0; i < nChunks / 2; i++)
            nameScript << OP_2DROP;
        if (nChunks % 2 != 0)
            nameScript << OP_DROP;
    }
    return true;
*)
end;


function readScriptData(const buf:ansistring; var position:integer):ansistring;
const
  OP_PUSHDATA1 = 76;
  OP_PUSHDATA2 = 77;
  OP_PUSHDATA4 = 78;
var n:dword;
begin
  if position>length(buf) then raise exception.Create('readScriptData: read outside the buffer');
  n:= ord(buf[position]);
  case n of
    OP_PUSHDATA1:begin inc(position); n:= ord(buf[position]); inc(position); end;
    OP_PUSHDATA2:begin inc(position); n:= ord(buf[position])+ord(buf[position+1])*$100; position:=position+2; end;
    OP_PUSHDATA4:begin
        inc(position);
        n:=  ord(buf[position])
            +ord(buf[position+1])*$100
            +ord(buf[position+2])*$10000
            +ord(buf[position+3])*$1000000;
        position:=position+4;
    end;
  else
    //just n symbols
    position:=position+1;
  end;
  result:=copy(buf,position,n);
  position:=position+n;
end;

function readNameScriptData(const buf:ansistring; var position:integer):ansistring;
  const
    OP_PUSHDATA1 = 76;
    OP_PUSHDATA2 = 77;
    OP_PUSHDATA4 = 78;
  function haveData():boolean;
  begin
    result:=(length(buf)>=position)
      and (ord(buf[position])<=OP_PUSHDATA4);
  end;
  var i:integer;
      nChunks:integer;
begin
  nChunks:=0; result:='';
  while haveData() do begin
     result:=result+readScriptData(buf,position);
     inc(nChunks);
  end;

  if  ((nChunks div 2  + nChunks mod 2)+position -1)  > length(buf) then raise exception.create('readNameScriptData: unexpected end of buffer');
  for i:=0 to nChunks div 2 - 1 do if buf[position] =  opNum('OP_2DROP') then inc(position) else  raise exception.create('readNameScriptData: unexpected opcode ');
  if (nChunks mod 2)=1 then if buf[position] =  opNum('OP_DROP') then inc(position) else  raise exception.create('readNameScriptData: unexpected opcode ');
end;


function decodeHRtext(s:ansistring):ansistring;
var i:integer;
begin
  i:=1;
  result:='';
  while i<=length(s) do
    if s[i]<>'#'
       then begin result:=result+s[i]; inc(i); end
       else begin result:=result+chr(strtoint('$'+copy(s,i+1,2))); i:=i+3; end;
end;



function scriptCompile(script:ansistring):ansistring;
  var inNameOp:boolean;
  procedure writeBuf(buf:ansistring);
  begin
    //if length(buf)>=$50 then raise exception.create('scriptCompile: too long data section!');
    //result:=result+chr(length(buf))+buf;
    if inNameOp
      then result:=result+writeNameData(buf)
      else result:=result+writeScriptData(buf);

  end;
  var op,s,t:ansistring;
      n:byte;
      i:integer;
begin
  inNameOp:=false;
  result:='';
  script:=trim(script)+' ';
  while trim(script)<>'' do begin
    if script[1]='`' //extended text
      then begin
        delete(script,1,1);
        if pos('` ',script)<1 then raise exception.create('scriptCompile: unlosed `text` constant');
        op:='`'+copy(script,1,pos('` ',script)-1)+'`';
        delete(script,1,pos('` ',script)+1);
      end else begin
        op:=copy(script,1,pos(' ',script)-1);
        delete(script,1,pos(' ',script));
      end;
    if length(op)<2 then raise exception.Create('scriptCompile: wrong cmd: '+op+' !');
    if op[1]='<' then begin
      //code58
      if op[length(op)]<>'>' then  raise exception.Create('scriptCompile: wrong code58 address: '+op+' !');
      s:=trim(copy(op,2,length(op)-2));
      s:=base58ToBufCheck(s);
      delete(s,1,1);
      writeBuf(s);
    end else if op[1]='[' then begin
      //hex
      if op[length(op)]<>']' then raise exception.Create('scriptCompile: wrong [hex] string: '+op+' !');
      s:=trim(copy(op,2,length(op)-2));
      s:=hexToBuf(s);
      writeBuf(s);
    end else if op[1]='{' then begin
      //hex no len
      if op[length(op)]<>'}' then raise exception.Create('scriptCompile: wrong {hex} string: '+op+' !');
      s:=trim(copy(op,2,length(op)-2));
      s:=hexToBuf(s);
      result:=result+s;
    end else if op[1]='`' then begin
          //`txt#HH`
          if op[length(op)]<>'`' then raise exception.Create('scriptCompile: wrong {hex} string: '+op+' !');
          s:=trim(copy(op,2,length(op)-2));
          t:=decodeHRtext(s);
          {
          i:=1;
          t:='';
          while i<=length(s) do
            if s[i]<>'#'
               then begin t:=t+s[i]; inc(i); end
               else begin t:=t+chr(strtoint('$'+copy(s,i+1,2))); i:=i+3; end;
          }
          writeBuf(t);
    end else begin
      //op
      n:=opcodes.IndexOf(op);
      if n<0 then raise exception.Create('scriptCompile: unknown operation: '+op+'');

      if (opcodes[n]=opNum('OP_NAME_NEW')) or (opcodes[n]=opNum('OP_NAME_UPDATE')) or (opcodes[n]=opNum('OP_NAME_DELETE')) then inNameOp:=true;
      if (opcodes[n]=opNum('OP_DUP')) or (opcodes[n]=opNum('OP_HASH160')) then inNameOp:=false;

      n:=integer(pointer(opcodes.Objects[n]));
      result:=result+chr(n);


    end;
  end;
end;

function scriptParseToList(buf:ansistring):tStringList;
var i,n,c:integer;
    d:dword;
var inNameOp:boolean;

  function pullbuf(n:dword):ansistring;
  begin
    result:=copy(buf,i,n);
    i:=i+n;
  end;

  function pullData():ansistring;
  begin
    //inc(i);
    //result:=pullbuf(ord(buf[i-1]));
    if inNameOp
      then result:= readNameScriptData(buf,i)
      else result:= readScriptData(buf,i);
  end;

begin
  inNameOp:=false;
  result:=tStringList.Create;
  i:=1;
  while i<=length(buf) do begin
    c:=ord(buf[i]);
    n:=opcodes.IndexOfObject(tObject(pointer(c)));
    if n>=0 then begin
        (*
       if opcodes[n]='OP_PUSHDATA1' then begin
          result.Append(buf[i]);
          inc(i);
          d:=ord(buf[i]);
          result.Append(buf[i]);
          inc(i);
          result.Append(pullbuf(d));
       end else if opcodes[n]='OP_PUSHDATA2' then begin  //LE!
         result.Append(buf[i]);
         inc(i); d:=ord(buf[i]);  inc(i); d:=d+ord(buf[i])*$100;
         result.Append(copy(buf,i-1,2));
         inc(i);
         result.Append(pullbuf(d));
       end else if opcodes[n]='OP_PUSHDATA4' then begin  //LE!
         result.Append(buf[i]);
         inc(i); d:=ord(buf[i]);  inc(i); d:=d+ord(buf[i])*$100; inc(i); d:=d+ord(buf[i])*$10000; inc(i); d:=d+ord(buf[i])*$10000;
         result.Append(copy(buf,i-3,4));
         inc(i);
         result.Append(pullbuf(d));
       end else begin
         result.Append(buf[i]);
         i:=i+1;
       end;
      //https://github.com/emercoin/emercoin/blob/master/src/namecoin.cpp#L941
      *)

      if (opcodes[n]='OP_PUSHDATA1') or (opcodes[n]='OP_PUSHDATA2') or (opcodes[n]='OP_PUSHDATA4') then begin
        result.Append(pullData);

      end else begin
        result.AddObject(buf[i],opcodes.objects[n]);
        i:=i+1;

        if (opcodes[n]=opNum('OP_NAME_NEW')) or (opcodes[n]=opNum('OP_NAME_UPDATE')) or (opcodes[n]=opNum('OP_NAME_DELETE')) then inNameOp:=true;
        if (opcodes[n]=opNum('OP_DUP')) or (opcodes[n]=opNum('OP_HASH160')) then inNameOp:=false;
      end;

    end else //data
      result.Append(pullData);
  end;
end;


function scriptDecompile(buf:ansistring;addID:ansistring='';decodeText:boolean=false):ansistring;
var i,n,c:integer;
   var inNameOp:boolean;

  function pullbuf(n:integer):ansistring;
  begin
    result:=copy(buf,i,n);
    i:=i+n;
  end;

  function pullData():ansistring;
  begin
    //inc(i);
    //result:=bufToHex(pullbuf(ord(buf[i-1])));
    if inNameOp
      then result:= scriptDataBufToText(readNameScriptData(buf,i),decodeText)
      else result:= scriptDataBufToText(readScriptData(buf,i),decodeText);
  end;

  var d:dword;
begin
  inNameOp:=false;
  result:='';
  i:=1;
  while i<=length(buf) do begin
    c:=ord(buf[i]);
    n:=opcodes.IndexOfObject(tObject(pointer(c)));
//    if n<0 then raise exception.create('Unknown opcode '+inttostr(ord(buf[i])));
    if n>=0 then begin

      if (opcodes[n]='OP_PUSHDATA1') or (opcodes[n]='OP_PUSHDATA2') or (opcodes[n]='OP_PUSHDATA4') then result:=result + pullData+' '
      else if (opcodes[n]='OP_HASH160') and (length(buf)>i) and (ord(buf[i+1])=20) and (addId<>'') then begin
        i:=i+2;
        result:=result + opcodes[n]+' ';
        result:=result + '<'+buf2Base58Check(addId[1]+pullbuf(20))+'> '
      end else begin
        i:=i+1;
        result:=result + opcodes[n]+' ';
        if (opcodes[n]=opNum('OP_NAME_NEW')) or (opcodes[n]=opNum('OP_NAME_UPDATE')) or (opcodes[n]=opNum('OP_NAME_DELETE')) then inNameOp:=true;
        if (opcodes[n]=opNum('OP_DUP')) or (opcodes[n]=opNum('OP_HASH160')) then inNameOp:=false;
      end;

 (*     end else if opcodes[n]='OP_PUSHDATA1' then begin


         d:=ord(buf[i]);
         result:=result + '{'+bufToHex(buf[i])+'} ';
         inc(i);
         result:=result + '{'+bufToHex(pullbuf(d))+'} ';
      end else if opcodes[n]='OP_PUSHDATA2' then begin  //LE!

        d:=ord(buf[i]);  inc(i); d:=d+ord(buf[i])*$100;
        result:=result + '{'+bufToHex(copy(buf,i-1,2))+'} ';
        inc(i);
        result:=result + '{'+bufToHex(pullbuf(d))+'} ';
      end else if opcodes[n]='OP_PUSHDATA4' then begin  //LE!

        d:=ord(buf[i]);  inc(i); d:=d+ord(buf[i])*$100; inc(i); d:=d+ord(buf[i])*$10000; inc(i); d:=d+ord(buf[i])*$10000;
        result:=result + '{'+bufToHex(copy(buf,i-3,4))+'} ';
        inc(i);
        result:=result + '{'+bufToHex(pullbuf(d))+'} ';
      end else begin
        //do nothing           *)

      //https://github.com/emercoin/emercoin/blob/master/src/namecoin.cpp#L941
    end else //data
      result:=result + pullData+' ';
  end;
  result:=trim(result);
end;

function nameScriptDecode(buf:ansistring):tNameScript; //Name='' for non-name
var
    l:tStringList;
    i:integer;
    add,s:ansistring;
begin
{  tNameScript=record
   TXtype:char; //51,52,53
   Name:ansistring;
   Value:ansistring;
   Days:integer;
   Owner:ansistring;
end; }
  fillchar(result,sizeof(result),0);
  if length(buf)<4 then exit;


  l:=scriptParseToList(buf);

  try
    if l.Count<5 then exit;
    //OP_DUP OP_HASH160 <address> OP_EQUALVERIFY OP_CHECKSIG
    if {(l.Count>=5) and} (l[l.Count-5]=opNum('OP_DUP')) and (l[l.Count-4]=opNum('OP_HASH160')) and (l[l.Count-2]=opNum('OP_EQUALVERIFY')) and (l[l.Count-1]=opNum('OP_CHECKSIG')) then begin
      //checking tail
      add:=l[l.Count - 3];
      if (length(add)=20) and (l.Objects[l.Count - 3]=nil) then
        result.Owner:=add
      else exit;//incorrect address
    end;

    if result.Owner='' then exit; //

    for i:=1 to 5 do l.Delete(l.Count-1);

    if (l.Count=0) then begin
       exit; //just payment script
    end else if (l.Count>6) and ((l[0]=opNum('OP_NAME_NEW')) or (l[0]=opNum('OP_NAME_UPDATE')))
     {
       0 OP_NAME_NEW
       1 OP_DROP
       2 [name]
       3 [days]
       4 OP_2DROP
       5 [value]
       6 .... OP_2DROP OP_DROP only
      }

       and (l[1]=opNum('OP_DROP'))
       and (l.Objects[2]=nil)
       and (l.Objects[3]=nil)
       and (l[4]=opNum('OP_2DROP'))
       and (l.Objects[5]=nil)
       //and ((l[6]=opNum('OP_2DROP')) or (l[6]=opNum('OP_DROP')))
    then begin
    //   OP_NAME_NEW OP_DROP [747374] [0F27] OP_2DROP [747374310A747374320A74737433] OP_DROP                       OP_DUP OP_HASH160 <mhPsFuD6srgjVXMR2VdP45tpco3C5GStst> OP_EQUALVERIFY OP_CHECKSIG
   //    OP_NAME_NEW OP_DROP []       []     OP_2DROP OP_PUSHDATA2 [len] [data] OP_PUSHDATA2 [len] [data] OP_2DROP OP_DUP OP_HASH160 [649E41B014A856EB56AF9098696E8AAF5904B103] OP_EQUALVERIFY OP_CHECKSIG
   //Name: "tst" for 9999 days  value="tst1tst2tst3"  owner: <mhPsFuD6srgjVXMR2VdP45tpco3C5GStst>
   // длинное имя

    //  OP_NAME_NEW OP_DROP [name] [days] OP_2DROP [value] OP_DROP OP_DUP OP_HASH160 <address> OP_EQUALVERIFY OP_CHECKSIG
    //  OP_NAME_NEW OP_DROP [name] [days] OP_2DROP OP_PUSHDATA2 {len} {data} OP_PUSHDATA2 {len} {data} OP_2DROP OP_DUP OP_HASH160 <address> OP_EQUALVERIFY OP_CHECKSIG
    //  OP_NAME_NEW OP_DROP OP_PUSHDATA2 {len, max 0002} {name} [days] OP_2DROP OP_PUSHDATA2 {len 0802} {data1} OP_PUSHDATA2 {len 0802} {data2} OP_PUSHDATA2 {len 0802} {data 3} OP_PUSHDATA2 {len 0802} {data4} OP_PUSHDATA2 {len 0802} {data 5} ....A LOT OF BLOCKS... OP_PUSHDATA1 {rest len = C8} {last data} OP_2DROP OP_2DROP  OP_2DROP OP_2DROP ..close all blocks.. OP_2DROP OP_2DROP OP_DUP OP_HASH160 <address> OP_EQUALVERIFY OP_CHECKSIG
      result.TXtype:=l[0][1];
      result.Name:=l[2];

      s:='';
      i:=5;
      while (i<l.count) and (l.Objects[i]=nil) do begin s:=s+l[i]; inc(i); end;
      result.Value:=s;

      result.Days:=BufToInt(l[3]);
    end else if (l.Count=4) and (l[0]=opNum('OP_NAME_DELETE')) and (l[1]=opNum('OP_DROP'))
         and (l.Objects[2]=nil)
         and (l[3]=opNum('OP_DROP'))
    then begin
      //OP_NAME_DELETE OP_DROP [747379] OP_DROP OP_DUP OP_HASH160 [9836ED34086A8A029FE0B2CA1E3EAEF610D91117] OP_EQUALVERIFY OP_CHECKSIG
      //OP_NAME_DELETE OP_DROP [747379] OP_DROP OP_DUP OP_HASH160 [9836ED34086A8A029FE0B2CA1E3EAEF610D91117] OP_EQUALVERIFY OP_CHECKSIG

      result.TXtype:=l[0][1];// opNum('OP_NAME_DELETE');
      result.Name:=l[2];


      //https://github.com/emercoin/emercoin/blob/master/src/script/script.h#L425
      //https://github.com/emercoin/emercoin/blob/master/src/prevector.h#L342
    end;
  finally
    l.free;
  end;

end;

(*
//class CTransactionSignatureSerializer
{
private:
    const CTransaction& txTo;  //!< reference to the spending transaction (the one being serialized)
    const CScript& scriptCode; //!< output script being consumed
    const unsigned int nIn;    //!< input index of txTo being signed
    const bool fAnyoneCanPay;  //!< whether the hashtype has the SIGHASH_ANYONECANPAY flag set
    const bool fHashSingle;    //!< whether the hashtype is SIGHASH_SINGLE
    const bool fHashNone;      //!< whether the hashtype is SIGHASH_NONE
    public:
}
function


//    CTransactionSignatureSerializer(const CTransaction &txToIn, const CScript &scriptCodeIn, unsigned int nInIn, int nHashTypeIn) :
//        txTo(txToIn), scriptCode(scriptCodeIn), nIn(nInIn),
//        fAnyoneCanPay(!!(nHashTypeIn & SIGHASH_ANYONECANPAY)),
//        fHashSingle((nHashTypeIn & 0x1f) == SIGHASH_SINGLE),
//        fHashNone((nHashTypeIn & 0x1f) == SIGHASH_NONE) {}

    /** Serialize the passed scriptCode, skipping OP_CODESEPARATORs */
    template<typename S>
    void SerializeScriptCode(S &s) const {
        CScript::const_iterator it = scriptCode.begin();
        CScript::const_iterator itBegin = it;
        opcodetype opcode;
        unsigned int nCodeSeparators = 0;
        while (scriptCode.GetOp(it, opcode)) {
            if (opcode == OP_CODESEPARATOR)
                nCodeSeparators++;
        }
        ::WriteCompactSize(s, scriptCode.size() - nCodeSeparators);
        it = itBegin;
        while (scriptCode.GetOp(it, opcode)) {
            if (opcode == OP_CODESEPARATOR) {
                s.write((char* )&itBegin[0], it-itBegin-1);
                itBegin = it;
            }
        }
        if (itBegin != scriptCode.end())
            s.write((char* )&itBegin[0], it-itBegin);
    }

    /** Serialize an input of txTo */
    template<typename S>
    void SerializeInput(S &s, unsigned int nInput) const {
        // In case of SIGHASH_ANYONECANPAY, only the input being signed is serialized
        if (fAnyoneCanPay)
            nInput = nIn;
        // Serialize the prevout
        ::Serialize(s, txTo.vin[nInput].prevout);
        // Serialize the script
        if (nInput != nIn)
            // Blank out other inputs' signatures
            ::Serialize(s, CScriptBase());
        else
            SerializeScriptCode(s);
        // Serialize the nSequence
        if (nInput != nIn && (fHashSingle || fHashNone))
            // let the others update at will
            ::Serialize(s, (int)0);
        else
            ::Serialize(s, txTo.vin[nInput].nSequence);
    }

    /** Serialize an output of txTo */
    template<typename S>
    void SerializeOutput(S &s, unsigned int nOutput) const {
        if (fHashSingle && nOutput != nIn)
            // Do not lock-in the txout payee at other indices as txin
            ::Serialize(s, CTxOut());
        else
            ::Serialize(s, txTo.vout[nOutput]);
    }

    /** Serialize txTo */
    template<typename S>
    void Serialize(S &s) const {
        // Serialize nVersion
        ::Serialize(s, txTo.nVersion);
        // Serialize nTime
        ::Serialize(s, txTo.nTime);
        // Serialize vin
        unsigned int nInputs = fAnyoneCanPay ? 1 : txTo.vin.size();
        ::WriteCompactSize(s, nInputs);
        for (unsigned int nInput = 0; nInput < nInputs; nInput++)
             SerializeInput(s, nInput);
        // Serialize vout
        unsigned int nOutputs = fHashNone ? 0 : (fHashSingle ? nIn+1 : txTo.vout.size());
        ::WriteCompactSize(s, nOutputs);
        for (unsigned int nOutput = 0; nOutput < nOutputs; nOutput++)
             SerializeOutput(s, nOutput);
        // Serialize nLockTime
        ::Serialize(s, txTo.nLockTime);
    }
};


// uint256 SignatureHash(const CScript& scriptCode, const CTransaction& txTo, unsigned int nIn, int nHashType, const CAmount& amount, SigVersion sigversion, const PrecomputedTransactionData* cache)
//https://github.com/emercoin/emercoin/blob/master/src/script/interpreter.cpp#L1180
//function hashForSignature2(this:ttx; inIndex:integer; prevOutScript:ansistring; hashType:dword):ansistring;
function hashForSignature2(scriptCode:ansistring; txTo:ttx; nIn:integer; nHashType:dword; amount:qword;sigversion:integer; cache:ansistring):ansistring;
//const SIGVERSION_WITNESS_V0=1;
begin
  //from the Emercoin sources
  //SegWit mode:
  (*
      if (sigversion == SIGVERSION_WITNESS_V0) then begin
          uint256 hashPrevouts;
          uint256 hashSequence;
          uint256 hashOutputs;

          if (!(nHashType & SIGHASH_ANYONECANPAY)) {
              hashPrevouts = cache ? cache->hashPrevouts : GetPrevoutHash(txTo);
          }

          if (!(nHashType & SIGHASH_ANYONECANPAY) && (nHashType & 0x1f) != SIGHASH_SINGLE && (nHashType & 0x1f) != SIGHASH_NONE) {
              hashSequence = cache ? cache->hashSequence : GetSequenceHash(txTo);
          }


          if ((nHashType & 0x1f) != SIGHASH_SINGLE && (nHashType & 0x1f) != SIGHASH_NONE) {
              hashOutputs = cache ? cache->hashOutputs : GetOutputsHash(txTo);
          } else if ((nHashType & 0x1f) == SIGHASH_SINGLE && nIn < txTo.vout.size()) {
              CHashWriter ss(SER_GETHASH, 0);
              ss << txTo.vout[nIn];
              hashOutputs = ss.GetHash();
          }

          CHashWriter ss(SER_GETHASH, 0);
          // Version
          ss << txTo.nVersion;
          // nTime
          ss << txTo.nTime;
          // Input prevouts/nSequence (none/all, depending on flags)
          ss << hashPrevouts;
          ss << hashSequence;
          // The input being signed (replacing the scriptSig with scriptCode + amount)
          // The prevout may already be contained in hashPrevout, and the nSequence
          // may already be contain in hashSequence.
          ss << txTo.vin[nIn].prevout;
          ss << static_cast<const CScriptBase&>(scriptCode);
          ss << amount;
          ss << txTo.vin[nIn].nSequence;
          // Outputs (none/one/all, depending on flags)
          ss << hashOutputs;
          // Locktime
          ss << txTo.nLockTime;
          // Sighash type
          ss << nHashType;

          return ss.GetHash();
      end;
   *)


  //static const uint256 one(uint256S("0000000000000000000000000000000000000000000000000000000000000001"));
  //buf_ONE

  if nIn >= length(txTo.ins) then raise exception.Create('hashForSignature2: vIn out of bounds');



  // Check for invalid use of SIGHASH_SINGLE
  if ((nHashType and $1f) = SIGHASH_SINGLE) then begin
      if (nIn >= length(txTo.outs)) then raise exception.Create('hashForSignature2: vIn out of bounds for outs');
  end;

  // Wrapper to serialize only the necessary parts of the transaction being signed
  //https://github.com/emercoin/emercoin/blob/master/src/script/interpreter.cpp
  CTransactionSignatureSerializer txTmp(txTo, scriptCode, nIn, nHashType);

  // Serialize and hash
  CHashWriter ss(SER_GETHASH, 0);
  ss << txTmp << nHashType;
  return ss.GetHash();
  }


end;
*)

function dupeTx(tx:ttx):ttx;
var i,j:integer;
begin
  result:=tx;
  result.ins:=nil;
  result.outs:=nil;

  setLength(result.ins,length(tx.ins));
  setLength(result.outs,length(tx.outs));

  for i:=0 to length(tx.ins)-1 do begin
     result.ins[i].script:=tx.ins[i].script;
     result.ins[i].hash:=tx.ins[i].hash;
     result.ins[i].index:=tx.ins[i].index;
     result.ins[i].sequence:=tx.ins[i].sequence;
     setLength(result.ins[i].witness,length(tx.ins[i].witness));
     for j:=0 to length(tx.ins[i].witness)-1 do
       result.ins[i].witness[j]:=tx.ins[i].witness[j];
  end;

{
    ttxin=packed record
    hash:ansistring;
    index:dword;
    script:ansistring;
    sequence:dword;
    witness: array of ansistring;
}

  for i:=0 to length(tx.outs)-1 do begin
     result.outs[i].script:=tx.outs[i].script;
     result.outs[i].value:=tx.outs[i].value;
  end;

end;

function hashForSignature(const this:ttx; inIndex:integer; prevOutScript:ansistring; hashType:dword=SIGHASH_ALL):ansistring;
var
  ourScript,s:ansistring;
  txTmp:ttx;
  i:integer;
begin
  //typeforce(types.tuple(types.UInt32, types.Buffer, /* types.UInt8 */ types.Number), arguments)

  // https://github.com/bitcoin/bitcoin/blob/master/src/test/sighash_tests.cpp#L29
  if (inIndex >= length(this.ins)) then begin
    result:=buf_ONE;
    exit;
  end;

  // ignore OP_CODESEPARATOR
  //ourScript := bscript.compile(bscript.decompile(prevOutScript).filter(function (x) {
  //  return x !== opcodes.OP_CODESEPARATOR
  //}))
  s:=' '+scriptDecompile(prevOutScript)+' ';
  while pos(' OP_CODESEPARATOR ',s)>0 do delete(s,pos(' OP_CODESEPARATOR ',s),length(' OP_CODESEPARATOR ')-1); //left one space
  ourScript:=scriptCompile(s);

  //FIX!!!!!!!!!!!!!!!!!!
  //бредовая идея ourScript:=prevOutScript;


  txTmp := dupeTx(this);
  //txTmp := this;

  // SIGHASH_NONE: ignore all outputs? (wildcard payee)
  //if ((hashType & 0x1f) === Transaction.SIGHASH_NONE)
  {
    txTmp.outs = []

    // ignore sequence numbers (except at inIndex)
    txTmp.ins.forEach(function (input, i) {
      if (i === inIndex) return

      input.sequence = 0
    })
  }
  if ((hashType and $1f) = SIGHASH_NONE) then begin
    setLength(txTmp.outs,0);
    for i:=0 to length(txTmp.ins)-1 do
      if (inIndex<>i) then txTmp.ins[i].sequence:=0;

  end else if ((hashType and $1f) = SIGHASH_SINGLE) then begin

    // SIGHASH_SINGLE: ignore all outputs, except at the same index?
    //} else if ((hashType & 0x1f) === Transaction.SIGHASH_SINGLE)
      {
      // https://github.com/bitcoin/bitcoin/blob/master/src/test/sighash_tests.cpp#L60
      if (inIndex >= this.outs.length) return ONE

      // truncate outputs after
      txTmp.outs.length = inIndex + 1

      // "blank" outputs before
      for (var i = 0; i < inIndex; i++) {
        txTmp.outs[i] = BLANK_OUTPUT
      }

      // ignore sequence numbers (except at inIndex)
      txTmp.ins.forEach(function (input, y) {
        if (y === inIndex) return

        input.sequence = 0
      })
    }
    if (inIndex >= length(txTmp.outs)) then begin
      result:= buf_ONE;
      exit;
    end;

    // truncate outputs after
    //txTmp.outs.length = inIndex + 1
    setLength(txTmp.outs,inIndex + 1);

    // "blank" outputs before
    //for (var i = 0; i < inIndex; i++) {
    //  txTmp.outs[i] = BLANK_OUTPUT
    //}
    for i:=0 to inIndex-1 do txTmp.outs[i] := BLANK_OUTPUT;


    // ignore sequence numbers (except at inIndex)
    //txTmp.ins.forEach(function (input, y) {
    //  if (y === inIndex) return
    //  input.sequence = 0
    //})
    for i:=0 to length(txTmp.ins)-1 do
      if i<>inIndex then txTmp.ins[i].sequence:=0;
  end;


  // SIGHASH_ANYONECANPAY: ignore inputs entirely?
  //if (hashType & Transaction.SIGHASH_ANYONECANPAY) {
  //  txTmp.ins = [txTmp.ins[inIndex]]
  //  txTmp.ins[0].script = ourScript
  //
  //// SIGHASH_ALL: only ignore input scripts
  //} else {
  //  // "blank" others input scripts
  //  txTmp.ins.forEach(function (input) { input.script = EMPTY_SCRIPT })
  //  txTmp.ins[inIndex].script = ourScript
  //}

  if (hashType and SIGHASH_ANYONECANPAY)>0 then begin
    txTmp.ins[0] := txTmp.ins[inIndex];
    txTmp.ins[0].script := ourScript;
    setLength(txTmp.ins,1);
    // SIGHASH_ALL: only ignore input scripts
  end else begin
    // "blank" others input scripts
    for i:=0 to length(txTmp.ins)-1 do
        txTmp.ins[i].script:=EMPTY_SCRIPT;
    txTmp.ins[inIndex].script := ourScript;
  end;




  // serialize and hash
  //var buffer = Buffer.allocUnsafe(txTmp.__byteLength(false) + 4)
  //buffer.writeInt32LE(hashType, buffer.length - 4)
  //txTmp.__toBuffer(buffer, 0, false)
  //return bcrypto.hash256(buffer)

 //!!!! НЕТ? ДА?  hashType:=swapEndian(hashType);
  setLength(s,4); Move(hashType,s[1],4);

  //function packTX(tx:ttx;addWitness:boolean=true):ansistring;
  s:=packTX(txTmp)+s;


//  myBFS:=s;
  // unit1.Form1.Memo1.lines.Append('                       signTxIn Data for HFS='+bufToHex(s));
  result:=dosha256(dosha256(s));
//  result:=s;

  //не используем getTxHash потому, что он не добаляет hashType

end;

//const
  {
  "OP_FALSE": 0,
  "OP_0": 0,
  "OP_PUSHDATA1": 76,
  "OP_PUSHDATA2": 77,
  "OP_PUSHDATA4": 78,
  "OP_1NEGATE": 79,
  "OP_RESERVED": 80,
  "OP_TRUE": 81,
  "OP_1": 81,
  "OP_2": 82,
  "OP_3": 83,
  "OP_4": 84,
  "OP_5": 85,
  "OP_6": 86,
  "OP_7": 87,
  "OP_8": 88,
  "OP_9": 89,
  "OP_10": 90,
  "OP_11": 91,
  "OP_12": 92,
  "OP_13": 93,
  "OP_14": 94,
  "OP_15": 95,
  "OP_16": 96,

  "OP_NOP": 97,
  "OP_VER": 98,
  "OP_IF": 99,
  "OP_NOTIF": 100,
  "OP_VERIF": 101,
  "OP_VERNOTIF": 102,
  "OP_ELSE": 103,
  "OP_ENDIF": 104,
  "OP_VERIFY": 105,
  "OP_RETURN": 106,

  "OP_TOALTSTACK": 107,
  "OP_FROMALTSTACK": 108,
  "OP_2DROP": 109,
  "OP_2DUP": 110,
  "OP_3DUP": 111,
  "OP_2OVER": 112,
  "OP_2ROT": 113,
  "OP_2SWAP": 114,
  "OP_IFDUP": 115,
  "OP_DEPTH": 116,
  "OP_DROP": 117,
  "OP_DUP": 118,
  "OP_NIP": 119,
  "OP_OVER": 120,
  "OP_PICK": 121,
  "OP_ROLL": 122,
  "OP_ROT": 123,
  "OP_SWAP": 124,
  "OP_TUCK": 125,

  "OP_CAT": 126,
  "OP_SUBSTR": 127,
  "OP_LEFT": 128,
  "OP_RIGHT": 129,
  "OP_SIZE": 130,

  "OP_INVERT": 131,
  "OP_AND": 132,
  "OP_OR": 133,
  "OP_XOR": 134,
  "OP_EQUAL": 135,
  "OP_EQUALVERIFY": 136,
  "OP_RESERVED1": 137,
  "OP_RESERVED2": 138,

  "OP_1ADD": 139,
  "OP_1SUB": 140,
  "OP_2MUL": 141,
  "OP_2DIV": 142,
  "OP_NEGATE": 143,
  "OP_ABS": 144,
  "OP_NOT": 145,
  "OP_0NOTEQUAL": 146,
  "OP_ADD": 147,
  "OP_SUB": 148,
  "OP_MUL": 149,
  "OP_DIV": 150,
  "OP_MOD": 151,
  "OP_LSHIFT": 152,
  "OP_RSHIFT": 153,

  "OP_BOOLAND": 154,
  "OP_BOOLOR": 155,
  "OP_NUMEQUAL": 156,
  "OP_NUMEQUALVERIFY": 157,
  "OP_NUMNOTEQUAL": 158,
  "OP_LESSTHAN": 159,
  "OP_GREATERTHAN": 160,
  "OP_LESSTHANOREQUAL": 161,
  "OP_GREATERTHANOREQUAL": 162,
  "OP_MIN": 163,
  "OP_MAX": 164,

  "OP_WITHIN": 165,

  "OP_RIPEMD160": 166,
  "OP_SHA1": 167,
  "OP_SHA256": 168,
  "OP_HASH160": 169,
  "OP_HASH256": 170,
  "OP_CODESEPARATOR": 171,
  "OP_CHECKSIG": 172,
  "OP_CHECKSIGVERIFY": 173,
  "OP_CHECKMULTISIG": 174,
  "OP_CHECKMULTISIGVERIFY": 175,

  "OP_NOP1": 176,

  "OP_NOP2": 177,
  "OP_CHECKLOCKTIMEVERIFY": 177,

  "OP_NOP3": 178,
  "OP_CHECKSEQUENCEVERIFY": 178,

  "OP_NOP4": 179,
  "OP_NOP5": 180,
  "OP_NOP6": 181,
  "OP_NOP7": 182,
  "OP_NOP8": 183,
  "OP_NOP9": 184,
  "OP_NOP10": 185,

  "OP_PUBKEYHASH": 253,
  "OP_PUBKEY": 254,
  "OP_INVALIDOPCODE": 255
}
// , -> ));
//  ":  -> ', tObject(
//  " ->  opcodes.AddObject('

//Transaction.prototype.hasWitnesses = function () {
//  return this.ins.some(function (x) {
//    return x.witness.length !== 0
//  })
//}
function hasWitnesses(tx:ttx):boolean;
var i:integer;
begin
  result:=true;
  for i:=0 to length(tx.ins)-1 do
    if length(tx.ins[i].witness)>0 then exit;
  result:=false;
end;

function unpackTX(buf:ansistring):ttx;
var
  offset:integer;
  function readSlice (n:integer):ansistring; begin
    result:= copy(buf,offset+1,n);
    offset := offset + n
  end;

  function readUInt32 ():dword; begin
    Move(buf[offset+1],result,4);
    offset := offset + 4;
  end;

  function readInt32 ():longint; begin
    Move(buf[offset+1],result,4);
    offset := offset + 4;
  end;

  function readUInt64 ():UInt64; begin
    Move(buf[offset+1],result,8);
    offset := offset + 8;
  end;

//[0, 0xfd)	1
//[0xfd, 0xffff]	3
//[0x010000, 0xffffffff]	5
//[0x0100000000, 0x1fffffffffffff]	9
//uint8_t
//0xFD followed by the length as uint16_t
//0xFE followed by the length as uint32_t
//0xFF followed by the length as uint64_t

//little endian!
  function readVarInt ():int64;
  var n:byte;
  begin
    case ord(buf[offset+1]) of
    $FD:begin
      result:=ord(buf[offset+2])+ord(buf[offset+3]) * $100;
      offset:=offset+3;
    end;
    $FE:begin
      result:=ord(buf[offset+2])+ord(buf[offset+3]) * $100
              +ord(buf[offset+4])*10000+ord(buf[offset+5]) * $1000000;
      offset:=offset+5;
    end;
    $FF:begin
      Move(buf[offset+2],result,8);
      result:=SwapEndian(result);
      offset:=offset+9;
    end;
    else
      result:=ord(buf[offset+1]);
      offset:=offset+1;
    end;
    //SwapEndian(result)!
  end;


  function readVarSlice ():ansistring; begin
    result:=readSlice(readVarInt());
  end;

  type
    arrayofstring = array of string;
  function readVector ():arrayofstring;
  var count,i:integer;
  begin
    count := readVarInt();
    setlength(result,count);
    for i:=0 to count-1 do result[i]:= readVarSlice();
  end;


var hasWitnesses:boolean;
    vinLen,voutLen,i:dword;
begin
  //
  offset:=0;

  result.version := readInt32();

  result.time := readInt32();

  //var marker = buffer.readUInt8(offset) -> buf[offset + 1]
  //var flag = buffer.readUInt8(offset + 1)  -> buf[offset + 2]

  hasWitnesses := false;

  if (ord(buf[offset + 1]) = ADVANCED_TRANSACTION_MARKER)
      and
      (ord(buf[offset + 2]) = ADVANCED_TRANSACTION_FLAG)  then
  begin
    offset := offset + 2;
    hasWitnesses := true;
  end;


  //for (var i = 0; i < vinLen; ++i)
  {
    tx.ins.push({
      hash: readSlice(32),
      index: readUInt32(),
      script: readVarSlice(),
      sequence: readUInt32(),
      witness: EMPTY_WITNESS
    })
  }

  vinLen := readVarInt();
  setLength(result.ins,vinLen);
  if vinLen>0 then //crasy
  for i:=0 to vinLen-1 do
    with result.ins[i] do begin
      hash:=readSlice(32);
      index:= readUInt32();
      script:= readVarSlice();
      sequence:= readUInt32();
      witness:= EMPTY_WITNESS;
    end;

  // for (i = 0; i < voutLen; ++i)
  {
     tx.outs.push({
       value: readUInt64(),
       script: readVarSlice()
     })
   }
  voutLen := readVarInt();
  setLength(result.outs,voutLen);
  if voutLen>0 then
  for i:=0 to voutLen-1 do with result.outs[i] do begin
    value:= readUInt64();
    script:= readVarSlice();
  end;

       //if (hasWitnesses)
       {
        for (i = 0; i < vinLen; ++i) {
          tx.ins[i].witness = readVector()
        }

        // was this pointless?
        if (!tx.hasWitnesses()) throw new Error('Transaction has superfluous witness data')
      }

  if (hasWitnesses) then begin
    for i:=0 to vinLen-1 do
      result.ins[i].witness := readVector();
  end;

  //tx.locktime = readUInt32()
  result.locktime:=readUInt32();

  if offset<>length(buf) then
    raise exception.Create('Transaction has unexpected data:'+bufToHex(copy(buf,offset,length(buf)-offset+1)));
//      if (__noStrict) return tx
//      if (offset !== buffer.length) throw new Error('Transaction has unexpected data')

//      return tx
end;

function packTX(tx:ttx;addWitness:boolean=true;addRedeemScriptIfNotSigned:boolean=true):ansistring;
var buf:ansistring;
procedure writeSlice (s:ansistring); begin
  buf:=buf+s; // Гениально!
end;

procedure writeUInt32 (x:dword);
begin
  setLength(buf,length(buf)+4);
  Move(x,buf[length(buf)-3],4);
end;

procedure  writeInt32 (x:longint); begin
  setLength(buf,length(buf)+4);
  Move(x,buf[length(buf)-3],4);
end;

procedure writeUInt64 (x:UInt64); begin
  setLength(buf,length(buf)+8);
  Move(x,buf[length(buf)-7],8);
end;

//[0, 0xfd)	1
//[0xfd, 0xffff]	3
//[0x010000, 0xffffffff]	5
//[0x0100000000, 0x1fffffffffffff]	9
//uint8_t
//0xFD followed by the length as uint16_t
//0xFE followed by the length as uint32_t
//0xFF followed by the length as uint64_t

//little endian!
procedure writeVarInt (x:int64);
var n:byte;
begin
  // writeScriptVarInt( could be used instead
  if x<$fd then begin
    buf:=buf+chr(x);
  end else if x<$010000 then begin
    //2 byte
    buf:=buf+chr($FD)
    + chr(x mod $100) + chr(x div $100);
  end else if x<$0100000000 then begin
    //4 byte
    buf:=buf+chr($FE); //Yes, I know what 'for' means
    buf:=buf + chr(x mod $100); x:=x shr 8;
    buf:=buf + chr(x mod $100); x:=x shr 8;
    buf:=buf + chr(x mod $100); x:=x shr 8;
    buf:=buf + chr(x mod $100);
  end else begin
    //8 byte
    buf:=buf+chr($FF);
    x:=SwapEndian(x);
    writeUInt64(x);
  end;
end;


procedure writeVarSlice (s:ansistring); begin
  writeVarInt(length(s));
  buf:=buf + s;
end;

type
  arrayofstring = array of string;
procedure writeVector (v:arrayofstring);
var i:integer;
begin
  writeVarInt(length(v));
  for i:=0 to length(v)-1 do writeVarSlice(v[i]);
end;

var i:integer;
begin
  buf:='';
  writeInt32(tx.version);

  writeInt32(tx.time);

  if hasWitnesses(tx) and addWitness then
    buf:=buf+chr(ADVANCED_TRANSACTION_MARKER)+chr(ADVANCED_TRANSACTION_FLAG);

  writeVarInt(length(tx.ins));
  for i:=0 to length(tx.ins)-1 do with tx.ins[i] do begin
    if length(hash)<>32 then raise exception.Create('Invalid input hash #'+inttostr(i));
    writeSlice(hash);
    writeUInt32(index);
    if addRedeemScriptIfNotSigned or (not isOutputScript(script))
    then
      writeVarSlice(script)
    else
      writeVarSlice('');
    writeUInt32(sequence);
    //witness:= EMPTY_WITNESS;
  end;

  writeVarInt(length(tx.outs));
  for i:=0 to length(tx.outs)-1 do with tx.outs[i] do begin
    writeUInt64(value);
    writeVarSlice(script);
  end;

  if hasWitnesses(tx) and addWitness then
    for i:=0 to length(tx.ins)-1 do
      writeVector(tx.ins[i].witness);

//  if addWitness then
  writeUInt32(tx.locktime);

  result:=buf;
end;

function getTxHash(tx:ttx):ansistring;
begin
  //
  result:=doSha256(doSha256(packTX(tx,false)));
end;


function scriptExplain(buf:ansistring;addID:ansistring=''):ansistring;
var i,n,c:integer;
    s:ansistring;

  function pullbuf(n:integer):ansistring;
  begin
    result:=copy(buf,i,n);
    i:=i+n;
  end;

  function pullData():ansistring;
  begin
    inc(i);
    result:=pullbuf(ord(buf[i-1]));
  end;
begin
  result:='UNKNOWN SCRIPT';
//  i:=1;



// c:=ord(buf[i]);
// n:=opcodes.IndexOfObject(tObject(pointer(c)));

// if n<0 then exit;
// i:=i+1;
 i:=1;
 if copy(buf,i,2)=(chr($76)+chr($A9)) then begin
   //Probably money transfer:
   //OP_DUP OP_HASH160 <D3B9B852EB9275882501967255232279EA434257> OP_EQUALVERIFY OP_CHECKSIG
   //76A9 str 88AC
   result:='send to ';

   i:=3;
   if ord(buf[i])<>20 then begin
     result:=result + '[UNKNOWN ADDRESS:'+pullData+'] ';
   end else begin
     inc(i);
     if addId<>''
         then result:=result + '<'+buf2Base58Check(addId[1]+pullbuf(20))+'> '
         else result:=result + '<'+bufToHex(pullbuf(20))+'> ';
   end;

   if(copy(buf,i,2)<>(chr($88)+chr($AC))) and  (i<>(length(buf)-1))
   then result:='UNKNOWN OPERATION';


 end;

 //    51        75   03747379  011E   6D    0E747374310A747374320A74737433    75      76      A9     141499229323159C6F91E04E7D00AE34B2991E43B7   88             AC
 //OP_NAME_NEW OP_DROP [747379] [1E] OP_2DROP [747374310A747374320A74737433] OP_DROP OP_DUP OP_HASH160 <1499229323159C6F91E04E7D00AE34B2991E43B7> OP_EQUALVERIFY OP_CHECKSIG

 //5175 03747374 020F27 6D0E747374310A747374320A747374337576A9141499229323159C6F91E04E7D00AE34B2991E43B788AC
 //OP_NAME_NEW OP_DROP [747374] [0F27] OP_2DROP [747374310A747374320A74737433] OP_DROP OP_DUP OP_HASH160 <1499229323159C6F91E04E7D00AE34B2991E43B7> OP_EQUALVERIFY OP_CHECKSIG
 i:=1;
 if copy(buf,i,2)=(chr($51)+chr($75)) then begin
   //OP_NAME_NEW OP_DROP [747379] [1E] OP_2DROP [747374310A747374320A74737433] OP_DROP OP_DUP OP_HASH160 <1499229323159C6F91E04E7D00AE34B2991E43B7> OP_EQUALVERIFY OP_CHECKSIG
   i:=3;
   result:= 'Name: "'+pullData()+'" ';
   s:=pullData();    //0F27 = 9999 -> little endian !!! BIG!

   n:=0;
   //while length(s)>0 do begin n:=n shl 8 + ord(s[1]); delete(s,1,1); end;
   //Хер. там большие индейцы
   while length(s)>0 do begin n:=n shl 8 + ord(s[length(s)]); delete(s,length(s),1); end;
   result:= result + 'for '+inttostr(n)+' days ';

   if buf[i]<>chr($6D) then begin result:='WRONG/UNDETECTED NAME RECORD'; exit;  end;     //OP_2DROP=  6D
   inc(i);

   s:=pullData();
   if length(s)>30 then s:=copy(s,1,28)+'...';
   result:=result+ ' value="'+s+'" ';

   if copy(buf,i,3)<>hexToBuf('7576A9') then      //OP_DROP OP_DUP OP_HASH160
      begin result:='WRONG/UNDETECTED NAME RECORD'; exit;  end;
   i:=i+3;

   s:=pullData();

   if length(s)<>20 then s:='unknown address: '+bufToHex(s)
   else begin
     if addId<>''
         then s:='<'+buf2Base58Check(addId[1]+s)+'>'
         else s:='<'+bufToHex(s)+'>';
   end;
   result:=result+ ' owner: '+s+' ';

   if(copy(buf,i,2)<>(chr($88)+chr($AC))) and  (i<>(length(buf)-1))
   then result:='UNKNOWN OPERATION';

 end;


 result:=trim(result);
end;



INITIALIZATION

  opcodes := tStringList.create;

  //emer  : https://github.com/emercoin/emercoin/blob/master/src/script/script.h
  //static const int OP_NAME_NEW = 0x01;
  //static const int OP_NAME_UPDATE = 0x02;
  //static const int OP_NAME_DELETE = 0x03;
  //33 36

  opcodes.AddObject('OP_NAME_NEW', tObject(81));
  opcodes.AddObject('OP_NAME_UPDATE', tObject(82));
  opcodes.AddObject('OP_NAME_DELETE', tObject(83));

  //standart codes


  opcodes.AddObject('OP_FALSE', tObject(0));
  opcodes.AddObject('OP_0', tObject(0));
  opcodes.AddObject('OP_PUSHDATA1', tObject(76));
  opcodes.AddObject('OP_PUSHDATA2', tObject(77));
  opcodes.AddObject('OP_PUSHDATA4', tObject(78));
  opcodes.AddObject('OP_1NEGATE', tObject(79));
  opcodes.AddObject('OP_RESERVED', tObject(80));
  opcodes.AddObject('OP_TRUE', tObject(81));
  opcodes.AddObject('OP_1', tObject(81));
  opcodes.AddObject('OP_2', tObject(82));
  opcodes.AddObject('OP_3', tObject(83));
  opcodes.AddObject('OP_4', tObject(84));
  opcodes.AddObject('OP_5', tObject(85));
  opcodes.AddObject('OP_6', tObject(86));
  opcodes.AddObject('OP_7', tObject(87));
  opcodes.AddObject('OP_8', tObject(88));
  opcodes.AddObject('OP_9', tObject(89));
  opcodes.AddObject('OP_10', tObject(90));
  opcodes.AddObject('OP_11', tObject(91));
  opcodes.AddObject('OP_12', tObject(92));
  opcodes.AddObject('OP_13', tObject(93));
  opcodes.AddObject('OP_14', tObject(94));
  opcodes.AddObject('OP_15', tObject(95));
  opcodes.AddObject('OP_16', tObject(96));

  opcodes.AddObject('OP_NOP', tObject(97));
  opcodes.AddObject('OP_VER', tObject(98));
  opcodes.AddObject('OP_IF', tObject(99));
  opcodes.AddObject('OP_NOTIF', tObject(100));
  opcodes.AddObject('OP_VERIF', tObject(101));
  opcodes.AddObject('OP_VERNOTIF', tObject(102));
  opcodes.AddObject('OP_ELSE', tObject(103));
  opcodes.AddObject('OP_ENDIF', tObject(104));
  opcodes.AddObject('OP_VERIFY', tObject(105));
  opcodes.AddObject('OP_RETURN', tObject(106));

  opcodes.AddObject('OP_TOALTSTACK', tObject(107));
  opcodes.AddObject('OP_FROMALTSTACK', tObject(108));
  opcodes.AddObject('OP_2DROP', tObject(109));
  opcodes.AddObject('OP_2DUP', tObject(110));
  opcodes.AddObject('OP_3DUP', tObject(111));
  opcodes.AddObject('OP_2OVER', tObject(112));
  opcodes.AddObject('OP_2ROT', tObject(113));
  opcodes.AddObject('OP_2SWAP', tObject(114));
  opcodes.AddObject('OP_IFDUP', tObject(115));
  opcodes.AddObject('OP_DEPTH', tObject(116));
  opcodes.AddObject('OP_DROP', tObject(117));
  opcodes.AddObject('OP_DUP', tObject(118));
  opcodes.AddObject('OP_NIP', tObject(119));
  opcodes.AddObject('OP_OVER', tObject(120));
  opcodes.AddObject('OP_PICK', tObject(121));
  opcodes.AddObject('OP_ROLL', tObject(122));
  opcodes.AddObject('OP_ROT', tObject(123));
  opcodes.AddObject('OP_SWAP', tObject(124));
  opcodes.AddObject('OP_TUCK', tObject(125));

  opcodes.AddObject('OP_CAT', tObject(126));
  opcodes.AddObject('OP_SUBSTR', tObject(127));
  opcodes.AddObject('OP_LEFT', tObject(128));
  opcodes.AddObject('OP_RIGHT', tObject(129));
  opcodes.AddObject('OP_SIZE', tObject(130));

  opcodes.AddObject('OP_INVERT', tObject(131));
  opcodes.AddObject('OP_AND', tObject(132));
  opcodes.AddObject('OP_OR', tObject(133));
  opcodes.AddObject('OP_XOR', tObject(134));
  opcodes.AddObject('OP_EQUAL', tObject(135));
  opcodes.AddObject('OP_EQUALVERIFY', tObject(136));
  opcodes.AddObject('OP_RESERVED1', tObject(137));
  opcodes.AddObject('OP_RESERVED2', tObject(138));

  opcodes.AddObject('OP_1ADD', tObject(139));
  opcodes.AddObject('OP_1SUB', tObject(140));
  opcodes.AddObject('OP_2MUL', tObject(141));
  opcodes.AddObject('OP_2DIV', tObject(142));
  opcodes.AddObject('OP_NEGATE', tObject(143));
  opcodes.AddObject('OP_ABS', tObject(144));
  opcodes.AddObject('OP_NOT', tObject(145));
  opcodes.AddObject('OP_0NOTEQUAL', tObject(146));
  opcodes.AddObject('OP_ADD', tObject(147));
  opcodes.AddObject('OP_SUB', tObject(148));
  opcodes.AddObject('OP_MUL', tObject(149));
  opcodes.AddObject('OP_DIV', tObject(150));
  opcodes.AddObject('OP_MOD', tObject(151));
  opcodes.AddObject('OP_LSHIFT', tObject(152));
  opcodes.AddObject('OP_RSHIFT', tObject(153));

  opcodes.AddObject('OP_BOOLAND', tObject(154));
  opcodes.AddObject('OP_BOOLOR', tObject(155));
  opcodes.AddObject('OP_NUMEQUAL', tObject(156));
  opcodes.AddObject('OP_NUMEQUALVERIFY', tObject(157));
  opcodes.AddObject('OP_NUMNOTEQUAL', tObject(158));
  opcodes.AddObject('OP_LESSTHAN', tObject(159));
  opcodes.AddObject('OP_GREATERTHAN', tObject(160));
  opcodes.AddObject('OP_LESSTHANOREQUAL', tObject(161));
  opcodes.AddObject('OP_GREATERTHANOREQUAL', tObject(162));
  opcodes.AddObject('OP_MIN', tObject(163));
  opcodes.AddObject('OP_MAX', tObject(164));

  opcodes.AddObject('OP_WITHIN', tObject(165));

  opcodes.AddObject('OP_RIPEMD160', tObject(166));
  opcodes.AddObject('OP_SHA1', tObject(167));
  opcodes.AddObject('OP_SHA256', tObject(168));
  opcodes.AddObject('OP_HASH160', tObject(169));
  opcodes.AddObject('OP_HASH256', tObject(170));
  opcodes.AddObject('OP_CODESEPARATOR', tObject(171));
  opcodes.AddObject('OP_CHECKSIG', tObject(172));
  opcodes.AddObject('OP_CHECKSIGVERIFY', tObject(173));
  opcodes.AddObject('OP_CHECKMULTISIG', tObject(174));
  opcodes.AddObject('OP_CHECKMULTISIGVERIFY', tObject(175));

  opcodes.AddObject('OP_NOP1', tObject(176));

  opcodes.AddObject('OP_NOP2', tObject(177));
  opcodes.AddObject('OP_CHECKLOCKTIMEVERIFY', tObject(177));

  opcodes.AddObject('OP_NOP3', tObject(178));
  opcodes.AddObject('OP_CHECKSEQUENCEVERIFY', tObject(178));

  opcodes.AddObject('OP_NOP4', tObject(179));
  opcodes.AddObject('OP_NOP5', tObject(180));
  opcodes.AddObject('OP_NOP6', tObject(181));
  opcodes.AddObject('OP_NOP7', tObject(182));
  opcodes.AddObject('OP_NOP8', tObject(183));
  opcodes.AddObject('OP_NOP9', tObject(184));
  opcodes.AddObject('OP_NOP10', tObject(185));

  opcodes.AddObject('OP_PUBKEYHASH', tObject(253));
  opcodes.AddObject('OP_PUBKEY', tObject(254));
  opcodes.AddObject('OP_INVALIDOPCODE', tObject(255));


FINALIZATION
  opcodes.free;

end.
