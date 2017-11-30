unit CommonRefCounter;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-4-11
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Types,
  Windows,
  Classes,
  SysUtils,
  Variants,
  SyncObjs;

type

  // �Զ������������
  TAutoObject = class
  private
  protected
  public
    // Constructor
    constructor Create; virtual;
    // Destructor
    destructor Destroy; override;
  end;

  // �Զ������ӿ�ʵ�ֻ���(�ӿ��Զ������Զ��ͷ�)
  TAutoInterfacedObject = class(TInterfacedObject)
  private
  protected
  public
    // Constructor
    constructor Create; virtual;
    // Destructor
    destructor Destroy; override;
  end;

  // �Զ������ӿ�ʵ�ֻ���(�ӿ��ֶ������ֶ��ͷ�)
  TAutoUserInterfacedObject = class(TAutoObject, IInterface)
  private
  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
  end;

  // �����ڴ����(�������ڴ�ָ��;��������)
  // �紴������ʱָ���ڴ�ָ�룬��ɾ������ʱҲ���봫���ڴ�ָ�����
  procedure IncMem(pPointer:Pointer = nil;strDesc:string = '');
  // ɾ���ڴ����(�������ڴ�ָ��)
  procedure DecMem(pPointer:Pointer = nil);

  // �����ڴ�������ܵķ����ڴ淽��
  procedure GetMemEx(var P: Pointer; Size: Integer);
  // �����ڴ�������ܵ��ͷ��ڴ淽��
  procedure FreeMemEx(var P: Pointer); overload;

implementation

var
  {$IFDEF DEBUG}
  g_nObjCounter: Integer;        //����ʵ������
  {$ENDIF}
  g_lstObjects:TStringList;     //�����ֵ���б�(ָ��-����)
  g_Mutex:TMutex;                //������

{$REGION '�Զ������������'}

//���캯��
constructor TAutoObject.Create;
{$IFDEF DEBUG}
var
  strObjAddr:string;
  strClassName:string;
  szObjName:PChar;
  {$ENDIF}
begin
  {$IFDEF DEBUG}
  g_Mutex.Acquire;
  //��ָ���������ֵ�Լ��뵽�б���
  strObjAddr := IntToStr(Integer(self));
  strClassName := self.ClassName;
  GetMem(szObjName, 60 * sizeof(Char));
  ZeroMemory(szObjName, 60 * sizeof(Char));
  if Length(strClassName) < 60 then
  begin
    lstrcpy(szObjName, PWideChar(strClassName));
  end;
  g_lstObjects.AddObject(strObjAddr, TObject(szObjName));
  //�������������һ
  InterlockedIncrement(g_nObjCounter);
  g_Mutex.Release;
  {$ENDIF}
end;

//��������
destructor TAutoObject.Destroy;
{$IFDEF DEBUG}
var
  strObjAddr:string;
  szObjName:PChar;
  nIndex:Integer;
{$ENDIF}
begin
  {$IFDEF DEBUG}
  g_Mutex.Acquire;
  //����Ӧָ���������ֵ�Դ��б���ɾ��
  strObjAddr := IntToStr(Integer(self));
  if g_lstObjects.Find(strObjAddr, nIndex) then
  begin
    szObjName := PChar(g_lstObjects.Objects[nIndex]);
    FreeMem(szObjName);
    g_lstObjects.Delete(nIndex);
  end
  //���û���ҵ�ָ����ָ�룬���ʾ����ͷ�
  else
  begin
    MessageBox(GetDesktopWindow(), PChar('�ͷŶ���ʱ���ڶ����б���û���ҵ���Ӧ�Ķ���'), '�����������', MB_OK or MB_ICONWARNING);
  end;
  //�����������һ
  InterlockedDecrement(g_nObjCounter);
  g_Mutex.Release;
  {$ENDIF}
end;

{$ENDREGION}

{$REGION '�Զ������ӿ�ʵ�ֻ���(�ӿ��Զ������Զ��ͷ�)'}

//���캯��
constructor TAutoInterfacedObject.Create;
{$IFDEF DEBUG}
var
  strObjAddr:string;
  strClassName:string;
  szObjName:PChar;
  {$ENDIF}
begin
  {$IFDEF DEBUG}
  g_Mutex.Acquire;
  //��ָ���������ֵ�Լ��뵽�б���
  strObjAddr := IntToStr(Integer(self));
  strClassName := self.ClassName;
  GetMem(szObjName, 60 * sizeof(Char));
  ZeroMemory(szObjName, 60 * sizeof(Char));
  if Length(strClassName) < 60 then
  begin
    lstrcpy(szObjName, PWideChar(strClassName));
  end;
  g_lstObjects.AddObject(strObjAddr, TObject(szObjName));
  //�������������һ
  InterlockedIncrement(g_nObjCounter);
  g_Mutex.Release;
  {$ENDIF}
end;

//��������
destructor TAutoInterfacedObject.Destroy;
{$IFDEF DEBUG}
var
  strObjAddr:string;
  szObjName:PChar;
  nIndex:Integer;
{$ENDIF}
begin
  {$IFDEF DEBUG}
  g_Mutex.Acquire;
  //����Ӧָ���������ֵ�Դ��б���ɾ��
  strObjAddr := IntToStr(Integer(self));
  if g_lstObjects.Find(strObjAddr, nIndex) then
  begin
    szObjName := PChar(g_lstObjects.Objects[nIndex]);
    FreeMem(szObjName);
    g_lstObjects.Delete(nIndex);
  end
  //���û���ҵ�ָ����ָ�룬���ʾ����ͷ�
  else
  begin
    MessageBox(GetDesktopWindow(), PChar('�ͷŶ���ʱ���ڶ����б���û���ҵ���Ӧ�Ķ���'), '�����������', MB_OK or MB_ICONWARNING);
  end;
  //�����������һ
  InterlockedDecrement(g_nObjCounter);
  g_Mutex.Release;
  {$ENDIF}
end;

{$ENDREGION}

{ $REGION '�Զ������ӿ�ʵ�ֶ������' }

function TAutoUserInterfacedObject.QueryInterface(const IID: TGUID;out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TAutoUserInterfacedObject._AddRef: Integer;
begin
  Result := 1;
end;

function TAutoUserInterfacedObject._Release: Integer;
begin
  Result := 1;
end;

{$ENDREGION}

{$REGION '�ڴ��������'}

// �����ڴ����(�������ڴ�ָ��;��������)
procedure IncMem(pPointer:Pointer;strDesc:string);
{$IFDEF DEBUG}
var
  strObjAddr:string;
  szObjName:PChar;
{$ENDIF}
begin
  {$IFDEF DEBUG}
  //����ڴ�ָ�벻Ϊ�գ����ڴ�ָ����뵽�����б���
  if pPointer <> nil then
  begin
    g_Mutex.Acquire;
    strObjAddr := IntToStr(Integer(pPointer));
    GetMem(szObjName, 40 * sizeof(Char));
    ZeroMemory(szObjName, 40 * sizeof(Char));
    if Length(strDesc) < 40 then
    begin
      lstrcpy(szObjName, PWideChar(strDesc));
    end;
    g_lstObjects.AddObject(strObjAddr, TObject(szObjName));
    g_Mutex.Release;
  end;

  //���ڴ��������һ
  InterlockedIncrement(g_nObjCounter);
  {$ENDIF}
end;

// ɾ���ڴ����(�������ڴ�ָ��)
procedure DecMem(pPointer:Pointer);
{$IFDEF DEBUG}
var
  strObjAddr:string;
  szObjName:PChar;
  nIndex:Integer;
{$ENDIF}
begin
  {$IFDEF DEBUG}
  //����ڴ�ָ�벻Ϊ�գ��򽫶�Ӧ���ڴ�ָ��Ӷ����б���ɾ��
  if pPointer <> nil then
  begin
    g_Mutex.Acquire;
    strObjAddr := IntToStr(Integer(pPointer));
    if g_lstObjects.Find(strObjAddr, nIndex) then
    begin
      szObjName := PChar(g_lstObjects.Objects[nIndex]);
      FreeMem(szObjName);
      g_lstObjects.Delete(nIndex);
    end
    else
    begin
      MessageBox(GetDesktopWindow(), PChar('�ͷŶ���ʱ���ڶ����б���û���ҵ���Ӧ�Ķ���'), '�����������', MB_OK or MB_ICONWARNING);
    end;
    g_Mutex.Release;
  end;

  //�ڴ��������һ
  InterlockedDecrement(g_nObjCounter);
  {$ENDIF}
end;

// �����ڴ�������ܵķ����ڴ淽��
procedure GetMemEx(var P: Pointer; Size: Integer);
begin
  GetMem(P, Size);
  {$IFDEF DEBUG}
  InterlockedIncrement(g_nObjCounter);
  {$ENDIF}
end;

// �����ڴ�������ܵ��ͷ��ڴ淽��
procedure FreeMemEx(var P: Pointer);
begin
  FreeMem(P);
  {$IFDEF DEBUG}
  InterlockedDecrement(g_nObjCounter);
  {$ENDIF}
end;

{$ENDREGION}

//�������б������޶���δ�ͷ�
procedure CheckObjectList();
var
  I : Integer;
  LError:string;
  pDesc:PChar;
begin
  g_Mutex.Acquire;

  //��������б������ж���δ�ͷţ��������ʾ
  if g_lstObjects.Count > 0 then
  begin
    LError := 'û���ͷŵĶ����б�: ' + #13;
    for I := 0 to g_lstObjects.Count - 1 do
    begin
      pDesc := PChar(g_lstObjects.Objects[I]);
      LError := LError + pDesc + #13;
      FreeMem(pDesc);
    end;
    MessageBoxW(GetDesktopWindow(), PChar(LError), '�����������', MB_OK or MB_ICONWARNING);
  end;

  g_Mutex.Release;
end;



initialization
  {$IFDEF DEBUG}
  g_nObjCounter := 0;
  {$ENDIF}
  g_lstObjects := TStringList.Create;
  g_lstObjects.Sorted := True;
  g_Mutex := TMutex.Create;

finalization

  {$IFDEF DEBUG}
  //���δ�ͷŶ����б�
  CheckObjectList();

  //���������Ƿ�Ϊ0
  if g_nObjCounter > 0 then
  begin
    MessageBox(GetDesktopWindow(), PChar('���� ' + InttoStr(g_nObjCounter) + ' ������û�����������飡'), '�����������', MB_OK or MB_ICONWARNING);
  end
  else if g_nObjCounter < 0 then
  begin
    MessageBox(GetDesktopWindow(), PChar('���� ' + InttoStr(g_nObjCounter) + ' �������Destroy����û�м���inherited�����飡'), '�����������', MB_OK OR MB_ICONWARNING);
  end;
  {$ENDIF}

  //�ͷ�ȫ�ֶ���
  FreeAndNil(g_lstObjects);
  g_Mutex.Free;

end.
