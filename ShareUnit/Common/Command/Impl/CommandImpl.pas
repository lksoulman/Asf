unit CommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Command Implementation
// Author£º      lksoulman
// Date£º        2017-11-14
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Command,
  BaseObject,
  AppContext,
  CommonLock;

type

  // Command Implementation
  TCommandImpl = class(TBaseSplitStrInterfacedObject, ICommand)
  private
  protected
    // FId
    FId: Cardinal;
    // FCaption
    FCaption: string;
    // ShortKey
    FShortKey: Integer;
    // Visible
    FVisible: Boolean;
    // Lock
    FLock: TCSLock;
  public
    // Constructor
    constructor Create(AId: Cardinal; ACaption: string; AContext: IAppContext); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;

    { ICommand }

    // Get Id
    function GetId: Cardinal;
    // Get Basic Id
    function GetBasicId: Int64; virtual;
    // Get Caption
    function GetCaption: string;
    // Get Visible
    function GetVisible: Boolean;
    // Get Short Key
    function GetShortKey: Integer;
    // Execute
    procedure Execute(AParams: string); virtual;
  end;

implementation

{ TCommandImpl }

constructor TCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited Create(AContext);
  FId := AId;
  FCaption := ACaption;
  FLock := TCSLock.Create;
end;

destructor TCommandImpl.Destroy;
begin
  FLock.Free;
  inherited;
end;

function TCommandImpl.GetId: Cardinal;
begin
  Result := FId;
end;

function TCommandImpl.GetBasicId: Int64;
begin
  Result := 0;
end;

function TCommandImpl.GetCaption: string;
begin
  Result := FCaption;
end;

function TCommandImpl.GetVisible: Boolean;
begin
  Result := FVisible;
end;

function TCommandImpl.GetShortKey: Integer;
begin
  Result := FShortKey;
end;

procedure TCommandImpl.Execute(AParams: string);
begin

end;

end.
