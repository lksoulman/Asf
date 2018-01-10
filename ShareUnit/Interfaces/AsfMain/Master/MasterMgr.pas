unit MasterMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º MasterMgr
// Author£º      lksoulman
// Date£º        2017-11-20
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Command,
  ChildPage;

type

  // MasterMgr
  IMasterMgr = interface(ICmdInterceptor)
    ['{506AA3CE-0197-44C8-A831-CEBB36E881E6}']
    // Hide
    procedure Hide;
    // NewMaster
    procedure NewMaster;
    // DelMaster
    procedure DelMaster(AHandle: Integer);
    // IsHasChildPage
    function IsHasChildPage(AHandle: Integer; ACommandId: Integer): Boolean;
    // AddChildPage
    function AddChildPage(AHandle: Integer; AChildPage: IChildPage): Boolean;
    // BringToFrontChildPage
    function BringToFrontChildPage(AHandle, ACommandId: Integer; AParams: string): Boolean;
  end;

implementation

end.
