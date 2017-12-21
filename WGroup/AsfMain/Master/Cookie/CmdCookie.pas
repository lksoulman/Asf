unit CmdCookie;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º CmdCookie
// Author£º      lksoulman
// Date£º        2017-12-19
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  BaseObject,
  AppContext,
  CommonPool,
  CommonLock;

type

  // CmdCookie Pointer
  PCmdCookie = ^TCmdCookie;

  // CmdCookie
  TCmdCookie = packed record
    FId: Integer;
    FParams: string;
    FPrev: PCmdCookie;
    FNext: PCmdCookie;
  end;

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

  // CmdCookieMgr
  TCmdCookieMgr = class(TBaseObject)
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
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // CanPrev
    function CanPrev: Boolean;
    // CanNext
    function CanNext: Boolean;
    // CurrCmdCookie
    function CurrCmdCookie: PCmdCookie;
    // Prev
    function Prev(var ACookie: PCmdCookie): Boolean;
    // Next
    function Next(var ACookie: PCmdCookie): Boolean;
    // Push
    function Push(ACommandId: Integer; AParams: string): Boolean;
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

{ TCmdCookieMgr }

constructor TCmdCookieMgr.Create(AContext: IAppContext);
begin
  inherited;
  FLock := TCSLock.Create;
  FCmdCookiePool := TCmdCookiePool.Create(10);
end;

destructor TCmdCookieMgr.Destroy;
begin
  DoClearItems(FHead);
  FCmdCookiePool.Free;
  FLock.Free;
  inherited;
end;

procedure TCmdCookieMgr.DoClearItems(ACookie: PCmdCookie);
var
  LNext, LTemp: PCmdCookie;
begin
  LNext := ACookie;
  while LNext <> nil do begin
    LTemp := LNext.FNext;
    FCmdCookiePool.DeAllocate(LNext);
    LNext := LTemp;
  end;
end;

function TCmdCookieMgr.CanPrev: Boolean;
begin
  if (FMovePtr <> nil)
    and (FMovePtr^.FPrev <> nil) then begin
    Result := True;
  end else begin
    Result := False;
  end;
end;

function TCmdCookieMgr.CanNext: Boolean;
begin
  if (FMovePtr <> nil)
    and (FMovePtr^.FNext <> nil) then begin
    Result := True;
  end else begin
    Result := False;
  end;
end;

function TCmdCookieMgr.CurrCmdCookie: PCmdCookie;
begin
  Result := FMovePtr;
end;

function TCmdCookieMgr.Prev(var ACookie: PCmdCookie): Boolean;
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

function TCmdCookieMgr.Next(var ACookie: PCmdCookie): Boolean;
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

function TCmdCookieMgr.Push(ACommandId: Integer; AParams: string): Boolean;
var
  LCookie: PCmdCookie;
begin
  Result := False;
  LCookie := PCmdCookie(FCmdCookiePool.Allocate);

  if LCookie = nil then Exit;
  
  if (FMovePtr <> nil) then begin
    if FMovePtr^.FNext <> nil then begin
      DoClearItems(FMovePtr^.FNext);
    end;
    FMovePtr^.FNext := LCookie;
    LCookie.FPrev := FMovePtr;
    FMovePtr := LCookie;
  end else begin
    FHead := LCookie;
    FMovePtr := LCookie;
  end;
end;

end.
