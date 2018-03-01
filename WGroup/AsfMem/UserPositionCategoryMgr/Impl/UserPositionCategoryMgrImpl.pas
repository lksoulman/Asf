unit UserPositionCategoryMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： UserPositionCategoryMgr Implementation
// Author：      lksoulman
// Date：        2018-1-11
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  MsgEx,
  LogLevel,
  NativeXml,
  BaseObject,
  AppContext,
  CommonLock,
  UserCacheCfg,
  PositionCategory,
  Generics.Collections,
  UserPositionCategoryMgr;

type

  // UserPositionCategoryMgr Implementation
  TUserPositionCategoryMgrImpl = class(TBaseInterfacedObject, IUserPositionCategoryMgr)
  private
    // Lock
    FLock: TCSLock;
    // PositionCategorys
    FPositionCategorys: TList<TPositionCategory>;
  protected
    // Update
    procedure DoUpdate;
    // SaveData
    procedure DoSaveData;
    // AddDefault
    procedure DoAddDefault;
    // ClearPositionCategorys
    procedure DoClearPositionCategorys;
    // GetNameById
    function DoGetNameById(AId: Integer): string;
    // LoadXmlNodes
    procedure DoLoadXmlNodes(ANodeList: TList);
    // AddPositionCategoryNode
    procedure DoAddPositionCategoryNode(ANode: TXmlNode; APositionCategory: TPositionCategory);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IUserPositionCategoryMgr }

    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // SaveData
    procedure SaveData;
    // ClearData
    procedure ClearData;
    // Add
    procedure Add(AId: Integer; AName: string);
    // GetCount
    function GetCount: Integer;
    // GetPositionCategory
    function GetPositionCategory(AIndex: Integer): TPositionCategory;
  end;

implementation

uses
  Utils,
  PositionCategoryImpl;

const
  STORAGE_XML = '<?xml version="1.0" encoding="UTF-8"?>' + #13#10
  + '<PositionCategorys>' + #13#10
  + '<Version>' + #13#10 + '</Version>' + #13#10
  + '</PositionCategorys>';
  STORAGE_XML_VERSION = '1.0';

{ TUserPositionCategoryMgrImpl }

constructor TUserPositionCategoryMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FLock := TCSLock.Create;
  FPositionCategorys := TList<TPositionCategory>.Create;
  Update;
end;

destructor TUserPositionCategoryMgrImpl.Destroy;
begin
  DoClearPositionCategorys;
  FPositionCategorys.Free;
  FLock.Free;
  inherited;
end;

procedure TUserPositionCategoryMgrImpl.DoUpdate;
var
  LValue: string;
  LXml: TNativeXml;
  LNodeList: TList;
  LNode, LChildNode: TXmlNode;
begin
  DoClearPositionCategorys;

  LValue := FAppContext.GetCfg.GetUserCacheCfg.GetServerValue(CACHECFG_KEY_UserPositionCategory);
  if LValue <> '' then  begin
    LXml := TNativeXml.Create(nil);
    try
      LXml.ReadFromString(UTF8String(LValue));
      LXml.XmlFormat := xfReadable;
      LNode := LXml.Root;
      LChildNode := LNode.FindNode('Version');
      if (LChildNode <> nil)
        and (LChildNode.Value = STORAGE_XML_VERSION) then begin
        LNodeList := TList.Create;
        try
          LNode.FindNodes('PositionCategory', LNodeList);
          DoLoadXmlNodes(LNodeList);
        finally
          LNodeList.Free;
        end;
      end;
    finally
      LXml.Free;
    end;
  end;
  if FPositionCategorys.Count <= 0 then begin
    DoAddDefault;
  end;
end;

procedure TUserPositionCategoryMgrImpl.DoSaveData;
var
  LIndex: Integer;
  LValue: string;
  LXml: TNativeXml;
  LNodeList: TList;
  LNode, LChildNode: TXmlNode;
  LPositionCategory: TPositionCategory;
begin
  if FPositionCategorys.Count >= 0 then begin
    LXml := TNativeXml.Create(nil);
    try
      LXml.ReadFromString(UTF8String(STORAGE_XML));
      LXml.XmlFormat := xfReadable;
      LNode := LXml.Root;
      LChildNode := LNode.FindNode('Version');
      if (LChildNode <> nil) then begin
        LChildNode.Value := STORAGE_XML_VERSION;
      end;
      for LIndex := 0 to FPositionCategorys.Count - 1 do begin
        LChildNode := LNode.NodeNew('PositionCategory');
        if LChildNode <> nil then begin
          LPositionCategory := FPositionCategorys.Items[LIndex];
          DoAddPositionCategoryNode(LChildNode, LPositionCategory);
        end;
      end;
      LValue := LXml.WriteToLocalUnicodeString;
    finally
      LXml.Free;
    end;
  end else begin
    LValue := '';
  end;
//  FAppContext.GetCfg.GetUserCacheCfg.SaveServer(CACHECFG_KEY_UserPositionCategory, LValue, 'UserAttetionSector');
end;

procedure TUserPositionCategoryMgrImpl.DoAddDefault;
var
  LPositionCategory: TPositionCategory;
begin
  LPositionCategory := TPositionCategoryImpl.Create(FAppContext);
  TPositionCategoryImpl(LPositionCategory).FId := POSITIONCATEGORY_STOCK;
  TPositionCategoryImpl(LPositionCategory).FName := DoGetNameById(LPositionCategory.Id);
  FPositionCategorys.Add(LPositionCategory);

  LPositionCategory := TPositionCategoryImpl.Create(FAppContext);
  TPositionCategoryImpl(LPositionCategory).FId := POSITIONCATEGORY_BOND;
  TPositionCategoryImpl(LPositionCategory).FName := DoGetNameById(LPositionCategory.Id);
  FPositionCategorys.Add(LPositionCategory);

  LPositionCategory := TPositionCategoryImpl.Create(FAppContext);
  TPositionCategoryImpl(LPositionCategory).FId := POSITIONCATEGORY_FUND_INNER;
  TPositionCategoryImpl(LPositionCategory).FName := DoGetNameById(LPositionCategory.Id);
  FPositionCategorys.Add(LPositionCategory);

  LPositionCategory := TPositionCategoryImpl.Create(FAppContext);
  TPositionCategoryImpl(LPositionCategory).FId := POSITIONCATEGORY_FUND_OUTER;
  TPositionCategoryImpl(LPositionCategory).FName := DoGetNameById(LPositionCategory.Id);
  FPositionCategorys.Add(LPositionCategory);

  LPositionCategory := TPositionCategoryImpl.Create(FAppContext);
  TPositionCategoryImpl(LPositionCategory).FId := POSITIONCATEGORY_FUTURES;
  TPositionCategoryImpl(LPositionCategory).FName := DoGetNameById(LPositionCategory.Id);
  FPositionCategorys.Add(LPositionCategory);
end;

procedure TUserPositionCategoryMgrImpl.DoLoadXmlNodes(ANodeList: TList);
var
  LNode: TXmlNode;
  LName: string;
  LIndex, LId: Integer;
begin
  for LIndex := 0 to ANodeList.Count - 1 do begin
    LNode := ANodeList.Items[LIndex];
    if LNode <> nil then begin
      LId := Utils.GetIntegerByChildNodeName(LNode, 'Id', -1);
      LName := DoGetNameById(LId);  //Utils.GetStringByChildNodeName(LNode, 'Name');
      if (LId <> -1) and (LName <> '') then begin
        Add(LId, LName);
      end;
    end;
  end;
end;

procedure TUserPositionCategoryMgrImpl.DoAddPositionCategoryNode(ANode: TXmlNode; APositionCategory: TPositionCategory);
var
  LNode: TXmlNode;
begin
  LNode := ANode.NodeNew('Id');
  LNode.Value := UTF8String(IntToStr(APositionCategory.Id));
//  LNode := ANode.NodeNew('Name');
//  LNode.Value := UTF8String((APositionCategory.Name));
end;

procedure TUserPositionCategoryMgrImpl.DoClearPositionCategorys;
var
  LIndex: Integer;
  LPositionCategory: TPositionCategory;
begin
  for LIndex := 0 to FPositionCategorys.Count - 1 do begin
    LPositionCategory := FPositionCategorys.Items[LIndex];
    if LPositionCategory <> nil then begin
      LPositionCategory.Free;
    end;
  end;
  FPositionCategorys.Clear;
end;

function TUserPositionCategoryMgrImpl.DoGetNameById(AId: Integer): string;
begin
  case AId of
    POSITIONCATEGORY_STOCK:
      begin
        Result := '股票';
      end;
    POSITIONCATEGORY_BOND:
      begin
        Result := '债券';
      end;
    POSITIONCATEGORY_FUND_INNER:
      begin
        Result := '场内基金';
      end;
    POSITIONCATEGORY_FUND_OUTER:
      begin
        Result := '场外基金';
      end;
    POSITIONCATEGORY_FUTURES:
      begin
        Result := '期货';
      end;
    POSITIONCATEGORY_OPTION:
      begin
        Result := '期权';
      end;
  else
    Result := '';
  end;
end;

procedure TUserPositionCategoryMgrImpl.Lock;
begin
  FLock.Lock;
end;

procedure TUserPositionCategoryMgrImpl.UnLock;
begin
  FLock.UnLock;
end;

procedure TUserPositionCategoryMgrImpl.Update;
{$IFDEF DEBUG}
var
  LTick: Cardinal;
{$ENDIF}
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    FLock.Lock;
    try
      DoUpdate;
    finally
      FLock.UnLock;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.SysLog(llSLOW, Format('[TUserSectorMgrImpl][Update] Update use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TUserPositionCategoryMgrImpl.SaveData;
begin
  DoSaveData;
  FAppContext.SendMsgEx(Msg_AsfMem_ReUpdateUserPositionCategroyMgr, '');
end;

procedure TUserPositionCategoryMgrImpl.ClearData;
begin
  DoClearPositionCategorys;
end;

procedure TUserPositionCategoryMgrImpl.Add(AId: Integer; AName: string);
var
  LPositionCategory: TPositionCategory;
begin
  LPositionCategory := TPositionCategoryImpl.Create(FAppContext);
  TPositionCategoryImpl(LPositionCategory).FId := AId;
  TPositionCategoryImpl(LPositionCategory).FName := DoGetNameById(AId);
  FPositionCategorys.Add(LPositionCategory);
end;

function TUserPositionCategoryMgrImpl.GetCount: Integer;
begin
  Result := FPositionCategorys.Count;
end;

function TUserPositionCategoryMgrImpl.GetPositionCategory(AIndex: Integer): TPositionCategory;
begin
  if (AIndex >= 0) and (AIndex < FPositionCategorys.Count) then begin
    Result := FPositionCategorys.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

end.
