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
    // StopService
    procedure StopService;
    // UpdateTables
    procedure UpdateTables;
    // AsyncUpdate
    procedure AsyncUpdateTables;
    // ReplaceCreateCacheTables
    procedure ReplaceCreateCacheTables;
    // UpdateTable
    procedure UpdateTable(ATable: string);
    // AsyncUpdateTable
    procedure AsyncUpdateTable(ATable: string);
    // NoExistUpdateTable
    procedure NoExistUpdateTable(ATable: string);
    // SyncQuery
    function SyncQuery(ASql: WideString): IWNDataSet;
    // UpdateVersion
    function GetUpdateVersion(ATable: string): Integer;
    // AsyncQuery
    procedure AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
  end;

implementation

end.
