unit SeriesCallback;

interface

type
    TSeriesItemConditionCallback = class
      function isHoliday(day: TDateTime; IncludeUserDefined: boolean; idx: integer): boolean; virtual; abstract;
      function isMatched(day: TDateTime; ReferItem: TObject): boolean; virtual; abstract;  //TSeriesItem への参照を除くために TObject 型
    end;


implementation

end.
