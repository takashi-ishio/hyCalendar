object frmFindDialog: TfrmFindDialog
  Left = 209
  Top = 160
  BorderIcons = [biSystemMenu]
  Caption = #26908#32034
  ClientHeight = 369
  ClientWidth = 497
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 505
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object GroupList: TListView
    Left = 0
    Top = 193
    Width = 497
    Height = 176
    Align = alClient
    Columns = <
      item
        Caption = #26085#20184
        Width = 80
      end
      item
        Caption = #31278#21029
        Width = 80
      end
      item
        Caption = #34892#30058#21495
      end
      item
        AutoSize = True
        Caption = #20104#23450#25991#23383#21015
      end>
    GridLines = True
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu1
    SortType = stBoth
    TabOrder = 1
    ViewStyle = vsReport
    OnColumnClick = GroupListColumnClick
    OnCompare = GroupListCompare
    OnDblClick = GroupListDblClick
    OnSelectItem = GroupListSelectItem
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 497
    Height = 193
    Align = alTop
    TabOrder = 0
    DesignSize = (
      497
      193)
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 60
      Height = 12
      Caption = #26908#32034#25991#23383#21015
    end
    object Label2: TLabel
      Left = 24
      Top = 60
      Width = 48
      Height = 12
      Caption = #26908#32034#31684#22258
    end
    object Label3: TLabel
      Left = 216
      Top = 60
      Width = 12
      Height = 12
      Caption = #65374
    end
    object Label4: TLabel
      Left = 24
      Top = 98
      Width = 48
      Height = 12
      Caption = #26908#32034#23550#35937
    end
    object Label6: TLabel
      Left = 360
      Top = 56
      Width = 129
      Height = 33
      AutoSize = False
      Caption = #8251#25351#23450#12375#12394#12356#22580#21512#65292#12288#12288#12288#26085#20184#12513#12514#12364#23384#22312#12377#12427#26399#38291
      WordWrap = True
    end
    object Label5: TLabel
      Left = 271
      Top = 156
      Width = 11
      Height = 12
      Anchors = [akTop, akRight]
      Caption = #12391
    end
    object FindBox: TComboBox
      Left = 88
      Top = 20
      Width = 239
      Height = 20
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 12
      Sorted = True
      TabOrder = 0
      OnKeyDown = FindBoxKeyDown
    end
    object FindMethodBox: TComboBox
      Left = 340
      Top = 20
      Width = 48
      Height = 20
      Style = csDropDownList
      Anchors = [akTop, akRight]
      ItemHeight = 12
      ItemIndex = 0
      TabOrder = 1
      Text = 'AND'
      Items.Strings = (
        'AND'
        'OR')
    end
    object SearchBtn: TBitBtn
      Left = 403
      Top = 14
      Width = 74
      Height = 31
      Anchors = [akTop, akRight]
      Caption = #26908#32034
      Default = True
      TabOrder = 12
      OnClick = SearchBtnClick
    end
    object StartDate: TDateTimePicker
      Left = 120
      Top = 56
      Width = 89
      Height = 22
      Date = 38355.000000000000000000
      Time = 38355.000000000000000000
      MaxDate = 65745.000000000000000000
      MinDate = 29221.000000000000000000
      TabOrder = 3
      OnChange = StartDateChange
    end
    object EndDate: TDateTimePicker
      Left = 264
      Top = 56
      Width = 89
      Height = 22
      Date = 38355.000000000000000000
      Time = 38355.000000000000000000
      MaxDate = 65745.000000000000000000
      MinDate = 29221.000000000000000000
      TabOrder = 5
      OnChange = EndDateChange
    end
    object chkSearchRangeItem: TCheckBox
      Left = 176
      Top = 96
      Width = 89
      Height = 17
      Caption = #26399#38291#20104#23450
      Checked = True
      State = cbChecked
      TabOrder = 7
    end
    object chkSearchDayItem: TCheckBox
      Left = 96
      Top = 96
      Width = 81
      Height = 17
      Caption = #26085#20184#12513#12514
      Checked = True
      State = cbChecked
      TabOrder = 6
    end
    object chkSearchSeriesItem: TCheckBox
      Left = 264
      Top = 96
      Width = 89
      Height = 17
      Caption = #21608#26399#20104#23450
      Checked = True
      State = cbChecked
      TabOrder = 8
    end
    object btnExport: TButton
      Left = 287
      Top = 144
      Width = 193
      Height = 33
      Anchors = [akTop, akRight]
      Caption = #26908#32034#32080#26524#12434#12463#12522#12483#12503#12508#12540#12489#12408#12467#12500#12540
      TabOrder = 14
      WordWrap = True
      OnClick = btnExportClick
    end
    object cboExportStyle: TComboBox
      Left = 183
      Top = 152
      Width = 81
      Height = 20
      Style = csDropDownList
      Anchors = [akTop, akRight]
      ItemHeight = 12
      ItemIndex = 0
      TabOrder = 13
      Text = #12479#12502#21306#20999#12426
      Items.Strings = (
        #12479#12502#21306#20999#12426
        'CSV'#24418#24335)
    end
    object chkSearchReferenceFile: TCheckBox
      Left = 176
      Top = 120
      Width = 169
      Height = 17
      Caption = #21442#29031#12501#12449#12452#12523#12418#26908#32034#12377#12427
      Checked = True
      State = cbChecked
      TabOrder = 11
    end
    object chkSearchTodo: TCheckBox
      Left = 352
      Top = 96
      Width = 105
      Height = 17
      Caption = #26085#20184#20837#12426'TODO'
      Checked = True
      State = cbChecked
      TabOrder = 9
    end
    object EndDateEnable: TCheckBox
      Left = 240
      Top = 56
      Width = 25
      Height = 19
      TabOrder = 4
    end
    object StartDateEnable: TCheckBox
      Left = 96
      Top = 56
      Width = 25
      Height = 19
      TabOrder = 2
    end
    object chkSearchDayName: TCheckBox
      Left = 96
      Top = 120
      Width = 57
      Height = 17
      Caption = #31069#26085#21517
      Checked = True
      State = cbChecked
      TabOrder = 10
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 16
    Top = 128
    object mnuCopyToClipboardWithTab: TMenuItem
      Caption = #12479#12502#21306#20999#12426#12391#12522#12473#12488#12434#12467#12500#12540'(&T)'
      OnClick = mnuCopyToClipboardWithTabClick
    end
    object mnuCopyToClipboardWithCSV: TMenuItem
      Caption = 'CSV'#24418#24335#12391#12522#12473#12488#12434#12467#12500#12540'(&C)'
      OnClick = mnuCopyToClipboardWithCSVClick
    end
  end
end
