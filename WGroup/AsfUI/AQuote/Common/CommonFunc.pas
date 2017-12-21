unit CommonFunc;

interface

uses
  Windows,
  Classes,
  SysUtils,
  WNDataSetInf,
  ComDataSet,
  GFDataSet,
  Vcl.Forms;

function HexToIntDef(AStr: string; Def: Integer): Integer;
//function IGFData2DataSet(AGFData: IGFData): TGFDataSet;
//function IGFData2IDataSet(AGFData: IGFData): IWNDataSet;
function URLAddRamdomParam(AUrl: string): string;
//procedure Delay(AMillisecond: Cardinal);
//获取 期货 精度
function GetFutureDecimals(AStockCode: string): ShortInt;

// 替换链接中的皮肤,字体大小参数
function ReplaceURLParam(AUrl: string; ASkin: string; AFontSizeRatio: string): string;

//添加用户行为埋点记录
//procedure AddUserBehavior(AControl: IGilAppController; ANode: string);

implementation

function HexToIntDef(AStr: string; Def: Integer): Integer;
var
  temp: string;
  t: Cardinal;
begin
  t := 0;
  temp := UpperCase(trim(AStr));
  if pos('X', temp) > 0 then
    temp := Copy(AStr, pos('X', temp) + 1, length(temp))
  else if (length(AStr) > 1) and (AStr[1] = '$') then
    temp := Copy(AStr, 2, length(temp));
  if length(temp) < 8 then
    temp := '0' + temp;

  try
    HexToBin(pChar(temp), @t, SizeOf(Result));
    Result := Integer((t and $FF shl 24) or (t and $FF00 shl 8) or (t and $FF0000 shr 8) or (t and $FF000000 shr 24));
  Except
    Result := Def;
  end;
end;

//function IGFData2DataSet(AGFData: IGFData): TGFDataSet;
//begin
//  Result := nil;
//  if (AGFData <> nil) and (AGFData.Succeed) then
//  begin
//    Result := TGFDataSet.Create(nil);
//    Result.CreateDataSet(AGFData);
//  end;
//end;
//
//function IGFData2IDataSet(AGFData: IGFData): IWNDataSet;
//var
//  AGFDataSet: TGFDataSet;
//begin
//  Result := nil;
//  AGFDataSet := IGFData2DataSet(AGFData);
//  if AGFDataSet <> nil then
//  begin
//    Result := TCustomComDataSet.Create(AGFDataSet, true);
//  end;

//end;

function URLAddRamdomParam(AUrl: string): string;
var
  tmpPos: Integer;
begin
  Result := trim(AUrl);
  if Result = '' then
    exit;
  // 不是网页链接，直接退出。
  if pos('HTTP', UpperCase(AUrl)) <> 1 then
    exit;

  tmpPos := pos('?', Result);
  if tmpPos > 0 then
  begin
    Result := Result + '&OOOEEE=' + formatdatetime('hhmmsszzz', now);
  end
  else
  begin
    Result := Result + '?OOOEEE=' + formatdatetime('hhmmsszzz', now);
  end;

end;

function ReplaceURLParam(AUrl: string; ASkin: string; AFontSizeRatio: string): string;
begin
  Result := AUrl;
  if ASkin = 'Black' then // 黑色皮肤
  begin
    Result := StringReplace(Result, '!SkinStyle', '200000', [rfreplaceall]);
  end
  else if  ASkin = 'Classic' then
    Result := StringReplace(Result, '!SkinStyle', '300000', [rfreplaceall])
  else
  begin
    Result := StringReplace(Result, '!SkinStyle', '000000', [rfreplaceall]);
  end;
  Result := StringReplace(Result, '!fontRatio', AFontSizeRatio, [rfreplaceall]);
end;

//procedure AddUserBehavior(AControl: IGilAppController; ANode: string);
//begin
//  if(Assigned(AControl))and(ANode <> '')then
//  begin
//    AControl.AddUserBehavior(ANode);
//  end;
//end;

//procedure Delay(AMillisecond: Cardinal);
//var
//  tmpFirstTickCount: Cardinal;
//begin
//  tmpFirstTickCount := GetTickCount;
//  repeat
//    Application.ProcessMessages;
//  until ((GetTickCount - tmpFirstTickCount) >= AMillisecond);
//end;

function GetFutureDecimals(AStockCode: string): ShortInt;
  function GetFutureType: string;
  var
    vvIndex: Integer;
  begin
    Result := '';
    for vvIndex := 1 to Length(AStockCode) do
    begin
      if (AStockCode[vvIndex] in ['0'..'9']) then
        Break;
      Result := Result + AStockCode[vvIndex];
    end;
  end;

var
  vType: string;
begin
  vType := LowerCase(GetFutureType);

  if (vType = '') or (vType = 'tc') or (vType = 'ic') or (vType = 'if') or (vType = 'ih') or (vType = 'i') or (vType = 'j') or (vType = 'jm') then
  begin      //保存1位
    Result := 1;
  end
  else if (vType = 'au') or (vType = 'bb') or (vType = 'fb') then
  begin      //保存2位
    Result := 2;
  end
  else if (vType = 'tf') or (vType = 't') then
  begin     //保存3位
    Result := 3;
  end
  else
  begin    //保存0位
    Result := 0;
  end;
end;
end.
