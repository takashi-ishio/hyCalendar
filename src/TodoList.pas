unit TodoList;

interface

uses
    CalendarConfig, Contnrs, Classes, SysUtils, StrUtils, URLScan, DateUtils;


const
    MAX_LINK_INDEX = 7;

type

    TTodoItem = class
    private
        FName: string;
        FChecked: boolean;
        FLastUpdated: TDateTime;
        FDateCount: integer;
        FDate: array [0..MAX_LINK_INDEX] of double;
        FLinks: TStringList;

        procedure setName(new_name: string);
        function getDate(index: integer): TDateTime;
        function getURL(index: integer): string;
        function getURLCount: integer;

        procedure updateURL;
    public
        constructor Create; overload;
        constructor Create(name: string; last_updated: TDateTime); overload;
        destructor Destroy; override;

        property URLs[index: integer]: string read getURL;
        property URLCount: integer read getURLCount;
        property LinkedDate[index: integer]: TDateTime read getDate;
        property DateCount: integer read FDateCount;
        property Name: string read FName write setName;
        property Checked: boolean read FChecked write FChecked;
        property LastUpdated: TDateTime read FLastUpdated write FLastUpdated;
    end;

    TTodoList = class
    private
        FItems: TObjectList;
        function getItem(index: integer): TTodoItem;
    public
        constructor Create;
        destructor Destroy; override;
        procedure Clear;
        procedure add(item: TTodoItem);
        procedure remove(Item: TTodoItem);
        procedure move(item, target: TTodoItem); // item を target の上側に挿入する形で移動．target = nil のときはリストの末尾に移動
        procedure serialize(str: TStrings);
        function Count: integer;
        property Items[index: integer]: TTodoItem read getItem; default;
    end;

    TTodoMatcher = class
    private
        FTodo: TTodoList;
    public
        constructor Create;
        procedure match(day: TDateTime; config: TCalendarConfiguration; matchResult: TStringList);
        property TodoList: TTodoList write FTodo;
    end;

    function deserialize(str: TStrings; idx_start, idx_end: integer): TTodoList;


implementation

uses
    DateFormat;


const
    BEGIN_TODO_ITEM = '__BEGIN_TODO_ITEM__';
    END_TODO_ITEM = '__END_TODO_ITEM__';
    KEY_NAME = 'Name';
    KEY_CHECKED = 'Checked';
    KEY_LASTUPDATED = 'LastUpdated';


constructor TTodoItem.Create;
begin
    FName := '';
    FChecked := false;
    FDateCount := 0;
    FLinks := TStringList.Create;
    FLastUpdated := Date;
end;

constructor TTodoItem.Create(name: string; last_updated: TDateTime);
begin
    Create;
    FName := name;
    FLastUpdated := last_updated;
    updateURL;
end;

destructor TTodoItem.Destroy;
begin
    TURLExtractor.getInstance.cleanupURLs(FLinks);
    FLinks.Free;
end;

function TTodoItem.getURL(index: integer): string;
begin
    Result := FLinks[index];
end;

function TTodoItem.getURLCount: integer;
begin
    Result := FLinks.Count;
end;

procedure TTodoItem.updateURL;
var
    i, j: integer;
begin
    TURLExtractor.getInstance.cleanupURLs(FLinks);
    TURLExtractor.getInstance.extractURLs(FName, FLinks, YearOf(FLastUpdated));
    j := 0;
    for i:= 0 to FLinks.Count-1 do begin
        if j > MAX_LINK_INDEX then break;
        if TURLExtractor.getInstance.isDateURL(FLinks[i]) then begin
            FDate[j] := DateFormat.parseDate(FLinks[i]);
            inc(j);
        end;
    end;
    FDateCount := j;
end;

procedure TTodoItem.setName(new_name: string);
begin
    if FName <> new_name then FLastUpdated := Date;
    FName := new_name;
    updateURL;
end;


function TTodoItem.getDate(index: integer): TDateTime;
begin
    Result := FDate[index];
end;


function deserializeItem(str: TStrings): TTodoItem;
var
    item: TTodoItem;
begin
    item := TTodoItem.Create(str.Values[KEY_NAME], DateFormat.parseDateDef(str.Values[KEY_LASTUPDATED], date));
    item.Checked := StrToBoolDef(str.Values[KEY_CHECKED], false);
    Result := item;
end;

function deserialize(str: TStrings; idx_start, idx_end: integer): TTodoList;
var
    items: TTodoList;
    i: integer;
    tmp: TStringList;
begin
    tmp := TStringList.Create;
    items := TTodoList.Create;

    for i := idx_start to idx_end do begin
        if (str[i] = BEGIN_TODO_ITEM) then begin
            tmp.Clear;
        end else if (str[i] <> END_TODO_ITEM) then begin
            tmp.Add(str[i]);
        end else if (str[i] = END_TODO_ITEM) then begin
            items.add(deserializeItem(tmp));
        end;
    end;

    tmp.Free;
    Result := items;
end;



procedure TTodoList.serialize(str: TStrings);
var
    i: integer;
begin
    for i:= 0 to Count-1 do begin
        str.Add(BEGIN_TODO_ITEM);
        str.Add(KEY_NAME + '=' + Items[i].Name);
        str.Add(KEY_CHECKED + '=' + BoolToStr(Items[i].Checked, true));
        str.Add(KEY_LASTUPDATED + '=' + DateFormat.unparseDate(Items[i].LastUpdated));
        str.Add(END_TODO_ITEM);
    end;
end;

procedure TTodoList.add(item: TTodoItem);
begin
    FItems.Add(item);
end;

// remove したときはオブジェクトは消滅することに注意
procedure TTodoList.remove(Item: TTodoItem);
begin
    FItems.Remove(item);
end;

constructor TTodoList.Create;
begin
    FItems := TObjectList.Create(true);
end;

destructor TTodoList.Destroy;
begin
    FItems.Free;
end;

function TTodoList.Count: integer;
begin
    Result := FItems.Count;
end;

procedure TTodoList.Clear;
begin
    FItems.Clear;
end;

function TTodoList.getItem(index: integer): TTodoItem;
begin
    Result := FItems[index] as TTodoItem;
end;

 // item を target の上側に挿入する形で移動．target = nil のときはリストの末尾に移動
procedure TTodoList.move(item, target: TTodoItem);
var
    idx: integer;
    target_idx: integer;
begin
    idx := FItems.IndexOf(item);
    if target = nil then target_idx := Count-1
    else target_idx := FItems.IndexOf(target);
    if (idx > -1)and(target_idx > -1) then FItems.Move(idx, target_idx);
end;


constructor TTodoMatcher.Create;
begin
    FTodo := nil;
end;



procedure TTodoMatcher.match(day: TDateTime; config: TCalendarConfiguration; matchResult: TStringList);
var
    i, j: integer;
    item: TTodoItem;
begin
    //matchResult.Clear; // わざとクリアしない -- matchResult に複数の TodoList についての結果を累積させるため
    for i:=0 to FTodo.Count-1 do begin
        item := FTodo[i];
        if not (config.HideCompletedTodoOnCalendar and item.Checked) and (item.DateCount > 0) then begin

            for j:=0 to item.DateCount-1 do begin
                if item.LinkedDate[j] = day  then begin
                    if config.ShowTodoLiteral then begin
                        matchResult.Add(IfThen(item.Checked, config.DoneHeadLiteral, config.TodoHeadLiteral) + item.Name);
                    end else matchResult.Add(item.Name);
                end;
            end;
        end;
    end;
end;


end.
