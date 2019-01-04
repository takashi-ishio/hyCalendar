unit LogicalExprNode;

interface

uses
    Classes, SysUtils, Contnrs,
    SeriesItemCondition, SeriesCallback;

const
    LOGICAL_EXPR_AND = 0;
    LOGICAL_EXPR_OR  = 1;
    LOGICAL_EXPR_NAND = 2;
    LOGICAL_EXPR_NOR = 3;

type
    TLogicalExprNode = class(TSeriesItemCondition)
    private
        FMode: integer;
        FChildren: TObjectList;

    protected
        function getStringRepresentation: string; override;
        function getConditionItem(Index: integer): TSeriesItemCondition;

        procedure setOwner(new_owner: TObject); override;
    public
        constructor Create;
        destructor Destroy; override;

        function match(day: TDateTime; callback: TSeriesItemConditionCallback; idx: integer): boolean; override;
        function isDisabled: boolean; override;
        function isExclusion: boolean; override;

        procedure addChild(item: TSeriesItemCondition);
        procedure removeChild(item: TSeriesItemCondition);
        procedure insertChild(index: integer; item: TSeriesItemCondition);
        procedure exchangeChild(index1, index2: integer);
        function indexOf(item: TSeriesItemCondition): integer;
        procedure clearChildren;

        function ConditionCount: integer;

        property Mode: integer read FMode write FMode;
        property Conditions[Index: integer]: TSeriesItemCondition read getConditionItem; default;
    end;

implementation

function TLogicalExprNode.isDisabled: boolean;
var
    d: boolean;
    i: integer;
begin
    d := true;
    for i:=0 to FChildren.Count-1 do begin
        d := d and TSeriesItemCondition(FChildren[i]).isDisabled;
    end;
    Result := d or FDisabled;
end;

procedure TLogicalExprNode.setOwner(new_owner: TObject);
var
    i: integer;
begin
    inherited setOwner(new_owner);
    for i:=0 to FChildren.Count-1 do begin
        getConditionItem(i).Owner := new_owner;
    end;
end;

function TLogicalExprNode.isExclusion: boolean;
begin
    result := false;
end;

function TLogicalExprNode.ConditionCount: integer;
begin
    result := FChildren.Count;
end;

function TLogicalExprNode.getConditionItem(Index: integer): TSeriesItemCondition;
begin
    Result := TSeriesItemCondition(FChildren[Index]);
end;

function TLogicalExprNode.getStringRepresentation: string;
begin
    case Mode of
    LOGICAL_EXPR_AND: Result := '以下の条件をすべて満たす (AND)';
    LOGICAL_EXPR_OR: Result := '以下の条件のいずれかに該当する (OR)';
    LOGICAL_EXPR_NAND: Result := '以下の条件のすべてを満たすものは除く (NAND)';
    LOGICAL_EXPR_NOR: Result := '以下の条件のいずれかに該当するものは除く (NOR)';
    else
        Result := '不正なコードが設定されています．'
    end;
end;

constructor TLogicalExprNode.Create;
begin
    inherited Create;
    FMode := 0;
    FChildren := TObjectList.Create(FALSE);
end;

destructor TLogicalExprNode.Destroy;
var
    i: integer;
begin
    for i:=0 to ConditionCount-1 do begin
        Conditions[i].Free;
    end;
    FChildren.Free;
end;

procedure TLogicalExprNode.addChild(item: TSeriesItemCondition);
begin
    FChildren.Add(item);
    item.Owner := self.Owner;
end;

procedure TLogicalExprNode.clearChildren;
var
    i: integer;
begin
    for i:=0 to FChildren.Count-1 do begin
        getConditionItem(i).Owner := nil;
    end;
    FChildren.Clear;
end;

procedure TLogicalExprNode.insertChild(index: integer; item: TSeriesItemCondition);
begin
    FChildren.Insert(index, item);
    item.Owner := self.Owner;
end;

procedure TLogicalExprNode.removeChild(item: TSeriesItemCondition);
begin
    FChildren.Remove(item);
    item.Owner := nil;
end;

function TLogicalExprNode.indexOf(item: TSeriesItemCondition): integer;
begin
    Result := FChildren.indexOf(item);
end;

procedure TLogicalExprNode.exchangeChild(index1, index2: integer);
begin
    FChildren.Exchange(index1, index2);
end;

function TLogicalExprNode.match(day: TDateTime; callback: TSeriesItemConditionCallback; idx: integer): boolean;
var
    i: integer;
    enabler, disabler: boolean; // マッチする条件と，除外条件それぞれのマッチ状況
    c: integer;
begin
    c := 0;
    enabler := false;
    disabler := false;
    if (Mode = LOGICAL_EXPR_AND) or (Mode = LOGICAL_EXPR_NAND) then begin
        enabler := true;
        i := 0;
        while enabler and (i < FChildren.Count) do begin
            if not TSeriesItemCondition(FChildren[i]).isDisabled then begin
                if Conditions[i].isExclusion then begin
                    // disabler 側は常に OR 演算
                    disabler := disabler or TSeriesItemCondition(FChildren[i]).match(day, callback, idx);
                end else begin
                    enabler := enabler and TSeriesItemCondition(FChildren[i]).match(day, callback, idx);
                end;

                c := c + 1;
            end;
            i := i + 1;
        end;
        if (Mode = LOGICAL_EXPR_NAND) then enabler := not enabler;
    end else if (Mode = LOGICAL_EXPR_OR) or (Mode = LOGICAL_EXPR_NOR) then begin
        i := 0;
        while not enabler and (i < FChildren.Count) do begin
            if not TSeriesItemCondition(FChildren[i]).isDisabled then begin
                if Conditions[i].isExclusion then begin
                    disabler := disabler or TSeriesItemCondition(FChildren[i]).match(day, callback, idx);
                end else begin
                    enabler := enabler or TSeriesItemCondition(FChildren[i]).match(day, callback, idx);
                end;
                c := c + 1;
            end;
            i := i + 1;
        end;
        if (Mode = LOGICAL_EXPR_NOR) then enabler := not enabler;
    end;
    if (c = 0) then enabler := false; // 有効なデータがなければ false
    Result := enabler and not disabler;
end;



end.
