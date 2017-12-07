unit ServerInfo;

////////////////////////////////////////////////////////////////////////////////
//
// Description�� ServerInfo Interface
// Author��      lksoulman
// Date��        2017-7-21
// Comments��
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  Windows,
  Classes,
  SysUtils,
  IniFiles;

type

  // ServerInfo Interface
  IServerInfo = Interface(IInterface)
    ['{2BE2468A-C419-4BCB-9905-4B8CF5509689}']
    // Load File
    procedure LoadFile(AFile: TIniFile);
    // Next
    procedure NextServer;
    // First
    procedure FirstServer;
    // Is EOF
    function IsEOF: boolean;
    // Get Server Index
    function GetServerIndex: Integer;
    // Get Server Url
    function GetServerUrl: WideString;
    // Get Server Urls
    function GetServerUrls: WideString;
    // Get Server Name
    function GetServerName: WideString;
  end;

implementation

end.
