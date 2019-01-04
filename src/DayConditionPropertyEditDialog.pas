unit DayConditionPropertyEditDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms,
  Dialogs, StdCtrls, ComCtrls,
  DayConditionNode;

type
  TfrmDayConditionPropertyEditDialog = class(TForm)
    Label5: TLabel;
    MonthBox: TEdit;
    Label4: TLabel;
    RadioDayCondition: TRadioButton;
    DayBox: TEdit;
    Label9: TLabel;
    Label6: TLabel;
    WeekBox: TEdit;
    RadioWeekCondition: TRadioButton;
    WeekCountMethodBox: TComboBox;
    SaturdayCheck: TCheckBox;
    FridayCheck: TCheckBox;
    ThursdayCheck: TCheckBox;
    WednesdayCheck: TCheckBox;
    TuesdayCheck: TCheckBox;
    MondayCheck: TCheckBox;
    Label7: TLabel;
    SundayCheck: TCheckBox;
    HolidayHandlingForDay: TComboBox;
    Label10: TLabel;
    UserDefinedHolidayCheck: TCheckBox;
    RangeStart: TDateTimePicker;
    OKBtn: TButton;
    CanecelBtn: TButton;
    RangeEnd: TDateTimePicker;
    ConstrainedByRangeEnd: TCheckBox;
    ConstrainedByRangeStart: TCheckBox;
    Label3: TLabel;
    Label8: TLabel;
    HolidayHandlingForWeek: TComboBox;
    ConditionDisabled: TCheckBox;
    ExclusionCheck: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    RadioBiweekCondition: TRadioButton;
    BiweekBaseDate: TDateTimePicker;
    RadioOtherSeriesRef: TRadioButton;
    OtherSeriesRefListBox: TComboBox;
    Label11: TLabel;
    OtherSeriesRefDiffBox: TEdit;
    OtherSeriesRefDiffKindBox: TComboBox;
    OtherSeriesRefDiffUpDown: TUpDown;
    Label12: TLabel;
    HolidayHandlingForRefer: TComboBox;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    DayCountBox: TEdit;
    DayCountUpDown: TUpDown;
    Label17: TLabel;
    RadioDayCountCondition: TRadioButton;
    Label18: TLabel;
    DayCountBaseDate: TDateTimePicker;
    DayCountStyle: TComboBox;
    procedure RadioDayConditionClick(Sender: TObject);
    procedure RadioWeekConditionClick(Sender: TObject);
    procedure RadioBiweekConditionClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RadioOtherSeriesRefClick(Sender: TObject);
    procedure RadioDayCountConditionClick(Sender: TObject);
    procedure DayCountStyleChange(Sender: TObject);
  private
    { Private 宣言 }
    FCheckBox: array [1..7] of TCheckBox;
    FConditionButtons: array [0..3] of TButtonControl;

  public
    { Public 宣言 }
    procedure getConditionProperty(item: TDayConditionNode);
    procedure setConditionProperty(item: TDayConditionNode);
    procedure setSeriesItemList(list: TStrings);
  end;

var
  frmDayConditionPropertyEditDialog: TfrmDayConditionPropertyEditDialog;

implementation

uses DateUtils, CommCtrl, Math,
     DateTimePickerEnhance, SeriesItem;

{$R *.dfm}
const
    INDEX_RANGESTART = 0;
    INDEX_RANGEEND = 1;
    INDEX_DAYBOX  = 2;
    INDEX_WEEKBOX = 3;


procedure TfrmDayConditionPropertyEditDialog.setConditionProperty(item: TDayConditionNode);
// 「条件」選択にあわせて画面更新
var
    i: integer;

    procedure initComponents;
    var
        i: integer;
    begin
        ConditionDisabled.Checked := false;
        MonthBox.Text := '';
        DayBox.Text := '';
        WeekBox.Text := '';
        WeekCountMethodBox.ItemIndex := 0;
        RadioDayCondition.Checked := true;
        RadioDayConditionClick(self);
        for i:=1 to 7 do FCheckBox[i].Checked := false;
        ConstrainedByRangeStart.Checked := false;
        ConstrainedByRangeEnd.Checked := false;
        RangeStart.DateTime := DateOf(StartOfTheYear(Date));
        RangeEnd.DateTime := DateOf(EndOfTheYear(Date));
        BiweekBaseDate.DateTime := DateOf(Date);
        HolidayHandlingForWeek.ItemIndex := 0;
        HolidayHandlingForDay.ItemIndex := 0;
        UserDefinedHolidayCheck.Checked := false;
        ExclusionCheck.Checked := false;
        OtherSeriesRefListBox.ItemIndex := -1;
        OtherSeriesRefDiffUpDown.Position := 1;
        OtherSeriesRefDiffKindBox.ItemIndex := 0;
        DayCountBaseDate.DateTime := DateOf(Date);
        DayCountUpDown.Position := 2;
        DayCountSTyle.ItemIndex := 0;
    end;
begin
    if (item = nil) then begin
        OKBtn.Caption := '追加';
        initComponents;
    end else begin
        OKBtn.Caption := '更新';
        initComponents;
        ConditionDisabled.Checked := item.Disabled;

        MonthBox.Text := item.MonthExpr;

        if item.UseWeek = SERIES_WEEK then begin
            WeekCountMethodBox.ItemIndex := item.WeekMode;
            WeekBox.Text  := item.WeekExpr;
            RadioWeekCondition.Checked := true;
            RadioWeekConditionClick(self);
        end else if item.UseWeek = SERIES_DAY then begin
            DayBox.Text   := item.DayExpr;
            RadioDayCondition.Checked := true;
            RadioDayConditionClick(self);
        end else if item.UseWeek = SERIES_REFER then begin
            OtherSeriesRefListBox.ItemIndex := OtherSeriesRefListBox.Items.IndexOfObject(item.ReferItem);
            OtherSeriesRefDiffKindBox.ItemIndex := IfThen(item.ReferItemDelta > 0, 0, 1);
            OtherSeriesRefDiffUpDown.Position := IfThen(item.ReferItemDelta > 0, item.ReferItemDelta, -item.ReferItemDelta);
            RadioOtherSeriesRef.Checked := true;
            RadioOtherSeriesRefClick(self);
        end else if item.UseWeek = SERIES_DAYCOUNT then begin
            DayCountUpDown.Position := item.DayCount;
            DayCountBaseDate.Date := item.DayCountBaseDate;
            DayCountStyle.ItemIndex := item.DayCountStyle;
            RadioDayCountCondition.Checked := true;
            RadioDayCountConditionClick(self);
        end else begin
            BiweekBaseDate.DateTime := item.BiweekBaseDate;
            RadioBiweekCondition.Checked := true;
            RadioBiweekConditionClick(self);
        end;

        for i:=1 to 7 do FCheckBox[i].Checked := item.Youbi[i];

        RangeStart.DateTime := item.RangeStart;
        RangeEnd.DateTime := item.RangeEnd;
        ConstrainedByRangeStart.Checked := item.RangeStartEnabled;
        ConstrainedByRangeEnd.Checked   := item.RangeEndEnabled;
        UserDefinedHolidayCheck.Checked := item.UserDefinedHoliday;
        ExclusionCheck.Checked          := item.Exclusion;

        if item.UseWeek = SERIES_DAY then begin
            HolidayHandlingForWeek.ItemIndex := 0;
            HolidayHandlingForRefer.ItemIndex := 0;
            HolidayHandlingForDay.ItemIndex := item.HolidayHandling;
        end else if item.UseWeek = SERIES_REFER then begin
            HolidayHandlingForRefer.ItemIndex := item.HolidayHandling;
            HolidayHandlingForWeek.ItemIndex := 0;
            HolidayHandlingForDay.ItemIndex := 0;
        end else if item.UseWeek = SERIES_DAYCOUNT  then begin
            if item.DayCountStyle = DAYCOUNTSTYLE_COUNT_SPECIFIC_YOUBI then begin
                HolidayHandlingForWeek.ItemIndex := 0;
                HolidayHandlingForRefer.ItemIndex := item.HolidayHandling;
                HolidayHandlingForDay.ItemIndex := 0;
            end else begin
                HolidayHandlingForWeek.ItemIndex := 0;
                HolidayHandlingForRefer.ItemIndex := 0;
                HolidayHandlingForDay.ItemIndex := item.HolidayHandling;
            end;
        end else begin // WEEK, BIWEEK
            HolidayHandlingForWeek.ItemIndex := item.HolidayHandling;
            HolidayHandlingForDay.ItemIndex := 0;
            HolidayHandlingForRefer.ItemIndex := 0;
        end;

    end;
end;

procedure TfrmDayConditionPropertyEditDialog.getConditionProperty(item: TDayConditionNode);
var
    i: integer;

    function RadioToUseWeek: integer;
    begin
        Result := IfThen(RadioDayCondition.Checked, SERIES_DAY,
                  IfThen(RadioWeekCondition.Checked, SERIES_WEEK,
                  IfThen(RadioBiweekCondition.Checked, SERIES_BIWEEK,
                  IfThen(RadioDayCountCondition.Checked, SERIES_DAYCOUNT,
                  SERIES_REFER))));
    end;
begin
    item.Disabled := ConditionDisabled.Checked;

    item.MonthExpr := MonthBox.Text;
    item.DayExpr   := DayBox.Text;
    item.WeekMode  := WeekCountMethodBox.ItemIndex;
    item.WeekExpr  := WeekBox.Text;
    item.UseWeek   := RadioToUseWeek;
    item.BiweekBaseDate := BiweekBaseDate.Date;
    item.DayCount  := DayCountUpDown.Position;
    item.DayCountBaseDate := DayCountBaseDate.Date;
    item.DayCountStyle := DayCountStyle.ItemIndex;

    if OtherSeriesRefListBox.ItemIndex >= 0 then
        item.ReferItem := (OtherSeriesRefListBox.Items.Objects[OtherSeriesRefListBox.ItemIndex] as TSeriesItem)
    else
        item.ReferItem := nil;
    if OtherSeriesRefDiffKindBox.ItemIndex = 0 then
        item.ReferItemDelta := OtherSeriesRefDiffUpDown.Position
    else
        item.ReferItemDelta := - OtherSeriesRefDiffUpDown.Position;

    for i:=1 to 7 do item.Youbi[i] := FCheckBox[i].Checked;

    item.RangeStart := RangeStart.Date;
    item.RangeEnd   := RangeEnd.Date;
    item.RangeStartEnabled := ConstrainedByRangeStart.Checked;
    item.RangeEndEnabled   := ConstrainedByRangeEnd.Checked;
    item.UserDefinedHoliday := UserDefinedHolidayCheck.Checked;
    item.Exclusion := ExclusionCheck.Checked;

    if (item.UseWeek = SERIES_DAY) then
        item.HolidayHandling := HolidayHandlingForDay.ItemIndex
    else if item.UseWeek = SERIES_REFER then
        item.HolidayHandling := HolidayHandlingForRefer.ItemIndex
    else if (item.UseWeek = SERIES_WEEK) or (item.UseWeek = SERIES_BIWEEK) then
        item.HolidayHandling := HolidayHandlingForWeek.ItemIndex
    else if (item.UseWeek = SERIES_DAYCOUNT)  then begin
        if item.DayCountStyle = DAYCOUNTSTYLE_COUNT_SPECIFIC_YOUBI then
            item.HolidayHandling := HolidayHandlingForRefer.ItemIndex
        else
            item.HolidayHandling := HolidayHandlingForDay.ItemIndex;
    end else
        item.HolidayHandling := 0;
        

end;





procedure TfrmDayConditionPropertyEditDialog.RadioDayConditionClick(
  Sender: TObject);
begin
    HolidayHandlingForDay.Visible := true;
    HolidayHandlingForWeek.Visible := false;
    HolidayHandlingForRefer.Visible := false;
    DayCountBaseDate.Enabled := false;
    DayCountBox.Enabled := false;
    DayCountUpDown.Enabled := false;
    DayCountStyle.Enabled := false;
    WeekCountMethodBox.Enabled := false;
    BiweekBaseDate.Enabled := false;
    OtherSeriesRefListBox.Enabled := false;
    OtherSeriesRefDiffBox.Enabled := false;
    OtherSeriesRefDiffKindBox.Enabled := false;
end;

procedure TfrmDayConditionPropertyEditDialog.RadioDayCountConditionClick(
  Sender: TObject);
begin
    DayCountStyleChange(sender);
    HolidayHandlingForWeek.Visible := false;
    DayCountBaseDate.Enabled := true;
    DayCountBox.Enabled := true;
    DayCountUpDown.Enabled := true;
    DayCountStyle.Enabled := true;
    WeekCountMethodBox.Enabled := false;
    BiweekBaseDate.Enabled := false;
    OtherSeriesRefListBox.Enabled := false;
    OtherSeriesRefDiffBox.Enabled := false;
    OtherSeriesRefDiffKindBox.Enabled := false;
end;

procedure TfrmDayConditionPropertyEditDialog.RadioBiweekConditionClick(
  Sender: TObject);
begin
    HolidayHandlingForWeek.Visible := true;
    HolidayHandlingForDay.Visible := false;
    HolidayHandlingForRefer.Visible := false;
    DayCountBaseDate.Enabled := false;
    DayCountBox.Enabled := false;
    DayCountUpDown.Enabled := false;
    DayCountStyle.Enabled := false;
    WeekCountMethodBox.Enabled := false;
    BiweekBaseDate.Enabled := true;
    OtherSeriesRefListBox.Enabled := false;
    OtherSeriesRefDiffBox.Enabled := false;
    OtherSeriesRefDiffKindBox.Enabled := false;
end;

procedure TfrmDayConditionPropertyEditDialog.RadioWeekConditionClick(
  Sender: TObject);
begin
    HolidayHandlingForWeek.Visible := true;
    HolidayHandlingForDay.Visible := false;
    HolidayHandlingForRefer.Visible := false;
    DayCountBaseDate.Enabled := false;
    DayCountBox.Enabled := false;
    DayCountUpDown.Enabled := false;
    DayCountStyle.Enabled := false;
    WeekCountMethodBox.Enabled := true;
    BiweekBaseDate.Enabled := false;
    OtherSeriesRefListBox.Enabled := false;
    OtherSeriesRefDiffBox.Enabled := false;
    OtherSeriesRefDiffKindBox.Enabled := false;
end;

procedure TfrmDayConditionPropertyEditDialog.RadioOtherSeriesRefClick(
  Sender: TObject);
begin
    HolidayHandlingForWeek.Visible := false;
    HolidayHandlingForDay.Visible := false;
    HolidayHandlingForRefer.Visible := true;
    DayCountBaseDate.Enabled := false;
    DayCountBox.Enabled := false;
    DayCountUpDown.Enabled := false;
    DayCountStyle.Enabled := false;
    WeekCountMethodBox.Enabled := false;
    BiweekBaseDate.Enabled := false;
    OtherSeriesRefListBox.Enabled := true;
    OtherSeriesRefDiffBox.Enabled := true;
    OtherSeriesRefDiffKindBox.Enabled := true;
end;

procedure TfrmDayConditionPropertyEditDialog.DayCountStyleChange(
  Sender: TObject);
begin
    HolidayHandlingForDay.Visible := (DayCountStyle.ItemIndex = DAYCOUNTSTYLE_FILTER_YOUBI_AFTER_COUNT_ALL);
    HolidayHandlingForRefer.Visible := (DayCountStyle.ItemIndex = DAYCOUNTSTYLE_COUNT_SPECIFIC_YOUBI);
end;

procedure TfrmDayConditionPropertyEditDialog.FormCreate(Sender: TObject);
var
    i: integer;
begin

    for i:=0 to High(HOLIDAY_HANDLING_FOR_DAY) do
        HolidayHandlingForDay.Items.Add(HOLIDAY_HANDLING_FOR_DAY[i]);
    HolidayHandlingForDay.ItemIndex := 0;

    for i:=0 to High(HOLIDAY_HANDLING_FOR_WEEK) do
        HolidayHandlingForWeek.Items.Add(HOLIDAY_HANDLING_FOR_WEEK[i]);
    HolidayHandlingForWeek.ItemIndex := 0;

    for i:=0 to High(HOLIDAY_HANDLING_FOR_REFER) do
        HolidayHandlingForREFER.Items.Add(HOLIDAY_HANDLING_FOR_REFER[i]);
    HolidayHandlingForREFER.ItemIndex := 0;

///   for i:=0 to High(HOLIDAY_HANDLING_FOR_DAYCOUNT) do
///        HolidayHandlingForDayCount.Items.Add(HOLIDAY_HANDLING_FOR_DAYCOUNT[i]);
///    HolidayHandlingForDayCount.ItemIndex := 0;

    OtherSeriesRefDiffKindBox.ItemIndex := 0;

    FConditionButtons[INDEX_RANGESTART] := ConstrainedByRangeStart;
    FConditionButtons[INDEX_RANGEEND] := ConstrainedByRangeEnd;
    FConditionButtons[INDEX_WEEKBOX]  := RadioWeekCondition;
    FConditionButtons[INDEX_DAYBOX]  := RadioDayCondition;
    RangeStart.Tag := INDEX_RANGESTART;
    RangeEnd.Tag := INDEX_RANGEEND;
    WeekBox.Tag := INDEX_WEEKBOX;
    DayBox.Tag := INDEX_DAYBOX;

    FCheckBox[1] := SundayCheck;
    FCheckBox[2] := MondayCheck;
    FCheckBox[3] := TuesdayCheck;
    FCheckBox[4] := WednesdayCheck;
    FCheckBox[5] := ThursdayCheck;
    FCheckBox[6] := FridayCheck;
    FCheckBox[7] := SaturdayCheck;

    enhancePicker(RangeStart);
    enhancePicker(RangeEnd);
    enhancePicker(BiweekBaseDate);
    enhancePicker(DayCountBaseDate);

    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;

end;

procedure TfrmDayConditionPropertyEditDialog.setSeriesItemList(list: TStrings);
begin
    OtherSeriesRefListBox.Clear;
    OtherSeriesRefListBox.Items.AddStrings(list);
    OtherSeriesRefListBox.ItemIndex := -1;
end;

procedure TfrmDayConditionPropertyEditDialog.FormShow(Sender: TObject);
begin
    MonthBox.SetFocus;
end;


end.
