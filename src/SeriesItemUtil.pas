unit SeriesItemUtil;

interface

uses
  DateUtils, SysUtils,
  SeriesItem, DayConditionNode;


    procedure AddExcludedDay(series: TSeriesItem; day: TDateTime);
    procedure AddIncludedYoubi(series: TSeriesItem; day: TDateTime; youbi: Word);
    procedure AddIncludedDay(series: TSeriesItem; day: TDateTime);

implementation

procedure AddExcludedDay(series: TSeriesItem; day: TDateTime);
var
    item: TDayConditionNode;
begin
    item := TDayConditionNode.Create;
    item.RangeStartEnabled := true;
    item.RangeEndEnabled := true;
    item.RangeStart := DateOf(StartOfTheYear(day));
    item.RangeEnd   := DateOf(EndOfTheYear(day));
    item.MonthExpr := IntToStr(MonthOf(day));
    item.DayExpr   := IntToStr(DayOf(day));
    item.Exclusion := true;
    series.addCondition(item);
end;

procedure AddIncludedYoubi(series: TSeriesItem; day: TDateTime; youbi: Word);
var
    item: TDayConditionNode;
begin
    item := TDayConditionNode.Create;
    item.RangeStartEnabled := true;
    item.RangeEndEnabled := true;
    item.RangeStart := DateOf(StartOfTheYear(day));
    item.RangeEnd   := DateOf(EndOfTheYear(day));
    item.Youbi[youbi] := true;
    series.addCondition(item);
end;

procedure addIncludedDay(series: TSeriesItem; day: TDateTime);
var
    item: TDayConditionNode;
begin
    item := TDayConditionNode.Create;
    item.RangeStartEnabled := true;
    item.RangeEndEnabled := true;
    item.RangeStart := DateOf(StartOfTheYear(day));
    item.RangeEnd   := DateOf(EndOfTheYear(day));
    item.MonthExpr := IntToStr(MonthOf(day));
    item.DayExpr   := IntToStr(DayOf(day));
    item.Exclusion := false;
    series.addCondition(item);
end;


end.
