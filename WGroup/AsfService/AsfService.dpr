library AsfService;

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
  WaitMode in 'WaitMode\WaitMode.pas',
  Proxy in 'Proxy\Proxy.pas',
  GFDataParser in 'GFData\GFDataParser.pas',
  GFDataImpl in 'GFData\Impl\GFDataImpl.pas',
  HttpContext in 'HttpContext\HttpContext.pas',
  HttpContextPool in 'HttpContext\HttpContextPool.pas',
  Executors in 'Executor\Executors.pas',
  HttpExecutor in 'Executor\HttpExecutor.pas',
  HttpExecutorImpl in 'Executor\Impl\HttpExecutorImpl.pas',
  ExecutorThreadHttp in 'Executor\ExecutorThreadHttp.pas',
  Channel in 'Channel\Channel.pas',
  PostChannel in 'Channel\PostChannel.pas',
  JsonChannel in 'Channel\JsonChannel.pas',
  EDCryptChannel in 'Channel\EDCryptChannel.pas',
  CompressChannel in 'Channel\CompressChannel.pas',
  ChannelPipeLine in 'ChannelPipeLine\ChannelPipeLine.pas',
  JsonChannelPipeLine in 'ChannelPipeLine\JsonChannelPipeLine.pas',
  ShareMgr in 'ShareMgr\ShareMgr.pas',
  ShareMgrImpl in 'ShareMgr\Impl\ShareMgrImpl.pas',
  BasicServiceImpl in 'BasicService\Impl\BasicServiceImpl.pas',
  AssetServiceImpl in 'AssetService\Impl\AssetServiceImpl.pas',
  AbstractServiceImpl in 'AbstractService\Impl\AbstractServiceImpl.pas',
  AsfServicePlugInMgrImpl in 'WExport\Impl\AsfServicePlugInMgrImpl.pas',
  BasicServiceCommandImpl in 'WCommands\BasicServiceCommandImpl.pas',
  AssetServiceCommandImpl in 'WCommands\AssetServiceCommandImpl.pas';

{$R *.res}

begin
end.
