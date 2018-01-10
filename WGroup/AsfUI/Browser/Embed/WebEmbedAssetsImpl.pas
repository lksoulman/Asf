unit WebEmbedAssetsImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º WebEmbedAssets Implementation
// Author£º      lksoulman
// Date£º        2017-12-26
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  WebChildPageImpl;

type

  // WebEmbedAssets Implementation
  TWebEmbedAssetsImpl = class(TWebChildPageImpl)
  private
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

{ TWebEmbedAssetsImpl }

procedure TWebEmbedAssetsImpl.DoCreateObjects;
begin

end;

procedure TWebEmbedAssetsImpl.DoDestroyObjects;
begin

end;

procedure TWebEmbedAssetsImpl.DoInitObjectDatas;
begin
  inherited;

end;

procedure TWebEmbedAssetsImpl.DoAddSubcribeMsgExs;
begin

end;

procedure TWebEmbedAssetsImpl.DoActivate;
begin

end;

procedure TWebEmbedAssetsImpl.DoNoActivate;
begin

end;

procedure TWebEmbedAssetsImpl.DoReSubcribeHq;
begin

end;

procedure TWebEmbedAssetsImpl.DoReSecuMainMem;
begin

end;

procedure TWebEmbedAssetsImpl.DoReUpdateLanguage;
begin

end;

procedure TWebEmbedAssetsImpl.DoReUpdateSkinStyle;
begin
  inherited;

end;

procedure TWebEmbedAssetsImpl.DoUpdateCommandParam(AParams: string);
var
  LUrl: string;
begin
  if FBrowser = nil then Exit;
  
  BeginSplitParams(AParams);
  try
    ParamsVal('Url', LUrl);
    if LUrl <> '' then begin

    end else begin
      LUrl := 'https://www.baidu.com';
      FBrowser.LoadWebUrl(LUrl);
    end;
  finally
    EndSplitParams;
  end;
end;

end.
