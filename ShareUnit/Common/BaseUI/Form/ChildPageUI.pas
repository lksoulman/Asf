unit ChildPageUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Base Form UI
// Author£º      lksoulman
// Date£º        2017-12-13
// Comments£º
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

