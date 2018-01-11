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
  CommonRefCounter,
  Generics.Collections;

type

  // CommandJob
  TCommandJob = class(TAutoObject)
  private
    FId: Cardinal;
    FParams: string;
    FLast: Cardinal;
    FDelaySecs: Cardinal;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
  end;

  // CommandJobList
  TCommandJobList = class(TAutoObject)
  private
    // Lock
    FLock: TCSLock;
    // Count
    FCount: Integer;
    // CommandJobs
    FCommandJobs: TList<TCommandJob>;
  protected
    // ClearJobs
    procedure DoClearJobs;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // AddElement
    procedure AddElement(AJob: TCommandJob);
    // AddElementByDelay
    procedure AddElementByDelay(AJob: TCommandJob);
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

{ TCommandJob }

constructor TCommandJob.Create;
begin
  inherited;

end;

destructor TCommandJob.Destroy;
begin
  FParams := '';
  inherited;
end;

{ TCommandJobList }

constructor TCommandJobList.Create;
begin
  inherited;
  FCount := 0;
  FLock := TCSLock.Create;
  FCommandJobs := TList<TCommandJob>.Create;
end;

destructor TCommandJobList.Destroy;
begin
  DoClearJobs;
  FCommandJobs.Free;
  FLock.Free;
  inherited;
end;

procedure TCommandJobList.DoClearJobs;
var
  LIndex: Integer;
  LJob: TCommandJob;
begin
  for LIndex := 0 to FCommandJobs.Count - 1 do begin
    LJob := FCommandJobs.Items[LIndex];
    if LJob <> nil then begin
      LJob.Free;
    end;
  end;
  FCommandJobs.Clear;
end;

procedure TCommandJobList.Lock;
begin
  FLock.Lock;
end;

procedure TCommandJobList.UnLock;
begin
  FLock.UnLock;
end;

procedure TCommandJobList.AddElement(AJob: TCommandJob);
begin
  if AJob = nil then Exit;

  FLock.Lock;
  try
    if FCommandJobs.IndexOf(AJob) < 0 then begin
      FCommandJobs.Add(AJob);
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TCommandJobList.AddElementByDelay(AJob: TCommandJob);
var
  LIndex: Integer;
  LJob: TCommandJob;
begin
  if AJob = nil then Exit;

  FLock.Lock;
  try
    if FCommandJobs.IndexOf(AJob) < 0 then begin
      if FCommandJobs.Count > 0 then begin
        for LIndex := FCommandJobs.Count - 1 downto 0 do begin
          LJob := FCommandJobs.Items[LIndex];
          if (LJob <> nil) and
            (AJob.FDelaySecs < LJob.FDelaySecs)then begin
            Break;
          end;
        end;

        if LIndex = FCommandJobs.Count - 1 then begin
          FCommandJobs.Add(AJob);
        end else if LIndex < 0 then begin
          FCommandJobs.Insert(0, AJob);
        end else begin
          FCommandJobs.Insert(LIndex + 1, AJob);
        end;
      end else begin
        FCommandJobs.Add(AJob);
      end;
    end;
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
  FDelayCommandJobs := TCommandJobList.Create;
  FFixedCommandJobs := TCommandJobList.Create;
  FAsyncExecuteCmdThread := TExecutorThread.Create;
  FAsyncExecuteCmdThread.ThreadMethod := DoAsyncExecuteCmdThread;
  FAsyncExecuteCmdThread.StartEx;
  FIsStart := True;
end;

destructor TCommandMgrImpl.Destroy;
begin
  FAsyncExecuteCmdThread.ShutDown;
  FDelayCommandJobs.Free;
  FFixedCommandJobs.Free;
  FSysCommandDic.Free;
  FCommandDic.Free;
  FInterceptors.Free;
  FCommands.Free;
  FLock.Free;
  inherited;
end;

procedure TCommandMgrImpl.DoExecuteDelayJobs;
var
  LIndex: Integer;
  LJob: TCommandJob;
begin
  FDelayCommandJobs.Lock;
  try
    for LIndex := FDelayCommandJobs.FCommandJobs.Count - 1 downto 0 do begin
      LJob := FDelayCommandJobs.FCommandJobs.Items[LIndex];
      if LJob <> nil then begin
        LJob.FDelaySecs := LJob.FDelaySecs - 1;
        if LJob.FDelaySecs <= 0 then begin

          if FAsyncExecuteCmdThread.IsTerminated then Exit;

          ExecuteCmd(LJob.FId, LJob.FParams);
          FDelayCommandJobs.FCommandJobs.Delete(LIndex);

          LJob.Free;
        end;
      end;
    end;
  finally
    FDelayCommandJobs.UnLock;
  end;
end;

procedure TCommandMgrImpl.DoExecuteFixedJobs;
var
  LIndex: Integer;
  LJob: TCommandJob;
begin
  FFixedCommandJobs.Lock;
  try

    for LIndex := FFixedCommandJobs.FCommandJobs.Count - 1 downto 0 do begin
      LJob := FFixedCommandJobs.FCommandJobs.Items[LIndex];
      if LJob <> nil then begin
        LJob.FLast := LJob.FLast + 1;
        if LJob.FLast >= LJob.FDelaySecs then begin
          if FAsyncExecuteCmdThread.IsTerminated then Exit;

          ExecuteCmd(LJob.FId, LJob.FParams);
          LJob.FLast := 0;
        end;
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
  LCommandJob: TCommandJob;
begin
  LCommandJob := TCommandJob.Create;
  if LCommandJob <> nil then begin
    Result := True;
    LCommandJob.FId := ACommandId;
    LCommandJob.FParams := AParams;
    LCommandJob.FDelaySecs := ADelaySecs;
    FDelayCommandJobs.AddElementByDelay(LCommandJob);
  end else begin
    Result := False;
  end;
end;

function TCommandMgrImpl.FixedExecuteCmd(ACommandId: Cardinal; AParams: string; AFixedSecs: Cardinal): Boolean;
var
  LCommandJob: TCommandJob;
begin
  LCommandJob := TCommandJob.Create;
  if LCommandJob <> nil then begin
    Result := True;
    LCommandJob.FId := ACommandId;
    LCommandJob.FParams := AParams;
    LCommandJob.FDelaySecs := AFixedSecs;
    FFixedCommandJobs.AddElement(LCommandJob);
  end else begin
    Result := False;
  end;
end;

end.

