unit AbstractDocument;

interface

uses
    Classes,
    DocumentReference,
    SeriesItemManager;

type
    TAbstractCalendarDocument = class(TDocumentReference)
    public
        procedure updateSeriesItem(manager: TSeriesItemManager); virtual; abstract;

        { TodoItems, FreeMemo, MinDate, MaxDate はサポートしていない．
        TodoItems はおそらく不要だと思われる．
        FreeMemo は，起動時など更新タイミングが限られる．
        MinDate/MaxDate は CalendarItem 型をサポートする場合に必要になる，かも？
        }

    end;


implementation

end.
 