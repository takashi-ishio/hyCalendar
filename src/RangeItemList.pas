unit RangeItemList;

interface

uses
    Classes, RangeItem, RangeItemReferenceList,
    RangeItemManager;


type
    TRangeItemList = class(TRangeItemReferenceList)
    private
        FVisible: boolean;
    public
        constructor Create;
        destructor Destroy; override;
        procedure FreeAllItems;
        procedure registerLink(manager: TRangeItemManager; var start_date, end_date: TDateTime);
    end;

implementation

uses
  Math, DateUtils;

constructor TRangeItemList.Create;
begin
    inherited Create;
    FVisible := true;
end;

destructor TRangeItemList.Destroy;
begin
    FreeAllItems;
end;

procedure TRangeItemList.FreeAllItems;
var
    i: integer;
begin
    for i:=0 to self.Count-1 do begin
        TObject(Items[i]).Free;
    end;
    Clear;
end;

procedure TRangeItemList.registerLink(manager: TRangeItemManager; var start_date, end_date: TDateTime);
var
    idx, i: integer;
    diff: integer;
    item: TRangeItem;
begin
    for idx := 0 to getCount-1 do begin
      item := getItem(idx);
      diff := DaysBetween(item.StartDate, item.EndDate);
      for i:=0 to diff do begin
        manager.getRangeItems(IncDay(item.StartDate, i)).Add(item);
      end;

      start_date := Min(start_date, item.StartDate);
      end_date := Max(end_date, item.EndDate);
    end;
end;

end.
