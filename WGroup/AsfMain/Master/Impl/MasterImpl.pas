unit MasterImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Master Implementation
// Author£º      lksoulman
// Date£º        2017-11-20
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  Vcl.Forms,
  Master,
  Command,
  MasterUI,
  KeyFairy,
  SecuMain,
  CmdCookie,
  ChildPage,
  BaseObject,
  AppContext,
  Generics.Collections;

type

  // ChildPageInfo
  TChildPageInfo = packed record
    FChildPage: IChildPage;
  end;

  // ChildPageInfo Pointer
  PChildPageInfo = ^TChildPageInfo;

  // Master Implementation
  TMasterImpl = class(TBaseInterfacedObject, IMaster)
  private
    // MasterUI
    FMasterUI: TMasterUI;
    // KeyFairy
    FKeyFairy: IKeyFairy;
    // CmdCookieMgr
    FCmdCookieMgr: TCmdCookieMgr;
    // FrontChildPageInfo
    FFrontChildPageInfo: PChildPageInfo;
    // ChildPageInfoDic
    FChildPageInfoDic: TDictionary<Integer, PChildPageInfo>;
  protected
    // InitMasterEvents
    procedure DoInitMasterEvents;
    // ChildPageChangeSize
    procedure DoChildPageChangeSize(AForm: TForm);
    // MasterClientChangeSize
    procedure DoMasterClientChangeSize(Sender: TObject);
    // MasterKeyPress
    procedure DoMasterKeyPress(Sender: TObject; var Key: Char);

    // ClearChildPageInfo
    procedure DoClearChildPageInfos;
    // BringToFront
    procedure DoBringToFront(AChildPageInfo: PChildPageInfo; AParams: string);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IMaster }

    // GetHandle
    function GetHandle: Cardinal;
    // GetWindowState
    function GetWindowState: TWindowState;
    // SetWindowState
    procedure SetWindowState(AWindowState: TWindowState);

    // Show
    procedure Show;
    // Hide
    procedure Hide;
    // GoBack (True is Response, False Is not Response)
    function GoBack: Boolean;
    // GoForward (True is Response, False Is not Response)
    function GoForward: Boolean;
    // IsHasChildPage
    function IsHasChildPage(ACommandId: Integer): Boolean;
    // AddChildPage
    function AddChildPage(AChildPage: IChildPage): Boolean;
    // AddCmdCookie
    function AddCmdCookie(ACommandId: Integer; AParams: string): Boolean;
    // BringToFrontChildPage
    function BringToFrontChildPage(ACommandId: Integer; AParams: string): Boolean;

    property Handle: Cardinal read GetHandle;
    property WindowState: TWindowState read GetWindowState write SetWindowState;
  end;

implementation

{ TMasterImpl }

constructor TMasterImpl.Create(AContext: IAppContext);
begin
  inherited;
  FMasterUI := TMasterUI.Create(AContext);
  FMasterUI.PopupParent := nil;
  FCmdCookieMgr := TCmdCookieMgr.Create(AContext);
  FChildPageInfoDic := TDictionary<Integer, PChildPageInfo>.Create(20);
  DoInitMasterEvents;
end;

destructor TMasterImpl.Destroy;
begin
  DoClearChildPageInfos;
  FChildPageInfoDic.Free;
  FCmdCookieMgr.Free;
  FMasterUI.Free;
  FKeyFairy := nil;
  inherited;
end;

procedure TMasterImpl.DoInitMasterEvents;
begin
  FMasterUI.OnKeyPress := DoMasterKeyPress;
  FMasterUI.OnResize := DoMasterClientChangeSize;
end;

procedure TMasterImpl.DoChildPageChangeSize(AForm: TForm);
var
  LWidth, LHeight: Integer;
begin
  LWidth := FMasterUI.ClientWidth;
  LHeight := FMasterUI.ClientHeight;
  if (LWidth <> AForm.Width) 
    and (LHeight <> AForm.Height) then begin
    SetWindowPos(AForm.Handle, 0, 0, 0, LWidth, LHeight, SWP_NOACTIVATE);
  end;
end;

procedure TMasterImpl.DoMasterClientChangeSize(Sender: TObject);
begin
  if (FFrontChildPageInfo <> nil)
    and (FFrontChildPageInfo.FChildPage <> nil) then begin
    DoChildPageChangeSize(FFrontChildPageInfo.FChildPage.GetChildPageUI);
  end;
end;

procedure TMasterImpl.DoMasterKeyPress(Sender: TObject; var Key: Char);
var
  LKey: string;
  LSecuInfo: PSecuInfo;
begin
  LKey := Char(Key);
  if FKeyFairy <> nil then begin
    FKeyFairy.Display(Self.Handle, LKey, LSecuInfo);
  end else begin
    FKeyFairy := FAppContext.FindInterface(ASF_COMMAND_ID_KEYFAIRY) as IKeyFairy;
    if FKeyFairy = nil then Exit;
    FKeyFairy.Display(Self.Handle, LKey, LSecuInfo);
  end;
end;

procedure TMasterImpl.DoClearChildPageInfos;
var
  LIndex: Integer;
  LChildPageInfo: PChildPageInfo;
  LChildPageInfos: TArray<PChildPageInfo>;
begin
  LChildPageInfos := FChildPageInfoDic.Values.ToArray;
  for LIndex := Low(LChildPageInfos) to High(LChildPageInfos) do begin
    if LChildPageInfos[LIndex] <> nil then begin
      LChildPageInfo := LChildPageInfos[LIndex];
      if LChildPageInfo.FChildPage <> nil then begin
        LChildPageInfo.FChildPage := nil;
      end;
      Dispose(LChildPageInfo);
    end;
  end;
  FChildPageInfoDic.Clear;
end;

procedure TMasterImpl.DoBringToFront(AChildPageInfo: PChildPageInfo; AParams: string);
begin
  if AChildPageInfo <> FFrontChildPageInfo then begin
    if FFrontChildPageInfo <> nil then begin
      FFrontChildPageInfo.FChildPage.GoSendToBack;
    end;
    FFrontChildPageInfo := AChildPageInfo;
    DoChildPageChangeSize(FFrontChildPageInfo.FChildPage.GetChildPageUI);
    FFrontChildPageInfo.FChildPage.GoBringToFront(AParams);
  end;
end;

function TMasterImpl.GetHandle: Cardinal;
begin
  Result := FMasterUI.Handle;
end;

function TMasterImpl.GetWindowState: TWindowState;
begin
  Result := FMasterUI.WindowState;
end;

procedure TMasterImpl.SetWindowState(AWindowState: TWindowState);
begin
  if FMasterUI.WindowState <> AWindowState then begin
    FMasterUI.WindowState := AWindowState;
  end;
end;

procedure TMasterImpl.Show;
begin
  FMasterUI.Show;
end;

procedure TMasterImpl.Hide;
begin
  FMasterUI.Hide;
end;

function TMasterImpl.GoBack: Boolean;
var
  LParams: string;
  LCmdCookie: PCmdCookie;
  LChildPageInfo: PChildPageInfo;
begin
  Result := False;
  LCmdCookie := FCmdCookieMgr.CurrCmdCookie;
  if LCmdCookie <> nil then begin
    if FChildPageInfoDic.TryGetValue(LCmdCookie^.FId, LChildPageInfo) then begin
      Result := LChildPageInfo.FChildPage.GoBack;
    end;
  end;
  if not Result then begin
    if FCmdCookieMgr.CanPrev then begin
      FCmdCookieMgr.Prev(LCmdCookie);
      if LCmdCookie <> nil then begin
        if LCmdCookie.FParams <> '' then begin
          LParams := 'GoFuncName=GoBack@' + LCmdCookie.FParams;
        end else begin
          LParams := 'GoFuncName=GoBack';
        end;
      end;
    end;
  end;
end;

function TMasterImpl.GoForward: Boolean;
var
  LParams: string;
  LCmdCookie: PCmdCookie;
  LChildPageInfo: PChildPageInfo;
begin
  Result := False;
  LCmdCookie := FCmdCookieMgr.CurrCmdCookie;
  if LCmdCookie <> nil then begin
    if FChildPageInfoDic.TryGetValue(LCmdCookie^.FId, LChildPageInfo) then begin
      Result := LChildPageInfo.FChildPage.GoForward;
    end;
  end;
  if not Result then begin
    if FCmdCookieMgr.CanNext then begin
      FCmdCookieMgr.Next(LCmdCookie);
      if LCmdCookie <> nil then begin
        if LCmdCookie.FParams <> '' then begin
          LParams := 'GoFuncName=GoForward@' + LCmdCookie.FParams;
        end else begin
          LParams := 'GoFuncName=GoForward';
        end;
      end;
    end;
  end;
end;

function TMasterImpl.IsHasChildPage(ACommandId: Integer): Boolean;
var
  LChildPageInfo: PChildPageInfo;
begin
  if FChildPageInfoDic.TryGetValue(ACommandId, LChildPageInfo) then begin
    Result := True;
  end else begin
    Result := False;
  end;
end;

function TMasterImpl.AddChildPage(AChildPage: IChildPage): Boolean;
var
  LForm: TForm;
  LChildPageInfo: PChildPageInfo;
begin
  Result := False;
  if not FChildPageInfoDic.ContainsKey(AChildPage.CommandId) then begin
    New(LChildPageInfo);
    if LChildPageInfo <> nil then begin
      Result := True;
      LChildPageInfo.FChildPage := AChildPage;
      FChildPageInfoDic.AddOrSetValue(AChildPage.CommandId, LChildPageInfo);
      LForm := AChildPage.GetChildPageUI;
      LForm.ParentWindow := FMasterUI.Handle;
      LForm.Show;
    end;
  end;
end;

function TMasterImpl.AddCmdCookie(ACommandId: Integer; AParams: string): Boolean;
begin
  FCmdCookieMgr.Push(ACommandId, AParams);
end;

function TMasterImpl.BringToFrontChildPage(ACommandId: Integer; AParams: string): Boolean;
var
  LChildPageInfo: PChildPageInfo;
begin
  Result := False;
  if FChildPageInfoDic.TryGetValue(ACommandId, LChildPageInfo) then begin
    Result := True;
    DoBringToFront(LChildPageInfo, AParams);
    SetActiveWindow(Self.Handle);
  end;
end;

end.
