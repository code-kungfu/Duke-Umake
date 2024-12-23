object frmShortcuts: TfrmShortcuts
  Left = 422
  Top = 296
  BorderStyle = bsDialog
  Caption = 'UMake Desktop Shortcuts'
  ClientHeight = 298
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  DesignSize = (
    377
    298)
  TextHeight = 15
  object lblExplanationGeneric: TLabel
    Left = 42
    Top = 36
    Width = 295
    Height = 38
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'This shortcut can act as a drop target for UnrealScript source f' +
      'iles or project directories.'
    WordWrap = True
    ExplicitWidth = 299
  end
  object lblExplanationProject: TLabel
    Left = 42
    Top = 104
    Width = 295
    Height = 38
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Double-click this shortcut to directly compile the currently loa' +
      'ded project, Project.'
    WordWrap = True
    ExplicitWidth = 299
  end
  object lblProject: TLabel
    Left = 122
    Top = 81
    Width = 55
    Height = 15
    Caption = 'for Project'
  end
  object lblExplanationAuto: TLabel
    Left = 42
    Top = 172
    Width = 295
    Height = 49
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Double-click this shortcut to directly compile the most recently' +
      ' modified project in the following game directory:'
    WordWrap = True
    ExplicitWidth = 299
  end
  object BevelGeneric: TBevel
    Left = 168
    Top = 20
    Width = 177
    Height = 2
    Anchors = [akLeft, akTop, akRight]
    ExplicitWidth = 193
  end
  object BevelProject: TBevel
    Left = 179
    Top = 88
    Width = 166
    Height = 2
    Anchors = [akLeft, akTop, akRight]
    ExplicitWidth = 182
  end
  object BevelAuto: TBevel
    Left = 208
    Top = 156
    Width = 137
    Height = 2
    Anchors = [akLeft, akTop, akRight]
    ExplicitWidth = 153
  end
  object RadioButtonGeneric: TRadioButton
    Left = 8
    Top = 12
    Width = 157
    Height = 17
    Caption = 'Generic UMake Shortcut'
    Checked = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    TabStop = True
  end
  object RadioButtonProject: TRadioButton
    Left = 8
    Top = 80
    Width = 113
    Height = 17
    Caption = 'Project Shortcut'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
  end
  object RadioButtonAuto: TRadioButton
    Left = 8
    Top = 148
    Width = 201
    Height = 17
    Caption = 'Most Recently Changed Project'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
  end
  object ComboBoxGame: TComboBox
    Left = 42
    Top = 227
    Width = 272
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    Sorted = True
    TabOrder = 3
    OnChange = ComboBoxGameChange
    ExplicitWidth = 268
  end
  object ButtonBrowseGame: TBitBtn
    Left = 320
    Top = 226
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
    TabOrder = 4
    OnClick = ButtonBrowseGameClick
    ExplicitLeft = 316
  end
  object ButtonCreate: TButton
    Left = 124
    Top = 265
    Width = 145
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Create Desktop Shortcut'
    Default = True
    ModalResult = 1
    TabOrder = 5
    OnClick = ButtonCreateClick
    ExplicitLeft = 120
    ExplicitTop = 264
  end
  object ButtonCancel: TButton
    Left = 272
    Top = 265
    Width = 81
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 6
    ExplicitLeft = 268
    ExplicitTop = 264
  end
  object PanelFocus: TPanel
    Left = 0
    Top = 0
    Width = 0
    Height = 0
    TabOrder = 7
  end
end
