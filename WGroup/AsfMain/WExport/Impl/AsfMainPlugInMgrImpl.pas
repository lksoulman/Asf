unit AsfMainPlugInMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AsfMainPlugInMgrImpl Implementation
// Author£º      lksoulman
// Date£º        2017-11-15
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Command,
  AppContext,
  PlugInMgrImpl;

type

  // AsfMainPlugInMgrImpl Implementation
  TAsfMainPlugInMgrImpl = class(TPlugInMgrImpl)
  private
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IPlugInMgr }

    // Load
    procedure Load; override;
  end;

implementation

uses
  LoginCommandImpl,
  LoadProcessCommandImpl,
  KeyFairyCommandImpl,
  MasterMgrCommandImpl,
  ShortKeyDataMgrCommandImpl,
  SuperTabDataMgrCommandImpl,
  StatusHqDataMgrCommandImpl,
  StatusNewsDataMgrCommandImpl,
  StatusAlarmDataMgrCommandImpl,
  StatusReportDataMgrCommandImpl,
  StatusServerDataMgrCommandImpl;

{ TAsfMainPlugInMgrImpl }

constructor TAsfMainPlugInMgrImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TAsfMainPlugInMgrImpl.Destroy;
begin

  inherited;
end;

procedure TAsfMainPlugInMgrImpl.Load;
begin
//  DoAddCommand(TLoadProcessCommandImpl.Create(ASF_COMMAND_ID_LOADPROCESS, 'LoadProcess', FAppContext) as ICommand);
  DoAddCommand(TLoginCommandImpl.Create(ASF_COMMAND_ID_LOGIN, 'Login', FAppContext) as ICommand);
  DoAddCommand(TMasterMgrCommandImpl.Create(ASF_COMMAND_ID_MASTERMGR, 'Master Mgr', FAppContext) as ICommand);
  DoAddCommand(TShortKeyDataMgrCommandImpl.Create(ASF_COMMAND_ID_SHORTKEYDATAMGR, 'ShortKey', FAppContext) as ICommand);
  DoAddCommand(TSuperTabDataMgrCommandImpl.Create(ASF_COMMAND_ID_SUPERTABDATAMGR, 'SuperTab', FAppContext) as ICommand);
  DoAddCommand(TStatusHqDataMgrCommandImpl.Create(ASF_COMMAND_ID_STATUSHQDATAMGR, 'StatusHq', FAppContext) as ICommand);
  DoAddCommand(TStatusNewsDataMgrCommandImpl.Create(ASF_COMMAND_ID_STATUSNEWSDATAMGR, 'StatusNews', FAppContext) as ICommand);
  DoAddCommand(TStatusAlarmDataMgrCommandImpl.Create(ASF_COMMAND_ID_STATUSALARMDATAMGR, 'StatusAlarm', FAppContext) as ICommand);
  DoAddCommand(TStatusServerDataMgrCommandImpl.Create(ASF_COMMAND_ID_STATUSSERVERDATAMGR, 'StatusServer', FAppContext) as ICommand);
  DoAddCommand(TStatusReportDataMgrCommandImpl.Create(ASF_COMMAND_ID_STATUSREPORTDATAMGR, 'StatusReport', FAppContext) as ICommand);
  DoAddCommand(TKeyFairyCommandImpl.Create(ASF_COMMAND_ID_KEYFAIRY, 'KeyFairy', FAppContext) as ICommand);
end;

end.
