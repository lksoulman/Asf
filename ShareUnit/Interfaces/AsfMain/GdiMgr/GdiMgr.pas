unit GdiMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º GdiMgr Interface
// Author£º      lksoulman
// Date£º        2017-11-15
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // GdiMgr Interface
  IGdiMgr = interface(IInterface)
    ['{964FAA9D-E345-4B2A-8FCB-90E0FA833902}']
    // Get Img App Logo
    function GetImgAppLogo: TResourceStream;
    // Get Img App Logo Small
    function GetImgAppLogoS: TResourceStream;
    // Get Img App Close
    function GetImgAppClose: TResourceStream;
    // Get Img App Restore
    function GetImgAppRestore: TResourceStream;
    // Get Img App Maximize
    function GetImgAppMaximize: TResourceStream;
    // Get Img App Minimize
    function GetImgAppMinimize: TResourceStream;
    // Get Font Obj Height 18
    function GetFontObjHeight18: HFONT;
    // Get Font Obj Height 20
    function GetFontObjHeight20: HFONT;
    // Get Font Obj Height 22
    function GetFontObjHeight22: HFONT;
    // Get Font Obj Height 24
    function GetFontObjHeight24: HFONT;
    // Get Form Border
    function GetBrushObjFormBorder: HGDIOBJ;
    // Get Master Border
    function GetBrushObjMasterBorder: HGDIOBJ;
    // Get Master Child Border
    function GetBrushObjMasterChildBorder: HGDIOBJ;
    // Get Load Process Border
    function GetBrushObjLoadProcessBorder: HGDIOBJ;
    // Get Hq Red
    function GetColorRefHqRed: COLORREF;
    // Get Hq Green
    function GetColorRefHqGreen: COLORREF;
    // Get Hq Turnover
    function GetColorRefHqTurnover: COLORREF;
    // Get Form Back
    function GetColorRefFormBack: COLORREF;
    // Get Form Border
    function GetColorRefFormBorder: COLORREF;
    // Get Form Caption Text
    function GetColorRefFormCaptionText: COLORREF;
    // Get Form Caption Back
    function GetColorRefFormCaptionBack: COLORREF;
    // Get Master Back
    function GetColorRefMasterBack: COLORREF;
    // Get Master Border
    function GetColorRefMasterBorder: COLORREF;
    // Get Master Caption Text
    function GetColorRefMasterCaptionText: COLORREF;
    // Get Master Caption Back
    function GetColorRefMasterCaptionBack: COLORREF;
    // Get Master Caption Super Tab Back
    function GetColorRefMasterSuperTabBack: COLORREF;
    // Get Master StatusBar Back
    function GetColorRefMasterStatusBarBack: COLORREF;
    // Get Master StatusBar Text
    function GetColorRefMasterStatusBarText: COLORREF;
    // Get Master Child Back
    function GetColorRefMasterChildBack: COLORREF;
    // Get Master Child Border
    function GetColorRefMasterChildBorder: COLORREF;
    // Get Master Child Caption Text
    function GetColorRefMasterChildCaptionText: COLORREF;
    // Get Master Child Caption Back
    function GetColorRefMasterChildCaptionBack: COLORREF;
    // Get LoadProcess Back
    function GetColorRefLoadProcessBack: COLORREF;
    // Get LoadProcess Border
    function GetColorRefLoadProcessBorder: COLORREF;
    // Get LoadProcess Caption Text
    function GetColorRefLoadProcessCaptionText: COLORREF;
    // Get LoadProcess Caption Back
    function GetColorRefLoadProcessCaptionBack: COLORREF;
  end;

implementation

end.
