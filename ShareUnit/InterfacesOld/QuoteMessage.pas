unit QuoteMessage;

interface

uses Windows, Messages, Classes, ComObj, ActiveX, QuoteMngr_TLB,QuoteStruct;

type
  TMessageEvent = procedure(QuoteType: QuoteTypeEnum;p:Pointer) of object;

  TQuoteMessage = class(TAutoIntfObject, IQuoteMessage)
  private
    FMsgCookie: integer;
    FMsgHandle: Int64;
    FMsgActive: WordBool;
    FOnDataArrive: TMessageEvent;
    FOnDataReset: TMessageEvent;
    FOnInfoReset: TMessageEvent;
    procedure WndProc(var Message: TMessage);
  protected
    {IQuoteMessage}
    function Get_MsgCookie: Integer; safecall;
    procedure Set_MsgCookie(Value: Integer); safecall;
    function Get_MsgHandle: Int64; safecall;
    function Get_MsgActive: WordBool; safecall;
    procedure Set_MsgActive(Value: WordBool); safecall;
  public
    constructor Create(TypeLib: ITypeLib);
    destructor Destroy; override;
    property OnDataArrive: TMessageEvent read FOnDataArrive write FOnDataArrive;
    property OnDataReset: TMessageEvent read FOnDataReset write FOnDataReset;
    property OnInfoReset: TMessageEvent read FOnInfoReset write FOnInfoReset;
  end;

implementation

{ TQuoteMessage }

constructor TQuoteMessage.Create(TypeLib: ITypeLib);
begin
  //ClientSink := WNController.WNLoadRegTypeLib(LIBID_QuotaServer) as ITypeLib;
  //      OleCheck(LoadRegTypeLib(LIBID_QuoteMngr, 1, 0, 0, TypeLib));
        inherited Create(TypeLib, IQuoteMessage);

        FMsgHandle := Classes.AllocateHWnd(WndProc);
        FMsgActive := true;
end;

destructor TQuoteMessage.Destroy;
begin
        if FMsgHandle <> 0 then begin
                Classes.DeallocateHWnd(FMsgHandle);
                FMsgHandle := 0;
        end;
        inherited Destroy;
end;

function TQuoteMessage.Get_MsgActive: WordBool;
begin
        result := FMsgActive;
end;

function TQuoteMessage.Get_MsgCookie: Integer;
begin
        result := FMsgCookie;
end;

function TQuoteMessage.Get_MsgHandle: Int64;
begin
        result := FMsgHandle;
end;

procedure TQuoteMessage.Set_MsgActive(Value: WordBool);
begin
        FMsgActive := Value;
end;

procedure TQuoteMessage.Set_MsgCookie(Value: Integer);
begin
        FMsgCookie := Value;
end;

procedure TQuoteMessage.WndProc(var Message: TMessage);
begin
       if (Message.Msg = WM_DataArrive) then begin
                if FMsgActive and Assigned(FOnDataArrive) then
                        FOnDataArrive(Message.WParam,0)
        end else if  (Message.Msg = WM_DataReset) then begin
                if FMsgActive and Assigned(FOnDataReset) then
                        FOnDataReset(Message.WParam,0)
//        end else if (Message.Msg = WM_InfoReset) then begin
//                if Assigned(FOnInfoReset) then
//                        FOnInfoReset(Message.WParam)
        end;
end;

end.
