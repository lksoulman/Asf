unit MsgExSubcriberMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º MsgExSubcriberMgr
// Author£º      lksoulman
// Date£º        2017-12-08
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  Windows,
  Classes,
  SysUtils,
  CommonLock,
  BaseObject,
  AppContext,
  MsgExSubcriber,
  Generics.Collections;

type

  // MsgExSubcriberMgr
  TMsgExSubcriberMgr = class(TBaseObject)
  private
    // Lock
    FLock: TCSLock;
    // MsgExSubcriberDic
    FMsgExSubcriberDic: TDictionary<Integer, TList<IMsgExSubcriber>>;
  protected
    // ClearSubcribers
    procedure DoClearSubcribers;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // InvokeNotify
    procedure InvokeNotify(AMsgEx: TMsgEx);
    // Subcriber
    procedure Subcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
    // UnSubcriber
    procedure UnSubcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
  end;

implementation

uses
  LogLevel;

{ TMsgExSubcriberMgr }

constructor TMsgExSubcriberMgr.Create(AContext: IAppContext);
begin
  inherited;
  FLock := TCSLock.Create;
  FMsgExSubcriberDic := TDictionary<Integer, TList<IMsgExSubcriber>>.Create;
end;

destructor TMsgExSubcriberMgr.Destroy;
begin
  DoClearSubcribers;
  FMsgExSubcriberDic.Free;
  FLock.Free;
  inherited;
end;

procedure TMsgExSubcriberMgr.DoClearSubcribers;
var
  LIndex: Integer;
  LSubcribers: TList<IMsgExSubcriber>;
  LEnum: TDictionary<Integer, TList<IMsgExSubcriber>>.TPairEnumerator;
begin
  LEnum := FMsgExSubcriberDic.GetEnumerator;
  try
    while LEnum.MoveNext do begin
      LSubcribers := LEnum.Current.Value;
      if (LSubcribers <> nil) then begin
        if LSubcribers.Count > 0 then begin
          for LIndex := 0 to LSubcribers.Count - 1 do begin
            LSubcribers.Items[LIndex] := nil;
          end;
        end;
        LSubcribers.Free;
      end;
    end;
    FMsgExSubcriberDic.Clear;
  finally
    LEnum.Free;
  end;
end;

procedure TMsgExSubcriberMgr.InvokeNotify(AMsgEx: TMsgEx);
var
  LIndex: Integer;
  LSubcribers: TList<IMsgExSubcriber>;
begin
  FLock.Lock;
  try
    if FMsgExSubcriberDic.TryGetValue(AMsgEx.GetId, LSubcribers) then begin
      for LIndex := 0 to LSubcribers.Count - 1 do begin
        if (LSubcribers.Items[LIndex] <> nil)
          and LSubcribers.Items[LIndex].GetActive then begin
          try
            LSubcribers.Items[LIndex].InvokeNotify(AMsgEx);
          except
            on Ex: Exception do begin
              FAppContext.SysLog(llERROR, Format('[%s] InvokeNotify MsgEx(Id=%d, Info=%s) is Exception, Exception is %s.',
                [LSubcribers.Items[LIndex].GetLogInfo, AMsgEx.GetId, AMsgEx.GetInfo, Ex.Message]));
            end;
          end;
        end;
      end;
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TMsgExSubcriberMgr.Subcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
var
  LSubcribers: TList<IMsgExSubcriber>;
begin
  if ASubcriber = nil then Exit;

  FLock.Lock;
  try
    if FMsgExSubcriberDic.TryGetValue(AMsgExId, LSubcribers) then begin
      if LSubcribers.IndexOf(ASubcriber) < 0 then begin
        LSubcribers.Add(ASubcriber);
      end;
    end else begin
      LSubcribers := TList<IMsgExSubcriber>.Create;
      LSubcribers.Add(ASubcriber);
      FMsgExSubcriberDic.AddOrSetValue(AMsgExId, LSubcribers);
    end;
  finally
    FLock.UnLock;
  end;
end;

procedure TMsgExSubcriberMgr.UnSubcriber(AMsgExId: Integer; ASubcriber: IMsgExSubcriber);
var
  LSubcribers: TList<IMsgExSubcriber>;
begin
  if ASubcriber = nil then Exit;

  FLock.Lock;
  try
    if FMsgExSubcriberDic.TryGetValue(AMsgExId, LSubcribers) then begin
      LSubcribers.Remove(ASubcriber);
    end;
  finally
    FLock.UnLock;
  end;
end;

end.
