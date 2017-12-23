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
  BaseObject,
  AppContext,
  KeyFairyUI,
  KeySearchEngine;

type

  // KeyFairy Implementation
  TKeyFairyImpl = class(TBaseInterfacedObject, IKeyFairy)
  private
    // MasterHandle
    FMasterHandle: THandle;
    // KeyFairyUI
    FKeyFairyUI: TKeyFairyUI;
  protected
    // KeyFairyDeActivate
    procedure DoKeyFairyDeActivate(Sender: TObject);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IKeyFairy }

    // Display
    function Display(AMasterHandle: THandle; AKey: string; var ASecuInfo: PSecuInfo): Boolean;
    // DisplayEx
    function DisplayEx(AMasterHandle, APosHandle: THandle; AKey: string; ALeft, ATop: Integer; var ASecuInfo: PSecuInfo): Boolean;
  end;

implementation

{ TKeyFairyImpl }

constructor TKeyFairyImpl.Create(AContext: IAppContext);
begin
  inherited;
  FKeyFairyUI := TKeyFairyUI.Create(AContext);
  FKeyFairyUI.OnDeactivate := DoKeyFairyDeActivate;
end;

destructor TKeyFairyImpl.Destroy;
begin
  FKeyFairyUI.Free;
  inherited;
end;

procedure TKeyFairyImpl.DoKeyFairyDeActivate(Sender: TObject);
begin
  if FMasterHandle <> 0 then begin
    Self.FKeyFairyUI.Hide;
    SetActiveWindow(FMasterHandle);
    FMasterHandle := 0;
  end;
end;

function TKeyFairyImpl.Display(AMasterHandle: THandle; AKey: string; var ASecuInfo: PSecuInfo): Boolean;
var
  LRect: TRect;
begin
  Result := False;
  if AMasterHandle = 0 then Exit;

  FMasterHandle := AMasterHandle;
  SetForegroundWindow(FKeyFairyUI.Handle);
  GetWindowRect(AMasterHandle, LRect);
  FKeyFairyUI.Left := LRect.Right - FKeyFairyUI.Width;
  FKeyFairyUI.Top := LRect.Bottom - FKeyFairyUI.Height - 31;
  if not FKeyFairyUI.Showing then begin
    FKeyFairyUI.Show;
    FKeyFairyUI.SetKey(AKey);
  end;
end;

function TKeyFairyImpl.DisplayEx(AMasterHandle, APosHandle: THandle; AKey: string; ALeft, ATop: Integer; var ASecuInfo: PSecuInfo): Boolean;
var
  LRect: TRect;
begin
  Result := False;

  if (AMasterHandle = 0)
    or (APosHandle = 0) then Exit;

  GetWindowRect(AMasterHandle, LRect);
  FKeyFairyUI.Left := LRect.Right - FKeyFairyUI.Width;
  FKeyFairyUI.Top := LRect.Bottom - FKeyFairyUI.Height - 31;
  if not FKeyFairyUI.Showing then begin
    FKeyFairyUI.Show;
    FKeyFairyUI.SetKey(AKey);
  end;
end;

end.
