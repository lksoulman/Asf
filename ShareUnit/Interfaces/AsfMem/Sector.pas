unit Sector;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Sector
// Author£º      lksoulman
// Date£º        2018-1-9
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  BaseObject;

type

  // Sector
  TSector = class(TBaseObject)
  private
  protected
  public
    // GetId
    function GetId: Integer; virtual; abstract;
    // GetName
    function GetName: string; virtual; abstract;
    // GetElements
    function GetElements: TArray<Integer>; virtual; abstract;
    // GetParent
    function GetParent: TSector; virtual; abstract;
    // GetChildCount
    function GetChildCount: Integer; virtual; abstract;
    // GetChildByIndex
    function GetChildByIndex(const AIndex: Integer): TSector; virtual; abstract;

    property Id: Integer read GetId;
    property Name: string read GetName;
    property Elements: TArray<Integer> read GetElements;
    property Parent: TSector read GetParent;
    property ChildCount: Integer read GetChildCount;
    property Childs[const AIndex : Integer]: TSector read GetChildByIndex;
  end;

implementation

end.
