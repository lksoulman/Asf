unit WebCfgImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º WebCfg Implementation
// Author£º      lksoulman
// Date£º        2017-8-25
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  WebCfg,
  Windows,
  Classes,
  SysUtils,
  BaseObject,
  AppContext,
  Generics.Collections;

type

  // WebCfg Implementation
  TWebCfgImpl = class(TBaseInterfacedObject, IWebCfg)
  private
    // WebInfoDic
    FWebInfoDic: TDictionary<Integer, PWebInfo>;
  protected
    // InitWebInfo
    procedure DoInitWebInfos;
    // UnInitWebInfos
    procedure DoUnInitWebInfos;
    // LoadXmlNodes
    procedure DoLoadXmlNodes(ANodeList: TList);
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IWebCfg }

    // GetUrl
    function GetUrl(AWebID: Integer): WideString;
    // GetWebInfo
    function GetWebInfo(AWebID: Integer): PWebInfo;
  end;

implementation

uses
  Cfg,
  Utils,
  LogLevel,
  NativeXml,
  SystemInfo;

const
  SERVERIP = '!ServerIP';
  SKINSTYLE = '!skinstyle';
  FONTRATIO = '!fontRatio';

{ TWebCfgImpl }

constructor TWebCfgImpl.Create(AContext: IAppContext);
begin
  inherited;
  FWebInfoDic := TDictionary<Integer, PWebInfo>.Create;
  DoInitWebInfos;
end;

destructor TWebCfgImpl.Destroy;
begin
  DoUnInitWebInfos;
  FWebInfoDic.Free;
  inherited;
end;

procedure TWebCfgImpl.DoInitWebInfos;
var
  LFile: string;
  LNode: TXmlNode;
  LXml: TNativeXml;
  LNodeList: TList;
begin
  LFile := FAppContext.GetCfg.GetCfgPath + 'Web\WebCfg.xml';
  if FileExists(LFile) then begin
    LXml := TNativeXml.Create(nil);
    try
      LXml.LoadFromFile(LFile);
      LXml.XmlFormat := xfReadable;
      LNode := LXml.Root;
      LNodeList := TList.Create;
      try
        LNode.FindNodes('WebInfo', LNodeList);
        DoLoadXmlNodes(LNodeList);
      finally
        LNodeList.Free;
      end;
    finally
      LXml.Free;
    end;
  end else begin
    FAppContext.SysLog(llERROR, Format('[TWebCfgImpl][DoInitWebInfos] Load file %s is not exist.', [LFile]));
  end;
end;

procedure TWebCfgImpl.DoUnInitWebInfos;
var
  LIndex: Integer;
  LWebInfo: PWebInfo;
  LWebInfos: TArray<PWebInfo>;
begin
  LWebInfos := FWebInfoDic.Values.ToArray;
  for LIndex := Low(LWebInfos) to High(LWebInfos) do begin
    if LWebInfos[LIndex] <> nil then begin
      LWebInfo := LWebInfos[LIndex];
      Dispose(LWebInfo);
    end;
  end;
  FWebInfoDic.Clear;
end;

procedure TWebCfgImpl.DoLoadXmlNodes(ANodeList: TList);
var
  LNode: TXmlNode;
  LWebInfo: PWebInfo;
  LIndex, LWebID: Integer;
begin
  if ANodeList = nil then Exit;

  for LIndex := 0 to ANodeList.Count - 1 do begin
    LNode := ANodeList.Items[LIndex];
    if LNode <> nil then begin
      LWebID := Utils.GetIntegerByChildNodeName(LNode, 'WebID', 0);
      if not FWebInfoDic.ContainsKey(LWebID) then begin
        New(LWebInfo);
        LWebInfo^.FWebID := LWebID;
        LWebInfo^.FUrl := Utils.GetStringByChildNodeName(LNode, 'Url');
        LWebInfo^.FServerName := Utils.GetStringByChildNodeName(LNode, 'ServerName');
        LWebInfo^.FDescription := Utils.GetStringByChildNodeName(LNode, 'Description');
        FWebInfoDic.AddOrSetValue(LWebID, LWebInfo);
      end;
    end;
  end;
end;

function TWebCfgImpl.GetUrl(AWebID: Integer): WideString;
var
  LWebInfo: PWebInfo;
  LServerIP, LSkinStyle, LFontRatio: string;
begin
  if FWebInfoDic.TryGetValue(AWebID, LWebInfo)
    and (LWebInfo <> nil) then begin
    LServerIP := FAppContext.GetCfg.GetServerCfg.GetServerUrl(LWebInfo^.FServerName);
    Result := StringReplace(LWebInfo^.FUrl, SERVERIP, LServerIP, [rfReplaceAll]);
    LSkinStyle := FAppContext.GetCfg.GetSysCfg.GetSystemInfo.GetSystemInfo^.FSkinStyle;
    if LSkinStyle <> '' then begin
      Result := StringReplace(Result, SKINSTYLE, LSkinStyle, [rfReplaceAll]);
    end;
    LFontRatio := FAppContext.GetCfg.GetSysCfg.GetSystemInfo.GetSystemInfo^.FFontRatio;
    if LSkinStyle <> '' then begin
      Result := StringReplace(Result, FONTRATIO, LFontRatio, [rfReplaceAll]);
    end;
  end else begin
    Result := '';
  end;
end;

function TWebCfgImpl.GetWebInfo(AWebID: Integer): PWebInfo;
begin
  if not (FWebInfoDic.TryGetValue(AWebID, Result)
    and (Result <> nil)) then begin
    Result := nil;
  end;
end;

end.
