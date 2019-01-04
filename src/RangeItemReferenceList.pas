unit RangeItemReferenceList;

interface

uses
    Classes, RangeItem;

type
    // RangeItemList が格納するアイテムに対する
    // 参照専用リスト
    // (リストを破棄しても参照が解放されないという点で参照専用)
    // (RangeItemManager は，期間アイテムの管理に使っている）
    TRangeItemReferenceList = class
    private
        FItems: TList;
    public
        constructor Create;
        destructor Destroy; override;
        procedure Add(Item: TRangeItem);
        procedure Remove(item: TRangeItem);
        function Contains(item: TRangeItem): boolean;
        procedure Clear;
        procedure Sort;
        function getCount: integer;
        function getItem(Index: Integer): TRangeItem;
        function toString: string;
        property Count : integer read getCount;
        property Items[Index: integer]: TRangeItem read getItem; default;
    end;

implementation


constructor TRangeItemReferenceList.Create;
begin
    FItems := TList.Create;
end;

destructor TRangeItemReferenceList.Destroy;
begin
    // 格納しているオブジェクトは，共有オブジェクトなので，
    // 明示的に解放されない限り解放しない
    FItems.Free;
end;

function TRangeItemReferenceList.toString: string;
var
  i: integer;
  s: string;
begin
    s := '';
    for i:=0 to Count-1 do begin
        s := s + Items[i].toString +  #$D#$A;
    end;
    Result := s;
end;

procedure TRangeItemReferenceList.Clear;
begin
    FItems.Clear;
end;

procedure TRangeItemReferenceList.Remove(item: TRangeItem);
begin
    FItems.Remove(item);
end;

function TRangeItemReferenceList.Contains(item: TRangeItem): boolean;
begin
    Result := FItems.IndexOf(item) >= 0;
end;

procedure TRangeItemReferenceList.Add(item: TRangeItem);
begin
    FItems.Add(item);
end;

function TRangeItemReferenceList.getCount: integer;
begin
    Result := FItems.Count;
end;

function TRangeItemReferenceList.getItem(Index: Integer): TRangeItem;
begin
    Result := TRangeItem(FItems[Index]);
end;

procedure TRangeItemReferenceList.Sort;
begin
    FItems.Sort(RangeItem.ItemSorter);
end;

end.
