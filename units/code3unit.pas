unit code3unit;

//code3 password phrases generator

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function makeRandomCode3Sequence(d:double);

implementation

const
 code3begs:ansisting='abco';
 code3ends:ansisting='chodad';
 code3table=array[0..2] of ansistring =(
   'abaacaacgach',
   'badbabbaabax',
   'codcoscadcax'
  );

function makeRandomCode3Sequence(d:double);
begin

end;

end.

