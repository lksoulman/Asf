unit QuoteTimeCross;

interface

uses
  Windows,
  Classes,
  SysUtils,
  Forms,
  Graphics,
  G32Graphic,
  QuoteTimeStruct,
  QuoteTimeMenuIntf,
  QuoteTimeGraph,
  QuoteTimeData,
  QuoteTimeCrossDetail,
  QuoteCommLibrary;

type
  TQuoteTimeCross = class
  private
    FTimeGraphs: TQuoteTimeGraphs;
    FTimeDetail: TQuoteTimeCrossDetail;
    FTimeMenu: IQuoteTimeMenu;
    FIsDrawCross: Boolean;
    FIsHasDraw: Boolean;
    FXorPen: HPEN;
    FLastPoint: TPoint;
    FDataIndex: Integer;
    FColIndex: Integer;

    procedure DrawCross(_Canvas: TCanvas; _Pt: TPoint); overload;
  public
    constructor Create(_TimeGraphs: TQuoteTimeGraphs;
      _TimeMenu: IQuoteTimeMenu);
    destructor Destroy; override;

//    procedure DrawCross(_Pt: TPoint); overload;
    procedure DrawCross(_DataIndex, _Index: integer; _Pt: TPoint); overload;
    procedure DrawCross(_CrossMove: TCrossMoveType); overload;
    procedure ReDrawCross;
    procedure EraseCross; overload;
    procedure EraseCross(_VisibleDetail: Boolean); overload;
    procedure MouseLeave;
    procedure Resize;
    procedure UpdateSkin;
    procedure ResetFormat;

    property LastPoint: TPoint read FLastPoint;
    property DataIndex: Integer read FDataIndex;
    property ColIndex: Integer read FColIndex;
    property IsDrawCross: Boolean read FIsDrawCross write FIsDrawCross;
  end;

implementation

{ TQuoteTimeCross }

constructor TQuoteTimeCross.Create(_TimeGraphs: TQuoteTimeGraphs;
  _TimeMenu: IQuoteTimeMenu);
begin
  FTimeGraphs := _TimeGraphs;
  FTimeMenu := _TimeMenu;
  FIsDrawCross := False;
  FIsHasDraw := False;
  FDataIndex := 0;
  FColIndex := 0;

  FTimeDetail := TQuoteTimeCrossDetail.CreateNew
    (_TimeGraphs.G32Graphic.Control);
  FTimeDetail.PopupParent := Application.MainForm;
  FTimeDetail.Initialize(_TimeGraphs);
end;

destructor TQuoteTimeCross.Destroy;
begin
  if FXorPen <> 0 then
    DeleteObject(FXorPen);
  inherited;
end;

procedure TQuoteTimeCross.DrawCross(_CrossMove: TCrossMoveType);
var
  tmpPt: TPoint;
  tmpValue: Double;
  tmpData: TTimeData;
  tmpCompareValue: Integer;
  tmpGraph: TQuoteTimeGraph;
begin
  with FTimeGraphs do
  begin
    if Assigned(FTimeMenu) and not FTimeMenu.GetTimeMenuVisible then
    begin
      case _CrossMove of
        cmtLeft:
          begin
//            if (FColIndex = 0) and (FDataIndex = QuoteTimeData.MainDatasCount - 1) then
//            begin
//              exit;
//            end;

            if (FColIndex > 0) then
            begin
              Dec(FColIndex);
            end
            else
            begin
              if (FDataIndex < QuoteTimeData.MainDatasCount - 1) then
              begin
                Inc(FDataIndex);
                tmpData := QuoteTimeData.DataIndexToData(FDataIndex);
                if Assigned(tmpData) then
                begin
                  FColIndex := tmpData.DataCount - 1;
                end;
              end
            end;
          end;
        cmtRight:
          begin
            tmpData := QuoteTimeData.DataIndexToData(FDataIndex);
            if Assigned(tmpData) then
            begin
              if FColIndex < tmpData.DataCount - 1 then
              begin
                Inc(FColIndex);
              end
              else
              begin
                if FDataIndex > 0 then
                begin
                  Dec(FDataIndex);
                  FColIndex := 0;
                end;
              end;
            end;
          end;
        cmtHome:
          begin
            FDataIndex := 0;
            FColIndex := 0;
          end;
        cmtEnd:
          begin
            FDataIndex := QuoteTimeData.MainDatasCount - 1;
            if FDataIndex < 0 then
              FDataIndex := 0;
            tmpData := QuoteTimeData.DataIndexToData(FDataIndex);
            if Assigned(tmpData) then
              FColIndex := tmpData.DataCount - 1;
            if FColIndex < 0 then
              FColIndex := 0;
          end;
      end;

      tmpPt.Y := 0;
      tmpPt.X := IndexToX(FDataIndex, FColIndex);

      if not Assigned(tmpData) then exit;
      tmpData := QuoteTimeData.DataIndexToData(FDataIndex);
      tmpData.GetValue(dkPrice, FColIndex, tmpValue, tmpCompareValue);
      tmpGraph := GraphsHash[const_minutekey];
      if Assigned(tmpGraph) then
        tmpPt.Y := tmpGraph.ValueToY(tmpValue);

      if not FIsDrawCross then
      begin
        FIsDrawCross := True;
//        DrawCross(tmpPt);
        DrawCross(FDataIndex, FColIndex, tmpPt);
      end;

      EraseCross;
      DrawCross(FTimeGraphs.Canvas, tmpPt);
      FLastPoint := tmpPt;
      FIsHasDraw := True;
      FTimeDetail.DoDetail(FDataIndex, FColIndex, tmpPt);
    end;
  end;
end;

procedure TQuoteTimeCross.DrawCross(_Canvas: TCanvas; _Pt: TPoint);
var
  tmpOldPen: HPEN;
  tmpOldPenMode: Integer;
  tmpCenterRect: TRect;
begin
  if FXorPen = 0 then // PS_DASH
    FXorPen := CreatePen(PS_SOLID, 1,
      XorBackColor(FTimeGraphs.Display.BackColor,
      FTimeGraphs.Display.CrossLineColor));
  tmpCenterRect := FTimeGraphs.CenterRect;
  tmpCenterRect.Top := tmpCenterRect.Top + FTimeGraphs.TextHeight + 3;
  tmpOldPen := SelectObject(_Canvas.Handle, FXorPen);
  // ÉèÖÃPenÄ£Ê½
  tmpOldPenMode := SetROP2(_Canvas.Handle, R2_XORPEN);
  try
    MoveToEx(_Canvas.Handle, _Pt.X, tmpCenterRect.Top, nil);
    LineTo(_Canvas.Handle, _Pt.X, tmpCenterRect.Bottom);
    if _Pt.Y <> 0 then
    begin
      MoveToEx(_Canvas.Handle, tmpCenterRect.Left, _Pt.Y, nil);
      LineTo(_Canvas.Handle, tmpCenterRect.Right, _Pt.Y);
    end;
  finally
    SetROP2(_Canvas.Handle, tmpOldPenMode);
    SelectObject(_Canvas.Handle, tmpOldPen);
  end;
end;

//procedure TQuoteTimeCross.DrawCross(_Pt: TPoint);
//begin
//  with FTimeGraphs do
//  begin
//    if (Assigned(FTimeMenu) and not FTimeMenu.GetTimeMenuVisible) or
//      (FTimeGraphs.Display.ShowMode = smWSSelfDefinition) then
//    begin
//      if FIsDrawCross then
//      begin
//        EraseCross;
//        DrawCross(Canvas, _Pt);
//        FLastPoint := _Pt;
//        FIsHasDraw := True;
//        if not IsWindowVisible(FTimeDetail.Handle) then
//        begin
//          FTimeDetail.UpdateShowPos;
//        end;
//        XToIndex(_Pt.X, FDataIndex, FColIndex);
//        FTimeDetail.DoDetail(FDataIndex, FColIndex, _Pt);
//      end
//      else
//      begin
//        if IsWindowVisible(FTimeDetail.Handle) then
//          ShowWindow(FTimeDetail.Handle, SW_HIDE);
//      end;
//    end;
//  end;
//end;

procedure TQuoteTimeCross.DrawCross(_DataIndex, _Index: integer; _Pt: TPoint);
begin
  with FTimeGraphs do
  begin
    if (Assigned(FTimeMenu) and not FTimeMenu.GetTimeMenuVisible) or
      (FTimeGraphs.Display.ShowMode = smWSSelfDefinition) then
    begin
      if FIsDrawCross then
      begin
        EraseCross;
        DrawCross(Canvas, _Pt);
        FLastPoint := _Pt;
        FIsHasDraw := True;
        if not IsWindowVisible(FTimeDetail.Handle) then
        begin
          FTimeDetail.UpdateShowPos;
        end;
        FDataIndex := _DataIndex;
        FColIndex := _Index;
        FTimeDetail.DoDetail(FDataIndex, FColIndex, _Pt);
      end
      else
      begin
        if IsWindowVisible(FTimeDetail.Handle) then
          ShowWindow(FTimeDetail.Handle, SW_HIDE);
      end;
    end;
  end;
end;

procedure TQuoteTimeCross.EraseCross(_VisibleDetail: Boolean);
begin
  if _VisibleDetail = False then
    if IsWindowVisible(FTimeDetail.Handle) then
      ShowWindow(FTimeDetail.Handle, SW_HIDE);
  EraseCross;
end;

procedure TQuoteTimeCross.MouseLeave;
begin
  if not FTimeDetail.MouseInClient then
    if IsWindowVisible(FTimeDetail.Handle) then
      ShowWindow(FTimeDetail.Handle, SW_HIDE);
end;

procedure TQuoteTimeCross.EraseCross;
begin
  if FIsHasDraw then
  begin
    DrawCross(FTimeGraphs.Canvas, FLastPoint);
    FIsHasDraw := False;
  end;
end;

procedure TQuoteTimeCross.ReDrawCross;
begin
  with FTimeGraphs do
  begin
    if FIsDrawCross and FIsHasDraw then
    begin
      DrawCross(Canvas, FLastPoint);
      FIsHasDraw := True;
//      XToIndex(FLastPoint.X, FDataIndex, FColIndex);
      FTimeDetail.DoDetail(FDataIndex, FColIndex, FLastPoint);
    end;
  end;
end;

procedure TQuoteTimeCross.ResetFormat;
begin
  if Assigned(FTimeDetail) then
    FTimeDetail.ResetFormat;
end;

procedure TQuoteTimeCross.Resize;
begin
  if IsWindowVisible(FTimeDetail.Handle) then
    FTimeDetail.UpdateShowPos;
end;

procedure TQuoteTimeCross.UpdateSkin;
begin
  FTimeDetail.UpdateSkin;
end;

end.
