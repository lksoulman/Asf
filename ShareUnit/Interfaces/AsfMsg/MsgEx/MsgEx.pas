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

  { SysMsg  }

  { AsfMain.exe (100000, 10999] }

  Msg_AsfMain_ReUpdateSkinStyle                 = 100001;     // ����Ƥ����ʽ
  Msg_AsfMain_ReUpdateLanguage                  = 100002;     // �������԰�

  { AsfUI.dll (101000, 11999] }

//  Msg_AsfUI_

  { AsfMsg.dll (102000, 102999] }

//  Msg_AsfMsg_

  { AsfMem.dll (103000, 103999] }

  Msg_AsfMem_ReUpdateSecuMain                   = 103001;      // ֤ȯ���� SECUMAIN �ڴ����

  { AsfAuth.dll (104000, 104999] }

//  Msg_AsfAuth_

  { AsfCache.dll (105000, 105999] }

  Msg_AsfCache_ReUpdateBaseCache_SecuMain       = 105004;      // ����CACHE֤ȯ���� SECUMAIN ����

  { AsfService.dll (106000, 106999] }

//  Msg_AsfService_

  { AsfHqService.dll (107000, 107999] }

  Msg_AsfHqService_ReConnectServer              = 107001;     // �������������Ϣ
  Msg_AsfHqService_ReSubcribeHq                 = 107002;     // ���鶩�����ݸ�����Ҫ���¶���

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
