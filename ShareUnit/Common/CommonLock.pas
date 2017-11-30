unit CommonLock;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-7-10
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows;

type

  TCSLock = class
  protected
    m_dBegin: DWORD;                           // �����ٽ���ʱ��
    m_LockName: String;                        // �ٽ�������
    m_CriticalSection: TRTLCriticalSection;    // �ٽ�����Դ
  public
    // ���캯��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // �����ٽ�������
    procedure SetLockName(m_sLockName: String);
    // �����ٽ�����Դ
    procedure Lock;
    // �����ٽ�����Դ
    procedure UnLock;
  end;

implementation

constructor TCSLock.Create;
begin
  inherited Create;
  InitializeCriticalSection(m_CriticalSection);
end;

destructor TCSLock.Destroy;
begin
  DeleteCriticalSection(m_CriticalSection);
  inherited Destroy;
end;

procedure TCSLock.SetLockName(m_sLockName: String);
begin
  m_LockName := m_sLockName;
end;

procedure TCSLock.Lock;
//var
//  tmpTemp: DWORD;
begin
  m_dBegin := GetTickCount;
  EnterCriticalSection(m_CriticalSection);
//  tmpTemp := GetTickCount - m_dBegin;
end;

procedure TCSLock.UnLock;
//var
//  tmpTemp: DWORD;
begin
  LeaveCriticalSection(m_CriticalSection);
//  tmpTemp := GetTickCount;
end;

end.
