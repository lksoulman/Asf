unit UserCache;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserCache Interface
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

  // UserCache Interface
  IUserCache = Interface(IInterface)
    ['{D3E280F2-E5F1-4D74-818B-1F0BFC0016AE}']
    // UpdateTables
    procedure UpdateTables;
    // AsyncUpdateTables
    procedure AsyncUpdateTables;
    // ReplaceCreateCacheTables
    procedure ReplaceCreateCacheTables;
    // AsyncUpdateTable
    procedure AsyncUpdateTable(ATable: string);
    // ExecuteSql
    procedure ExecuteSql(ATable, ASql: string);
    //  Synchronous query data
    function SyncQuery(ASql: WideString): IWNDataSet;
    // Asynchronous query data
    procedure AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
  end;

implementation

end.
