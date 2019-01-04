unit Constants;

interface

uses
  SysUtils;

const
    MIN_YEAR = 1980;
    MAX_YEAR = 2099;

var
    FIRST_DATE: TDateTime;
    LAST_DATE: TDateTime;


implementation

initialization
  FIRST_DATE := EncodeDate(MIN_YEAR, 1, 1);
  LAST_DATE := EncodeDate(MAX_YEAR, 12, 31);

end.
