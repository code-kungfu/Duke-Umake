object frmLauncher: TfrmLauncher
  Left = 396
  Top = 287
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'UMake for Duke Nukem Forever 2001'
  ClientHeight = 239
  ClientWidth = 392
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    392
    239)
  TextHeight = 15
  object lblSource: TLabel
    Left = 9
    Top = 12
    Width = 317
    Height = 15
    Caption = 'Enter the &UnrealScript project directory you wish to compile:'
  end
  object lblHintsParagraph2: TLabel
    Left = 24
    Top = 116
    Width = 336
    Height = 33
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'You can have UMake set up a desktop shortcut and Explorer right-' +
      'click menu extensions for you. Check the Options dialog.'
    WordWrap = True
    ExplicitWidth = 344
  end
  object lblHints: TLabel
    Left = 8
    Top = 72
    Width = 29
    Height = 13
    Caption = 'Hints'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object bvlHints: TBevel
    Left = 42
    Top = 79
    Width = 334
    Height = 2
    Anchors = [akLeft, akTop, akRight]
    ExplicitWidth = 342
  end
  object lblHintsParagraph1: TLabel
    Left = 24
    Top = 92
    Width = 342
    Height = 15
    Caption = 
      'Drop an UnrealScript source file on the UMake icon to compile it' +
      '.'
  end
  object lblNote1: TLabel
    Left = 24
    Top = 152
    Width = 323
    Height = 12
    Caption = 
      'Note: With this version, you need to have already made a profile' +
      ' '
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -10
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblNote2: TLabel
    Left = 24
    Top = 165
    Width = 333
    Height = 12
    Caption = 'named "UMake" (Verbatim) ingame and have set it as your current'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -10
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblNote3: TLabel
    Left = 24
    Top = 178
    Width = 227
    Height = 12
    Caption = 'profile or else UMake will not work properly.'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -10
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btnBrowseProject: TBitBtn
    Left = 355
    Top = 31
    Width = 25
    Height = 25
    Anchors = [akTop, akRight]
    Glyph.Data = {
      06030000424D06030000000000003600000028000000100000000F0000000100
      180000000000D0020000120B0000120B00000000000000000000C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C000000000000000000000000000000000000000000000
      0000000000000000000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
      808080808080808080808080808080808080808080808080808080000000C0C0
      C0C0C0C0C0C0C0C0C0C0000000FFFFFF00000080808080808080808080808080
      8080808080808080808080808080000000C0C0C0C0C0C0C0C0C0000000FFFFFF
      FFFFFF0000008080808080808080808080808080808080808080808080808080
      80000000C0C0C0C0C0C0000000FFFFFFFFFFFFFFFFFF00000080808080808080
      8080808080808080808080808080808080808080000000C0C0C0000000FFFFFF
      FFFFFFFFFFFFFFFFFF0000000000000000000000000000000000000000000000
      00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0000000FFFFFFFFFFFFFFFFFF00000000000000000000
      0000000000000000000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000
      000000000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000
      00000000000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000C0C0C0C0C0C0C0C0C00000
      00C0C0C0000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0000000000000000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0}
    TabOrder = 1
    OnClick = btnBrowseProjectClick
    ExplicitLeft = 351
  end
  object btnOptions: TButton
    Left = 8
    Top = 206
    Width = 81
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Options...'
    TabOrder = 2
    OnClick = btnOptionsClick
    ExplicitTop = 205
  end
  object btnCompile: TButton
    Left = 211
    Top = 206
    Width = 81
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Compile'
    Enabled = False
    ModalResult = 1
    TabOrder = 3
    ExplicitLeft = 207
    ExplicitTop = 205
  end
  object btnClose: TButton
    Left = 295
    Top = 206
    Width = 81
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Close'
    ModalResult = 2
    TabOrder = 4
    OnClick = btnCloseClick
    ExplicitLeft = 291
    ExplicitTop = 205
  end
  object comProject: TComboBox
    Left = 8
    Top = 32
    Width = 345
    Height = 23
    TabOrder = 0
    OnChange = comProjectChange
  end
end
