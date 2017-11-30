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
  MasterMgr,
  AppContext,
  AppContextObject,
  CommonRefCounter,
  Generics.Collections;

type

  // MasterInfo
  TMasterInfo = packed record
    FMaster: IMaster;
  end;

  // MasterInfo Pointer
  PMasterInfo = ^TMasterInfo;

  // MasterMgr Implementation
  TMasterMgrImpl = class(TAppContextObject, IMasterMgr)
  private
    // MasterInfos
    FMasterInfos: TList<PMasterInfo>;
    // MasterInfoDic
    FMasterInfoDic: TDictionary<Cardinal, PMasterInfo>;
  protected
    // Clear MasterInfos
    procedure DoClearMasterInfos;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IMasterMgr }

    // Hide
    procedure Hide;
    // New Master
    procedure NewMaster;
    // Del Master
    procedure DelMaster(AHandle: Integer);
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

end.
