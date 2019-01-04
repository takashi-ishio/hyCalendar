unit ConfigDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CalendarConfig, ExtCtrls, ComCtrls, Menus;

type
  TfrmConfigDialog = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    GroupBox1: TGroupBox;
    TextFontLabel: TLabel;
    TextFontChangeBtn: TButton;
    FontDialog1: TFontDialog;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    GroupBox9: TGroupBox;
    AutoSave: TCheckBox;
    WindowPosSave: TCheckBox;
    GroupBox8: TGroupBox;
    MarkingCaseSensitive: TCheckBox;
    AutoMarkingWhenFind: TCheckBox;
    MarkingAutoComplete: TCheckBox;
    Label3: TLabel;
    DayNameFontLabel: TLabel;
    DayNameFontChangeBtn: TButton;
    Label4: TLabel;
    DayFontLabel: TLabel;
    DayFontChangeBtn: TButton;
    Label5: TLabel;
    HyperlinkFontChangeBtn: TButton;
    HyperlinkFontLabel: TLabel;
    Label6: TLabel;
    FreeMemoFontLabel: TLabel;
    FreeMemoFontChangeBtn: TButton;
    Label7: TLabel;
    RangeItemFontLabel: TLabel;
    RangeItemFontChangeBtn: TButton;
    Label8: TLabel;
    SaveZoomRate: TCheckBox;
    SeriesPlanItemFontChangeBtn: TButton;
    SeriesPlanItemFontLabel: TLabel;
    Label12: TLabel;
    ToolbarSave: TCheckBox;
    TabSheet5: TTabSheet;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    MarkingColorBox: TColorBox;
    ClippedMarkColorBox: TColorBox;
    Label2: TLabel;
    Label9: TLabel;
    TodayColorBox: TColorBox;
    SelectColorBox: TColorBox;
    Label10: TLabel;
    Label11: TLabel;
    TodoFontLabel: TLabel;
    TodoFontChangeBtn: TButton;
    TabSheet6: TTabSheet;
    GroupBox2: TGroupBox;
    HideHyperlinkString: TCheckBox;
    ShowHyperlinkLabel: TCheckBox;
    HyperlinkWithEditMode: TCheckBox;
    SelectDayWithoutMovePageIfVisible: TCheckBox;
    PopupLinkContents: TCheckBox;
    TabSheet7: TTabSheet;
    GroupBox5: TGroupBox;
    EnableDialogCloseShortcut: TCheckBox;
    TabSheet8: TTabSheet;
    GroupBox6: TGroupBox;
    TextAttrList: TListBox;
    Label15: TLabel;
    TextAttrNameEdit: TEdit;
    TextAttrAddBtn: TButton;
    TextAttrColorBox: TColorBox;
    TextAttrBoldCheck: TCheckBox;
    TextAttrItalicCheck: TCheckBox;
    TextAttrUnderlineCheck: TCheckBox;
    TextAttrStrikeoutCheck: TCheckBox;
    Label16: TLabel;
    Label17: TLabel;
    TextAttrReadBtn: TButton;
    TextAttrDelBtn: TButton;
    Label18: TLabel;
    TabSheet9: TTabSheet;
    GroupBox11: TGroupBox;
    TextAttrShowRadio: TRadioButton;
    TextAttrHidePredefinedRadio: TRadioButton;
    TextAttrHideRadio: TRadioButton;
    GroupBox12: TGroupBox;
    DayItemTextAttrShow: TRadioButton;
    DayItemTextAttrHidePredefined: TRadioButton;
    DayItemTextAttrHide: TRadioButton;
    GroupBox13: TGroupBox;
    TextAttrTag: TEdit;
    Label19: TLabel;
    PopupNoHideTimeout: TCheckBox;
    Label20: TLabel;
    HolidayNameFontLabel: TLabel;
    HolidayNameFontChangeBtn: TButton;
    DefaultBackColorBox: TColorBox;
    Label21: TLabel;
    GroupBox14: TGroupBox;
    StartupImeModeOn: TCheckBox;
    AttributeOverrideHyperLinkFont: TCheckBox;
    GroupBox16: TGroupBox;
    CursorCanMoveAnotherRow: TCheckBox;
    TabSheet10: TTabSheet;
    GroupBox4: TGroupBox;
    Label13: TLabel;
    Label14: TLabel;
    ShowTodoItems: TCheckBox;
    ShowTodoLiteral: TCheckBox;
    TodoHeadLiteral: TEdit;
    DoneHeadLiteral: TEdit;
    HideDaystringTodoOnCalendar: TCheckBox;
    GroupBox7: TGroupBox;
    ZoomRateForEachPage: TCheckBox;
    StartFromMonday: TCheckBox;
    GroupBox10: TGroupBox;
    RegistBtn: TButton;
    UnregistBtn: TButton;
    MonthTabSave: TCheckBox;
    MonthTabAutoClose: TCheckBox;
    GroupBox15: TGroupBox;
    Label22: TLabel;
    FileHistorySizeBox: TEdit;
    FileHistorySizeUpDown: TUpDown;
    FileHistoryClearBtn: TButton;
    SaturdayColorBox: TColorBox;
    Label23: TLabel;
    SundayColorBox: TColorBox;
    OtherMonthColorBox: TColorBox;
    Label24: TLabel;
    Label25: TLabel;
    HideCompletedTodoOnCalendar: TCheckBox;
    AutoExtendRowsCheck: TCheckBox;
    GroupBox17: TGroupBox;
    RegisterFreeMemoURLToToolbar: TCheckBox;
    Label26: TLabel;
    DefaultMonthTabBeforeBox: TEdit;
    DefaultMonthTabBeforeUpDown: TUpDown;
    DefaultMonthTabAfterBox: TEdit;
    DefaultMonthTabAfterUpDown: TUpDown;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    TodoViewFontLabel: TLabel;
    TodoViewFontChangeBtn: TButton;
    Label30: TLabel;
    OtherMonthSundayColorBox: TColorBox;
    GroupBox18: TGroupBox;
    TaskTrayCheck: TCheckBox;
    GroupBox19: TGroupBox;
    PopupCellContents: TCheckBox;
    CalendarItemWordWrap: TCheckBox;
    ShowHyperlinkContextMenu: TCheckBox;
    Label31: TLabel;
    Label32: TLabel;
    TodayWidthBox: TEdit;
    TodayWidthUpDown: TUpDown;
    SelectWidthBox: TEdit;
    SelectWidthUpDown: TUpDown;
    UseOtherMonthColorForContents: TCheckBox;
    OtherMonthBackColorBox: TColorBox;
    Label33: TLabel;
    procedure FontChangeBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RegistBtnClick(Sender: TObject);
    procedure UnregistBtnClick(Sender: TObject);
    procedure TextAttrListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure TextAttrReadBtnClick(Sender: TObject);
    procedure TextAttrAddBtnClick(Sender: TObject);
    procedure TextAttrListDblClick(Sender: TObject);
    procedure TextAttrDelBtnClick(Sender: TObject);
    procedure FileHistoryClearBtnClick(Sender: TObject);
  private
    { Private 宣言 }
    FUpdate : boolean;
    FFont : array[0..MAX_SCREEN_FONT_INDEX] of TFont;
    FFontLabel: array[0..MAX_SCREEN_FONT_INDEX] of TLabel;
    FFontButton: array[0..MAX_SCREEN_FONT_INDEX] of TButton;
    FConfiguration: TCalendarConfiguration;
    function getFontName(f: TFont): string;
  public
    { Public 宣言 }
    function Execute(config: TCalendarConfiguration): boolean;
  end;

var
  frmConfigDialog: TfrmConfigDialog;

implementation

uses FileExtRegisteration, StrUtils;

{$R *.dfm}

function TfrmConfigDialog.Execute(config: TCalendarConfiguration): boolean;
var
    i: integer;
begin
    FConfiguration := config;

    FUpdate := false;

    // 設定を全部ダイアログにコピー
    // copy fonts
    for i:=0 to MAX_SCREEN_FONT_INDEX do begin
        FFont[i].Assign(config.Fonts(i));
    end;

    for i:=0 to MAX_SCREEN_FONT_INDEX do begin
        FFontLabel[i].Font := FFont[i];
        FFontLabel[i].Caption := getFontName(FFont[i]);
    end;
    config.CheckoutTextAttributeList(TextAttrList.Items);

    MarkingColorBox.Selected := config.MarkingColor;
    ZoomRateForEachPage.Checked := config.ZoomRateForEachPage;
    AutoSave.Checked := config.AutoSave;
    WindowPosSave.Checked := config.WindowPosSave;
    HyperlinkWithEditMode.Checked := config.HyperlinkWithEditMode;
    HideHyperlinkString.Checked := config.HideHyperlinkString;
    SelectDayWithoutMovePageIfVisible.Checked := config.SelectDayWithoutMovePageIfVisible;
    MarkingCaseSensitive.Checked := config.MarkingCaseSensitive;
    AutoMarkingWhenFind.Checked := config.AutoMarkingWhenFind;
    ToolbarSave.Checked := config.ToolbarSave;
    PopupLinkContents.Checked := config.PopupLinkContents;
    PopupNoHideTimeout.Checked := config.PopupNoHideTimeout;
    ShowHyperlinkLabel.Checked := config.ShowHyperlinkLabel;
    ShowHyperlinkContextMenu.Checked := config.ShowHyperlinkContextMenu;
    PopupCellContents.Checked := config.PopupCellContents;
    MarkingAutoComplete.Checked := config.MarkingAutoComplete;
    ClippedMarkColorBox.Selected := config.ClippedMarkColor;
    DefaultBackColorBox.Selected := config.DefaultBackColor;
    TodayColorBox.Selected := config.TodayCursorColor;
    TodayWidthUpDown.Position := config.TodayCursorWidth;
    SelectColorBox.Selected := config.SelectCursorColor;
    SelectWidthUpDown.Position := config.SelectCursorWidth;
    SaveZoomRate.Checked := config.SaveZoomRate;
    StartFromMonday.Checked := config.StartFromMonday;
    ShowTodoLiteral.Checked := config.ShowTodoLiteral;
    TodoHeadLiteral.Text := config.TodoHeadLiteral;
    DoneHeadLiteral.Text := config.DoneHeadLiteral;
    SaturdayColorBox.Selected := config.SaturdayColor;
    SundayColorBox.Selected := config.SundayColor;
    OtherMonthColorBox.Selected := config.OtherMonthColor;
    OtherMonthSundayColorBox.Selected := config.OtherMonthSundayColor;
    UseOtherMonthColorForContents.Checked := config.UseOtherMonthColorForContents;
    OtherMonthBackColorBox.Selected := config.OtherMonthBackColor;
    HideCompletedTodoOnCalendar.Checked := config.HideCompletedTodoOnCalendar;
    ShowTodoItems.Checked := Config.ShowTodoItems;
    EnableDialogCloseShortcut.Checked := config.EnableDialogCloseShortcut;
    TextAttrShowRadio.Checked := (not config.HideTextAttrOnPopup);
    TextAttrHidePredefinedRadio.Checked := config.HideTextAttrOnPopup and config.HidePredefinedTextAttrOnPopup;
    TextAttrHideRadio.Checked := config.HideTextAttrOnPopup and not config.HidePredefinedTextAttrOnPopup;
    DayItemTextAttrShow.Checked := (not config.HideTextAttrOnDayItem);
    DayItemTextAttrHidePredefined.Checked := config.HideTextAttrOnDayItem and config.HidePredefinedTextAttrOnDayItem;
    DayItemTextAttrHide.Checked := config.HideTextAttrOnDayItem and not config.HidePredefinedTextAttrOnDayItem;
    TextAttrTag.Text := config.TextAttrTag;
    CalendarItemWordWrap.Checked := config.CalendarItemWordWrap;
    StartupImeModeOn.Checked := config.StartupImeModeOn;
    AttributeOverrideHyperLinkFont.Checked := config.TextAttrOverrideHyperlinkFont;
    FileHistorySizeUpDown.Position := config.FileHistory.Size;
    FileHistorySizeBox.Text := IntToStr(FileHistorySizeUpDown.Position);
    FileHistoryClearBtn.Enabled := config.FileHistory.hasEntry;
    CursorCanMoveAnotherRow.Checked := config.CursorCanMoveAnotherRow;
    MonthTabSave.Checked := config.MonthTabSave;
    MonthTabAutoClose.Checked := config.MonthTabAutoClose;
    HideDaystringTodoOnCalendar.Checked := config.HideDaystringTodoOnCalendar;
    AutoExtendRowsCheck.Checked := config.AutoExtendRows;
    RegisterFreeMemoURLToToolbar.Checked := config.RegisterFreeMemoURLToToolbar;
    DefaultMonthTabBeforeUpDown.Position := config.DefaultMonthTabBefore;
    DefaultMonthTabAfterUpDown.Position := config.DefaultMonthTabAfter;
    TaskTrayCheck.Checked := config.UseTaskTray;


    ShowModal;

    if FUpdate then begin

        // OK が押された場合のみ設定を書き戻す

        // copy fonts
        for i:=0 to MAX_SCREEN_FONT_INDEX do begin
            config.Fonts(i).Assign(FFont[i]);
        end;
        config.CheckinTextAttributeList(TextAttrList.Items);
        config.MarkingColor := MarkingColorBox.Selected;
        config.WindowPosSave := WindowPosSave.Checked;
        config.ZoomRateForEachPage := ZoomRateForEachPage.Checked;
        config.HyperlinkWithEditMode := HyperlinkWithEditMode.Checked;
        config.AutoSave := AutoSave.Checked;
        config.HideHyperlinkString := HideHyperlinkString.Checked;
        config.MarkingCaseSensitive := MarkingCaseSensitive.Checked;
        config.AutoMarkingWhenFind := AutoMarkingWhenFind.Checked;
        config.ToolbarSave := ToolbarSave.Checked;
        config.PopupLinkContents := PopupLinkContents.Checked;
        config.PopupNoHideTimeout := PopupNoHideTimeout.Checked;
        config.ShowHyperlinkLabel := ShowHyperlinkLabel.Checked;
        config.ShowHyperlinkContextMenu := ShowHyperlinkContextMenu.Checked;

        config.PopupCellContents := PopupCellContents.Checked;
        config.MarkingAutoComplete := MarkingAutoComplete.Checked;
        config.ClippedMarkColor := ClippedMarkColorBox.Selected;
        config.DefaultBackColor := DefaultBackColorBox.Selected;
        config.TodayCursorColor := TodayColorBox.Selected;
        config.TodayCursorWidth := TodayWidthUpDown.Position;
        config.SelectCursorColor := SelectColorBox.Selected;
        config.SelectCursorWidth := SelectWidthUpDown.Position;
        config.SaturdayColor := SaturdayColorBox.Selected;
        config.SundayColor := SundayColorBox.Selected;
        config.OtherMonthColor := OtherMonthColorBox.Selected;
        config.OtherMonthSundayColor := OtherMonthSundayColorBox.Selected;
        config.UseOtherMonthColorForContents := UseOtherMonthColorForContents.Checked;
        config.OtherMonthBackColor := OtherMonthBackColorBox.Selected;
        config.SaveZoomRate := SaveZoomRate.Checked;
        config.SelectDayWithoutMovePageIfVisible := SelectDayWithoutMovePageIfVisible.Checked;
        config.StartFromMonday := StartFromMonday.Checked;
        config.ShowTodoLiteral := ShowTodoLiteral.Checked;
        config.ShowTodoItems := ShowTodoItems.Checked;
        config.EnableDialogCloseShortcut := EnableDialogCloseShortcut.Checked;
        config.TodoHeadLiteral := TodoHeadLiteral.Text;
        config.DoneHeadLiteral := DoneHeadLiteral.Text;
        config.HideCompletedTodoOnCalendar := HideCompletedTodoOnCalendar.Checked;
        config.CalendarItemWordWrap := CalendarItemWordWrap.Checked;
        config.RegisterFreeMemoURLToToolbar := RegisterFreeMemoURLToToolbar.Checked;

        config.StartupImeModeOn := StartupImeModeOn.Checked;

        config.HideTextAttrOnPopup := not TextAttrShowRadio.Checked;
        config.HidePredefinedTextAttrOnPopup := config.HideTextAttrOnPopup and TextAttrHidePredefinedRadio.Checked;
        config.TextAttrTag := AnsiLeftStr(TextAttrTag.Text, 1);

        config.HideTextAttrOnDayItem := not DayItemTextAttrShow.Checked;
        config.HidePredefinedTextAttrOnDayItem := config.HideTextAttrOnDayItem and DayItemTextAttrHidePredefined.Checked;

        config.TextAttrOverrideHyperlinkFont := AttributeOverrideHyperLinkFont.Checked;
        config.FileHistory.Size := FileHistorySizeUpDown.Position;
        config.CursorCanMoveAnotherRow := CursorCanMoveAnotherRow.Checked;

        config.MonthTabSave := MonthTabSave.Checked;
        config.MonthTabAutoClose := MonthTabAutoClose.Checked;
        config.HideDaystringTodoOnCalendar := HideDaystringTodoOnCalendar.Checked;
        config.AutoExtendRows := AutoExtendRowsCheck.Checked;
        config.DefaultMonthTabBefore := DefaultMonthTabBeforeUpDown.Position;
        config.DefaultMonthTabAfter := DefaultMonthTabAfterUpDown.Position ;


        config.UseTaskTray := TaskTrayCheck.Checked;

    end else begin
        // コピーしたデータのうち明示的な破棄が必要なものを処理

        config.CleanupTextAttributeList(TextAttrList.Items);
    end;
    Result := FUpdate;
end;


procedure TfrmConfigDialog.FontChangeBtnClick(Sender: TObject);
var
    i: integer;
begin
    i := 0;
    while i<= MAX_SCREEN_FONT_INDEX do begin
        if FFontButton[i] = Sender then break;
        i:=i+1;
    end;
    if i>MAX_SCREEN_FONT_INDEX then exit;

    FontDialog1.Font.Assign(FFont[i]);
    if FontDialog1.Execute then begin
        FFont[i].assign(FontDialog1.Font);
        FFontLabel[i].Font := FFont[i];
        FFontLabel[i].Caption := getFontName(FFont[i]);
        FFontLabel[i].Repaint;
    end;
end;

procedure TfrmConfigDialog.CancelBtnClick(Sender: TObject);
begin
    FUpdate := false;
    Close;
end;

procedure TfrmConfigDialog.OKBtnClick(Sender: TObject);
begin
    FUpdate := true;
    Close;
end;

procedure TfrmConfigDialog.FormCreate(Sender: TObject);
var
    i: integer;
begin
    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;

    for i:=0 to MAX_SCREEN_FONT_INDEX do begin
        FFont[i] := TFont.Create;
    end;

    FFontLabel[INDEX_TEXTFONT] := TextFontLabel;
    FFontLabel[INDEX_DAYFONT]  := DayFontLabel;
    FFontLabel[INDEX_DAYNAMEFONT] := DayNameFontLabel;
    FFontLabel[INDEX_HYPERLINKFONT] := HyperlinkFontLabel;
    FFontLabel[INDEX_FREEMEMOFONT] := FreeMemoFontLabel;
    FFontLabel[INDEX_RANGEITEMFONT] := RangeItemFontLabel;
    FFontLabel[INDEX_SERIESPLANITEMFONT] := SeriesPlanItemFontLabel;
    FFontLabel[INDEX_TODOFONT] := TodoFontLabel;
    FFontLabel[INDEX_HOLIDAYNAMEFONT] := HolidayNameFontLabel;
    FFontLabel[INDEX_TODOVIEWFONT] := TodoViewFontLabel;

    FFontButton[INDEX_TEXTFONT] := TextFontChangeBtn;
    FFontButton[INDEX_DAYFONT]  := DayFontChangeBtn;
    FFontButton[INDEX_DAYNAMEFONT] := DayNameFontChangeBtn;
    FFontbutton[INDEX_HYPERLINKFONT] := HyperlinkFontChangeBtn;
    FFontButton[INDEX_FREEMEMOFONT] := FreeMemoFontChangeBtn;
    FFontButton[INDEX_RANGEITEMFONT] := RangeItemFontChangeBtn;
    FFontButton[INDEX_SERIESPLANITEMFONT] := SeriesPlanItemFontChangeBtn;
    FFontButton[INDEX_TODOFONT] := TodoFontChangeBtn;
    FFontButton[INDEX_HOLIDAYNAMEFONT] := HolidayNameFontChangeBtn;
    FFontButton[INDEX_TODOVIEWFONT] := TodoViewFontChangeBtn;
end;

function TfrmConfigDialog.getFontName(f: TFont): string;
begin
    Result := f.Name + ' (' + IntToStr(f.Size) + ')';
end;

procedure TfrmConfigDialog.FormDestroy(Sender: TObject);
var
    i: integer;
begin
    for i:=0 to MAX_SCREEN_FONT_INDEX do begin
        FFont[i].Free;
    end;
end;


procedure TfrmConfigDialog.RegistBtnClick(Sender: TObject);
begin
    FileExtRegisteration.RegisterFileExtension;
end;

procedure TfrmConfigDialog.UnregistBtnClick(Sender: TObject);
begin
    FileExtRegisteration.UnregisterFileExtension;
end;

procedure TfrmConfigDialog.TextAttrListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
    offset : integer;
    attr: TTextAttribute;
begin
    with (Control as TListBox).Canvas do begin
	    FillRect(Rect);       // 長方形を消去
	    Offset := 2;

        attr := (Control as TListBox).Items.Objects[index] as TTextAttribute;
	    if attr <> nil then begin
            Font.Color := attr.Color;
            Font.Style := attr.style;
	    TextOut(Rect.Left + Offset, Rect.Top, (Control as TListBox).Items[Index])
	end;

end;

end;

procedure TfrmConfigDialog.TextAttrReadBtnClick(Sender: TObject);
var
    attr: TTextAttribute;
begin
    if TextAttrList.ItemIndex > -1 then begin
        TextAttrNameEdit.Text := TextAttrList.Items[TextAttrList.ItemIndex];
        attr := TextAttrList.Items.Objects[TextAttrList.ItemIndex] as TTextAttribute;
        if attr <> nil then begin
            TextAttrColorBox.Selected := attr.color;
            TextAttrBoldCheck.Checked := (fsBold in attr.style);
            TextAttrItalicCheck.Checked := (fsItalic in attr.style);
            TextAttrUnderlineCheck.Checked := (fsUnderline in attr.style);
            TextAttrStrikeoutCheck.Checked := (fsStrikeOut in attr.style);
        end;
    end;
end;

procedure TfrmConfigDialog.TextAttrAddBtnClick(Sender: TObject);
var
    idx: integer;
    attr: TTextAttribute;

    function getFontStyle: TFontStyles;
    var
        f: TFontStyles;
    begin
        if TextAttrBoldCheck.Checked then f := [fsBold] else f := [];
        if TextAttrItalicCheck.Checked then f := f + [fsItalic];
        if TextAttrUnderlineCheck.Checked then f := f + [fsUnderline];
        if TextAttrStrikeoutCheck.Checked then f := f + [fsStrikeout];
        result := f;
    end;

begin
    if TextAttrNameEdit.Text = '' then begin
        MessageDlg('文字列が指定されていません．', mtError, [mbOK], 0);
        exit;
    end;

    idx := TextAttrList.Items.IndexOf(TextAttrNameEdit.Text);
    if idx > -1 then begin
        if MessageDlg(TextAttrNameEdit.Text + 'の情報を上書きします．よろしいですか？', mtConfirmation, mbOKCancel, 0) = mrOK then begin
            attr := TextAttrList.Items.Objects[idx] as TTextAttribute;
            attr.color := TextAttrColorbox.Selected;
            attr.style := getFontStyle;
            TextAttrList.Repaint;
        end;
    end else begin
        // 新アイテム作成
        attr := TTextAttribute.Create(TextAttrColorbox.Selected);
        attr.style := getFontStyle;
        TextAttrList.Items.AddObject(TextAttrNameEdit.Text, attr);
        TextAttrList.Repaint;
    end;
end;

procedure TfrmConfigDialog.TextAttrListDblClick(Sender: TObject);
begin
    TextAttrReadBtnClick(sender);
end;

procedure TfrmConfigDialog.TextAttrDelBtnClick(Sender: TObject);
var
    attr: TTextAttribute;
begin
    if TextAttrList.ItemIndex = -1 then exit;

    if MessageDlg(TextAttrList.Items[TextAttrList.ItemIndex] + ' の情報を削除してもよろしいですか？', mtConfirmation, mbOKCancel, 0) = mrOK then begin
        attr := TextAttrList.Items.Objects[TextAttrList.ItemIndex] as TTextAttribute;
        attr.Free;
        TextAttrList.Items.Delete(TextAttrList.ItemIndex);
        TextAttrList.Repaint;
    end;
end;

procedure TfrmConfigDialog.FileHistoryClearBtnClick(Sender: TObject);
begin
    FConfiguration.FileHistory.Clear;
    FileHistoryClearBtn.Enabled := FConfiguration.FileHistory.hasEntry;
end;

end.
