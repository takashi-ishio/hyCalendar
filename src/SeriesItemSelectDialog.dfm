object frmSeriesItemSelectDialog: TfrmSeriesItemSelectDialog
  Left = 369
  Top = 202
  BorderIcons = [biSystemMenu]
  Caption = #21608#26399#20104#23450#12398#36984#25246
  ClientHeight = 222
  ClientWidth = 240
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
  object SeriesList: TListBox
    Left = 0
    Top = 25
    Width = 240
    Height = 197
    Align = alClient
    ItemHeight = 12
    TabOrder = 0
    OnClick = SeriesListClick
    OnDblClick = SeriesListDblClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 240
    Height = 25
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 1
    DesignSize = (
      240
      25)
    object SeriesEdit: TEdit
      Left = 0
      Top = 1
      Width = 188
      Height = 20
      Anchors = [akLeft, akTop, akRight, akBottom]
      ReadOnly = True
      TabOrder = 0
    end
    object SeriesSelectBtn: TButton
      Left = 190
      Top = 0
      Width = 49
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #36984#25246
      Default = True
      TabOrder = 1
      OnClick = SeriesSelectBtnClick
    end
  end
end
