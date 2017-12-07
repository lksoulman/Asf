unit SysSectorMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description：
// Author：      lksoulman
// Date：        2017-8-23
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Sector,
  Windows,
  Classes,
  SysUtils;

type

  // 用户板块管理接口
  ISysSectorMgr = Interface(IInterface)
    ['{339180B9-E14F-4254-B7F1-FAE221385F3D}']
    // 获取根结点板块
    function GetRootSector: ISector; safecall;
  end;

implementation

end.
