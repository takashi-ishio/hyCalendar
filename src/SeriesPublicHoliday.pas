unit SeriesPublicHoliday;

interface

uses
  Contnrs, Classes, SysUtils, Forms,
  SeriesItem, SeriesCallback;

const
  MAX_LINES = 3000;

type
  TPublicHolidays = class(TSeriesItem)
  private
      FHolidayCount : integer;
      FHoliday     : array [0..MAX_LINES] of TDateTime;
      FHolidayName : array [0..MAX_LINES] of string;
      FErrorLines: TStringList;

  public
      constructor Create; overload;
      constructor Create(filename: string); overload;
      destructor Destroy; override;
      function match(d: TDateTime; callback: TSeriesItemConditionCallback; idx: integer; var ret: string): boolean; override;
      function hasError: boolean;
      property ErrorLines: TStringList read FErrorLines;
  end;


implementation

uses
    DateFormat;


const HolidayFile = 'holidays.txt';

constructor TPublicHolidays.Create(filename: string);
var
    l : TStringList;
    i : integer;
    idx: integer;
    d : TDateTime;
    errmsg : string;

begin
    inherited Create;

    Self.IsHoliday := true;
    Self.IsShownAsDayName := true;

    FErrorLines := TStringList.Create;

    l := TStringList.Create;
    FHolidayCount := 0;
    try
        errmsg := ExtractFilePath(Application.EXEName) + filename + '‚Ì“Ç‚Ýž‚Ý‚ÉŽ¸”s‚µ‚Ü‚µ‚½D';
        l.LoadFromFile(ExtractFilePath(Application.EXEName) + filename);
        for i:=0 to l.Count-1 do begin
            if i > MAX_LINES then break;

            idx := AnsiPos(#09, l[i]);
            if idx > 0 then begin
                if DateFormat.TryParseDate(Copy(l[i], 1, idx-1), d) then begin
                    FHoliday[FHolidayCount] := d;
                    FHolidayName[FHolidayCount] := Copy(l[i], idx+1, Length(l[i]));
                    FHolidayCount := FHolidayCount + 1;
                end else begin
                    ErrorLines.Add(l[i]);
                    break;
                end;
            end;
        end;
    except on E: Exception do
      FErrorLines.add(errmsg + ': ' + E.Message);
    end;
    l.Free;
end;

constructor TPublicHolidays.Create;
begin
  Create(HolidayFile);
end;

function TPublicHolidays.hasError: boolean;
begin
    Result := FErrorLines.Count > 0;
end;

destructor TPublicHolidays.Destroy;
begin
  FErrorLines.Free;
  inherited Destroy;
end;


function TPublicHolidays.match(d: TDateTime; callback: TSeriesItemConditionCallback; idx: integer; var ret: string): boolean;
var
    i: integer;
    found: boolean;
begin
    i := 0;
    found := false;
    while not found and (i < FHolidayCount) do begin
        found := found or (d = FHoliday[i]);
        i := i + 1;
    end;
    if found then ret := FHolidayName[i-1]
    else ret := '';
    Result := found;
end;


end.
