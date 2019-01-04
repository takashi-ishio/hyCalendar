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
    FMatched:    array [MIN_YEAR..MAX_YEAR, 1..12, 1..31] of TStringList; // �e�����ƂɁC���茋�ʂ��i�[�D�P�ł��}�b�`������̂��ł���܂ł̓��X�g�͍��Ȃ�
    FCachedItem: array [MIN_YEAR..MAX_YEAR, 1..12, 1..31] of integer; // �e�����ƂɁC�ǂ̗\��܂Ŕ�����s������.�l P �̂Ƃ��CP-1 �܂Ŕ��肪�I�����Ă���
    FIsHoliday:  array [MIN_YEAR..MAX_YEAR, 1..12, 1..31] of integer; // �j�����ǂ����D-1 �Ȃ畽��, 0�ȏ�̗D��x���ݒ肳�ꂽ��x��
    FSorted: boolean;
    // ����������傫������悤�Ȃ�L���b�V���A���S���Y�������ŉ��������j�ŁD
    // �v�����ꂽ���t d �̏������ɁC�ʂ̓��t d2 �̓��e���K�v�ɂȂ�����C��������ɔ��肷��

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

    // getItems - ���̓��Ƀ}�b�`���邷�ׂĂ̎����\���Ԃ�
    function getItems(day: TDateTime): TStringList;
    // getSeries �͓��t���łȂ����ׂāC
    // getDayNameList �͓��t���̂��ׂĂ�Ԃ�
    procedure getSeries(day: TDateTime; matched: TStrings);
    procedure getDayNameList(day: TDateTime; matched: TStrings);

    // SeriesItem ���@��x���I�u�W�F�N�g���ǂ����𔻒�
    function isPublicHoliday(item: TObject): boolean;
    function getPublicHolidayName(day: TDateTime): string;

    function isHolidayColor(day: TDateTime): boolean;
    function isActualHoliday(day: TDateTime): boolean;

    // �����J�E���g�p�C���^�t�F�[�X
    function findFirstMatchDay(item: TSeriesItem; from: TDateTime; limit: integer): integer;

    // Callback �C���^�t�F�[�X
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

  // idx ���P��O�܂� Match ����
  if FCachedItem[y, m, d] < idx then begin
     Match(day, idx);
  end;

  // ���Ƃ̓}�b�`���ʂ��Q�Ƃ��邾��
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

  // ReferItem �܂ŁC�}�b�`��Ƃ��ĂȂ���΂���
  i := FItems.IndexOf(ReferItem);
  if FCachedItem[y, m, d] <= i then begin
    match(day, i+1);
  end;

  // FMatched �́C�A�C�e�����O�̂Ƃ��� nil �ɂȂ��Ă��邱�Ƃ�����̂Œ���
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

// TSeriesItem ��P�̂ł��������Ȃ��N���X����
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
  // �{���͂����ŁC�����t�@�C���Ɋ܂܂ꂽ�A�C�e���Q��
  // �K�؂ȗD��x�����ɕ��בւ���D
  // ���̂Ƃ��낢��Ȃ��i�Ƃ������t�@�C���Ԃ̗D��x�\�[�g�̒�`���Ȃ��j�̂ŕ��u
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
