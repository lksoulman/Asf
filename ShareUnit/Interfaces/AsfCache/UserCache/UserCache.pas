unit UserCache;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� UserCache Interface
// Author��      lksoulman
// Date��        2017-8-11
// Comments��
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
    // StopService
    procedure StopService;
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
    // SyncQuery
    function SyncQuery(ASql: WideString): IWNDataSet;
    // UpdateVersion
    function GetUpdateVersion(ATable: string): Integer;
    // AsyncQuery
    procedure AsyncQuery(ASql: WideString; ADataArrive: Int64; ATag: Int64);
  end;

implementation

end.
