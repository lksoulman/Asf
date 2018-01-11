unit ChromeImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º Chrome Implementation
// Author£º      lksoulman
// Date£º        2017-12-26
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Chrome,
  Browser,
  LogLevel,
  BaseObject,
  AppContext,
  CommonLock;
//  DcefB.Core.App,
//  DcefB.Cef3.Types,
//  DcefB.Cef3.Classes,
//  DcefB.Cef3.Interfaces;

type

  // Cefv8HandlerOwnEx
//  TCefv8HandlerOwnEx = class(TCefv8HandlerOwn)
//  private
//    // Cefv8Context
//    FCefv8Context: ICefv8Context;
//  protected
//    // Execute
//    function Execute(const name: ustring; const Obj: ICefv8Value; const arguments: TCefv8ValueArray;
//      var retval: ICefv8Value; var exception: ustring): Boolean; override;
//  public
//    // Constructor
//    constructor Create(AContext: ICefv8Context); reintroduce;
//    // Destructor
//    destructor Destroy; override;
//    // DoFocusedNodeChanged
//    procedure DoFocusedNodeChanged(const ABrowser: ICefBrowser; const AFrame: ICefFrame; const ANode: ICefDomNode);
//  end;

  // Chrome Implementation
  TChromeImpl = class(TBaseInterfacedObject, IChrome)
  private
  protected
    // IsInit
    FIsInit: Boolean;
    // IsInitSuccess
    FIsInitSuccess: Boolean;
    // IsSingleProcess
    FIsSingleProcess: Boolean;
    // Lock
    FLock: TCSLock;
    // AppPath
    FAppPath: string;
    // CefExVals
    FCefExVals: TStringList;
    // DoContextCreated
//    procedure DoContextCreated(const ABrowser: ICefBrowser; const AFrame: ICefFrame; const AContext: ICefv8Context);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IAppChrome }

    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // InitChrome
    procedure InitChrome;
    // IsInitSuccess
    function IsInitSuccess: Boolean;
    // CreateBrowser
    function CreateBrowser: IBrowser;
  end;

implementation

uses
  BrowserImpl;

const

  FUNCNAME_TEST = 'Test';

{ TCefv8HandlerOwnEx }

//constructor TCefv8HandlerOwnEx.Create(AContext: ICefv8Context);
//begin
//  inherited Create;
//  FCefv8Context := AContext;
//end;
//
//destructor TCefv8HandlerOwnEx.Destroy;
//begin
//  FCefv8Context := nil;
//  inherited;
//end;
//
//procedure TCefv8HandlerOwnEx.DoFocusedNodeChanged(const ABrowser: ICefBrowser;
//  const AFrame: ICefFrame; const ANode: ICefDomNode);
//begin
//
//end;
//
//function TCefv8HandlerOwnEx.Execute(const name: ustring; const Obj: ICefv8Value;
//  const arguments: TCefv8ValueArray; var retval: ICefv8Value;
//  var exception: ustring): Boolean;
//begin
//
//end;

{ TChromeImpl }

constructor TChromeImpl.Create(AContext: IAppContext);
begin
  inherited;
  FIsInit := False;
  FIsInitSuccess := False;
  FIsSingleProcess := False;
  FLock := TCSLock.Create;
  FCefExVals := TStringList.Create;
  FAppPath := ExtractFilePath(ParamStr(0));
  FAppPath := ExpandFileName(FAppPath + '..\');
end;

destructor TChromeImpl.Destroy;
begin
//  if DcefBApp <> nil then begin
//    DcefBApp.OnContextCreated := nil;
//  end;
  FCefExVals.Free;
  FLock.Free;
  inherited;
end;

procedure TChromeImpl.Lock;
begin
  FLock.Lock;
end;

procedure TChromeImpl.UnLock;
begin
  FLock.UnLock;
end;

procedure TChromeImpl.InitChrome;
var
  LTick: Cardinal;
begin
  if not FIsInit then begin
    LTick := GetTickCount;
    try
//      if DcefBApp <> nil then begin
//        DcefBApp.CefLocalesDirPath := FAppPath + 'Bin\AsfCef\locales\';
//        DcefBApp.CefLibrary := FAppPath + 'Bin\AsfCef\libcef.dll';
//        DcefBApp.CefCache := FAppPath + 'Cache\Cef\';
//        DcefBApp.CefLocale := 'zh-CN';
//        DcefBApp.OnContextCreated := DoContextCreated;
//      end;
    finally
      LTick := GetTickCount - LTick;
      FAppContext.SysLog(llSLOW, '[TAppChromeImpl][InitChrome]', LTick);
    end;
    FIsInit := True;
  end;
end;

function TChromeImpl.IsInitSuccess: Boolean;
begin
  Result := FIsInitSuccess;
end;

function TChromeImpl.CreateBrowser: IBrowser;
begin
  if FIsInitSuccess then begin
    Result := TBrowserImpl.Create(FAppContext, Self) as IBrowser;
  end else begin
    Result := nil;
  end;
end;

//procedure TChromeImpl.DoContextCreated(const ABrowser: ICefBrowser; const AFrame: ICefFrame;
//  const AContext: ICefv8Context);
////var
////  LCefv8Handler: TCefv8HandlerOwnEx;
//begin
////  LCefv8Handler := TCefv8HandlerOwnEx.Create(AContext);
////  TCefv8ValueRef.NewFunction(FUNCNAME_TEST, LCefv8Handler);
//
//end;

end.
