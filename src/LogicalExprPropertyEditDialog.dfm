object frmLogicalExprPropertyEditDialog: TfrmLogicalExprPropertyEditDialog
  Left = 322
  Top = 277
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #26465#20214#24335#12398#35373#23450
  ClientHeight = 126
  ClientWidth = 378
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
  object Label11: TLabel
    Left = 16
    Top = 28
    Width = 72
    Height = 12
    Caption = #26465#20214#24335#12398#31278#21029
  end
  object CancelBtn: TButton
    Left = 281
    Top = 87
    Width = 72
    Height = 30
    Cancel = True
    Caption = #12461#12515#12531#12475#12523
    ModalResult = 2
    TabOrder = 3
  end
  object OKBtn: TButton
    Left = 192
    Top = 87
    Width = 74
    Height = 30
    Caption = #26356#26032
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object LogicalExprBox: TComboBox
    Left = 97
    Top = 24
    Width = 265
    Height = 20
    Style = csDropDownList
    ItemHeight = 12
    ItemIndex = 0
    TabOrder = 0
    Text = #26465#20214#12434#12377#12409#12390#28288#12383#12377' (AND)'
    Items.Strings = (
      #26465#20214#12434#12377#12409#12390#28288#12383#12377' (AND)'
      #26465#20214#12398#12356#12378#12428#12363#12395#35442#24403#12377#12427' (OR)'
      #26465#20214#12398#12377#12409#12390#12434#28288#12383#12377#12418#12398#12399#38500#12367' (NAND)'
      #26465#20214#12398#12356#12378#12428#12363#12395#35442#24403#12377#12427#12418#12398#12399#38500#12367' (NOR)')
  end
  object ConditionDisabled: TCheckBox
    Left = 104
    Top = 56
    Width = 249
    Height = 17
    Caption = #26465#20214#12434#28961#21177#12395#12377#12427
    TabOrder = 1
  end
end
