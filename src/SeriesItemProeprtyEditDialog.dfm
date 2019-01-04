object frmSeriesItemPropertyEditDialog: TfrmSeriesItemPropertyEditDialog
  Left = 193
  Top = 115
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #21608#26399#20104#23450#12398#24773#22577
  ClientHeight = 328
  ClientWidth = 400
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
  object GroupBox1: TGroupBox
    Left = 16
    Top = 16
    Width = 369
    Height = 249
    Caption = #21608#26399#20104#23450#12398#24773#22577
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 32
      Width = 24
      Height = 12
      Caption = #21517#21069
    end
    object Label2: TLabel
      Left = 67
      Top = 54
      Width = 265
      Height = 24
      Caption = #29305#21029#12394#21517#21069#65306' '#21517#21069#12398#20013#12398' "%d" '#12399#29694#22312#12398#26085#12354#12427#12356#12399#22522#28310#26085#12363#12425#12398#26085#25968#12395#22793#25563#12373#12428#12414#12377
      WordWrap = True
    end
    object ItemIsHidden: TCheckBox
      Left = 55
      Top = 100
      Width = 201
      Height = 17
      Caption = #12371#12398#20104#23450#12434#38750#34920#31034#12395#12377#12427
      TabOrder = 1
    end
    object SeriesItemNameBox: TEdit
      Left = 48
      Top = 28
      Width = 265
      Height = 20
      TabOrder = 0
    end
    object ItemIsShownAsDayName: TCheckBox
      Left = 55
      Top = 128
      Width = 305
      Height = 17
      Caption = #12371#12398#20104#23450#12399#26085#20184#12398#21517#21069#12392#12375#12390#34920#31034#12377#12427#65288#20027#12395#35352#24565#26085#29992#65289
      TabOrder = 2
    end
    object ItemIsHoliday: TCheckBox
      Left = 55
      Top = 156
      Width = 265
      Height = 17
      Caption = #12371#12398#20104#23450#12399#12518#12540#12470#12540#23450#32681#12398#31069#26085#12392#12375#12390#25201#12431#12428#12427
      TabOrder = 3
    end
    object FontColorBox: TColorBox
      Left = 190
      Top = 182
      Width = 153
      Height = 22
      Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames]
      ItemHeight = 16
      TabOrder = 5
    end
    object UseColorBox: TCheckBox
      Left = 55
      Top = 184
      Width = 121
      Height = 17
      Caption = #34920#31034#33394#12434#22793#26356#12377#12427
      TabOrder = 4
    end
    object SpecifyBaseDateCheck: TCheckBox
      Left = 55
      Top = 212
      Width = 185
      Height = 17
      Caption = #26085#25968#12398#22522#28310#12434#29694#22312#26085#20197#22806#12395#35373#23450
      TabOrder = 6
    end
    object BaseDatePicker: TDateTimePicker
      Left = 246
      Top = 210
      Width = 97
      Height = 20
      Date = 38906.000000000000000000
      Time = 38906.000000000000000000
      TabOrder = 7
    end
  end
  object OKBtn: TButton
    Left = 198
    Top = 279
    Width = 81
    Height = 33
    Caption = #26356#26032
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 295
    Top = 279
    Width = 81
    Height = 33
    Cancel = True
    Caption = #12461#12515#12531#12475#12523
    ModalResult = 2
    TabOrder = 2
  end
end
