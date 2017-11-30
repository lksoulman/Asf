unit BaseCache;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º BaseCache Interface
// Author£º      lksoulman
// Date£º        2017-8-11
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  WNDataSetInf;

type

  // BaseCache Interface
  IBaseCache = Interface(IInterface)
    ['{D3E280F2-E5F1-4D74-818B-1F0BFC0016AE}']
    // Update
    procedure UpdateTables;
    // AsyncUpdate
    procedure AsyncUpdateTables;
    // AsyncUpdateTable
    procedure AsyncUpdateTable(AName: string);
    // Query
    function Query(ASql: WideString): IWNDataSet;
    // Async Query
    procedure AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
  end;

implementation

end.
