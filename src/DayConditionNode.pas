unit DayConditionNode;

interface

uses
    Classes, DateUtils, StrUtils, SysUtils, Math,
    SeriesItem, SeriesItemCondition, SeriesCallback,
    DayConditionUtil;

const
    SERIES_DAY = 0;      // UseWeek 変数の意味: 日付条件
    SERIES_WEEK = 1;     // 週で条件
    SERIES_BIWEEK = 2;   // 隔週予定
    SERIES_REFER = 3;    // 他の周期予定の判断結果に依存
    SERIES_DAYCOUNT = 4; // 一定日数間隔


    HANDLING_HOLIDAY_NORMAL = 0;
    HANDLING_HOLIDAY_EXCLUDE = 1;
    HANDLING_HOLIDAY_NEXT = 2;
    HANDLING_DAYNAME_WITH_HOLIDAY_NEXT = 3;
    HANDLING_DAYNAME_WITHOUT_HOLIDAY_NEXT = 4;
    HANDLING_DAYNAME_WITHOUT_HOLIDAY_NEXT2 = 5;
    HANDLING_HOLIDAY_PREVIOUS = 6;
    HANDLING_DAYNAME_WITH_HOLIDAY_PREVIOUS = 7;
    HANDLING_DAYNAME_WITHOUT_HOLIDAY_PREVIOUS = 8;
    HANDLING_DAYNAME_WITHOUT_HOLIDAY_PREVIOUS2 = 9;

    WEEK_HANDLING_HOLIDAY_NORMAL = 0;
    WEEK_HANDLING_HOLIDAY_EXCLUDE = 1;
    WEEK_HANDLING_HOLIDAY_NEXT = 2;
    WEEK_HANDLING_HOLIDAY_NEXT_WEEKDAY = 3;
    WEEK_HANDLING_HOLIDAY_NEXT_WEEK = 4;
    WEEK_HANDLING_HOLIDAY_PREVIOUS = 5;
    WEEK_HANDLING_HOLIDAY_PREVIOUS_WEEKDAY = 6;
    WEEK_HANDLING_HOLIDAY_PREVIOUS_WEEK = 7;

    // 参照モードのときの HolidayHanlding
    // 0は祝日だろうと気にしない，1は祝日は該当曜日としてカウントしない，
    // 2は祝日なら該当曜日でなくてもカウントする
    REFER_HANDLING_HOLIDAY_IGNORE = 0;
    REFER_HANDLING_HOLIDAY_EXCLUDE_HOLIDAY = 1;
    REFER_HANDLING_HOLIDAY_INCLUDE_HOLIDAY = 2;


    FORMAT_DAY : array [0..9, 0..1] of string = (
        ('かつ', ''),
        ('かつ', '（祝日は除く）'),
        ('かつ', '（祝日なら翌日へずれる）'),
        ('以降で最初の', ''),
        ('以降で最初の', '（祝日なら翌日）'),
        ('以降で最初の', '（祝日なら次の%s曜日）'),
        ('かつ', '（祝日なら前日へずれる）'),
        ('以前の最後の', ''),
        ('以前の最後の', '（祝日なら前日）'),
        ('以前の最後の', '（祝日なら前の%s曜日）') );

    FORMAT_DAYCOUNT : array [0..9] of string = (
        '，かつ',
        '，かつ',
        '，かつ',
        'の該当日以降で最初の',
        'の該当日以降で最初の',
        'の該当日以降で最初の',
        '，かつ',
        'の該当日以前の最後の',
        'の該当日以前の最後の',
        'の該当日以前の最後の');

    FORMAT_WEEK: array [0..7] of string = (
        '', '祝日は除く', '祝日なら翌日にずれる',
        '祝日なら次の平日(月～金)にずれる',
        '祝日なら翌週にずれる',
        '祝日なら前日にずれる',
        '祝日なら前の平日(月～金)にずれる',
        '祝日なら前週にずれる');

    FORMAT_REFER: array [0..2] of string = (
        '', '(ただし祝日は数えない)', '(祝日は曜日無関係に数える)' );

    HOLIDAY_HANDLING_FOR_DAY: array [0..9] of string =
                  ( '指定日かつ指定曜日',
                    '指定日かつ指定曜日（祝日は除く）',
                    '指定日かつ指定曜日（祝日なら翌日へずれる）',
                    '指定日以降で最初の指定曜日',
                    '指定日以降で最初の指定曜日（祝日なら翌日）',
                    '指定日以降で最初の指定曜日（祝日なら次の指定曜日）',
                    '指定日かつ指定曜日（祝日なら前日へずれる）',
                    '指定日以前の最後の指定曜日',
                    '指定日以前の最後の指定曜日（祝日なら前日）',
                    '指定日以前の最後の指定曜日（祝日なら前の指定曜日）');
    HOLIDAY_HANDLING_FOR_WEEK: array [0..7] of string =
                  ( '指定曜日',
                    '指定曜日，祝日は除く',
                    '指定曜日，祝日なら翌日にずれる',
                    '指定曜日，祝日なら次の平日(月～金)にずれる',
                    '指定曜日，祝日なら翌週にずれる',
                    '指定曜日，祝日なら前日にずれる',
                    '指定曜日，祝日なら前の平日(月～金)にずれる',
                    '指定曜日，祝日なら前週にずれる');

    HOLIDAY_HANDLING_FOR_REFER: array [0..2] of string =
                  ( '指定曜日だけを数える',
                    '指定曜日から祝日を除外した日を数える',
                    '指定曜日と祝日を数える' );

    DAYCOUNTSTYLE_COUNT_SPECIFIC_YOUBI = 0;
    DAYCOUNTSTYLE_FILTER_YOUBI_AFTER_COUNT_ALL = 1;

type
    TDayConditionNode = class(TSeriesItemCondition)
    private
        FMonthCondition: TMonthMatchExpr;

        FYoubi: TYoubiCondition;

        FRangeStartEnabled, FRangeEndEnabled: boolean;
        FRangeStart, FRangeEnd: TDateTime;
        FHolidayHandling : integer;

        FIsExclusion: boolean; // "この日は除外" フラグ
        FUserDefinedHoliday: boolean; // ユーザ定義の休日も祝日扱いするか


        FUseWeek: Integer; // どの条件タイプを使うか

        // FUseWeek == SERIES_DAY の場合にのみ有効
        FDayCondition: TDayMatchExpr;

        // FUseWeek == SERIES_WEEK の場合に有効
        FWeekCondition: TWeekMatchExpr;

        // FUseWeek == SERIES_BIWEEK の場合に有効
        FBiweekBaseDate: TDateTime;             // 隔週基準日

        // FUseWeek == SERIES_REFER の場合に有効
        FReferItem: TSeriesItem;
        FReferItemDelta: Integer; // 日数の差分
        FReferItemID: integer; // FReferItem のリスト内 Index (ファイル読み書き時に一時的にセットされる)

        // FUseWeek == SERIES_DAY_COUNT の場合に有効
        FDayCount: integer;
        FDayCountBaseDate: TDateTime;
        FDayCountStyle: integer;

        // Callback 用変数群
        FContextIndex: integer;
        FContextCallback: TSeriesItemConditionCallback;
        function isHoliday(day: TDateTime): boolean;
        function isWeekday(day: TDateTime): boolean;

        // プロパティアクセス系
        procedure setMonthExpr(expr: string);
        procedure setDayExpr(expr: string);
        procedure setWeekExpr(expr: string);
        procedure setWeekCountMode(mode: integer);

        function getMonthExpr: string;
        function getDayExpr: string;
        function getWeekExpr: string;
        function getWeekCountMode: integer;

        procedure setYoubi(Index: integer; value: boolean);
        function  getYoubi(Index: integer): boolean;

        // マッチ処理
        function match_day(day: TDateTime): boolean;
        function match_day_without_holiday(day: TDateTime; increment: integer): boolean;
        function match_first_day_from_specified_day(day: TDateTime; increment: integer): boolean;
        function match_first_day_from_specified_day_without_holiday(day: TDateTime; increment: integer): boolean;
        function match_first_specified_youbi_from_specified_day_without_holiday(day: TDateTime; increment: integer): boolean;
        function match_week(day: TDateTime; biweek: boolean): boolean;
        function match_reference(day: TDateTime): boolean;
        function match_month_day(day: TDateTime): boolean;
        function match_daycount(day: TDateTime): boolean;

        // 文字列表現作成
        function getBiweekExprAsString: string;

        procedure setDayCountStyle(value: integer);

    protected
        function getStringRepresentation: string; override;

    public

        constructor Create;
        destructor Destroy; override;

        function getOwner: TSeriesItem;

        function match(day: TDateTime; callback: TSeriesItemConditionCallback; idx: integer): boolean; override;
        function isExclusion: boolean; override;

        property MonthExpr: string read getMonthExpr write setMonthExpr;
        property DayExpr: string read getDayExpr write setDayExpr;
        property WeekExpr: string read getWeekExpr write setWeekExpr;
        property WeekMode: integer read getWeekCountMode write setWeekCountMode;
        property UseWeek: Integer read FUseWeek write FUseWeek;

        property RangeStart: TDateTime read FRangeStart write FRangeStart;
        property RangeEnd:   TDateTime read FRangeEnd   write FRangeEnd;
        property RangeStartEnabled: boolean read FRangeStartEnabled write FRangeStartEnabled;
        property RangeEndEnabled:   boolean read FRangeEndEnabled   write FRangeEndEnabled;

        property BiweekBaseDate: TDateTime read FBiweekBaseDate write FBiweekBaseDate;

        property Exclusion: boolean read FIsExclusion write FIsExclusion;

        property UserDefinedHoliday: boolean read FUserDefinedHoliday write FUserDefinedHoliday;
        property HolidayHandling: integer read FHolidayHandling write FHolidayHandling;
        property Youbi[Index: integer]: boolean read getYoubi write setYoubi;

        property ReferItem: TSeriesItem read FReferItem write FReferItem;
        property ReferItemDelta: integer read FReferItemDelta write FReferItemDelta;
        property ReferItemID: integer read FReferItemID write FReferItemID;

        property DayCount: integer read FDayCount write FDayCount;
        property DayCountBaseDate: TDateTime read FDayCountBaseDate write FDayCountBaseDate;
        property DayCountStyle: integer read FDayCountStyle write setDayCountStyle;
    end;

implementation

uses
    DateFormat, StringSplitter, DateValidation;

const
    BLOCK_INFINITE_CHECK = 50;


function TDayConditionNode.isHoliday(day: TDateTime): boolean;
begin
  Assert(FContextCallback <> nil);
  Result := FContextCallback.isHoliday(day, FUserDefinedHoliday, FContextIndex);
end;

function TDayConditionNode.isWeekday(day: TDateTime): boolean;
begin
    Result := (DayOfTheWeek(day) <> DaySunday) and
              (DayOfTheWeek(day) <> daySaturday) and
              (not isHoliday(day));
end;

constructor TDayConditionNode.Create;
begin
    inherited Create;
    FMonthCondition := TMonthMatchExpr.Create;
    FDayCondition := TDayMatchExpr.Create;
    FWeekCondition := TWeekMatchExpr.Create;
    FYoubi := TYoubiCondition.Create;
    FUseWeek := 0;
    FMonthCondition.Expr := '';
    FDayCondition.Expr := '';
    FWeekCondition.Expr := '';
    FDisabled := false;
    FRangeStartEnabled := false;
    FRangeEndEnabled := false;
    FUserDefinedHoliday := false;
    FReferItem := nil;
    FReferItemDelta := 0;
end;

destructor TDayConditionNode.Destroy;
begin
  FMonthCondition.Free;
  FDayCondition.Free;
  FWeekCondition.Free;
  FYoubi.Free;
  inherited Destroy;
end;

procedure TDayConditionNode.setDayCountStyle(value: integer);
begin
  if (value = DAYCOUNTSTYLE_COUNT_SPECIFIC_YOUBI) or
     (value = DAYCOUNTSTYLE_FILTER_YOUBI_AFTER_COUNT_ALL) then
      FDayCountStyle := value
  else
      FDayCountStyle := DAYCOUNTSTYLE_FILTER_YOUBI_AFTER_COUNT_ALL;
end;

function TDayConditionNode.getWeekExpr: string;
begin
  Result := FWeekCondition.Expr;
end;

function TDayConditionNode.getWeekCountMode: integer;
begin
  Result := FWeekCondition.WeekCountMode;
end;

procedure TDayConditionNode.setWeekCountMode(mode: integer);
begin
  FWeekCondition.WeekCountMode := mode;
end;

function TDayConditionNode.getOwner: TSeriesItem;
begin
    Result := Owner as TSeriesItem;
end;

function TDayConditionNode.isExclusion: boolean;
begin
    Result := FIsExclusion;
end;

function TDayConditionNode.getMonthExpr: string;
begin
  Result := FMonthCondition.Expr;
end;

function TDayConditionNode.getDayExpr: string;
begin
  Result := FDayCondition.Expr;
end;

// 指定月かつ指定日
function TDayConditionNode.match_month_day(day: TDateTime): boolean;
begin
    if UseWeek <> SERIES_DAYCOUNT then
        Result := (FMonthCondition.match(day) and
                  FDayCondition.match(day))
    else // WeekMode = SERIES_DAYCOUNT
        Result := FMonthCondition.match(day) and
                  ((DaysBetween(day, FDayCountBaseDate) mod FDayCount) = 0);
end;

function TDayConditionNode.match_day_without_holiday(day: TDateTime; increment: integer): boolean;
// 指定日かつ指定曜日（祝日の場合は翌日へずれる）.
// この条件を満たすには，次のいずれかの条件を満たす．
//   - 指定日かつ指定曜日で，祝日でない．
//   - 祝日をたどっていくと，指定日かつ指定曜日であるような日に遭遇する．
var
    block: integer; // 際限ない戻りを防ぐ
begin
    Result := false;

    if not isHoliday(day) then begin
        if match_month_day(day) and FYoubi.match(day) then Result := true
        else begin
            day := incDay(day, increment);
            block := 0;
            while isHoliday(day) and (block < BLOCK_INFINITE_CHECK) do begin
                if match_month_day(day) and FYoubi.match(day) then begin
                    Result := true;
                    break;
                end;
                day := IncDay(day, increment);
                inc(block);
            end;
        end;
    end;

end;

function TDayConditionNode.match_first_day_from_specified_day(day: TDateTime; increment: integer): boolean;
// 指定日以降(以前)の，至近の指定された曜日にマッチする．
// 上記の条件を満たすには，
//   指定曜日で，かつ次の２条件のいずれかを満たす．
//    - 指定月日である．
//    - 前日方向にたどっていくと，指定曜日に遭遇せずに，指定月日までさかのぼれる．
begin
    Result := false;
    if FYoubi.match(day) then begin
        if match_month_day(day) and FYoubi.match(day) then Result := true
        else begin
            day := incDay(day, increment);
            while (not FYoubi.match(day)) do begin
                if match_month_day(day) then begin
                    Result := true;
                    break;
                end;
                day := IncDay(day, increment);
            end;
        end;
    end;
end;

function TDayConditionNode.match_first_specified_youbi_from_specified_day_without_holiday(day: TDateTime; increment: integer): boolean;
// 指定日以降(以前)の，至近の指定された曜日．祝日の場合は前か次の指定曜日へずれる
// 上記の条件を満たすのは，
// 1.  指定曜日かつ祝日でなく指定月日．
// 2.  指定曜日かつ祝日でなく，1.を満たす日まで指定曜日をさかのぼれる．
var
    block: integer;
begin
    Result := false;

    if not isHoliday(day) and FYoubi.match(day) then begin
        if match_month_day(day) then result := true
        else begin
            day := incDay(day, increment);
            block := 0;
            while (not FYoubi.match(day) or (isHoliday(day))) and (block < BLOCK_INFINITE_CHECK) do begin
                if match_month_day(day) then begin
                    Result := true;
                    break;
                end;
                day := IncDay(day, increment);
                inc(block);
            end;
        end;
    end;
end;

function TDayConditionNode.match_first_day_from_specified_day_without_holiday(day: TDateTime; increment: integer): boolean;
// 指定日以降(以前)の，至近の指定された曜日．祝日の場合は翌日 or 前日にずれる
// 上記の条件を満たすのは，次の三つの場合が考えられる．
// 1. 指定曜日かつ指定月日であり，かつ祝日でない．
// 2. 指定曜日かつ祝日でなく，Reachable である．
// 3. 指定曜日ではく祝日でもなく，「指定曜日まで祝日だけである」かつ，その指定曜日が reachable である．
// Reachable = その日から「指定曜日に遭遇することなく指定月日までたどりつける」または「指定月日までが祝日だけである」
var
    all_days_are_holiday: boolean;
    block: integer;

    function reachable(day: TDateTime): boolean;
    begin
        Result := false;
        day := incDay(day, increment);
        all_days_are_holiday := all_days_are_holiday and isHoliday(day);
        block := 0;
        while (not FYoubi.match(day) or all_days_are_holiday) and (block < BLOCK_INFINITE_CHECK) do begin
            if match_month_day(day) then begin
                Result := true;
                break;
            end;
            day := incDay(day, increment);
            inc(block);
            all_days_are_holiday := all_days_are_holiday and isHoliday(day);
        end;
    end;


begin
    Result := false;
    if not isHoliday(day) then begin
        if match_month_day(day) and FYoubi.match(day) then result := true
        else begin
            if FYoubi.match(day) then result := reachable(day)
            else begin
                day := incDay(day, increment);
                all_days_are_holiday := isHoliday(day);
                block := 0;
                while (not FYoubi.match(day) and all_days_are_holiday) do begin
                    all_days_are_holiday := all_days_are_holiday and isHoliday(day);
                    inc(block);
                    day := incDay(day, increment);
                end;
                Result := reachable(day) and isHoliday(day);
            end;
        end;
    end;

end;


function TDayConditionNode.match_day(day: TDateTime): boolean;
var
    increment : integer;

begin // match_day body

    Result := false;

    case HolidayHandling of
    HANDLING_HOLIDAY_NORMAL: begin
            // 指定日かつ指定曜日
            Result := match_month_day(day) and FYoubi.match(day);
        end;
    HANDLING_HOLIDAY_EXCLUDE: begin
            // 指定日かつ指定曜日（祝日は除く）
            Result := match_month_day(day)
                      and FYoubi.match(day)
                      and (not isHoliday(day));
        end;
    HANDLING_HOLIDAY_NEXT, HANDLING_HOLIDAY_PREVIOUS: begin
            increment := ifThen(HolidayHandling = HANDLING_HOLIDAY_NEXT, -1, 1);
            Result := match_day_without_holiday(day, increment);
        end;
    HANDLING_DAYNAME_WITH_HOLIDAY_NEXT, HANDLING_DAYNAME_WITH_HOLIDAY_PREVIOUS: begin
           increment := ifThen(HolidayHandling = HANDLING_DAYNAME_WITH_HOLIDAY_NEXT, -1, 1);
             Result := match_first_day_from_specified_day(day, increment);
        end;
    HANDLING_DAYNAME_WITHOUT_HOLIDAY_NEXT, HANDLING_DAYNAME_WITHOUT_HOLIDAY_PREVIOUS: begin

            increment := ifThen(HolidayHandling = HANDLING_DAYNAME_WITHOUT_HOLIDAY_NEXT, -1, 1);
            Result := match_first_day_from_specified_day_without_holiday(day, increment);

        end;
    HANDLING_DAYNAME_WITHOUT_HOLIDAY_NEXT2, HANDLING_DAYNAME_WITHOUT_HOLIDAY_PREVIOUS2: begin
            increment := ifThen(HolidayHandling = HANDLING_DAYNAME_WITHOUT_HOLIDAY_NEXT2, -1, 1);
            Result := match_first_specified_youbi_from_specified_day_without_holiday(day, increment);
        end;
    end
end;

function TDayConditionNode.match_week(day: TDateTime; biweek: boolean): boolean;
var
    increment : integer;
    block: integer;

    function match_week_internal(day: TDateTime): boolean;
    begin
        Result := FMonthCondition.match(day) and
                  ((not biweek and FWeekCondition.match(day)) or
                   ( biweek and
                     (day >= FBiweekBaseDate) and
                     ((WeeksBetween(day, FBiweekBaseDate) mod 2) = 0)));
    end;
begin
    Result := false;

    case HolidayHandling of
    WEEK_HANDLING_HOLIDAY_NORMAL:
        Result := match_week_internal(day)
                  and FYoubi.match(day);
    WEEK_HANDLING_HOLIDAY_EXCLUDE:
        Result := match_week_internal(day)
                  and FYoubi.match(day)
                  and not isHoliday(day);
    WEEK_HANDLING_HOLIDAY_NEXT, WEEK_HANDLING_HOLIDAY_PREVIOUS: begin
        // 祝日なら翌日へずれる
            if match_week_internal(day)
                  and FYoubi.match(day)
                  and not isHoliday(day) then
                Result := true
            else if isHoliday(day) then
                Result := false
            else begin
                increment := IfThen(HolidayHandling = WEEK_HANDLING_HOLIDAY_NEXT, -1, 1);
                block:=0;
                day := IncDay(day, increment);
                while isHoliday(day) and (block < BLOCK_INFINITE_CHECK) do begin
                    if match_week_internal(day) and FYoubi.match(day) then begin
                        Result := true;
                        break;
                    end;
                    day := IncDay(day, increment);
                    inc(block);
                end;
            end;
        end;
    WEEK_HANDLING_HOLIDAY_NEXT_WEEKDAY, WEEK_HANDLING_HOLIDAY_PREVIOUS_WEEKDAY: begin
        // 祝日なら次の平日(土日祝を除いた日）へずれる
            if match_week_internal(day)
                  and FYoubi.match(day)
                  and not isHoliday(day) then
                Result := true
            else if isHoliday(day) or not isWeekday(day) then
                Result := false
            else begin
                increment := IfThen(HolidayHandling = WEEK_HANDLING_HOLIDAY_NEXT_WEEKDAY, -1, 1);
                block:=0;
                day := IncDay(day, increment);
                while (isHoliday(day) or not isWeekday(day)) and (block < BLOCK_INFINITE_CHECK) do begin
                    if match_week_internal(day) and FYoubi.match(day) and isHoliday(day) then begin
                        Result := true;
                        break;
                    end;
                    day := IncDay(day, increment);
                    inc(block);
                end;
            end;
        end;
    WEEK_HANDLING_HOLIDAY_NEXT_WEEK, WEEK_HANDLING_HOLIDAY_PREVIOUS_WEEK: begin
        // 祝日なら次の週にずれる
            if match_week_internal(day)
               and FYoubi.match(day)
               and not isHoliday(day) then Result := true
            else if FYoubi.match(day) and not isHoliday(day) then begin
                increment := IfThen(HolidayHandling = WEEK_HANDLING_HOLIDAY_NEXT_WEEK, -7, 7);
                block:=0;
                day := IncDay(day, increment);
                while isHoliday(day) and (block < BLOCK_INFINITE_CHECK) do begin
                    if match_week_internal(day) and FYoubi.match(day) then begin
                        Result := true;
                        break;
                    end;
                    day := IncDay(day, increment);
                    inc(block);
                end;
            end;
        end;
    end;

end;

function TDayConditionNode.match_reference(day: TDateTime): boolean;
var
    delta: integer;
    max_delta: integer;
    count: integer;
begin
    Result := false;

    if (FReferItem = nil)  then begin
        exit;
    end;

    // delta が "0" すなわち同じ日なら，FReferItem.match だけをチェックする
    if FReferItemDelta = 0 then begin
        // 祝日であっても無関係な場合 は 指定曜日のとき,
        // 祝日は数えない指定のときは   指定曜日かつ祝日でない日,
        // 祝日を数える指定のときは，指定曜日かつ，祝日である場合,
      Result := (
                  ( (FHolidayHandling = REFER_HANDLING_HOLIDAY_IGNORE)and
                    FYoubi.match(day)
                  ) or

                  ( (FHolidayHandling = REFER_HANDLING_HOLIDAY_EXCLUDE_HOLIDAY) and
                    FYoubi.match(day) and
                    not isHoliday(day)
                  ) or
                  (
                   (FHolidayHandling = REFER_HANDLING_HOLIDAY_INCLUDE_HOLIDAY) and
                   (FYoubi.match(day) or
                    isHoliday(day)
                   )
                  )
                ) and FContextCallback.isMatched(day, FReferItem); //FReferItem.match(day, FContextCallback, FContextIndex);
      exit;
    end;


    // "3日前" の指定なら，3日後が FReferItem.match していることをチェックする
    delta := IfThen(FReferItemDelta > 0, -1, 1);
    max_delta := IfThen(FReferItemDelta > 0, FReferItemDelta, -FReferItemDelta);
    count := 0;
    while (count < max_delta + 1) do begin
        // 祝日であっても無関係な場合 は 指定曜日のとき
        // 祝日は数えない指定のときは   指定曜日かつ祝日でない日
        // 祝日を数える指定のときは，指定曜日かつ，祝日である場合
        // の場合，日数をカウントする
        if ( ((FHolidayHandling = REFER_HANDLING_HOLIDAY_IGNORE)and
              FYoubi.match(day)) or
             ((FHolidayHandling = REFER_HANDLING_HOLIDAY_EXCLUDE_HOLIDAY) and
              FYoubi.match(day) and
              not isHoliday(day)
             ) or
             ((FHolidayHandling = REFER_HANDLING_HOLIDAY_INCLUDE_HOLIDAY) and
               (FYoubi.match(day) or
               isHoliday(day))
             )
           ) then begin
            inc(count);
        end;
        // ここで count = 0 である（day で最初に与えられた日自体が曜日的に該当しない）場合は終了
        if (count = 0) then begin
            result := false;
            break;
        end;
        day := IncDay(day, delta);
        if not isValid(day) then break;

        // 必要な日数が数え終えられている状態の間，マッチ処理を実行
        if count = max_delta then begin
            if FContextCallback.isMatched(day, FReferItem) then begin
                Result := true;
                break;
            end;
        end;
    end;
end;

function TDayConditionNode.match(day: TDateTime; callback: TSeriesItemConditionCallback; idx: integer): boolean;
var
    r: boolean;
begin
    // 自分が何番目の周期予定かの Index 値を保存
    // この値より小さい周期予定の影響だけを受ける
    FContextIndex := idx;
    FContextCallback := callback;


    r := (not FRangeStartEnabled or (FRangeStart <= day)) and
         (not FRangeEndEnabled   or (day <= FRangeEnd));
    if UseWeek = SERIES_WEEK then begin
        r := r and match_week(day, false);
    end else if UseWeek = SERIES_DAY then begin
        r := r and match_day(day);
    end else if UseWeek = SERIES_BIWEEK then begin
        r := r and match_week(day, true);
    end else if UseWeek = SERIES_DAYCOUNT then begin
        r := r and match_daycount(day);
    end else if UseWeek = SERIES_REFER then begin
        r := r and match_reference(day);
    end else begin     // 無効な条件が存在した場合，マッチさせない
        r := false;
    end;

    Result := r;

    // コンテキスト値を破棄
    FContextIndex := 0;
    FContextCallback := nil;
end;

function TDayConditionNode.match_daycount(day: TDateTime): boolean;

    function isCountTarget(day: TDateTime): boolean;
    begin
        Result := ((FHolidayHandling = REFER_HANDLING_HOLIDAY_IGNORE) and
                        FYoubi.match(day)) or
                  ((FHolidayHandling = REFER_HANDLING_HOLIDAY_EXCLUDE_HOLIDAY) and
                        FYoubi.match(day) and not isHoliday(day)) or
                  ((FHolidayHandling = REFER_HANDLING_HOLIDAY_INCLUDE_HOLIDAY) and
                        (FYoubi.match(day) or isHoliday(day)));
    end;

    function CountDays(day: TDateTime): integer;
    var
        d1, d2: TDateTime;
        count: integer;
    begin
        if day < FDayCountBaseDate then begin
            d1 := day;
            d2 := FDayCountBaseDate-1;
        end else begin
            d1 := FDayCountBaseDate+1;
            d2 := day;
        end;
        count := 0;
        while d1 <= d2 do begin
            if isCountTarget(d1) then inc(count);
            d1 := IncDay(d1, 1);
        end;
        Result := count;
    end;

begin
    if FDayCountStyle = DAYCOUNTSTYLE_COUNT_SPECIFIC_YOUBI then begin
        // 1.6.0: カウント対象を限定する
        Result := (day = FDayCountBaseDate) or
                  (isCountTarget(day) and ((CountDays(day) mod FDayCount) = 0));
    end else begin
        // そうでない場合は素直に従来の実装を利用
        Result := match_day(day);
    end;
end;

procedure TDayConditionNode.setYoubi(Index: integer; value: boolean);
begin
  FYoubi[Index] := value;
end;

function TDayConditionNode.getYoubi(Index: integer): boolean;
begin
  Result := FYoubi[Index];
end;

procedure TDayConditionNode.setMonthExpr(expr: string);
begin
  FMonthCondition.Expr := expr;
end;

procedure TDayConditionNode.setDayExpr(expr: string);
begin
  FDayCondition.Expr := expr;
end;

procedure TDayConditionNode.setWeekExpr(expr: string);
begin
  FWeekCondition.Expr := expr;
end;


function TDayConditionNode.getBiweekExprAsString: string;
var
    s: string;
begin
    s := FYoubi.toString;
    if s <> '' then s := s + '曜';
    s := DateFormat.unparseDate(FBiweekBaseDate) + 'からの隔週 ' + s;
    Result := s;
end;

function TDayConditionNode.getStringRepresentation: string;
var
    s: string;
    y: string;
    head_s : string;
const
    USER_DEFINED_HOLIDAY_INCLUDED = ' [ユーザー定義の祝日を含む]';
    EXCLUSION_OPTION = '*除外対象* ';

    // ユーザ定義の祝日を含むかどうかの文字列を返す
    // "祝日の場合は…" と書いてる条件が設定されているときのみ有効
    function getUserDefinedHoliday: string;
    begin
        if (FUseWeek = SERIES_DAY) or (FUseWeek = SERIES_DAYCOUNT) then begin
            if UserDefinedHoliday and (AnsiPos('祝日', FORMAT_DAY[HolidayHandling, 1]) > 0) then
                Result := USER_DEFINED_HOLIDAY_INCLUDED
            else
                Result := '';
        end else begin
            if UserDefinedHoliday and (AnsiPos('祝日', FORMAT_WEEK[HolidayHandling]) > 0) then
                Result := USER_DEFINED_HOLIDAY_INCLUDED
            else
                Result := '';
        end;
    end;

    function isSpecificYear: boolean;
    var
        y1, m1, d1: Word;
        y2, m2, d2: Word;
    begin
        DecodeDate(FRangeStart, y1, m1, d1);
        DecodeDate(FRangeEnd,   y2, m2, d2);
        Result := FRangeStartEnabled and (m1 = 1) and (d1 = 1) and
                  FRangeEndEnabled and (y1 = y2) and (m2 = 12) and (d2 = 31);
    end;

    function getCountTargetYoubi: string;
    var
        s : string;
    begin
        s := FYoubi.toString;
        if s <> '' then s := ' カウント対象: ' + s + '曜日';
        s := s + FORMAT_REFER[HolidayHandling];
        s := s + getUserDefinedHoliday;
        Result := s;
    end;


begin
    s := FMonthCondition.toString;

    if isSpecificYear then s := IntToStr(YearOf(FRangeStart)) + '年 ' + s;
    if isExclusion then head_s := EXCLUSION_OPTION
    else head_s := '';

    if UseWeek = SERIES_WEEK then begin
        s := s + FWeekCondition.toString(FYoubi);

        s := s + ' ' + FORMAT_WEEK[HolidayHandling];

        s := s + getUserDefinedHoliday;

    end else if UseWeek = SERIES_BIWEEK then begin
        s := s + getBiweekExprAsString + getUserDefinedHoliday;
    end else if UseWeek = SERIES_REFER then begin
        if FReferItem <> nil then begin
            s := s + '予定 "' + FReferItem.Name + '"';

            if FReferItemDelta < 0 then
                s := s + 'から' + IntToStr(-FReferItemDelta) + '日前'
            else if FReferItemDelta > 0 then
                s := s + 'から' + IntToStr(FReferItemDelta) + '日後'
            else
                s := s + 'の日';

            s := s + getCountTargetYoubi;
        end else begin
            s := s + '(参照アイテムが指定されていません)';
        end;

    end else if UseWeek = SERIES_DAYCOUNT then begin
        if FDayCount > 1 then begin
            s := s + DateFormat.unparseDate(FDayCountBaseDate) + 'を基準に'
                 + IntToStr(FDayCount) + '日に１日';
        end else begin
            s := s + '毎日';
        end;
        if FDayCountStyle = DAYCOUNTSTYLE_COUNT_SPECIFIC_YOUBI then begin
            s := s + getCountTargetYoubi;
        end else begin
            if FYoubi.Enabled then begin
                s := s + FORMAT_DAYCOUNT[HolidayHandling];
                y := FYoubi.toString;
                if y <> '' then s := s + y + '曜日';
            end;
            // 祝日の記述部分は Day のと共用
            s := s + Format(FORMAT_DAY[HolidayHandling, 1], [FYoubi.toString]);
            s := s + getUserDefinedHoliday;
        end;


    end else if UseWeek = SERIES_DAY then begin
        s := s + FDayCondition.toString;

        if FYoubi.Enabled then begin
            if (s <> '') then s := s + FORMAT_DAY[HolidayHandling, 0];

            y := FYoubi.toString;
            if y <> '' then s := s + y + '曜日';
        end;
        s := s + Format(FORMAT_DAY[HolidayHandling, 1], [FYoubi.toString]);

        s := s + getUserDefinedHoliday;
    end else begin
        s := '(文字列表現が未実装の予定)';
    end;

    if not isSpecificYear and RangeStartEnabled then begin
        if s <> '' then s := s + ' ';
        s := s + FormatDateTime(ShortDateFormat, RangeStart) + ' から';
    end;
    if not isSpecificYear and RangeEndEnabled then begin
        if s <> '' then s := s + ' ';
        s := s + FormatDateTime(ShortDateFormat, RangeEnd) + ' まで';
    end;

    if s = '' then begin
        s := IfThen(isExclusion, EXCLUSION_OPTION, '') + '毎日(無条件)';
    end;

    s := head_s + s;
    Result := s;
end;


end.
