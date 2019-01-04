unit CountdownItem;

interface

uses
  SeriesItem, SysUtils, DateUtils, StrUtils,
  DateFormat;

type
    TCountdownItem = class
    private
        FDisabled: boolean;
        FReferSeries: boolean;
        FDate: TDateTime;
        FSeriesItem: TSeriesItem;
        FActiveLimit: integer;
        FUseCaption: boolean;
        FCaption: string;
        FEveryYear: boolean;

        procedure calculateCaption(var dayname: string; var diff: integer);

    public
        constructor Create;
        destructor Destroy; override;

        function duplicate: TCountdownItem;

        function toString(var s: string): boolean;
        function toStringForItemList: string;

        property Disabled: boolean read FDisabled write FDisabled;
        property SpecifiedDate: TDateTime read FDate write FDate;
        property ActiveLimit: integer read FActiveLimit write FActiveLimit;
        property SeriesItem: TSeriesItem read FSeriesItem write FSeriesItem;
        property ReferSeries: boolean read FReferSeries write FReferSeries;
        property UseCaption: boolean read FUseCaption write FUseCaption;
        property Caption: string read FCaption write FCaption;
        property EveryYear: boolean read FEveryYear write FEveryYear;
    end;


implementation

uses
    DocumentManager;

constructor TCountdownItem.Create;
begin
    FDisabled := false;
    FReferSeries := false;
    FDate := Date;
    FSeriesItem := nil;
    FActiveLimit := 100;
    FUseCaption := false;
    FCaption := '';
    FEveryYear := false;
end;

destructor TCountdownItem.Destroy;
begin

end;

function TCountdownItem.duplicate: TCountdownItem;
var
    item: TCountdownItem;
begin
    item := TCountdownItem.Create;
    item.Disabled := Disabled;
    item.ReferSeries := ReferSeries;
    item.SpecifiedDate := SpecifiedDate;
    item.SeriesItem := SeriesItem;
    item.ActiveLimit := ActiveLimit;
    item.UseCaption := UseCaption;
    item.Caption := Caption;
    item.EveryYear := EveryYear;
    Result := item;
end;

procedure TCountdownItem.calculateCaption(var dayname: string; var diff: integer);
var
  d: TDateTime;
begin
    if FReferSeries and (FSeriesItem <> nil) then begin
        diff := TDocumentManager.getInstance.countDate(FSeriesItem, Date, FActiveLimit);
        d := IncDay(Date, diff);
        if FUseCaption then begin
            if diff >= 0 then
                dayname := StringReplace(FCaption, '%D', DateFormat.unparseDate(d), [rfReplaceAll])
            else
                dayname := StringReplace(FCaption, '%D', '????/??/??', [rfReplaceAll]);
        end else begin
            dayname := FSeriesItem.Name;
        end;
    end else if FReferSeries and (FSeriesItem = nil) then begin
        dayname := '';
        diff := 0;
    end else begin
        if EveryYear then begin
            d := FDate;
            while d < Date do d := IncYear(d, 1);
        end else begin
            d := FDate;
        end;
        diff := DaysBetween(Date, d);
        if Date > d then diff := -diff;
        if FUseCaption then dayname := StringReplace(FCaption, '%D', DateFormat.unparseDate(d), [rfReplaceAll])
        else dayname := DateFormat.unparseDate(d);
    end;
end;


function TCountdownItem.toString(var s: string): boolean;
var
    diff: integer;
    dayname: string;

begin
    s := '';
    if FDisabled then Result := false
    else if FReferSeries and (FSeriesItem = nil) then Result := false
    else begin
        calculateCaption(dayname, diff);
        if diff = 0 then begin
            s := 'ç°ì˙ÇÕ[' + dayname + ']';
            Result := true;
        end else if (0 < diff) and (diff <= FActiveLimit) then begin
            s := dayname + 'Ç‹Ç≈Ç†Ç∆'  + IntToStr(diff) + 'ì˙';
            Result := true;
        end else begin
            Result := false;
        end;
    end;
end;

function TCountdownItem.toStringForItemList: string;
var
    dayname: string;
    diff: integer;
begin
    if FReferSeries and (FseriesItem <> nil) then begin
        calculateCaption(dayname, diff);
        Result := dayname + 'Ç‹Ç≈ÇÃì˙êî' + IfThen(FDisabled, '(ñ≥å¯)', '');
    end else if FReferSeries and (FseriesItem = nil) then begin
        Result := '(ñ≥å¯Ç»çÄñ⁄)';
    end else begin
        calculateCaption(dayname, diff);
        Result := dayname + 'Ç‹Ç≈ÇÃì˙êî' + IfThen(FDisabled, '(ñ≥å¯)', '');
    end;
end;


end.
