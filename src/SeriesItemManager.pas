unit SeriesItemManager;

interface

uses
  Contnrs, Classes, SysUtils, DateUtils,
  Constants,
  SeriesItem, SeriesCallback, SeriesPublicHoliday;

type
  TSeriesItemManager = class(TSeriesItemConditionCallback)
  private
    FEmptyList: TStringList;
    FMatched:    array [MIN_YEAR..MAX_YEAR, 1..12, 1..31] of TStringList; // 各日ごとに，判定結果を格納．１つでもマッチするものができるまではリストは作らない
    FCachedItem: array [MIN_YEAR..MAX_YEAR, 1..12, 1..31] of integer; // 各日ごとに，どの予定まで判定を行ったか.値 P のとき，P-1 まで判定が終了している
    FIsHoliday:  array [MIN_YEAR..MAX_YEAR, 1..12, 1..31] of integer; // 祝日かどうか．-1 なら平日, 0以上の優先度が設定されたら休日
    FSorted: boolean;
    // メモリ消費が大きすぎるようならキャッシュアルゴリズム導入で解放する方針で．
    // 要求された日付 d の処理中に，別の日付 d2 の内容が必要になったら，そちらを先に判定する

    FItems: TObjectList;
    FPublicHolidays: TPublicHolidays;

    procedure SortByPriority;
    procedure match(day: TDateTime; idx: integer);

  public

    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure registerItems(items: TSeriesItemList);
    procedure registerItem(item: TSeriesItem);

    function ErrorForHolidayFile: TStrings;

    // getItems - その日にマッチするすべての周期予定を返す
    function getItems(day: TDateTime): TStringList;
    // getSeries は日付名でないすべて，
    // getDayNameList は日付名のすべてを返す
    procedure getSeries(day: TDateTime; matched: TStrings);
    procedure getDayNameList(day: TDateTime; matched: TStrings);

    // SeriesItem が法定休日オブジェクトかどうかを判定
    function isPublicHoliday(item: TObject): boolean;
    function getPublicHolidayName(day: TDateTime): string;

    function isHolidayColor(day: TDateTime): boolean;
    function isActualHoliday(day: TDateTime): boolean;

    // 日数カウント用インタフェース
    function findFirstMatchDay(item: TSeriesItem; from: TDateTime; limit: integer): integer;

    // Callback インタフェース
    function isHoliday(day: TDateTime; IncludeUserDefined: boolean; idx: integer): boolean; override;
    function isMatched(day: TDateTime; ReferItem: TObject): boolean; override;

  end;


implementation

const
  IS_WEEKDAY = -1;
  IS_PUBLIC_HOLIDAY = 0;

function TSeriesItemManager.ErrorForHolidayFile: TStrings;
begin
  Result := FPublicHolidays.ErrorLines;
end;

function TSeriesItemManager.isHolidayColor(day: TDateTime): boolean;
begin
  Result := (DayOfTheWeek(day) = daySunday) or isActualHoliday(day);
end;

function TSeriesItemManager.isPublicHoliday(item: TObject): boolean;
begin
  Result := (item = FPublicHolidays);
end;

function TSeriesItemManager.isActualHoliday(day: TDateTime): boolean;
var
  y, m, d: Word;
begin
  match(day, FItems.Count);
  DecodeDate(day, y, m, d);
  Result := FIsHoliday[y, m, d] <> IS_WEEKDAY;
end;

function TSeriesItemManager.getPublicHolidayName(day: TDateTime): string;
var
  items: TStringList;
begin
  items := getItems(day);
  if (items.Count > 0) and isPublicHoliday(items.Objects[0]) then
    result := items[0]
  else
    result := '';
end;

function TSeriesItemManager.isHoliday(day: TDateTime; IncludeUserDefined: boolean; idx: integer): boolean;
var
  y, m, d: Word;
begin
  DecodeDate(day, y, m, d);

  // idx より１個手前まで Match する
  if FCachedItem[y, m, d] < idx then begin
     Match(day, idx);
  end;

  // あとはマッチ結果を参照するだけ
  Result := (FIsHoliday[y, m, d] = IS_PUBLIC_HOLIDAY) or
            (IncludeUserDefined and
              (FIsHoliday[y, m, d] > IS_PUBLIC_HOLIDAY)and
              (FIsHoliday[y, m, d] < idx));
end;

function TSeriesItemManager.isMatched(day: TDateTime; ReferItem: TObject): boolean;
var
  i: integer;
  y, m, d: Word;
begin
  DecodeDate(day, y, m, d);

  // ReferItem まで，マッチ作業してなければする
  i := FItems.IndexOf(ReferItem);
  if FCachedItem[y, m, d] <= i then begin
    match(day, i+1);
  end;

  // FMatched は，アイテムが０個のときは nil になっていることがあるので注意
  Result := (FMatched[y, m, d] <> nil) and
            (FMatched[y, m, d].IndexOfObject(ReferItem) >= 0);
end;

constructor TSeriesItemManager.Create;
begin
  FItems := TObjectList.Create(FALSE);
  FPublicHolidays:= TPublicHolidays.Create;
  FEmptyList := TStringList.Create;
  Clear;
end;

destructor TSeriesItemManager.Destroy;
begin
  FItems.Free;
  FEmptyList.Free;
  FPublicHolidays.Free;
end;

procedure TSeriesItemManager.getSeries(day: TDateTime; matched: TStrings);
var
    i: integer;
    items : TStringList;
    item: TSeriesItem;
begin
    items := getItems(day);
    for i:=0 to items.Count-1 do begin
      item := Items.Objects[i] as TSeriesItem;
      if not item.IsHidden and not item.IsShownAsDayName then matched.AddObject(items[i], item);
    end;
end;

procedure TSeriesItemManager.getDayNameList(day: TDateTime; matched: TStrings);
var
    i: integer;
    items : TStringList;
    item: TSeriesItem;
begin
    items := getItems(day);
    for i:=0 to items.Count-1 do begin
      item := Items.Objects[i] as TSeriesItem;
      if not item.IsHidden and item.IsShownAsDayName then matched.AddObject(items[i], item);
    end;
end;

procedure TSeriesItemManager.Clear;
var
  y, m, d: integer;
begin
  FItems.Clear;
  FSorted := true;
  for y:=MIN_YEAR to MAX_YEAR do
    for m:=1 to 12 do
      for d:=1 to 31 do begin
        if FMatched[y, m, d] <> nil then FMatched[y, m, d].Clear;
        FCachedItem[y, m, d] := 0;
        FIsHoliday[y, m, d] := IS_WEEKDAY;
      end;
  FItems.Add(FPublicHolidays);
end;

// TSeriesItem を単体でしか持たないクラス向け
procedure TSeriesItemManager.registerItem(item: TSeriesItem);
begin
  FItems.Add(item);
  FSorted := False;
end;

procedure TSeriesItemManager.registerItems(items: TSeriesItemList);
var
  i: integer;
begin
  for i:=0 to items.Count-1 do begin
    FItems.Add(items.Items[i]);
  end;
  FSorted := False;
end;

procedure TSeriesItemManager.SortByPriority;
begin
  // 本来はここで，複数ファイルに含まれたアイテム群を
  // 適切な優先度順序に並べ替える．
  // 今のところいらない（というかファイル間の優先度ソートの定義がない）ので放置
  FSorted := True;
end;

procedure TSeriesItemManager.match(day: TDateTime; idx: integer);
var
  i: integer;
  y, m, d: Word;
  item: TSeriesItem;
  name: string;
begin
  if not FSorted then SortByPriority;

  DecodeDate(day, y, m, d);

  i := FCachedItem[y, m, d];

  if idx > FItems.Count then idx := FItems.Count;

  while i < idx do begin
    item := TSeriesItem(FItems[i]);
    if item.match(day, self, i, name) then begin
      if FMatched[y, m, d] = nil then FMatched[y, m, d] := TStringList.Create;
      FMatched[y, m, d].AddObject(name, item);
      if item.IsHoliday and (FIsHoliday[y, m, d] = IS_WEEKDAY) then FIsHoliday[y, m, d] := i;
    end;
    inc(i);
    FCachedItem[y, m, d] := i;
  end;


end;

function TSeriesItemManager.getItems(day: TDateTime): TStringList;
var
  y, m, d: Word;
begin
  match(day, FItems.Count);

  DecodeDate(day, y, m, d);

  if FMatched[y, m, d] = nil then Result := FEmptyList
  else Result := FMatched[y, m, d];
end;

function TSeriesItemManager.findFirstMatchDay(item: TSeriesItem; from: TDateTime; limit: integer): integer;
var
  i: integer;
  d: TDateTime;
begin
  i := 0;
  d := from;
  while i <= limit do begin
      if isMatched(d, item) then begin
        Result := i;
        exit;
      end;
      d := incday(d, 1);
      inc(i);
  end;
  Result := -1;
end;

end.
