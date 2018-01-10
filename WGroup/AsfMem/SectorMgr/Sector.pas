unit Sector;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Sector Interface
// Author£º      lksoulman
// Date£º        2018-1-9
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Sector
  ISector = interface(IInterface)
    ['{EA2CE3C3-E20B-437D-BE79-FF7B8BC8F9E4}']
    // GetId
    function GetId: Integer;
    // GetName
    function GetName: string;
    // GetElements
    function GetElements: string;
    // GetParent
    function GetParent: ISector;
    // GetChildCount
    function GetChildCount: Integer;
    // GetChildByIndex
    function GetChildByIndex(const AIndex: Integer): ISector;

    property Id: Integer read GetId;
    property Name: string read GetName;
    property Elements: string read GetElements;
    property Parent: ISector read GetParent;
    property ChildCount: Integer read GetChildCount;
    property Childs[const AIndex : Integer] : ISector read GetChildByIndex;
  end;

implementation

end.
