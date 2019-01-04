object frmImportDialog: TfrmImportDialog
  Left = 249
  Top = 155
  BorderStyle = bsDialog
  Caption = #26085#20184#12513#12514#12398#12452#12531#12509#12540#12488#21177#26524#12398#30906#35469
  ClientHeight = 399
  ClientWidth = 483
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
    Top = 272
    Width = 449
    Height = 105
    Caption = #12452#12531#12509#12540#12488#23550#35937#12398#20877#36984#25246
    TabOrder = 3
    object Label1: TLabel
      Left = 16
      Top = 36
      Width = 53
      Height = 12
      Caption = #12501#12449#12452#12523#21517
    end
    object FileNameBrowseBtn: TButton
      Left = 392
      Top = 32
      Width = 41
      Height = 22
      Caption = #21442#29031
      TabOrder = 1
      OnClick = FileNameBrowseBtnClick
    end
    object FileNameEdit: TEdit
      Left = 80
      Top = 32
      Width = 311
      Height = 20
      TabOrder = 0
      Text = 'FileNameEdit'
    end
    object ReloadBtn: TButton
      Left = 312
      Top = 64
      Width = 121
      Height = 25
      Caption = #20877#35501#12415#36796#12415
      TabOrder = 2
      OnClick = ReloadBtnClick
    end
  end
  object ApplyBtn: TButton
    Left = 24
    Top = 16
    Width = 201
    Height = 33
    Caption = #20197#19979#12398#32080#26524#12434#36969#29992#12377#12427
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = ApplyBtnClick
  end
  object CancelBtn: TButton
    Left = 256
    Top = 16
    Width = 201
    Height = 33
    Cancel = True
    Caption = #12461#12515#12531#12475#12523
    ModalResult = 2
    TabOrder = 1
    OnClick = CancelBtnClick
  end
  object GroupBox2: TGroupBox
    Left = 16
    Top = 72
    Width = 449
    Height = 185
    Caption = #35501#12415#36796#12415#32080#26524
    TabOrder = 2
    object MessageListBox: TListBox
      Left = 24
      Top = 24
      Width = 401
      Height = 137
      ItemHeight = 12
      TabOrder = 0
    end
  end
  object FileOpenDialog: TOpenDialog
    DefaultExt = '*.txt'
    Filter = #12486#12461#12473#12488#12501#12449#12452#12523'|*.txt|'#12377#12409#12390#12398#12501#12449#12452#12523'|*.*'
    Top = 368
  end
end
