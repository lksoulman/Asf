unit SectorImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Sector Implementation
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
  SectorUpdate,
  SectorMgrUpdate,
  Generics.Collections;

type

  // Sector Implementation
  TSectorImpl = class(TBaseInterfacedObject, ISector, ISectorUpdate)
  private
  protected
    // Parent
    FParent: ISector;
    // SectorInfo
    FSectorInfo: TSectorInfo;
    // Childs
    FChilds: TList<ISector>;
    // ChildDic
    FChildDic: TDictionary<Integer, ISector>;

    // DoClearChilds
    procedure DoClearChilds;
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParent: ISector); reintroduce;
    // Destructor
    destructor Destroy; override;

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

    { ISectorUpdate }

    // ClearChilds
    function ClearChilds: Boolean;
    // CheckChildVersion
    function CheckChildVersion: Boolean;
    // GetSectorInfo
    function GetSectorInfo: PSectorInfo;
    // AddChild
    function AddChild(AId: Integer): ISector;

    property Id: Integer read GetId;
    property Name: string read GetName;
    property Elements: string read GetElements;
    property Parent: ISector read GetParent;
    property ChildCount: Integer read GetChildCount;
    property Childs[const AIndex : Integer] : ISector read GetChildByIndex;
  end;

implementation

{ TSectorImpl }

constructor TSectorImpl.Create(AContext: IAppContext; AParent: ISector);
begin
  inherited Create(AContext);
  FParent := AParent;
  FChilds := TList<ISector>.Create;
  FChildDic := TDictionary<Integer, ISector>.Create(50);
  ZeroMemory(@FSectorInfo, SizeOf(TSectorInfo));
end;

destructor TSectorImpl.Destroy;
begin
  DoClearChilds;
  FChildDic.Free;
  FChilds.Free;
  FParent := nil;
  inherited;
end;

procedure TSectorImpl.DoClearChilds;
var
  LIndex: Integer;
begin
  for LIndex := 0 to FChilds.Count - 1 do begin
    if FChilds.Items[LIndex] <> nil then begin
      FChilds.Items[LIndex] := nil;
    end;
  end;
  FChilds.Clear;
end;

function TSectorImpl.GetId: Integer;
begin
  Result := FSectorInfo.FId;
end;

function TSectorImpl.GetName: string;
begin
  Result := FSectorInfo.FName;
end;

function TSectorImpl.GetElements: string;
begin
  Result := FSectorInfo.FElements;
end;

function TSectorImpl.GetParent: ISector;
begin
  Result := FParent as ISector;
end;

function TSectorImpl.GetChildCount: Integer;
begin
  Result := FChilds.Count;
end;

function TSectorImpl.GetChildByIndex(const AIndex: Integer): ISector;
begin
  if (AIndex >= 0) and (AIndex < FChilds.Count) then begin
    Result := FChilds.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

function TSectorImpl.GetSectorInfo: PSectorInfo;
begin
  Result := @FSectorInfo;
end;

function TSectorImpl.CheckChildVersion: Boolean;
var
  LIndex: Integer;
  LSectorMgr: ISectorMgr;
begin
  Result := False;
  LSectorMgr := FAppContext.FindInterface(ASF_COMMAND_ID_SECTORMGR) as ISectorMgr;
  if LSectorMgr <> nil then begin
    for LIndex := FChilds.Count - 1 downto 0 do begin
      if FChilds.Items[LIndex] <> nil then begin
        if (FChilds.Items[LIndex] as ISectorUpdate).GetSectorInfo.FVersion
          < LSectorMgr.GetVersion then begin
          (LSectorMgr as ISectorMgrUpdate).DeleteSector((FChilds.Items[LIndex] as ISectorUpdate).GetSectorInfo.FId);
          FChildDic.Remove((FChilds.Items[LIndex] as ISectorUpdate).GetSectorInfo.FId);
          FChilds.Items[LIndex] := nil;
          FChilds.Delete(LIndex);
        end;
      end;
    end;
    Result := True;
    LSectorMgr := nil;
  end;
end;

function TSectorImpl.ClearChilds: Boolean;
begin
  Result := True;
  DoClearChilds;
  FParent := nil;
end;

function TSectorImpl.AddChild(AId: Integer): ISector;
begin
  if not FChildDic.TryGetValue(AId, Result) then begin
    Result := TSectorImpl.Create(FAppContext, Self);
  end;
end;

end.
