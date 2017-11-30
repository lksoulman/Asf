unit PlugInMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： PlugInMgr Interface Implementation
// Author：      lksoulman
// Date：        2017-8-10
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Command,
  PlugInMgr,
  AppContext,
  CommonRefCounter,
  Generics.Collections;

type

  // PlugInMgr Interface
  TPlugInMgrImpl = class(TAutoInterfacedObject, IPlugInMgr)
  private
    type
      // CommandInfo
      TCommandInfo = packed record
        FCommand: ICommand;
      end;
      // PCommandInfo
      PCommandInfo = ^TCommandInfo;
  private
    // Commands
    FCommandInfos: TList<PCommandInfo>;
  protected
    // Caption
    FCaption: string;
    // AppContext
    FAppContext: IAppContext;

    // Clear Command
    procedure DoClearCommands;
    // Add Command
    procedure DoAddCommand(ACommand: ICommand);
  public
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;

    { IPlugInMgr }

    // Get Caption
    function GetCaption: string;
    // Load
    procedure Load; virtual;
    //设置语言类型(ARefresh : 是否需要刷新窗体)
//    procedure SetLanguage(ALanguage: TLanguageType; ARefresh: Boolean);
  end;

implementation

{ TPlugInMgrImpl }

constructor TPlugInMgrImpl.Create(AContext: IAppContext);
begin
  inherited Create;
  FAppContext := AContext;
  FCommandInfos := TList<PCommandInfo>.Create;
end;

destructor TPlugInMgrImpl.Destroy;
begin
  DoClearCommands;
  FCommandInfos.Free;
  FAppContext := nil;
  inherited;
end;

function TPlugInMgrImpl.GetCaption: string;
begin
  Result := FCaption;
end;

procedure TPlugInMgrImpl.Load;
begin

end;

procedure TPlugInMgrImpl.DoClearCommands;
var
  LIndex: Integer;
  LPCommandInfo: PCommandInfo;
begin
  for LIndex := 0 to FCommandInfos.Count - 1 do begin
    LPCommandInfo := FCommandInfos.Items[LIndex];
    if LPCommandInfo <> nil then begin
      if LPCommandInfo^.FCommand <> nil then begin
        FAppContext.GetCommandMgr.UnRegisterCmd(LPCommandInfo^.FCommand);
        LPCommandInfo^.FCommand := nil;
      end;
      Dispose(LPCommandInfo);
    end;
  end;
end;

procedure TPlugInMgrImpl.DoAddCommand(ACommand: ICommand);
var
  LPCommandInfo: PCommandInfo;
begin
  New(LPCommandInfo);
  LPCommandInfo.FCommand := ACommand;
  FAppContext.GetCommandMgr.RegisterCmd(ACommand);
  FCommandInfos.Add(LPCommandInfo);
end;

end.
