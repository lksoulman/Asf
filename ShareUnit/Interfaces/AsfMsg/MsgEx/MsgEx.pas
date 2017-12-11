unit MsgEx;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� MsgEx
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
  CommonRefCounter;

const

  MSG_HQSERVICE_CONNECT                 = 1001;         // �������������Ϣ
  MSG_HQSERVICE_RESUBCRIBE              = 1002;         // ���鶩�����ݸ�����Ҫ���¶���
  MSG_SECUMAIN_MEMORY_UPDATE            = 1003;         // ֤ȯ���� SECUMAIN �ڴ����
  MSG_BASECACHE_TABLE_SECUMAIN_UPDATE   = 1004;         // ����CACHE֤ȯ���� SECUMAIN ����


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
