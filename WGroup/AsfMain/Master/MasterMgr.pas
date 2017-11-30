unit MasterMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� MasterMgr
// Author��      lksoulman
// Date��        2017-11-20
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Master;

type

  // MasterMgr
  IMasterMgr = interface
    ['{506AA3CE-0197-44C8-A831-CEBB36E881E6}']
    // Hide
    procedure Hide;
    // New Master
    procedure NewMaster;
    // Del Master
    procedure DelMaster(AHandle: Integer);
  end;

implementation

end.
