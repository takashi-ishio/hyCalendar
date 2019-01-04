unit DateValidationTest;

interface

uses
  DateUtils, SysUtils, DateValidation, TestFramework;

type
  TDateValidationTest = class(TTestCase)

  published
    procedure TestIsValid;
    
  end;


implementation

procedure TDateValidationTest.TestIsValid;
begin
  CheckFalse(isValid(EncodeDate(1970, 1, 1)));
  CheckFalse(isValid(EncodeDate(1979,12,31)));
  CheckTrue( isValid(EncodeDate(1980, 1, 1)));
  CheckTrue( isValid(EncodeDate(1990, 1, 1)));
  CheckTrue( isValid(EncodeDate(2000, 1, 1)));
  CheckTrue( isValid(EncodeDate(2050, 1, 1)));
  CheckTrue( isValid(EncodeDate(2099, 1, 1)));
  CheckTrue( isValid(EncodeDate(2099,12,31)));
  CheckFalse(isValid(EncodeDate(2100, 1, 1)));
end;

initialization
 TestFramework.RegisterTest(TDateValidationTest.Suite);


end.
