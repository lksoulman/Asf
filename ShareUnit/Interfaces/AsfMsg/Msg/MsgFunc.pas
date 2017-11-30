unit MsgFunc;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Message Function Definition
// Author��      lksoulman
// Date��        2017-7-29
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx;

type

  // ����
  TMsgFuncOperate = procedure of Object;

  // �����¼�
  TMsgFuncCreate = function: TObject of Object;

  // ��Ϣ�ص���������
  TMsgFuncCallBack = procedure (AMsgEx: TMsgEx; var ALogTag: string) of Object;

implementation

end.
