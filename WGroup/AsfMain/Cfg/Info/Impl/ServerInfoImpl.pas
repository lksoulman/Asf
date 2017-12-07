unit ServerInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º ServerInfo Implementation
// Author£º      lksoulman
// Date£º        2017-7-21
// Comments£º
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
  AppContext,
  CommonRefCounter;

type

  // ServerInfo Implementation
  TServerInfoImpl = class(TAutoInterfacedObject, IServerInfo)
  private
    // Server Mame
    FServerName: string;
    // Server Index
    FServerIndex: Integer;
    // Attempt Count
    FAttemptCount: Integer;
    // Server List
    FServerList: TStringList;
  protected
  public
    // Constructor
    constructor Create(AServerName: string); reintroduce;
    // Destructor
    destructor Destroy; override;

    { IServerInfo }

    // Load File
    procedure LoadFile(AFile: TIniFile);
    // Next
    procedure NextServer;
    // First
    procedure FirstServer;
    // Is EOF
    function IsEOF: boolean;
    // Get Server Index
    function GetServerIndex: Integer;
    // Get Server Url
    function GetServerUrl: WideString;
    // Get Server Urls
    function GetServerUrls: WideString;
    // Get Server Name
    function GetServerName: WideString;
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

procedure TServerInfoImpl.LoadFile(AFile: TIniFile);
begin
  FServerList.DelimitedText := AFile.ReadString('ServerInfo', FServerName, '');
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

end.
