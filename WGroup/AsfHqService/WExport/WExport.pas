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

  function GetPlugInMgr(AMainApplication: TApplication; AContext: IAppContext): IPlugInMgr;
  begin
    Application := AMainApplication;
    Result := TAsfHqServicePlugInMgrImpl.Create(AContext) as IPlugInMgr;
  end;

var
  LOldAppication: TApplication;

initialization

  LOldAppication := Application;

finalization

  Application := LOldAppication;

end.
