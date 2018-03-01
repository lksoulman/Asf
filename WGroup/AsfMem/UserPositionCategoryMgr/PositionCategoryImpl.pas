unit PositionCategoryImpl;

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext,
  PositionCategory;

type

  // PositionCategoryImpl
  TPositionCategoryImpl = class(TPositionCategory)
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

{ TPositionCategoryImpl }

constructor TPositionCategoryImpl.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TPositionCategoryImpl.Destroy;
begin
  FName := '';
  inherited;
end;

function TPositionCategoryImpl.GetId: Integer;
begin
  Result := FId;
end;

function TPositionCategoryImpl.GetName: string;
begin
  Result := FName;
end;

end.
