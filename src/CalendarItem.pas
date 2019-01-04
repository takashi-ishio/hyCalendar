unit CalendarItem;

interface

uses Controls, DateUtils, SysUtils, Classes;

const
    MARKING_AND = 0;
    MARKING_OR  = 1;


type


  TCalendarItem = class
  private
    FText: string;
    FDay : TDate;
    FHyperLinks : TStringList;
  public
    constructor Create(day: TDate);
    destructor Destroy; override;
    function match(text: string; and_or: integer; caseSensitive: boolean): boolean;
    function getHyperLinks: TStrings;
    function getString: string;
    function getDate: TDate;
    procedure setString(text: string);
  end;

  TCalendarItemMonth = class
  private
    FItems : array [1..31] of TCalendarItem;
  public
    constructor Create;
    destructor Destroy; override;
    function getItem(Index: Integer): TCalendarItem;
    procedure setItem(item: TCalendarItem);
    property Items [Index: Integer]: TCalendarItem read getItem; default;
  end;


implementation

uses URLScan, StringSplitter, StrUtils;

constructor TCalendarItemMonth.Create;
var
    i: integer;
begin
    for i:=1 to 31 do begin
        FItems[i] := nil;
    end;
end;

destructor TCalendarItemMonth.Destroy;
var
    i: integer;
begin
    for i:=1 to 31 do begin
        if FItems[i] <> nil then FItems[i].Free;
    end;
end;

function TCalendarItemMonth.getItem(Index: Integer): TCalendarItem;
begin
    if (Index > 0)and(Index <= 31) then Result := FItems[Index]
    else Result := nil;
end;

procedure TCalendarItemMonth.setItem(item: TCalendarItem);
begin
    FItems[DayOf(item.getDate)] := item;
end;


constructor TCalendarItem.Create(day: TDate);
begin
    FDay  := day;
    FHyperLinks := TStringList.Create;
    FHyperLinks.Sorted := true;
end;

destructor TCalendarItem.Destroy;
begin
    TURLExtractor.getInstance.cleanupURLs(FHyperLinks);
    FHyperLinks.Free;
end;

function TCalendarItem.getDate: TDate;
begin
    Result := FDay;
end;

function TCalendarItem.getString: string;
begin
    Result := FText;
end;

function TCalendarItem.getHyperLinks: TStrings;
begin
    Result := FHyperLinks;
end;

procedure TCalendarItem.setString(text: string);
begin
    FText := text;
    TURLExtractor.getInstance.extractURLs(FText, FHyperLinks, YearOf(FDay));
end;

function TCalendarItem.match(text: string; and_or: integer; caseSensitive: boolean): boolean;
var
    s: TStringSplitter;
    t: string;
    b: boolean;
    at_least_one: boolean; // ƒAƒCƒeƒ€‚È‚µ‚Ì‚Æ‚«‚Í false ‚É‚·‚é‚½‚ß

    function match_internal(text: string; caseSensitive: boolean): boolean;
    begin
        Result := (caseSensitive and (AnsiContainsStr(getString, text)))
               or (not caseSensitive and (AnsiContainsStr(AnsiUpperCase(getString), AnsiUpperCase(text) )));
    end;

begin
    b := (and_or = MARKING_AND);
    at_least_one := false;

    s := TStringSplitter.Create(' ');
    s.setString(text);
    while (s.hasNext) do begin
        t := s.getLine;
        if (t <> '') then begin
            at_least_one := true;
            if (and_or = MARKING_AND) then b := b and match_internal(t, caseSensitive)
            else b := b or match_internal(t, caseSensitive);
        end;
    end;
    s.Free;

    result := b and at_least_one;
end;


end.
