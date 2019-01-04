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
    { Private �錾 }
    FDocument: TCalendarDocument;
    FFonts: TFontMap;

    FDefaultFileMenuCount: integer; // �t�@�C�������ő�������O�̃��j���[��

    FActionCallback: TCalendarCallback;
    FUndoBuffer: TUndoBuffer;
    FHintWindowStack: THintWindowStack;
    FHyperlink: THyperlink;

    FBaseDate: TDate;          // �\�����̌��̂P�����w���i�N�E���ɂ݈̂Ӗ�������j
    FBaseDateBack: integer;    // �␳�����i�P�����̉����O���P�s�ڂɗ��邩; 7�̔{���j
    FBaseDateProceed: integer; // �ꃖ���̉�����܂ŏo����; �V�̔{��

    FGridRows: integer;
    FGridCols: integer;
    FEditing : boolean; // TextBox �ŕҏW���������t���O�Ɠ��t
    FEditingDate: TDateTime;

    FPopupDate  : TDate;       // Popup ���j���[���o�Ă�����t
    FCellRenderer: TCellRenderer;
    FHyperLinkers: array [0..MAX_HYPERLINKS] of TStaticText;
    FConfiguration: TCalendarConfiguration;
    FExitWithoutSave : boolean;
    FURLCache : TStringList;  // �R���{�{�b�N�X�ɋL�����ꂽ���e���o���Ă���
    FURLMemo  : TStringList;
    FFindCache : TStringList;

    FPointedURL : string;       // FreeMemo/ItemEdit �����̃n�C�p�[�����N�p
    FPointedStart : integer;    // FreeMemo ���̃e�L�X�g�łǂ����炪�n�C�p�[�����N���̋L�^
    FPointedLength: integer;    // FreeMemo ���̃n�C�p�[�����N�̒����imm/dd ���� PointedURL�Ƃ��Ă� yyyy/mm/dd �ɂ��Ă��܂��̂Œ����������j


    FHintOnCell: array [0..6, 1..MAX_ROW_COUNT] of boolean; // �e�Z���ł͂ݏo�������e�����邩�ǂ���
    FEnforceSelectDayWithoutMovePage : boolean; // �y�[�W�ړ������ɍςނȂ�y�[�W�ړ����Ȃ�. �؂���Ȃǂ� Undo���Ɉꎞ�I�ɗL���ɂ����

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
    { Public �錾 }
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
    FILE_LOAD_ERROR_MESSAGE = '�t�@�C���̓ǂݍ��݂Ɏ��s���܂����D';
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
        Result := '*�㏑���֎~* ���̃v���O�������t�@�C�����g�p���ł��D';
    end else begin
        result := '';
    end;
end;

procedure TfrmCalendar.ActivateApplication;
begin
//    FTaskTray.ActivateApplication;
    if IsIconic(Application.Handle) then begin
//        FIsIconic := false;
        // �E�B���h�E���T�C�Y�ύX�����C�^�X�N�o�[�ɕ��A�����Ă�����
        setWindowPos(Application.Handle, HWND_TOP, 0, 0, 0, 0, SWP_SHOWWINDOW or SWP_NOSIZE or SWP_NOMOVE);
        // �A�v���P�[�V������ "���ɖ߂�"
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
  frmSeriesItemEditDialog.SeriesItemList := FDocument.SeriesItems; // �����\�胊�X�g���_�C�A���O�Ɋ֘A�t���D
end;

function TfrmCalendar.PopupNoHideTimeout: boolean;
begin
  Result := FConfiguration.PopupNoHideTimeout;
end;

// ���̃^�u�ŕ\�����͈̔͂̌��̖�����Ԃ�
// �i2�����ȏオ�\������Ă���Ƃ��́C�S���̓����܂܂�Ă��錎�̖����j
//  �v�Z��: (�O���b�h�E���̓� + 1��) �̌��̍ŏ��̓� - 1 ��
//  +1���́C�O���b�h�E���̓��������������ꍇ�ւ̑Ώ�
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
//            self.Show;   // �\�����������猳�ɖ߂�
//            frm.BringToFront;
//        end else begin
//            //�A�C�R�����́C��\���ɂȂ��Ă���̂ł��̂܂ܑf�ʂ�
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
            msg := '�\�����ʃG���[���������܂����D'#13#10;
            msg := msg + '�ȉ��̃G���[�񍐗p�f�[�^���N���b�v�{�[�h�ɏo�͂��܂����̂ŁC'#13#10;
            msg := msg + '�J���҂܂ł���񂢂�������΍K���ł��D'#13#10;
            msg := msg + '�����f�����������܂����C��낵�����肢�������܂��D'#13#10;
            msg := msg + '��O: ' + E.ClassName + ' ' + E.Message + #13#10 + errorlog.Text;
            errorlog.Free;
            Clipboard.AsText := msg;
            MessageDlg(msg, mtError, [mbOK], 0);
        end;
    end;
end;



//-----------------------------------------------------------------------------
// �������`�I������
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

        // �c�[���o�[�̍����̓f�U�C������
        // ���I�Ɍ��肳��Ă��ăv���p�e�B�ɕۑ�����Ȃ��悤�Ȃ̂ł����Őݒ�
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
            OnMouseUp := FreeMemoMouseDown; // �킴�� Down �C�x���g�ɂ��Ă���

            ScrollBars := ssBoth;
            WordWrap := false;
            WantTabs := true;
            WantReturns := true;
            PopupMenu := ItemEditPopupMenu;

            // FreeMemo �ɑΉ����� URL ���i�[���� FURLMemo ��������
            // FreeMemo ��ǂݍ��ށi�t�@�C���J���j�O�ɐ�������K�v����
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

            // �O���b�h������
            CalGrid.Align := alClient;
            CalGrid.ColCount := CellRenderer.DAY_PER_WEEK;
            CalGrid.RowCount := 7;         // �T�T�� + �O��Q�T�ԂԂ�\���\�ɂ���
            CalGrid.FixedCols := 0;
            CalGrid.FixedRows := 1;
            CalGrid.PopupMenu := Popup;


            // �X�e�[�^�X�o�[�̍������t�H���g�ɍ��킹�Ē���
            Statusbar1.Height := StatusBar1.Canvas.TextHeight('��') + 6;

            // AutoHotkey�� Caption ���ɏ���� "&" ��ǉ�����̂ŋ֎~
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

    // �^�X�N�g���C�p�ɏ������ق��̃A�C�R�������o��
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

    // �ݒ�t�@�C����ǂ�ŐF�X�ݒ�
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


    // �g�嗦��ݒ�
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
      MessageDlg('�j���t�@�C�����ɃG���[�𔭌����܂����D�j���͕\������܂���D', mtError, [mbOK], 0);
    end;

    // �`��p�I�u�W�F�N�g������
    FCellRenderer := TCellRenderer.Create(CalGrid.Canvas, CalGrid.FixedColor, FConfiguration.DefaultBackColor, FConfiguration);
    FDocument.ColorManager.DefaultBackColor := FConfiguration.DefaultBackColor;

    for i:=0 to MAX_HYPERLINKS do begin
        FHyperLinkers[i] := nil; //TStaticText.Create(Self);
    end;


    // Ini �t�@�C����ǂ�Ńt�H���g�C�E�B���h�E�ʒu�ݒ�
    with FConfiguration do begin

        FFreeMemoArea.Font := FFonts.FreeMemoFont;
        ItemEdit.Font := FFonts.TextFont;
        ItemEdit.Color := DefaultBackColor;

        if WindowPosSave then begin
            // �S�̂̃T�C�Y�E�ʒu
            self.Left := WindowLeft;
            self.Top := WindowTop;
            self.Width := WindowWidth;
            self.Height := WindowHeight;

            // �c�Q�ɕ�������X�v���b�^�̔z�u
            self.StatusBar1.Align := alBottom;
            self.StatusBar1.Top := self.Height - self.StatusBar1.Height - 1;

            self.BottomAreaPanel.Height := MemoHeight;
            self.BottomAreaPanel.Top    := self.StatusBar1.Top - self.BottomAreaPanel.Height - 1;
            self.BottomAreaPanel.Align := alBottom;

            self.Splitter1.Top := self.BottomAreaPanel.Top - self.Splitter1.Height - 1;
            self.Splitter1.Align := alBottom;

            // �t���[������TODO�̃X�v���b�^�̔z�u
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

        // �Ƃ肠���������l�Ƃ��č����̏�����ݒ�
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
                // �^�u���Ȃ��Ɩ��Ȃ̂ŁC���݌��̃^�u������
                m := TPageNode.Create(FBaseDate);
                MonthTab.Tabs.AddObject(m.toString, m);
            end;

            MonthTab.TabIndex := page;
        end else begin

            // �^�u�ɂT�������\���i�Ƃ肠�����挎�`�R������j
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

    // ���̎��_�ł͈����̓t�@�C�����̂͂��D
    if ParamCount > 0 then begin
        if not LoadFrom(ParamStr(1)) then begin
            // �t�@�C�����J���Ȃ������炽�����ɏI��
            Application.Terminate;
            Exit;
        end;
    end else begin
        LoadFrom('');
    end;

    FHyperlink := THyperlink.Create;

    loadIconForTasktray;

    // �������̑����� FormShow �Ŏ��s
    Self.Show;
end;

procedure TfrmCalendar.FormShow(Sender: TObject);
var
    i: integer;

begin

    if FIsFirst then begin


        CalGrid.SetFocus;
        mnuUndo.Enabled := false;

        // �c�[���o�[�̐ݒ�𕜌�
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

        // �N�����C�Ȃ���FindBox��Top=0 �ɂȂ��Ă��܂��̂ŏC��
        FindBox.Top := 3;

        // �y�[�W��؂�ւ��čĕ`��
        MonthTabChange(sender);

        // �J���[�p���b�g������
        for i:=0 to COLOR_BOX_COUNT-1 do begin
            FDocument.ColorManager.setColor(i, FConfiguration.PaletteColor[i]);
        end;

        // �����p���b�g�ݒ�
        //FPaintColorSelected := 0;
        FDocument.ColorManager.selectColor(0);

        // �J���[���j���[������
        Popup.OwnerDraw := true;

        // �t�H�[���̐������I����Ă���͂��Ȃ̂Őݒ��n��
//        frmFindDialog.setSearchOption(FConfiguration.MarkingAutoComplete, FConfiguration.MarkingCaseSensitive);

        // IME ��Ԃ̐ݒ�
        if FConfiguration.StartupImeModeOn then SetImeMode(self.Handle, imOpen);

        FIsFirst := false;

        TrayIcon1.Visible := FConfiguration.UseTaskTray; //if FConfiguration.UseTaskTray then FTaskTray.CreateTaskBarIcon;

    end;

    // CalGrid �ɑ΂��� IME �𖳌��ɂ���iImeMode �ݒ肪�ł��Ȃ��̂� API ���ڗ��p�j
    // SetImeMode ����Ŏg��Ȃ��ƌ��ʂ��Ȃ��l�q�Ȃ̂ł�����
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

            // �{���� frmFindDialog ���Ɏ��s���Ăق������C
            // WriteIni ���邽�߂ɓ������K�v�ɂȂ��Ă��܂��̂�
            // �����ŕۑ�
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

        // �J���[�p���b�g�ۑ�
        for i:=0 to COLOR_BOX_COUNT-1 do begin
            FConfiguration.PaletteColor[i] := FDocument.ColorManager.getColor(i);
        end;

        WriteIniFile;
    end;

    // �t�@�C�����X�g��ۑ�
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
// ���t�ړ��֌W
//-----------------------------------------------------------------------------

// �u�^�u�����v
procedure TfrmCalendar.pmnuCloseTabClick(Sender: TObject);
var
    idx: integer;
    p: TPoint;
begin
    p := MonthTab.ScreenToClient(TabPopup.PopupPoint);
    idx := MonthTab.IndexOfTabAt(p.X, p.Y);
    if (idx >= 0) and (MonthTab.Tabs.Count > 1) then begin // �Ō�̃^�u�Ȃ���Ȃ�
        if (MonthTab.TabIndex=idx) then begin
            if (idx = 0) then MoveTab(Sender, 1)
            else MoveTab(Sender, idx-1);
        end;

        MonthTab.Tabs.Objects[idx].Free;
        MonthTab.Tabs.Delete(idx);
    end;
end;

// �^�u���̓���I��
procedure TfrmCalendar.selectDay(day: TDate; with_open: boolean; with_focus: boolean);
var
b: boolean;
    c, r: integer;
begin
    // ������\���Z�������݂̃^�u�ɂ���΂����I������
    if (PosToDay(0, 1) <= day)and(day <= PosToDay(CalGrid.ColCount-1, CalGrid.RowCount-1)) then begin
        FCellRenderer.ConvertDayToPos(FBaseDate, day, FBaseDateBack, c, r);
        CalGrid.Col := c;
        CalGrid.Row := r;

        // �I�������Z�����\���͈͊O�̂Ƃ��͂ł��邾�������Ɋ񂹂�
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
        // �Ȃ��ꍇ�͂Ƃ肠��������[
        CalGrid.Row := 1;
        CalGrid.Col := 0;
    end;
end;

function TfrmCalendar.PosToDay(ACol, ARow: Integer): TDate;
begin
    Result := FCellRenderer.ConvertPosToDay(FBaseDate, FBaseDateBack, ACol, ARow);
end;


// �g�嗦�̐ݒ�ɍ��킹�ăO���b�h����
procedure TfrmCalendar.AdjustGridSizeInternal;
var
    i: integer;
begin
    // �O���b�h�̍s������: �\������T�̐��������ꍇ�̂�
    if (FGridRows > DEFAULT_ROW_COUNT) then begin
        CalGrid.RowCount := FGridRows + 1 + ((FBaseDateBack + FBaseDateProceed) div 7);
    end else if (FGridRows < DEFAULT_ROW_COUNT) then begin
        CalGrid.RowCount := DEFAULT_ROW_COUNT + 2 + ((FBaseDateBack + FBaseDateProceed) div 7);
    end else begin
        CalGrid.RowCount := DEFAULT_ROW_COUNT + 1 + ((FBaseDateBack + FBaseDateProceed) div 7);
    end;

    // �X�N���[���o�[���o���Ă���
    // FGridCols, Rows -- �\�����CCalGrid.Col/RowCount -- ���ۂ̑��ݐ�
    if (FGridCols < CalGrid.ColCount)and
       (FGridRows < (CalGrid.RowCount-1)) then begin
        CalGrid.ScrollBars := ssBoth;
    end else if (FGridCols < CalGrid.ColCount) then begin
        CalGrid.ScrollBars := ssHorizontal;
    end else if (FGridRows < CalGrid.RowCount-1) then
        CalGrid.ScrollBars := ssVertical
    else
        CalGrid.ScrollBars := ssNone;


    // �T�C�Y�Ē��� (�X�N���[���o�[�̏o���e���ŕω����� ClientWidth, Height �̒l���g���čČv�Z)
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
    // �t�H�[���j���r���ɌĂ΂ꂽ�ꍇ(�Ȃ����Ă΂�邱�Ƃ�����)�͖�������
    if not Self.Visible then exit;

    adjustGridSizeInternal;

    if FGridCols = 7 then
        CalGrid.LeftCol := 0
    else if (CalGrid.LeftCol + FGridCols <= CalGrid.Col) then
        CalGrid.LeftCol := 1 + CalGrid.Col - FGridCols
    else if (CalGrid.LeftCol > CalGrid.Col) then
        CalGrid.LeftCol := CalGrid.Col;

    if FGridRows >= DEFAULT_ROW_COUNT then // �\���s�����W����葽���ꍇ
        CalGrid.TopRow := 1
    else if (CalGrid.TopRow + FGridRows <= CalGrid.Row) then
        CalGrid.TopRow := 1 + CalGrid.Row - FGridRows
    else if (CalGrid.TopRow > CalGrid.Row) then
        CalGrid.TopRow := CalGrid.Row;


    // �T�C�Y�ύX�ɍ��킹�ăZ�����đI���i�n�C�p�[�����N���x���̕\�������Ȃǁj
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

// ���t�ɑΉ�����K�؂ȃ^�u��T��
procedure TfrmCalendar.MoveDate(day: TDate; with_open: boolean; with_focus: boolean = true );
var
    tab: TPageNode;
    i: integer;
    idx : integer;
begin
    if not isValid(day) then exit;

    // �����^�u�̓��Ȃ�ړ����Ȃ�
    if (FEnforceSelectDayWithoutMovePage or
        FConfiguration.SelectDayWithoutMovePageIfVisible)
       and(PosToDay(0, 1) <= day)
       and(day <= PosToDay(CalGrid.ColCount-1, CalGrid.RowCount-1)) then begin
        SelectDay(day, with_open, with_focus);
        exit;
    end;

    // �ĕ`��ꎞ��~
    CalGrid.OnDrawCell := nil;
    try
        idx := MonthTab.Tabs.Count;
        for i:=0 to MonthTab.Tabs.Count-1 do begin
            tab := TPageNode(MonthTab.Tabs.Objects[i]);
            if day < tab.getBaseDate then begin
                // ����ȏ�͒T�����Ă��Ӗ����Ȃ��̂ŏI��
                idx := i;
                break;
            end else if (day >= tab.getBaseDate)and
                        (day < IncMonth(tab.getBaseDate, 1)) then begin
                // �Ή�����^�u�𔭌�: ������J��
                MoveTab(self, i);
                SelectDay(day, with_open, with_focus);
                exit;
            end;
        end;

        // �K�؂ȃ^�u��������Ȃ������ꍇ
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
    // �^�u�؂�ւ��O�̏���ۑ�
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

    // �g�嗦�ɍ��킹�ĕ�����̂ق����ݒ�
    ZoomRateRows.Text := IntToStr(FGridRows) + '�T';
    ZoomRateColumns.ItemIndex := FGridCols - 1;
    adjustGridSize(Sender);

    // ���߂ĕ\������Ȃ����I���C
    // �����łȂ��Ƃ��͈ȑO�I�����Ă����Z����I��
    if m.FirstShow then begin
        selectDay(Date, false, false);
    end else begin
        // �u�g���v�\�����Ă��ꍇ�C�O���b�h�͈͊O�ɃJ�[�\��������\������
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
    i := AnsiPos('�T', ZoomRateRows.Text);
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
// �`��֌W
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
// ���t�����ҏW
//-----------------------------------------------------------------------------

procedure TfrmCalendar.EnterItemEdit;
var
    str: string;
begin
    HideHyperLinks(0);
    // �I�΂�Ă���Z����ҏW�\�ȏ�Ԃɂ���
    // (ItemEdit ���Z���̈ʒu�Ɉړ����ĕ\������)

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
    // �t�H�[�J�X���O�ꂽ���ҏW���I������Ƃ݂Ȃ��ăf�[�^�X�V
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
    // �I�����ꂽ�Z���ɍ��킹�ăn�C�p�[�����N�̕\�����X�V
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
// TodoListView, FreeMemo, frmTodoDialog.TodoListView ��
// �g����̂ň�ʓI�Ȏ����ɂȂ��Ă���
var
    control: TWinControl;
begin
    if Sender is TWinControl then control := TMemo(Sender)
    else exit;

    if control.Cursor <> crHandPoint then exit;
//    if control.Owner is TfrmHintWindow then FHintWindowStack.hideHint(TfrmHintWindow(control.Owner), false);

    FHyperlink.OpenHyperLink(FPointedURL);

    // TMemo.SelStart �͐������l��Ԃ��Ȃ��̂�
    // URL �̓L���b�V�����Ă������l���g��
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

            // �����ֈړ�
            if ssCtrl in Shift then begin
                // CTRL �L�[��������Ă���ꍇ�͎��̃^�u�Ŏ����ꂽ�y�[�W�ֈړ�
                if MonthTab.TabIndex = MonthTab.Tabs.Count -1 then begin
                    exit; // Key = 0 �ɂ��Ȃ��̂Ńy�[�W�����Ɉړ�����
                end;

                base := TPageNode(MonthTab.Tabs.Objects[MonthTab.TabIndex]);
                if (old < base.BaseDate) then old := incWeek(old, 1);
                if (old > EndOfTheMonth(base.BaseDate)) then old := incWeek(old, -1);

                target := TPageNode(MonthTab.Tabs.Objects[MonthTab.TabIndex+1]);
                d := IncWeek(old, WeeksBetween(old, target.BaseDate)); // �j����ς��Ȃ��悤�T�P�ʂňړ�
                if d < target.BaseDate then d := IncWeek(d, 1); // �����ڂ̏T�̏ꍇ�C�P�����K�v������
                // �T�����킹��
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
                    // �u��֐i�ށv�ꍇ�C�ő�ŗ��X���܂Ői��ł��܂��̂ň����߂�
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
                // CTRL �t���̏ꍇ�͑O�̃y�[�W��
                if MonthTab.TabIndex = 0 then exit; // Key = 0 �łȂ��̂� VK_NEXT �Ɠ��l

                // ������͂ݏo���Ă���Ԃ���C��
                base := TPageNode(MonthTab.Tabs.Objects[MonthTab.TabIndex]);
                if (old < base.BaseDate) then old := incWeek(old, 1);
                if (old > EndOfTheMonth(base.BaseDate)) then old := incWeek(old, -1);

                target := TPageNode(MonthTab.Tabs.Objects[MonthTab.TabIndex-1]);
                d := IncWeek(old, -WeeksBetween(old, EndOfTheMonth(target.BaseDate)));
                if d > EndOfTheMonth(target.BaseDate) then d := IncWeek(d, -1); // �����ڂ̏T�̏ꍇ�C�P���炷�K�v������

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
// �t�@�C���ǂݏ����֘A
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
// �t�@�C���ǂݍ��� -- filename: �V�K�쐬�̂Ƃ��͋󕶎���
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
        end else MessageDlg('���̃t�@�C���͂��łɊJ����Ă��܂��D', mtInformation, [mbOk], 0);
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
        select := MessageDlg('�t�@�C���͕ύX����Ă��܂��D�ۑ����܂����H', mtInformation, mbYesNoCancel, 0);
        if select = mrYes then begin
            mnuSaveClick(Sender);
            if FDocument.Dirty then Exit;// �u���O�����ĕۑ��v���L�����Z������Ă���
        end else if select = mrCancel then Exit;
        // No �̏ꍇ�͕��ʂɐi��
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
    // �ҏW���̃f�[�^������ꍇ�C
    // �t�H�[�J�X���O���Ċm���ɕҏW���I��点��
    if ItemEdit.Focused then CalGrid.SetFocus;

    SaveDialog1.FileName := FDocument.Filename;

    if SaveDialog1.Execute then begin
        if TDocumentManager.getInstance.IsReferenceDocument(SaveDialog1.FileName) then begin
            MessageDlg('�Q�ƃt�@�C���Ƃ��Ċ��Ɏg�p����Ă��閼�O�́C�t�@�C�����Ƃ��đI���ł��܂���D', mtInformation, [mbOK], 0);
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
        // caption�ύX�CFileHistory�̍X�V�͕K�v�Ȃ�
    end;
end;


procedure TfrmCalendar.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
    select: Integer;
begin

    // �ҏW���A�C�e�����������ꍇ�̗p�S
    if ItemEdit.Focused then Calgrid.SetFocus;

    if FExitWithoutSave then CanClose := true
    else if FConfiguration.AutoSave then begin
        mnuSaveClick(Sender);
        CanClose := (not FDocument.Dirty)and(FDocument.FileName <> '');
    end else if FDocument.Dirty then begin
        select := MessageDlg('�t�@�C���͕ύX����Ă��܂��D�ۑ����܂����H', mtInformation, mbYesNoCancel, 0);
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
                MessageDlg('�G���[�������������߁Cini �t�@�C���ɐݒ��ۑ��ł��܂���ł����D'#13#10
                    + '����N�����́C����N�����̐ݒ���g�p���܂��D'#13#10
                    + '�G���[�����͈ȉ��̂Ƃ���ł��F'#13#10
                    +  E.Message, mtError, [mbOK], 0);
            end;
        end;
    end;
end;

procedure TfrmCalendar.mnuExitWithoutSaveClick(Sender: TObject);
var
    select: integer;
begin
    select := MessageDlg('�t�@�C����ۑ������ɏI�����Ă�낵���ł����H', mtInformation, mbOKCancel, 0);
    if select = mrOK then begin
        FExitWithoutSave := true;
        Close;
    end;
end;



//-----------------------------------------------------------------------------
// ���ԗ\��֘A
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
// �|�b�v�A�b�v���j���[
//-----------------------------------------------------------------------------
procedure TfrmCalendar.CalGridContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
const
    COLOR_PAINT_MENU = '���̓��t�ɐF��h��';
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
        for i:=0 to COLOR_BOX_COUNT do begin // COUNT���P�������
            FColorEditMenus[i] := TMenuItem.Create(PopupMenu);
            FColorEditMenus[i].OnClick := ColorEditMenuClick;
            FColorEditMenus[i].Tag := i-1;
            FColorEditMenus[i].OnDrawItem := ColorEditPopupDraw;
            FColorEditMenus[i].OnMeasureItem := ColorEditPopupMeasure;
        end;
    end;

    // �R���e�L�X�g���j���[�p�� URL �̒Z���o�[�W���������
    function makeHyperlinkCaption(url: string): string;
    var
      s: string;
    begin
        // �Ƃ肠����45�o�C�g�ȏ�Ő؂�l�ߔ���
        if Length(url) > 45 then begin
          s := LeftStr(url, 28) + RightStr(url, 13);
          // ���o���ʂ��{���ɑO���Z���Ȃ邱�Ƃ��m�F�i�S�p�������ƒ����Ȃ邱�Ƃ�����j
          if Length(s) < Length(url) then
            Result := LeftStr(url, 28) + ' ... ' + RightStr(url, 13) + ' ���J��'
          else Result := url +' ���J��';
        end else Result := url +' ���J��';
    end;
begin
    if FColorEditMenus[0] = nil then generateColorMenu;

    colorMenu := Popup.Items.Find(COLOR_PAINT_MENU);
    if colorMenu <> nil then begin
        // �F���j���[�I�u�W�F�N�g���͍̂ė��p����̂ŁC
        // �e���j���[�ɂ���ĉ������Ȃ��悤�ɐڑ�����
        while colorMenu.Count > 0 do begin
            colorMenu.Delete(0);
        end;
    end;


    Popup.Items.Clear;

    // �ʒu�ɉ����ăZ�������t��item �擾
    CalGrid.MouseToCell(MousePos.X, MousePos.Y, ACol, ARow);
    if ARow = 0 then begin
        FPopupDate := FBaseDate;
        addItem('���̗j���������\��ɉ����� ...', mnuSeriesIncludeYoubiClick, IfThen(FConfiguration.StartFromMonday, IfThen(ACol=6, 1, ACol+2), ACol+1));
    end else begin
        d := PosToDay(ACol, ARow);

        FPopupDate := d;

        // �R���e�L�X�g���j���[�� URL ��\������
        if FConfiguration.ShowHyperlinkContextMenu then begin
            hyperlinks := TDocumentManager.getInstance.getHyperlinks(d);

            // URL �̃��X�g�����炩���� FHyperlink �ɓo�^���Ă���
            FHyperlink.registerHyperLink(hyperlinks);

            // �o�^ URL �ɑΉ�����^�O�����������ă��j���[�쐬
            for i:=0 to hyperLinks.Count-1 do begin
                if i > MAX_HYPERLINKS then break;
                addItem(makeHyperlinkCaption(hyperLinks[i]), FHyperlink.HyperLinkDblClick, i);
            end;
            if hyperLinks.Count > 0 then addItem('-', nil, 0);
            TDocumentManager.getInstance.cleanupHyperlinks(hyperlinks);
        end;

        // ���ԗ\��C�����j���[��ǉ�
        ranges := TStringList.Create;
        TDocumentManager.getInstance.getRangeNames(d, ranges);
        for i:=0 to ranges.Count-1 do begin
          if ranges[i] <> '' then
            addItem(Ranges[i] + ' �̏C��', mnuEditRangeClick, i);
        end;
        ranges.Free;

        // ��ɕ\������郁�j���[�̒ǉ�
        addItem('�V�������ԗ\��̒ǉ�(&R) ...', mnuAddRangeClick, 0);

        addItem('-', nil, 0);

        colorMenu := addItem(COLOR_PAINT_MENU, nil, 0);
        colorMenu.Add(FColorEditMenus);

        addItem('���̓��t�̐F���p���b�g�ɒ��o', mnuSelectColorToPaletteClick, 0);

        addItem('-', nil, 0);

        addItem('���t������؂���(&X)', mnuCutToClipboardClick, FLAG_EDIT_FROM_POPUP_MENU);
        addItem('���t�������R�s�[(&C)', mnuCopyToClipboardClick, FLAG_EDIT_FROM_POPUP_MENU);
        addItem('���t������\��t��(&V)', mnuPasteFromClipboardClick, FLAG_EDIT_FROM_POPUP_MENU);
        addItem('���t�����ɒǉ��\��t��(&A)', mnuAppendPasteClick, FLAG_EDIT_FROM_POPUP_MENU);
        addItem('�\����G�N�X�|�[�g�p�ɃR�s�[(&E)', mnuCopyPopupStringToClipboardClick, FLAG_EDIT_FROM_POPUP_MENU);

        addItem('-', nil, 0);

        // �����\��C�����j���[��ǉ�
        l := TStringList.Create;
        TDocumentManager.getInstance.getEditableSeriesItems(d, l);
        if l.Count > 0 then addItem('-', nil, 0);
        for i:=0 to l.Count-1 do begin
            addItem('���̓��� ' + l[i] + ' ���珜��', mnuSeriesExcludeClick, i);
        end;
        l.Free;
        addItem('���̓��������\��ɉ����� ...', mnuSeriesIncludeClick, ACol);
    end;


end;



//-----------------------------------------------------------------------------
// �n�C�p�[�����N Combo box �֘A
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
        // ���O�ŏ��� -- �J�[�\���L�[�ړ����� OnClick �C�x���g���N�������Ȃ�����
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
        // �L���b�V�����ꂽ���̂ƁCFreeMemo �ɋL�����ꂽ���̂��}�[�W
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
// ����
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

    // �������T���āC���̓��t�ֈړ� (MoveDate)
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
// �N���b�v�{�[�h�n
//-----------------------------------------------------------------------------
procedure TfrmCalendar.mnuPasteFromClipboardClick(Sender: TObject);
var
    d: TDateTime;
    action: TCalendarAction;
    hwnd: THandle;
    s: string;
    target: TWinControl;
begin
    // �ΏۃR���g���[���͕ʃE�B���h�E�̂Ƃ�������i���C���E�B���h�E�̃V���[�g�J�b�g�������D�悳��邽�߁j
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
    // �ΏۃR���g���[���͕ʃE�B���h�E�̂Ƃ�������i���C���E�B���h�E�̃V���[�g�J�b�g�������D�悳��邽�߁j
    target := Screen.ActiveForm.ActiveControl;
    if target is TCustomEdit then begin
        TCustomEdit(target).CopyToClipboard;
        s := Clipboard.AsText; // ���e�L�X�g�`���Ŏ��o���āCRichEdit �̏���������
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
    // �ΏۃR���g���[���͕ʃE�B���h�E�̂Ƃ�������i���C���E�B���h�E�̃V���[�g�J�b�g�������D�悳��邽�߁j
    target := Screen.ActiveForm.ActiveControl;
    if target is TCustomEdit then begin
        TCustomEdit(target).CutToClipboard;
        s := Clipboard.AsText; // ���e�L�X�g�`���Ŏ��o���āCRichEdit �̏���������
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
        // Freememo �����TODO���X�g�ҏW���Ȃ炽���̓\��t��
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
// �q���g������E���t�|�b�v�A�b�v�E�n�C�p�[�����N�֌W
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

            // ItemEdit �̕ҏW���̓t�H�[�J�X���ڂ��ƕҏW���I����Ă��܂��̂ŁC�E�B���h�E�ɂ͈ړ����Ȃ�
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

        // EM_CHARFROMPOS �́C���� Word (16bits) �ɕ����ʒu��Ԃ�
        new(pos);
        pos.x := X;
        pos.y := Y;
        CaretPos := memo.Perform(EM_CHARFROMPOS, 0, LPARAM(pos));

        memo.Perform(EM_POSFROMCHAR, WPARAM(pos), CaretPos);
        CharPos.X := pos.x;
        CharPos.Y := pos.y;

        dispose(pos);

        if (CaretPos >= 0)and(CaretPos<Length(memo.Text)) then begin
            // �n�C�p�[�����N���邩�ǂ�������
            testLinkAtCursorPos(memo, memo.Text, YearOf(date), CaretPos+1, x, y, CharPos);
        end else begin
            resetLinkCursor(memo);
        end;

    end else if Sender is TMemo then begin
        edit := Sender as TMemo;

        // �N���b�N�ŃE�B���h�E���b�N �� �ҏW���� ����� Mouse Move �����ł���Ƃ�������
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
            // �n�C�p�[�����N���邩�ǂ�������
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

            // ���t�Ȃ烊���N���\��.
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
                // �ʏ�̓Z���̒��g���q���g�Ƃ��ĕ\��
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

                       HintPos.Y := HintPos.Y + CalGrid.Canvas.TextHeight('A'); // ���t���\���ʒu������������

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

     // ���ǁCCanShow = False �ɂ��Ă����ifrmHintWindow ��ʂɕ\�����邽�߁j

     CanShow := false;
end;

procedure TfrmCalendar.CalGridMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
    rect: TRect;
    ACol, ARow: integer;
begin
    FHintWindowStack.OnMouseMove(Sender, Shift, X, Y);

    // ���� URL ������΃J�[�\���ύX
    CalGrid.MouseToCell(X, Y, ACol, ARow);
    FPointedURL := FCellRenderer.findURL(x, y, PosToDay(ACol, ARow), rect);
    if FPointedURL <> '' then CalGrid.Cursor := crHandPoint
    else CalGrid.Cursor := crDefault;
end;



//-----------------------------------------------------------------------------
// ���̑�
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

        // �u�y�[�W���Ƃ̊g�嗦�ۑ��v���ݒ肳�ꂽ�ꍇ�́C���݂̏��������ŕۑ����Ă���
        with FConfiguration do begin
            if SaveZoomRate and ZoomRateForEachPage then setZoomRate(YearOf(FBaseDate), monthOf(FBaseDate), FGridRows, FGridCols);
        end;

        // �ݒ�ő����ɍX�V����K�v��������̂��X�V

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

    // �����T�C�Y���ύX�ɑ΂��čX�V
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
        MessageDlg('�o�[�W�������_�C�A���O�쐬���ɃG���[���������܂����D '#13#10 +
                   '�����͎��̒ʂ�ł��D '#13#10 + Err.Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TfrmCalendar.mnuFindDialogClick(Sender: TObject);
begin
    makeFindDialogIfNecessary;
    // ���[�_���łȂ��E�B���h�E�̏ꍇ�C�e�E�B���h�E��
    // �V���[�g�J�b�g�����ł��Ă��܂��炵���̂ŁC������������ōs��
    // * TodoDialog�ɂ��Ă����l�̏������s���Ă���
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
      MessageDlg('�v�����^�ւ̃A�N�Z�X�Ɏ��s�������߁C���݈���@�\�͖����ł��D', mtError, [mbOK], 0);
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
        // ��: frm ���܂� nil �̏ꍇ�CSender = frm �����藧���Ȃ��̂� Close ���N���Ȃ������D
        ShortCutToKey(mnu.Shortcut, k, s);
        if (Shift = s) and (Key = k) then begin
            if FConfiguration.EnableDialogCloseShortcut and
               (Sender = frm) then Sender.Close
            else begin
                // Sender �����Y�t�H�[���łȂ���΁C�E�B���h�E�J��
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
    // �t�H�[���j���r���ɌĂ΂ꂽ�ꍇ�͖�������
    if not Self.Visible then exit;

    if ((item.Data <> nil)and(not item.Deleting)) then begin // �폜���̍��ڂ͔�΂�
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
// TodoListView, frmTodoDialog.TodoListView ��
// �g����̂ŃR���g���[�����p�����[�^�����ꂽ�����ɂȂ��Ă���
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

    // �����܂ł����烊���N�Ȃ�
    view.Cursor:= crDefault;
    FPointedURL := '';
end;

// �n�C�p�[�����N�p�̃J�[�\��������
procedure TfrmCalendar.resetLinkCursor(target: TWinControl);
begin
    target.Cursor:= crDefault;
    FPointedURL := '';
end;

// �}�E�X�J�[�\��(x, y) �� Target �R���g���[����̕����� text ��
//  idx �����ڂ��|�C���g���Ă���Ƃ��Ƀq���g�������\�����邩�ǂ����̏���
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
        FontTester.Canvas.Font := font; // self.Canvas �Ȃǂ��g���ƍĕ`�悪�������Ă��܂�
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

        // ���t�^�̏ꍇ�͓��e���|�b�v�A�b�v
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
                    (target as TRichEdit).Perform(EM_POSFROMCHAR, Integer(pos), url_idx-1);  // zero-based index �Ȃ̂� -1
                    CharPos.X := pos.x - 4; // �}�[�W����ݒ肷��K�v����
                    CharPos.Y := pos.y - 4;
                    ARect.TopLeft := target.ClientToScreen(CharPos);
                    CharPos.X := pos.x + w + 4;
                    CharPos.Y := pos.y + h + 4;
                    ARect.BottomRight := target.ClientToScreen(CharPos);
                    dispose(pos);
                end else if target is TMemo then begin
                    calcFontSize((target as TMemo).Font, w, h);
                    CharPosTmp := (target as TMemo).Perform(EM_POSFROMCHAR, url_idx-1, 0);  // zero-based index �Ȃ̂� -1
                    CharPos.X := LoWord( CharPosTmp);
                    CharPos.Y := HiWord(CharPosTmp);
                    Dec(CharPos.X, 4); // �}�[�W����ݒ肷��K�v����
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

                // HintWindow ��Ńn�C�p�[�����N���Ă�ꍇ�́C�q�q���g���o��
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
    // �Q�ƊǗ��_�C�A���O��\��
    if frmReferenceDialog = nil then Application.CreateForm(TfrmReferenceDialog, frmReferenceDialog);
    frmReferenceDialog.ShowModal;

    // ���ׂĂ̕\�����A�b�v�f�[�g
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
// [�w����t���C�����\�肩�珜�O����] �R���e�L�X�g���j���[
begin
    // FPopupDate, Tag �Ԗڂ̍��ڂ��폜����
    // * �_�C�A���O��\�����Ȃ��̂ŁCBeginEdit �͎g��Ȃ�
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
    // �ҏW���̃V���[�g�J�b�g�L�[�ɂ��A�C�e���ړ���h��
    if not TodoListView.IsEditing then
        FTodoUpdateManager.moveUpTodo(TodoListView.Selected);
end;

procedure TfrmCalendar.mnuMoveDownTodoClick(Sender: TObject);
begin
    // �ҏW���̃V���[�g�J�b�g�L�[�ɂ��A�C�e���ړ���h��
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

    // �p�ꃂ�[�h�̏ꍇ�CIME �̐ݒ�͓��{�ꃂ�[�h�̂Ƃ��ƕς��Ȃ���
    // ���Ƀ`�F�b�N�{�b�N�X�̏�Ԃ��ω�������ԂłQ�x�ڂ̃C�x���g�����ł��Ă��܂�.
    // �����ŁCKeyDown �C�x���g���ɕۊǂ�����Ԃ���ς�������ǂ����Ŕ��肷��
    // -- KeyDown �̂Ƃ�����ς���Ă��Ȃ���Ԃ̂Ƃ������������s��

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

// �F�h�胁�j���[�I�����̓���
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
     ('���݂̑I��F', '�p���b�g�P', '�p���b�g�Q', '�p���b�g�R',
     '�p���b�g�S', '�p���b�g�T', '�p���b�g�U');

// �F�h�胁�j���[�̕\��
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

// �F�h�胁�j���[�̃T�C�Y�v�Z
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
        // TODO���X�g���o���Ƃ��CMemoWidth �����ɉ�ʑS���̂Ƃ��� TODO ���X�g�̕��������Ŋm��
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
    // �ҏW���A�C�e�����������ꍇ�̗p�S
    if ItemEdit.Focused then Calgrid.SetFocus;

    //if FConfiguration.AutoSave then begin
    //    mnuSaveClick(Sender);
    //    CanClose := (not FDocument.Dirty)and(FDocument.FileName <> '');
    if FDocument.Dirty then begin
        select := MessageDlg('�t�@�C���͕ύX����Ă��܂��D�ۑ����܂����H', mtInformation, mbYesNoCancel, 0);
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
    // ���j���[��������Ȃ���Βǉ�
    size := FConfiguration.FileHistory.Size;
    while mnuFile.Count < FDefaultFileMenuCount + size do begin
        item:= TMenuItem.Create(mnuFile);
        mnuFile.Add(item);
    end;
    // �]���Ă�Ԃ�͍폜
    while mnuFile.Count > FDefaultFileMenuCount + size do begin
        mnuFile.Items[mnuFile.Count-1].Free;
    end;
    // �X�V
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
        // �Q�ƃA�C�e���ł͔w�i�F��ς���
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
    // �A�C�e������x�N���A
    while PresetZoomRatePopupMenu.Items.Count > DEFAULT_MENU_COUNT do begin
        PresetZoomRatePopupMenu.Items[DEFAULT_MENU_COUNT].Free;
    end;

    // ���X�g��ǉ�
    for i:=0 to FConfiguration.getPresetZoomRateCount-1 do begin
        item := TMenuItem.Create(PresetZoomRatePopupMenu.Items);
        FConfiguration.getPresetZoomRate(i, rows, cols);
        item.Caption := IntToStr(cols) + '��x' + IntToStr(rows) + '�T';
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
            ZoomRateRows.Text := IntToStr(FGridRows) + '�T';
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
    // �V���O���N���b�N�ł̃|�b�v�A�b�v�E�B���h�E�̃��b�N
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

        // �N�����Ƀf�[�^��ǂݍ���ł��āC�����ꂪ�L���Ȃ畜�A����
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

    fileCount := DragQueryFile(handle, $ffffffff, nil, 0); // �t�@�C�����擾
    for i := 0 to fileCount - 1 do begin
        if i>0 then link := link + #13#10;

        size := DragQueryFile(handle, i, nil, 0); // �������擾�D������ size �͏I�[ NUL �����܂܂Ȃ�
        buf := StrAlloc(size + 1);                // NUL �����Ԃ� +1 ���ăo�b�t�@�m��
        DragQueryFile(handle, i, buf, size+1);
        link := link + 'file:"' + string(buf) + '"';
        StrDispose(buf);
    end;

    if (ARow > 0) and (ACol >= 0) then begin
        if FEditing then ItemEditExit(self); // �����\��ҏW���Ȃ����

        // �u�ǉ��\��t���v�A�N�V����������Ă��܂�
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
