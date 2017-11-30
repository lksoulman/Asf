library AsfCache;

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
  AsfCachePlugInMgrImpl in 'WExport\Impl\AsfCachePlugInMgrImpl.pas',
  CacheGF in 'AbstractCache\CacheGF.pas',
  CacheTable in 'AbstractCache\CacheTable.pas',
  CacheOperateType in 'AbstractCache\CacheOperateType.pas',
  SQLiteAdapter in 'AbstractCache\SQLite\SQLiteAdapter.pas',
  SQLiteDataSet in 'AbstractCache\SQLite\SQLiteDataSet.pas',
  AbstractCacheImpl in 'AbstractCache\Impl\AbstractCacheImpl.pas',
  BaseCacheImpl in 'BaseCache\Impl\BaseCacheImpl.pas',
  UserCacheImpl in 'UserCache\Impl\UserCacheImpl.pas',
  UserAssetCacheImpl in 'UserAssetCache\Impl\UserAssetCacheImpl.pas',
  BaseCacheCommandImpl in 'WCommands\BaseCacheCommandImpl.pas',
  UserCacheCommandImpl in 'WCommands\UserCacheCommandImpl.pas';

{$R *.res}

begin
end.
