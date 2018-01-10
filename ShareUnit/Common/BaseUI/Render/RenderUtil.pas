unit RenderUtil;

////////////////////////////////////////////////////////////////////////////////
//
// Description： Render Utils
// Author：      lksoulman
// Date：        2017-10-26
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  GDIPAPI,
  GDIPOBJ,
  ActiveX,
  SysUtils;

type

  // Draw Text Align
  TDrawTextAlign = (dtaTop,
                    dtaLeft,
                    dtaRight,
                    dtaBottom,
                    dtaCenter,
                    dtaTopLeft,
                    dtaTopRight,
                    dtaBottomLeft,
                    dtaBottomRight);
  // CreateGPImage
//  function CreateGPImage(AResStream: TResourceStream): TGPImage;
  // GetTextSize
  function GetTextSizeX(ADC: HDC; AFont: HFONT; AText: string; var ASize: TSize): Boolean;

  // FillSolidRect
  procedure FillSolidRect(ADC: HDC; APRect: PRECT; AColorRef: COLORREF); overload;

  // FillSolidRect
  procedure FillSolidRect(ADC: HDC; AX, AY, ACX, ACY: Integer; AColorRef: COLORREF); overload;

  // DrawBorder
  procedure DrawBorder(ADC: HDC; ABorderPen : HGDIOBJ; const ARect: TRect; ABorders: integer);

  // DrawImageX
  procedure DrawImageX(AGraphics: TGPGraphics; AImage: TGPImage; ADesRect, ASrcRect: TRect); overload;

  // DrawImageX
  procedure DrawImageX(AGraphics: TGPGraphics; AResourceStream: TResourceStream; ADesRect, ASrcRect: TRect); overload;

  // DrawTextX
  procedure DrawTextX(ADC: HDC; ARect: TRect; AText: string; AColorRef: COLORREF; ATextAlign: TDrawTextAlign;
    AMulitLine: Boolean = False; AEllipsis: Boolean = True);

  // GdiPlusDrawTextExX
  procedure GdiPlusDrawTextX(ADC: HDC; AGraphics: TGPGraphics; AText: string; ARect: TRect;
    AFont: HFONT; AColorRef: COLORREF; AHorzAlignment, AVertAlignment: TStringAlignment);

implementation


  procedure FillSolidRect(ADC: HDC; APRect: PRECT; AColorRef: COLORREF);
  begin
    SetBkColor(ADC, AColorRef);
    ExtTextOut(ADC, 0, 0, ETO_OPAQUE, APRect, nil, 0, nil);
  end;

  procedure FillSolidRect(ADC: HDC; AX, AY, ACX, ACY: Integer; AColorRef: COLORREF);
  var
    LRect: TRect;
  begin
    LRect.Left := AX;
    LRect.Top := AY;
    LRect.Right := AX + ACX;
    LRect.Bottom := AY + ACY;

    SetBkColor(ADC, AColorRef);
    ExtTextOut(ADC, 0, 0, ETO_OPAQUE, @LRect, nil, 0, nil);
  end;

  procedure DrawBorder(ADC: HDC; ABorderPen : HGDIOBJ; const ARect: TRect; ABorders: integer);
  var
    LGDIOBJ: HGDIOBJ;
  begin
    if ABorders = 0 then Exit;

    LGDIOBJ := SelectObject(ADC, ABorderPen);
    try
      //绘制左边框
      if (ABorders and 1) > 0 then begin
        MoveToEx(ADC, ARect.Left, ARect.Top, nil);
        //bottom加一是为了把结束点像素也画上
        LineTo(ADC, ARect.Left, ARect.Bottom + 1);
      end;

      //绘制右边框
      if (ABorders and 2) > 0 then begin
        MoveToEx(ADC, ARect.Right, ARect.Top, nil);
        LineTo(ADC, ARect.Right, ARect.Bottom + 1);
      end;

      //绘制上边框
      if (ABorders and 4) > 0 then begin
        MoveToEx(ADC, ARect.Left, ARect.Top, nil);
        LineTo(ADC, ARect.Right + 1, ARect.Top);
      end;

      //绘制下边框
      if (ABorders and 8) > 0 then begin
        MoveToEx(ADC, ARect.Left, ARect.Bottom, nil);
        LineTo(ADC, ARect.Right + 1, ARect.Bottom);
      end;
    finally
      SelectObject(ADC, LGDIOBJ);
    end;
  end;

  procedure DumpRect(ADesRectF: PGPRectF; ASrcRect: PRect);
  begin
    ADesRectF^.X := ASrcRect^.Left;
    ADesRectF^.Y := ASrcRect^.Top;
    ADesRectF^.Width := ASrcRect^.Width;
    ADesRectF^.Height := ASrcRect^.Height;
  end;

  function CreateGPImage(AResStream: TResourceStream): TGPImage;
  var
    LStream: IStream;
  begin
    Result := nil;
    if AResStream = nil then Exit;
    LStream := TStreamAdapter.Create(AResStream);
    Result := TGPImage.Create(LStream);
  end;

  function GetTextSizeX(ADC: HDC; AFont: HFONT; AText: string; var ASize: TSize): Boolean;
  var
    LOBJ: HGDIOBJ;
  begin
    LOBJ := SelectObject(ADC, AFont);
    try
      Result := GetTextExtentPoint32(ADC, PChar(AText), Length(AText), ASize);
      if not Result then begin
        ASize.cx := 0;
        ASize.cy := 0;
      end;
    finally
      SelectObject(ADC, LOBJ);
    end;
  end;

  procedure DrawImageX(AGraphics: TGPGraphics; AImage: TGPImage; ADesRect, ASrcRect: TRect);
  var
    LDesRectF, LSrcRectF: TGPRectF;
  begin
    DumpRect(@LDesRectF, @ADesRect);
    DumpRect(@LSrcRectF, @ASrcRect);
    AGraphics.DrawImage(AImage, LDesRectF, LSrcRectF.X, LSrcRectF.Y,
      LSrcRectF.Width, LSrcRectF.Height, UnitPixel);
  end;

  procedure DrawImageX(AGraphics: TGPGraphics; AResourceStream: TResourceStream; ADesRect, ASrcRect: TRect);
  var
    LGPImage: TGPImage;
    LDesRectF, LSrcRectF: TGPRectF;
  begin
    LGPImage := CreateGPImage(AResourceStream);
    if LGPImage = nil then Exit;

    DumpRect(@LDesRectF, @ADesRect);
    DumpRect(@LSrcRectF, @ASrcRect);
    AGraphics.DrawImage(LGPImage, LDesRectF, LSrcRectF.X, LSrcRectF.Y,
      LSrcRectF.Width, LSrcRectF.Height, UnitPixel);
    LGPImage.Free;
  end;

  procedure DrawTextX(ADC: HDC; ARect: TRect; AText: string; AColorRef: COLORREF; ATextAlign: TDrawTextAlign;
    AMulitLine: Boolean = False; AEllipsis: Boolean = True);
  var
    LFormat: Cardinal;
  begin
    case ATextAlign of
      dtaTop:
        LFormat := DT_TOP + DT_CENTER;
      dtaLeft:
        LFormat := DT_LEFT + DT_VCENTER;
      dtaRight:
        LFormat := DT_RIGHT + DT_VCENTER;
      dtaBottom:
        LFormat := DT_BOTTOM + DT_CENTER;
      dtaCenter:
        LFormat := DT_CENTER + DT_VCENTER;
      dtaTopLeft:
        LFormat := DT_TOP + DT_LEFT;
      dtaTopRight:
        LFormat := DT_TOP + DT_RIGHT;
      dtaBottomLeft:
        LFormat := DT_BOTTOM + DT_LEFT;
      dtaBottomRight:
        LFormat := DT_BOTTOM + DT_RIGHT;
    else
      LFormat := DT_LEFT + DT_VCENTER;
    end;

    if AMulitLine then begin
      LFormat := LFormat + DT_WORDBREAK
    end else begin
      LFormat := LFormat + DT_SINGLELINE;
    end;

    if AEllipsis then begin
      LFormat := LFormat + DT_END_ELLIPSIS;
    end;
    SetBkMode(ADC, TRANSPARENT);
    SetTextColor(ADC, AColorRef);
    DrawText(ADC, PChar(AText), Length(AText), ARect, LFormat + DT_NOPREFIX);
  end;

  procedure GdiPlusDrawTextX(ADC: HDC; AGraphics: TGPGraphics; AText: string; ARect: TRect;
    AFont: HFONT; AColorRef: COLORREF; AHorzAlignment, AVertAlignment: TStringAlignment);
  var
    LFont: TGPFont;
    LColor: TGPColor;
    LRectF: TGPRectF;
    LBrush: TGPBrush;
    LFormat: TGPStringFormat;
  begin
    LColor := ColorRefToARGB(AColorRef);
    LRectF := MakeRect(ARect.Left + 0.0, ARect.Top + 0.0,
      ARect.Width + 0.0, ARect.Height + 0.0);
    LFont := TGPFont.Create(ADC, AFont);
    try
      LBrush := TGPSolidBrush.Create(LColor);
      try
        LFormat := TGPStringFormat.Create;
        try
          LFormat.SetAlignment(AHorzAlignment);
          LFormat.SetLineAlignment(AVertAlignment);
          LFormat.SetTrimming(StringTrimmingEllipsisWord);
          AGraphics.DrawString(AText, -1, LFont, LRectF, LFormat, LBrush);
        finally
          LFormat.Free;
        end;
      finally
        LBrush.Free;
      end;
    finally
      LFont.Free;
    end;
  end;


end.
