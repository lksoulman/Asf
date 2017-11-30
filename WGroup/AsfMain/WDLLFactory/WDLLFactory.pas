unit WDLLFactory;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� WDLLFactory Interface
// Author��      lksoulman
// Date��        2017-11-15
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // WDLLFactory Interface
  IWDLLFactory = interface(IInterface)
    ['{5444ED58-7876-433A-8E8F-FF58134C435E}']
    // Load
    procedure Load(AFileName: string);
  end;

implementation

end.
