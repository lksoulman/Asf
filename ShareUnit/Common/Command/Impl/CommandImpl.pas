unit CommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Command Interface Implementation
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
  AppContext,
  CommonLock,
  CommonRefCounter;

type

  // Command Interface
  TCommandImpl = class(TAutoInterfacedObject, ICommand)
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
    // App Context
    FAppContext: IAppContext;
    // Fast Split Params
    FFastSplitParams: TStringList;

    // EndSplit
    procedure EndSplitParams;
    // BeginSplit
    procedure BeginSplitParams(AParams: string);
    // ParamsVal
    procedure ParamsVal(AName: string; var AVal: string);
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
    // Execute
    procedure ExecuteEx(AParams: array of string); virtual;
    // Execute
    procedure ExecuteAsync(AParams: string); virtual;
    // Execute
    procedure ExecuteAsyncEx(AParams: array of string); virtual;
  end;

implementation

{ TCommandImpl }

constructor TCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited Create;
  FId := AId;
  FCaption := ACaption;
  FAppContext := AContext;
  FLock := TCSLock.Create;
  FFastSplitParams := TStringList.Create;
  FFastSplitParams.Delimiter := '@';
end;

destructor TCommandImpl.Destroy;
begin
  FFastSplitParams.Free;
  FLock.Free;
  inherited;
end;

procedure TCommandImpl.EndSplitParams;
begin
  FFastSplitParams.DelimitedText := '';
end;

procedure TCommandImpl.BeginSplitParams(AParams: string);
begin
  FFastSplitParams.DelimitedText := AParams;
end;

procedure TCommandImpl.ParamsVal(AName: string; var AVal: string);
begin
  AVal := FFastSplitParams.Values[AName];
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

procedure TCommandImpl.ExecuteEx(AParams: array of string);
begin

end;

procedure TCommandImpl.ExecuteAsync(AParams: string);
begin

end;

procedure TCommandImpl.ExecuteAsyncEx(AParams: array of string);
begin

end;

end.
