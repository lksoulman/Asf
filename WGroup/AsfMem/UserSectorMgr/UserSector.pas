unit UserSector;

/// /////////////////////////////////////////////////////////////////////////////
//
// Description£º UserSector
// Author£º      lksoulman
// Date£º        2018-1-8
// Comments£º
//
/// /////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  BaseObject,
  AppContext;

type

  // UserSector
  TUserSector = class(TBaseObject)
  private
  protected
  public
    // GetName
    function GetName: string; virtual; abstract;
    // GetOrderNo
    function GetOrderNo: Integer; virtual; abstract;
    // GetInnerCodes
    function GetInnerCodes: string; virtual; abstract;
    // SetName
    procedure SetName(AName: string); virtual; abstract;
    // SetOrderNo
    procedure SetOrderNo(AOrderNo: Integer); virtual; abstract;
    // SetInnerCodes
    procedure SetInnerCodes(AInnerCodes: string); virtual; abstract;
    // Add
    procedure Add(AInnerCode: Integer); virtual; abstract;
    // Delete
    procedure Delete(AInnerCode: Integer); virtual; abstract;

    property Name: string read GetName write SetName;
    property OrderNo: Integer read GetOrderNo write SetOrderNo;
    property InnerCodes: string read GetInnerCodes write SetInnerCodes;
  end;

implementation

end.
