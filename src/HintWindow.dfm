object frmHintWindow: TfrmHintWindow
  Left = 193
  Top = 115
  BorderStyle = bsNone
  Caption = 'frmHintWindow'
  ClientHeight = 185
  ClientWidth = 320
  Color = clGradientInactiveCaption
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDeactivate = FormDeactivate
  OnKeyDown = FormKeyDown
  OnPaint = FormPaint
  DesignSize = (
    320
    185)
  PixelsPerInch = 96
  TextHeight = 12
  object HintString: TMemo
    Left = 1
    Top = 8
    Width = 318
    Height = 176
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clCream
    Lines.Strings = (
      'HintString')
    ReadOnly = True
    TabOrder = 1
  end
  object CloseButton: TButton
    Left = 275
    Top = 2
    Width = 42
    Height = 25
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = #38281#12376#12427
    TabOrder = 0
    Visible = False
    OnClick = CloseButtonClick
  end
  object Timer1: TTimer
    Interval = 0
    OnTimer = Timer1Timer
    Left = 256
    Top = 48
  end
end
