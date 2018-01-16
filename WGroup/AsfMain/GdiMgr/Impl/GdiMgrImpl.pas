unit GdiMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º GdiMgr Implementation
// Author£º      lksoulman
// Date£º        2017-11-15
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  GdiMgr,
  AppContext,
  CommonRefCounter;

type

  // GdiMgr Implementation
  TGdiMgrImpl = class(TAutoInterfacedObject, IGdiMgr)
  private
    // AppContext
    FAppContext: IAppContext;
    // App Logo
    FImgAppLogo: TResourceStream;
    // App Logo Small
    FImgAppLogoS: TResourceStream;
    // App Close
    FImgAppClose: TResourceStream;
    // App Restore
    FImgAppRestore: TResourceStream;
    // App Maximize
    FImgAppMaximize: TResourceStream;
    // App Minimize
    FImgAppMinimize: TResourceStream;

    // Hq Red
    FColorRefHqRed: COLORREF;
    // Hq Green
    FColorRefHqGreen: COLORREF;
    // Hq Turnover
    FColorRefHqTurnover: COLORREF;
    // Form Back
    FColorRefFormBack: COLORREF;
    // Form Border
    FColorRefFormBorder: COLORREF;
    // Form Caption Text
    FColorRefFormCaptionText: COLORREF;
    // Form Caption Back
    FColorRefFormCaptionBack: COLORREF;
    // Master Back
    FColorRefMasterBack: COLORREF;
    // Master Border
    FColorRefMasterBorder: COLORREF;
    // Master Caption Text
    FColorRefMasterCaptionText: COLORREF;
    // Master Caption Back
    FColorRefMasterCaptionBack: COLORREF;
    // Master Caption Super Tab Back
    FColorRefMasterSuperTabBack: COLORREF;
    // Master StatusBar Back
    FColorRefMasterStatusBarBack: COLORREF;
    // Master StatusBar Text
    FColorRefMasterStatusBarText: COLORREF;
    // Master Child Back
    FColorRefMasterChildBack: COLORREF;
    // Master Child Border
    FColorRefMasterChildBorder: COLORREF;
    // Master Child Caption Text
    FColorRefMasterChildCaptionText: COLORREF;
    // Master Child Caption Back
    FColorRefMasterChildCaptionBack: COLORREF;
    // Load Process Back
    FColorRefLoadProcessBack: COLORREF;
    // Load Process Back
    FColorRefLoadProcessBorder: COLORREF;
    // Load Process Caption Text
    FColorRefLoadProcessCaptionText: COLORREF;
    // Load Process Caption Back
    FColorRefLoadProcessCaptionBack: COLORREF;
    // ColorRefButtonBack
    FColorRefButtonBack: COLORREF;
    // ColorRefButtonBorder
    FColorRefButtonBorder: COLORREF;
    // ColorRefButtonText
    FColorRefButtonText: COLORREF;
    // ColorRefButtonHotBack
    FColorRefButtonHotBack: COLORREF;
    // ColorRefButtonHotBorder
    FColorRefButtonHotBorder: COLORREF;
    // ColorRefButtonHotText
    FColorRefButtonHotText: COLORREF;
    // ColorRefButtonDownBack
    FColorRefButtonDownBack: COLORREF;
    // ColorRefButtonDownBorder
    FColorRefButtonDownBorder: COLORREF;
    // ColorRefButtonDownText
    FColorRefButtonDownText: COLORREF;
    // ColorRefButtonDisableBack
    FColorRefButtonDisableBack: COLORREF;
    // ColorRefButtonDisableBorder
    FColorRefButtonDisableBorder: COLORREF;
    // ColorRefButtonDisableText
    FColorRefButtonDisableText: COLORREF;

    // Font Obj Height 18
    FFontObjHeight18: HFONT;
    // Font Obj Height 20
    FFontObjHeight20: HFONT;
    // Font Obj Height 22
    FFontObjHeight22: HFONT;
    // Font Obj Height 24
    FFontObjHeight24: HFONT;

    // Form Border
    FBrushObjFormBorder: HGDIOBJ;
    // Master Border
    FBrushObjMasterBorder: HGDIOBJ;
    // Master Child Border
    FBrushObjMasterChildBorder: HGDIOBJ;
    // Load Process Border
    FBrushObjLoadProcessBorder: HGDIOBJ;
  protected
    // Init
    procedure DoInit;
    // Un Init
    procedure DoUnInit;
    // Init Fonts
    procedure DoInitFonts;
    // Init Colors
    procedure DoInitColors;
    // Init Brushs
    procedure DoInitBrushs;
    // Init Resources
    procedure DoInitResources;
    // Clear Fonts
    procedure DoClearFonts;
    // Clear Brushs
    procedure DoClearBrushs;
    // Clear Resources
    procedure DoClearResources;
  public
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce;
    // Destructor
    destructor Destroy; override;

    { IGdiMgr }

    // GetImgAppLogo
    function GetImgAppLogo: TResourceStream;
    // GetImgAppLogoSmall
    function GetImgAppLogoS: TResourceStream;
    // GetImgAppClose
    function GetImgAppClose: TResourceStream;
    // GetImgAppRestore
    function GetImgAppRestore: TResourceStream;
    // GetImgAppMaximize
    function GetImgAppMaximize: TResourceStream;
    // GetImgAppMinimize
    function GetImgAppMinimize: TResourceStream;
    // GetFontObjHeight18
    function GetFontObjHeight18: HFONT;
    // GetFontObjHeight20
    function GetFontObjHeight20: HFONT;
    // GetFontObjHeight22
    function GetFontObjHeight22: HFONT;
    // GetFontObjHeight24
    function GetFontObjHeight24: HFONT;
    // GetFormBorder
    function GetBrushObjFormBorder: HGDIOBJ;
    // GetMasterBorder
    function GetBrushObjMasterBorder: HGDIOBJ;
    // GetMasterChildBorder
    function GetBrushObjMasterChildBorder: HGDIOBJ;
    // GetLoadProcessBorder
    function GetBrushObjLoadProcessBorder: HGDIOBJ;
    // GetHqRed
    function GetColorRefHqRed: COLORREF;
    // GetHqGreen
    function GetColorRefHqGreen: COLORREF;
    // GetHqTurnover
    function GetColorRefHqTurnover: COLORREF;
    // GetFormBack
    function GetColorRefFormBack: COLORREF;
    // GetFormBorder
    function GetColorRefFormBorder: COLORREF;
    // GetFormCaptionText
    function GetColorRefFormCaptionText: COLORREF;
    // GetFormCaptionBack
    function GetColorRefFormCaptionBack: COLORREF;
    // GetMasterBack
    function GetColorRefMasterBack: COLORREF;
    // GetMasterBorder
    function GetColorRefMasterBorder: COLORREF;
    // GetMasterCaptionText
    function GetColorRefMasterCaptionText: COLORREF;
    // GetMasterCaptionBack
    function GetColorRefMasterCaptionBack: COLORREF;
    // GetMasterCaptionSuperTabBack
    function GetColorRefMasterSuperTabBack: COLORREF;
    // GetMasterStatusBarBack
    function GetColorRefMasterStatusBarBack: COLORREF;
    // GetMasterStatusBarText
    function GetColorRefMasterStatusBarText: COLORREF;
    // GetMasterChildBack
    function GetColorRefMasterChildBack: COLORREF;
    // GetMasterChildBorder
    function GetColorRefMasterChildBorder: COLORREF;
    // GetMasterChildCaptionText
    function GetColorRefMasterChildCaptionText: COLORREF;
    // GetMasterChildCaptionBack
    function GetColorRefMasterChildCaptionBack: COLORREF;
    // GetLoadProcessBack
    function GetColorRefLoadProcessBack: COLORREF;
    // GetLoadProcessBorder
    function GetColorRefLoadProcessBorder: COLORREF;
    // GetLoadProcessCaptionText
    function GetColorRefLoadProcessCaptionText: COLORREF;
    // GetLoadProcessCaptionBack
    function GetColorRefLoadProcessCaptionBack: COLORREF;
    // GetColorRefButtonBack
    function GetColorRefButtonBack: COLORREF;
    // GetColorRefButtonBorder
    function GetColorRefButtonBorder: COLORREF;
    // GetColorRefButtonText
    function GetColorRefButtonText: COLORREF;
    // GetColorRefButtonHotBack
    function GetColorRefButtonHotBack: COLORREF;
    // GetColorRefButtonHotBorder
    function GetColorRefButtonHotBorder: COLORREF;
    // GetColorRefButtonHotText
    function GetColorRefButtonHotText: COLORREF;
    // GetColorRefButtonDownBack
    function GetColorRefButtonDownBack: COLORREF;
    // GetColorRefButtonDownBorder
    function GetColorRefButtonDownBorder: COLORREF;
    // GetColorRefButtonDownText
    function GetColorRefButtonDownText: COLORREF;
    // GetColorRefButtonDisableBack
    function GetColorRefButtonDisableBack: COLORREF;
    // GetColorRefButtonDisableBorder
    function GetColorRefButtonDisableBorder: COLORREF;
    // GetColorRefButtonDisableText
    function GetColorRefButtonDisableText: COLORREF;
  end;

implementation

{ TGdiMgrImpl }

constructor TGdiMgrImpl.Create(AContext: IAppContext);
begin
  inherited Create;
  FAppContext := AContext;
  DoInit;
end;

destructor TGdiMgrImpl.Destroy;
begin
  DoUnInit;
  FAppContext := nil;
  inherited;
end;

procedure TGdiMgrImpl.DoInit;
begin
  DoInitFonts;
  DoInitColors;
  DoInitBrushs;
  DoInitResources;
end;

procedure TGdiMgrImpl.DoUnInit;
begin
  DoClearFonts;
  DoClearBrushs;
  DoClearResources;
end;

procedure TGdiMgrImpl.DoInitFonts;
var
  LFont: HGDIOBJ;
  LLogFont: LOGFONT;
begin
  ZeroMemory(@LLogFont, Sizeof(LOGFONT));
  LFont := GetStockObject(DEFAULT_GUI_FONT);
  GetObject(LFont, SizeOf(LOGFONT), @LLogFont);
  LLogFont.lfCharSet := DEFAULT_CHARSET;

  lstrcpy(LLogFont.lfFaceName , PChar('Î¢ÈíÑÅºÚ'));
  LLogFont.lfHeight := 18;
  LLogFont.lfWeight := FW_NORMAL;       // FW_BOLD
  LLogFont.lfItalic := Byte(False);
  LLogFont.lfUnderline := Byte(False);
  FFontObjHeight18 := CreateFontIndirect(LLogFont);

  lstrcpy(LLogFont.lfFaceName , PChar('Î¢ÈíÑÅºÚ'));
  LLogFont.lfHeight := 20;
  LLogFont.lfWeight := FW_NORMAL;
  LLogFont.lfItalic := Byte(False);
  LLogFont.lfUnderline := Byte(False);
  FFontObjHeight20 := CreateFontIndirect(LLogFont);

  lstrcpy(LLogFont.lfFaceName , PChar('Î¢ÈíÑÅºÚ'));
  LLogFont.lfHeight := 22;
  LLogFont.lfWeight := FW_NORMAL;
  LLogFont.lfItalic := Byte(False);
  LLogFont.lfUnderline := Byte(False);
  FFontObjHeight22 := CreateFontIndirect(LLogFont);

  lstrcpy(LLogFont.lfFaceName , PChar('Î¢ÈíÑÅºÚ'));
  LLogFont.lfHeight := 24;
  LLogFont.lfWeight := FW_NORMAL;
  LLogFont.lfItalic := Byte(False);
  LLogFont.lfUnderline := Byte(False);
  FFontObjHeight24 := CreateFontIndirect(LLogFont);
end;

procedure TGdiMgrImpl.DoInitColors;
begin
  FColorRefHqRed := RGB(255, 0, 0);
  FColorRefHqGreen := RGB(0, 128, 0);
  FColorRefHqTurnover := RGB(255, 200, 20);
  FColorRefFormBack := RGB(25, 25, 25);
  FColorRefFormBorder := RGB(24, 131, 215);
  FColorRefFormCaptionText := RGB(255, 95, 7);
  FColorRefFormCaptionBack := RGB(35, 35, 35);
  FColorRefMasterBack := RGB(25, 25, 25);
  FColorRefMasterBorder := RGB(24, 131, 215);
  FColorRefMasterCaptionText := RGB(124, 124, 124);
  FColorRefMasterCaptionBack := RGB(35, 35, 35);
  FColorRefMasterSuperTabBack := RGB(45, 45, 45);
  FColorRefMasterStatusBarBack := RGB(45, 45, 45);
  FColorRefMasterStatusBarText := RGB(124, 124, 124);
  FColorRefMasterChildBack := RGB(25, 25, 25);
  FColorRefMasterChildBorder := RGB(24, 131, 215);
  FColorRefMasterChildCaptionText := RGB(124, 124, 124);
  FColorRefMasterChildCaptionBack := RGB(35, 35, 35);
  FColorRefLoadProcessBack := RGB(25, 25, 25);
  FColorRefLoadProcessBorder := RGB(24, 131, 215);
  FColorRefLoadProcessCaptionText := RGB(124, 124, 124);
  FColorRefLoadProcessCaptionBack := RGB(35, 35, 35);

  FColorRefButtonBack := RGB(68, 68, 68);
  FColorRefButtonBorder := RGB(204, 204, 204);
  FColorRefButtonText := RGB(214, 214, 214);
  FColorRefButtonHotBack  := RGB(253, 143, 0);
  FColorRefButtonHotBorder := RGB(253, 143, 0);
  FColorRefButtonHotText := RGB(255, 255, 255);
  FColorRefButtonDownBack := RGB(153, 57, 4);
  FColorRefButtonDownBorder := RGB(153, 57, 4);
  FColorRefButtonDownText := RGB(255, 255, 255);
  FColorRefButtonDisableBack := RGB(160, 160, 160);
  FColorRefButtonDisableBorder := RGB(160, 160, 160);
  FColorRefButtonDisableText := RGB(180, 180, 180);
end;

procedure TGdiMgrImpl.DoInitBrushs;
begin
  FBrushObjFormBorder := CreatePen(PS_SOLID, 1, FColorRefFormBorder);
  FBrushObjMasterBorder := CreatePen(PS_SOLID, 1, FColorRefMasterBorder);
  FBrushObjMasterChildBorder := CreatePen(PS_SOLID, 1, FColorRefMasterChildBorder);
  FBrushObjLoadProcessBorder := CreatePen(PS_SOLID, 1, FColorRefLoadProcessBorder);
end;

procedure TGdiMgrImpl.DoInitResources;
begin
  if FAppContext = nil then Exit;

  FImgAppLogo := FAppContext.GetResourceSkin.GetStream('SKIN_APP_LOGO');
  FImgAppLogoS := FAppContext.GetResourceSkin.GetStream('SKIN_APP_LOGO_SMALL');
  FImgAppClose := FAppContext.GetResourceSkin.GetStream('SKIN_APP_CLOSE');
  FImgAppRestore := FAppContext.GetResourceSkin.GetStream('SKIN_APP_RESTORE');
  FImgAppMaximize := FAppContext.GetResourceSkin.GetStream('SKIN_APP_MAXIMIZE');
  FImgAppMinimize := FAppContext.GetResourceSkin.GetStream('SKIN_APP_MINIMIZE');
end;

procedure TGdiMgrImpl.DoClearFonts;
begin
  DeleteObject(FFontObjHeight18);
  DeleteObject(FFontObjHeight20);
  DeleteObject(FFontObjHeight22);
  DeleteObject(FFontObjHeight24);
end;

procedure TGdiMgrImpl.DoClearBrushs;
begin
  DeleteObject(FBrushObjFormBorder);
  DeleteObject(FBrushObjMasterBorder);
  DeleteObject(FBrushObjMasterChildBorder);
  DeleteObject(FBrushObjLoadProcessBorder);
end;

procedure TGdiMgrImpl.DoClearResources;
begin
  if FImgAppLogo <> nil then begin
    FImgAppLogo.Free;
  end;
  if FImgAppLogoS <> nil then begin
    FImgAppLogoS.Free;
  end;
  if FImgAppClose <> nil then begin
    FImgAppClose.Free;
  end;
  if FImgAppRestore <> nil then begin
    FImgAppRestore.Free;
  end;
  if FImgAppMaximize <> nil then begin
    FImgAppMaximize.Free;
  end;
  if FImgAppMinimize <> nil then begin
    FImgAppMinimize.Free;
  end;
end;

function TGdiMgrImpl.GetImgAppLogo: TResourceStream;
begin
  Result := FImgAppLogo;
end;

function TGdiMgrImpl.GetImgAppLogoS: TResourceStream;
begin
  Result := FImgAppLogoS;
end;

function TGdiMgrImpl.GetImgAppClose: TResourceStream;
begin
  Result := FImgAppClose;
end;

function TGdiMgrImpl.GetImgAppRestore: TResourceStream;
begin
  Result := FImgAppRestore;
end;

function TGdiMgrImpl.GetImgAppMaximize: TResourceStream;
begin
  Result := FImgAppMaximize;
end;

function TGdiMgrImpl.GetImgAppMinimize: TResourceStream;
begin
  Result := FImgAppMinimize;
end;

function TGdiMgrImpl.GetFontObjHeight18: HFONT;
begin
  Result := FFontObjHeight18;
end;

function TGdiMgrImpl.GetFontObjHeight20: HFONT;
begin
  Result := FFontObjHeight20;
end;

function TGdiMgrImpl.GetFontObjHeight22: HFONT;
begin
  Result := FFontObjHeight22;
end;

function TGdiMgrImpl.GetFontObjHeight24: HFONT;
begin
  Result := FFontObjHeight24;
end;

function TGdiMgrImpl.GetBrushObjFormBorder: HGDIOBJ;
begin
  Result := FBrushObjFormBorder;
end;

function TGdiMgrImpl.GetBrushObjMasterBorder: HGDIOBJ;
begin
  Result := FBrushObjMasterBorder;
end;

function TGdiMgrImpl.GetBrushObjMasterChildBorder: HGDIOBJ;
begin
  Result := FBrushObjMasterChildBorder;
end;

function TGdiMgrImpl.GetBrushObjLoadProcessBorder: HGDIOBJ;
begin
  Result := FBrushObjLoadProcessBorder;
end;

function TGdiMgrImpl.GetColorRefFormBack: COLORREF;
begin
   Result := FColorRefFormBack;
end;

function TGdiMgrImpl.GetColorRefFormBorder: COLORREF;
begin
  Result := FColorRefFormBorder;
end;

function TGdiMgrImpl.GetColorRefFormCaptionText: COLORREF;
begin
  Result := FColorRefFormCaptionText;
end;

function TGdiMgrImpl.GetColorRefFormCaptionBack: COLORREF;
begin
  Result := FColorRefFormCaptionBack;
end;

function TGdiMgrImpl.GetColorRefHqRed: COLORREF;
begin
  Result := FColorRefHqRed;
end;

function TGdiMgrImpl.GetColorRefHqGreen: COLORREF;
begin
  Result := FColorRefHqGreen;
end;

function TGdiMgrImpl.GetColorRefHqTurnover: COLORREF;
begin
  Result := FColorRefHqTurnover;
end;

function TGdiMgrImpl.GetColorRefMasterBack: COLORREF;
begin
  Result := FColorRefMasterBack;
end;

function TGdiMgrImpl.GetColorRefMasterBorder: COLORREF;
begin
  Result := FColorRefMasterBorder;
end;

function TGdiMgrImpl.GetColorRefMasterCaptionText: COLORREF;
begin
  Result := FColorRefMasterCaptionText;
end;

function TGdiMgrImpl.GetColorRefMasterCaptionBack: COLORREF;
begin
  Result := FColorRefMasterCaptionBack;
end;

function TGdiMgrImpl.GetColorRefMasterSuperTabBack: COLORREF;
begin
  Result := FColorRefMasterSuperTabBack;
end;

function TGdiMgrImpl.GetColorRefMasterStatusBarBack: COLORREF;
begin
  Result := FColorRefMasterStatusBarBack;
end;

function TGdiMgrImpl.GetColorRefMasterStatusBarText: COLORREF;
begin
  Result := FColorRefMasterStatusBarText;
end;

function TGdiMgrImpl.GetColorRefMasterChildBack: COLORREF;
begin
  Result := FColorRefMasterChildBack;
end;

function TGdiMgrImpl.GetColorRefMasterChildBorder: COLORREF;
begin
  Result := FColorRefMasterChildBorder;
end;

function TGdiMgrImpl.GetColorRefMasterChildCaptionText: COLORREF;
begin
  Result := FColorRefMasterChildCaptionText;
end;

function TGdiMgrImpl.GetColorRefMasterChildCaptionBack: COLORREF;
begin
  Result := FColorRefMasterChildCaptionBack;
end;

function TGdiMgrImpl.GetColorRefLoadProcessBack: COLORREF;
begin
  Result := FColorRefLoadProcessBack;
end;

function TGdiMgrImpl.GetColorRefLoadProcessBorder: COLORREF;
begin
  Result := FColorRefLoadProcessBorder;
end;

function TGdiMgrImpl.GetColorRefLoadProcessCaptionText: COLORREF;
begin
  Result := FColorRefLoadProcessCaptionText;
end;

function TGdiMgrImpl.GetColorRefLoadProcessCaptionBack: COLORREF;
begin
  Result := FColorRefLoadProcessCaptionBack;
end;

function TGdiMgrImpl.GetColorRefButtonBack: COLORREF;
begin
  Result := FColorRefButtonBack;
end;

function TGdiMgrImpl.GetColorRefButtonBorder: COLORREF;
begin
  Result := FColorRefButtonBorder;
end;

function TGdiMgrImpl.GetColorRefButtonText: COLORREF;
begin
  Result := FColorRefButtonText;
end;

function TGdiMgrImpl.GetColorRefButtonHotBack: COLORREF;
begin
  Result := FColorRefButtonHotBack;
end;

function TGdiMgrImpl.GetColorRefButtonHotBorder: COLORREF;
begin
  Result := FColorRefButtonHotBorder;
end;

function TGdiMgrImpl.GetColorRefButtonHotText: COLORREF;
begin
  Result := FColorRefButtonHotText;
end;

function TGdiMgrImpl.GetColorRefButtonDownBack: COLORREF;
begin
  Result := FColorRefButtonDownBack;
end;

function TGdiMgrImpl.GetColorRefButtonDownBorder: COLORREF;
begin
  Result := FColorRefButtonDownBorder;
end;

function TGdiMgrImpl.GetColorRefButtonDownText: COLORREF;
begin
  Result := FColorRefButtonDownText;
end;

function TGdiMgrImpl.GetColorRefButtonDisableBack: COLORREF;
begin
  Result := FColorRefButtonDisableBack;
end;

function TGdiMgrImpl.GetColorRefButtonDisableBorder: COLORREF;
begin
  Result := FColorRefButtonDisableBorder;
end;

function TGdiMgrImpl.GetColorRefButtonDisableText: COLORREF;
begin
  Result := FColorRefButtonDisableText;
end;

end.
