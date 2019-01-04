unit SeriesCallback;

interface

type
    TSeriesItemConditionCallback = class
      function isHoliday(day: TDateTime; IncludeUserDefined: boolean; idx: integer): boolean; virtual; abstract;
      function isMatched(day: TDateTime; ReferItem: TObject): boolean; virtual; abstract;  //TSeriesItem ‚Ö‚ÌQÆ‚ğœ‚­‚½‚ß‚É TObject Œ^
    end;


implementation

end.
