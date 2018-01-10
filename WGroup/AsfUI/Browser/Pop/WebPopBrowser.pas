unit WebPopBrowser;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� WebPopBrowser Interface
// Author��      lksoulman
// Date��        2017-12-26
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // WebPopBrowser Interface
  IWebPopBrowser = interface(IInterface)
    ['{5F908BDB-625F-4B59-ACA1-74AE31806FDC}']
    // Hide
    procedure Hide;
    // Show
    procedure Show;
    // LoadWebUrl
    procedure LoadWebUrl(ACaptionPrefix, AUrl: string);
  end;

implementation

end.
