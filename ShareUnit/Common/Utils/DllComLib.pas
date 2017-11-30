unit DllComLib;

////////////////////////////////////////////////////////////////////////////////
//
// Description��
// Author��      lksoulman
// Date��        2017-4-10
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Winapi.Windows,
  Classes,
  SysUtils,
  System.Win.ComObj,
  System.Win.ComServ,
  ActiveX,
  Generics.Collections;

type

  // ��ͨ�ĵ�������
  TDllGetClassObjectFunc = function(): IInterface; stdcall;
  // Com �ĵ�������
  TDllComGetClassObjectFunc = function(const CLSID, IID: TGUID; var Obj): HResult; stdcall;

  TDllComLib = class
  private
    // ģ���ļ��ֵ�
    FModuleFileDic: TDictionary<string, HMODULE>;
    // ģ�麯���ֵ�
    FModuleGetClassObjectDic: TDictionary<HMODULE, TDllGetClassObjectFunc>;
    // ģ�麯���ֵ�
    FModuleComGetClassObjectDic: TDictionary<HMODULE, IClassFactory>;
    //
  protected
    // ͨ�� HModule �� GUID �����ӿ�
    function DoCreateInterfaceByHModuleAndGUID(AHModule: HModule; AGUID: TGUID): IInterface;
    // ͨ�� HModule �� Index �����ӿ�
    function DoCreateInterfaceByHModuleAndIndex(AHModule: HModule; AIndex: Integer): IInterface;
    // ͨ�� HModule �� FuncName �����ӿ�
    function DoCreateInterfaceByHModuleAndFuncName(AHModule: HModule; AFuncName: string): IInterface;
  public
    // ���캯��
    constructor Create;
    // ��������
    destructor Destroy; override;
    // ͨ�� File �� GUID �����ӿ�
    function CreateInterface(AFile: string; AGUID: TGUID): IInterface; overload;
    // ͨ�� File �� Index �����ӿ�
    function CreateInterface(AFile: string; AIndex: Integer): IInterface; overload;
    // ͨ�� File �� FuncName �����ӿ�
    function CreateInterface(AFile: string; AFuncName: string): IInterface; overload;
  end;

implementation

const
  DLLGETCLASSOBJECT = 'DllGetClassObject';

constructor TDllComLib.Create;
begin
  FModuleFileDic := TDictionary<string, HMODULE>.Create;
  FModuleGetClassObjectDic := TDictionary<HMODULE, TDllGetClassObjectFunc>.Create;
  FModuleComGetClassObjectDic := TDictionary<HMODULE, IClassFactory>.Create;
end;

destructor TDllComLib.Destroy;
begin
  FModuleComGetClassObjectDic.Free;
  FModuleGetClassObjectDic.Free;
  FModuleFileDic.Free;
end;

function TDllComLib.DoCreateInterfaceByHModuleAndGUID(AHModule: HModule; AGUID: TGUID): IInterface;
var
  LClassFactory: IClassFactory;
  LGetClassObject: TDllComGetClassObjectFunc;
begin
  Result := nil;
  if not (FModuleComGetClassObjectDic.TryGetValue(AHModule, LClassFactory)
      and (LClassFactory <> nil)) then begin
    LGetClassObject := GetProcAddress(AHModule, DLLGETCLASSOBJECT);
    if not Assigned(LGetClassObject) then Exit;
    OleCheck(LGetClassObject(AGUID, IClassFactory, LClassFactory));
    if LClassFactory = nil then Exit;
    FModuleComGetClassObjectDic.AddOrSetValue(AHModule, LClassFactory);
  end;
  OleCheck(LClassFactory.CreateInstance(nil, IUnknown, Result));
end;

function TDllComLib.DoCreateInterfaceByHModuleAndIndex(AHModule: HModule; AIndex: Integer): IInterface;
var
  LGetClassObjectFunc: TDllGetClassObjectFunc;
begin
  Result := nil;
  if FModuleGetClassObjectDic.TryGetValue(AHModule, LGetClassObjectFunc)
    and (LGetClassObjectFunc <> nil) then begin
    LGetClassObjectFunc := GetProcAddress(AHModule, MakeIntResource(AIndex));
    if LGetClassObjectFunc = nil then Exit;
    FModuleGetClassObjectDic.AddOrSetValue(AHModule, LGetClassObjectFunc);
  end;
  Result := LGetClassObjectFunc;
end;

function TDllComLib.DoCreateInterfaceByHModuleAndFuncName(AHModule: HModule; AFuncName: string): IInterface;
var
  LGetClassObjectFunc: TDllGetClassObjectFunc;
begin
  Result := nil;
  if FModuleGetClassObjectDic.TryGetValue(AHModule, LGetClassObjectFunc)
    and (LGetClassObjectFunc <> nil) then begin
    LGetClassObjectFunc := GetProcAddress(AHModule, PChar(AFuncName));
    if LGetClassObjectFunc = nil then Exit;
    FModuleGetClassObjectDic.AddOrSetValue(AHModule, LGetClassObjectFunc);
  end;
  Result := LGetClassObjectFunc;
end;

function TDllComLib.CreateInterface(AFile: string; AGUID: TGUID): IInterface;
var
  LHModule: HModule;
begin
  Result := nil;
  if FileExists(AFile) then begin
    if not (FModuleFileDic.TryGetValue(AFile, LHModule)
      and (LHModule <> 0)) then begin
      LHModule := LoadLibrary(PChar(AFile));
      if LHModule = 0 then Exit;
      FModuleFileDic.AddOrSetValue(AFile, LHModule);
    end;
    Result := DoCreateInterfaceByHModuleAndGUID(LHModule, AGUID);
  end;
end;

function TDllComLib.CreateInterface(AFile: string; AIndex: Integer): IInterface;
var
  LHModule: HModule;
begin
  Result := nil;
  if FileExists(AFile) then begin
    if not (FModuleFileDic.TryGetValue(AFile, LHModule)
      and (LHModule <> 0)) then begin
      LHModule := LoadLibrary(PChar(AFile));
      if LHModule = 0 then Exit;
      FModuleFileDic.AddOrSetValue(AFile, LHModule);
    end;
    Result := DoCreateInterfaceByHModuleAndIndex(LHModule, AIndex);
  end;
end;

function TDllComLib.CreateInterface(AFile: string; AFuncName: string): IInterface;
var
  LHModule: HModule;
begin
  Result := nil;
  if FileExists(AFile) then begin
    if not (FModuleFileDic.TryGetValue(AFile, LHModule)
      and (LHModule <> 0)) then begin
      LHModule := LoadLibrary(PChar(AFile));
      if LHModule = 0 then Exit;
      FModuleFileDic.AddOrSetValue(AFile, LHModule);
    end;
    Result := DoCreateInterfaceByHModuleAndFuncName(LHModule, AFuncName);
  end;
end;

end.
