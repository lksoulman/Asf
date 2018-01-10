unit MsgExImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º MsgEx Implementation
// Author£º      lksoulman
// Date£º        2017-12-08
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  MsgEx;

type

  // MsgEx Implementation
  TMsgExImpl = class(TMsgEx)
  private
    // Id
    FId: Integer;
    // Info
    FInfo: string;
    // CreateTime
    FCreateTime: TDateTime;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // GetId
    function GetId: Integer; override;
    // GetInfo
    function GetInfo: string; override;
    // GetCreateTime
    function GetCreateTime: TDateTime; override;
    // Update
    procedure Update(AId: Integer; AInfo: string);
  end;

implementation

{ TMsgExImpl }

constructor TMsgExImpl.Create;
begin
  inherited;
  FId := 0;
  FInfo := '';
end;

destructor TMsgExImpl.Destroy;
begin
  FInfo := '';
  inherited;
end;

function TMsgExImpl.GetId: Integer;
begin
  Result := FId;
end;

function TMsgExImpl.GetInfo: string;
begin
  Result := FInfo;
end;

function TMsgExImpl.GetCreateTime: TDateTime;
begin
  Result := FCreateTime;
end;

procedure TMsgExImpl.Update(AId: Integer; AInfo: string);
begin
  FId := AId;
  FInfo := AInfo;
end;

end.
