unit LogicalExprPropertyEditDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,  Forms,
  Dialogs, StdCtrls, SeriesItemCondition, LogicalExprNode;

type
  TfrmLogicalExprPropertyEditDialog = class(TForm)
    CancelBtn: TButton;
    OKBtn: TButton;
    LogicalExprBox: TComboBox;
    Label11: TLabel;
    ConditionDisabled: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
    procedure setLogicalExpr(item: TLogicalExprNode);
    procedure getLogicalExpr(item: TLogicalExprNode);
  end;

var
  frmLogicalExprPropertyEditDialog: TfrmLogicalExprPropertyEditDialog;

implementation

{$R *.dfm}

procedure TfrmLogicalExprPropertyEditDialog.setLogicalExpr(item: TLogicalExprNode);
begin
    if item <> nil then begin
        LogicalExprbox.ItemIndex := item.Mode;
        ConditionDisabled.Checked := item.Disabled;
        OKbtn.Caption := '更新';
    end else begin
        LogicalExprBox.ItemIndex := 0;
        ConditionDisabled.Checked := false;
        OKbtn.Caption := '追加';
    end;
end;

procedure TfrmLogicalExprPropertyEditDialog.getLogicalExpr(item: TLogicalExprNode);
begin
    item.Mode := LogicalExprbox.ItemIndex;
    item.Disabled := ConditionDisabled.Checked;
end;

procedure TfrmLogicalExprPropertyEditDialog.FormCreate(Sender: TObject);
begin
    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;

end;

procedure TfrmLogicalExprPropertyEditDialog.FormShow(Sender: TObject);
begin
    LogicalExprbox.SetFocus;
end;

end.
