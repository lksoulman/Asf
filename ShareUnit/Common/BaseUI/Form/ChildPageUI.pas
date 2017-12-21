unit ChildPageUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Base Form UI
// Author��      lksoulman
// Date��        2017-12-13
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Vcl.Forms,
  AppContext,
  CustomBaseUI;

type

  // ChildPageUI
  TChildPageUI = class(TCustomBaseUI)
  private
  protected
    // BeforeCreate
    procedure DoBeforeCreate; override;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

{ TChildPageUI }

constructor TChildPageUI.Create(AContext: IAppContext);
begin
  inherited;

end;

destructor TChildPageUI.Destroy;
begin

  inherited;
end;

procedure TChildPageUI.DoBeforeCreate;
begin
  inherited;
  FIsMaximize := False;
  FIsMinimize := False;
  FBorderWidth := 0;
  FCaptionHeight := 0;
  FBorderStyleEx := bsNone;
end;

end.

