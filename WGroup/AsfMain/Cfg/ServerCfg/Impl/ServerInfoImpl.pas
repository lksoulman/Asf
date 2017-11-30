unit ServerInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-21
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Json,
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  ServerInfo,
  AppContext;

type

  TServerInfoImpl = class(TInterfacedObject, IServerInfo)
  private
    // ��¼���������û�����
    FUserName: string;
    // ��¼���������û�����
    FPassword: string;
    // ����������
    FServerName: string;
    // �������±�
    FServerIndex: Integer;
    // ���Է���������
    FAttemptCount: Integer;
    // �������б�
    FServerList: TStringList;
    // Ӧ�ó��������Ľӿ�
    FAppContext: IAppContext;
  protected
  public
    // ���췽��
    constructor Create(AServerName: string);
    // ��������
    destructor Destroy; override;

    { IServerInfo }

    // ��ʼ����Ҫ����Դ
    procedure Initialize(AContext: IAppContext); safecall;
    // �ͷŲ���Ҫ����Դ
    procedure UnInitialize; safecall;
    // ��������
    procedure SaveCache; safecall;
    // ͨ��Ini�������
    procedure LoadByIniFile(AFile: TIniFile); safecall;
    // ͨ��Json�������
    procedure LoadByJsonObject(AObject: TJSONObject); safecall;
    // ��һ������
    procedure NextServer; safecall;
    // ��һ������
    procedure FirstServer; safecall;
    // �ǲ��ǽ���
    function IsEOF: boolean; safecall;
    // ��ȡȥ������±�
    function GetServerIndex: Integer; safecall;
    // ��ȡ����Url
    function GetServerUrl: WideString; safecall;
    // ��ȡ����
    function GetServerUrls: WideString; safecall;
    // ��ȡȥ���������
    function GetServerName: WideString; safecall;
    // ��ȡ�û�����
    function GetUserName: WideString;
    // �����û�����
    procedure SetUserName(AUserName: WideString); safecall;
    // ��ȡ�û�����
    function GetPassword: WideString;
    // �����û�����
    procedure SetPassword(APassword: WideString); safecall;
  end;

implementation

uses
  Utils;

{ TServerInfoImpl }

constructor TServerInfoImpl.Create(AServerName: string);
begin
  inherited Create;
  FServerIndex := 0;
  FAttemptCount := 0;
  FServerName := AServerName;
  FServerList := TStringList.Create;
  FServerList.Delimiter := ';';
end;

destructor TServerInfoImpl.Destroy;
begin
  FServerList.Free;
  inherited;
end;

procedure TServerInfoImpl.Initialize(AContext: IAppContext);
begin
  FAppContext := AContext;
end;

procedure TServerInfoImpl.UnInitialize;
begin
  FAppContext := nil;
end;

procedure TServerInfoImpl.SaveCache;
begin

end;

procedure TServerInfoImpl.LoadByIniFile(AFile: TIniFile);
begin
  FServerList.DelimitedText := AFile.ReadString('ServerInfo', FServerName, '');
end;

procedure TServerInfoImpl.LoadByJsonObject(AObject: TJSONObject);
begin
  if AObject = nil then Exit;

  FServerList.DelimitedText := Utils.GetStringByJsonObject(AObject, FServerName);
end;

procedure TServerInfoImpl.NextServer;
begin
  if FServerList.Count <= 0 then Exit;

  Inc(FAttemptCount);
  FServerIndex := (FServerIndex + 1) mod FServerList.Count;
end;

procedure TServerInfoImpl.FirstServer;
begin
  FAttemptCount := 0;
end;

function TServerInfoImpl.IsEOF: boolean;
begin
  Result := True;
  if FServerList.Count <= 0 then Exit;

  if FAttemptCount < FServerList.Count then begin
    Result := False;
  end else begin
    Result := True;
  end;
end;

function TServerInfoImpl.GetServerUrl: WideString;
begin
  if (FServerIndex >= 0) and (FServerIndex < FServerList.Count) then begin
    Result := FServerList.Strings[FServerIndex];
  end else begin
    Result := '';
  end;
end;

function TServerInfoImpl.GetServerUrls: WideString;
begin
  Result := FServerList.DelimitedText;
end;

function TServerInfoImpl.GetServerName: WideString;
begin
  Result := FServerName;
end;

function TServerInfoImpl.GetServerIndex: Integer;
begin
  Result := FServerIndex;
end;

function TServerInfoImpl.GetUserName: WideString;
begin
  Result := FUserName;
end;

procedure TServerInfoImpl.SetUserName(AUserName: WideString); safecall;
begin
  FUserName := AUserName;
end;

function TServerInfoImpl.GetPassword: WideString;
begin
  Result := FPassword;
end;

procedure TServerInfoImpl.SetPassword(APassword: WideString);
begin
  FPassword := APassword;
end;

end.
