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

end.
