unit LoadProcessUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º LoadProcessUI
// Author£º      lksoulman
// Date£º        2017-11-16
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Messages,
  Variants,
  Graphics,
  Controls,
  Dialogs,
  Vcl.Forms,
  Vcl.ExtCtrls,
  GDIPOBJ,
  RenderUtil,
  AppContext,
  CustomBaseUI;

type

  // LoadProcessUI
  TLoadProcessUI = class(TCustomBaseUI)
  private
    // ShowInfo
    FShowInfo: string;
  protected
    // Update Skin Style
    procedure DoUpdateSkinStyle; override;

    // Draw Client
//    procedure DrawC(ADC: HDC; ARect: TRect); override;
//    // Draw ShowInfo
//    procedure DrawShowInfo(ADC: HDC; ARect: TRect);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // ShowInfo
    procedure ShowInfo(AInfo: string);
  end;

implementation

{$R *.dfm}

{ TLoadProcessUI }

constructor TLoadProcessUI.Create(AContext: IAppContext);
begin
  inherited;
  Caption := '²å¼þ×°ÔØ';
end;

destructor TLoadProcessUI.Destroy;
begin
  inherited;
end;

procedure TLoadProcessUI.DoUpdateSkinStyle;
begin
//  if Color <> FAppContext.GetGdiMgr.GetColorRefLoadProcessBack then begin
//    Color := FAppContext.GetGdiMgr.GetColorRefLoadProcessBack;
//  end;
//  FBorderColor := FAppContext.GetGdiMgr.GetColorRefLoadProcessBorder;
//  FCaptionBackColor := FAppContext.GetGdiMgr.GetColorRefLoadProcessCaptionBack;
//  FCaptionTextColor := FAppContext.GetGdiMgr.GetColorRefLoadProcessCaptionText;
end;

//procedure TLoadProcessUI.DrawC(ADC: HDC; ARect: TRect);
//begin
//  inherited;
//  DrawShowInfo(ADC, ARect);
//end;

//procedure TLoadProcessUI.DrawShowInfo(ADC: HDC; ARect: TRect);
//var
//  LRect: TRect;
//begin
//  if FShowInfo <> '' then begin
//    LRect := ARect;
//    LRect.Inflate(-10, 80);
//    DrawTextX(ADC, LRect, FShowInfo,
//      FAppContext.GetGdiMgr.GetColorRefLoadProcessCaptionText, dtaLeft, False, True);
//  end;
//end;

procedure TLoadProcessUI.ShowInfo(AInfo: string);
begin
  FShowInfo := AInfo;
  Invalidate;
end;

end.
