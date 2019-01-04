unit SeriesItem;

interface

uses
    Classes, SysUtils, DateUtils, Contnrs, Graphics,
    SeriesItemCondition, SeriesCallback;

type

    TSeriesItem = class
    private
        FName: string;  // 管理用の名前（= 通常は表示用の名前）
        FIsHidden: boolean;
        FIsShownAsDayName: boolean;
        FIsHoliday: boolean;
        FColor: TColor;
        FUseColor: boolean;

        FSpecifyBaseDate: boolean;
        FBaseDate: TDateTime;

        FConditions: TObjectList;

        function getConditionItem(Index: integer): TSeriesItemCondition;

        procedure setIsHoliday(b: boolean);
        procedure setIsShownAsDayName(b: boolean);

    public
        constructor Create;
        destructor Destroy; override;

        procedure addCondition(item: TSeriesItemCondition);
        procedure removeCondition(item: TSeriesItemCondition); // remove does NOT free condition.
        procedure deleteCondition(index: Integer);
        procedure exchangeCondition(index1, index2: integer);
        procedure insertCondition(index: integer; item: TSeriesItemCondition);
        procedure clearCondition;
        function replaceCondition(index: integer; item: TSeriesItemCondition): TSeriesItemCondition;
        function indexOf(item: TSeriesItemCondition): integer;
        function ConditionCount: integer;

        function match(day: TDateTime; callback: TSeriesItemConditionCallback; idx: integer; var ret: string): boolean; overload; virtual; // ret には表示したい日付名を返す（日付ごとなどに違う内容を返してもよい）
        property Name: string read FName write FName;
        property IsHidden: boolean read FIsHidden write FIsHidden;
        property IsShownAsDayName: boolean read FIsShownAsDayName write setIsShownAsDayName;
        property IsHoliday: boolean read FIsHoliday write setIsHoliday;
        property Color: TColor read FColor write FColor;
        property UseColor: boolean read FUseColor write FUseColor;
        property SpecifyBaseDate: boolean read FSpecifyBaseDate write FSpecifyBaseDate;
        property BaseDate: TDateTime read FBaseDate write FBaseDate;

        property Conditions[Index: integer]: TSeriesItemCondition read getConditionItem; default;

    end;

    TSeriesItemList = class
    private
        FItems: TObjectList;
        FEditing: Boolean;
        function getItem(index: integer): TSeriesItem;
    public
        constructor Create;
        destructor Destroy; override;

        function Add: TSeriesItem;
        procedure Delete(index: integer);
        function IndexOf(item: TSeriesItem): integer;
        procedure Exchange(index1, index2: integer);
        procedure Clear;

        procedure BeginEdit;
        procedure EndEdit;

        function Count: integer;
        property Editing: boolean read FEditing;
        property Items[Index: integer] : TSeriesItem read getItem; default;
    end;


implementation


constructor TSeriesItem.Create;
begin
    FName := '（新しい予定）';
    FIsHidden := false;

    FIsShownAsDayName := false;
    FIsHoliday := false;

    FConditions := TObjectList.Create(FALSE);
    FUseColor := false;
    FColor := clBlack;
end;

destructor TSeriesItem.Destroy;
var
    i: integer;
begin
    for i:=0 to FConditions.Count-1 do begin
        Conditions[i].Free;
    end;
    FConditions.Free;
    inherited;
end;

procedure TSeriesItem.setIsShownAsDayName(b: boolean);
begin
    FIsShownAsDayName := b;
end;

procedure TSeriesItem.deleteCondition(index: Integer);
begin
  FConditions.Delete(index);
end;

procedure TSeriesItem.setIsHoliday(b: boolean);
begin
    FIsHoliday := b;
end;

function TSeriesItem.match(day: TDateTime; callback: TSeriesItemConditionCallback; idx: integer; var ret: string): boolean;
var
    enabler, disabler: boolean; // マッチ条件と，除外条件がそれぞれマッチしたかどうか
    i: integer;
    all_disabled: boolean;
    matched: boolean;
begin
    enabler := false;
    disabler := false;
    all_disabled := true;
    for i:=0 to ConditionCount-1 do begin
        if Conditions[i].isExclusion then begin
            disabler := disabler or ((not Conditions[i].Disabled) and Conditions[i].match(day, callback, idx))
        end else begin
            enabler := enabler or  ((not Conditions[i].Disabled) and Conditions[i].match(day, callback, idx));
        end;
        all_disabled := all_disabled and Conditions[i].Disabled;
    end;
    if all_disabled then enabler := false;

    matched := enabler and not disabler;

    if matched then begin
        // "%d" があれば，今日あるいは指定日からの日数に置換
        if FSpecifyBaseDate then
            ret := StringReplace(FName, '%d', IntToStr(DaysBetween(day, FBaseDate)), [rfReplaceAll])
        else
            ret := StringReplace(FName, '%d', IntToStr(DaysBetween(day, Date)), [rfReplaceAll]);
    end;

    Result := matched;   // 除外条件が１つもなければマッチ成功
end;


function TSeriesItem.replaceCondition(index: integer; item: TSeriesItemCondition): TSeriesItemCondition;
begin
    if (0 <= index) and (index < ConditionCount) then begin
        Result := Conditions[index];
        (FConditions[index] as TSeriesItemCondition).Owner := nil;
        FConditions[index] := item;
        item.Owner := self;
    end else Result := nil;
end;


procedure TSeriesItem.exchangeCondition(index1, index2: integer);
begin
    if (0 <= index1) and (index1 < FConditions.Count) and
       (0 <= index2) and (index2 < FConditions.Count) then
      FConditions.Exchange(Index1, Index2);
end;

function TSeriesItem.indexOf(item: TSeriesItemCondition): integer;
begin
    Result := FConditions.IndexOf(item);
end;

procedure TSeriesItem.insertCondition(index: integer; item: TSeriesItemCondition);
begin
    if (item <> nil) and (FConditions.IndexOf(item) = -1) and (item.Owner = nil) then begin
        FConditions.Insert(index, item);
        item.Owner := self;
    end;
end;

function TSeriesItem.getConditionItem(Index: integer): TSeriesItemCondition;
begin
    Result := TSeriesItemCondition(FConditions[Index]);
end;

procedure TSeriesItem.removeCondition(item: TSeriesItemCondition);
begin
    if item.Owner = self then begin
      FConditions.Remove(item);
      item.Owner := nil;
    end;
end;

procedure TSeriesItem.clearCondition;
var
    i: integer;
begin
    for i:=0 to FConditions.Count-1 do begin
        (FConditions[i] as TSeriesItemCondition).Owner := nil;
    end;
    FConditions.Clear;
end;


procedure TSeriesItem.addCondition(item: TSeriesItemCondition);
begin
    if (item <> nil) and (FConditions.IndexOf(item) = -1) and (item.Owner = nil) then begin
      FConditions.Add(item);
      item.Owner := self;
    end;
end;

function TSeriesItem.ConditionCount: integer;
begin
    result := FConditions.Count;
end;

constructor TSeriesItemList.Create;
begin
    FItems := TObjectList.Create(FALSE);
end;

destructor TSeriesItemList.Destroy;
begin
    Clear;
    FItems.Free;
end;

function  TSeriesItemList.Count: integer;
begin
    Result := FItems.Count;
end;

procedure TSeriesItemList.Exchange(index1, index2: integer);
begin
    if (0 <= index1) and (index1 < FItems.Count) and
       (0 <= index2) and (index2 < FItems.Count) then
      FItems.Exchange(index1, index2);
end;

procedure TSeriesItemList.Clear;
var
    i: integer;
begin
    for i:=0 to Count-1 do begin
        Items[i].Free;
    end;
    FItems.Clear;
end;

procedure TSeriesItemList.Delete(index: integer);
begin
    Items[index].Free;
    FItems.Delete(Index);
end;

function TSeriesItemList.getItem(index: integer): TSeriesItem;
begin
    Result := TSeriesItem(FItems[index]);
end;

function TSeriesItemList.Add: TSeriesItem;
var
    item : TSeriesItem;
begin
    item := TSeriesItem.Create;
    FItems.Add(item);
    Result := item;
end;


function TSeriesItemList.IndexOf(item: TSeriesItem): integer;
begin
    Result := FItems.IndexOf(item);
end;

procedure TSeriesItemList.BeginEdit;
begin
    FEditing := True;
end;

procedure TSeriesItemList.EndEdit;
begin
    FEditing := False;
end;


end.
