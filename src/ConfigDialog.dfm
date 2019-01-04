object frmConfigDialog: TfrmConfigDialog
  Left = 229
  Top = 129
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #35373#23450
  ClientHeight = 438
  ClientWidth = 466
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
  object OKBtn: TButton
    Left = 280
    Top = 392
    Width = 73
    Height = 33
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = OKBtnClick
  end
  object CancelBtn: TButton
    Left = 368
    Top = 392
    Width = 73
    Height = 33
    Cancel = True
    Caption = #12461#12515#12531#12475#12523
    TabOrder = 1
    OnClick = CancelBtnClick
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 465
    Height = 377
    ActivePage = TabSheet1
    MultiLine = True
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = #12501#12457#12531#12488
      object GroupBox1: TGroupBox
        Left = 16
        Top = 16
        Width = 421
        Height = 305
        Caption = #12501#12457#12531#12488#35373#23450
        TabOrder = 0
        object TextFontLabel: TLabel
          Left = 176
          Top = 24
          Width = 73
          Height = 12
          Caption = 'TextFontLabel'
        end
        object Label3: TLabel
          Left = 32
          Top = 24
          Width = 44
          Height = 12
          Caption = #26085#20184#12513#12514
        end
        object DayNameFontLabel: TLabel
          Left = 176
          Top = 52
          Width = 99
          Height = 12
          Caption = 'DayNameFontLabel'
        end
        object Label4: TLabel
          Left = 32
          Top = 52
          Width = 24
          Height = 12
          Caption = #26332#26085
        end
        object DayFontLabel: TLabel
          Left = 176
          Top = 80
          Width = 70
          Height = 12
          Caption = 'DayFontLabel'
        end
        object Label5: TLabel
          Left = 32
          Top = 80
          Width = 48
          Height = 12
          Caption = #26085#20184#25968#23383
        end
        object HyperlinkFontLabel: TLabel
          Left = 176
          Top = 136
          Width = 70
          Height = 12
          Caption = 'DayFontLabel'
        end
        object Label6: TLabel
          Left = 32
          Top = 136
          Width = 111
          Height = 12
          Caption = #12495#12452#12497#12540#12522#12531#12463#25991#23383#21015
        end
        object FreeMemoFontLabel: TLabel
          Left = 176
          Top = 164
          Width = 70
          Height = 12
          Caption = 'DayFontLabel'
        end
        object Label7: TLabel
          Left = 32
          Top = 164
          Width = 51
          Height = 12
          Caption = #12501#12522#12540#12513#12514
        end
        object RangeItemFontLabel: TLabel
          Left = 176
          Top = 192
          Width = 104
          Height = 12
          Caption = 'RangeItemFontLabel'
        end
        object Label8: TLabel
          Left = 32
          Top = 192
          Width = 48
          Height = 12
          Caption = #26399#38291#20104#23450
        end
        object SeriesPlanItemFontLabel: TLabel
          Left = 176
          Top = 220
          Width = 126
          Height = 12
          Caption = 'SeriesPlanItemFontLabel'
        end
        object Label12: TLabel
          Left = 32
          Top = 220
          Width = 48
          Height = 12
          Caption = #21608#26399#20104#23450
        end
        object Label11: TLabel
          Left = 32
          Top = 248
          Width = 128
          Height = 12
          Caption = 'ToDo ('#12459#12524#12531#12480#12540#34920#31034#29992')'
        end
        object TodoFontLabel: TLabel
          Left = 176
          Top = 248
          Width = 75
          Height = 12
          Caption = 'TodoFontLabel'
        end
        object Label20: TLabel
          Left = 32
          Top = 108
          Width = 36
          Height = 12
          Caption = #20241#26085#21517
        end
        object HolidayNameFontLabel: TLabel
          Left = 176
          Top = 108
          Width = 117
          Height = 12
          Caption = 'HolidayNameFontLabel'
        end
        object Label29: TLabel
          Left = 32
          Top = 276
          Width = 103
          Height = 12
          Caption = 'ToDo ('#12522#12473#12488#34920#31034#29992')'
        end
        object TodoViewFontLabel: TLabel
          Left = 176
          Top = 276
          Width = 100
          Height = 12
          Caption = 'TodoViewFontLabel'
        end
        object TextFontChangeBtn: TButton
          Left = 336
          Top = 21
          Width = 57
          Height = 20
          Caption = #22793#26356
          TabOrder = 0
          OnClick = FontChangeBtnClick
        end
        object DayNameFontChangeBtn: TButton
          Left = 336
          Top = 49
          Width = 57
          Height = 20
          Caption = #22793#26356
          TabOrder = 1
          OnClick = FontChangeBtnClick
        end
        object DayFontChangeBtn: TButton
          Left = 336
          Top = 77
          Width = 57
          Height = 20
          Caption = #22793#26356
          TabOrder = 2
          OnClick = FontChangeBtnClick
        end
        object HyperlinkFontChangeBtn: TButton
          Left = 336
          Top = 133
          Width = 57
          Height = 20
          Caption = #22793#26356
          TabOrder = 4
          OnClick = FontChangeBtnClick
        end
        object FreeMemoFontChangeBtn: TButton
          Left = 336
          Top = 161
          Width = 57
          Height = 20
          Caption = #22793#26356
          TabOrder = 5
          OnClick = FontChangeBtnClick
        end
        object RangeItemFontChangeBtn: TButton
          Left = 336
          Top = 189
          Width = 57
          Height = 20
          Caption = #22793#26356
          TabOrder = 6
          OnClick = FontChangeBtnClick
        end
        object SeriesPlanItemFontChangeBtn: TButton
          Left = 336
          Top = 217
          Width = 57
          Height = 20
          Caption = #22793#26356
          TabOrder = 7
          OnClick = FontChangeBtnClick
        end
        object TodoFontChangeBtn: TButton
          Left = 336
          Top = 245
          Width = 57
          Height = 20
          Caption = #22793#26356
          TabOrder = 8
          OnClick = FontChangeBtnClick
        end
        object HolidayNameFontChangeBtn: TButton
          Left = 336
          Top = 105
          Width = 57
          Height = 20
          Caption = #22793#26356
          TabOrder = 3
          OnClick = FontChangeBtnClick
        end
        object TodoViewFontChangeBtn: TButton
          Left = 336
          Top = 273
          Width = 57
          Height = 20
          Caption = #22793#26356
          TabOrder = 9
          OnClick = FontChangeBtnClick
        end
      end
    end
    object TabSheet5: TTabSheet
      Caption = #34920#31034#33394
      ImageIndex = 4
      object GroupBox3: TGroupBox
        Left = 16
        Top = 16
        Width = 428
        Height = 310
        Caption = #33394#12398#35373#23450
        TabOrder = 0
        object Label1: TLabel
          Left = 32
          Top = 60
          Width = 88
          Height = 12
          Caption = #26908#32034#32080#26524' '#32972#26223#33394
        end
        object Label2: TLabel
          Left = 32
          Top = 88
          Width = 102
          Height = 12
          Caption = #12399#12415#20986#12375#34920#31034#12510#12540#12463
        end
        object Label9: TLabel
          Left = 32
          Top = 116
          Width = 80
          Height = 12
          Caption = #29694#22312#26085#12459#12540#12477#12523
        end
        object Label10: TLabel
          Left = 32
          Top = 144
          Width = 68
          Height = 12
          Caption = #36984#25246#12459#12540#12477#12523
        end
        object Label21: TLabel
          Left = 32
          Top = 32
          Width = 36
          Height = 12
          Caption = #32972#26223#33394
        end
        object Label23: TLabel
          Left = 32
          Top = 172
          Width = 84
          Height = 12
          Caption = #22303#26332#26085#12398#34920#31034#33394
        end
        object Label24: TLabel
          Left = 32
          Top = 200
          Width = 114
          Height = 12
          Caption = #26085#26332#26085'/'#31069#26085#12398#34920#31034#33394
        end
        object Label25: TLabel
          Left = 32
          Top = 228
          Width = 108
          Height = 12
          Caption = #21029#12398#26376#12398#26085#12398#34920#31034#33394
        end
        object Label30: TLabel
          Left = 32
          Top = 256
          Width = 132
          Height = 12
          Caption = #21029#12398#26376#12398#26085#31069#26085#12398#34920#31034#33394
        end
        object Label31: TLabel
          Left = 319
          Top = 116
          Width = 45
          Height = 12
          Caption = #26528#12398#22826#12373
        end
        object Label32: TLabel
          Left = 318
          Top = 144
          Width = 45
          Height = 12
          Caption = #26528#12398#22826#12373
        end
        object Label33: TLabel
          Left = 32
          Top = 284
          Width = 108
          Height = 12
          Caption = #21029#12398#26376#12398#26085#12398#32972#26223#33394
        end
        object MarkingColorBox: TColorBox
          Left = 184
          Top = 56
          Width = 129
          Height = 22
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 1
        end
        object ClippedMarkColorBox: TColorBox
          Left = 184
          Top = 84
          Width = 129
          Height = 22
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 2
        end
        object TodayColorBox: TColorBox
          Left = 184
          Top = 112
          Width = 129
          Height = 22
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 3
        end
        object SelectColorBox: TColorBox
          Left = 184
          Top = 139
          Width = 129
          Height = 22
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 6
        end
        object DefaultBackColorBox: TColorBox
          Left = 184
          Top = 28
          Width = 129
          Height = 22
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 0
        end
        object SaturdayColorBox: TColorBox
          Left = 184
          Top = 168
          Width = 129
          Height = 22
          DefaultColorColor = clBlue
          Selected = clBlue
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 9
        end
        object SundayColorBox: TColorBox
          Left = 184
          Top = 196
          Width = 129
          Height = 22
          DefaultColorColor = clRed
          Selected = clRed
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 10
        end
        object OtherMonthColorBox: TColorBox
          Left = 184
          Top = 224
          Width = 129
          Height = 22
          DefaultColorColor = clGray
          Selected = clGrayText
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 11
        end
        object OtherMonthSundayColorBox: TColorBox
          Left = 184
          Top = 252
          Width = 129
          Height = 22
          DefaultColorColor = clGray
          Selected = clMaroon
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 13
        end
        object TodayWidthBox: TEdit
          Left = 370
          Top = 112
          Width = 22
          Height = 20
          TabOrder = 4
          Text = '1'
        end
        object TodayWidthUpDown: TUpDown
          Left = 392
          Top = 112
          Width = 16
          Height = 20
          Associate = TodayWidthBox
          Min = 1
          Max = 5
          Position = 1
          TabOrder = 5
        end
        object SelectWidthBox: TEdit
          Left = 369
          Top = 139
          Width = 22
          Height = 20
          TabOrder = 7
          Text = '1'
        end
        object SelectWidthUpDown: TUpDown
          Left = 391
          Top = 139
          Width = 16
          Height = 20
          Associate = SelectWidthBox
          Min = 1
          Max = 5
          Position = 1
          TabOrder = 8
        end
        object UseOtherMonthColorForContents: TCheckBox
          Left = 326
          Top = 224
          Width = 89
          Height = 22
          Caption = #20104#23450#12395#12418#36969#29992
          TabOrder = 12
        end
        object OtherMonthBackColorBox: TColorBox
          Left = 184
          Top = 280
          Width = 129
          Height = 22
          DefaultColorColor = clGray
          Selected = clDefault
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 14
        end
      end
    end
    object TabSheet9: TTabSheet
      Caption = #35013#39166#25991#23383#21015' (1)'
      ImageIndex = 8
      object GroupBox11: TGroupBox
        Left = 16
        Top = 240
        Width = 377
        Height = 57
        Caption = #12509#12483#12503#12450#12483#12503#26178#12398#35013#39166#25991#23383#21015#12398#34920#31034
        TabOrder = 2
        object TextAttrShowRadio: TRadioButton
          Left = 16
          Top = 24
          Width = 89
          Height = 17
          Caption = #12377#12409#12390#34920#31034
          TabOrder = 0
        end
        object TextAttrHidePredefinedRadio: TRadioButton
          Left = 128
          Top = 24
          Width = 129
          Height = 17
          Caption = #12518#12540#12470#23450#32681#12398#12415#34920#31034
          TabOrder = 1
        end
        object TextAttrHideRadio: TRadioButton
          Left = 280
          Top = 24
          Width = 73
          Height = 17
          Caption = #34920#31034#12375#12394#12356
          TabOrder = 2
        end
      end
      object GroupBox12: TGroupBox
        Left = 16
        Top = 152
        Width = 377
        Height = 57
        Caption = #26085#20184#12513#12514#20869#12391#12398#35013#39166#25991#23383#21015#12398#34920#31034
        TabOrder = 1
        object DayItemTextAttrShow: TRadioButton
          Left = 16
          Top = 24
          Width = 89
          Height = 17
          Caption = #12377#12409#12390#34920#31034
          TabOrder = 0
        end
        object DayItemTextAttrHidePredefined: TRadioButton
          Left = 128
          Top = 24
          Width = 129
          Height = 17
          Caption = #12518#12540#12470#23450#32681#12398#12415#34920#31034
          TabOrder = 1
        end
        object DayItemTextAttrHide: TRadioButton
          Left = 280
          Top = 24
          Width = 73
          Height = 17
          Caption = #34920#31034#12375#12394#12356
          TabOrder = 2
        end
      end
      object GroupBox13: TGroupBox
        Left = 16
        Top = 16
        Width = 377
        Height = 105
        Caption = #35013#39166#25991#23383#21015#12398#35373#23450
        TabOrder = 0
        object Label19: TLabel
          Left = 32
          Top = 32
          Width = 218
          Height = 12
          Caption = #35013#39166#25991#23383#21015#12398#38283#22987#12539#32066#20102#25991#23383#65288#65297#25991#23383#12398#12415#65289
        end
        object TextAttrTag: TEdit
          Left = 280
          Top = 28
          Width = 33
          Height = 20
          MaxLength = 1
          TabOrder = 0
          Text = '|'
        end
        object AttributeOverrideHyperLinkFont: TCheckBox
          Left = 32
          Top = 64
          Width = 305
          Height = 17
          Caption = #12495#12452#12497#12540#12522#12531#12463#23550#35937#25991#23383#21015#12418#35013#39166#25991#23383#21015#12398#21177#26524#12395#24467#12358
          TabOrder = 1
        end
      end
    end
    object TabSheet8: TTabSheet
      Caption = #35013#39166#25991#23383#21015' (2)'
      ImageIndex = 7
      object GroupBox6: TGroupBox
        Left = 16
        Top = 24
        Width = 377
        Height = 217
        Caption = #12518#12540#12470#23450#32681#12398#35013#39166#25991#23383#21015#12398#20316#25104
        TabOrder = 0
        object Label15: TLabel
          Left = 176
          Top = 52
          Width = 36
          Height = 12
          Caption = #25991#23383#21015
        end
        object Label16: TLabel
          Left = 188
          Top = 84
          Width = 12
          Height = 12
          Caption = #33394
        end
        object Label17: TLabel
          Left = 172
          Top = 114
          Width = 42
          Height = 12
          Caption = #12473#12479#12452#12523
        end
        object Label18: TLabel
          Left = 136
          Top = 176
          Width = 217
          Height = 25
          AutoSize = False
          Caption = #8251#32232#38598#12398#32080#26524#12399#65292#35373#23450#12480#12452#12450#12525#12464#12398' "OK" '#12434#25276#12377#12414#12391#36969#29992#12373#12428#12414#12379#12435
          WordWrap = True
        end
        object TextAttrList: TListBox
          Left = 24
          Top = 32
          Width = 81
          Height = 137
          Style = lbOwnerDrawFixed
          ItemHeight = 16
          TabOrder = 0
          OnDblClick = TextAttrListDblClick
          OnDrawItem = TextAttrListDrawItem
        end
        object TextAttrNameEdit: TEdit
          Left = 224
          Top = 48
          Width = 129
          Height = 20
          TabOrder = 2
        end
        object TextAttrAddBtn: TButton
          Left = 112
          Top = 80
          Width = 49
          Height = 25
          Caption = #8592#36861#21152
          TabOrder = 8
          WordWrap = True
          OnClick = TextAttrAddBtnClick
        end
        object TextAttrColorBox: TColorBox
          Left = 224
          Top = 80
          Width = 129
          Height = 22
          Style = [cbStandardColors, cbExtendedColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 3
        end
        object TextAttrBoldCheck: TCheckBox
          Left = 224
          Top = 112
          Width = 65
          Height = 17
          Caption = #24375#35519
          TabOrder = 4
        end
        object TextAttrItalicCheck: TCheckBox
          Left = 280
          Top = 112
          Width = 57
          Height = 17
          Caption = #26012#20307
          TabOrder = 5
        end
        object TextAttrUnderlineCheck: TCheckBox
          Left = 224
          Top = 136
          Width = 49
          Height = 17
          Caption = #19979#32218
          TabOrder = 6
        end
        object TextAttrStrikeoutCheck: TCheckBox
          Left = 280
          Top = 136
          Width = 81
          Height = 17
          Caption = #21462#12426#28040#12375#32218
          TabOrder = 7
        end
        object TextAttrReadBtn: TButton
          Left = 112
          Top = 40
          Width = 49
          Height = 25
          Caption = #21442#29031#8594
          TabOrder = 1
          OnClick = TextAttrReadBtnClick
        end
        object TextAttrDelBtn: TButton
          Left = 112
          Top = 136
          Width = 49
          Height = 25
          Caption = #21066#38500
          TabOrder = 9
          OnClick = TextAttrDelBtnClick
        end
      end
    end
    object TabSheet6: TTabSheet
      Caption = #12495#12452#12497#12540#12522#12531#12463#34920#31034
      ImageIndex = 5
      object GroupBox2: TGroupBox
        Left = 24
        Top = 111
        Width = 401
        Height = 210
        Caption = #12495#12452#12497#12540#12522#12531#12463
        TabOrder = 1
        object HideHyperlinkString: TCheckBox
          Left = 16
          Top = 89
          Width = 369
          Height = 17
          Caption = #26085#20184#12513#12514#12398'URL'#12434#26085#20184#26528#20869#12363#12425#38560#12377
          TabOrder = 2
        end
        object ShowHyperlinkLabel: TCheckBox
          Left = 311
          Top = 158
          Width = 273
          Height = 17
          Caption = #12495#12452#12497#12540#12522#12531#12463#12398#12521#12505#12523#12434#12475#12523#12398#19979#12395#34920#31034#12377#12427' '
          TabOrder = 6
          Visible = False
        end
        object HyperlinkWithEditMode: TCheckBox
          Left = 16
          Top = 181
          Width = 329
          Height = 17
          Caption = #26085#20184#12522#12531#12463#12391#31227#21205#12375#12383#12392#12365#33258#21205#30340#12395#32232#38598#12514#12540#12489#12395#12377#12427
          TabOrder = 5
        end
        object SelectDayWithoutMovePageIfVisible: TCheckBox
          Left = 16
          Top = 150
          Width = 289
          Height = 17
          Caption = #26085#20184#12434#31227#21205#12377#12427#12392#12365#12395#12391#12365#12427#12384#12369#12506#12540#12472#31227#21205#12434#12375#12394#12356
          TabOrder = 4
        end
        object PopupLinkContents: TCheckBox
          Left = 16
          Top = 27
          Width = 249
          Height = 17
          Caption = #26085#20184#12522#12531#12463#20808#12398#20869#23481#12434#12509#12483#12503#12450#12483#12503#34920#31034#12377#12427
          TabOrder = 0
        end
        object PopupNoHideTimeout: TCheckBox
          Left = 16
          Top = 58
          Width = 313
          Height = 17
          Caption = #12509#12483#12503#12450#12483#12503#34920#31034#12434#26178#38291#32076#36942#12391#12399#28040#12373#12394#12356
          TabOrder = 1
        end
        object ShowHyperlinkContextMenu: TCheckBox
          Left = 16
          Top = 121
          Width = 289
          Height = 17
          Caption = #26085#20184#12513#12514#12398'URL'#12434#12467#12531#12486#12461#12473#12488#12513#12491#12517#12540#12395#34920#31034#12377#12427
          TabOrder = 3
        end
      end
      object GroupBox19: TGroupBox
        Left = 24
        Top = 16
        Width = 401
        Height = 89
        Caption = #26085#20184#12398#26528#12363#12425#12398#12399#12415#20986#12375
        TabOrder = 0
        object PopupCellContents: TCheckBox
          Left = 16
          Top = 24
          Width = 337
          Height = 17
          Caption = #26528#12363#12425#12399#12415#12384#12375#12383#20869#23481#12364#12354#12427#26085#20184#12391#12399#12509#12483#12503#12450#12483#12503#12434#34920#31034#12377#12427
          TabOrder = 0
        end
        object CalendarItemWordWrap: TCheckBox
          Left = 16
          Top = 55
          Width = 361
          Height = 17
          Caption = #26085#20184#26528#12363#12425#27178#12395#12399#12415#12384#12377#20998#12399#25240#12426#36820#12375#12390#34920#31034#12377#12427
          TabOrder = 1
        end
      end
    end
    object TabSheet7: TTabSheet
      Caption = #12461#12540#25805#20316
      ImageIndex = 6
      object GroupBox5: TGroupBox
        Left = 16
        Top = 136
        Width = 377
        Height = 73
        Caption = #12471#12519#12540#12488#12459#12483#12488#12398#35373#23450
        TabOrder = 1
        object EnableDialogCloseShortcut: TCheckBox
          Left = 16
          Top = 28
          Width = 337
          Height = 33
          Caption = #26908#32034#12539'TODO '#12394#12393#12398#12480#12452#12450#12525#12464#34920#31034#12398#12471#12519#12540#12488#12459#12483#12488#12364#12381#12398#12480#12452#12450#12525#12464#19978#12391#25276#12373#12428#12383#22580#21512#65292#23550#35937#12398#12480#12452#12450#12525#12464#12434#38281#12376#12427
          TabOrder = 0
          WordWrap = True
        end
      end
      object GroupBox14: TGroupBox
        Left = 16
        Top = 232
        Width = 377
        Height = 65
        Caption = 'IME'#12398#35373#23450
        TabOrder = 2
        object StartupImeModeOn: TCheckBox
          Left = 16
          Top = 28
          Width = 345
          Height = 17
          Caption = #36215#21205#26178#12395'IME'#12434#33258#21205#30340#12395#26377#21177#12395#12377#12427
          TabOrder = 0
        end
      end
      object GroupBox16: TGroupBox
        Left = 16
        Top = 16
        Width = 377
        Height = 97
        Caption = #12459#12524#12531#12480#12540#12398#25805#20316
        TabOrder = 0
        object CursorCanMoveAnotherRow: TCheckBox
          Left = 16
          Top = 28
          Width = 345
          Height = 17
          Caption = #36913#26411#12392#27425#12398#36913#12398#38283#22987#26085#12434#24038#21491#12461#12540#12391#31227#21205#12377#12427
          TabOrder = 0
        end
        object AutoExtendRowsCheck: TCheckBox
          Left = 16
          Top = 56
          Width = 337
          Height = 25
          Caption = #19978#19979#31471#12391#12399#12479#12502#12434#20999#12426#26367#12360#12378#12395#19978#19979#12395#12381#12398#12414#12414#12473#12463#12525#12540#12523#12377#12427
          TabOrder = 1
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = #12484#12540#12523#12496#12540
      ImageIndex = 2
      object GroupBox8: TGroupBox
        Left = 16
        Top = 16
        Width = 377
        Height = 129
        Caption = #26908#32034#12484#12540#12523#12496#12540#12398#35373#23450
        TabOrder = 0
        object MarkingCaseSensitive: TCheckBox
          Left = 16
          Top = 24
          Width = 329
          Height = 17
          Caption = #26908#32034#26178#12395#22823#25991#23383#12392#23567#25991#23383#12434#21306#21029#12377#12427
          TabOrder = 0
        end
        object AutoMarkingWhenFind: TCheckBox
          Left = 16
          Top = 56
          Width = 305
          Height = 17
          Caption = #12300#27425#12408#31227#21205#12301#12364#36984#12400#12428#12383#12392#12365#12395#33258#21205#12391#12510#12540#12461#12531#12464#12377#12427
          TabOrder = 1
        end
        object MarkingAutoComplete: TCheckBox
          Left = 16
          Top = 88
          Width = 289
          Height = 17
          Caption = #12458#12540#12488#12467#12531#12503#12522#12540#12488#12434' ON '#12395#12377#12427
          TabOrder = 2
        end
      end
      object GroupBox17: TGroupBox
        Left = 16
        Top = 168
        Width = 377
        Height = 65
        Caption = 'URL'#12484#12540#12523#12496#12540#12398#35373#23450
        TabOrder = 1
        object RegisterFreeMemoURLToToolbar: TCheckBox
          Left = 16
          Top = 28
          Width = 273
          Height = 17
          Caption = #12501#12522#12540#12513#12514#12398'URL'#12434#12522#12473#12488#38917#30446#12392#12375#12390#30331#37682#12377#12427
          TabOrder = 0
        end
      end
    end
    object TabSheet10: TTabSheet
      Caption = #12459#12524#12531#12480#12540#34920#31034
      ImageIndex = 9
      object GroupBox4: TGroupBox
        Left = 16
        Top = 116
        Width = 377
        Height = 201
        Caption = 'ToDo '#12522#12473#12488' '#34920#31034
        TabOrder = 1
        object Label13: TLabel
          Left = 110
          Top = 144
          Width = 124
          Height = 12
          Alignment = taRightJustify
          Caption = 'TODO'#12395#20184#21152#12377#12427#25991#23383#21015
        end
        object Label14: TLabel
          Left = 64
          Top = 172
          Width = 168
          Height = 12
          Alignment = taRightJustify
          Caption = #32066#20102#12375#12383'TODO'#12395#20184#21152#12377#12427#25991#23383#21015
        end
        object ShowTodoItems: TCheckBox
          Left = 16
          Top = 24
          Width = 353
          Height = 17
          Caption = 'TODO '#12398#20869#23481#12434#65292#23550#24540#12375#12383#26085#20184#12398#20104#23450#27396#12395#34920#31034#12377#12427
          TabOrder = 0
        end
        object ShowTodoLiteral: TCheckBox
          Left = 32
          Top = 112
          Width = 337
          Height = 17
          Caption = #12459#12524#12531#12480#12540#19978#12395#34920#31034#12377#12427#12392#12365#20808#38957#12395#25991#23383#21015#12434#20184#21152#12377#12427
          TabOrder = 3
        end
        object TodoHeadLiteral: TEdit
          Left = 240
          Top = 140
          Width = 73
          Height = 20
          MaxLength = 10
          TabOrder = 4
        end
        object DoneHeadLiteral: TEdit
          Left = 240
          Top = 168
          Width = 73
          Height = 20
          TabOrder = 5
        end
        object HideDaystringTodoOnCalendar: TCheckBox
          Left = 32
          Top = 82
          Width = 329
          Height = 17
          Caption = #26085#20184#27396#12395#34920#31034#12373#12428#12427'TODO'#25991#23383#21015#12363#12425#12399#26085#20184#12434#38500#21435#12377#12427
          TabOrder = 2
        end
        object HideCompletedTodoOnCalendar: TCheckBox
          Left = 32
          Top = 52
          Width = 257
          Height = 17
          Caption = #32066#20102#12375#12383'TODO'#12399#12459#12524#12531#12480#12540#19978#12395#12399#34920#31034#12375#12394#12356
          TabOrder = 1
        end
      end
      object GroupBox7: TGroupBox
        Left = 16
        Top = 12
        Width = 377
        Height = 85
        Caption = #12459#12524#12531#12480#12540#34920#31034
        TabOrder = 0
        object ZoomRateForEachPage: TCheckBox
          Left = 16
          Top = 55
          Width = 297
          Height = 17
          Caption = #34920#31034#12469#12452#12474#65288#25313#22823#29575#65289#12434#12506#12540#12472#65288#65297#12534#26376#65289#12372#12392#12395#21306#21029#12377#12427
          TabOrder = 1
        end
        object StartFromMonday: TCheckBox
          Left = 16
          Top = 24
          Width = 233
          Height = 17
          Caption = #12459#12524#12531#12480#12540#12434#26376#26332#22987#12414#12426#12395#12377#12427
          TabOrder = 0
        end
      end
    end
    object TabSheet4: TTabSheet
      Caption = #33258#21205#20445#23384
      ImageIndex = 3
      object GroupBox9: TGroupBox
        Left = 16
        Top = 16
        Width = 409
        Height = 257
        Caption = #12501#12449#12452#12523#12539#35373#23450#12398#20445#23384#12458#12503#12471#12519#12531
        TabOrder = 0
        object Label26: TLabel
          Left = 40
          Top = 216
          Width = 71
          Height = 12
          Caption = #20445#23384#12375#12394#12356#26178' '
        end
        object Label27: TLabel
          Left = 176
          Top = 216
          Width = 55
          Height = 12
          Caption = #12534#26376#21069#12363#12425
        end
        object Label28: TLabel
          Left = 292
          Top = 216
          Width = 84
          Height = 12
          Caption = #12534#26376#20808#12414#12391#12434#38283#12367
        end
        object AutoSave: TCheckBox
          Left = 16
          Top = 24
          Width = 289
          Height = 17
          Caption = #12503#12525#12464#12521#12512#32066#20102#26178#65292#12501#12449#12452#12523#12434#33258#21205#30340#12395#20445#23384#12377#12427
          TabOrder = 0
        end
        object WindowPosSave: TCheckBox
          Left = 16
          Top = 56
          Width = 329
          Height = 17
          Caption = #12503#12525#12464#12521#12512#32066#20102#26178#12398#12454#12451#12531#12489#12454#12524#12452#12450#12454#12488#12434#20445#23384#12377#12427
          TabOrder = 1
        end
        object SaveZoomRate: TCheckBox
          Left = 16
          Top = 88
          Width = 313
          Height = 17
          Caption = #12503#12525#12464#12521#12512#32066#20102#26178#12398#34920#31034#12469#12452#12474#65288#25313#22823#29575#65289#12434#20445#23384#12377#12427
          TabOrder = 2
        end
        object ToolbarSave: TCheckBox
          Left = 16
          Top = 120
          Width = 297
          Height = 17
          Caption = #12503#12525#12464#12521#12512#32066#20102#26178#12398#12484#12540#12523#12496#12540#12398#35373#23450#12434#20445#23384#12377#12427
          TabOrder = 3
        end
        object MonthTabSave: TCheckBox
          Left = 16
          Top = 152
          Width = 313
          Height = 17
          Caption = #12503#12525#12464#12521#12512#32066#20102#26178#12395#38283#12356#12390#12356#12427#12479#12502#12398#29366#24907#12434#20445#23384#12377#12427
          TabOrder = 4
        end
        object MonthTabAutoClose: TCheckBox
          Left = 40
          Top = 184
          Width = 273
          Height = 17
          Caption = #65298#12534#26376#20197#19978#21069#12398#12479#12502#12399#24489#20803#12375#12394#12356
          TabOrder = 5
        end
        object DefaultMonthTabBeforeBox: TEdit
          Left = 128
          Top = 211
          Width = 25
          Height = 20
          TabOrder = 6
          Text = '1'
        end
        object DefaultMonthTabBeforeUpDown: TUpDown
          Left = 153
          Top = 211
          Width = 16
          Height = 20
          Associate = DefaultMonthTabBeforeBox
          Max = 12
          Position = 1
          TabOrder = 7
        end
        object DefaultMonthTabAfterBox: TEdit
          Left = 245
          Top = 211
          Width = 25
          Height = 20
          TabOrder = 8
          Text = '3'
        end
        object DefaultMonthTabAfterUpDown: TUpDown
          Left = 270
          Top = 211
          Width = 16
          Height = 20
          Associate = DefaultMonthTabAfterBox
          Max = 12
          Position = 3
          TabOrder = 9
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = #12471#12473#12486#12512#35373#23450
      ImageIndex = 1
      object GroupBox10: TGroupBox
        Left = 16
        Top = 24
        Width = 201
        Height = 121
        Caption = #25313#24373#23376#12398#35373#23450
        TabOrder = 0
        object RegistBtn: TButton
          Left = 16
          Top = 24
          Width = 169
          Height = 30
          Caption = '.cal '#25313#24373#23376#12398#38306#36899#20184#12369#12434#34892#12358
          TabOrder = 0
          OnClick = RegistBtnClick
        end
        object UnregistBtn: TButton
          Left = 16
          Top = 69
          Width = 169
          Height = 30
          Caption = #38306#36899#20184#12369#12434#35299#38500#12377#12427
          TabOrder = 1
          OnClick = UnregistBtnClick
        end
      end
      object GroupBox15: TGroupBox
        Left = 256
        Top = 24
        Width = 161
        Height = 121
        Caption = #12501#12449#12452#12523#12398#23653#27508
        TabOrder = 1
        object Label22: TLabel
          Left = 16
          Top = 32
          Width = 70
          Height = 12
          Caption = #35352#25014#12377#12427#20491#25968
        end
        object FileHistorySizeBox: TEdit
          Left = 96
          Top = 28
          Width = 33
          Height = 20
          TabOrder = 0
          Text = '0'
        end
        object FileHistorySizeUpDown: TUpDown
          Left = 129
          Top = 28
          Width = 16
          Height = 20
          Associate = FileHistorySizeBox
          Max = 10
          TabOrder = 1
        end
        object FileHistoryClearBtn: TButton
          Left = 24
          Top = 60
          Width = 113
          Height = 30
          Caption = #23653#27508#12434#12463#12522#12450#12377#12427
          TabOrder = 2
          OnClick = FileHistoryClearBtnClick
        end
      end
      object GroupBox18: TGroupBox
        Left = 16
        Top = 168
        Width = 401
        Height = 81
        Caption = #12479#12473#12463#12488#12524#12452
        TabOrder = 2
        object TaskTrayCheck: TCheckBox
          Left = 32
          Top = 40
          Width = 345
          Height = 17
          Caption = #12479#12473#12463#12488#12524#12452#12434#20351#12358' '#65288#26368#23567#21270#12398#12363#12431#12426#12395#12454#12451#12531#12489#12454#12434#38560#12377#65289
          TabOrder = 0
        end
      end
    end
  end
  object FontDialog1: TFontDialog
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
    Font.Style = []
    Left = 144
    Top = 392
  end
end
