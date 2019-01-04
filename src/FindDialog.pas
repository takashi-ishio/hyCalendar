unit FindDialog;
// 検索ダイアログ．

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DateUtils, StdCtrls, ComCtrls, ToolWin, CalendarDocument, CalendarItem,
  Math, Buttons, Menus, Clipbrd, DocumentManager, ExtCtrls,
  CommCtrl, SearchResult;

type

  TfrmFindDialog = class(TForm)
    GroupList: TListView;
    PopupMenu1: TPopupMenu;
    mnuCopyToClipboardWithTab: TMenuItem;
    mnuCopyToClipboardWithCSV: TMenuItem;
    Panel1: TPanel;
    FindBox: TComboBox;
    FindMethodBox: TComboBox;
    SearchBtn: TBitBtn;
    Label1: TLabel;
    StartDate: TDateTimePicker;
    EndDate: TDateTimePicker;
    Label2: TLabel;
    Label3: TLabel;
    chkSearchRangeItem: TCheckBox;
    chkSearchDayItem: TCheckBox;
    chkSearchSeriesItem: TCheckBox;
    Label4: TLabel;
    btnExport: TButton;
    cboExportStyle: TComboBox;
    chkSearchReferenceFile: TCheckBox;
    chkSearchTodo: TCheckBox;
    EndDateEnable: TCheckBox;
    StartDateEnable: TCheckBox;
    Label6: TLabel;
    Label5: TLabel;
    chkSearchDayName: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure SearchBtnClick(Sender: TObject);
    procedure GroupListSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure GroupListColumnClick(Sender: TObject; Column: TListColumn);
    procedure GroupListCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure GroupListDblClick(Sender: TObject);
    procedure FindBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ToolBar1Resize(Sender: TObject);
    procedure mnuCopyToClipboardWithTabClick(Sender: TObject);
    procedure mnuCopyToClipboardWithCSVClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StartDateChange(Sender: TObject);
    procedure EndDateChange(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
  private
    { Private 宣言 }
    FDocument: TCalendarDocument;
    FSortKey: TListColumn;
    FSortReverse: boolean;
    FCaseSensitive: boolean;
    FAutoComplete: boolean;
    procedure searchItems(text: string; target: TFindSettings);
    procedure copyToClipboard(isCSV: boolean);
  protected
    procedure WndProc(var Message: TMessage); override;

  public
    { Public 宣言 }
    isAlreadyShown: boolean;
    procedure setSearchOption(autoComplete, caseSensitive: boolean);
  end;

var
  frmFindDialog: TfrmFindDialog;

implementation

uses
    Calendar, DateFormat, StringSplitter, StrUtils, DateTimePickerEnhance;

{$R *.dfm}

procedure TfrmFindDialog.WndProc(var Message: TMessage);
begin

  if (Message.Msg = CM_SYSFONTCHANGED) then begin

        if self.Visible and not IsIconic(Application.Handle) then begin
            self.Hide;
            self.Show;   // 表示中だったら元に戻す
        end else begin
            // アイコン時は，非表示になっているのでそのまま素通し
            inherited WndProc(Message);
        end;
      Message.Msg := 0;
  end else inherited WndProc(message);
end;


procedure TfrmFindDialog.searchItems(text: string; target: TFindSettings);
var
    listitem: TListItem;
    i: integer;
    searchResult: TSearchResult;
begin
    GroupList.Items.BeginUpdate;
    GroupList.Items.Clear;

    TDocumentManager.getInstance.searchText(text, FindMethodBox.ItemIndex, FCaseSensitive, StartDate.Date, EndDate.Date, target);

    searchResult := TDocumentManager.getInstance.LastSearchResult;
    for i:=0 to searchResult.Count-1 do begin
        listitem := GroupList.Items.Add;
        listitem.Caption := searchResult.Day[i];
        listitem.SubItems.Clear;
        listitem.SubItems.Add(searchResult.Kind[i]);
        listitem.SubItems.Add(searchResult.Rank[i]);
        listitem.SubItems.Add(searchResult.Text[i]);
    end;

    GroupList.Items.EndUpdate;
end;

procedure TfrmFindDialog.FormCreate(Sender: TObject);
begin
    FDocument := TDocumentManager.getInstance.MainDocument;
    FSortKey  := GroupList.Columns[0];
    StartDate.Date := Date;
    EndDate.Date := Date;
    enhancePicker(StartDate);
    enhancePicker(EndDate);
    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;
end;

procedure TfrmFindDialog.SearchBtnClick(Sender: TObject);
var
    target: TFindSettings;
begin
    target := [];
    if chkSearchDayItem.Checked then Include(target, findDayItem);
    if chkSearchRangeItem.Checked then Include(target, findRangeItem);
    if chkSearchSeriesItem.Checked then Include(target, findSeriesItem);
    if chkSearchTodo.Checked then Include(target, findTodoItem);
    if chkSearchDayName.Checked then Include(target, findDayName);
    if chkSearchReferenceFile.Checked then Include(target, findReferences);
    if StartDateEnable.Checked then Include(target, findWithStartDate);
    if EndDateEnable.Checked then Include(target, findWithEndDate);

    if FindBox.Text <> '' then begin
        searchItems(FindBox.Text, target);
        if (FindBox.Items.IndexOf(FindBox.Text) = -1) then begin
            FindBox.AddItem(FindBox.Text, nil);
            frmCalendar.AddFindCache(FindBox.Text);
        end;
        frmCalendar.setMarking(FindBox.Text);
    end else begin
        frmCalendar.setMarking('');
    end;

end;

procedure TfrmFindDialog.GroupListSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
    if Selected and (item <> nil) then begin
        frmCalendar.MoveDate(DateFormat.parseDate(item.Caption), false, false);
        GroupList.SetFocus;
    end;
end;

procedure TfrmFindDialog.GroupListColumnClick(Sender: TObject;
  Column: TListColumn);
begin
    if FSortKey = Column then FSortReverse := not FSortReverse
    else begin
        FSortKey := Column;
        FSortReverse := false;
    end;
    GroupList.AlphaSort;
end;

procedure TfrmFindDialog.GroupListCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
// Result := Item1 - Item2;
var
    c: array [0..3] of integer;
begin
    c[0] := CompareDate(DateFormat.parseDate(Item1.Caption), DateFormat.parseDate(Item2.Caption));
    c[1] := AnsiStrComp( PChar(Item1.SubItems[0]), PChar(Item2.SubItems[0]) );
    c[2] := StrToInt(Item1.SubItems[1])-StrToInt(Item2.SubItems[1]);
    c[3] := AnsiStrComp( PChar(Item1.SubItems[2]), PChar(Item2.SubItems[2]) );

    if FSortReverse then c[FSortKey.Index] := - c[FSortKey.Index];

    if FSortKey.Index = 0 then
        Compare := IfThen(c[0] <> 0, c[0], IfThen(c[1] <> 0, c[1], IfThen(c[2] <> 0, c[2], c[3])))
    else if FSortKey.Index = 1 then
        Compare := IfThen(c[1] <> 0, c[1], IfThen(c[0] <> 0, c[0], IfThen(c[2] <> 0, c[2], c[3])))
    else if FSortKey.Index = 2 then
        Compare := IfThen(c[2] <> 0, c[2], IfThen(c[0] <> 0, c[0], IfThen(c[1] <> 0, c[1], c[3])))
    else if FSortKey.Index = 3 then
        Compare := IfThen(c[3] <> 0, c[3], IfThen(c[0] <> 0, c[0], IfThen(c[1] <> 0, c[1], c[2])));
end;

procedure TfrmFindDialog.FormShow(Sender: TObject);
begin
    FindBox.SetFocus;
end;

procedure TfrmFindDialog.FormActivate(Sender: TObject);
begin
    frmCalendar.setFindCache(FindBox.Items);
    FindBox.AutoComplete := FAutoComplete;  // FConfig.MarkingAutoComplete;
end;

procedure TfrmFindDialog.setSearchOption(autoComplete, caseSensitive: boolean);
begin
    FAutoComplete := autoComplete;
    FCaseSensitive := caseSensitive;
end;

procedure TfrmFindDialog.GroupListDblClick(Sender: TObject);
begin
    if GroupList.Selected <> nil then begin
        frmCalendar.MoveDate(DateFormat.parseDate(GroupList.Selected.Caption), true);
    end;
end;

procedure TfrmFindDialog.FindBoxKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
// このコードは frmCalendar.DirectHyperlinkBoxKeyDown と同じ
var
    combo: TComboBox;
begin
    if Sender is TComboBox then combo := TComboBox(Sender) else exit;

    if Key = VK_RETURN then begin
        combo.DroppedDown := false;
        SearchBtnClick(Sender);
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

procedure TfrmFindDialog.ToolBar1Resize(Sender: TObject);
begin
//    FindBox.Width := Toolbar1.Width - FindMethodBox.Width - SearchBtn.Width - 2 * ToolButton1.Width;
end;

procedure TfrmFindDialog.copyToClipboard(isCSV: boolean);
var
    i: integer;
    str: TStringList;
    item : TListItem;
begin
    str := TStringList.Create;
    for i:=0 to GroupList.Items.Count-1 do begin
        item := GroupList.Items[i];
        if isCSV then begin
            str.Add(item.Caption + ',' + QuotedStr(item.SubItems[2]));
        end else begin
            str.Add(item.Caption + #09 + item.SubItems[2]);
        end;
    end;
    if str.Text <> '' then Clipboard.AsText := str.Text;
    str.Free;
end;

procedure TfrmFindDialog.mnuCopyToClipboardWithTabClick(Sender: TObject);
begin
    copyToClipboard(false);
end;

procedure TfrmFindDialog.mnuCopyToClipboardWithCSVClick(Sender: TObject);
begin
    copyToClipboard(true);
end;

procedure TfrmFindDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    frmCalendar.execDialogShortcut(self, Key, Shift);
end;

procedure TfrmFindDialog.StartDateChange(Sender: TObject);
begin
    StartDateEnable.Checked := true;
end;

procedure TfrmFindDialog.EndDateChange(Sender: TObject);
begin
    EndDateEnable.Checked := true;
end;

procedure TfrmFindDialog.btnExportClick(Sender: TObject);
begin
    if cboExportStyle.ItemIndex = 0 then
        mnuCopyToClipboardWithTabClick(Sender)
    else if cboExportStyle.ItemIndex = 1 then
        mnuCopyToClipboardWithCSVClick(Sender);
end;

end.
