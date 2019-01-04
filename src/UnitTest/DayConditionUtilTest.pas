unit DayConditionUtilTest;

interface

uses
  TestFramework, StringSplitter, SysUtils, DateUtils, DayConditionUtil;
type

  TestTMonthMatchExpr = class(TTestCase)
  strict private
    FMonthMatchExpr: TMonthMatchExpr;

  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Testmatch;
    procedure TesttoString;
  end;

  TestTDayMatchExpr = class(TTestCase)
  strict private
    FDayMatchExpr: TDayMatchExpr;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Testmatch;
    procedure TesttoString;
  end;

  TestTYoubiCondition = class(TTestCase)
  strict private
    FYoubiCondition: TYoubiCondition;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Testmatch;
    procedure TesttoString;
  end;

  TestTWeekMatchExpr = class(TTestCase)
  strict private
    FWeekMatchExpr: TWeekMatchExpr;
    FYoubiCondition: TYoubiCondition;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Testmatch;
    procedure TesttoString;
  end;

implementation

function MakeDate(m, d: integer): TDateTime;
begin
  Result := EncodeDate(2000, m, d);
end;

procedure TestTMonthMatchExpr.SetUp;
begin
  FMonthMatchExpr := TMonthMatchExpr.Create;
end;

procedure TestTMonthMatchExpr.TearDown;
begin
  FMonthMatchExpr.Free;
  FMonthMatchExpr := nil;
end;

procedure TestTMonthMatchExpr.Testmatch;
begin
  FMonthMatchExpr.Expr := '1-3, 5, 11-';
  CheckTrue(FMonthMatchExpr.match(MakeDate(1,1)));
  CheckTrue(FMonthMatchExpr.match(MakeDate(2,1)));
  CheckTrue(FMonthMatchExpr.match(MakeDate(3,1)));
  CheckTrue(FMonthMatchExpr.match(MakeDate(5,1)));
  CheckTrue(FMonthMatchExpr.match(MakeDate(11,1)));
  CheckTrue(FMonthMatchExpr.match(MakeDate(12,1)));
  CheckFalse(FMonthMatchExpr.match(MakeDate(4,1)));
  CheckFalse(FMonthMatchExpr.match(MakeDate(6,1)));
  CheckFalse(FMonthMatchExpr.match(MakeDate(7,1)));
  CheckFalse(FMonthMatchExpr.match(MakeDate(8,1)));
  CheckFalse(FMonthMatchExpr.match(MakeDate(9,1)));
  CheckFalse(FMonthMatchExpr.match(MakeDate(10,1)));

  FMonthMatchExpr.Expr := '-1,z';
  CheckTrue(FMonthMatchExpr.match(MakeDate(1,1)));
  CheckFalse(FMonthMatchExpr.match(MakeDate(2,1)));
  CheckFalse(FMonthMatchExpr.match(MakeDate(12,1)));

  FMonthMatchExpr.Expr := ',5,,3,';
  CheckTrue(FMonthMatchExpr.match(MakeDate(3,1)));
  CheckTrue(FMonthMatchExpr.match(MakeDate(5,1)));
  CheckFalse(FMonthMatchExpr.match(MakeDate(4,1)));

  FMonthMatchExpr.Expr := 'z';
  CheckFalse(FMonthMatchExpr.match(MakeDate(1,1)));
  CheckFalse(FMonthMatchExpr.match(MakeDate(12,1)));

  FMonthMatchExpr.Expr := '-z';
  CheckFalse(FMonthMatchExpr.match(MakeDate(1,1)));
  CheckFalse(FMonthMatchExpr.match(MakeDate(5,1)));
  CheckFalse(FMonthMatchExpr.match(MakeDate(12,1)));

  FMonthMatchExpr.Expr := '';
  CheckEquals('', FMonthMatchExpr.Expr);
  CheckTrue(FMonthMatchExpr.match(MakeDate(1,1)));
  CheckTrue(FMonthMatchExpr.match(MakeDate(5,1)));
  CheckTrue(FMonthMatchExpr.match(MakeDate(12,1)));

  FMonthMatchExpr.Expr := 'NONE';
  CheckEquals('NONE', FMonthMatchExpr.Expr);
end;

procedure TestTMonthMatchExpr.TesttoString;
var
  ReturnValue: string;
begin
  FMonthMatchExpr.Expr := '3, 7-9';
  ReturnValue := FMonthMatchExpr.toString;
  CheckEquals('3, 7�`9��  ', ReturnValue);

  FMonthMatchExpr.Expr := '2,,7,8,12,z';
  ReturnValue := FMonthMatchExpr.toString;
  CheckEquals('2, 7�`8, 12��  ', ReturnValue);

  FMonthMatchExpr.Expr := '';
  ReturnValue := FMonthMatchExpr.toString;
  CheckEquals('', ReturnValue);

end;

procedure TestTDayMatchExpr.SetUp;
begin
  FDayMatchExpr := TDayMatchExpr.Create;
end;

procedure TestTDayMatchExpr.TearDown;
begin
  FDayMatchExpr.Free;
  FDayMatchExpr := nil;
end;

procedure TestTDayMatchExpr.Testmatch;
begin
  FDayMatchExpr.Expr := '-4,9,22,28-';
  CheckTrue(FDayMatchExpr.match(MakeDate(1,1)));
  CheckTrue(FDayMatchExpr.match(MakeDate(2,1)));
  CheckFalse(FDayMatchExpr.match(MakeDate(1,5)));
  CheckFalse(FDayMatchExpr.match(MakeDate(2,5)));
  CheckTrue(FDayMatchExpr.match(MakeDate(1,9)));
  CheckFalse(FDayMatchExpr.match(MakeDate(1,10)));
  CheckTrue(FDayMatchExpr.match(MakeDate(1,28)));
  CheckTrue(FDayMatchExpr.match(MakeDate(1,29)));
  CheckTrue(FDayMatchExpr.match(MakeDate(1,30)));
  CheckTrue(FDayMatchExpr.match(MakeDate(1,31)));
  CheckTrue(FDayMatchExpr.match(MakeDate(2,28)));
  CheckTrue(FDayMatchExpr.match(MakeDate(2,29)));

  FDayMatchExpr.Expr := 'z'; // ��: -z �̂悤�ȏ������͈Ӗ��Ȃ�
  CheckTrue(FDayMatchExpr.match(MakeDate(2,29)));
  CheckTrue(FDayMatchExpr.match(MakeDate(1,31)));
  CheckFalse(FDayMatchExpr.match(MakeDate(2,28)));
  CheckFalse(FDayMatchExpr.match(MakeDate(1,30)));

  FDayMatchExpr.Expr := '-z'; // ��: -z �̂悤�ȏ������͈Ӗ��Ȃ�
  CheckFalse(FDayMatchExpr.match(MakeDate(1,31)));
  CheckFalse(FDayMatchExpr.match(MakeDate(2,28)));
  CheckFalse(FDayMatchExpr.match(MakeDate(2,29)));

  FDayMatchExpr.Expr := '31,z'; // ��: -z �̂悤�ȏ������͈Ӗ��Ȃ�
  CheckFalse(FDayMatchExpr.match(MakeDate(1,30)));
  CheckTrue(FDayMatchExpr.match(MakeDate(1,31)));
  CheckFalse(FDayMatchExpr.match(MakeDate(2,28)));
  CheckTrue(FDayMatchExpr.match(MakeDate(2,29)));
end;

procedure TestTDayMatchExpr.TesttoString;
var
  ReturnValue: string;
begin
  FDayMatchExpr.Expr := '';
  ReturnValue := FDayMatchExpr.toString;
  CheckEquals('', ReturnValue);

  FDayMatchExpr.Expr := '5-14, 11-20';
  ReturnValue := FDayMatchExpr.toString;
  CheckEquals('5�`20��  ', ReturnValue);

  FDayMatchExpr.Expr := '7,z';
  ReturnValue := FDayMatchExpr.toString;
  CheckEquals('7��, ����  ', ReturnValue);

  FDayMatchExpr.Expr := '-2,30-,z';
  ReturnValue := FDayMatchExpr.toString;
  CheckEquals('1�`2, 30�`31��, ����  ', ReturnValue);

end;

procedure TestTYoubiCondition.SetUp;
begin
  FYoubiCondition := TYoubiCondition.Create;
end;

procedure TestTYoubiCondition.TearDown;
begin
  FYoubiCondition.Free;
  FYoubiCondition := nil;
end;

procedure TestTYoubiCondition.Testmatch;
begin
  // 1��1��=�y�j��

  FYoubiCondition.Youbi[1] := True;
  CheckTrue(FYoubiCondition.Enabled);
  FYoubiCondition.Youbi[2] := True;
  FYoubiCondition.Youbi[1] := False;
  FYoubiCondition.Youbi[2] := False;
  CheckFalse(FYoubiCondition.Enabled);

  FYoubiCondition.Youbi[1] := True;  // ���j
  CheckTrue(FYoubiCondition.match(MakeDate(1, 2)));
  CheckTrue(FYoubiCondition.match(MakeDate(1, 9)));
  CheckTrue(FYoubiCondition.match(MakeDate(1, 16)));
  CheckFalse(FYoubiCondition.match(MakeDate(1, 1)));
  CheckFalse(FYoubiCondition.match(MakeDate(1, 3)));
  CheckFalse(FYoubiCondition.match(MakeDate(1, 4)));
  CheckFalse(FYoubiCondition.match(MakeDate(1, 5)));
  CheckFalse(FYoubiCondition.match(MakeDate(1, 6)));
  CheckFalse(FYoubiCondition.match(MakeDate(1, 7)));

  FYoubiCondition.Youbi[4] := True;
  CheckFalse(FYoubiCondition.match(MakeDate(1, 1)));
  CheckTrue(FYoubiCondition.match(MakeDate(1, 2)));
  CheckFalse(FYoubiCondition.match(MakeDate(1, 3)));
  CheckFalse(FYoubiCondition.match(MakeDate(1, 4)));
  CheckTrue(FYoubiCondition.match(MakeDate(1, 5)));
  CheckFalse(FYoubiCondition.match(MakeDate(1, 6)));
  CheckFalse(FYoubiCondition.match(MakeDate(1, 7)));
end;

procedure TestTYoubiCondition.TesttoString;
var
  ReturnValue: string;
begin
  ReturnValue := FYoubiCondition.toString;
  CheckEquals('', ReturnValue);

  FYoubiCondition.Youbi[1] := True;
  ReturnValue := FYoubiCondition.toString;
  CheckEquals('��', ReturnValue);

  FYoubiCondition.Youbi[3] := True;
  ReturnValue := FYoubiCondition.toString;
  CheckEquals('��, ��', ReturnValue);

  FYoubiCondition.Youbi[2] := True;
  ReturnValue := FYoubiCondition.toString;
  CheckEquals('���`��', ReturnValue);
end;

procedure TestTWeekMatchExpr.SetUp;
begin
  FWeekMatchExpr := TWeekMatchExpr.Create;
  FYoubiCondition := TYoubiCondition.Create;
end;

procedure TestTWeekMatchExpr.TearDown;
begin
  FWeekMatchExpr.Free;
  FWeekMatchExpr := nil;
  FYoubiCondition.Free;
  FYoubiCondition := nil;
end;

procedure TestTWeekMatchExpr.Testmatch;
begin
  FWeekMatchExpr.Expr := '1,3,z';
  CheckTrue(FWeekMatchExpr.match(makeDate(1,1)));
  CheckTrue(FWeekMatchExpr.match(makeDate(1,7)));
  CheckFalse(FWeekMatchExpr.match(makeDate(1,8)));
  CheckFalse(FWeekMatchExpr.match(makeDate(1,14)));
  CheckTrue(FWeekMatchExpr.match(makeDate(1,15)));
  CheckTrue(FWeekMatchExpr.match(makeDate(1,21)));
  CheckFalse(FWeekMatchExpr.match(makeDate(1,22)));
  CheckFalse(FWeekMatchExpr.match(makeDate(1,24)));
  CheckTrue(FWeekMatchExpr.match(makeDate(1,25)));
  CheckTrue(FWeekMatchExpr.match(makeDate(1,29)));
  CheckTrue(FWeekMatchExpr.match(makeDate(1,30)));
  CheckTrue(FWeekMatchExpr.match(makeDate(1,31)));
  CheckTrue(FWeekMatchExpr.match(makeDate(2,1)));
  CheckTrue(FWeekMatchExpr.match(makeDate(2,7)));
  CheckFalse(FWeekMatchExpr.match(makeDate(2,8)));

  // 1/1 �͓y�j�n�܂�-- ISO8601�I�ɂ́C1/3�����P�T
  FWeekMatchExpr.WeekCountMode := WEEKMODE_ISO8601;
  CheckFalse(FWeekMatchExpr.match(makeDate(1,1)));
  CheckFalse(FWeekMatchExpr.match(makeDate(1,2))); // ���j
  CheckTrue(FWeekMatchExpr.match(makeDate(1,3)));
  CheckTrue(FWeekMatchExpr.match(makeDate(1,9)));
  CheckFalse(FWeekMatchExpr.match(makeDate(1,10)));
  CheckFalse(FWeekMatchExpr.match(makeDate(1,16)));
  CheckTrue(FWeekMatchExpr.match(makeDate(1,17)));
  CheckTrue(FWeekMatchExpr.match(makeDate(1,23)));
  CheckTrue(FWeekMatchExpr.match(makeDate(1,24))); // �ŏI�T�Ɋ܂܂��
  CheckTrue(FWeekMatchExpr.match(makeDate(1,30)));
  CheckTrue(FWeekMatchExpr.match(makeDate(1,31)));  // 31���́u�����̍ŏ��̏T�v

  FWeekMatchExpr.Expr := '3,z'; //��P�T�����
  CheckFalse(FWeekMatchExpr.match(makeDate(1,31)));
end;

procedure TestTWeekMatchExpr.TesttoString;
var
  ReturnValue: string;
begin
  FWeekMatchExpr.Expr := '1,3,z';
  ReturnValue := FWeekMatchExpr.toString(FYoubiCondition);
  CheckEquals('��1, 3, �ŏI  ���`���j', ReturnValue);
  FWeekMatchExpr.Expr := '1-3';
  ReturnValue := FWeekMatchExpr.toString(FYoubiCondition);
  CheckEquals('��1, 2, 3  ���`���j', ReturnValue);
  FYoubiCondition.Youbi[1] := True;
  ReturnValue := FWeekMatchExpr.toString(FYoubiCondition);
  CheckEquals('��1, 2, 3  ���j', ReturnValue);

  FWeekMatchExpr.WeekCountMode := WEEKMODE_ISO8601;
  ReturnValue := FWeekMatchExpr.toString(FYoubiCondition);
  CheckEquals('��1, 2, 3�T  ���j', ReturnValue);

  FWeekMatchExpr.Expr := '1,3,z';
  ReturnValue := FWeekMatchExpr.toString(FYoubiCondition);
  CheckEquals('��1, 3�T, �ŏI�T  ���j', ReturnValue);

end;

initialization
  RegisterTest(TestTMonthMatchExpr.Suite);
  RegisterTest(TestTDayMatchExpr.Suite);
  RegisterTest(TestTYoubiCondition.Suite);
  RegisterTest(TestTWeekMatchExpr.Suite);

end.

