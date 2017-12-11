unit WExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Export
// Author��      lksoulman
// Date��        2017-12-08
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
  AsfMsgPlugInMgrImpl;

  function GetPlugInMgr(AMainApplication: TApplication; AContext: IAppContext): IPlugInMgr;
  begin
    Application := AMainApplication;
    Result := TAsfMsgPlugInMgrImpl.Create(AContext) as IPlugInMgr;
  end;

var
  LOldAppication: TApplication;

initialization

  LOldAppication := Application;

finalization

  Application := LOldAppication;

end.
