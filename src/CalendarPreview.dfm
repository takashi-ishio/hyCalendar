inherited frmCalendarPrintPreview: TfrmCalendarPrintPreview
  Left = 261
  Top = 207
  Caption = 'frmCalendarPrintPreview'
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  ExplicitWidth = 662
  ExplicitHeight = 432
  PixelsPerInch = 96
  TextHeight = 12
  inherited IconBar: TToolBar
    inherited PrinterSetBtn: TSpeedButton
      Visible = True
    end
  end
  object plPrev1: TplPrev
    LeftMargin = 41
    TopMargin = 41
    RightMargin = 41
    BottomMargin = 42
    HeaderMargin = 0
    FooterMargin = 0
    PageCount = 1
    plSetPrinter = plSetPrinter1
    BtnOptions = [boPrintBtn, boPrinterSetBtn, boFirstPageBtn, boPriorPageBtn, boNextPageBtn, boLastPageBtn, boZoomDownBtn, boZoomUpBtn, boPageWholeBtn, boPageWidthBtn, boCloseBtn]
    Title = #21360#21047#12503#12524#12499#12517#12540'[Mr.XRAY]'
    Cursor = crHourGlass
    FormLeft = 20
    FormTop = 20
    FormWidth = 1536
    FormHeight = 1152
    FormName = 'frmCalendarPrintPreview'
    FormIconBar = True
    FormBorderIcons = [biSystemMenu, biMinimize, biMaximize]
    FormBorderStyle = bsSizeable
    FormPosition = poDefault
    FormCanMove = True
    FormCanResize = True
    FormWindowState = fwNormal
    FormStatusBar = True
    PaperColor = clWhite
    ViewClip = True
    PrintOffsetX = 0
    PrintOffsetY = 0
    ZoomType = ztWholePage
    InversePrint = False
    Left = 352
    Top = 72
  end
  object plSetPrinter1: TplSetPrinter
    PrinterName = 'Adobe PDF'
    Left = 320
    Top = 72
    DevDataSize = 1424
    ADevData = 
      '41646F6265205044460000000000000000000000000000000000000000000000' +
      '010402059C00F40453EF8001010009009A0B3408640001000F00B00402000100' +
      'B004030001004134000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000010000000000000001000000' +
      '0200000001000000000000000000000000000000000000000000000050524956' +
      '4220000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000180000000000102710271027' +
      '0000102700000000000000000000C40200000000000000000000000000000000' +
      '0000000000000000030000000000000030021000503403002888040000000000' +
      '000000000000000000000000000000000000000000000000F919117805000000' +
      '04000600FF00FF00010000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '3002000045424441000001000100000001000000010000000100000000000000' +
      '53006D0061006C006C006500730074002000460069006C006500200053006900' +
      '7A00650000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '0000000000000000000000000000000000000000000000000000000000000000' +
      '00000000000000000000000001000000'
    DesignValue = (
      'Adobe PDF'
      0
      'A4'
      9
      15
      1282)
  end
end