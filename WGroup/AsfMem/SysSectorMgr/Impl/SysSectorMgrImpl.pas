unit SysSectorMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： SysSectorMgr Implementation
// Author：      lksoulman
// Date：        2017-8-23
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Sector,
  Windows,
  Classes,
  SysUtils,
  BaseObject,
  AppContext,
  SysSectorMgr;

type

  // SysSectorMgr Implementation
  TSysSectorMgrImpl = class(TBaseInterfacedObject, ISysSectorMgr)
  private
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ISectorUserMgr }

    // 获取根结点板块
    function GetRootSector: ISector; safecall;
  end;

implementation

{ TSysSectorMgrImpl }

constructor TSysSectorMgrImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TSysSectorMgrImpl.Destroy;
begin

  inherited;
end;


function TSysSectorMgrImpl.GetRootSector: ISector;
begin

end;

end.
