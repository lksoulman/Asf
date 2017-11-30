unit ChildPageImpl;



interface

uses
  Windows,
  Classes,
  SysUtils,
  ChildPage,
  BaseFormUI,
  AppContext;

type

  // Child Page Impl
  TChildPageImpl = class(TBaseFormUI, IChildPage)
  private
  protected
    // CommandId
    FCommandId: Integer;
  public
    // Constructor
    constructor Create(AContext: IAppContext; ACommandId: Integer); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;

    { IChildPage }

    // Show
    procedure Show;
    // Hide
    procedure Hide;
    // Close
    procedure Close;
    // Set Activate
    procedure SetActivate; virtual;
    // Set No Activate
    procedure SetNoActivate; virtual;
    // Bring To Front
    procedure BringToFront;
    // Update Style Skin
    procedure UpdateStyleSkin; virtual;
    // Go Back (True is Response, False Is not Response)
    function GoBack: Boolean; virtual;
    // Go Forward (True is Response, False Is not Response)
    function GoForward: Boolean; virtual;
    // Get Handle
    function GetHandle: Cardinal; virtual;
    // Get Command Id
    function GetCommandId: Integer; virtual;
  end;

implementation

{ TChildPageImpl }

constructor TChildPageImpl.Create(AContext: IAppContext; ACommandId: Integer);
begin
  inherited Create(AContext);
  FCommandId := ACommandId;
end;

destructor TChildPageImpl.Destroy;
begin

  inherited;
end;

procedure TChildPageImpl.Show;
begin
  inherited Show;
end;

procedure TChildPageImpl.Hide;
begin
  inherited Hide;
end;

procedure TChildPageImpl.Close;
begin
  inherited Close;
end;

procedure TChildPageImpl.SetActivate;
begin
  if not FIsActivate then begin

    FIsActivate := True;
  end;
end;

procedure TChildPageImpl.SetNoActivate;
begin
  if FIsActivate then begin

    FIsActivate := False;
  end;
end;

procedure TChildPageImpl.BringToFront;
begin
  inherited BringToFront;
end;

procedure TChildPageImpl.UpdateStyleSkin;
begin

end;

function TChildPageImpl.GoBack: Boolean;
begin
  Result := False;
end;

function TChildPageImpl.GoForward: Boolean;
begin
  Result := False;
end;

function TChildPageImpl.GetHandle: Cardinal;
begin
  Result := Self.Handle;
end;

function TChildPageImpl.GetCommandId: Integer;
begin
  Result := FCommandId;
end;

end.
