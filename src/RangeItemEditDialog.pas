unit RangeItemEditDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, DateUtils, RangeItem, CommCtrl, DocumentManager;

type

  TRangeItemEditResult = (rrEdit, rrCancel, rrDelete);


  TfrmRangeItemEditDialog = class(TForm)
    StartDatePicker: TDateTimePicker;
    Label1: TLabel;
    Label2: TLabel;
    EndDatePicker: TDateTimePicker;
    OKBtn: TButton;
    TextInputBox: TEdit;
    Label4: TLabel;
    LineColorBox: TColorBox;
    Label5: TLabel;
    CancelBtn: TButton;
    DeleteBtn: TButton;
    DaysInputBox: TEdit;
    Label3: TLabel;
    Label6: TLabel;
    TextColorBox: TColorBox;
    IsDayTextColorCheck: TCheckBox;
    Label7: TLabel;
    PenWidthEdit: TEdit;
    UpDown1: TUpDown;
    Label8: TLabel;
    PenStyleBox: TComboBox;
    DaysCountUpDown: TUpDown;
    DiffDaysInputBox: TEdit;
    UpDown2: TUpDown;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    DupBtn: TButton;
    Label12: TLabel;
    SkipSaturdayCheck: TCheckBox;
    SkipSundayCheck: TCheckBox;
    SkipHolidayCheck: TCheckBox;
    ArrowTypeBox: TComboBox;
    Label13: TLabel;
    procedure StartDatePickerChange(Sender: TObject);
    procedure DaysInputBoxChange(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure TextInputBoxChange(Sender: TObject);
    procedure IsDayTextColorCheckClick(Sender: TObject);
    procedure PenWidthEditChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DiffDaysInputBoxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DupBtnClick(Sender: TObject);
  private
    { Private 宣言 }
    FIgnoreDaysTextChangeFlag : boolean;
    FSelectedButton : TRangeItemEditResult;
    FEditingDay: TDate;
    FEditingItem: TRangeItem;

    procedure updateAllDateBox;


    function getItemText: string;
    function getStartDate: TDate;
    function getEndDate: TDate;
    function getItemColor : TColor;
    function getTextColor : TColor;
    function getIsDayTextColor: boolean;
    function getPenWidth: integer;
    function getPenStyle: integer;
    function getSkipDays: integer;
    function getArrowType: integer;
    procedure setItemText(text: string);
    procedure setStartDate(day: TDate);
    procedure setEndDate(day: TDate);
    procedure setItemColor(color: TColor);
    procedure setTextColor(color: TColor);
    procedure setIsDayTextColor(b: boolean);
    procedure setPenWidth(w: integer);
    procedure setPenStyle(s: integer);
    procedure setSkipDays(saturday, sunday, holiday: boolean);
    procedure setArrowType(arrowType: integer);
  public
    { Public 宣言 }
    function ExecuteAddItem(day: TDate): TRangeItemEditResult;
    function ExecuteEditItem(d: TDateTime; index: integer): TRangeItemEditResult;

    property ItemText: string read getItemText write setItemText;
    property StartDate: TDate read getStartDate write setStartDate;
    property EndDate: TDate read getEndDate write setEndDate;
    property ItemColor: TColor read getItemColor write setItemColor;
    property TextColor: TColor read getTextColor write setTextColor;
    property isDayTextColor: boolean read getIsDayTextColor write setIsDayTextColor;
    property PenWidth: integer read getPenWidth write setPenWidth;
    property PenStyle: integer read getPenStyle write setPenStyle;
    property ArrowType: integer read getArrowType write setArrowType;
    property SkipDays: integer read getSkipDays;
  end;

var
  frmRangeItemEditDialog: TfrmRangeItemEditDialog;

implementation

uses
    Math, DateValidation, CalendarDocument, DateTimePickerEnhance;

const
    CAPTION_ADD = '期間予定の追加';
    CAPTION_EDIT = '期間予定の編集';
    CAPTION_DUP  = '複製された期間予定の追加';

{$R *.dfm}

procedure TfrmRangeItemEditDialog.setSkipDays(saturday, sunday, holiday: boolean);
begin
    SkipSaturdayCheck.Checked := saturday;
    SkipSundayCheck.Checked := sunday;
    SkipHolidayCheck.Checked := holiday;
end;

function TfrmRangeItemEditDialog.getArrowType: integer;
begin
  Result := ArrowTypeBox.ItemIndex;
end;

procedure TfrmRangeItemEditDialog.setArrowType(arrowType: integer);
begin
    if (arrowType >=0) and (arrowType < ArrowTypeBox.Items.Count) then
        ArrowTypeBox.ItemIndex := arrowType
    else
        ArrowTypeBox.ItemIndex := 0;
end;

function TfrmRangeItemEditDialog.getSkipDays: integer;
begin
    Result := IfThen(SkipSaturdayCheck.Checked, SKIP_SATURDAY, 0) +
              IfThen(SkipSundayCheck.Checked, SKIP_SUNDAY, 0) +
              IfThen(SkipHolidayCheck.Checked, SKIP_HOLIDAY, 0);
end;

function TfrmRangeItemEditDialog.ExecuteAddItem(day: TDate): TRangeItemEditResult;
var
    doc : TCalendarDocument;
begin
    FEditingItem := nil;
    FEditingDay  := day;
    Caption := CAPTION_ADD;
    FSelectedButton := rrCancel;

    ShowModal;

    Result := FSelectedButton;

    if FSelectedButton = rrEdit then begin
        doc := TDocumentManager.getInstance.MainDocument;

        if not isValid(StartDate) then exit;
        if not isValid(EndDate) then exit;

        TDocumentManager.getInstance.createRangeItem(StartDate, EndDate,
                            ItemText, ItemColor, TextColor, isDayTextColor,
                            PenWidth, PenStyle, ArrowType, SkipDays);
        doc.Dirty := true;
    end;

end;


function TfrmRangeItemEditDialog.ExecuteEditItem(d: TDateTime; index: integer): TRangeItemEditResult;
var
    doc  : TCalendarDocument;
begin
    doc := TDocumentManager.getInstance.MainDocument;
    FSelectedButton := rrCancel;


    // 編集するオブジェクトの値をセット
    FEditingItem := TDocumentManager.getInstance.getRangeItems(d).Items[index];  //doc.getItem(d).RangeItems[index];
    Assert(TDocumentManager.getInstance.IsMainDocument(FEditingItem.Owner), '別ファイルのデータを編集しようとしました．');
    Caption := CAPTION_EDIT;

    ShowModal;

    Result := FSelectedButton;

    if FSelectedButton = rrEdit then begin
        if not isValid(StartDate) then exit;
        if not isValid(EndDate) then exit;

        // if Duplicated
        if FEditingItem = nil then begin // if Duplicated
            TDocumentManager.getInstance.createRangeItem(
            //doc.createRangeItem(
                StartDate, EndDate,
                ItemText, ItemColor, TextColor, isDayTextColor,
                PenWidth, PenStyle, ArrowType, SkipDays);
        end else begin

            // 値を更新
            TDocumentManager.getInstance.updateRangeItem(FEditingItem,
                StartDate, EndDate, ItemText, itemColor, TExtColor, isDayTextColor, PenWidth, PenStyle, ArrowType, SkipDays);
            {FEditingItem.Text := ItemText;
            FEditingItem.StartDate := StartDate;
            FEditingItem.EndDate := EndDate;
            FEditingItem.Color := ItemColor;
            FEditingItem.TextColor := TextColor;
            FEditingItem.IsDayTextColor := isDayTextColor;
            FEditingItem.PenWidth := PenWidth;
            FEditingItem.PenStyle := PenStyle;}

        end;

        doc.Dirty := true;

    end else if FSelectedButton = rrDelete then begin
      TDocumentManager.getInstance.freeRangeItem(FEditingItem);
        //doc.freeRangeItem(FEditingItem);
    end;


end;


procedure TfrmRangeItemEditDialog.updateAllDateBox;
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

procedure TfrmRangeItemEditDialog.StartDatePickerChange(Sender: TObject);
begin
    updateAllDateBox;
end;

procedure TfrmRangeItemEditDialog.DaysInputBoxChange(Sender: TObject);
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

procedure TfrmRangeItemEditDialog.OKBtnClick(Sender: TObject);
begin
    if isValid(StartDatePicker.Date)and
       isValid(EndDatePicker.Date)and
       (DaysBetween(StartDatePicker.Date, EndDatePicker.Date) <= DaysCountUpDown.Max ) then begin
        FSelectedButton := rrEdit;
        Close;
    end else begin
        MessageDlg('このソフトウェアで扱える範囲外の日付が指定されています．', mtInformation, [mbOK], 0);
    end;
end;

procedure TfrmRangeItemEditDialog.CancelBtnClick(Sender: TObject);
begin
    FSelectedButton := rrCancel;
    Close;
end;

procedure TfrmRangeItemEditDialog.DeleteBtnClick(Sender: TObject);
begin
    if MessageDlg('この予定を削除します．よろしいですか？', mtWarning, mbOKCancel, 0) = mrOk then begin
        FSelectedButton := rrDelete;
        Close;
    end;
end;

function TfrmRangeItemEditDialog.getItemText: string;
begin
    Result := TextInputBox.Text;
end;

function TfrmRangeItemEditDialog.getStartDate: TDate;
begin
    if StartDatePicker.Date < EndDatePicker.Date then
        Result := StartDatePicker.Date
    else Result := EndDatePicker.Date;
end;

function TfrmRangeItemEditDialog.getEndDate: TDate;
begin
    if StartDatePicker.Date < EndDatePicker.Date then
        Result := EndDatePicker.Date
    else Result := StartDatePicker.Date;
end;

function TfrmRangeItemEditDialog.getItemColor : TColor;
begin
    Result := LineColorBox.Selected;
end;

procedure TfrmRangeItemEditDialog.setItemText(text: string);
begin
    TextInputBox.Text := text;
end;

procedure TfrmRangeItemEditDialog.setStartDate(day: TDate);
begin
    StartDatePicker.Date := day;
end;

procedure TfrmRangeItemEditDialog.setEndDate(day: TDate);
begin
    EndDatePicker.Date := day;
end;

procedure TfrmRangeItemEditDialog.setItemColor(color: TColor);
begin
    LineColorBox.Selected := color;
end;

procedure TfrmRangeItemEditDialog.TextInputBoxChange(Sender: TObject);
begin
    OKBtn.Enabled := not (TextInputBox.Text = '');
end;

procedure TfrmRangeItemEditDialog.IsDayTextColorCheckClick(Sender: TObject);
begin
    TextColorBox.Enabled := not IsDayTextColorCheck.Checked;
end;

function TfrmRangeItemEditDialog.getIsDayTextColor: boolean;
begin
    Result := IsDayTextColorCheck.Checked;
end;

function TfrmRangeItemEditDialog.getTextColor : TColor;
begin
    Result := TextColorBox.Selected;
end;

procedure TfrmRangeItemEditDialog.setTextColor(color: TColor);
begin
    TextColorBox.Selected := color;
end;

procedure TfrmRangeItemEditDialog.setIsDayTextColor(b: boolean);
begin
    isDayTextColorCheck.Checked := b;
end;

function TfrmRangeItemEditDialog.getPenWidth: integer;
begin
    Result := StrToInt(PenWidthEdit.Text);
end;

procedure TfrmRangeItemEditDialog.setPenWidth(w: integer);
begin
    Updown1.Position := w;
    PenWidthEdit.Text := IntToStr(w);
end;


function TfrmRangeItemEditDialog.getPenStyle: integer;
begin
    Result := PenStyleBox.ItemIndex;
end;

procedure TfrmRangeItemEditDialog.setPenStyle(s: integer);
begin
    PenStyleBox.ItemIndex := s;
end;

procedure TfrmRangeItemEditDialog.PenWidthEditChange(Sender: TObject);
var
    i: integer;
begin
    try
        i := StrToInt(PenWidthEdit.Text);
        if (i<=0) then begin
            PenWidthEdit.Text := '1';
        end else if (i>5) then begin
            PenWidthEdit.Text := '5';
        end;
    except
        PenWidthEdit.Text := '1';
    end;
end;

procedure TfrmRangeItemEditDialog.FormShow(Sender: TObject);
begin
    StartDatePicker.SetFocus;

    if FEditingItem = nil then begin
        OKBtn.Enabled := false;
        DeleteBtn.Visible := false;
        DupBtn.Visible := false;

        TextInputBox.Text := '';
        StartDatePicker.Date := FEditingDay;
        EndDatePicker.Date := FEditingDay;
        DaysInputBox.Text := '1';
        TextColorBox.Selected := clBlack;
        LineColorBox.Selected := clBlack;
        isDayTextColor := true;
        PenStyleBox.ItemIndex := 0;
        PenWidthEdit.Text := '1';
        ArrowTypeBox.ItemIndex := 0;
        setSkipDays(false, false, false);

    end else begin
        DeleteBtn.Visible := true;
        DupBtn.Visible := true;

        ItemText  := FEditingItem.Text;
        StartDate := FEditingItem.StartDate;
        EndDate   := FEditingItem.EndDate;
        ItemColor := FEditingItem.Color;
        TextColor := FEditingItem.TextColor;
        isDayTextColor := FEditingItem.IsDayTextColor;
        PenWidth := FEditingItem.PenWidth;
        PenStyle := FEditingItem.PenStyle;
        ArrowType := FEditingItem.ArrowType;
        setSkipDays(FEditingItem.SkipYoubi[7], FEditingItem.SkipYoubi[1], FEditingItem.SkipHoliday);

        DaysInputBox.Text := IntToStr(DaysBetween(StartDatePicker.Date, EndDatePicker.Date)+1);
    end;
end;

procedure TfrmRangeItemEditDialog.DiffDaysInputBoxChange(Sender: TObject);
var
    dayCount: integer;
begin
    if FIgnoreDaysTextChangeFlag then exit;
    If TryStrToInt(DiffDaysInputBox.Text, dayCount) then begin
        EndDatePicker.Date := IncDay(StartDatePicker.Date, dayCount);
        updateAllDateBox;
    end;
end;

procedure TfrmRangeItemEditDialog.FormCreate(Sender: TObject);
begin
    enhancePicker(StartDatePicker);
    enhancePicker(EndDatePicker);
    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;
end;

procedure TfrmRangeItemEditDialog.DupBtnClick(Sender: TObject);
begin
    DeleteBtn.Visible := false;
    DupBtn.Visible := false;
    FEditingItem := nil;
    Caption := CAPTION_DUP;
end;

end.
