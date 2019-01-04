unit UndoBuffer;
// UndoBuffer ‚Ì‚½‚ß‚ÌƒXƒ^ƒu

interface

uses Classes, Contnrs, CalendarAction;

type
    TUndoBuffer = class
    public
        constructor Create(max_undo: integer);
        destructor Destroy; override;
        procedure Clear;
        function Count: integer;
        function CanUndo: boolean;
        function CanRedo: boolean;
        procedure pushAction(action : TCalendarAction);
        procedure rollback(back: integer);
        procedure redo(step: integer);
    end;

implementation

constructor TUndoBuffer.Create(max_undo: integer);
begin

end;

destructor TUndoBuffer.Destroy;
begin

end;

procedure TUndoBuffer.Clear;
begin
end;

function TUndoBuffer.Count: integer;
begin
    Result := 0;
end;

function TUndoBuffer.CanUndo: boolean;
begin
    Result := false;
end;

function TUndoBuffer.CanRedo: boolean;
begin
    Result := false;
end;

procedure TUndoBuffer.pushAction(action : TCalendarAction);
begin

end;

procedure TUndoBuffer.rollback(back: integer);
begin

end;

procedure TUndoBuffer.redo(step: integer);
begin

end;

end.
