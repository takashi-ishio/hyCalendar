unit PageNode;

interface

uses DateUtils, SysUtils;

type
    // Tab �Ɋ֘A�t�����Ă��錎�̏���ۑ�����I�u�W�F�N�g
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
        Result := FormatDateTime('m"��"', FBaseDate)
    else
        Result := FormatDateTime('yyyy"�N"m"��"', FBaseDate);
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
