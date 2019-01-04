unit RangeItemManager;
// �e�h�L�������g���쐬�������ԗ\��̊Ǘ��N���X


interface

uses
    Classes, DateUtils, SysUtils, Constants, RangeItemReferenceList, RangeItem;

type

    TRangeItemMonth = class
    private
        FItems: array [1..31] of TRangeItemReferenceList;
        function getRanges(index: integer): TRangeItemReferenceList;
    public
        constructor Create;
        destructor Destroy; override;
        procedure Clear;
        property RangeItems[index: integer]: TRangeItemReferenceList read getRanges;
    end;


    TRangeItemManager = class
    private
        FItems: array [MIN_YEAR..MAX_YEAR, 1..12] of TRangeItemMonth;
    public
        constructor Create;
        destructor Destroy; override;
        function getRangeItems(day: TDateTime): TRangeItemReferenceList;
        function getSortedRangeItems(day: TDateTime): TRangeItemReferenceList;
        procedure Clear;
        procedure registerRangeLink(item: TRangeItem);
        procedure unregisterRangeLink(item: TRangeItem);
        procedure negotiateRanks(start_date, end_Date: TDateTime);
    end;


implementation

constructor TRangeItemMonth.Create;
var
    i: integer;
begin
    for i:=1 to 31 do begin
        FItems[i] := nil;
    end;
end;

destructor TRangeItemMonth.Destroy;
var
    i: integer;
begin
    for i:=1 to 31 do begin
        if FItems[i] <> nil then FItems[i].Free;
    end;
end;

procedure TRangeItemMonth.Clear;
var
  i: integer;
begin
    for i:=1 to 31 do begin
        if FItems[i] <> nil then TRangeItemReferenceList(FItems[i]).Clear;
    end;
end;

function TRangeItemMonth.getRanges(index: integer): TRangeItemReferenceList;
begin
    if (index > 0) and (index <= 31) then begin
        if FItems[index] = nil then
            FItems[index] := TRangeItemReferenceList.Create;
        Result := FItems[index];
    end else Result := nil;
end;

constructor TRangeItemManager.Create;
var
    y, m: integer;
begin
    for y:=MIN_YEAR to MAX_YEAR do
        for m:=1 to 12 do
            FItems[y, m] :=nil;
end;

destructor TRangeItemManager.Destroy;
var
    y, m: integer;
begin
    for y:=MIN_YEAR to MAX_YEAR do
        for m:=1 to 12 do
            if FItems[y, m] <> nil then FItems[y, m].Free;
end;


procedure TRangeItemManager.Clear;
var
    y, m: integer;
begin
  for y:=MIN_YEAR to MAX_YEAR do
    for m:=1 to 12 do
      if FItems[y, m] <> nil then TRangeItemMonth(FItems[y, m]).Clear;
end;


function TRangeItemManager.getSortedRangeItems(day: TDateTime): TRangeItemReferenceList;
var
    ref: TRangeItemReferenceList;
begin
    ref := getRangeItems(day);
    ref.Sort;
    Result := ref;
end;

function TRangeItemManager.getRangeItems(day: TDateTime): TRangeItemReferenceList;
var
    y, m, d: Word;
begin
    DecodeDate(day, y, m, d);
    if FItems[y, m] <> nil then
        Result := FItems[y, m].getRanges(d)
    else begin
        FItems[y, m] := TRangeItemMonth.Create;
        Result := FItems[y, m].getRanges(d);
    end;
end;

procedure TRangeItemManager.registerRangeLink(item: TRangeItem);
var
    i: integer;
    diff: integer;
begin
    diff := DaysBetween(item.StartDate, item.EndDate);
    for i:=0 to diff do begin
        getRangeItems(IncDay(item.StartDate, i)).Add(item);
    end;
end;


procedure TRangeItemManager.unregisterRangeLink(item: TRangeItem);
var
    i: integer;
    diff: integer;
begin
    diff := DaysBetween(item.StartDate, item.EndDate);
    for i:=0 to diff do begin
        getRangeItems(IncDay(item.StartDate, i)).Remove(item);
    end;
end;

procedure TRangeItemManager.negotiateRanks(start_date, end_Date: TDateTime);
const
    MAX_RANK = 32;
var
    l: TList;
    i: integer;
    r: integer;
    d : array [0..MAX_RANK] of TDateTime;     // d[N]: Rank N �Ɋ���t�������̍ŏI��
    prev: integer;
    prev_tmp: integer;
    item: TRangeItem;

    procedure addNewItem(items: TRangeItemReferenceList);
    var
        i: integer;
    begin
        for i := 0 to items.Count-1 do begin
            if l.IndexOf(items[i]) = -1 then begin
                l.Add(items[i]);
            end;
        end;
    end;

    procedure listupAffectedItems(start_date, end_Date: TDateTime);
    var
        i: integer;
        diff: integer;
    begin
        diff := DaysBetween(start_date, end_date);
        for i:=0 to diff do begin
            addNewItem(getRangeItems(IncDay(start_date, i)));   //TDocumentManager.getInstance.getItem(IncDay(start_date, i)).RangeItems);
        end;
    end;


begin

    l := TList.Create;

    // �����A�C�e���W�����\�z
    listupAffectedItems(start_date, end_date);

    // Range���d�Ȃ��Ă���I�u�W�F�N�g�����ׂĎ�J��
    prev := 0;
    while l.Count <> prev do begin
        prev_tmp := l.Count;
        for i:=prev to prev_tmp-1 do begin
            listupAffectedItems(TRangeItem(l[i]).StartDate, TRangeItem(l[i]).EndDate);
        end;
        prev := prev_tmp;
    end;

    // �I�u�W�F�N�g���������Ƃ���ŊJ�n���t�����ŕ��בւ�(secondkey: �I�����t�̒x�����j
    l.Sort(ItemSorter);

    // rank allocation table ��������( d[r] = Rank r ���Ɛ肳��Ă���ŏI�� )
    for r:=0 to MAX_RANK do begin
        d[r] := 0;
    end;

    // �I�u�W�F�N�g�Ƀ����N��ݒ�
    for i:=0 to l.Count-1 do begin
        item := TRangeItem(l[i]);
        item.Rank := MAX_RANK; // �ň��ł� MAX_RANK �ɗ}����
        for r:=0 to MAX_RANK do begin
            if item.StartDate > d[r] then begin
                // �󂢂Ă��� Rank �����蓖��
                item.Rank := r;
                d[r] := item.EndDate;
                break;
            end;
        end;
    end;
    l.Free;
end;

end.
