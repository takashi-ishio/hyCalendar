unit ImportDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ImportText;

type
  TfrmImportDialog = class(TForm)
    GroupBox1: TGroupBox;
    FileNameBrowseBtn: TButton;
    FileNameEdit: TEdit;
    Label1: TLabel;
    ApplyBtn: TButton;
    CancelBtn: TButton;
    GroupBox2: TGroupBox;
    MessageListBox: TListBox;
    ReloadBtn: TButton;
    FileOpenDialog: TOpenDialog;
    procedure FormShow(Sender: TObject);
    procedure FileNameBrowseBtnClick(Sender: TObject);
    procedure ReloadBtnClick(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private éŒ¾ }
    FImportText: TImportText;
    FUpdated: boolean;
  public
    { Public éŒ¾ }
    property ImportApply: boolean read FUpdated;
  end;

var
  frmImportDialog: TfrmImportDialog;

implementation

{$R *.dfm}

uses
    DocumentManager;

procedure TfrmImportDialog.FormCreate(Sender: TObject);
begin
    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;
end;

procedure TfrmImportDialog.FormShow(Sender: TObject);
begin
    FileNameEdit.Text := FileOpenDialog.FileName;
    ReloadBtnClick(Sender);
end;

procedure TfrmImportDialog.FileNameBrowseBtnClick(Sender: TObject);
begin
    if FileOpenDialog.Execute then begin
        FileNameEdit.Text := FileOpenDialog.FileName;
        ReloadBtnClick(Sender);
    end;
end;

procedure TfrmImportDialog.ReloadBtnClick(Sender: TObject);
begin
    if Assigned(FImportText) then FImportText.Free;
    FImportText := TImportText.Create(FileNameEdit.Text);
    MessageListBox.Items.Clear;
    if FImportText.hasError then begin
        MessageListBox.Items.AddStrings(FImportText.ErrorItems);
        MessageListBox.Items.AddStrings(FImportText.FoundItems);
    end else begin
        MessageListBox.Items.AddStrings(FImportText.FoundItems);
    end;
    ApplyBtn.Enabled := (FImportText.ItemCount > 0);
end;

procedure TfrmImportDialog.ApplyBtnClick(Sender: TObject);
begin
    FImportText.apply(TDocumentManager.getInstance.MainDocument);
    FUpdated := true;
    Close;
end;

procedure TfrmImportDialog.CancelBtnClick(Sender: TObject);
begin
    FUpdated := false;
    Close;
end;

end.
