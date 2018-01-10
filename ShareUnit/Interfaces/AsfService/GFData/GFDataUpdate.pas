unit GFDataUpdate;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Finance Data Update Interface
// Author£º      lksoulman
// Date£º        2017-9-11
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  GFData,
  Windows,
  Classes,
  SysUtils;

type

  // Finance Data Update Interface
  IGFDataUpdate = Interface(IInterface)
    ['{503963C3-63F2-4307-9126-903E2F1D6285}']
    // GetIsCanceled
    function GetIsCancel: Boolean; safecall;
    // GetErrorCode
    function GetErrorCode: Integer; safecall;
    // GetDataEvent
    function GetDataEvent: TGFDataEvent; safecall;
    // SetKey
    function SetKey(AKey: Int64): Boolean; safecall;
    // SetDataEvent
    function SetDataEvent(AEvent: TGFDataEvent): Boolean; safecall;
    // SetCancel
    function SetCancel(ACancel: Boolean = True): Boolean; safecall;
    // SetErrorCode
    function SetErrorCode(AErrorCode: Integer): Boolean; safecall;
    // SetErrorInfo
    function SetErrorInfo(AErrorInfo: WideString): Boolean; safecall;
    // SetResponseStream
    function SetResponseStream(AResponseStream: TStream): Boolean; safecall;
    // SetRequestSize
    function SetRequestSize(ASize: Cardinal): Boolean; safecall;
    // SetRequestCompressSize
    function SetRequestCompressSize(ASize: Cardinal): Boolean; safecall;
    // SetResponseSize
    function SetResponseSize(ASize: Cardinal): Boolean; safecall;
    // SetResponseCompress Size
    function SetResponseCompressSize(ASize: Cardinal): Boolean; safecall;
    // SetQueueWaitUseTime
    function SetQueueWaitUseTime(AUseTime: Cardinal): Boolean; safecall;
    // SetExecutePostUseTime
    function SetExecutePostUseTime(AUseTime: Cardinal): Boolean; safecall;
    // SetRequestCompressUseTime
    function SetRequestCompressUseTime(AUseTime: Cardinal): Boolean; safecall;
    // SetResponseUncompressUseTime
    function SetResponseUncompressUseTime(AUseTime: Cardinal): Boolean; safecall;
  end;

implementation

end.
