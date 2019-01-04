unit SeriesPublicHolidayTest;

interface

uses
  Classes, SysUtils, TestFramework,
  SeriesPublicHoliday;

type
  TPublicHolidaysTest = class(TTestCase)

  private
    FHolidays: TPublicHolidays;

  protected
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure TestError;
    procedure TestMatch;
  end;

implementation

procedure TPublicHolidaysTest.SetUp;
begin
  FHolidays := TPublicHolidays.Create;
end;

procedure TPublicHolidaysTest.TearDown;
begin
  FHolidays.Free;
end;

procedure TPublicHolidaysTest.TestMatch;
var
  s: string;
  b: boolean;
begin
  b := FHolidays.match(StrToDate('2001/1/1'), nil, 0, s);
  CheckTrue(b);
  CheckEquals('Œ³“ú', s);

  b := FHolidays.match(StrToDate('2001/11/23'), nil, 0, s);
  CheckTrue(b);
  CheckEquals('‹Î˜JŠ´ŽÓ‚Ì“ú', s);

  b := FHolidays.match(StrToDate('2001/1/4'), nil, 0, s);
  CheckFalse(b);

end;

procedure TPublicHolidaysTest.TestError;
var
  holidays: TPublicHolidays;
begin
  holidays := TPublicHolidays.Create('holidays-error-test.txt');
  CheckTrue(holidays.hasError);
  CheckEquals('2000/1/1x'#9'Œ³“ú', holidays.ErrorLines[0]);
  holidays.Free;
end;


initialization
 TestFramework.RegisterTest(TPublicHolidaysTest.Suite);

 end.
