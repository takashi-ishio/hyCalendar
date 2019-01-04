unit ColorManager;
// 着色情報を管理するためのクラス．
// 同時に，メインフォームのカラーパレットの内容も管理する．
// Undo機能も実装している．

interface

uses
    Types, Classes, Graphics, ExtCtrls, Constants,
    DateUtils, UndoBuffer, CalendarAction,
    CalendarCallback, ColorPair;

type
    TPaintColorManager = class
    private
        FDefaultBackColor: TColor;

        // 色ボックスに指定された基本色
        SelectedColor: TCellColorConfig;
        PaletteColor: array [0..COLOR_BOX_COUNT-1] of TCellColorConfig;

        // 日付別色情報もここで持つ
        DayColor: array [MIN_YEAR..MAX_YEAR, 1..12, 1..31] of TCellColorConfig;


    public
        constructor Create;

        // パレット編集・選択関数
        procedure paintColorBox(idx: integer; canvas: TCanvas; rect: TRect);
        procedure selectColor(idx: integer);
        function getColor(idx: integer): TCellColorConfig;
        procedure setColor(idx: integer; cl: TCellColorConfig);
        procedure selectDateColor(day: TDateTime);

        // カラー編集
        procedure Clear;
        function getHeadColor(day: TDateTime): TColor;
        function getBackColor(day: TDateTime): TColor;
        procedure updateColor(day: TDateTime; callback: TCalendarCallback; undo: TUndoBuffer);
        procedure updateColorByIndex(day: TDateTime; callback: TCalendarCallback; undo: TUndoBuffer; idx: integer);

        procedure updateColorWithoutUndo(day: TDateTime; Color: TCellColorConfig);

        procedure serialize(f: TStrings);
        procedure deserialize(f: TStrings; start_idx, end_idx: integer);

        property DefaultBackColor: TColor read FDefaultBackColor write FDefaultBackColor;
    end;


implementation

uses SysUtils, Calendar, StringSplitter, DateFormat;


const
    COLOR_ITEM_SEPARATOR = ',';

type

    TCalendarPaintAction = class(TCalendarAction)
    private
        FColorManager: TPaintColorManager;
        FDay: TDateTime;
        FOriginalColor: TCellColorConfig;
        FPaintedColor: TCellColorConfig;
        FWindow: TCalendarCallBack;
    public
        constructor Create(form: TCalendarCallback; manager: TPaintColorManager; day: TDateTime; original, painted: TCellColorConfig);
        destructor Destroy; override;
        procedure doAction; override;
        procedure undoAction; override;
    end;



constructor TPaintColorManager.Create;
begin
    FDefaultBackColor := clWhite;
    Clear;
end;

procedure TPaintColorManager.paintColorBox(idx: integer; canvas: TCanvas; rect: TRect);
var
    color: TCellColorConfig;
begin
    if idx >= 0 then color := PaletteColor[idx]
    else color := SelectedColor;

    canvas.Brush.Color := color.Back;
    if color.Back = clDefault then canvas.Brush.Color := FDefaultBackColor;
    canvas.FillRect(rect);
    canvas.Rectangle(rect);
    rect.Bottom := rect.Bottom - (rect.Bottom - rect.Top) div 2;
    rect.Right  := rect.Right - (rect.Right - rect.Left) div 2;
    canvas.Brush.Color := color.Head;
    if color.Head = clDefault then canvas.Brush.Color := FDefaultBackColor;
    canvas.FillRect(rect);
    canvas.Pen.Color := clBlack;
    canvas.Rectangle(rect);
end;

function TPaintColorManager.getHeadColor(day: TDateTime): TColor;
var
    y, m, d: Word;
begin
    DecodeDate(day, y, m, d);
    Result := DayColor[y, m, d].Head;
end;

function TPaintColorManager.getBackColor(day: TDateTime): TColor;
var
    y, m, d: Word;
begin
    DecodeDate(day, y, m, d);
    Result := DayColor[y, m, d].Back;
end;

procedure TPaintColorManager.updateColorWithoutUndo(day: TDateTime; color: TCellColorConfig);
var
    y, m, d: Word;
begin
    DecodeDate(day, y, m, d);
    DayColor[y, m, d] := color;
end;

procedure TPaintColorManager.updateColorByIndex(day: TDateTime; callback: TCalendarCallback; undo: TUndoBuffer; idx: integer);
var
    y, m, d: Word;
    action: TCalendarAction;
begin
    DecodeDate(day, y, m, d);
    if idx = -1 then begin
        action := TCalendarPaintAction.Create(callback, self, day, DayColor[y, m, d], SelectedColor);
    end else begin
        action := TCalendarPaintAction.Create(callback, self, day, DayColor[y, m, d], PaletteColor[idx]);
    end;
    Undo.pushAction(action);
    action.doAction;

end;

procedure TPaintColorManager.updateColor(day: TDateTime; callback: TCalendarCallback; undo: TUndoBuffer);
var
    y, m, d: Word;
    action: TCalendarAction;
begin
    DecodeDate(day, y, m, d);
    action := TCalendarPaintAction.Create(callback, self, day, DayColor[y, m, d], SelectedColor);
    Undo.pushAction(action);
    action.doAction;

end;

procedure TPaintColorManager.selectColor(idx: integer);
begin
    SelectedColor := PaletteColor[idx];
end;

procedure TPaintColorManager.selectDateColor(day: TDateTime);
var
    y, m, d: Word;
begin
    DecodeDate(day, y, m, d);
    SelectedColor := DayColor[y, m, d];
end;

function TPaintColorManager.getColor(idx: integer): TCellColorConfig;
begin
    if idx = -1 then Result := SelectedColor
    else Result := PaletteColor[idx];
end;

procedure TPaintColorManager.setColor(idx: integer; cl: TCellColorConfig);
begin
    if idx = -1 then SelectedColor := cl
    else PaletteColor[idx] := cl;
end;

procedure TPaintColorManager.Clear;
var
    y, m, d: integer;
begin
    for y := MIN_YEAR to MAX_YEAR do
        for m := 1 to 12 do
            for d := 1 to 31 do begin
                DayColor[y, m, d].Head := clDefault;
                DayColor[y, m, d].Back := clDefault;
            end;
end;

procedure TPaintColorManager.serialize(f: TStrings);
var
    y, m, d: Word;
begin
    for y := MIN_YEAR to MAX_YEAR do
        for m := 1 to 12 do
            for d := 1 to 31 do begin
                if (DayColor[y, m, d].Head <> clDefault)or
                    (DayColor[y, m, d].Back <> clDefault) then begin
                    f.Add(unparseDate(EncodeDate(y, m, d)) + COLOR_ITEM_SEPARATOR + ColorToString(DayColor[y,m,d].Back) + COLOR_ITEM_SEPARATOR + ColorToString(DayColor[y,m,d].Head) );
                end;
            end;
end;

procedure TPaintColorManager.deserialize(f: TStrings; start_idx, end_idx: integer);
var
    i: integer;
    s: TStringSplitter;
    day: TDateTime;
    y,m,d: word;
begin
    s := TStringSplitter.Create(COLOR_ITEM_SEPARATOR);
    try
        for i:=start_idx to end_idx do begin
            s.setString(f[i]);
            if s.hasNext then begin
                day := DateFormat.parseDate(s.getLine);
                DecodeDate(day, y, m, d);
                if s.hasNext then begin
                    DayColor[y, m, d].Back := StringToColor(s.getLine);
                    if s.hasNext then begin
                        DayColor[y, m, d].Head := StringToColor(s.getLine);
                    end;
                end;
            end;
        end;
    finally
        s.Free;
    end;
end;

constructor TCalendarPaintAction.Create(form: TCalendarCallback; manager: TPaintColorManager; day: TDateTime; original, painted: TCellColorConfig);
begin
    FColorManager := manager;
    FDay := day;
    FOriginalColor := original;
    FPaintedColor := painted;
    FWindow := form;
end;

destructor TCalendarPaintAction.Destroy;
begin
    // do nothing
end;

procedure TCalendarPaintAction.doAction;
begin
    FColorManager.updateColorWithoutUndo(FDay, FPaintedColor);
    FWindow.CalendarRepaint;
    FWindow.setDirty;
end;

procedure TCalendarPaintAction.undoAction;
begin
    FColorManager.updateColorWithoutUndo(FDay, FOriginalColor);
    FWindow.CalendarRepaint;
    FWindow.setDirty;
end;


end.
