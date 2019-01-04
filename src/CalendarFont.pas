unit CalendarFont;

interface

uses
    Graphics, 
    CalendarConfig;

type
    TFontMap = class
    private
        FConfiguration: TCalendarConfiguration;

    protected
        function UseScreenFontForPrint(index: integer): boolean;
        function getFont(index: integer): TFont; virtual;

    public
        constructor Create(config: TCalendarConfiguration);

        function TextFont: TFont;
        function DayFont: TFont;
        function DayNameFont: TFont;
        function HyperlinkFont: TFont;
        function FreeMemoFont: TFont;
        function RangeItemFont: TFont;
        function SeriesPlanItemFont: TFont;
        function TodoFont: TFont;
        function HolidayNameFont: TFont;
        function TodoViewFont: TFont;

    end;

    TPrinterFontMap = class(TFontMap)
    protected
        function getFont(index: integer): TFont; override;

    public
        constructor Create(config: TCalendarConfiguration);

    end;

implementation


constructor TFontMap.Create(config: TCalendarConfiguration);
begin
    FConfiguration := config;
end;

function TFontMap.UseScreenFontForPrint(index: integer): boolean;
begin
    Result := FConfiguration.UseScreenFontForPrint(index);
end;

function TFontMap.getFont(index: integer): TFont;
begin
    Result := FConfiguration.Fonts(index);
end;

function TFontMap.TextFont: TFont;
begin
    Result := getFont(INDEX_TEXTFONT);
end;

function TFontMap.DayFont: TFont;
begin
    Result := getFont(INDEX_DAYFONT);
end;

function TFontMap.DayNameFont: TFont;
begin
    Result := getFont(INDEX_DAYNAMEFONT);
end;

function TFontMap.HyperlinkFont: TFont;
begin
    Result := getFont(INDEX_HYPERLINKFONT);
end;

function TFontMap.FreeMemoFont: TFont;
begin
    Result := getFont(INDEX_FREEMEMOFONT);
end;

function TFontMap.RangeItemFont: TFont;
begin
    Result := getFont(INDEX_RANGEITEMFONT);
end;

function TFontMap.SeriesPlanItemFont: TFont;
begin
    Result := getFont(INDEX_SERIESPLANITEMFONT);
end;

function TFontMap.TodoFont: TFont;
begin
    Result := getFont(INDEX_TODOFONT);
end;

function TFontMap.HolidayNameFont: TFont;
begin
    Result := getFont(INDEX_HOLIDAYNAMEFONT);
end;

function TFontMap.TodoViewFont: TFont;
begin
    Result := getFont(INDEX_TODOVIEWFONT);
end;

constructor TPrinterFontMap.Create(config: TCalendarConfiguration);
begin
    inherited Create(config);
end;

function TPrinterFontMap.getFont(index: integer): TFont;
begin
    if not UseScreenFontForPrint(index) and (0 <= index) and (index <= MAX_SCREEN_FONT_INDEX) then begin
        Result := inherited getFont(INDEX_PRINT_FONT_OFFSET + index);
    end else begin
        Result := inherited getFont(index);
    end;
end;

end.
