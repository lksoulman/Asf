unit SectorImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Sector Interface
// Author��      lksoulman
// Date��        2017-8-23
// Comments��
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

  // Sector Interface
  TSectorImpl = class(TAutoInterfacedObject, ISector)
  private
    // Sector ID
    FSectorID: string;
    // Sector Name
    FSectorName: string;
    // Child Sector Str
    FChildSectorStr: string;
    // Child Sectors
    FChildSectors: TList<ISector>;
  protected
    // ������
    procedure DoClearSectors;
  public
    // ���췽��
    constructor Create; override;
    // ��������
    destructor Destroy; override;

    { ISector }

    // ��ȡ��� ID
    function GetSectorID: WideString; safecall;
    // ��ȡ��������
    function GetSectorName: WideString; safecall;
    // ��ȡ�Ӱ��ɷ����ַ�������
    function GetChildSectors: WideString; safecall;
    // ��ȡ�ǲ��Ǵ����Ӱ��
    function GetChildSectorExist: boolean; safecall;
    // ��ȡ�Ӱ�����
    function GetChildSectorCount: Integer; safecall;
    // ��ȡ�Ӱ��ӿ�ͨ���±�
    function GetChildSector(AIndex: Integer): ISector; safecall;
    // ��ȡ�Ӱ���ǲ��Ǵ���
    function GetExistChildSectorName(AName: WideString): boolean; safecall;
    // �����Ӱ��
    function AddChildSectorByName(AName: WideString): ISector; safecall;
    // ���ð�� ID
    procedure SetSectorID(AID: WideString); safecall;
    // ���ð������
    procedure SetSectorName(AName: WideString); safecall;
    // ɾ���Ӱ��
    procedure DelChildSector(ASector: ISector); safecall;
    // ɾ���Ӱ��ͨ���������
    procedure DelChildSectorByName(AName: WideString); safecall;
  end;

implementation

{ TSectorImpl }

constructor TSectorImpl.Create;
begin
  inherited;
  FChildSectors := TList<ISector>.Create;
end;

destructor TSectorImpl.Destroy;
begin
  DoClearSectors;
  FChildSectors.Free;
  inherited;
end;

procedure TSectorImpl.DoClearSectors;
var
  LIndex: Integer;
  LSector: ISector;
begin
  for LIndex := 0 to FChildSectors.Count - 1 do begin
    LSector := FChildSectors.Items[LIndex];
    FChildSectors.Items[LIndex] := nil;
    if (LSector <> nil) then begin
      LSector := nil;
      Break;
    end;
  end;
  FChildSectors.Clear;
end;

function TSectorImpl.GetSectorID: WideString;
begin
  Result := FSectorID;
end;

function TSectorImpl.GetSectorName: WideString;
begin
  Result := FSectorName;
end;

function TSectorImpl.GetChildSectors: WideString;
begin
  Result := FChildSectorStr;
end;

function TSectorImpl.GetChildSectorExist: boolean;
begin
  Result := (FChildSectors.Count > 0);
end;

function TSectorImpl.GetChildSectorCount: Integer;
begin
  Result := FChildSectors.Count;
end;

function TSectorImpl.GetChildSector(AIndex: Integer): ISector;
begin
  if (AIndex >= 0) and (AIndex < FChildSectors.Count) then begin
    Result := FChildSectors.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

function TSectorImpl.GetExistChildSectorName(AName: WideString): boolean;
var
  LIndex: Integer;
begin
  Result := False;
  for LIndex := 0 to FChildSectors.Count - 1 do begin
    if (FChildSectors.Items[LIndex] <> nil)
      and (FChildSectors.Items[LIndex].GetSectorName = AName) then begin
      Result := True;
      Exit;
    end;
  end;
end;

function TSectorImpl.AddChildSectorByName(AName: WideString): ISector;
begin
  if not GetExistChildSectorName(AName) then begin
    Result := TSectorImpl.Create as ISector;
    Result.SetSectorName(AName);
    FChildSectors.Add(Result);
  end else begin
    Result := nil;
  end;
end;

procedure TSectorImpl.SetSectorID(AID: WideString);
begin
  FSectorID := AID;
end;

procedure TSectorImpl.SetSectorName(AName: WideString);
begin
  FSectorName := AName;
end;

procedure TSectorImpl.DelChildSector(ASector: ISector);
begin
  if (ASector <> nil) and (FChildSectors.IndexOf(ASector) >= 0) then begin
    FChildSectors.Remove(ASector);
  end;
end;

procedure TSectorImpl.DelChildSectorByName(AName: WideString);
var
  LIndex: Integer;
  LSector: ISector;
begin
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
