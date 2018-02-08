unit MsgExSubcriber;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º MsgExSubcriber Interface
// Author£º      lksoulman
// Date£º        2017-12-08
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MsgEx,
  Windows,
  Classes,
  SysUtils,
  CommonLock,
  CommonRefCounter,
  Generics.Collections;

type

  // MsgExSubcriber Interface
  IMsgExSubcriber = interface(IInterface)
    ['{A7AB4C4E-DA89-4921-BA4F-F686089D5AC4}']
    // GetActive
    function GetActive: Boolean;
    // GetLogInfo
    function GetLogInfo: string;
    // SetActive
    procedure SetActive(Active: Boolean);
    // SetLogInfo
    procedure SetLogInfo(ALogInfo: string);
    // InvokeNotify
    procedure InvokeNotify(AMsgEx: TMsgEx);
  end;

implementation


end.
