unit SeriesItemConditionTest;

interface

uses
  Classes, SysUtils, TestFramework,
  SeriesCallback, SeriesItemCondition;

type

  TSeriesItemConditionImpl = class(TSeriesItemCondition)
  protected
    function getStringRepresentation: string; override;
  public
    constructor Create;
    function isExclusion: boolean; override;
    function match(day: TDateTime; callback: TSeriesItemConditionCallback; idx: integer): boolean; override;

  end;

  TSeriesItemConditionTest = class(TTestCase)
  private
    FItem: TSeriesItemCondition;

  protected
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure TestProperties;

  end;

implementation

function TSeriesItemConditionImpl.getStringRepresentation: string;
begin
  result := 'TEST';
end;

constructor TSeriesItemConditionImpl.Create;
begin
  inherited;
end;

function TSeriesItemConditionImpl.isExclusion: boolean;
begin
  result := false;
end;

function TSeriesItemConditionImpl.match(day: TDateTime; callback: TSeriesItemConditionCallback; idx: integer): boolean;
begin
  result := (day = StrToDate('2000/1/1'));
end;

procedure TSeriesItemConditionTest.SetUp;
begin
  FItem := TSeriesItemConditionImpl.Create;
end;

procedure TSeriesItemConditionTest.TearDown;
begin
  FItem.Free;
end;

procedure TSeriesItemConditionTest.TestProperties;
begin
  FItem.Disabled := true;
  FItem.Rank := 5;
  FItem.Owner := self;
  CheckEquals(true, FItem.Disabled);
  CheckEquals(5, FItem.Rank);
  CheckTrue(self = FItem.Owner);
  CheckTrue(FItem.Disabled); // í èÌÇÕòAìÆÇ∑ÇÈ
  FItem.Disabled := false;
  FItem.Rank := 2;
  FItem.Owner := nil;
  CheckEquals(false, FItem.Disabled);
  CheckEquals(2, FItem.Rank);
  CheckTrue(nil = FItem.Owner);
  CheckFalse(FItem.Disabled); // í èÌÇÕòAìÆÇ∑ÇÈ
end;

initialization
 TestFramework.RegisterTest(TSeriesItemConditionTest.Suite);

end.
