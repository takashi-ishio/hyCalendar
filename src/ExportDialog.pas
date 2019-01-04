unit ExportDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, DateUtils, Clipbrd, ExtCtrls, DocumentManager;

type
  TfrmExportDialog = class(TForm)
    btnSaveToFile: TButton;
    btnCopyToClipboard: TButton;
    btnClose: TButton;
    SaveDialog1: TSaveDialog;
    ExportStyle: TRadioGroup;
    ExportOptionGroupBox: TGroupBox;
    ExportWithRangeSeriesTodo: TCheckBox;
    ExportWithReferences: TCheckBox;
    ExportEmptyItem: TCheckBox;
    ExportRangeGroupBox: TGroupBox;
    StartDatePicker: TDateTimePicker;
    EndDatePicker: TDateTimePicker;
    Label1: TLabel;
    Label2: TLabel;
    Label9: TLabel;
    Label11: TLabel;
    DaysInputBox: TEdit;
    DiffDaysInputBox: TEdit;
    UpDown2: TUpDown;
    DaysCountUpDown: TUpDown;
    Label3: TLabel;
    Label10: TLabel;
    ResultLabel: TLabel;
    ExportCSVWithDateHead: TCheckBox;
    DayStyleGroupBox: TGroupBox;
    OutputDateFormat: TComboBox;
    ExportWithDayName: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure DiffDaysInputBoxChange(Sender: TObject);
    procedure DaysInputBoxChange(Sender: TObject);
    procedure StartDatePickerChange(Sender: TObject);
    procedure btnSaveToFileClick(Sender: TObject);
    procedure btnCopyToClipboardClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private 宣言 }
    FIgnoreDaysTextChangeFlag : boolean;
    FText: TStringList;
    procedure updateAllDateBox;
    function makeText: integer;
  public
    { Public 宣言 }
  end;

var
  frmExportDialog: TfrmExportDialog;

implementation

uses
    DateTimePickerEnhance, StrUtils;

{$R *.dfm}

procedure TfrmExportDialog.FormCreate(Sender: TObject);
begin
    SaveDialog1.InitialDir := GetCurrentDir;
    StartDatePicker.Date := Date;
    EndDatePicker.Date := Date;
    enhancePicker(StartDatePicker);
    enhancePicker(EndDatePicker);
    FText := TStringList.Create;
    OutputDateFormat.Perform(CB_SETDROPPEDWIDTH, OutputDateFormat.Width * 2, 0);
    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;
end;

procedure TfrmExportDialog.DiffDaysInputBoxChange(Sender: TObject);
var
    dayCount: integer;
begin
    if FIgnoreDaysTextChangeFlag then exit;
    If TryStrToInt(DiffDaysInputBox.Text, dayCount) then begin
        EndDatePicker.Date := IncDay(StartDatePicker.Date, dayCount);
        updateAllDateBox;
    end;
end;

procedure TfrmExportDialog.DaysInputBoxChange(Sender: TObject);
var
    dayCount : integer;
begin
    if FIgnoreDaysTextChangeFlag then exit;
    If TryStrToInt(DaysInputBox.Text, dayCount) then begin
        if dayCount > 0 then begin
            EndDatePicker.Date := IncDay(StartDatePicker.Date, dayCount-1);
        end else if dayCount < 0 then begin
            EndDatePicker.Date := IncDay(StartDatePicker.Date, dayCount);
        end;
        updateAllDateBox;
    end;
end;

procedure TfrmExportDialog.StartDatePickerChange(Sender: TObject);
begin
    updateAllDateBox;
end;

procedure TfrmExportDialog.updateAllDateBox;
begin
    FIgnoreDaysTextChangeFlag := true;
    if StartDatePicker.Date <= EndDatePicker.Date then begin
        DaysInputBox.Text := IntToStr(DaysBetween(StartDatePicker.Date, EndDatePicker.Date)+1);
        DiffDaysInputBox.Text := IntToStr(DaysBetween(StartDatePicker.Date, EndDatePicker.Date));
    end else begin
        DaysInputBox.Text := IntToStr(DaysBetween(StartDatePicker.Date, EndDatePicker.Date)+1);
        DiffDaysInputBox.Text := IntToStr(-DaysBetween(StartDatePicker.Date, EndDatePicker.Date));
    end;
    FIgnoreDaysTextChangeFlag := false;
end;

function TfrmExportDialog.makeText: integer;
var
    setting: TExportSettings;
    dateOutputFormat: string;
    i: integer;

    function indexToExportStyle: TExportStyle;
    begin
        if ExportStyle.ItemIndex = 0 then
            Result := expsText
        else if ExportStyle.ItemIndex = 1 then
            Result := expsCSV
        else if ExportStyle.ItemIndex = 2 then
            Result := expsTab
        else
            Result := expsText;
    end;

begin
    setting := [];
    if ExportWithDayName.Checked then setting := setting + [expYoubi];
    if ExportEmptyItem.Checked then setting := setting + [expEmptyItem];
    if ExportWithReferences.Checked then setting := setting + [expReferences];
    if ExportWithRangeSeriesTodo.Checked then setting := setting + [expRangeSeriesTodo];
    if ExportCSVWithDateHead.Checked then setting := setting + [expCSVWithDateHead];

    dateOutputFormat := OutputDateFormat.Text;
    i := AnsiPos('(', dateOutputFormat);
    if i>0 then begin
        // ここで "(" 以降を取り除いて，Trim してから makeExportText に渡す
        dateOutputFormat := Trim(Copy(dateOutputFormat, 1, i-1));

    end;

    // オプション設定から， export 設定変数を構築
    Result := TDocumentManager.getInstance.makeExportText(StartDatePicker.Date, EndDatePicker.Date, dateOutputFormat, indexToExportStyle, setting, FText);
end;

procedure TfrmExportDialog.btnSaveToFileClick(Sender: TObject);
var
    count: integer;
begin
    if SaveDialog1.Execute then begin
        count := makeText;
        FText.SaveToFile(SaveDialog1.FileName);
        FText.Clear;
        ResultLabel.Caption := 'ファイルへ' + intToStr(count) + '日分のデータを出力しました．';
    end;
end;

procedure TfrmExportDialog.btnCopyToClipboardClick(Sender: TObject);
var
    count: integer;
begin
    count := makeText;
    ResultLabel.Caption := 'クリップボードへ' + intToStr(count) + '日分のデータを出力しました．';
    Clipboard.AsText := FText.Text;
    FText.Clear;

end;

procedure TfrmExportDialog.FormDestroy(Sender: TObject);
begin
    FText.Free;
end;

procedure TfrmExportDialog.btnCloseClick(Sender: TObject);
begin
    Close;
end;

end.
