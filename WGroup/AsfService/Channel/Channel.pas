unit Channel;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Channel
// Author��      lksoulman
// Date��        2017-9-13
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  HttpContext,
  HttpExecutor,
  CommonRefCounter;

type

  // Channel
  TChannel = class(TAutoObject)
  private
    // Next
    FNext: TChannel;
    // Prev
    FPrev: TChannel;
  protected
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
    // Up Stream
    procedure UpStream(AContext: THttpContext; AExecutor: IHttpExecutor); virtual; abstract;
    // Down Stream
    procedure DownStream(AContext: THttpContext; AExecutor: IHttpExecutor); virtual; abstract;

    property Next: TChannel read FNext write FNext;
    property Prev: TChannel read FPrev write FPrev;
  end;


implementation

{ TChannel }

constructor TChannel.Create;
begin
  inherited;

end;

destructor TChannel.Destroy;
begin

  inherited;
end;

end.
