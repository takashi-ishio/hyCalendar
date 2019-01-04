unit UndoBufferTest;

interface

uses
    SysUtils, TestFrameWork, CalendarAction, UndoBuffer;

type
    TUndoBufferTest = class(TTestCase)
    private
      FBuffer: TUndoBuffer;
    protected
      procedure SetUp; override;
      procedure TearDown; override;
    published
      procedure TestCountAndClear;
      procedure TestRollback;
    end;


implementation

type
  TIncrementAction = class(TCalendarAction)
    procedure doAction; override;
    procedure undoAction; override;
    constructor Create;
  end;

var
  Counter: Integer;

constructor TIncrementAction.Create;
begin
  doAction;
end;

procedure TIncrementAction.doAction;
begin
  Inc(Counter);
end;

procedure TIncrementAction.undoAction;
begin
  Dec(Counter);
end;

procedure TUndoBufferTest.setUp;
begin
  inherited;
  FBuffer := TUndoBuffer.Create(5);
  Counter := 0;
end;

procedure TUndoBufferTest.tearDown;
begin
  inherited;
  FBuffer.Free;
end;

procedure TUndoBufferTest.TestCountAndClear;
begin
  CheckEquals(0, FBuffer.Count);
  CheckFalse(FBuffer.CanUndo);
  CheckFalse(FBuffer.CanRedo);
  FBuffer.pushAction(TIncrementAction.Create);
  CheckEquals(1, FBuffer.Count);
  FBuffer.pushAction(TIncrementAction.Create);
  CheckEquals(2, FBuffer.Count);
  FBuffer.Clear;
  CheckFalse(FBuffer.CanUndo);
  CheckFalse(FBuffer.CanRedo);
  CheckEquals(0, FBuffer.Count);
  FBuffer.pushAction(TIncrementAction.Create);
  CheckEquals(1, FBuffer.Count);
  FBuffer.pushAction(TIncrementAction.Create);
  FBuffer.pushAction(TIncrementAction.Create);
  FBuffer.pushAction(TIncrementAction.Create);
  CheckEquals(4, FBuffer.Count);
  FBuffer.pushAction(TIncrementAction.Create);
  CheckEquals(5, FBuffer.Count);
  FBuffer.pushAction(TIncrementAction.Create);
  CheckEquals(5, FBuffer.Count);
  CheckTrue(FBuffer.CanUndo);
  CheckFalse(FBuffer.CanRedo);
end;

procedure TUndoBufferTest.TestRollback;
begin
  FBuffer.pushAction(TIncrementAction.Create);
  CheckEquals(1, Counter);
  CheckTrue(FBuffer.CanUndo);
  CheckFalse(FBuffer.CanRedo);

  FBuffer.rollback(1);
  CheckFalse(FBuffer.CanUndo);
  CheckTrue(FBuffer.CanRedo);
  CheckEquals(0, Counter);

  FBuffer.redo(1);
  CheckEquals(1, Counter);
  FBuffer.rollback(3);
  CheckEquals(0, Counter);

  FBuffer.pushAction(TIncrementAction.Create);
  FBuffer.pushAction(TIncrementAction.Create);
  CheckEquals(2, FBuffer.Count);

  FBuffer.rollback(3);
  CheckEquals(0, Counter);
  FBuffer.redo(3);
  CheckEquals(2, Counter);
  FBuffer.pushAction(TIncrementAction.Create);
  FBuffer.pushAction(TIncrementAction.Create);
  FBuffer.pushAction(TIncrementAction.Create);
  FBuffer.pushAction(TIncrementAction.Create);
  FBuffer.rollback(5);
  CheckEquals(1, Counter);

  CheckTrue(FBuffer.CanRedo);
  FBuffer.redo(1);
  CheckTrue(FBuffer.CanRedo);
  FBuffer.redo(1);
  CheckTrue(FBuffer.CanRedo);
  FBuffer.redo(1);
  CheckTrue(FBuffer.CanRedo);
  FBuffer.redo(1);
  CheckTrue(FBuffer.CanRedo);
  FBuffer.redo(1);
  CheckFalse(FBuffer.CanRedo);
  CheckEquals(6, Counter);

end;



initialization
 TestFramework.RegisterTest(TUndoBufferTest.Suite);


end.
