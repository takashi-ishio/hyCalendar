object frmRangeItemEditDialog: TfrmRangeItemEditDialog
  Left = 239
  Top = 203
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #26399#38291#20104#23450#12398#32232#38598
  ClientHeight = 301
  ClientWidth = 491
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object Label1: TLabel
    Left = 24
    Top = 32
    Width = 84
    Height = 12
    Caption = #26399#38291#20104#23450#38283#22987#26085
  end
  object Label2: TLabel
    Left = 24
    Top = 64
    Width = 84
    Height = 12
    Caption = #26399#38291#20104#23450#32066#20102#26085
  end
  object Label4: TLabel
    Left = 48
    Top = 100
    Width = 60
    Height = 12
    Caption = #34920#31034#25991#23383#21015
  end
  object Label5: TLabel
    Left = 48
    Top = 140
    Width = 60
    Height = 12
    Caption = #31684#22258#34920#31034#33394
  end
  object Label3: TLabel
    Left = 336
    Top = 62
    Width = 24
    Height = 12
    Caption = #26085#38291
  end
  object Label6: TLabel
    Left = 36
    Top = 172
    Width = 72
    Height = 12
    Caption = #25991#23383#21015#34920#31034#33394
  end
  object Label7: TLabel
    Left = 72
    Top = 204
    Width = 36
    Height = 12
    Caption = #32218#12398#24133
  end
  object Label8: TLabel
    Left = 200
    Top = 204
    Width = 48
    Height = 12
    Caption = #32218#12398#31278#39006
  end
  object Label9: TLabel
    Left = 252
    Top = 30
    Width = 22
    Height = 12
    Caption = #12363#12425
  end
  object Label10: TLabel
    Left = 336
    Top = 30
    Width = 12
    Height = 12
    Caption = #26085
  end
  object Label11: TLabel
    Left = 260
    Top = 62
    Width = 12
    Height = 12
    Caption = #20840
  end
  object Label12: TLabel
    Left = 14
    Top = 272
    Width = 94
    Height = 12
    Caption = #34920#31034#12434#39131#12400#12377#26332#26085
  end
  object Label13: TLabel
    Left = 36
    Top = 235
    Width = 72
    Height = 12
    Caption = #24038#21491#31471#12398#30690#21360
  end
  object StartDatePicker: TDateTimePicker
    Left = 120
    Top = 24
    Width = 129
    Height = 21
    Date = 37908.000000000000000000
    Time = 37908.000000000000000000
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    ImeMode = imClose
    ParentFont = False
    TabOrder = 0
    OnChange = StartDatePickerChange
  end
  object EndDatePicker: TDateTimePicker
    Left = 120
    Top = 56
    Width = 129
    Height = 21
    Date = 37908.000000000000000000
    Time = 37908.000000000000000000
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    ImeMode = imClose
    ParentFont = False
    TabOrder = 2
    OnChange = StartDatePickerChange
  end
  object OKBtn: TButton
    Left = 376
    Top = 16
    Width = 97
    Height = 33
    Caption = #30906#23450
    Default = True
    TabOrder = 13
    OnClick = OKBtnClick
  end
  object TextInputBox: TEdit
    Left = 120
    Top = 96
    Width = 209
    Height = 21
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnChange = TextInputBoxChange
  end
  object LineColorBox: TColorBox
    Left = 120
    Top = 136
    Width = 113
    Height = 22
    Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
    ItemHeight = 16
    TabOrder = 5
  end
  object CancelBtn: TButton
    Left = 376
    Top = 64
    Width = 97
    Height = 33
    Cancel = True
    Caption = #12461#12515#12531#12475#12523
    TabOrder = 14
    OnClick = CancelBtnClick
  end
  object DeleteBtn: TButton
    Left = 376
    Top = 112
    Width = 97
    Height = 33
    Caption = #21066#38500
    TabOrder = 15
    OnClick = DeleteBtnClick
  end
  object DaysInputBox: TEdit
    Left = 280
    Top = 56
    Width = 33
    Height = 20
    ImeMode = imClose
    TabOrder = 3
    Text = '1'
    OnChange = DaysInputBoxChange
  end
  object TextColorBox: TColorBox
    Left = 120
    Top = 168
    Width = 113
    Height = 22
    Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
    ItemHeight = 16
    TabOrder = 7
  end
  object IsDayTextColorCheck: TCheckBox
    Left = 240
    Top = 172
    Width = 113
    Height = 17
    Caption = #27161#28310#35373#23450#12434#20351#29992
    TabOrder = 6
    OnClick = IsDayTextColorCheckClick
  end
  object PenWidthEdit: TEdit
    Left = 120
    Top = 200
    Width = 41
    Height = 20
    ImeMode = imClose
    MaxLength = 2
    TabOrder = 8
    Text = '1'
    OnChange = PenWidthEditChange
  end
  object UpDown1: TUpDown
    Left = 161
    Top = 200
    Width = 16
    Height = 20
    Associate = PenWidthEdit
    Min = 1
    Max = 5
    Position = 1
    TabOrder = 17
  end
  object PenStyleBox: TComboBox
    Left = 264
    Top = 200
    Width = 97
    Height = 20
    Style = csDropDownList
    ItemHeight = 12
    TabOrder = 9
    Items.Strings = (
      #23455#32218
      #28857#32218
      #30772#32218
      #19968#28857#37782#32218
      #20108#28857#37782#32218)
  end
  object DaysCountUpDown: TUpDown
    Left = 313
    Top = 56
    Width = 17
    Height = 20
    Associate = DaysInputBox
    Min = 1
    Max = 3660
    Position = 1
    TabOrder = 18
    Thousands = False
  end
  object DiffDaysInputBox: TEdit
    Left = 280
    Top = 24
    Width = 33
    Height = 20
    ImeMode = imClose
    TabOrder = 1
    Text = '0'
    OnChange = DiffDaysInputBoxChange
  end
  object UpDown2: TUpDown
    Left = 313
    Top = 24
    Width = 16
    Height = 20
    Associate = DiffDaysInputBox
    Min = -3660
    Max = 3660
    TabOrder = 19
    Thousands = False
  end
  object DupBtn: TButton
    Left = 376
    Top = 160
    Width = 97
    Height = 33
    Caption = #35079#35069
    TabOrder = 16
    OnClick = DupBtnClick
  end
  object SkipSaturdayCheck: TCheckBox
    Left = 122
    Top = 271
    Width = 57
    Height = 17
    Caption = #22303#26332#26085
    TabOrder = 10
  end
  object SkipSundayCheck: TCheckBox
    Left = 194
    Top = 271
    Width = 57
    Height = 17
    Caption = #26085#26332#26085
    TabOrder = 11
  end
  object SkipHolidayCheck: TCheckBox
    Left = 266
    Top = 271
    Width = 57
    Height = 17
    Caption = #31069#26085
    TabOrder = 12
  end
  object ArrowTypeBox: TComboBox
    Left = 120
    Top = 232
    Width = 113
    Height = 20
    Style = csDropDownList
    ItemHeight = 12
    ItemIndex = 0
    TabOrder = 20
    Text = #8592#8594' '#65288#20001#26041#12354#12426#65289
    Items.Strings = (
      #8592#8594' '#65288#20001#26041#12354#12426#65289
      #8592#65293' '#65288#24038#12398#12415#65289
      #65293#8594' '#65288#21491#12398#12415#65289
      #65293#65293' '#65288#20001#26041#12394#12375#65289)
  end
end
