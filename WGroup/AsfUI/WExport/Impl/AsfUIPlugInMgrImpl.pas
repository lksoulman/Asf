unit AsfUIPlugInMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AsfUIPlugInMgr Implementation
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

  // AsfUIPlugInMgr Implementation
  TAsfUIPlugInMgrImpl = class(TPlugInMgrImpl)
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


{ TAsfUIPlugInMgrImpl }

constructor TAsfUIPlugInMgrImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TAsfUIPlugInMgrImpl.Destroy;
begin

  inherited;
end;

procedure TAsfUIPlugInMgrImpl.Load;
begin

end;

end.
