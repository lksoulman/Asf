unit WExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Export
// Author£º      lksoulman
// Date£º        2017-11-14
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
  AsfMainPlugInMgrImpl;

var
  G_PlugInMgr: IPlugInMgr;

  function GetPlugInMgr(AMainApplication: TApplication; AContext: IAppContext): IPlugInMgr;
  begin
    Application := AMainApplication;
    if G_PlugInMgr = nil then begin
      G_PlugInMgr := TAsfMainPlugInMgrImpl.Create(AContext) as IPlugInMgr;
    end;
    Result := G_PlugInMgr;
  end;

end.
