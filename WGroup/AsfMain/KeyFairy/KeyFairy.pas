unit KeyFairy;

////////////////////////////////////////////////////////////////////////////////
//
// Description£º KeyFairy
// Author£º      lksoulman
// Date£º        2017-11-27
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

  // KeyFairy
  IKeyFairy = interface(IInterface)
    ['{ACA3A476-66E3-4953-8213-E1E7CEC2D062}']
    // Display
    function Display(AMasterHandle: THandle; AKey: string; var ASecuInfo: PSecuInfo): Boolean;
    // DisplayEx
    function DisplayEx(AMasterHandle, APosHandle: THandle; AKey: string; ALeft, ATop: Integer; var ASecuInfo: PSecuInfo): Boolean;
  end;

implementation

end.
