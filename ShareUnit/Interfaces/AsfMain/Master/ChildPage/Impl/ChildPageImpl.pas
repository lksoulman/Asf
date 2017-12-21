unit ChildPageImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description： ChildPage Implementation
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
  ChildPage,
  BaseObject,
  AppContext,
  ChildPageUI,
  MsgExSubcriber,
  MsgExSubcriberImpl,
  Generics.Collections,
  MsgExSubcriberAdapter;

type

  // ChildPage Implementation
  TChildPageImpl = class(TBaseSplitStrInterfacedObject, IChildPage)
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
    // ChildPageUI
    FChildPageUI: TChildPageUI;
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
//    // GetParent
//    function GetParent: TWinControl;
//    // SetParent
//    procedure SetParent(AParent: TWinControl);
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
//    property Parent: TWinControl read GetParent write SetParent;
    property Caption: string read GetCaption write SetCaption;
    property CommandId: Integer read GetCommandId write SetCommandId;
  end;

implementation

{ TChildPageImpl }

constructor TChildPageImpl.Create(AContext: IAppContext);
begin
  inherited;
  FChildPageUI := TChildPageUI.Create(AContext);
  FNoActiveNotifyMsgs := TList<Integer>.Create;
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(AContext, DoMsgExNotify);
  DoCreateObjects;
  DoInitObjectDatas;
  DoAddSubcribeMsgExs;
  DoCreateAfter;
end;

destructor TChildPageImpl.Destroy;
begin
  DoDestroyBefore;
  DoDestroyObjects;
  FMsgExSubcriberAdapter.Free;
  FNoActiveNotifyMsgs.Free;
  FChildPageUI.Free;
  inherited;
end;

procedure TChildPageImpl.DoCreateAfter;
begin
  FMsgExSubcriberAdapter.SubcribeMsgEx;
end;

procedure TChildPageImpl.DoDestroyBefore;
begin
  FCommandParams := '';
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(False);
end;

procedure TChildPageImpl.DoSendToBack;
begin
  DoNoActivate;
  FChildPageUI.SendToBack;
end;

procedure TChildPageImpl.DoBringToFront;
begin
  DoActivate;
  DoUpdateNoActiveNotifyMsg;
  DoUpdateCommandParam(FCommandParams);
//  FChildPageUI.BringToFront;
end;

procedure TChildPageImpl.DoUpdateNoActiveNotifyMsg;
var
  LIndex: Integer;
begin
  for LIndex := 0 to FNoActiveNotifyMsgs.Count -1 do begin
    DoUpdateOperate(FNoActiveNotifyMsgs.Items[LIndex]);
  end;
  if FNoActiveNotifyMsgs.Count > 0 then begin
    FNoActiveNotifyMsgs.Clear;
  end;
end;

procedure TChildPageImpl.DoMsgExNotify(AObject: TObject);
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

procedure TChildPageImpl.DoUpdateOperate(AMsgExId: Integer);
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

procedure TChildPageImpl.DoAddNoActiveNotifyMsg(AMsgExId: Integer);
begin
  if FNoActiveNotifyMsgs.IndexOf(AMsgExId) < 0 then begin
    FNoActiveNotifyMsgs.Add(AMsgExId);
  end;
end;

function TChildPageImpl.GetHandle: Cardinal;
begin
  Result := FChildPageUI.Handle;
end;

function TChildPageImpl.GetCaption: string;
begin
  Result := FChildPageUI.Caption;
end;

procedure TChildPageImpl.SetCaption(ACaption: string);
begin
  FChildPageUI.Caption := ACaption;
end;

//function TChildPageImpl.GetParent: TWinControl;
//begin
//  Result := FChildPageUI.Parent;
//end;

function TChildPageImpl.GetActive: Boolean;
begin
  Result := FActive;
end;

function TChildPageImpl.GetCommandId: Integer;
begin
  Result := FCommandId;
end;

procedure TChildPageImpl.SetCommandId(ACommandId: Integer);
begin
  FCommandId := ACommandId;
end;

procedure TChildPageImpl.DoCreateObjects;
begin

end;

procedure TChildPageImpl.DoDestroyObjects;
begin

end;

procedure TChildPageImpl.DoInitObjectDatas;
begin
  FActive := False;
  FCommandParams := '';

end;

procedure TChildPageImpl.DoAddSubcribeMsgExs;
begin

end;

procedure TChildPageImpl.DoActivate;
begin

end;

procedure TChildPageImpl.DoNoActivate;
begin

end;

procedure TChildPageImpl.DoReSubcribeHq;
begin

end;

procedure TChildPageImpl.DoReSecuMainMem;
begin

end;

procedure TChildPageImpl.DoReUpdateLanguage;
begin

end;

procedure TChildPageImpl.DoReUpdateSkinStyle;
begin
  if FChildPageUI.Color <> FAppContext.GetGdiMgr.GetColorRefMasterBack then begin
    FChildPageUI.Color := FAppContext.GetGdiMgr.GetColorRefMasterBack;
  end;
end;

procedure TChildPageImpl.DoUpdateCommandParam(AParams: string);
begin

end;

function TChildPageImpl.GoBack: Boolean;
begin
  Result := False;
end;

function TChildPageImpl.GoForward: Boolean;
begin
  Result := False;
end;

function TChildPageImpl.GoSendToBack: Boolean;
begin
  if FActive then begin
    DoSendToBack;
    FActive := False;
  end;
end;

function TChildPageImpl.GetChildPageUI: TForm;
begin
  Result := FChildPageUI;
end;

function TChildPageImpl.GoBringToFront(AParams: string): Boolean;
begin
  FCommandParams := AParams;
  if not FActive then begin
    DoBringToFront;
    FActive := True;
  end;
end;

end.
