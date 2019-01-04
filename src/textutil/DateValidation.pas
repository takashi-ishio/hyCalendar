unit DateValidation;

interface

  function isValid(day: TDateTime): boolean;

implementation

uses
  DateUtils,
  Constants;

function isValid(day: TDateTime): boolean;
begin
    Result :=  (YearOf(day) >= MIN_YEAR)and(YearOf(day) <= MAX_YEAR);
end;

end.
