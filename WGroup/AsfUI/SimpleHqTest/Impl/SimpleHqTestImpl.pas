unit SimpleHqTestImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SimpleHqTest Implementation
// Author£º      lksoulman
// Date£º        2017-12-15
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  MsgEx,
  SecuMain,
  AppContext,
  ChildPageImpl,
  MsgExSubcriber,
  QuoteTime,
  QuoteTimeStruct,
  QuoteCommLibrary;

type

  // SimpleHqTest Implementation
  TSimpleHqTestImpl = class(TChildPageImpl)
  private
    // InnerCode
    FInnerCode: Integer;
    // QuoteTime
    FQuoteTime: TQuoteTime;
  protected
    // CreateObjects
    procedure DoCreateObjects; override;
    // DestroyObjects
    procedure DoDestroyObjects; override;
    // InitObjectDatas
    procedure DoInitObjectDatas; override;
    // AddSubcribeMsgExs
    procedure DoAddSubcribeMsgExs; override;

    // Activate
    procedure DoActivate; override;
    // NoActivate
    procedure DoNoActivate; override;
    // ReSubcribeHq
    procedure DoReSubcribeHq; override;
    // ReSecuMainMem
    procedure DoReSecuMainMem; override;
    // ReUpdateLanguage
    procedure DoReUpdateLanguage; override;
    // ReUpdateSkinStyle
    procedure DoReUpdateSkinStyle; override;
    // UpdateCommandParam
    procedure DoUpdateCommandParam(AParams: string); override;
  public
  end;

implementation

{ TSimpleHqTestImpl }

procedure TSimpleHqTestImpl.DoCreateObjects;
begin
  FQuoteTime := TQuoteTime.Create(FAppContext, smNormal);
  FQuoteTime.Align := alClient;
  FQuoteTime.Parent := FChildPageUI;
end;

procedure TSimpleHqTestImpl.DoDestroyObjects;
begin
  FQuoteTime.Free;
end;

procedure TSimpleHqTestImpl.DoInitObjectDatas;
begin
  inherited;

end;

procedure TSimpleHqTestImpl.DoAddSubcribeMsgExs;
begin
  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfHqService_ReSubcribeHq);
end;

procedure TSimpleHqTestImpl.DoActivate;
begin

end;

procedure TSimpleHqTestImpl.DoNoActivate;
begin

end;

procedure TSimpleHqTestImpl.DoReSubcribeHq;
var
  LSecuInfo: PSecuInfo;
begin
  FInnerCode := 1752;
  if FAppContext.QuerySecuInfo(FInnerCode, LSecuInfo) then begin
    FQuoteTime.ChangeStock(stSingleDay, LSecuInfo);
  end;
end;

procedure TSimpleHqTestImpl.DoReSecuMainMem;
begin

end;

procedure TSimpleHqTestImpl.DoReUpdateLanguage;
begin

end;

procedure TSimpleHqTestImpl.DoReUpdateSkinStyle;
begin
  inherited;

end;

procedure TSimpleHqTestImpl.DoUpdateCommandParam(AParams: string);
var
  LInnerCodeStr: string;
begin
  BeginSplitParams(AParams);
  try
    ParamsVal('InnerCode', LInnerCodeStr);
    FInnerCode := StrToIntDef(LInnerCodeStr, 0);
  finally
    EndSplitParams;
  end;
end;

end.
