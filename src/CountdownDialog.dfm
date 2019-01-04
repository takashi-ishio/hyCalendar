object frmCountdown: TfrmCountdown
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #26085#20184#12459#12454#12531#12488#12480#12454#12531#12398#35373#23450
  ClientHeight = 389
  ClientWidth = 616
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object CounterGroup: TGroupBox
    Left = 263
    Top = 24
    Width = 337
    Height = 345
    Caption = #12459#12454#12531#12479#12398#20869#23481
    TabOrder = 1
    object Label1: TLabel
      Left = 56
      Top = 119
      Width = 55
      Height = 13
      Caption = #21608#26399#20104#23450': '
    end
    object SelectedSeriesItemLabel: TLabel
      Left = 117
      Top = 119
      Width = 131
      Height = 13
      Caption = #65288#21491#12398#12508#12479#12531#12363#12425#25351#23450#12375#12414#12377#65289
    end
    object Label3: TLabel
      Left = 125
      Top = 241
      Width = 134
      Height = 13
      Caption = #26085#21069#12395#12394#12427#12414#12391#12399#34920#31034#12375#12394#12356
    end
    object Label2: TLabel
      Left = 232
      Top = 178
      Width = 73
      Height = 13
      Caption = #12414#12391#12354#12392#9675#9675#26085
    end
    object Label4: TLabel
      Left = 24
      Top = 310
      Width = 295
      Height = 13
      AutoSize = False
      Caption = #26032#12383#12394#12459#12454#12531#12479#12434#36861#21152#12377#12427#12395#12399#65292#24038#12398#12300#26032#35215#12301#12434#36984#25246#12375#12390#12367#12384#12373#12356#65294
      WordWrap = True
    end
    object Label5: TLabel
      Left = 105
      Top = 206
      Width = 199
      Height = 13
      Caption = #29305#27530#12394#21517#21069': "%D" '#12399#26085#20184#12395#32622#25563#12373#12428#12414#12377
    end
    object DisableCheck: TCheckBox
      Left = 24
      Top = 277
      Width = 145
      Height = 12
      Caption = #12371#12398#12459#12454#12531#12479#12434#28961#21177#12395#12377#12427
      TabOrder = 9
      WordWrap = True
      OnClick = DisableCheckClick
    end
    object radioSpecifiedDate: TRadioButton
      Left = 24
      Top = 33
      Width = 146
      Height = 17
      Caption = #25351#23450#26085#12414#12391#12434#12459#12454#12531#12488#12377#12427
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = radioSpecifiedDateClick
    end
    object radioSpecifiedSeriesitem: TRadioButton
      Left = 24
      Top = 96
      Width = 281
      Height = 17
      Caption = #36984#25246#12375#12383#21608#26399#20104#23450#12398#27425#12398#26085#20184#12414#12391#12434#12459#12454#12531#12488#12377#12427
      TabOrder = 3
      OnClick = radioSpecifiedDateClick
    end
    object DateTimePicker1: TDateTimePicker
      Left = 176
      Top = 29
      Width = 121
      Height = 24
      Date = 39011.000000000000000000
      Time = 39011.000000000000000000
      TabOrder = 1
      OnChange = DateTimePicker1Change
    end
    object btnSelectSeriesitem: TButton
      Left = 264
      Top = 114
      Width = 57
      Height = 25
      Caption = #21442#29031'...'
      TabOrder = 4
      OnClick = btnSelectSeriesitemClick
    end
    object CountdownLimitBox: TEdit
      Left = 56
      Top = 237
      Width = 41
      Height = 21
      ImeMode = imDisable
      TabOrder = 7
      Text = '100'
      OnChange = CountdownLimitBoxChange
    end
    object CountDownLimit: TUpDown
      Left = 97
      Top = 237
      Width = 16
      Height = 21
      Associate = CountdownLimitBox
      Max = 366
      Position = 100
      TabOrder = 8
      OnClick = CountDownLimitClick
    end
    object UseCaptionCheck: TCheckBox
      Left = 24
      Top = 152
      Width = 145
      Height = 17
      Caption = #34920#31034#25991#23383#21015#12434#25351#23450#12377#12427
      TabOrder = 5
      OnClick = UseCaptionCheckClick
    end
    object CaptionBox: TEdit
      Left = 56
      Top = 175
      Width = 170
      Height = 21
      TabOrder = 6
      OnChange = CaptionBoxChange
    end
    object EveryYearCheck: TCheckBox
      Left = 66
      Top = 63
      Width = 225
      Height = 17
      Caption = #25351#23450#26085#12434#36942#12366#12383#12425#65297#24180#21336#20301#12391#24310#38263#12377#12427
      TabOrder = 2
      OnClick = EveryYearCheckClick
    end
  end
  object GroupBox2: TGroupBox
    Left = 16
    Top = 24
    Width = 225
    Height = 345
    Caption = #35373#23450#12373#12428#12390#12356#12427#12459#12454#12531#12479
    TabOrder = 0
    object CountdownList: TListBox
      Left = 16
      Top = 28
      Width = 193
      Height = 218
      ItemHeight = 13
      TabOrder = 0
      OnClick = CountdownListClick
    end
    object btnDelete: TButton
      Left = 151
      Top = 259
      Width = 58
      Height = 30
      Caption = #21066#38500
      TabOrder = 3
      OnClick = btnDeleteClick
    end
    object btnDup: TButton
      Left = 83
      Top = 259
      Width = 58
      Height = 30
      Caption = #35079#35069
      TabOrder = 2
      OnClick = btnDupClick
    end
    object btnUp: TButton
      Left = 16
      Top = 295
      Width = 58
      Height = 30
      Caption = #8593#19978#12408
      TabOrder = 4
      OnClick = btnUpClick
    end
    object btnDown: TButton
      Left = 83
      Top = 295
      Width = 58
      Height = 30
      Caption = #8595#19979#12408
      TabOrder = 5
      OnClick = btnDownClick
    end
    object btnAdd: TButton
      Left = 16
      Top = 259
      Width = 58
      Height = 30
      Caption = #26032#35215
      TabOrder = 1
      OnClick = btnAddClick
    end
  end
end
