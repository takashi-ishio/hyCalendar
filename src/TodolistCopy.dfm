object frmTodolistCopyDialog: TfrmTodolistCopyDialog
  Left = 337
  Top = 226
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'TODO'#12522#12473#12488#12434#12463#12522#12483#12503#12508#12540#12489#12408#12467#12500#12540#12377#12427
  ClientHeight = 152
  ClientWidth = 378
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object Label1: TLabel
    Left = 40
    Top = 88
    Width = 116
    Height = 12
    Caption = #26410#32066#20102#12450#12452#12486#12512#12398#20808#38957
  end
  object Label2: TLabel
    Left = 40
    Top = 116
    Width = 104
    Height = 12
    Caption = #32066#20102#12450#12452#12486#12512#12398#20808#38957
  end
  object CopyAllItemCheck: TCheckBox
    Left = 16
    Top = 24
    Width = 233
    Height = 17
    Caption = #32066#20102#28168#12415#12450#12452#12486#12512#12418#12377#12409#12390#12467#12500#12540#12377#12427
    TabOrder = 0
  end
  object CopyListToClipboardBtn: TBitBtn
    Left = 259
    Top = 40
    Width = 102
    Height = 28
    Caption = #12467#12500#12540#12377#12427
    Default = True
    ModalResult = 1
    TabOrder = 1
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000130B0000130B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF003333330B7FFF
      FFB0333333777F3333773333330B7FFFFFB0333333777F3333773333330B7FFF
      FFB0333333777F3333773333330B7FFFFFB03FFFFF777FFFFF77000000000077
      007077777777777777770FFFFFFFF00077B07F33333337FFFF770FFFFFFFF000
      7BB07F3FF3FFF77FF7770F00F000F00090077F77377737777F770FFFFFFFF039
      99337F3FFFF3F7F777FF0F0000F0F09999937F7777373777777F0FFFFFFFF999
      99997F3FF3FFF77777770F00F000003999337F773777773777F30FFFF0FF0339
      99337F3FF7F3733777F30F08F0F0337999337F7737F73F7777330FFFF0039999
      93337FFFF7737777733300000033333333337777773333333333}
    NumGlyphs = 2
  end
  object BitBtn1: TBitBtn
    Left = 259
    Top = 80
    Width = 102
    Height = 28
    Cancel = True
    Caption = #12461#12515#12531#12475#12523
    ModalResult = 2
    TabOrder = 2
    NumGlyphs = 2
  end
  object TodoItemHeadText: TEdit
    Left = 168
    Top = 84
    Width = 49
    Height = 20
    TabOrder = 3
    Text = '[ ]'
  end
  object AddHeadTextCheck: TCheckBox
    Left = 16
    Top = 56
    Width = 233
    Height = 17
    Caption = #21508#12450#12452#12486#12512#12398#20808#38957#12395#25991#23383#21015#12434#20184#21152#12377#12427
    TabOrder = 4
  end
  object TodoCompletedItemHeadText: TEdit
    Left = 168
    Top = 112
    Width = 49
    Height = 20
    TabOrder = 5
    Text = '[x]'
  end
end
