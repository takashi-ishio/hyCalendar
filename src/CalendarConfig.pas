unit CalendarConfig;

interface

// フォント設定などを INI ファイルと同期させる

uses
    Graphics, IniFiles, SysUtils, Contnrs, Classes,
    StrUtils, DateUtils, Math,
    ColorPair, FileHistory;

const

    MAX_FONT_INDEX = 20;
    INDEX_TEXTFONT = 0;
    INDEX_DAYFONT = 1;
    INDEX_DAYNAMEFONT = 2;        // 曜日フォント
    INDEX_HYPERLINKFONT = 3;
    INDEX_FREEMEMOFONT = 4;
    INDEX_RANGEITEMFONT = 5;
    INDEX_SERIESPLANITEMFONT = 6;
    INDEX_TODOFONT = 7;           // TODO カレンダー領域への表示フォント
    INDEX_HOLIDAYNAMEFONT = 8;    // 休日名
    INDEX_TODOVIEWFONT = 9;      // TODO 編集ビューのフォント
    INDEX_PRINT_TEXTFONT = 10;    // 各フォントの印刷用バージョン
    INDEX_PRINT_DAYFONT = 11;
    INDEX_PRINT_DAYNAMEFONT = 12;
    INDEX_PRINT_HYPERLINKFONT = 13;
    INDEX_PRINT_FREEMEMOFONT = 14;
    INDEX_PRINT_RANGEITEMFONT = 15;
    INDEX_PRINT_SERIESPLANITEMFONT = 16;
    INDEX_PRINT_TODOFONT = 17;
    INDEX_PRINT_HOLIDAYNAMEFONT = 18;
    INDEX_PRINT_TODOVIEWFONT = 19;
    INDEX_PRINT_HEADERFONT = 20;

    INDEX_PRINT_FONT_OFFSET = 10;
    MAX_SCREEN_FONT_INDEX = 9;



    MAX_TOOLBAR_INDEX = 3;
    INDEX_TOOLBAR_VIEW = 0;
    INDEX_TOOLBAR_MARKING = 1;
    INDEX_TOOLBAR_URL = 2;
    INDEX_TOOLBAR_PAINT = 3;

    START_FROM_MONDAY = 2;
    START_FROM_SUNDAY = 1;

    DEFAULT_ROW_COUNT = 6;
    DEFAULT_COL_COUNT = 7;
    MAX_ROW_COUNT = 60;
    MAX_COL_COUNT = 7;

    DEFAULT_FILE_HISTORY_SIZE = 4;

    MAX_DEFAULT_MONTH_TAB = 12;

type
    TTextAttribute = class
    public
        color: TColor;
        style: TFontStyles;
        constructor Create(color: TColor);
        function Duplicate: TTextAttribute;
    end;


    TCalendarConfiguration = class
    private
        FFileName : string;
        FFont : array[0..MAX_FONT_INDEX] of TFont;
        FUseScreenFontForPrint: array [0..MAX_SCREEN_FONT_INDEX] of boolean;

        FFileHistory: TFileHistory;

        FAutoSave : boolean;
        FZoomRateForEachPage : boolean;
        FHyperlinkWithEditMode : boolean;
        FHideHyperlinkString: boolean;
        FPopupLinkContents: boolean;
        FPopupCellContents: boolean;
        FPopupNoHideTimeout: boolean;
        FShowHyperlinkLabel: boolean;
        FShowHyperlinkContextMenu: boolean;

        FStartFromMonday: boolean;

        FCalendarItemWordWrap: boolean;
        FClippedMarkColor: TColor;

        FDefaultBackColor : TColor;
        FMarkingColor : TColor;
        FMarkingCaseSensitive : boolean;
        FMarkingAutoComplete: boolean;
        FAutoMarkingWhenFind : boolean;

        FWindowPosSave : boolean;
        FWindowLeft : integer;
        FWindowTop : integer;
        FWindowWidth : integer;
        FWindowHeight : integer;
        FFinderWindowLeft : integer;
        FFinderWindowTop : integer;
        FFinderWindowWidth : integer;
        FFinderWindowHeight : integer;
        FMemoHeight: integer;
        FMemoWidth: integer;
        FShowFreeMemoArea : boolean;
        FShowTodoListArea : boolean;

        FAutoExtendRows: boolean;

        FSaturdayColor: TColor;
        FSundayColor: TColor;
        FOtherMonthColor: TColor;
        FOtherMonthSundayColor: TColor;
        FUseOtherMonthColorForContents: boolean;
        FOtherMonthPrintSkip: boolean;
        FOtherMonthBackColor: TColor;

        FHideCompletedTodo: boolean; // "チェック済みTODOは隠す"
        FShowTodoItems: boolean;
        FShowTodoLiteral: boolean;
        FTodoHeadLiteral: string;
        FDoneHeadLiteral: string;
        FHideCompletedTodoOnCalendar: boolean;
        FHideDaystringTodoOnCalendar: boolean;

        FColorNames: TStringList;
        FUserColorNames: TStringList;
        FTextAttrTag : string;
        FHideTextAttrOnDayItem: boolean; // 装飾文字列は日付メモ上に表示しない
        FHidePredefinedTextAttrOnDayItem: boolean;   // 日付メモ上で隠すのは predefined な装飾文字列のみ
        FHideTextAttrOnPopup: boolean; // 装飾文字列はポップアップ時も表示しない
        FHidePredefinedTextAttrOnPopup: boolean;   // ポップアップ時に隠すのは predefined な装飾文字列のみ

        FSelectCursorWidth: integer;
        FTodayCursorWidth: integer;
        FSelectCursorColor: TColor;
        FTodayCursorColor: TColor;

        FPrinterLineWidth: Integer;
        FPrinterLineColor: TColor;
        FPrintCaptionPosition: Integer;
        FPrintPageTwoColumns: boolean;
        FPrintFreememoRatio: Integer;
        FPrintFreememoTwoColumns: boolean;
        FPrintTodoRatio: Integer;

        FZoomRateRows: integer;     // 全体で１個の拡大率を保存する場合に使用
        FZoomRateCols: integer;
        FSaveZoomRate: boolean;
        FZoomRateList: TObjectList;   // ページごとに拡大率を保存する場合に使用

        FPresetZoomRate: TStringList;

        FSelectDayWithoutMovePageIfVisible: boolean; // 同じタブに日付が（その月の外とはいえ）含まれている場合に移動しない

        FEnableDialogCloseShortcut: boolean;

        FStartupImeModeOn: Boolean;

        FCursorCanMoveAnotherRow: Boolean; // 左右カーソルで前後の行へ移動する

        FTextAttrOverrideHyperlinkFont: boolean;

        // TodoList をクリップボードへコピーするときの設定
        FCopyTodoAll: boolean; // すべてのTodoitem をコピーする
        FCopyTodoWithHeadString: boolean; // ヘッダとして文字列をつける
        FCopyTodoHead: string;             // 未終了のアイテムに付ける文字列
        FCopyTodoHeadForCompleted: string; // 終了済みアイテムに付ける文字列

        // 月タブ表示の保存
        FMonthTabSave: boolean;
        FMonthTabAutoClose: boolean;
        FTabs: TStringList;
        FDefaultMonthTabBefore: integer;
        FDefaultMonthTabAfter: integer;

        FRegisterFreeMemoURLToToolbar: boolean;

        // タスクトレイ関連
        FUseTaskTray: boolean;

        function getStartOfWeek: integer;

        procedure getColorNameCallback(const s: string);

        function EncodePresetZoomRate(rows, cols: integer): string;
        procedure DecodePresetZoomRate(s: string; var rows, cols: integer);


    public

        // 配列メンバー（配列プロパティだと setter/getter の定義が必要なので public field）
        // ツールバーの位置情報
        ToolbarSave : boolean;
        ToolbarId : array[0..MAX_TOOLBAR_INDEX] of integer;
        ToolbarWidth : array[0..MAX_TOOLBAR_INDEX] of integer;
        ToolbarIndex : array[0..MAX_TOOLBAR_INDEX] of integer;
        ToolbarVisible: array[0..MAX_TOOLBAR_INDEX] of boolean;
        ToolbarBreak: array[0..MAX_TOOLBAR_INDEX] of boolean;

        // カラーパレット情報
        PaletteColor: array[0..COLOR_BOX_COUNT-1] of TCellColorConfig;

        // 読み書き用メソッド
        constructor Create(filename: string; defaultFont: TFont);
        destructor Destroy; override;
        procedure ReadIniFile;
        procedure WriteIniFile;

        // 装飾文字列へのアクセスメソッド
        function GetTextAttribute(name: string): TTextAttribute;
        function GetPredefinedTextAttribute(name: string): TTextAttribute;
        // 装飾文字列を編集するためのメソッド
        procedure CheckoutTextAttributeList(list: TStrings); // 取り出し
        procedure CheckinTextAttributeList(list: TStrings);  // 保存．list の中身は破棄される
        procedure CleanupTextAttributeList(list: TStrings);  // 保存せずに list の中身を破棄

        // 共通の拡大率
        procedure setSharedZoomRate(rows, cols: integer);
        procedure getSharedZoomRate(var rows, cols: integer);
        // 各 yyyy/mm ごとの拡大率
        procedure setZoomRate(y, m: integer; rows, cols: integer);
        procedure getZoomRate(day: TDateTime; var rows, cols: integer);

        // プリセット拡大率
        procedure addPresetZoomRate(rows, cols: integer);
        procedure removePresetZoomRate(rows, cols: integer);
        procedure getPresetZoomRate(index: integer; var rows, cols: integer);
        function getPresetZoomRateCount: integer;

        //procedure setZoomRate(y, m: integer; rate: Extended); // プロパティでは２引数にうまく対処できないのでメソッドとして実装
        //function  getZoomRate(day: TDateTime): Extended;

        // ページの自動拡張
        property AutoExtendRows: boolean read FAutoExtendRows write FAutoExtendRows;

        // ファイルヒストリ
        property FileHistory: TFileHistory read FFileHistory;

        // フォント系
        function Fonts(idx: integer): TFont;



        function UseScreenFontForPrint(idx: integer): boolean;
        procedure SetUseScreenFontForPrint(idx: integer; newValue: boolean);

        // 色々オプション類
        property AutoSave: boolean read FAutoSave write FAutoSave;
        property ZoomRateForEachPage: boolean read FZoomRateForEachPage write FZoomRateForEachPage;
        property HyperlinkWithEditMode: boolean read FHyperlinkWithEditMode write FHyperlinkWithEditMode;
        property HideHyperlinkString: boolean read FHideHyperlinkString write FHideHyperlinkString;
        property PopupLinkContents: boolean read FPopupLinkContents write FPopupLinkContents;
        property PopupCellContents: boolean read FPopupCellContents write FPopupCellContents;
        property PopupNoHideTimeout: boolean read FPopupNoHideTimeout write FPopupNoHideTimeout;
        property ShowHyperlinkLabel: boolean read FShowHyperLinkLabel write FShowHyperLinkLabel;
        property ClippedMarkColor: TColor read FClippedMarkColor write FClippedMarkColor;
        property SaveZoomRate: boolean read FSaveZoomRate write FSaveZoomRate;
        property EnableDialogCloseShortcut: boolean read FEnableDialogCloseShortcut write FEnableDialogCloseShortcut;
        property SelectDayWithoutMovePageIfVisible: boolean read FSelectDayWithoutMovePageIfVisible write FSelectDayWithoutMovePageIfVisible;
        property CalendarItemWordWrap: boolean read FCalendarItemWordWrap write FCalendarItemWordWrap;
        property ShowHyperlinkContextMenu: boolean read FShowHyperlinkContextMenu write FShowHyperlinkContextMenu;

        property StartupImeModeOn: Boolean read FStartupImeModeOn write FStartupImeModeOn;

        // 装飾文字列はハイパーリンク文字列のフォント設定を上書きするかどうか
        property TextAttrOverrideHyperlinkFont: boolean read FTextAttrOverrideHyperlinkFont write FTextAttrOverrideHyperlinkFont;

        // カーソルサイズ
        property SelectCursorWidth: integer read FSelectCursorWidth write FSelectCursorWidth;
        property TodayCursorWidth: integer read FTodayCursorWidth write FTodayCursorWidth;
        // 色設定
        property SelectCursorColor: TColor read FSelectCursorColor write FSelectCursorColor;
        property TodayCursorColor: TColor read FTodayCursorColor write FTodayCursorColor;
        property DefaultBackColor: TColor read FDefaultBackColor write FDefaultBackColor;
        property SaturdayColor: TColor read FSaturdayColor write FSaturdayColor;
        property SundayColor: TColor read FSundayColor write FSundayColor;
        property OtherMonthColor: TColor read FOtherMonthColor write FOtherMonthColor;
        property OtherMonthSundayColor: TColor read FOtherMonthSundayColor write FOtherMonthSundayColor;
        property UseOtherMonthColorForContents: boolean read FUseOtherMonthColorForContents write FUseOtherMonthColorForContents;
        property OtherMonthPrintSkip: boolean read FOtherMonthPrintSkip write FOtherMonthPrintSkip;
        property OtherMonthBackColor: TColor read FOtherMonthBackColor write FOtherMonthBackColor;

        // 検索系の設定
        property MarkingColor: TColor read FMarkingColor write FMarkingColor;
        property MarkingCaseSensitive: boolean read FMarkingCaseSensitive write FMarkingCaseSensitive;
        property MarkingAutoComplete: boolean read FMarkingAutoComplete write FMarkingAutoComplete;
        property AutoMarkingWhenFind: boolean read FAutoMarkingWhenFind write FAutoMarkingWhenFind;

        // ウィンドウ位置保存設定
        property WindowPosSave: boolean read FWindowPosSave write FWindowPosSave;
        property WindowLeft: integer read FWindowLeft write FWindowLeft;
        property WindowTop: integer read FWindowTop write FWindowTop;
        property WindowWidth: integer read FWindowWidth write FWindowWidth;
        property WindowHeight: integer read FWindowHeight write FWindowHeight;
        property FinderWindowLeft: integer read FFinderWindowLeft write FFinderWindowLeft;
        property FinderWindowTop: integer read FFinderWindowTop write FFinderWindowTop;
        property FinderWindowWidth: integer read FFinderWindowWidth write FFinderWindowWidth;
        property FinderWindowHeight: integer read FFinderWindowHeight write FFinderWindowHeight;
        property MemoHeight: integer read FMemoHeight write FMemoHeight;
        property MemoWidth: integer read FMemoWidth write FMemoWidth;
        property ShowFreeMemoArea : boolean read FShowFreeMemoArea write FShowFreeMemoArea;
        property ShowTodoListArea : boolean read FShowTodoListArea write FShowTodoListArea;


        // １週間の始まりは月曜？
        property StartFromMonday: boolean read FStartFromMonday write FStartFromMonday;
        property StartOfWeek: integer read getStartOfWeek; // StartFromMonday の別表現

        // TODO 表示の設定
        property HideCompletedTodo: boolean read FHideCompletedTodo write FHideCompletedTodo;
        property ShowTodoItems: boolean read FShowTodoItems write FShowTodoItems;
        property ShowTodoLiteral: boolean read FShowTodoLiteral write FShowTodoLiteral;
        property TodoHeadLiteral: string read FTodoHeadLiteral write FTodoHeadLiteral;
        property DoneHeadLiteral: string read FDoneHeadLiteral write FDoneHeadLiteral;
        property HideCompletedTodoOnCalendar: boolean read FHideCompletedTodoOnCalendar write FHideCompletedTodoOnCalendar;
        property HideDaystringTodoOnCalendar: boolean read FHideDaystringTodoOnCalendar write FHideDaystringTodoOnCalendar;

        // 装飾文字列の取り扱い設定
        property TextAttrTag: string read FTextAttrTag write FTextAttrTag;
        property HideTextAttrOnDayItem: boolean read FHideTextAttrOnDayItem write FHideTextAttrOnDayItem;
        property HidePredefinedTextAttrOnDayItem: boolean read FHidePredefinedTextAttrOnDayItem write FHidePredefinedTextAttrOnDayItem;
        property HideTextAttrOnPopup: boolean read FHideTextAttrOnPopup write FHideTextAttrOnPopup;
        property HidePredefinedTextAttrOnPopup: boolean read FHidePredefinedTextAttrOnPopup write FHidePredefinedTextAttrOnPopup;

        // 月タブの保存
        property MonthTabSave: boolean read FMonthTabSave write FMonthTabSave;
        property MonthTabAutoClose: boolean read FMonthTabAutoClose write FMonthTabAutoClose;
        property MonthTabs: TStringList read FTabs;
        property DefaultMonthTabBefore: integer read FDefaultMonthTabBefore write FDefaultMonthTabBefore;
        property DefaultMonthTabAfter: integer read FDefaultMonthTabAfter write FDefaultMonthTabAfter;

        // TODOリストをクリップボードにコピーするときの設定（コピー用ダイアログで最後に使った設定）
        property CopyTodoAll: boolean read FCopyTodoAll write FCopyTodoAll;
        property CopyTodoWithHeadString: boolean read FCopyTodoWithHeadString write FCopyTodoWithHeadString;
        property CopyTodoHead: string read FCopyTodoHead write FCopyTodoHead;
        property CopyTodoHeadForCompleted: string read FCopyTodoHeadForCompleted write FCopyTodoHeadForCompleted;

        // カーソル左右で前後の行へ移動
        property CursorCanMoveAnotherRow: boolean read FCursorCanMoveAnotherRow write FCursorCanMoveAnotherRow;

        // URLツールバーにURLを登録するかどうか
        property RegisterFreeMemoURLToToolbar: boolean read FRegisterFreeMemoURLToToolbar write FRegisterFreeMemoURLToToolbar;

        // 印刷時設定
        property PrinterLineColor: TColor read FPrinterLineColor write FPrinterLineColor;
        property PrinterLineWidth: Integer read FPrinterLineWidth write FPrinterLineWidth;
        property PrintCaptionPosition: Integer read FPrintCaptionPosition write FPrintCaptionPosition;
        property PrintPageTwoColumns: boolean read FPrintPageTwoColumns write FPrintPageTwoColumns;
        property PrintFreememoRatio: Integer read FPrintFreememoRatio write FPrintFreememoRatio;
        property PrintFreememoTwoColumns: boolean read FPrintFreememoTwoColumns write FPrintFreememoTwoColumns;
        property PrintTodoRatio: Integer read FPrintTodoRatio write FPrintTodoRatio;

        // タスクトレイ
        property UseTaskTray: boolean read FUseTaskTray write FUseTaskTray;
    end;


implementation

const
    KEY_GENERAL = 'General';
    KEY_WINDOW = 'Window';
    KEY_WINDOW_FINDER = 'FinderWindow';
    KEY_TOOLBAR = 'Toolbar';
    KEY_USER_COLOR_LIST = 'UserColorList';
    KEY_COPYTODO_DIALOG_SETTING = 'CopyTodoDialogSetting';
    KEY_PALETTE_COLOR = 'PaletteColor';
    KEY_FILE_HISTORY = 'FileHistory';
    KEY_PRINTER = 'Printer';

    KEY_TODO_LIST = 'TodoList';
    KEY_HIDE_COMPLETED_TODO = 'HideCompletedTodo';
    KEY_HIDE_COMPLETED_TODO_ON_CALENDAR = 'HideCompletedTodoOnCalendar';
    KEY_SHOW_TODO_ITEMS = 'ShowTodoItems';
    KEY_SHOW_TODO_LITERAL = 'ShowTodoLiteral';
    KEY_TODO_HEAD_LITERAL = 'TodoHeadLiteral';
    KEY_DONE_HEAD_LITERAL = 'DoneHeadLiteral';
    KEY_HIDE_DAYSTRING_TODO_ON_CALENDAR = 'HideDaystringTodoOnCalendar';

    KEY_AUTO_EXTEND_ROWS = 'AutoExtendRows';

    KEY_SHOW_FREEMEMO_AREA = 'ShowFreeMemoArea';
    KEY_SHOW_TODOLIST_AREA = 'ShowTodoListArea';

    KEY_ENABLE_DIALOG_CLOSE_SHORTCUT = 'EnableDialogCloseShortcut';

    KEY_FIXSIZE = 'FixSize';
    KEY_TOOLBAR_NAME: array[0..MAX_TOOLBAR_INDEX] of string = ('ViewToolbar', 'MarkingToolBar', 'URLToolbar', 'PaintToolBar' );

    KEY_POPUPLINKCONTENTS = 'PopupLinkContents';
    KEY_POPUPCELLCONTENTS = 'PopupCellContents';
    KEY_POPUP_NO_HIDE_TIMEOUT = 'PopupNoHideTimeout';

    KEY_ZOOMRATE = 'ZoomRateForEachPage';
    KEY_ZOOMRATE_ROWS = 'ZoomRateForEachPageRows';
    KEY_ZOOMRATE_COLS = 'ZoomRateForEachPageCols';
    KEY_DEFAULT_ZOOMRATE = 'ZoomRate';
    KEY_DEFAULT_ZOOMRATE_ROWS = 'ZoomRateRows';
    KEY_DEFAULT_ZOOMRATE_COLS = 'ZoomRateCols';
    KEY_SAVE_ZOOMRATE = 'SaveZoomRate';
    KEY_ZOOMRATE_LIST = 'ZoomRateList';
    KEY_YEAR = 'Year';
    KEY_MONTH = 'Month';
    KEY_START_FROM_MONDAY = 'StartFromMonday';

    KEY_LINKWITHEDIT = 'HyperLinkWithEditMode';
    KEY_SELECT_DAY_WITHOUT_MOVE_PAGE_IF_VISIBLE = 'SelectDayWithoutMovePageIfVisible';
    KEY_AUTOSAVE = 'AutoSave';
    KEY_SAVE = 'Save';
    KEY_HIDELINKSTRING = 'HideHyperlinkString';
    KEY_SHOWHYPERLINKLABEL = 'SHOWHyperlinkLabel';
    KEY_SHOWHYPERLINK_CONTEXTMENU = 'ShowHyperlinkContextMenu';
    KEY_CALENDAR_ITEM_WORDWRAP = 'CalendarItemWordWrap';

    KEY_DEFAULT_BACKCOLOR = 'DefaultBackColor';
    KEY_ClippedMarkColor = 'ClippedMarkColor';
    KEY_TODAY_CURSOR_COLOR = 'TodayCursorColor';
    KEY_TODAY_CURSOR_WIDTH = 'TodayCursorWidth';
    KEY_SELECT_CURSOR_COLOR = 'SelectCursorColor';
    KEY_SELECT_CURSOR_WIDTH = 'SelectCursorWidth';
    KEY_SATURDAY_COLOR = 'SaturdayColor';
    KEY_SUNDAY_COLOR = 'SundayColor';
    KEY_OTHER_MONTH_COLOR = 'OtherMonthColor';
    KEY_OTHER_MONTH_SUNDAY_COLOR = 'OtherMonthSundayColor';
    KEY_USE_OTHER_MONTH_COLOR_FOR_CONTENT = 'UseOtherMonthColorForContent';
    KEY_OTHER_MONTH_PRINT_SKIP = 'OtherMonthPrintSkip';
    KEY_OTHER_MONTH_BACKCOLOR = 'OtherMonthBackColor';

    KEY_MARKINGAUTOCOMPLETE = 'MarkingAutoComplete';
    KEY_MARKINGCOLOR = 'MarkingColor';
    KEY_MARKINGCASESENSITIVE = 'MarkingCaseSensitive';
    KEY_AUTOMARKING = 'AutoMarkingWhenFind';

    KEY_FONTNAME: array [0..MAX_FONT_INDEX] of string =
      ('TextFont', 'DayFont', 'DayNameFont',
       'HyperlinkFont', 'FreeMemoFont', 'RangeItemFont',
       'SeriesPlanItemFont', 'TodoFont', 'HolidayNameFont',
       'TodoViewFont',
       'PrintTextFont', 'PrintDayFont', 'PrintDayNameFont',
       'PrintHyperlinkFont', 'PrintFreeMemoFont', 'PrintRangeItemFont',
       'PrintSeriesPlanItemFont', 'PrintTodoFont', 'PrintHolidayNameFont',
       'PrintTodoViewFont',
       'PrintHeaderFont'
       );
    KEY_PRINTFONT = 'UseScreenFontForPrint';

    KEY_MONTHTAB = 'MonthTab';
    KEY_MONTHTAB_COUNT = 'MonthTabCount';
    KEY_MONTHTAB_SAVE = 'MonthTabSave';
    KEY_MONTHTAB_AUTO_CLOSE = 'MonthTabAutoClose';

    KEY_LINE_COLOR = 'LineColor';
    KEY_LINE_WIDTH = 'LineWidth';

    KEY_ID = 'ID';
    KEY_INDEX = 'Index';
    KEY_VISIBLE = 'Visible';
    KEY_BREAK = 'Break';

    KEY_STYLE = 'Style';
    KEY_PITCH = 'Pitch';
    KEY_COLOR = 'Color';
    KEY_NAME = 'Name';
    KEY_SIZE = 'Size';
    KEY_CHARSET = 'Charset';

    KEY_LEFT = 'Left';
    KEY_WIDTH = 'Width';
    KEY_TOP = 'Top';
    KEY_HEIGHT = 'Height';
    KEY_MEMOHEIGHT = 'MemoHeight';
    KEY_MEMOWIDTH = 'MemoWidth';

    KEY_STARTUP_IME_MODE_ON = 'StartupImeModeOn';

    KEY_TEXTATTR_TAG = 'TextAttrTag';
    KEY_TEXTATTR_OVERRIDE_HYPERLINK_FONT = 'TextAttrOverrideHyperlinkFont';
    KEY_USER_COLOR_COUNT = 'Count';
    KEY_HIDE_TEXTATTR_ON_DAYITEM = 'HideTextAttrOnDayItem';
    KEY_HIDE_PREDEFINED_TEXTATTR_ON_DAYITEM = 'HidePredefinedTextAttrOnDayItem';
    KEY_HIDE_TEXTATTR_ON_POPUP = 'HideTextAttrOnPopup';
    KEY_HIDE_PREDEFINED_TEXTATTR_ON_POPUP = 'HidePredefinedTextAttrOnPopup';

    KEY_COPYTODO_ALL = 'CopyTodoAll';
    KEY_COPYTODO_WITH_HEAD_STRING = 'CopyTodoWithHeadString';
    KEY_COPYTODO_HEAD = 'CopyTodoHead';
    KEY_COPYTODO_HEAD_FOR_COMPLETED = 'CopyTodoHeadForCompleted';

    KEY_HEADCOLOR = 'HeadColor';
    KEY_BACKCOLOR = 'BackColor';

    KEY_FILE_HISTORY_SIZE = 'HistorySize';

    KEY_PRESET_ZOOMRATE = 'PresetZoomRate';

    KEY_CURSOR_CAN_MOVE_ANOTHER_ROW = 'CursorCanMoveAnotherRow';

    KEY_REGISTER_FREEMEMO_URL_TOOLBAR = 'RegisterFreeMemoURLToToolbar';

    KEY_DEFAULT_MONTHTAB_BEFORE = 'DefaultMonthTabBefore';
    KEY_DEFAULT_MONTHTAB_AFTER = 'DefaultMonthTabAfter';

    KEY_USE_TASKTRAY = 'UseTaskTray';

    KEY_PRINT_CAPTION_POSITION = 'CaptionPosition';
    KEY_PRINT_PAGE_TWO_COLUMNS = 'PrintPageTwoColumns';
    KEY_PRINT_FREEMEMO_RATIO = 'FreeMemoRatio';
    KEY_PRINT_FREEMEMO_TWO_COLUMNS = 'FreeMemoTwoColumns';
    KEY_PRINT_TODO_RATIO = 'TodoRatio';


type


    TZoomRateItem = class
        Year: Integer;
        Month: Integer;
        Rows: integer;
        Cols: integer;
        constructor Create(y, m, r, c: integer);
    end;


resourcestring
  clNameBlack = '黒';
  clNameMaroon = '茶色';
  clNameGreen = '緑';
  clNameOlive = 'オリーブ';
  clNameNavy = '紺';
  clNamePurple = '紫';
  clNameTeal = '青緑';
  clNameGray = '灰色';
  clNameSilver = '銀色';
  clNameRed = '赤';
  clNameLime = 'ライム';
  clNameYellow = '黄色';
  clNameBlue = '青';
  clNameFuchsia = '赤紫';
  clNameAqua = '水色';
  clNameWhite = '白';
  clNameMoneyGreen = 'マネーグリーン';
  clNameSkyBlue = '空色';
  clNameCream = 'クリーム色';
  clNameMedGray = 'ミディアムグレー';


const
  ColorToPretyName: array[0..19] of TIdentMapEntry = (
    (Value: clBlack; Name: clNameBlack),
    (Value: clMaroon; Name: clNameMaroon),
    (Value: clGreen; Name: clNameGreen),
    (Value: clOlive; Name: clNameOlive),
    (Value: clNavy; Name: clNameNavy),
    (Value: clPurple; Name: clNamePurple),
    (Value: clTeal; Name: clNameTeal),
    (Value: clGray; Name: clNameGray),
    (Value: clSilver; Name: clNameSilver),
    (Value: clRed; Name: clNameRed),
    (Value: clLime; Name: clNameLime),
    (Value: clYellow; Name: clNameYellow),
    (Value: clBlue; Name: clNameBlue),
    (Value: clFuchsia; Name: clNameFuchsia),
    (Value: clAqua; Name: clNameAqua),
    (Value: clWhite; Name: clNameWhite),
    (Value: clMoneyGreen; Name: clNameMoneyGreen),
    (Value: clSkyBlue; Name: clNameSkyBlue),
    (Value: clCream; Name: clNameCream),
    (Value: clMedGray; Name: clNameMedGray));


function FontStylesToInt(styles: TFontStyles): integer;
var
    i: integer;
begin
    i := 0;
    if fsBold in styles then i := i + 1;
    if fsItalic in styles then i := i + 2;
    if fsUnderline in styles then i := i + 4;
    if fsStrikeout in styles then i := i + 8;
    Result := i;
end;

function IntToFontStyles(i: integer): TFontStyles;
var
    styles: TFontStyles;
begin
    styles := [];
    if (i and 1) = 1 then styles := styles + [fsBold];
    if (i and 2) = 2 then styles := styles + [fsItalic];
    if (i and 4) = 4 then styles := styles + [fsUnderline];
    if (i and 8) = 8 then styles := styles + [fsStrikeout];
    Result := styles;
end;

function FontPitchToInt(pitch: TFontPitch): integer;
begin
    if pitch = fpDefault then Result := 0
    else if pitch = fpVariable then Result := 1
    else if pitch = fpFixed then Result := 2
    else Result := 0;
end;

function IntToFontPitch(i: integer): TFontPitch;
begin
    if i = 0 then Result := fpDefault
    else if i = 1 then Result := fpVariable
    else if i = 2 then Result := fpFixed
    else Result := fpDefault;
end;


constructor TTextAttribute.Create(color: TColor);
begin
    self.color := color;
    style := [];
end;

function TTextAttribute.Duplicate: TTextAttribute;
var
    new_item : TTextAttribute;
begin
    new_item := TTextAttribute.Create(self.color);
    new_item.style := self.style;
    result := new_item;
end;

function TCalendarConfiguration.GetPredefinedTextAttribute(name: string): TTextAttribute;
var
    idx: integer;
begin
    idx := FColorNames.IndexOf(AnsiLowerCase(name));
    if idx = -1 then result := nil
    else result := FColorNames.Objects[idx] as TTextAttribute;
end;

function TCalendarConfiguration.GetTextAttribute(name: string): TTextAttribute;
var
    idx: integer;
begin
    idx := FUserColorNames.IndexOf(AnsiLowerCase(name));
    if idx > -1 then result := FUserColorNames.Objects[idx] as TTextAttribute
    else result := GetPredefinedTextAttribute(name);
end;

function TCalendarConfiguration.Fonts(idx: integer): TFont;
begin
    Result := nil;
    if (idx>=0)and(idx<=MAX_FONT_INDEX) then begin
        Result := FFont[idx];
    end;
end;

function TCalendarConfiguration.UseScreenFontForPrint(idx: integer): boolean;
begin
    Result := false;
    if (idx >=0) and (idx<=MAX_SCREEN_FONT_INDEX) then begin
        Result := FUseScreenFontForPrint[idx];
    end;
end;

procedure TCalendarConfiguration.SetUseScreenFontForPrint(idx: integer; newValue: boolean);
begin
    if (idx >=0) and (idx<=MAX_SCREEN_FONT_INDEX) then begin
        FUseScreenFontForPrint[idx] := newValue;
    end;
end;


constructor TCalendarConfiguration.Create(filename: string; defaultFont: TFont);
var
    i: integer;
begin
    FFileName := filename;
    for i:=0 to MAX_FONT_INDEX do begin
        FFont[i] := TFont.Create;
        if defaultFont <> nil then FFont[i].Assign(defaultFont);
    end;
    FZoomRateList := TObjectList.Create(TRUE);
    FFileHistory := TFileHistory.Create;

    FUserColorNames := TStringList.Create;
    FColorNames := TStringList.Create;
    GetColorValues(GetColorNameCallback);

    FPresetZoomRate := TStringList.Create;
    FPresetZoomRate.Duplicates := dupIgnore;
    FPresetZoomRate.Sorted := True;

    FTabs := TStringList.Create;
end;

destructor TCalendarConfiguration.Destroy;
var
    i: integer;
begin
    for i:=0 to MAX_FONT_INDEX do begin
        FFont[i].Free;
    end;
    FZoomRateList.Free;
    CleanupTextAttributeList(FColorNames);
    FColorNames.Free;
    CleanupTextAttributeList(FUserColorNames);
    FUserColorNames.Free;
    FPresetZoomRate.Free;
    FTabs.Free;
end;


procedure TCalendarConfiguration.getColorNameCallback(const s: string);
// 標準の色定数を記憶
var
    color: TColor;
    name: string;
    start: integer;
begin
    color := StringToColor(s);
    if IntToIdent(color, name, ColorToPretyName) then begin
        FColorNames.AddObject(name, TTextAttribute.Create(color));
        if Copy(s, 1, 2) = 'cl' then start := 3
        else start := 1;
        FColorNames.AddObject(AnsiLowerCase(Copy(s, start, length(s))), TTextAttribute.Create(color));
    end;
end;

procedure TCalendarConfiguration.CheckoutTextAttributeList(list: TStrings);
// FUserColorNames --> ListBox コピー
var
    i: integer;
begin
    CleanupTextAttributeList(list);
    for i:=0 to FUserColorNames.Count-1 do begin
        list.AddObject(FUserColorNames[i], (FUserColorNames.Objects[i] as TTextAttribute).Duplicate);
    end;
end;

procedure TCalendarConfiguration.CheckinTextAttributeList(list: TStrings);
// FUserColorNames <-- ListBox 移動
var
    i: integer;
begin
    CleanupTextAttributeList(FUserColorNames);
    for i:=0 to list.Count-1 do begin
        FUserColorNames.AddObject(list[i], list.Objects[i]);
    end;
    list.Clear;
end;

procedure TCalendarConfiguration.CleanupTextAttributeList(list: TStrings);
var
    i: integer;
begin
    for i:=0 to list.Count-1 do begin
        list.Objects[i].Free;
    end;
    list.Clear;
end;

function TCalendarConfiguration.getStartOfWeek: integer;
begin
    Result := IfThen(FStartFromMonday, START_FROM_MONDAY, START_FROM_SUNDAY);
end;

procedure TCalendarConfiguration.ReadIniFile;
var
  i: integer;

  FontIni: TIniFile;
  y, m, r, c: integer;

  procedure ReadFont(key: string; Font: TFont);
  begin
    Font.Color:= StringToColor(FontIni.ReadString(key, KEY_COLOR, 'clBlack'));
    Font.Style:= IntToFontStyles(FontIni.ReadInteger(key, KEY_STYLE, 0));
    Font.Pitch:= IntToFontPitch(FontIni.ReadInteger(key, KEY_PITCH, 0));
    Font.Name := FontIni.ReadString(key, KEY_NAME, Font.Name);
    Font.Size := FontIni.ReadInteger(key, KEY_SIZE, Font.Size);
    Font.Charset := FontIni.ReadInteger(key, KEY_CHARSET, Font.Charset);
  end;

  procedure ReadUserColor(i: integer);
  var
    attr: TTextAttribute;
    color: TColor;
    name: string;
    style: TFontStyles;
  begin
    color := StringToColor(FontIni.ReadString(KEY_USER_COLOR_LIST, KEY_COLOR + IntToStr(i), 'clDefault'));
    name  := FontIni.ReadString(KEY_USER_COLOR_LIST, KEY_NAME + IntToStr(i), '');
    style := IntToFontStyles(FontIni.ReadInteger(KEY_USER_COLOR_LIST, KEY_STYLE + IntToStr(i), 0));
    attr := TTextAttribute.Create(color);
    attr.style := style;
    FUserColorNames.AddObject(name, attr);
  end;

  function ReadStringWithDefaultTrailingBlanks(const section, key, default: string): string;
  const DEFAULT_VALUE = '__INIFILE_DEFAULT_VALUE__';
  var
    s: string;
  begin
      s := FontIni.ReadString(section, key, DEFAULT_VALUE);
      if s = DEFAULT_VALUE then s := default;
      Result := s;
  end;


begin
    FontIni:= TIniFile.Create(FFilename);
    try
        FAutoSave := FontIni.ReadBool(KEY_GENERAL, KEY_AUTOSAVE, false);
        FWindowPosSave := FontIni.ReadBool(KEY_WINDOW, KEY_SAVE, true);
        FZoomRateForEachPage := FontIni.ReadBool(KEY_GENERAL, KEY_ZOOMRATE, false);
        FHyperlinkWithEditMode := FontIni.ReadBool(KEY_GENERAL, KEY_LINKWITHEDIT, false);
        FSelectDayWithoutMovePageIfVisible := FontIni.ReadBool(KEY_GENERAL, KEY_SELECT_DAY_WITHOUT_MOVE_PAGE_IF_VISIBLE, false);
        FHideHyperlinkString := FontIni.ReadBool(KEY_GENERAL, KEY_HIDELINKSTRING, false);
        FMarkingCaseSensitive := FontIni.ReadBool(KEY_GENERAL, KEY_MARKINGCASESENSITIVE, false);
        FMarkingAutoComplete := FontIni.ReadBool(KEY_GENERAL, KEY_MARKINGAUTOCOMPLETE, false);
        FAutoMarkingWhenFind := FontIni.ReadBool(KEY_GENERAL, KEY_AUTOMARKING, false);
        FPopupLinkContents := FontIni.ReadBool(KEY_GENERAL, KEY_POPUPLINKCONTENTS, true);
        FPopupCellContents := FontIni.ReadBOol(KEY_GENERAL, KEY_POPUPCELLCONTENTS, true);
        FPopupNoHideTimeout := FontIni.ReadBool(KEY_GENERAL, KEY_POPUP_NO_HIDE_TIMEOUT, false);
        FShowHyperlinkLabel := Fontini.ReadBool(KEY_GENERAL, KEY_SHOWHYPERLINKLABEL, false);
        FShowHyperlinkContextMenu := FontIni.ReadBool(KEY_GENERAL, KEY_SHOWHYPERLINK_CONTEXTMENU, true);
        FCalendarItemWordWrap := FontIni.ReadBool(KEY_GENERAL, KEY_CALENDAR_ITEM_WORDWRAP, false);
        FClippedMarkColor := StringToColor(FontIni.ReadString(KEY_GENERAL, KEY_ClippedMarkColor, 'clGreen'));
        FDefaultBackColor := StringToColor(FontIni.ReadString(KEY_GENERAL, KEY_DEFAULT_BACKCOLOR, 'clWhite'));

        FUseTaskTray := FontIni.ReadBool(KEY_GENERAL, KEY_USE_TASKTRAY, false);

        FCursorCanMoveAnotherRow := FontIni.ReadBool(KEY_GENERAL, KEY_CURSOR_CAN_MOVE_ANOTHER_ROW, false);

        FPresetZoomRate.CommaText := FontIni.ReadString(KEY_GENERAL, KEY_PRESET_ZOOMRATE, '');


        FWindowLeft := FontIni.ReadInteger(KEY_WINDOW, KEY_LEFT, 0);
        FWindowTop := FontIni.ReadInteger(KEY_WINDOW, KEY_TOP, 0);
        FWindowWidth := FontIni.ReadInteger(KEY_WINDOW, KEY_WIDTH, 640);
        FWindowHeight := FontIni.ReadInteger(KEY_WINDOW, KEY_HEIGHT, 480);

        FShowFreeMemoArea := Fontini.ReadBool(KEY_WINDOW, KEY_SHOW_FREEMEMO_AREA, true);
        FShowTodoListArea := Fontini.ReadBool(KEY_WINDOW, KEY_SHOW_TODOLIST_AREA, true);

        FStartupImeModeOn := FontIni.ReadBool(KEY_GENERAL, KEY_STARTUP_IME_MODE_ON, false);

        FFinderWindowLeft := FontIni.ReadInteger(KEY_WINDOW_FINDER, KEY_LEFT, 0);
        FFinderWindowTop := FontIni.ReadInteger(KEY_WINDOW_FINDER, KEY_TOP, 0);
        FFinderWindowWidth := FontIni.ReadInteger(KEY_WINDOW_FINDER, KEY_WIDTH, 0);
        FFinderWindowHeight := FontIni.ReadInteger(KEY_WINDOW_FINDER, KEY_HEIGHT, 0);

        FMemoHeight := FontIni.ReadInteger(KEY_WINDOW, KEY_MEMOHEIGHT, 100);
        FMemoWidth := FontIni.ReadInteger(KEY_WINDOW, KEY_MEMOWIDTH, 400);
        FMarkingColor := StringToColor(Fontini.ReadString(KEY_GENERAL, KEY_MARKINGCOLOR, 'clSkyBlue'));
        FSelectCursorColor := StringToColor(FontIni.ReadString(KEY_GENERAL, KEY_SELECT_CURSOR_COLOR, 'clGreen'));
        FTodayCursorColor := StringToColor(FontIni.ReadString(KEY_GENERAL, KEY_TODAY_CURSOR_COLOR, 'clBlue'));
        FSelectCursorWidth := FontIni.ReadInteger(KEY_GENERAL, KEY_SELECT_CURSOR_WIDTH, 1);
        FTodayCursorWidth := FontIni.ReadInteger(KEY_GENERAL, KEY_TODAY_CURSOR_WIDTH, 1);

        FSaturdayColor := StringToColor(FontIni.readString(KEY_GENERAL, KEY_SATURDAY_COLOR, 'clBlue'));
        FSundayColor := StringToColor(FontIni.readString(KEY_GENERAL, KEY_SUNDAY_COLOR, 'clRed'));
        FOtherMonthColor := StringToColor(FontIni.readString(KEY_GENERAL, KEY_OTHER_MONTH_COLOR, 'clGrayText'));
        FOtherMonthSundayColor := StringToColor(FontIni.ReadString(KEY_GENERAL, KEY_OTHER_MONTH_SUNDAY_COLOR, '$008080E0'));
        FUseOtherMonthColorForContents := FontIni.ReadBool(KEY_GENERAL, KEY_USE_OTHER_MONTH_COLOR_FOR_CONTENT, false);
        FOtherMonthPrintSkip := FontIni.ReadBool(KEY_PRINTER, KEY_OTHER_MONTH_PRINT_SKIP, false);
        FOtherMonthBackColor := StringToColor(FontIni.ReadString(KEY_GENERAL, KEY_OTHER_MONTH_BACKCOLOR, 'clDefault'));

        FSaveZoomRate := FontIni.ReadBool(KEY_GENERAL, KEY_SAVE_ZOOMRATE, false);
        FZoomRateRows := FontIni.ReadInteger(KEY_GENERAL, KEY_DEFAULT_ZOOMRATE_ROWS, DEFAULT_ROW_COUNT);
        if FZoomRateRows = 0 then FZoomRateRows := DEFAULT_ROW_COUNT;
        FZoomRateCols := FontIni.ReadInteger(KEY_GENERAL, KEY_DEFAULT_ZOOMRATE_COLS, DEFAULT_COL_COUNT);
        if FZoomRateCols = 0 then FZoomRAteCols := DEFAULT_COL_COUNT;
        // FZoomRate := FontIni.ReadInteger(KEY_GENERAL, KEY_DEFAULT_ZOOMRATE, 0);
        FStartFromMonday := FontIni.ReadBool(KEY_GENERAL, KEY_START_FROM_MONDAY, false);

        FHideCompletedTodo := FontIni.ReadBool(KEY_TODO_LIST, KEY_HIDE_COMPLETED_TODO, false);
        FHideCompletedTodoOnCalendar := FontIni.ReadBool(KEY_TODO_LIST, KEY_HIDE_COMPLETED_TODO_ON_CALENDAR, false);
        FShowTodoItems := FontIni.ReadBool(KEY_TODO_LIST, KEY_SHOW_TODO_ITEMS, false);
        FShowTodoLiteral := FontIni.ReadBool(KEY_TODO_LIST, KEY_SHOW_TODO_LITERAL, false);
        FHideDaystringTodoOnCalendar := FontIni.ReadBool(KEY_TODO_LIST, KEY_HIDE_DAYSTRING_TODO_ON_CALENDAR, false);

        FTodoHeadLiteral := ReadStringWithDefaultTrailingBlanks(KEY_TODO_LIST, KEY_TODO_HEAD_LITERAL, 'TODO: ');
        FDoneHeadLiteral := ReadStringWithDefaultTrailingBlanks(KEY_TODO_LIST, KEY_DONE_HEAD_LITERAL, 'DONE: ');

        FEnableDialogCloseShortcut := FontIni.ReadBool(KEY_GENERAL, KEY_ENABLE_DIALOG_CLOSE_SHORTCUT, false);

        FTextAttrTag := AnsiLeftStr(FontIni.ReadString(KEY_GENERAL, KEY_TEXTATTR_TAG, '|'), 1);
        FTextAttrOverrideHyperlinkFont := FontIni.ReadBool(KEY_GENERAL, KEY_TEXTATTR_OVERRIDE_HYPERLINK_FONT, false);
        FHideTextAttrOnDayItem := FontIni.ReadBool(KEY_GENERAL, KEY_HIDE_TEXTATTR_ON_DAYITEM, false);
        FHidePredefinedTextAttrOnDayItem := FontIni.ReadBool(KEY_GENERAL, KEY_HIDE_PREDEFINED_TEXTATTR_ON_DAYITEM, false);
        FHideTextAttrOnPopup := FontIni.ReadBool(KEY_GENERAL, KEY_HIDE_TEXTATTR_ON_POPUP, false);
        FHidePredefinedTextAttrOnPopup := FontIni.ReadBool(KEY_GENERAL, KEY_HIDE_PREDEFINED_TEXTATTR_ON_POPUP, false);

        FRegisterFreeMemoURLToToolbar := FontIni.ReadBool(KEY_GENERAL, KEY_REGISTER_FREEMEMO_URL_TOOLBAR, true);


        FPrinterLineWidth := FontIni.ReadInteger(KEY_PRINTER, KEY_LINE_WIDTH, 1);
        FPrinterLineColor := StringToColor(FontIni.ReadString(KEY_PRINTER, KEY_LINE_COLOR, 'clBlack'));
        FPrintCaptionPosition := FontIni.ReadInteger(KEY_PRINTER, KEY_PRINT_CAPTION_POSITION, 0);
        FPrintPageTwoColumns := FontIni.ReadBool(KEY_PRINTER, KEY_PRINT_PAGE_TWO_COLUMNS, false);
        FPrintFreememoRatio := FontIni.ReadInteger(KEY_PRINTER, KEY_PRINT_FREEMEMO_RATIO, 0);
        FPrintFreememoTwoColumns := FontIni.ReadBool(KEY_PRINTER, KEY_PRINT_FREEMEMO_TWO_COLUMNS, false);
        FPrintTodoRatio := FontIni.ReadInteger(KEY_PRINTER, KEY_PRINT_TODO_RATIO, 0);


        ToolBarSave := FontIni.ReadBool(KEY_TOOLBAR, KEY_SAVE, true);
        for i:=0 to MAX_TOOLBAR_INDEX do begin
            ToolBarWidth[i] := FontIni.ReadInteger(KEY_TOOLBAR_NAME[i], KEY_WIDTH, 200);
            ToolBarIndex[i] := FontIni.ReadInteger(KEY_TOOLBAR_NAME[i], KEY_INDEX, i);
            ToolBarVisible[i] := FontIni.ReadBool(KEY_TOOLBAR_NAME[i], KEY_VISIBLE, (i <> INDEX_TOOLBAR_URL));
            ToolBarBreak[i] := FontIni.ReadBool(KEY_TOOLBAR_NAME[i], KEY_BREAK, false);
        end;

        FMonthTabSave := FontIni.ReadBool(KEY_MONTHTAB, KEY_MONTHTAB_SAVE, false);
        FDefaultMonthTabBefore := FontIni.ReadInteger(KEY_MONTHTAB, KEY_DEFAULT_MONTHTAB_BEFORE, 1);
        FDefaultMonthTabAfter := FontIni.ReadInteger(KEY_MONTHTAB, KEY_DEFAULT_MONTHTAB_AFTER, 3);
        if FDefaultMonthTabBefore > MAX_DEFAULT_MONTH_TAB then FDefaultMonthTabBefore := MAX_DEFAULT_MONTH_TAB;
        if FDefaultMonthTabAfter  > MAX_DEFAULT_MONTH_TAB then FDefaultMonthTabAfter  := MAX_DEFAULT_MONTH_TAB;

        FMonthTabAutoClose := FontIni.ReadBool(KEY_MONTHTAB, KEY_MONTHTAB_AUTO_CLOSE, false);
        c := FontIni.ReadInteger(KEY_MONTHTAB, KEY_MONTHTAB_COUNT, 0);
        FTabs.Clear;
        for i:=0 to c-1 do begin
            FTabs.add(FontIni.ReadString(KEY_MONTHTAB, KEY_MONTHTAB + IntToStr(i), ''));
        end;

        FAutoExtendRows := FontIni.ReadBool(KEY_GENERAL, KEY_AUTO_EXTEND_ROWS, false);

        for i := 0 to MAX_FONT_INDEX do ReadFont(KEY_FONTNAME[i], Fonts(i));

        for i := 0 to MAX_SCREEN_FONT_INDEX do begin
            FUseScreenFontForPrint[i] := FontIni.ReadBool(KEY_PRINTER, KEY_PRINTFONT + KEY_FONTNAME[i], true);
        end;

        for i:=0 to FontIni.ReadInteger(KEY_USER_COLOR_LIST, KEY_USER_COLOR_COUNT, 0)-1 do begin
            ReadUserColor(i);
        end;

        FCopyTodoAll := FontIni.ReadBool(KEY_COPYTODO_DIALOG_SETTING, KEY_COPYTODO_ALL, false);
        FCopyTodoWithHeadString := FontIni.ReadBool(KEY_COPYTODO_DIALOG_SETTING, KEY_COPYTODO_WITH_HEAD_STRING, false);
        FCopyTodoHead := FontIni.ReadString(KEY_COPYTODO_DIALOG_SETTING, KEY_COPYTODO_HEAD, '[ ]');
        FCopyTodoHeadForCompleted := FontIni.ReadString(KEY_COPYTODO_DIALOG_SETTING, KEY_COPYTODO_HEAD_FOR_COMPLETED, '[x]');

        for i:=0 to COLOR_BOX_COUNT-1 do begin
            paletteColor[i].Head := StringToColor(FontIni.ReadString( KEY_PALETTE_COLOR, KEY_HEADCOLOR + IntToStr(i), DEFAULT_PALETTE_HEAD[i]));
            paletteColor[i].Back := StringToColor(FontIni.ReadString( KEY_PALETTE_COLOR, KEY_BACKCOLOR + IntToStr(i), DEFAULT_PALETTE_BACK[i]));
        end;

        if SaveZoomRate and ZoomRateForEachPage then begin
            i := 0;
            while FontIni.ValueExists(KEY_ZOOMRATE_LIST, KEY_YEAR + IntToStr(i)) do begin
                y := FontIni.ReadInteger(KEY_ZOOMRATE_LIST, KEY_YEAR + IntToStr(i), 0);
                m := FontIni.ReadInteger(KEY_ZOOMRATE_LIST, KEY_MONTH + IntToStr(i), 0);
                r := FontIni.ReadInteger(KEY_ZOOMRATE_LIST, KEY_ZOOMRATE_ROWS + IntToStr(i), DEFAULT_ROW_COUNT);
                c := FontIni.ReadInteger(KEY_ZOOMRATE_LIST, KEY_ZOOMRATE_COLS + IntToStr(i), DEFAULT_COL_COUNT);
                //r := FontIni.ReadInteger(KEY_ZOOMRATE_LIST, KEY_ZOOMRATE + IntToStr(i), 0);
                setZoomRate(y, m, r, c);
                inc(i);
            end;
        end;

        FFileHistory.Size := FontIni.ReadInteger(KEY_FILE_HISTORY, KEY_FILE_HISTORY_SIZE, DEFAULT_FILE_HISTORY_SIZE);
        i := FFileHistory.Size;
        while i > 0 do begin
            // リストに古いものから順番に追加していく
            i := i - 1;
            FFileHistory.Add(FontIni.ReadString(KEY_FILE_HISTORY, KEY_FILE_HISTORY + IntToStr(i), ''));
        end;

    finally FontIni.Free;
    end;
end;


procedure TCalendarConfiguration.WriteIniFile;
var
    i, j: integer;
    zoomitem : TZoomRateItem;

    whole: TStringList;
    general: TStringList;
    window: TStringList;
    window_finder: TStringList;
    printer: TStringList;
    todo_list: TStringList;
    file_history: TStringList;
    zoomrate_list: TStringList;
    user_color_list: TStringList;
    palette_color: TStringList;
    monthtab: TStringList;
    copytodo_dialog_setting: TStringList;
    fontlist: TStringList;
    toolbarlist: TStringList;


  procedure addSectionKey(list: TStringList; key: string);
  begin
      list.Add('[' + key + ']');
  end;

  procedure AddStringEntry(list: TStringList; key: string; value: string);
  begin
    list.Add(key + '=' + value);
  end;

  procedure AddIntegerEntry(list: TStringList; key: string; value: integer);
  begin
    list.Add(key + '=' + IntToStr(value));
  end;

  procedure AddBoolEntry(list: TStringList; key: string; value: boolean);
  var
      s: string;
  begin
      s := IfThen(value, '1', '0');
      list.Add(key + '=' + s);
  end;

  procedure WriteFont(key: string; font: TFont);
  begin
      addSectionKey(fontlist, key);
      AddStringEntry(fontlist, KEY_NAME, font.Name);
      AddIntegerEntry(fontlist, KEY_SIZE, font.Size);
      AddIntegerEntry(fontlist, KEY_STYLE, FontStylesToInt(font.style) );
      AddIntegerEntry(fontlist, KEY_PITCH, FontPitchToInt(font.Pitch));
      AddStringEntry(fontlist, KEY_COLOR, ColorToString(font.Color));
      AddIntegerEntry(fontlist, KEY_CHARSET, font.Charset);
  end;

  procedure WriteToolbar;
  var
      i: integer;
  begin
      AddSectionKey(toolbarlist, KEY_TOOLBAR);
      AddBoolEntry(toolbarlist, KEY_SAVE, ToolBarSave);
      for i:=0 to MAX_TOOLBAR_INDEX do begin
          AddSectionkey(toolbarlist, KEY_TOOLBAR_NAME[i]);
          AddIntegerEntry(toolbarlist, KEY_WIDTH, ToolBarWidth[i]);
          AddIntegerEntry(toolbarlist, KEY_INDEX, ToolBarIndex[i]);
          AddBoolEntry(toolbarlist, KEY_VISIBLE, ToolBarVisible[i]);
          AddBoolEntry(toolbarlist, KEY_BREAK, ToolBarBreak[i]);
      end;
  end;

  procedure WriteUserColor;
  var
    i: integer;
    attr: TTextAttribute;
  begin
      AddIntegerEntry(user_color_list, KEY_USER_COLOR_COUNT, FUserColorNames.Count);
      for i:=0 to FUserColorNames.Count-1 do begin
          AddStringEntry(user_color_list, KEY_NAME + IntToStr(i), FUserColorNames[i]);
          attr := FUserColorNames.Objects[i] as TTextAttribute;
          AddIntegerEntry(user_color_list, KEY_STYLE + IntToStr(i), FontStylesToInt(attr.style));
          AddStringEntry(user_color_list, KEY_COLOR + IntToStr(i), ColorToString(attr.color));
      end;
  end;


begin
    whole := TStringList.Create;
    general := TStringList.Create;
    window := TStringList.Create;
    window_finder := TStringList.Create;
    printer := TStringList.Create;
    todo_list := TStringList.Create;
    file_history := TStringList.Create;
    zoomrate_list := TStringList.Create;
    user_color_list := TStringList.Create;
    palette_color := TStringList.Create;
    monthtab := TStringList.Create;
    copytodo_dialog_setting := TStringList.Create;
    fontlist := TStringList.Create;
    toolbarlist := TStringList.Create;
    try
        AddSectionKey(general, KEY_GENERAL);
        AddSectionKey(window, KEY_WINDOW);
        AddSectionKey(window_finder, KEY_WINDOW_FINDER);
        AddSectionKey(printer, KEY_PRINTER);
        AddSectionKey(todo_list, KEY_TODO_LIST);
        AddSectionKey(file_history, KEY_FILE_HISTORY);
        AddSectionKey(zoomrate_list, KEY_ZOOMRATE_LIST);
        AddSectionKey(user_color_list, KEY_USER_COLOR_LIST);
        AddSectionKey(palette_color, KEY_PALETTE_COLOR);
        AddSectionKey(monthtab, KEY_MONTHTAB);
        AddSectionKey(copytodo_dialog_setting, KEY_COPYTODO_DIALOG_SETTING);

        AddBoolEntry(general, KEY_AUTOSAVE, FAutoSave);
        AddBoolEntry(general, KEY_LINKWITHEDIT, FHyperlinkWithEditMode);
        AddBoolEntry(general, KEY_SELECT_DAY_WITHOUT_MOVE_PAGE_IF_VISIBLE, FSelectDayWithoutMovePageIfVisible);
        AddBoolEntry(general, KEY_HIDELINKSTRING, FHideHyperlinkString);
        AddBoolEntry(general, KEY_MARKINGCASESENSITIVE, FMarkingCaseSensitive);
        AddBoolEntry(general, KEY_AUTOMARKING, FAutoMarkingWhenFind);
        AddBoolEntry(general, KEY_POPUPLINKCONTENTS, FPopupLinkContents);
        AddBoolEntry(general, KEY_POPUPCELLCONTENTS, FPopupCellContents);
        AddBoolEntry(general, KEY_POPUP_NO_HIDE_TIMEOUT, FPopupNoHideTimeout);
        AddBoolEntry(general, KEY_SHOWHYPERLINKLABEL, FSHOWHyperlinkLabel);
        AddBoolEntry(general, KEY_SHOWHYPERLINK_CONTEXTMENU, FShowHyperlinkContextMenu);
        AddBoolEntry(general, KEY_MARKINGAUTOCOMPLETE, FMarkingAutoComplete);
        AddBoolEntry(general, KEY_CALENDAR_ITEM_WORDWRAP, FCalendarItemWordWrap);
        AddBoolEntry(general, KEY_STARTUP_IME_MODE_ON, FStartupImeModeOn);
        AddBoolEntry(general, KEY_CURSOR_CAN_MOVE_ANOTHER_ROW, FCursorCanMoveAnotherRow);
        AddBoolEntry(general, KEY_USE_TASKTRAY, FUseTaskTray);

        AddStringEntry(general, KEY_ClippedMarkColor, ColorToString(FClippedMarkColor));
        AddStringEntry(general, KEY_DEFAULT_BACKCOLOR, ColorToString(FDefaultBackColor));
        AddBoolEntry(window, KEY_SAVE, FWindowPosSave);
        AddIntegerEntry(window, KEY_LEFT, FWindowLeft);
        AddIntegerEntry(window, KEY_TOP, FWindowTop);
        AddIntegerEntry(window, KEY_WIDTH, FWindowWidth);
        AddIntegerEntry(window, KEY_HEIGHT, FWindowHeight);
        AddIntegerEntry(window, KEY_MEMOHEIGHT, FMemoHeight);
        AddIntegerEntry(window, KEY_MEMOWIDTH, FMemoWidth);
        AddBoolEntry(window, KEY_SHOW_FREEMEMO_AREA, FShowFreeMemoArea);
        AddBoolEntry(window, KEY_SHOW_TODOLIST_AREA, FShowTodoListArea);
        AddIntegerEntry(window_finder, KEY_LEFT, FFinderWindowLeft);
        AddIntegerEntry(window_finder, KEY_TOP, FFinderWindowTop);
        AddIntegerEntry(window_finder, KEY_WIDTH, FFinderWindowWidth);
        AddIntegerEntry(window_finder, KEY_HEIGHT, FFinderWindowHeight);

        AddBoolEntry(general, KEY_ENABLE_DIALOG_CLOSE_SHORTCUT, FEnableDialogCloseShortcut);
        AddBoolEntry(general, KEY_AUTO_EXTEND_ROWS, FAutoExtendRows);
        AddBoolEntry(general, KEY_REGISTER_FREEMEMO_URL_TOOLBAR, FRegisterFreeMemoURLToToolbar);

        AddBoolEntry(general, KEY_ZOOMRATE, FZoomRateForEachPage);
        AddIntegerEntry(general, KEY_DEFAULT_ZOOMRATE_ROWS, FZoomRAteRows);
        AddIntegerEntry(general, KEY_DEFAULT_ZOOMRATE_Cols, FZoomRAteCols);
        AddBoolEntry(general, KEY_SAVE_ZOOMRATE, FSaveZoomRate);
        AddBoolEntry(general, KEY_START_FROM_MONDAY, FStartFromMonday);

        AddStringEntry(general, KEY_MARKINGCOLOR, ColorToString(FMarkingColor));
        AddStringEntry(general, KEY_TODAY_CURSOR_COLOR, ColorToString(FTodayCursorColor));
        AddStringEntry(general, KEY_SELECT_CURSOR_COLOR, ColorToString(FSelectCursorColor));
        AddIntegerEntry(general, KEY_SELECT_CURSOR_WIDTH, FSelectCursorWidth);
        AddIntegerEntry(general, KEY_TODAY_CURSOR_WIDTH, FTodayCursorWidth);

        AddStringEntry(general, KEY_SATURDAY_COLOR, ColorToString(FSaturdayColor));
        AddStringEntry(general, KEY_SUNDAY_COLOR, ColorToString(FSundayColor));
        AddStringEntry(general, KEY_OTHER_MONTH_COLOR, ColorToString(FOtherMonthColor));
        AddStringEntry(general, KEY_OTHER_MONTH_SUNDAY_COLOR, ColorToString(FOtherMonthSundayColor));
        AddBoolEntry(general, KEY_USE_OTHER_MONTH_COLOR_FOR_CONTENT, FUseOtherMonthColorForContents);
        AddBoolEntry(printer, KEY_OTHER_MONTH_PRINT_SKIP, FOtherMonthPrintSkip);
        AddStringEntry(general, KEY_OTHER_MONTH_BACKCOLOR, ColorToString(FOtherMonthBackColor));

        AddStringEntry(general, KEY_PRESET_ZOOMRATE, FPresetZoomRate.CommaText);

        AddStringEntry(general, KEY_TEXTATTR_TAG, FTextAttrTag);
        AddBoolEntry(general, KEY_TEXTATTR_OVERRIDE_HYPERLINK_FONT, FTextAttrOverrideHyperlinkFont);
        AddBoolEntry(general, KEY_HIDE_TEXTATTR_ON_POPUP, FHideTextAttrOnPopup);
        AddBoolEntry(general, KEY_HIDE_PREDEFINED_TEXTATTR_ON_POPUP, FHidePredefinedTextAttrOnPopup);
        AddBoolEntry(general, KEY_HIDE_TEXTATTR_ON_DAYITEM, FHideTextAttrOnDayItem);
        AddBoolEntry(general, KEY_HIDE_PREDEFINED_TEXTATTR_ON_DAYITEM, FHidePredefinedTextAttrOnDayItem);

        WriteToolbar;

        AddBoolEntry(todo_list, KEY_HIDE_COMPLETED_TODO, FHideCompletedTodo);
        AddBoolEntry(todo_list, KEY_HIDE_COMPLETED_TODO_ON_CALENDAR, FHideCompletedTodoOnCalendar);
        AddBoolEntry(todo_list, KEY_SHOW_TODO_ITEMS, FShowTodoItems);
        AddBoolEntry(todo_list, KEY_SHOW_TODO_LITERAL, FShowTodoLiteral);
        AddStringEntry(todo_list, KEY_TODO_HEAD_LITERAL, '''' + FTodoHeadLiteral + '''');
        AddStringEntry(todo_list, KEY_DONE_HEAD_LITERAL, '''' + FDoneHeadLiteral + '''');
        AddBoolEntry(todo_list, KEY_HIDE_DAYSTRING_TODO_ON_CALENDAR, FHideDaystringTodoOnCalendar);

        AddBoolEntry(copytodo_dialog_setting, KEY_COPYTODO_ALL, FCopyTodoAll);
        AddBoolEntry(copytodo_dialog_setting, KEY_COPYTODO_WITH_HEAD_STRING, FCopyTodoWithHeadString);
        AddStringEntry(copytodo_dialog_setting, KEY_COPYTODO_HEAD, FCopyTodoHead);
        AddStringEntry(copytodo_dialog_setting, KEY_COPYTODO_HEAD_FOR_COMPLETED, FCopyTodoHeadForCompleted);

        AddBoolEntry(monthtab, KEY_MONTHTAB_SAVE, FMonthTabSave);
        AddIntegerEntry(monthtab, KEY_DEFAULT_MONTHTAB_BEFORE, FDefaultMonthTabBefore);
        AddIntegerEntry(monthtab, KEY_DEFAULT_MONTHTAB_AFTER, FDefaultMonthTabAfter);
        AddBoolEntry(monthtab, KEY_MONTHTAB_AUTO_CLOSE, FMonthTabAutoClose);
        AddIntegerEntry(monthtab, KEY_MONTHTAB_COUNT, FTabs.Count);
        for i:=0 to FTabs.Count-1 do begin
            AddStringEntry(monthtab, KEY_MONTHTAB + IntToStr(i), FTabs[i]);
        end;

        AddIntegerEntry(printer, KEY_LINE_WIDTH, FPrinterLineWidth);
        AddStringEntry(printer, KEY_LINE_COLOR, ColorToString(FPrinterLineColor) );
        AddIntegerEntry(printer, KEY_PRINT_CAPTION_POSITION, FPrintCaptionPosition);
        AddBoolEntry(printer, KEY_PRINT_PAGE_TWO_COLUMNS, FPrintPageTwoColumns);
        AddIntegerEntry(printer, KEY_PRINT_FREEMEMO_RATIO, FPrintFreememoRatio);
        AddBoolEntry(printer, KEY_PRINT_FREEMEMO_TWO_COLUMNS, FPrintFreememoTwoColumns);
        AddIntegerEntry(printer, KEY_PRINT_TODO_RATIO, FPrintTodoRatio);

        for i := 0 to MAX_FONT_INDEX do writeFont(KEY_FONTNAME[i], Fonts(i));

        for i := 0 to MAX_SCREEN_FONT_INDEX do begin
            AddBoolEntry(printer, KEY_PRINTFONT + KEY_FONTNAME[i], FUseScreenFontForPrint[i]);
        end;


        WriteUserColor;

        for i:=0 to COLOR_BOX_COUNT-1 do begin
            AddStringEntry(palette_color, KEY_HEADCOLOR + IntToStr(i), ColorToString(paletteColor[i].Head));
            AddStringEntry(palette_color, KEY_BACKCOLOR + IntToStr(i), ColorToString(paletteColor[i].Back));
        end;

        if SaveZoomRate and ZoomRateForEachPage then begin
            j := 0;
            for i:=0 to FZoomRateList.Count-1 do begin
                zoomitem := TZoomRateItem(FZoomRateList[i]);
                AddIntegerEntry(zoomrate_list, KEY_YEAR + IntToStr(j), zoomitem.Year);
                AddIntegerEntry(zoomrate_list, KEY_MONTH + IntToStr(j), zoomitem.Month);
                AddIntegerEntry(zoomrate_list, KEY_ZOOMRATE_ROWS + IntToStr(j), zoomitem.Rows);
                AddIntegerEntry(zoomrate_list, KEY_ZOOMRATE_COLS + IntToStr(j), zoomitem.Cols);
                inc(j);
            end;
        end else begin
            zoomrate_list.Clear;
        end;

        AddIntegerEntry(file_history, KEY_FILE_HISTORY_SIZE, FFileHistory.Size);
        // 新しいものから順番に書いていく
        for i := 0 to FFileHistory.Size-1 do begin
            AddStringEntry(file_history, KEY_FILE_HISTORY + IntToStr(i), FFileHistory.getFilename(i));
        end;

        whole.AddStrings(general);
        whole.AddStrings(window);
        whole.AddStrings(window_finder);
        whole.AddStrings(toolbarlist);
        whole.AddStrings(todo_list);
        whole.AddStrings(copytodo_dialog_setting);
        whole.AddStrings(fontlist);
        whole.AddStrings(palette_color);
        whole.AddStrings(file_history);
        whole.AddStrings(monthtab);
        whole.AddStrings(printer);
        whole.AddStrings(user_color_list);
        whole.AddStrings(zoomrate_list);
        whole.SaveToFile(FFilename);

    finally
        whole.Free;
        general.Free;
        window.Free;
        window_finder.Free;
        printer.Free;
        todo_list.Free;
        fontlist.Free;
        file_history.Free;
        zoomrate_list.Free;
        user_color_list.Free;
        palette_color.Free;
        monthtab.Free;
        copytodo_dialog_setting.Free;
        toolbarlist.Free;
    end;
end;

procedure TCalendarConfiguration.setZoomRate(y, m: integer; rows, cols: integer); //rate: Extended);
var
    i: integer;
    item: TZoomRateItem;
begin
    for i:=0 to FZoomRateList.Count-1 do begin
        item := TZoomRateItem(FZoomRateList[i]);
        if (item.Year = y)and(item.Month = m) then begin
            item.Rows := rows;
            item.Cols := cols;
            //item.Rate := Round(100 * rate);
            Exit;
        end;
    end;
    FZoomRateList.Add(TZoomRateItem.Create(y, m, rows, cols)); //Round(100 * rate)));
end;

procedure TCalendarConfiguration.getZoomRate(day: TDateTime; var rows, cols: integer); //: Extended;
var
    i: integer;
    year: integer;
    month: integer;
    item: TZoomRateItem;
begin
    year := YearOf(day);
    month := MonthOf(day);
    for i:=0 to FZoomRateList.Count-1 do begin
        item := TZoomRateItem(FZoomRateList[i]);
        if (item.Year = year)and(item.Month = month) then begin
            rows := item.Rows;
            cols := item.Cols;
            //Result := item.rate * 1.0 / 100;
            Exit;
        end;
    end;
    rows := DEFAULT_ROW_COUNT;
    cols := DEFAULT_COL_COUNT;
    //Result := 1.0;
end;

constructor TZoomRateItem.Create(y, m, r, c: integer);
begin
    Year := y;
    Month := m;
    Rows := r;
    Cols := c;
    //Rate := r;
end;

procedure  TCalendarConfiguration.setSharedZoomRate(rows, cols: integer); // setSingleZoomRate(rate: Extended);
begin
    FZoomRateRows := rows;
    FZoomRateCols := cols;
    //FZoomRate := Round( rate * 100 );
end;

procedure TCalendarConfiguration.getSharedZoomRate(var rows, cols: integer);   // getSingleZoomRate: Extended;
begin
    rows := FZoomRateRows;
    cols := FZoomRateCols;
    //Result := FZoomRate * 1.0 / 100;
end;


function TCalendarConfiguration.EncodePresetZoomRate(rows, cols: integer): string;
begin
    Result := IntToStr(cols) + '*' + IntToStr(rows);
end;

procedure TCalendarConfiguration.DecodePresetZoomRate(s: string; var rows, cols: integer);
var
    idx: integer;
    r, c: string;
begin
    idx := Pos('*', s);
    if idx > 0 then begin
        c := Copy(s, 1, idx-1);
        r := Copy(s, idx+1, Length(s));
        rows := StrToIntDef(r, DEFAULT_ROW_COUNT);
        if (rows > MAX_ROW_COUNT)or(rows < 1) then rows := DEFAULT_ROW_COUNT;
        cols := StrToIntDef(c, DEFAULT_COL_COUNT);
        if (cols > MAX_COL_COUNT)or(cols < 1) then cols := DEFAULT_COL_COUNT;
    end else begin
        rows := DEFAULT_ROW_COUNT;
        cols := DEFAULT_COL_COUNT;
    end;
end;

procedure TCalendarConfiguration.addPresetZoomRate(rows, cols: integer);
begin
    // FPresetZoomRate は Sorted かつ dupIgnore なので add するだけでよい
    FPresetZoomRate.Add(EncodePresetZoomRate(rows, cols));
end;

procedure TCalendarConfiguration.removePresetZoomRate(rows, cols: integer);
var
    i: integer;
begin
    i := FPresetZoomRate.IndexOf(EncodePresetZoomRate(rows, cols));
    if (i>=0)and(i<FPresetZoomRate.Count) then FPresetZoomRate.Delete(i);
end;

procedure TCalendarConfiguration.getPresetZoomRate(index: integer; var rows, cols: integer);
begin
    DecodePresetZoomRate(FPresetZoomRate[index], rows, cols);
end;

function TCalendarConfiguration.getPresetZoomRateCount: integer;
begin
    Result := FPresetZoomRate.Count;
end;

end.
