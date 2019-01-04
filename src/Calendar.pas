unit Calendar;

interface

uses
  StdCtrls, Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs, Grids, CommCtrl,
  Buttons, ExtCtrls, ShellAPI, ComCtrls, Math, DateUtils,
  Menus, Clipbrd, IMM, StrUtils, HintWindow, ToolWin, ImgList,
  CalendarDocument,
  CellRenderer, URLScan,
  CalendarConfig, UndoBuffer, awhhelp,
  TodoUpdateManager, ColorManager,
  CalendarActionFactory,
  ColorPair, CalendarCallback,
  CountdownDialog,
  DocumentManager,
  CalendarFont,
  Hyperlinks,
  JclDebug;


const
    HELP_FILENAME = 'hyCalendar.chm';
    MAX_HYPERLINKS = 15;

type
  TRichEditEx = class(TRichEdit)
  public
    property OnDblClick;
  end;


  TfrmCalendarCallback = class;

  TfrmCalendar = class(TForm)
    MonthTab: TTabControl;
    CalGrid: TDrawGrid;
    ItemEdit: TMemo;
    MainMenu1: TMainMenu;
    mnuFile: TMenuItem;
    mnuOpen: TMenuItem;
    mnuSaveAs: TMenuItem;
    mnuSave: TMenuItem;
    N1: TMenuItem;
    mnuExit: TMenuItem;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    N3: TMenuItem;
    mnuShowOptionDialogFont: TMenuItem;
    Popup: TPopupMenu;
    Splitter1: TSplitter;
    mnuExitWithoutSave: TMenuItem;
    TabPopup: TPopupMenu;
    pmnuCloseTab: TMenuItem;
    ImageList1: TImageList;
    mnuNewFile: TMenuItem;
    CoolBar1: TCoolBar;
    mnuEdit: TMenuItem;
    mnuPasteFromClipboard: TMenuItem;
    mnuCopyToClipboard: TMenuItem;
    mnuCutToClipboard: TMenuItem;
    Show1: TMenuItem;
    mnuShowURLToolBar: TMenuItem;
    mnuShowViewToolbar: TMenuItem;
    mnuShowFindToolbar: TMenuItem;
    mnuUndo: TMenuItem;
    mnuRedo: TMenuItem;
    N2: TMenuItem;
    mnuSeriesItemEdit: TMenuItem;
    mnuMoveToday: TMenuItem;
    Help1: TMenuItem;
    mnuOpenReadme: TMenuItem;
    mnuAbout: TMenuItem;
    mnuFindDialog: TMenuItem;
    N4: TMenuItem;
    mnuPrint: TMenuItem;
    ViewToolbar: TToolBar;
    MoveDateBtn: TButton;
    MoveDatePicker: TDateTimePicker;
    URLToolbar: TToolBar;
    DirectHyperLinkBox: TComboBox;
    DirectHyperLinkBtn: TButton;
    MarkingToolbar: TToolBar;
    MarkingBtn: TToolButton;
    FindBtn: TToolButton;
    FindBox: TComboBox;
    mnuTodo: TMenuItem;
    BottomAreaPanel: TPanel;
    Splitter2: TSplitter;
    TodoListView: TListView;
    TodoPopupMenu: TPopupMenu;
    mnuAddTodo: TMenuItem;
    mnuEditTodo: TMenuItem;
    mnuDeleteTodo: TMenuItem;
    mnuRefreshTodo: TMenuItem;
    N5: TMenuItem;
    mnuReferenceManage: TMenuItem;
    mnuMoveDownTodo: TMenuItem;
    mnuMoveUpTodo: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    mnuCopyTodoListToClipboard: TMenuItem;
    mnuCopyPopupStringToClipboard: TMenuItem;
    N8: TMenuItem;
    mnuCopyTodoList: TMenuItem;
    FindMethodBox: TComboBox;
    PaintToolBar: TToolBar;
    EditToolSelectButton: TToolButton;
    EditToolIconList: TImageList;
    EditToolSelectPopup: TPopupMenu;
    mnuEditToolNormal: TMenuItem;
    mnuEditToolPaint: TMenuItem;
    mnuEditToolColorConfig: TMenuItem;
    ToolButton1: TToolButton;
    PaintColorBox6: TPaintBox;
    PaintColorBox5: TPaintBox;
    PaintColorBox4: TPaintBox;
    PaintColorBox3: TPaintBox;
    PaintColorBox2: TPaintBox;
    PaintColorBox1: TPaintBox;
    ToolButton3: TToolButton;
    SelectedColorPaintBox: TPaintBox;
    mnuShowPaintToolBar: TMenuItem;
    mnuShowFreeMemoArea: TMenuItem;
    N9: TMenuItem;
    mnuShowTodoArea: TMenuItem;
    StatusBar1: TStatusBar;
    ZoomRateRows: TComboBox;
    ZoomRateColumns: TComboBox;
    FindBackwardBtn: TToolButton;
    N10: TMenuItem;
    FreeMemoAreaPanel: TPanel;
    mnuReferenceReload: TMenuItem;
    mnuExport: TMenuItem;
    N12: TMenuItem;
    ToolButton5: TToolButton;
    PresetZoomRateButton: TToolButton;
    PresetZoomRatePopupMenu: TPopupMenu;
    mnuAddPresetZoomRate: TMenuItem;
    mnuRemovePresetZoomRate: TMenuItem;
    N11: TMenuItem;
    mnuImport: TMenuItem;
    ItemEditPopupMenu: TPopupMenu;
    mnuCutItemEditTextToClipboard: TMenuItem;
    mnuCopyItemEditTextToClipboard: TMenuItem;
    mnuPasteItemEditTextFromClipboard: TMenuItem;
    mnuAppendPaste: TMenuItem;
    mnuOpenCountdownDialog: TMenuItem;
    HTMLHelp1: THTMLHelp;
    TrayIcon1: TTrayIcon;
    FontTester: TPaintBox;
    mnuEditColorPalette: TMenuItem;
    procedure adjustGridSize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CalGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure MonthTabChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CalGridDblClick(Sender: TObject);
    procedure ItemEditExit(Sender: TObject);
    procedure mnuSaveAsClick(Sender: TObject);
    procedure mnuOpenClick(Sender: TObject);
    procedure mnuSaveClick(Sender: TObject);
    procedure CalGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure mnuShowOptionDialogClick(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure CalGridContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure mnuExitWithoutSaveClick(Sender: TObject);
    procedure FreeMemoDblClick(Sender: TObject);
    procedure FreeMemoChange(Sender: TObject);
    procedure CalGridTopLeftChanged(Sender: TObject);
    procedure MonthTabChanging(Sender: TObject; var AllowChange: Boolean);
    procedure ZoomRateRowsChange(Sender: TObject);
    procedure MoveDatePickerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MoveDateBtnClick(Sender: TObject);
    procedure pmnuCloseTabClick(Sender: TObject);
    procedure CalGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ItemEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DirectHyperLinkBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DirectHyperLinkBtnClick(Sender: TObject);
    procedure updateDirectHyperlink(Sender: TObject);
    procedure FreeMemoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FreeMemoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TextMarkingClick(Sender: TObject);
    procedure FindBtnClick(Sender: TObject);
    procedure mnuPasteFromClipboardClick(Sender: TObject);
    procedure mnuCopyToClipboardClick(Sender: TObject);
    procedure mnuCutToClipboardClick(Sender: TObject);
    procedure CalGridMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure CalGridMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormShow(Sender: TObject);
    procedure CalGridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure mnuShowToolbarClick(Sender: TObject);
    procedure mnuUndoClick(Sender: TObject);
    procedure FreeMemoEnter(Sender: TObject);
    procedure FreeMemoExit(Sender: TObject);
    procedure ItemEditChange(Sender: TObject);
    procedure CalGridEnter(Sender: TObject);
    procedure mnuRedoClick(Sender: TObject);
    procedure mnuSeriesItemEditClick(Sender: TObject);
    procedure mnuMoveTodayClick(Sender: TObject);
    procedure mnuOpenReadmeClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure mnuFindDialogClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure mnuPrintClick(Sender: TObject);
    procedure CoolBar1Change(Sender: TObject);
    procedure mnuTodoClick(Sender: TObject);
    procedure mnuAddTodoClick(Sender: TObject);
    procedure mnuDeleteTodoClick(Sender: TObject);
    procedure TodoListViewEdited(Sender: TObject; Item: TListItem;
      var S: String);
    procedure TodoListViewChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure mnuEditTodoClick(Sender: TObject);
    procedure mnuRefreshTodoClick(Sender: TObject);
    procedure TodoListViewMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TodoPopupMenuPopup(Sender: TObject);
    procedure mnuReferenceManageClick(Sender: TObject);
    procedure TodoListViewEnter(Sender: TObject);
    procedure mnuMoveUpTodoClick(Sender: TObject);
    procedure mnuMoveDownTodoClick(Sender: TObject);
    procedure mnuCopyTodoListToClipboardClick(Sender: TObject);
    procedure mnuCopyPopupStringToClipboardClick(Sender: TObject);
    procedure mnuCopyTodoListClick(Sender: TObject);
    procedure mnuEditToolNormalClick(Sender: TObject);
    procedure mnuEditToolPaintClick(Sender: TObject);
    procedure PaintColorBoxClick(Sender: TObject);
    procedure PaintColorBoxPaint(Sender: TObject);
    procedure mnuEditToolColorConfigClick(Sender: TObject);
    procedure CalGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mnuShowFreeMemoAreaClick(Sender: TObject);
    procedure mnuShowTodoAreaClick(Sender: TObject);
    procedure TodoListViewEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure TodoListViewCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure mnuReferenceReloadClick(Sender: TObject);
    procedure mnuExportClick(Sender: TObject);
    procedure PresetZoomRateButtonClick(Sender: TObject);
    procedure mnuAddPresetZoomRateClick(Sender: TObject);
    procedure mnuRemovePresetZoomRateClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TodoListViewClick(Sender: TObject);
    procedure CalGridClick(Sender: TObject);
    procedure mnuImportClick(Sender: TObject);
    procedure mnuAppendPasteClick(Sender: TObject);
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure mnuOpenCountdownDialogClick(Sender: TObject);
    procedure TrayIcon1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private 宣言 }
    FDocument: TCalendarDocument;
    FFonts: TFontMap;

    FDefaultFileMenuCount: integer; // ファイル履歴で増減する前のメニュー個数

    FActionCallback: TCalendarCallback;
    FUndoBuffer: TUndoBuffer;
    FHintWindowStack: THintWindowStack;
    FHyperlink: THyperlink;

    FBaseDate: TDate;          // 表示中の月の１日を指す（年・月にのみ意味がある）
    FBaseDateBack: integer;    // 補正日数（１ヶ月の何日前が１行目に来るか; 7の倍数）
    FBaseDateProceed: integer; // 一ヶ月の何日先まで出すか; ７の倍数

    FGridRows: integer;
    FGridCols: integer;
    FEditing : boolean; // TextBox で編集中を示すフラグと日付
    FEditingDate: TDateTime;

    FPopupDate  : TDate;       // Popup メニューが出ている日付
    FCellRenderer: TCellRenderer;
    FHyperLinkers: array [0..MAX_HYPERLINKS] of TStaticText;
    FConfiguration: TCalendarConfiguration;
    FExitWithoutSave : boolean;
    FURLCache : TStringList;  // コンボボックスに記入された内容を覚えていく
    FURLMemo  : TStringList;
    FFindCache : TStringList;

    FPointedURL : string;       // FreeMemo/ItemEdit 内部のハイパーリンク用
    FPointedStart : integer;    // FreeMemo 内のテキストでどこからがハイパーリンクかの記録
    FPointedLength: integer;    // FreeMemo 内のハイパーリンクの長さ（mm/dd 式を PointedURLとしては yyyy/mm/dd にしてしまうので長さがずれる）


    FHintOnCell: array [0..6, 1..MAX_ROW_COUNT] of boolean; // 各セルではみ出した内容があるかどうか
    FEnforceSelectDayWithoutMovePage : boolean; // ページ移動せずに済むならページ移動しない. 切り取りなどの Undo時に一時的に有効にされる

    FTodoUpdateManager: TTodoUpdateManager;
    FIsFirst : boolean;

    FColorEditMenus: array [0..COLOR_BOX_COUNT] of TMenuItem;
    FPaintColorBox: array [0..COLOR_BOX_COUNT-1] of TPaintBox;
    FPaintToolSelected : boolean;

    FFreeMemoArea: TRichEditEx;

    FFlagLoading: boolean;
    FFlagClipboardCopying: boolean;
    FFlagConfiguring: boolean;
    FFlagRepainting: boolean;

    FSetSavedFindDialogPos: boolean;


    function getStatusString: string;

    procedure makeFindDialogIfNecessary;
    procedure makeSeriesItemEditDialogIfNecessary;
    procedure AdjustGridSizeInternal;
    procedure saveConfiguration;
    procedure updateFileHistoryMenu;
    function getWindowTitle(filename: string): string;
    procedure HideHyperLinks(visibleCount: integer);
    function PosToDay(ACol, ARow: Integer): TDate;
    procedure EnterItemEdit;

    procedure selectDay(day: TDate; with_open: boolean; with_focus: boolean);
    procedure MoveTab(Sender: TObject; idx: integer);
    function TabEndDate: TDate;

    procedure DoShowHint(var HintStr: string; var CanShow: Boolean;
                             var HintInfo: THintInfo);

    procedure ApplicationMinimized(Sender: TObject);

    procedure MyWndProc(var Message: TMessage);

    procedure resetLinkCursor(target: TWinControl);
    procedure testLinkAtCursorPos(target: TWinControl; text: string; year, idx: integer; x,y : integer; charPos: TPoint);

    procedure ColorEditMenuClick(Sender: TObject);
    procedure ColorEditPopupDraw(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure ColorEditPopupMeasure(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
    procedure mnuSelectColorToPaletteClick(Sender: TObject);

    procedure mnuFileHistoryOpen(Sender: TObject);

    procedure FreeMemoProtectChange(Sender: TObject; StartPos, EndPos: Integer; var AllowChange: Boolean);

    procedure mnuRestorePresetZoomRate(Sender: TObject);
    procedure updatePresetZoomRateMenu;

    procedure processDroppedFile(handle: Integer);



  public
    { Public 宣言 }
    procedure MoveDateDefault(day: TDate);
    procedure MoveDate(day: TDate; with_open: boolean; with_focus: boolean = true );

    procedure ShowTodayHint;
    procedure ApplicationRestored(Sender: TObject);

    procedure execDialogShortcut(Sender: TForm; Key: Word; Shift: TShiftState);

    procedure mnuSeriesExcludeClick(Sender: TObject);
    procedure mnuSeriesIncludeClick(Sender: TObject);
    procedure mnuSeriesIncludeYoubiClick(Sender: TObject);

    procedure mnuAddRangeClick(Sender: TObject);
    procedure mnuEditRangeClick(Sender: TObject);
    procedure setFindCache(target: TStrings);
    procedure addFindCache(text: string);
    procedure setMarking(text: string);
    procedure setDirty;

    function LoadFrom(filename: string): boolean;
    function PopupNoHideTimeout: boolean;
    procedure ActivateApplication;

    property ActionCallback: TCalendarCallback read FActionCallback;
    property EnforceSelectDayWithoutMovePage : boolean read FEnforceSelectDayWithoutMovePage write FEnforceSelectDayWithoutMovePage;
  end;

  TfrmCalendarCallback = class(TCalendarCallback)
  private
      FfrmCalendar: TfrmCalendar;
  public
      constructor Create(frm: TfrmCalendar);

      procedure CalendarRepaint; override;
      procedure SetDirty; override;
      procedure MoveDate(d: TDateTime); override;
      procedure setEnforceSelectDayWithoutMovePage(value: boolean); override;
  end;


var
  frmCalendar: TfrmCalendar;

implementation

uses Types,
  PageNode, RangeItemEditDialog,
  TodoList,
  DateValidation,
  SeriesItemEditDialog,
  About, FindDialog, CalendarPrintDialog,
  ConfigDialog,
  TodoDialog, ReferenceDialog, DateFormat,
  PaintColorConfigDialog,
  ExportDialog,
  DateTimePickerEnhance, CalendarAction,
  ImportDialog;

const
    FLAG_EDIT_FROM_POPUP_MENU = 1;

    WM_MY_ACTIVATE = WM_APP + 2;

    MAX_UNDO_STEP = 256;
    FILE_LOAD_ERROR_MESSAGE = 'ファイルの読み込みに失敗しました．';
    APPLICATION_NAME = 'hyCalendar ';

{$R *.dfm}



procedure TfrmCalendar.ShowTodayHint;
var
    HintPos: TPoint;
    HintStr: string;
    CursorRect: TRect;
    w, h: integer;
begin
    if FHintWindowStack.TopDate = Date then FHintWindowStack.HideAllHint
    else begin
        HintStr := TDocumentManager.getInstance.getHintString(Date);
        FHintWindowStack.calculateSize(HintStr, w, h);
        HintPos.x := Screen.WorkAreaWidth - w;
        HintPos.y := Screen.WorkAreaHeight - h;
        CursorRect.TopLeft := HintPos;
        CursorRect.Right := Screen.WorkAreaWidth;
        CursorRect.Bottom := Screen.WorkAreaHeight;
        FHintWindowStack.AllowPopup;
        FHintWindowStack.popup(Date, HintPos, HintStr, CursorRect, self);
    end;
end;

function TfrmCalendar.getStatusString: string;
begin
    if not FDocument.Locked and (FDocument.Filename <> '') then begin
        Result := '*上書き禁止* 他のプログラムがファイルを使用中です．';
    end else begin
        result := '';
    end;
end;

procedure TfrmCalendar.ActivateApplication;
begin
//    FTaskTray.ActivateApplication;
    if IsIconic(Application.Handle) then begin
//        FIsIconic := false;
        // ウィンドウをサイズ変更せず，タスクバーに復帰させておいて
        setWindowPos(Application.Handle, HWND_TOP, 0, 0, 0, 0, SWP_SHOWWINDOW or SWP_NOSIZE or SWP_NOMOVE);
        // アプリケーションを "元に戻す"
        Application.Restore;
    end else begin
        SetForegroundWindow(Application.MainForm.Handle);
    end;
end;

procedure TfrmCalendar.MoveDateDefault(day: TDate);
begin
    MoveDate(day, FConfiguration.HyperlinkWithEditMode);
end;

procedure TfrmCalendar.makeSeriesItemEditDialogIfNecessary;
begin
  if frmSeriesItemEditDialog = nil then begin
    Application.CreateForm(TfrmSeriesItemEditDialog, frmSeriesItemEditDialog);
  end;
  frmSeriesItemEditDialog.SeriesItemList := FDocument.SeriesItems; // 周期予定リストをダイアログに関連付け．
end;

function TfrmCalendar.PopupNoHideTimeout: boolean;
begin
  Result := FConfiguration.PopupNoHideTimeout;
end;

// そのタブで表示中の範囲の月の末日を返す
// （2ヶ月以上が表示されているときは，全部の日が含まれている月の末日）
//  計算式: (グリッド右下の日 + 1日) の月の最初の日 - 1 日
//  +1日は，グリッド右下の日が月末だった場合への対処
function TfrmCalendar.TabEndDate: TDate;
begin
     Result := IncDay(StartOfTheMonth(IncDay(FCellRenderer.ConvertPosToDay(FBaseDate, FBaseDateBack, CalGrid.ColCount-1, CalGrid.RowCount-1), 1)), -1);
end;



constructor TfrmCalendarCallback.Create(frm: TfrmCalendar);
begin
  FfrmCalendar := frm;
end;

procedure TfrmCalendarCallback.CalendarRepaint;
begin
  FfrmCalendar.CalGrid.Repaint;
end;

procedure TfrmCalendarCallback.SetDirty;
begin
  FfrmCalendar.setDirty;
end;

procedure TfrmCalendarCallback.MoveDate(d: TDateTime);
begin
  FfrmCalendar.MoveDate(d, false);
end;

procedure TfrmCalendarCallback.setEnforceSelectDayWithoutMovePage(value: boolean);
begin
  FfrmCalendar.EnforceSelectDayWithoutMovePage := value;
end;



procedure TfrmCalendar.MyWndProc(var Message: TMessage);
var
    errorlog: TStringList;
    msg: string;
begin
    try
        if Message.Msg = WM_MY_ACTIVATE then begin
            ActivateApplication;
//  end else if (Message.Msg = CM_SYSFONTCHANGED) then begin
//
//        frm := Screen.ActiveForm;
//
//        if (frm <> nil) and not IsIconic(Application.Handle) then begin
//            self.Repaint;
//            self.Hide;
//            self.Show;   // 表示中だったら元に戻す
//            frm.BringToFront;
//        end else begin
//            //アイコン時は，非表示になっているのでそのまま素通し
//            WndProc(Message);
//        end;
//      Message.Msg := 0;
        end else if (Message.Msg = WM_DROPFILES) then begin
            processDroppedFile(Message.WParam);
        end else WndProc(message);
    except
        on E: Exception do begin
            errorlog := TStringList.Create;
            JclLastExceptStackListToStrings(errorlog, true, true, true, false);
            msg := '予期せぬエラーが発生しました．'#13#10;
            msg := msg + '以下のエラー報告用データをクリップボードに出力しましたので，'#13#10;
            msg := msg + '開発者までご一報いただければ幸いです．'#13#10;
            msg := msg + 'ご迷惑をおかけしますが，よろしくお願いいたします．'#13#10;
            msg := msg + '例外: ' + E.ClassName + ' ' + E.Message + #13#10 + errorlog.Text;
            errorlog.Free;
            Clipboard.AsText := msg;
            MessageDlg(msg, mtError, [mbOK], 0);
        end;
    end;
end;



//-----------------------------------------------------------------------------
// 初期化～終了処理
//-----------------------------------------------------------------------------
procedure TfrmCalendar.FormCreate(Sender: TObject);

    procedure initControls;
    var
        i: integer;
    begin
        Application.OnShowHint := DoShowHint;
        Application.OnMinimize := ApplicationMinimized;
        Application.OnRestore  := ApplicationRestored;
        self.WindowProc := MyWndProc;

        FEnforceSelectDayWithoutMovePage := false;

        FDefaultFileMenuCount := mnuFile.Count;

        FHintWindowStack := THintWindowStack.Create(self);

        enhancePicker(MoveDatePicker);

        FActionCallback := TfrmCalendarCallback.Create(self);

        // ツールバーの高さはデザイン時に
        // 動的に決定されていてプロパティに保存されないようなのでここで設定
        ViewToolBar.ButtonHeight := MarkingToolBar.ButtonHeight;
        URLToolBar.ButtonHeight := MarkingToolBar.ButtonHeight;
        PaintToolBar.ButtonHeight := MarkingToolBar.ButtonHeight;


        FFreeMemoArea := TRichEditEx.Create(FreeMemoAreaPanel);
        FFreeMemoArea.Parent := FreeMemoAreaPanel;
        with FFreeMemoArea do begin
            Left := 0;
            Top  := 0;
            Align := alClient;

            OnDblClick := FreeMemoDblClick;
            OnChange := FreeMemoChange;
            OnEnter := FreeMemoEnter;
            OnExit := FreeMemoExit;
            OnProtectChange := FreeMemoProtectChange;
            OnMouseMove := FreeMemoMouseMove;
            OnMouseDown := FreeMemoMouseDown;
            OnMouseUp := FreeMemoMouseDown; // わざと Down イベントにしている

            ScrollBars := ssBoth;
            WordWrap := false;
            WantTabs := true;
            WantReturns := true;
            PopupMenu := ItemEditPopupMenu;

            // FreeMemo に対応する URL を格納する FURLMemo を初期化
            // FreeMemo を読み込む（ファイル開く）前に生成する必要あり
            FURLCache := TStringList.Create;
            FURLCache.Sorted := true;
            FURLCache.Duplicates := dupIgnore;
            FURLCache.CaseSensitive := true;
            FURLMemo  := TStringList.Create;
            FURLMemo.Sorted := true;
            FURLMemo.CaseSensitive := true;
            FFindCache := TStringList.Create;
            FFindCache.Sorted := true;
            FFindCache.Duplicates := dupIgnore;
            FFindCache.CaseSensitive := true;

            // グリッド初期化
            CalGrid.Align := alClient;
            CalGrid.ColCount := CellRenderer.DAY_PER_WEEK;
            CalGrid.RowCount := 7;         // ５週間 + 前後２週間ぶん表示可能にする
            CalGrid.FixedCols := 0;
            CalGrid.FixedRows := 1;
            CalGrid.PopupMenu := Popup;


            // ステータスバーの高さをフォントに合わせて調整
            Statusbar1.Height := StatusBar1.Canvas.TextHeight('あ') + 6;

            // AutoHotkeyは Caption 中に勝手に "&" を追加するので禁止
            Popup.AutoHotkeys := maManual;

            ItemEdit.Visible := false;
            //ItemEdit.Parent  := CalGrid;



            FUndoBuffer := TUndoBuffer.Create(MAX_UNDO_STEP);
            MoveDatePicker.Date := Date;

            FPaintColorBox[0] := PaintColorBox1;
            FPaintColorBox[1] := PaintColorBox2;
            FPaintColorBox[2] := PaintColorBox3;
            FPaintColorBox[3] := PaintColorBox4;
            FPaintColorBox[4] := PaintColorBox5;
            FPaintColorBox[5] := PaintColorBox6;

            for i:=0 to COLOR_BOX_COUNT-1 do begin
                FPaintColorBox[i].OnClick := PaintColorBoxClick;
                FPaintColorBox[i].OnPaint := PaintColorBoxPaint;
                FPaintColorBox[i].Tag := i;
            end;
        end;
    end;

    // タスクトレイ用に小さいほうのアイコンを取り出す
    procedure loadIconForTasktray;
    var
        hLarge, hSmall: HIcon;
    begin
        ExtractIconEx(PAnsiChar(Application.EXENAME), 0, hLarge, hSmall, 1);
        TrayIcon1.Icon.Handle := hSmall;
    end;

var
    i: integer;
    m: TPageNode;
    col, row: integer;
    day: TDateTime;
    page, closedPage: integer;

begin
    FIsFirst := true;

    initControls;

    // 設定ファイルを読んで色々設定
    FConfiguration := TCalendarConfiguration.Create( ExtractFilePath(Application.ExeName) + 'hycalendar.ini', CalGrid.Font );
    FConfiguration.ReadIniFile;

    FFonts := TFontMap.Create(FConfiguration);

    setConfigurationForPicker(FConfiguration);

    for col:=0 to 6 do
        for row:=1 to MAX_ROW_COUNT do
            FHintOnCell[col][row] := false;

    updatePresetZoomRateMenu;

//    FTaskTray := TTasktray.Create;
//    FTaskTray.OnRightClick := frmCalendar.ShowTodayHint;


    // 拡大率を設定
    if FConfiguration.SaveZoomRate then begin
        if FConfiguration.ZoomRateForEachPage then
            FConfiguration.getZoomRate(date, FGridRows, FGridCols)
        else
            FConfiguration.getSharedZoomRate(FGridRows, FGridCols);
    end else begin
        FGridCols := DEFAULT_COL_COUNT;
        FGridRows := DEFAULT_ROW_COUNT;
    end;
    self.Caption := getWindowTitle('');
    TDocumentManager.getInstance.Configuration := FConfiguration;
    FDocument := TDocumentManager.getInstance.MainDocument;

    if TDocumentManager.getInstance.hasStartupError then begin
      MessageDlg('祝日ファイル中にエラーを発見しました．祝日は表示されません．', mtError, [mbOK], 0);
    end;

    // 描画用オブジェクトを準備
    FCellRenderer := TCellRenderer.Create(CalGrid.Canvas, CalGrid.FixedColor, FConfiguration.DefaultBackColor, FConfiguration);
    FDocument.ColorManager.DefaultBackColor := FConfiguration.DefaultBackColor;

    for i:=0 to MAX_HYPERLINKS do begin
        FHyperLinkers[i] := nil; //TStaticText.Create(Self);
    end;


    // Ini ファイルを読んでフォント，ウィンドウ位置設定
    with FConfiguration do begin

        FFreeMemoArea.Font := FFonts.FreeMemoFont;
        ItemEdit.Font := FFonts.TextFont;
        ItemEdit.Color := DefaultBackColor;

        if WindowPosSave then begin
            // 全体のサイズ・位置
            self.Left := WindowLeft;
            self.Top := WindowTop;
            self.Width := WindowWidth;
            self.Height := WindowHeight;

            // 縦２つに分割するスプリッタの配置
            self.StatusBar1.Align := alBottom;
            self.StatusBar1.Top := self.Height - self.StatusBar1.Height - 1;

            self.BottomAreaPanel.Height := MemoHeight;
            self.BottomAreaPanel.Top    := self.StatusBar1.Top - self.BottomAreaPanel.Height - 1;
            self.BottomAreaPanel.Align := alBottom;

            self.Splitter1.Top := self.BottomAreaPanel.Top - self.Splitter1.Height - 1;
            self.Splitter1.Align := alBottom;

            // フリーメモとTODOのスプリッタの配置
            self.FreeMemoAreaPanel.Width := MemoWidth;
            self.Splitter2.Left := MemoWidth + 1;

            mnuShowFreeMemoArea.Checked := not ShowFreeMemoArea;
            mnuShowFreeMemoAreaClick(mnuShowFreeMemoArea);
            mnuShowTodoArea.Checked     := not ShowTodoListArea;
            mnuShowTodoAreaClick(mnuShowTodoArea);

        end else begin

            if (Screen.Width < 800) then begin
                self.Width := 640;
                self.Height := 420;
                self.Top := 0;
                self.Left := 0;
            end else begin
                self.Width := 800;
                self.Height := 560;
                self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
                self.Top := (Screen.WorkAreaHeight - self.Height) div 2;
            end;
        end;

        // とりあえず初期値として今月の初日を設定
        FBaseDate := IncMonth(StartOfTheMonth(Date), 0);

        if MonthTabSave then begin
            MonthTab.Tabs.Clear;
            page := 0;
            closedPage := 0;
            for i:=0 to MonthTabs.Count-1 do begin
                if DateFormat.TryParseDate(MonthTabs[i], day) then begin
                    day := StartOfTheMonth(day);
                    if not FConfiguration.MonthTabAutoClose or (day >= IncMonth(StartOfTheMonth(Date), -1)) then begin
                        m := TPageNode.Create(day);
                        MonthTab.Tabs.AddObject(m.toString, m);
                        if FBaseDate = day then page := i - closedPage;
                    end else begin
                        inc(closedPage);
                    end;
                end;
            end;
            if MonthTab.Tabs.Count = 0 then begin
                // タブがないと問題なので，現在月のタブをつける
                m := TPageNode.Create(FBaseDate);
                MonthTab.Tabs.AddObject(m.toString, m);
            end;

            MonthTab.TabIndex := page;
        end else begin

            // タブに５ヶ月分表示（とりあえず先月～３ヶ月先）
            MonthTab.Tabs.Clear;

            for i:=-FConfiguration.DefaultMonthTabBefore to FConfiguration.DefaultMonthTabAfter do begin
                day := IncMonth(FBaseDate, i);
                m := TPageNode.Create(day);
                MonthTab.Tabs.AddObject(m.toString,  m);
            end;
            MonthTab.TabIndex := FConfiguration.DefaultMonthTabBefore;
        end;


        FindBox.AutoComplete := MarkingAutoComplete;

    end;
    DragAcceptFiles(self.Handle, TRUE);

    FTodoUpdateManager := TTodoUpdateManager.getInstance;
    FTodoUpdateManager.setConfiguration(FConfiguration);
    FTodoUpdateManager.registerListener(TodoListView);

    Application.HelpFile   := ExtractFilePath(Application.ExeName)+ HELP_FILENAME;

    // この時点では引数はファイル名のはず．
    if ParamCount > 0 then begin
        if not LoadFrom(ParamStr(1)) then begin
            // ファイルを開けなかったらただちに終了
            Application.Terminate;
            Exit;
        end;
    end else begin
        LoadFrom('');
    end;

    FHyperlink := THyperlink.Create;

    loadIconForTasktray;

    // 初期化の続きは FormShow で実行
    Self.Show;
end;

procedure TfrmCalendar.FormShow(Sender: TObject);
var
    i: integer;

begin

    if FIsFirst then begin


        CalGrid.SetFocus;
        mnuUndo.Enabled := false;

        // ツールバーの設定を復元
        with FConfiguration do begin
            if ToolbarSave then begin
                Coolbar1.Bands.BeginUpdate;
                for i:=0 to MAX_TOOLBAR_INDEX do begin
                    CoolBar1.Bands.FindItemID(i).Index := ToolbarIndex[i];
                    CoolBar1.Bands[ToolbarIndex[i]].Width := ToolBarWidth[i];
                    CoolBar1.Bands[ToolbarIndex[i]].Visible := ToolBarVisible[i];
                    CoolBar1.Bands[ToolbarIndex[i]].Break := ToolBarBreak[i];

                end;
                Coolbar1.Bands.EndUpdate;

                mnuShowFindToolbar.Checked := ToolBarVisible[INDEX_TOOLBAR_MARKING];
                mnuShowViewToolbar.Checked := ToolBarVisible[INDEX_TOOLBAR_VIEW];
                mnuShowURLToolbar.Checked := ToolBarVisible[INDEX_TOOLBAR_URL];
                mnuShowPaintToolBar.Checked := ToolBarVisible[INDEX_TOOLBAR_PAINT];

                CoolBar1Change(Sender);

            end else begin
                Coolbar1.Bands[ToolbarIndex[INDEX_TOOLBAR_URL]].Visible := false;
                mnuShowUrlToolbar.Checked := false;
            end;

            FSetSavedFindDialogPos := WindowPosSave;

//            if WindowPosSave then begin
//                frmFindDialog.Left   := FinderWindowLeft;
//                frmFindDialog.Top    := FinderWindowTop;
//                frmFindDialog.Width  := FinderWindowWidth;
//                frmFindDialog.Height := FinderWindowHeight;
//            end;

        end;

        // 起動時，なぜかFindBoxがTop=0 になってしまうので修正
        FindBox.Top := 3;

        // ページを切り替えて再描画
        MonthTabChange(sender);

        // カラーパレット初期化
        for i:=0 to COLOR_BOX_COUNT-1 do begin
            FDocument.ColorManager.setColor(i, FConfiguration.PaletteColor[i]);
        end;

        // 初期パレット設定
        //FPaintColorSelected := 0;
        FDocument.ColorManager.selectColor(0);

        // カラーメニュー初期化
        Popup.OwnerDraw := true;

        // フォームの生成が終わっているはずなので設定を渡す
//        frmFindDialog.setSearchOption(FConfiguration.MarkingAutoComplete, FConfiguration.MarkingCaseSensitive);

        // IME 状態の設定
        if FConfiguration.StartupImeModeOn then SetImeMode(self.Handle, imOpen);

        FIsFirst := false;

        TrayIcon1.Visible := FConfiguration.UseTaskTray; //if FConfiguration.UseTaskTray then FTaskTray.CreateTaskBarIcon;

    end;

    // CalGrid に対して IME を無効にする（ImeMode 設定ができないので API 直接利用）
    // SetImeMode より後で使わないと効果がない様子なのでここで
    ImmAssociateContext(CalGrid.Handle, 0);
    ImmAssociateContext(TodoListView.Handle, 0);
end;


procedure TfrmCalendar.saveConfiguration;
var
    i: integer;
    idx: integer;
    day: TDateTime;
begin
    with FConfiguration do begin

        if WindowPosSave then begin
            WindowLeft := self.Left;
            WindowTop  := self.Top;
            WindowWidth := self.Width;
            WindowHeight := self.Height;
            MemoHeight := self.BottomAreaPanel.Height;
            MemoWidth := self.FreememoAreaPanel.Width;
            ShowFreeMemoArea := mnuShowFreeMemoArea.Checked;
            ShowTodoListArea := mnuShowTodoArea.Checked;

            // 本当は frmFindDialog 側に実行してほしいが，
            // WriteIni するために同期が必要になってしまうので
            // ここで保存
            if frmFindDialog <> nil then begin
                FinderWindowLeft := frmFindDialog.Left;
                FinderWindowTop := frmFindDialog.Top;
                FinderWindowWidth := frmFindDialog.Width;
                FinderWindowHeight := frmFindDialog.Height;
            end;
        end;


        if MonthTabSave then begin
            MonthTabs.Clear;
            for i:=0 to MonthTab.Tabs.Count-1 do begin
                day := (MonthTab.Tabs.Objects[i] as TPageNode).getBaseDate;
                MonthTabs.Add(DateFormat.unparseDate(day));
            end;
        end;

        if ToolbarSave then begin
            for i:=0 to MAX_TOOLBAR_INDEX do begin
                if CoolBar1.Bands[i].Control = MarkingToolBar then
                    idx := INDEX_TOOLBAR_MARKING
                else if CoolBar1.Bands[i].Control = ViewToolBar then
                    idx := INDEX_TOOLBAR_VIEW
                else if CoolBar1.Bands[i].Control = PaintToolBar then
                    idx := INDEX_TOOLBAR_PAINT
                else idx := INDEX_TOOLBAR_URL;

                ToolBarWidth[idx] := CoolBar1.Bands[i].Width;
                ToolBarVisible[idx] := CoolBar1.Bands[i].Visible;
                ToolBarBreak[idx] := CoolBar1.Bands[i].Break;
                ToolBarIndex[idx] := Coolbar1.Bands[i].Index;
            end;
        end;



        if SaveZoomRate then FConfiguration.setSharedZoomRate(FGridRows, FGridCols); //ZoomRate := FZoomRate;

        // カラーパレット保存
        for i:=0 to COLOR_BOX_COUNT-1 do begin
            FConfiguration.PaletteColor[i] := FDocument.ColorManager.getColor(i);
        end;

        WriteIniFile;
    end;

    // ファイルリストを保存
    TDocumentManager.getInstance.SaveReferenceList;

end;

procedure TfrmCalendar.FormDestroy(Sender: TObject);
var
    i: integer;
begin

    TTodoUpdateManager.Cleanup;
    FActionCallback.Free;

//    if FConfiguration.UseTaskTray then FTaskTray.DeleteTaskbarIcon;
//    FTaskTray.Free;
    FHyperlink.Free;

    FHintWindowStack.Free;
    FUndoBuffer.Free;

    FCellRenderer.Free;
    FCellRenderer := nil;

    FFonts.Free;
    FConfiguration.Free;
    FFindCache.Free;
    FURLCache.Free;
    TURLExtractor.getInstance.cleanupURLs(FURLMemo);
    FURLMemo.Free;
    FDocument := nil;
    For i:=0 to MonthTab.Tabs.Count-1 do begin
        TPageNode(MonthTab.Tabs.Objects[i]).Free;
    end;
    MonthTab.Tabs.Clear;

    TDocumentManager.Cleanup;


end;


//-----------------------------------------------------------------------------
// 日付移動関係
//-----------------------------------------------------------------------------

// 「タブを閉じる」
procedure TfrmCalendar.pmnuCloseTabClick(Sender: TObject);
var
    idx: integer;
    p: TPoint;
begin
    p := MonthTab.ScreenToClient(TabPopup.PopupPoint);
    idx := MonthTab.IndexOfTabAt(p.X, p.Y);
    if (idx >= 0) and (MonthTab.Tabs.Count > 1) then begin // 最後のタブなら閉じない
        if (MonthTab.TabIndex=idx) then begin
            if (idx = 0) then MoveTab(Sender, 1)
            else MoveTab(Sender, idx-1);
        end;

        MonthTab.Tabs.Objects[idx].Free;
        MonthTab.Tabs.Delete(idx);
    end;
end;

// タブ内の日を選択
procedure TfrmCalendar.selectDay(day: TDate; with_open: boolean; with_focus: boolean);
var
b: boolean;
    c, r: integer;
begin
    // 今日を表すセルが現在のタブにあればそれを選択する
    if (PosToDay(0, 1) <= day)and(day <= PosToDay(CalGrid.ColCount-1, CalGrid.RowCount-1)) then begin
        FCellRenderer.ConvertDayToPos(FBaseDate, day, FBaseDateBack, c, r);
        CalGrid.Col := c;
        CalGrid.Row := r;

        // 選択したセルが表示範囲外のときはできるだけ中央に寄せる
        if (CalGrid.VisibleColCount < 7) and ((c < CalGrid.LeftCol)or(CalGrid.LeftCol + CalGrid.VisibleColCount <= c)) then begin
            CalGrid.LeftCol := max((CalGrid.Col) - CalGrid.VisibleColCount div 2, 0);
        end;
        if (CalGrid.VisibleRowCount < 6) and ((r < CalGrid.TopRow) or (CalGrid.TopRow + CalGrid.VisibleRowCount <= r)) then begin
            CalGrid.TopRow := max((CalGrid.Row) - CalGrid.VisibleRowCount div 2, 1);
        end;

        CalGridSelectCell(self, CalGrid.Col, CalGrid.Row, b);

        if with_focus then CalGrid.SetFocus;

        if with_open then begin
            EnterItemEdit;
        end;

    end else begin
        // ない場合はとりあえず左上端
        CalGrid.Row := 1;
        CalGrid.Col := 0;
    end;
end;

function TfrmCalendar.PosToDay(ACol, ARow: Integer): TDate;
begin
    Result := FCellRenderer.ConvertPosToDay(FBaseDate, FBaseDateBack, ACol, ARow);
end;


// 拡大率の設定に合わせてグリッド調整
procedure TfrmCalendar.AdjustGridSizeInternal;
var
    i: integer;
begin
    // グリッドの行数調整: 表示する週の数が多い場合のみ
    if (FGridRows > DEFAULT_ROW_COUNT) then begin
        CalGrid.RowCount := FGridRows + 1 + ((FBaseDateBack + FBaseDateProceed) div 7);
    end else if (FGridRows < DEFAULT_ROW_COUNT) then begin
        CalGrid.RowCount := DEFAULT_ROW_COUNT + 2 + ((FBaseDateBack + FBaseDateProceed) div 7);
    end else begin
        CalGrid.RowCount := DEFAULT_ROW_COUNT + 1 + ((FBaseDateBack + FBaseDateProceed) div 7);
    end;

    // スクロールバーを出しておく
    // FGridCols, Rows -- 表示数，CalGrid.Col/RowCount -- 実際の存在数
    if (FGridCols < CalGrid.ColCount)and
       (FGridRows < (CalGrid.RowCount-1)) then begin
        CalGrid.ScrollBars := ssBoth;
    end else if (FGridCols < CalGrid.ColCount) then begin
        CalGrid.ScrollBars := ssHorizontal;
    end else if (FGridRows < CalGrid.RowCount-1) then
        CalGrid.ScrollBars := ssVertical
    else
        CalGrid.ScrollBars := ssNone;


    // サイズ再調整 (スクロールバーの出現影響で変化した ClientWidth, Height の値を使って再計算)
    for i:= 0 to CalGrid.ColCount-1 do begin
        CalGrid.ColWidths[i] := Floor((CalGrid.ClientWidth - CalGrid.GridLineWidth*FGridCols) / FGridCols);
    end;
    for i:=1 to CalGrid.RowCount-1 do begin
        CalGrid.RowHeights[i] := Floor((CalGrid.ClientHeight - CalGrid.RowHeights[0]-CalGrid.GridLineWidth*FGridRows) / (FGridRows));
    end;
end;


procedure TfrmCalendar.adjustGridSize(Sender: TObject);
var
    b: boolean;
begin
    // フォーム破棄途中に呼ばれた場合(なぜか呼ばれることがある)は無視する
    if not Self.Visible then exit;

    adjustGridSizeInternal;

    if FGridCols = 7 then
        CalGrid.LeftCol := 0
    else if (CalGrid.LeftCol + FGridCols <= CalGrid.Col) then
        CalGrid.LeftCol := 1 + CalGrid.Col - FGridCols
    else if (CalGrid.LeftCol > CalGrid.Col) then
        CalGrid.LeftCol := CalGrid.Col;

    if FGridRows >= DEFAULT_ROW_COUNT then // 表示行数が標準より多い場合
        CalGrid.TopRow := 1
    else if (CalGrid.TopRow + FGridRows <= CalGrid.Row) then
        CalGrid.TopRow := 1 + CalGrid.Row - FGridRows
    else if (CalGrid.TopRow > CalGrid.Row) then
        CalGrid.TopRow := CalGrid.Row;


    // サイズ変更に合わせてセルを再選択（ハイパーリンクラベルの表示調整など）
    if (CalGrid.Col >= 0) and(CalGrid.Row > 0) then
        CalGridSelectCell(Sender, CalGrid.Col, CalGrid.Row, b);
end;

procedure TfrmCalendar.MoveDatePickerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if Key = VK_RETURN then begin
        MoveDateBtn.SetFocus;
        MoveDateBtnClick(Sender);
    end;
end;

procedure TfrmCalendar.MoveDateBtnClick(Sender: TObject);
begin
    MoveDate(MoveDatePicker.Date, false);
end;

// 日付に対応する適切なタブを探す
procedure TfrmCalendar.MoveDate(day: TDate; with_open: boolean; with_focus: boolean = true );
var
    tab: TPageNode;
    i: integer;
    idx : integer;
begin
    if not isValid(day) then exit;

    // 同じタブの日なら移動しない
    if (FEnforceSelectDayWithoutMovePage or
        FConfiguration.SelectDayWithoutMovePageIfVisible)
       and(PosToDay(0, 1) <= day)
       and(day <= PosToDay(CalGrid.ColCount-1, CalGrid.RowCount-1)) then begin
        SelectDay(day, with_open, with_focus);
        exit;
    end;

    // 再描画一時停止
    CalGrid.OnDrawCell := nil;
    try
        idx := MonthTab.Tabs.Count;
        for i:=0 to MonthTab.Tabs.Count-1 do begin
            tab := TPageNode(MonthTab.Tabs.Objects[i]);
            if day < tab.getBaseDate then begin
                // これ以上は探索しても意味がないので終了
                idx := i;
                break;
            end else if (day >= tab.getBaseDate)and
                        (day < IncMonth(tab.getBaseDate, 1)) then begin
                // 対応するタブを発見: それを開く
                MoveTab(self, i);
                SelectDay(day, with_open, with_focus);
                exit;
            end;
        end;

        // 適切なタブが見つからなかった場合
        tab := TPageNode.Create(day);
        MonthTab.Tabs.InsertObject(idx, tab.toString, tab);
        MoveTab(self, idx);
        SelectDay(day, with_open, with_focus);

    finally
        CalGrid.OnDrawCell := CalGridDrawCell;
        CalGrid.Repaint;
    end;
end;

procedure TfrmCalendar.MoveTab(Sender: TObject; idx: integer);
var
    b: boolean;
begin
    MonthTabChanging(Sender, b);
    MonthTab.TabIndex := idx;
    MonthTabChange(Sender);
end;


procedure TfrmCalendar.MonthTabChanging(Sender: TObject;
  var AllowChange: Boolean);
var
    m: TPageNode;
begin
    AllowChange := true;
    // タブ切り替え前の情報を保存
    m := TPageNode(MonthTab.Tabs.Objects[MonthTab.TabIndex]);
    m.Row := CalGrid.Row;
    m.Col := CalGrid.Col;
end;

procedure TfrmCalendar.MonthTabChange(Sender: TObject);
var
    m : TPageNode;
    b: boolean;
begin
    m := TPageNode(MonthTab.Tabs.Objects[MonthTab.TabIndex]);
    FBaseDate :=  m.BaseDate;
    FBaseDateBack := 0;
    FBaseDateProceed := 0;

    if FConfiguration.ZoomRateForEachPage then begin
        FConfiguration.getZoomRate(FBaseDate, FGridRows, FGridCols);
    end;

    // 拡大率に合わせて文字列のほうも設定
    ZoomRateRows.Text := IntToStr(FGridRows) + '週';
    ZoomRateColumns.ItemIndex := FGridCols - 1;
    adjustGridSize(Sender);

    // 初めて表示するなら日を選択，
    // そうでないときは以前選択していたセルを選択
    if m.FirstShow then begin
        selectDay(Date, false, false);
    end else begin
        // 「拡張」表示してた場合，グリッド範囲外にカーソルがある可能性あり
        if CalGrid.RowCount <= m.Row then
          CalGrid.Row := CalGrid.RowCount-1
        else
          CalGrid.Row := m.Row;
        CalGrid.Col := m.Col;
    end;
    if Self.Active then CalGrid.SetFocus;

    if not FIsFirst then CalGrid.Repaint;

    CalGridSelectCell(Sender, CalGrid.Col, CalGrid.Row, b);

end;



procedure TfrmCalendar.CalGridMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
    if CalGrid.Row = CalGrid.RowCount-1 then begin
        MoveDate(IncDay(PosToDay(CalGrid.Col, CalGrid.Row), 7), false);
        handled := true;
    end;
end;

procedure TfrmCalendar.CalGridMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
    if CalGrid.Row = 1 then begin
        MoveDate(IncDay(PosToDay(CalGrid.Col, CalGrid.Row), -7), false);
        handled := true;
    end;
end;


procedure TfrmCalendar.ZoomRateRowsChange(Sender: TObject);
var
    i: integer;
    day : TDate;
    row, col: integer;
begin
    i := AnsiPos('週', ZoomRateRows.Text);
    if i > 0 then begin
        if not TryStrToInt(Copy(ZoomRateRows.Text, 1, i-1), row) then
            row := FGridRows;
    end else begin
        if not TryStrToInt(ZoomRateRows.Text, row) then
            row := FGridRows;
    end;
    if row > MAX_ROW_COUNT then row := MAX_ROW_COUNT;
    if row < 1 then row := 1;

    if not TryStrToInt(Copy(ZoomRateColumns.Text, 1, 1), col) then
        col := FGridCols;

    if (row <> FGridRows)or(col <> FGridCols)then begin
        FGridRows := row;
        FGridCols := col;
        adjustGridSize(sender);
    end;

    if FConfiguration.ZoomRateForEachPage then begin
        day := TPageNode(MonthTab.Tabs.Objects[MonthTab.TabIndex]).getBaseDate;
        FConfiguration.setZoomRate(YearOf(day), monthOf(day), FGridRows, FGridCols);
    end;
end;


//-----------------------------------------------------------------------------
// 描画関係
//-----------------------------------------------------------------------------
procedure TfrmCalendar.CalGridDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
    day : TDate;
begin
    if (ARow = 0) then begin
        FCellRenderer.drawNameOfDay(rect, ACol);
    end else begin
        day := PosToDay(ACol, ARow);
        FCellRenderer.draw(Rect, FBaseDate, day, (gdSelected in State), FHintOnCell[ACol][ARow]);
    end;
end;


//-----------------------------------------------------------------------------
// 日付メモ編集
//-----------------------------------------------------------------------------

procedure TfrmCalendar.EnterItemEdit;
var
    str: string;
begin
    HideHyperLinks(0);
    // 選ばれているセルを編集可能な状態にする
    // (ItemEdit をセルの位置に移動して表示する)

    FEditingDate := PosToDay(CalGrid.Col, CalGrid.Row);
    if IsValid(FEditingDate) then begin
        str := FDocument.getDayText(FEditingDate);
        FEditing := True;

        ItemEdit.Text := str; //item.getString;
        ItemEdit.SelStart := Length(str); //ItemEdit.Text);
        ItemEdit.SelLength := 0;
        itemEdit.ClearUndo;
        ItemEdit.Width := Min(Max(200, CalGrid.ColWidths[CalGrid.Col] * 2 - 16), CalGrid.Width);
        ItemEdit.Height := Min(Max(140, CalGrid.RowHeights[CalGrid.Row] * 2 - 16), CalGrid.Height);
        ItemEdit.Left := Min(CalGrid.Left + CalGrid.Width  - ItemEdit.Width,  CalGrid.Left + CalGrid.CellRect(CalGrid.Col, CalGrid.Row).Left);
        ItemEdit.Top  := Min(CalGrid.Top  + CalGrid.Height - ItemEdit.Height, CalGrid.Top  + CalGrid.CellRect(CalGrid.Col, CalGrid.Row).Top + FCellRenderer.getTextOffset);
        ItemEdit.Show;
        ItemEdit.SetFocus;
        mnuUndo.Enabled := false;
   end;
end;

procedure TfrmCalendar.CalGridDblClick(Sender: TObject);
begin
    HideHyperLinks(0);

    if (CalGrid.Cursor = crHandPoint) and (FPointedURL <> '') then begin
        FHyperlink.OpenHyperLink(FPointedURL);
        Exit;
    end;

    EnterItemEdit;
end;


procedure TfrmCalendar.ItemEditExit(Sender: TObject);
var
  s: string;
begin
    // フォーカスが外れた＝編集が終わったとみなしてデータ更新
    if not FEditing then exit;

    if FEditing then begin
      s := FDocument.getDayText(FEditingDate);
      if s <> ItemEdit.Text then begin
        FDocument.SetDayText(FEditingDate, ItemEdit.Text);
        SetDirty;
      end;
    end;
    ItemEdit.Visible := false;
    mnuUndo.Enabled := false;
    FEditing := false;
end;


procedure TfrmCalendar.CalGridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
    d: TDate;
    rect: TRect;
    d2: TDate;

    hyperlinks: TStrings;
    i: integer;
begin
    if (ACol < 0) or (ARow <=0) then exit;
    // 選択されたセルに合わせてハイパーリンクの表示を更新
    CanSelect := true;

    if (FConfiguration.ShowHyperlinkLabel) then begin

        d := PosToDay(ACol, ARow);
        rect := CalGrid.CellRect(ACol, ARow);
        hyperlinks := TDocumentManager.getInstance.getHyperlinks(d);
        for i:=0 to hyperLinks.Count-1 do begin // item.getHyperLinks.Count-1
            if i > MAX_HYPERLINKS then break;

            if FHyperLinkers[i] = nil then begin
                FHyperLinkers[i] := TStaticText.Create(self);
                FHyperLinkers[i].Parent := self;
                FHyperLinkers[i].Visible := false;
                FHyperLinkers[i].OnDblClick := FHyperlink.HyperLinkDblClick;
            end;

            FHyperLinkers[i].Visible := false;
            FHyperLinkers[i].Left := CalGrid.Left + rect.Left + 4;
            FHyperLinkers[i].Top  := MonthTab.Top + CalGrid.RowHeights[0] + rect.Bottom + i * FHyperLinkers[0].Height;
            FHyperlinkers[i].Font := FFonts.HyperlinkFont;
            FHyperLinkers[i].AutoSize := true;
            FHyperLinkers[i].Caption := hyperlinks[i]; //item.getHyperLinks[i];
            FHyperLinkers[i].AutoSize := false;

            if TURLExtractor.getInstance.isDateURL(FHyperLinkers[i].Caption) then begin
                d2 := DateFormat.parseDate(FHyperLinkers[i].Caption);
                FHyperLinkers[i].Hint := TDocumentManager.getInstance.getHintString(d2);
                FHyperLinkers[i].ShowHint := true;
            end else begin
                FHyperLinkers[i].ShowHint := false;
                FHyperLinkers[i].Hint := '';
            end;

            if FHyperLinkers[i].Left + FHyperLinkers[i].Width > CalGrid.Width then
                FHyperLinkers[i].Width := CalGrid.Width - FHyperLinkers[i].Left - 4;

            if (FHyperLinkers[i].Top + FHyperLinkers[i].Height > MonthTab.Top + MonthTab.Height) then begin
                FHyperLinkers[i].Visible := false;
            end else begin
                FHyperLinkers[i].Visible := true;
            end;

        end;
        HideHyperLinks(hyperlinks.Count);
        TDocumentManager.getInstance.cleanupHyperlinks(hyperlinks);
    end else begin
       HideHyperLinks(0);
    end;

end;

procedure TfrmCalendar.HideHyperLinks(visibleCount: integer);
var i: integer;
begin
    for i:=visibleCount to MAX_HYPERLINKS do begin
        if FHyperLinkers[i] = nil then break;
        FHyperLinkers[i].Visible := false;
    end;
end;



procedure TfrmCalendar.FreeMemoDblClick(Sender: TObject);
// TodoListView, FreeMemo, frmTodoDialog.TodoListView に
// 使われるので一般的な実装になっている
var
    control: TWinControl;
begin
    if Sender is TWinControl then control := TMemo(Sender)
    else exit;

    if control.Cursor <> crHandPoint then exit;
//    if control.Owner is TfrmHintWindow then FHintWindowStack.hideHint(TfrmHintWindow(control.Owner), false);

    FHyperlink.OpenHyperLink(FPointedURL);

    // TMemo.SelStart は正しい値を返さないので
    // URL はキャッシュしておいた値を使う
end;

procedure TfrmCalendar.CalGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
    old: TDate;
    d: TDate;
    base, target: TPageNode;
    b: boolean;
    add: integer;

    procedure ExtendRow(weeks: integer);
    begin
      if weeks > 0 then begin
        FBaseDateProceed := FBaseDateProceed + 7 * weeks;
      end else begin
        FBaseDateBack := FBaseDateBack + 7 * (-weeks);
      end;
      AdjustGridSizeInternal;
      if weeks > 0 then begin
        CalGrid.Row := CalGrid.RowCount-1;
        CalGrid.TopRow := 1 + CalGrid.Row - FGridRows;
      end;
      CalGridSelectCell(Sender, CalGrid.Col, CalGrid.Row, b);
    end;

begin
    case Key of
    VK_RETURN: CalGridDblClick(Sender);
    VK_SPACE: CalGridMouseDown(Sender, mbLeft, Shift, 0, 0);
    VK_DOWN: begin
          if CalGrid.Row = CalGrid.RowCount-1 then begin
              if FConfiguration.AutoExtendRows then begin
                ExtendRow(1);
              end else begin
                MoveDate(IncDay(PosToDay(CalGrid.Col, CalGrid.Row), 7), false);
              end;
              Key := 0;
          end;
        end;
    VK_UP: begin
          if CalGrid.Row = 1 then begin
              if FConfiguration.AutoExtendRows then begin
                ExtendRow(-1);
              end else begin
                MoveDate(IncDay(PosToDay(CalGrid.Col, CalGrid.Row), -7), false);
              end;
              Key := 0;
          end;
        end;
    VK_RIGHT: begin
          if (CalGrid.Col = CalGrid.ColCount-1)and(FConfiguration.CursorCanMoveAnotherRow) then begin
              if (CalGrid.Row < CalGrid.RowCount-1) then begin
                CalGrid.Col := 0;
                CalGrid.LeftCol := 0;
                CalGrid.Row := CalGrid.Row + 1;
                CalGridSelectCell(Sender, CalGrid.Col, CalGrid.Row, b);
              end else if FConfiguration.AutoExtendRows then begin
                CalGrid.Col := 0;
                CalGrid.LeftCol := 0;
                ExtendRow(1);
              end else begin
                MoveDate(IncDay(PosToDay(CalGrid.Col, CalGrid.Row), 1), false);
              end;
              Key := 0;
          end;
        end;
    VK_LEFT: begin
          if (CalGrid.Col = 0)and(FConfiguration.CursorCanMoveAnotherRow) then begin
              if CalGrid.Row > 1 then begin
                CalGrid.Row := CalGrid.Row - 1;
                CalGrid.Col := CalGrid.ColCount-1;
                CalGrid.LeftCol := CalGrid.ColCount - CalGrid.VisibleColCount;
                CalGridSelectCell(Sender, CalGrid.Col, CalGrid.Row, b);
              end else if FConfiguration.AutoExtendRows then begin
                CalGrid.Col := CalGrid.ColCount-1;
                CalGrid.LeftCol := CalGrid.ColCount - CalGrid.VisibleColCount;
                ExtendRow(-1);
              end else begin
                MoveDate(IncDay(PosToDay(CalGrid.Col, CalGrid.Row), -1), false);
              end;
              Key := 0;
          end;
        end;
    VK_NEXT: begin
            old := PosToDay(CalGrid.Col, CalGrid.Row);

            // 翌月へ移動
            if ssCtrl in Shift then begin
                // CTRL キーが押されている場合は次のタブで示されたページへ移動
                if MonthTab.TabIndex = MonthTab.Tabs.Count -1 then begin
                    exit; // Key = 0 にしないのでページ末尾に移動する
                end;

                base := TPageNode(MonthTab.Tabs.Objects[MonthTab.TabIndex]);
                if (old < base.BaseDate) then old := incWeek(old, 1);
                if (old > EndOfTheMonth(base.BaseDate)) then old := incWeek(old, -1);

                target := TPageNode(MonthTab.Tabs.Objects[MonthTab.TabIndex+1]);
                d := IncWeek(old, WeeksBetween(old, target.BaseDate)); // 曜日を変えないよう週単位で移動
                if d < target.BaseDate then d := IncWeek(d, 1); // 月境目の週の場合，１足す必要がある
                // 週をあわせる
                 if NthDayOfWeek(old) = 5 then
                     d := IncWeek(d, 4 - NthDayOfWeek(d))
                  else
                    d := IncWeek(d, NthDayOfWeek(old)-NthDayOfWeek(d));

                MoveDate(d, false);
            end else begin

                if (CalGrid.Row <= CalGrid.RowCount - 5) then begin
                    CalGrid.Row := CalGrid.Row + 4;
                    CalGridSelectCell(Sender, CalGrid.Col, CalGrid.Row, b);
                end else if FConfiguration.AutoExtendRows then begin
                    add := 4 - (CalGrid.RowCount-1-CalGrid.Row);
                    ExtendRow(add);

                end else if old > TabEndDate then begin
                    d := IncWeek(old, 4);
                    // 「先へ進む」場合，最大で翌々月まで進んでしまうので引き戻す
                    while d > EndOfTheMonth(old) do begin
                        d := IncWeek(d, -1);
                    end;
                    MoveDate(d, false);
                end else begin
                    d := IncWeek(old, 4);
                    if MonthOf(d) = MonthOf(FBaseDate) then d := IncWeek(d, 1);
                    MoveDate(d, false);
                end;
            end;

            Key := 0;
        end;
    VK_PRIOR: begin
            old := PosToDay(CalGrid.Col, CalGrid.Row);

            if ssCtrl in Shift then begin
                // CTRL 付きの場合は前のページへ
                if MonthTab.TabIndex = 0 then exit; // Key = 0 でないのは VK_NEXT と同様

                // 月からはみ出しているぶんを修正
                base := TPageNode(MonthTab.Tabs.Objects[MonthTab.TabIndex]);
                if (old < base.BaseDate) then old := incWeek(old, 1);
                if (old > EndOfTheMonth(base.BaseDate)) then old := incWeek(old, -1);

                target := TPageNode(MonthTab.Tabs.Objects[MonthTab.TabIndex-1]);
                d := IncWeek(old, -WeeksBetween(old, EndOfTheMonth(target.BaseDate)));
                if d > EndOfTheMonth(target.BaseDate) then d := IncWeek(d, -1); // 月境目の週の場合，１ずらす必要がある

                if NthDayOfWeek(old) < NthDayOfWeek(d) then
                    d := IncWeek(d, NthDayOfWeek(old)-NthDayOfWeek(d));

                MoveDate(d, false);

            end else begin

              if (CalGrid.Row >= 5) then begin
                CalGrid.Row := CalGrid.Row - 4;
                CalGridSelectCell(Sender, CalGrid.Col, CalGrid.Row, b);
              end else if FConfiguration.AutoExtendRows then begin
                add := 4 - (CalGrid.Row-1);
                ExtendRow(-add);
              end else if old < FBaseDate then begin
                d := IncWeek(old, -4);
                if MonthOf(d) <> MonthOf(old) then d := IncWeek(d, 1);
                MoveDate(d, false);
              end else begin
                d := IncWeek(old, -4);
                if MonthOf(d) = MonthOf(FBaseDate) then d := IncWeek(d, -1);
                MoveDate(d, false);
              end;
            end;
            Key := 0;
        end;
    end;
end;

procedure TfrmCalendar.ItemEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
    ime: HIMC;
    l: Longint;
begin
    ime := ImmGetContext(ItemEdit.Handle);
    l := ImmGetCompositionString(ime, GCS_COMPSTR, nil, 0);

    if ((l = IMM_ERROR_NODATA)or(l=0)) and (KEY = VK_RETURN)and(ssAlt in Shift) then begin
        CalGrid.SetFocus;
    end;

    if (KEY = VK_ESCAPE) //or ((KEY = VK_RETURN)and(ssAlt in Shift))
        then CalGrid.SetFocus;
    ImmReleaseContext(ItemEdit.Handle, ime);
end;

//-----------------------------------------------------------------------------
// ファイル読み書き関連
//-----------------------------------------------------------------------------
procedure TfrmCalendar.mnuExitClick(Sender: TObject);
begin
    Close;
end;

procedure TfrmCalendar.setDirty;
begin
    FDocument.Dirty := true;
end;


function TfrmCalendar.LoadFrom(filename: string): boolean;
// ファイル読み込み -- filename: 新規作成のときは空文字列
var
    Handle: HWND;
    title :string;
begin

    title := GetWindowTitle(filename);

    Handle := FindWindow('TfrmCalendar', PChar(title));
    if (filename <> '')and(Handle <> 0)then begin
        if FIsFirst then begin
            SetForegroundWindow(Handle);
            SendMessage(handle, WM_MY_ACTIVATE, 0, 0);
            //SetForegroundWindow(Handle) //SetWindowPos(Handle, HWND_TOP, 0, 0, 0, 0, SWP_SHOWWINDOW or SWP_NOSIZE or SWP_NOMOVE)
        end else MessageDlg('このファイルはすでに開かれています．', mtInformation, [mbOk], 0);
        Result := false;
        Exit;
    end;



    FFlagLoading := true;
    try
        if TDocumentManager.getInstance.LoadFrom(filename) then begin
            Result := true;
            if filename <> '' then begin
                FConfiguration.FileHistory.Add(filename);
            end;
        end else begin
            MessageDlg(FILE_LOAD_ERROR_MESSAGE + #13#10 + FDocument.LastErrorString, mtError, [mbOK], 0);
            Clipboard.AsText := FILE_LOAD_ERROR_MESSAGE + #13#10 + FDocument.LastErrorString;
            Result := false;
        end;
        updateFileHistoryMenu;
        self.Caption := getWindowTitle(FDocument.Filename);
        mnuUndo.Enabled := false;
        FFreeMemoArea.SelStart := 0;
        FFreeMemoArea.SelLength := 0;
        FTodoUpdateManager.updateAllView;
        TDocumentManager.getInstance.checkoutFreeMemo(FFreeMemoArea);
        UpdateDirectHyperlink(self);

    finally
        FFlagLoading := false;
    end;


end;

function TfrmCalendar.getWindowTitle(filename: string): string;
begin
    Result := APPLICATION_NAME + ' ' + filename;
end;

procedure TfrmCalendar.mnuOpenClick(Sender: TObject);
var
    select: Word;
begin
    if ItemEdit.Focused then CalGrid.SetFocus;

    if FDocument.Dirty then begin
        select := MessageDlg('ファイルは変更されています．保存しますか？', mtInformation, mbYesNoCancel, 0);
        if select = mrYes then begin
            mnuSaveClick(Sender);
            if FDocument.Dirty then Exit;// 「名前をつけて保存」がキャンセルされている
        end else if select = mrCancel then Exit;
        // No の場合は普通に進む
    end;

    if Sender = mnuNewFile then begin
        LoadFrom('');
        CalGrid.Repaint;
        StatusBar1.Repaint;
    end else if OpenDialog1.Execute then begin
        LoadFrom(OpenDialog1.FileName);
        CalGrid.Repaint;
        StatusBar1.Repaint;
    end;
end;


procedure TfrmCalendar.mnuSaveAsClick(Sender: TObject);
begin
    // 編集中のデータがある場合，
    // フォーカスを外して確実に編集を終わらせる
    if ItemEdit.Focused then CalGrid.SetFocus;

    SaveDialog1.FileName := FDocument.Filename;

    if SaveDialog1.Execute then begin
        if TDocumentManager.getInstance.IsReferenceDocument(SaveDialog1.FileName) then begin
            MessageDlg('参照ファイルとして既に使用されている名前は，ファイル名として選択できません．', mtInformation, [mbOK], 0);
        end else begin
            TDocumentManager.getInstance.checkinFreeMemo(FFreeMemoArea); // before FDocument.SaveAs

            try
                FDocument.SaveAs(SaveDialog1.FileName);
            except
                on E: Exception do begin
                    MessageDlg(E.Message, mtError, [mbOK], 0); 
                end;
            end;

            self.Caption := getWindowTitle(FDocument.Filename);
            FConfiguration.FileHistory.Add(FDocument.Filename);
            updateFileHistoryMenu;
            StatusBar1.Repaint;
        end;
    end;
end;

procedure TfrmCalendar.mnuSaveClick(Sender: TObject);
begin
    if ItemEdit.Focused then CalGrid.SetFocus;
    if FDocument.FileName = '' then begin
        mnuSaveAsClick(Sender);
    end else begin
        TDocumentManager.getInstance.checkinFreeMemo(FFreeMemoArea); // before FDocument.SaveAs
        try
            FDocument.SaveAs(FDocument.FileName);
        except
            on E: Exception do begin
                MessageDlg(E.Message, mtError, [mbOK], 0);
            end;
        end;
        StatusBar1.Repaint;
        // caption変更，FileHistoryの更新は必要なし
    end;
end;


procedure TfrmCalendar.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
    select: Integer;
begin

    // 編集中アイテムがあった場合の用心
    if ItemEdit.Focused then Calgrid.SetFocus;

    if FExitWithoutSave then CanClose := true
    else if FConfiguration.AutoSave then begin
        mnuSaveClick(Sender);
        CanClose := (not FDocument.Dirty)and(FDocument.FileName <> '');
    end else if FDocument.Dirty then begin
        select := MessageDlg('ファイルは変更されています．保存しますか？', mtInformation, mbYesNoCancel, 0);
        if select = mrYes then begin
            mnuSaveClick(Sender);
            CanClose := not FDocument.Dirty;
        end else if select = mrNo then begin
            CanClose := true;
        end else if select = mrCancel then begin
            CanClose := false;
        end;
    end;

    if CanClose then begin
        try
            saveConfiguration;
        except
            on E: Exception do begin
                MessageDlg('エラーが発生したため，ini ファイルに設定を保存できませんでした．'#13#10
                    + '次回起動時は，今回起動時の設定を使用します．'#13#10
                    + 'エラー原因は以下のとおりです：'#13#10
                    +  E.Message, mtError, [mbOK], 0);
            end;
        end;
    end;
end;

procedure TfrmCalendar.mnuExitWithoutSaveClick(Sender: TObject);
var
    select: integer;
begin
    select := MessageDlg('ファイルを保存せずに終了してよろしいですか？', mtInformation, mbOKCancel, 0);
    if select = mrOK then begin
        FExitWithoutSave := true;
        Close;
    end;
end;



//-----------------------------------------------------------------------------
// 期間予定関連
//-----------------------------------------------------------------------------
procedure TfrmCalendar.mnuAddRangeClick(Sender: TObject);
begin
    if frmRangeItemEditDialog = nil then Application.CreateForm(TfrmRangeItemEditDialog, frmRangeItemEditDialog);

    if frmRangeItemEditDialog.ExecuteAddItem(FPopupDate) = rrEdit then CalGrid.Repaint;
end;

procedure TfrmCalendar.mnuEditRangeClick(Sender: TObject);
var
    mnu : TMenuItem;
begin
    if frmRangeItemEditDialog = nil then Application.CreateForm(TfrmRangeItemEditDialog, frmRangeItemEditDialog);

    mnu := Sender as TMenuItem;
    if frmRangeItemEditDialog.ExecuteEditItem(FPopupDate, mnu.Tag) <> rrCancel then CalGrid.Repaint;
end;

//-----------------------------------------------------------------------------
// ポップアップメニュー
//-----------------------------------------------------------------------------
procedure TfrmCalendar.CalGridContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
const
    COLOR_PAINT_MENU = 'この日付に色を塗る';
var
    ACol, ARow: integer;
    i: integer;
    l: TStringList;
    d : TDate;
    colorMenu: TMenuItem;
    ranges: TStringList;
    hyperlinks: TStringList;

    function addItem(caption: string; event: TNotifyEvent; tag: integer): TMenuItem;
    var
        mnu: TMenuItem;
    begin
        mnu := TMenuItem.Create(self);
        mnu.Caption := caption;
        mnu.OnClick := event;
        mnu.Tag     := tag;
        Popup.Items.Add(mnu);
        Result := mnu;
    end;

    procedure generateColorMenu;
    var
        i: integer;
    begin
        for i:=0 to COLOR_BOX_COUNT do begin // COUNTより１個多く作る
            FColorEditMenus[i] := TMenuItem.Create(PopupMenu);
            FColorEditMenus[i].OnClick := ColorEditMenuClick;
            FColorEditMenus[i].Tag := i-1;
            FColorEditMenus[i].OnDrawItem := ColorEditPopupDraw;
            FColorEditMenus[i].OnMeasureItem := ColorEditPopupMeasure;
        end;
    end;

    // コンテキストメニュー用に URL の短いバージョンを作る
    function makeHyperlinkCaption(url: string): string;
    var
      s: string;
    begin
        // とりあえず45バイト以上で切り詰め発生
        if Length(url) > 45 then begin
          s := LeftStr(url, 28) + RightStr(url, 13);
          // 抽出結果が本当に前より短くなることを確認（全角が多いと長くなることがある）
          if Length(s) < Length(url) then
            Result := LeftStr(url, 28) + ' ... ' + RightStr(url, 13) + ' を開く'
          else Result := url +' を開く';
        end else Result := url +' を開く';
    end;
begin
    if FColorEditMenus[0] = nil then generateColorMenu;

    colorMenu := Popup.Items.Find(COLOR_PAINT_MENU);
    if colorMenu <> nil then begin
        // 色メニューオブジェクト自体は再利用するので，
        // 親メニューによって解放されないように接続解除
        while colorMenu.Count > 0 do begin
            colorMenu.Delete(0);
        end;
    end;


    Popup.Items.Clear;

    // 位置に応じてセル→日付→item 取得
    CalGrid.MouseToCell(MousePos.X, MousePos.Y, ACol, ARow);
    if ARow = 0 then begin
        FPopupDate := FBaseDate;
        addItem('この曜日を周期予定に加える ...', mnuSeriesIncludeYoubiClick, IfThen(FConfiguration.StartFromMonday, IfThen(ACol=6, 1, ACol+2), ACol+1));
    end else begin
        d := PosToDay(ACol, ARow);

        FPopupDate := d;

        // コンテキストメニューに URL を表示する
        if FConfiguration.ShowHyperlinkContextMenu then begin
            hyperlinks := TDocumentManager.getInstance.getHyperlinks(d);

            // URL のリストをあらかじめ FHyperlink に登録しておく
            FHyperlink.registerHyperLink(hyperlinks);

            // 登録 URL に対応するタグだけ持たせてメニュー作成
            for i:=0 to hyperLinks.Count-1 do begin
                if i > MAX_HYPERLINKS then break;
                addItem(makeHyperlinkCaption(hyperLinks[i]), FHyperlink.HyperLinkDblClick, i);
            end;
            if hyperLinks.Count > 0 then addItem('-', nil, 0);
            TDocumentManager.getInstance.cleanupHyperlinks(hyperlinks);
        end;

        // 期間予定修正メニューを追加
        ranges := TStringList.Create;
        TDocumentManager.getInstance.getRangeNames(d, ranges);
        for i:=0 to ranges.Count-1 do begin
          if ranges[i] <> '' then
            addItem(Ranges[i] + ' の修正', mnuEditRangeClick, i);
        end;
        ranges.Free;

        // 常に表示されるメニューの追加
        addItem('新しい期間予定の追加(&R) ...', mnuAddRangeClick, 0);

        addItem('-', nil, 0);

        colorMenu := addItem(COLOR_PAINT_MENU, nil, 0);
        colorMenu.Add(FColorEditMenus);

        addItem('この日付の色をパレットに抽出', mnuSelectColorToPaletteClick, 0);

        addItem('-', nil, 0);

        addItem('日付メモを切り取り(&X)', mnuCutToClipboardClick, FLAG_EDIT_FROM_POPUP_MENU);
        addItem('日付メモをコピー(&C)', mnuCopyToClipboardClick, FLAG_EDIT_FROM_POPUP_MENU);
        addItem('日付メモを貼り付け(&V)', mnuPasteFromClipboardClick, FLAG_EDIT_FROM_POPUP_MENU);
        addItem('日付メモに追加貼り付け(&A)', mnuAppendPasteClick, FLAG_EDIT_FROM_POPUP_MENU);
        addItem('予定をエクスポート用にコピー(&E)', mnuCopyPopupStringToClipboardClick, FLAG_EDIT_FROM_POPUP_MENU);

        addItem('-', nil, 0);

        // 周期予定修正メニューを追加
        l := TStringList.Create;
        TDocumentManager.getInstance.getEditableSeriesItems(d, l);
        if l.Count > 0 then addItem('-', nil, 0);
        for i:=0 to l.Count-1 do begin
            addItem('この日を ' + l[i] + ' から除く', mnuSeriesExcludeClick, i);
        end;
        l.Free;
        addItem('この日を周期予定に加える ...', mnuSeriesIncludeClick, ACol);
    end;


end;



//-----------------------------------------------------------------------------
// ハイパーリンク Combo box 関連
//-----------------------------------------------------------------------------

procedure TfrmCalendar.DirectHyperLinkBoxKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
    combo: TComboBox;
begin
    if Sender is TComboBox then combo := TComboBox(Sender) else exit;

    if Key = VK_RETURN then begin
        combo.DroppedDown := false;
        combo.OnClick(Sender);
    end else if Key = VK_DOWN then begin
        // 自前で処理 -- カーソルキー移動時に OnClick イベントを起こさせないため
        if not combo.DroppedDown then
            combo.DroppedDown := true
        else
            combo.ItemIndex := combo.ItemIndex+1;
        Key := 0;
    end else if KEY = VK_UP then begin
        if not combo.DroppedDown then
            combo.DroppedDown := true
        else
            combo.ItemIndex := combo.ItemIndex-1;
        KEY := 0;
    end;
end;

procedure TfrmCalendar.DirectHyperLinkBtnClick(Sender: TObject);
begin
    FHyperlink.OpenHyperLink(DirectHyperLinkBox.Text);
    if (DirectHyperLinkBox.Text <> '') and (FURLMemo.IndexOf(DirectHyperLinkBox.Text) = -1)and (FURLCache.IndexOf(DirectHyperLinkBox.Text) = -1) then begin
      DirectHyperLinkBox.AddItem(DirectHyperLinkBox.Text, nil);
      FURLCache.Add(DirectHyperLinkBox.Text);
    end;
end;

procedure TfrmCalendar.updateDirectHyperlink(Sender: TObject);
var
    l: TStringList;
begin
    if FConfiguration.RegisterFreeMemoURLToToolbar then begin
        // キャッシュされたものと，FreeMemo に記入されたものをマージ
        l := TStringList.Create;
        l.Duplicates := dupIgnore;
        l.Sorted := true;
        l.CaseSensitive := true;
        TURLExtractor.getInstance.extractURLs(FFreeMemoArea.Text, FURLMemo, YearOf(date));
        l.AddStrings(FURLMemo);
        l.addStrings(FURLCache);
        DirectHyperLinkBox.Items.Clear;
        DirectHyperLinkBox.Items.AddStrings(l);
        l.Free;
    end;
end;


//-----------------------------------------------------------------------------
// 検索
//-----------------------------------------------------------------------------
procedure TfrmCalendar.TextMarkingClick(Sender: TObject);
begin
    FCellRenderer.MarkingMode := FindMethodBox.ItemIndex;
    FCellRenderer.marking := FindBox.Text;
    CalGrid.Repaint;

    if (Findbox.Text <> '') and (FFindCache.IndexOf(FindBox.Text) = -1) then begin
      FindBox.AddItem(FindBox.Text, nil);
      FFindCache.Add(FindBox.Text);
    end;
end;

procedure TfrmCalendar.FindBtnClick(Sender: TObject);
var
    d: TDate;
    direction : integer;
    ret: TDateTime;
begin
    if FConfiguration.AutoMarkingWhenFind then TextMarkingClick(Sender);
    if FindBox.Text = '' then exit;


    if Sender = FindBackwardBtn then
        direction := -1
    else
        direction := 1;

    // 文字列を探して，次の日付へ移動 (MoveDate)
    d := IncDay(PosToDay(CalGrid.Col, CalGrid.Row), direction);
    if FDocument.FindText(FindBox.Text, d, direction, FindMethodBox.ItemIndex, FConfiguration.MarkingCaseSensitive, ret) then
        MoveDate(ret, true);
end;

procedure TfrmCalendar.setFindCache(target: TStrings);
begin
    target.Clear;
    target.AddStrings(FFindCache);
end;

procedure TfrmCalendar.addFindCache(text: string);
begin
    if FFindCache.IndexOf(text) = -1 then begin
        FFindCache.Add(text);
        FindBox.Items.Add(text);
    end;
end;

procedure TfrmCalendar.setMarking(text: string);
begin
    FCellRenderer.Marking := text;
    FindBox.Text := text;
    CalGrid.Repaint;
end;

//-----------------------------------------------------------------------------
// クリップボード系
//-----------------------------------------------------------------------------
procedure TfrmCalendar.mnuPasteFromClipboardClick(Sender: TObject);
var
    d: TDateTime;
    action: TCalendarAction;
    hwnd: THandle;
    s: string;
    target: TWinControl;
begin
    // 対象コントロールは別ウィンドウのときもある（メインウィンドウのショートカット発動が優先されるため）
    target := Screen.ActiveForm.ActiveControl;
    if target is TCustomEdit then begin
        TCustomEdit(target).PasteFromClipboard;
    end else if target is TCustomCombo then begin
        TCustomCombo(target).Perform(WM_PASTE, 0, 0);
    end else if target is TListView then begin
        if TListView(target).IsEditing then begin
            hwnd := ListView_GetEditControl(target.Handle);
            SendMessage(hwnd, WM_PASTE, 0, 0);
        end;
    end;

    if (target = CalGrid)and
       (CalGrid.Col >= 0) and (CalGrid.Row > 0) and
       Clipboard.HasFormat(CF_TEXT) then begin
        d := PosToDay(CalGrid.Col, CalGrid.Row);
        if (sender as TMenuItem).Tag = FLAG_EDIT_FROM_POPUP_MENU then d := FPopupDate;
        if not isValid(d) then exit;


        s := FDocument.getDayText(d);
        action := CalendarActionFactory.createPasteAction(FActionCallback, FDocument, d, s, Clipboard.AsText);
        FUndoBuffer.pushAction(action);
        action.doAction;
        mnuUndo.Enabled := FUndoBuffer.CanUndo;
    end;
end;

procedure TfrmCalendar.mnuCopyToClipboardClick(Sender: TObject);
var
    d : TDateTime;
    s: string;
    target: TWinControl;
begin
    FFlagClipboardCopying := true;
    // 対象コントロールは別ウィンドウのときもある（メインウィンドウのショートカット発動が優先されるため）
    target := Screen.ActiveForm.ActiveControl;
    if target is TCustomEdit then begin
        TCustomEdit(target).CopyToClipboard;
        s := Clipboard.AsText; // 一回テキスト形式で取り出して，RichEdit の書式を消す
        Clipboard.AsText := s;
    end else if target is TCustomCombo then begin
        TCustomCombo(target).Perform(WM_COPY, 0, 0);
    end else if target is TListView then begin
        if TListView(target).IsEditing then begin
            SendMessage(ListView_GetEditControl(target.Handle), WM_COPY, 0, 0);
        end;
    end;
    FFlagClipboardCopying := false;

    if (target = CalGrid)and
       (CalGrid.Col >= 0) and
        (CalGrid.Row > 0) then begin
        d := PosToDay(CalGrid.Col, CalGrid.Row);
        if (sender as TMenuItem).Tag = FLAG_EDIT_FROM_POPUP_MENU then d := FPopupDate;
        if not isValid(d) then exit;
        s := FDocument.getDayText(d);
        if (s <> '') then Clipboard.AsText := s;
    end;
end;

procedure TfrmCalendar.mnuCopyPopupStringToClipboardClick(Sender: TObject);
var
    d : TDateTime;

begin
    if (CalGrid.Col >= 0) and
        (CalGrid.Row > 0) then begin
        d := PosToDay(CalGrid.Col, CalGrid.Row);
        if (sender as TMenuItem).Tag = FLAG_EDIT_FROM_POPUP_MENU then d := FPopupDate;
        if not isValid(d) then exit;
        Clipboard.AsText := TDocumentManager.getInstance.getHintString(d);
    end;
end;


procedure TfrmCalendar.mnuCutToClipboardClick(Sender: TObject);
var
    d: TDateTime;
    action: TCalendarAction;
    s: string;
    target: TWinControl;
begin
    // 対象コントロールは別ウィンドウのときもある（メインウィンドウのショートカット発動が優先されるため）
    target := Screen.ActiveForm.ActiveControl;
    if target is TCustomEdit then begin
        TCustomEdit(target).CutToClipboard;
        s := Clipboard.AsText; // 一回テキスト形式で取り出して，RichEdit の書式を消す
        Clipboard.AsText := s;
    end else if target is TCustomCombo then begin
        TCustomCombo(target).Perform(WM_CUT, 0, 0);
    end else if target is TListView then begin
        if TListView(target).IsEditing then begin
            SendMessage(ListView_GetEditControl(target.Handle), WM_CUT, 0, 0);
        end;
    end;

    if (target = CalGrid)and
       (CalGrid.Col >= 0) and
       (CalGrid.Row > 0) then begin
        d := PosToDay(CalGrid.Col, CalGrid.Row);
        if (sender as TMenuItem).Tag = FLAG_EDIT_FROM_POPUP_MENU then d := FPopupDate;
        s := FDocument.getDayText(d);
        if s <> '' then begin
            action := CalendarActionFactory.createCutAction(FActionCallback, FDocument, d, s);
            action.doAction;
            FUndoBuffer.pushAction(action);
            mnuUndo.Enabled := FUndoBuffer.CanUndo;
        end;
    end;
end;

procedure TfrmCalendar.mnuAppendPasteClick(Sender: TObject);
var
  d: TDateTime;
  s: string;
  action: TCalendarAction;
  editBox: TCustomEdit;
  target: TWinControl;
begin
    target := Screen.ActiveForm.ActiveControl;
    if (target is TCustomEdit) and not (target is TRichEdit) then begin
        editBox := TCustomEdit(target);
        if not AnsiEndsStr(#13#10, editBox.Text) then
            editBox.Text := editBox.Text + #13#10;
        editBox.Text := editBox.Text + Clipboard.AsText;
    end else if (target = CalGrid)and
       (CalGrid.Col >= 0) and (CalGrid.Row > 0) and
       Clipboard.HasFormat(CF_TEXT) then begin
        d := PosToDay(CalGrid.Col, CalGrid.Row);
        if (sender as TMenuItem).Tag = FLAG_EDIT_FROM_POPUP_MENU then d := FPopupDate;
        if not isValid(d) then exit;

        s := FDocument.getDayText(d);
        action := CalendarActionFactory.createAppendPasteAction(FActionCallback, FDocument, d, s, Clipboard.AsText);
        FUndoBuffer.pushAction(action);
        action.doAction;
        mnuUndo.Enabled := FUndoBuffer.CanUndo;
    end else begin
        // Freememo およびTODOリスト編集中ならただの貼り付け
        mnuPasteFromClipboardClick(Sender);
    end;
end;


procedure TfrmCalendar.mnuUndoClick(Sender: TObject);
var
  target : TWinControl;
begin
    target := Screen.ActiveForm.ActiveControl;
    if target is TCustomEdit then begin
        TCustomEdit(target).Undo;
        mnuUndo.Enabled := TCustomEdit(target).CanUndo;
    end else if target is TListView then begin
        if TListView(target).IsEditing then begin
            SendMessage(ListView_GetEditControl(target.Handle), WM_UNDO, 0, 0);
        end;
    end else if target = CalGrid then begin
        if FUndoBuffer.CanUndo then begin
            FUndoBuffer.rollback(1);
            mnuUndo.Enabled := FUndoBuffer.CanUndo;
            mnuRedo.Enabled := FUndoBuffer.CanRedo;
        end;
    end;
end;



procedure TfrmCalendar.FreeMemoEnter(Sender: TObject);
begin
    FFreeMemoArea.ClearUndo;
    mnuUndo.Enabled := false;
    mnuRedo.Enabled := false;
end;

procedure TfrmCalendar.FreeMemoExit(Sender: TObject);
begin
    updateDirectHyperlink(Sender);
    mnuUndo.Enabled := false;
end;


procedure TfrmCalendar.ItemEditChange(Sender: TObject);
begin
    mnuUndo.Enabled := ItemEdit.CanUndo;
    mnuRedo.Enabled := false;
end;

procedure TfrmCalendar.CalGridEnter(Sender: TObject);
begin
    mnuUndo.Enabled := FUndoBuffer.CanUndo;
    mnuRedo.Enabled := FUndoBuffer.CanRedo;
end;

procedure TfrmCalendar.mnuRedoClick(Sender: TObject);
begin
    if Screen.ActiveForm.ActiveControl = CalGrid then begin
        if FUndoBuffer.CanRedo then begin
            FUndoBuffer.redo(1);
            mnuUndo.Enabled := FUndoBuffer.CanUndo;
            mnuRedo.Enabled := FUndoBuffer.CanRedo;
        end;
    end;
end;


//-----------------------------------------------------------------------------
// ヒント文字列・日付ポップアップ・ハイパーリンク関係
//-----------------------------------------------------------------------------
procedure TfrmCalendar.FreeMemoMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    memo: TCustomMemo;
begin
    if Sender is TCustomMemo then begin
        memo := TCustomMemo(Sender);

        if (FPointedURL <> '') then begin
            memo.SelStart := FPointedStart;
            memo.SelLength := FPointedLength;

            // ItemEdit の編集中はフォーカスを移すと編集が終わってしまうので，ウィンドウには移動しない
            if Sender <> ItemEdit then FHintWindowStack.SetFocusToTopHint;
        end;
    end;

end;

procedure TfrmCalendar.FreeMemoMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
    CaretPos : LongInt;
    CharPosTmp: LongInt;
    CharPos: TPoint;
    memo: TRichEdit;
    edit: TMemo;
    pos:  PPointL;
    year: integer;
begin

    FHintWindowStack.OnMouseMove(Sender, Shift, X, Y);

    if Sender is TRichEdit then begin
        memo := Sender as TRichEdit;

        // EM_CHARFROMPOS は，下位 Word (16bits) に文字位置を返す
        new(pos);
        pos.x := X;
        pos.y := Y;
        CaretPos := memo.Perform(EM_CHARFROMPOS, 0, LPARAM(pos));

        memo.Perform(EM_POSFROMCHAR, WPARAM(pos), CaretPos);
        CharPos.X := pos.x;
        CharPos.Y := pos.y;

        dispose(pos);

        if (CaretPos >= 0)and(CaretPos<Length(memo.Text)) then begin
            // ハイパーリンクするかどうか処理
            testLinkAtCursorPos(memo, memo.Text, YearOf(date), CaretPos+1, x, y, CharPos);
        end else begin
            resetLinkCursor(memo);
        end;

    end else if Sender is TMemo then begin
        edit := Sender as TMemo;

        // クリックでウィンドウロック → 編集解除 直後に Mouse Move が飛んでくるときがある
        if (edit = ItemEdit) and (not FEditing) then exit;

        CaretPos := LoWord( edit.Perform(EM_CHARFROMPOS, 0, MakeLParam(X, Y)));
        CharPosTmp := edit.Perform(EM_POSFROMCHAR, CaretPos, 0);
        CharPos.X := LoWord(CharPosTmp);
        CharPos.Y := HiWord(CharPosTmp);

        year := YearOf(date);
        if (edit = ItemEdit) then year := YearOf(FEditingDate);
        if edit.Parent.ClassType = TfrmHintWindow then begin
            year := YearOf((edit.Parent as TfrmHintWindow).HintDate);
        end;

        if (CaretPos >= 0)and(CaretPos<Length(edit.Text)) then begin
            // ハイパーリンクするかどうか処理
            testLinkAtCursorPos(edit, edit.Text, year, CaretPos+1, x, y, CharPos);
        end else begin
            resetLinkCursor(edit);
        end;
        exit;

    end;

end;


procedure TfrmCalendar.DoShowHint(var HintStr: string; var CanShow: Boolean;
    var HintInfo: THintInfo);
var
  ACol,ARow: Integer;
  ARect: TRect;
  url: string;
  urlpos : TRect;
  day: TDateTime;
begin
     if HintInfo.HintControl = CalGrid then begin
        with HintInfo do begin
            CalGrid.MouseToCell(CursorPos.x, CursorPos.y, ACol, ARow);
            url := FCellRenderer.findURL(CursorPos.x, CursorPos.y, PosToDay(ACol, ARow), urlpos);

            // 日付ならリンク先を表示.
            if (url <> '') then begin
                if FConfiguration.PopupLinkContents and TURLExtractor.getInstance.isDateURL(URL) then begin
                    day := DateFormat.parseDate(url);
                    HintStr := TDocumentManager.getInstance.getHintString(day);
                    CanShow := true;
                    CursorRect.TopLeft := CalGrid.ClientToScreen(urlpos.TopLeft);
                    CursorRect.BottomRight := CalGrid.ClientToScreen(urlpos.BottomRight);
                    if FConfiguration.PopupNoHideTimeout then
                        HideTimeout := High(Integer)
                    else
                        HideTimeout := Application.HintHidePause;

                    FHintWIndowStack.popup(day, HintInfo.HintPos, HintStr, CursorRect, self);

                end else begin
                    CanShow := false;
                end;
            end else begin
                // 通常はセルの中身をヒントとして表示
                if FConfiguration.PopupCellContents then begin
                   if FHintOnCell[ACol][ARow] then begin

                       ARect := CalGrid.CellRect( ACol, ARow );
                       HintPos := CalGrid.ClientToScreen( ARect.TopLeft );

                       day := PosToDay(ACol, ARow);
                       HintStr := TDocumentManager.getInstance.getHintString(day);
                       CanShow := true;
                       CursorRect.TopLeft := HintPos;
                       CursorRect.BottomRight := CalGrid.ClientToScreen(ARect.BottomRight);

                       if FConfiguration.PopupNoHideTimeout then
                           HideTimeout := High(Integer)
                       else
                           HideTimeout := Application.HintHidePause;

                       HintPos.Y := HintPos.Y + CalGrid.Canvas.TextHeight('A'); // 日付より表示位置を少し下げる

                       FHintWindowStack.popup(day, HintInfo.HintPos, HintStr, CursorRect, self);

                   end else begin
                       CanShow := false;
                   end;
                end else begin
                    CanShow := false;
                end;
            end;
        end;
     end;

     // 結局，CanShow = False にしておく（frmHintWindow を別に表示するため）

     CanShow := false;
end;

procedure TfrmCalendar.CalGridMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
    rect: TRect;
    ACol, ARow: integer;
begin
    FHintWindowStack.OnMouseMove(Sender, Shift, X, Y);

    // もし URL があればカーソル変更
    CalGrid.MouseToCell(X, Y, ACol, ARow);
    FPointedURL := FCellRenderer.findURL(x, y, PosToDay(ACol, ARow), rect);
    if FPointedURL <> '' then CalGrid.Cursor := crHandPoint
    else CalGrid.Cursor := crDefault;
end;



//-----------------------------------------------------------------------------
// その他
//-----------------------------------------------------------------------------
procedure TfrmCalendar.FreeMemoChange(Sender: TObject);
begin
    if (not FFlagLoading)and(not FFlagConfiguring)and(not FFlagRepainting) then begin
        setDirty;
        mnuUndo.Enabled := FFreeMemoArea.CanUndo;
    end;
end;

procedure TfrmCalendar.CalGridTopLeftChanged(Sender: TObject);
var
    b: boolean;
begin
    CalGridSelectCell(Sender, CalGrid.Col, CalGrid.Row, b);
end;

procedure TfrmCalendar.mnuShowOptionDialogClick(Sender: TObject);
begin
    if ItemEdit.Focused then CalGrid.SetFocus;

    
    if frmConfigDialog = nil then Application.CreateForm(TfrmConfigDialog, frmConfigDialog);

    if frmConfigDialog.Execute(FConfiguration) then begin

        // 「ページごとの拡大率保存」が設定された場合は，現在の情報をここで保存しておく
        with FConfiguration do begin
            if SaveZoomRate and ZoomRateForEachPage then setZoomRate(YearOf(FBaseDate), monthOf(FBaseDate), FGridRows, FGridCols);
        end;

        // 設定で即座に更新する必要があるものを更新

        FindBox.AutoComplete := FConfiguration.MarkingAutoComplete;
        if frmFindDialog <> nil then frmFindDialog.setSearchOption(FConfiguration.MarkingAutoComplete, FConfiguration.MarkingCaseSensitive);

        FCellRenderer.CellBackColor := FConfiguration.DefaultBackColor;
        FDocument.ColorManager.DefaultBackColor := FConfiguration.DefaultBackColor;
        if PaintToolBar.Visible then PaintToolBar.Repaint;

        FTodoUpdateManager.updateAllView;

        ItemEdit.Font := FFonts.TextFont;
        ItemEdit.Color := FConfiguration.DefaultBackColor;

        FFlagConfiguring := true;
        try
            FFreeMemoArea.Font := FFonts.FreeMemoFont;
            TDocumentManager.getInstance.checkinFreeMemo(FFreeMemoArea);
            TDocumentManager.getInstance.checkoutFreeMemo(FFreeMemoArea);
        finally
            FFlagConfiguring := false;
        end;

        TrayIcon1.Visible := FConfiguration.UseTaskTray;
//        if FConfiguration.UseTaskTray then FTaskTray.CreateTaskBarIcon
//        else FTaskTray.DeleteTaskBarIcon;
    end;
    CalGrid.Repaint;

    // 履歴サイズ等変更に対して更新
    updateFileHistoryMenu;
end;

procedure TfrmCalendar.mnuShowToolbarClick(Sender: TObject);
var
    menu : TMenuItem;
begin
    menu := Sender As TMenuItem;
    menu.Checked := not menu.Checked;
    Coolbar1.Bands[ CoolBar1.Bands.FindItemID(menu.Tag).Index ].Visible  := menu.Checked;
end;



procedure TfrmCalendar.mnuSeriesItemEditClick(Sender: TObject);
begin
    TDocumentManager.getInstance.BeginEditSeriesItems;
    makeSeriesItemEditDialogIfNecessary;
    frmSeriesItemEditDialog.ShowModal;
    TDocumentManager.getInstance.updateSeriesItems;
    CalGrid.Repaint;
    StatusBar1.Repaint;
end;

procedure TfrmCalendar.mnuMoveTodayClick(Sender: TObject);
begin
    MoveDate(Date, FConfiguration.HyperlinkWithEditMode);
end;

procedure TfrmCalendar.mnuOpenReadmeClick(Sender: TObject);
begin
    Application.HelpCommand(HELP_INDEX, 0);
end;

procedure TfrmCalendar.mnuAboutClick(Sender: TObject);
begin
  try
    if frmAbout = nil then Application.CreateForm(TfrmAbout, frmAbout);
    frmAbout.ShowModal;
  except
    on Err: Exception do begin
        MessageDlg('バージョン情報ダイアログ作成時にエラーが発生しました． '#13#10 +
                   '原因は次の通りです． '#13#10 + Err.Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfrmCalendar.mnuFindDialogClick(Sender: TObject);
begin
    makeFindDialogIfNecessary;
    // モーダルでないウィンドウの場合，親ウィンドウに
    // ショートカットが飛んできてしまうらしいので，処理をこちらで行う
    // * TodoDialogについても同様の処理を行っている
    if frmFindDialog.Active then frmFindDialog.Close
    else frmFindDialog.Show;
end;

procedure TfrmCalendar.FormDeactivate(Sender: TObject);
begin
    ItemEditExit(Sender);
end;


procedure TfrmCalendar.mnuPrintClick(Sender: TObject);
begin
  if frmCalendarPrint = nil then Application.CreateForm(TfrmCalendarPrint, frmCalendarPrint);

  if frmCalendarPrint.available then begin
    try
      TDocumentManager.getInstance.checkinFreeMemo(FFreeMemoArea); // before FDocument.SaveAs
      frmCalendarPrint.Config   := FConfiguration;
      frmCalendarPrint.BaseDate := FBaseDate;
      frmCalendarPrint.Filename := FDocument.Filename;
      frmCalendarPrint.ShowModal;
    except
    end;
  end else begin
      MessageDlg('プリンタへのアクセスに失敗したため，現在印刷機能は無効です．', mtError, [mbOK], 0);
  end;
end;

procedure TfrmCalendar.CoolBar1Change(Sender: TObject);
begin
    DirectHyperLinkBox.Width := URLToolbar.ClientWidth - DirectHyperLinkBtn.Width - DirectHyperlinkBox.Left;
end;


procedure TfrmCalendar.ApplicationMinimized(Sender: TObject);
begin
    if FEditing then ItemEditExit(sender);
    if frmFindDialog <> nil then begin
        frmFindDialog.isAlreadyShown := frmFindDialog.Visible;
        frmFindDialog.Close;
    end;
    if FConfiguration.UseTaskTray then begin
        ShowWindow(Application.Handle, SW_HIDE);
//        FIsIconic := true;

//        FTaskTray.HideApplication;
    end;
end;

procedure TfrmCalendar.ApplicationRestored(Sender: TObject);
begin
  if (frmFindDialog <> nil) and frmFindDialog.isAlreadyShown then frmFindDialog.Show;
end;

procedure TfrmCalendar.mnuTodoClick(Sender: TObject);
begin
    if frmTodoDialog = nil then Application.CreateForm(TfrmTodoDialog, frmTodoDialog);
    if frmTodoDialog.Active then frmTodoDialog.Close
    else frmTodoDialog.Show;
end;


procedure TfrmCalendar.execDialogShortcut(Sender: TForm; Key: Word; Shift: TShiftState);

    function isModalForm(frm: TForm): boolean;
    begin
        Result := (frm = frmSeriesItemEditDialog) or
                  (frm = frmCalendarPrint);
    end;

    function testShortcut(mnu: TMenuItem; frm: TForm): boolean;
    var
        k: Word;
        s: TShiftState;
    begin
        // 注: frm がまだ nil の場合，Sender = frm が成り立たないので Close が起きないだけ．
        ShortCutToKey(mnu.Shortcut, k, s);
        if (Shift = s) and (Key = k) then begin
            if FConfiguration.EnableDialogCloseShortcut and
               (Sender = frm) then Sender.Close
            else begin
                // Sender が当該フォームでなければ，ウィンドウ開く
                if not isModalForm(Sender) then mnu.OnClick(Sender);
            end;
            Result := true;
        end else Result := false;
    end;

begin

    if (Key = VK_ESCAPE) then Sender.Close
    else begin
        testShortcut(mnuFindDialog, frmFindDialog);
        testShortcut(mnuTodo, frmTodoDialog);
        testShortcut(mnuSeriesItemEdit, frmSeriesItemEditDialog);
        testShortcut(mnuMoveToday, frmCalendar);
        testShortcut(mnuPrint, frmCalendarPrint);
    end;

end;




procedure TfrmCalendar.mnuAddTodoClick(Sender: TObject);
begin
    FTodoUpdateManager.addTodo(TodoListView);
end;


procedure TfrmCalendar.mnuDeleteTodoClick(Sender: TObject);
begin
    FTodoUpdateManager.deleteTodo(TodoListView.Selected);
end;

procedure TfrmCalendar.TodoListViewEdited(Sender: TObject; Item: TListItem;
  var S: String);
begin
    if (item.Data <> nil) then begin
        FTodoUpdateManager.updateCaption(item, s);
        CalGrid.Repaint;
    end;
end;

procedure TfrmCalendar.TodoListViewChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
    // フォーム破棄途中に呼ばれた場合は無視する
    if not Self.Visible then exit;

    if ((item.Data <> nil)and(not item.Deleting)) then begin // 削除中の項目は飛ばす
        if Change = ctState then begin
            FTodoUpdateManager.updateCheckbox(item);
        end;
    end;
end;

procedure TfrmCalendar.mnuEditTodoClick(Sender: TObject);
begin
    if TodoListView.Selected <> nil then TodoListView.Selected.EditCaption;
end;

procedure TfrmCalendar.mnuRefreshTodoClick(Sender: TObject);
begin
    FTodoUpdateManager.updateAllView;
end;

procedure TfrmCalendar.TodoListViewMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
// TodoListView, frmTodoDialog.TodoListView に
// 使われるのでコントロールがパラメータ化された実装になっている
var
    item: TListItem;
    w: integer;
    l: integer;
    view: TListView;
    CharPos: TPoint;
    rect: TRect;
begin
    FHintWindowStack.OnMouseMove(Sender, Shift, X, Y);

    view := Sender as TListView;

    item := view.GetItemAt(x, y);
    if item <> nil then begin

        rect := item.DisplayRect(drLabel);
        if (rect.Top <= y) and (y <= rect.Bottom) then begin
            w := X - rect.Left;

            if w >= 0 then begin

                l := 1;
                while (view.Canvas.TextWidth(Copy(item.Caption, 1, l)) < w) and
                      (l <= Length(item.Caption)) do inc(l);

                if l <= Length(Item.Caption) then begin

                    CharPos.X := view.Canvas.TextWidth(Copy(item.Caption, 1, l));
                    CharPos.Y := rect.Top;
                    testLinkAtCursorPos(view, item.Caption, YearOf(FTodoUpdateManager.getTodoLastUpdated(item)), l, x, y, CharPos);
                    exit;
                end;
            end;
        end;
    end;

    // ここまできたらリンクなし
    view.Cursor:= crDefault;
    FPointedURL := '';
end;

// ハイパーリンク用のカーソル初期化
procedure TfrmCalendar.resetLinkCursor(target: TWinControl);
begin
    target.Cursor:= crDefault;
    FPointedURL := '';
end;

// マウスカーソル(x, y) が Target コントロール上の文字列 text の
//  idx 文字目をポイントしているときにヒント文字列を表示するかどうかの処理
procedure TfrmCalendar.testLinkAtCursorPos(target: TWinControl; text: string; year, idx: integer; x,y : integer; charPos: TPoint);
var
    url_idx, len: integer;
    url: string;
    day: TDateTime;
    s: string;
    p: TPoint;
    ARect: TRect;

    pos: PPOINTL;
    w, h: integer;
    CharPosTmp: LongInt;

    window: TWinControl;


    procedure calcFontSize(font: TFont; var width, height: integer);
    var
        pointedURL: string;
    begin
        pointedURL := Copy(text, url_idx, len);
        FontTester.Canvas.Font := font; // self.Canvas などを使うと再描画が発生してしまう
        width := FontTester.Canvas.TextWidth(pointedURL);
        height := FontTester.Canvas.TextHeight(pointedURL);
    end;

begin
    TURLExtractor.getInstance.extractURL(idx, text, url_idx, url);
    if url <> '' then begin
        target.Cursor:= crHandPoint;
        FPointedURL := url;
        FPointedStart := url_idx-1;
        FPointedLength := Length(FPointedURL);
        exit;
    end else  begin

        // 日付型の場合は内容をポップアップ
        TURLExtractor.getInstance.extractDate(idx, text, year, url_idx, len, day);
        if day > 0 then begin
            target.Cursor:= crHandPoint;

            FPointedURL := DateToStr(day); //Copy(text, url_idx, len);
            FPointedStart := url_idx-1; 
            FPointedLength := len;

            if (FConfiguration.PopupLinkContents) then begin
                s := TDocumentManager.getInstance.getHintString(day);
                p := target.ClientToScreen(Point(x, y));


                if target is TRichEdit then begin
                    calcFontSize((target as TRichEdit).Font, w, h);
                    new(pos);
                    (target as TRichEdit).Perform(EM_POSFROMCHAR, Integer(pos), url_idx-1);  // zero-based index なので -1
                    CharPos.X := pos.x - 4; // マージンを設定する必要あり
                    CharPos.Y := pos.y - 4;
                    ARect.TopLeft := target.ClientToScreen(CharPos);
                    CharPos.X := pos.x + w + 4;
                    CharPos.Y := pos.y + h + 4;
                    ARect.BottomRight := target.ClientToScreen(CharPos);
                    dispose(pos);
                end else if target is TMemo then begin
                    calcFontSize((target as TMemo).Font, w, h);
                    CharPosTmp := (target as TMemo).Perform(EM_POSFROMCHAR, url_idx-1, 0);  // zero-based index なので -1
                    CharPos.X := LoWord( CharPosTmp);
                    CharPos.Y := HiWord(CharPosTmp);
                    Dec(CharPos.X, 4); // マージンを設定する必要あり
                    Dec(CharPos.Y, 4);
                    ARect.TopLeft := target.ClientToScreen(CharPos);
                    CharPos.X := CharPos.x + 4 + w + 4;
                    CharPos.Y := CharPos.y + 4 + h + 4;
                    ARect.BottomRight := target.ClientToScreen(CharPos);
                end else if target is TListView then begin
                    calcFontSize((target as TListView).Font, w, h);
                    CharPos.X := (target as TListView).getItemAt(X, Y).Left + (target as TListView).StringWidth(Copy(text, 1, url_idx-1));
                    ARect.TopLeft := target.ClientToScreen(CharPos);
                    ARect.BottomRight := target.ClientToScreen( (target as TListView).getItemAt(x, y).DisplayRect(drLabel).BottomRight );
                    ARect.Right := ARect.Left + w;
                end;

                // HintWindow 上でハイパーリンクしてる場合は，子ヒントを出す
                p.X := p.X + 12;
                p.Y := p.Y + 20;

                window := target;
                repeat window := window.Parent; until ((window is TCustomForm)or(window = nil));
                FHintWindowStack.popup(day, p, s, ARect, window as TCustomForm);
            end;

        end else begin
            resetLinkCursor(target);
        end;
    end;
end;




procedure TfrmCalendar.StatusBar1DrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
var
  text, item: string;
  i: integer;
const
  LEFT_MARGIN = 4;
begin
  text := getStatusString;
    for i:=0 to FDocument.getCountdownItemCount-1 do begin
        if FDocument.getCountdownItem(i).toString(item) then begin
            text := text + item + '    ';
        end;
    end;
    StatusBar.Canvas.TextOut(LEFT_MARGIN + Rect.Left, Rect.Top, text);
end;

procedure TfrmCalendar.TodoPopupMenuPopup(Sender: TObject);
begin
    FTodoUpdateManager.setupTodoLinkPopupMenu(TodoListView, TodoPopupMenu);
end;

procedure TfrmCalendar.TrayIcon1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    if Button = mbLeft then begin
      FHintWindowStack.HideAllHint;
      ActivateApplication;
    end else if Button = mbRight then begin
      ShowTodayHint;
    end;
end;

procedure TfrmCalendar.mnuReferenceManageClick(Sender: TObject);
begin
    // 参照管理ダイアログを表示
    if frmReferenceDialog = nil then Application.CreateForm(TfrmReferenceDialog, frmReferenceDialog);
    frmReferenceDialog.ShowModal;

    // すべての表示をアップデート
    FTodoUpdateManager.updateAllView;
    try
        FFlagRepainting := true;
        TDocumentManager.getInstance.checkinFreeMemo(FFreeMemoArea);
        TDocumentManager.getInstance.checkoutFreeMemo(FFreeMemoArea);
    finally
        FFlagRepainting := false;
    end;
    CalGrid.Repaint;
end;

procedure TfrmCalendar.TodoListViewEnter(Sender: TObject);
begin
    mnuUndo.Enabled := true;
end;


procedure TfrmCalendar.mnuSeriesExcludeClick(Sender: TObject);
// [指定日付を，周期予定から除外する] コンテキストメニュー
begin
    // FPopupDate, Tag 番目の項目を削除する
    // * ダイアログを表示しないので，BeginEdit は使わない
    makeSeriesItemEditDialogIfNecessary;
    if frmSeriesItemEditDialog.AddExcludedDateToSelectedItem(FPopupdate, (Sender as TMenuItem).Tag) then begin
        setDirty;
    end;
    CalGrid.Repaint;
    StatusBar1.Repaint;
end;

procedure TfrmCalendar.mnuSeriesIncludeClick(Sender: TObject);
begin
    TDocumentManager.getInstance.BeginEditSeriesItems;
    makeSeriesItemEditDialogIfNecessary;
    if frmSeriesItemEditDialog.AddDateToSomeItem(FPopupDate) then begin
        setDirty;
    end;
    TDocumentManager.getInstance.updateSeriesItems;
    CalGrid.Repaint;
    StatusBar1.Repaint;
end;

procedure TfrmCalendar.mnuSeriesIncludeYoubiClick(Sender: TObject);
begin
    TDocumentManager.getInstance.BeginEditSeriesItems;
    makeSeriesItemEditDialogIfNecessary;
    if frmSeriesItemEditDialog.AddYoubiToSomeItem(FPopupDate, (Sender as TMenuItem).Tag) then begin
        setDirty;
    end;
    TDocumentManager.getInstance.updateSeriesItems;
    CalGrid.Repaint;
    StatusBar1.Repaint;
end;

procedure TfrmCalendar.mnuMoveUpTodoClick(Sender: TObject);
begin
    // 編集中のショートカットキーによるアイテム移動を防ぐ
    if not TodoListView.IsEditing then
        FTodoUpdateManager.moveUpTodo(TodoListView.Selected);
end;

procedure TfrmCalendar.mnuMoveDownTodoClick(Sender: TObject);
begin
    // 編集中のショートカットキーによるアイテム移動を防ぐ
    if not TodoListView.IsEditing then
        FTodoUpdateManager.moveDownTodo(TodoListView.Selected);
end;

procedure TfrmCalendar.mnuCopyTodoListToClipboardClick(Sender: TObject);
begin
    FTodoUpdateManager.copyToClipboard;
end;

procedure TfrmCalendar.mnuCopyTodoListClick(Sender: TObject);
begin
    FTodoUpdateManager.copyToClipboard;
end;

procedure TfrmCalendar.mnuEditToolNormalClick(Sender: TObject);
begin
    EditToolSelectButton.ImageIndex := mnuEditToolNormal.ImageIndex;
    FPaintToolSelected := false;
end;

procedure TfrmCalendar.mnuEditToolPaintClick(Sender: TObject);
begin
    EditToolSelectButton.ImageIndex := mnuEditToolPaint.ImageIndex;
    FPaintToolSelected := true;
end;

procedure TfrmCalendar.PaintColorBoxClick(Sender: TObject);
var
    box: TPaintBox;
begin
    if Sender <> SelectedColorPaintBox then begin
        box := Sender as TPaintBox;
        FDocument.ColorManager.selectColor(box.Tag);
        SelectedColorPaintBox.Repaint;
    end;

    if (not FPaintToolSelected) and (CalGrid.Col>=0) and (CalGrid.Row>0) then begin
        FDocument.ColorManager.updateColor(PosToDay(CalGrid.Col, CalGrid.Row), self.ActionCallback, FUndoBuffer);
        setDirty;
        mnuUndo.Enabled := FUndoBuffer.CanUndo;
    end;
end;

procedure TfrmCalendar.PaintColorBoxPaint(Sender: TObject);
const
    MARGIN = 2;
var
    box: TPaintBox;
    rect: TRect;
begin
    box := Sender as TPaintBox;
    box.Canvas.Brush.Color := CoolBar1.Bands[0].Color;

    box.Canvas.FillRect(box.Canvas.ClipRect);
    rect := box.ClientRect; //box.Canvas.ClipRect;
    rect.Left := rect.Left + MARGIN;
    rect.Top  := rect.Top  + MARGIN;
    rect.Bottom := rect.Bottom - MARGIN;
    rect.Right  := rect.right  - MARGIN;

    if Sender = SelectedColorPaintBox then
        FDocument.ColorManager.paintColorBox(-1, box.Canvas, rect)
    else
        FDocument.ColorManager.paintColorBox(box.Tag, box.Canvas, rect);
end;

procedure TfrmCalendar.mnuEditToolColorConfigClick(Sender: TObject);
begin
    if frmPaintColorConfig = nil then Application.CreateForm(TfrmPaintColorConfig, frmPaintColorConfig);

    frmPaintColorConfig.ColorManager := FDocument.ColorManager;
    frmPaintColorConfig.ShowModal;
    if PaintToolbar.Visible then PaintToolbar.Repaint;
end;

procedure TfrmCalendar.CalGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    if (FPaintToolSelected) and (Button = mbLeft) and (CalGrid.Col>=0) and (CalGrid.Row>0) then begin
        FDocument.ColorManager.updateColor(PosToDay(CalGrid.Col, CalGrid.Row), self.ActionCallback, FUndoBuffer);
        setDirty;
        mnuUndo.Enabled := true;
    end;

end;

//procedure TfrmCalendar.TodoListViewKeyPress(Sender: TObject;
//  var Key: Char);
//var
//    Imc:HIMC;
//    dwConversion, dwSentence: DWORD;
//begin
//    if TodoListView.IsEditing then exit;
//
//    Imc := ImmGetContext(TodoListView.Handle);
//    ImmGetConversionStatus(Imc, dwConversion, dwSentence);
//    ImmReleaseContext(TodoListView.Handle, Imc);

    // 英語モードの場合，IME の設定は日本語モードのときと変わらないが
    // 既にチェックボックスの状態が変化した状態で２度目のイベントが飛んできてしまう.
    // そこで，KeyDown イベント時に保管した状態から変わったかどうかで判定する
    // -- KeyDown のときから変わっていない状態のときだけ処理を行う

//    if (Key = ' ') and (TodoListView.ItemFocused <> nil) then
//        TodoListView.ItemFocused.Checked := not TodoListView.ItemFocused.Checked;

//    If ((dwConversion And IME_CMODE_FULLSHAPE) = 0)and(Key=' ')and
//        (TodoListView.ItemFocused <> nil)and
//        (FTodoListViewBeforeKeyDown = TodoListView.ItemFocused.Checked) Then begin
//        TodoListView.ItemFocused.Checked := not TodoListView.ItemFocused.Checked;
//        key := #0;
//    end;
//
//end;

//procedure TfrmCalendar.TodoListViewKeyDown(Sender: TObject; var Key: Word;
//  Shift: TShiftState);
//begin
//    if TodoListView.ItemFocused <> nil then
//        FTodoListViewBeforeKeyDown := TodoListView.ItemFocused.Checked;
//end;

// 色塗りメニュー選択時の動作
procedure TfrmCalendar.ColorEditMenuClick(Sender: TObject);
var
    menu: TMenuItem;
begin
    menu := Sender as TMenuItem;
    FDocument.ColorManager.updateColorByIndex(FPopupDate, self.ActionCallback, FUndoBuffer, menu.Tag);
    setDirty;
    mnuUndo.Enabled := FUndoBuffer.CanUndo;
end;


const
    COLOR_MENU_NAME: array [0..COLOR_BOX_COUNT] of string =
     ('現在の選択色', 'パレット１', 'パレット２', 'パレット３',
     'パレット４', 'パレット５', 'パレット６');

// 色塗りメニューの表示
procedure TfrmCalendar.ColorEditPopupDraw(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
var
    m: TMenuItem;
    rect: TRect;
begin
    if Selected then begin
        ACanvas.Brush.Color := clHighlight;
        ACanvas.FillRect(ARect);
    end else begin
        ACanvas.Brush.Color := clMenu;
        ACanvas.FillRect(ARect);
    end;

    m := Sender as TMenuItem;
    rect.Left := ARect.Left + 2;
    rect.Top  := ARect.Top + 2;
    rect.Bottom := ARect.Bottom - 2;
    rect.Right  := Rect.Left + 20;
    FDocument.ColorManager.paintColorBox(m.Tag, ACanvas, rect);
    if Selected then begin
        ACanvas.Brush.Color := clHighlight;
    end else begin
        ACanvas.Brush.Color := clMenu;
    end;
    ACanvas.Font.Color := clMenuText;
    ACanvas.TextOut(Rect.Right + 2, Rect.Top, COLOR_MENU_NAME[m.Tag+1]);
end;

// 色塗りメニューのサイズ計算
procedure TfrmCalendar.ColorEditPopupMeasure(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
var
    i: integer;
begin
    i := (Sender as TMenuItem).Tag;
    width := 32 + ACanvas.TextWidth(COLOR_MENU_NAME[i+1]);
    height := 24;
end;

procedure TfrmCalendar.mnuSelectColorToPaletteClick(Sender: TObject);
begin
    FDocument.ColorManager.selectDateColor(FPopupDate);
    SelectedColorPaintBox.Invalidate;
end;

procedure TfrmCalendar.mnuShowFreeMemoAreaClick(Sender: TObject);
begin
    (Sender as TMenuItem).Checked := not (Sender as TMenuItem).Checked;
    FreeMemoAreaPanel.Visible := (Sender as TMenuItem).Checked;

    BottomAreaPanel.Visible := TodoListView.Visible or FreeMemoAreaPanel.Visible;
    Splitter1.Visible := BottomAreaPanel.Visible;
    adjustGridSize(Sender);
end;

procedure TfrmCalendar.mnuShowTodoAreaClick(Sender: TObject);
begin
    (Sender as TMenuItem).Checked := not (Sender as TMenuItem).Checked;
    TodoListView.Visible := (Sender as TMenuItem).Checked;

    if not TodoListView.Visible then begin
        FConfiguration.MemoWidth := self.FreeMemoAreaPanel.Width;
        FreeMemoAreaPanel.Width := BottomAreaPanel.Width
    end else begin
        // TODOリストを出すとき，MemoWidth が既に画面全幅のときは TODO リストの幅を自動で確保
        if FConfiguration.MemoWidth >= self.BottomAreaPanel.Width then
             FreeMemoAreaPanel.Width := (FConfiguration.MemoWidth * 6) div 10 - Splitter2.Width
        else
            FreeMemoAreaPanel.Width := FConfiguration.MemoWidth;
    end;
    BottomAreaPanel.Visible := TodoListView.Visible or FreeMemoAreaPanel.Visible;
    Splitter1.Visible :=BottomAreaPanel.Visible;
    adjustGridSize(Sender);
end;


procedure TfrmCalendar.mnuFileHistoryOpen(Sender: TObject);
var
    item: TMenuItem;
    CanClose: boolean;
    select: integer;
begin
    // 編集中アイテムがあった場合の用心
    if ItemEdit.Focused then Calgrid.SetFocus;

    //if FConfiguration.AutoSave then begin
    //    mnuSaveClick(Sender);
    //    CanClose := (not FDocument.Dirty)and(FDocument.FileName <> '');
    if FDocument.Dirty then begin
        select := MessageDlg('ファイルは変更されています．保存しますか？', mtInformation, mbYesNoCancel, 0);
        if select = mrYes then begin
            mnuSaveClick(Sender);
            CanClose := not FDocument.Dirty;
        end else if select = mrNo then begin
            CanClose := true;
        end else begin // if select = mrCancel
            CanClose := false;
        end;
    end else CanClose := true;

    if CanClose then begin
        item := Sender as TMenuItem;
        LoadFrom(FConfiguration.FileHistory.getFilename(item.Tag));
        CalGrid.Repaint;
        StatusBar1.Repaint;
    end;

end;

procedure TfrmCalendar.FreeMemoProtectChange(Sender: TObject; StartPos, EndPos: Integer; var AllowChange: Boolean);
begin
    AllowChange := FFlagLoading or FFlagClipboardCopying or FFlagConfiguring or FFlagRepainting;
end;

procedure TfrmCalendar.updateFileHistoryMenu;
var
    item: TMenuItem;
    i: integer;
    size: integer;
begin
    // メニュー個数が足りなければ追加
    size := FConfiguration.FileHistory.Size;
    while mnuFile.Count < FDefaultFileMenuCount + size do begin
        item:= TMenuItem.Create(mnuFile);
        mnuFile.Add(item);
    end;
    // 余ってるぶんは削除
    while mnuFile.Count > FDefaultFileMenuCount + size do begin
        mnuFile.Items[mnuFile.Count-1].Free;
    end;
    // 更新
    for i:=0 to FConfiguration.FileHistory.Size-1 do begin
        item := mnuFile.Items[mnuFile.Count-FConfiguration.FileHistory.Size+i];
        item.Caption := '&' + IntToStr(i) + ' ' + FConfiguration.FileHistory.getFilename(i);
        item.Tag := i;
        item.OnClick := mnuFileHistoryOpen;
        item.Visible := FConfiguration.FileHistory.isEnable(i);
    end;
end;

procedure TfrmCalendar.TodoListViewEditing(Sender: TObject;
  Item: TListItem; var AllowEdit: Boolean);
begin
    AllowEdit := FTodoUpdateManager.isEditable(TodoListView.ItemFocused);
end;

procedure TfrmCalendar.TodoListViewCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
    if FTodoUpdateManager.getTodoItem(item) = nil then begin
        // 参照アイテムでは背景色を変える
        Sender.Canvas.Brush.Color := RGB(200, 200, 200);
        Sender.Canvas.Brush.Style := bsSolid;
    end else begin
        Sender.Canvas.Brush.Style := bsClear;
    end;
    DefaultDraw := true;
end;

procedure TfrmCalendar.mnuReferenceReloadClick(Sender: TObject);
begin
    TDocumentManager.getInstance.ReloadReferences;
    FTodoUpdateManager.updateAllView;
    try
        FFlagLoading := true;
        TDocumentManager.getInstance.checkinFreeMemo(FFreeMemoArea);
        TDocumentManager.getInstance.checkoutFreeMemo(FFreeMemoArea);
    finally
        FFlagLoading := false;
    end;
    CalGrid.Repaint;
end;

procedure TfrmCalendar.mnuExportClick(Sender: TObject);
begin
    if frmExportDialog = nil then Application.CreateForm(TfrmExportDialog, frmExportDialog);
    frmExportDialog.ShowModal;
end;

procedure TfrmCalendar.PresetZoomRateButtonClick(Sender: TObject);
begin
    mnuAddPresetZoomRateClick(Sender);
end;

procedure TfrmCalendar.updatePresetZoomRateMenu;
var
    i: integer;
    item: TMenuItem;
    rows, cols: integer;
const
    DEFAULT_MENU_COUNT = 3;
begin
    // アイテムを一度クリア
    while PresetZoomRatePopupMenu.Items.Count > DEFAULT_MENU_COUNT do begin
        PresetZoomRatePopupMenu.Items[DEFAULT_MENU_COUNT].Free;
    end;

    // リストを追加
    for i:=0 to FConfiguration.getPresetZoomRateCount-1 do begin
        item := TMenuItem.Create(PresetZoomRatePopupMenu.Items);
        FConfiguration.getPresetZoomRate(i, rows, cols);
        item.Caption := IntToStr(cols) + '日x' + IntToStr(rows) + '週';
        item.Tag := i;
        item.OnClick := mnuRestorePresetZoomRate;
        PresetZoomRatePopupMenu.Items.Add(item);
    end;
end;

procedure TfrmCalendar.mnuAddPresetZoomRateClick(Sender: TObject);
begin
    FConfiguration.addPresetZoomRate(FGridRows, FGridCols);
    updatePresetZoomRateMenu;
end;

procedure TfrmCalendar.mnuRestorePresetZoomRate(Sender: TObject);
var
    i: integer;
begin
    if (Sender is TMenuItem) then begin
        i := (Sender as TMenuItem).Tag;
        if (i>=0)and(i<FConfiguration.getPresetZoomRateCount) then begin
            FConfiguration.getPresetZoomRate(i, FGridRows, FGridCols);
            ZoomRateRows.Text := IntToStr(FGridRows) + '週';
            ZoomRateColumns.ItemIndex := FGridCols - 1;
            adjustGridSize(Sender);
        end;
    end;
end;

procedure TfrmCalendar.mnuRemovePresetZoomRateClick(Sender: TObject);
begin
    FConfiguration.removePresetZoomRate(FGridRows, FGridCols);
    updatePresetZoomRateMenu;
end;

procedure TfrmCalendar.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if (Key = VK_ESCAPE) then begin
        FHintWindowStack.notifyESC(Key);
    end;
end;

procedure TfrmCalendar.TodoListViewClick(Sender: TObject);
begin
    if (FPointedURL <> '') then begin
        FHintWindowStack.SetFocusToTopHint;
    end;
end;

procedure TfrmCalendar.CalGridClick(Sender: TObject);
begin
    // シングルクリックでのポップアップウィンドウのロック
    if (CalGrid.Cursor = crHandPoint) and (FPointedURL <> '') then begin
        FHintWindowStack.SetFocusToTopHint;
    end;
end;

procedure TfrmCalendar.mnuImportClick(Sender: TObject);
begin
    if frmImportDialog = nil then  Application.CreateForm(TfrmImportDialog, frmImportDialog);

    if frmImportDialog.FileOpenDialog.Execute then begin
        frmImportDialog.ShowModal;
        if frmImportDialog.ImportApply then begin
            setDirty;
            CalGrid.Repaint;
        end;
    end;
end;

procedure TfrmCalendar.makeFindDialogIfNecessary;
begin
    if frmFindDialog = nil then begin
        Application.CreateForm(TfrmFindDialog, frmFindDialog);
        frmFindDialog.setSearchOption(FConfiguration.MarkingAutoComplete, FConfiguration.MarkingCaseSensitive);

        // 起動時にデータを読み込んでいて，かつそれが有効なら復帰する
        if FSetSavedFindDialogPos and (frmFindDialog.Width > 0) and (frmFindDialog.Height > 0) then begin
            frmFindDialog.Left   := FConfiguration.FinderWindowLeft;
            frmFindDialog.Top    := FConfiguration.FinderWindowTop;
            frmFindDialog.Width  := FConfiguration.FinderWindowWidth;
            frmFindDialog.Height := FConfiguration.FinderWindowHeight;
        end else begin
            frmFindDialog.Left := (Screen.Width - frmFindDialog.Width) div 2;
            frmFindDialog.Top := (Screen.Height - frmFindDialog.Height) div 2;
        end;
    end;
end;

procedure TfrmCalendar.processDroppedFile(handle: Integer);
var
    pos: TPoint;
    gridPos: TPoint;
    size: integer;
    buf: PAnsiChar;
    fileCount: integer;
    i: integer;
    link: string;

    ACol, ARow: integer;
    d: TDateTime;
    s: string;
    action: TCalendarAction;
begin
    DragQueryPoint(handle, pos);
    gridPos := CalGrid.ParentToClient(pos, self);
    CalGrid.MouseToCell(gridPos.X, gridPos.Y, ACol, ARow);

    fileCount := DragQueryFile(handle, $ffffffff, nil, 0); // ファイル数取得
    for i := 0 to fileCount - 1 do begin
        if i>0 then link := link + #13#10;

        size := DragQueryFile(handle, i, nil, 0); // 文字数取得．ただし size は終端 NUL 分を含まない
        buf := StrAlloc(size + 1);                // NUL 文字ぶん +1 してバッファ確保
        DragQueryFile(handle, i, buf, size+1);
        link := link + 'file:"' + string(buf) + '"';
        StrDispose(buf);
    end;

    if (ARow > 0) and (ACol >= 0) then begin
        if FEditing then ItemEditExit(self); // もし予定編集中なら解除

        // 「追加貼り付け」アクションを作ってしまう
        d := PosToDay(ACol, ARow);
        s := FDocument.getDayText(d);
        action := CalendarActionFactory.createAppendPasteAction(FActionCallback, FDocument, d, s, link);
        FUndoBuffer.pushAction(action);
        action.doAction;
        mnuUndo.Enabled := FUndoBuffer.CanUndo;
    end else begin
        pos := FFreeMemoArea.ParentToClient(pos, self);
        if InRange(pos.X, 0, FFreeMemoArea.Width) and
           InRange(pos.Y, 0, FFreeMemoArea.Height) then begin
            FFreeMemoArea.SelStart := 0;
            FFreeMemoArea.SelText := link + #13#10;
        end;
    end;
end;

procedure TfrmCalendar.mnuOpenCountdownDialogClick(Sender: TObject);
begin
    if frmCountdown = nil then Application.CreateForm(TfrmCountdown, frmCountdown);
    frmCountdown.ShowModal;
    StatusBar1.Repaint;
    setDirty;
end;



end.
