unit BaseObject;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º BaseObject
// Author£º      lksoulman
// Date£º        2017-12-18
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Command,
  AppContext,
  QuoteMessage,
  QuoteMngr_TLB,
  QuoteManagerEx,
  CommonRefCounter;

type

  // BaseObject
  TBaseObject = class(TAutoObject)
  private
  protected
    // AppContext
    FAppContext: IAppContext;
  public
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
  end;

  // BaseHqObject
  TBaseHqObject = class(TBaseObject)
  private
    // InitQuoteMessage
    procedure DoInitHqMessage;
    // UnInitQuoteMessage
    procedure DoUnInitHqMessage;
  protected
    // QuoteMessage
    FQuoteMessage: IQuoteMessage;
    // QuoteManagerEx
    FQuoteManagerEx: IQuoteManagerEx;

    // ReSubcribeHqData
    procedure DoReSubcribeHqData; virtual;
    // UnSubcirbeHqData
    procedure DoUnSubcirbeHqData; virtual;
    // InfoReset
    procedure DoInfoReset(AQuoteType: QuoteTypeEnum; APointer: Pointer); virtual;
    // DataReset
    procedure DoDataReset(AQuoteType: QuoteTypeEnum; APointer: Pointer); virtual;
    // DataArrive
    procedure DoDataArrive(AQuoteType: QuoteTypeEnum; APointer: Pointer); virtual;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // ReSubcribeHqData
    procedure ReSubcribeHqData;
    // UnSubcirbeHqData
    procedure UnSubcirbeHqData;
    // SetSubcribeState
    procedure SetSubcribeState(Active: Boolean);
  end;

  // BaseInterfacedObject
  TBaseInterfacedObject = class(TAutoInterfacedObject)
  private
  protected
    // AppContext
    FAppContext: IAppContext;
  public
    // Constructor
    constructor Create(AContext: IAppContext); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
  end;

  // BaseSplitStrInterfacedObject
  TBaseSplitStrInterfacedObject = class(TBaseInterfacedObject)
  private
  protected
    // FastSplit Params
    FFastSplitParams: TStringList;

    // EndSplit
    procedure EndSplitParams;
    // BeginSplit
    procedure BeginSplitParams(AParams: string);
    // ParamsVal
    procedure ParamsVal(AName: string; var AVal: string);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
  end;

  // BaseHqInterfacedObject
  TBaseHqInterfacedObject = class(TBaseInterfacedObject)
  private
    // InitQuoteMessage
    procedure DoInitHqMessage;
    // UnInitQuoteMessage
    procedure DoUnInitHqMessage;
  protected
    // QuoteMessage
    FQuoteMessage: IQuoteMessage;
    // QuoteManagerEx
    FQuoteManagerEx: IQuoteManagerEx;

    // ReSubcribeHqData
    procedure DoReSubcribeHqData; virtual;
    // UnSubcribeHqData
    procedure DoUnSubcribeHqData; virtual;
    // InfoReset
    procedure DoInfoReset(AQuoteType: QuoteTypeEnum; APointer: Pointer); virtual;
    // DataReset
    procedure DoDataReset(AQuoteType: QuoteTypeEnum; APointer: Pointer); virtual;
    // DataArrive
    procedure DoDataArrive(AQuoteType: QuoteTypeEnum; APointer: Pointer); virtual;
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // ReSubcribeHqData
    procedure ReSubcribeHqData;
    // UnSubcirbeHqData
    procedure UnSubcirbeHqData;
    // SetSubcribeState
    procedure SetSubcribeState(Active: Boolean);
  end;

implementation

{ TBaseObject }

constructor TBaseObject.Create(AContext: IAppContext);
begin
  inherited Create;
  FAppContext := AContext;
end;

destructor TBaseObject.Destroy;
begin
  FAppContext := nil;
  inherited;
end;

{ TBaseHqObject }

constructor TBaseHqObject.Create(AContext: IAppContext);
begin
  inherited;
  FQuoteManagerEx := FAppContext.FindInterface(ASF_COMMAND_ID_QUOTEMANAGEREX) as IQuoteManagerEx;
  DoInitHqMessage;
end;

destructor TBaseHqObject.Destroy;
begin
  DoUnInitHqMessage;
  FQuoteManagerEx := nil;
  inherited;
end;

procedure TBaseHqObject.DoInitHqMessage;
var
  LQuoteMessage: TQuoteMessage;
begin
  if FQuoteManagerEx = nil then Exit;

  LQuoteMessage := TQuoteMessage.Create(FQuoteManagerEx.GetTypeLib);
  LQuoteMessage.OnDataReset := DoDataReset;
  LQuoteMessage.OnInfoReset := DoInfoReset;
  LQuoteMessage.OnDataArrive := DoDataArrive;
  FQuoteMessage := LQuoteMessage as IQuoteMessage;
  FQuoteManagerEx.ConnectMessage(FQuoteMessage);
end;

procedure TBaseHqObject.DoUnInitHqMessage;
begin
  if FQuoteManagerEx = nil then Exit;

  if FQuoteMessage <> nil then begin
    DoUnSubcirbeHqData;
    FQuoteManagerEx.DisconnectMessage(FQuoteMessage);
    FQuoteMessage := nil;
  end;
end;

procedure TBaseHqObject.DoReSubcribeHqData;
begin

end;

procedure TBaseHqObject.DoUnSubcirbeHqData;
begin

end;

procedure TBaseHqObject.DoInfoReset(AQuoteType: QuoteTypeEnum; APointer: Pointer);
begin

end;

procedure TBaseHqObject.DoDataReset(AQuoteType: QuoteTypeEnum; APointer: Pointer);
begin
  DoReSubcribeHqData;
end;

procedure TBaseHqObject.DoDataArrive(AQuoteType: QuoteTypeEnum; APointer: Pointer);
begin

end;

procedure TBaseHqObject.ReSubcribeHqData;
begin
  DoReSubcribeHqData;
end;

procedure TBaseHqObject.UnSubcirbeHqData;
begin
  DoUnSubcirbeHqData;
end;

procedure TBaseHqObject.SetSubcribeState(Active: Boolean);
begin
  if FQuoteMessage = nil then Exit;

  if FQuoteMessage.MsgActive <> Active then begin
    FQuoteMessage.MsgActive := Active;
  end;
end;

{ TBaseInterfacedObject }

constructor TBaseInterfacedObject.Create(AContext: IAppContext);
begin
  inherited Create;
  FAppContext := AContext;
end;

destructor TBaseInterfacedObject.Destroy;
begin
  FAppContext := nil;
  inherited;
end;

{ TBaseSplitStrInterfacedObject }

constructor TBaseSplitStrInterfacedObject.Create(AContext: IAppContext);
begin
  inherited;
  FFastSplitParams := TStringList.Create;
  FFastSplitParams.Delimiter := '@';
end;

destructor TBaseSplitStrInterfacedObject.Destroy;
begin
  FFastSplitParams.Free;
  inherited;
end;

procedure TBaseSplitStrInterfacedObject.EndSplitParams;
begin
  FFastSplitParams.DelimitedText := '';
end;

procedure TBaseSplitStrInterfacedObject.BeginSplitParams(AParams: string);
begin
  FFastSplitParams.DelimitedText := AParams;
end;

procedure TBaseSplitStrInterfacedObject.ParamsVal(AName: string; var AVal: string);
begin
  AVal := FFastSplitParams.Values[AName];
end;

{ TBaseHqInterfacedObject }

constructor TBaseHqInterfacedObject.Create(AContext: IAppContext);
begin
  inherited;
  FQuoteManagerEx := FAppContext.FindInterface(ASF_COMMAND_ID_QUOTEMANAGEREX) as IQuoteManagerEx;
  DoInitHqMessage;
end;

destructor TBaseHqInterfacedObject.Destroy;
begin
  DoUnInitHqMessage;
  FQuoteManagerEx := nil;
  inherited;
end;

procedure TBaseHqInterfacedObject.DoInitHqMessage;
var
  LQuoteMessage: TQuoteMessage;
begin
  if FQuoteManagerEx = nil then Exit;

  LQuoteMessage := TQuoteMessage.Create(FQuoteManagerEx.GetTypeLib);
  LQuoteMessage.OnDataReset := DoDataReset;
  LQuoteMessage.OnInfoReset := DoInfoReset;
  LQuoteMessage.OnDataArrive := DoDataArrive;
  FQuoteMessage := LQuoteMessage as IQuoteMessage;
  FQuoteManagerEx.ConnectMessage(FQuoteMessage);
end;

procedure TBaseHqInterfacedObject.DoUnInitHqMessage;
begin
  if FQuoteManagerEx = nil then Exit;

  if FQuoteMessage <> nil then begin
    DoUnSubcribeHqData;
    FQuoteManagerEx.DisconnectMessage(FQuoteMessage);
    FQuoteMessage := nil;
  end;
end;

procedure TBaseHqInterfacedObject.DoReSubcribeHqData;
begin

end;

procedure TBaseHqInterfacedObject.DoUnSubcribeHqData;
begin

end;

procedure TBaseHqInterfacedObject.DoInfoReset(AQuoteType: QuoteTypeEnum; APointer: Pointer);
begin

end;

procedure TBaseHqInterfacedObject.DoDataReset(AQuoteType: QuoteTypeEnum; APointer: Pointer);
begin
  DoReSubcribeHqData;
end;

procedure TBaseHqInterfacedObject.DoDataArrive(AQuoteType: QuoteTypeEnum; APointer: Pointer);
begin

end;

procedure TBaseHqInterfacedObject.ReSubcribeHqData;
begin
  DoReSubcribeHqData;
end;

procedure TBaseHqInterfacedObject.UnSubcirbeHqData;
begin
  DoUnSubcribeHqData;
end;

procedure TBaseHqInterfacedObject.SetSubcribeState(Active: Boolean);
begin
  if FQuoteMessage = nil then Exit;

  if FQuoteMessage.MsgActive <> Active then begin
    FQuoteMessage.MsgActive := Active;
  end;
end;

end.
