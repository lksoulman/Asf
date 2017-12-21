library AsfUI;

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
  AsfUIPlugInMgrImpl in 'WExport\Impl\AsfUIPlugInMgrImpl.pas',
  SimpleHqTestImpl in 'SimpleHqTest\Impl\SimpleHqTestImpl.pas',
  SimpleHqTestCommandImpl in 'WCommands\SimpleHqTestCommandImpl.pas',
  QuoteTime in 'AQuote\Time\QuoteTime.pas',
  QuoteTimeButton in 'AQuote\Time\QuoteTimeButton.pas',
  QuoteTimeCross in 'AQuote\Time\QuoteTimeCross.pas',
  QuoteTimeCrossDetail in 'AQuote\Time\QuoteTimeCrossDetail.pas',
  QuoteTimeData in 'AQuote\Time\QuoteTimeData.pas',
  QuoteTimeDisplay in 'AQuote\Time\QuoteTimeDisplay.pas',
  QuoteTimeGraph in 'AQuote\Time\QuoteTimeGraph.pas',
  QuoteTimeHandle in 'AQuote\Time\QuoteTimeHandle.pas',
  QuoteTimeHint in 'AQuote\Time\QuoteTimeHint.pas',
  QuoteTimeHistory in 'AQuote\Time\QuoteTimeHistory.pas',
  QuoteTimeIcon in 'AQuote\Time\QuoteTimeIcon.pas',
  QuoteTimeMenu in 'AQuote\Time\QuoteTimeMenu.pas',
  QuoteTimeMenuIntf in 'AQuote\Time\QuoteTimeMenuIntf.pas',
  QuoteTimeMinute in 'AQuote\Time\QuoteTimeMinute.pas',
  QuoteTimeMovePt in 'AQuote\Time\QuoteTimeMovePt.pas',
  QuoteTimeSQL in 'AQuote\Time\QuoteTimeSQL.pas',
  QuoteTimeStruct in 'AQuote\Time\QuoteTimeStruct.pas',
  QuoteTimeTradeDetail in 'AQuote\Time\QuoteTimeTradeDetail.pas',
  QuoteTimeVolume in 'AQuote\Time\QuoteTimeVolume.pas',
  BaseForm in 'AQuote\Common\BaseForm.pas',
  CommonFunc in 'AQuote\Common\CommonFunc.pas',
  QuotaCommScrollBar in 'AQuote\Common\QuotaCommScrollBar.pas',
  QuoteCommConst in 'AQuote\Common\QuoteCommConst.pas',
  QuoteCommHint in 'AQuote\Common\QuoteCommHint.pas',
  QuoteCommLibrary in 'AQuote\Common\QuoteCommLibrary.pas',
  QuoteCommMenu in 'AQuote\Common\QuoteCommMenu.pas',
  QuoteCommMine in 'AQuote\Common\QuoteCommMine.pas',
  QuoteCommStack in 'AQuote\Common\QuoteCommStack.pas',
  SelfRightMenuComm in 'AQuote\Common\SelfRightMenuComm.pas';

{$R *.res}

begin
end.
