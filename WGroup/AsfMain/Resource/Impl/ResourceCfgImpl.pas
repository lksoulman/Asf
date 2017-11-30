unit ResourceCfgImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Resource Cfg Interface Implementation
// Author��      lksoulman
// Date��        2017-8-25
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Graphics,
  AppContext,
  ResourceCfg,
  CommonRefCounter,
  Generics.Collections;

type

  // Resource Cfg Interface Implementation
  TResourceCfgImpl = class(TAutoInterfacedObject, IResourceCfg)
  private
    // Cfg Instance
    FInstance: HMODULE;
    // Application Context
    FAppContext: IAppContext;
  protected
    // Change Skin
//    procedure DoChangeSkin;
    // Init Library
    procedure DoInitLibrary;
    // Un Init Cfg Library
    procedure DoUnInitLibrary;
    // Load Library
    function DoLoadLibrary(AFile: string): HMODULE;
  public
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce;
    // Destructor
    destructor Destroy; override;

    { IResource }

    // Get Instance
    function GetInstance: HMODULE;
    // Get Stream
    function GetStream(AResourceName: string): TResourceStream;
  end;

implementation

uses
  Cfg,
  LogLevel;

const
  RESOURCE_FILE_CFG          = 'AsfResources.dll';

{ TResourceCfgImpl }

constructor TResourceCfgImpl.Create(AContext: IAppContext);
begin
  inherited Create;
  FAppContext := AContext;
  FInstance := 0;
  DoInitLibrary;
end;

destructor TResourceCfgImpl.Destroy;
begin
  FAppContext := nil;
  inherited;
end;

function TResourceCfgImpl.GetInstance: HMODULE;
begin
  Result := FInstance;
end;

function TResourceCfgImpl.GetStream(AResourceName: string): TResourceStream;
begin
  if FInstance <> 0 then begin
    Result := TResourceStream.Create(FInstance, AResourceName, RT_RCDATA);
  end else begin
    Result := nil;
  end;
end;

procedure TResourceCfgImpl.DoInitLibrary;
begin
  if FInstance = 0 then begin
    FInstance := DoLoadLibrary(RESOURCE_FILE_CFG);
  end;
end;

procedure TResourceCfgImpl.DoUnInitLibrary;
begin
  if FInstance <> 0 then begin
    FreeLibrary(FInstance);
    FInstance := 0;
  end;
end;

function TResourceCfgImpl.DoLoadLibrary(AFile: string): HMODULE;
{$IFDEF DEBUG}
var
  LTick: Cardinal;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
{$ENDIF}

  if FileExists(AFile) then begin
    Result := LoadLibrary(PChar(AFile));
    if Result = 0 then begin
      FAppContext.SysLog(llERROR, Format('[TResourceImpl][LoadLibrary] LoadLibrary(%s) return is 0, GetLastError is %d.', [AFile, GetLastError]));
    end;
  end else begin
    Result := 0;
    FAppContext.SysLog(llERROR, Format('[TResourceImpl][LoadLibrary] %s is not exists.', [AFile]));
  end;

{$IFDEF DEBUG}
  LTick := GetTickCount - LTick;
  FAppContext.SysLog(llSLOW, Format('[TResourceSkinImpl][DoLoadLibrary] LoadLibrary(%s) Execute use time %d.', [AFile, LTick]));
{$ENDIF}
end;

end.
