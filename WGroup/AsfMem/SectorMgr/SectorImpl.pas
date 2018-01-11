unit SectorImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SectorImpl
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
  Sector,
  Command,
  SectorMgr,
  BaseObject,
  AppContext,
  Generics.Collections;

type

  // SectorImpl
  TSectorImpl = class(TSector)
  private
  protected
    // Parent
    FParent: TSector;
    // Childs
    FChilds: TList<TSector>;

    // DoClearChilds
    procedure DoClearChilds;
  public
    // Id
    FId: Integer;
    // Name
    FName: string;
    // Elements
    FElements: string;
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParent: TSector); reintroduce;
    // Destructor
    destructor Destroy; override;
    // ClearChilds
    procedure ClearChilds;
    // GetId
    function GetId: Integer; override;
    // GetName
    function GetName: string; override;
    // GetElements
    function GetElements: string; override;
    // GetParent
    function GetParent: TSector; override;
    // GetChildCount
    function GetChildCount: Integer; override;
    // GetChildByIndex
    function GetChildByIndex(const AIndex: Integer): TSector; override;
    // AddChild
    function AddChild(AId: Integer): TSector;
  end;

implementation

{ TSectorImpl }

constructor TSectorImpl.Create(AContext: IAppContext; AParent: TSector);
begin
  inherited Create(AContext);
  FParent := AParent;
  FChilds := TList<TSector>.Create;
end;

destructor TSectorImpl.Destroy;
begin
  FName := '';
  FElements := '';
  DoClearChilds;
  FChilds.Free;
  FParent := nil;
  inherited;
end;

procedure TSectorImpl.DoClearChilds;
var
  LIndex: Integer;
  LSector: TSector;
begin
  for LIndex := 0 to FChilds.Count - 1 do begin
    LSector := FChilds.Items[LIndex];
    if LSector <> nil then begin
      LSector.Free;
    end;
  end;
  FChilds.Clear;
end;

procedure TSectorImpl.ClearChilds;
begin
  DoClearChilds;
end;

function TSectorImpl.GetId: Integer;
begin
  Result := FId;
end;

function TSectorImpl.GetName: string;
begin
  Result := FName;
end;

function TSectorImpl.GetElements: string;
begin
  Result := FElements;
end;

function TSectorImpl.GetParent: TSector;
begin
  Result := FParent;
end;

function TSectorImpl.GetChildCount: Integer;
begin
  Result := FChilds.Count;
end;

function TSectorImpl.GetChildByIndex(const AIndex: Integer): TSector;
begin
  if (AIndex >= 0) and (AIndex < FChilds.Count) then begin
    Result := FChilds.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

function TSectorImpl.AddChild(AId: Integer): TSector;
begin
  Result := TSectorImpl.Create(FAppContext, Self);
  FChilds.Add(Result);
end;

end.
