unit ScheduleItemTest;

interface

uses
    StrUtils, DateUtils, SysUtils,
    TestFrameWork, ScheduleItem, RangeList;

type
    TDayScheduleTest = class(TTestCase)
    private
        item: TScheduleItem;
        range: TRangeList;
    protected
        procedure SetUp; override;
        procedure TearDown; override;

    published
        procedure TestMatch;

    end;

implementation

procedure TDayScheduleTest.SetUp;
begin
  item := TScheduleItemFactory.CreateDaySchedule(StrToDate('2001/1/1'));
  item.Name := 'ƒeƒXƒg—\’è';
  range := TRangeList.Create;
end;

procedure TDayScheduleTest.TearDown;
begin
  item.Free;
  range.Free;
end;

procedure TDayScheduleTest.TestMatch;
var
  ymd1, ymd2: TDateTime;
begin
  item.match(StrToDate('2000/1/1'), StrToDate('2000/12/31'), range);
  CheckEquals(0, range.Count);
  range.Clear;

  item.match(StrToDate('2000/1/1'), StrToDate('2002/12/31'), range);
  CheckEquals(1, range.Count);
  range.Get(0, ymd1, ymd2);
  CheckEquals(StrToDate('2001/1/1'), ymd1);
  CheckEquals(StrToDate('2001/1/1'), ymd2);
  range.Clear;

  item.match(StrToDate('2002/1/1'), StrToDate('2000/12/31'), range);
  CheckEquals(0, range.Count);
  range.Clear;

  item.match(StrToDate('2001/1/1'), StrToDate('2001/1/1'), range);
  CheckEquals(1, range.Count);
  range.Get(0, ymd1, ymd2);
  CheckEquals(StrToDate('2001/1/1'), ymd1);
  CheckEquals(StrToDate('2001/1/1'), ymd2);
  range.Clear;
end;

initialization
  TestFramework.RegisterTest(TDayScheduleTest.Suite);

end.
