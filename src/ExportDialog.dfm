object frmExportDialog: TfrmExportDialog
  Left = 83
  Top = 168
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #26085#20184#12513#12514#12398#12456#12463#12473#12509#12540#12488
  ClientHeight = 326
  ClientWidth = 580
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object ResultLabel: TLabel
    Left = 424
    Top = 136
    Width = 129
    Height = 41
    AutoSize = False
    Caption = #26465#20214#12434#25351#23450#12375#12390#65292#19978#12398#12508#12479#12531#12434#25276#12377#12392#20986#21147#12364#23455#34892#12373#12428#12414#12377#65294
    WordWrap = True
  end
  object btnSaveToFile: TButton
    Left = 416
    Top = 32
    Width = 145
    Height = 41
    Caption = #12501#12449#12452#12523#12408#20986#21147'(&S) ...'
    Default = True
    TabOrder = 4
    OnClick = btnSaveToFileClick
  end
  object btnCopyToClipboard: TButton
    Left = 416
    Top = 84
    Width = 145
    Height = 41
    Caption = #12463#12522#12483#12503#12508#12540#12489#12408#12467#12500#12540'(&C)'
    TabOrder = 5
    OnClick = btnCopyToClipboardClick
  end
  object btnClose: TButton
    Left = 416
    Top = 192
    Width = 145
    Height = 41
    Cancel = True
    Caption = #38281#12376#12427
    TabOrder = 6
    OnClick = btnCloseClick
  end
  object ExportStyle: TRadioGroup
    Left = 16
    Top = 200
    Width = 113
    Height = 89
    Caption = #20986#21147#24418#24335
    ItemIndex = 0
    Items.Strings = (
      #12486#12461#12473#12488
      'CSV'#24418#24335
      #12479#12502#21306#20999#12426'CSV')
    TabOrder = 2
  end
  object ExportOptionGroupBox: TGroupBox
    Left = 144
    Top = 128
    Width = 249
    Height = 185
    Caption = #20986#21147#12377#12427#24773#22577
    TabOrder = 3
    object ExportWithRangeSeriesTodo: TCheckBox
      Left = 16
      Top = 48
      Width = 225
      Height = 33
      Caption = #26399#38291#12539#21608#26399#20104#23450#65292'TODO'#38917#30446#12434#21547#12417#12427
      TabOrder = 0
      WordWrap = True
    end
    object ExportWithReferences: TCheckBox
      Left = 16
      Top = 88
      Width = 185
      Height = 17
      Caption = #21442#29031#12501#12449#12452#12523#12398#20869#23481#12418#21547#12417#12427
      TabOrder = 1
    end
    object ExportEmptyItem: TCheckBox
      Left = 16
      Top = 120
      Width = 209
      Height = 17
      Caption = #20104#23450#12398#12394#12356#26085#12418#26085#20184#12384#12369#20986#21147#12377#12427
      TabOrder = 2
    end
    object ExportCSVWithDateHead: TCheckBox
      Left = 16
      Top = 144
      Width = 225
      Height = 33
      Caption = '(CSV'#12539#12479#12502#21306#20999#12426#20986#21147#29992') '#21508#26085#20184#12487#12540#12479#12398#20808#38957#34892#12384#12369#12395#26085#20184#12434#20184#21152#12377#12427
      TabOrder = 3
      WordWrap = True
    end
    object ExportWithDayName: TCheckBox
      Left = 16
      Top = 15
      Width = 225
      Height = 33
      Caption = #26332#26085#12434#20986#21147#12377#12427
      TabOrder = 4
      WordWrap = True
    end
  end
  object ExportRangeGroupBox: TGroupBox
    Left = 16
    Top = 16
    Width = 377
    Height = 97
    Caption = #20986#21147#12377#12427#26399#38291
    TabOrder = 0
    object Label1: TLabel
      Left = 64
      Top = 30
      Width = 36
      Height = 12
      Caption = #38283#22987#26085
    end
    object Label2: TLabel
      Left = 64
      Top = 62
      Width = 36
      Height = 12
      Caption = #32066#20102#26085
    end
    object Label9: TLabel
      Left = 212
      Top = 30
      Width = 22
      Height = 12
      Caption = #12363#12425
    end
    object Label11: TLabel
      Left = 220
      Top = 62
      Width = 12
      Height = 12
      Caption = #20840
    end
    object Label3: TLabel
      Left = 296
      Top = 62
      Width = 24
      Height = 12
      Caption = #26085#38291
    end
    object Label10: TLabel
      Left = 296
      Top = 30
      Width = 12
      Height = 12
      Caption = #26085
    end
    object StartDatePicker: TDateTimePicker
      Left = 112
      Top = 24
      Width = 97
      Height = 22
      Date = 38358.000000000000000000
      Time = 38358.000000000000000000
      ImeMode = imClose
      TabOrder = 0
      OnChange = StartDatePickerChange
    end
    object EndDatePicker: TDateTimePicker
      Left = 112
      Top = 56
      Width = 97
      Height = 22
      Date = 38358.000000000000000000
      Time = 38358.000000000000000000
      ImeMode = imClose
      TabOrder = 2
      OnChange = StartDatePickerChange
    end
    object DaysInputBox: TEdit
      Left = 240
      Top = 56
      Width = 33
      Height = 20
      ImeMode = imClose
      TabOrder = 3
      Text = '1'
      OnChange = DaysInputBoxChange
    end
    object DiffDaysInputBox: TEdit
      Left = 240
      Top = 24
      Width = 33
      Height = 20
      ImeMode = imClose
      TabOrder = 1
      Text = '0'
      OnChange = DiffDaysInputBoxChange
    end
    object UpDown2: TUpDown
      Left = 273
      Top = 24
      Width = 16
      Height = 20
      Associate = DiffDaysInputBox
      Min = -3660
      Max = 3660
      TabOrder = 4
      Thousands = False
    end
    object DaysCountUpDown: TUpDown
      Left = 273
      Top = 56
      Width = 16
      Height = 20
      Associate = DaysInputBox
      Min = 1
      Max = 3660
      Position = 1
      TabOrder = 5
      Thousands = False
    end
  end
  object DayStyleGroupBox: TGroupBox
    Left = 16
    Top = 128
    Width = 113
    Height = 57
    Caption = #26085#20184#12398#24418#24335
    TabOrder = 1
    object OutputDateFormat: TComboBox
      Left = 8
      Top = 21
      Width = 97
      Height = 20
      Style = csDropDownList
      ItemHeight = 12
      ItemIndex = 0
      TabOrder = 0
      Text = 'yyyy/mm/dd ('#20363': 2004/01/01)'
      Items.Strings = (
        'yyyy/mm/dd ('#20363': 2004/01/01)'
        'yyyy/m/d ('#20363': 2004/1/1)'
        'mm/dd'
        'm/d'
        'yyyy'#39#24180#39'm'#39#26376#39'd'#39#26085#39' ('#20363': 2004'#24180'1'#26376'1'#26085')'
        'gge'#39#24180#39'm'#39#26376#39'd'#39#26085#39' ('#20803#21495#20184#12365#21644#26278')'
        'm'#39#26376#39'd'#39#26085#39)
    end
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '*.txt'
    Filter = #12486#12461#12473#12488#12501#12449#12452#12523'(*.txt; *.csv)|*.txt;*.csv|'#12377#12409#12390#12398#12501#12449#12452#12523'(*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = #20986#21147#12501#12449#12452#12523#12398#25351#23450
    Left = 504
    Top = 264
  end
end
