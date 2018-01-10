unit UserSector;

/// /////////////////////////////////////////////////////////////////////////////
//
// Description£∫ UserSector Interface
// Author£∫      lksoulman
// Date£∫        2017-8-23
// Comments£∫
//
/// /////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

const

  // ≈≈–Ú
  UPDATEOPERATE_SORT_BYORDERNO = 1;

type

  // UserSector
  IUserSector = Interface(IInterface)
    ['{1CD531FC-3B3F-49BC-B5D3-CD0AE1F59F71}']
    // GetName
    function GetName: string;
    // GetOrderNo
    function GetOrderNo: Integer;
    // GetInnerCodes
    function GetInnerCodes: string;
    // SetName
    procedure SetName(AName: string);
    // SetOrderNo
    procedure SetOrderNo(AOrderNo: Integer);
    // SetInnerCodes
    procedure SetInnerCodes(AInnerCodes: string);
    // Add
    procedure Add(AInnerCode: Integer);
    // Delete
    procedure Delete(AInnerCode: Integer);

    property Name: string read GetName write SetName;
    property OrderNo: Integer read GetOrderNo write SetOrderNo;
    property InnerCodes: string read GetInnerCodes write SetInnerCodes;
  end;

implementation

end.
