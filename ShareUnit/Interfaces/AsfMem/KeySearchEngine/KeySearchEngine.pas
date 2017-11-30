unit KeySearchEngine;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º KeySearchEngine Interface
// Author£º      lksoulman
// Date£º        2017-11-14
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  SecuMain;

type

  // KeySearchEngine Interface
  IKeySearchEngine = interface(IInterface)
    ['{FF6DE470-A546-4F1B-B716-3F1590E7FE21}']
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

end.
