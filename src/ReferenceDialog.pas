unit ReferenceDialog;
// 他のファイルへの参照を管理する．現時点では未実装

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, ExtCtrls, DocumentManager,
  DocumentReference, Imm;

type
  TfrmReferenceDialog = class(TForm)
    Panel1: TPanel;
    ReferenceListView: TListView;
    AddBtn: TBitBtn;
    DeleteBtn: TBitBtn;
    OpenDialog1: TOpenDialog;
    btnReferenceReload: TBitBtn;
    procedure AddBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnReferenceReloadClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ReferenceListViewChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ReferenceListViewEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure ReferenceListViewKeyPress(Sender: TObject; var Key: Char);
  private
    { Private 宣言 }
    documentManager: TDocumentManager;
    FLastChar: Char;
  public
    { Public 宣言 }
  end;

var
  frmReferenceDialog: TfrmReferenceDialog;

implementation

{$R *.dfm}

procedure TfrmReferenceDialog.AddBtnClick(Sender: TObject);
var
    item: TListItem;
    ref: TDocumentReference;
begin
    if OpenDialog1.Execute then begin
        if documentManager.AddReference(OpenDialog1.FileName) then begin
          ref := documentManager.References[documentManager.ReferenceCount-1];
          item := ReferenceListView.Items.Add;
          item.Data := ref;
          item.Caption := ref.Header;
          item.Checked := true;
          item.SubItems.Add(ref.Filename);
          item.SubItems.Add(ref.Status);
        end else begin
          MessageDlg('そのファイルは参照リストに加えることができません．現在編集中か，既に参照されています．', mtInformation, [mbOK], 0);
        end;
    end;
end;

procedure TfrmReferenceDialog.DeleteBtnClick(Sender: TObject);
var
    ref: TDocumentReference;
begin
    if (ReferenceListView.Selected <> nil) then begin
        ref := TDocumentReference(ReferenceListView.Selected.Data);
        if MessageDlg(ref.Header + ' への参照を解除します．よろしいですか？',
                    mtConfirmation, mbOKCancel, 0) = mrOK then begin
            documentManager.RemoveReference(ReferenceListView.ItemIndex);
            ReferenceListView.Selected.Delete;
        end;
    end;
end;

procedure TfrmReferenceDialog.FormCreate(Sender: TObject);
begin
    documentManager := TDocumentManager.getInstance;
    ImmAssociateContext(ReferenceListView.Handle, 0);
    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;
end;

procedure TfrmReferenceDialog.FormShow(Sender: TObject);
var
    i: integer;
    item : TListItem;
begin
    ReferenceListView.Items.Clear;
    for i:=0 to documentManager.ReferenceCount-1 do begin
        item := ReferenceListView.Items.Add;
        item.Data := documentManager.References[i];
        item.Checked := documentManager.References[i].Visible;
        item.Caption := documentManager.References[i].Header;
        item.SubItems.Add(documentManager.References[i].Filename);
        item.SubItems.Add(documentManager.References[i].Status);
    end;
end;

procedure TfrmReferenceDialog.btnReferenceReloadClick(Sender: TObject);
begin
    documentManager.ReloadReferences;
    FormShow(self);   // リスト更新のため
end;

procedure TfrmReferenceDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if Key = VK_F5 then
        btnReferenceReloadClick(Sender);
end;

procedure TfrmReferenceDialog.ReferenceListViewChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
var
    ref: TDocumentReference;
begin
  if (Change = ctState) and (Item <> nil) and (item.Data <> nil) then begin
      ref := TDocumentReference(Item.Data);
      ref.Visible := item.Checked;
  end;
end;

procedure TfrmReferenceDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    documentManager.updateVisibleReferences;
end;

procedure TfrmReferenceDialog.ReferenceListViewEditing(Sender: TObject;
  Item: TListItem; var AllowEdit: Boolean);
begin
    AllowEdit := false;
end;

procedure TfrmReferenceDialog.ReferenceListViewKeyPress(Sender: TObject;
  var Key: Char);
begin
    // 全角スペース入力時は #129, @ の順番で文字が飛んでくる
    if (FLastChar = #129)and(KEY= '@')and (ReferenceListView.ItemFocused <> nil) then
        ReferenceListView.ItemFocused.Checked := not ReferenceListView.ItemFocused.Checked;

    FLastChar := Key;

end;

end.
