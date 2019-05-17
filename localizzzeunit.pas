unit Localizzzeunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser
  {$ifndef CONSOLEMODE}
  , FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, Buttons, Menus, ComboEx
  {$endif}
  ;
{
type

  { TLocalizzzeForm }

  TLocalizzzeForm = class(TForm)
    procedure FormCreate(Sender: TObject);
  private

  public

  end;
}

//  Таким образом, если у злоумышленника будет доступ в этому компьютеру (например, он будет украден), ваш приватный ключ будет безнадежно скомпрометирован. Это будет означать БЕЗВОЗВРАТНУЮ потерю всех активов, зарегистрированных на Ваш публичный ключ.
// Thus, if an attacker would have access to this computer (for example, it is stolen), your private key would be hopelessly compromised. This would mean the IRRETRIEVABLE losses of all assets registered to your public key.

{
Мы настоятельно рекомендуем использовать хороший пароль пользователя для защиты этих данных в случае, если будет использован такой способ их хранения.

НЕ ДЕЛАЙТЕ резервные копии файла конфигурации программы. При его утрате все данные могут быть восстановлены при помощи мастер-пароля. При этом в случае, если злоумышленник получит доступ к резервным копиям, приватный ключ может быть скомпрометирован.

Не сохраняйте пароль пользователя в большом количестве мест. В случае, если Вы его забудете, Вы всегда сможете получить доступ к данным, используя ваш мастер-пароль.

В случае, если пароль пользователя был скомпрометирован (есть предположение, что его узнали посторонние, или Вы использовали его на каких-то других сайтах, и т.п.) - немедленно смените его и удалите все резервные копии файла настроек, защищенные старым паролем


Словарь
Мастер-пароль - Основной пароль, "сид", позволяющий восстановить все приватные ключи и получить доступ ко всем данным пользователя. Можно потерять что угодно, кроме мастер-пароля, т.к. все это может быть восстановлено с его использованием. Потеря мастер-пароля недопустима. Мастер-пароль не используется в обычной работе, его можно хранить в безопасном труднодоступном месте (например, половину- в банковской ячейке, а вторую половину - в надежном личном хранилище). Мастер-пароль не может быть изменен (может быть только получено новое хранилище, и все данные могут быть переведны в него, но это не всегда возможно).
Пароль пользователя - пароль или пин-код, использующийся для рутинного доступа к программе. Забытый пароль пользователя не является большой проблемой, т.к. все данные можно восстановить с использованием мастер-пароля. Программа доступа к EmerAPI сохраняет приватные ключи на устройстве пользователя, шифруя их с использованием пароля пользователя.
Приватный ключ - секретная последовательность символов, формирующаяся на основании мастер-пароля (используется алгоритм sha256). Зная мастер-пароль, можно легко получить приватный ключ, но обратная операция невозможна. Приватный ключ используется для шифрования данных и обеспечения безопасных каналов связи. Компрометация приватного ключа недопустима, по этой причине он всегда хранится в зашифрованном виде на безопасном устройстве. Приватный ключ никогда не передается за пределы устройства.
Публичный ключ - последовательность символов, вместе с приватным ключем составляющих ключевую пару. Публичный ключ не является секретным. Для отправки пользователю шифрованного сообщения или проверки электронной подписи, сделанной приватным ключем, требуется знать публичный ключ.
Адрес - последовательность символов, сформированных на основе публичного ключа.
Компрометация - ситуация, при которой секретная информация (пароль, ключи и прочее) могли стать известны посторонним.
Потеря данных (утрата данных) - ситуация, при которой доступ к информации утрачен (никто более не может получить доступ к этой информации)


Для достижения максимальной безопасности используйте для взаимодействия с системой выделенное (используемое только для этой цели) устройство со встроенной надежной системой защиты информации (например, мобильный телефон с установленным PIN-кодом или компьютер, диск которого зашифрован надежными средствами.
Храните такое устройство в сейфе или другом безопасном месте. Не снимайте блокировку с устройства в небезопасной среде (при наличии посторонних в непосредственной близости, а также в местах, который вы не контроллируете, т.к. там могут быть установлены камеры и иные средства, с помощью которых Ваши данные могут быть скомпрометированы.

Некоторые рекомендации по обеспечению безопасности.
Данные рекомендации носят общий характер. Данные рекомендации применимы к большинству систем, связанных с использованием паролей и электронных ключей, а не только к системам Antifake и EmerAPI

Для максимальной безопасности
1. Соблюдайте безопасность при работах, связанные с вводом мастер-пароля (его создание, восстановление данных, и т.д.).
  1.1. Все действия производите в безопасном окружении (где минимизирована возможность наблюдения). Учтите, что современные видеокамеры могут быть очень маленького размера при высоком разрешении, возможно разглядеть набираемый пароль через окно иди в отражениях. Мы рекомендуем создавать физические барьеры, препятствующие подглядывание, даже в безопасном месте. Использование беспроводных клавиатур может увеличивать риск.
  1.2. При печати мастер-пароля иди приватного ключа используйте принтер, непосредственно подключенный к компьютеру. При использоавнии лазерного принтера мы рекомендуем распечатать несколько разных страниц с текстом после печати мастер-пароря или QR-кода с мастер-паролем или приватным ключём. Некоторые принтеры могут хранить в памяти последние распечатанные страницы, убедитесь, что такая память очищена.
  1.3. Работайте только на компьютере с операционной системой, установленной из надежного источника, или на мобильном телефон с заводской прошивкой без установленных дополнительных программ. Не используйте этот компьютер для других целей для достижения наивысшей безопасности.
  1.4. Доступ у мастер-паролю и устройствам хранения приватного ключа должен быть только у Вас. Не передавайте эту информаци или доступ к ней в том числе и системному администратору Вашей организации.
2. Используйте выделенный компьютер (мобильный телефон), предназначенный только для работы с системой EmerApi / Antifake.
  2.1. Устройство должно быть надежно защищено паролем. Вы можете использовать PIN-код для сотового телефона (убедитесь, что телефон будет заблокирован при попытках перебора и нет другого способа добраться до сохраненной информации) или надежные средста шифрования персональных компьютеров (убедитесь, что зашифрованы сами данные на диске, а не просто установлен пароль на вход)
  2.2. Не устанавливайте никакого дополнительного программного обеспечения на выделенном устройстве
  2.3. Храните устройство в безопасном месте (сейфе). Предусмотрите способ обнаружения вскрытия устройства или физического доступа к нему посторонних (злоумышленник может присоединить к компьютеру собственное устройство).
  2.4. Наилучшим решением является использование специализированного устройства для хранения приватного ключа и обеспечения подписания транзакций.
3. Соблюдайте общие правила работы с паролями
  3.1. Не используйте нигде более пароли, использованные Вами в качестве мастер-пароля, пароля пользователя и других
  3.2. Не оставляйте записи паролей в местах, где посторонние могут получить к ним доступ
  3.3. Не набирайте пароль нигде кроме как в программме EmerAPI / Antifake. Это касается и запрета на отправку пароля по электронной почте, скайпу и т.п.
  3.4. Не сообщайте пароль посторонним. Если по какой-то причине это пришлось сделать- немедленно смените пароль после компрометации и удалите все архивы файлов конфигурации.
  3.5. Храните пароль по частям (например, в идеальном случае следует разделить мастер-пароль на две части, первую из которых хранить в банковской ячейке в США, а вторую - в ячейке банка Китая). Более подробно см.способы хранения пароля
  3.6. Не используйте в паролях осмысленные слова, номера телефонов, важные даты и т.п. Современные средства позволяют очень быстро из подбирать.
  3.7. Никогда и ни при каких обстоятельствах не сообщайте никому мастер-пароль, пароль пользователя и не передавайте приватный ключ.
  3.8. Не храните все части мастер-пароля в электронном виде в программах, предназначенных для хранения паролей. Хотя бы одна часть должна храниться в виде твердой копии в безопасном месте. Хранение пароля пользователя таким способом допустимо при условии использования безопасного устройства для доступа к системе.
4. Продумайте защиту от раскрытия пароля под давлением (ситуация, когда злоумышленники физически захватили оператора, имеющего доступ к системе, и требуют его его раскрытия под угрозой физического насилия)
  4.1. Храните мастер- пароль или его часть в месте, доступ в которое под давлением невозможен (например, в банковской ячейке).
  4.2. Храните устройство, на котором находится приватный ключ, в безопасном месте, доступ в которое невозможет для посторонних или сотрудников, находящихся под давлением. Например, это может быть сейф в охраняемом офисе или банковская ячейка.
  При соблюдении указанных требований находящийся под давлением оператор физически не может предоставить злоумышленникам доступа к системе, что, кроме всего прочего, снижает риск противоправных действий в его адрес.
5. При ежедневном использовании,
  5.1. Мы не рекомендуем использование программы хранения ключа и подписи транзакций в качестве ежедневно используемого криптовалютного кошелька, хотя такие функции в ней присутствуют. Каждое использование создает риск компрометации приватного ключа. Используйсте отдельный кошелек (или другой адрес в системе EmerAPI / Antifake) для пополнения баланса, продления лизинга имён и прочих операций.
  5.2. В случае, если возможность электронной подписи, блокчейн-заверения документов и другой функционал EmerAPI / Antifake требуется нескольким вашим сотрудникам, мы настоятельно рекомендуем создать для каждого сотрудника собственный мастер-пароль и адрес в системе. В случае увольнения сотрудника или компрометации его пароля доступ может быть легко аннулирован.
  5.3. В многопользовательских системах проводите периодический аудит системы, блокируйте доступ уволенным пользователям. Можно рекомендовать периодическую смену паролей и учетных адресов пользователей.
  5.4. Убедитесь, что НЕ выполняется резервное копирование файлов, содержащих приватный ключ, пусть даже в зашифрованном виде, если для этого не используется выделенное устройство.
Примечания
  1. Юридические особенности и взаимодействие со спецслужбами.
    1.1. Требование предоставления мастер-пароля, пароля пользователя или приватного ключа незаконно в большинстве стран.
      Мастер-пароль не используется для шифрования пересылаемых данных и не хранится в компьютере. По этой причине требование его предоставления для расшифровки передаваемой информации бессмысленно. Шифрование производится средствами SSL-соединения.
    1.2. Возможность правдоподобного отрицания.
      Система построена таким образом, что не существует способа доказать наличие у оператора мастер-пароля (он нигде не хранится, эксплуатация системы возможна без него).
      В случае, когда необходимо обеспечить возможность правдоподобного отрицания владения ключами доступа к системе (например, при физическом захвате сотрудников злоумышленниками) возможно физическое уничтожение устройств доступа. Такое уничтожение не повлечет за собой утрату данных (они могут быть восстановлены с помощью мастер-пароля), но после этого не будет способа определить, был ли у оператора доступ к системе.
    1.3. Система использует стандартные криптоалгоритмы (ECDSA, sha256, RIPMD160), используемые, среди прочего, во многих блокчейн- системах (например, в Bitcoin). Убедитесь, что использование этих криптоалгоритмов не противоречит законодательству Вашей страны.
   2. Рекомендации по выборру оборудования
    2.1. В качестве устройства, обеспечиващего работу с основным приватным ключём, можно рекомендовать либо мобильный телефон (apple или на базе android), либо ноутбук (желательно со съемной батареей для безопасного длительного хранения в сейфе). Лучше использовать качественную технику. Кастомные прошивки и "рут" андроида крайне не рекомендуются.
    2.2. Операционная система устройсва, хранящего приватный ключ, может быть любой. Мы рекомендуем linux (например, Ubuntu) как потенциально более защищенную систему, однако допустимо использование Windows и OsX.
    2.3. При использовании ПК в качетсве устройства хранения данных мы рекомендуем использовать программы шифрования раздела - например, LUKS (Linux) (убедитесь в шифровании swap или в том, что swap отключен) , Bitlocker (windows), Veracrypt (windows, linux), FileVault (OSX). Допустимо и использование шифрования части данных (ecryptfs в Linux, файлы-тома Veracrypt, частичное шифрование FileVault в OSX и другие). В случае использования подобной схемы, особенно на Linux/Windows, убедитесь в том, что swap отключен или зашифрован.
    2.4. При использовании ПК учтите, что в некоторых случаях секретная информация может попадать в SWAP разделы диска. Возможно полностью шифровать все данные компьютера (включая SWAP) или отключить swap.
    2.5. При использовании ПК , если не осуществялется шифрование всего диска (например, при использовании ecryptfs или файлов- томов Veracrypt) убедитесь, что конфигурационный файл программы сохраняется в защищенной области диска. Отключите swap.
    2.6. При использовании телефонов на базе Android мы не рекомендуем использовать модели неизвестных производителей.
    2.8. При использовании телефонов установка защиты (пин-код) обязательна. Не используйте "стандартные" pin-коды. Не используйте пин-код, который используется Вами где-то еще.
    2.7. При использовании телефонов биометрическая система защиты может быть применена при условии безопасного хранения устройства.
    2.8. Повреждение устройства и потеря информации не опасны при условии аккуратного хранения мастер- пароля. Лучше потерять доступ, чем дать его постороннему.
    2.9. Минимизируйте вероятность хищения устройства. Если оно произошло - не используйте более пин-коды или пароли на вход, которые вы использовали на этом устройстве, и постарайтесь уничтожить все копии этих паролей.
    2.10. Мы не рекомендуем использовать бывшую в употреблении технику для хранения приватного ключа, т.к. в ней могут быть установлены закладки - как программные, так и аппаратные.
    2.11. Мы не рекомендуем продавать технику, использованную для хранения приватного ключа. При ее утилизации тщательно убедитесь в физическом разрушении носителя информации, удалите секретную информацию перед утилизацией, если это возможно.
    2.12. Мы не рекомендуем передавать в ремонт технику, использующуюся для хранения приватного ключа, или использовать технику, ранее ремонтировавшуюся. Это касается и случаев, когда возможна деинсталляция устровйства хранения данных.
    2.13. Мы НЕ рекомендуем использовать флеш-накопители и другие съемные носители для обеспечения безопасности вместо безопасного хранения выделенного устройства. Значительная часть атак осуществляется именно через скомпрометированные устройства (компьютеры, телефоны).




Хранение паролей

}


var languages:tStringList;

function CurrentLanguage():ansistring;

var
  //LocalizzzeForm: TLocalizzzeForm;
  LocalizzzeData:TJSONData;



procedure localizzze(obj:TComponent);

function GetLocaleLanguage: string;
function GetLocaleLanguageTag: ansistring;

function localizzzeString(sign:ansistring;s:String):String;

implementation

{$R *.lfm}
uses Crypto {$IFDEF MSWINDOWS}
  ,windows

  {$ENDIF}
  , settingsunit, helperUnit
  {$ifndef CONSOLEMODE}
  ,ComCtrls,CheckLst
  {$endif}
  ;

{  CHANGET INTO NEW WAY $R resources.rc}

var
    assignationList:tStringList;
    LocalizzzeListCache:tStringList;
    //Для правильного перевода tStrings объектов. Сохраняет исходные данные списка при первом вызове. Потом переводит по ним, в случае, если список остался нетронут.
    //В строке хранится sign:sha256(.Text) хеш объекта .Text строкового значения списка ПОСЛЕ последнего перевода
    // в .Objects хранится копия списка первого вызова.
    //Таким образом,
    //Если хеш совпадает => список не менялся => используем для перевода ассоциированный список
    //Если хеш изменился => была вызвана перегенерация списка => заменяем дочерний список текущим , переводим и перехешируем.

{  $IFDEF DARWIN}
//  fbl := NSLocale.currentLocale.localeIdentifier.UTF8String;
{ $ENDIF}

{$IFDEF MSWINDOWS}
function GetLocaleInformation(Flag: integer): string;
var
  pcLCA: array[0..20] of char;
begin
  if (GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, Flag, pcLCA, 19) <= 0) then
  begin
    pcLCA[0] := #0;
  end;
  Result := pcLCA;
end;

{$ENDIF}

function GetLocaleLanguage: string;
begin
  {$IFDEF MSWINDOWS}
   Result := GetLocaleInformation(LOCALE_SENGLANGUAGE);
  {$ELSE}
   Result := SysUtils.GetEnvironmentVariable('LANG');
  {$ENDIF}
end;

function GetLocaleLanguageTag: ansistring;
begin
  result:=GetLocaleLanguage;
  result:=lowercase(result);
  result:=copy(result,1,2);
end;

function CurrentLanguage():ansistring;
begin
  result:='';
  if (Settings<>nil) {and (Settings.Loaded)} then result:=Settings.getValue('Language') else result:=GetLocaleLanguageTag();
end;




procedure localizzzeStrings(sign:ansistring;s:tStrings);
var i,n:integer;
    t:ansistring;
    source:tStringList;
begin
  if (s=nil) or (s.Count<1) then exit;;

  t:=s.Text;
  t:=sign+':'+t;

  n:=LocalizzzeListCache.IndexOf(t);
  if (n>=0) and (tStringList(LocalizzzeListCache.Objects[n]).Count = s.Count) then begin
    //the list has not been changed since last translation
    for i:=0 to tStringList(LocalizzzeListCache.Objects[n]).Count-1 do
       s[i] := localizzzeString(sign+'.'+uppercase(tStringList(LocalizzzeListCache.Objects[n])[i]),tStringList(LocalizzzeListCache.Objects[n])[i]);
    //rehash the list
    LocalizzzeListCache[n]:=sign+':'+s.Text;
    exit;
  end;
  if n>=0 then //the list count was changed but the hashes is the same???? How is it possible?
     raise exception.Create('localizzzeStrings: internal error 1');

  //the list was changed or this is first call
  //Removing sign if exists
  for n:= LocalizzzeListCache.Count-1 downto 0 do
     if pos(sign+':',LocalizzzeListCache[n])=1 then begin
       //The elements frequenly changing will be moved to the end of the list
       tStringList(LocalizzzeListCache.Objects[n]).Free;
       LocalizzzeListCache.Delete(n);
       break;
     end;

  source:=tStringList.Create;
  source.Assign(s);

  for i:=0 to s.Count-1 do
    s[i] := localizzzeString(sign+'.'+uppercase(s[i]),s[i]);

  LocalizzzeListCache.AddObject(sign+':'+s.Text,source);
end;

procedure localizzzeComboEx(sign:ansistring;c:TComboBoxEx);
var i:integer;
begin
  //Can't change, only can rebuild items... Will think after.
//  for i:=0 to c.ItemsEx.Count-1 do
//     c.Items[i]:=sign+c.Items[i];
//     c.ItemsEx.ToString;
//     s[i]:=sign+'.'+s[i];
end;



function localizzzeString(sign:ansistring;s:String):String;
//jObject : TJSONObject;
//jArray : TJSONArray;
var
  //obj:TJSONObject;
  d:tJsonData;
  function AssignElem(d:tJsonData):string;
  var t:tJsonData;
  begin
    if d.Count=0 then begin result:=''; exit; end;

    t:=TJSONObject(d).Find(currentLanguage);
    if t<>nil then begin result:=t.AsString; exit; end;

    t:=TJSONObject(d).Find('en');
    if t<>nil then begin result:=t.AsString; exit; end;

    t:=d.Items[0];
    result:=t.AsString;
  end;
  var n:integer;
begin
  sign:=uppercase(sign); //ЗАДОЛБАЛО!!!
  result:=s;
  if LocalizzzeData=nil then exit;

  d:=TJSONObject(LocalizzzeData).Find(sign);
  if d<>nil then begin
    result:=assignElem(d);
    exit;
  end;

  n:=assignationList.IndexOf(ANSIUPPERCASE(s));
  if n>=0 then begin
    d:=TJSONObject(assignationList.Objects[n]);
    result:=assignElem(d);
    exit;
  end;

  d:=TJSONObject(LocalizzzeData).Find(ANSIUPPERCASE(s));
  if d<>nil then begin
    //found by caption.
    assignationList.AddObject(s,d);
    result:=assignElem(d);
    exit;
  end;

end;

procedure localizzze(obj:TComponent);
var i:integer;
  function sig(obj:TComponent):ansistring;
  begin
    if obj.Owner<>nil then begin
      if obj.Owner is tFrame
       then result:=uppercase(obj.Owner.ClassName)
       else result:=uppercase(obj.Owner.Name);
      if pos('_',result)>0 then result:=copy(uppercase(obj.Owner.Name),1,pos('_',result)-1);
    end
    else
      result:='';

    if result<>'' then result:=result+'.';
    result:=result+uppercase(obj.Name);
  end;
  var hint:string;
begin

  if obj is TWinControl then
    for i:=0 to TWinControl(obj).ControlCount-1 do
//      if (TWinControl(obj).Controls[i] is tWinControl) then
        localizzze(TWinControl(obj).Controls[i]);

  if obj is TMenu then
    for i:=0 to TMenu(obj).Items.Count -1 do
       localizzze(TMenu(obj).Items[i])

  else if obj is TComboBox then localizzzeStrings(sig(obj),TComboBox(obj).Items)
  else if obj is TCheckListBox then localizzzeStrings(sig(obj),TCheckListBox(obj).Items)
  else if obj is TComboBoxEx then localizzzeComboEx(sig(obj),TComboBoxEx(obj) )
  else if obj is tLabel then (obj as tLabel).Caption:=localizzzeString(sig(obj),(obj as tLabel).Caption)
  else if obj is TTabSheet then (obj as TTabSheet).Caption:=localizzzeString(sig(obj),(obj as TTabSheet).Caption)
  else if obj is tBitBtn then begin
     (obj as tBitBtn).Caption := localizzzeString(sig(obj),(obj as tBitBtn).Caption);
     //(obj as tBitBtn).Hint := localizzzeString(sig(obj)+'.hint',(obj as tBitBtn).Hint);
  end
  else if obj is tGroupBox then (obj as tGroupBox).Caption:=localizzzeString(sig(obj),(obj as tGroupBox).Caption)

  else if obj is tButton then (obj as tButton).Caption:=localizzzeString(sig(obj),(obj as tButton).Caption)
  else if obj is TLabeledEdit then (obj as TLabeledEdit).EditLabel.Caption:=localizzzeString(sig(obj),(obj as TLabeledEdit).EditLabel.Caption)
  else if obj is tCheckBox then (obj as tCheckBox).Caption:=localizzzeString(sig(obj),(obj as tCheckBox).Caption)
  else if obj is tCustomForm then (obj as tCustomForm).Caption:=localizzzeString(sig(obj),(obj as tCustomForm).Caption)
  else if obj is tRadioButton then (obj as tRadioButton).Caption:=localizzzeString(sig(obj),(obj as tRadioButton).Caption)

  else if obj is tMenuItem then begin
    (obj as tMenuItem).Caption:=localizzzeString(sig(obj),(obj as tMenuItem).Caption);
    for i:=0 to tMenuItem(obj).Count -1 do
       localizzze(tMenuItem(obj).Items[i]);
  end;

  //Hint addition
  if obj is TControl then begin
    hint := localizzzeString(sig(obj)+'.hint',(obj as TControl).Hint);
    if hint<>'' then begin
      (obj as TControl).Hint:=hint;
      (obj as TControl).ShowHint:=true;
    end;
  end;
end;


procedure localizzzeInit();
var i,j:integer;
    s:string;
    t:TJSONData;
    ResStream : TResourceStream;
    fs:tFileStream;
begin


 if fileexists(extractFilePath(application.ExeName)+'translation.txt') then
   try
     fs:=tFileStream.Create(extractFilePath(application.ExeName)+'translation.txt',fmOpenRead);
     setLength(s,fs.Size);
     fs.Read(s[1],length(s));
   finally
     FreeAndNil(fs);
   end
 else
  try
    ResStream := TResourceStream.Create(HInstance, 'translation', PChar(RT_RCDATA));
    setLength(s,ResStream.Size);
    ResStream.Read(s[1],length(s));
    //Png := TPortableNetworkGraphic.Create;
    //Png.LoadFromStream(ResStream);
    //Image.Canvas.Draw(0, 0, Png);
  finally
    FreeAndNil(ResStream);
    //FreeAndNil(Png);
  end;


//  mLanguageData.Lines.Clear;
  t := GetJSON(changeQuotesSafe(s));
  try
    LocalizzzeData := TJSONObject.Create;
    for i:=0 to t.Count-1 do begin
      tJsonObject(LocalizzzeData).Add(
       trim(AnsiUpperCase(tJsonObject(t).Names[i]))
       ,
       t.Items[i].Clone
      );
      for j:=0 to tJsonObject(t.Items[i]).Count-1 do
         if languages.IndexOf(tJsonObject(t.Items[i]).Names[j])<0
            then languages.add(tJsonObject(t.Items[i]).Names[j]);
    end;

  finally
    t.Free;
  end;

//  for i:=0 to LocalizzzeData.Count-1 do
//     tJsonObject(LocalizzzeData).
//     tJsonObject(LocalizzzeData).Names[i]:=trim(AnsiUpperCase(tJsonObject(LocalizzzeData).Names[i]));
  //for i:=0 to LocalizzzeData.Count-1 do begin
  //   t:=tJsonObject(LocalizzzeData.Items[i]);
  //   mLanguageData.Append(tJsonObject(LocalizzzeData).Names[i]);
  //   //LocalizzzeData.Items[i].AsString:=trim(AnsiUpperCase(LocalizzzeData.Items[i].AsString));
  //end;

end;


INITIALIZATION
  //LocalizzzeData:=tStringList.Create;
  languages:=tStringList.Create;
  assignationList:=tStringList.create;
  LocalizzzeListCache:=tStringList.create;
  localizzzeInit();
FINALIZATION


while LocalizzzeListCache.Count>0 do begin
  tStringList(LocalizzzeListCache.Objects[0]).free;
  LocalizzzeListCache.Delete(0);
end;
FreeAndNil(LocalizzzeListCache);

FreeAndNil(LocalizzzeData);


LocalizzzeData.Free;
languages.free;
assignationList.free;


end.

