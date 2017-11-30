unit WDLLFactoryImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º WDLLFactory Implementation
// Author£º      lksoulman
// Date£º        2017-4-11
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Vcl.Forms,
  PlugInMgr,
  AppContext,
  CommonLock,
  WDLLFactory,
  AppContextObject,
  CommonRefCounter,
  Generics.Collections;

type

  // DllGetPlugInMgr
  TDllGetPlugInMgr = function(AMainApplication: TApplication; AContext: IAppContext): IPlugInMgr; stdcall;

  // WDLLFactory Implementation
  TWDLLFactoryImpl = class(TAppContextObject, IWDLLFactory)
  private
    type
      // PlugInMgrInfo
      TPlugInMgrInfo = packed record
        FMODULE: HMODULE;
        FPlugInMgr: IPlugInMgr;
        FDllGetPlugInMgr: TDllGetPlugInMgr;
      end;
      // PlugInMgrInfo Pointer
      PPlugInMgrInfo = ^TPlugInMgrInfo;
  private
    // Lock
    FLock: TCSLock;
    // FuncName
    FFuncName: string;
    // MainPlugInMgrInfo
    FMainPlugInMgrInfo: TPlugInMgrInfo;
    // PlugInMgr
    FPlugInMgrInfos: TList<PPlugInMgrInfo>;
    // PlugInMgrDic
    FPlugInMgrInfoDic: TDictionary<string, Integer>;
  protected
    // Clear
    procedure DoClear;
    // Load PlugInMgr
    procedure DoLoadPlugInMgr(APlugInMgrInfo: PPlugInMgrInfo);
    // Get PlugInMgrInfo
    function GetPlugInMgrInfo(AIndex: Integer): PPlugInMgrInfo;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IWDLLFactory }

    // Load
    procedure Load(AFileName: string);
  end;

implementation

uses
  Command,
  AsfMainPlugInMgrImpl;

{ TWDLLFactoryImpl }

constructor TWDLLFactoryImpl.Create(AContext: IAppContext);
begin
  inherited;
  FFuncName := 'GetPlugInMgr';
  FLock := TCSLock.Create;
  FPlugInMgrInfos := TList<PPlugInMgrInfo>.Create;
  FPlugInMgrInfoDic := TDictionary<string, Integer>.Create(15);
  FMainPlugInMgrInfo.FPlugInMgr := TAsfMainPlugInMgrImpl.Create(AContext);
  FMainPlugInMgrInfo.FPlugInMgr.Load;
end;

destructor TWDLLFactoryImpl.Destroy;
begin
  FMainPlugInMgrInfo.FPlugInMgr := nil;
  DoClear;
  FPlugInMgrInfoDic.Free;
  FPlugInMgrInfos.Free;
  FLock.Free;
  inherited;
end;

procedure TWDLLFactoryImpl.Load(AFileName: string);
var
  LIndex: Integer;
  LHModule: HMODULE;
  LPPlugInMgrInfo: PPlugInMgrInfo;
begin
  if AFileName = '' then Exit;

  FLock.Lock;
  try
    if not FPlugInMgrInfoDic.TryGetValue(AFileName, LIndex) then begin
      LHModule := LoadLibrary(PChar(AFileName));
      if LHModule <> 0 then begin
        New(LPPlugInMgrInfo);
        if LPPlugInMgrInfo <> nil then begin
          LPPlugInMgrInfo^.FMODULE := LHModule;
          LPPlugInMgrInfo^.FDllGetPlugInMgr := GetProcAddress(LHModule, PChar(FFuncName));
          DoLoadPlugInMgr(LPPlugInMgrInfo);
          LIndex := FPlugInMgrInfos.Add(LPPlugInMgrInfo);
          FPlugInMgrInfoDic.AddOrSetValue(AFileName, LIndex);
//          FAppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_LOADPROCESS,
//            Format('Load dll %s PlugInMgr', [AFileName]));
        end;
      end;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TWDLLFactoryImpl.DoClear;
var
  LIndex: Integer;
  LPPlugInMgrInfo: PPlugInMgrInfo;
begin
  for LIndex := FPlugInMgrInfos.Count - 1 downto 0 do begin
    LPPlugInMgrInfo := FPlugInMgrInfos.Items[LIndex];
    if LPPlugInMgrInfo <> nil then begin
      if LPPlugInMgrInfo^.FPlugInMgr <> nil then begin
        LPPlugInMgrInfo^.FPlugInMgr := nil;
        FreeLibrary(LPPlugInMgrInfo^.FMODULE);
      end;
      Dispose(LPPlugInMgrInfo);
    end;
  end;
  FPlugInMgrInfos.Clear;
  FPlugInMgrInfoDic.Clear;
end;

procedure TWDLLFactoryImpl.DoLoadPlugInMgr(APlugInMgrInfo: PPlugInMgrInfo);
begin
  if not Assigned(APlugInMgrInfo^.FDllGetPlugInMgr) then Exit;

  APlugInMgrInfo^.FPlugInMgr := APlugInMgrInfo^.FDllGetPlugInMgr(Application, FAppContext);
  if APlugInMgrInfo^.FPlugInMgr <> nil then begin
    APlugInMgrInfo^.FPlugInMgr.Load;
  end;
end;

function TWDLLFactoryImpl.GetPlugInMgrInfo(AIndex: Integer): PPlugInMgrInfo;
begin
  if (AIndex >= 0)
    and (AIndex < FPlugInMgrInfos.Count) then begin
    Result := FPlugInMgrInfos.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

end.
