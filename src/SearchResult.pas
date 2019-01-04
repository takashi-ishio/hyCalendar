unit SearchResult;

interface

uses
    Classes, SysUtils, DateUtils;


type
    TSearchResult = class
    private
        FDay: TStringList;
        FKind: TStringList;
        FText: TStringList;
        FRank: TStringList;

        function getCount: integer;
        function getDay(index: integer): string;
        function getKind(index: integer): string;
        function getText(index: integer): string;
        function getRank(index: integer): string;
    public
        constructor Create;
        destructor Destroy; override;
        procedure Clear;
        procedure Add(d: TDateTime; kind, text: string; rank: integer);
        procedure Concat(other: TSearchResult);

        property Day [index: integer]: string read getDay;
        property Kind [index: integer]: string read getKind;
        property Text [index: integer]: string read getText;
        property Rank [index: integer]: string read getRank;
        property Count: integer read getCount;
    end;

implementation

constructor TSearchResult.Create;
begin
    FDay := TStringList.Create;
    FKind := TStringList.Create;
    FText := TStringList.Create;
    FRank := TStringList.Create;
end;

destructor TSearchResult.Destroy;
begin
    FDay.Free;
    FKind.Free;
    FText.Free;
    FRank.Free;
end;

procedure TSearchResult.Clear;
begin
    FDay.Clear;
    FKind.Clear;
    FText.Clear;
    FRank.Clear;
end;

function TSearchResult.getCount: integer;
begin
    Result := FDay.Count;
end;

procedure TSearchResult.Add(d: TDateTime; kind, text: string; rank: integer);
begin
    FDay.Add(FormatDateTime('yyyy/MM/dd', d));
    FKind.Add(kind);
    FText.Add(text);
    FRank.Add(IntToStr(rank));
end;

function TSearchResult.getDay(index: integer): string;
begin
    Result := FDay[index];
end;

function TSearchResult.getKind(index: integer): string;
begin
    Result := FKind[index];
end;

function TSearchResult.getText(index: integer): string;
begin
    Result := FText[index];
end;

function TSearchResult.getRank(index: integer): string;
begin
    Result := FRank[index];
end;

procedure TSearchResult.Concat(other: TSearchResult);
begin
    FDay.AddStrings(other.FDay);
    FKind.AddStrings(other.FKind);
    FText.AddStrings(other.FText);
    FRank.AddStrings(other.FRank);
end;

end.
