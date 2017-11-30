unit Sector;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-8-23
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // ���ӿ�
  ISector = Interface(IInterface)
    ['{1CD531FC-3B3F-49BC-B5D3-CD0AE1F59F71}']
    // ��ȡ��� ID
    function GetSectorID: WideString; safecall;
    // ��ȡ��������
    function GetSectorName: WideString; safecall;
    // ��ȡ�Ӱ��ɷ����ַ�������
    function GetChildSectors: WideString; safecall;
    // ��ȡ�ǲ��Ǵ����Ӱ��
    function GetChildSectorExist: boolean; safecall;
    // ��ȡ�Ӱ�����
    function GetChildSectorCount: Integer; safecall;
    // ��ȡ�Ӱ��ӿ�ͨ���±�
    function GetChildSector(AIndex: Integer): ISector; safecall;
    // ��ȡ�Ӱ���ǲ��Ǵ���
    function GetExistChildSectorName(AName: WideString): boolean; safecall;
    // �����Ӱ��
    function AddChildSectorByName(AName: WideString): ISector; safecall;
    // ���ð�� ID
    procedure SetSectorID(AID: WideString); safecall;
    // ���ð������
    procedure SetSectorName(AName: WideString); safecall;
    // ɾ���Ӱ��
    procedure DelChildSector(ASector: ISector); safecall;
    // ɾ���Ӱ��ͨ���������
    procedure DelChildSectorByName(AName: WideString); safecall;
  end;

implementation

end.
