unit KeyFairyImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º KeyFairy Implementation
// Author£º      lksoulman
// Date£º        2017-11-27
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  SecuMain,
  KeyFairy,
  AppContext,
  KeyFairyUI,
  KeySearchEngine,
  AppContextObject;

type

  // KeyFairy Implementation
  TKeyFairyImpl = class(TAppContextObject, IKeyFairy)
  private
    // KeyFairyUI
    FKeyFairyUI: TKeyFairyUI;
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IKeyFairy }

    // Display
    function Display(AHandle: THandle; AKey: string; var ASecuMainItem: PSecuMainItem): Boolean;
    // DisplayEx
    function DisplayEx(AHandle: THandle; AKey: string; ALeft, ATop: Integer; var ASecuMainItem: PSecuMainItem): Boolean;
  end;

implementation

{ TKeyFairyImpl }

constructor TKeyFairyImpl.Create(AContext: IAppContext);
begin
  inherited;
  FKeyFairyUI := TKeyFairyUI.Create(AContext);
end;

destructor TKeyFairyImpl.Destroy;
begin
  FKeyFairyUI.Free;
  inherited;
end;

function TKeyFairyImpl.Display(AHandle: THandle; AKey: string; var ASecuMainItem: PSecuMainItem): Boolean;
var
  LRect: TRect;
begin
  Result := False;
  GetWindowRect(AHandle, LRect);
  FKeyFairyUI.Left := LRect.Right - FKeyFairyUI.Width;
  FKeyFairyUI.Top := LRect.Bottom - FKeyFairyUI.Height;
  if not FKeyFairyUI.Showing then begin
//    SetParent(FKeyFairyUI.Handle, AHandle);
    FKeyFairyUI.Show;
    FKeyFairyUI.SetKey(AKey);
  end;
end;

function TKeyFairyImpl.DisplayEx(AHandle: THandle; AKey: string; ALeft, ATop: Integer; var ASecuMainItem: PSecuMainItem): Boolean;
begin
  Result := False;

end;

end.
