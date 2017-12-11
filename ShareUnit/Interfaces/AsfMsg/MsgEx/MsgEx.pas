unit MsgEx;

////////////////////////////////////////////////////////////////////////////////
//
// Description： MsgEx
// Author：      lksoulman
// Date：        2017-12-08
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  CommonRefCounter;

const

  MSG_HQSERVICE_CONNECT                 = 1001;         // 行情服务连接消息
  MSG_HQSERVICE_RESUBCRIBE              = 1002;         // 行情订阅数据更新需要重新订阅
  MSG_SECUMAIN_MEMORY_UPDATE            = 1003;         // 证券主表 SECUMAIN 内存更新
  MSG_BASECACHE_TABLE_SECUMAIN_UPDATE   = 1004;         // 基础CACHE证券主表 SECUMAIN 更新


type

  // MsgEx
  TMsgEx = class(TAutoObject)
  private
  protected
  public
    // GetId
    function GetId: Integer; virtual; abstract;
    // GetInfo
    function GetInfo: string; virtual; abstract;
    // GetCreateTime
    function GetCreateTime: TDateTime; virtual; abstract;

    property Id: Integer read GetId;
    property CreateTime: TDateTime read GetCreateTime;
  end;

implementation

end.
