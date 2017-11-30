unit FastLog;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-1
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  LogLevel,
  CommonLock,
  CommonRefCounter;

type

  TFastLog = class(TAutoObject)
  private
    // ·��
    FPath: string;
    // ����־·��
    FSlowPath: string;
    // �̰߳�ȫ��
    FLock: TCSLock;
    // �̰߳�ȫ��
    FSlowLock: TCSLock;
    // ��־����
    FLevel: TLogLevel;
    // ʱ���ʽ
    FDateFormat: string;
    // ��־�ݴ�����
    FLogInfos: TStringList;
    // ��־�ݴ�����
    FSlowLogInfos: TStringList;
  protected
    // �����־���ļ�
    procedure DoSafeLogOutputFile;
    // �����־���ļ�
    procedure DoSafeSlowLogOutputFile;
  public
    // ���캯��
    constructor Create; override;
    // ��������
    destructor Destroy; override;
    // ��ʼ������
    procedure Initialize;
    // �����־���ļ�
    procedure SafeOutputFile;
    // �������·��
    procedure SetOutputPath(APath: string);
    // ������־����
    procedure SetLogLevel(ALevel: TLogLevel);
    // �����־
    procedure AppendLog(ALevel: TLogLevel; ALog: string);
    // �������־
    procedure AppendSlowLog(ALevel: TLogLevel; AUseTime: Integer; ALog: string);
  end;

implementation

const

 LOGLEVEL_OUTSTRING: TLogLevelArray = ('[DEBUG]',
                                       '[INFO ]',
                                       '[WARN ]',
                                       '[ERROR]',
                                       '[FATAL]',
                                       '[SLOW ]'
                                       );

{ TFastLog }

constructor TFastLog.Create;
begin
  inherited;
  FDateFormat := '[hh:nn:ss.zzz]';
{$IFDEF DEBUG}
  FLevel := llDEBUG;
{$ELSE}
  FLevel := llWARN;
{$ENDIF}

  SetOutputPath(ExtractFilePath(ParamStr(0)) + '\Log\');
  FLock := TCSLock.Create;
  FSlowLock := TCSLock.Create;
  FLogInfos := TStringList.Create;
  FSlowLogInfos := TStringList.Create;
end;

destructor TFastLog.Destroy;
begin
  FSlowLogInfos.Free;
  FLogInfos.Free;
  FSlowLock.Free;
  FLock.Free;
  inherited;
end;

procedure TFastLog.Initialize;
begin
  if not DirectoryExists(FPath) then begin
    ForceDirectories(FPath);
  end;
  if not DirectoryExists(FSlowPath) then begin
    ForceDirectories(FSlowPath);
  end;
end;

procedure TFastLog.SafeOutputFile;
begin
  DoSafeLogOutputFile;
  DoSafeSlowLogOutputFile;
end;

procedure TFastLog.DoSafeLogOutputFile;
var
  LFile: string;
  LTextFile: TextFile;
begin
  try
    FLock.Lock;
    try
      if FLogInfos.Text = '' then Exit;

      LFile := FPath + FormatDateTime('YYYY-MM-DD', Now) + '.log';
      AssignFile(LTextFile, LFile);
      try
        if FileExists(LFile) then
          Append(LTextFile)
        else
          ReWrite(LTextFile);
        Write(LTextFile, FLogInfos.Text);
        FLogInfos.Clear;
      finally
        CloseFile(LTextFile);
      end;
    finally
      FLock.UnLock;
    end;
  except
    on Ex: Exception do begin
      AppendLog(llError, Format('[TFastLog][DoSafeLogOutputFile] Exception is %s.', [Ex.Message]));
    end;
  end;
end;

procedure TFastLog.DoSafeSlowLogOutputFile;
var
  LFile: string;
  LTextFile: TextFile;
begin
  try
    FSlowLock.Lock;
    try
      if FSlowLogInfos.Text = '' then Exit;

      LFile := FSlowPath + FormatDateTime('YYYY-MM-DD', Now) + '.log';
      AssignFile(LTextFile, LFile);
      try
        if FileExists(LFile) then
          Append(LTextFile)
        else
          ReWrite(LTextFile);
        Write(LTextFile, FSlowLogInfos.Text);
        FSlowLogInfos.Clear;
      finally
        CloseFile(LTextFile);
      end;
    finally
      FSlowLock.UnLock;
    end;
  except
    on Ex: Exception do begin
      AppendLog(llError, Format('[TFastLog][DoSafeSlowLogOutputFile] Exception is %s.', [Ex.Message]));
    end;
  end;
end;

procedure TFastLog.SetOutputPath(APath: string);
begin
  FPath := APath;
  FSlowPath := APath + 'Slow\';
end;

procedure TFastLog.SetLogLevel(ALevel: TLogLevel);
begin
  FLevel := ALevel;
end;

procedure TFastLog.AppendLog(ALevel: TLogLevel; ALog: string);
var
  LLog: string;
begin
  if Ord(ALevel) < Ord(FLevel) then Exit;

  FLock.Lock;
  try
    LLog := Format('%s %s %s', [FormatDateTime(FDateFormat, Now), LOGLEVEL_OUTSTRING[ALevel], ALog]);
    FLogInfos.Add(LLog);
  finally
    FLock.UnLock;
  end;
end;

procedure TFastLog.AppendSlowLog(ALevel: TLogLevel; AUseTime: Integer; ALog: string);
var
  LLog: string;
begin
  if Ord(ALevel) < Ord(FLevel) then Exit;

  FSlowLock.Lock;
  try
    LLog := Format('%s %s [%10.0dms] %s', [FormatDateTime(FDateFormat, Now), LOGLEVEL_OUTSTRING[ALevel], AUseTime, ALog]);
    FSlowLogInfos.Add(LLog);
  finally
    FSlowLock.UnLock;
  end;
end;

end.
