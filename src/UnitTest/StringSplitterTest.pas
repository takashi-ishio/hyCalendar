unit StringSplitterTest;

interface

uses
  SysUtils, StringSplitter, TestFramework;

type
  TStringSplitterTest = class(TTestCase)

  private
    FSplitter: TStringSplitter;

  protected
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure TestGetLine;
    procedure TestResetSeparator;

  end;

implementation

procedure TStringSplitterTest.SetUp;
begin
  inherited;
  FSplitter := TStringSplitter.Create;
end;

procedure TStringSplitterTest.TearDown;
begin
  inherited;
  FSplitter.Free;
end;

procedure TStringSplitterTest.TestGetLine;
begin
  CheckFalse(FSplitter.hasNext);
  CheckFalse(FSplitter.isFirst);

  FSplitter.setString('Test1'#13#10'Test2'#13#10'Test3'#13#10);
  CheckFalse(FSplitter.isFirst);
  CheckTrue(FSplitter.hasNext);

  CheckEquals('Test1', FSplitter.getLine);
  CheckTrue(FSplitter.isFirst);
  CheckTrue(FSplitter.hasNext);

  CheckEquals('Test2', FSplitter.getLine);
  CheckFalse(FSplitter.isFirst);
  CheckTrue(FSplitter.hasNext);

  CheckEquals('Test3', FSplitter.getLine);
  CheckTrue(FSplitter.hasNext);

  CheckEquals('', FSplitter.getLine);
  CheckFalse(FSplitter.hasNext);

  CheckEquals('', FSplitter.getLine);
  CheckFalse(FSplitter.hasNext);

end;

procedure TStringSplitterTest.TestResetSeparator;
begin
  FSplitter.setString('Test'#13#10'test2/test3/test4');
  CheckEquals('Test', FSplitter.getLine);
  CheckTrue(FSplitter.isFirst);
  FSplitter.resetSeparator('/');
  CheckEquals('test2', FSplitter.getLine);
  CheckFalse(FSplitter.isFirst);
  CheckEquals('test3', FSplitter.getLine);
  CheckEquals('test4', FSplitter.getLine);
end;

initialization
 TestFramework.RegisterTest(TStringSplitterTest.Suite);


end.
