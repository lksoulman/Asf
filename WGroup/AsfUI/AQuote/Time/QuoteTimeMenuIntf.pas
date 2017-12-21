unit QuoteTimeMenuIntf;

interface

uses Windows, Classes, SysUtils;

type

  // ÓÒ¼ü²Ëµ¥
  IQuoteTimeMenu = interface
    ['{868A0102-9F29-4364-89DC-B2EC023C4673}']
    procedure MainMenu(const _Pt: TPoint); safecall;
    function HotKey(_ShortCut: TShortCut): boolean; safecall;
    function GetTimeMenuVisible: Boolean; safecall;
    procedure AddUserBehavior(UserBehavior: string); safecall;
  end;

implementation

end.
