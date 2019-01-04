unit RangeItemTest;

interface

uses
  Classes, SysUtils, RangeItem, TestFramework;

type
  TRangeItemTest = class(TTestCase)
  private
    FRange: TRangeItem;
  protected
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure TestSkipdays;
    procedure TestProperties;
    procedure TestToString;
  end;


implementation

procedure TRangeItemTest.SetUp;
begin
  FRange := TRangeItem.Create(StrToDate('2001/1/1'), StrToDate('2001/1/10'), 'OWNER');
end;

procedure TRangeItemTest.TearDown;
begin
  FRange.Free;
end;

procedure TRangeItemTest.TestProperties;
begin

end;

procedure TRangeItemTest.TestToString;
begin

end;

procedure TRangeItemTest.TestSkipdays;
begin
  CheckEquals(0, FRange.EncodedSkipDays);
  CheckFalse(FRange.SkipHoliday);
  CheckFalse(FRange.SkipYoubi[1]);
  CheckFalse(FRange.SkipYoubi[2]);
  CheckFalse(FRange.SkipYoubi[3]);
  CheckFalse(FRange.SkipYoubi[4]);
  CheckFalse(FRange.SkipYoubi[5]);
  CheckFalse(FRange.SkipYoubi[6]);
  CheckFalse(FRange.SkipYoubi[7]);

  FRange.SkipHoliday := true;
  CheckTrue(FRange.SkipHoliday);
  CheckEquals(1, FRange.EncodedSkipDays);
  CheckFalse(FRange.SkipYoubi[1]);
  CheckFalse(FRange.SkipYoubi[2]);
  CheckFalse(FRange.SkipYoubi[3]);
  CheckFalse(FRange.SkipYoubi[4]);
  CheckFalse(FRange.SkipYoubi[5]);
  CheckFalse(FRange.SkipYoubi[6]);
  CheckFalse(FRange.SkipYoubi[7]);

  FRange.SkipYoubi[1] := true;
  CheckEquals(3, FRange.EncodedSkipDays);
  CheckTrue(FRange.SkipHoliday);
  CheckTrue(FRange.SkipYoubi[1]);
  CheckFalse(FRange.SkipYoubi[2]);
  CheckFalse(FRange.SkipYoubi[3]);
  CheckFalse(FRange.SkipYoubi[4]);
  CheckFalse(FRange.SkipYoubi[5]);
  CheckFalse(FRange.SkipYoubi[6]);
  CheckFalse(FRange.SkipYoubi[7]);

  FRange.SkipYoubi[4] := true;
  CheckEquals(19, FRange.EncodedSkipDays);
  CheckTrue(FRange.SkipHoliday);
  CheckTrue(FRange.SkipYoubi[1]);
  CheckFalse(FRange.SkipYoubi[2]);
  CheckFalse(FRange.SkipYoubi[3]);
  CheckTrue(FRange.SkipYoubi[4]);
  CheckFalse(FRange.SkipYoubi[5]);
  CheckFalse(FRange.SkipYoubi[6]);
  CheckFalse(FRange.SkipYoubi[7]);

  FRange.EncodedSkipDays := 172;
  CheckFalse(FRange.SkipHoliday);
  CheckFalse(FRange.SkipYoubi[1]);
  CheckTrue(FRange.SkipYoubi[2]);
  CheckTrue(FRange.SkipYoubi[3]);
  CheckFalse(FRange.SkipYoubi[4]);
  CheckTrue(FRange.SkipYoubi[5]);
  CheckFalse(FRange.SkipYoubi[6]);
  CheckTrue(FRange.SkipYoubi[7]);

  FRange.EncodedSkipDays := 255;
  CheckTrue(FRange.SkipHoliday);
  CheckTrue(FRange.SkipYoubi[1]);
  CheckTrue(FRange.SkipYoubi[2]);
  CheckTrue(FRange.SkipYoubi[3]);
  CheckTrue(FRange.SkipYoubi[4]);
  CheckTrue(FRange.SkipYoubi[5]);
  CheckTrue(FRange.SkipYoubi[6]);
  CheckTrue(FRange.SkipYoubi[7]);

  FRange.SkipYoubi[2] := false;
  CheckEquals(251, FRange.EncodedSkipDays);
  FRange.SkipYoubi[7] := false;
  CheckEquals(123, FRange.EncodedSkipDays);
  FRange.SkipYoubi[2] := false;
  CheckEquals(123, FRange.EncodedSkipDays);
  FRange.SkipHoliday := false;
  CheckEquals(122, FRange.EncodedSkipDays);
  FRange.SkipHoliday := false;
  CheckEquals(122, FRange.EncodedSkipDays);
end;

initialization
 TestFramework.RegisterTest(TRangeItemTest.Suite);

end.
