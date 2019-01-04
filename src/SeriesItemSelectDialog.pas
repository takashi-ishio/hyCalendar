unit SeriesItemSelectDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, SeriesItem;

type
  TfrmSeriesItemSelectDialog = class(TForm)
    SeriesList: TListBox;
    Panel1: TPanel;
    SeriesEdit: TEdit;
    SeriesSelectBtn: TButton;
    procedure SeriesListClick(Sender: TObject);
    procedure SeriesListDblClick(Sender: TObject);
    procedure SeriesSelectBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
    function Execute(items: TSeriesItemList; AllowNewItem: boolean): TSeriesItem;
  end;

var
  frmSeriesItemSelectDialog: TfrmSeriesItemSelectDialog;

implementation

{$R *.dfm}

function TfrmSeriesItemSelectDialog.Execute(items: TSeriesItemList; AllowNewItem: boolean): TSeriesItem;
var
    i: integer;
    old_index: integer;
    item : TSeriesItem;
begin
    old_index := SeriesList.ItemIndex;
    SeriesList.Clear;

    if AllowNewItem then SeriesList.AddItem('（新しい予定の作成）', nil);

    for i:=0 to items.Count-1 do begin
        SeriesList.AddItem(items[i].Name, items[i]);
    end;
    if (-1 < old_index) and (old_index < SeriesList.Items.Count) then begin
        SeriesList.ItemIndex := old_index
    end else begin
        if SeriesList.Items.Count = 0 then begin
            MessageDlg('周期予定がありません．', mtInformation, [mbOK], 0);
            Result := nil;
            Exit;
        end;
        SeriesList.ItemIndex := 0;
    end;
    SeriesEdit.Text := SeriesList.Items[SeriesList.ItemIndex];

    if ShowModal = mrOk then begin
        item := SeriesList.Items.Objects[SeriesList.ItemIndex] as TSeriesItem;
        if item = nil then item := items.Add;
        Result := item;
    end else Result := nil;

end;


procedure TfrmSeriesItemSelectDialog.FormCreate(Sender: TObject);
begin
    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;

end;

procedure TfrmSeriesItemSelectDialog.SeriesListClick(Sender: TObject);
begin
    SeriesEdit.Text := SeriesList.Items[SeriesList.ItemIndex];
end;

procedure TfrmSeriesItemSelectDialog.SeriesListDblClick(Sender: TObject);
begin
    SeriesEdit.Text := SeriesList.Items[SeriesList.ItemIndex];
    Self.ModalResult := mrOk;
end;

procedure TfrmSeriesItemSelectDialog.SeriesSelectBtnClick(Sender: TObject);
begin
    if SeriesList.ItemIndex >= 0 then Self.ModalResult := mrOK;
end;

end.
