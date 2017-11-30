unit JsonChannelPipeLine;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Http Channel Pipe Line
// Author��      lksoulman
// Date��        2017-10-5
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
  ChannelPipeLine;

type

  // Json Channel Pipe Line
  TJsonChannelPipeLine = class(TChannelPipeLine)
  private
  protected
    // Init Pipe Line
    procedure DoInitPipeLine; override;
  public
    // Constructor
    constructor Create; override;
    // Destructor
    destructor Destroy; override;
  end;

implementation

uses
  JsonChannel,
  PostChannel,
  EDCryptChannel,
  CompressChannel;

{ TJsonChannelPipeLine }

constructor TJsonChannelPipeLine.Create;
begin
  inherited;

end;

destructor TJsonChannelPipeLine.Destroy;
begin

  inherited;
end;

procedure TJsonChannelPipeLine.DoInitPipeLine;
begin
  AddChannel(TJsonChannel.Create);
  AddChannel(TCompressChannel.Create);
  AddChannel(TEDCryptChannel.Create);
  AddChannel(TPostChannel.Create);
end;

end.
