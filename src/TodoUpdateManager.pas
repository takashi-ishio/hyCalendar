unit TodoUpdateManager;
// TODOリストはメインフォームとTODOダイアログの２箇所に表示されるので，
// 操作や表示などは一貫して TodoUpdateManager オブジェクトが行う

interface

uses
    Classes, ComCtrls, Controls, Dialogs, SysUtils, Forms, Menus, Clipbrd,
    Contnrs, Math, StrUtils,
    CalendarDocument, TodoList,
    TodolistCopy, CalendarConfig,
    CalendarFont,
    Hyperlinks;

type
    TTodoItemReference = class
    private
        FTodoItem: TTodoItem;

        function getLastUpdated: TDateTime;
    public
        constructor Create(todo: TTodoItem);
        property TodoItem: TTodoItem read FTodoItem;
        property LastUpdated: TDateTime read getLastUpdated;
    end;

    TTodoUpdateManager = class
    private
        FListeners: TObjectList;
        FHideCheckedTodo: Boolean;
        FConfiguration: TCalendarConfiguration;
        FFonts: TFontMap;
        FHyperlink: THyperlink;


        constructor Create;
        function getCount: integer;
        function getListener(index: integer): TListView;

        procedure updateView(view: TListView);
        procedure setHideCheckedTodo(hide: boolean);

        procedure moveTodo(item: TListItem; direction: TSearchDirection);
        procedure swapItem(src_idx, target_idx: integer);

    public
        class function getInstance: TTodoUpdateManager;
        class procedure Cleanup;
        destructor Destroy; override;

        procedure registerListener(view: TListView);

        procedure setupTodoLinkPopupMenu(view: TListview; menu: TPopupMenu);

        procedure findAllVisibleTodoItems(result: TStringList);

        procedure updateAllView;

        function getTodoLastUpdated(item: TListItem): TDateTime;
        function getTodoItem(item: TListItem): TTodoItem;
        function getTodoItemReference(item: TListItem): TTodoItemReference;

        function isEditable(item: TListItem): boolean;

        procedure addTodo(Sender: TListView);
        procedure deleteTodo(item: TListItem);
        procedure moveUpTodo(item: TListItem);
        procedure moveDownTodo(item: TListItem);

        procedure setConfiguration(config: TCalendarConfiguration);

        procedure copyToClipboard;

        procedure updateCheckbox(item: TListItem);
        procedure updateCaption(item: TListItem; var s: string);

        property ViewCount: integer read getCount;
        property View[index: integer]: TListView read getListener;

        property HideCheckedTodo: boolean read FHideCheckedTodo write setHideCheckedTodo;
    end;


implementation

uses
    Calendar, DocumentManager;
var
    theInstance : TTodoUpdateManager;


constructor TTodoItemReference.Create(todo: TTodoItem);
begin
    FTodoItem := todo;
end;

function TTodoItemReference.getLastUpdated: TDateTime;
begin
    Result := FTodoItem.LastUpdated;
end;

class function TTodoUpdateManager.getInstance: TTodoUpdateManager;
begin
    if (theInstance = nil) then begin
        theInstance := TTodoUpdateManager.Create;
    end;
    Result := theInstance;
end;

class procedure TTodoUpdateManager.Cleanup;
begin
    if theInstance <> nil then begin
        theInstance.Free;
        theInstance := nil;
    end;
end;

constructor TTodoUpdateManager.Create;
begin
    FListeners := TObjectList.Create(false);
    FHideCheckedTodo := false;
    FHyperlink := THyperlink.Create;
end;

destructor TTodoUpdateManager.Destroy;
begin
    FListeners.Free;
    FHyperlink.Free;
    if (FFonts = nil) then FFonts.Free;
end;


procedure TTodoUpdateManager.setConfiguration(config: TCalendarConfiguration);
begin
    FConfiguration    := config;
    FFonts := TFontMap.Create(FConfiguration);
    FHideCheckedTodo := config.HideCompletedTodo;
end;

procedure TTodoUpdateManager.setupTodoLinkPopupMenu(view: TListview; menu: TPopupMenu);
const
    DEFAULT_MENU_COUNT = 9;
var
    i: integer;
    item: TMenuItem;
    todoItem: TTodoItem;
    todoItemReference: TTodoItemReference;
begin
    while menu.Items.Count > DEFAULT_MENU_COUNT do begin
        menu.Items[DEFAULT_MENU_COUNT].Free;
    end;

    if View.Selected = nil then exit;
    todoItem := getTodoItem(view.Selected);
    if todoItem = nil then begin
        todoItemReference := getTodoItemReference(view.Selected);
        if todoItemReference = nil then exit;
        todoItem := todoItemReference.TodoItem;
    end;
    if todoItem.URLCount = 0 then exit;

    item := TMenuItem.Create(menu);
    item.Caption := '-';
    menu.Items.Add(item);

    for i:=0 to todoItem.URLCount-1 do begin
        item := TMenuItem.Create(menu);
        item.Caption := todoItem.URLs[i];
        item.OnClick := FHyperlink.HyperLinkDblClick;
        menu.Items.Add(item);
    end;

end;

procedure TTodoUpdateManager.registerListener(view: TListView);
begin
    FListeners.Add(view);
end;

function TTodoUpdateManager.getListener(index: integer): TListView;
begin
    Result := FListeners[index] as TListView;
end;

function TTodoUpdateManager.getCount: integer;
begin
    Result := FListeners.Count;
end;

procedure TTodoUpdateManager.updateAllView;
var
    i: integer;
begin
    for i:=0 to ViewCount-1 do updateView(View[i])
end;

function TTodoUpdateManager.getTodoItem(item: TListItem): TTodoItem;
var
    obj: TObject;
begin
    obj := TObject(item.Data);
    if obj is TTodoItem then Result := obj as TTodoItem
    else Result := nil;
end;

procedure TTodoUpdateManager.setHideCheckedTodo(hide: boolean);
var
    i, j: integer;
begin
    FConfiguration.HideCompletedTodo := hide;
    
    if (not FHideCheckedTodo) and hide then begin
        // チェック済みTODOを消去
        FHideCheckedTodo := hide;
        for i:=0 to ViewCount-1 do begin
            j := 0;
            while j < View[i].Items.Count do begin
                if View[i].Items[j].Checked then View[i].Items[j].Delete
                else inc(j);
            end;
        end;
    end else if FHideCheckedTodo and not hide then begin
        // 再表示時は，アイテムを追加しなおす
        FHideCheckedTodo := hide;
        updateAllView;
    end;
end;

// ビューのアイテムを１度クリアして書き直す
procedure TTodoUpdateManager.updateView(view: TListView);
var
    i, idx: integer;
    item: TListItem;
    todo: TTodoItem;
    doc: TCalendarDocument;
begin
    view.Items.Clear;
    view.Font := FFonts.TodoViewFont;

    // メインドキュメントの情報はきちんと追加
    doc := TDocumentManager.getInstance.MainDocument;
    for i:= 0 to doc.TodoItems.Count-1 do begin
        todo := doc.TodoItems[i];
        if not (HideCheckedTodo and todo.Checked) then begin
            item := view.Items.Add;
            item.Caption := todo.Name;
            item.Checked := todo.Checked;
            item.Data    := todo;
        end;
    end;
    // 参照ドキュメントの TODO リストは，アイテムへのポインタを付加しない
    for idx:=0 to TDocumentManager.getInstance.VisibleReferenceCount-1 do begin
        if TDocumentManager.getInstance.VisibleReferences[idx] is TCalendarDocument then begin
            doc := TDocumentManager.getInstance.VisibleReferences[idx] as TCalendarDocument;
            for i:= 0 to doc.TodoItems.Count-1 do begin
                todo := doc.TodoItems[i];
                if not (HideCheckedTodo and todo.Checked) then begin
                    item := view.Items.Add;
                    item.Caption := todo.Name;
                    item.Checked := todo.Checked;
                    item.Data := TTodoItemReference.Create(todo);
                    item.ImageIndex := 0;
                end;
            end;
        end;
    end;

end;

procedure TTodoUpdateManager.findAllVisibleTodoItems(result: TStringList);
var
    i, idx: integer;
    todo: TTodoItem;
    doc: TCalendarDocument;
begin
    result.Clear;

    // メインドキュメントの情報はきちんと追加
    doc := TDocumentManager.getInstance.MainDocument;
    for i:= 0 to doc.TodoItems.Count-1 do begin
        todo := doc.TodoItems[i];
        result.AddObject(todo.Name, todo);
    end;
    // 参照ドキュメントの TODO リストは，アイテムへのポインタを付加しない
    for idx:=0 to TDocumentManager.getInstance.VisibleReferenceCount-1 do begin
        if TDocumentManager.getInstance.VisibleReferences[idx] is TCalendarDocument then begin
            doc := TDocumentManager.getInstance.VisibleReferences[idx] as TCalendarDocument;
            for i:= 0 to doc.TodoItems.Count-1 do begin
                todo := doc.TodoItems[i];
                result.AddObject(todo.Name, todo);
            end;
        end;
    end;
end;

procedure TTodoUpdateManager.updateCheckbox(item: TListItem);
var
    i: integer;
    viewItem: TListItem;
    todoItem : TTodoItem;
begin
    todoItem := getTodoItem(item);
    if (todoItem <> nil) and (todoItem.Checked <> item.Checked) then begin
        todoItem.Checked := item.Checked;

        for i:=0 to ViewCount-1 do begin
            viewItem := View[i].FindData(0, Item.Data, true, false);
            if viewItem <> nil then begin
                viewItem.Checked := item.Checked;
            end else begin
                if (not item.Checked) then updateView(View[i]);
            end;
        end;

        TDocumentManager.getInstance.MainDocument.Dirty := true;

        if todoItem.DateCount > 0 then frmCalendar.CalGrid.Repaint;
    end else if (todoItem = nil) and (TTodoItemReference(Item.Data).TodoItem.Checked <> item.Checked) then begin
        // アイテムが参照ファイルの場合，変更を元に戻す
        item.Checked := TTodoItemReference(Item.Data).TodoItem.Checked;
    end;
end;

procedure TTodoUpdateManager.updateCaption(item: TListItem; var s: string);
var
    i: integer;
    viewItem: TListItem;
    todoItem : TTodoItem;
begin
    todoItem := getTodoItem(Item);
    if (todoItem <> nil) and (todoItem.Name <> s) then begin
        todoItem.Name := s;

        for i:=0 to ViewCount-1 do begin
            viewItem := View[i].FindData(0, Item.Data, true, false);
            if viewItem <> nil then viewItem.Caption := s;
        end;

        TDocumentManager.getInstance.MainDocument.Dirty := true;
        if todoItem.DateCount > 0 then frmCalendar.CalGrid.Repaint;
    end else if (todoItem = nil) and (item.Caption <> s) then begin
        // アイテムが参照ファイルの場合，変更を元に戻す
        s := item.Caption;
    end;
end;


procedure TTodoUpdateManager.addTodo(Sender: TListView);
var
    TodoItem : TTodoItem;
    item: TListItem;
    i: integer;
    doc: TCalendarDocument;

    function findLastItem(view: TListView): integer;
    var
        j: integer;
    begin
        j := 0;
        while (j<view.Items.Count)and(getTodoItem(view.Items[j])<>nil) do inc(j);
        Result := j;
    end;

begin
    TodoItem := TTodoItem.Create;
    TodoItem.Name := '新しいTodoItem';
    doc := TDocumentManager.getInstance.MainDocument;
    doc.TodoItems.add(TodoItem);

    // 適切な位置に挿入する必要アリ
    for i:=0 to ViewCount-1 do begin
        item := View[i].Items.Insert(findLastItem(view[i]));
        item.Caption := TodoItem.Name;
        item.Data := TodoItem;
        if View[i] = Sender then begin
            Sender.Selected := item;
            Sender.Selected.EditCaption;
        end;
    end;

    doc.Dirty := true;

end;

procedure TTodoUpdateManager.deleteTodo(item: TListItem);
var
    todoItem: TTodoITem;
    viewItem: TListItem;
    i: integer;
begin
    if item <> nil then begin
        todoItem := getTodoItem(item);
        if todoItem = nil then exit;
        if MessageDlg('"' + todoItem.Name + '" を削除します．よろしいですか？', mtConfirmation, mbOKCancel, 0) = mrOk then begin

            for i:=0 to ViewCount-1 do begin
                viewItem := View[i].FindData(0, Item.Data, true, false);
                if viewItem <> nil then View[i].Items.Delete(View[i].Items.IndexOf(viewItem));
            end;

            TDocumentManager.getInstance.MainDocument.TodoItems.remove(todoItem);
            TDocumentManager.getInstance.MainDocument.Dirty := true;
            if todoItem.DateCount > 0 then frmCalendar.CalGrid.Repaint;
        end;

    end;
end;


procedure TTodoUpdateManager.swapItem(src_idx, target_idx: integer);
// ListView 上で start_idx, end_idx の中身を交換
var
    view_idx: integer;
    src_item, target_item: TListItem;
    src_todo, target_todo: TTodoItem;
begin
    for view_idx:=0 to ViewCount-1 do begin
        src_item := view[view_idx].Items[src_idx];
        src_todo := getTodoItem(src_item);

        target_item := view[view_idx].Items[target_idx];
        target_todo := getTodoItem(target_item);

        // 一方でも nil なら（参照ドキュメントのデータなら）並び替えできない
        if (src_todo = nil) or (target_todo = nil) then break;

        // 先に Data を 変えないと Checked の更新でイベントが発生してしまう
        src_item.Data    := target_todo;
        target_item.Data := src_todo;

        src_item.Caption := target_todo.Name;
        src_item.Checked := target_todo.Checked;
        target_item.Caption := src_todo.Name;
        target_item.Checked := src_todo.Checked;
    end;
end;

procedure TTodoUpdateManager.moveTodo(item: TListItem; direction: TSearchDirection);
var
    target: TListItem;
    todoItem : TTodoItem;
begin
    if item <> nil then begin
        todoItem := getTodoItem(item);
        if todoItem = nil then exit;
        target := item.ListView.GetNextItem(item, direction, [isNone]);
        if (target <> nil) then begin
            TDocumentManager.getInstance.MainDocument.TodoItems.move(todoitem, TTodoItem(target.Data));
            TDocumentManager.getInstance.MainDocument.Dirty := true;
            frmCalendar.CalGrid.Repaint;

            swapItem(item.Index, target.Index);

            target.Selected := true;
            target.Focused := true;
            target.MakeVisible(false);
            item.ListView.SetFocus;
        end;
    end;
end;

procedure TTodoUpdateManager.moveUpTodo(item: TListItem);
begin
    moveTodo(item, sdAbove);
end;

procedure TTodoUpdateManager.moveDownTodo(item: TListItem);
begin
    moveTodo(item, sdBelow);
end;


procedure TTodoUpdateManager.copyToClipboard;
const
    CRLF = #13#10;
var
    s: string;
    todo: TTodoItem;
    unchecked_head: string;
    checked_head: string;
    doc: TCalendarDocument;
    idx: integer;

    procedure makeTodoString;
    var i: integer;
    begin
        for i:= 0 to doc.TodoItems.Count-1 do begin
            todo := doc.TodoItems[i];
            if FConfiguration.CopyTodoAll or not todo.Checked then begin
                s := s + IfThen(todo.Checked, checked_head, unchecked_head) + todo.Name + CRLF;
            end;
        end;
    end;
begin
    if frmTodolistCopyDialog = nil then  Application.CreateForm(TfrmTodolistCopyDialog, frmTodolistCopyDialog);

    if frmTodolistCopyDialog.Execute(FConfiguration) then begin

        s := '';

        if FConfiguration.CopyTodoWithHeadString then begin
            unchecked_head := FConfiguration.CopyTodoHead;
            checked_head := FConfiguration.CopyTodoHeadForCompleted;
        end else begin
            unchecked_head := '';
            checked_head := '';
        end;

        doc := TDocumentManager.getInstance.MainDocument;
        makeTodoString;

        for idx := 0 to TDocumentManager.getInstance.ReferenceCount-1 do begin
            if TDocumentManager.getInstance.References[idx] is TCalendarDocument then begin
                doc := TDocumentManager.getInstance.References[idx] as TCalendarDocument;
                makeTodoString;
            end;
        end;

        Clipboard.AsText := s;
    end;
end;

function TTodoUpdateManager.getTodoLastUpdated(item: TListItem): TDateTime;
var
    obj: TObject;
begin
    obj := TObject(item.Data);
    if obj is TTodoItem then
        Result := (obj as TTodoItem).LastUpdated
    else if obj is TTodoItemReference then
        Result := (obj as TTodoItemReference).LastUpdated
    else Result := Date;
end;

function TTodoUpdateManager.getTodoItemReference(item: TListItem): TTodoItemReference;
var
    obj: TObject;
begin
    obj := TObject(item.Data);
    if obj is TTodoItemReference then Result := obj as TTodoItemReference
    else Result := nil;
end;

// caption の変更を許可するかどうか
function TTodoUpdateManager.isEditable(item: TListItem): boolean;
begin
    Result := (getTodoItem(item) <> nil);
end;

end.
