unit DayConditionNode;

interface

uses
    Classes, DateUtils, StrUtils, SysUtils, Math,
    SeriesItem, SeriesItemCondition, SeriesCallback,
    DayConditionUtil;

const
    SERIES_DAY = 0;      // UseWeek �ϐ��̈Ӗ�: ���t����
    SERIES_WEEK = 1;     // �T�ŏ���
    SERIES_BIWEEK = 2;   // �u�T�\��
    SERIES_REFER = 3;    // ���̎����\��̔��f���ʂɈˑ�
    SERIES_DAYCOUNT = 4; // �������Ԋu


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

    // �Q�ƃ��[�h�̂Ƃ��� HolidayHanlding
    // 0�͏j�����낤�ƋC�ɂ��Ȃ��C1�͏j���͊Y���j���Ƃ��ăJ�E���g���Ȃ��C
    // 2�͏j���Ȃ�Y���j���łȂ��Ă��J�E���g����
    REFER_HANDLING_HOLIDAY_IGNORE = 0;
    REFER_HANDLING_HOLIDAY_EXCLUDE_HOLIDAY = 1;
    REFER_HANDLING_HOLIDAY_INCLUDE_HOLIDAY = 2;


    FORMAT_DAY : array [0..9, 0..1] of string = (
        ('����', ''),
        ('����', '�i�j���͏����j'),
        ('����', '�i�j���Ȃ痂���ւ����j'),
        ('�ȍ~�ōŏ���', ''),
        ('�ȍ~�ōŏ���', '�i�j���Ȃ痂���j'),
        ('�ȍ~�ōŏ���', '�i�j���Ȃ玟��%s�j���j'),
        ('����', '�i�j���Ȃ�O���ւ����j'),
        ('�ȑO�̍Ō��', ''),
        ('�ȑO�̍Ō��', '�i�j���Ȃ�O���j'),
        ('�ȑO�̍Ō��', '�i�j���Ȃ�O��%s�j���j') );

    FORMAT_DAYCOUNT : array [0..9] of string = (
        '�C����',
        '�C����',
        '�C����',
        '�̊Y�����ȍ~�ōŏ���',
        '�̊Y�����ȍ~�ōŏ���',
        '�̊Y�����ȍ~�ōŏ���',
        '�C����',
        '�̊Y�����ȑO�̍Ō��',
        '�̊Y�����ȑO�̍Ō��',
        '�̊Y�����ȑO�̍Ō��');

    FORMAT_WEEK: array [0..7] of string = (
        '', '�j���͏���', '�j���Ȃ痂���ɂ����',
        '�j���Ȃ玟�̕���(���`��)�ɂ����',
        '�j���Ȃ痂�T�ɂ����',
        '�j���Ȃ�O���ɂ����',
        '�j���Ȃ�O�̕���(���`��)�ɂ����',
        '�j���Ȃ�O�T�ɂ����');

    FORMAT_REFER: array [0..2] of string = (
        '', '(�������j���͐����Ȃ�)', '(�j���͗j�����֌W�ɐ�����)' );

    HOLIDAY_HANDLING_FOR_DAY: array [0..9] of string =
                  ( '�w������w��j��',
                    '�w������w��j���i�j���͏����j',
                    '�w������w��j���i�j���Ȃ痂���ւ����j',
                    '�w����ȍ~�ōŏ��̎w��j��',
                    '�w����ȍ~�ōŏ��̎w��j���i�j���Ȃ痂���j',
                    '�w����ȍ~�ōŏ��̎w��j���i�j���Ȃ玟�̎w��j���j',
                    '�w������w��j���i�j���Ȃ�O���ւ����j',
                    '�w����ȑO�̍Ō�̎w��j��',
                    '�w����ȑO�̍Ō�̎w��j���i�j���Ȃ�O���j',
                    '�w����ȑO�̍Ō�̎w��j���i�j���Ȃ�O�̎w��j���j');
    HOLIDAY_HANDLING_FOR_WEEK: array [0..7] of string =
                  ( '�w��j��',
                    '�w��j���C�j���͏���',
                    '�w��j���C�j���Ȃ痂���ɂ����',
                    '�w��j���C�j���Ȃ玟�̕���(���`��)�ɂ����',
                    '�w��j���C�j���Ȃ痂�T�ɂ����',
                    '�w��j���C�j���Ȃ�O���ɂ����',
                    '�w��j���C�j���Ȃ�O�̕���(���`��)�ɂ����',
                    '�w��j���C�j���Ȃ�O�T�ɂ����');

    HOLIDAY_HANDLING_FOR_REFER: array [0..2] of string =
                  ( '�w��j�������𐔂���',
                    '�w��j������j�������O�������𐔂���',
                    '�w��j���Əj���𐔂���' );

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

        FIsExclusion: boolean; // "���̓��͏��O" �t���O
        FUserDefinedHoliday: boolean; // ���[�U��`�̋x�����j���������邩


        FUseWeek: Integer; // �ǂ̏����^�C�v���g����

        // FUseWeek == SERIES_DAY �̏ꍇ�ɂ̂ݗL��
        FDayCondition: TDayMatchExpr;

        // FUseWeek == SERIES_WEEK �̏ꍇ�ɗL��
        FWeekCondition: TWeekMatchExpr;

        // FUseWeek == SERIES_BIWEEK �̏ꍇ�ɗL��
        FBiweekBaseDate: TDateTime;             // �u�T���

        // FUseWeek == SERIES_REFER �̏ꍇ�ɗL��
        FReferItem: TSeriesItem;
        FReferItemDelta: Integer; // �����̍���
        FReferItemID: integer; // FReferItem �̃��X�g�� Index (�t�@�C���ǂݏ������Ɉꎞ�I�ɃZ�b�g�����)

        // FUseWeek == SERIES_DAY_COUNT �̏ꍇ�ɗL��
        FDayCount: integer;
        FDayCountBaseDate: TDateTime;
        FDayCountStyle: integer;

        // Callback �p�ϐ��Q
        FContextIndex: integer;
        FContextCallback: TSeriesItemConditionCallback;
        function isHoliday(day: TDateTime): boolean;
        function isWeekday(day: TDateTime): boolean;

        // �v���p�e�B�A�N�Z�X�n
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

        // �}�b�`����
        function match_day(day: TDateTime): boolean;
        function match_day_without_holiday(day: TDateTime; increment: integer): boolean;
        function match_first_day_from_specified_day(day: TDateTime; increment: integer): boolean;
        function match_first_day_from_specified_day_without_holiday(day: TDateTime; increment: integer): boolean;
        function match_first_specified_youbi_from_specified_day_without_holiday(day: TDateTime; increment: integer): boolean;
        function match_week(day: TDateTime; biweek: boolean): boolean;
        function match_reference(day: TDateTime): boolean;
        function match_month_day(day: TDateTime): boolean;
        function match_daycount(day: TDateTime): boolean;

        // ������\���쐬
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

// �w�茎���w���
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
// �w������w��j���i�j���̏ꍇ�͗����ւ����j.
// ���̏����𖞂����ɂ́C���̂����ꂩ�̏����𖞂����D
//   - �w������w��j���ŁC�j���łȂ��D
//   - �j�������ǂ��Ă����ƁC�w������w��j���ł���悤�ȓ��ɑ�������D
var
    block: integer; // �ی��Ȃ��߂��h��
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
// �w����ȍ~(�ȑO)�́C���߂̎w�肳�ꂽ�j���Ƀ}�b�`����D
// ��L�̏����𖞂����ɂ́C
//   �w��j���ŁC�����̂Q�����̂����ꂩ�𖞂����D
//    - �w�茎���ł���D
//    - �O�������ɂ��ǂ��Ă����ƁC�w��j���ɑ��������ɁC�w�茎���܂ł����̂ڂ��D
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
// �w����ȍ~(�ȑO)�́C���߂̎w�肳�ꂽ�j���D�j���̏ꍇ�͑O�����̎w��j���ւ����
// ��L�̏����𖞂����̂́C
// 1.  �w��j�����j���łȂ��w�茎���D
// 2.  �w��j�����j���łȂ��C1.�𖞂������܂Ŏw��j���������̂ڂ��D
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
// �w����ȍ~(�ȑO)�́C���߂̎w�肳�ꂽ�j���D�j���̏ꍇ�͗��� or �O���ɂ����
// ��L�̏����𖞂����̂́C���̎O�̏ꍇ���l������D
// 1. �w��j�����w�茎���ł���C���j���łȂ��D
// 2. �w��j�����j���łȂ��CReachable �ł���D
// 3. �w��j���ł͂��j���ł��Ȃ��C�u�w��j���܂ŏj�������ł���v���C���̎w��j���� reachable �ł���D
// Reachable = ���̓�����u�w��j���ɑ������邱�ƂȂ��w�茎���܂ł��ǂ����v�܂��́u�w�茎���܂ł��j�������ł���v
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
            // �w������w��j��
            Result := match_month_day(day) and FYoubi.match(day);
        end;
    HANDLING_HOLIDAY_EXCLUDE: begin
            // �w������w��j���i�j���͏����j
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
        // �j���Ȃ痂���ւ����
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
        // �j���Ȃ玟�̕���(�y���j�����������j�ւ����
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
        // �j���Ȃ玟�̏T�ɂ����
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

    // delta �� "0" ���Ȃ킿�������Ȃ�CFReferItem.match �������`�F�b�N����
    if FReferItemDelta = 0 then begin
        // �j���ł����Ă����֌W�ȏꍇ �� �w��j���̂Ƃ�,
        // �j���͐����Ȃ��w��̂Ƃ���   �w��j�����j���łȂ���,
        // �j���𐔂���w��̂Ƃ��́C�w��j�����C�j���ł���ꍇ,
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


    // "3���O" �̎w��Ȃ�C3���オ FReferItem.match ���Ă��邱�Ƃ��`�F�b�N����
    delta := IfThen(FReferItemDelta > 0, -1, 1);
    max_delta := IfThen(FReferItemDelta > 0, FReferItemDelta, -FReferItemDelta);
    count := 0;
    while (count < max_delta + 1) do begin
        // �j���ł����Ă����֌W�ȏꍇ �� �w��j���̂Ƃ�
        // �j���͐����Ȃ��w��̂Ƃ���   �w��j�����j���łȂ���
        // �j���𐔂���w��̂Ƃ��́C�w��j�����C�j���ł���ꍇ
        // �̏ꍇ�C�������J�E���g����
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
        // ������ count = 0 �ł���iday �ōŏ��ɗ^����ꂽ�����̂��j���I�ɊY�����Ȃ��j�ꍇ�͏I��
        if (count = 0) then begin
            result := false;
            break;
        end;
        day := IncDay(day, delta);
        if not isValid(day) then break;

        // �K�v�ȓ����������I�����Ă����Ԃ̊ԁC�}�b�`���������s
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
    // ���������Ԗڂ̎����\�肩�� Index �l��ۑ�
    // ���̒l��菬���������\��̉e���������󂯂�
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
    end else begin     // �����ȏ��������݂����ꍇ�C�}�b�`�����Ȃ�
        r := false;
    end;

    Result := r;

    // �R���e�L�X�g�l��j��
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
        // 1.6.0: �J�E���g�Ώۂ����肷��
        Result := (day = FDayCountBaseDate) or
                  (isCountTarget(day) and ((CountDays(day) mod FDayCount) = 0));
    end else begin
        // �����łȂ��ꍇ�͑f���ɏ]���̎����𗘗p
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
    if s <> '' then s := s + '�j';
    s := DateFormat.unparseDate(FBiweekBaseDate) + '����̊u�T ' + s;
    Result := s;
end;

function TDayConditionNode.getStringRepresentation: string;
var
    s: string;
    y: string;
    head_s : string;
const
    USER_DEFINED_HOLIDAY_INCLUDED = ' [���[�U�[��`�̏j�����܂�]';
    EXCLUSION_OPTION = '*���O�Ώ�* ';

    // ���[�U��`�̏j�����܂ނ��ǂ����̕������Ԃ�
    // "�j���̏ꍇ�́c" �Ə����Ă�������ݒ肳��Ă���Ƃ��̂ݗL��
    function getUserDefinedHoliday: string;
    begin
        if (FUseWeek = SERIES_DAY) or (FUseWeek = SERIES_DAYCOUNT) then begin
            if UserDefinedHoliday and (AnsiPos('�j��', FORMAT_DAY[HolidayHandling, 1]) > 0) then
                Result := USER_DEFINED_HOLIDAY_INCLUDED
            else
                Result := '';
        end else begin
            if UserDefinedHoliday and (AnsiPos('�j��', FORMAT_WEEK[HolidayHandling]) > 0) then
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
        if s <> '' then s := ' �J�E���g�Ώ�: ' + s + '�j��';
        s := s + FORMAT_REFER[HolidayHandling];
        s := s + getUserDefinedHoliday;
        Result := s;
    end;


begin
    s := FMonthCondition.toString;

    if isSpecificYear then s := IntToStr(YearOf(FRangeStart)) + '�N ' + s;
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
            s := s + '�\�� "' + FReferItem.Name + '"';

            if FReferItemDelta < 0 then
                s := s + '����' + IntToStr(-FReferItemDelta) + '���O'
            else if FReferItemDelta > 0 then
                s := s + '����' + IntToStr(FReferItemDelta) + '����'
            else
                s := s + '�̓�';

            s := s + getCountTargetYoubi;
        end else begin
            s := s + '(�Q�ƃA�C�e�����w�肳��Ă��܂���)';
        end;

    end else if UseWeek = SERIES_DAYCOUNT then begin
        if FDayCount > 1 then begin
            s := s + DateFormat.unparseDate(FDayCountBaseDate) + '�����'
                 + IntToStr(FDayCount) + '���ɂP��';
        end else begin
            s := s + '����';
        end;
        if FDayCountStyle = DAYCOUNTSTYLE_COUNT_SPECIFIC_YOUBI then begin
            s := s + getCountTargetYoubi;
        end else begin
            if FYoubi.Enabled then begin
                s := s + FORMAT_DAYCOUNT[HolidayHandling];
                y := FYoubi.toString;
                if y <> '' then s := s + y + '�j��';
            end;
            // �j���̋L�q������ Day �̂Ƌ��p
            s := s + Format(FORMAT_DAY[HolidayHandling, 1], [FYoubi.toString]);
            s := s + getUserDefinedHoliday;
        end;


    end else if UseWeek = SERIES_DAY then begin
        s := s + FDayCondition.toString;

        if FYoubi.Enabled then begin
            if (s <> '') then s := s + FORMAT_DAY[HolidayHandling, 0];

            y := FYoubi.toString;
            if y <> '' then s := s + y + '�j��';
        end;
        s := s + Format(FORMAT_DAY[HolidayHandling, 1], [FYoubi.toString]);

        s := s + getUserDefinedHoliday;
    end else begin
        s := '(������\�����������̗\��)';
    end;

    if not isSpecificYear and RangeStartEnabled then begin
        if s <> '' then s := s + ' ';
        s := s + FormatDateTime(ShortDateFormat, RangeStart) + ' ����';
    end;
    if not isSpecificYear and RangeEndEnabled then begin
        if s <> '' then s := s + ' ';
        s := s + FormatDateTime(ShortDateFormat, RangeEnd) + ' �܂�';
    end;

    if s = '' then begin
        s := IfThen(isExclusion, EXCLUSION_OPTION, '') + '����(������)';
    end;

    s := head_s + s;
    Result := s;
end;


end.
