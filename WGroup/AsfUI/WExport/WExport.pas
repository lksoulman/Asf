unit WExport;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Export
// Author��      lksoulman
// Date��        2017-11-15
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
  AsfUIPlugInMgrImpl;

  function GetPlugInMgr(AMainApplication: TApplication; AContext: IAppContext): IPlugInMgr;
  begin
    // �ͷŴ��ڱ���
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
