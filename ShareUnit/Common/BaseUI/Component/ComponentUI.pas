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
  CommonRefCounter;

type

  // Component UI
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
    // RectEx Is Valid
    function RectExIsValid: Boolean; virtual;
    // Pt In RectEx
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
