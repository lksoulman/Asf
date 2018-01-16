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
    // Id
    FId: Integer;
    // Name
    FName: string;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // GetId
    function GetId: Integer; override;
    // GetName
    function GetName: string; override;
  end;

implementation

{ TAttentionImpl }

constructor TAttentionImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TAttentionImpl.Destroy;
begin

  inherited;
end;

function TAttentionImpl.GetId: Integer;
begin
  Result := FId;
end;

function TAttentionImpl.GetName: string;
begin
  Result := FName;
end;

end.
