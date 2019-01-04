unit PageNode;

interface

uses DateUtils, SysUtils;

type
    // Tab に関連付けられている月の情報を保存するオブジェクト
    TPageNode = class
    private
        FBaseDate: TDateTime;
        FCol: integer;
        FRow: integer;

    public
        constructor Create(Base: TDateTime);
        function toString: string;
        function getBaseDate: TDateTime;
        function isFirst : boolean;
        property BaseDate: TDateTime read FBaseDate;
        property Col: integer read FCol write FCol;
        property Row: integer read FRow write FRow;
        property FirstShow: boolean read isFirst;
    end;

implementation



constructor TPageNode.Create(Base: TDateTime);
begin
    FBaseDate := StartOfTheMonth(Base);
    FCol := -1;
    FRow := -1;
end;

function TPageNode.toString: string;
begin
    if YearOf(FBaseDate) = YearOf(Now) then
        Result := FormatDateTime('m"月"', FBaseDate)
    else
        Result := FormatDateTime('yyyy"年"m"月"', FBaseDate);
end;

function TPageNode.getBaseDate: TDateTime;
begin
    result := FBaseDate;
end;

function TPageNode.isFirst : boolean;
begin
    Result := (Col = -1)and(Row = -1);
end;

end.
