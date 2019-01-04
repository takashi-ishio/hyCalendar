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

        { TodoItems, FreeMemo, MinDate, MaxDate �̓T�|�[�g���Ă��Ȃ��D
        TodoItems �͂����炭�s�v���Ǝv����D
        FreeMemo �́C�N�����ȂǍX�V�^�C�~���O��������D
        MinDate/MaxDate �� CalendarItem �^���T�|�[�g����ꍇ�ɕK�v�ɂȂ�C�����H
        }

    end;


implementation

end.
 