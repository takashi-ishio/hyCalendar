unit DateFormatTest;

interface

uses
  DateUtils, SysUtils, DateFormat, TestFramework;


type
  TDateFormatTest = class(TTestCase)

  protected
    procedure SetUp; override;

  published
    procedure TestTryParseDate;
    procedure TestTryParseDateDef;
    procedure TestUnparseDate;

  end;


implementation


procedure TDateFormatTest.SetUp;
begin
  inherited;
  DateSeparator := '/';
end;


procedure TDateFormatTest.TestTryParseDate;
var
  d: TDateTime;
begin
  CheckFalse(TryParseDate('xxxx/xx/xx', d));
  CheckFalse(TryParseDate('19100/1/1', d));
  CheckFalse(TryParseDate('1999/13/1', d));
  CheckFalse(TryParseDate('1999/2/30', d));
  CheckTrue(TryParseDate('1999/05/01', d));
  CheckEquals(1999, YearOf(d));
  CheckEquals(5, MonthOf(d));
  CheckEquals(1, DayOf(d));
  CheckTrue(TryParseDate('05/05/01', d));
  CheckEquals(2005, YearOf(d));
  CheckEquals(5, MonthOf(d));
  CheckEquals(1, DayOf(d));
  CheckTrue(TryParseDate('2000/02/29', d));
  CheckEquals(2000, YearOf(d));
  CheckEquals(2, MonthOf(d));
  CheckEquals(29, DayOf(d));
end;

procedure TDateFormatTest.TestTryParseDateDef;
var
  d: TDateTime;
  default: TDateTime;
begin
  default := StrToDate('2000/1/1');
  CheckEquals(default, ParseDateDef('xxxx/xx/xx', default));
  CheckEquals(default, ParseDateDef('19100/1/1', default));
  CheckEquals(default, ParseDateDef('1999/13/1', default));
  CheckEquals(default, ParseDateDef('1999/2/30', default));
  CheckEquals(StrToDate('199/1/1'), ParseDateDef('199/1/1', default));
  d := ParseDateDef('1999/05/01', default);
  CheckEquals(1999, YearOf(d));
  CheckEquals(5, MonthOf(d));
  CheckEquals(1, DayOf(d));
  d := ParseDateDef('05/05/01', default);
  CheckEquals(2005, YearOf(d));
  CheckEquals(5, MonthOf(d));
  CheckEquals(1, DayOf(d));
  d := ParseDateDef('2000/02/29', default);
  CheckEquals(2000, YearOf(d));
  CheckEquals(2, MonthOf(d));
  CheckEquals(29, DayOf(d));
end;

procedure TDateFormatTest.TestUnparseDate;
begin
  CheckEquals('2000/01/01', unparseDate(EncodeDate(2000, 1, 1)));
  CheckEquals('1999/01/01', unparseDate(EncodeDate(1999, 1, 1)));
  CheckEquals('2010/01/01', unparseDate(EncodeDate(2010, 1, 1)));
end;

initialization
 TestFramework.RegisterTest(TDateFormatTest.Suite);

end.
