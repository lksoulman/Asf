unit WExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Export
// Author��      lksoulman
// Date��        2017-12-05
// Comments��
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
  AsfHqServicePlugInMgrImpl;

var
  G_PlugInMgr: IPlugInMgr;

  function GetPlugInMgr(AMainApplication: TApplication; AContext: IAppContext): IPlugInMgr;
  begin
    Application := AMainApplication;
    if G_PlugInMgr = nil then begin
      G_PlugInMgr := TAsfHqServicePlugInMgrImpl.Create(AContext) as IPlugInMgr;
    end;
    Result := G_PlugInMgr;
  end;

end.
