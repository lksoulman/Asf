unit ProcessSingleton;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º ProcessSingleton
// Author£º      lksoulman
// Date£º        2017-12-26
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  LogLevel,
  BaseObject,
  AppContext;

const

  PROCESS_MAX_COUNT = 10;

type

  // ProcessInfo
  TProcessInfo = packed record
    FHandle: Integer;
    FProcessId: DWORD;
    FTerminated: Integer;
    FPathHashInt: Integer;
  end;

  // ProcessInfo Pointer
  PProcessInfo = ^TProcessInfo;

  // ProcessShareData
  TProcessShareData = packed record
    FProcessInfos: Array [0 .. PROCESS_MAX_COUNT - 1] of TProcessInfo;
    FProcessInfoCount: Integer;
  end;

  // ProcessShareData Pointer
  PProcessShareData = ^TProcessShareData;

  // ProcessSingleton
  TProcessSingleton = class(TBaseObject)
  private
    // MapFile
    FMapFile: THandle;
    // MapFileName
    FMapFileName: string;
    // ProcessHashInt
    FProcessHashInt: Integer;
    // ProcessMaxCount
    FProcessMaxCount: Integer;
    // ProcessShareData
    FProcessShareData: PProcessShareData;

    // Constructor
    constructor Create(AContext: IAppContext); override;
  protected
    // InitData
    procedure DoInitData;
    // UnInitData
    procedure DoUnInitData;
    // DeleteProcessInfo
    procedure DoDeleteProcessInfo;
    // FindIndex
    function DoFindIndex(AHashInt: Integer): Integer;
  public
    // Destructor
    destructor Destroy; override;
    // Instance
    class function Instance(AContext: IAppContext): TProcessSingleton;
    // CheckIsRunning
    function CheckIsRunning(AHandle: THandle; APath: string): Boolean;
  end;

//  // HashStringAsInt
//  function HashStringAsInt(AValue: string): Integer;

implementation

  function HashStringAsInt(AValue: string): Integer;
  var
    LIndex: Integer;
  begin
    Result := 0;
    for LIndex := 0 to AValue.Length - 1 do begin
      Result := ((Result shl 2) or (Result shr (SizeOf(Result) * 8 - 2))) xor Ord(AValue.Chars[LIndex]);
    end;
  end;

{ TProcessSingleton }

constructor TProcessSingleton.Create;
begin
  inherited;
  FProcessHashInt := 0;
  FProcessMaxCount := PROCESS_MAX_COUNT;
  FMapFileName := 'B7FD5671-8498-4BBE-9C6F-2C9A8918D014';
  DoInitData;
end;

destructor TProcessSingleton.Destroy;
begin
  DoUnInitData;
  inherited;
end;

class function TProcessSingleton.Instance(AContext: IAppContext): TProcessSingleton;
begin
  Result := TProcessSingleton.Create(AContext);
end;

function TProcessSingleton.CheckIsRunning(AHandle: THandle; APath: string): Boolean;
var
  LIndex: Integer;
  LIsRunning: Boolean;
  LHandle, LMasterHandle: THandle;
begin
  Result := False;
  if FProcessShareData <> nil then begin
    FProcessHashInt := HashStringAsInt(APath);
    LIndex := DoFindIndex(FProcessHashInt);
    if (LIndex >= Low(FProcessShareData.FProcessInfos))
      and (LIndex <= High(FProcessShareData.FProcessInfos)) then begin
      if FProcessShareData.FProcessInfos[LIndex].FTerminated > 0 then begin
        LHandle := OpenProcess(PROCESS_TERMINATE, False, FProcessShareData.FProcessInfos[LIndex].FProcessId);
        if LHandle <> 0 then begin
          TerminateProcess(LHandle, 0);
        end;
        for LIndex := LIndex to High(FProcessShareData.FProcessInfos) - 1 do begin
          FProcessShareData.FProcessInfos[LIndex] := FProcessShareData.FProcessInfos[LIndex + 1];
        end;
        FAppContext.SysLog(llDEBUG, Format('FProcessShareData.FProcessInfos[LIndex] > 0', []));
        ZeroMemory(@FProcessShareData.FProcessInfos[LIndex], SizeOf(TProcessInfo));
        Dec(FProcessShareData.FProcessInfoCount);
      end else begin
        SendMessage(FProcessShareData.FProcessInfos[LIndex].FHandle, WM_SYSCOMMAND, SC_RESTORE, 0);
        LMasterHandle := GetLastActivePopup(FProcessShareData.FProcessInfos[LIndex].FHandle);
        FAppContext.SysLog(llDEBUG, Format('LMasterHandle = %d', [LMasterHandle]));
        if (LMasterHandle <> 0)
          and (LMasterHandle <> FProcessShareData.FProcessInfos[LIndex].FHandle)
          and IsWindowVisible(LMasterHandle) and
          IsWindowEnabled(LMasterHandle) then begin
          SetForegroundWindow(LMasterHandle);
          FAppContext.SysLog(llDEBUG, Format('SetForegroundWindow(%d)', [LMasterHandle]));
        end;
        Result := True;
      end;
    end;
    if not Result then begin
      if FProcessShareData.FProcessInfoCount < FProcessMaxCount then begin
        LIndex := FProcessShareData.FProcessInfoCount;
        FProcessShareData^.FProcessInfos[LIndex].FHandle := AHandle;
        FProcessShareData^.FProcessInfos[LIndex].FProcessId := GetCurrentProcessId;
        FProcessShareData^.FProcessInfos[LIndex].FTerminated := 0;
        FProcessShareData^.FProcessInfos[LIndex].FPathHashInt := FProcessHashInt;
        Inc(FProcessShareData.FProcessInfoCount);
      end else begin
        Exit;
      end;
    end;
  end;
end;

procedure TProcessSingleton.DoInitData;
var
  LIndex: Integer;
begin
  FMapFile := OpenFileMapping(FILE_MAP_ALL_ACCESS, False, PChar(FMapFileName));
  if FMapFile = 0 then begin
    FMapFile := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, SizeOf(TProcessShareData), PChar(FMapFileName));
    FProcessShareData := MapViewOfFile(FMapFile, FILE_MAP_WRITE or FILE_MAP_READ, 0, 0, 0);
    if FProcessShareData = nil then begin
      CloseHandle(FMapFile);
      FMapFile := 0;
    end;
  end else begin
    FProcessShareData := MapViewOfFile(FMapFile, FILE_MAP_WRITE or FILE_MAP_READ, 0, 0, 0);
    if FProcessShareData = nil then begin
      CloseHandle(FMapFile);
      FMapFile := 0;
    end;
  end;

  for LIndex := Low(FProcessShareData.FProcessInfos) to High(FProcessShareData.FProcessInfos) do begin
    FAppContext.SysLog(llDEBUG, Format('FProcessInfos[%d].FPathHashInt=%d', [LIndex,
        FProcessShareData.FProcessInfos[LIndex].FPathHashInt]));
  end;
end;

procedure TProcessSingleton.DoUnInitData;
begin
  if FProcessShareData <> nil then begin
    FAppContext.SysLog(llDEBUG, Format('DoDeleteProcessInfo', []));
    DoDeleteProcessInfo;
    UnMapViewOfFile(FProcessShareData);
    FProcessShareData := nil;
  end;
  if FMapFile = 0 then begin
    CloseHandle(FMapFile);
  end;
end;

procedure TProcessSingleton.DoDeleteProcessInfo;
var
  LIndex: Integer;
  LHandle: THandle;
begin
  LIndex := DoFindIndex(FProcessHashInt);
  if (LIndex >= Low(FProcessShareData.FProcessInfos))
    and (LIndex <= High(FProcessShareData.FProcessInfos)) then begin
    if FProcessShareData.FProcessInfos[LIndex].FTerminated > 0 then begin
      for LIndex := LIndex to High(FProcessShareData.FProcessInfos) - 1 do begin
        FProcessShareData.FProcessInfos[LIndex] := FProcessShareData.FProcessInfos[LIndex + 1];
      end;
      ZeroMemory(@FProcessShareData.FProcessInfos[LIndex], SizeOf(TProcessInfo));
      Dec(FProcessShareData.FProcessInfoCount);
    end;
  end;
end;

function TProcessSingleton.DoFindIndex(AHashInt: Integer): Integer;
var
  LIndex, LLow, LHigh: Integer;
begin
  Result := -1;
  for LIndex := Low(FProcessShareData.FProcessInfos) to High(FProcessShareData.FProcessInfos) do begin
    if FProcessShareData.FProcessInfos[LIndex].FPathHashInt = AHashInt then begin
      Result := LIndex;
      Exit;
    end;
  end;
end;

end.
