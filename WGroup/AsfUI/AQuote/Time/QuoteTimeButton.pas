unit QuoteTimeButton;

interface

uses Windows, Classes, Graphics;

type

  TDirectionType = (dtBuy, dtSell);

  TIconButton = class
  private
    FRect: TRect;
    FTime: Integer;
    FFocused: Boolean;
    FDirectionType: TDirectionType;
  public
    constructor Create;
    destructor Destroy; override;

    property Rect: TRect read FRect write FRect;
    property Time: Integer read FTime write FTime;
    property Focused: Boolean read FFocused write FFocused;
    property DirectionType: TDirectionType read FDirectionType
      write FDirectionType;
  end;

  TTitleButton = class(TIconButton)
  private
    FHint: string;
    FResName: string;
    FHotResName: string;
    FOnClick: TNotifyEvent;
  public
    constructor Create;
    destructor Destroy; override;

    property Hint: string read FHint write FHint;
    property ResName: string read FResName write FResName;
    property HotResName: string read FHotResName write FHotResName;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

implementation

{ TIconButton }

constructor TIconButton.Create;
begin
  FFocused := False;
end;

destructor TIconButton.Destroy;
begin

  inherited;
end;

{ TTitleButton }

constructor TTitleButton.Create;
begin
  FHint := '';
  FResName := '';
  FHotResName := '';
end;

destructor TTitleButton.Destroy;
begin

  inherited;
end;

end.
