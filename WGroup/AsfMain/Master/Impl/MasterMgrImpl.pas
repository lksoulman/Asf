unit MasterMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º MasterMgr Implementation
// Author£º      lksoulman
// Date£º        2017-11-20
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Vcl.Forms,
  Master,
  Command,
  MasterMgr,
  ChildPage,
  BaseObject,
  AppContext,
  CommandMgr,
  Generics.Collections;

type

  // MasterInfo
  TMasterInfo = packed record
    FMaster: IMaster;
  end;

  // MasterInfo Pointer
  PMasterInfo = ^TMasterInfo;

  // MasterMgr Implementation
  TMasterMgrImpl = class(TBaseSplitStrInterfacedObject, IMasterMgr)
  private
    // MasterInfos
    FMasterInfos: TList<PMasterInfo>;
    // MasterInfoDic
    FMasterInfoDic: TDictionary<Cardinal, PMasterInfo>;
  protected
    // ClearMasterInfos
    procedure DoClearMasterInfos;
    // LoadDefaultChildPage
    procedure DoLoadDefaultChildPage(AMasterInfo: PMasterInfo);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ICmdInterceptor }

    // ExecuteCmdAfter
    procedure ExecuteCmdAfter(ACommand: Integer; AParams: string);
    // ExecuteCmdBefore
    procedure ExecuteCmdBefore(ACommand: Integer; AParams: string);

    { IMasterMgr }

    // Hide
    procedure Hide;
    // NewMaster
    procedure NewMaster;
    // DelMaster
    procedure DelMaster(AHandle: Integer);
    // IsHasChildPage
    function IsHasChildPage(AHandle: Integer; ACommandId: Integer): Boolean;
    // AddChildPage
    function AddChildPage(AHandle: Integer; AChildPage: IChildPage): Boolean;
    // BringToFrontChildPage
    function BringToFrontChildPage(AHandle, ACommandId: Integer; AParams: string): Boolean;
  end;

implementation

uses
  MasterImpl;

{ TMasterMgrImpl }

constructor TMasterMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FMasterInfos := TList<PMasterInfo>.Create;
  FMasterInfoDic := TDictionary<Cardinal, PMasterInfo>.Create;
end;

destructor TMasterMgrImpl.Destroy;
begin
  DoClearMasterInfos;
  FMasterInfoDic.Free;
  FMasterInfos.Free;
  inherited;
end;

procedure TMasterMgrImpl.DoClearMasterInfos;
var
  LIndex: Integer;
  LPMasterInfo: PMasterInfo;
begin
  for LIndex := 0 to FMasterInfos.Count - 1 do begin
    LPMasterInfo := FMasterInfos.Items[LIndex];
    if LPMasterInfo <> nil then begin
      if LPMasterInfo^.FMaster <> nil then begin
        LPMasterInfo^.FMaster := nil;
      end;
    end;
  end;
end;

procedure TMasterMgrImpl.DoLoadDefaultChildPage(AMasterInfo: PMasterInfo);
begin
  if AMasterInfo <> nil then begin
    FAppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_SIMPLEHQTEST,
      Format('MasterHandle=%d@Params=InnerCode=1752', [AMasterInfo.FMaster.Handle]));
  end;
end;

procedure TMasterMgrImpl.ExecuteCmdAfter(ACommand: Integer; AParams: string);
begin

end;

procedure TMasterMgrImpl.ExecuteCmdBefore(ACommand: Integer; AParams: string);
var
  LHandle: Integer;
  LMasterInfo: PMasterInfo;
  LMasterHandle, LGoFuncName: string;
begin
  if ACommand >= ASF_COMMAND_ID_SIMPLEHQTEST then begin
    BeginSplitParams(AParams);
    try
      ParamsVal('GoFuncName', LGoFuncName);
      if LGoFuncName = '' then begin
        ParamsVal('MasterHandle', LMasterHandle);
        LHandle := StrToIntDef(LMasterHandle, 0);
        if LHandle <> 0 then begin
          if FMasterInfoDic.TryGetValue(LHandle, LMasterInfo) then begin
            LMasterInfo.FMaster.AddCmdCookie(ACommand, AParams);
          end;
        end;
      end;
    finally
      EndSplitParams;
    end;
  end;
end;

procedure TMasterMgrImpl.Hide;
var
  LIndex: Integer;
  LPMasterInfo: PMasterInfo;
begin
  for LIndex := 0 to FMasterInfos.Count - 1 do begin
    LPMasterInfo := FMasterInfos.Items[LIndex];
    if LPMasterInfo <> nil then begin
      if LPMasterInfo^.FMaster <> nil then begin
        LPMasterInfo^.FMaster.Hide;
      end;
    end;
  end;
end;

procedure TMasterMgrImpl.NewMaster;
var
  LPMasterInfo: PMasterInfo;
begin
  New(LPMasterInfo);
  LPMasterInfo.FMaster := TMasterImpl.Create(FAppContext) as IMaster;
  FMasterInfos.Add(LPMasterInfo);
  FMasterInfoDic.AddOrSetValue(LPMasterInfo.FMaster.GetHandle, LPMasterInfo);
  if FMasterInfos.Count <= 1 then begin
    LPMasterInfo.FMaster.SetWindowState(wsMaximized);
  end;
  LPMasterInfo.FMaster.Show;
  DoLoadDefaultChildPage(LPMasterInfo);
end;

procedure TMasterMgrImpl.DelMaster(AHandle: Integer);
var
  LPMasterInfo: PMasterInfo;
begin
  if FMasterInfoDic.TryGetValue(AHandle, LPMasterInfo) then begin
    FMasterInfos.Remove(LPMasterInfo);
    FMasterInfoDic.Remove(AHandle);
    if LPMasterInfo.FMaster <> nil then begin
      LPMasterInfo.FMaster := nil;
      Dispose(LPMasterInfo);
    end;

    if FMasterInfos.Count <= 0 then begin
      FAppContext.ExitApp;
    end;
  end;
end;

function TMasterMgrImpl.IsHasChildPage(AHandle: Integer; ACommandId: Integer): Boolean;
var
  LPMasterInfo: PMasterInfo;
begin
  Result := False;
  if FMasterInfoDic.TryGetValue(AHandle, LPMasterInfo) then begin
    if LPMasterInfo.FMaster <> nil then begin
      Result := LPMasterInfo^.FMaster.IsHasChildPage(ACommandId);
    end;
  end;
end;

function TMasterMgrImpl.AddChildPage(AHandle: Integer; AChildPage: IChildPage): Boolean;
var
  LPMasterInfo: PMasterInfo;
begin
  Result := False;
  if AChildPage = nil then Exit;

  if FMasterInfoDic.TryGetValue(AHandle, LPMasterInfo) then begin
    if LPMasterInfo^.FMaster <> nil then begin
      Result := LPMasterInfo^.FMaster.AddChildPage(AChildPage);
    end;
  end;
end;

function TMasterMgrImpl.BringToFrontChildPage(AHandle, ACommandId: Integer; AParams: string): Boolean;
var
  LPMasterInfo: PMasterInfo;
begin
  Result := False;
  if FMasterInfoDic.TryGetValue(AHandle, LPMasterInfo) then begin
    if LPMasterInfo^.FMaster <> nil then begin
      Result := LPMasterInfo^.FMaster.BringToFrontChildPage(ACommandId, AParams);
    end;
  end;
end;

end.
