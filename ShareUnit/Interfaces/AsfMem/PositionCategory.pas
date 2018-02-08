unit PositionCategory;

////////////////////////////////////////////////////////////////////////////////
//
// Description： PositionCategory
// Author：      lksoulman
// Date：        2018-1-22
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  BaseObject;

const

  POSITIONCATEGORY_STOCK              = 1;  // 股票
  POSITIONCATEGORY_BOND               = 2;  // 债券
  POSITIONCATEGORY_FUND_INNER         = 3;  // 场内基金
  POSITIONCATEGORY_FUND_OUTER         = 4;  // 场外基金
  POSITIONCATEGORY_FUTURES            = 5;  // 期货
  POSITIONCATEGORY_OPTION             = 6;  // 期权

  POSITIONCATEGORY_NAME_STOCK         = '股票';
  POSITIONCATEGORY_NAME_BOND          = '债券';
  POSITIONCATEGORY_NAME_FUND_INNER    = '场内基金';
  POSITIONCATEGORY_NAME_FUND_OUTER    = '场外基金';
  POSITIONCATEGORY_NAME_FUTURES       = '期货';
  POSITIONCATEGORY_NAME_OPTION        = '期权';

type

  // PositionCategory
  TPositionCategory = class(TBaseObject)
  private
  protected
  public
    // GetId
    function GetId: Integer; virtual; abstract;
    // GetName
    function GetName: string; virtual; abstract;

    property Id: Integer read GetId;
    property Name: string read GetName;
  end;

implementation

end.
