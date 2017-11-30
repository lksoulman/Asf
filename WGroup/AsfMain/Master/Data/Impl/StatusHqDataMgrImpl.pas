unit StatusHqDataMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： StatusHqDataMgr Implementation
// Author：      lksoulman
// Date：        2017-11-22
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext,
  CommonLock,
  StatusHqDataMgr,
  AppContextObject,
  CommonRefCounter,
  Generics.Collections;

type

  // StatusHqDataMgr Implementation
  TStatusHqDataMgrImpl = class(TAppContextObject, IStatusHqDataMgr)
  private
    // Lock
    FLock: TCSLock;
    // StatusHqDatas
    FStatusHqDatas: TList<PStatusHqData>;
  protected
    // ClearDatas
    procedure DoClearDatas;
    // AddTestDatas
    procedure DoAddTestDatas;
    // Update
    procedure DoUpdate;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IStatusHqDataMgr }

    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // Get Count
    function GetDataCount: Integer;
    // Get Data
    function GetData(AIndex: Integer): PStatusHqData;
  end;

implementation

{ TStatusHqDataMgrImpl }

constructor TStatusHqDataMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FLock := TCSLock.Create;
  FStatusHqDatas := TList<PStatusHqData>.Create;
  DoAddTestDatas;
end;

destructor TStatusHqDataMgrImpl.Destroy;
begin
  DoClearDatas;
  FStatusHqDatas.Free;
  FLock.Free;
  inherited;
end;

procedure TStatusHqDataMgrImpl.DoClearDatas;
var
  LIndex: Integer;
  LStatusHqData: PStatusHqData;
begin
  for LIndex := 0 to FStatusHqDatas.Count - 1 do begin
    LStatusHqData := FStatusHqDatas.Items[LIndex];
    if LStatusHqData <> nil then begin
      Dispose(LStatusHqData);
    end;
  end;
  FStatusHqDatas.Clear;
end;

procedure TStatusHqDataMgrImpl.DoAddTestDatas;
var
  LStatusHqData: PStatusHqData;
begin
  New(LStatusHqData);
  LStatusHqData^.FInnerCode := 1;
  LStatusHqData^.FSecuAbbr := '上证: ';
  LStatusHqData^.FNowPrice := 0;
  LStatusHqData^.FPreClose := 0;
  LStatusHqData^.FTurnover := 0;
  FStatusHqDatas.Add(LStatusHqData);

  New(LStatusHqData);
  LStatusHqData^.FInnerCode := 11089;
  LStatusHqData^.FSecuAbbr := '创业板: ';
  LStatusHqData^.FNowPrice := 0;
  LStatusHqData^.FPreClose := 0;
  LStatusHqData^.FTurnover := 0;
  FStatusHqDatas.Add(LStatusHqData);

  New(LStatusHqData);
  LStatusHqData^.FInnerCode := 3159;
  LStatusHqData^.FSecuAbbr := '恒指: ';
  LStatusHqData^.FNowPrice := 0;
  LStatusHqData^.FPreClose := 0;
  LStatusHqData^.FTurnover := 0;
  FStatusHqDatas.Add(LStatusHqData);

  New(LStatusHqData);
  LStatusHqData^.FInnerCode := 1055;
  LStatusHqData^.FSecuAbbr := '深证:';
  LStatusHqData^.FNowPrice := 0;
  LStatusHqData^.FPreClose := 0;
  LStatusHqData^.FTurnover := 0;
  FStatusHqDatas.Add(LStatusHqData);

  New(LStatusHqData);
  LStatusHqData^.FInnerCode := 7542;
  LStatusHqData^.FSecuAbbr := '中小板: ';
  LStatusHqData^.FNowPrice := 0;
  LStatusHqData^.FPreClose := 0;
  LStatusHqData^.FTurnover := 0;
  FStatusHqDatas.Add(LStatusHqData);

  New(LStatusHqData);
  LStatusHqData^.FInnerCode := 3145;
  LStatusHqData^.FSecuAbbr := '沪深300: ';
  LStatusHqData^.FNowPrice := 0;
  LStatusHqData^.FPreClose := 0;
  LStatusHqData^.FTurnover := 0;
  FStatusHqDatas.Add(LStatusHqData);
end;

procedure TStatusHqDataMgrImpl.DoUpdate;
begin

end;

procedure TStatusHqDataMgrImpl.Lock;
begin
  FLock.Lock;
end;

procedure TStatusHqDataMgrImpl.UnLock;
begin
  FLock.UnLock;
end;

procedure TStatusHqDataMgrImpl.Update;
begin

end;

function TStatusHqDataMgrImpl.GetDataCount: Integer;
begin
  Result := FStatusHqDatas.Count;
end;

function TStatusHqDataMgrImpl.GetData(AIndex: Integer): PStatusHqData;
begin
  if (AIndex >= 0)
    and (AIndex < FStatusHqDatas.Count) then begin
    Result := FStatusHqDatas.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

end.
