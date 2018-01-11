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
  TMasterInfo = class(TBaseObject)
  private
    FMaster: IMaster;
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
  end;

  // MasterMgr Implementation
  TMasterMgrImpl = class(TBaseSplitStrInterfacedObject, IMasterMgr)
  private
    // MasterInfos
    FMasterInfos: TList<TMasterInfo>;
    // MasterInfoDic
    FMasterInfoDic: TDictionary<Cardinal, TMasterInfo>;
  protected
    // ClearMasterInfos
    procedure DoClearMasterInfos;
    // LoadDefaultChildPage
    procedure DoLoadDefaultChildPage(AMasterInfo: TMasterInfo);
    // ApplicationMessage
    procedure DoApplicationMessage(var AMsg: TMsg; var AHandled: Boolean);
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

{ TMasterInfo }

constructor TMasterInfo.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TMasterInfo.Destroy;
begin
  FMaster := nil;
  inherited;
end;

{ TMasterMgrImpl }

constructor TMasterMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FMasterInfos := TList<TMasterInfo>.Create;
  FMasterInfoDic := TDictionary<Cardinal, TMasterInfo>.Create;
  Application.OnMessage := DoApplicationMessage;
end;

destructor TMasterMgrImpl.Destroy;
begin
  Application.OnMessage := nil;
  DoClearMasterInfos;
  FMasterInfoDic.Free;
  FMasterInfos.Free;
  inherited;
end;

procedure TMasterMgrImpl.DoClearMasterInfos;
var
  LIndex: Integer;
  LMasterInfo: TMasterInfo;
begin
  for LIndex := 0 to FMasterInfos.Count - 1 do begin
    LMasterInfo := FMasterInfos.Items[LIndex];
    if LMasterInfo <> nil then begin
      LMasterInfo.Free;
    end;
  end;
end;

procedure TMasterMgrImpl.DoLoadDefaultChildPage(AMasterInfo: TMasterInfo);
begin
//  if AMasterInfo <> nil then begin
//    FAppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_SIMPLEHQTIMETEST,
//      Format('MasterHandle=%d@Params=InnerCode=1752', [AMasterInfo.FMaster.Handle]));
//  end;

//  if AMasterInfo <> nil then begin
//    FAppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_HOMEPAGE,
//      Format('MasterHandle=%d@Params=InnerCode=1752', [AMasterInfo.FMaster.Handle]));
//  end;
end;

procedure TMasterMgrImpl.DoApplicationMessage(var AMsg: TMsg; var AHandled: Boolean);
begin

end;

procedure TMasterMgrImpl.ExecuteCmdAfter(ACommand: Integer; AParams: string);
begin

end;

procedure TMasterMgrImpl.ExecuteCmdBefore(ACommand: Integer; AParams: string);
var
  LHandle: Integer;
  LMasterInfo: TMasterInfo;
  LMasterHandle, LGoFuncName: string;
begin
  if ACommand >= ASF_COMMAND_ID_SIMPLEHQTIMETEST then begin
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
  LMasterInfo: TMasterInfo;
begin
  for LIndex := 0 to FMasterInfos.Count - 1 do begin
    LMasterInfo := FMasterInfos.Items[LIndex];
    if LMasterInfo <> nil then begin
      if LMasterInfo.FMaster <> nil then begin
        LMasterInfo.FMaster.Hide;
      end;
    end;
  end;
end;

procedure TMasterMgrImpl.NewMaster;
var
  LMasterInfo: TMasterInfo;
begin
  LMasterInfo := TMasterInfo.Create(FAppContext);
  LMasterInfo.FMaster := TMasterImpl.Create(FAppContext) as IMaster;
  FMasterInfos.Add(LMasterInfo);
  FMasterInfoDic.AddOrSetValue(LMasterInfo.FMaster.GetHandle, LMasterInfo);
  if FMasterInfos.Count <= 1 then begin
    LMasterInfo.FMaster.SetWindowState(wsMaximized);
  end;
  LMasterInfo.FMaster.Show;
  DoLoadDefaultChildPage(LMasterInfo);
end;

procedure TMasterMgrImpl.DelMaster(AHandle: Integer);
var
  LMasterInfo: TMasterInfo;
begin
  if FMasterInfoDic.TryGetValue(AHandle, LMasterInfo) then begin
    FMasterInfos.Remove(LMasterInfo);
    FMasterInfoDic.Remove(AHandle);
    if LMasterInfo <> nil then begin
      LMasterInfo.Free;
    end;
    if FMasterInfos.Count <= 0 then begin
      FAppContext.ExitApp;
    end;
  end;
end;

function TMasterMgrImpl.IsHasChildPage(AHandle: Integer; ACommandId: Integer): Boolean;
var
  LMasterInfo: TMasterInfo;
begin
  Result := False;
  if FMasterInfoDic.TryGetValue(AHandle, LMasterInfo) then begin
    if LMasterInfo.FMaster <> nil then begin
      Result := LMasterInfo.FMaster.IsHasChildPage(ACommandId);
    end;
  end;
end;

function TMasterMgrImpl.AddChildPage(AHandle: Integer; AChildPage: IChildPage): Boolean;
var
  LMasterInfo: TMasterInfo;
begin
  Result := False;
  if AChildPage = nil then Exit;

  if FMasterInfoDic.TryGetValue(AHandle, LMasterInfo) then begin
    if LMasterInfo.FMaster <> nil then begin
      Result := LMasterInfo.FMaster.AddChildPage(AChildPage);
    end;
  end;
end;

function TMasterMgrImpl.BringToFrontChildPage(AHandle, ACommandId: Integer; AParams: string): Boolean;
var
  LMasterInfo: TMasterInfo;
begin
  Result := False;
  if FMasterInfoDic.TryGetValue(AHandle, LMasterInfo) then begin
    if LMasterInfo.FMaster <> nil then begin
      Result := LMasterInfo.FMaster.BringToFrontChildPage(ACommandId, AParams);
    end;
  end;
end;

end.
