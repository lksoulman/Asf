unit SectorTreeCommandImpl;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º SectorTreeCommand Implementation
// Author£º      lksoulman
// Date£º        2018-1-15
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  Command,
  SysUtils,
  SectorTree,
  AppContext,
  CommandImpl;

type

  // SectorTreeCommand Implementation
  TSectorTreeCommandImpl = class(TCommandImpl)
  private
    // SectorTree
    FSectorTree: ISectorTree;
  protected
  public
    // Constructor
    constructor Create(AId: Cardinal; ACaption: string; AContext: IAppContext); override;
    // Destructor
    destructor Destroy; override;

    { ICommand }

    // Execute
    procedure Execute(AParams: string); override;
  end;

implementation

uses
  SectorTreeImpl;

{ TSectorTreeCommandImpl }

constructor TSectorTreeCommandImpl.Create(AId: Cardinal; ACaption: string; AContext: IAppContext);
begin
  inherited;

end;

destructor TSectorTreeCommandImpl.Destroy;
begin
  if FSectorTree <> nil then begin
    FAppContext.UnRegisterInterface(FId);
    FSectorTree := nil;
  end;
  inherited;
end;

procedure TSectorTreeCommandImpl.Execute(AParams: string);
var
  LFuncName: string;
begin
  BeginSplitParams(AParams);
  try
    ParamsVal('FuncName', LFuncName);
    if LFuncName = 'Hide' then begin
      if FSectorTree <> nil then begin
        FSectorTree.Hide;
      end;
    end else begin
      if FSectorTree = nil then begin
        FSectorTree := TSectorTreeImpl.Create(FAppContext) as ISectorTree;
        FAppContext.RegisterInteface(FId, FSectorTree);
      end;
      if FSectorTree <> nil then begin
        if LFuncName = 'Show' then begin
          FSectorTree.Show;
        end;
      end;
    end;
  finally
    EndSplitParams;
  end;
end;

end.
