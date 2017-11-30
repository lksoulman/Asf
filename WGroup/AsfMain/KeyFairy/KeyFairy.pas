unit KeyFairy;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� KeyFairy
// Author��      lksoulman
// Date��        2017-11-27
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  SecuMain;

type

  // KeyFairy
  IKeyFairy = interface(IInterface)
    ['{ACA3A476-66E3-4953-8213-E1E7CEC2D062}']
    // Display
    function Display(AHandle: THandle; AKey: string; var ASecuMainItem: PSecuMainItem): Boolean;
    // DisplayEx
    function DisplayEx(AHandle: THandle; AKey: string; ALeft, ATop: Integer; var ASecuMainItem: PSecuMainItem): Boolean;
  end;

implementation

end.
