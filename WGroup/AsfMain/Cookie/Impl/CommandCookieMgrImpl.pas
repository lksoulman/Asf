unit CommandCookieMgrImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º CommandCookie Implementation
// Author£º      lksoulman
// Date£º        2017-11-23
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  AppContext,
  CommonPool,
  CommonLock,
  CommandCookieMgr,
  CommonRefCounter,
  Generics.Collections;

type

  // CmdCookiePool
  TCmdCookiePool = class(TPointerPool)
  private
  protected
  // Create
    function DoCreate: Pointer; override;
    // Destroy
    procedure DoDestroy(APointer: Pointer); override;
    // Allocate Before
    procedure DoAllocateBefore(APointer: Pointer); override;
    // DeAllocate Before
    procedure DoDeAllocateBefore(APointer: Pointer); override;
  end;

  // CommandCookie
  TCommandCookie = class(TAutoObject)
  private
    // Lock
    FLock: TCSLock;
    // Head
    FHead: PCmdCookie;
    // MovePtr
    FMovePtr: PCmdCookie;
    // CmdCookiePool
    FCmdCookiePool: TCmdCookiePool;
  protected
    // DoClearItems
    procedure DoClearItems(ACookie: PCmdCookie);
  public
    // Constructor
    constructor Create(ACookiePool: TCmdCookiePool); reintroduce;
    // Destructor
    destructor Destroy; override;
    // CanPrev
    function CanPrev: Boolean;
    // CanNext
    function CanNext: Boolean;
    // Allocate
    function Allocate: PCmdCookie;
    // Push
    function Push(ACookie: PCmdCookie): Boolean;
    // Prev
    function Prev(var ACookie: PCmdCookie): Boolean;
    // Next
    function Next(var ACookie: PCmdCookie): Boolean;
  end;

  // CommandCookieMgr Implementation
  TCommandCookieMgrImpl = class(TAutoInterfacedObject, ICommandCookieMgr)
  private
    // AppContext
    FAppContext: IAppContext;
    // CmdCookiePool
    FCmdCookiePool: TCmdCookiePool;
    // CommandCookies
    FCommandCookies: TList<TCommandCookie>;
    // CommandCookieDic
    FCommandCookieDic: TDictionary<Integer, TCommandCookie>;
  protected
    // ClearCookie
    procedure DoClearCommandCookies;
  public
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce;
    // Destructor
    destructor Destroy; override;

    { ICommandCookie }

    // CanPrev
    function CanPrev(AHandle: Integer): Boolean;
    // CanNext
    function CanNext(AHandle: Integer): Boolean;
    // Allocate
    function Allocate(AHandle: Integer): PCmdCookie;
    // Push
    function Push(AHandle: Integer; ACookie: PCmdCookie): Boolean;
    // Prev
    function Prev(AHandle: Integer; var ACookie: PCmdCookie): Boolean;
    // Next
    function Next(AHandle: Integer; var ACookie: PCmdCookie): Boolean;
  end;

implementation

{ TCmdCookiePool }

function TCmdCookiePool.DoCreate: Pointer;
var
  LCmdItem: PCmdCookie;
begin
  New(LCmdItem);
  LCmdItem^.FId := 0;
  LCmdItem^.FParams := '';
  LCmdItem^.FPrev := nil;
  LCmdItem^.FNext := nil;
  Result := LCmdItem;
end;

procedure TCmdCookiePool.DoDestroy(APointer: Pointer);
begin
  if APointer <> nil then begin
    Dispose(APointer);
  end;
end;

procedure TCmdCookiePool.DoAllocateBefore(APointer: Pointer);
begin

end;

procedure TCmdCookiePool.DoDeAllocateBefore(APointer: Pointer);
begin
  if APointer <> nil then begin
    PCmdCookie(APointer)^.FId := 0;
    PCmdCookie(APointer)^.FParams := '';
    PCmdCookie(APointer)^.FPrev := nil;
    PCmdCookie(APointer)^.FNext := nil;
  end;
end;

{ TCommandCookie }

constructor TCommandCookie.Create(ACookiePool: TCmdCookiePool);
begin
  inherited Create;
  FCmdCookiePool := ACookiePool;
  FLock := TCSLock.Create;
end;

destructor TCommandCookie.Destroy;
begin
  DoClearItems(FHead);
  FLock.Free;
  FCmdCookiePool := nil;
  inherited;
end;

procedure TCommandCookie.DoClearItems(ACookie: PCmdCookie);
var
  LNext, LTemp: PCmdCookie;
begin
  LNext := ACookie;
  while ACookie <> nil do begin
    LTemp := LNext.FNext;
    FCmdCookiePool.DeAllocate(LNext);
    LNext := LTemp;
  end;
end;

function TCommandCookie.CanPrev: Boolean;
begin
  if (FMovePtr <> nil)
    and (FMovePtr^.FPrev <> nil) then begin
    Result := True;
  end else begin
    Result := False;
  end;
end;

function TCommandCookie.CanNext: Boolean;
begin
  if (FMovePtr <> nil)
    and (FMovePtr^.FNext <> nil) then begin
    Result := True;
  end else begin
    Result := False;
  end;
end;

function TCommandCookie.Allocate: PCmdCookie;
begin
  Result := PCmdCookie(FCmdCookiePool.Allocate);
end;

function TCommandCookie.Push(ACookie: PCmdCookie): Boolean;
begin
  Result := False;
  if ACookie = nil then Exit;

  Result := True;
  if (FMovePtr <> nil)
    and (FMovePtr^.FNext <> nil) then begin
    DoClearItems(FMovePtr^.FNext);
    FMovePtr^.FNext := ACookie;
    ACookie.FPrev := FMovePtr;
    FMovePtr := ACookie;
  end else begin
    FHead := ACookie;
    FMovePtr := ACookie;
  end;
end;

function TCommandCookie.Prev(var ACookie: PCmdCookie): Boolean;
begin
  if CanPrev then begin
    Result := True;
    FMovePtr := FMovePtr.FPrev;
    ACookie := FMovePtr;
  end else begin
    Result := False;
    ACookie := nil;
  end;
end;

function TCommandCookie.Next(var ACookie: PCmdCookie): Boolean;
begin
  if CanNext then begin
    Result := True;
    FMovePtr := FMovePtr.FNext;
    ACookie := FMovePtr;
  end else begin
    Result := False;
    ACookie := nil;
  end;
end;

{ TCommandCookieMgrImpl }

constructor TCommandCookieMgrImpl.Create(AContext: IAppContext);
begin
  inherited Create;
  FAppContext := AContext;
  FCmdCookiePool := TCmdCookiePool.Create(20);
  FCommandCookies := TList<TCommandCookie>.Create;
  FCommandCookieDic := TDictionary<Integer, TCommandCookie>.Create(5);
end;

destructor TCommandCookieMgrImpl.Destroy;
begin
  DoClearCommandCookies;
  FCommandCookieDic.Free;
  FCommandCookies.Free;
  FCmdCookiePool.Free;
  FAppContext := nil;
  inherited;
end;

procedure TCommandCookieMgrImpl.DoClearCommandCookies;
var
  LIndex: Integer;
  LCommandCookie: TCommandCookie;
begin
  for LIndex := 0 to FCommandCookies.Count - 1 do begin
    LCommandCookie := FCommandCookies.Items[LIndex];
    if LCommandCookie <> nil then begin
      LCommandCookie.Free;
    end;
  end;
  FCommandCookies.Clear;
end;

function TCommandCookieMgrImpl.CanPrev(AHandle: Integer): Boolean;
var
  LCommandCookie: TCommandCookie;
begin
  if FCommandCookieDic.TryGetValue(AHandle, LCommandCookie) then begin
    Result := LCommandCookie.CanPrev;
  end else begin
    Result := False;
  end;
end;

function TCommandCookieMgrImpl.CanNext(AHandle: Integer): Boolean;
var
  LCommandCookie: TCommandCookie;
begin
  if FCommandCookieDic.TryGetValue(AHandle, LCommandCookie) then begin
    Result := LCommandCookie.CanNext;
  end else begin
    Result := False;
  end;
end;

function TCommandCookieMgrImpl.Allocate(AHandle: Integer): PCmdCookie;
begin
  Result := PCmdCookie(FCmdCookiePool.Allocate);
end;

function TCommandCookieMgrImpl.Push(AHandle: Integer; ACookie: PCmdCookie): Boolean;
var
  LCommandCookie: TCommandCookie;
begin
  Result := False;
  if (ACookie = nil)
    or (AHandle = 0) then Exit;

  if FCommandCookieDic.TryGetValue(AHandle, LCommandCookie) then begin
    Result := LCommandCookie.Push(ACookie);
  end else begin
    LCommandCookie := TCommandCookie.Create(FCmdCookiePool);
    Result := LCommandCookie.Push(ACookie);
  end;
end;

function TCommandCookieMgrImpl.Prev(AHandle: Integer; var ACookie: PCmdCookie): Boolean;
var
  LCommandCookie: TCommandCookie;
begin
  if FCommandCookieDic.TryGetValue(AHandle, LCommandCookie) then begin
    Result := LCommandCookie.Prev(ACookie);
  end else begin
    Result := False;
  end;
end;

function TCommandCookieMgrImpl.Next(AHandle: Integer; var ACookie: PCmdCookie): Boolean;
var
  LCommandCookie: TCommandCookie;
begin
  if FCommandCookieDic.TryGetValue(AHandle, LCommandCookie) then begin
    Result := LCommandCookie.Next(ACookie);
  end else begin
    Result := False;
  end;
end;

end.

