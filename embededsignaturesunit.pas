unit EmbededSignaturesUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  //desrError -> general error
  //desrPassed -> signature correct
  //desrFailed -> signature not matched with the keypresented
  //desrPubkey -> public key decoded from the signature, but there is no original key.
  tdecodeEmbededSignatureResult=(desrError,desrPassed,desrFailed,desrPubkey);

function checkAddressSignature(digest,sign,address:ansistring;out pubKey:ansistring; AddressCompressed:boolean=true):tdecodeEmbededSignatureResult;
function decodeEmbededSignature(signText,Message:string;out Pubkey:ansistring;out SignType:ansistring; out ClaimedAddress:ansistring; AddressCompressed:boolean=true):tdecodeEmbededSignatureResult;
function extractSignature(s:string; out sigtype:ansistring; out address:ansistring):ansistring;
function extractSignatures(var message:string):tStringList; overload;
function extractSignatures(var lines:tStringList):tStringList; overload;
function magicSignHash(message:ansistring;messagePrefix:ansistring=''):ansistring;

function decodeBitcoinStandartSignature(text:string;out message:string;out address:ansistring; out sign:string):boolean;

function exctractLines(message:string):tStringList;

function signMessage(message:string;privKey:ansistring;Magic:ansistring='EmerCoin Signed Message:'#10):ansistring;

implementation
uses Localizzzeunit, crypto, CryptoLib4PascalConnectorUnit, emertx;

function decodeBitcoinStandartSignature(text:string;out message:string;out address:ansistring; out sign:string):boolean;
var lines:tStringList;
    //returns:
    //cleared message
    //address in code58
    //sign in bytes
begin
  result:=false;
  message:=''; address := ''; sign:='';
  lines:=exctractLines(text);
  try
    while (lines.Count>0) and (trim(uppercase(lines[0]))<>'-----BEGIN BITCOIN SIGNED MESSAGE-----') do lines.Delete(0);
    if lines.Count=0 then exit;
    lines.Delete(0);
    //grab the message
    while (lines.Count>0) and (trim(uppercase(lines[0]))<>'-----BEGIN SIGNATURE-----') do begin
      message:=message+lines[0]+#10;
      lines.Delete(0);
    end;
    //erase last \n
    if (length(message)>2) and (copy(message,length(message)-1,2)=#13#10) then
       delete(message,length(message)-1,2)
    else
       if (message<>'') and (message[length(message)]=#10) then delete(message,length(message),1);

    if lines.Count=0 then exit;
    lines.Delete(0);
    //ok, grab address
    while trim(lines[0])='' do lines.Delete(0);  if lines.Count=0 then exit;

    address:=trim(lines[0]);
    try
      base58ToBufCheck(address);
    except
      address:='';
    end;
    lines.Delete(0);
    if lines.Count=0 then exit;
    while trim(lines[0])='' do lines.Delete(0);  if lines.Count=0 then exit;
    //grab signature
    while (lines.Count>0) and (trim(uppercase(lines[0]))<>'-----END BITCOIN SIGNED MESSAGE-----') do begin
      sign:=sign+trim(lines[0]);
      lines.Delete(0);
    end;
    if lines.Count=0 then exit;
    //ok, everything is correct. decode signarue
    try
      sign:=base64ToBuf(sign);
      result:=true;
    except
      sign:='';
    end;

  finally
    lines.free;
  end;
end;

function extractSignature(s:string; out sigtype:ansistring; out address:ansistring):ansistring;   //does not decode address
 var
   signatures:array[0..2] of ansistring=('EMSIGN','BTSIGN','ETSIGN');

 function cutSignature(var s:string):string;
 var i:integer;
 begin
   result:='';
   if (uppercase(copy(s,1,5))<>'-----') then exit;
   delete(s,1,5);
   for i:=0 to length(signatures)-1 do
     if copy(uppercase(s),1,length(signatures[i])+1)=(signatures[i]+'=') then begin
       delete(s,1,1+length(signatures[i]));
       result:=signatures[i];
       break;
     end;
 end;
 var i:integer;
begin
  //returns '' if there is no embeded signature


  //supported format:
  //-----<signature>=[address:]<signature>-----
  //signature in base64
  //address in code8check
  //signatures:
  //EMSIGN -> Emercoin signature, magic = 'EmerCoin Signed Message:'#10;
  //BTSIGN -> Bitcoin signature; magic preffix = 'Bitcoin Signed Message:'#10
  //ETSIGN -> Ethereum signatire, "Ethereum Signed Message:"#10

  sigtype:='';
  address:='';
  result:='';
  // -----EMSIGN=[85+]-----

  if length(s)<100 then exit;

  if (uppercase(copy(s,length(s)-4,5))<>'-----') then exit;

  sigtype:=cutSignature(s);
  if sigtype='' then exit;
  //[address:]<signature>
  i:= pos(':',s);
  if i>0 then begin
    address:=copy(s,1,i-1);
    delete(s,1,i);
  end;

  try
    //result:=base64ToBuf(copy(s,13,length(s)-17));
    result:=base64ToBuf(s);
    if address<>'' then base58ToBufCheck(address); //is it correct code58check?
  except
    result:='';
    address:='';
  end;


end;

function exctractLines(message:string):tStringList;
var
  s:string;
  i:integer;
begin
  s:=message+#10;
  result:=tStringList.Create;

  i:=pos(#10,s);
  while i>0 do begin
    //if (length(s)<>1) and (i>1) then //do not add last line, because we add it
    //No! Add it - it lets us to recognize if there is #10 at the end
    result.Append(copy(s,1,i-1));
    delete(s,1,i);
    i:=pos(#10,s);
  end;

end;

function extractSignatures(var message:string):tStringList;
var lines:tStringList;
    //s:string;
    i:integer;
begin
  //cut using #10
  //s:=message+#10;
  //lines:=tStringList.Create;
  lines:=exctractLines(message);
  try

    {i:=pos(#10,s);
    while i>0 do begin
      lines.Append(copy(s,1,i-1));
      delete(s,1,i);
      i:=pos(#10,s);
    end; }

    result:=extractSignatures(lines);

    //regenerate message if something was deleted
    //delete last #10 if exists. If there were lines removed - delete also #13#10 if exists
    if (result.Count>0)
      then begin
         message:='';
         for i:=0 to lines.Count-1 do
           message:=message+lines[i]+#10;

         if (length(message)>2) and (copy(message,length(message)-1,2)=#13#10)
         then
           delete(message,length(message)-1,2)
         else
           if (message<>'') and (message[length(message)]=#10) then delete(message,length(message),1);
      end;


  finally
    lines.free;
  end;
end;

function extractSignatures(var lines:tStringList):tStringList;
var
  i:integer;
  s:string;
  sign:ansistring;
  p1,p2:ansistring;
begin
  result:=tStringList.Create;
  i:=lines.Count-1;
  repeat
    s:=trim(lines[i]);
    if (length(s)>100) and (extractSignature(s,p1,p2)<>'')
    then begin
      //if it is a sign -delete all lines above
      result.Append(s);
      s:=''; //for continue
      while lines.Count>i do lines.Delete(lines.Count-1);
    end;
    dec(i);
  until (i<0) or (s<>'');

end;
(*
/**
 * Perform ECDSA key recovery (see SEC1 4.1.6) for curves over (mod p)-fields
 * recid selects which key is recovered
 * if check is non-zero, additional checks are performed
 */
int ECDSA_SIG_recover_key_GFp(EC_KEY *eckey, ECDSA_SIG *ecsig, const unsigned char *msg, int msglen, int recid, int check)
{
    if (!eckey) return 0;

    int ret = 0;
    BN_CTX *ctx = NULL;

    BIGNUM *x = NULL;
    BIGNUM *e = NULL;
    BIGNUM *order = NULL;
    BIGNUM *sor = NULL;
    BIGNUM *eor = NULL;
    BIGNUM *field = NULL;
    EC_POINT *R = NULL;
    EC_POINT *O = NULL;
    EC_POINT *Q = NULL;
    BIGNUM *rr = NULL;
    BIGNUM *zero = NULL;
    int n = 0;
    int i = recid / 2;

    const EC_GROUP *group = EC_KEY_get0_group(eckey);
    if ((ctx = BN_CTX_new()) == NULL) { ret = -1; goto err; }
    BN_CTX_start(ctx);
    order = BN_CTX_get(ctx);
    if (!EC_GROUP_get_order(group, order, ctx)) { ret = -2; goto err; }
    x = BN_CTX_get(ctx);
    if (!BN_copy(x, order)) { ret=-1; goto err; }
    if (!BN_mul_word(x, i)) { ret=-1; goto err; }
    if (!BN_add(x, x, ecsig->r)) { ret=-1; goto err; }
    field = BN_CTX_get(ctx);
    if (!EC_GROUP_get_curve_GFp(group, field, NULL, NULL, ctx)) { ret=-2; goto err; }
    if (BN_cmp(x, field) >= 0) { ret=0; goto err; }
    if ((R = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
    if (!EC_POINT_set_compressed_coordinates_GFp(group, R, x, recid % 2, ctx)) { ret=0; goto err; }
    if (check)
    {
        if ((O = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
        if (!EC_POINT_mul(group, O, NULL, R, order, ctx)) { ret=-2; goto err; }
        if (!EC_POINT_is_at_infinity(group, O)) { ret = 0; goto err; }
    }
    if ((Q = EC_POINT_new(group)) == NULL) { ret = -2; goto err; }
    n = EC_GROUP_get_degree(group);
    e = BN_CTX_get(ctx);
    if (!BN_bin2bn(msg, msglen, e)) { ret=-1; goto err; }
    if (8*msglen > n) BN_rshift(e, e, 8-(n & 7));
    zero = BN_CTX_get(ctx);
    if (!BN_zero(zero)) { ret=-1; goto err; }
    if (!BN_mod_sub(e, zero, e, order, ctx)) { ret=-1; goto err; }
    rr = BN_CTX_get(ctx);
    if (!BN_mod_inverse(rr, ecsig->r, order, ctx)) { ret=-1; goto err; }
    sor = BN_CTX_get(ctx);
    if (!BN_mod_mul(sor, ecsig->s, rr, order, ctx)) { ret=-1; goto err; }
    eor = BN_CTX_get(ctx);
    if (!BN_mod_mul(eor, e, rr, order, ctx)) { ret=-1; goto err; }
    if (!EC_POINT_mul(group, Q, eor, R, sor, ctx)) { ret=-2; goto err; }
    if (!EC_KEY_set_public_key(eckey, Q)) { ret=-2; goto err; }

    ret = 1;

err:
    if (ctx) {
        BN_CTX_end(ctx);
        BN_CTX_free(ctx);
    }
    if (R != NULL) EC_POINT_free(R);
    if (O != NULL) EC_POINT_free(O);
    if (Q != NULL) EC_POINT_free(Q);
    return ret;
}


*)


(*
Another source:
Message.magicBytes = new Buffer('Bitcoin Signed Message:\n');

Message.magicHash = function(str) {
  var magicBytes = Message.magicBytes;
  var prefix1 = BufferWriter.varintBufNum(magicBytes.length);
  var message = new Buffer(str);
  var prefix2 = BufferWriter.varintBufNum(message.length);
  var buf = Buffer.concat([prefix1, magicBytes, prefix2, message]);
  var hash = sha256sha256(buf);
  return hash;
};

*)
function magicSignHash(message:ansistring;messagePrefix:ansistring=''):ansistring;
begin
  if messagePrefix='' then
    //validation.cpp
    //messagePrefix :='Bitcoin Signed Message:'#10;
    messagePrefix :='EmerCoin Signed Message:'#10;
    //"Ethereum Signed Message:"#10

  message:=message;
  result:=dosha256(dosha256(writeScriptData(messagePrefix)+writeScriptData(message)));
end;

function checkAddressSignature(digest,sign,address:ansistring;out pubKey:ansistring; AddressCompressed:boolean=true):tdecodeEmbededSignatureResult;
begin
  result:=desrError;

  try
    pubkey:=restorePubKeyFromSign(sign,digest);
  except
    pubkey:='';
  end;

  if pubkey='' then exit;

  if address='' then begin
    result:=desrPubkey;
    exit;
  end;

  if DoRipeMD160(DoSha256(pubKeyToBuf(bufToPubKey(pubkey),AddressCompressed)))
     =
     copy(base58ToBufCheck(address),2,20)
    then result:=desrPassed
    else result:=desrFailed
end;

function signMessage(message:string;privKey:ansistring;Magic:ansistring='EmerCoin Signed Message:'#10):ansistring;
begin
  result:=ECDSAMessageSignature(privKey,magicSignHash(Message,Magic));
end;

function decodeEmbededSignature(signText,Message:string;out Pubkey:ansistring;out SignType:ansistring; out ClaimedAddress:ansistring; AddressCompressed:boolean=true):tdecodeEmbededSignatureResult;
//signText - full line with the signature
var digest:ansistring;
    sign:ansistring;
begin
  //(desrError,desrPassed,desrFailed,desrPubkey);
  result:=desrError;
  sign:=extractSignature(signText,SignType,ClaimedAddress);

  if sign='' then exit;//raise exception.create('invalid embeded signature');

  if SignType='BTSIGN'
     then digest:=magicSignHash(Message,'Bitcoin Signed Message:'#10)
  else if SignType='ETSIGN'
     then digest:=magicSignHash(Message,'Ethereum Signed Message:'#10)
  else
     digest:=magicSignHash(Message);

  result:=checkAddressSignature(digest,sign,ClaimedAddress,pubkey,AddressCompressed);

end;

end.

