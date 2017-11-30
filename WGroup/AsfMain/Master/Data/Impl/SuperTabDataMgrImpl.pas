unit SuperTabDataMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SuperTabDataMgr Implementation
// Author£º      lksoulman
// Date£º        2017-11-22
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext,
  CommonLock,
  SuperTabDataMgr,
  AppContextObject,
  CommonRefCounter,
  Generics.Collections;

type

  // SuperTabDataMgr Implementation
  TSuperTabDataMgrImpl = class(TAppContextObject, ISuperTabDataMgr)
  private
    // Lock
    FLock: TCSLock;
    // SuperTabDatas
    FSuperTabDatas: TList<PSuperTabData>;
    // ResourceStream
    FResourceStreams: TList<TResourceStream>;
    // ResourceStreamDic
    FResourceStreamDic: TDictionary<string, TResourceStream>;
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

    { ISuperTabDataMgr }

    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // Get DataCount
    function GetDataCount: Integer;
    // Get Data
    function GetData(AIndex: Integer): PSuperTabData;
    // GetStream
    function GetStream(AResourceName: string): TResourceStream;
  end;

implementation

{ TSuperTabDataMgrImpl }

constructor TSuperTabDataMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FLock := TCSLock.Create;
  FSuperTabDatas := TList<PSuperTabData>.Create;
  FResourceStreams := TList<TResourceStream>.Create;
  FResourceStreamDic := TDictionary<string, TResourceStream>.Create;
  DoAddTestDatas;
end;

destructor TSuperTabDataMgrImpl.Destroy;
begin
  DoClearDatas;
  FResourceStreamDic.Free;
  FResourceStreams.Free;
  FSuperTabDatas.Free;
  FLock.Free;
  inherited;
end;

procedure TSuperTabDataMgrImpl.DoClearDatas;
var
  LIndex: Integer;
  LSuperTabData: PSuperTabData;
  LResourceStream: TResourceStream;
begin
  for LIndex := 0 to FSuperTabDatas.Count - 1 do begin
    LSuperTabData := FSuperTabDatas.Items[LIndex];
    if LSuperTabData <> nil then begin
      Dispose(LSuperTabData);
    end;
  end;
  FSuperTabDatas.Clear;

  for LIndex := 0 to FResourceStreams.Count - 1 do begin
    LResourceStream := FResourceStreams.Items[LIndex];
    if LResourceStream <> nil then begin
      LResourceStream.Free;
    end;
  end;
  FResourceStreams.Clear;
  FResourceStreamDic.Clear;
end;

procedure TSuperTabDataMgrImpl.DoAddTestDatas;
var
  LSuperTabData: PSuperTabData;
begin
  New(LSuperTabData);
  LSuperTabData^.FCommandId := 60000001;
  LSuperTabData^.FResourceName := 'SKIN_APP_HQ';
  FSuperTabDatas.Add(LSuperTabData);

  New(LSuperTabData);
  LSuperTabData^.FCommandId := 60000001;
  LSuperTabData^.FResourceName := 'SKIN_APP_ASSET';
  FSuperTabDatas.Add(LSuperTabData);

  New(LSuperTabData);
  LSuperTabData^.FCommandId := 60000001;
  LSuperTabData^.FResourceName := 'SKIN_APP_PARAMSSETTING';
  FSuperTabDatas.Add(LSuperTabData);

  New(LSuperTabData);
  LSuperTabData^.FCommandId := 60000001;
  LSuperTabData^.FResourceName := 'SKIN_APP_MANAGEMENTVIEW';
  FSuperTabDatas.Add(LSuperTabData);

  New(LSuperTabData);
  LSuperTabData^.FCommandId := 60000001;
  LSuperTabData^.FResourceName := 'SKIN_APP_RISKMANAGEMENT';
  FSuperTabDatas.Add(LSuperTabData);

  New(LSuperTabData);
  LSuperTabData^.FCommandId := 60000001;
  LSuperTabData^.FResourceName := 'SKIN_APP_HQ';
  FSuperTabDatas.Add(LSuperTabData);

  New(LSuperTabData);
  LSuperTabData^.FCommandId := 60000001;
  LSuperTabData^.FResourceName := 'SKIN_APP_ASSET';
  FSuperTabDatas.Add(LSuperTabData);
end;

procedure TSuperTabDataMgrImpl.DoUpdate;
begin

end;

procedure TSuperTabDataMgrImpl.Lock;
begin
  FLock.Lock;
end;

procedure TSuperTabDataMgrImpl.UnLock;
begin
  FLock.UnLock;
end;

procedure TSuperTabDataMgrImpl.Update;
begin
  FLock.Lock;
  try
    DoUpdate;
  finally
    FLock.UnLock;
  end;
end;

function TSuperTabDataMgrImpl.GetDataCount: Integer;
begin
  Result := FSuperTabDatas.Count;
end;

function TSuperTabDataMgrImpl.GetData(AIndex: Integer): PSuperTabData;
begin
  if (AIndex >= 0)
    and (AIndex < FSuperTabDatas.Count) then begin
    Result := FSuperTabDatas.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

function TSuperTabDataMgrImpl.GetStream(AResourceName: string): TResourceStream;
begin
  if not FResourceStreamDic.TryGetValue(AResourceName, Result) then begin
    Result := FAppContext.GetResourceSkin.GetStream(AResourceName);
    if Result <> nil then begin
      FResourceStreams.Add(Result);
      FResourceStreamDic.AddOrSetValue(AResourceName, Result);
    end;
  end;
end;

end.

