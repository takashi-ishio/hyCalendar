unit ImportText;

interface

uses
    Classes, Contnrs, SysUtils, CalendarDocument, CalendarItem;

type
    TImportItem = class
    private
        day: TDateTime;
        FContents: TStringList;

    public
        constructor Create(d: TDateTime);
        destructor Destroy; override;

        procedure add(s: string);
        function line(i: integer): string;
        function LineCount: integer;
        function getString: string;
        property Date: TDateTime read day;
    end;


    TImportText = class
    private
        FError: TStringList;
        FMap: TStringList;
        FItems: TObjectList;

        procedure parse(lines: TStrings);
        function getItemOrCreate(d: TDateTime): TImportItem;
    public
        constructor Create(filename: string);
        destructor Destroy; override;

        function hasError: boolean;
        function ErrorItems: TStrings;
        function FoundItems: TStrings;

        function ItemCount: integer;
        function GetItem(idx: integer): TImportItem;
        function saveImportLog(filename: string): boolean;
        procedure apply(target: TCalendarDocument);
    end;


implementation

uses StrUtils;

const
    CRLF = #13#10;
    MAX_ERROR = 50;

    ERR_NO_DATE_ITEM = 'エラー: (%d行目) 日付データと関連付けられていないデータ行';
    ERR_FILE_NOT_FOUND = 'エラー: ファイルが開けません．';
    ERR_MAX_ERROR = 'エラー多数のため，表示を省略しました．';

//-----------------------------------------------
// TImportItem の実装
//

constructor TImportItem.Create(d: TDateTime);
begin
    day := d;
    FContents := TStringList.Create;
end;

destructor TImportItem.Destroy;
begin
    FContents.Free;
end;


procedure TImportItem.add(s: string);
begin
    FContents.Add(s);
end;

function TImportItem.line(i: integer): string;
begin
    Result := FContents[i];
end;

function TImportItem.LineCount: integer;
begin
    Result := FContents.Count;
end;



//--------------------------------------------------
// TImportText の実装
//

constructor TImportText.Create(filename: string);
var
    Lines: TStringList;
begin
    FError := TStringList.Create;
    FMap := TStringList.Create;
    FItems := TObjectList.Create(true);

    Lines := TStringList.Create;
    try
        Lines.LoadFromFile(filename);
        parse(Lines);
    except
        on EFOpenError do begin
            FError.Add(ERR_FILE_NOT_FOUND);
            //FError.Add(Format(ERR_FILE_NOT_FOUND, [filename]));
        end;
    end;
    Lines.Free;
end;

function TImportText.GetItem(idx: integer): TImportItem;
begin
    Result := FItems[idx] as TImportItem;
end;

function TImportText.FoundItems: TStrings;
begin
    Result := FMap;
end;

function CompareByDate(Item1, Item2: Pointer): Integer;
var
    p1, p2: TImportItem;
begin
    p1 := TImportItem(Item1);
    p2 := TImportItem(Item2);
    Result := Round(p1.Date) - Round(p2.Date);
end;

procedure TImportText.parse(lines: TStrings);
var
    i: integer;
    after_empty: boolean;
    d: TDateTime;
    item: TImportItem;
begin
    item := nil;
    after_empty := true;

    for i:=0 to lines.Count-1 do begin
        if lines[i] = '' then begin
            after_empty := true;
            continue;
        end;

        if after_empty and TryStrToDate(lines[i], d) then begin
            item := getItemOrCreate(d);
        end else begin
            if item = nil then begin
                if FError.Count < MAX_ERROR then
                    FError.Add(Format(ERR_NO_DATE_ITEM, [1+i]));
            end else begin
                item.add(lines[i]);
            end;
        end;
        after_empty := false;
    end;

    if FError.Count = MAX_ERROR then FError.Add(ERR_MAX_ERROR);

    FItems.Sort(CompareByDate);

    for i:=0 to FItems.Count-1 do begin
        FMap.Add(FormatDateTime('yyyy/mm/dd', GetItem(i).Date) + ' の予定 ' + IntToStr(GetItem(i).LineCount) + '行');
    end;
end;


destructor TImportText.Destroy;
begin
    FError.Free;
    FMap.Free;
    FItems.Free;
end;

function TImportText.getItemOrCreate(d: TDateTime): TImportItem;
var
    i: integer;
    item: TImportItem;
begin
    for i:=0 to FItems.Count-1 do begin
        item := GetItem(i);
        if item.Date = d then begin
            Result := item;
            Exit;
        end;
    end;
    item := TImportItem.Create(d);
    FItems.Add(item);
    Result := item;
end;

function TImportText.hasError: boolean;
begin
    Result := FError.Count > 0;
end;

function TImportText.ErrorItems: TStrings;
begin
    Result := FError;
end;

function TImportItem.getString: string;
begin
    Result := FContents.Text;
end;

function TImportText.saveImportLog(filename: string): boolean;
begin
    try
        FMap.SaveToFile(filename);
        Result := true;
    except
        Result := false;
    end;
end;

procedure TImportText.apply(target: TCalendarDocument);
var
    i: integer;
    item: TImportItem;
    calItem: TCalendarItem;
    s: string;
begin
    for i := 0 to FItems.Count-1 do begin
        item := FItems[i] as TImportItem;
        calItem := target.getItemOrCreate(item.Date);
        s := calItem.getString;
        if (s = '') then
            calItem.setString(item.getString)
        else if AnsiEndsStr(CRLF, s) then
            calItem.setString(s + item.getString)
        else
            calItem.setString(s + CRLF + item.getString);
    end;
end;

function TImportText.ItemCount: integer;
begin
    Result := FItems.Count;
end;

end.
