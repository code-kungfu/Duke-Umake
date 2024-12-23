object frmMainForm: TfrmMainForm
  Left = 482
  Top = 201
  BorderIcons = [biSystemMenu]
  Caption = 'UMake for Duke Nukem 2001'
  ClientHeight = 334
  ClientWidth = 303
  Color = clBtnFace
  Constraints.MaxWidth = 315
  Constraints.MinHeight = 113
  Constraints.MinWidth = 315
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    303
    334)
  TextHeight = 15
  object ButtonDetails: TButton
    Left = 246
    Top = 53
    Width = 57
    Height = 25
    Anchors = [akTop, akRight]
    BiDiMode = bdLeftToRight
    Caption = '&Details'
    ParentBiDiMode = False
    TabOrder = 4
    OnClick = ButtonDetailsClick
    ExplicitLeft = 242
  end
  object ButtonAbort: TButton
    Left = 185
    Top = 53
    Width = 57
    Height = 25
    Anchors = [akTop, akRight]
    BiDiMode = bdLeftToRight
    Caption = '&Abort'
    Enabled = False
    ParentBiDiMode = False
    TabOrder = 3
    OnClick = ButtonAbortClick
    ExplicitLeft = 181
  end
  object ProgressBar: TProgressBar
    Left = 8
    Top = 30
    Width = 294
    Height = 12
    Anchors = [akLeft, akTop, akRight]
    Max = 1
    Step = 1
    TabOrder = 1
    ExplicitWidth = 290
  end
  object ButtonOptions: TButton
    Left = 8
    Top = 53
    Width = 73
    Height = 25
    Caption = '&Options...'
    TabOrder = 2
    OnClick = ButtonOptionsClick
  end
  object PageControlDetails: TPageControl
    Left = 8
    Top = 96
    Width = 295
    Height = 230
    ActivePage = TabSheetMessages
    Anchors = [akLeft, akTop, akRight, akBottom]
    Enabled = False
    TabOrder = 6
    ExplicitWidth = 291
    ExplicitHeight = 229
    object TabSheetError: TTabSheet
      Caption = 'Error'
      OnResize = TabSheetErrorResize
      DesignSize = (
        287
        200)
      object ImageError: TImage
        Left = 11
        Top = 11
        Width = 33
        Height = 33
      end
      object LabelErrorTitle: TLabel
        Left = 56
        Top = 12
        Width = 101
        Height = 13
        Caption = 'Compilation failed'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LabelErrorLocation: TLabel
        Left = 56
        Top = 28
        Width = 54
        Height = 15
        Caption = '(Location)'
      end
      object ButtonErrorEdit: TButton
        Left = 222
        Top = 168
        Width = 57
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = '&Edit'
        TabOrder = 0
        OnClick = ButtonErrorEditClick
        ExplicitLeft = 214
        ExplicitTop = 167
      end
      object RichEditError: TRichEdit
        Left = 8
        Top = 56
        Width = 271
        Height = 103
        Anchors = [akLeft, akTop, akRight, akBottom]
        PlainText = True
        ScrollBars = ssBoth
        TabOrder = 1
        WantReturns = False
      end
    end
    object TabSheetWarnings: TTabSheet
      Caption = 'Warnings'
      ImageIndex = 2
      OnResize = TabSheetWarningsResize
      DesignSize = (
        287
        200)
      object ImageWarning: TImage
        Left = 11
        Top = 11
        Width = 33
        Height = 33
      end
      object LabelWarningTitle: TLabel
        Left = 56
        Top = 12
        Width = 53
        Height = 13
        Caption = 'Warnings'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LabelWarningLocation: TLabel
        Left = 56
        Top = 28
        Width = 54
        Height = 15
        Caption = '(Location)'
      end
      object LabelWarningNumber: TLabel
        Left = 113
        Top = 12
        Width = 37
        Height = 15
        Caption = '(0 of 0)'
      end
      object RichEditWarning: TRichEdit
        Left = 8
        Top = 56
        Width = 271
        Height = 103
        Anchors = [akLeft, akTop, akRight, akBottom]
        PlainText = True
        ScrollBars = ssBoth
        TabOrder = 0
        WantReturns = False
      end
      object ButtonWarningEdit: TButton
        Left = 222
        Top = 168
        Width = 57
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = '&Edit'
        Enabled = False
        TabOrder = 3
        OnClick = ButtonErrorEditClick
        ExplicitLeft = 218
      end
      object ButtonWarningNext: TButton
        Left = 68
        Top = 168
        Width = 57
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = '&Next '#8250#8250
        Enabled = False
        TabOrder = 1
        OnClick = ButtonWarningNextClick
      end
      object ButtonWarningPrev: TButton
        Left = 8
        Top = 168
        Width = 57
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = #8249#8249' &Prev'
        Enabled = False
        TabOrder = 2
        OnClick = ButtonWarningPrevClick
      end
    end
    object TabSheetMessages: TTabSheet
      Caption = 'Messages'
      object RichEditMessages: TRichEdit
        Left = 0
        Top = 0
        Width = 287
        Height = 200
        Align = alClient
        PlainText = True
        ScrollBars = ssBoth
        TabOrder = 0
        WantReturns = False
        ExplicitWidth = 283
        ExplicitHeight = 199
      end
    end
  end
  object StaticTextProgress: TStaticText
    Left = 8
    Top = 8
    Width = 295
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Initializing'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    ExplicitWidth = 291
  end
  object ButtonRebuild: TButton
    Left = 120
    Top = 53
    Width = 57
    Height = 25
    Caption = '&Rebuild'
    TabOrder = 5
    OnClick = FormShow
  end
end
