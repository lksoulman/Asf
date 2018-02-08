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
  CacheType,
  SectorMgr,
  BaseObject,
  AppContext,
  WNDataSetInf,
  Generics.Collections;

type

  // SectorImpl
  TSectorImpl = class(TSector)
  private
  protected
    // Childs
    FChilds: TList<TSector>;

    // ClearChilds
    procedure DoClearChilds;
    // LoadElements
    procedure DoLoadElements;
  public
    // Id
    FId: Integer;
    // Name
    FName: string;
    // IsLoadElements
    FIsLoadElements: Boolean;
    // Elements
    FElements: TArray<Integer>;
    // Parent
    FParent: TSector;
  public
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce;
    // Destructor
    destructor Destroy; override;
    // ResetValue
    procedure ResetValue;
    // ClearChilds
    procedure ClearChilds;
    // GetId
    function GetId: Integer; override;
    // GetName
    function GetName: string; override;
    // GetElements
    function GetElements: TArray<Integer>; override;
    // GetParent
    function GetParent: TSector; override;
    // GetChildCount
    function GetChildCount: Integer; override;
    // GetChildByIndex
    function GetChildByIndex(const AIndex: Integer): TSector; override;
    // AddChild
    function AddChild(ASector: TSector): Boolean;
  end;

implementation

{ TSectorImpl }

constructor TSectorImpl.Create(AContext: IAppContext);
begin
  inherited Create(AContext);
  FChilds := TList<TSector>.Create;
end;

destructor TSectorImpl.Destroy;
begin
  FName := '';
  SetLength(FElements, 0);
  DoClearChilds;
  FChilds.Free;
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
      TSectorImpl(LSector).ClearChilds;
    end;
  end;
  FChilds.Clear;
end;

procedure TSectorImpl.DoLoadElements;
var
  LSql: string;
  LCount: Integer;
  LInnerCode: IWNField;
  LDataSet: IWNDataSet;
begin
  if not FIsLoadElements then begin
    LSql := Format('SELECT InnerCode FROM DW_PlateComponent WHERE PlateCode = %d', [FId]);
    if FAppContext <> nil then begin
      LDataSet := FAppContext.CacheSyncQuery(ctBaseData, LSql);
      if LDataSet <> nil then begin
        SetLength(FElements, LDataSet.RecordCount);
        if LDataSet.RecordCount > 0 then begin
          LInnerCode := LDataSet.FieldByName('InnerCode');
          if LInnerCode <> nil then begin
            LCount := 0;
            LDataSet.First;
            while not LDataSet.Eof do begin

              FElements[LCount] := LInnerCode.AsInteger;
              Inc(LCount);
              LDataSet.Next;
            end;
          end;
        end;
        FIsLoadElements := True;
      end;
    end;
  end;
end;

procedure TSectorImpl.ResetValue;
begin
  FId := 0;
  FName := '';
  FIsLoadElements := False;
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

function TSectorImpl.GetElements: TArray<Integer>;
begin
  if FIsLoadElements then begin
    Result := FElements;
  end else begin
    DoLoadElements;
    Result := FElements;
  end;
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

function TSectorImpl.AddChild(ASector: TSector): Boolean;
begin
  Result := True;
  FChilds.Add(ASector);
end;

end.
