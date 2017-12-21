unit WExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Export
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
  Vcl.Forms,
  PlugInMgr,
  AppContext;

  // GetPlugInMgr
  function GetPlugInMgr(AMainApplication: TApplication; AContext: IAppContext): IPlugInMgr; stdcall;

exports

  GetPlugInMgr            name 'GetPlugInMgr';

implementation

uses
  AsfUIPlugInMgrImpl;

  function GetPlugInMgr(AMainApplication: TApplication; AContext: IAppContext): IPlugInMgr;
  begin
    // ÊÍ·Å´°¿Ú±¨´í
//    Application := AMainApplication;
    Result := TAsfUIPlugInMgrImpl.Create(AContext) as IPlugInMgr;
  end;

var
  LOldAppication: TApplication;

initialization

  LOldAppication := Application;

finalization

  Application := LOldAppication;

end.
