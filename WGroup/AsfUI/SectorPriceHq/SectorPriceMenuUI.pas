unit SectorPriceMenuUI;

////////////////////////////////////////////////////////////////////////////////
//
// Description： SectorPriceMenuUI
// Author：      lksoulman
// Date：        2018-1-17
// Comments：
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Controls,
  Graphics,
  Utils,
  MsgEx,
  Command,
  RenderDC,
  NativeXml,
  RenderUtil,
  BaseObject,
  AppContext,
  ComponentUI,
  CustomFrameUI,
  Attention,
  UserAttentionMgr,
  Generics.Collections,
  MsgExSubcriberAdapter,
  QuoteCommMenu;

const

  {我的关注}

  MARKETID_ATTENTION            = 1000;
  MODULEID_SELF                 = 1001;          // 自选
  MODULEID_POSITION             = 1101;          // 持仓

  MODULEID_ASTOCK_SH_SZ         = 2001;          // 沪深A股
  MODULEID_ASTOCK_SH            = 2002;          // 上证A股
  MODULEID_ASTOCK_SZ            = 2003;          // 上证A股
  MODULEID_SMALLANDMEDIUM       = 2004;          // 中小板
  MODULEID_BSTOCK_SH_SZ         = 2006;          // 沪深B股

  MODULEID_SCREEN_SH_SZ         = 1;             // 沪深A股综合屏
  MODULEID_SCREEN_ASTOCK        = 2;             // A股板块综合屏
  MODULEID_SCREEN_FUTURES       = 3;             // 股指期货综合屏

type

  // SectorChildList
  TSectorChildList = class;

  // SectorPriceMenuUI
  TSectorPriceMenuUI = class;

  // SectorChildItemMgr
  TSectorChildItemMgr = class;

  // SectorParams
  TSectorParams = packed record
    FSectorId: Integer;
    FModuleId: Integer;
    FSectorName: string;
  end;

  // SectorItem
  TSectorItem = class(TComponentUI)
  private
    // SectorId
    FSectorId: Integer;
    // MarketId
    FMarketId: Integer;
    // ParentUI
    FParentUI: TSectorPriceMenuUI;
  protected
  public
    // Constructor
    constructor Create(AParentUI: TSectorPriceMenuUI); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // RectExIsValid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // SectorChildItem
  TSectorChildItem = class(TComponentUI)
  private
    // SectorId
    FSectorId: Integer;
    // ModuleId
    FModuleId: Integer;
    // ParentUI
    FParentUI: TSectorPriceMenuUI;
  protected
  public
    // Constructor
    constructor Create(AParentUI: TSectorPriceMenuUI); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // RectExIsValid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // SectorChildSubItem
  TSectorChildSubItem = class(TSectorChildItem)
  private
    // Width
    FWidth: Integer;
    // SubWidth
    FSubWidth: Integer;
  protected
  public
    // Constructor
    constructor Create(AParentUI: TSectorPriceMenuUI); override;
    // Destructor
    destructor Destroy; override;
    // RectExIsValid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // SectorChildAddItem
  TSectorChildAddItem = class(TSectorItem)
  private
    // Width
    FWidth: Integer;
    // IconSize
    FIconSize: TSize;
    // IconWidth
    FIconWidth: Integer;
  protected
  public
    // Constructor
    constructor Create(AParentUI: TSectorPriceMenuUI); override;
    // Destructor
    destructor Destroy; override;
    // RectExIsValid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // SectorToolItem
  TSectorToolItem = class(TSectorItem)
  private
  protected
    // Enable
    FEnable: Boolean;
  public
    // Constructor
    constructor Create(AParentUI: TSectorPriceMenuUI); override;
    // Destructor
    destructor Destroy; override;
    // RectExIsValid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
  end;

  // RankToolItem
  TRankToolItem = class(TSectorToolItem)
  private
  protected
  public
    // Constructor
    constructor Create(AParentUI: TSectorPriceMenuUI); override;
    // Destructor
    destructor Destroy; override;
    // RectExIsValid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // PriceToolItem
  TPriceToolItem = class(TSectorToolItem)
  private
  protected
  public
    // Constructor
    constructor Create(AParentUI: TSectorPriceMenuUI); override;
    // Destructor
    destructor Destroy; override;
    // RectExIsValid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // MultiStockToolItem
  TMultiStockToolItem = class(TSectorToolItem)
  private
  protected
  public
    // Constructor
    constructor Create(AParentUI: TSectorPriceMenuUI); override;
    // Destructor
    destructor Destroy; override;
    // RectExIsValid
    function RectExIsValid: Boolean; override;
    // PtInRectEx
    function PtInRectEx(APt: TPoint): Boolean; override;
    // Draw
    function Draw(ARenderDC: TRenderDC): Boolean; override;
  end;

  // SectorItemMgr
  TSectorItemMgr = class(TBaseObject)
  private
  protected
    // Height
    FHeight: Integer;
    // ItemWidth
    FItemWidth: Integer;
    // SelectedMarketId
    FSelectedMarketId: Integer;
    // ComponentsRect
    FComponentsRect: TRect;
    // ParentUI
    FParentUI: TSectorPriceMenuUI;
    // SectorItems
    FSectorItems: TList<TSectorItem>;

    // ClearSectorItems
    procedure DoClearSectorItems;
    // DrawBack
    procedure DoDrawBack;
    // DrawBorder
    procedure DoDrawBorder;
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParentUI: TSectorPriceMenuUI); reintroduce;
    // Destructor
    destructor Destroy; override;
    // Calc
    procedure Calc; virtual;
    // Draw
    procedure Draw; virtual;
    // ChangeMarket
    function ChangeMarket(AMarketId: Integer): Boolean;
    // Add
    function Add(AMarketId, ASectorId: Integer; ACaption: string): TSectorItem;
    // FindComponent
    function Find(APt: TPoint; var AComponent: TComponentUI): Boolean; virtual;
  end;

  // SectorChildList
  TSectorChildList = class(TBaseObject)
  private
  protected
    // ItemSpace
    FItemSpace: Integer;
    // ItemWidth
    FItemWidth: Integer;
    // ItemHeight
    FItemHeight: Integer;
    // ShowCount
    FShowCount: Integer;
    // ComponentsRect
    FComponentsRect: TRect;
    // MarketId
    FMarketId: Integer;
    // SelectedModuleId
    FSelectedModuleId: Integer;
    // ParentUI
    FParentUI: TSectorPriceMenuUI;
    // SectorChildItems
    FSectorChildItems: TList<TSectorChildItem>;
    // ModuleIdDic
    FModuleIdDic: TDictionary<Integer, Integer>;

    // ClearItems
    procedure DoClearItems(AList: TList<TSectorChildItem>);
    // GetIndex
    function GetIndex(AModuleId: Integer): Integer;
    // GetSectorChildItem
    function GetSectorChildItem(AIndex: Integer): TSectorChildItem;
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParentUI: TSectorPriceMenuUI); reintroduce; virtual;
    // Destructor
    destructor Destroy; override;
    // Calc
    procedure Calc;
    // Draw
    procedure Draw;
    // Change
    function Change(AModuleId: Integer): Boolean;
    // IsHasModule
    function IsHasModule(AModuleId: Integer): Boolean;
    // FindComponent
    function Find(APt: TPoint; var AComponent: TComponentUI): Boolean;
    // Add
    function Add(AModuleId, ASectorId: Integer; ACaption: string): TSectorChildItem; virtual;
  end;

  // AttentionSectorChildList
  TAttentionSectorChildList = class(TSectorChildList)
  private
    // DefaultChildItems
    FDefaultChildItems: TList<TSectorChildItem>;
    // AttentionChildItems
    FAttentionChildItems: TList<TSectorChildItem>;
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParentUI: TSectorPriceMenuUI); override;
    // Destructor
    destructor Destroy; override;
    // ClearAttentionChildItems
    procedure ClearAttentionChildItems;
    // Add
    function Add(AModuleId, ASectorId: Integer; ACaption: string): TSectorChildItem; override;
    // AttentionChildAdd
    function AttentionChildAdd(AModuleId, ASectorId: Integer; ACaption: string): TSectorChildItem;
  end;

  // SectorChildItemMgr
  TSectorChildItemMgr = class(TBaseObject)
  private
    // Height
    FHeight: Integer;
    // ComponentsRect
    FComponentsRect: TRect;
    // ParentUI
    FParentUI: TSectorPriceMenuUI;
    // SectorChildList
    FSectorChildList: TSectorChildList;
    // AttentionSectorChildList
    FAttentionSectorChildList: TAttentionSectorChildList;
    // SectorChildSubItem
    FSectorChildSubItem: TSectorChildSubItem;
    // SectorChildAddItem
    FSectorChildAddItem: TSectorChildAddItem;
    // SectorItemsDic
    FSectorChildListDic: TDictionary<Integer, TSectorChildList>;
  protected
    // ClearSectorChildListDic
    procedure DoClearSectorChildListDic;
    // DrawBack
    procedure DoDrawBack;
    // DrawBorder
    procedure DoDrawBorder;
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParentUI: TSectorPriceMenuUI); reintroduce;
    // Destructor
    destructor Destroy; override;
    // Calc
    procedure Calc;
    // Draw
    procedure Draw;
    // FindComponent
    function Find(APt: TPoint; var AComponent: TComponentUI): Boolean;
    // ChangeModule
    function ChangeModule(AMarketId, AModuleId: Integer; var IsCalc: Boolean): Boolean;
    // Add
    function Add(AMarketId, AModuleId, ASectorId: Integer; ACaption: string): TSectorChildItem;
  end;

  // SectorToolItemMgr
  TSectorToolItemMgr = class(TBaseObject)
  private
    // Width
    FWidth: Integer;
    // ItemSpace
    FItemSpace: Integer;
    // ItemWidth
    FItemWidth: Integer;
    // ItemHeight
    FItemHeight: Integer;
    // ComponentsRect
    FComponentsRect: TRect;
    // ParentUI
    FParentUI: TSectorPriceMenuUI;
    // RankToolItem
    FRankToolItem: TRankToolItem;
    // PriceToolItem
    FPriceToolItem: TPriceToolItem;
    // MultiStockToolItem
    FMultiStockToolItem: TMultiStockToolItem;
    // SectorToolItems
    FSectorToolItems: TList<TSectorToolItem>;
  protected
    // DrawBack
    procedure DoDrawBack;
    // DrawBorder
    procedure DoDrawBorder;
  public
    // Constructor
    constructor Create(AContext: IAppContext; AParentUI: TSectorPriceMenuUI); reintroduce;
    // Destructor
    destructor Destroy; override;
    // Calc
    procedure Calc;
    // Draw
    procedure Draw;
    // FindComponent
    function Find(APt: TPoint; var AComponent: TComponentUI): Boolean;
  end;

  // SectorPriceMenu
  TSectorPriceMenuUI = class(TCustomFrameUI)
  private
    // SubPopMenu
    FSubPopMenu: TGilPopMenu;
    // SectorItemMgr
    FSectorItemMgr: TSectorItemMgr;
    // UserAttentionMgr
    FUserAttentionMgr: IUserAttentionMgr;
    // SectorToolItemMgr
    FSectorToolItemMgr: TSectorToolItemMgr;
    // SectorChildItemMgr
    FSectorChildItemMgr: TSectorChildItemMgr;
    // MsgExSubcriberAdapter
    FMsgExSubcriberAdapter: TMsgExSubcriberAdapter;
    // SectorItemBackColor
    FSectorItemBackColor: TColor;
    // SectorItemColor
    FSectorItemColor: TColor;
    // SectorItemFontColor
    FSectorItemFontColor: TColor;
    // SectorItemHotColor
    FSectorItemHotColor: TColor;
    // SectorItemHotFontColor
    FSectorItemHotFontColor: TColor;
    // SectorItemHotColor
    FSectorItemDownColor: TColor;
    // SectorItemHotFontColor
    FSectorItemDownFontColor: TColor;
    // SectorItemLineColor
    FSectorItemLineColor: TColor;
    // SectorItemColor
    FSectorChildItemBackColor: TColor;
    // SectorItemColor
    FSectorChildItemColor: TColor;
    // SectorItemFontColor
    FSectorChildItemFontColor: TColor;
    // SectorItemHotColor
    FSectorChildItemHotColor: TColor;
    // SectorItemHotFontColor
    FSectorChildItemHotFontColor: TColor;
    // SectorItemHotColor
    FSectorChildItemDownColor: TColor;
    // SectorItemHotFontColor
    FSectorChildItemDownFontColor: TColor;
    // SectorItemLineColor
    FSectorChildItemLineColor: TColor;
    // SectorAddColor
    FSectorAddColor: TColor;
    // SectorAddFontColor
    FSectorAddFontColor: TColor;
    // SectorAddColor
    FSectorAddHotColor: TColor;
    // SectorAddFontColor
    FSectorAddHotFontColor: TColor;
    // SectorAddColor
    FSectorAddDownColor: TColor;
    // SectorAddFontColor
    FSectorAddDownFontColor: TColor;

    // PriceToolResourceStream
    FPriceResourceStream: TResourceStream;
    // AddSectorResourceStream
    FAddSectorResourceStream: TResourceStream;
    // EnableResourceStream
    FEnableRankToolResourceStream: TResourceStream;
    // UnEnableResourceStream
    FUnEnableRankToolResourceStream: TResourceStream;
    // EnableMultiStockToolResourceStream
    FEnableMultiStockToolResourceStream: TResourceStream;
    // UnEnableMultiStockToolResourceStream
    FUnEnableMultiStockToolResourceStream: TResourceStream;
  protected
    // AddTestData
    procedure DoAddTestData;
    // ReadCfgData
    procedure DoReadCfgData;
    // AddChildData
    procedure DoAddChildData(AMarketId: Integer; ANode: TXmlNode);
    // UpdateAttentionData
    function DoUpdateAttentionData: Boolean;
    // UpdateSkinStyle
    procedure DoUpdateSkinStyle;
    // CalcComponentsRect
    procedure DoCalcComponentsRect; override;
    // DrawBK
    procedure DoDrawBK(ARenderDC: TRenderDC); override;
    // DrawComponents
    procedure DoDrawComponents(ARenderDC: TRenderDC); override;
    // FindComponent
    function DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean; override;
    // MouseUpAfter
    procedure DoMouseUpAfter(AComponent: TComponentUI); override;
    // LClickComponent
    procedure DoLClickComponent(AComponent: TComponentUI); override;
    // UpdateMsgEx
    procedure DoUpdateMsgEx(AObject: TObject);
    // LClickSubMenuItem
    procedure DoLClickSubMenuItem(AObject: TObject);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;
    // Change
    procedure Change(AMarketId, AModuleId: Integer);
  end;

implementation

{ TSectorItem }

constructor TSectorItem.Create(AParentUI: TSectorPriceMenuUI);
begin
  inherited Create;
  FParentUI := AParentUI;
  FId := FParentUI.GetUniqueId;
end;

destructor TSectorItem.Destroy;
begin

  inherited;
end;

function TSectorItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TSectorItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

function TSectorItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LRect: TRect;
  LBackColor: TColor;
  LFontColor: TColor;
  LBorderPen, LOldObj: HGDIOBJ;
begin
  Result := True;
  if FParentUI.FSectorItemMgr.FSelectedMarketId = FMarketId then begin
    LBackColor := FParentUI.FSectorItemHotColor;
    LFontColor := FParentUI.FSectorItemHotFontColor;
  end else begin
    LBackColor := FParentUI.FSectorItemColor;
    LFontColor := FParentUI.FSectorItemFontColor;
    if FParentUI.MouseMoveId = FId then begin
      LBackColor := FParentUI.FSectorItemHotColor;
      LFontColor := FParentUI.FSectorItemHotFontColor;
      if FParentUI.MouseDownId = FId then begin
        LBackColor := FParentUI.FSectorItemDownColor;
        LFontColor := FParentUI.FSectorItemDownFontColor;
      end;
    end;
  end;

  LRect := FRectEx;

  // DrawBack
  FillSolidRect(ARenderDC.MemDC, @FRectEx, LBackColor);

  // DrawText
  LOldObj := SelectObject(FParentUI.RenderDC.MemDC,
      FParentUI.FAppContext.GetGdiMgr.GetFontObjHeight20);
  try
    DrawTextX(ARenderDC.MemDC, FRectEx, FCaption, LFontColor, dtaCenter, False, False);
  finally
    SelectObject(ARenderDC.MemDC, LOldObj);
  end;

  // DrawLine
  LBorderPen := CreatePen(PS_SOLID, 1, FParentUI.FSectorItemLineColor);
  try
    LRect.Right := LRect.Right - 1;
    LOldObj := SelectObject(ARenderDC.MemDC, LBorderPen);
    try
      MoveToEx(ARenderDC.MemDC, LRect.Right, LRect.Top, nil);
      LineTo(ARenderDC.MemDC, LRect.Right, LRect.Bottom);
    finally
      SelectObject(ARenderDC.MemDC, LOldObj);
    end;
  finally
    DeleteObject(LBorderPen);
  end;
end;

{ TSectorChildItem }

constructor TSectorChildItem.Create(AParentUI: TSectorPriceMenuUI);
begin
  inherited Create;
  FParentUI := AParentUI;
  FId := FParentUI.GetUniqueId;
end;

destructor TSectorChildItem.Destroy;
begin

  inherited;
end;

function TSectorChildItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TSectorChildItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

function TSectorChildItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LRect: TRect;
  LBackColor: TColor;
  LFontColor: TColor;
  LRgnObj, LOldObj: HGDIOBJ;
begin
  Result := True;
  LBackColor := FParentUI.FSectorChildItemColor;
  LFontColor := FParentUI.FSectorChildItemFontColor;
  if (FParentUI.FSectorChildItemMgr.FSectorChildList <> nil)
    and (FParentUI.FSectorChildItemMgr.FSectorChildList.FSelectedModuleId = FModuleId) then begin
    LBackColor := FParentUI.FSectorChildItemHotColor;
    LFontColor := FParentUI.FSectorChildItemHotFontColor;
  end else begin
    if FParentUI.MouseMoveId = FId then begin
      LBackColor := FParentUI.FSectorChildItemHotColor;
      LFontColor := FParentUI.FSectorChildItemHotFontColor;
      if FParentUI.MouseDownId = FId then begin
        LBackColor := FParentUI.FSectorChildItemDownColor;
        LFontColor := FParentUI.FSectorChildItemDownFontColor;
      end;
    end;
  end;

//  // DrawBack
//  LRgnObj := CreateRoundRectRgn(FRectEx.Left, FRectEx.Top, FRectEx.Right, FRectEx.Bottom, 3, 3);
//  try
//    LOldObj := SelectObject(ARenderDC.MemDC, LRgnObj);
//    try
      FillSolidRect(ARenderDC.MemDC, @FRectEx, LBackColor);
//    finally
//      SelectObject(ARenderDC.MemDC, LOldObj);
//    end;
//  finally
//    DeleteObject(LRgnObj);
//  end;

  // DrawText
  LRect := FRectEx;
  LOldObj := SelectObject(FParentUI.RenderDC.MemDC,
      FParentUI.FAppContext.GetGdiMgr.GetFontObjHeight20);
  try
    DrawTextX(ARenderDC.MemDC, LRect, FCaption, LFontColor, dtaCenter, False, True);
  finally
    SelectObject(ARenderDC.MemDC, LOldObj);
  end;
end;

{ TSectorChildSubItem }

constructor TSectorChildSubItem.Create(AParentUI: TSectorPriceMenuUI);
begin
  inherited;
  FWidth := 100;
  FSubWidth := 20;
  FCaption := '';
end;

destructor TSectorChildSubItem.Destroy;
begin

  inherited;
end;

function TSectorChildSubItem.RectExIsValid: Boolean;
begin
  Result := (FRectEx.Left < FRectEx.Right) and (FRectEx.Width >= FWidth);
end;

function TSectorChildSubItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

function TSectorChildSubItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LRect: TRect;
  LSubColor: TColor;
  LBackColor: TColor;
  LFontColor: TColor;
  LPt, LPt1, LPt2: TPoint;
  LBorderPen, LOldObj: HGDIOBJ;
begin
  Result := True;
  LSubColor := FParentUI.FSectorChildItemFontColor;
  LBackColor := FParentUI.FSectorChildItemColor;
  LFontColor := FParentUI.FSectorChildItemFontColor;
  if (FParentUI.FSectorChildItemMgr.FSectorChildList <> nil)
    and (FParentUI.FSectorChildItemMgr.FSectorChildList.FSelectedModuleId = FModuleId) then begin
    LSubColor := FParentUI.FSectorChildItemHotFontColor;
    LBackColor := FParentUI.FSectorChildItemHotColor;
    LFontColor := FParentUI.FSectorChildItemHotFontColor;
  end else begin
    if FParentUI.MouseMoveId = FId then begin
      LSubColor := FParentUI.FSectorChildItemHotFontColor;
      LBackColor := FParentUI.FSectorChildItemHotColor;
      LFontColor := FParentUI.FSectorChildItemHotFontColor;
      if FParentUI.MouseDownId = FId then begin
        LSubColor := FParentUI.FSectorChildItemDownFontColor;
        LBackColor := FParentUI.FSectorChildItemDownColor;
        LFontColor := FParentUI.FSectorChildItemDownFontColor;
      end;
    end;
  end;

  // DrawBack
  FillSolidRect(ARenderDC.MemDC, @FRectEx, LBackColor);

  // DrawText
  LRect := FRectEx;
  LRect.Right := LRect.Right - FSubWidth;
  LOldObj := SelectObject(FParentUI.RenderDC.MemDC,
      FParentUI.FAppContext.GetGdiMgr.GetFontObjHeight20);
  try
    DrawTextX(ARenderDC.MemDC, LRect, FCaption, LFontColor, dtaCenter, False, True);
  finally
    SelectObject(ARenderDC.MemDC, LOldObj);
  end;

  // DrawIcon
  LRect := FRectEx;
  LRect.Left := LRect.Right - FSubWidth;
  LBorderPen := CreatePen(PS_SOLID, 2, LSubColor);
  try
    LOldObj := SelectObject(FParentUI.RenderDC.MemDC, LBorderPen);
    try
      LPt := Point((LRect.Left + LRect.Right) div 2, (LRect.Top + LRect.Bottom) div 2);
      LPt.X := LPt.X - 3;
      LPt1.X := LPt.X;
      LPt1.Y := LPt.Y + 3;
      LPt2.X := LPt.X - 6;
      LPt2.Y := LPt.Y - 3;
      MoveToEx(FParentUI.RenderDC.MemDC, LPt1.X, LPt1.Y, nil);
      LineTo(FParentUI.RenderDC.MemDC, LPt2.X, LPt2.Y);
      LPt1.X := LPt.X;
      LPt1.Y := LPt.Y + 3;
      LPt2.X := LPt.X + 6;
      LPt2.Y := LPt.Y - 3;
      MoveToEx(FParentUI.RenderDC.MemDC, LPt1.X, LPt1.Y, nil);
      LineTo(FParentUI.RenderDC.MemDC, LPt2.X, LPt2.Y);
    finally
      SelectObject(FParentUI.RenderDC.MemDC, LOldObj);
    end;
  finally
    DeleteObject(LBorderPen);
  end;
end;

{ TSectorChildAddItem }

constructor TSectorChildAddItem.Create(AParentUI: TSectorPriceMenuUI);
begin
  inherited;
  FWidth := 80;
  FIconSize.cx := 14;
  FIconSize.cy := 14;
  FIconWidth := 20;
  FCaption := '板块添加';
end;

destructor TSectorChildAddItem.Destroy;
begin

  inherited;
end;

function TSectorChildAddItem.RectExIsValid: Boolean;
begin
  Result := (FRectEx.Left < FRectEx.Right) and (FRectEx.Width >= FWidth);
end;

function TSectorChildAddItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

function TSectorChildAddItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LOldObj: HGDIOBJ;
  LBackColor: TColor;
  LFontColor: TColor;
  LRect, LTempRect: TRect;
  LResourceStream: TResourceStream;
begin
  Result := True;
  LBackColor := FParentUI.FSectorAddColor;
  LFontColor := FParentUI.FSectorAddFontColor;
  if FParentUI.MouseMoveId = FId then begin
    LBackColor := FParentUI.FSectorAddHotColor;
    LFontColor := FParentUI.FSectorAddHotFontColor;
    if FParentUI.MouseDownId = FId then begin
      LBackColor := FParentUI.FSectorAddDownColor;
      LFontColor := FParentUI.FSectorAddDownFontColor;
    end;
  end;

  // DrawBack
  FillSolidRect(ARenderDC.MemDC, @FRectEx, LBackColor);

  // DrawIcon
  LRect := FRectEx;
  LRect.Right := LRect.Left + FIconWidth;
  LRect.Left := (LRect.Left + LRect.Right - FIconSize.cx) div 2;
  LRect.Top := (LRect.Top + LRect.Bottom - FIconSize.cy + 2) div 2;
  LRect.Right := LRect.Left + FIconSize.cx;
  LRect.Bottom := LRect.Right + FIconSize.cy;
  LTempRect := LRect;
  OffsetRect(LTempRect, -LTempRect.Left, -LTempRect.Top);
  LResourceStream := FParentUI.FAddSectorResourceStream;
  if LResourceStream <> nil then begin
    DrawImageX(ARenderDC.GPGraphics, LResourceStream, LRect, LTempRect);
  end;

  // DrawText
  LRect := FRectEx;
  LRect.Left := LRect.Left + FIconWidth;
  LRect.Right := FRectEx.Right;
  LOldObj := SelectObject(FParentUI.RenderDC.MemDC,
      FParentUI.FAppContext.GetGdiMgr.GetFontObjHeight20);
  try
    DrawTextX(ARenderDC.MemDC, LRect, FCaption, LFontColor, dtaCenter, False, False);
  finally
    SelectObject(ARenderDC.MemDC, LOldObj);
  end;
end;

{ TSectorToolItem }

constructor TSectorToolItem.Create(AParentUI: TSectorPriceMenuUI);
begin
  inherited;
  FParentUI := AParentUI;

end;

destructor TSectorToolItem.Destroy;
begin

  inherited;
end;

function TSectorToolItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TSectorToolItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

{ TRankToolItem }

constructor TRankToolItem.Create(AParentUI: TSectorPriceMenuUI);
begin
  inherited;
  FEnable := True;
end;

destructor TRankToolItem.Destroy;
begin

  inherited;
end;

function TRankToolItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TRankToolItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

function TRankToolItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LRect: TRect;
  LResourceStream: TResourceStream;
begin
  Result := True;
  if FEnable then begin
    LResourceStream := FParentUI.FEnableRankToolResourceStream;
  end else begin
    LResourceStream := FParentUI.FUnEnableRankToolResourceStream;
  end;
  if LResourceStream = nil then Exit;

  LRect := FRectEx;
  OffsetRect(LRect, -LRect.Left, -LRect.Top);
  DrawImageX(ARenderDC.GPGraphics, LResourceStream, FRectEx, LRect);
end;

{ TPriceToolItem }

constructor TPriceToolItem.Create(AParentUI: TSectorPriceMenuUI);
begin
  inherited;

end;

destructor TPriceToolItem.Destroy;
begin

  inherited;
end;

function TPriceToolItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TPriceToolItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

function TPriceToolItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LRect: TRect;
  LResourceStream: TResourceStream;
begin
  Result := True;
  LResourceStream := FParentUI.FPriceResourceStream;
  if LResourceStream = nil then Exit;

  LRect := FRectEx;
  OffsetRect(LRect, -LRect.Left, -LRect.Top);
  DrawImageX(ARenderDC.GPGraphics, LResourceStream, FRectEx, LRect);
end;

{ TMultiStockToolItem }

constructor TMultiStockToolItem.Create(AParentUI: TSectorPriceMenuUI);
begin
  inherited;
  FEnable := True;
end;

destructor TMultiStockToolItem.Destroy;
begin

  inherited;
end;

function TMultiStockToolItem.RectExIsValid: Boolean;
begin
  Result := FRectEx.Left < FRectEx.Right;
end;

function TMultiStockToolItem.PtInRectEx(APt: TPoint): Boolean;
begin
  Result := PtInRect(FRectEx, APt);
end;

function TMultiStockToolItem.Draw(ARenderDC: TRenderDC): Boolean;
var
  LRect: TRect;
  LResourceStream: TResourceStream;
begin
  Result := True;
  if FEnable then begin
    LResourceStream := FParentUI.FEnableMultiStockToolResourceStream;
  end else begin
    LResourceStream := FParentUI.FUnEnableMultiStockToolResourceStream;
  end;
  if LResourceStream = nil then Exit;

  LRect := FRectEx;
  OffsetRect(LRect, -LRect.Left, -LRect.Top);
  DrawImageX(ARenderDC.GPGraphics, LResourceStream, FRectEx, LRect);
end;

{ TSectorItemMgr }

constructor TSectorItemMgr.Create(AContext: IAppContext; AParentUI: TSectorPriceMenuUI);
begin
  inherited Create(AContext);
  FHeight := 28;
  FItemWidth := 85;
  FParentUI := AParentUI;
  FSectorItems := TList<TSectorItem>.Create;
end;

destructor TSectorItemMgr.Destroy;
begin
  DoClearSectorItems;
  FSectorItems.Free;
  inherited;
end;

procedure TSectorItemMgr.DoClearSectorItems;
var
  LIndex: Integer;
  LSectorItem: TSectorItem;
begin
  for LIndex := 0 to FSectorItems.Count - 1 do begin
    LSectorItem := FSectorItems.Items[LIndex];
    if LSectorItem <> nil then begin
      LSectorItem.Free;
    end;
  end;
  FSectorItems.Clear;
end;

procedure TSectorItemMgr.DoDrawBack;
begin
  FillSolidRect(FParentUI.RenderDC.MemDC, @FComponentsRect, FParentUI.FSectorItemBackColor);
end;

procedure TSectorItemMgr.DoDrawBorder;
var
  LRect: TRect;
  LBorderPen, LOldObj: HGDIOBJ;
begin
  LRect := FComponentsRect;
  // DrawLine
  LBorderPen := CreatePen(PS_SOLID, 1, FParentUI.FSectorItemLineColor);
  try
    LOldObj := SelectObject(FParentUI.RenderDC.MemDC, LBorderPen);
    try
      MoveToEx(FParentUI.RenderDC.MemDC, LRect.Left, LRect.Bottom, nil);
      LineTo(FParentUI.RenderDC.MemDC, LRect.Right, LRect.Bottom);
    finally
      SelectObject(FParentUI.RenderDC.MemDC, LOldObj);
    end;
  finally
    DeleteObject(LBorderPen);
  end;
end;

procedure TSectorItemMgr.Calc;
var
  LRect: TRect;
  LIndex: Integer;
  LSectorItem: TSectorItem;
begin
  LRect := FComponentsRect;
  LRect.Right := LRect.Left;
  LRect.Bottom := LRect.Bottom - 1;
  for LIndex := 0 to FSectorItems.Count - 1 do begin
    LSectorItem := FSectorItems.Items[LIndex];
    if LSectorItem <> nil then begin
      LRect.Left := LRect.Right;
      LRect.Right := LRect.Left + FItemWidth;
      LSectorItem.FRectEx := LRect;
    end;
  end;
end;

procedure TSectorItemMgr.Draw;
var
  LIndex: Integer;
  LSectorItem: TSectorItem;
begin
  DoDrawBack;
  for LIndex := 0 to FSectorItems.Count - 1 do begin
    LSectorItem := FSectorItems.Items[LIndex];
    if (LSectorItem <> nil) then begin
      LSectorItem.Draw(FParentUI.RenderDC);
    end;
  end;
  DoDrawBorder;
end;

function TSectorItemMgr.ChangeMarket(AMarketId: Integer): Boolean;
begin
  Result := False;
  if FSelectedMarketId <> AMarketId then begin
    Result := True;
    FSelectedMarketId := AMarketId;
  end;
end;

function TSectorItemMgr.Add(AMarketId, ASectorId: Integer; ACaption: string): TSectorItem;
begin
  Result := TSectorItem.Create(FParentUI);
  Result.FMarketId := AMarketId;
  Result.FSectorId := ASectorId;
  Result.Caption := ACaption;
  FSectorItems.Add(Result);
end;

function TSectorItemMgr.Find(APt: TPoint; var AComponent: TComponentUI): Boolean;
var
  LIndex: Integer;
  LSectorItem: TSectorItem;
begin
  Result := False;
  AComponent := nil;
  for LIndex := 0 to FSectorItems.Count - 1 do begin
    LSectorItem := FSectorItems.Items[LIndex];
    if (LSectorItem <> nil)
      and LSectorItem.PtInRectEx(APt) then begin
      Result := True;
      AComponent := LSectorItem;
      Exit;
    end;
  end;
end;

{ TSectorChildList }

constructor TSectorChildList.Create(AContext: IAppContext; AParentUI: TSectorPriceMenuUI);
begin
  inherited Create(AContext);
  FParentUI := AParentUI;
  FSectorChildItems := TList<TSectorChildItem>.Create;
  FModuleIdDic := TDictionary<Integer, Integer>.Create;
  FItemWidth := 105;
  FItemSpace := 10;
  FItemHeight := 24;
  FShowCount := 0;
  FSelectedModuleId := -1;
end;

destructor TSectorChildList.Destroy;
begin
  DoClearItems(FSectorChildItems);
  FSectorChildItems.Free;
  FModuleIdDic.Free;
  inherited;
end;

procedure TSectorChildList.DoClearItems(AList: TList<TSectorChildItem>);
var
  LIndex: Integer;
  LSectorChildItem: TSectorChildItem;
begin
  for LIndex := 0 to AList.Count - 1 do begin
    LSectorChildItem := AList.Items[LIndex];
    if LSectorChildItem <> nil then begin
      LSectorChildItem.Free;
    end;
  end;
  AList.Clear;
end;

function TSectorChildList.GetIndex(AModuleId: Integer): Integer;
begin
  if not FModuleIdDic.TryGetValue(AModuleId, Result) then begin
    Result := -1;
  end;
end;

function TSectorChildList.GetSectorChildItem(AIndex: Integer): TSectorChildItem;
begin
  if (AIndex >= 0)
    and (AIndex < FSectorChildItems.Count) then begin
    Result := TSectorChildItem(FSectorChildItems.Items[AIndex]);
  end else begin
    Result := nil;
  end;
end;

procedure TSectorChildList.Calc;
var
  LRect: TRect;
  LSectorChildItem: TSectorChildItem;
  LIndex, LCount, LTotalWidth, LWidth: Integer;
begin
  if FParentUI.FSectorChildItemMgr.FSectorChildAddItem.Visible then begin
    LTotalWidth := FComponentsRect.Width - FParentUI.FSectorChildItemMgr.FSectorChildAddItem.FWidth - FItemSpace;
  end else begin
    LTotalWidth := FComponentsRect.Width;
  end;

  LWidth := FItemWidth + FItemSpace;
  if LTotalWidth > 0 then begin
    LCount := LTotalWidth div LWidth;
  end else begin
    LCount := 0;
  end;

  if LCount >= FSectorChildItems.Count then begin
    LCount := FSectorChildItems.Count;
    FParentUI.FSectorChildItemMgr.FSectorChildSubItem.Visible := False;
  end else begin
    LTotalWidth := LTotalWidth - FParentUI.FSectorChildItemMgr.FSectorChildSubItem.FWidth - FItemSpace;
    LCount := LTotalWidth div LWidth;
    FParentUI.FSectorChildItemMgr.FSectorChildSubItem.Visible := True;
  end;

  LRect := FComponentsRect;
  LRect.Right := LRect.Left;
  LRect.Top := (LRect.Top + LRect.Bottom - FItemHeight) div 2;
  LRect.Bottom := LRect.Top + FItemHeight;
  for LIndex := 0 to LCount - 1 do begin
    LSectorChildItem := FSectorChildItems.Items[LIndex];
    if LSectorChildItem <> nil then begin
      LRect.Left := LRect.Right + FItemSpace;
      LRect.Right := LRect.Left + FItemWidth;
      LSectorChildItem.FRectEx := LRect;
    end;
  end;

  if FParentUI.FSectorChildItemMgr.FSectorChildSubItem.Visible then begin
    LRect.Left := LRect.Right + FItemSpace;
    LRect.Right := LRect.Left + FParentUI.FSectorChildItemMgr.FSectorChildSubItem.FWidth;
    if LRect.Left > FComponentsRect.Right then begin
      LRect.Left := FComponentsRect.Right;
    end;
    if LRect.Right > FComponentsRect.Right then begin
      LRect.Right := FComponentsRect.Right;
    end;
    FParentUI.FSectorChildItemMgr.FSectorChildSubItem.RectEx := LRect;
    LIndex := GetIndex(FSelectedModuleId);
    if LIndex <> -1 then begin
      if LIndex < LCount then begin
        LSectorChildItem := GetSectorChildItem(LCount);
        if LSectorChildItem <> nil then begin
          FParentUI.FSectorChildItemMgr.FSectorChildSubItem.FSectorId := LSectorChildItem.FSectorId;
          FParentUI.FSectorChildItemMgr.FSectorChildSubItem.FModuleId := LSectorChildItem.FModuleId;
          FParentUI.FSectorChildItemMgr.FSectorChildSubItem.FCaption := LSectorChildItem.Caption;
        end;
      end else begin
        LSectorChildItem := GetSectorChildItem(LIndex);
        if LSectorChildItem <> nil then begin
          FParentUI.FSectorChildItemMgr.FSectorChildSubItem.FSectorId := LSectorChildItem.FSectorId;
          FParentUI.FSectorChildItemMgr.FSectorChildSubItem.FModuleId := LSectorChildItem.FModuleId;
          FParentUI.FSectorChildItemMgr.FSectorChildSubItem.FCaption := LSectorChildItem.Caption;
        end;
      end;
    end;
  end;

  if FParentUI.FSectorChildItemMgr.FSectorChildAddItem.Visible then begin
    LRect.Left := LRect.Right + FItemSpace;
    LRect.Right := LRect.Left + FParentUI.FSectorChildItemMgr.FSectorChildAddItem.FWidth;
    if LRect.Left > FComponentsRect.Right then begin
      LRect.Left := FComponentsRect.Right;
    end;
    if LRect.Right > FComponentsRect.Right then begin
      LRect.Right := FComponentsRect.Right;
    end;
    FParentUI.FSectorChildItemMgr.FSectorChildAddItem.RectEx := LRect;
  end;

  FShowCount := LCount;
end;

procedure TSectorChildList.Draw;
var
  LIndex, LCount: Integer;
  LSectorChildItem: TSectorChildItem;
begin
  LCount := FShowCount;
  for LIndex := 0 to LCount - 1 do begin
    if (LIndex > FSectorChildItems.Count - 1) then begin
      Break;
    end;
    LSectorChildItem := FSectorChildItems.Items[LIndex];
    if LSectorChildItem <> nil then begin
      LSectorChildItem.Draw(FParentUI.RenderDC);
    end;
  end;

  if FParentUI.FSectorChildItemMgr.FSectorChildSubItem.Visible
    and FParentUI.FSectorChildItemMgr.FSectorChildSubItem.RectExIsValid then begin
    FParentUI.FSectorChildItemMgr.FSectorChildSubItem.Draw(FParentUI.RenderDC);
  end;

  if FParentUI.FSectorChildItemMgr.FSectorChildAddItem.Visible
    and FParentUI.FSectorChildItemMgr.FSectorChildAddItem.RectExIsValid then begin
    FParentUI.FSectorChildItemMgr.FSectorChildAddItem.Draw(FParentUI.RenderDC);
  end;
end;

function TSectorChildList.Change(AModuleId: Integer): Boolean;
begin
  Result := False;
  if FSelectedModuleId <> AModuleId then begin
    Result := True;
    FSelectedModuleId := AModuleId;
  end;
end;

function TSectorChildList.IsHasModule(AModuleId: Integer): Boolean;
begin
  if FModuleIdDic.ContainsKey(AModuleId) then begin
    Result := True;
  end else begin
    Result := False;
  end;
end;

function TSectorChildList.Find(APt: TPoint; var AComponent: TComponentUI): Boolean;
var
  LIndex, LCount: Integer;
  LSectorChildItem: TSectorChildItem;
begin
  Result := False;
  AComponent := nil;
  LCount := FShowCount;
  for LIndex := 0 to LCount - 1 do begin
    if (LIndex > FSectorChildItems.Count - 1) then begin
      Break;
    end;
    LSectorChildItem := FSectorChildItems.Items[LIndex];
    if (LSectorChildItem <> nil)
      and LSectorChildItem.PtInRectEx(APt) then begin
      Result := True;
      AComponent := LSectorChildItem;
      Exit;
    end;
  end;
end;

function TSectorChildList.Add(AModuleId, ASectorId: Integer; ACaption: string): TSectorChildItem;
var
  LIndex: Integer;
begin
  Result := TSectorChildItem.Create(FParentUI);
  Result.FModuleId := AModuleId;
  Result.FSectorId := ASectorId;
  Result.Caption := ACaption;
  LIndex := FSectorChildItems.Add(Result);
  FModuleIdDic.AddOrSetValue(Result.FModuleId, LIndex);
end;

{ TAttentionSectorChildList }

constructor TAttentionSectorChildList.Create(AContext: IAppContext; AParentUI: TSectorPriceMenuUI);
begin
  inherited;
  FDefaultChildItems := TList<TSectorChildItem>.Create;
  FAttentionChildItems := TList<TSectorChildItem>.Create;
end;

destructor TAttentionSectorChildList.Destroy;
begin
  DoClearItems(FAttentionChildItems);
  DoClearItems(FDefaultChildItems);
  FAttentionChildItems.Free;
  FDefaultChildItems.Free;
  FSectorChildItems.Clear;
  inherited;
end;

procedure TAttentionSectorChildList.ClearAttentionChildItems;
var
  LIndex, LId: Integer;
  LSectorChildItem: TSectorChildItem;
begin
  FModuleIdDic.Clear;
  FSectorChildItems.Clear;
  for LIndex := 0 to FDefaultChildItems.Count - 1 do begin
    LSectorChildItem := FDefaultChildItems.Items[LIndex];
    if LSectorChildItem <> nil then begin
      LId := FSectorChildItems.Add(LSectorChildItem);
      FModuleIdDic.AddOrSetValue(LSectorChildItem.FModuleId, LId);
    end;
  end;
  DoClearItems(FAttentionChildItems);
end;

function TAttentionSectorChildList.Add(AModuleId, ASectorId: Integer; ACaption: string): TSectorChildItem;
begin
  if not FModuleIdDic.ContainsKey(AModuleId) then begin
    Result := TSectorChildItem.Create(FParentUI);
    Result.FModuleId := AModuleId;
    Result.FSectorId := ASectorId;
    Result.Caption := ACaption;
    FDefaultChildItems.Add(Result);
  end else begin
    Result := nil;
  end;
end;

function TAttentionSectorChildList.AttentionChildAdd(AModuleId, ASectorId: Integer; ACaption: string): TSectorChildItem;
var
  LIndex: Integer;
begin
  if not FModuleIdDic.ContainsKey(AModuleId) then begin
    Result := TSectorChildItem.Create(FParentUI);
    Result.FModuleId := AModuleId;
    Result.FSectorId := ASectorId;
    Result.Caption := Copy(ACaption, 1, Length(ACaption));
    FAttentionChildItems.Add(Result);
    LIndex := FSectorChildItems.Add(Result);
    FModuleIdDic.AddOrSetValue(Result.FModuleId, LIndex);
  end else begin
    Result := nil;
  end;
end;

{ TSectorChildItemMgr }

constructor TSectorChildItemMgr.Create(AContext: IAppContext; AParentUI: TSectorPriceMenuUI);
begin
  inherited Create(AContext);
  FParentUI := AParentUI;
  FSectorChildSubItem := TSectorChildSubItem.Create(FParentUI);
  FSectorChildAddItem := TSectorChildAddItem.Create(FParentUI);
  FSectorChildListDic := TDictionary<Integer, TSectorChildList>.Create;
  FHeight := 28;
end;

destructor TSectorChildItemMgr.Destroy;
begin
  DoClearSectorChildListDic;
  FSectorChildAddItem.Free;
  FSectorChildSubItem.Free;
  FSectorChildListDic.Free;
  inherited;
end;

procedure TSectorChildItemMgr.DoClearSectorChildListDic;
var
  LIndex: Integer;
  LSectorChildList: TSectorChildList;
  LSectorChildLists: TArray<TSectorChildList>;
begin
  LSectorChildLists := FSectorChildListDic.Values.ToArray;
  for LIndex := Low(LSectorChildLists) to High(LSectorChildLists) do begin
    LSectorChildList := LSectorChildLists[LIndex];
    if LSectorChildList <> nil then begin
      LSectorChildList.Free;
    end;
  end;
  FSectorChildListDic.Clear;
end;

procedure TSectorChildItemMgr.DoDrawBack;
begin
  FillSolidRect(FParentUI.RenderDC.MemDC, @FComponentsRect, FParentUI.FSectorChildItemBackColor);
end;

procedure TSectorChildItemMgr.DoDrawBorder;
begin

end;

procedure TSectorChildItemMgr.Calc;
begin
  if FSectorChildList <> nil then begin
    FSectorChildList.FComponentsRect := FComponentsRect;
    FSectorChildList.Calc;
  end;
end;

procedure TSectorChildItemMgr.Draw;
begin
  DoDrawBack;
  if FSectorChildList <> nil then begin
    FSectorChildList.Draw;
  end;
  DoDrawBorder;
end;

function TSectorChildItemMgr.ChangeModule(AMarketId, AModuleId: Integer; var IsCalc: Boolean): Boolean;
var
  LVisible: Boolean;
  LModuleId: Integer;
  LSectorChildItem: TSectorChildItem;
  LSectorChildList: TSectorChildList;
begin
  IsCalc := False;
  Result := False;
  if not ((FSectorChildList <> nil) and (FSectorChildList.FMarketId = AMarketId)) then begin
    if FSectorChildListDic.TryGetValue(AMarketId, LSectorChildList) then begin
      if LSectorChildList <> FSectorChildList then begin
        IsCalc := True;
        Result := True;
        FSectorChildList := LSectorChildList;
      end;
    end;
  end;

  LVisible := AMarketId = MARKETID_ATTENTION;
  if FSectorChildAddItem.Visible <> LVisible then begin
    IsCalc := True;
    Result := True;
    FSectorChildAddItem.Visible := LVisible;
  end;

  if FSectorChildList <> nil then begin

    if FSectorChildList.IsHasModule(AModuleId) then begin
      LModuleId := AModuleId;
      if FSectorChildList.Change(LModuleId) then begin
        Result := True;
      end;
    end else begin

      if AModuleId = -1 then begin
        LModuleId := FSectorChildList.FSelectedModuleId;
        if LModuleId = -1 then begin
          LSectorChildItem := FSectorChildList.GetSectorChildItem(0);
          if LSectorChildItem <> nil then begin
            LModuleId := LSectorChildItem.FModuleId;
            if FSectorChildList.Change(LModuleId) then begin
              Result := True;
            end;
          end;
        end;
      end;
    end;

  end;
end;

function TSectorChildItemMgr.Add(AMarketId, AModuleId, ASectorId: Integer; ACaption: string): TSectorChildItem;
var
  LSectorChildList: TSectorChildList;
begin
  if FSectorChildListDic.TryGetValue(AMarketId, LSectorChildList) then begin
    Result := LSectorChildList.Add(AModuleId, ASectorId, ACaption);
  end else begin
    if AMarketId = MARKETID_ATTENTION then begin
      FAttentionSectorChildList := TAttentionSectorChildList.Create(FAppContext, FParentUI);
      LSectorChildList := FAttentionSectorChildList;
    end else begin
      LSectorChildList := TSectorChildList.Create(FAppContext, FParentUI);
    end;
    LSectorChildList.FMarketId := AMarketId;
    FSectorChildListDic.AddOrSetValue(AMarketId, LSectorChildList);
    Result := LSectorChildList.Add(AModuleId, ASectorId, ACaption);
  end;
end;

function TSectorChildItemMgr.Find(APt: TPoint; var AComponent: TComponentUI): Boolean;
begin
  if FSectorChildList <> nil then begin
    Result := FSectorChildList.Find(APt, AComponent);
    if (not Result)
      and FSectorChildSubItem.Visible
       then begin
      if FSectorChildSubItem.PtInRectEx(APt) then begin
        Result := True;
        AComponent := FSectorChildSubItem;
      end;
    end;

    if not Result
      and FSectorChildAddItem.Visible
      and FSectorChildAddItem.PtInRectEx(APt) then begin
      Result := True;
      AComponent := FSectorChildAddItem;
    end;
  end else begin
    Result := False;
  end;
end;

{ TSectorToolItemMgr }

constructor TSectorToolItemMgr.Create(AContext: IAppContext;
  AParentUI: TSectorPriceMenuUI);
begin
  inherited Create(FAppContext);
  FParentUI := AParentUI;
  FWidth := 70;
  FItemSpace := 10;
  FItemWidth := 22;
  FItemHeight := 20;
  FSectorToolItems := TList<TSectorToolItem>.Create;
  FRankToolItem := TRankToolItem.Create(AParentUI);
  FPriceToolItem := TPriceToolItem.Create(AParentUI);
  FMultiStockToolItem := TMultiStockToolItem.Create(AParentUI);
  FPriceToolItem.Visible := False;
  FSectorToolItems.Add(FRankToolItem);
  FSectorToolItems.Add(FPriceToolItem);
  FSectorToolItems.Add(FMultiStockToolItem);
  FParentUI.DoAddComponent(FRankToolItem);
  FParentUI.DoAddComponent(FPriceToolItem);
  FParentUI.DoAddComponent(FMultiStockToolItem);
end;

destructor TSectorToolItemMgr.Destroy;
begin
  FMultiStockToolItem.Free;
  FPriceToolItem.Free;
  FRankToolItem.Free;
  FSectorToolItems.Free;
  inherited;
end;

procedure TSectorToolItemMgr.DoDrawBack;
begin
  FillSolidRect(FParentUI.RenderDC.MemDC, @FComponentsRect, FParentUI.FSectorChildItemBackColor);
end;

procedure TSectorToolItemMgr.DoDrawBorder;
begin

end;

procedure TSectorToolItemMgr.Calc;
var
  LRect: TRect;
  LIndex: Integer;
  LSectorToolItem: TSectorToolItem;
begin
  LRect := FComponentsRect;
  LRect.Left := LRect.Right;
  LRect.Top := (LRect.Top + LRect.Bottom - FItemHeight) div 2;
  LRect.Bottom := LRect.Top + FItemHeight;
  for LIndex := 0 to FSectorToolItems.Count - 1 do begin
    LSectorToolItem := FSectorToolItems.Items[LIndex];
    if (LSectorToolItem <> nil)
      and LSectorToolItem.Visible then begin
      LRect.Right := LRect.Left - FItemSpace;
      LRect.Left := LRect.Right - FItemWidth;
      LSectorToolItem.FRectEx := LRect;
    end;
  end;
end;

procedure TSectorToolItemMgr.Draw;
var
  LIndex: Integer;
  LSectorToolItem: TSectorToolItem;
begin
  DoDrawBack;
  for LIndex := 0 to FSectorToolItems.Count - 1 do begin
    LSectorToolItem := FSectorToolItems.Items[LIndex];
    if (LSectorToolItem <> nil)
      and LSectorToolItem.Visible then begin
      LSectorToolItem.Draw(FParentUI.RenderDC);
    end;
  end;
  DoDrawBorder;
end;

function TSectorToolItemMgr.Find(APt: TPoint; var AComponent: TComponentUI): Boolean;
var
  LIndex: Integer;
  LSectorItem: TSectorItem;
begin
  Result := False;
  AComponent := nil;
  for LIndex := 0 to FSectorToolItems.Count - 1 do begin
    LSectorItem := FSectorToolItems.Items[LIndex];
    if (LSectorItem <> nil)
      and LSectorItem.PtInRectEx(APt) then begin
      Result := True;
      AComponent := LSectorItem;
      Exit;
    end;
  end;
end;

{ TSectorPriceMenuUI }

constructor TSectorPriceMenuUI.Create(AContext: IAppContext);
begin
  inherited;
  FUserAttentionMgr := FAppContext.FindInterface(ASF_COMMAND_ID_USERATTENTIONMGR) as IUserAttentionMgr;
  FSectorItemMgr := TSectorItemMgr.Create(FAppContext, Self);
  FSectorToolItemMgr := TSectorToolItemMgr.Create(FAppContext, Self);
  FSectorChildItemMgr := TSectorChildItemMgr.Create(FAppContext, Self);
  FMsgExSubcriberAdapter := TMsgExSubcriberAdapter.Create(FAppContext, DoUpdateMsgEx);
  FMsgExSubcriberAdapter.AddSubcribeMsgEx(Msg_AsfMem_ReUpdateUserAttentionMgr);
  FMsgExSubcriberAdapter.SubcribeMsgEx;
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(True);
  Height := FSectorItemMgr.FHeight + FSectorChildItemMgr.FHeight;
  DoUpdateSkinStyle;
//  DoAddTestData;
  DoReadCfgData;
  DoUpdateAttentionData;
  Change(MARKETID_ATTENTION, MODULEID_SELF);
end;

destructor TSectorPriceMenuUI.Destroy;
begin
  FMsgExSubcriberAdapter.SetSubcribeMsgExState(False);
  FMsgExSubcriberAdapter.Free;
  if FSubPopMenu <> nil then begin
    FSubPopMenu.Free;
  end;
  FSectorChildItemMgr.Free;
  FSectorToolItemMgr.Free;
  FSectorItemMgr.Free;
  FComponents.Clear;
  FUserAttentionMgr := nil;
  inherited;
end;

procedure TSectorPriceMenuUI.Change(AMarketId, AModuleId: Integer);
var
  LIsInvalidate, LIsCalc: Boolean;
begin
  LIsInvalidate := FSectorItemMgr.ChangeMarket(AMarketId);
  LIsInvalidate := FSectorChildItemMgr.ChangeModule(AMarketId, AModuleId, LIsCalc) or LIsInvalidate;
  if LIsCalc then begin
    FSectorChildItemMgr.Calc;
  end;
  if LIsInvalidate then begin
    Invalidate;
  end;
end;

procedure TSectorPriceMenuUI.DoAddTestData;
var
  LSectorItem: TSectorItem;
  LSectorChildItem: TSectorChildItem;
  LCaption, LChildCaption: string;
  LModuleId, LSectorId, LChildModuleId, LChildSectorId: Integer;
begin
  LModuleId := 1000;
  LSectorId := 3;
  LCaption := '我的关注';
  LSectorItem := FSectorItemMgr.Add(LModuleId, LSectorId, LCaption);
  DoAddComponent(LSectorItem);
  LChildModuleId := 1001;
  LChildSectorId := 4;
  LChildCaption := '自选';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 1101;
  LChildSectorId := 5;
  LChildCaption := '持仓';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);


  LModuleId := 0;
  LSectorId := 0;
  LCaption := '综合屏';
  LSectorItem := FSectorItemMgr.Add(LModuleId, LSectorId, LCaption);
  DoAddComponent(LSectorItem);
  LChildModuleId := 1;
  LChildSectorId := 0;
  LChildCaption := '沪深A股';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 2;
  LChildSectorId := 0;
  LChildCaption := 'A股板块';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 3;
  LChildSectorId := 0;
  LChildCaption := '股指期货';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);


  LModuleId := 2000;
  LSectorId := 7;
  LCaption := '沪深股票';
  LSectorItem := FSectorItemMgr.Add(LModuleId, LSectorId, LCaption);
  DoAddComponent(LSectorItem);
  LChildModuleId := 2001;
  LChildSectorId := 8;
  LChildCaption := '沪深A股';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 2002;
  LChildSectorId := 9;
  LChildCaption := '上证A股';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 2003;
  LChildSectorId := 10;
  LChildCaption := '深证A股';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 2004;
  LChildSectorId := 13;
  LChildCaption := '中小板';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 2005;
  LChildSectorId := 14;
  LChildCaption := '创业板';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 2006;
  LChildSectorId := 15;
  LChildCaption := '沪深B股';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 2007;
  LChildSectorId := 16;
  LChildCaption := '上证B股';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 2008;
  LChildSectorId := 17;
  LChildCaption := '深证B股';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);


  LModuleId := 3000;
  LSectorId := 50;
  LCaption := '股  转';
  LSectorItem := FSectorItemMgr.Add(LModuleId, LSectorId, LCaption);
  DoAddComponent(LSectorItem);
  LChildModuleId := 3001;
  LChildSectorId := 54;
  LChildCaption := '集合竞价转让';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 3002;
  LChildSectorId := 52;
  LChildCaption := '做市转让';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 3003;
  LChildSectorId := 53;
  LChildCaption := '两网及退市';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);


  LModuleId := 6000;
  LSectorId := 196;
  LCaption := '港  股';
  LSectorItem := FSectorItemMgr.Add(LModuleId, LSectorId, LCaption);
  DoAddComponent(LSectorItem);
  LChildModuleId := 6001;
  LChildSectorId := 197;
  LChildCaption := '香港主板';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 6002;
  LChildSectorId := 198;
  LChildCaption := '创业板';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 6003;
  LChildSectorId := 202;
  LChildCaption := '恒指成分股';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 6004;
  LChildSectorId := 200;
  LChildCaption := '国指成分股';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);

  LModuleId := 9000;
  LSectorId := 300;
  LCaption := '美  股';
  FSectorItemMgr.Add(LModuleId, LSectorId, LCaption);
  DoAddComponent(LSectorItem);
  LChildModuleId := 9001;
  LChildSectorId := 301;
  LChildCaption := '中概股';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 9002;
  LChildSectorId := 302;
  LChildCaption := '明星股';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 9003;
  LChildSectorId := 303;
  LChildCaption := '纽交所';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 9004;
  LChildSectorId := 304;
  LChildCaption := '美交所';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 9005;
  LChildSectorId := 305;
  LChildCaption := '纳斯达克';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);


  LModuleId := 5000;
  LSectorId := 182;
  LCaption := '债  券';
  FSectorItemMgr.Add(LModuleId, LSectorId, LCaption);
  DoAddComponent(LSectorItem);
  LChildModuleId := 5001;
  LChildSectorId := 183;
  LChildCaption := '上证债券';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 5002;
  LChildSectorId := 187;
  LChildCaption := '深证债券';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 5003;
  LChildSectorId := 185;
  LChildCaption := '上证企债';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 5004;
  LChildSectorId := 184;
  LChildCaption := '上证国债';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 5005;
  LChildSectorId := 184;
  LChildCaption := '公司债';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 5006;
  LChildSectorId := 186;
  LChildCaption := '可转债';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 5007;
  LChildSectorId := 191;
  LChildCaption := '债券回购';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);


  LModuleId := 7000;
  LSectorId := 243;
  LCaption := '期  货';
  LSectorItem := FSectorItemMgr.Add(LModuleId, LSectorId, LCaption);
  DoAddComponent(LSectorItem);
  LChildModuleId := 7004;
  LChildSectorId := 247;
  LChildCaption := '中金所';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 7001;
  LChildSectorId := 244;
  LChildCaption := '上期所';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 7002;
  LChildSectorId := 246;
  LChildCaption := '大商所';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 7003;
  LChildSectorId := 245;
  LChildCaption := '郑商所';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);


  LModuleId := 4000;
  LSectorId := 174;
  LCaption := '基  金';
  FSectorItemMgr.Add(LModuleId, LSectorId, LCaption);
  DoAddComponent(LSectorItem);
  LChildModuleId := 4001;
  LChildSectorId := 1248;
  LChildCaption := '上证基金';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 4002;
  LChildSectorId := 1249;
  LChildCaption := '深证基金';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 4003;
  LChildSectorId := 177;
  LChildCaption := 'ETF';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 4004;
  LChildSectorId := 178;
  LChildCaption := 'LOF';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 4005;
  LChildSectorId := 176;
  LChildCaption := '分级基金';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 4006;
  LChildSectorId := 175;
  LChildCaption := '封闭基金';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 4007;
  LChildSectorId := 262;
  LChildCaption := '货币基金';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);


  LModuleId := 8000;
  LSectorId := 249;
  LCaption := '指  数';
  LSectorItem := FSectorItemMgr.Add(LModuleId, LSectorId, LCaption);
  DoAddComponent(LSectorItem);
  LChildModuleId := 8001;
  LChildSectorId := 776;
  LChildCaption := '沪深指数';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 8003;
  LChildSectorId := 255;
  LChildCaption := '申万一级';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 8004;
  LChildSectorId := 256;
  LChildCaption := '申万二级';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 8005;
  LChildSectorId := 281;
  LChildCaption := '中信一级';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 8006;
  LChildSectorId := 282;
  LChildCaption := '中信二级';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
  LChildModuleId := 8007;
  LChildSectorId := 175;
  LChildCaption := '国外指数';
  LSectorChildItem := FSectorChildItemMgr.Add(LModuleId, LChildModuleId, LChildSectorId, LChildCaption);
  DoAddComponent(LSectorChildItem);
end;

procedure TSectorPriceMenuUI.DoReadCfgData;
var
  LNodeList: TList;
  LXml: TNativeXml;
  LNode, LChildNode: TXmlNode;
  LFile, LName: string;
  LIndex, LMarketId, LSectorId: Integer;
begin
  LFile := FAppContext.GetCfg.GetCfgPath + 'Menu\SectorPriceMenu.xml';
  if FileExists(LFile) then begin
    LXml := TNativeXml.Create(nil);
    try
      LXml.LoadFromFile(LFile);
      LXml.XmlFormat := xfReadable;
      LNode := LXml.Root;
      LNodeList := TList.Create;
      try
        LNode.FindNodes('Level_1', LNodeList);
        for LIndex := 0 to LNodeList.Count - 1 do begin
          LChildNode := LNodeList.Items[LIndex];
          if LChildNode <> nil then begin
            LMarketId := StrToIntDef(string(LChildNode.AttributeValueByName[UTF8String('MarketId')]), -1);
            LSectorId := StrToIntDef(string(LChildNode.AttributeValueByName[UTF8String('SectorId')]), -1);
            LName := LChildNode.AttributeValueByName[UTF8String('Name')];
            if (LMarketId <> -1)
              and (LSectorId <> -1)
              and (LName <> '') then begin
              FSectorItemMgr.Add(LMarketId, LSectorId, LName);
              DoAddChildData(LMarketId, LChildNode);
            end;
          end;
        end;
      finally
        LNodeList.Free;
      end;
    finally
      LXml.Free;
    end;
  end;
end;

procedure TSectorPriceMenuUI.DoAddChildData(AMarketId: Integer; ANode: TXmlNode);
var
  LName: string;
  LNodeList: TList;
  LChildNode: TXmlNode;
  LIndex, LModuleId, LSectorId: Integer;
begin
  LNodeList := TList.Create;
  try
    ANode.FindNodes('Level_2', LNodeList);
    for LIndex := 0 to LNodeList.Count - 1 do begin
      LChildNode := LNodeList.Items[LIndex];
      if LChildNode <> nil then begin
        LModuleId := StrToIntDef(string(LChildNode.AttributeValueByName[UTF8String('ModuleId')]), -1);
        LSectorId := StrToIntDef(string(LChildNode.AttributeValueByName[UTF8String('SectorId')]), -1);
        LName := LChildNode.AttributeValueByName[UTF8String('Name')];
        if (LModuleId <> -1)
          and (LSectorId <> -1)
          and (LName <> '') then begin
          FSectorChildItemMgr.Add(AMarketId, LModuleId, LSectorId, LName);
        end;
      end;
    end;
  finally
    LNodeList.Free;
  end;
end;

function TSectorPriceMenuUI.DoUpdateAttentionData: Boolean;
var
  LIndex: Integer;
  LAttention: TAttention;
begin
  Result := False;
  if FUserAttentionMgr = nil then Exit;

  FUserAttentionMgr.Lock;
  try
    if FSectorChildItemMgr.FAttentionSectorChildList = nil then begin
      FSectorChildItemMgr.FAttentionSectorChildList := TAttentionSectorChildList.Create(FAppContext, Self);
    end;
    FSectorChildItemMgr.FAttentionSectorChildList.ClearAttentionChildItems;
    for LIndex := 0 to FUserAttentionMgr.GetCount - 1 do begin
      LAttention := FUserAttentionMgr.GetAttention(LIndex);
      if LAttention <> nil then begin
        Result := (FSectorChildItemMgr.FAttentionSectorChildList.AttentionChildAdd(LAttention.ModuleId,
          LAttention.SectorId, LAttention.Name) <> nil) or Result;
      end;
    end;
  finally
    FUserAttentionMgr.UnLock;
  end;
end;

procedure TSectorPriceMenuUI.DoUpdateSkinStyle;
var
  LPriceResourceStream: TResourceStream;
begin
  FSectorItemBackColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_MainBackColor');
  FSectorItemColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_MainBackColor');
  FSectorItemFontColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_MainButtonFontColor');
  FSectorItemHotColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_MainBackColor');
  FSectorItemHotFontColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_MainButtonSelectedFontColor');
  FSectorItemDownColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_MainBackColor');
  FSectorItemDownFontColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_MainButtonSelectedFontColor');
  FSectorItemLineColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_MainButtonFrameLineColor');
  FSectorChildItemBackColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_ChildBackColor');
  FSectorChildItemColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_ChildBackColor');
  FSectorChildItemFontColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_ChildButtonFontColor');
  FSectorChildItemHotColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_ChildButtonSelectedBackColor');
  FSectorChildItemHotFontColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_ChildButtonSelectedFontColor');
  FSectorChildItemDownColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_ChildButtonSelectedBackColor');
  FSectorChildItemDownFontColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_ChildButtonSelectedFontColor');
  FSectorChildItemLineColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_ChildButtonFocusedFrameLineColor');
  FSectorAddColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_ChildBackColor');
  FSectorAddFontColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_ButtonAddPlateFontColor');
  FSectorAddHotColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_ChildBackColor');
  FSectorAddHotFontColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_ButtonAddPlateFocusFontColor');
  FSectorAddDownColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_ChildBackColor');
  FSectorAddDownFontColor := FAppContext.GetResourceSkin.GetColor('PlateMenu_ButtonAddPlateFocusFontColor');

  if FPriceResourceStream <> nil then begin
    LPriceResourceStream := FPriceResourceStream;
    FPriceResourceStream := nil;
    FreeAndNil(LPriceResourceStream);
  end;
  FPriceResourceStream := FAppContext.GetResourceSkin.GetStream('PlateMenu_QuotePrice');

  if FAddSectorResourceStream <> nil then begin
    LPriceResourceStream := FAddSectorResourceStream;
    FAddSectorResourceStream := nil;
    FreeAndNil(LPriceResourceStream);
  end;
  FAddSectorResourceStream := FAppContext.GetResourceSkin.GetStream('PlateMenu_Add');

  if FEnableRankToolResourceStream <> nil then begin
    LPriceResourceStream := FEnableRankToolResourceStream;
    FEnableRankToolResourceStream := nil;
    FreeAndNil(LPriceResourceStream);
  end;
  FEnableRankToolResourceStream := FAppContext.GetResourceSkin.GetStream('PlateMenu_ComplexRank_Enable');

  if FUnEnableRankToolResourceStream <> nil then begin
    LPriceResourceStream := FUnEnableRankToolResourceStream;
    FUnEnableRankToolResourceStream := nil;
    FreeAndNil(LPriceResourceStream);
  end;
  FUnEnableRankToolResourceStream := FAppContext.GetResourceSkin.GetStream('PlateMenu_ComplexRank_UnEnable');

  if FEnableMultiStockToolResourceStream <> nil then begin
    LPriceResourceStream := FEnableMultiStockToolResourceStream;
    FEnableMultiStockToolResourceStream := nil;
    FreeAndNil(LPriceResourceStream);
  end;
  FEnableMultiStockToolResourceStream := FAppContext.GetResourceSkin.GetStream('PlateMenu_MultiStock_Enable');

  if FUnEnableMultiStockToolResourceStream <> nil then begin
    LPriceResourceStream := FUnEnableMultiStockToolResourceStream;
    FUnEnableMultiStockToolResourceStream := nil;
    FreeAndNil(LPriceResourceStream);
  end;
  FUnEnableMultiStockToolResourceStream := FAppContext.GetResourceSkin.GetStream('PlateMenu_MultiStock_UnEnable');
end;

procedure TSectorPriceMenuUI.DoCalcComponentsRect;
var
  LRect: TRect;
begin
  LRect := FComponentsRect;
  LRect.Bottom := LRect.Top + FSectorItemMgr.FHeight;
  FSectorItemMgr.FComponentsRect := LRect;
  FSectorItemMgr.Calc;

  LRect.Top := LRect.Bottom;
  LRect.Bottom := LRect.Top + FSectorChildItemMgr.FHeight;

  LRect.Left := LRect.Right - FSectorToolItemMgr.FWidth;
  if LRect.Left < FComponentsRect.Left then begin
    LRect.Left := FComponentsRect.Left;
  end;
  FSectorToolItemMgr.FComponentsRect := LRect;
  FSectorToolItemMgr.Calc;

  LRect.Right := LRect.Left;
  LRect.Left := FComponentsRect.Left;
  FSectorChildItemMgr.FComponentsRect := LRect;
  FSectorChildItemMgr.Calc;
end;

procedure TSectorPriceMenuUI.DoDrawBK(ARenderDC: TRenderDC);
begin
  FillSolidRect(ARenderDC.MemDC, @FComponentsRect, FSectorItemBackColor);
end;

procedure TSectorPriceMenuUI.DoDrawComponents(ARenderDC: TRenderDC);
begin
  FSectorItemMgr.Draw;
  FSectorChildItemMgr.Draw;
  FSectorToolItemMgr.Draw;
end;

function TSectorPriceMenuUI.DoFindComponent(APt: TPoint; var AComponent: TComponentUI): Boolean;
begin
  if PtInRect(FSectorItemMgr.FComponentsRect, APt) then begin
    Result := FSectorItemMgr.Find(APt, AComponent);
  end else if PtInRect(FSectorChildItemMgr.FComponentsRect, APt) then begin
    Result := FSectorChildItemMgr.Find(APt, AComponent);
  end else if PtInRect(FSectorToolItemMgr.FComponentsRect, APt) then begin
    Result := FSectorToolItemMgr.Find(APt, AComponent);
  end else begin
    Result := False;
  end;
end;

procedure TSectorPriceMenuUI.DoMouseUpAfter(AComponent: TComponentUI);
var
  LPt: TPoint;
  LTextRect: TRect;
  LIsCalc: Boolean;
begin
  if AComponent is TSectorChildAddItem then begin

  end else if AComponent is TRankToolItem then begin

  end else if AComponent is TPriceToolItem then begin

  end else if AComponent is TMultiStockToolItem then begin

  end else if AComponent is TSectorChildSubItem then begin
    LTextRect := AComponent.RectEx;
    LTextRect.Right := LTextRect.Right - TSectorChildSubItem(AComponent).FSubWidth;
    if PtInRect(LTextRect, FMouseUpPt) then begin
      if (FSectorChildItemMgr.FSectorChildList <> nil)
        and (FSectorChildItemMgr.FSectorChildList.FSelectedModuleId <> TSectorChildItem(AComponent).FModuleId) then begin
        FSectorChildItemMgr.FSectorChildList.FSelectedModuleId := TSectorChildItem(AComponent).FModuleId;
      end;
    end;
  end else if AComponent is TSectorChildItem then begin
    if (FSectorChildItemMgr.FSectorChildList <> nil)
      and (FSectorChildItemMgr.FSectorChildList.FSelectedModuleId <> TSectorChildItem(AComponent).FModuleId) then begin
      FSectorChildItemMgr.FSectorChildList.FSelectedModuleId := TSectorChildItem(AComponent).FModuleId;
    end;
  end else begin
    if FSectorItemMgr.FSelectedMarketId <> TSectorItem(AComponent).FMarketId then begin
      FSectorItemMgr.FSelectedMarketId := TSectorItem(AComponent).FMarketId;
      FSectorChildItemMgr.ChangeModule(TSectorItem(AComponent).FMarketId, -1, LIsCalc);
      if LIsCalc then begin
        FSectorChildItemMgr.Calc;
      end;
    end;
  end;
end;

procedure TSectorPriceMenuUI.DoLClickComponent(AComponent: TComponentUI);
var
  LPt: TPoint;
  LIndex: Integer;
  LSubRect: TRect;
  LSectorChildItem: TSectorChildItem;
  LMenuItem, LSelectMenuItem: TGilMenuItem;
begin
  if AComponent is TSectorChildSubItem then begin
    LSubRect := AComponent.RectEx;
    LSubRect.Left := LSubRect.Right - TSectorChildSubItem(AComponent).FSubWidth;
    if PtInRect(LSubRect, FMouseUpPt) then begin
      if FSectorChildItemMgr.FSectorChildList = nil then Exit;

      if FSubPopMenu = nil then begin
        FSubPopMenu := TGilPopMenu.Create(FAppContext);
        FSubPopMenu.UpdateSkin;
      end;
      FSubPopMenu.ClearMenus;
      for LIndex := FSectorChildItemMgr.FSectorChildList.FShowCount
        to FSectorChildItemMgr.FSectorChildList.FSectorChildItems.Count -1 do begin
        LSectorChildItem := FSectorChildItemMgr.FSectorChildList.FSectorChildItems.Items[LIndex];
        if LSectorChildItem <> nil then begin
          LMenuItem := FSubPopMenu.AddMenuItem(LSectorChildItem.Caption, '');
          LMenuItem.OnClick := DoLClickSubMenuItem;
          LMenuItem.ID := LSectorChildItem.FModuleId;
          LMenuItem.IconType := ditRadioBox;
          if LIndex = FSectorChildItemMgr.FSectorChildList.FShowCount then begin
            LSelectMenuItem := LMenuItem;
            LSelectMenuItem.Radioed := True;
          end;
          if FSectorChildItemMgr.FSectorChildList.FSelectedModuleId = LSectorChildItem.FModuleId then begin
            LSelectMenuItem := LMenuItem;
            LSelectMenuItem.Radioed := True;
          end;
        end;
      end;
      if FSubPopMenu.MenuItemCount > 0 then begin
        LPt := Self.ClientToScreen(Point(AComponent.RectEx.Left, AComponent.RectEx.Bottom));
        FSubPopMenu.PopMenu(LPt);
      end;
    end else begin
//      FAppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_SECTORTREE, 'FuncName=Show');
    end;
  end else if AComponent is TSectorChildAddItem then begin
    FAppContext.GetCommandMgr.ExecuteCmd(ASF_COMMAND_ID_SECTORTREE, 'FuncName=Show');
  end else if AComponent is TRankToolItem then begin

  end else if AComponent is TPriceToolItem then begin

  end else if AComponent is TMultiStockToolItem then begin

  end else if AComponent is TSectorChildItem then begin

  end else begin

  end;
end;

procedure TSectorPriceMenuUI.DoUpdateMsgEx(AObject: TObject);
var
  LIsCalc: Boolean;
  LMarketId, LModuleId: Integer;
begin
  if (FSectorChildItemMgr.FSectorChildList <> nil)
    and (FSectorChildItemMgr.FSectorChildList.FMarketId = MARKETID_ATTENTION) then begin
    LMarketId := FSectorChildItemMgr.FSectorChildList.FMarketId;
    LModuleId := FSectorChildItemMgr.FSectorChildList.FSelectedModuleId;
  end else begin
    LMarketId := -1;
    LModuleId := -1;
  end;

  if DoUpdateAttentionData then begin
    if (LMarketId <> -1)
      and (LModuleId <> -1) then begin
      if FSectorChildItemMgr.FSectorChildList.IsHasModule(LModuleId) then begin
        FSectorChildItemMgr.Calc;
        Invalidate;
      end else begin
        LMarketId := MARKETID_ATTENTION;
        LModuleId := MODULEID_SELF;
        Change(LMarketId, LModuleId);
        FSectorChildItemMgr.Calc;
        Invalidate;
      end;
    end;
  end;
end;

procedure TSectorPriceMenuUI.DoLClickSubMenuItem(AObject: TObject);
var
  LMenuItem: TGilMenuItem;
begin
  LMenuItem := TGilMenuItem(AObject);
  if FSectorChildItemMgr.FSectorChildSubItem <> nil then begin
    if FSectorChildItemMgr.FSectorChildSubItem.FModuleId <> LMenuItem.ID then begin
      FSectorChildItemMgr.FSectorChildSubItem.FModuleId := LMenuItem.ID;
      FSectorChildItemMgr.FSectorChildSubItem.Caption := LMenuItem.Caption;
      if FSectorChildItemMgr.FSectorChildList <> nil then begin
        FSectorChildItemMgr.FSectorChildList.FSelectedModuleId := LMenuItem.ID;
      end;
      Invalidate;
    end;
  end;
end;

end.
