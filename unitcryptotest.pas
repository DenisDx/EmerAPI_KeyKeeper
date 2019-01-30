unit unitCryptoTest;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, ComCtrls;

type

  { TcryptoTestForm }

  TcryptoTestForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    Button18: TButton;
    Edit31: TEdit;
    enc_88: TBitBtn;
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    chByDenis: TCheckBox;
    CheckBox3: TCheckBox;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit19: TEdit;
    Edit2: TEdit;
    Edit20: TEdit;
    Edit21: TEdit;
    Edit22: TEdit;
    Edit23: TEdit;
    Edit24: TEdit;
    Edit25: TEdit;
    Edit26: TEdit;
    Edit27: TEdit;
    Edit28: TEdit;
    Edit29: TEdit;
    Edit3: TEdit;
    Edit30: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo2: TMemo;
    Memo3: TMemo;
    PageControl1: TPageControl;
    Memo1: TMemo;
    Password: TEdit;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    Splitter1: TSplitter;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure enc_88Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
//    procedure Button10Click(Sender: TObject);
//    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure fillAllForBuf(s:ansistring;excl:tEdit=nil);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Edit19Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
  private

  public

  end;

var
  cryptoTestForm: TcryptoTestForm=nil;

implementation
uses USha256, crypto, CryptoLib4PascalConnectorUnit, UOpenSSLdef, UOpenSSL, PodbiralkaUnit
  ,fpjson, jsonparser
  ,EmerApiTestUnit

    ,ClpIX9ECParameters
  ,ClpIECDomainParameters
  ,ClpECDomainParameters
  ,ClpIECKeyPairGenerator
  ,ClpIECKeyGenerationParameters
  ,ClpBigInteger
  ,ClpCustomNamedCurves
  ,HlpHashFactory
  ,ClpIECInterface

  ,PasswordHelper

  ,HDNodeUnit

  ,HelperUnit
  ;


{$R *.lfm}



(*

function signECDSA(hash:ansistring; d:PBIGNUM{key^...}):PECDSA_SIG;
  var N_OVER_TWO:PBIGNUM;// = secp256k1.n.shiftRight(1)
  var x:ansistring; // = d.toBuffer(32)
  var e:PBIGNUM; // = BigInteger.fromBuffer(hash)
  var n:PBIGNUM; // = secp256k1.n
  var G:PEC_POINT; // = secp256k1.G  //point

    //var r, s <-result^._r, result^._s
  procedure initConsts();
  begin
    x := bignumToBuf(d); while length(x)<32 do x:=#0+x;
    e := bufToBigNum(hash);
    n := secp256k1.n
    G := secp256k1.G  //point
  end;


  function deterministicGenerateK(hash, x:ansistring{32}):PECDSA_SIG;
    function checkSig(k)
    begin
        var Q = G.multiply(k)

        if (secp256k1.isInfinity(Q)) return false

        r = Q.affineX.mod(n)
        if (r.signum() === 0) return false

        s = k.modInverse(n).multiply(e.add(d.multiply(r))).mod(n)
        if (s.signum() === 0) return false

        return true
    end;

  begin
    typeforce(types.tuple(
      types.Hash256bit,
      types.Buffer256bit,
      types.Function
    ), arguments)

    // Step A, ignored as hash already provided
    // Step B
    // Step C
    var k = Buffer.alloc(32, 0)
    var v = Buffer.alloc(32, 1)

    // Step D
    k = createHmac('sha256', k)
      .update(v)
      .update(ZERO)
      .update(x)
      .update(hash)
      .digest()

    // Step E
    v = createHmac('sha256', k).update(v).digest()

    // Step F
    k = createHmac('sha256', k)
      .update(v)
      .update(ONE)
      .update(x)
      .update(hash)
      .digest()

    // Step G
    v = createHmac('sha256', k).update(v).digest()

    // Step H1/H2a, ignored as tlen === qlen (256 bit)
    // Step H2b
    v = createHmac('sha256', k).update(v).digest()

    var T = BigInteger.fromBuffer(v)

    // Step H3, repeat until T is within the interval [1, n - 1] and is suitable for ECDSA
    while (T.signum() <= 0 || T.compareTo(secp256k1.n) >= 0 || !checkSig(T)) {
      k = createHmac('sha256', k)
        .update(v)
        .update(ZERO)
        .digest()

      v = createHmac('sha256', k).update(v).digest()

      // Step H1/H2a, again, ignored as tlen === qlen (256 bit)
      // Step H2b again
      v = createHmac('sha256', k).update(v).digest()
      T = BigInteger.fromBuffer(v)
    }

    return T
  end;//deterministicGenerateK
begin
  initConsts;

  //typeforce(types.tuple(types.Hash256bit, types.BigInt), arguments)
  if length(hash)<>32 then raise exception.create('sign: wrong hash size');

  result:=deterministicGenerateK(hash, x);

  // enforce low S values, see bip62: 'low s values in signatures'
  //if (s.compareTo(N_OVER_TWO) > 0) {
  //  s = n.subtract(s)
  //}
  if result^._s > N_OVER_TWO then result^._s := n-s ?!?

end;


*)

{
procedure TcryptoTestForm.Button10Click(Sender: TObject);

  Var PECS : PECDSA_SIG;
    d:pBigNum;
  p : PAnsiChar;
  i : Integer;
  digest:ansistring;
  r,s:ansistring;
  key:PEC_KEY;

  rp:pointer;
  kinv: PBIGNUM;
  dl:TC_INT;
  ctx : BN_CTX;
  _type: TC_INT;

  ps:pAnsiChar;
  _dgstlen: TC_INT;
  _sig: PAnsiChar; _siglen: TC_UINT;
  pp:pointer;
  fori:integer;





  mdctx:^EVP_MD_CTX;
  ret:integer;
  sig:pchar;

  ECS : ECDSA_SIG;
  pbr,pbs:pBIGNUM;

  pubKey:TECDSA_Public;
  group: PEC_GROUP;
  order:PBIGNUM;
  halforder:PBIGNUM;
begin

 if not LoadSSLCrypt() then exit;
 InitCrypto;

 s:=base58ToBufcheck(trim(edit1.text));

 if s[1]<>hexToBuf( trim(edit12.text))
   then raise exception.create('Wrong wif signature. Must be '+bufToHex(hexToBuf( trim(edit12.text)))+' but found '+bufToHex(s[1]));
 delete(s,1,1);//удаляем сингатуру
 if not (((length(s)=33) and (s[33]=#1)) or (length(s)=32))
    then raise exception.create('wrong private key size');
 CheckBox1.checked:=((length(s)=33) and (s[33]=#1));
 Key:=CreatePrivateKeyFromStrBuf(s);

 ///////////////
 d:=EC_KEY_get0_private_key(key);
//!!!! PECS:=signECDSA(doSHA256('test'),d);


 memo1.Lines.Append('r='+bufToHex(bignumToBuf(PECS^._r)));
 memo1.Lines.Append('s='+bufToHex(bignumToBuf(PECS^._s)));


 BN_free(d);
 EC_KEY_free(key);
{

 // Key:=CreatePrivateKeyFromStrBuf(DoSha256( trim(edit1.text)));
 //! Key^.group:=EC_GROUP_new_by_curve_name(CT_NID_secp256k1);
  //Key^.pub_key:=nil;//GetPublicKey(Key);

  pubKey:=GetPublicKey(Key);
  memo1.Lines.Append( 'pubKey='+ publicKey2Address(pubKey,chr(strtoint(edit13.text)),checkbox1.checked));
  {
  Key := EC_KEY_new_by_curve_name(CT_NID_secp256k1);
  If Not Assigned(Key) then Exit;
  EC_KEY_generate_key(Key);
  pubKey:=GetPublicKey(Key);
   }

  //digest:='12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
  //digest:=#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
  digest:=doSHA256('12345');



//  EVP_DigestInit_ex: function(ctx: PEVP_MD_CTX; const _type: PEVP_MD; impl: PENGINE): TC_INT; cdecl = nil;
//  EVP_DigestUpdate: function(ctx: PEVP_MD_CTX;const d: Pointer; cnt: TC_SIZE_T): TC_INT; cdecl = nil;
//  EVP_DigestFinal_ex: function(ctx: PEVP_MD_CTX;md: PAnsiChar;var s: TC_INT): TC_INT; cdecl = nil;



(*

  //EVP_MD_CTX *mdctx = NULL;
  mdctx:=nil;
  ret := 0;
  sig:=nil; //*sig = NULL;

  //  /* Create the Message Digest Context */
  //if(!(mdctx = EVP_MD_CTX_create())) goto err;
  mdctx := EVP_MD_CTX_new();
  if mdctx=nil then raise exception.create('err: EVP_MD_CTX_new() returns nil');

  //* Initialise the DigestSign operation - SHA-256 has been selected as the message digest function in this example */
  //   if(1 != EVP_DigestSignInit(mdctx, NULL, EVP_sha256(), NULL, key)) goto err;
  //EVP_DigestInit_ex: function(ctx: PEVP_MD_CTX; const _type: PEVP_MD; impl: PENGINE): TC_INT; cdecl = nil;
  if EVP_DigestSignInit(mdctx, nil, EVP_sha256(), nil, key)<>1 then raise exception.create('err: EVP_DigestSignInit() <>1');

     /* Call update with the message */
     if(1 != EVP_DigestSignUpdate(mdctx, msg, strlen(msg))) goto err;

     /* Finalise the DigestSign operation */
     /* First call EVP_DigestSignFinal with a NULL sig parameter to obtain the length of the
      * signature. Length is returned in slen */
     if(1 != EVP_DigestSignFinal(mdctx, NULL, slen)) goto err;
     /* Allocate memory for the signature based on size in slen */
     if(!( *sig = OPENSSL_malloc(sizeof(unsigned char) * ( *slen)))) goto err;
     /* Obtain the signature */
     if(1 != EVP_DigestSignFinal(mdctx, *sig, slen)) goto err;

     /* Success */
     ret = 1;

     err:
     if(ret != 1)
     {
       /* Do some error handling */
     }

     /* Clean up */
     if( *sig && !ret) OPENSSL_free( *sig);
     if(mdctx) EVP_MD_CTX_destroy(mdctx);




     *)









 // ECDSA_sign_setup: function(_eckey: PEC_KEY; _ctx: PBN_CTX; _kinv: PPBIGNUM; _rp: PPBIGNUM): TC_INT; cdecl = nil;
 _dgstlen:=length(digest); ps:=@digest[1];

// pbr:=BN_new();
// pbs:=BN_new();

for fori:=0 to 1 do begin


  //_dgstlen:=32;

  //PECS:=ECDSA_do_sign(ps,_dgstlen,Key);

  //ECDSA_SIG_get0: procedure(const _sig : PECDSA_SIG; const pr: PPBIGNUM; const ps:PPBIGNUM);
  PECS:=ECDSA_do_sign(ps,_dgstlen,Key);



  ECDSA_SIG_get0(PECS,@pbr,@pbs);
 {
  ECS:=PECS^;
  BN_copy(pbr,ECS._r);
  BN_copy(pbs,ECS._s);
  }

  //BN_copy: function(a: PBIGNUM;b: PBIGNUM): PBIGNUM; cdecl = nil;

//  PECS := PPECDSA_SIG(pp)^;


//  rp:=nil; kinv:=nil; dl:=length(digest);
  //ctx:=nil;

//  ps:=@digest[1];

//  ECDSA_sign_setup(Key,@ctx,@kinv,@rp);
//  PECS := ECDSA_do_sign_ex(@digest[1],dl,rp,kinv,Key);

//     ECDSA_do_sign: function(const _dgst: PAnsiChar; _dgst_len: TC_INT;                                           _eckey: PEC_KEY): PECDSA_SIG; cdecl = nil;
//  ECDSA_do_sign_ex: function(const _dgst: PAnsiChar;  _dgstlen: TC_INT; const _kinv: PBIGNUM; const _rp: Pointer; _eckey: PEC_KEY): PECDSA_SIG; cdecl = nil;
//          ECDSA_sign: function(_type: TC_INT; const _dgst: PAnsiChar; _dgstlen: TC_INT; _sig: PAnsiChar; var _siglen: TC_UINT; _eckey: PEC_KEY): TC_INT; cdecl = nil;

{
  _type:=0; _dgstlen:=length(digest);
  ECDSA_sign(_type,@ps, _dgstlen, @_sig,_siglen,key);
  setLength(s,_siglen);
  move(_sig,s[1],_siglen);
  memo1.Lines.Append('res='+bufToHex(s));
  exit;
}

  Try
    if PECS = Nil then raise Exception.Create('ECDSASign: Error signing');

    i := BN_num_bytes(PECS^._r);
    SetLength(r,i);
    //p := @Result.r[1];
    //i := BN_bn2bin(PECS^._r,p);
    i := BN_bn2bin(PECS^._r,@r[1]);

    i := BN_num_bytes(PECS^._s);
    SetLength(s,i);
    //p := @Result.s[1];
    //i := BN_bn2bin(PECS^._s,p);
    i := BN_bn2bin(PECS^._s,@s[1]);


    //SetLength(Result.y,BN_num_bytes(BNy));
    //BN_bn2bin(BNy,@Result.y[1]);

   // memo1.Lines.Append('r1='+bufToHex(bignumToBuf(pbr)));
   // memo1.Lines.Append('s1='+bufToHex(bignumToBuf(pbs)));
  Finally
    ECDSA_SIG_free(PECS);
  End;

  //memo1.Lines.Append('prk='+bufToHex(bignumToBuf(Key^.priv_key)));





  memo1.Lines.Append('prk='+privKeyToCode58(Key, chr(strtoint(edit12.text)),CheckBox1.checked));
//  memo1.Lines.Append('prk[0]='+bufToHex(bignumToBuf(EC_KEY_get0_private_key(Key))));


  memo1.Lines.Append('r='+bufToHex(r));
  memo1.Lines.Append('s='+bufToHex(s));

  //memo1.Lines.Append('r1='+bufToHex(bignumToBuf(pbr)));
  //memo1.Lines.Append('s1='+bufToHex(bignumToBuf(pbs)));


end;
//!  EC_GROUP_free(key^.group);
  key^.group:=nil;
//  BN_free(pbr);
EC_KEY_free(key);
//  BN_free(pbs);
   }

end;
}

function bufToSmart16(s:ansistring):ansistring;
var i:integer;
begin
  result:='';
  for i:=1 to length(s) do
    if ord(s[i])<32
      then result:=result+'%'+inttohex(ord(s[i]),2)
      else result:=result+s[i];

end;

function smartToBuf16(s:ansistring):ansistring;
var i:integer;
begin
 //символ символ %hex
 result:='';
 i:=1;
 while i<=length(s) do
   if s[i]='%' then begin
     result:=result+hexToBuf(copy(s,i+1,2));
     i:=i+3;
   end else begin
     result:=result+s[i];
     i:=i+1;
   end;
end;


function smartToBuf(s:ansistring):ansistring;
begin
 if pos('%',s)>0 then begin
   result:=smartToBuf16(s);
 end else
 if pos('\',s)>0 then begin
   s:=trim(s);
   result:=octMixToBuf(s);
 end else
 begin
   //hex
   s:=trim(s);
   while pos(' ',s)>0 do delete(s,pos(' ',s),1);
   result:=hexToBuf(s);
 end;
end;


procedure TcryptoTestForm.BitBtn1Click(Sender: TObject);
var pass:ansistring;
begin

  if CheckBox3.Checked
    then pass:=HexToBuf(Password.Text)
    else pass:=Password.Text;


  case RadioGroup2.ItemIndex of
    0:memo3.text:= bufToHex(Encrypt_AES256(memo2.Text,pass));
    1:memo3.text:= bufToHex(Encrypt_AES256_CBC(memo2.Text,pass));
    2:memo3.text:= bufToHex(Encrypt_AES256_CTR(memo2.Text,pass));
  else
    raise exception.Create('Not supported');
  end;


end;

procedure TcryptoTestForm.BitBtn2Click(Sender: TObject);
var pass:ansistring;
begin
  //https://asecuritysite.com/encryption/ecc3
  //priv: c9f4f55bdeb5ba0bd337f2dbc952a5439e20ef9af6203d25d014e7102d86aaee
  //pub 03C44370819CB3B7B57B2AA7EDF550A9A5410C234D27AFF497458BBBFEC8B6A327
  //  5273534b2f44726c58644137492b714b6f2b794f6b673d3d  -> Hello

 //http://point-at-infinity.org/ecc/nisttv
  if CheckBox3.Checked
    then pass:=HexToBuf(Password.Text)
    else pass:=Password.Text;

  case RadioGroup2.ItemIndex of
    0:memo2.text:= Decrypt_AES256(hexToBuf(trim(memo3.Text)),pass);
    1:memo2.text:= Decrypt_AES256_CBC(hexToBuf(trim(memo3.Text)),pass);
    //2:memo2.text:= Decrypt_AES256_CTR(hexToBuf(trim(memo3.Text)),Password.Text);
  else
    raise exception.Create('Not supported');
  end;




end;

procedure TcryptoTestForm.BitBtn3Click(Sender: TObject);
begin
  if chByDenis.Checked
    then memo3.Text:= bufToHex(encrypt_EC2(memo2.Text,hexToBuf(Edit28.text)))
    else memo3.Text:= bufToHex(encrypt_EC(memo2.Text,hexToBuf(Edit28.text)));
end;

procedure TcryptoTestForm.BitBtn4Click(Sender: TObject);
var s:ansistring;
begin


s:=base58ToBufCheck(trim(edit29.text));

//if s[1]<>hexToBuf( trim(edit12.text))
//  then raise exception.create('Wrong wif signature. Must be '+bufToHex(hexToBuf( trim(edit12.text)))+' but found '+bufToHex(s[1]));
//delete(s,1,1);//удаляем сингатуру

//if not (((length(s)=33) and (s[33]=#1)) or (length(s)=32))
//   then raise exception.create('wrong private key size');

//CheckBox1.checked:=((length(s)=33) and (s[33]=#1));

//PrivateKey:=CreatePrivateKeyFromStrBuf(s);


 delete(s,1,1);
 if chByDenis.Checked
   then memo2.Text:=Decrypt_EC2(hexToBuf(memo3.Text),CreatePrivateKeyFromStrBuf(s))
   else memo2.Text:=Decrypt_EC(hexToBuf(memo3.Text),CreatePrivateKeyFromStrBuf(s));
end;

procedure TcryptoTestForm.BitBtn5Click(Sender: TObject);
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
  //rnd:=buf2TBigInteger(randomKey);
  rnd:=buf2TBigInteger(hexToBuf('8888888888888888888888888888888888888888888888888888888888888888'));
  //2. R = rnd*G
  R:=Lcurve.G.Multiply(rnd);
  //3. S = rnd*Q
  S:=bufToiecPoint(hexToBuf(Edit28.text)).Multiply(rnd);
  //calc result = R + encrypted_data. Compression is used! password = compressed S
  //result:= iecPointToBuf(R,true) + Encrypt_AES256(data,iecPointToBuf(S,true));


//  memo1.Append('R(rand=[88]).x='+bufToHex(TBigInteger2buf(R.XCoord.ToBigInteger())));
//  memo1.Append('S(rand=[88]).x='+bufToHex(TBigInteger2buf(S.XCoord.ToBigInteger())));
  memo1.Append('R(rand=[88])='+bufToHex(iecPointToBuf(R,true)));
  memo1.Append('S(rand=[88])='+bufToHex(iecPointToBuf(S,true)));

  memo1.Append('S(rand=[88])*d='+bufToHex(iecPointToBuf(S.Multiply(Buf2TbigInteger(base58ToBufCheck(trim(edit29.text)))),true)));

  memo1.Append('S(rand=[88]) sha='+bufToHex(dosha256(iecPointToBuf(S,true) )));

end;

procedure TcryptoTestForm.Button18Click(Sender: TObject);
begin
   fillAllForBuf(base64ToBuf(edit31.Text),Edit31);
end;

procedure TcryptoTestForm.enc_88Click(Sender: TObject);
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
  //rnd:=buf2TBigInteger(randomKey);
  rnd:=buf2TBigInteger(hexToBuf('8888888888888888888888888888888888888888888888888888888888888888'));
  //2. R = rnd*G

  R:=Lcurve.G.Multiply(rnd);
  //3. S = rnd*Q
  S:=bufToiecPoint(hexToBuf(Edit28.text)).Multiply(rnd);
  //calc result = R + encrypted_data. Compression is used! password = sha256(compressed S)
  memo1.Append(
    'enc_88(''8888'')='+bufToHex(Encrypt_AES256('8888',dosha256(iecPointToBuf(S,true))))
  );

end;

procedure TcryptoTestForm.Button10Click(Sender: TObject);
begin
  memo3.Text:=bufToHex(dosha256(trim(memo2.Text)));
end;

procedure TcryptoTestForm.Button11Click(Sender: TObject);
var s:ansistring;
begin

  s:=createBIP32seed(trim(edit1.text),trim(combobox1.Text), strtoint(Edit17.Text));

  Edit6.text:=bufToHex(s);

//  s:= createHmac('sha512', HDNode.MASTER_SECRET).update(seed).digest()
  {
  //Edit6.text:='';
  s:=trim(edit1.text);
  s:=bip39tobytes(s);
  if s<>''
     //then Edit6.text:=bufToHex(createBIP32seed(s,trim(Edit16.Text)))
     then Edit6.text:=bufToHex(createBIP32seed(trim(edit1.text),trim(Edit16.Text)))
     else Edit6.text:='Invalid BIP39 password';
}
   {
if (seed.length < 16) throw new TypeError('Seed should be at least 128 bits')
if (seed.length > 64) throw new TypeError('Seed should be at most 512 bits')

var I = createHmac('sha512', HDNode.MASTER_SECRET).update(seed).digest()
var IL = I.slice(0, 32)
var IR = I.slice(32)

// In case IL is 0 or >= n, the master key is invalid
// This is handled by the ECPair constructor
var pIL = BigInteger.fromBuffer(IL)
var keyPair = new ECPair(pIL, null, {
  network: network
})

return new HDNode(keyPair, IR)
    }
end;

procedure TcryptoTestForm.Button12Click(Sender: TObject);
begin
  combobox1.Text:='mnemonic';
  edit17.Text:='2048';
end;

procedure TcryptoTestForm.Button13Click(Sender: TObject);
begin
  combobox1.Text:='witnesskey';
  //edit17.Text:='4096';
  edit17.Text:='2048';
end;

procedure TcryptoTestForm.Button14Click(Sender: TObject);
var i:integer;
    s:ansistring;

    function version_number(seed_phrase:ansistring):word;
    var s:ansistring;
    begin
      //skip prep
      //hmac_sha_512("Seed version", normalized)
       //s:=createBIP32seed(seed_phrase,'Seed version', 1{strtoint(Edit17.Text)});
      s:=createBIP32seed(seed_phrase,{'Seed version'}trim(Edit20.text), 1{strtoint(Edit17.Text)});
      //s:=bufToHex(s);
      if ord(s[1]) div 16 = 0
          then result:= ord(s[1])
          else result:= ord(s[1])*16+ord(s[2]) div 16;
    end;

begin
  {
  def version_number(seed_phrase):
  # normalize seed
  normalized = prepare_seed(seed_phrase)
  # compute hash
  h = hmac_sha_512("Seed version", normalized)
  # use hex encoding, because prefix length is a multiple of 4 bits
  s = h.encode('hex')
  # the length of the prefix is written on the fist 4 bits
  # for example, the prefix '101' is of length 4*3 bits = 4*(1+2)
  length = int(s[0]) + 2
  # read the prefix
  prefix = s[0:length]
  # return version number
  return hex(int(prefix, 16))
  }

  for i:=0 to 2047 do begin
    //s:=createBIP32seed(trim(edit1.text)+' '+bip0039english[i],trim(combobox1.Text), strtoint(Edit17.Text));
    //if ord(s[1])=strtoint(Edit16.Text) then begin
    //if version_number(trim(edit1.text)+' '+bip0039english[i])=strtoint(Edit16.Text) then begin
    //if bip39toEntropy(trim(edit1.text)+' '+bip0039english[i])<>'' then begin
    s:=trim(edit1.text)+' '+bip0039english[i];
    if checkEntropy(bip39tobytes(s))
        and
       (version_number(s)=strtoint(Edit16.Text))
    then begin
      edit1.text:=trim(edit1.text)+' '+bip0039english[i];
      exit;
    end;
  end;
end;

procedure TcryptoTestForm.Button15Click(Sender: TObject);
begin
  Edit22.Text:='0x0488ADE4';
  Edit23.Text:='0x0488B21E';

  Edit12.Text:='$80';
  Edit13.Text:='$21';
end;

procedure TcryptoTestForm.Button16Click(Sender: TObject);
begin
  Edit22.Text:='0x04358394';
  Edit23.Text:='0x043587CF';

  Edit12.Text:='$EF';
  Edit13.Text:='$6F';
end;

procedure TcryptoTestForm.Button17Click(Sender: TObject);
begin
 fillAllForBuf(SmartToBuf16(edit30.Text),Edit30);
//  Edit8.Text:=bufToHex(SmartToBuf16(edit30.Text));
//  Edit7.text:=buf2Base58Check(hexToBuf(Edit8.Text));
//  Edit9.text:=buf2Base58(hexToBuf(Edit8.Text));
end;


function TBigInteger2buf(d:TBigInteger):ansistring;
var ar:array of byte;
begin
  ar:=d.ToByteArray();
  setLength(result,length(ar));
  move(ar[0],result[1],length(ar));
  while (length(result)>1) and (result[1]=#0) do delete(result,1,1);
end;

function buf2TBigInteger(buf:ansistring):TBigInteger;
var ar:array of byte;
begin
  setLength(ar,length(buf));
  move(buf[1],ar[0],length(buf));
  result:=TBigInteger.Create(1,ar);
end;


procedure TcryptoTestForm.Button1Click(Sender: TObject);
var
  Lcurve: IX9ECParameters;
  domain: IECDomainParameters;
  generator: IECKeyPairGenerator;
  keygenParams: IECKeyGenerationParameters;

  var PrivD,Dmax, P: TBigInteger;
      Q:IECPoint;
  buf,s:ansistring;
  var ar:array of byte;
begin
  Lcurve := TCustomNamedCurves.GetByName('secp256k1');
  System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');
  //domain := TECDomainParameters.Create(Lcurve.Curve, Lcurve.G, Lcurve.N, Lcurve.H, Lcurve.GetSeed);
  Dmax:=TBigInteger.Create('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',16);
  P:=TBigInteger.Create('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',16);



  buf:=trim(edit1.text);
  setLength(ar,length(buf));
  move(buf[1],ar[0],length(buf));
  PrivD := TBigInteger.Create(1, THashFactory.TCrypto.CreateSHA2_256().ComputeBytes(ar).GetBytes());

  if (PrivD.CompareTo(Dmax)<0) and (PrivD.CompareTo(TBigInteger.Zero)>0) then
  begin
   //Q:=G*d
   Q:=Lcurve.G.Multiply(PrivD);

   if Q.IsValid() then begin
       //pubkey.EC_OpenSSL_NID:=CT_NID_secp256k1;
       //pubkey.x:=TBigInteger2buf(Q.XCoord.ToBigInteger());
       //pubkey.y:=TBigInteger2buf(Q.YCoord.ToBigInteger());
      memo3.Text:='D='+bufToHex(TBigInteger2buf(PrivD));
      memo3.Lines.Append('        curve.G='+bufToHex(TBigInteger2buf(Lcurve.G.XCoord.ToBigInteger()))+' : '+bufToHex(TBigInteger2buf(Lcurve.G.YCoord.ToBigInteger())));
      memo3.Lines.Append('Affine: curve.G='+bufToHex(TBigInteger2buf(Lcurve.G.AffineXCoord.ToBigInteger()))+' : '+bufToHex(TBigInteger2buf(Lcurve.G.AffineYCoord.ToBigInteger())));
      memo3.Lines.Append('X='+bufToHex(TBigInteger2buf(Q.XCoord.ToBigInteger())));
      memo3.Lines.Append('Y='+bufToHex(TBigInteger2buf(Q.YCoord.ToBigInteger())));

      memo3.Lines.Append('G.X*D='+bufToHex(TBigInteger2buf(Lcurve.G.XCoord.ToBigInteger().Multiply(PrivD).&Mod(P))));
      memo3.Lines.Append('G.Y*D='+bufToHex(TBigInteger2buf(Lcurve.G.YCoord.ToBigInteger().Multiply(PrivD).&Mod(P))));

      memo3.Lines.Append('Xn='+bufToHex(TBigInteger2buf(Q.Normalize().XCoord.ToBigInteger())));
      memo3.Lines.Append('Yn='+bufToHex(TBigInteger2buf(Q.Normalize().YCoord.ToBigInteger())));
   end;
  end;
end;


procedure TcryptoTestForm.Button2Click(Sender: TObject);
var PrivateKey:ansistring;
    pubKey:TECDSA_Public;
    pubKey1:TECDSA_Public;

    bn:PBIGNUM;

    s:ansistring;
var
  HDNode:tHDNode;
  networkData:tnetworkData;



begin
  //if not LoadSSLCrypt() then exit;
  //InitCrypto;

  if RadioGroup1.ItemIndex=3 then begin
    try
      s:=base58ToBuf(trim(edit1.text));

      if (length(s)=(32+5))
         or ((length(s)=(33+5)) and (s[33+1]=#1)) then
      begin
        RadioGroup1.ItemIndex:=2;
        edit12.text:='$'+inttohex(ord(s[1]),2);
      end else raise exception.create('try next');
    except
      try
        s:=hexToBuf( trim(edit1.text));
        if not (((length(s)=33) and (s[33]=#1)) or (length(s)=32))
           then RadioGroup1.ItemIndex:=0
           else RadioGroup1.ItemIndex:=1;
      except
        RadioGroup1.ItemIndex:=0;
      end;
    end;
  end;

  case RadioGroup1.ItemIndex of
    0:begin
      if checkBox2.Checked then begin
         //hd
        s:=normalizeBip(edit1.text);

        if s='' then begin
          s:=getBip39FromMasterPassword(trim(edit1.text));
          showMessage('BIP created from the master password: '+s);
        end;

        s:=createBIP32seed(s,trim(combobox1.Text), strtoint(Edit17.Text));
        Edit6.text:=bufToHex(s);
        {
        DeterministicKey deterministicKey = HDKeyDerivation.createMasterPrivateKey(seed);
        child0 = HDKeyDerivation.deriveChildKey(deterministicKey, 0);
        ....

                    DeterministicKey child = HDKeyDerivation.deriveChildKey(child0, i);
                    byte[] child1hash160 = child.getIdentifier();
                    com.matthewmitchell.peercoinj.core.Address a = new com.matthewmitchell.peercoinj.core.Address(networkParameters, child1hash160);

                    SharedPreferencesHelper.getInstance().putStringValue(a.toString(), child.getPrivateKeyAsHex());
                    EmcAddress emcAddress = new EmcAddress("", a.toString());
                    App.getDbInstance().emcAddressDao().insertAll(emcAddress);
       //------------------------------------------------------------------------
       typeforce(types.tuple(types.Buffer, types.maybe(types.Network)), arguments)

       if (seed.length < 16) throw new TypeError('Seed should be at least 128 bits')
       if (seed.length > 64) throw new TypeError('Seed should be at most 512 bits')

       var I = createHmac('sha512', HDNode.MASTER_SECRET).update(seed).digest()
       var IL = I.slice(0, 32)
       var IR = I.slice(32)

       // In case IL is 0 or >= n, the master key is invalid
       // This is handled by the ECPair constructor
       var pIL = BigInteger.fromBuffer(IL)
       var keyPair = new ECPair(pIL, null, {
         network: network
       })

       return new HDNode(keyPair, IR)
       }

        //function hmac_sha512(buf:ansistring;pass:ansistring;iterCount:integer=1):ansistring;
        if (length(s)>64) or (length(s)<16) then Edit21.Text:='WRONG SEED'
        else begin

          s:= hmac_sha512(s,trim(Edit18.Text));
          //s:= hmac_sha512('!','!');


          //s:= hmac_sha512(trim(Edit18.Text),s,1);
          //s:= hmac_sha512(s,trim(Edit18.Text),0);

          //s:=copy(s,33,32)+copy(s,1,32);
          networkData.wif:=chr(strToInt(Edit12.Text));
          networkData.bip32.VerPrivate:=myStrToInt(Edit22.Text);
          networkData.bip32.VerPublic:=myStrToInt(Edit23.Text);

          HDNode.loadFromKey(s,networkData,0,0,0);
          //PrivateKey:=CreatePrivateKeyFromStrBuf(copy(s,1,32));
          PrivateKey:=HDNode.getPrivateKey;

          if PrivateKey<>'' then begin
            Edit21.Text:=HDNode.asCode58;
            button3.Click;;
            //HDNode:=HDNode.derive(0);
            //HDNode:=HDNode.derive(0);
            //Edit24.Text:=HDNode.asCode58;
            //Edit25.Text:=privKeyToCode58(HDNode.getPrivateKey);
            //Edit26.Text:=publicKey2Address(GetPublicKey(HDNode.getPrivateKey),chr(strtoint(edit13.text)),checkbox1.checked);
          end else begin
            Edit21.Text:='invalid private key';
            Edit24.Text:='';
            Edit25.Text:='';
            Edit26.Text:='';
          end;



        end;
      end else
        PrivateKey:=CreatePrivateKeyFromStrBuf(DoSha256( trim(edit1.text)));

    end;
    1:begin
        s:=hexToBuf( trim(edit1.text));
        if not (((length(s)=33) and (s[33]=#1)) or (length(s)=32))
                   then raise exception.create('wrong private key size');
        CheckBox1.checked:=((length(s)=33) and (s[33]=#1));
        PrivateKey:=CreatePrivateKeyFromStrBuf(s);
    end;
    2:begin
        s:=base58ToBuf(trim(edit1.text));

        if copy(s,length(s)-3,4)<> Copy(DoSha256(DoSha256(copy(s,1,length(s)-4))),1,4)
           then raise exception.create('Wrong sha256 signature. Must be '+bufToHex(copy(s,length(s)-3,4))+' but calculated '+
             bufToHex(Copy(DoSha256(DoSha256(copy(s,1,length(s)-4))),1,4))
           );
        delete(s,length(s)-3,4);//удаляем CRC

        if s[1]<>hexToBuf( trim(edit12.text))
          then raise exception.create('Wrong wif signature. Must be '+bufToHex(hexToBuf( trim(edit12.text)))+' but found '+bufToHex(s[1]));
        delete(s,1,1);//удаляем сингатуру

        if not (((length(s)=33) and (s[33]=#1)) or (length(s)=32))
           then raise exception.create('wrong private key size');

        CheckBox1.checked:=((length(s)=33) and (s[33]=#1));

        PrivateKey:=CreatePrivateKeyFromStrBuf(s);

      end;
  else
    raise exception.create('Фигня какая-то');
  end;


  pubKey:=GetPublicKey(PrivateKey);


  edit2.Text:=privKeyToCode58(PrivateKey, chr(strtoint(edit12.text)),CheckBox1.checked);


  //bn:=EC_KEY_get0_private_key(PrivateKey);
  //edit5.Text:=bufToHex(bignumToBuf(bn));
  edit5.Text:=bufToHex(PrivateKey);

  Edit4.text := 'x=' +bufToHex(pubkey.x) + '  y='+ bufToHex(pubkey.y);

  Edit14.Text:= bufToHex(pubKeyToBuf(pubKey)) ;

  pubKey1:= bufToPubkey(hexToBuf(trim(Edit14.Text)));
  Edit15.text := 'x=' +bufToHex(pubkey1.x) + '  y='+ bufToHex(pubkey1.y);



  try
    Edit3.Text := publicKey2Address(pubKey,chr(strtoint(edit13.text)),checkbox1.checked); //ToHexaString(GetPublicKey(PrivateKey).x);
  except
    Edit3.Text := 'WRONG KEY!';
  end;

//  edit6.Text:='new: '+buf2Base58Check(#33#33#33) + ' old: '+raw2code58old(#33#33#33);


  if checkbox1.checked then begin
    if (ord(pubkey.y[length(pubkey.y)-1]) mod 2)<>0
       then s:=#02 //Even
       else s:=#03;//нечет

    s:=s + pubkey.x;
  end else begin
      s:= #4 + pubkey.x + pubkey.y;
  end;
  edit10.Text:= bufToHex(DoRipeMD160(DoSha256(s)));


  edit11.Text:= buf2Base58Check(#0+DoRipeMD160(DoSha256(s)));


  //if Assigned(PrivateKey) then EC_KEY_free(PrivateKey);

  button11click(nil);


  s:=bip39tobytes(trim(edit1.text));
  if checkEntropy(s)
      then Edit19.text:=bufToHex(shrbuf(s,(length(s)*8) div 33 ,true))
      else Edit19.text:='Entropy crc error';
end;

procedure TcryptoTestForm.Button3Click(Sender: TObject);
var
  HDNode:tHDNode;
  networkData:tnetworkData;
  s:ansistring;
begin

  networkData.wif:=chr(strToInt(Edit12.Text));
  networkData.pubKeySig:=chr(strToInt(Edit13.Text));
  networkData.bip32.VerPrivate:=myStrToInt(Edit22.Text);
  networkData.bip32.VerPublic:=myStrToInt(Edit23.Text);

  HDNode.loadFromCode58(Edit21.Text,networkData);
   //networkData.wif:=chr(strToInt(Edit12.Text));
  //networkData.bip32.VerPrivate:=myStrToInt(Edit22.Text);
  //networkData.bip32.VerPublic:=myStrToInt(Edit23.Text);
  //     HDNode.loadFromKey(s,networkData,0,0,0);
   //PrivateKey:=HDNode.getPrivateKey;
  if HDNode.isPrivate then begin
    HDNode:=HDNode.derive(edit27.Text);
     label24.Caption:=edit27.Text+' extended privkey';
    label25.Caption:=edit27.Text+' private key';
    label26.Caption:=edit27.Text+' address';
     Edit24.Text:=HDNode.asCode58;
    Edit25.Text:=HDNode.getShortPrivateKeyCode58; //privKeyToCode58(HDNode.getPrivateKey,chr(strtoint(edit12.text)),checkbox1.checked);
    Edit26.Text:=HDNode.getAddressCode58;//publicKey2Address(GetPublicKey(HDNode.getPrivateKey),chr(strtoint(edit13.text)),checkbox1.checked);
  end else begin
    Edit24.Text:='';
    Edit25.Text:='';
    Edit26.Text:='';
  end;

end;

procedure TcryptoTestForm.fillAllForBuf(s:ansistring;excl:tEdit=nil);
begin
 if excl<>Edit7 then Edit7.text:=buf2Base58Check(s);
 if excl<>Edit8 then Edit8.Text:=bufToHex(s);
 if excl<>Edit9 then Edit9.text:=buf2Base58(S);
 if excl<>Edit30 then edit30.Text:=bufToSmart16(s);
 if excl<>Edit31 then edit31.Text:=bufToBase64(s);
end;

procedure TcryptoTestForm.Button4Click(Sender: TObject);
begin
  //if not LoadSSLCrypt() then exit;
  //InitCrypto;
//  '0121CB0E58025DD234AD1598CCD6E6BF92D343A47F80723B1129A67382D5' -> 'EA2vkLXef24CWVBuN6QF6ce16zYUsjxRVDEKurGk'
  //Edit7.text:=buf2Base58Check(hexToBuf('0121CB0E58025DD234AD1598CCD6E6BF92D343A47F80723B1129A67382D5'))

  fillAllForBuf(hexToBuf(Edit8.Text),edit8);
  {
  Edit7.text:=buf2Base58Check(hexToBuf(Edit8.Text));
  Edit9.text:=buf2Base58(hexToBuf(Edit8.Text));
  edit30.Text:=bufToSmart16(HexToBuf(Edit8.Text));
  }
end;

procedure TcryptoTestForm.Button5Click(Sender: TObject);
var s:string;
begin
  //if not LoadSSLCrypt() then exit;
  //InitCrypto;

  fillAllForBuf(base58ToBufCheck(Edit7.Text),edit7);

  {
  s:=base58ToBufCheck(Edit7.text);

  //s:=base58ToBuf(Edit7.text);
  //delete(s,1,1);
  //delete(s,length(s)-3,4);

  Edit8.Text:=bufToHex(s);
  Edit9.text:=buf2Base58(hexToBuf(Edit8.Text));
  edit30.Text:=bufToSmart16(HexToBuf(Edit8.Text));
  }
end;

procedure TcryptoTestForm.Button6Click(Sender: TObject);
begin
  // if not LoadSSLCrypt() then exit;
  //InitCrypto;

  fillAllForBuf(base58ToBuf(Edit9.text),Edit9);
  {
  Edit8.Text:=bufToHex(base58ToBuf(Edit9.text));
  Edit7.text:=buf2Base58Check(hexToBuf(Edit8.Text));
  edit30.Text:=bufToSmart16(HexToBuf(Edit8.Text));
  }
end;

procedure TcryptoTestForm.Button7Click(Sender: TObject);
begin
  if PodbiralkaForm=nil then
    Application.CreateForm(TPodbiralkaForm, PodbiralkaForm);

  PodbiralkaForm.show;
end;

procedure TcryptoTestForm.Button8Click(Sender: TObject);
var s:ansistring;
var json:TJSONObject;
    ja,ja1:TJSONArray;
    getblockcount:cardinal;
    i,j:integer;
    txr:tStringList;
    txs:tStringList;
    utxo:tStringList;
begin

  //query { nameshow(name: "denis") { answer }}
  //query { getblockcount { answer }}
  //{"data":{"getblockcount":{"answer":"{'result': 17148, 'error': None, 'id': None}"}}}
Button8.Enabled:=false;
txr:=tStringList.create();
txs:=tStringList.create();
utxo:=tStringList.create();
try

  Memo1.lines.Text:='';

  s:=getEmerRPCAnswer(
    'query { getblockcount { answer }}'
  );
  //Memo1.lines.append(s);
  json := TJSONObject(GetJSON(changeNone(changeQuotes(s))));
  //Memo1.lines.append(changeNone(changeQuotes(s)));
  try
    Memo1.lines.append('getblockcount='+inttostr(strtoint(json.Elements['result'].AsJSON)));
    getblockcount:=strtoint(json.Elements['result'].AsJSON);
    //Memo1.lines.append('getblockcount='+json.Elements['result'].AsJSON);
    //Memo1.lines.append('getblockcount='+json.AsJSON);
  finally
    json.Free;
  end;
  //========================================
  //gettxlistfor 0 310240 EVFyPAe7FNmoUdNzHvU5eFbgkY5m5ig2Pw
  //gettxlistfor <fromblock> <toblock> <address> [type=0] [verbose=0]
  //[type]: 0 - sent/received, 1 - received, 2 - sent
  //[verbose]: 0 - false, 1 - true
  // (code -1)


  s:=getEmerRPCAnswer(
    'query { gettxlistfor(fromblock:0,toblock:'+inttostr(getblockcount)+',address:"'+trim(Edit3.Text)+'") { answer }}'
  );
 // Memo1.lines.append(s);
  json := TJSONObject(GetJSON(changeNone(changeQuotes(s))));
  try
    //Memo1.lines.append(json.AsJSON);
    if json.Elements['result'].AsJSON='null' then
      Memo1.lines.append('gettxlistfor='+json.AsJSON)
    else begin
        //Memo1.lines.append('gettxlistfor='+json.Elements['result'].AsJSON);
        ja:=TJSONArray(json.Elements['result']);
        for i:=0 to ja.Count-1 do begin
          ja1:=TJSONArray(TJSONObject(ja.Items[i]).Elements['recieved']);
          for j:=0 to ja1.Count-1 do begin
            txr.Add(TJSONObject(ja1.Items[j]).Elements['txid'].asjson); //txid
            //Memo1.lines.append('rec tx:'+TJSONObject(ja1.Items[j]).Elements['txid'].AsString); //Elements['result']
          end;

          ja1:=TJSONArray(TJSONObject(ja.Items[i]).Elements['sent']);
          for j:=0 to ja1.Count-1 do begin
            txs.Add(TJSONObject(ja1.Items[j]).Elements['txid'].asjson); //txid
            //Memo1.lines.append('snd tx:'+TJSONObject(ja1.Items[j]).Elements['txid'].AsString); //Elements['result']
          end;

          //.Elements['received']
        end;
    end;
  finally
    json.Free;
  end;


  for i:=0 to txr.Count-1 do begin
    //gettransaction "txid" ( include_watchonly )
    //getrawtransaction "txid" ( verbose )
    s:=getEmerRPCAnswer(
      //'query { gettransaction(txid:'+txr[i]+',includeWatchonly:true) { answer }}'
      'query { getrawtransaction(txid:'+txr[i]+',verbose:1) { answer }}'
    );
    json := TJSONObject(GetJSON(changeNone(changeQuotes(s))));
    Memo1.lines.append('rec tx:'+txr[i]+':');
    //json.Elements['result'].
    ja:=TJSONArray(TJSONObject(json.Elements['result']).Elements['vout']);
    for j:=0 to ja.Count-1 do begin
       ja1:=TJSONArray(TJSONObject(TJSONObject(ja[j]).Elements['scriptPubKey']).Elements['addresses']);
       Memo1.lines.append('    tst:'+ja1[0].AsJSON+'');
       if (ja1.Count=1) and (TJSONObject(ja1[0]).AsString=trim(Edit3.Text)) then begin

         Memo1.lines.append('    txo:'+ inttostr(round(1000000*TJSONObject(ja[j]).Elements['value'].AsFloat))+'');
       end;
    end;

    //"vin"[] "vout": []
    //  scriptPubKey."addresses": ["address"]
    //  scriptPubKey."asm": "OP_DUP OP_HASH160 649e41b014a856eb56af9098696e8aaf5904b103 OP_EQUALVERIFY OP_CHECKSIG",
    //json := TJSONObject(GetJSON(changeNone(changeQuotes(s))));
    //Memo1.lines.append(json.AsJSON);
  end;

finally
  Button8.Enabled:=true;
  txr.free;
  txs.free;
  utxo.free;
end;



//  Memo1.lines.append('==========================');
//  s:=getEmerRPCAnswer(
//    //'getrawtransaction "296bbe9a347bf211a345d717da4409bdaa9551b1ae2b0fcbea4f36a937b43a6d" 1'
//    'query { getrawtransaction(txid:"296bbe9a347bf211a345d717da4409bdaa9551b1ae2b0fcbea4f36a937b43a6d",verbose:1) { answer }}'
//  );
//  Memo1.lines.append(s);
end;

procedure TcryptoTestForm.Button9Click(Sender: TObject);
var s:ansistring;
begin
  //Button3Click(nil);
  s:=smartToBuf(memo2.Text);
  memo3.Text:='';
  //\000\000\000\000\000\000\000@\000\000\000\000\000\000\000P\325\340\n\b\000\000
  memo3.Lines.Append('x='+bufToHex(s));
  memo3.Lines.Append('length(x)='+inttostr(length(s)));
  memo3.Lines.Append('sha256(x)='+bufToHex(doSHA256(s)));
  memo3.Lines.Append('sha256(sha256(x))='+bufToHex(doSHA256(doSHA256(s))));
  memo3.Lines.Append('RipeMD160(sha256(x))='+bufToHex(DoRipeMD160(doSHA256(s))));

end;

 {
function shlbuf(buf:ansistring;ofs:byte;delIfZero:boolean=false):ansistring;
var i:integer;
begin
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

function bytesToBIP39(buf:ansistring;const bipArray:array of string;separator:string=' '):string;
var i:integer;
begin
  result:='';
  for i:=1 to (length(buf)*8) div 11 do begin
    result:=bipArray[ord(buf[length(buf)]) + $100*(ord(buf[length(buf)-1]) and 7)]+separator+result;
    buf:=shrbuf(buf,11);
  end;
  //result:=trim(result);
  delete(result,length(result)-length(separator)+1,length(separator));
end;
}
{
function checkEntropy(buf:ansistring):boolean;
var c:integer; //c- crc bits count
    crc:byte;
    s:ansistring;
begin
  c:= (length(buf)*8) div 33;
  crc:=ord(buf[length(buf)]) and ((1 shl c) -1);

  buf:= shrbuf(buf,c);

  //delete first byte?
 //         __unused bits count__
  if (  (8-(length(buf)*8) mod 11)  )<=c then delete(buf,1,1);

  s:=dosha256(buf);
  result:= (ord(s[length(s)]) and (1 shl c -1)) = crc;
end;
}
procedure TcryptoTestForm.Edit19Change(Sender: TObject);
var buf:ansistring;
    hash:ansistring;
    //bi,bih:tBigInteger;

    crc:byte;
    i:integer;
    res:ansistring;
begin
  if Edit19.Focused then begin
     try
       buf:=hexToBuf(Edit19.Text);
     except
       exit;
     end;
     if length(buf)<3 then exit;
     if length(buf) mod 4 <>0 then exit;
     hash:=dosha256(buf);
     //err crc:=ord(hash[length(hash)]);
     //err crc:=crc and (1 shl (length(buf) div 4) - 1);
     crc:=ord(hash[1]) shr (8 - length(buf) div 4);

     //shl buf for length(buf) div 4
     res:=shlbuf(buf,length(buf) div 4);

     res[length(res)]:=chr(ord(res[length(res)]) + crc);

     edit1.Text:=bytesToBIP39(res,bip0039english,' ');
     {
     setLength(res,length(buf)+1); res[1]:=#0;
     for i:=1 to lenght(res)-1 do begin
        res[i]:=chr(ord(res[i]) + ord(buf[i]) shr (8-length(buf) div 4) );
        res[i+1]:=chr(ord(buf[i]) shl ofs);
     end;
     }


  end;
end;


procedure TcryptoTestForm.Edit1Change(Sender: TObject);
var s:ansistring;
begin
  if not Edit1.Focused then exit;

  s:=bip39tobytes(trim(edit1.text));
  if checkEntropy(s)
      then Edit19.text:=bufToHex(shrbuf(s,(length(s)*8) div 33 ,true))
      else Edit19.text:='Entropy crc error';

end;


end.

