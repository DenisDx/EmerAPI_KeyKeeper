unit UCryptoCut;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, UOpenSSLdef, UOpenSSL;

Type

TRawBytes=AnsiString;

TBigNum = Class
  private
    FBN : PBIGNUM;
    procedure SetHexaValue(const Value: AnsiString);
    function GetHexaValue: AnsiString;
    procedure SetValue(const Value: Int64);
    function GetValue: Int64;
    function GetDecimalValue: AnsiString;
    procedure SetDecimalValue(const Value: AnsiString);
    function GetRawValue: TRawBytes;
    procedure SetRawValue(const Value: TRawBytes);
  public
    Constructor Create; overload;
    Constructor Create(initialValue : Int64); overload;
    Constructor Create(hexaValue : AnsiString); overload;
    Destructor Destroy; override;
    Function Copy : TBigNum;
    Function Add(BN : TBigNum) : TBigNum; overload;
    Function Add(int : Int64) : TBigNum; overload;
    Function Sub(BN : TBigNum) : TBigNum; overload;
    Function Sub(int : Int64) : TBigNum; overload;
    Function Multiply(BN : TBigNum) : TBigNum; overload;
    Function Multiply(int : Int64) : TBigNum; overload;
    Function LShift(nbits : Integer) : TBigNum;
    Function RShift(nbits : Integer) : TBigNum;
    Function CompareTo(BN : TBigNum) : Integer;
    Function Divide(BN : TBigNum) : TBigNum; overload;
    Function Divide(int : Int64) : TBigNum; overload;
    Procedure Divide(dividend, remainder : TBigNum); overload;
    Function ToInt64(var int : Int64) : TBigNum;
    Function ToDecimal : AnsiString;
    Property HexaValue : AnsiString read GetHexaValue write SetHexaValue;
    Property RawValue : TRawBytes read GetRawValue write SetRawValue;
    Property DecimalValue : AnsiString read GetDecimalValue write SetDecimalValue;
    Property Value : Int64 read GetValue write SetValue;
    Function IsZero : Boolean;
    Class Function HexaToDecimal(hexa : AnsiString) : AnsiString;
    Class Function TargetToHashRate(EncodedTarget : Cardinal) : TBigNum;
  End;

implementation
{ TBigNum }

function TBigNum.Add(BN: TBigNum): TBigNum;
begin
  BN_add(FBN,BN.FBN,FBN);
  Result := Self;
end;

function TBigNum.Add(int: Int64): TBigNum;
Var bn : TBigNum;
begin
  bn := TBigNum.Create(int);
  Result := Add(bn);
  bn.Free;
end;

function TBigNum.CompareTo(BN: TBigNum): Integer;
begin
  Result := BN_cmp(FBN,BN.FBN);
end;

function TBigNum.Copy: TBigNum;
begin
  Result := TBigNum.Create(0);
  BN_copy(Result.FBN,FBN);
end;

constructor TBigNum.Create;
begin
  Create(0);
end;

constructor TBigNum.Create(hexaValue: AnsiString);
begin
  Create(0);
  SetHexaValue(hexaValue);
end;

constructor TBigNum.Create(initialValue : Int64);
begin
  FBN := BN_new();
  SetValue(initialValue);
end;

destructor TBigNum.Destroy;
begin
  BN_free(FBN);
  inherited;
end;

procedure TBigNum.Divide(dividend, remainder: TBigNum);
Var ctx : PBN_CTX;
begin
  ctx := BN_CTX_new();
  BN_div(FBN,remainder.FBN,FBN,dividend.FBN,ctx);
  BN_CTX_free(ctx);
end;

function TBigNum.Divide(int: Int64): TBigNum;
Var bn : TBigNum;
begin
  bn := TBigNum.Create(int);
  Result := Divide(bn);
  bn.Free;
end;

function TBigNum.Divide(BN: TBigNum): TBigNum;
Var _div,_rem : PBIGNUM;
  ctx : PBN_CTX;
begin
  _div := BN_new();
  _rem := BN_new();
  ctx := BN_CTX_new();
  BN_div(FBN,_rem,FBN,BN.FBN,ctx);
  BN_free(_div);
  BN_free(_rem);
  BN_CTX_free(ctx);
  Result := Self;
end;

function TBigNum.GetDecimalValue: AnsiString;
var p : PAnsiChar;
begin
  p := BN_bn2dec(FBN);
  Result := strpas(p);
  OpenSSL_free(p);
end;

function TBigNum.GetHexaValue: AnsiString;
Var p : PAnsiChar;
begin
  p := BN_bn2hex(FBN);
  Result := strpas( p );
  OPENSSL_free(p);
end;

function TBigNum.GetRawValue: TRawBytes;
Var p : PAnsiChar;
  i : Integer;
begin
  i := BN_num_bytes(FBN);
  SetLength(Result,i);
  p := @Result[1];
  i := BN_bn2bin(FBN,p);
end;

function TBigNum.GetValue: Int64;
Var p : PAnsiChar;
  a : AnsiString;
  err : Integer;
begin
  p := BN_bn2dec(FBN);
  a := strpas(p);
  OPENSSL_free(p);
  val(a,Result,err);
end;

class function TBigNum.HexaToDecimal(hexa: AnsiString): AnsiString;
Var bn : TBigNum;
begin
  bn := TBigNum.Create(hexa);
  result := bn.ToDecimal;
  bn.Free;
end;

function TBigNum.IsZero: Boolean;
Var dv : AnsiString;
begin
  dv := DecimalValue;
  Result := dv='0';
end;

function TBigNum.LShift(nbits: Integer): TBigNum;
begin
  if BN_lshift(FBN,FBN,nbits)<>1 then raise Exception.Create('Error on LShift');
  Result := Self;
end;

function TBigNum.Multiply(int: Int64): TBigNum;
Var n : TBigNum;
  ctx : PBN_CTX;
begin
  n := TBigNum.Create(int);
  Try
    ctx := BN_CTX_new();
    if BN_mul(FBN,FBN,n.FBN,ctx)<>1 then raise Exception.Create('Error on multiply');
    Result := Self;
  Finally
    BN_CTX_free(ctx);
    n.Free;
  End;
end;

function TBigNum.RShift(nbits: Integer): TBigNum;
begin
  if BN_rshift(FBN,FBN,nbits)<>1 then raise Exception.Create('Error on LShift');
  Result := Self;
end;

function TBigNum.Multiply(BN: TBigNum): TBigNum;
Var ctx : PBN_CTX;
begin
  ctx := BN_CTX_new();
  if BN_mul(FBN,FBN,BN.FBN,ctx)<>1 then raise Exception.Create('Error on multiply');
  Result := Self;
  BN_CTX_free(ctx);
  Result := Self;
end;

procedure TBigNum.SetDecimalValue(const Value: AnsiString);
Var i : Integer;
begin
  if BN_dec2bn(@FBN,PAnsiChar(Value))=0 then raise Exception.Create('Error on dec2bn');
end;

procedure TBigNum.SetHexaValue(const Value: AnsiString);
Var i : Integer;
begin
  i := BN_hex2bn(@FBN,PAnsiChar(Value));
  if i=0 then begin
      Raise Exception.Create('Invalid Hexadecimal value:'+Value);
  end;
end;

procedure TBigNum.SetRawValue(const Value: TRawBytes);
var p : PBIGNUM;
begin
  p := BN_bin2bn(PAnsiChar(Value),length(Value),FBN);
  if (p<>FBN) Or (p=Nil) then Raise Exception.Create('Error decoding Raw value to BigNum'+#10+
    ERR_error_string(ERR_get_error(),nil));
end;

procedure TBigNum.SetValue(const Value: Int64);
var a : UInt64;
begin
  if Value<0 then a := (Value * (-1))
  else a := Value;
  if BN_set_word(FBN,a)<>1 then raise Exception.Create('Error on set Value');
  if Value<0 then BN_set_negative(FBN,1)
  else BN_set_negative(FBN,0);
end;

function TBigNum.Sub(BN: TBigNum): TBigNum;
begin
  BN_sub(FBN,FBN,BN.FBN);
  Result := Self;
end;

function TBigNum.Sub(int: Int64): TBigNum;
Var bn : TBigNum;
begin
  bn := TBigNum.Create(int);
  Result := Sub(bn);
  bn.Free;
end;

class function TBigNum.TargetToHashRate(EncodedTarget: Cardinal): TBigNum;
Var bn1,bn2 : TBigNum;
  part_A, part_B : Cardinal;
  ctx : PBN_CTX;
begin
  { Target is 2 parts: First byte (A) is "0" bits on the left. Bytes 1,2,3 (B) are number after first "1" bit
    Example: Target 23FEBFCE
       Part_A: 23  -> 35 decimal
       Part_B: FEBFCE
    Target to Hash rate Formula:
      Result = 2^Part_A + ( (2^(Part_A-24)) * Part_B )
  }
  Result := TBigNum.Create(2);
  part_A := EncodedTarget shr 24;
  bn1 := TBigNum.Create(part_A);
  ctx := BN_CTX_new();
  try
    if BN_exp(Result.FBN,Result.FBN,bn1.FBN,ctx)<>1 then raise Exception.Create('Error 20161017-3');
  finally
    BN_CTX_free(ctx);
    bn1.Free;
  end;
  //
  if part_A<=24 then part_A:=24;
  //
  part_B := (EncodedTarget shl 8) shr 8;
  bn2 := TBigNum.Create(2);
  Try
    bn1 := TBigNum.Create(part_A - 24);
    ctx := BN_CTX_new();
    try
      If BN_exp(bn2.FBN,bn2.FBN,bn1.FBN,ctx)<>1 then raise Exception.Create('Error 20161017-4');
    finally
      BN_CTX_free(ctx);
      bn1.Free;
    end;
    bn2.Multiply(part_B);
    Result.Add(bn2);
  Finally
    bn2.Free;
  End;
end;

function TBigNum.ToDecimal: AnsiString;
var p : PAnsiChar;
begin
  p := BN_bn2dec(FBN);
  Result := strpas(p);
  OpenSSL_free(p);
end;

function TBigNum.ToInt64(var int: Int64): TBigNum;
Var s : AnsiString;
 err : Integer;
 p : PAnsiChar;
begin
  p := BN_bn2dec(FBN);
  s := strpas( p );
  OPENSSL_free(p);
  val(s,int,err);
  if err<>0 then int := 0;
  Result := Self;
end;



end.

