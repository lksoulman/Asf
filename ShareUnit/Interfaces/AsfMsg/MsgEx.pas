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

  Msg_AsfUI_ReLoadInfo                          = 101001;     // ������Ϣ

  { AsfMsg.dll (102000, 102999] }



  { AsfMem.dll (103000, 103999] }

  Msg_AsfMem_ReUpdateSecuMain                   = 103001;      // ֤ȯ���� SECUMAIN �ڴ����
  Msg_AsfMem_ReUpdateSectorMgr                  = 103002;      // ��������ڴ����
  Msg_AsfMem_ReUpdateAttentionMgr               = 103003;      // �û���ע������
  Msg_AsfMem_ReUpdateUserSectorMgr              = 103004;      // �û������ڴ����
  Msg_AsfMem_ReUpdateUserAttentionMgr           = 103005;      // �û���ע�ڴ����
  Msg_AsfMem_ReUpdateUserPositionCategroyMgr    = 103006;      // �û��ֲַ����ڴ����


  { AsfAuth.dll (104000, 104999] }

//  Msg_AsfAuth_

  { AsfCache.dll (105000, 105999] }

  Msg_AsfCache_ReUpdateBaseCache_SecuMain       = 105004;      // ����CACHE֤ȯ���� SECUMAIN ����
  Msg_AsfCache_ReUpdateUserCache_UserSector     = 105101;      // �û�CACHE���� UserSector ����

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
    property Info: string read GetInfo;
    property CreateTime: TDateTime read GetCreateTime;
  end;

implementation

end.
