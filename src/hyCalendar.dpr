program hyCalendar;

{$R 'resource.res' 'resource.rc'}

uses
  Forms,
  Printers,
  SysUtils,
  JclDebug,
  Calendar in 'Calendar.pas' {frmCalendar},
  CalendarItem in 'CalendarItem.pas',
  CellRenderer in 'CellRenderer.pas',
  ConfigDialog in 'ConfigDialog.pas' {frmConfigDialog},
  FileExtRegisteration in 'FileExtRegisteration.pas',
  PageNode in 'PageNode.pas',
  CalendarConfig in 'CalendarConfig.pas',
  CalendarDocument in 'CalendarDocument.pas',
  RangeItem in 'RangeItem.pas',
  RangeItemList in 'RangeItemList.pas',
  RangeItemEditDialog in 'RangeItemEditDialog.pas' {frmRangeItemEditDialog},
  RangeItemReferenceList in 'RangeItemReferenceList.pas',
  UndoBuffer in 'UndoBuffer.pas',
  CalendarAction in 'CalendarAction.pas',
  SeriesItem in 'SeriesItem.pas',
  SeriesItemCondition in 'SeriesItemCondition.pas',
  About in 'About.pas' {frmAbout},
  FindDialog in 'FindDialog.pas' {frmFindDialog},
  CalendarPrinter in 'CalendarPrinter.pas',
  CalendarPrintDialog in 'CalendarPrintDialog.pas' {frmCalendarPrint},
  SeriesItemEditDialog in 'SeriesItemEditDialog.pas' {frmSeriesItemEditDialog},
  DayConditionPropertyEditDialog in 'DayConditionPropertyEditDialog.pas' {frmDayConditionPropertyEditDialog},
  SeriesItemProeprtyEditDialog in 'SeriesItemProeprtyEditDialog.pas' {frmSeriesItemPropertyEditDialog},
  LogicalExprPropertyEditDialog in 'LogicalExprPropertyEditDialog.pas' {frmLogicalExprPropertyEditDialog},
  CalendarPreview in 'CalendarPreview.pas' {frmCalendarPrintPreview},
  TodoList in 'TodoList.pas',
  TodoDialog in 'TodoDialog.pas' {frmTodoDialog},
  TodoUpdateManager in 'TodoUpdateManager.pas',
  ReferenceDialog in 'ReferenceDialog.pas' {frmReferenceDialog},
  SeriesItemSelectDialog in 'SeriesItemSelectDialog.pas' {frmSeriesItemSelectDialog},
  TodolistCopy in 'TodolistCopy.pas' {frmTodolistCopyDialog},
  ColorManager in 'ColorManager.pas',
  PaintColorConfigDialog in 'PaintColorConfigDialog.pas' {frmPaintColorConfig},
  PLPREVFRM in 'Lib\PLPREVFRM.pas' {plPrevForm},
  FileHistory in 'FileHistory.pas',
  DocumentManager in 'DocumentManager.pas',
  RangeItemManager in 'RangeItemManager.pas',
  DocumentReference in 'DocumentReference.pas',
  SearchResult in 'SearchResult.pas',
  ExportDialog in 'ExportDialog.pas' {frmExportDialog},
  DateTimePickerEnhance in 'DateTimePickerEnhance.pas',
  HintWindow in 'HintWindow.pas' {frmHintWindow},
  Rokuyo in 'Rokuyo.pas',
  AbstractDocument in 'AbstractDocument.pas',
  LogicalExprNode in 'LogicalExprNode.pas',
  ImportDialog in 'ImportDialog.pas' {frmImportDialog},
  DayConditionNode in 'DayConditionNode.pas',
  ImportText in 'ImportText.pas',
  CalendarActionFactory in 'CalendarActionFactory.pas',
  Constants in 'textutil\Constants.pas',
  URLScan in 'textutil\URLScan.pas',
  DateFormat in 'textutil\DateFormat.pas',
  StringSplitter in 'textutil\StringSplitter.pas',
  ColoredStringList in 'ColoredStringList.pas',
  DateValidation in 'textutil\DateValidation.pas',
  ColorPair in 'textutil\ColorPair.pas',
  SeriesItemSerialize in 'SeriesItemSerialize.pas',
  SeriesItemUtil in 'SeriesItemUtil.pas',
  SeriesItemManager in 'SeriesItemManager.pas',
  SeriesPublicHoliday in 'SeriesPublicHoliday.pas',
  SeriesCallback in 'SeriesCallback.pas',
  CalendarCallback in 'CalendarCallback.pas',
  DayConditionUtil in 'DayConditionUtil.pas',
  CountdownDialog in 'CountdownDialog.pas' {frmCountdown},
  CountdownItem in 'CountdownItem.pas',
  Hyperlinks in 'Hyperlinks.pas',
  BatchExport in 'BatchExport.pas',
  awhhelp in 'lib\awhhelp.pas',
  MetafileUtils in 'lib\MetafileUtils.pas',
  plPrev in 'lib\plPrev.pas',
  plSetPrinter in 'lib\plSetPrinter.pas',
  TextUtils in 'lib\TextUtils.pas',
  CalendarFont in 'CalendarFont.pas';

{$R *.res}

var
    tracking: boolean;
begin
    tracking := JclStartExceptionTracking;
    if ParamCount > 0 then begin
      if Pos('-export:', ParamStr(1)) > 0 then begin
        exportCalendarFile(ParamStr(0), Copy(ParamStr(1), Length('-export:')+1, Length(ParamStr(1))));
        Exit;
      end;
    end;

    Application.Initialize;
    Application.Title := 'hyCalendar';
    Application.ShowMainForm := False; // 自動ではフォームを表示しない（Create中に表示する）
    Application.CreateForm(TfrmCalendar, frmCalendar);
  Application.Run;
    if tracking then JclStopExceptionTracking;

end.
