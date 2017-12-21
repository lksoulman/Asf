unit ResourceSkin;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º ResourceSkin Interface
// Author£º      lksoulman
// Date£º        2017-8-25
// Comments£º
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  Vcl.Graphics;

type

  // ResourceSkin Interface
  IResourceSkin = interface(IInterface)
    ['{9BB7760F-2A08-4D6F-A021-73E2C27B4AC8}']
    // ChangeSkin
    function ChangeSkin: Boolean;
    // GetInstance
    function GetInstance: HMODULE;
    // GetColor
    function GetColor(AKey: string): TColor;
    // GetConfig
    function GetConfig(AKey: string): string;
    // Get Stream
    function GetStream(AResourceName: string): TResourceStream;
  end;

implementation

end.
