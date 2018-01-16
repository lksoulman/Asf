unit Attention;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Attention
// Author£º      lksoulman
// Date£º        2018-1-12
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
