unit SignMessageUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TSignMessageForm }

  TSignMessageForm = class(TForm)
    bPaste: TButton;
    chMakeupBeforeSign: TCheckBox;
    chIgnoreSigns: TCheckBox;
    ePrivKey: TEdit;
    lSignFormat: TLabel;
    lDocForSign: TLabel;
    rbsf_em: TRadioButton;
    rbsf_em1: TRadioButton;
    rbUseMyKey: TRadioButton;
    rbUseAKey: TRadioButton;
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  SignMessageForm: TSignMessageForm;

//https://8gwifi.org/ecsignverify.jsp
//https://brainwalletx.github.io/#sign

(*
function encodeSignature (signature, recovery, compressed) {
  if (compressed) recovery += 4
  return Buffer.concat([Buffer.alloc(1, recovery + 27), signature])
}

function decodeSignature (buffer) {
  if (buffer.length !== 65) throw new Error('Invalid signature length')

  var flagByte = buffer.readUInt8(0) - 27
  if (flagByte > 7) throw new Error('Invalid signature parameter')

  return {
    compressed: !!(flagByte & 4),
    recovery: flagByte & 3,
    signature: buffer.slice(1)
  }
}

function magicHash (message, messagePrefix) {
  messagePrefix = messagePrefix || '\u0018Bitcoin Signed Message:\n'
  if (!Buffer.isBuffer(messagePrefix)) messagePrefix = Buffer.from(messagePrefix, 'utf8')

  var messageVISize = varuint.encodingLength(message.length)
  var buffer = Buffer.allocUnsafe(messagePrefix.length + messageVISize + message.length)
  messagePrefix.copy(buffer, 0)
  varuint.encode(message.length, buffer, messagePrefix.length)
  buffer.write(message, messagePrefix.length + messageVISize)
  return hash256(buffer)
}

function sign (message, privateKey, compressed, messagePrefix) {
  var hash = magicHash(message, messagePrefix)
  var sigObj = secp256k1.sign(hash, privateKey)
  return encodeSignature(sigObj.signature, sigObj.recovery, compressed)
}

function verify (message, address, signature, messagePrefix) {
  if (!Buffer.isBuffer(signature)) signature = Buffer.from(signature, 'base64')

  var parsed = decodeSignature(signature)
  var hash = magicHash(message, messagePrefix)
  var publicKey = secp256k1.recover(hash, parsed.signature, parsed.recovery, parsed.compressed)

  var actual = hash160(publicKey)
  var expected = bs58check.decode(address).slice(1)

  return bufferEquals(actual, expected)
}
*)


implementation

{$R *.lfm}

uses Localizzzeunit;

{ TSignMessageForm }

procedure TSignMessageForm.FormShow(Sender: TObject);
begin
  localizzze(self);
end;

end.

