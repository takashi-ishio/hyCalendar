unit CalendarAction;
// undo ���������邽�߂� Action �N���X�D

interface

uses Classes, Graphics;

type

    TCalendarAction = class
    public
        destructor Destroy; override;
        procedure doAction; virtual; abstract;
        procedure undoAction; virtual; abstract;
    end;



implementation

destructor TCalendarAction.Destroy;
begin

end;


end.
