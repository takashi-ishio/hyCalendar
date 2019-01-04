unit SeriesItemTest;

interface

uses
  Classes, Graphics, SysUtils, DateUtils,
  SeriesItem, SeriesItemCondition, SeriesItemConditionTest,
  TestFramework;

type
  TSeriesItemTest = class(TTestCase)

  private
    FItem: TSeriesItem;

  protected
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure TestProperties;
    procedure TestAddCondition;
    procedure TestDeleteCondition;
    procedure TestRemoveCondition;
    procedure TestExchangeCondition;
    procedure TestClearCondition;
    procedure TestReplaceCondition;
    procedure TestMatch;
  end;

  TSeriesItemListTest = class(TTestCase)
  private
    FList: TSeriesItemList;

  protected
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure TestAddDeleteClear;
    procedure TestExchange;
    procedure TestEditing;
  end;

implementation

procedure TSeriesItemTest.SetUp;
begin
    FItem := TSeriesItem.Create;
end;

procedure TSeriesItemTest.TearDown;
begin
    FItem.Free;
end;

procedure TSeriesItemTest.TestProperties;
begin
  CheckEquals('（新しい予定）', FItem.Name);
  CheckFalse(FItem.IsHidden);
  CheckFalse(FItem.IsShownAsDayName);
  CheckFalse(FItem.IsHoliday);
  CheckFalse(FItem.UseColor);
  CheckEquals(clBlack, FItem.Color);
  CheckEquals(0, FItem.ConditionCount);

  FItem.Name := 'NEW SCHEDULE';
  CheckEquals('NEW SCHEDULE', FItem.Name);

  FItem.IsHidden := true;
  CheckTrue(FItem.IsHidden);

  FItem.IsShownAsDayName := true;
  CheckTrue(FItem.IsShownAsDayName);

  FItem.IsHoliday := true;
  CheckTrue(FItem.IsHoliday);

  FItem.UseColor := true;
  CheckTrue(FItem.UseColor);

  FItem.Color := clRed;
  CheckEquals(clRed, FItem.Color);
end;

procedure TSeriesItemTest.TestAddCondition;
var
  cond, cond2, cond3, cond4: TSeriesItemCondition;

begin
  cond := TSeriesItemConditionImpl.Create;
  cond2 := TSeriesItemConditionImpl.Create;
  cond3 := TSeriesItemConditionImpl.Create;
  cond4 := TSeriesItemConditionImpl.Create;
  FItem.addCondition(cond);
  FItem.addCondition(cond2);
  CheckEquals(2, FItem.ConditionCount);
  CheckTrue(FItem.Conditions[0] = cond);
  CheckTrue(FItem.Conditions[1] = cond2);
  FItem.addCondition(nil);
  CheckEquals(2, FItem.ConditionCount);
  FItem.addCondition(cond);
  CheckEquals(2, FItem.ConditionCount);
  FItem.addCondition(cond2);
  CheckEquals(2, FItem.ConditionCount);
  CheckTrue(cond.Owner = FItem);
  CheckTrue(cond2.Owner = FItem);
  FItem.insertCondition(1, cond3);
  CheckEquals(3, FItem.ConditionCount);
  CheckTrue(cond3.Owner = FItem);
  CheckTrue(FItem.Conditions[0] = cond);
  CheckTrue(FItem.Conditions[1] = cond3);
  CheckTrue(FItem.Conditions[2] = cond2);
  FItem.insertCondition(1, cond);
  CheckEquals(3, FItem.ConditionCount);
  FItem.insertCondition(3, cond4);
  CheckEquals(4, FItem.ConditionCount);

  CheckEquals(0, FItem.indexOf(cond));
  CheckEquals(1, FItem.indexOf(cond3));
  CheckEquals(2, FItem.indexOf(cond2));
  CheckEquals(3, FItem.indexOf(cond4));

  // cond, cond2, cond3 は FItem.Free で解放される
end;

procedure TSeriesItemTest.TestDeleteCondition;
var
  cond, cond2: TSeriesItemCondition;
begin
  cond := TSeriesItemConditionImpl.Create;
  cond2 := TSeriesItemConditionImpl.Create;
  FItem.addCondition(cond);
  FItem.addCondition(cond2);
  FItem.deleteCondition(0);
  CheckEquals(1, FItem.ConditionCount);
  CheckTrue(cond2 = FItem.Conditions[0]);
end;

procedure TSeriesItemTest.TestRemoveCondition;
var
  cond: TSeriesItemCondition;
  item2: TSeriesItem;
  cond2: TSeriesItemCondition;
begin
  cond := TSeriesItemConditionImpl.Create;
  FItem.addCondition(cond);
  CheckTrue(cond.Owner = FItem);
  CheckEquals(1, FItem.ConditionCount);
  FItem.removeCondition(cond);
  CheckEquals(0, FItem.ConditionCount);
  CheckTrue(cond.Owner = nil);

  item2 := TSeriesItem.Create;
  cond2 := TSeriesItemConditionImpl.Create;
  try
    item2.addCondition(cond2);
    CheckTrue(cond2.Owner = item2);
    FItem.removeCondition(cond2);
    CheckTrue(cond2.Owner = item2);
  finally
    item2.Free;
  end;
end;

procedure TSeriesItemTest.TestExchangeCondition;
var
  cond: TSeriesItemCondition;
  cond2: TSeriesItemCondition;
  cond3: TSeriesItemCondition;
begin
  cond := TSeriesItemConditionImpl.Create;
  cond2 := TSeriesItemConditionImpl.Create;
  cond3 := TSeriesItemConditionImpl.Create;
  FItem.addCondition(cond);
  FItem.addCondition(cond2);
  FItem.addCondition(cond3);
  FItem.exchangeCondition(0, 2);
  CheckEquals(2, FItem.indexOf(cond));
  CheckEquals(1, FItem.indexOf(cond2));
  CheckEquals(0, FItem.indexOf(cond3));

  // Valid but No effect
  FItem.exchangeCondition(1, 1);
  CheckEquals(2, FItem.indexOf(cond));
  CheckEquals(1, FItem.indexOf(cond2));
  CheckEquals(0, FItem.indexOf(cond3));

  // Invalid: No Effect
  FItem.exchangeCondition(-1, 1);
  FItem.exchangeCondition(1, -1);
  FItem.exchangeCondition(1, 5);
  FItem.exchangeCondition(3, 2);
  CheckEquals(2, FItem.indexOf(cond));
  CheckEquals(1, FItem.indexOf(cond2));
  CheckEquals(0, FItem.indexOf(cond3));
end;

procedure TSeriesItemTest.TestClearCondition;
var
  cond: TSeriesItemCondition;
  cond2: TSeriesItemCondition;
begin
  cond := TSeriesItemConditionImpl.Create;
  cond2 := TSeriesItemConditionImpl.Create;
  FItem.addCondition(cond);
  FItem.addCondition(cond2);
  FItem.clearCondition;
  CheckTrue(cond.Owner = nil);
  CheckTrue(cond2.Owner = nil);
  CheckEquals(0, FItem.ConditionCount);
  FItem.addCondition(cond);
  FItem.addCondition(cond2);
  CheckEquals(2, FItem.ConditionCount);
end;

procedure TSeriesItemTest.TestReplaceCondition;
var
  cond: TSeriesItemCondition;
  cond2: TSeriesItemCondition;
begin
  cond := TSeriesItemConditionImpl.Create;
  cond2 := TSeriesItemConditionImpl.Create;
  FItem.addCondition(cond);
  FItem.replaceCondition(0, cond2);
  CheckEquals(-1, FItem.indexOf(cond));
  CheckEquals(0, FItem.indexOf(cond2));
  CheckTrue(cond.Owner = nil);
  CheckTrue(cond2.Owner = FItem);
  FItem.addCondition(cond);
end;

// 基本のマッチ動作だけテスト
procedure TSeriesItemTest.TestMatch;
var
  s: string;
  b: boolean;
  cond: TSeriesItemCondition;
  d: integer;
begin
  b := FItem.match(StrToDate('2000/1/1'), nil, 0, s);
  CheckEquals(false, b);

  cond := TSeriesItemConditionImpl.Create;
  FItem.addCondition(cond);
  b := FItem.match(StrToDate('2000/1/1'), nil, 0, s);
  CheckEquals(true, b);
  CheckEquals('（新しい予定）', s);
  b := FItem.match(StrToDate('2000/1/2'), nil, 0, s);
  CheckEquals(false, b);

  FItem.SpecifyBaseDate := false;
  d := DaysBetween(StrToDate('2000/1/1'), Date);
  FItem.Name := '予定 %d %D %d';
  b := FItem.match(StrToDate('2000/1/1'), nil, 0, s);
  CheckEquals('予定 '+IntToStr(d) +' %D ' + IntToStr(d), s);
  CheckTrue(b);

  FItem.SpecifyBaseDate := true;
  FItem.BaseDate := StrToDate('2000/1/10');
  b := FItem.match(StrToDate('2000/1/1'), nil, 0, s);
  CheckEquals('予定 9 %D 9', s);
  CheckTrue(b);

end;

procedure TSeriesItemListTest.SetUp;
begin
  FList := TSeriesItemList.Create;
end;

procedure TSeriesItemListTest.TearDown;
begin
  FList.Free; // free all items
end;

procedure TSeriesItemListTest.TestAddDeleteClear;
var
  item: TSeriesItem;
  item2: TSeriesItem;
begin
  item := FList.Add;
  item2 := FList.Add;
  CheckTrue(item = FList.Items[0]);
  CheckTrue(item2 = FList.Items[1]);
  CheckEquals(0, FList.IndexOf(item));
  CheckEquals(1, FList.IndexOf(item2));
  CheckEquals(2, FList.Count);
  FList.Delete(0);
  CheckEquals(1, FList.Count);
  CheckEquals(0, FList.IndexOf(item2));
  FList.Clear;
  CheckEquals(0, FList.Count);
end;

procedure TSeriesItemListTest.TestExchange;
var
  item: TSeriesItem;
  item2: TSeriesItem;
begin
  item := FList.Add;
  item2 := FList.Add;
  CheckTrue(item = FList.Items[0]);
  CheckTrue(item2 = FList.Items[1]);

  FList.Exchange(0, 1);
  CheckTrue(item = FList.Items[1]);
  CheckTrue(item2 = FList.Items[0]);
  CheckTrue(item = FList.Items[1]);
  CheckTrue(item2 = FList.Items[0]);

  FList.Exchange(0, 0);
  CheckTrue(item = FList.Items[1]);
  CheckTrue(item2 = FList.Items[0]);

  FList.Exchange(2, 0);
  FList.Exchange(-1, 0);
  FList.Exchange(0, -1);
  FList.Exchange(0, 3);
  CheckTrue(item = FList.Items[1]);
  CheckTrue(item2 = FList.Items[0]);
end;

procedure TSeriesItemListTest.TestEditing;
begin
  CheckFalse(FList.Editing);
  FList.BeginEdit;
  CheckTrue(FList.Editing);
  FList.EndEdit;
  CheckFalse(FList.Editing);
end;

initialization
 TestFramework.RegisterTest(TSeriesItemTest.Suite);
 TestFramework.RegisterTest(TSeriesItemListTest.Suite);

end.
