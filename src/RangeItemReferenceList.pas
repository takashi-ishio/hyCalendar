unit RangeItemReferenceList;

interface

uses
    Classes, RangeItem;

type
    // RangeItemList ���i�[����A�C�e���ɑ΂���
    // �Q�Ɛ�p���X�g
    // (���X�g��j�����Ă��Q�Ƃ��������Ȃ��Ƃ����_�ŎQ�Ɛ�p)
    // (RangeItemManager �́C���ԃA�C�e���̊Ǘ��Ɏg���Ă���j
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
    // �i�[���Ă���I�u�W�F�N�g�́C���L�I�u�W�F�N�g�Ȃ̂ŁC
    // �����I�ɉ������Ȃ����������Ȃ�
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
