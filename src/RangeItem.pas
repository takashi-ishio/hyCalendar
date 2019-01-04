unit RangeItem;

interface

uses
    Windows, Controls, DateUtils, Classes, Graphics, SysUtils, StrUtils;

const
    KEY_FIXED_RANK = '#';

    SKIP_HOLIDAY = 1;
    SKIP_SUNDAY = 2;
    SKIP_SATURDAY = 128;
    SKIP_YOUBI: array [1..7] of integer = (2, 4, 8, 16, 32, 64, 128);
    SKIP_BITMASK = 255;


    ARROWTYPE_BOTH = 0;
    ARROWTYPE_LEFT_ONLY = 1;
    ARROWTYPE_RIGHT_ONLY = 2;
    ARROWTYPE_NOTHING = 3;

type
    TRangeItem = class
    private
        FOwner : string;

        FStart : TDate;
        FEnd   : TDate;
        FText  : string;
        FColor : TColor;
        FIsDayTextColor : boolean;
        FTextColor: TColor;
        FRank  : integer;
        FPenWidth : integer;
        FPenStyle : TPenStyle;

        FArrowType: integer;

        FSkipDays : integer;
        function getPenStyle: integer;
        procedure setPenStyle(style: integer);
        procedure setPenWidth(width: integer);

        procedure setSkipHoliday(value: boolean);
        function getSkipHoliday: boolean;
        procedure setSkipYoubi(idx: integer; value: boolean);
        function getSkipYoubi(idx: integer): boolean;

    public
        constructor Create(start_date, end_date: TDate; AOwner: string);
        destructor Destroy; override;
        function toString: string;

        property Rank : integer read FRank write FRank;
        property Text : string read FText write FText;
        property IsDayTextColor : boolean read FIsDayTextColor write FIsDayTextColor;
        property TextColor: TColor read FTextColor write FTextColor;
        property Color: TColor read FColor write FColor;
        property PenWidth: integer read FPenWidth write setPenWidth;
        property PenStyle: integer read getPenStyle write setPenStyle;
        property LineStyle: TPenStyle read FPenStyle;
        property StartDate: TDate read FStart write FStart;
        property EndDate  : TDate read FEnd   write FEnd;
        property Owner: string read FOwner write FOwner;
        property SkipHoliday: boolean read getSkipHoliday write setSkipHoliday;
        property SkipYoubi[index: integer]: boolean read GetSkipYoubi write SetSkipYoubi; // index は DayOfWeek 準拠
        property ArrowType: integer read FArrowType write FArrowType;
        // for Serialize
        property EncodedSkipDays: integer read FSkipDays write FSkipDays;
    end;

    function ItemSorter(Item1, Item2: Pointer): Integer;

implementation


constructor TRangeItem.Create(start_date, end_date: TDate; AOwner: string);
begin
    FOwner := AOwner;
    FStart := start_date;
    FEnd   := end_date;
    FSkipDays := 0;
    FArrowType := ARROWTYPE_BOTH;
end;

destructor TRangeItem.Destroy;
begin

end;

procedure TRangeItem.setSkipHoliday(value: boolean);
begin
    if value then
        FSkipDays := FSkipDays or SKIP_HOLIDAY
    else
        FSkipDays := FSkipDays and (SKIP_BITMASK and not SKIP_HOLIDAY);
end;

function TRangeItem.getSkipHoliday: boolean;
begin
    Result := (FSkipDays and SKIP_HOLIDAY) <> 0;
end;

procedure TRangeItem.setSkipYoubi(idx: integer; value: boolean);
begin
    if value then
        FSkipDays := FSkipDays or SKIP_YOUBI[idx]
    else
        FSkipDays := FSkipDays and (SKIP_BITMASK and not SKIP_YOUBI[idx]);
end;

function TRangeItem.getSkipYoubi(idx: integer): boolean;
begin
    Result := (FSkipDays and SKIP_YOUBI[idx]) <> 0;
end;

function TRangeItem.toString: string;
begin
    Result := Text + '  (' + FormatDateTime('m/d', StartDate) + ' - ' + FormatDateTime('m/d', EndDate) + ')';
end;

procedure TRangeItem.setPenStyle(style: integer);
begin
    case style of
    0: FPenStyle := psSolid;
    1: FPenStyle := psDot;
    2: FPenStyle := psDash;
    3: FPenStyle := psDashDot;
    4: FPenStyle := psDashDotDot;
    else  FPenStyle := psSolid;
    end;
end;

function TRangeItem.getPenStyle: integer;
begin
    case FPenStyle of
    psSolid: Result := 0;
    psDot:   Result := 1;
    psDash:  Result := 2;
    psDashDot: Result := 3;
    psDashDotDot: Result := 4;
    else Result := 0;
    end;
end;

procedure TRangeItem.setPenWidth(width: integer);
begin
    if (width < 1) then FPenWidth := 1
    else if (width > 5) then FPenWidth := 5
    else FPenWidth := width;
end;


function ItemSorter(Item1, Item2: Pointer): Integer;
// 開始日が早いもの有利，終了日が遅いもの有利，ロケール依存の辞書式順序で早いもの有利
var
    i1, i2: TRangeItem;
    diff: integer;
begin
    i1 := TRangeItem(item1);
    i2 := TRangeItem(item2);
    diff := Round(i1.StartDate - i2.StartDate);
    if diff = 0 then diff := Round(i2.EndDate - i1.EndDate);
    if diff = 0 then diff := AnsiCompareStr(i1.Text, i2.Text);
    Result := diff;
end;



end.
