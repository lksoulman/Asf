unit PositionCategory;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� PositionCategory
// Author��      lksoulman
// Date��        2018-1-22
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  BaseObject;

const

  POSITIONCATEGORY_STOCK              = 1;  // ��Ʊ
  POSITIONCATEGORY_BOND               = 2;  // ծȯ
  POSITIONCATEGORY_FUND_INNER         = 3;  // ���ڻ���
  POSITIONCATEGORY_FUND_OUTER         = 4;  // �������
  POSITIONCATEGORY_FUTURES            = 5;  // �ڻ�
  POSITIONCATEGORY_OPTION             = 6;  // ��Ȩ

  POSITIONCATEGORY_NAME_STOCK         = '��Ʊ';
  POSITIONCATEGORY_NAME_BOND          = 'ծȯ';
  POSITIONCATEGORY_NAME_FUND_INNER    = '���ڻ���';
  POSITIONCATEGORY_NAME_FUND_OUTER    = '�������';
  POSITIONCATEGORY_NAME_FUTURES       = '�ڻ�';
  POSITIONCATEGORY_NAME_OPTION        = '��Ȩ';

type

  // PositionCategory
  TPositionCategory = class(TBaseObject)
  private
  protected
  public
    // GetId
    function GetId: Integer; virtual; abstract;
    // GetName
    function GetName: string; virtual; abstract;

    property Id: Integer read GetId;
    property Name: string read GetName;
  end;

implementation

end.
