unit KeySearchEngineImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º KeySearchEngine Implementation
// Author£º      lksoulman
// Date£º        2017-11-24
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  SecuMain,
  AppContext,
  KeySearchFilter,
  KeySearchEngine,
  AppContextObject,
  Generics.Collections;

type

  // KeySearchEngine Implementation
  TKeySearchEngineImpl = class(TAppContextObject, IKeySearchEngine)
  private
    // IsUpdate
    FIsUpdate: Boolean;
    // KeySearchObject
    FKeySearchObject: TKeySearchObject;
  protected
  public
    // Constructor
    constructor Create(AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { IKeySearchEngine }

    // IsUpdate
    function IsUpdate: Boolean;
    // ClearKeySecuMainItems
    procedure ClearKeySecuMainItems;
    // FuzzySearchKey
    procedure FuzzySearchKey(AKey: string);
    // SetIsUpdate
    procedure SetIsUpdate(AIsUpdate: Boolean);
    // AddSecuMainItem
    procedure AddSecuMainItem(ASecuMainItem: PSecuMainItem);
    // SetResultCallBack
    procedure SetResultCallBack(AOnResultCallBack: TNotifyEvent);
  end;

implementation

{ TKeySearchEngineImpl }

constructor TKeySearchEngineImpl.Create(AContext: IAppContext);
begin
  inherited;
  FIsUpdate := True;
  FKeySearchObject := TKeySearchObject.Create;
end;

destructor TKeySearchEngineImpl.Destroy;
begin
  FKeySearchObject.Free;
  inherited;
end;

function TKeySearchEngineImpl.IsUpdate: Boolean;
begin
  Result := FIsUpdate;
end;

procedure TKeySearchEngineImpl.ClearKeySecuMainItems;
begin
  FKeySearchObject.ClearSecuMainItems;
end;

procedure TKeySearchEngineImpl.FuzzySearchKey(AKey: string);
begin
  FKeySearchObject.IsStop := False;
  FKeySearchObject.Key := AKey;
  FKeySearchObject.KeyLen := Length(AKey);
end;

procedure TKeySearchEngineImpl.SetIsUpdate(AIsUpdate: Boolean);
begin
  FIsUpdate := AIsUpdate;
end;

procedure TKeySearchEngineImpl.AddSecuMainItem(ASecuMainItem: PSecuMainItem);
begin
  FKeySearchObject.AddSecuMainItem(ASecuMainItem);
end;

procedure TKeySearchEngineImpl.SetResultCallBack(AOnResultCallBack: TNotifyEvent);
begin
  FKeySearchObject.SetResultCallBack(AOnResultCallBack);
end;

end.
