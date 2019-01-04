object frmCalendarPrint: TfrmCalendarPrint
  Left = 231
  Top = 175
  BorderStyle = bsDialog
  Caption = #12459#12524#12531#12480#12540#12398#21360#21047
  ClientHeight = 453
  ClientWidth = 569
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object RangeGroup: TGroupBox
    Left = 16
    Top = 112
    Width = 402
    Height = 97
    Caption = #21360#21047#31684#22258
    TabOrder = 1
    object Label1: TLabel
      Left = 16
      Top = 28
      Width = 48
      Height = 12
      Caption = #38283#22987#24180#26376
    end
    object Label2: TLabel
      Left = 16
      Top = 60
      Width = 48
      Height = 12
      Caption = #32066#20102#24180#26376
    end
    object Label3: TLabel
      Left = 144
      Top = 28
      Width = 12
      Height = 12
      Caption = #24180
    end
    object Label4: TLabel
      Left = 144
      Top = 60
      Width = 12
      Height = 12
      Caption = #24180
    end
    object Label5: TLabel
      Left = 224
      Top = 28
      Width = 12
      Height = 12
      Caption = #26376
    end
    object Label6: TLabel
      Left = 224
      Top = 60
      Width = 12
      Height = 12
      Caption = #26376
    end
    object Label13: TLabel
      Left = 264
      Top = 28
      Width = 114
      Height = 12
      Caption = #12506#12540#12472#12372#12392#12398#20986#21147#31684#22258
    end
    object StartYearBox: TEdit
      Left = 80
      Top = 24
      Width = 41
      Height = 20
      ImeMode = imClose
      TabOrder = 0
      Text = '2003'
      OnExit = StartYearBoxExit
    end
    object StartYear: TUpDown
      Left = 121
      Top = 24
      Width = 17
      Height = 20
      Associate = StartYearBox
      Min = 1980
      Max = 2099
      Position = 2003
      TabOrder = 1
      Thousands = False
    end
    object StartMonthBox: TEdit
      Left = 168
      Top = 24
      Width = 33
      Height = 20
      ImeMode = imClose
      TabOrder = 2
      Text = '1'
      OnExit = StartMonthBoxExit
    end
    object StartMonth: TUpDown
      Left = 201
      Top = 24
      Width = 17
      Height = 20
      Associate = StartMonthBox
      Min = 1
      Max = 12
      Position = 1
      TabOrder = 3
      Thousands = False
      OnChangingEx = StartMonthChangingEx
    end
    object EndYear: TUpDown
      Left = 121
      Top = 56
      Width = 17
      Height = 20
      Associate = EndYearBox
      Min = 1980
      Max = 2099
      Position = 2003
      TabOrder = 4
      Thousands = False
    end
    object EndYearBox: TEdit
      Left = 80
      Top = 56
      Width = 41
      Height = 20
      ImeMode = imClose
      TabOrder = 5
      Text = '2003'
      OnExit = EndYearBoxExit
    end
    object EndMonthBox: TEdit
      Left = 168
      Top = 56
      Width = 33
      Height = 20
      ImeMode = imClose
      TabOrder = 6
      Text = '1'
      OnExit = EndMonthBoxExit
    end
    object EndMonth: TUpDown
      Left = 201
      Top = 56
      Width = 17
      Height = 20
      Associate = EndMonthBox
      Min = 1
      Max = 12
      Position = 1
      TabOrder = 7
      Thousands = False
      OnChangingEx = EndMonthChangingEx
    end
    object WeeksPerPage: TComboBox
      Left = 264
      Top = 56
      Width = 113
      Height = 20
      Style = csDropDownList
      ItemHeight = 12
      ItemIndex = 0
      TabOrder = 8
      Text = #65300#65374#65302#36913#65288#33258#21205#65289
      Items.Strings = (
        #65300#65374#65302#36913#65288#33258#21205#65289
        #65302#36913#22266#23450)
    end
  end
  object PrintBtn: TButton
    Left = 446
    Top = 67
    Width = 89
    Height = 33
    Caption = #21360#21047'(&O)'
    TabOrder = 8
    OnClick = PrintBtnClick
  end
  object PrinterGroup: TGroupBox
    Left = 16
    Top = 16
    Width = 402
    Height = 81
    Caption = #12503#12522#12531#12479
    TabOrder = 0
    object PrinterInfoLabel: TLabel
      Left = 16
      Top = 24
      Width = 80
      Height = 12
      Caption = 'PrinterInfoLabel'
    end
    object Label8: TLabel
      Left = 16
      Top = 51
      Width = 48
      Height = 12
      Caption = #20986#21147#26041#21521
    end
    object PrinterDialogBtn: TButton
      Left = 280
      Top = 24
      Width = 89
      Height = 33
      Caption = #35373#23450' ...'
      TabOrder = 0
      OnClick = PrinterDialogBtnClick
    end
    object PrintOrientationCombo: TComboBox
      Left = 80
      Top = 48
      Width = 185
      Height = 20
      Style = csDropDownList
      ItemHeight = 12
      ItemIndex = 0
      TabOrder = 1
      Text = #29992#32025#12395#23550#12375#12390#27178#21521#12365#12395#20986#21147
      Items.Strings = (
        #29992#32025#12395#23550#12375#12390#27178#21521#12365#12395#20986#21147
        #12503#12522#12531#12479#12398#35373#23450#12395#21512#12431#12379#12390#20986#21147)
    end
  end
  object FreeMemoGroup: TGroupBox
    Left = 16
    Top = 336
    Width = 249
    Height = 109
    Caption = #12501#12522#12540#12513#12514#27396
    TabOrder = 3
    object Label7: TLabel
      Left = 24
      Top = 24
      Width = 120
      Height = 12
      Caption = #12506#12540#12472#19979#37096#12398#21344#26377#29575'(%)'
    end
    object Label9: TLabel
      Left = 24
      Top = 80
      Width = 105
      Height = 12
      Caption = 'TODO'#27396#12398#21344#26377#24133'(%)'
    end
    object FreeMemoRatioBox: TEdit
      Left = 160
      Top = 20
      Width = 49
      Height = 20
      ImeMode = imClose
      TabOrder = 0
      Text = '0'
    end
    object FreememoRatioUpDown: TUpDown
      Left = 209
      Top = 20
      Width = 17
      Height = 20
      Associate = FreeMemoRatioBox
      Max = 50
      Increment = 5
      TabOrder = 1
    end
    object FreeMemoTwoColumns: TCheckBox
      Left = 43
      Top = 46
      Width = 183
      Height = 17
      Caption = #20108#27573#32068#12391#20986#21147#12377#12427
      TabOrder = 2
    end
    object TodoRatioUpDown: TUpDown
      Left = 209
      Top = 76
      Width = 16
      Height = 20
      Associate = TodoRatioBox
      Increment = 5
      TabOrder = 3
    end
    object TodoRatioBox: TEdit
      Left = 160
      Top = 76
      Width = 49
      Height = 20
      ImeMode = imClose
      TabOrder = 4
      Text = '0'
    end
  end
  object PreviewBtn: TButton
    Left = 446
    Top = 19
    Width = 89
    Height = 33
    Caption = #12503#12524#12499#12517#12540'(&P)'
    Default = True
    TabOrder = 7
    OnClick = PrintBtnClick
  end
  object HeaderGroup: TGroupBox
    Left = 286
    Top = 317
    Width = 267
    Height = 125
    Caption = #12504#12483#12480#12539#12501#12483#12479
    TabOrder = 6
    object Label10: TLabel
      Left = 24
      Top = 24
      Width = 90
      Height = 12
      Caption = #24180#12539#26376#12398#34920#31034#20301#32622
    end
    object CaptionFontLabel: TLabel
      Left = 24
      Top = 95
      Width = 89
      Height = 12
      Caption = 'CaptionFontLabel'
    end
    object CaptionTopLeft: TRadioButton
      Left = 48
      Top = 48
      Width = 57
      Height = 17
      Caption = #24038#19978
      TabOrder = 0
    end
    object CaptionBottomLeft: TRadioButton
      Left = 48
      Top = 72
      Width = 57
      Height = 17
      Caption = #24038#19979
      TabOrder = 1
    end
    object CaptionTopCenter: TRadioButton
      Left = 104
      Top = 48
      Width = 57
      Height = 17
      Caption = #20013#22830#19978
      Checked = True
      TabOrder = 2
      TabStop = True
    end
    object CaptionBottomCenter: TRadioButton
      Left = 104
      Top = 72
      Width = 57
      Height = 17
      Caption = #20013#22830#19979
      TabOrder = 3
    end
    object CaptionTopRight: TRadioButton
      Left = 176
      Top = 48
      Width = 57
      Height = 17
      Caption = #21491#19978
      TabOrder = 4
    end
    object CaptionBottomRight: TRadioButton
      Left = 176
      Top = 72
      Width = 57
      Height = 17
      Caption = #21491#19979
      TabOrder = 5
    end
    object CaptionFontButton: TButton
      Left = 175
      Top = 91
      Width = 73
      Height = 25
      Caption = #12501#12457#12531#12488#36984#25246
      TabOrder = 6
      OnClick = CaptionFontButtonClick
    end
    object CaptionNone: TRadioButton
      Left = 176
      Top = 24
      Width = 65
      Height = 17
      Caption = #38750#34920#31034
      TabOrder = 7
    end
  end
  object LineGroup: TGroupBox
    Left = 432
    Top = 123
    Width = 120
    Height = 86
    Caption = #26085#20184#12398#26528
    TabOrder = 4
    object Label11: TLabel
      Left = 14
      Top = 28
      Width = 21
      Height = 12
      Caption = #22826#12373
    end
    object Label12: TLabel
      Left = 14
      Top = 60
      Width = 12
      Height = 12
      Caption = #33394
    end
    object LineWidthBox: TEdit
      Left = 51
      Top = 24
      Width = 32
      Height = 20
      ImeMode = imClose
      TabOrder = 0
      Text = '1'
      OnExit = StartMonthBoxExit
    end
    object LineColorBox: TColorBox
      Left = 32
      Top = 54
      Width = 79
      Height = 22
      Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
      ItemHeight = 16
      TabOrder = 1
    end
    object LineWidthUpDown: TUpDown
      Left = 83
      Top = 24
      Width = 16
      Height = 20
      Associate = LineWidthBox
      Min = 1
      Max = 15
      Position = 1
      TabOrder = 2
      Thousands = False
      OnChangingEx = StartMonthChangingEx
    end
  end
  object LayoutGroup: TGroupBox
    Left = 16
    Top = 224
    Width = 156
    Height = 97
    Caption = #20986#21147#12473#12479#12452#12523
    TabOrder = 2
    object StyleNormal: TRadioButton
      Left = 24
      Top = 24
      Width = 72
      Height = 17
      Caption = #36890#24120
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object StyleTwoPart: TRadioButton
      Left = 24
      Top = 47
      Width = 125
      Height = 17
      Caption = #24038#21491#12395#20108#20998#21106#12377#12427
      TabOrder = 1
      OnClick = StyleTwoPartClick
    end
    object HideOtherMonth: TCheckBox
      Left = 24
      Top = 70
      Width = 129
      Height = 17
      Caption = #21069#24460#12398#26376#12434#38750#34920#31034
      TabOrder = 2
    end
  end
  object FontGroup: TGroupBox
    Left = 191
    Top = 224
    Width = 361
    Height = 82
    Caption = #20986#21147#29992#12501#12457#12531#12488#12398#25351#23450#65288#30011#38754#34920#31034#29992#12501#12457#12531#12488#12363#12425#12398#22793#26356#65289
    TabOrder = 5
    object PrintFontLabel: TLabel
      Left = 143
      Top = 52
      Width = 74
      Height = 15
      Caption = 'PrintFontLabel'
    end
    object PrintFontCombo: TComboBox
      Left = 17
      Top = 24
      Width = 328
      Height = 20
      Style = csDropDownList
      ItemHeight = 12
      TabOrder = 0
      OnChange = PrintFontComboChange
    end
    object PrintFontButton: TButton
      Left = 272
      Top = 50
      Width = 73
      Height = 25
      Caption = #12501#12457#12531#12488#36984#25246
      TabOrder = 2
      OnClick = PrintFontButtonClick
    end
    object UsePrintFontCheck: TCheckBox
      Left = 18
      Top = 50
      Width = 112
      Height = 17
      Caption = #12501#12457#12531#12488#22793#26356#12377#12427#65306
      TabOrder = 1
      OnClick = UsePrintFontCheckClick
    end
  end
  object PrintDialog1: TPrintDialog
    Left = 512
    Top = 32
  end
  object FontDialog1: TFontDialog
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    Left = 520
    Top = 56
  end
end
