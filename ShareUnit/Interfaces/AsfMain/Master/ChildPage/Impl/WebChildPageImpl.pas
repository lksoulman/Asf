unit WebChildPageImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： WebChildPage Implementation
// Author：      lksoulman
// Date：        2017-12-15
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  MsgEx,
  Browser,
  ChildPage,
  BaseObject,
  AppContext,
  MsgExSubcriber,
  MsgExSubcriberImpl,
  Generics.Collections,
  MsgExSubcriberAdapter;

type

  // WebChildPage Implementation
  TWebChildPageImpl = class(TBaseSplitStrInterfacedObject, IChildPage)
  private
    // CreateAfter
    procedure DoCreateAfter;
    // DestroyBefore
    procedure DoDestroyBefore;
    // SendToBack
    procedure DoSendToBack;
    // BringToFront
    procedure DoBringToFront;
    // UpdateNoActiveNotifyMsg
    procedure DoUpdateNoActiveNotifyMsg;
    // MsgExNotify
    procedure DoMsgExNotify(AObject: TObject);
    // UpdateOperate
    procedure DoUpdateOperate(AMsgExId: Integer);
    // DoAddNoActiveNotifyMsg
    procedure DoAddNoActiveNotifyMsg(AMsgExId: Integer);
  protected
    // Active
    FActive: Boolean;
    // CommandId
    FCommandId: Integer;
    // CommandParams
    FCommandParams: string;
    // Browser
    FBrowser: IBrowser;
    // NoActiveNotifyMsgs
    FNoActiveNotifyMsgs: TList<Integer>;
    // MsgExSubcriberAdapter
    FMsgExSubcriberAdapter: TMsgExSubcriberAdapter;

    // CreateObjects
    procedure DoCreateObjects; virtual;
    // DestroyObjects
    procedure DoDestroyObjects; virtual;
    // InitObjectDatas
    procedure DoInitObjectDatas; virtual;
    // AddSubcribeMsgExs
    procedure DoAddSubcribeMsgExs; virtual;

    // Activate
    procedure DoActivate; virtual;
    // NoActivate
    procedure DoNoActivate; virtual;
    // ReSubcribeHq
    procedure DoReSubcribeHq; virtual;
    // ReSecuMainMem
    procedure DoReSecuMainMem; virtual;
    // ReUpdateLanguage
    procedure DoReUpdateLanguage; virtual;
    // ReUpdateSkinStyle
    procedure DoReUpdateSkinStyle; virtual;
    // UpdateCommandParam
    procedure DoUpdateCommandParam(AParams: string); virtual;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IChildPage }

    // GetActive
    function GetActive: Boolean;
    // GetHandle
    function GetHandle: Cardinal;
    // GetCaption
    function GetCaption: string;
    // SetCaption
    procedure SetCaption(ACaption: string);
    // GetMasterHandle
    function GetMasterHandle: Cardinal;
    // GetCommandId
    function GetCommandId: Integer;
    // SetCommandId
    procedure SetCommandId(ACommandId: Integer);


    // GoBack (True is Response, False Is not Response)
    function GoBack: Boolean;
    // GoForward (True is Response, False Is not Response)
    function GoForward: Boolean;
    // GoSendToBack
    function GoSendToBack: Boolean;
    // GetChildPageUI
    function GetChildPageUI: TForm;
    // GoBringToFront
    function GoBringToFront(AParams: string): Boolean;
    property Active: Boolean read GetActive;
    property Handle: Cardinal read GetHandle;
    property MasterHandle: Cardinal read GetMasterHandle;
    property Caption: string read GetCaption write SetCaption;
    property CommandId: Integer read GetCommandId write SetCommandId;
  end;

implementation

{ TWebChildPageImpl }

constructor TWebChildPageImpl.Create(AContext: IAppContext);
begin
  inherited;
  FBrowser := FAppContext.CreateBrowser;
  FNoActiveNotifyMsgs := TList<Integer>.Create;
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(AContext, DoMsgExNotify);
  DoCreateObjects;
  DoInitObjectDatas;
  DoAddSubcribeMsgExs;
  DoCreateAfter;
end;

destructor TWebChildPageImpl.Destroy;
begin
  DoDestroyBefore;
  DoDestroyObjects;
  FMsgExSubcriberAdapter.Free;
  FNoActiveNotifyMsgs.Free;
  FBrowser := nil;
  inherited;
end;

procedure TWebChildPageImpl.DoCreateAfter;
begin
  FMsgExSubcriberAdapter.SubcribeMsgEx;
end;

procedure TWebChildPageImpl.DoDestroyBefore;
begin
  FCommandParams := '';
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(False);
end;

procedure TWebChildPageImpl.DoSendToBack;
begin
  DoNoActivate;
  if FBrowser <> nil then begin
    FBrowser.GetBrowserUI.SendToBack;
  end;
end;

procedure TWebChildPageImpl.DoBringToFront;
begin
  DoActivate;
  DoUpdateNoActiveNotifyMsg;
  DoUpdateCommandParam(FCommandParams);
  if FBrowser <> nil then begin
    FBrowser.GetBrowserUI.BringToFront;
  end;
end;

procedure TWebChildPageImpl.DoUpdateNoActiveNotifyMsg;
var
  LIndex: Integer;
begin
  for LIndex := 0 to FNoActiveNotifyMsgs.Count - 1 do begin
    DoUpdateOperate(FNoActiveNotifyMsgs.Items[LIndex]);
  end;
  if FNoActiveNotifyMsgs.Count > 0 then begin
    FNoActiveNotifyMsgs.Clear;
  end;
end;

procedure TWebChildPageImpl.DoMsgExNotify(AObject: TObject);
var
  LMsgEx: TMsgEx;
  LUpdateOperate: Integer;
begin
  LMsgEx := TMsgEx(AObject);
  if FActive then begin
    DoUpdateOperate(LMsgEx.Id);
  end else begin
    DoAddNoActiveNotifyMsg(LMsgEx.Id);
  end;
end;

procedure TWebChildPageImpl.DoUpdateOperate(AMsgExId: Integer);
begin
  case AMsgExId of
    // 100001    更新皮肤样式
    Msg_AsfMain_ReUpdateSkinStyle:
      begin
        DoReUpdateSkinStyle;
      end;
    // 100002    更新语言包
    Msg_AsfMain_ReUpdateLanguage:
      begin
        DoReUpdateLanguage;
      end;
    // 103001    证券主表 SECUMAIN 内存更新
    Msg_AsfMem_ReUpdateSecuMain:
      begin
        DoReSecuMainMem;
      end;
    // 105004    基础CACHE证券主表 SECUMAIN 更新
    Msg_AsfCache_ReUpdateBaseCache_SecuMain:
      begin

      end;
    // 107001    行情服务连接消息
    Msg_AsfHqService_ReConnectServer:
      begin
        DoReSubcribeHq;
      end;
    // 107002    行情订阅数据更新需要重新订阅
    Msg_AsfHqService_ReSubcribeHq:
      begin
        DoReSubcribeHq;
      end;
  end;
end;

procedure TWebChildPageImpl.DoAddNoActiveNotifyMsg(AMsgExId: Integer);
begin
  if FNoActiveNotifyMsgs.IndexOf(AMsgExId) < 0 then begin
    FNoActiveNotifyMsgs.Add(AMsgExId);
  end;
end;

function TWebChildPageImpl.GetHandle: Cardinal;
begin
  if FBrowser <> nil then begin
    Result := FBrowser.GetBrowserUI.Handle;
  end else begin
    Result := 0;
  end;
end;

function TWebChildPageImpl.GetCaption: string;
begin
  if FBrowser <> nil then begin
    Result := FBrowser.GetBrowserUI.Caption;
  end else begin
    Result := '';
  end;
end;

procedure TWebChildPageImpl.SetCaption(ACaption: string);
begin
  if FBrowser <> nil then begin
    FBrowser.GetBrowserUI.Caption := ACaption;
  end;
end;

function TWebChildPageImpl.GetMasterHandle: Cardinal;
begin
  if FBrowser <> nil then begin
    Result := FBrowser.GetBrowserUI.ParentWindow;
  end else begin
    Result := 0;
  end;
end;

function TWebChildPageImpl.GetActive: Boolean;
begin
  Result := FActive;
end;

function TWebChildPageImpl.GetCommandId: Integer;
begin
  Result := FCommandId;
end;

procedure TWebChildPageImpl.SetCommandId(ACommandId: Integer);
begin
  FCommandId := ACommandId;
end;

procedure TWebChildPageImpl.DoCreateObjects;
begin

end;

procedure TWebChildPageImpl.DoDestroyObjects;
begin

end;

procedure TWebChildPageImpl.DoInitObjectDatas;
begin
  FActive := False;
  FCommandParams := '';

end;

procedure TWebChildPageImpl.DoAddSubcribeMsgExs;
begin

end;

procedure TWebChildPageImpl.DoActivate;
begin

end;

procedure TWebChildPageImpl.DoNoActivate;
begin

end;

procedure TWebChildPageImpl.DoReSubcribeHq;
begin

end;

procedure TWebChildPageImpl.DoReSecuMainMem;
begin

end;

procedure TWebChildPageImpl.DoReUpdateLanguage;
begin

end;

procedure TWebChildPageImpl.DoReUpdateSkinStyle;
begin
  if FBrowser <> nil then begin
    if FBrowser.GetBrowserUI.Color <> FAppContext.GetGdiMgr.GetColorRefMasterBack then begin
      FBrowser.GetBrowserUI.Color := FAppContext.GetGdiMgr.GetColorRefMasterBack;
    end;
  end;
end;

procedure TWebChildPageImpl.DoUpdateCommandParam(AParams: string);
begin

end;

function TWebChildPageImpl.GoBack: Boolean;
begin
  Result := False;
end;

function TWebChildPageImpl.GoForward: Boolean;
begin
  Result := False;
end;

function TWebChildPageImpl.GoSendToBack: Boolean;
begin
  if FActive then begin
    DoSendToBack;
    FActive := False;
  end;
end;

function TWebChildPageImpl.GetChildPageUI: TForm;
begin
  if FBrowser <> nil then begin
    Result := FBrowser.GetBrowserUI;
  end else begin
    Result := nil;
  end;
end;

function TWebChildPageImpl.GoBringToFront(AParams: string): Boolean;
begin
  FCommandParams := AParams;
  if not FActive then begin
    DoBringToFront;
    FActive := True;
  end;
end;

end.
