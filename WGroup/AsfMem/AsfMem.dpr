library AsfMem;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  System.SysUtils,
  System.Classes,
  WExport in 'WExport\WExport.pas',
  AsfMemPlugInMgrImpl in 'WExport\Impl\AsfMemPlugInMgrImpl.pas',
  SecuMainImpl in 'WCMemTable\SecuMain\Impl\SecuMainImpl.pas',
  SecuMainCommandImpl in 'WCommands\SecuMainCommandImpl.pas',
  KeySearchFilter in 'KeySearchEngine\KeySearchFilter.pas',
  KeySearchEngineImpl in 'KeySearchEngine\Impl\KeySearchEngineImpl.pas',
  KeySearchEngineCommandImpl in 'WCommands\KeySearchEngineCommandImpl.pas',
  UserSector in 'UserSectorMgr\UserSector.pas',
  UserSectorImpl in 'UserSectorMgr\UserSectorImpl.pas',
  UserSectorUpdate in 'UserSectorMgr\UserSectorUpdate.pas',
  UserSectorMgrImpl in 'UserSectorMgr\Impl\UserSectorMgrImpl.pas',
  UserSectorMgrCommandImpl in 'WCommands\UserSectorMgrCommandImpl.pas',
  Sector in 'SectorMgr\Sector.pas',
  SectorImpl in 'SectorMgr\SectorImpl.pas',
  SectorUpdate in 'SectorMgr\SectorUpdate.pas',
  SectorMgr in 'SectorMgr\SectorMgr.pas',
  SectorMgrImpl in 'SectorMgr\Impl\SectorMgrImpl.pas';

{$R *.res}

begin
end.
