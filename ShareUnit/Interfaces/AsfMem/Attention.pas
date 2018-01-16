unit Attention;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Attention
// Author��      lksoulman
// Date��        2018-1-12
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  BaseObject;

type

  // Attention
  TAttention = class(TBaseObject)
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
