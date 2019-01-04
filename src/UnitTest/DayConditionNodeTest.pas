unit DayConditionNodeTest;

interface

uses
  TestFramework, DayConditionNode, SeriesCallback, Classes, StrUtils,
  SeriesItemCondition, SeriesItem, SysUtils, Math, DateUtils;

type
  // クラスのテストメソッド TDayConditionNode

  TDayConditionNodeTest = class(TTestCase)
  strict private
    FDayConditionNode: TDayConditionNode;
    FSeriesItem: TSeriesItem;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestgetOwner;
    procedure Testmatch;
    procedure TestisExclusion;
  end;

implementation

procedure TDayConditionNodeTest.SetUp;
begin
  FSeriesItem := TSeriesItem.Create;
  FDayConditionNode := TDayConditionNode.Create;
end;

procedure TDayConditionNodeTest.TearDown;
begin
  FSeriesItem.removeCondition(FDayConditionNode);
  FSeriesItem.Free;
  FDayConditionNode.Free;
  FDayConditionNode := nil;
end;

procedure TDayConditionNodeTest.TestGetOwner;
var
  ReturnValue: TSeriesItem;
begin
  FSeriesItem.addCondition(FDayConditionNode);
  ReturnValue := FDayConditionNode.getOwner;
  CheckTrue(ReturnValue = FSeriesItem);
  FSeriesItem.removeCondition(FDayConditionNode);
  ReturnValue := FDayConditionNode.getOwner;
  CheckTrue(ReturnValue = nil);
end;

procedure TDayConditionNodeTest.Testmatch;
var
  ReturnValue: Boolean;
  idx: Integer;
  callback: TSeriesItemConditionCallback;
  day: TDateTime;
begin
  // 月・日・週・曜日に関する個別条件はテスト済み
  // 問題は「休日ならずれる」などをどうテストするか...
  // TODO: メソッド呼び出しパラメータのセットアップ
  //ReturnValue := FDayConditionNode.match(day, callback, idx);
  // TODO: メソッド呼び出しの検証
end;

procedure TDayConditionNodeTest.TestisExclusion;
var
  ReturnValue: Boolean;
begin
  ReturnValue := FDayConditionNode.isExclusion;
  // TODO: メソッド呼び出しの検証
end;

initialization
  // テストランナーでテストケースを登録します
  RegisterTest(TDayConditionNodeTest.Suite);
end.

