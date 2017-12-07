unit UserSectorImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserSector Implementation
// Author£º      lksoulman
// Date£º        2017-8-23
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Sector,
  Windows,
  Classes,
  SysUtils,
  CommonRefCounter,
  Generics.Collections;

type

  // UserSectorInfo
  TUserSectorInfo = packed record
    FID: string;
    FCID: Integer;
    FName: string;
    FOrder: Integer;
    FInnerCodes: string;
  end;

  // UserSectorInfo Pointer
  PUserSectorInfo = ^TUserSectorInfo;

  // UserSector Implementation
  TUserSectorImpl = class(TAutoInterfacedObject, ISector)
  private
    // ChildSectors
    FChildSectors: TList<ISector>;
    // UserSectorInfo
    FUserSectorInfo: TUserSectorInfo;
  protected
    // ClearSectors
    procedure DoClearSectors;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;

    { ISector }

    // GetDataPtr
    function GetDataPtr: Pointer;
    // GetSectorID
    function GetSectorID: WideString;
    // GetSectorName
    function GetSectorName: WideString;
    // GetChildSectors
    function GetChildSectors: WideString;
    // GetChildSectorExist
    function GetChildSectorExist: boolean;
    // GetChildSectorCount
    function GetChildSectorCount: Integer;
    // GetChildSector
    function GetChildSector(AIndex: Integer): ISector;
    // GetExistChildSectorName
    function GetExistChildSectorName(AName: WideString): boolean;
    // AddChildSectorByName
    function AddChildSectorByName(AName: WideString): ISector;
    // DeleteChildSectorByName
    procedure DeleteChildSectorByName(AName: WideString);
  end;

implementation

{ TUserSectorImpl }

constructor TUserSectorImpl.Create;
begin
  inherited;

end;

destructor TUserSectorImpl.Destroy;
begin
  DoClearSectors;
  if FChildSectors <> nil then begin
    FChildSectors.Free;
  end;
  inherited;
end;

procedure TUserSectorImpl.DoClearSectors;
var
  LIndex: Integer;
begin
  if FChildSectors = nil then Exit;

  for LIndex := 0 to FChildSectors.Count - 1 do begin
    FChildSectors.Items[LIndex] := nil;
  end;
  FChildSectors.Clear;
end;

function TUserSectorImpl.GetDataPtr: Pointer;
begin
  Result := @FUserSectorInfo;
end;

function TUserSectorImpl.GetSectorID: WideString;
begin
  Result := FUserSectorInfo.FID;
end;

function TUserSectorImpl.GetSectorName: WideString;
begin
  Result := FUserSectorInfo.FName;
end;

function TUserSectorImpl.GetChildSectors: WideString;
begin
  Result := FUserSectorInfo.FInnerCodes;
end;

function TUserSectorImpl.GetChildSectorExist: boolean;
begin
  Result := False;
  if FChildSectors = nil then Exit;
  Result := (FChildSectors.Count > 0);
end;

function TUserSectorImpl.GetChildSectorCount: Integer;
begin
  Result := 0;
  if FChildSectors = nil then Exit;
  Result := FChildSectors.Count;
end;

function TUserSectorImpl.GetChildSector(AIndex: Integer): ISector;
begin
  Result := nil;
  if FChildSectors = nil then Exit;
  if (AIndex >= 0) and (AIndex < FChildSectors.Count) then begin
    Result := FChildSectors.Items[AIndex];
  end;
end;

function TUserSectorImpl.GetExistChildSectorName(AName: WideString): boolean;
var
  LIndex: Integer;
begin
  Result := False;
  if FChildSectors = nil then Exit;
  for LIndex := 0 to FChildSectors.Count - 1 do begin
    if (FChildSectors.Items[LIndex] <> nil)
      and (FChildSectors.Items[LIndex].GetSectorName = AName) then begin
      Result := True;
      Exit;
    end;
  end;
end;

function TUserSectorImpl.AddChildSectorByName(AName: WideString): ISector;
var
  LUserSectorInfo: PUserSectorInfo;
begin
  if not GetExistChildSectorName(AName) then begin
    Result := TUserSectorImpl.Create as ISector;
    LUserSectorInfo := PUserSectorInfo(Result.GetDataPtr);
    if LUserSectorInfo <> nil then begin
      LUserSectorInfo^.FName := AName;
    end;
    FChildSectors.Add(Result);
  end else begin
    Result := nil;
  end;
end;

procedure TUserSectorImpl.DeleteChildSectorByName(AName: WideString);
var
  LIndex: Integer;
  LSector: ISector;
begin
  if FChildSectors = nil then Exit;
  for LIndex := 0 to FChildSectors.Count - 1 do begin
    LSector := FChildSectors.Items[LIndex];
    if (LSector <> nil)
      and (LSector.GetSectorName = AName) then begin
      FChildSectors.Delete(LIndex);
      LSector := nil;
      break;
    end;
  end;
end;

end.
