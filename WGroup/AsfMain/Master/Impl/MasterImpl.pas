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
  Vcl.Forms,
  Master,
  MasterUI,
//  ChildPage,
  AppContext,
  AppContextObject,
  CommonRefCounter,
  Generics.Collections;

type

  // Child Page Info
  TChildPageInfo = packed record
    //
//    FChildPage: IChildPage;
  end;

  // Child Page Info Pointer
  PChildPageInfo = ^TChildPageInfo;

  // Master Implementation
  TMasterImpl = class(TAppContextObject, IMaster)
  private
    // MasterUI
    FMasterUI: TMasterUI;
    // CurrChildPageInfo
    FCurrChildPageInfo: PChildPageInfo;
    // ChildPageInfo
    FChildPageInfos: TList<PChildPageInfo>;
  protected
    // ClearChildPageInfo
    procedure DoClearChildPageInfos;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IMaster }

    // Show
    procedure Show;
    // Hide
    procedure Hide;
    // Go Back (True is Response, False Is not Response)
    function GoBack: Boolean;
    // Go Forward (True is Response, False Is not Response)
    function GoForward: Boolean;
    // Get Handle
    function GetHandle: Cardinal;
    // Get Count
    function GetPageCount: Integer;
    // Get Active Page
//    function GetActivePage: IChildPage;
//    // Find Page
//    function FindPage(ACommandId: Integer): IChildPage;
//    // Add ChildPage
//    procedure AddChildPage(AChildPage: IChildPage);
//    // Set ActivatePage
//    procedure SetActivatePage(AChildPage: IChildPage);
    // Set WindowState
    procedure SetWindowState(AWindowState: TWindowState);
  end;

implementation

{ TMasterImpl }

constructor TMasterImpl.Create(AContext: IAppContext);
begin
  inherited;
  FMasterUI := TMasterUI.Create(AContext);
  FMasterUI.PopupParent := nil;
  FChildPageInfos := TList<PChildPageInfo>.Create;
end;

destructor TMasterImpl.Destroy;
begin
  FChildPageInfos.Free;
  FMasterUI.Free;
  inherited;
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
begin

end;

function TMasterImpl.GoForward: Boolean;
begin

end;

function TMasterImpl.GetHandle: Cardinal;
begin
  Result := FMasterUI.Handle;
end;

function TMasterImpl.GetPageCount: Integer;
begin
  Result := FChildPageInfos.Count;
end;

//function TMasterImpl.GetActivePage: IChildPage;
//begin
//  Result := FCurrChildPageInfo^.FChildPage;
//end;
//
//function TMasterImpl.FindPage(ACommandId: Integer): IChildPage;
//var
//  LChildPageInfo: PChildPageInfo;
//begin
////  if FCommandChildPageInfoDic.TryGetValue(ACommandId, LChildPageInfo) then begin
////    Result := LChildPageInfo^.FChildPage;
////  end else begin
////    Result := nil;
////  end;
//end;
//
//procedure TMasterImpl.AddChildPage(AChildPage: IChildPage);
//var
//  LChildPageInfo: PChildPageInfo;
//begin
//  if AChildPage = nil then Exit;
//
////  if not FCommandChildPageInfoDic.ContainsKey(AChildPage.GetCommandId) then begin
////    New(LChildPageInfo);
////    LChildPageInfo^.FChildPage := AChildPage;
////    FChildPageInfos.Add(LChildPageInfo);
////    FCommandChildPageInfoDic.AddOrSetValue(AChildPage.GetCommandId, LChildPageInfo);
////  end;
//end;
//
//procedure TMasterImpl.SetActivatePage(AChildPage: IChildPage);
//var
//  LChildPageInfo: PChildPageInfo;
//begin
//  if AChildPage = nil then Exit;
//
//  if FCurrChildPageInfo^.FChildPage <> AChildPage then begin
//    if FCurrChildPageInfo^.FChildPage <> nil then begin
//      FCurrChildPageInfo^.FChildPage.SetNoActivate;
//      FCurrChildPageInfo := nil;
//    end;
////    if FCommandChildPageInfoDic.TryGetValue(AChildPage.GetCommandId, LChildPageInfo) then begin
////      FCurrChildPageInfo := LChildPageInfo;
////      if (FCurrChildPageInfo <> nil)
////        and (FCurrChildPageInfo^.FChildPage <> nil)then begin
////        FCurrChildPageInfo.FChildPage.SetActivate;
////      end;
////    end;
//  end;
//end;

procedure TMasterImpl.SetWindowState(AWindowState: TWindowState);
begin
  if FMasterUI.WindowState <> AWindowState then begin
    FMasterUI.WindowState := AWindowState;
  end;
end;

procedure TMasterImpl.DoClearChildPageInfos;
var
  LIndex: Integer;
  LChildPageInfo: PChildPageInfo;
begin
//  for LIndex := 0 to FChildPageInfos.Count - 1 do begin
//    LChildPageInfo := FChildPageInfos.Items[LIndex];
//    if LChildPageInfo <> nil then begin
//      if LChildPageInfo.FChildPage <> nil then begin
//        LChildPageInfo.FChildPage := nil;
//      end;
//      Dispose(LChildPageInfo);
//    end;
//  end;
end;

end.
