unit MsgType;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� Message Type
// Author��      lksoulman
// Date��        2017-7-29
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils;

type

  // Message Type
  TMsgType = (mtNone,                       //
              mtSecuMainUpdate,             // SecuMain Table
              mtSecuMainMemUpdate,             // SecuMain Table
              mtSecurityDataUpdate,         // Security Data Update
              mtUserSectorDataUpdate        // User Sector Data Update
              );

  // Message Type Dynamic Array
  TMsgTypeDynArray = Array Of TMsgType;

implementation

end.
