unit UserAttentionMgr;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º UserAttentionMgr Interface
// Author£º      lksoulman
// Date£º        2018-1-11
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Attention;

type

  // UserAttentionMgr
  IUserAttentionMgr = interface(IInterface)
    ['{8D1CDB9E-8CEB-4A79-9862-C5A5ACB932C6}']
    // Lock
    procedure Lock;
    // UnLock
    procedure UnLock;
    // Update
    procedure Update;
    // SaveData
    procedure SaveData;
    // ClearAttentions
    procedure ClearAttentions;
    // AddAttention
    procedure AddAttention(AId: Integer; AName: string);
    // GetCount
    function GetCount: Integer;
    // GetAttention
    function GetAttention(AIndex: Integer): TAttention;
  end;

implementation

end.
