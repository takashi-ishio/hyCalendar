unit RangeListTest;

interface

uses
    StrUtils, DateUtils, SysUtils,
    TestFrameWork, RangeList ;

type

    TRangeListTest = class(TTestCase)
    private
        list: TRangeList;

    protected
        procedure SetUp; override;
        procedure TearDown; override;

    published
        procedure TestAdd;
        procedure TestClear;
        procedure TestGet;
    end;


implementation


procedure TRangeListTest.SetUp;
begin
  list := TRangeList.Create;
end;

procedure TRangeListTest.TearDown;
begin
    if Assigned(list) then list.Free;
end;

procedure TRangeListTest.TestAdd;
begin
  CheckEquals(0, list.Count);
  list.Add(StrToDate('2001/1/1'), StrToDate('2001/1/2'));
  CheckEquals(1, list.Count);
  list.Add(StrToDate('2001/1/5'), StrToDate('2001/1/7'));
  CheckEquals(2, list.Count);
  list.Add(StrToDate('2001/1/10'), StrToDate('2001/1/12'));
  CheckEquals(3, list.Count);
  list.Add(StrToDate('2001/1/1'), StrToDate('2001/1/2')); // èdï°ÇãñÇ∑
  CheckEquals(4, list.Count);
  list.Add(StrToDate('2001/1/12'), StrToDate('2001/1/10'));
  CheckEquals(5, list.Count);
end;

procedure TRangeListTest.TestGet;
var
  ymd1, ymd2: TDateTime;
begin
  CheckEquals(0, list.Count);
  list.Add(StrToDate('2001/1/1'), StrToDate('2001/1/2'));
  CheckEquals(1, list.Count);
  CheckFalse(list.Get(-1, ymd1, ymd2));
  CheckFalse(list.Get(1, ymd1, ymd2));
  CheckTrue(list.Get(0, ymd1, ymd2));
  CheckEquals(StrToDate('2001/1/1'), ymd1);
  CheckEquals(StrToDate('2001/1/2'), ymd2);

  list.Add(StrToDate('2001/1/5'), StrToDate('2001/1/7'));
  list.Add(StrToDate('2001/1/12'), StrToDate('2001/1/10')); // ãtÇæÇ∆é©ìÆÇ≈from, to ì¸ÇÍë÷Ç¶

  CheckTrue(list.Get(0, ymd1, ymd2));
  CheckEquals(StrToDate('2001/1/1'), ymd1);
  CheckEquals(StrToDate('2001/1/2'), ymd2);

  CheckTrue(list.Get(1, ymd1, ymd2));
  CheckEquals(StrToDate('2001/1/5'), ymd1);
  CheckEquals(StrToDate('2001/1/7'), ymd2);

  CheckTrue(list.Get(2, ymd1, ymd2));
  CheckEquals(StrToDate('2001/1/10'), ymd1);
  CheckEquals(StrToDate('2001/1/12'), ymd2);
end;

procedure TRangeListTest.TestClear;
begin
  CheckEquals(0, list.Count);
  list.Add(StrToDate('2001/1/1'), StrToDate('2001/1/2'));
  CheckEquals(1, list.Count);
  list.Add(StrToDate('2001/1/5'), StrToDate('2001/1/7'));
  CheckEquals(2, list.Count);
  list.Add(StrToDate('2001/1/10'), StrToDate('2001/1/12'));
  CheckEquals(3, list.Count);
  list.Clear;
  CheckEquals(0, list.Count);
  list.Add(StrToDate('2001/1/1'), StrToDate('2001/1/2'));
  CheckEquals(1, list.Count);
end;


initialization
 TestFramework.RegisterTest(TRangeListTest.Suite);

end.
