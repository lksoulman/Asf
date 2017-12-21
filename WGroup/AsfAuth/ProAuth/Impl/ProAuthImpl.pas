unit ProAuthImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º ProdAuth Implementation
// Author£º      lksoulman
// Date£º        2017-8-17
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  ProAuth,
  Windows,
  Classes,
  SysUtils,
  BaseObject,
  AppContext,
  WNDataSetInf,
  Generics.Collections;

type

  // ProdAuth Implementation
  TProAuthImpl = class(TBaseInterfacedObject, IProAuth)
  private
    type
      // Authority
      TAuthority = packed record
        FFuncNo: Integer;       // Function No
        FFuncName: string;      // Function Name
        FEndDate: TDateTime;    // Start Date
        FStartDate: TDateTime;  // End Date
      end;
      // Authority Pointer
      PAuthority = ^TAuthority;
  private
    // Product Authority Dictionary
    FAuthorityDic: TDictionary<Integer, PAuthority>;
  protected
    // Get Authority
    procedure DoGetAuthority;
    // Clear Authority Dictionary
    procedure DoClearAuthorityDic;
    // Load Data
    procedure DoLoadData(ADataSet: IWNDataSet; ANoField, ANameField, ASDateField, AEDateField: IWNField);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IProAuth }

    // Update
    procedure Update;
    // GetIsHasAuth
    function GetIsHasAuth(AFuncNo: Integer): Boolean;
  end;

implementation

uses
  Login,
  LogLevel,
  ServiceType;

{ TProAuthImpl }

constructor TProAuthImpl.Create(AContext: IAppContext);
begin
  inherited;
  FAuthorityDic := TDictionary<Integer, PAuthority>.Create;
end;

destructor TProAuthImpl.Destroy;
begin
  DoClearAuthorityDic;
  FAuthorityDic.Free;
  inherited;
end;

procedure TProAuthImpl.Update;
begin
  if FAppContext.IsLogin(stBasic) then begin
    DoGetAuthority;
  end else begin
    FAppContext.SysLog(llERROR, '[TProAuthImpl][Update] IsLogin(stBasic) return is false, permission is not load.');
  end;
end;

function TProAuthImpl.GetIsHasAuth(AFuncNo: Integer): Boolean;
begin
  Result := FAuthorityDic.ContainsKey(AFuncNo);
end;

procedure TProAuthImpl.DoGetAuthority;
var
{$IFDEF DEBUG}
  LTick: Cardinal;
{$ENDIF}
  LDataSet: IWNDataSet;
  LNoField, LNameField, LEDateField, LSDateField: IWNField;
begin
{$IFDEF DEBUG}
  LTick := GetTickCount;
  try
{$ENDIF}

    LDataSet := FAppContext.GFPrioritySyncQuery(stBasic, 'USER_QX', 100000);
    if (LDataSet <> nil) and (LDataSet.RecordCount > 0) then begin
      LNoField := LDataSet.FieldByName('mkid');
      LNameField := LDataSet.FieldByName('qx');
      LEDateField := LDataSet.FieldByName('jzrq');
      LSDateField := LDataSet.FieldByName('qsrq');

      if (LNoField = nil) then begin
        FAppContext.IndicatorLog(llERROR, Format('[TProAuthImpl][DoGetAuthority] [Indicator][USER_QX] Return field %s is nil.', ['FuncNo']));
        Exit;
      end;
      if (LNameField = nil) then begin
        FAppContext.IndicatorLog(llERROR, Format('[TProAuthImpl][DoGetAuthority] [Indicator][USER_QX] Return field %s is nil.', ['FuncName']));
        Exit;
      end;

      if (LEDateField = nil) then begin
        FAppContext.IndicatorLog(llERROR, Format('[TProAuthImpl][DoGetAuthority] [Indicator][USER_QX] Return field %s is nil.', ['EndDate']));
        Exit;
      end;

      if (LSDateField = nil) then begin
        FAppContext.IndicatorLog(llERROR, Format('[TProAuthImpl][DoGetAuthority] [Indicator][USER_QX] Return field %s is nil.', ['StartDate']));
        Exit;
      end;
      DoLoadData(LDataSet, LNoField, LNameField, LSDateField, LEDateField);
      LDataSet := nil;
    end;

{$IFDEF DEBUG}
  finally
    LTick := GetTickCount - LTick;
    FAppContext.SysLog(llSLOW, Format('[TProAuthImpl][DoGetAuthority] Load permissions data to dictionary use time is %d ms.', [LTick]), LTick);
  end;
{$ENDIF}
end;

procedure TProAuthImpl.DoClearAuthorityDic;
var
  LPAuthority: PAuthority;
  LEnum: TDictionary<Integer, PAuthority>.TPairEnumerator;
begin
  LEnum := FAuthorityDic.GetEnumerator;
  try
    while LEnum.MoveNext do begin
      LPAuthority := LEnum.Current.Value;
      if (LPAuthority <> nil) then begin
        Dispose(LPAuthority);
      end;
    end;
  finally
    LEnum.Free;
  end;
  FAuthorityDic.Clear;
end;

procedure TProAuthImpl.DoLoadData(ADataSet: IWNDataSet; ANoField, ANameField, ASDateField, AEDateField: IWNField);
var
  LFuncNo: Integer;
  LPAuthority: PAuthority;
begin
  ADataSet.First;
  try
    while not ADataSet.Eof do begin
      LFuncNo := ANoField.AsInteger;
      if FAuthorityDic.TryGetValue(LFuncNo, LPAuthority)
        and (LPAuthority <> nil) then begin
        FAppContext.IndicatorLog(llERROR, Format('[TProAuthImpl][DoLoadData] [Indicator][USER_QX] return dataset FuncNo(%d) is repeated.', [LFuncNo]));
      end else begin
        New(LPAuthority);
        FAuthorityDic.AddOrSetValue(LFuncNo, LPAuthority);
      end;
      LPAuthority^.FFuncNo := LFuncNo;
      LPAuthority^.FFuncName := ANameField.AsString;
      LPAuthority^.FEndDate := AEDateField.AsDateTime;
      LPAuthority^.FStartDate := ASDateField.AsDateTime;
      ADataSet.Next;
    end;
  except
    on Ex: Exception do begin
      FAppContext.SysLog(llError, Format('[TProAuthImpl][DoLoadData] Load data is exception, exception is %s.', [Ex.Message]));
    end;
  end;
end;

end.
