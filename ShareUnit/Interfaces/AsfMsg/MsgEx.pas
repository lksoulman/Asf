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

  { SysMsg  }

  { AsfMain.exe (100000, 10999] }

  Msg_AsfMain_ReUpdateSkinStyle                 = 100001;     // 更新皮肤样式
  Msg_AsfMain_ReUpdateLanguage                  = 100002;     // 更新语言包

  { AsfUI.dll (101000, 11999] }

  Msg_AsfUI_ReLoadInfo                          = 101001;     // 加载信息

  { AsfMsg.dll (102000, 102999] }



  { AsfMem.dll (103000, 103999] }

  Msg_AsfMem_ReUpdateSecuMain                   = 103001;      // 证券主表 SECUMAIN 内存更新
  Msg_AsfMem_ReUpdateSectorMgr                  = 103002;      // 板块数据内存更新
  Msg_AsfMem_ReUpdateAttentionMgr               = 103003;      // 用户关注板块更新
  Msg_AsfMem_ReUpdateUserSectorMgr              = 103004;      // 用户板块表内存更新
  Msg_AsfMem_ReUpdateUserAttentionMgr           = 103005;      // 用户关注内存更新
  Msg_AsfMem_ReUpdateUserPositionCategroyMgr    = 103006;      // 用户持仓分类内存更新


  { AsfAuth.dll (104000, 104999] }

//  Msg_AsfAuth_

  { AsfCache.dll (105000, 105999] }

  Msg_AsfCache_ReUpdateBaseCache_SecuMain       = 105004;      // 基础CACHE证券主表 SECUMAIN 更新
  Msg_AsfCache_ReUpdateUserCache_UserSector     = 105101;      // 用户CACHE板块表 UserSector 更新

  { AsfService.dll (106000, 106999] }

//  Msg_AsfService_

  { AsfHqService.dll (107000, 107999] }

  Msg_AsfHqService_ReConnectServer              = 107001;     // 行情服务连接消息
  Msg_AsfHqService_ReSubcribeHq                 = 107002;     // 行情订阅数据更新需要重新订阅

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
