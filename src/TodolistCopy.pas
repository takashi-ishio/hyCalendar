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
    { Private �錾 }
  public
    { Public �錾 }
    function Execute(config: TCalendarConfiguration): boolean;
  end;

var
  frmTodolistCopyDialog: TfrmTodolistCopyDialog;

implementation

{$R *.dfm}

function TfrmTodolistCopyDialog.Execute(config: TCalendarConfiguration): boolean;
begin
    // �ݒ���擾���ă_�C�A���O�ɐݒ�
    CopyAllItemCheck.Checked := config.CopyTodoAll;
    AddHeadTextCheck.Checked := config.CopyTodoWithHeadString;
    TodoItemHeadText.Text    := config.CopyTodoHead;
    TodoCompletedItemHeadText.Text := config.CopyTodoHeadForCompleted;

    self.ShowModal;

    // �ݒ��ۑ�
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
