unit UserUTXOListUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, EmerAPIMain;


tUserUTXOList = class(tUTXOList)
private
  fEmerAPI:tEmerAPI;
  procedure SetEmerAPI(mEmerAPI:tEmerAPI);
public
  property EmerAPI:tEmerAPI read fEmerAPI write SetEmerAPI();

end;

implementation

procedure tUserUTXOList.SetEmerAPI(mEmerAPI:tEmerAPI);
begin
  fEmerAPI:=mEmerAPI;
  blockChain:=fEmerAPI.
end;

end.

