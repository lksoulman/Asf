unit ComponentUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Component UI
// Author£º      lksoulman
// Date£º        2017-10-27
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  RenderDC,
  CommonLock,
  CommonRefCounter;

type

  // ComponentId
  TComponentId = class(TAutoObject)
  private
    // Id
    FId: Integer;
    // Lock
    FLock: TCSLock;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // GenerateId
    function GenerateId: Integer;
  end;

  // ComponentUI
  TComponentUI = class(TAutoObject)
  private
  protected
    // Id
    FId: Integer;
    // Tag
    FTag: Integer;
    // Rect
    FRectEx: TRect;
    // Caption
    FCaption: string;
    // Visible
    FVisible: Boolean;
    // Resource Stream
    FResourceStream: TResourceStream;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // RectExIsValid
    function RectExIsValid: Boolean; virtual;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; virtual;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; virtual;

    property Id: Integer read FId write FId;
    property Tag: Integer read FTag write FTag;
    property RectEx: TRect read FRectEx write FRectEx;
    property Caption: string read FCaption write FCaption;
    property Visible: Boolean read FVisible write FVisible;
    property ResourceStream: TResourceStream read FResourceStream write FResourceStream;
  end;

implementation

{ TComponentId }

constructor TComponentId.Create;
begin
  inherited;
  FId := 0;
  FLock := TCSLock.Create;
end;

destructor TComponentId.Destroy;
begin
  FLock.Free;
  inherited;
end;

function TComponentId.GenerateId: Integer;
begin
  FLock.Lock;
  try
    Result := FId;
    Inc(FId);
  finally
    FLock.UnLock;
  end;
end;

{ TComponentUI }

constructor TComponentUI.Create;
begin
  inherited;
  FVisible := True;
end;

destructor TComponentUI.Destroy;
begin
  inherited;
end;

function TComponentUI.RectExIsValid: Boolean;
begin
  Result := False;
end;

function TComponentUI.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := False;
end;

function TComponentUI.Draw(ARenderDC: TRenderDC): Boolean;
begin
  Result := False;
end;

end.
