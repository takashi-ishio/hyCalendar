unit SeriesCallback;

interface

type
    TSeriesItemConditionCallback = class
      function isHoliday(day: TDateTime; IncludeUserDefined: boolean; idx: integer): boolean; virtual; abstract;
      function isMatched(day: TDateTime; ReferItem: TObject): boolean; virtual; abstract;  //TSeriesItem �ւ̎Q�Ƃ��������߂� TObject �^
    end;


implementation

end.
