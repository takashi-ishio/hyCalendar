unit SeriesItemSerialize;

interface

uses
    Classes, SysUtils, Graphics, Contnrs,
    DateFormat, SeriesItemCondition,
    SeriesItem, DayConditionNode, LogicalExprNode;

const
    CONDITION_BEGIN = '__SERIES_CONDITION_START__';
    CONDITION_END = '__SERIES_CONDITION_END__';

    KEY_TYPE = 'Type';
    VALUE_LOGICALEXPR = 'LogicalExprNode';
    VALUE_CONDITION = 'ConditionNode';

    KEY_DISABLED = 'Disabled';
    KEY_RANK = 'Rank';
    KEY_MODE = 'Mode';
    KEY_ISWEEK = 'IsWeek';
    KEY_MONTH = 'Month';
    KEY_DAY = 'Day';
    KEY_WEEK = 'Week';
    KEY_WEEKCOUNT = 'WeekCount';
    KEY_BIWEEKBASEDATE = 'BiweekBaseDate';
    KEY_DAYCOUNT = 'DayCount';
    KEY_DAYCOUNT_BASEDATE = 'DayCountBaseDate';
    KEY_DAYCOUNT_STYLE = 'DayCountStyle';
    KEY_YOUBI : array [1..7] of string = ('Sunday', 'Monday', 'Tuesday',
        'Wednesday', 'Thursday', 'Friday', 'Saturday');
    KEY_USER_DEFINED_HOLIDAY = 'UserDefinedHoliday';
    KEY_HOLIDAY_HANDLING = 'HolidayHandling';
    KEY_RANGE_START_ENABLED = 'RangeStartEnabled';
    KEY_RANGE_End_ENABLED = 'RangeEndEnabled';
    KEY_RANGE_START = 'RangeStart';
    KEY_RANGE_End = 'RangeEnd';
    KEY_EXCLUSION = 'Exclusion';
    KEY_REFER_ITEM_ID = 'ReferItemID';
    KEY_REFER_ITEM_DELTA = 'ReferItemDelta';

    procedure SerializeSeriesItemList(list: TSeriesItemList; str: TStrings);
    procedure SerializeSeriesItem(item: TSeriesItem; str: TStrings);
    function DeserializeSeriesItemList(str: TStrings; start_idx, end_idx: integer): TSeriesItemList;
    function DeserializeSeriesItemCondition(str: TStrings; var idx: integer): TSeriesItemCondition;
    procedure SerializeLogicalExprNode(node: TLogicalExprNode; str: TStrings);
    procedure SerializeDayConditionNode(node: TDayConditionNode; str: TStrings);

    procedure convertReferenceToID(list: TSeriesItemList);
    procedure resolveReferences(list: TSeriesItemList);

implementation

// function flattenConditionTree(item: TSeriesItem): TObjectList;
//    procedure constructConditionTree(item: TSeriesItem);


function flattenConditionTree(item: TSeriesItem): TObjectList;
// ツリーから RANK を設定してリストに展開
var
    i: integer;
    list: TObjectList;

    procedure parseTree(item: TLogicalExprNode; rank: integer);
    var
        i: integer;
    begin
        i := 0;
        while i < item.ConditionCount do begin
            list.Add(item.Conditions[i]);
            item.Conditions[i].Rank := rank;
            if item.Conditions[i] is TLogicalExprNode then begin
                parseTree(TLogicalExprNode(item.Conditions[i]), rank + 1);
            end;
            inc(i);
        end;
    end;

begin
    list := TObjectList.Create(FALSE);
    i := 0;
    while i < item.ConditionCount do begin
        list.Add(item.Conditions[i]);
        item.Conditions[i].Rank := 0;
        if item.Conditions[i] is TLogicalExprNode then begin
            parseTree(TLogicalExprNode(item.Conditions[i]), 1);
        end;
        inc(i);
    end;
    Result := list;
end;


const
    ITEM_BEGIN = '__SERIES_ITEM_START__';
    ITEM_END = '__SERIES_ITEM_END__';
    KEY_NAME = 'Name';
    KEY_IS_HIDDEN = 'IsHidden';
    KEY_IS_HOLIDAY = 'IsHoliday';
    KEY_IS_SHOWN_AS_DAY_NAME = 'IsShownAsDayName';
    KEY_COLOR = 'Color';
    KEY_BASEDATE = 'BaseDate';
    KEY_CONDITIONS = '__CONDITIONS_LIST__';


procedure SerializeLogicalExprNode(node: TLogicalExprNode; str: TStrings);
begin
    str.Add(CONDITION_BEGIN);
    str.Add(KEY_TYPE + '=' + VALUE_LOGICALEXPR);
    str.Add(KEY_DISABLED + '=' + BoolToStr(node.Disabled, true));
    str.Add(KEY_RANK + '=' + IntToStr(node.Rank));
    str.Add(KEY_MODE + '=' + IntToStr(node.Mode));
    str.Add(CONDITION_END);
end;

procedure SerializeDayConditionNode(node: TDayConditionNode; str: TStrings);
var
    i: integer;
begin
    str.Add(CONDITION_BEGIN);
    str.Add(KEY_TYPE + '=' + VALUE_CONDITION);
    str.Add(KEY_DISABLED + '=' + BoolToStr(node.Disabled, true));
    str.Add(KEY_RANK + '=' + IntToStr(node.Rank));
    str.Add(KEY_MONTH + '=' + node.MonthExpr);
    str.Add(KEY_ISWEEK + '=' + IntToStr(node.UseWeek));
    if node.UseWeek = SERIES_DAY then str.Add(KEY_DAY + '=' + node.DayExpr)
    else if node.UseWeek = SERIES_WEEK then begin
        str.Add(KEY_WEEK + '=' + node.WeekExpr);
        str.Add(KEY_WEEKCOUNT + '=' + IntToStr(node.WeekMode));
    end else if node.UseWeek = SERIES_REFER then begin
        str.Add(KEY_REFER_ITEM_ID + '=' + IntToStr(node.ReferItemID));
        str.Add(KEY_REFER_ITEM_DELTA + '=' + IntToStr(node.ReferItemDelta));
    end else if node.UseWeek = SERIES_DAYCOUNT then begin
        str.Add(KEY_DAYCOUNT_BASEDATE + '=' + DateFormat.unparseDate(node.DayCountBaseDate));
        str.Add(KEY_DAYCOUNT + '=' + IntToStr(node.DayCount));
        str.Add(KEY_DAYCOUNT_STYLE + '=' + IntToStr(node.DayCountStyle));
    end else begin // if FUseWeek = SERIES_BIWEEK
        str.Add(KEY_BIWEEKBASEDATE + '=' + DateFOrmat.unparseDate(node.BiweekBaseDate));
    end;
    for i:=1 to 7 do begin
        str.Add(KEY_YOUBI[i] + '=' + BoolToStr(node.Youbi[i], true));
    end;
    str.Add(KEY_USER_DEFINED_HOLIDAY + '=' + BoolToStr(node.UserDefinedHoliday, true));
    str.Add(KEY_HOLIDAY_HANDLING + '=' + IntToStr(node.HolidayHandling));
    str.Add(KEY_RANGE_START_ENABLED + '=' + BoolToStr(node.RangeStartEnabled, true));
    str.Add(KEY_RANGE_END_ENABLED + '=' + BoolToStr(node.RangeEndEnabled, true));
    str.Add(KEY_RANGE_START + '=' + DateFormat.unparseDate(node.RangeStart));
    str.Add(KEY_RANGE_END + '=' + DateFormat.unparseDate(node.RangeEnd));
    str.Add(KEY_EXCLUSION + '=' + BoolToStr(node.Exclusion, true));
    str.Add(CONDITION_END);
end;

procedure SerializeSeriesItem(item: TSeriesItem; str: TStrings);
var
    i: integer;
    cond: TSeriesItemCondition;
    flatconditions : TObjectList;
begin
    str.Add(ITEM_BEGIN);
    str.Add(KEY_NAME + '=' + item.Name);
    str.Add(KEY_IS_HIDDEN + '=' + BoolToStr(item.IsHidden));
    str.Add(KEY_IS_HOLIDAY + '=' + BoolToStr(item.IsHoliday));
    str.Add(KEY_IS_SHOWN_AS_DAY_NAME +  '=' + BoolToStr(item.IsShownAsDayName));
    if item.UseColor then str.Add(KEY_COLOR +  '=' + ColorToString(item.Color));
    if item.SpecifyBaseDate then str.Add(KEY_BASEDATE + '=' + DateFormat.unparseDate(item.BaseDate));
    str.Add(KEY_CONDITIONS);
    flatconditions := flattenConditionTree(item);
    for i:=0 to flatconditions.Count-1 do begin
      cond := TSeriesItemCondition(flatconditions[i]);
      if cond is TLogicalExprNode then
        SerializeLogicalExprNode(cond as TLogicalExprNode, str)
      else if cond is TDayConditionNode then
        SerializeDayConditionNode(cond as TDayConditionNode, str);
    end;
    str.Add(ITEM_END);
    flatconditions.Free;
end;

procedure SerializeSeriesItemList(list: TSeriesItemList; str: TStrings);
var
    i: integer;
begin
    convertReferenceToID(list);
    for i:=0 to list.Count-1 do begin
        SerializeSeriesItem(list.Items[i], str);
    end;
end;


procedure constructConditionTree(item: TSeriesItem);
// RANK からツリーを構築
var
    i: integer;

    procedure parseConditionHierarchy(node: TLogicalExprNode; var idx: integer);
    begin
        node.clearChildren;
        idx := idx + 1;
        while (idx < item.ConditionCount) do begin
            if item.Conditions[idx].Rank = node.Rank + 1 then begin
                node.addChild(item.Conditions[idx]);

                if item.Conditions[idx] is TLogicalExprNode then begin
                    parseConditionHierarchy(TLogicalExprNode(item.Conditions[idx]), idx);
                end else idx := idx + 1;

            end else begin
                Exit;
            end;

        end;
    end;

begin
    // RANK値からツリー子ノードを判別
    i := 0;
    while i < item.ConditionCount do begin
        if item.Conditions[i] is TLogicalExprNode then begin
             parseConditionHierarchy(item.Conditions[i] as TLogicalExprNode, i);
        end else i := i + 1;
    end;
    // リストから RANK > 0 なノードを除くことでツリー完成
    i := 0;
    while i < item.ConditionCount do begin
        if item.Conditions[i].Rank > 0 then item.DeleteCondition(i)
        else inc(i);
    end;
end;




//-------------------------------------------------------------------------
// シリアライズ・デシリアライズ処理
//-------------------------------------------------------------------------

// シリアライズ・デシリアライズの実装用定数


function DeserializeSeriesItemCondition(str: TStrings; var idx: integer): TSeriesItemCondition;
var
    logical: TLogicalExprNode;
    day: TDayConditionNode;
    list: TStringList;
    i: integer;

    function getUseWeek(s: string): integer;
    var
        intValue: integer;
        value: boolean;
    begin
        if TryStrToInt(s, intValue) then begin
            if (intValue = SERIES_DAY) or
               (intValue = SERIES_WEEK) or
               (intValue = SERIES_BIWEEK) or
               (intValue = SERIES_REFER)or
               (intValue = SERIES_DAYCOUNT) then
                Result := intValue
            else
                Result := SERIES_DAY;
        end else if TryStrToBool(s, value) then begin
            if value then
                Result := SERIES_WEEK
            else
                Result := SERIES_DAY;
        end else begin
            Result := SERIES_DAY;
        end;
     end;

begin

    while (idx < str.Count) and (str[idx] <> CONDITION_BEGIN) do inc(idx);
    inc(idx);
    list := TStringList.Create;
    while (idx < str.Count) and (str[idx] <> CONDITION_END) do begin
        list.Add(str[idx]);
        inc(idx);
    end;
    inc(idx);

    if (list.Values[KEY_TYPE] = VALUE_LOGICALEXPR) then begin
        logical := TLogicalExprNode.Create;
        logical.Mode := StrToIntDef(list.Values[KEY_MODE], 0);
        logical.Disabled := StrToBoolDef(list.Values[KEY_DISABLED], false);
        logical.Rank := StrToIntDef(list.Values[KEY_RANK], 0);
        Result := logical;
    end else begin
        day := TDayConditionNode.Create;
        day.Disabled := StrToBoolDef(list.Values[KEY_DISABLED], false);
        day.Rank := StrToIntDef(list.Values[KEY_RANK], 0);
        day.MonthExpr := list.Values[KEY_MONTH];
        day.DayExpr := list.Values[KEY_DAY];
        day.WeekMode := StrToIntDef(list.Values[KEY_WEEKCOUNT], 0);
        day.WeekExpr := list.Values[KEY_WEEK];

        day.UseWeek := getUseWeek(list.Values[KEY_ISWEEK]);
        day.BiweekBaseDate := DateFormat.parseDateDef(list.Values[KEY_BIWEEKBASEDATE], Date);
        day.DayCount := StrToIntDef(list.Values[KEY_DAYCOUNT], 1);
        day.DayCountBaseDate := DateFormat.parseDateDef(list.Values[KEY_DAYCOUNT_BASEDATE], Date);
        day.DayCountStyle := StrToIntDef(list.Values[KEY_DAYCOUNT_STYLE], 1);
        day.HolidayHandling := StrToIntDef(list.Values[KEY_HOLIDAY_HANDLING], 0);
        day.UserDefinedHoliday := StrToBoolDef(list.Values[KEY_USER_DEFINED_HOLIDAY], false);
        day.ReferItem := nil;
        day.ReferItemID := StrToIntDef(list.Values[KEY_REFER_ITEM_ID], -1);
        day.ReferItemDelta := StrToIntDef(list.Values[KEY_REFER_ITEM_DELTA], 1);

        for i:=1 to 7 do day.Youbi[i] := StrToBoolDef(list.Values[KEY_YOUBI[i]], false);
        day.RangeStartEnabled := StrToBoolDef(list.Values[KEY_RANGE_START_ENABLED], false);
        day.RangeEndEnabled   := StrToBoolDef(list.Values[KEY_RANGE_END_ENABLED], false);
        day.RangeStart := DateFormat.parseDateDef(list.Values[KEY_RANGE_START], Date);
        day.RangeEnd   := DateFormat.parseDateDef(list.Values[KEY_RANGE_END], Date);
        day.Exclusion  := StrToBoolDef(list.Values[KEY_EXCLUSION], false);

        Result := day;
    end;
    list.Free;


end;

function DeserializeSeriesItemList(str: TStrings; start_idx, end_idx: integer): TSeriesItemList;
var
    itemlist: TSeriesItemList;
    condition: TSeriesItemCondition;
    strlist: TStringList;
    planitem: TSeriesItem;
    idx: integer;
begin
    itemlist:= TSeriesItemList.Create;

    strlist := TStringList.Create;

    idx := start_idx;

    while idx <= end_idx do begin
        while (str[idx] <> ITEM_BEGIN)and(idx <= end_idx) do inc(idx);

        if (str[idx] <> ITEM_BEGIN) then begin
            strlist.Free;
            Result := itemlist;
            exit;
        end;

        inc(idx);
        strlist.Clear;
        while (str[idx] <> KEY_CONDITIONS) do begin
            strlist.Add(str[idx]);
            inc(idx);
        end;
        inc(idx); //KEY_CONDITIONS 読み飛ばし

        planitem := itemlist.Add;
        planitem.Name := strlist.Values[KEY_NAME];
        planitem.IsHidden := StrToBoolDef(strlist.Values[KEY_IS_HIDDEN], false);
        planitem.IsHoliday := StrToBoolDef(strlist.Values[KEY_IS_HOLIDAY], false);
        planitem.IsShownAsDayName := StrToBoolDef(strlist.Values[KEY_IS_SHOWN_AS_DAY_NAME], false);
        if strlist.Values[KEY_COLOR] <> '' then begin
            planitem.UseColor := true;
            planitem.Color := StringToColor(strlist.Values[KEY_COLOR]);
        end else begin
            planitem.UseColor := false;
        end;
        if strlist.Values[KEY_BASEDATE] <> '' then begin
            planitem.SpecifyBaseDate := true;
            planitem.BaseDate := DateFormat.parseDate(strlist.Values[KEY_BASEDATE]);
        end else begin
            planitem.SpecifyBaseDate := false;
        end;


        while (str[idx] <> ITEM_END) and (idx <= end_idx) do begin
            condition := SeriesItemSerialize.deserializeSeriesItemCondition(str, idx);
            planitem.addCondition(condition);
        end;
        inc(idx); // ITEM_END 読み飛ばし
        constructConditionTree(planitem);
    end;
    strlist.Free;
    resolveReferences(itemlist);
    Result := itemlist;
end;


// オブジェクトへの参照を，ID参照へ変換する
// このメソッドは flattenTree の後に実行されることが前提
procedure convertReferenceToID(list: TSeriesItemList);
var
    i, j: integer;
    item: TSeriesItem;
    flatconditions: TObjectList;
    cond: TDayConditionNode;
begin
    for i:=0 to list.Count-1 do begin
        item := list.Items[i];
        flatconditions := flattenConditionTree(item);
        for j:=0 to flatConditions.Count-1 do begin
            if flatconditions[j] is TDayConditionNode then begin
                cond := flatconditions[j] as TDayConditionNode;
                cond.ReferItemID := list.IndexOf(cond.ReferItem);
            end;
        end;
        flatconditions.Free;
    end;
end;



// IDによる参照を，オブジェクトへの直接参照へ変換する
procedure resolveReferences(list: TSeriesItemList);

    procedure visitCondition(item: TDayConditionNode);
    begin
        if (item.ReferItemID > -1)and(item.ReferItemID < list.indexOf(item.getOwner) ) then begin
            item.ReferItem := list.Items[item.ReferItemID];
        end else begin
            item.ReferItem := nil;
        end;
    end;

    procedure visit(item: TSeriesItemCondition); forward ;

    procedure visitExpr(item: TLogicalExprNode);
    var
        i: integer;
    begin
        i := 0;
        while (i < item.ConditionCount) do begin
            visit(item.Conditions[i]);
            inc(i);
        end;
    end;

    procedure visit(item: TSeriesItemCondition);
    begin
        if item is TLogicalExprNode then
            visitExpr(item as TLogicalExprNode)
        else if item is TDayConditionNode then
            visitCondition(item as TDayConditionNode);
    end;

var
    i, j: integer;
    item: TSeriesItem;
begin
    i := 0;
    while i < list.Count do begin
        item := list.Items[i];
        j := 0;
        while j < item.ConditionCount do begin
            visit(item.conditions[j]);
            inc(j);
        end;
        inc(i);
    end;
end;



end.
