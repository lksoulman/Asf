unit CompanyInfoImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� CompanyInfo Implementation
// Author��      lksoulman
// Date��        2017-7-20
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles,
  AppContext,
  CompanyInfo,
  AppContextObject,
  CommonRefCounter;

type

  // CompanyInfo Implementation
  TCompanyInfoImpl = class(TAppContextObject, ICompanyInfo)
  private
    // CompanyInfo
    FCompanyInfo: TCompanyInfo;
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ICompanyInfo }

    // ReadSysCfg
    procedure ReadSysCfg(AFile: TIniFile);
    // Get Company Info
    function GetCompanyInfo: PCompanyInfo;
  end;

implementation

{ TCompanyInfoImpl }

constructor TCompanyInfoImpl.Create(AContext: IAppContext);
begin
  inherited;
  FCompanyInfo.FEmail := 'service@gildata.com';
  FCompanyInfo.FPhone := '400-820-7887';
  FCompanyInfo.FWebsite := 'http://www.gildata.com';
  FCompanyInfo.FCopyright := '';
end;

destructor TCompanyInfoImpl.Destroy;
begin

  inherited;
end;

procedure TCompanyInfoImpl.ReadSysCfg(AFile: TIniFile);
begin
  if AFile = nil then Exit;

  FCompanyInfo.FEmail := AFile.ReadString('CompanyInfo', 'Email', FCompanyInfo.FEmail);
  FCompanyInfo.FPhone := AFile.ReadString('CompanyInfo', 'Phone', FCompanyInfo.FPhone);
  FCompanyInfo.FWebsite := AFile.ReadString('CompanyInfo', 'Website', FCompanyInfo.FWebsite);
  FCompanyInfo.FCopyright := AFile.ReadString('CompanyInfo', 'Copyright', FCompanyInfo.FCopyright);
end;

function TCompanyInfoImpl.GetCompanyInfo: PCompanyInfo;
begin
  Result := @FCompanyInfo;
end;

end.
