unit UserSectorMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� User Sector Manager Interface
// Author��      lksoulman
// Date��        2017-8-23
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Sector,
  Windows,
  Classes,
  SysUtils;

type

  // User Sector Manager Interface
  IUserSectorMgr = Interface(IInterface)
    ['{339180B9-E14F-4254-B7F1-FAE221385F3D}']
    // ������
    procedure BeginRead; safecall;
    // ������
    procedure EndRead; safecall;
    // д����
    procedure BeginWrite; safecall;
    // д����
    procedure EndWrite; safecall;
    // ��ȡ�������
    function GetRootSector: ISector; safecall;
  end;

implementation

end.
