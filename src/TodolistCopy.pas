unit TodolistCopy;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, CalendarConfig;

type
  TfrmTodolistCopyDialog = class(TForm)
    CopyAllItemCheck: TCheckBox;
    CopyListToClipboardBtn: TBitBtn;
    BitBtn1: TBitBtn;
    TodoItemHeadText: TEdit;
    AddHeadTextCheck: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    TodoCompletedItemHeadText: TEdit;
    procedure FormCreate(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
    function Execute(config: TCalendarConfiguration): boolean;
  end;

var
  frmTodolistCopyDialog: TfrmTodolistCopyDialog;

implementation

{$R *.dfm}

function TfrmTodolistCopyDialog.Execute(config: TCalendarConfiguration): boolean;
begin
    // 設定を取得してダイアログに設定
    CopyAllItemCheck.Checked := config.CopyTodoAll;
    AddHeadTextCheck.Checked := config.CopyTodoWithHeadString;
    TodoItemHeadText.Text    := config.CopyTodoHead;
    TodoCompletedItemHeadText.Text := config.CopyTodoHeadForCompleted;

    self.ShowModal;

    // 設定を保存
    if self.ModalResult = mrOk then begin
        config.CopyTodoAll := CopyAllItemCheck.Checked;
        config.CopyTodoWithHeadString := AddHeadTextCheck.Checked;
        config.CopyTodoHead := TodoItemHeadText.Text;
        config.CopyTodoHeadForCompleted := TodoCompletedItemHeadText.Text;

        Result := true;
    end else Result := false;
end;

procedure TfrmTodolistCopyDialog.FormCreate(Sender: TObject);
begin
    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;

end;

end.
