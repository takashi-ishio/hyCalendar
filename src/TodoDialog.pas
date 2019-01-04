unit TodoDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ExtCtrls, ComCtrls, CalendarDocument,
  TodoList, TodoUpdateManager, DocumentManager, Menus, Imm, HintWindow;

type
  TfrmTodoDialog = class(TForm)
    TodoListView: TListView;
    Panel1: TPanel;
    HideCheckedTodo: TCheckBox;
    AddBtn: TBitBtn;
    DeleteBtn: TBitBtn;
    TodoPopupMenu: TPopupMenu;
    mnuAddTodo: TMenuItem;
    mnuDeleteTodo: TMenuItem;
    mnuEditTodo: TMenuItem;
    mnuRefresh: TMenuItem;
    RefreshBtn: TBitBtn;
    MoveUpBtn: TBitBtn;
    MoveDownBtn: TBitBtn;
    mnuMoveUpTodo: TMenuItem;
    mnuMoveDownTodo: TMenuItem;
    CopyListToClipboardBtn: TBitBtn;
    N1: TMenuItem;
    N2: TMenuItem;
    mnuCopyListToClipboard: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure TodoListViewEdited(Sender: TObject; Item: TListItem;
      var S: String);
    procedure TodoListViewChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure HideCheckedTodoClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mnuAddTodoClick(Sender: TObject);
    procedure mnuDeleteTodoClick(Sender: TObject);
    procedure mnuEditTodoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnuRefreshClick(Sender: TObject);
    procedure RefreshBtnClick(Sender: TObject);
    procedure TodoPopupMenuPopup(Sender: TObject);
    procedure MoveUpBtnClick(Sender: TObject);
    procedure MoveDownBtnClick(Sender: TObject);
    procedure CopyListToClipboardBtnClick(Sender: TObject);
    procedure mnuCopyListToClipboardClick(Sender: TObject);
    procedure TodoListViewEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure TodoListViewCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
//    procedure TodoListViewKeyPress(Sender: TObject; var Key: Char);
//    procedure TodoListViewKeyDown(Sender: TObject; var Key: Word;
//      Shift: TShiftState);
  private
    { Private 宣言 }
    FDocument: TCalendarDocument;
    FTodoUpdateManager: TTodoUpdateManager;
//    FTodoListViewBeforeKeyDown: boolean;
    //FHintWindowStack: THintWindowStack;
  public
    { Public 宣言 }
  end;

var
  frmTodoDialog: TfrmTodoDialog;

implementation

uses Calendar;

{$R *.dfm}



procedure TfrmTodoDialog.FormShow(Sender: TObject);
begin
    HideCheckedTodo.Checked := FTodoUpdateManager.HideCheckedTodo;
    TodoListView.OnMouseMove := frmCalendar.TodoListViewMouseMove;
    TodoListView.OnDblClick  := frmCalendar.FreeMemoDblClick;
end;

procedure TfrmTodoDialog.AddBtnClick(Sender: TObject);
begin
    FTodoUpdateManager.addTodo(TodoListView);
end;

procedure TfrmTodoDialog.DeleteBtnClick(Sender: TObject);
begin
    FTodoUpdateManager.deleteTodo(TodoListView.Selected);
end;

procedure TfrmTodoDialog.TodoListViewEdited(Sender: TObject;
  Item: TListItem; var S: String);
begin
    if (item.Data <> nil) then begin
        FTodoUpdateManager.updateCaption(item, s);
    end;
end;

procedure TfrmTodoDialog.TodoListViewChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
    if (item.Data <> nil)then begin
        if Change = ctState then begin
            FTodoUpdateManager.updateCheckbox(item);
        end;
    end;
end;

procedure TfrmTodoDialog.HideCheckedTodoClick(Sender: TObject);
begin
    FTodoUpdateManager.HideCheckedTodo := HideCheckedTodo.Checked;
end;

procedure TfrmTodoDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    frmCalendar.execDialogShortcut(self, Key, Shift);
end;

procedure TfrmTodoDialog.mnuAddTodoClick(Sender: TObject);
begin
    AddBtnClick(Sender);
end;

procedure TfrmTodoDialog.mnuDeleteTodoClick(Sender: TObject);
begin
    DeleteBtnClick(Sender);
end;

procedure TfrmTodoDialog.mnuEditTodoClick(Sender: TObject);
begin
    if TodoListView.Selected <> nil then TodoListView.Selected.EditCaption;
end;

procedure TfrmTodoDialog.FormCreate(Sender: TObject);
begin
    FDocument := TDocumentManager.getInstance.MainDocument;
    FTodoUpdateManager := TTodoUpdateManager.getInstance;
    FTodoUpdateManager.registerListener(TodoListView);

    ImmAssociateContext(TodoListView.Handle, 0);

    FTodoUpdateManager.updateAllView;

    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;
end;

procedure TfrmTodoDialog.mnuRefreshClick(Sender: TObject);
begin
    FTodoUpdateManager.updateAllView;
end;

procedure TfrmTodoDialog.RefreshBtnClick(Sender: TObject);
begin
    FTodoUpdateManager.updateAllView;
end;

procedure TfrmTodoDialog.TodoPopupMenuPopup(Sender: TObject);
begin
    FTodoUpdateManager.setupTodoLinkPopupMenu(TodoListView, TodoPopupMenu);
end;

procedure TfrmTodoDialog.MoveUpBtnClick(Sender: TObject);
begin
    // 編集中のショートカットキーによるアイテム移動を防ぐ
    if not TodoListView.IsEditing then
        FTodoUpdateManager.moveUpTodo(TodoListView.Selected);
end;

procedure TfrmTodoDialog.MoveDownBtnClick(Sender: TObject);
begin
    // 編集中のショートカットキーによるアイテム移動を防ぐ
    if not TodoListView.IsEditing then
        FTodoUpdateManager.moveDownTodo(TodoListView.Selected);
end;

procedure TfrmTodoDialog.CopyListToClipboardBtnClick(Sender: TObject);
begin
    FTodoUpdateManager.copyToClipboard;
end;

procedure TfrmTodoDialog.mnuCopyListToClipboardClick(Sender: TObject);
begin
    FTodoUpdateManager.copyToClipboard;
end;

//procedure TfrmTodoDialog.TodoListViewKeyPress(Sender: TObject;
//  var Key: Char);
//var
//    Imc:HIMC;
//    dwConversion, dwSentence: DWORD;
//begin
//
//    if TodoListView.IsEditing then exit;
//
//    Imc := ImmGetContext(TodoListView.Handle);
//    ImmGetConversionStatus(Imc, dwConversion, dwSentence);
//    ImmReleaseContext(TodoListView.Handle, Imc);
//
//    // 英語モードの場合，IME の設定は日本語モードのときと変わらないが
//    // 既にチェックボックスの状態が変化した状態で，さらにイベントが飛んできてしまう.
//    // そこで，KeyDown イベント時に保管した状態から変わったかどうかで判定する
//    // -- KeyDown のときから変わっていない状態のときだけ処理を行う
//    If ((dwConversion And IME_CMODE_FULLSHAPE) = 0)and(Key=' ')and
//        (FTodoListViewBeforeKeyDown = TodoListView.ItemFocused.Checked) Then begin
//        TodoListView.ItemFocused.Checked := not TodoListView.ItemFocused.Checked;
//        key := #0;
//    end;
//
//end;
//
//procedure TfrmTodoDialog.TodoListViewKeyDown(Sender: TObject;
//  var Key: Word; Shift: TShiftState);
//begin
//    if TodoListView.ItemFocused <> nil then
//        FTodoListViewBeforeKeyDown := TodoListView.ItemFocused.Checked;
//end;

procedure TfrmTodoDialog.TodoListViewEditing(Sender: TObject;
  Item: TListItem; var AllowEdit: Boolean);
begin
    AllowEdit := FTodoUpdateManager.isEditable(TodoListView.ItemFocused);
end;

procedure TfrmTodoDialog.TodoListViewCustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
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

end.
