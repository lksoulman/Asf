unit Chrome;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Chrome Interface
// Author��      lksoulman
// Date��        2017-12-26
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  Browser;

type

  // Chrome
  IChrome = interface
    ['{8A7C2507-7965-4E9B-99E3-B93070EC757F}']
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // InitChrome
    procedure InitChrome;
    // IsInitSuccess
    function IsInitSuccess: Boolean;
    // CreateBrowser
    function CreateBrowser: IBrowser;
  end;

implementation

end.
