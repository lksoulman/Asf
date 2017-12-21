unit CommandMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£∫ CommandMgr Implementation
// Author£∫      lksoulman
// Date£∫        2017-11-14
// Comments£∫
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Command,
  CommandMgr,
  BaseObject,
  AppContext,
  CommonPool,
  CommonLock,
  CommonQueue,
  ExecutorThread,
  Generics.Collections;

type

  // CommandJob
  PCommandJob = ^TCommandJob;

  // CommandJob
  TCommandJob = packed record
    FId: Cardinal;
    FParams: string;
    FLast: Cardinal;
    FDelaySecs: Cardinal;
    FPrev: PCommandJob;
    FNext: PCommandJob;
  end;

  // CommandJobList
  TCommandJobList = class(TBaseObject)
  private
    // Lock
    FLock: TCSLock;
    // Count
    FCount: Integer;
    // Head
    FHead: PCommandJob;
    // Tail
    FTail: PCommandJob;
  protected
    // ClearJobs
    procedure DoClearJobs;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Remove
    procedure Remove(AJob: PCommandJob);
    // AddHeadElement
    procedure AddHeadElement(AJob: PCommandJob);
    // AddTailElemnt
    procedure AddTailElement(AJob: PCommandJob);
    // AddElementByDelay
    procedure AddElementByDelay(AJob: PCommandJob);
  end;

  // CommandJobPool
  TCommandJobPool = class(TPointerPool)
  private
  protected
  public
    // Create
    function DoCreate: Pointer; override;
    // Destroy
    procedure DoDestroy(APointer: Pointer); override;
    // Allocate Before
    procedure DoAllocateBefore(APointer: Pointer); override;
    // DeAllocate Before
    procedure DoDeAllocateBefore(APointer: Pointer); override;
  end;

  // CommandMgr Implementation
  TCommandMgrImpl = class(TBaseInterfacedObject, ICommandMgr)
  private
    // Lock
    FLock: TCSLock;
    // IsStart
    FIsStart: Boolean;
    // Commands
    FCommands: TList<ICommand>;
    // Interceptors
    FInterceptors: TList<ICmdInterceptor>;
    // CommandDic
    FCommandDic: TDictionary<Cardinal, ICommand>;
    // SysCommandDic
    FSysCommandDic: TDictionary<Cardinal, ICommand>;
    // CommandJobPool
    FCommandJobPool: TCommandJobPool;
    // DelayCommandJob
    FDelayCommandJobs: TCommandJobList;
    // FixedCommandJob
    FFixedCommandJobs: TCommandJobList;
    // AsyncExecuteThread
    FAsyncExecuteCmdThread: TExecutorThread;
  protected
    // ExecuteDelayJobs
    procedure DoExecuteDelayJobs;
    // ExecuteFixedJobs
    procedure DoExecuteFixedJobs;
    // AsyncExecuteCmdThread
    procedure DoAsyncExecuteCmdThread(AObject: TObject);
    // ExecuteCmdAfter
    procedure DoExecuteCmdAfter(ACommandId: Cardinal; AParams: string);
    // ExecuteCmdBefore
    procedure DoExecuteCmdBefore(ACommandId: Cardinal; AParams: string);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ICommandMgr }

    // StopJobs
    procedure StopJobs;
    // Register
    function RegisterCmd(ACommand: ICommand): Boolean;
    // UnRegister
    function UnRegisterCmd(ACommand: ICommand): Boolean;
    // ExecuteCmd
    function ExecuteCmd(ACommandId: Cardinal; AParams: string): Boolean;
    // RegisterCmdInterceptor
    function RegisterInterceptor(AInterceptor: ICmdInterceptor): Boolean;
    // UnRegisterCmdInterceptor
    function UnRegisterInterceptor(AInterceptor: ICmdInterceptor): Boolean;
    // DelayExecuteCmd
    function DelayExecuteCmd(ACommandId: Cardinal; AParams: string; ADelaySecs: Cardinal): Boolean;
    // FixedExecuteCmd
    function FixedExecuteCmd(ACommandId: Cardinal; AParams: string; AFixedSecs: Cardinal): Boolean;
  end;

implementation

{ TCommandJobPool }

function TCommandJobPool.DoCreate: Pointer;
var
  LCommandJob: PCommandJob;
begin
  New(LCommandJob);
  LCommandJob^.FId := 0;
  LCommandJob^.FParams := '';
  LCommandJob^.FLast := 0;
  LCommandJob^.FDelaySecs := 0;
  LCommandJob^.FPrev := nil;
  LCommandJob^.FNext := nil;
  Result := LCommandJob;
end;

procedure TCommandJobPool.DoDestroy(APointer: Pointer);
begin
  if APointer <> nil then begin
    Dispose(APointer);
  end;
end;

procedure TCommandJobPool.DoAllocateBefore(APointer: Pointer);
begin
  if APointer <> nil then begin
    PCommandJob(APointer)^.FId := 0;
    PCommandJob(APointer)^.FParams := '';
    PCommandJob(APointer)^.FLast := 0;
    PCommandJob(APointer)^.FDelaySecs := 0;
    PCommandJob(APointer)^.FPrev := nil;
    PCommandJob(APointer)^.FNext := nil;
  end;
end;

procedure TCommandJobPool.DoDeAllocateBefore(APointer: Pointer);
begin

end;

{ TCommandJobList }

constructor TCommandJobList.Create(AContext: IAppContext);
begin
  inherited;
  FHead := nil;
  FTail := nil;
  FCount := 0;
  FLock := TCSLock.Create;
end;

destructor TCommandJobList.Destroy;
begin
  DoClearJobs;
  FLock.Free;
  inherited;
end;

procedure TCommandJobList.DoClearJobs;
var
  LNextJob, LJob: PCommandJob;
begin
  LNextJob := FHead;
  while LNextJob <> nil do begin
    LJob := LNextJob;
    LNextJob := LNextJob.FNext;
    Dispose(LJob);
  end;
end;

procedure TCommandJobList.Lock;
begin
  FLock.Lock;
end;

procedure TCommandJobList.UnLock;
begin
  FLock.UnLock;
end;

procedure TCommandJobList.Remove(AJob: PCommandJob);
begin
  if AJob = nil then Exit;

  if AJob = FHead then begin
    if FHead = FTail then begin
      FHead := nil;
      FTail := nil;
    end else begin
      FHead := FHead.FNext;
      FHead.FPrev := nil;
      AJob^.FNext := nil;
    end;
    Dec(FCount);
  end else if AJob = FTail then begin
    if FHead = FTail then begin
      FHead := nil;
      FTail := nil;
    end else begin
      FTail := FTail.FPrev;
      FTail.FNext := nil;
      AJob^.FPrev := nil;
    end;
    Dec(FCount);
  end else begin
    AJob^.FPrev.FNext := AJob^.FNext;
    AJob^.FNext.FPrev := AJob^.FPrev;
    AJob^.FNext := nil;
    AJob^.FPrev := nil;
    Dec(FCount);
  end;
end;

procedure TCommandJobList.AddHeadElement(AJob: PCommandJob);
begin
  if AJob = nil then Exit;

  FLock.Lock;
  try
    if FHead = nil then begin
      FHead := AJob;
      FTail := AJob;
    end else begin
      FHead^.FPrev := AJob;
      AJob^.FNext := FHead;
      FHead := AJob;
    end;
    Inc(FCount);
  finally
    FLock.UnLock;
  end;
end;

procedure TCommandJobList.AddTailElement(AJob: PCommandJob);
begin
  if AJob = nil then Exit;

  FLock.Lock;
  try
    if FHead = nil then begin
      FHead := AJob;
      FTail := AJob;
    end else begin
      if FTail <> nil then begin
        FTail^.FNext := AJob;
        AJob^.FPrev := FTail;
        FTail := AJob;
      end;
    end;
    Inc(FCount);
  finally
    FLock.UnLock;
  end;
end;

procedure TCommandJobList.AddElementByDelay(AJob: PCommandJob);
var
  LJob, LPrevJob: PCommandJob;
begin
  if AJob = nil then Exit;

  FLock.Lock;
  try
    if FHead = nil then begin
      FHead := AJob;
      FTail := AJob;
    end else begin
      LPrevJob := FTail;
      while LPrevJob <> nil do begin
        LJob := LPrevJob;
        if LJob^.FDelaySecs > AJob^.FDelaySecs then begin
          LPrevJob := LPrevJob.FPrev;
        end else begin
          AJob^.FNext := LJob^.FNext;
          LJob^.FNext := AJob;
          AJob^.FPrev := LJob;
          if LJob = FTail then begin
            FTail := AJob;
          end;
          Break;
        end;
      end;

      if LPrevJob = nil then begin
        AJob.FNext := FHead;
        FHead.FPrev := AJob;
        FHead := AJob;
      end;
    end;
    Inc(FCount);
  finally
    FLock.UnLock;
  end;
end;

{ TCommandMgrImpl }

constructor TCommandMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FLock := TCSLock.Create;
  FCommands := TList<ICommand>.Create;
  FInterceptors := TList<ICmdInterceptor>.Create;
  FCommandDic := TDictionary<Cardinal, ICommand>.Create;
  FSysCommandDic := TDictionary<Cardinal, ICommand>.Create;
  FCommandJobPool := TCommandJobPool.Create(10);
  FDelayCommandJobs := TCommandJobList.Create(AContext);
  FFixedCommandJobs := TCommandJobList.Create(AContext);
  FAsyncExecuteCmdThread := TExecutorThread.Create;
  FAsyncExecuteCmdThread.ThreadMethod := DoAsyncExecuteCmdThread;
  FAsyncExecuteCmdThread.StartEx;
  FIsStart := True;
end;

destructor TCommandMgrImpl.Destroy;
begin
  FAsyncExecuteCmdThread.ShutDown;
  FFixedCommandJobs.Free;
  FDelayCommandJobs.Free;
  FCommandJobPool.Free;
  FSysCommandDic.Free;
  FCommandDic.Free;
  FInterceptors.Free;
  FCommands.Free;
  FLock.Free;
  inherited;
end;

procedure TCommandMgrImpl.DoExecuteDelayJobs;
var
  LNextJob, LJob: PCommandJob;
begin
  FDelayCommandJobs.Lock;
  try
    LNextJob := FDelayCommandJobs.FHead;
    while LNextJob <> nil do begin
      if FAsyncExecuteCmdThread.IsTerminated then Exit;

      LJob := LNextJob;
      LNextJob := LNextJob.FNext;
      LJob.FDelaySecs := LJob.FDelaySecs - 1;
      if LJob.FDelaySecs <= 0 then begin
        ExecuteCmd(LJob.FId, LJob.FParams);
        FDelayCommandJobs.Remove(LJob);
        FCommandJobPool.DeAllocate(LJob);
      end;
    end;
  finally
    FDelayCommandJobs.UnLock;
  end;
end;

procedure TCommandMgrImpl.DoExecuteFixedJobs;
var
  LNextJob, LJob: PCommandJob;
begin
  FFixedCommandJobs.Lock;
  try
    LNextJob := FFixedCommandJobs.FHead;
    while LNextJob <> nil do begin
      if FAsyncExecuteCmdThread.IsTerminated then Exit;

      LJob := LNextJob;
      LNextJob := LNextJob.FNext;
      LJob.FLast := LJob.FLast + 1;
      if LJob.FLast >= LJob.FDelaySecs then begin
        ExecuteCmd(LJob.FId, LJob.FParams);
        LJob.FLast := 0;
      end;
    end;
  finally
    FFixedCommandJobs.UnLock;
  end;
end;

procedure TCommandMgrImpl.DoAsyncExecuteCmdThread(AObject: TObject);
begin
  while not FAsyncExecuteCmdThread.IsTerminated do begin
    case FAsyncExecuteCmdThread.WaitForEx(1000) of
      WAIT_TIMEOUT:
        begin
          if FAsyncExecuteCmdThread.IsTerminated then Exit;

          DoExecuteDelayJobs;
          DoExecuteFixedJobs;
        end;
    end;
  end;
end;

procedure TCommandMgrImpl.DoExecuteCmdAfter(ACommandId: Cardinal; AParams: string);
var
  LIndex: Integer;
begin
  for LIndex := 0 to FInterceptors.Count - 1 do begin
    if FInterceptors.Items[LIndex] <> nil then begin
      FInterceptors.Items[LIndex].ExecuteCmdAfter(ACommandId, AParams);
    end;
  end;
end;

procedure TCommandMgrImpl.DoExecuteCmdBefore(ACommandId: Cardinal; AParams: string);
var
  LIndex: Integer;
begin
  for LIndex := 0 to FInterceptors.Count - 1 do begin
    if FInterceptors.Items[LIndex] <> nil then begin
      FInterceptors.Items[LIndex].ExecuteCmdBefore(ACommandId, AParams);
    end;
  end;
end;

procedure TCommandMgrImpl.StopJobs;
begin
  if FIsStart then begin
    FAsyncExecuteCmdThread.ShutDown;
    FIsStart := False;
  end;
end;

function TCommandMgrImpl.RegisterCmd(ACommand: ICommand): Boolean;
var
  LOldCommand: ICommand;
begin
  Result := False;
  if ACommand = nil then Exit;

  Result := True;
  FCommands.Add(ACommand);

  if FCommandDic.TryGetValue(ACommand.GetId, LOldCommand) then begin
    MessageBox(0, PWideChar('√¸¡Ó±‡¬Î÷ÿ∏¥:' + IntToStr(ACommand.GetId)
      + ':' + LOldCommand.GetCaption + '--' + ACommand.GetCaption),
      '◊¢≤·√¸¡Ó≥ˆ¥Ì', MB_OK or MB_ICONWARNING);
    Exit;
  end;

  FCommandDic.AddOrSetValue(ACommand.GetId, ACommand);

  if ACommand.GetShortKey <> 0 then begin
    if not FSysCommandDic.TryGetValue(ACommand.GetShortKey, LOldCommand) then begin
      FSysCommandDic.AddOrSetValue(ACommand.GetShortKey, ACommand);
    end;
  end;
end;

function TCommandMgrImpl.UnRegisterCmd(ACommand: ICommand): Boolean;
begin
  Result := False;
  if ACommand = nil then Exit;

  Result := True;
  FCommands.Remove(ACommand);
  FCommandDic.Remove(ACommand.GetId);
  FSysCommandDic.Remove(ACommand.GetShortKey);
end;

function TCommandMgrImpl.ExecuteCmd(ACommandId: Cardinal; AParams: string): Boolean;
var
  LCommand: ICommand;
begin
  if FCommandDic.TryGetValue(ACommandId, LCommand) then begin
    Result := True;
    DoExecuteCmdBefore(ACommandId, AParams);
    LCommand.Execute(AParams);
    DoExecuteCmdAfter(ACommandId, AParams);
  end else begin
    Result := False;
  end;
end;

function TCommandMgrImpl.RegisterInterceptor(AInterceptor: ICmdInterceptor): Boolean;
begin
  Result := False;
  if AInterceptor = nil then Exit;

  if FInterceptors.IndexOf(AInterceptor) < 0 then begin
    Result := True;
    FInterceptors.Add(AInterceptor);
  end;
end;

function TCommandMgrImpl.UnRegisterInterceptor(AInterceptor: ICmdInterceptor): Boolean;
begin
  Result := False;
  if AInterceptor = nil then Exit;

  FInterceptors.Remove(AInterceptor);
end;

function TCommandMgrImpl.DelayExecuteCmd(ACommandId: Cardinal; AParams: string; ADelaySecs: Cardinal): Boolean;
var
  LCommandJob: PCommandJob;
begin
  LCommandJob := PCommandJob(FCommandJobPool.Allocate);
  if LCommandJob <> nil then begin
    Result := True;
    LCommandJob^.FId := ACommandId;
    LCommandJob^.FParams := AParams;
    LCommandJob^.FDelaySecs := ADelaySecs;
    FDelayCommandJobs.AddElementByDelay(LCommandJob);
  end else begin
    Result := False;
  end;
end;

function TCommandMgrImpl.FixedExecuteCmd(ACommandId: Cardinal; AParams: string; AFixedSecs: Cardinal): Boolean;
var
  LCommandJob: PCommandJob;
begin
  LCommandJob := PCommandJob(FCommandJobPool.Allocate);
  if LCommandJob <> nil then begin
    Result := True;
    LCommandJob^.FId := ACommandId;
    LCommandJob^.FParams := AParams;
    LCommandJob^.FDelaySecs := AFixedSecs;
    FFixedCommandJobs.AddTailElement(LCommandJob);
  end else begin
    Result := False;
  end;
end;

end.

