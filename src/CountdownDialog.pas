unit CountdownDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls,
  SeriesItemSelectDialog, SeriesItem,
  CountdownItem, DateTimePickerEnhance;

type
  TfrmCountdown = class(TForm)
    CounterGroup: TGroupBox;
    DisableCheck: TCheckBox;
    radioSpecifiedDate: TRadioButton;
    radioSpecifiedSeriesitem: TRadioButton;
    DateTimePicker1: TDateTimePicker;
    Label1: TLabel;
    SelectedSeriesItemLabel: TLabel;
    btnSelectSeriesitem: TButton;
    Label3: TLabel;
    CountdownLimitBox: TEdit;
    CountDownLimit: TUpDown;
    GroupBox2: TGroupBox;
    CountdownList: TListBox;
    btnDelete: TButton;
    btnDup: TButton;
    btnUp: TButton;
    btnDown: TButton;
    btnAdd: TButton;
    UseCaptionCheck: TCheckBox;
    CaptionBox: TEdit;
    Label2: TLabel;
    Label4: TLabel;
    EveryYearCheck: TCheckBox;
    Label5: TLabel;
    procedure btnAddClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSelectSeriesitemClick(Sender: TObject);
    procedure DateTimePicker1Change(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure CountdownListClick(Sender: TObject);
    procedure radioSpecifiedDateClick(Sender: TObject);
    procedure DisableCheckClick(Sender: TObject);
    procedure CountDownLimitClick(Sender: TObject; Button: TUDBtnType);
    procedure UseCaptionCheckClick(Sender: TObject);
    procedure CaptionBoxChange(Sender: TObject);
    procedure CountdownLimitBoxChange(Sender: TObject);
    procedure btnDupClick(Sender: TObject);
    procedure EveryYearCheckClick(Sender: TObject);
  private
    { Private 宣言 }
    FSelectedSeriesItem: TSeriesItem;
    procedure updateListBoxCaption;
    procedure updateLabel;
    function selectedItem: TCountdownItem;
  public
    { Public 宣言 }
  end;

var
  frmCountdown: TfrmCountdown;

implementation

uses
  DocumentManager;

const
  DEFAULT_LABEL = '（右のボタンから指定します）';
{$R *.dfm}

procedure TfrmCountdown.updateListBoxCaption;
begin
    CountdownList.Items[CountdownList.ItemIndex] := selectedItem.toStringForItemList;
end;

procedure TfrmCountdown.UseCaptionCheckClick(Sender: TObject);
begin
    selectedItem.UseCaption := UseCaptionCheck.Checked;
    updateListBoxCaption;
end;

function TfrmCountdown.selectedItem: TCountdownItem;
begin
    if CountdownList.ItemIndex > -1 then begin
        Result := TCountdownItem(CountdownList.Items.Objects[CountdownList.ItemIndex]);
    end else begin
        Result := nil;
    end;
end;

procedure TfrmCountdown.btnAddClick(Sender: TObject);
var
    item: TCountdownItem;
begin
    item := TCountdownItem.Create;
    TDocumentManager.getInstance.MainDocument.addCountdownItem(item);
    CountdownList.AddItem(item.toStringForItemList, item);
    CountdownList.ItemIndex := CountdownList.Count-1;
    CountdownListClick(Sender);
end;

procedure TfrmCountdown.btnDeleteClick(Sender: TObject);
var
    item: TCountdownItem;
    idx: integer;
begin
    idx := CountdownList.ItemIndex;
    item := selectedItem;
    if selectedItem <> nil then begin
        if MessageDlg('「' + item.toStringForItemList + '」を削除します．よろしいですか？', mtInformation, [mbYes, mbNo], 0) = mrYes then begin
            TDocumentManager.getInstance.MainDocument.freeCountdownItem(item);
            CountdownList.DeleteSelected;
            if CountdownList.Count > idx then
                CountdownList.ItemIndex := idx
            else
                CountdownList.ItemIndex := CountdownList.Count-1;
            CountdownListClick(Sender);
        end;
    end;
end;

procedure TfrmCountdown.btnDownClick(Sender: TObject);
var
  idx: integer;
begin
    if CountdownList.ItemIndex < CountdownList.Count-1 then begin
        idx := CountdownList.ItemIndex;
        CountdownList.Items.Exchange(idx+1, idx);
        TDocumentManager.getInstance.MainDocument.exchangeCountdownItem(idx+1, idx);
        CountdownList.ItemIndex := idx + 1;
    end;
end;

procedure TfrmCountdown.btnDupClick(Sender: TObject);
var
    item : TCountdownItem;
begin
    if selectedItem = nil then Exit;

    item := selectedItem.duplicate;
    TDocumentManager.getInstance.MainDocument.addCountdownItem(item);
    CountdownList.AddItem(item.toStringForItemList, item);
    CountdownList.ItemIndex := CountdownList.Count-1;
    CountdownListClick(Sender);
end;

procedure TfrmCountdown.btnOKClick(Sender: TObject);
begin
    Close;
end;

procedure TfrmCountdown.btnSelectSeriesitemClick(Sender: TObject);
begin
    if frmSeriesItemSelectDialog = nil then  Application.CreateForm(TfrmSeriesItemSelectDialog, frmSeriesItemSelectDialog);
    FSelectedSeriesItem := frmSeriesItemSelectDialog.Execute(TDocumentManager.getInstance.MainDocument.SeriesItems, false);
    if FSelectedSeriesItem <> nil then begin
        SelectedSeriesItemLabel.Caption := FSelectedSeriesItem.Name;
        radioSpecifiedSeriesItem.Checked := true;
        selectedItem.SeriesItem := FSelectedSeriesItem;
        updateListBoxCaption;
    end;
end;

procedure TfrmCountdown.btnUpClick(Sender: TObject);
var
  idx: integer;
begin
    if CountdownList.ItemIndex >= 1 then begin
        idx := CountdownList.ItemIndex;
        CountdownList.Items.Exchange(idx-1, idx);
        TDocumentManager.getInstance.MainDocument.exchangeCountdownItem(idx-1, idx);
        CountdownList.ItemIndex := idx - 1;
    end;
end;

procedure TfrmCountdown.CaptionBoxChange(Sender: TObject);
begin
    selectedItem.Caption := CaptionBox.Text;
    updateListBoxCaption;
end;

procedure TfrmCountdown.EveryYearCheckClick(Sender: TObject);
begin
    selectedItem.EveryYear := EveryYearCheck.Checked;
    updateListBoxCaption;
end;

procedure TfrmCountdown.CountdownLimitBoxChange(Sender: TObject);
begin
    if (selectedItem <> nil) then begin
        selectedItem.ActiveLimit := CountDownLimit.Position;
        updateListBoxCaption;
    end;
end;

procedure TfrmCountdown.CountDownLimitClick(Sender: TObject;
  Button: TUDBtnType);
begin
    selectedItem.ActiveLimit := CountDownLimit.Position;
    updateListBoxCaption;
end;

procedure TfrmCountdown.CountdownListClick(Sender: TObject);
var
    item: TCountdownItem;
begin
    item := selectedItem;

    if item <> nil then begin

        CounterGroup.Enabled := true;
        DisableCheck.Checked := item.Disabled;
        DateTimePicker1.Date := item.SpecifiedDate;
        CountDownLimit.Position := item.ActiveLimit;
        radioSpecifiedDate.Checked := not item.ReferSeries;
        radioSpecifiedSeriesitem.Checked := item.ReferSeries;
        CaptionBox.Text := item.Caption;
        UseCaptionCheck.Checked := item.UseCaption;
        EveryYearCheck.Checked := selectedItem.EveryYear;
        FSelectedSeriesItem := item.SeriesItem;
        updateLabel;

    end else begin
        CounterGroup.Enabled := false;
    end;
end;

procedure TfrmCountdown.DateTimePicker1Change(Sender: TObject);
begin
    radioSpecifiedDate.Checked := true;
    selectedItem.SpecifiedDate := DateTimePicker1.Date;
    updateListBoxCaption;
end;

procedure TfrmCountdown.DisableCheckClick(Sender: TObject);
begin
    selectedItem.Disabled := DisableCheck.Checked;
    updateListBoxCaption;
end;

procedure TfrmCountdown.FormCreate(Sender: TObject);
begin
    DateTimePickerEnhance.enhancePicker(DateTimePicker1);
    DateTimePicker1.Date := Date;
    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;
end;

procedure TfrmCountdown.updateLabel;
begin
    if (FSelectedSeriesItem = nil) or (TDocumentManager.getInstance.MainDocument.SeriesItems.IndexOf(FSelectedSeriesItem) = -1) then begin
        FSelectedSeriesItem := nil;
        SelectedSeriesItemLabel.Caption := DEFAULT_LABEL;
    end else begin
        SelectedSeriesItemLabel.Caption := FSelectedSeriesItem.Name;
    end;
end;

procedure TfrmCountdown.FormShow(Sender: TObject);
var
    i: integer;
    item: TCountdownItem;
begin
    updateLabel;
    CountdownList.Clear;
    for i:=0 to TDocumentManager.getInstance.MainDocument.getCountdownItemCount-1 do begin
        item := TDocumentManager.getInstance.MainDocument.getCountdownItem(i);
        CountdownList.AddItem(item.toStringForItemList, item);
    end;
    if CountdownList.Count > 0 then
        CountdownList.ItemIndex := 0
    else
        CountdownList.ItemIndex := -1;
    CountdownListClick(Sender);
end;

procedure TfrmCountdown.radioSpecifiedDateClick(Sender: TObject);
begin
    selectedItem.ReferSeries := radioSpecifiedSeriesitem.Checked;
    updateListBoxCaption;
end;

end.
