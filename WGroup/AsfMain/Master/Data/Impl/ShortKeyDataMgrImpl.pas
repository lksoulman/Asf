unit ShortKeyDataMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º ShortKeyDataMgr Implementation
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
  BaseObject,
  AppContext,
  CommonLock,
  ShortKeyDataMgr,
  Generics.Collections;

type

  // ShortKeyDataMgr Implementation
  TShortKeyDataMgrImpl = class(TBaseInterfacedObject, IShortKeyDataMgr)
  private
    // Lock
    FLock: TCSLock;
    // ShortKeyDatas
    FShortKeyDatas: TList<PShortKeyData>;
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

    { IShortKeyDataMgr }

    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // Get Count
    function GetDataCount: Integer;
    // Get Data
    function GetData(AIndex: Integer): PShortKeyData;
    // GetStream
    function GetStream(AResourceName: string): TResourceStream;
  end;

implementation

uses
  Command;

{ TShortKeyDataMgrImpl }

constructor TShortKeyDataMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FLock := TCSLock.Create;
  FShortKeyDatas := TList<PShortKeyData>.Create;
  FResourceStreams := TList<TResourceStream>.Create;
  FResourceStreamDic := TDictionary<string, TResourceStream>.Create;
  DoAddTestDatas;
end;

destructor TShortKeyDataMgrImpl.Destroy;
begin
  DoClearDatas;
  FResourceStreamDic.Free;
  FResourceStreams.Free;
  FShortKeyDatas.Free;
  FLock.Free;
  inherited;
end;

procedure TShortKeyDataMgrImpl.DoClearDatas;
var
  LIndex: Integer;
  LShortKeyData: PShortKeyData;
  LResourceStream: TResourceStream;
begin
  for LIndex := 0 to FShortKeyDatas.Count - 1 do begin
    LShortKeyData := FShortKeyDatas.Items[LIndex];
    if LShortKeyData <> nil then begin
      Dispose(LShortKeyData);
    end;
  end;
  FShortKeyDatas.Clear;

  for LIndex := 0 to FResourceStreams.Count - 1 do begin
    LResourceStream := FResourceStreams.Items[LIndex];
    if LResourceStream <> nil then begin
      LResourceStream.Free;
    end;
  end;
  FResourceStreams.Clear;
  FResourceStreamDic.Clear;
end;

procedure TShortKeyDataMgrImpl.DoAddTestDatas;
var
  LShortKeyData: PShortKeyData;
begin
  New(LShortKeyData);
  LShortKeyData^.FCommandId := ASF_COMMAND_ID_MASTERMGR;
  LShortKeyData^.FResourceName := 'SKIN_APP_BACKSPACE';
  FShortKeyDatas.Add(LShortKeyData);

  New(LShortKeyData);
  LShortKeyData^.FCommandId := ASF_COMMAND_ID_MASTERMGR;
  LShortKeyData^.FResourceName := 'SKIN_APP_FORWARD';
  FShortKeyDatas.Add(LShortKeyData);

  New(LShortKeyData);
  LShortKeyData^.FCommandId := ASF_COMMAND_ID_MASTERMGR;
  LShortKeyData^.FResourceName := 'SKIN_APP_REFRESH';
  FShortKeyDatas.Add(LShortKeyData);

  New(LShortKeyData);
  LShortKeyData^.FCommandId := ASF_COMMAND_ID_MASTERMGR;
  LShortKeyData^.FResourceName := 'SKIN_APP_SKIN';
  FShortKeyDatas.Add(LShortKeyData);

  New(LShortKeyData);
  LShortKeyData^.FCommandId := ASF_COMMAND_ID_MASTERMGR;
  LShortKeyData^.FResourceName := 'SKIN_APP_HELP';
  FShortKeyDatas.Add(LShortKeyData);

  New(LShortKeyData);
  LShortKeyData^.FCommandId := ASF_COMMAND_ID_MASTERMGR;
  LShortKeyData^.FResourceName := 'SKIN_APP_NEWWORK';
  LShortKeyData^.FCommandParams := 'FuncName=NewMaster';
  FShortKeyDatas.Add(LShortKeyData);

  New(LShortKeyData);
  LShortKeyData^.FCommandId := ASF_COMMAND_ID_MASTERMGR;
  LShortKeyData^.FResourceName := 'SKIN_APP_F6';
  FShortKeyDatas.Add(LShortKeyData);

  New(LShortKeyData);
  LShortKeyData^.FCommandId := ASF_COMMAND_ID_MASTERMGR;
  LShortKeyData^.FResourceName := 'SKIN_APP_F4';
  FShortKeyDatas.Add(LShortKeyData);

  New(LShortKeyData);
  LShortKeyData^.FCommandId := ASF_COMMAND_ID_MASTERMGR;
  LShortKeyData^.FResourceName := 'SKIN_APP_F3';
  FShortKeyDatas.Add(LShortKeyData);

  New(LShortKeyData);
  LShortKeyData^.FCommandId := ASF_COMMAND_ID_MASTERMGR;
  LShortKeyData^.FResourceName := 'SKIN_APP_81';
  FShortKeyDatas.Add(LShortKeyData);
end;

procedure TShortKeyDataMgrImpl.DoUpdate;
begin

end;

procedure TShortKeyDataMgrImpl.Lock;
begin
  FLock.Lock;
end;

procedure TShortKeyDataMgrImpl.UnLock;
begin
  FLock.UnLock;
end;

procedure TShortKeyDataMgrImpl.Update;
begin
  DoClearDatas;
  DoAddTestDatas;
end;

function TShortKeyDataMgrImpl.GetDataCount: Integer;
begin
  Result := FShortKeyDatas.Count;
end;

function TShortKeyDataMgrImpl.GetData(AIndex: Integer): PShortKeyData;
begin
  if (AIndex >= 0)
    and (AIndex < FShortKeyDatas.Count) then begin
    Result := FShortKeyDatas.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

function TShortKeyDataMgrImpl.GetStream(AResourceName: string): TResourceStream;
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
