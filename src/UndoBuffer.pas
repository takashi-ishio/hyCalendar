unit UndoBuffer;

interface

uses Classes, Contnrs, CalendarAction;

type

    TUndoBuffer = class
    private
        FMaxUndo: integer;
        FList : TObjectList;
        FIndex: integer; // ÅŒã‚É add ‚³‚ê‚½ item ‚ðŽ¦‚·
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

constructor TUndoBuffer.Create;
begin
    FList := TObjectList.Create;
    FIndex := -1;
    FMaxUndo := max_undo;
end;

destructor TUndoBuffer.Destroy;
begin
    FList.Free;
end;

procedure TUndoBuffer.Clear;
begin
    FList.Clear;
    FIndex := -1;
end;

function TUndoBuffer.CanUndo: boolean;
begin
    Result := (FIndex >= 0);
end;

procedure TUndoBuffer.pushAction(action : TCalendarAction);
var
    i: integer;
begin
    if CanRedo then begin
        i := Count-1;
        while Findex < i do begin
            FList.Delete(i);
            Dec(i);
        end;
    end;
    FList.Add(action);
    Inc(FIndex);

    if FMaxUndo < Count then begin
        FList.Delete(0);
        Dec(FIndex);
    end;
end;

procedure TUndoBuffer.redo(step: integer);
var
    i: integer;
begin
    if (not CanRedo)or(step < 1) then exit;
    i := step;
    repeat
        Inc(FIndex);
        TCalendarAction(FList[FIndex]).doAction;
        Dec(i);
    until not CanRedo or (i = 0);
end;

function TUndoBuffer.CanRedo: boolean;
begin
    Result := (FIndex < Count-1);
end;

procedure TUndoBuffer.rollback(back: integer);
var
    i: integer;
begin
    i := back;
    while (FIndex >= 0)and(i > 0) do begin
        TCalendarAction(FList[FIndex]).undoAction;
        Dec(FIndex);
        Dec(i);
    end;
end;

function TUndoBuffer.Count: integer;
begin
    Result := FList.Count;
end;


end.
