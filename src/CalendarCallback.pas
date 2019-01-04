unit CalendarCallback;

interface

type
    TCalendarCallback = class
      procedure CalendarRepaint; virtual; abstract;
      procedure SetDirty; virtual; abstract;
      procedure MoveDate(d: TDateTime); virtual; abstract;
      procedure setEnforceSelectDayWithoutMovePage(value: boolean); virtual; abstract;
    end;

implementation

end.
