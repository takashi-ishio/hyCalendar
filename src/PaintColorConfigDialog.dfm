object frmPaintColorConfig: TfrmPaintColorConfig
  Left = 257
  Top = 200
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #33394#12398#27083#25104
  ClientHeight = 213
  ClientWidth = 368
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
    Left = 16
    Top = 16
    Width = 103
    Height = 12
    Caption = #26368#24460#12395#36984#25246#12373#12428#12383#33394
  end
  object Label2: TLabel
    Left = 24
    Top = 132
    Width = 36
    Height = 12
    Caption = #32972#26223#33394
  end
  object Label3: TLabel
    Left = 24
    Top = 164
    Width = 36
    Height = 12
    Caption = #26085#20184#33394
  end
  object SelectedColorPaintBox: TPaintBox
    Tag = -1
    Left = 58
    Top = 42
    Width = 25
    Height = 22
    OnClick = PaintColorBoxClick
    OnPaint = PaintColorBoxPaint
  end
  object PaintColorBox1: TPaintBox
    Left = 123
    Top = 42
    Width = 25
    Height = 22
    OnPaint = PaintColorBoxPaint
  end
  object PaintColorBox2: TPaintBox
    Tag = 1
    Left = 148
    Top = 42
    Width = 25
    Height = 22
  end
  object PaintColorBox3: TPaintBox
    Tag = 2
    Left = 173
    Top = 42
    Width = 25
    Height = 22
  end
  object PaintColorBox4: TPaintBox
    Tag = 3
    Left = 198
    Top = 42
    Width = 25
    Height = 22
  end
  object PaintColorBox5: TPaintBox
    Tag = 4
    Left = 223
    Top = 42
    Width = 25
    Height = 22
  end
  object PaintColorBox6: TPaintBox
    Tag = 5
    Left = 248
    Top = 42
    Width = 25
    Height = 22
  end
  object Label4: TLabel
    Left = 144
    Top = 16
    Width = 71
    Height = 12
    Caption = #12459#12521#12540#12497#12524#12483#12488
  end
  object BackColorBox: TColorBox
    Left = 72
    Top = 128
    Width = 113
    Height = 22
    Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
    ItemHeight = 16
    TabOrder = 0
  end
  object HeadColorBox: TColorBox
    Left = 72
    Top = 160
    Width = 113
    Height = 22
    Style = [cbStandardColors, cbExtendedColors, cbCustomColor, cbPrettyNames]
    ItemHeight = 16
    TabOrder = 1
  end
  object ReadBtn: TBitBtn
    Left = 64
    Top = 80
    Width = 65
    Height = 25
    Caption = #35501#20986
    TabOrder = 2
    OnClick = ReadBtnClick
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000120B0000120B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333303333
      333333333337F33333333333333033333333333333373F333333333333090333
      33333333337F7F33333333333309033333333333337373F33333333330999033
      3333333337F337F33333333330999033333333333733373F3333333309999903
      333333337F33337F33333333099999033333333373333373F333333099999990
      33333337FFFF3FF7F33333300009000033333337777F77773333333333090333
      33333333337F7F33333333333309033333333333337F7F333333333333090333
      33333333337F7F33333333333309033333333333337F7F333333333333090333
      33333333337F7F33333333333300033333333333337773333333}
    NumGlyphs = 2
  end
  object WriteBtn: TBitBtn
    Left = 144
    Top = 80
    Width = 65
    Height = 25
    Caption = #26360#36796
    TabOrder = 3
    OnClick = WriteBtnClick
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000120B0000120B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333000333
      3333333333777F33333333333309033333333333337F7F333333333333090333
      33333333337F7F33333333333309033333333333337F7F333333333333090333
      33333333337F7F33333333333309033333333333FF7F7FFFF333333000090000
      3333333777737777F333333099999990333333373F3333373333333309999903
      333333337F33337F33333333099999033333333373F333733333333330999033
      3333333337F337F3333333333099903333333333373F37333333333333090333
      33333333337F7F33333333333309033333333333337373333333333333303333
      333333333337F333333333333330333333333333333733333333}
    NumGlyphs = 2
  end
  object BackColorDefault: TCheckBox
    Left = 200
    Top = 128
    Width = 145
    Height = 25
    Caption = #12487#12501#12457#12523#12488#32972#26223#33394#12434#20351#12358
    TabOrder = 4
  end
  object HeadColorDefault: TCheckBox
    Left = 200
    Top = 184
    Width = 145
    Height = 25
    Caption = #12487#12501#12457#12523#12488#32972#26223#33394#12434#20351#12358
    TabOrder = 5
    OnClick = HeadColorDefaultClick
  end
  object SameHeadColor: TCheckBox
    Left = 200
    Top = 164
    Width = 153
    Height = 17
    Caption = #32972#26223#33394#12395#21512#12431#12379#12427
    TabOrder = 6
    OnClick = SameHeadColorClick
  end
end
