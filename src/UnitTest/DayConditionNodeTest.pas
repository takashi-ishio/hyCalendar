unit DayConditionNodeTest;

interface

uses
  TestFramework, DayConditionNode, SeriesCallback, Classes, StrUtils,
  SeriesItemCondition, SeriesItem, SysUtils, Math, DateUtils;

type
  // �N���X�̃e�X�g���\�b�h TDayConditionNode

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
  // ���E���E�T�E�j���Ɋւ���ʏ����̓e�X�g�ς�
  // ���́u�x���Ȃ炸���v�Ȃǂ��ǂ��e�X�g���邩...
  // TODO: ���\�b�h�Ăяo���p�����[�^�̃Z�b�g�A�b�v
  //ReturnValue := FDayConditionNode.match(day, callback, idx);
  // TODO: ���\�b�h�Ăяo���̌���
end;

procedure TDayConditionNodeTest.TestisExclusion;
var
  ReturnValue: Boolean;
begin
  ReturnValue := FDayConditionNode.isExclusion;
  // TODO: ���\�b�h�Ăяo���̌���
end;

initialization
  // �e�X�g�����i�[�Ńe�X�g�P�[�X��o�^���܂�
  RegisterTest(TDayConditionNodeTest.Suite);
end.

