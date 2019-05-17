unit PodbiralkaUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons
  {$ifdef unix}
  ,cthreads
  ,cmem // the c memory manager is on some systems much faster for multi-threading
  {$endif}

  ,HDNodeUnit
    ,ClpIX9ECParameters
    ,ClpIECInterface
      ,ClpBigInteger
  ;

type

  { TPodbiralkaForm }

  TPodbiralkaForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    Button1: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit2: TEdit;
    Edit22: TEdit;
    Edit23: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label17: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private

  public

  end;



  TPodbiralkaThread = class(TThread)
    //will be destroyed by parent.
    //must leave unempty result if
  private
  protected
    procedure Execute; override;
  public
    Q:IECPoint;
    G:IECPoint;
    //N:tBigInteger;
    D:tBigInteger;

    Task:string; //for ref olny
    hdNode:tHDNode; //for ref only!
    //Lcurve: IX9ECParameters;

    {
    legacyMode:boolean;
    network:tNetworkData;
    compressed:boolean;
    hdSalt:string;
    hdIter:dword;
    hdPath:ansistring;
    hdSeed:string;

    task:ansistring;
    result:ansistring;
    PrivKey:ansistring;
    }
  end;


var
  PodbiralkaForm: TPodbiralkaForm=nil;

implementation

{$R *.lfm}
uses USha256, crypto, UOpenSSLdef, UOpenSSL, CryptoLib4PascalConnectorUnit, ClpIAsymmetricCipherKeyPair
  ,ClpIECDomainParameters
  ,ClpECDomainParameters
  ,ClpIECKeyPairGenerator
  ,ClpIECKeyGenerationParameters
  ,ClpCustomNamedCurves
  ,HlpHashFactory
  ,PasswordHelper
  ,ClpSecureRandom
  ,ClpISecureRandom
  ,helperUnit

  ;

{ TPodbiralkaForm }

var
  inProgress:boolean=false;

const
  CHARACTERS : AnsiString = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';


function TBigInteger2buf(d:TBigInteger):ansistring;
var ar:array of byte;
begin
  ar:=d.ToByteArray();
  setLength(result,length(ar));
  move(ar[0],result[1],length(ar));
  while (length(result)>1) and (result[1]=#0) do delete(result,1,1);
end;

procedure TPodbiralkaThread.Execute;
begin
  if Terminated then exit;

  //Q:=G*d

  //Q:= G.Multiply(D).Normalize();

  //DO NOTHING NOW
end;

procedure TPodbiralkaForm.Button1Click(Sender: TObject);
var
  d:tdatetime;
  found:boolean;
  c:cardinal;
  a,s,st,ss:ansistring;
  cc:byte;
  ini:ansistring;
  i:byte;
  //PrivateKey:PEC_KEY;


  savedPrivKey:ansistring;

  threads:array[0..1] of TPodbiralkaThread;
  myThread:TPodbiralkaThread;

  FRandom :TSecureRandom;
  Bytes:TBytes;

  networkData:tnetworkData;

  foundResult, foundTask:ansistring;




var

  //pubKey:TECDSA_Public;

  //domain: IECDomainParameters;
  //generator: IECKeyPairGenerator;
  //keygenParams: IECKeyGenerationParameters;

     PrivD,Dmax: TBigInteger;
      Q:IECPoint;

      Lcurve :IX9ECParameters;

  function myGetBip(buf:ansistring):string;
  var
    hash,res:ansistring;
    crc:byte;
    i:integer;
  begin
    //create entropy 128 bit
    buf:=copy(dosha256(buf),1,16);

    hash:=dosha256(buf);
    //err crc:=ord(hash[length(hash)]);
    //err crc:=crc and (1 shl (length(buf) div 4) - 1);
    crc:=ord(hash[1]) shr (8 - length(buf) div 4);

    //shl buf for length(buf) div 4
    res:=shlbuf(buf,length(buf) div 4);

    res[length(res)]:=chr(ord(res[length(res)]) + crc);

    result:=bytesToBIP39(res,bip0039english,' ');
  end;

begin
  FRandom := TSecureRandom.Create();
  FRandom.Boot();

  for i:=0 to length(threads)-1 do threads[i]:=nil;

  if inProgress then begin
    inProgress:=false;
    exit;
  end else inProgress:=true;

  //if not LoadSSLCrypt() then exit;
  //InitCrypto;

  //generator := TECKeyPairGenerator.Create('ECDSA');
  //keygenParams := TECKeyGenerationParameters.Create(domain, FRandom);
  //generator.Init(keygenParams);

  Lcurve := TCustomNamedCurves.GetByName('secp256k1');
  System.Assert(Lcurve <> Nil, 'Lcurve Cannot be Nil');

  Dmax:=TBigInteger.Create('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',16);

  Edit4.text:='';
  Edit5.text:='';
  Edit6.text:='';

  savedPrivKey:='';

  d:=now();
  found:=false;
  c:=0; cc:=1;
  ini:=Edit3.text;
  a:=#0;
  while (not found) and (inProgress) do begin

    if RadioButton1.Checked then begin
      if cc>length(CHARACTERS) then begin
        //move to length(ini)
        i:=length(a)-1;
        while (i>0) and (a[i]=CHARACTERS[length(CHARACTERS)]) do dec(i);
        if i>0 then begin
          //не нужно добавлять новый разряд
          a[i]:=CHARACTERS[pos(a[i],CHARACTERS)+1];
          inc(i);
          while i<=length(a) do begin
            a[i]:=CHARACTERS[1];
            inc(i);
          end;
        end else
          //нужно добавлять новый разряд : 999 -> 0000
          a:=stringofchar(CHARACTERS[1],length(a)+1);
        cc:=1;
      end else a[length(a)]:=CHARACTERS[cc];

      s:=trim(ini+a);
    end else begin
       s:='';

       setLength(Bytes,16);
       FRandom.NextBytes(Bytes);
       s:=bytes2buf(Bytes);
    //========================
    //checking threads list
//    !while (not found) and (inProgress) do
//    addThreadTask(trim(ini+a))
    end;

    //Добавим новую задачу в тред, если он освободится. иначе будем ждать
    //если добавили - чистим s
    repeat
      myThread:=nil;
      for i:=0 to length(threads)-1 do
        if threads[i]=nil then begin
          threads[i]:=TPodbiralkaThread.Create(true);
          myThread:=threads[i];
          break;
        end else
        if threads[i].Finished then begin
//=============================================== end calc
          if not checkbox2.Checked{legacyMode} then begin
            foundResult:=buf2Base58Check(chr(strtoint(Edit13.Text))+
               DoRipeMD160(DoSha256(bytes2Buf(threads[i].Q.GetEncoded(checkBox1.Checked))))
            );
            found:=(copy(foundResult,2,length(trim(Edit1.text)))=trim(Edit1.text))
                   and
                   (copy(foundResult,length(foundResult)+1-length(trim(Edit2.text)),length(trim(Edit2.text)))=trim(Edit2.text));
            if found then begin
              savedPrivKey:=privKeyToCode58(tBigInteger2buf(threads[i].D),chr(strtoint(Edit12.Text)) , checkBox1.Checked);
              foundTask:=threads[i].Task;
            end;

          end else begin
            //HD mode
            foundResult:=threads[i].hdNode.getAddressCode58;
            //foundResult:='dsadasd';
            found:=(copy(foundResult,2,length(trim(Edit1.text)))=trim(Edit1.text))
                   and
                   (copy(foundResult,length(foundResult)+1-length(trim(Edit2.text)),length(trim(Edit2.text)))=trim(Edit2.text));
            if found then begin
              savedPrivKey:=threads[i].hdNode.getShortPrivateKeyCode58;
              foundTask:=threads[i].Task;
            end;

          end;

          //!! threads[i].Free;
          //!! threads[i]:=TPodbiralkaThread.Create(true);
          myThread:=threads[i];
//=============================================== / end calc
          break;
        end;

      if (myThread<>nil) and (not found) then begin
//=============================================== begin calc
          myThread.Task:=s;

          //setLength(ar, length(s));
          //move(s[1],ar[0],length(s));

          if not checkbox2.Checked{legacyMode} then begin


            PrivD := buf2tBigInteger(dosha256(s)); // TBigInteger.Create(1, THashFactory.TCrypto.CreateSHA2_256().ComputeBytes(ar).GetBytes());
            if (PrivD.CompareTo(Dmax)<0) and (PrivD.CompareTo(TBigInteger.Zero)>0) then
            begin
              //Q:=G*d

              //xx:=PrivD;//Lcurve.G.GetAffineXCoord.ToBigInteger();
              //yy:=PrivD;//Lcurve.G.GetAffineYCoord.ToBigInteger();
              //xx:=xx.Multiply(PrivD);
              //yy:=yy.Multiply(PrivD);

              myThread.D:=PrivD;
              myThread.Q:=Lcurve.G;//.Multiply(PrivD).Normalize();
              //TO THE THREAD
              myThread.Q:= myThread.Q.Multiply(myThread.D).Normalize();
              myThread.Resume;
          {

              if Q.IsValid() then begin
                  pubkey.EC_OpenSSL_NID:=CT_NID_secp256k1;


                  pubkey.x:=TBigInteger2buf(Q.XCoord.ToBigInteger());
                  pubkey.y:=TBigInteger2buf(Q.YCoord.ToBigInteger());

                  if (length(pubkey.x)<>32) or (length(pubkey.y)<>32)
                     then result:= 'WRONG KEY'
                     else result:= publicKey2Address(pubKey, network.pubKeySig,compressed);

              end;
          }
            end;
          end else begin
            //new mode
            myThread.Q:=Lcurve.G;

            ss:=createBIP32seed(myGetBip(myThread.Task),trim(combobox1.Text), strtoint(Edit17.Text));
            if ((length(ss)>64) or (length(ss)<16)) then continue;

            ss:= hmac_sha512(ss,trim(Edit18.Text));


            myThread.hdNode.clear;

            networkData.pubKeySig:=chr(strToInt(Edit13.Text));
            networkData.wif:=chr(strToInt(Edit12.Text));
            networkData.bip32.VerPrivate:=myStrToInt(Edit22.Text);
            networkData.bip32.VerPublic:=myStrToInt(Edit23.Text);

            myThread.HDNode.loadFromKey(ss,networkData,0,0,0);
            if not myThread.HDNode.isValid then continue;

            myThread.HDNode:=myThread.HDNode.derive(Edit8.Text);
            if not myThread.HDNode.isValid then continue;

            //myThread.HDNode:=myThread.HDNode.derive(0).derive(0);


            {myThread.HDNode:=myThread.HDNode.derive(Edit8.Text);
            }



            //PrivateKey:=CreatePrivateKeyFromStrBuf(copy(s,1,32));
            //PrivateKey:=HDNode.getPrivateKey;

            {
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
            }

            myThread.Resume;
          end;
//======================================================================================

       {
        myThread.legacyMode:=not checkbox2.Checked;
        myThread.task:=s;

        myThread.network.wif:=chr(strtoint(Edit12.Text));
        myThread.network.pubKeySig:=chr(strtoint(Edit13.Text));
        myThread.network.bip32.VerPrivate:=myStrToInt(Edit22.Text);
        myThread.network.bip32.VerPublic:=myStrToInt(Edit23.Text);

        myThread.compressed:=checkbox1.Checked;

        myThread.hdSalt:=Combobox1.Text;
        myThread.hdIter:=strtoint(Edit17.Text);
        myThread.hdPath:=trim(Edit8.Text);
        myThread.hdSeed:=trim(Edit18.Text);

        threads[i].resume;
        }
        s:='';
      end else
        application.ProcessMessages;

    until found or (not inProgress) or (s='');


   (*

    s:=trim(ini+a);
    setLength(ar, length(s));
    move(s[1],ar[0],length(s));


    PrivD := TBigInteger.Create(1, THashFactory.TCrypto.CreateSHA2_256().ComputeBytes(ar).GetBytes());
    if (PrivD.CompareTo(Dmax)<0) and (PrivD.CompareTo(TBigInteger.Zero)>0) then
    begin
      //Q:=G*d
      Q:=Lcurve.G.Multiply(PrivD).Normalize();

      if Q.IsValid() then begin
          pubkey.EC_OpenSSL_NID:=CT_NID_secp256k1;


          pubkey.x:=TBigInteger2buf(Q.XCoord.ToBigInteger());
          pubkey.y:=TBigInteger2buf(Q.YCoord.ToBigInteger());

          if (length(pubkey.x)<>32) or (length(pubkey.y)<>32)
             then s:= 'WRONG KEY'
             else s:= publicKey2Address(pubKey,chr(strtoint(edit13.text)),checkbox1.checked);

          found:=(copy(s,2,length(trim(Edit1.text)))=trim(Edit1.text))
                 and
                 (copy(s,length(s)+1-length(trim(Edit2.text)),length(trim(Edit2.text)))=trim(Edit2.text));
      end;
    end;
 *)
    //d--------------------------------------------------

    if (c mod 100)=0 then begin
      label1.Caption:=inttostr(c)+ ' passed; '+ floattostr(round( c/(1+(now()-d)*24*60*60 ) ))+' address per second; Checking "'+ini+a+'" ';
      application.ProcessMessages;
    end;

    if CheckBox1.checked then st:=#1 else st:='';
    //if found then
    //    savedPrivKey:=buf2Base58Check(chr(strtoint(edit12.text))+TBigInteger2buf(PrivD)+st);
    if not found then savedPrivKey:='';



    //if Assigned(PrivateKey) then EC_KEY_free(PrivateKey);
    inc(c); inc(cc);
  end;
  inProgress:=false;
  if found then begin
    Edit4.text:=foundResult;
    if RadioButton2.Checked then begin
       if checkBox2.Checked
          then Edit5.text:='N/A'
          else Edit5.text:=bufToHex(foundTask);
    end else begin
       Edit5.text:=foundTask;
    end;

    Edit6.text:=savedPrivKey;

    if checkBox2.Checked
      then Edit7.text:=myGetBip(foundTask)
      else Edit7.text:='N/A';
  end;
end;

procedure TPodbiralkaForm.BitBtn1Click(Sender: TObject);
begin
  //main net emercoin
  Edit22.Text:='0x0488ADE4';
  Edit23.Text:='0x0488B21E';

  Edit12.Text:='$80';
  Edit13.Text:='$21';

  checkBox1.Checked:=true;
  combobox1.Text:='witnesskey';
  Edit17.Text:='2048';
  Edit18.Text:='Bitcoin seed';
  Edit8.Text:='m/0/0';
end;

procedure TPodbiralkaForm.BitBtn2Click(Sender: TObject);
begin
    //bitcoin MAIN
  Edit22.Text:='0x0488ADE4';
  Edit23.Text:='0x0488B21E';

  Edit12.Text:='$80';
  Edit13.Text:='$00';

  checkBox1.Checked:=true;
  combobox1.Text:='mnemonic';
  Edit17.Text:='2048';
  Edit18.Text:='Bitcoin seed';
  Edit8.Text:='m/0/0';
end;

procedure TPodbiralkaForm.BitBtn3Click(Sender: TObject);
begin
  //test net emercoin
  Edit22.Text:='0x04358394';
  Edit23.Text:='0x043587CF';

  Edit12.Text:='$EF';
  Edit13.Text:='$6F';

  checkBox1.Checked:=true;
  combobox1.Text:='witnesskey';
  Edit17.Text:='2048';
  Edit18.Text:='Bitcoin seed';
  Edit8.Text:='m/0/0';
end;

procedure TPodbiralkaForm.BitBtn4Click(Sender: TObject);
begin
  //bitcoin MAIN : Emercoin Secure
  Edit22.Text:='0x0488ADE4';
  Edit23.Text:='0x0488B21E';

  Edit12.Text:='$80';
  Edit13.Text:='$00';

  checkBox1.Checked:=true;
  combobox1.Text:='witnesskey';
  Edit17.Text:='2048';
  Edit18.Text:='Bitcoin seed';
  Edit8.Text:='m/0/0';
end;

procedure TPodbiralkaForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  inProgress:=false;
end;

end.

