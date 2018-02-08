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
  CommonRefCounter;

type

  // Attention
  TAttention = class(TAutoObject)
  private
  protected
  public
    // GetName
    function GetName: string; virtual; abstract;
    // GetSectorId
    function GetSectorId: Integer; virtual; abstract;
    // GetModuleId
    function GetModuleId: Integer; virtual; abstract;

    property Name: string read GetName;
    property SectorId: Integer read GetSectorId;
    property ModuleId: Integer read GetModuleId;
  end;

implementation

end.
