unit DayConditionUtil;

interface

uses
  DateUtils, SysUtils,
  StringSplitter;

type
    TMonthMatchExpr = class
    private
      FExpr: string;
      FMonth: array [0..12] of boolean;  // 0 ÇÕñ¢égópÅiì‡ïîìIÇ…ÅCàµÇ¢ÇDay, Week Ç∆Ç†ÇÌÇπÇÈÇΩÇﬂÅj
      procedure setExpr(expr: string);
    public
      constructor Create;
      function match(day: TDateTime): boolean;
      function toString: string;
      property Expr: string read FExpr write setExpr;
    end;

    TDayMatchExpr = class
    private
      FExpr: string;
      FDay: array [0..31] of boolean; // 0 ÇÕÅuññì˙ÅvÇà”ñ°Ç∑ÇÈ
      procedure setExpr(expr: string);
    public
      constructor Create;
      function match(day: TDateTime): boolean;
      function toString: string;
      property Expr: string read FExpr write setExpr;
    end;

    TYoubiCondition = class
    private
      FYoubi: array [1..7] of boolean;         // ójì˙
      FYoubiEnable: boolean;
      procedure setYoubi(Index: integer; value: boolean);
      function getYoubi(Index: integer): boolean;

    public
      constructor Create;
      function match(day: TDateTime): boolean;
      function toString: string;
      property Enabled: boolean read FYoubiEnable;
      property Youbi[Index: integer]: boolean read getYoubi write setYoubi; default;
    end;

    TWeekMatchExpr = class
    private
      FExpr: string;
      FWeek: array[0..6] of boolean; // ëÊÇPÅ`ÇUèTÅ{ç≈èIèT
      FWeekCountMode: integer;

      procedure setExpr(expr: string);
    public
      constructor Create;
      function match(day: TDateTime): boolean;
      function toString(youbi_condition: TYoubiCondition): string;
      property WeekCountMode: integer read FWeekCountMode write FWeekCountMode;
      property Expr: string read FExpr write setExpr;
    end;

    procedure parseExpr(expr: string; var ar: array of boolean);

const
    WEEKMODE_NthDay = 0;
    WEEKMODE_ISO8601 = 1;


implementation

const
  IDX_END_OF_MONTH = 0;



//--------------------------------------------------------------
// åéÇÃèåèéÆ
//--------------------------------------------------------------
constructor TMonthMatchExpr.Create;
var
  i: integer;
begin
  for i:=0 to 12 do FMonth[i] := false;
end;

procedure TMonthMatchExpr.setExpr(expr: string);
begin
  parseExpr(expr, FMonth);
  FExpr := expr;
end;

function TMonthMatchExpr.match(day: TDateTime): boolean;
begin
    if (FExpr <> '') then Result := FMonth[MonthOf(day)]
    else Result := true;
end;

function TMonthMatchExpr.toString: string;
var
    s: string;
    i: integer;
    start: integer;
    all_true: boolean;
begin
    if FExpr = '' then Result := ''
    else begin
        s := '';
        i := 1;
        all_true := true;
        start := 0;
        while i <= 12 do begin
            if FMonth[i] then begin
                if start = 0 then start := i;
            end else begin
                all_true := false;
                if start > 0 then begin
                    if s <> '' then s := s + ', ';
                    if start = i - 1 then s := s + IntToStr(start)
                    else s := s + IntToStr(start) + 'Å`' + IntToStr(i-1);
                    start := 0;
                end;
            end;
            inc(i);
        end;

        if all_true then begin
            Result := '';
        end else begin
            if FMonth[12] then begin
                if s <> '' then s := s + ', ';
                if start = 12 then s := s + IntToStr(start)
                else s := s + IntToStr(start) + 'Å`' + IntToStr(12);
            end;

            if s <> '' then s := s + 'åé  ';
            Result := s;
        end;
    end;
end;

//--------------------------------------------------------------
// ì˙ïtÇÃèåèéÆ
//--------------------------------------------------------------
constructor TDayMatchExpr.Create;
var
  i: integer;
begin
  for i:=0 to 31 do FDay[i] := false;
end;

procedure TDayMatchExpr.setExpr(expr: string);
begin
  parseExpr(expr, FDay);
  FExpr := expr;
end;

function TDayMatchExpr.match(day: TDateTime): boolean;
begin
    Result := ((FExpr = '' ) or
                FDay[DayOf(day)] or
               (FDay[IDX_END_OF_MONTH] and (IsSameDay(day, EndOfTheMonth(day)))));
end;

function TDayMatchExpr.toString: string;
var
    s: string;
    i: integer;
    start: integer;
begin
    if FExpr = '' then Result := ''
    else begin
        s := '';
        i := 1;
        start := 0;
        while i <= 31 do begin
            if FDay[i] then begin
                if start = 0 then start := i;
            end else begin
                if start > 0 then begin
                    if s <> '' then s := s + ', ';
                    if start = i - 1 then s := s + IntToStr(start)
                    else s := s + IntToStr(start) + 'Å`' + IntToStr(i-1);
                    start := 0;
                end;
            end;
            inc(i);
        end;
        if FDay[31] then begin
            if s <> '' then s := s + ', ';
            if start = 31 then s := s + IntToStr(start)
            else s := s + IntToStr(start) + 'Å`' + IntToStr(31);
        end;

        if s <> '' then s := s + 'ì˙';
        if FDay[IDX_END_OF_MONTH] then begin
            if s <> '' then s := s + ', ';
            s := s + 'ññì˙';
        end;
        if s <> '' then s:= s + '  ';
        Result := s;
    end;
end;

//--------------------------------------------------------------
// ójì˙ÇÃèåè
//--------------------------------------------------------------
constructor TYoubiCondition.Create;
var
  i: integer;
begin
  for i:=1 to 7 do FYoubi[i] := false;
  FYoubiEnable := false;
end;

function TYoubiCondition.match(day: TDateTime): boolean;
begin
  Result := not FYoubiEnable or FYoubi[DayOfWeek(day)];
end;

procedure TYoubiCondition.setYoubi(Index: integer; value: boolean);
var
    i: integer;
    b: boolean;
begin
    FYoubi[Index] := value;
    if value then FYoubiEnable := true
    else begin
        b := false;
        for i:=1 to 7 do b := b or FYoubi[i];
        FYoubiEnable := b;
    end;
end;

function TYoubiCondition.getYoubi(Index: integer): boolean;
begin
    Result := FYoubi[Index];
end;

function TYoubiCondition.toString: string;
var
    s: string;
    i, start: integer;
    all_true: boolean;
begin
    s := '';
    all_true := true;
    start := 0;
    i := 1;
    while i <= 7 do begin
        if FYoubi[i] then begin
            if (start = 0)and(i<7) then start := i
            else if (start = 0)and(i=7) then begin
                if s <> '' then s := s + ', ';
                s := s + ShortDayNames[i]; // ç≈å„ÇÃÇ∆Ç´ÇæÇØÇÕì¡ï àµÇ¢
            end
        end else begin
            all_true := false;
            if start > 0 then begin
                if s <> '' then s := s + ', '; // ãÊêÿÇË "," í«â¡
                // ÇRì˙à»è„òAë±ÇÃÇ∆Ç´ÇÃÇ› "Å`" Ç≈Ç¬Ç»ÇÆÅ@
                if start = i - 1 then s := s + ShortDayNames[start]
                else if start = i - 2 then s := s + ShortDayNames[start] + ', ' + ShortDayNames[start+1]
                else s := s + ShortDayNames[start] + 'Å`' + ShortDayNames[i-1];
                start := 0;
            end;
        end;
        inc(i);
    end;
    if all_true then s := '';

    Result := s;
end;

//--------------------------------------------------------------
// èTÇÃèåèéÆ
//--------------------------------------------------------------
constructor TWeekMatchExpr.Create;
var
  i: integer;
begin
  for i:=0 to 6 do FWeek[i] := false;
end;

procedure TWeekMatchExpr.setExpr(expr: string);
begin
  parseExpr(expr, FWeek);
  FExpr := expr;
end;

function TWeekMatchExpr.match(day: TDateTime): boolean;
var
  year, month1, month2, week: Word;
begin
  Result := false;

  case FWeekCountMode of
  WEEKMODE_NthDay:
    Result := (FExpr = '') or
              FWeek[NthDayOfWeek(day)] or
              (FWeek[0] and
               (MonthOf(day) <> MonthOf(IncDay(day, 7))));
  WEEKMODE_ISO8601:
    begin
      week := WeekOfTheMonth(day, year, month1);
      if (FExpr <> '')  then begin
        if FWeek[week] then Result := true
        else if FWeek[0] and (month1 = MonthOf(day)) then begin
          WeekOfTheMonth(IncDay(day, 7), year, month2);
          Result := month1 <> month2;
        end;
      end;
    end;
  end;
end;

function TWeekMatchExpr.toString(youbi_condition: TYoubiCondition): string;
var
    s: string;
    i: integer;
    all_true: boolean;
    youbi: string;
begin
    youbi := youbi_condition.toString;
    s := '';
    if FExpr <> '' then begin
        s := '';
        all_true := true;
        for i:=1 to 5 do begin
            all_true := all_true and FWeek[i];
            if FWeek[i] then begin
                if s <> '' then s := s + ', ';
                s := s + IntToStr(i);
            end;
        end;
        if all_true then s := '';

        if WeekCountMode = WEEKMODE_NthDay then begin
            if s <> '' then s := 'ëÊ' + s;
            if FWeek[0] then begin
                if s <> '' then s := s + ', ç≈èI'
                else s := 'ç≈èI';
            end;
            if s <> '' then s := s + '  ';
            if youbi <> '' then s := s + youbi + 'ój'
            else s := s + 'åéÅ`ì˙ój';
        end else begin
            if s <> '' then s := 'ëÊ' + s + 'èT';
            if FWeek[0] then begin
                if s <> '' then s := s + ', ç≈èIèT'
                else s := 'ç≈èIèT';
            end;
            if s <> '' then s := s + '  ';
            if youbi <> '' then s := s + youbi + 'ój';
        end;
    end else begin
        s := youbi;
        if s <> '' then s := s + 'ój';
    end;
    Result := s;
end;

//--------------------------------------------------------------
// ã§í ä÷êî
//--------------------------------------------------------------
procedure parseExpr(expr: string; var ar: array of boolean);
var
    i: integer;
    value: integer;
    valid: boolean;
    low_index, high_index: integer;
    tokenizer: TStringSplitter;
    s: string;
    idx : integer;

    function eval(t: string; var num: integer): boolean;
    begin
        try
            t := Trim(t);
            if t = 'z' then begin
                num := 0;
                Result := true;
                exit;
            end;
            num := StrToInt(t);
            Result := (Low(ar) < num) and (num <= High(ar));
        except
            Result := false;
        end;
    end;

begin
    for i:=Low(ar) to High(ar) do begin
        ar[i] := false;
    end;

    low_index := 0;
    high_index := 0;

    expr := Trim(expr);
    tokenizer := TStringSplitter.Create(',');
    tokenizer.setString(expr);
    while tokenizer.hasNext do begin
        s := Trim(tokenizer.getLine);
        idx := AnsiPos('-', s);
        if idx > 0 then begin

            if idx = 1 then begin
                low_index := 1; //Low(ar) + 1;
                valid := true;
            end else begin
                valid := eval(Copy(s, 1, idx-1), value);
                if valid then low_index := value;
            end;

            if valid then begin

                if idx = Length(s) then begin
                    high_index := High(ar);
                    valid := true;
                end else begin
                    valid := eval(Copy(s, idx+1, Length(s)), value);
                    if valid then high_index := value;
                end;

                if valid then begin
                    for i:=low_index to high_index do begin
                        if (1 <= i) and (i <= High(ar)) then begin
                            ar[i] := true;
                        end;
                    end;
                end;
            end;
        end else begin
            valid := eval(s, value);
            if valid then begin
                if (Low(ar) <= value) and (value <= High(ar)) then
                    ar[value] := true;
            end;
        end;
    end;
    tokenizer.Free;
end;

end.
