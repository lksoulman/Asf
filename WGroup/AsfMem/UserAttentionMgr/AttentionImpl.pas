unit AttentionImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º AttentionImpl
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
  Attention,
  AppContext;

type

  // AttentionImpl
  TAttentionImpl = class(TAttention)
  private
  protected
  public
    // Name
    FName: string;
    // SectorId
    FSectorId: Integer;
    // ModuleId
    FModuleId: Integer;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // GetName
    function GetName: string; override;
    // GetSectorId
    function GetSectorId: Integer; override;
    // GetModuleId
    function GetModuleId: Integer; override;
  end;

implementation

{ TAttentionImpl }

constructor TAttentionImpl.Create;
begin
  inherited;

end;

destructor TAttentionImpl.Destroy;
begin

  inherited;
end;

function TAttentionImpl.GetName: string;
begin
  Result := FName;
end;

function TAttentionImpl.GetSectorId: Integer;
begin
  Result := FSectorId;
end;

function TAttentionImpl.GetModuleId: Integer;
begin
  Result := FModuleId;
end;

end.
