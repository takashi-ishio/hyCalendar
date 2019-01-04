unit SeriesItemCondition;

interface

uses
    Classes, DateUtils, SysUtils, StringSplitter, Contnrs, StrUtils, Math,
    SeriesCallback;



type
    TSeriesItemCondition = class
    protected
        FOwner: TObject; //TSeriesItem への参照を除くために TObject 型
        FDisabled: boolean;
        FRank: integer;
        function getStringRepresentation: string; virtual; abstract;
        procedure setOwner(new_owner: TObject); virtual;
        constructor Create;

    public
        // 表示上の有効・無効判定
        function isDisabled: boolean; virtual;
        function isExclusion: boolean; virtual; abstract;
        function match(day: TDateTime; callback: TSeriesItemConditionCallback; idx: integer): boolean; virtual; abstract;
        property asString: string read getStringRepresentation;

        // このアイテム自身が無効化されているかどうか
        property Disabled: boolean read FDisabled write FDisabled;
        property Rank: integer read FRank write FRank;
        property Owner: TObject read FOwner write setOwner;
    end;



implementation

uses
    DateFormat;


constructor TSeriesItemCondition.Create;
begin
    FRank := 0;
    FDisabled := false;
    FOwner := nil;
end;

function TSeriesItemCondition.isDisabled: boolean;
begin
    Result := FDisabled;
end;

procedure TSeriesItemCondition.setOwner(new_owner: TObject);
begin
    FOwner := new_owner;
end;

end.
