unit DateFormat;
// ロケール非依存な文字列関数を提供する．
// StrToDate のかわりに parseDate
// DateToStr のかわりに unparseDate

// -- といっても，実際にはロケール依存なグローバル変数を変換のつど
//    再設定しているだけだが，最も簡便な実装なのでこれを採用している．
//    （ShortDateFormat などのグローバル変数は Windows の設定が変わると
//      即座に値が変わる）

interface

const
    SAVE_DATE_FORMAT = 'yyyy/mm/dd'; // システムの 'yyyy/MM/dd' に相当
    SAVE_DATE_SEPARATOR = '/';


    //procedure saveOriginalDateFormat;

    //function getOriginalDateSeparator: char;
    function TryParseDate(s: string; var d: TDateTime): boolean;
    function parseDate(str: string): TDateTime;
    function parseDateDef(str: string; default: TDateTime): TDateTime;

    function unparseDate(d: TDateTime): string;

implementation

uses SysUtils;

//var
//    originalDateFormat : string;
//    originalDateSeparator : char;

procedure selectSaveDateFormat;
begin
    ShortDateFormat := SAVE_DATE_FORMAT;
    DateSeparator := SAVE_DATE_SEPARATOR;
end;


function TryParseDate(s: string; var d: TDateTime): boolean;
begin
    selectSaveDateFormat;
    Result := TryStrToDate(s, d);
end;

function parseDate(str: string): TDateTime;
begin
    selectSaveDateFormat;
    Result := StrToDate(str);
end;

function parseDateDef(str: string; default: TDateTime): TDateTime;
begin
    selectSaveDateFormat;
    Result := StrToDateDef(str, default);
end;

function unparseDate(d: TDateTime): string;
begin
    selectSaveDateFormat;
    Result := FormatDateTime(ShortDateFormat, d);
end;

//function getOriginalDateSeparator: char;
//begin
//    Result := originalDateSeparator;
//end;

//procedure saveOriginalDateFormat;
//begin
//    originalDateFormat := ShortDateFormat;
//    originalDateSeparator := DateSeparator;
//    DateSeparator := SAVE_DATE_SEPARATOR;
//    ShortDateFormat := SAVE_DATE_FORMAT;
//end;

//initialization
//    originalDateSeparator := #0;


end.
