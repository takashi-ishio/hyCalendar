object frmDayConditionPropertyEditDialog: TfrmDayConditionPropertyEditDialog
  Left = 233
  Top = 134
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #26465#20214#12398#32232#38598
  ClientHeight = 460
  ClientWidth = 479
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
  object Label5: TLabel
    Left = 200
    Top = 20
    Width = 218
    Height = 24
    Caption = '"-2,4,6-8" '#24418#24335#65294'"z" '#12399#21336#20307#12391#26376#26411#26085#12539#36913#65292#26410#35352#20837#12394#12425#28961#26465#20214#65294
    WordWrap = True
  end
  object Label4: TLabel
    Left = 80
    Top = 24
    Width = 12
    Height = 12
    Caption = #26376
  end
  object Label9: TLabel
    Left = 176
    Top = 24
    Width = 12
    Height = 12
    Caption = #26085
  end
  object Label6: TLabel
    Left = 176
    Top = 56
    Width = 12
    Height = 12
    Caption = #36913
  end
  object Label7: TLabel
    Left = 24
    Top = 230
    Width = 24
    Height = 12
    Caption = #26332#26085
  end
  object Label10: TLabel
    Left = 24
    Top = 272
    Width = 59
    Height = 12
    Caption = #26332#26085#12398#25201#12356
  end
  object Label3: TLabel
    Left = 216
    Top = 324
    Width = 22
    Height = 12
    Caption = #12363#12425
  end
  object Label8: TLabel
    Left = 216
    Top = 348
    Width = 22
    Height = 12
    Caption = #12414#12391
  end
  object Label1: TLabel
    Left = 56
    Top = 432
    Width = 259
    Height = 12
    Caption = #65288#26465#20214#12395#12510#12483#12481#12375#12383#26085#20184#12399#21608#26399#20104#23450#12363#12425#38500#22806#12373#12428#12427#65289
  end
  object Label2: TLabel
    Left = 304
    Top = 248
    Width = 116
    Height = 12
    Caption = #26332#26085#26410#35352#20837#65309#26465#20214#12394#12375
  end
  object Label11: TLabel
    Left = 307
    Top = 184
    Width = 22
    Height = 12
    Caption = #12363#12425
  end
  object Label12: TLabel
    Left = 387
    Top = 184
    Width = 12
    Height = 12
    Caption = #26085
  end
  object Label14: TLabel
    Left = 344
    Top = 87
    Width = 88
    Height = 12
    Caption = #12363#12425'1, 3, 5, ...'#36913#30446
  end
  object Label15: TLabel
    Left = 207
    Top = 87
    Width = 36
    Height = 12
    Caption = #22522#28310#26085
  end
  object Label16: TLabel
    Left = 344
    Top = 119
    Width = 22
    Height = 12
    Caption = #12363#12425
  end
  object Label17: TLabel
    Left = 418
    Top = 119
    Width = 43
    Height = 12
    Caption = #26085#12395#65297#26085
  end
  object Label18: TLabel
    Left = 207
    Top = 119
    Width = 36
    Height = 12
    Caption = #22522#28310#26085
  end
  object MonthBox: TEdit
    Left = 24
    Top = 20
    Width = 49
    Height = 20
    ImeMode = imDisable
    TabOrder = 0
  end
  object RadioDayCondition: TRadioButton
    Left = 104
    Top = 20
    Width = 17
    Height = 17
    Checked = True
    TabOrder = 1
    TabStop = True
    OnClick = RadioDayConditionClick
  end
  object DayBox: TEdit
    Left = 122
    Top = 20
    Width = 49
    Height = 20
    ImeMode = imDisable
    TabOrder = 2
  end
  object WeekBox: TEdit
    Left = 122
    Top = 52
    Width = 49
    Height = 20
    ImeMode = imDisable
    TabOrder = 4
  end
  object RadioWeekCondition: TRadioButton
    Left = 104
    Top = 54
    Width = 17
    Height = 17
    TabOrder = 3
    OnClick = RadioWeekConditionClick
  end
  object WeekCountMethodBox: TComboBox
    Left = 200
    Top = 52
    Width = 201
    Height = 20
    Style = csDropDownList
    ItemHeight = 12
    ItemIndex = 0
    TabOrder = 5
    Text = #25351#23450#26332#26085#12364#20309#24230#30446#12363#12391#25968#12360#12427
    Items.Strings = (
      #25351#23450#26332#26085#12364#20309#24230#30446#12363#12391#25968#12360#12427
      #65300#26085#20197#19978#12354#12427#36913#12434#31532#19968#36913#12392#12377#12427#65288'ISO8601'#28310#25312#65289)
  end
  object SaturdayCheck: TCheckBox
    Left = 384
    Top = 229
    Width = 33
    Height = 17
    Caption = #22303
    TabOrder = 24
  end
  object FridayCheck: TCheckBox
    Left = 336
    Top = 229
    Width = 33
    Height = 17
    Caption = #37329
    TabOrder = 23
  end
  object ThursdayCheck: TCheckBox
    Left = 288
    Top = 229
    Width = 41
    Height = 17
    Caption = #26408
    TabOrder = 22
  end
  object WednesdayCheck: TCheckBox
    Left = 240
    Top = 229
    Width = 41
    Height = 17
    Caption = #27700
    TabOrder = 21
  end
  object TuesdayCheck: TCheckBox
    Left = 192
    Top = 229
    Width = 33
    Height = 17
    Caption = #28779
    TabOrder = 20
  end
  object MondayCheck: TCheckBox
    Left = 144
    Top = 229
    Width = 33
    Height = 17
    Caption = #26376
    TabOrder = 19
  end
  object SundayCheck: TCheckBox
    Left = 96
    Top = 229
    Width = 33
    Height = 17
    Caption = #26085
    TabOrder = 18
  end
  object HolidayHandlingForDay: TComboBox
    Left = 89
    Top = 266
    Width = 337
    Height = 20
    Style = csDropDownList
    ItemHeight = 12
    TabOrder = 25
  end
  object UserDefinedHolidayCheck: TCheckBox
    Left = 248
    Top = 296
    Width = 177
    Height = 17
    Caption = #12518#12540#12470#12540#23450#32681#12398#31069#26085#12434#21547#12417#12427
    TabOrder = 28
  end
  object RangeStart: TDateTimePicker
    Left = 104
    Top = 322
    Width = 105
    Height = 20
    Date = 37952.000000000000000000
    Time = 37952.000000000000000000
    ImeMode = imDisable
    TabOrder = 30
  end
  object OKBtn: TButton
    Left = 344
    Top = 348
    Width = 81
    Height = 30
    Caption = #36861#21152
    Default = True
    ModalResult = 1
    TabOrder = 35
  end
  object CanecelBtn: TButton
    Left = 344
    Top = 392
    Width = 81
    Height = 30
    Cancel = True
    Caption = #12461#12515#12531#12475#12523
    ModalResult = 2
    TabOrder = 36
  end
  object RangeEnd: TDateTimePicker
    Left = 104
    Top = 346
    Width = 105
    Height = 20
    Date = 37952.000000000000000000
    Time = 37952.000000000000000000
    ImeMode = imDisable
    TabOrder = 32
  end
  object ConstrainedByRangeEnd: TCheckBox
    Left = 40
    Top = 348
    Width = 57
    Height = 17
    Caption = #32066#20102#26085
    TabOrder = 31
  end
  object ConstrainedByRangeStart: TCheckBox
    Left = 40
    Top = 324
    Width = 57
    Height = 17
    Caption = #38283#22987#26085
    TabOrder = 29
  end
  object HolidayHandlingForWeek: TComboBox
    Left = 89
    Top = 266
    Width = 337
    Height = 20
    Style = csDropDownList
    ItemHeight = 12
    TabOrder = 26
  end
  object ConditionDisabled: TCheckBox
    Left = 40
    Top = 384
    Width = 265
    Height = 17
    Caption = #12371#12398#26465#20214#12434#28961#21177#12395#12377#12427
    TabOrder = 33
  end
  object ExclusionCheck: TCheckBox
    Left = 40
    Top = 408
    Width = 257
    Height = 17
    Caption = #12371#12398#26465#20214#12434#12300#38500#22806#26465#20214#12301#12395#12377#12427
    TabOrder = 34
    WordWrap = True
  end
  object RadioBiweekCondition: TRadioButton
    Left = 104
    Top = 86
    Width = 57
    Height = 17
    Caption = #38548#36913
    TabOrder = 6
    OnClick = RadioBiweekConditionClick
  end
  object BiweekBaseDate: TDateTimePicker
    Left = 249
    Top = 82
    Width = 89
    Height = 20
    Date = 37952.000000000000000000
    Time = 37952.000000000000000000
    ImeMode = imDisable
    TabOrder = 7
  end
  object RadioOtherSeriesRef: TRadioButton
    Left = 104
    Top = 182
    Width = 89
    Height = 17
    Caption = #36984#25246#12375#12383#20104#23450
    TabOrder = 13
    OnClick = RadioOtherSeriesRefClick
  end
  object OtherSeriesRefListBox: TComboBox
    Left = 195
    Top = 180
    Width = 105
    Height = 20
    Style = csDropDownList
    ImeMode = imDisable
    ItemHeight = 12
    TabOrder = 14
  end
  object OtherSeriesRefDiffBox: TEdit
    Left = 339
    Top = 180
    Width = 25
    Height = 20
    ImeMode = imDisable
    TabOrder = 15
    Text = '1'
  end
  object OtherSeriesRefDiffKindBox: TComboBox
    Left = 403
    Top = 180
    Width = 41
    Height = 20
    Style = csDropDownList
    ImeMode = imDisable
    ItemHeight = 12
    ItemIndex = 0
    TabOrder = 17
    Text = #24460
    Items.Strings = (
      #24460
      #21069)
  end
  object OtherSeriesRefDiffUpDown: TUpDown
    Left = 364
    Top = 180
    Width = 16
    Height = 20
    Associate = OtherSeriesRefDiffBox
    Max = 99
    Position = 1
    TabOrder = 16
  end
  object HolidayHandlingForRefer: TComboBox
    Left = 89
    Top = 266
    Width = 337
    Height = 20
    Style = csDropDownList
    ItemHeight = 12
    TabOrder = 27
  end
  object DayCountBox: TEdit
    Left = 372
    Top = 114
    Width = 25
    Height = 20
    ImeMode = imDisable
    TabOrder = 10
    Text = '2'
  end
  object DayCountUpDown: TUpDown
    Left = 397
    Top = 114
    Width = 16
    Height = 20
    Associate = DayCountBox
    Min = 1
    Max = 999
    Position = 2
    TabOrder = 11
  end
  object RadioDayCountCondition: TRadioButton
    Left = 104
    Top = 118
    Width = 97
    Height = 17
    Caption = #19968#23450#26085#25968#38291#38548
    TabOrder = 8
    OnClick = RadioDayCountConditionClick
  end
  object DayCountBaseDate: TDateTimePicker
    Left = 249
    Top = 114
    Width = 89
    Height = 20
    Date = 37952.000000000000000000
    Time = 37952.000000000000000000
    ImeMode = imDisable
    TabOrder = 9
  end
  object DayCountStyle: TComboBox
    Left = 216
    Top = 144
    Width = 247
    Height = 20
    Style = csDropDownList
    ItemHeight = 12
    ItemIndex = 1
    TabOrder = 12
    Text = #12377#12409#12390#12398#26085#12434#25968#12360#12390#25351#23450#12398#26332#26085#12395#12384#12369#34920#31034
    OnChange = DayCountStyleChange
    Items.Strings = (
      #25351#23450#12398#26332#26085#12384#12369#12434#25968#12360#12427
      #12377#12409#12390#12398#26085#12434#25968#12360#12390#25351#23450#12398#26332#26085#12395#12384#12369#34920#31034)
  end
end
