unit AbstractServiceImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AbstractService implementation
// Author£º      lksoulman
// Date£º        2017-9-13
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Proxy,
  GFData,
  Windows,
  Classes,
  SysUtils,
  WaitMode,
  ShareMgr,
  Executors,
  GFDataImpl,
  AppContext,
  HttpContext,
  GFDataUpdate,
  ExecutorThread,
  HttpContextPool,
  AppContextObject;

type

  // AbstractService Implementation
  TAbstractServiceImpl = class(TAppContextObject)
  private
  protected
    // Server Url
    FServerUrl: string;
    // Init Logined
    FInitLogined: Boolean;
    // Executor Count
    FExecutorCount: Integer;
    // Priority Executor Count
    FPriorityExecutorCount: Integer;
    // Heart Beat Time
    FHeartBeatInterval: Cardinal;
    // Last Heart Beat Time
    FLastHeartBeatTick: Cardinal;

    // Share Manager
    FShareMgr: IShareMgr;
    // Handler Executors
    FExecutors: TExecutors;
    // Priority Handler Executors
    FPriorityExecutors: TExecutors;
    // Keep Alive Heart Beat Thread
    FKeepAliveHeartBeatThread: TExecutorThread;


    // CreateBefore
    procedure DoCreateBefore; virtual;
    // Keep Alive Heart Beat
    procedure DoKeepAliveHeartBeat; virtual;
    // Call back Keep Alive Heart Beat GFData
    procedure DoKeepAliveHeartBeatGFData(AGFData: IGFData); virtual;
    // Heart Beat Thread Execute
    procedure DoKeepAliveHeartBeatThreadExecute(AObject: TObject); virtual;

    // Create GFData
    function DoCreateGFData: IGFData;
    // No Login Default Post
    function DoNoLoginDefaultPost(AGFData: IGFData): Boolean;
    // Synchronous Post
    function DoSyncPost(AIndicator: WideString; AWaitTime: DWORD): IGFData;
    // Asynchronous Post
    function DoAsyncPost(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
    // Priority Synchronous Post
    function DoPrioritySyncPost(AIndicator: WideString; AWaitTime: DWORD): IGFData;
    // Priority Asynchronous Post
    function DoPriorityAsyncPost(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
  end;

implementation

uses
  Vcl.Forms,
  LogLevel,
  GFDataSet,
  ErrorCode,
  ShareMgrImpl;

{ TAbstractServiceImpl }

constructor TAbstractServiceImpl.Create(AContext: IAppContext);
begin
  inherited;
  DoCreateBefore;
  FInitLogined := False;
  FShareMgr := TShareMgrImpl.Create(FAppContext) as IShareMgr;
  FExecutors := TExecutors.Create(FShareMgr);
  FPriorityExecutors := TExecutors.Create(FShareMgr);
  FKeepAliveHeartBeatThread := TExecutorThread.Create;
  FKeepAliveHeartBeatThread.ThreadMethod := DoKeepAliveHeartBeatThreadExecute;
  FExecutors.SetFixedThread(FExecutorCount);
  FPriorityExecutors.SetFixedThread(FPriorityExecutorCount);
  FExecutors.Start;
  FPriorityExecutors.Start;
  FKeepAliveHeartBeatThread.StartEx;
end;

destructor TAbstractServiceImpl.Destroy;
begin
  FKeepAliveHeartBeatThread.ShutDown;
  FPriorityExecutors.ShutDown;
  FExecutors.ShutDown;
  FPriorityExecutors.Free;
  FExecutors.Free;
  FShareMgr := nil;
  inherited;
end;

procedure TAbstractServiceImpl.DoCreateBefore;
begin
  FExecutorCount := 6;
  FPriorityExecutorCount := 2;
  FLastHeartBeatTick := 0;
  FHeartBeatInterval := 1000 * 60 * 10;
end;

procedure TAbstractServiceImpl.DoKeepAliveHeartBeat;
var
  LIndicator: string;
begin
  LIndicator := Format('UPDATE_SESSION_EXPIRE("%s", "pc")', [FShareMgr.GetHardDiskIdMD5]);
  DoAsyncPost(LIndicator, DoKeepAliveHeartBeatGFData, 0);
end;

procedure TAbstractServiceImpl.DoKeepAliveHeartBeatGFData(AGFData: IGFData);
begin
  FLastHeartBeatTick := GetTickCount;
  if FAppContext <> nil then begin
    FAppContext.SysLog(llDEBUG, Format('[%s][DoKeepAliveHeartBeatThreadExecute] Update LastHeartBeatTick %d', [Self.ClassName, FLastHeartBeatTick]));
  end;
end;

procedure TAbstractServiceImpl.DoKeepAliveHeartBeatThreadExecute(AObject: TObject);
var
  LResult: Cardinal;
  LTick, LInterval: Cardinal;
begin
  while not FKeepAliveHeartBeatThread.IsTerminated do begin
    Application.ProcessMessages;

    LResult := FKeepAliveHeartBeatThread.WaitForEx(3000);
    case LResult of
      WAIT_TIMEOUT:
        begin
          if FKeepAliveHeartBeatThread.IsTerminated then Exit;

          if FShareMgr.GetIsLogined then begin
            LTick := GetTickCount;
            LInterval := LTick - FLastHeartBeatTick;
            if LInterval > FHeartBeatInterval  then begin
              DoKeepAliveHeartBeat;
              if FAppContext <> nil then begin
                FAppContext.SysLog(llDEBUG, Format('[%s][DoKeepAliveHeartBeatThreadExecute] DoKeepAliveHeartBeat %d', [Self.ClassName, LTick]));
              end;
            end;
          end;
        end;
    end;
  end;
end;

function TAbstractServiceImpl.DoCreateGFData: IGFData;
begin
  Result := TGFDataImpl.Create as IGFData;
end;

function TAbstractServiceImpl.DoNoLoginDefaultPost(AGFData: IGFData): Boolean;
begin
  Result := True;
  if FInitLogined then begin
    (AGFData as IGFDataUpdate).SetErrorCode(ErrorCode_Service_Response_NoLogin);
  end else begin
    (AGFData as IGFDataUpdate).SetErrorCode(ErrorCode_Service_Response_Need_ReLogin);
  end;
end;

function TAbstractServiceImpl.DoSyncPost(AIndicator: WideString; AWaitTime: DWORD): IGFData;
var
  LContext: THttpContext;
begin
  Result := DoCreateGFData;
  LContext := THttpContext(FShareMgr.GetHttpContextPool.Allocate);
  if LContext <> nil then begin
    LContext.WaitMode := wmBlocking;
    LContext.Indicator := AIndicator;
    LContext.GFDataUpdate := Result as IGFDataUpdate;
    FExecutors.Submit(LContext);
    LContext.SetWaitStart(AWaitTime);
    FShareMgr.GetHttpContextPool.DeAllocate(LContext);
  end;
end;

function TAbstractServiceImpl.DoAsyncPost(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
var
  LContext: THttpContext;
begin
  Result := DoCreateGFData;
  LContext := THttpContext(FShareMgr.GetHttpContextPool.Allocate);
  if LContext <> nil then begin
    LContext.DataEvent := AEvent;
    LContext.WaitMode := wmNoBlocking;
    LContext.Indicator := AIndicator;
    LContext.GFDataUpdate := Result as IGFDataUpdate;
    LContext.GFDataUpdate.SetKey(AKey);
    FExecutors.Submit(LContext);
  end;
end;

function TAbstractServiceImpl.DoPrioritySyncPost(AIndicator: WideString; AWaitTime: DWORD): IGFData;
var
  LContext: THttpContext;
begin
  Result := DoCreateGFData;
  LContext := THttpContext(FShareMgr.GetHttpContextPool.Allocate);
  if LContext <> nil then begin
    LContext.WaitMode := wmBlocking;
    LContext.Indicator := AIndicator;
    LContext.GFDataUpdate := Result as IGFDataUpdate;
    FPriorityExecutors.Submit(LContext);
    LContext.SetWaitStart(AWaitTime);
    FShareMgr.GetHttpContextPool.DeAllocate(LContext);
  end;
end;

function TAbstractServiceImpl.DoPriorityAsyncPost(AIndicator: WideString; AEvent: TGFDataEvent; AKey: Int64): IGFData;
var
  LContext: THttpContext;
begin
  Result := DoCreateGFData;
  LContext := THttpContext(FShareMgr.GetHttpContextPool.Allocate);
  if LContext <> nil then begin
    LContext.DataEvent := AEvent;
    LContext.WaitMode := wmNoBlocking;
    LContext.Indicator := AIndicator;
    LContext.GFDataUpdate := Result as IGFDataUpdate;
    LContext.GFDataUpdate.SetKey(AKey);
    FPriorityExecutors.Submit(LContext);
  end;
end;

end.
