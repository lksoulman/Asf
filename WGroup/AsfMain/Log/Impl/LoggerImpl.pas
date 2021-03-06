unit LoggerImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Logger Implementation
// Author��      lksoulman
// Date��        2017-7-1
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Logger,
  FastLog,
  Windows,
  Classes,
  SysUtils,
  LogLevel,
  AppContext,
  CommonLock,
  ExecutorThread,
  CommonRefCounter;

type

  // Logger Implementation
  TLoggerImpl = class(TAutoInterfacedObject, ILogger)
  private
    // IsInit
    FIsInit: Boolean;
    // AppPath
    FAppPath: string;
    // LogLevel
    FLevel: TLogLevel;
    // HQLog
    FHQLog: TFastLog;
    // WebLog
    FWebLog: TFastLog;
    // SystemLog
    FSysLog: TFastLog;
    // IndicatorLog
    FIndicatorLog: TFastLog;
    // AppContext
    FAppContext: IAppContext;
    // LogOutputThread
    FLogOutputThread: TExecutorThread;
  protected
    // Init
    procedure DoInitialize;
    // UnInit
    procedure DoUnInitialize;
    // Output File Thread Execute
    procedure DoOutputFileThreadExecute(AObject: TObject);
  public
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce;
    // Destructor
    destructor Destroy; override;

    { ILogger }

    // Force Write Disk
    procedure ForceWriteDisk; safecall;
    // Set Log Level
    procedure SetLogLevel(ALevel: TLogLevel); safecall;
    // HQ Log
    procedure HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Web Log
    procedure WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // System Log
    procedure SysLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
    // Indicator Log
    procedure IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0); safecall;
  end;

implementation

uses
  Vcl.Forms;

{ TLoggerImpl }

constructor TLoggerImpl.Create(AContext: IAppContext);
begin
  inherited Create;
  FAppContext := AContext;
  FIsInit := False;
{$IFDEF DEBUG}
  FLevel := llDEBUG;
{$ELSE}
  FLevel := llWARN;
{$ENDIF}
  FAppPath := ExtractFilePath(ParamStr(0));
  FAppPath := ExpandFileName(FAppPath + '..\');
  FHQLog := TFastLog.Create;
  FWebLog := TFastLog.Create;
  FSysLog := TFastLog.Create;
  FIndicatorLog := TFastLog.Create;
  FLogOutputThread := TExecutorThread.Create;
  FLogOutputThread.ThreadMethod := DoOutputFileThreadExecute;
  DoInitialize;
end;

destructor TLoggerImpl.Destroy;
begin
  DoUnInitialize;
  FIndicatorLog.Free;
  FSysLog.Free;
  FWebLog.Free;
  FHQLog.Free;
  FAppContext := nil;
  inherited;
end;

procedure TLoggerImpl.DoInitialize;
begin
  if not FIsInit then begin
    FHQLog.SetOutputPath(FAppPath + 'Log\HQ\');
    FWebLog.SetOutputPath(FAppPath + 'Log\Web\');
    FSysLog.SetOutputPath(FAppPath + 'Log\Sys\');
    FIndicatorLog.SetOutputPath(FAppPath + 'Log\Indicator\');
    FHQLog.Initialize;
    FWebLog.Initialize;
    FSysLog.Initialize;
    FIndicatorLog.Initialize;
    FLogOutputThread.Start;
    FIsInit := True;

    HQLog(FLevel, 'FastLog Start');
    SysLog(FLevel, 'FastLog Start');
    WebLog(FLevel, 'FastLog Start');
    IndicatorLog(FLevel, 'FastLog Start');
    HQLog(llSLOW, 'FastLog Start');
    SysLog(llSLOW, 'FastLog Start');
    WebLog(llSLOW, 'FastLog Start');
    IndicatorLog(llSLOW, 'FastLog Start');
  end;
end;

procedure TLoggerImpl.DoUnInitialize;
begin
  if FIsInit then begin
    FLogOutputThread.ShutDown;
    HQLog(FLevel, 'FastLog End');
    SysLog(FLevel, 'FastLog End');
    WebLog(FLevel, 'FastLog End');
    IndicatorLog(FLevel, 'FastLog End');
    HQLog(llSLOW, 'FastLog End');
    SysLog(llSLOW, 'FastLog End');
    WebLog(llSLOW, 'FastLog End');
    IndicatorLog(llSLOW, 'FastLog End');
    FIsInit := False;
    ForceWriteDisk;
  end;
end;

procedure TLoggerImpl.ForceWriteDisk;
begin
  FHQLog.SafeOutputFile;
  FWebLog.SafeOutputFile;
  FSysLog.SafeOutputFile;
  FIndicatorLog.SafeOutputFile;
end;

procedure TLoggerImpl.SetLogLevel(ALevel: TLogLevel);
begin
  FLevel := ALevel;
  FHQLog.SetLogLevel(ALevel);
  FWebLog.SetLogLevel(ALevel);
  FSysLog.SetLogLevel(ALevel);
  FIndicatorLog.SetLogLevel(ALevel);
end;

procedure TLoggerImpl.HQLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  case ALevel of
    llSLOW:
      FHQLog.AppendSlowLog(ALevel, AUseTime, ALog);
  else
    FHQLog.AppendLog(ALevel, ALog);
  end;
end;

procedure TLoggerImpl.WebLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  case ALevel of
    llSLOW:
      FWebLog.AppendSlowLog(ALevel, AUseTime, ALog);
  else
    FWebLog.AppendLog(ALevel, ALog);
  end;
end;

procedure TLoggerImpl.SysLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  case ALevel of
    llSLOW:
      FSysLog.AppendSlowLog(ALevel, AUseTime, ALog);
  else
    FSysLog.AppendLog(ALevel, ALog);
  end;
end;

procedure TLoggerImpl.IndicatorLog(ALevel: TLogLevel; ALog: WideString; AUseTime: Integer = 0);
begin
  case ALevel of
    llSLOW:
      FIndicatorLog.AppendSlowLog(ALevel, AUseTime, ALog);
  else
    FIndicatorLog.AppendLog(ALevel, ALog);
  end;
end;

procedure TLoggerImpl.DoOutputFileThreadExecute(AObject: TObject);
begin
  while not FLogOutputThread.IsTerminated do begin
    Application.ProcessMessages;

    FHQLog.SafeOutputFile;
    FWebLog.SafeOutputFile;
    FSysLog.SafeOutputFile;
    FIndicatorLog.SafeOutputFile;
    Sleep(1000);
  end;
end;

end.
