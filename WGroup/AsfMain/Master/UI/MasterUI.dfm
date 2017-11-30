object MasterUI: TMasterUI
  Left = 0
  Top = 0
  Caption = 'MasterUI'
  ClientHeight = 496
  ClientWidth = 807
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object PnlSuperTab: TPanel
    Left = 0
    Top = 0
    Width = 60
    Height = 496
    Align = alLeft
    BevelOuter = bvNone
    Caption = 'PnlSuperTab'
    TabOrder = 0
  end
  object PnlChildPages: TPanel
    Left = 60
    Top = 0
    Width = 747
    Height = 496
    Align = alClient
    BevelOuter = bvNone
    Caption = 'PnlChildPages'
    TabOrder = 1
  end
end
