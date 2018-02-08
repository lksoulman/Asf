unit UserAttentionMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserAttentionMgr Implementation
// Author£º      lksoulman
// Date£º        2018-1-11
// Comments£º
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
  Attention,
  BaseObject,
  AppContext,
  CommonLock,
  UserCacheCfg,
  UserAttentionMgr,
  Generics.Collections;

type

  // UserAttentionMgr Implementation
  TUserAttentionMgrImpl = class(TBaseInterfacedObject, IUserAttentionMgr)
  private
    // Lock
    FLock: TCSLock;
    // AttentionSectors
    FAttentions: TList<TAttention>;
  protected
    // Update
    procedure DoUpdate;
    // SaveData
    procedure DoSaveData;
    // ClearAttentions
    procedure DoClearAttentions;
    // LoadXmlNodes
    procedure DoLoadXmlNodes(ANodeList: TList);
    // AddAttentionNode
    procedure DoAddAttentionNode(ANode: TXmlNode; AAttention: TAttention);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IUserAttentionMgr }

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
    // GetCount
    function GetCount: Integer;
    // GetAttention
    function GetAttention(AIndex: Integer): TAttention;
    // Add
    procedure Add(ASectorId, AModuleId: Integer; AName: string);
  end;

implementation

uses
  Utils,
  AttentionImpl;

const
  STORAGE_XML = '<?xml version="1.0" encoding="UTF-8"?>' + #13#10
  + '<Attentions>' + #13#10
  + '<Version>' + #13#10 + '</Version>' + #13#10
  + '</Attentions>';
  STORAGE_XML_VERSION = '1.0';

{ TUserAttentionMgrImpl }

constructor TUserAttentionMgrImpl.Create(AContext: IAppContext);
begin
  inherited;
  FLock := TCSLock.Create;
  FAttentions := TList<TAttention>.Create;
end;

destructor TUserAttentionMgrImpl.Destroy;
begin
  DoClearAttentions;
  FAttentions.Free;
  FLock.Free;
  inherited;
end;

procedure TUserAttentionMgrImpl.DoUpdate;
var
  LValue: string;
  LXml: TNativeXml;
  LNodeList: TList;
  LNode, LChildNode: TXmlNode;
begin
  DoClearAttentions;

  LValue := FAppContext.GetCfg.GetUserCacheCfg.GetServerValue(CACHECFG_KEY_UserAttention);
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
          LNode.FindNodes('Attention', LNodeList);
          DoLoadXmlNodes(LNodeList);
        finally
          LNodeList.Free;
        end;
      end;
    finally
      LXml.Free;
    end;
  end;
end;

procedure TUserAttentionMgrImpl.DoSaveData;
var
  LIndex: Integer;
  LValue: string;
  LXml: TNativeXml;
  LNodeList: TList;
  LAttention: TAttention;
  LNode, LChildNode: TXmlNode;
begin
  if FAttentions.Count >= 0 then begin
    LXml := TNativeXml.Create(nil);
    try
      LXml.ReadFromString(UTF8String(STORAGE_XML));
      LXml.XmlFormat := xfReadable;
      LNode := LXml.Root;
      LChildNode := LNode.FindNode('Version');
      if (LChildNode <> nil) then begin
        LChildNode.Value := STORAGE_XML_VERSION;
      end;
      for LIndex := 0 to FAttentions.Count - 1 do begin
        LChildNode := LNode.NodeNew('Attention');
        if LChildNode <> nil then begin
          LAttention := FAttentions.Items[LIndex];
          DoAddAttentionNode(LChildNode, LAttention);
        end;
      end;
      LValue := LXml.WriteToLocalUnicodeString;
    finally
      LXml.Free;
    end;
  end else begin
    LValue := '';
  end;
//  FAppContext.GetCfg.GetUserCacheCfg.SaveServer(CACHECFG_KEY_UserAttention, LValue, 'UserAttetionSector');
end;

procedure TUserAttentionMgrImpl.DoLoadXmlNodes(ANodeList: TList);
var
  LNode: TXmlNode;
  LName: string;
  LIndex, LSectorId, LModuleId: Integer;
begin
  for LIndex := 0 to ANodeList.Count - 1 do begin
    LNode := ANodeList.Items[LIndex];
    if LNode <> nil then begin
      LSectorId := Utils.GetIntegerByChildNodeName(LNode, 'SectorId', -1);
      LModuleId := Utils.GetIntegerByChildNodeName(LNode, 'ModuleId', -1);
      LName := Utils.GetStringByChildNodeName(LNode, 'Name');
      if (LSectorId <> -1)
        and (LModuleId <> -1)
        and (LName <> '') then begin
        Add(LSectorId, LModuleId, LName);
      end;
    end;
  end;
end;

procedure TUserAttentionMgrImpl.DoAddAttentionNode(ANode: TXmlNode; AAttention: TAttention);
var
  LNode: TXmlNode;
begin
  LNode := ANode.NodeNew('SectorId');
  LNode.Value := UTF8String(IntToStr(AAttention.SectorId));
  LNode := ANode.NodeNew('ModuleId');
  LNode.Value := UTF8String(IntToStr(AAttention.ModuleId));
  LNode := ANode.NodeNew('Name');
  LNode.Value := UTF8String((AAttention.Name));
end;

procedure TUserAttentionMgrImpl.DoClearAttentions;
var
  LIndex: Integer;
  LAttention: TAttention;
begin
  for LIndex := 0 to FAttentions.Count - 1 do begin
    LAttention := FAttentions.Items[LIndex];
    if LAttention <> nil then begin
      LAttention.Free;
    end;
  end;
  FAttentions.Clear;
end;

procedure TUserAttentionMgrImpl.Lock;
begin
  FLock.Lock;
end;

procedure TUserAttentionMgrImpl.UnLock;
begin
  FLock.UnLock;
end;

procedure TUserAttentionMgrImpl.Update;
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

procedure TUserAttentionMgrImpl.SaveData;
begin
  DoSaveData;
  FAppContext.SendMsgEx(Msg_AsfMem_ReUpdateUserAttentionMgr, '');
end;

procedure TUserAttentionMgrImpl.ClearData;
begin
  DoClearAttentions;
end;

procedure TUserAttentionMgrImpl.Add(ASectorId, AModuleId: Integer; AName: string);
var
  LAttention: TAttention;
begin
  LAttention := TAttentionImpl.Create;
  TAttentionImpl(LAttention).FSectorId := ASectorId;
  TAttentionImpl(LAttention).FModuleId := AModuleId;
  TAttentionImpl(LAttention).FName := Copy(AName, 1, Length(AName));
  FAttentions.Add(LAttention);
end;

function TUserAttentionMgrImpl.GetCount: Integer;
begin
  Result := FAttentions.Count;
end;

function TUserAttentionMgrImpl.GetAttention(AIndex: Integer): TAttention;
begin
  if (AIndex >= 0) and (AIndex < FAttentions.Count) then begin
    Result := FAttentions.Items[AIndex];
  end else begin
    Result := nil;
  end;
end;

end.
