unit CalendarPrinter;
// 印刷用クラス
// TCalendarPrinter を生成して使う．
// 内部的には，印刷用に特化した（解像度調整の付いた）
//  TCellRenderer クラスを使って描画処理を行う

interface

uses
    Graphics, SysUtils, Forms, Types, Math, Printers, Classes, DateUtils,
    CellRenderer, CalendarConfig, Windows, plPrev, CalendarFont;

type
    TCaptionPosition = (None, TopLeft, TopCenter, TopRight, BottomLeft, BottomCenter, BottomRight);

    TCellRendererForPreview = class (TCellRenderer)

    private
        FPreview: TplPrev;
    protected

        function isVisibleDay(baseDate: TDateTime; day: TDateTime): boolean; override;
        function createRgn(left, top, right, bottom: integer): HRGN; override;
    public
        procedure setFont(font: TFont); override;
        procedure setFontColor(cl: TColor); override;
        procedure setDayFontColor(cl: TColor); override;
        constructor Create(canvas:TCanvas; fonts: TCalendarConfiguration; prev: TplPrev);
    end;

    TCalendarPrinter = class
    private
        // F付きは外部からもらってくる情報
        FConfiguration: TCalendarConfiguration;
        FFreeMemoRatio: integer;
        FFreeMemoColumns : integer;
        FTodoRatio: integer;
        FFileName: string;
        FStartDate, FEndDate: TDateTime;
        FAutoWeeks: boolean;

        FPreview: TplPrev;

        FCaptionFont: TFont;
        FCaptionPos : TCaptionPosition;
        FLineWidth: Integer;
        FLineColor: TColor;
        FLayoutStyle: integer;

        //
        Printing : boolean;

        Canvas: TCanvas;
        Renderer: TCellRenderer;
        DrawSizeRatio: integer;

        CellWidth: integer;          // 日付セルのサイズ
        CellHeight: integer;
        BodyWidth: integer;          // カレンダーエリアのサイズ
        BodyHeight: integer;
        HorizontalMargin: integer;   // 紙の余白
        VerticalMargin: integer;
        HeaderHeight: integer;       // ヘッダ（ファイル名など描画部）高さ
        FooterHeight: integer;       // フッタ描画部高さ
        DayHeaderHeight: integer;    // カレンダーエリアのうち曜日名描画部分の高さ
        FreeMemoHeight: integer;     // フリーメモエリアのサイズ


        CELL_MARGIN : integer;


        procedure adjustRectToInnerFrame(var rect: TRect);
        procedure drawString(left, right, top, bottom: integer; s: string);
        procedure drawStringWithAlign(left, right, top, bottom: integer; s: string; pos: TCaptionPosition);
        procedure drawFreeMemo(left, right, top, bottom: integer);
        procedure drawTodoList(left, right, top, bottom: integer);
        procedure calcRect(ACol, ARow: integer; var rect: TRect);

        procedure setFreeMemoColumns(columns: integer);

        function makeTitle: string;
        function getWeeks(baseDate: TDateTime): integer;

    public

        constructor Create(config: TCalendarConfiguration; prev: TplPrev);
        destructor Destroy; override;

        procedure setup;
        function PageCount: integer;
        procedure Print;
        procedure Preview;
        procedure DrawPage(page: integer);
        procedure DrawPageForPreview;

        procedure setCaptionFont(font: TFont; pos: TCaptionPosition);
        property FreeMemoRatio: integer read FFreeMemoRatio write FFreeMemoRatio;
        property FileName: string read FFileName write FFileName;
        property StartDate: TDateTime read FStartDate write FStartDate;
        property EndDate: TDateTime read FEndDate write FEndDate;
        property FreeMemoColumns: integer read FFreeMemoColumns write setFreeMemoColumns;
        property TodoRatio: integer read FTodoRatio write FTodoRatio;
        property LineColor: TColor read FLineColor write FLineColor;
        property LineWidth: integer read FLineWidth write FLineWidth;
        property LayoutStyle: integer read FLayoutStyle write FLayoutStyle;
        property AutoWeeks: boolean read FAutoWeeks write FAutoWeeks;
    end;

    function CaptionPositionToInteger(pos: TCaptionPosition): integer;
    function IntegerToCaptionPosition(pos: integer): TCaptionPosition;

const
      LAYOUT_STYLE_NORMAL = 0;
      LAYOUT_STYLE_TWO_PART = 1;


implementation

uses
    CalendarPreview, DocumentManager, TodoUpdateManager, TodoList;


function CaptionPositionToInteger(pos: TCaptionPosition): integer;
begin
    case pos of
    TopCenter:
        Result := 0;
    TopLeft:
        Result := 1;
    TopRight:
        Result := 2;
    BottomCenter:
        Result := 3;
    BottomLeft:
        Result := 4;
    BottomRight:
        Result := 5;
    None:
        Result := 6;
    else
        Result := 0;
    end;
end;

function IntegerToCaptionPosition(pos: integer): TCaptionPosition;
begin
    case pos of
    0: Result := TopCenter;
    1: Result := TopLeft;
    2: Result := TopRight;
    3: Result := BottomCenter;
    4: Result := BottomLeft;
    5: Result := BottomRight;
    6: Result := None;
    else Result := TopCenter;
    end;

end;



function hasFooter(pos: TCaptionPosition): boolean;
begin
    case pos of
    TopLeft:
        Result := False;
    TopCenter:
        Result := False;
    TopRight:
        Result := False;
    BottomLeft:
        Result := True;
    BottomCenter:
        Result := True;
    BottomRight:
        Result := True;
    None:
        Result := false;
    else
        Result := false;
    end;
end;

function hasHeader(pos: TCaptionPosition): boolean;
begin
    Result := not hasFooter(pos) and (pos <> None);
end;


function TCellRendererForPreview.createRgn(left, top, right, bottom: integer): HRGN;
begin
    Result := CreateRectRgn(Round(Left * FCanvas.Font.PixelsPerInch / 254.0) ,
                            Round(Top * FCanvas.Font.PixelsPerInch / 254.0),
                            Round(Right * FCanvas.Font.PixelsPerInch / 254.0),
                            Round(Bottom * FCanvas.Font.PixelsPerInch / 254.0) );
end;

procedure TCellRendererForPreview.setFontColor(cl: TColor);
begin
    FPreview.FontColor(cl);
    ensureOtherMonthColor;
end;

procedure TCellRendererForPreview.setDayFontColor(cl: TColor);
begin
    FPreview.FontColor(cl);
    // Don't use other month color.  cl already reflects the property.
end;

function TCellRendererForPreview.isVisibleDay(baseDate: TDateTime; day: TDateTime): boolean;
begin
    Result := (StartOfTheMonth(BaseDate) <= day)and(day <= EndOfTheMonth(BaseDate)) or not Configuration.OtherMonthPrintSkip;
end;


procedure TCellRendererForPreview.setFont(font: TFont);
begin
    FPreview.FontName(Font.Name);
    FPreview.FontSize(Font.Size);
    FPreview.FontColor(Font.Color);
    FPreview.FontStyle(Font.Style);
    ensureOtherMonthColor;
end;


constructor TCellRendererForPreview.Create(canvas:TCanvas; fonts: TCalendarConfiguration; prev: TplPrev);
begin
    inherited Create(canvas, clWhite, clWhite, fonts);
    FPreview := prev;
end;



function TCalendarPrinter.getWeeks(baseDate: TDateTime): integer;
var
  days: integer;

  function isEndOfWeek(d: TDateTime): boolean;
  begin
      Result := ((FConfiguration.StartOfWeek = 1) and (DayOfWeek(d) = 7)) or
               ((FConfiguration.StartOfWeek = 2) and (DayOfWeek(d) = 1));
  end;

begin
    if FAutoWeeks then begin
        days := DaysInMonth(baseDate);
        case days of
        28: Result := IfThen(DayOfWeek(baseDate) = FConfiguration.StartOfWeek, 4, 5);
        29: Result := 5;
        30: Result := IfThen(isEndOfWeek(baseDate), 6, 5);
        31: Result := IfThen(isEndOfWeek(baseDate) or isEndOfWeek(IncDay(baseDate, 1)), 6, 5);
        else
            Result := 6;
        end;
    end else Result := 6;
end;

constructor TCalendarPrinter.Create(config: TCalendarConfiguration; prev: TplPrev);
begin
    FConfiguration := config;
    FFreeMemoRatio := 0;
    FPreview := prev;
    FLineWidth := 1;
    FLineColor := clBlack;
    FAutoWeeks := true;
    renderer := nil;
end;

destructor TCalendarPrinter.Destroy;
begin
    if renderer <> nil then renderer.Free;
end;

procedure TCalendarPrinter.setFreeMemoColumns(columns: integer);
begin
    if (columns <= 0) or (columns > 2) then columns := 1;
    FFreeMemoColumns := columns;
end;

function TCalendarPrinter.makeTitle: string;
begin
    Result := ExtractFileName(filename) + ' - hyCalendar';
end;

procedure TCalendarPrinter.setCaptionFont(font: TFont; pos: TCaptionPosition);
begin
    FCaptionFont := font; // 参照コピーだけなので captionFont は Free 不要
    FCaptionPos := pos;
end;


function TCalendarPrinter.PageCount: integer;
var
    i: integer;
    day: TDateTime;
begin
    i := 0;
    day := StartDate;
    while day <= EndDate do begin
        inc(i);
        day := IncMonth(day, 1);
    end;
    Result := i;
end;

procedure TCalendarPrinter.adjustRectToInnerFrame(var rect: TRect);
// CELL_MARGIN で表現されるポイント分，Rect を内側に小さくする
begin
    with Rect do begin
        Left   := Left   + CELL_MARGIN * DrawSizeRatio;
        Top    := Top    + CELL_MARGIN * DrawSizeRatio;
        Right  := Right  - CELL_MARGIN * DrawSizeRatio;
        Bottom := Bottom - CELL_MARGIN * DrawSizeRatio;
    end;
end;

procedure TCalendarPrinter.setup;
var
    h: integer;
    width, height: integer;

    procedure swapValue(var x, y: integer);
    var
        t: integer;
    begin
        t := x;
        x := y;
        y := t;
    end;

begin
    if renderer <> nil then renderer.Free;
    if Printing then begin
        // 印刷時はプリンターの情報を直接扱う．
        width := Printer.PageWidth;
        height := Printer.PageHeight;
        Canvas := Printer.Canvas;
        renderer := TCellRenderer.Create(Canvas, clWhite, clWhite, FConfiguration);
        DrawSizeRatio := 5 * Ceil( Canvas.Font.PixelsPerInch / 254.0 ); // アバウトだが元の "1" = 0.5mm とみなす
        if DrawSizeRatio <= 0 then DrawSizeRatio := 5;
        CELL_MARGIN := 2;
    end else begin
        // FPreview によってスケーリング単位が変更されているのでこうなる
        Canvas := FPreview.Canvas;
        width  := FPreview.PaperWidth;
        height := FPreview.PaperHeight;
        renderer:= TCellRendererForPreview.Create(Canvas, FConfiguration, FPreview);
        DrawSizeRatio := 5; // 1mm 単位で指定されるので，CELL_MARGIN などの "1" 単位を 0.5mm とみなす
        CELL_MARGIN := 2;
    end;
    renderer.FontMap := TPrinterFontMap.Create(FConfiguration);
    renderer.DrawSizeRatio := DrawSizeRatio;
    renderer.IndicateToday := false;

    VerticalMargin := height div 16;

    // 枠の幅の計算
    if LayoutStyle = LAYOUT_STYLE_NORMAL then begin
        // 端 日 月 火 水 木 金 土 端  （端=1/2)
        HorizontalMargin := width div 16;
        BodyWidth := width - 2 * HorizontalMargin;
        CellWidth := BodyWidth div 7;
    end else begin
        // 端 日 月 火 水 空間 木 金 土 空間 端 （空間=1, 端=1/2) 
        HorizontalMargin := width div 20;
        BodyWidth := width - 2 * HorizontalMargin;
        CellWidth := BodyWidth div 9;
    end;


    Renderer.setFont(FCaptionFont);
    h := Canvas.TextHeight('W');
//    renderer.setFont(FConfiguration.DayFont);
//    h := max(Canvas.TextHeight('W'), h);

    HeaderHeight    := h * 2;
    FooterHeight    := 0;

    if FCaptionPos = None then
        HeaderHeight := 0;

    if hasFooter(FCaptionPos) then
        swapValue(HeaderHeight, FooterHeight);


    BodyHeight      := height - 2 * VerticalMargin - HeaderHeight - FooterHeight;
    FreememoHeight  := (BodyHeight * FreeMemoRatio) div 100;
    BodyHeight      := BodyHeight - HeaderHeight - FooterHeight - FreeMemoHeight;

end;

procedure TCalendarPrinter.drawStringWithAlign(left, right, top, bottom: integer; s: string; pos: TCaptionPosition);
begin
    case pos of
    TopLeft:
        drawString(left, left+ Canvas.TextWidth(s), top, top + Canvas.TextHeight(s), s);
    TopCenter:
        drawString(left, right, top, top + Canvas.TextHeight(s), s);
    TopRight:
        drawString(right - Canvas.TextWidth(s), right, top, top + Canvas.TextHeight(s), s);
    BottomLeft:
        drawString(left, left+ Canvas.TextWidth(s), bottom, bottom - Canvas.TextHeight(s), s);
    BottomCenter:
        drawString(left, right, bottom, bottom - Canvas.TextHeight(s), s);
    BottomRight:
        drawString(right - Canvas.TextWidth(s), right, bottom, bottom - Canvas.TextHeight(s), s);
    end;

end;

procedure TCalendarPrinter.drawString(left, right, top, bottom: integer; s: string);
var
    w, h: integer;
begin
    w := Canvas.TextWidth(s);
    h := Canvas.TextHeight(s);
    Canvas.TextOut((left + right - w) div 2, (top + bottom - h) div 2,s);
end;

procedure TCalendarPrinter.drawFreeMemo(left, right, top, bottom: integer);
var
    i: integer;
    y: integer;
    h: integer;

    rect: TRect;     // 描画領域全体
    textarea: TRect; // テキスト１個描く用

    col : integer;
    width, nextColumn: integer;
    clipped: boolean;

    freeMemo: TStringList;
begin
    freeMemo := TStringList.Create;
    TDocumentManager.getInstance.findVisibleFreeMemo(freeMemo);

    h := Canvas.TextHeight('W');

    // 外枠を作る
    Canvas.Pen.Color := FLineColor;  //clBlack;
    Canvas.Pen.Width := FLineWidth;
    if LayoutStyle = LAYOUT_STYLE_NORMAL then begin
        rect.Left   := left;
        rect.Right  := right;
        rect.Top    := top;
        rect.Bottom := bottom;
        Canvas.Rectangle(rect);
    end else begin
        // LAYOUT_STYLE_TWO_PART
        // ２分割時は２つの枠で描画

        // 中間の微妙な位置が右端のときは，そこをあらかじめ取り除く
        if (Right > left + CellWidth * 4) and (Right < left + CellWidth * 5) then
            Right := left + CellWidth * 4;

        rect.Left   := left;
        rect.Right  := left + CellWidth * 4;
        rect.Top    := top;
        rect.Bottom := bottom;
        Canvas.Rectangle(rect);
        rect.Left   := left + CellWidth * 5;
        rect.Right  := right;
        if rect.Left < rect.Right then Canvas.Rectangle(rect);
        rect.Left := left;
    end;

    adjustRectToInnerFrame(rect);

    // フォント設定　
    renderer.setFont(renderer.FontMap.FreeMemoFont);

    // 幅設定 (２分割時は，いちおう真ん中を避けるように動作)
    if LayoutStyle = LAYOUT_STYLE_NORMAL then begin
        width   := (Rect.Right - Rect.left - HorizontalMargin * (FFreeMemoColumns - 1)) div FFreeMemoColumns;
        nextColumn := width + HorizontalMargin;
    end else begin
        width   := CellWidth * 4;
        nextColumn := width + CellWidth;
    end;

    // 描画開始
    clipped := false;
    i := 0;
    col := 0;
    y  := Rect.Top;
    while (i < freeMemo.Count) and (col < FFreeMemoColumns) do begin
        // 文字列の描画位置設定
        textarea.Top    := y;
        textarea.Bottom := y + h;
        textarea.Left   := Rect.Left + col * nextColumn;
        textarea.Right  := textarea.Left + width;

        DrawText(Canvas.Handle, PChar(FreeMemo[i]), Length(FreeMemo[i]), textarea, DT_WORDBREAK or DT_CALCRECT or DT_WORD_ELLIPSIS);
        if (textarea.Bottom >= rect.Bottom) then begin
            inc(col);
            y := Rect.Top;
            continue;
        end else begin
            textarea.Right := textarea.Left + width;
            if (textarea.Bottom = y + h) and (Canvas.TextWidth(FreeMemo[i]) > width) then clipped := true;
            DrawText(Canvas.Handle, PChar(FreeMemo[i]), Length(FreeMemo[i]), textarea, DT_WORDBREAK or DT_WORD_ELLIPSIS);
            inc(i);
            y := textarea.Bottom + 1;
        end;
    end;

    // はみ出したらクリッピングマーク描画
    if clipped or (i < FreeMemo.Count) then begin
        Renderer.drawClippedMark(rect);
    end;

    freeMemo.Free;
end;


procedure TCalendarPrinter.drawTodoList(left, right, top, bottom: integer);
var
    i: integer;
    y: integer;
    h: integer;

    rect: TRect;     // 描画領域全体
    textarea: TRect; // テキスト１個描く用

    width: integer;
    clipped: boolean;

    s: string;

    todolist: TStringList;
    todoManager: TTodoUpdateManager;
    todoItem: TTodoItem;
begin
    todoManager := TTodoUpdateManager.getInstance;
    todolist := TStringList.Create;
    todoManager.findAllVisibleTodoItems(todolist);

    h := Canvas.TextHeight('W');

    // フォント設定　
    renderer.setFont(renderer.FontMap.TodoViewFont);

    // 外枠を作る
    rect.Left   := left;
    rect.Right  := right;
    rect.Top    := top;
    rect.Bottom := bottom;

    width := Rect.Right - Rect.Left - Canvas.TextWidth('W') * 2;

    Canvas.Pen.Color := FLineColor;  //clBlack;
    Canvas.Pen.Width := FLineWidth;
    Canvas.Rectangle(rect);
    adjustRectToInnerFrame(rect);

    // 描画開始
    clipped := false;
    i := 0;
    y  := Rect.Top;


    while (i < todoList.Count) do begin
        todoItem := todoList.Objects[i] as TTodoItem;

        // 「チェック済みTODOは隠す」が指定されている場合
        if FConfiguration.HideCompletedTodo and
            todoItem.Checked then begin
            inc(i);
            continue;
        end;


        // 文字列の描画位置設定
        textarea.Top    := y;
        textarea.Bottom := y + h;
        if (textarea.Bottom >= rect.Bottom) then begin
            textarea.Bottom := rect.Bottom-1;
            clipped := true;
        end;
        textarea.Left   := Rect.Left + Canvas.TextWidth('W');
        textarea.Right  := Rect.Right - Canvas.TextWidth('W');

        // サイズ計算
        if todoItem.Checked then
            s := '■ ' + todoItem.Name
        else
            s := '□ ' + todoItem.Name;
        DrawText(Canvas.Handle, PChar(s), Length(s), textarea, DT_WORDBREAK or DT_CALCRECT or DT_WORD_ELLIPSIS);

        if (textarea.Bottom >= rect.Bottom) then begin
            // はみ出している場合はとばす
            clipped := true;
            break;
        end else begin
            // 実際の描画
            textarea.Right := textarea.Left + width;
            if (textarea.Bottom = y + h) and (Canvas.TextWidth(s) > width) then clipped := true;
            DrawText(Canvas.Handle, PChar(s), Length(s), textarea, DT_WORDBREAK or DT_WORD_ELLIPSIS);

            inc(i);
            y := textarea.Bottom + 1;
        end;
    end;

    // はみ出したらクリッピングマーク描画
    if clipped or (i < todoList.Count) then begin
        Renderer.drawClippedMark(rect);
    end;

    todoList.Free;
end;


procedure TCalendarPrinter.DrawPage(page: integer);
var
    BaseDate: TDateTime;
    row, col: integer;
    rect: TRect;
    day: TDateTime;
    b: boolean;
    h: integer;
begin
    h := Canvas.TextHeight('W');

    if (page < 1)or(page > PageCount) then exit;
    baseDate := IncMonth(StartDate, page-1);

    DayHeaderHeight := BodyHeight div (getWeeks(baseDate) * 3 + 1); // 1週は3HeaderHeight
    CellHeight      := DayHeaderHeight * 3;


    // ヘッダ, フッタ描画
    renderer.setFont(FCaptionFont);
    if hasFooter(FCaptionPos) then begin
        drawStringWithAlign(HorizontalMargin, HorizontalMargin + BodyWidth,
                   VerticalMargin + HeaderHeight + BodyHeight + h + FreeMemoHeight,
                   VerticalMargin + HeaderHeight + BodyHeight + h + FreeMemoHeight + FooterHeight,
                   FormatDateTime('yyyy"年"m"月"', BaseDate), FCaptionPos);
    end else if hasHeader(FCaptionPos) then begin
        drawStringWithAlign(HorizontalMargin, HorizontalMargin + BodyWidth, VerticalMargin, VerticalMargin + HeaderHeight, FormatDateTime('yyyy"年"m"月"', BaseDate), FCaptionPos);
    end;
//    renderer.setFont(FConfiguration.DayFont);
//    Canvas.TextOut(HorizontalMargin, VerticalMargin, ExtractFileName(filename));

    // 曜日（第一行）描画
    for col:=0 to 6 do begin
        calcRect(col, 0, rect);
        adjustRectToInnerFrame(rect);
        renderer.drawNameOfDay(rect, col);
    end;

    // 本体描画
    for row:=1 to getWeeks(baseDate) do begin
        for col:=0 to 6 do begin
            calcRect(col, row, rect);
            //adjustRectToInnerFrame(rect);
            day := renderer.ConvertPosToDay(BaseDate, 0, col, row);
            if AutoWeeks and (FConfiguration.StartOfWeek =  DayOfWeek(BaseDate)) then day := IncDay(day, 7);

            renderer.draw(rect, BaseDate, day, false, b);
        end;
    end;

    // 枠描画
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Color := FLineColor;
    Canvas.Pen.Width := FLineWidth;

    if LayoutStyle = LAYOUT_STYLE_NORMAL then begin
        for row:=0 to getWeeks(BaseDate)+1 do begin
            calcRect(7, row, rect);
            Canvas.MoveTo(HorizontalMargin, Rect.Top);
            Canvas.LineTo(rect.Left, rect.Top);
        end;
        for col:=0 to 7 do begin
            calcRect(col, getWeeks(BaseDate)+1, rect);
            Canvas.MoveTo(rect.Left, VerticalMargin + HeaderHeight);
            Canvas.LineTo(rect.Left, Rect.Top);
        end;
    end else begin
        // LAYOUT_STYLE_TWO_PART
        for row:=0 to getWeeks(BaseDate)+1 do begin
            // 左４列の右端まで横線
            calcRect(3, row, rect);
            Canvas.MoveTo(HorizontalMargin, Rect.Top);
            Canvas.LineTo(rect.Right, rect.Top);
            // 右
            calcRect(4, row, rect);
            Canvas.MoveTo(Rect.Left, Rect.Top);
            calcRect(7, row, rect);
            Canvas.LineTo(rect.Right, rect.Top);
        end;
        for col:=0 to 8 do begin
            calcRect(col, getWeeks(BaseDate)+1, rect);
            Canvas.MoveTo(rect.Left, VerticalMargin + HeaderHeight);
            Canvas.LineTo(rect.Left, Rect.Top);
        end;
        // 左４列目の右はしだけ縦線を追加
        calcRect(3, getWeeks(BaseDate)+1, rect);
        Canvas.MoveTo(rect.Right, VerticalMargin + HeaderHeight);
        Canvas.LineTo(rect.Right, Rect.Top);

    end;

    // フリーメモ，TODOを描く
    if LayoutStyle = LAYOUT_STYLE_NORMAL then begin
        if FreeMemoRatio > 0 then begin
            if (TodoRatio < 100) then begin
                drawFreeMemo(HorizontalMargin,
                             HorizontalMargin + ((BodyWidth * (100-TodoRatio)) div 100),
                             VerticalMargin + HeaderHeight + BodyHeight + h,
                             VerticalMargin + HeaderHeight + BodyHeight + h + FreeMemoHeight);
            end;
            if (TodoRatio > 0) then begin
                drawTodoList(HorizontalMargin + ((BodyWidth * (100-TodoRatio)) div 100),
                             HorizontalMargin + BodyWidth,
                             VerticalMargin + HeaderHeight + BodyHeight + h,
                             VerticalMargin + HeaderHeight + BodyHeight + h + FreeMemoHeight);
            end;
        end;
    end else begin
        if FreeMemoRatio > 0 then begin
            if TodoRatio >= 40 then begin
                drawFreeMemo(HorizontalMargin,
                             HorizontalMargin + CellWidth * 4,
                             VerticalMargin + HeaderHeight + BodyHeight + h,
                             VerticalMargin + HeaderHeight + BodyHeight + h + FreeMemoHeight);
                drawTodoList(HorizontalMargin + CellWidth * 5,
                             HorizontalMargin + BodyWidth,
                             VerticalMargin + HeaderHeight + BodyHeight + h,
                             VerticalMargin + HeaderHeight + BodyHeight + h + FreeMemoHeight);
            end else begin
                drawFreeMemo(HorizontalMargin,
                             HorizontalMargin + ((BodyWidth * (100-TodoRatio)) div 100),
                             VerticalMargin + HeaderHeight + BodyHeight + h,
                             VerticalMargin + HeaderHeight + BodyHeight + h + FreeMemoHeight);
                if (TodoRatio > 0) then begin
                    drawTodoList(HorizontalMargin + ((BodyWidth * (100-TodoRatio)) div 100),
                                 HorizontalMargin + BodyWidth,
                                 VerticalMargin + HeaderHeight + BodyHeight + h,
                                 VerticalMargin + HeaderHeight + BodyHeight + h + FreeMemoHeight);
                end;
            end;
        end;
    end;
end;

procedure TCalendarPrinter.calcRect(ACol, ARow: integer; var rect: TRect);
// ACol, ARow で与えられるセルの位置を rect に計算する
begin
    // TWO_PART の場合，4-6 列目を右にずらして座標計算
    if (LayoutStyle = LAYOUT_STYLE_TWO_PART) and (ACol > 3) then ACol := ACol + 1;

    rect.Left := HorizontalMargin + CellWidth * ACol;
    rect.Right := rect.Left + CellWidth - 1;

    if ARow = 0 then begin
        rect.Top := VerticalMargin + HeaderHeight;
        rect.Bottom := rect.Top + DayHeaderHeight - 1;
    end else begin
        rect.Top := VerticalMargin + HeaderHeight + DayHeaderHeight + CellHeight * (ARow-1);
        rect.Bottom := rect.Top + CellHeight - 1;
    end;
end;

procedure TCalendarPrinter.DrawPageForPreview;
begin
    setup;
    DrawPage(FPreview.PageNumber);
end;

procedure TCalendarPrinter.Preview;
begin
    FPreview.Title := makeTitle;
    FPreview.PageCount := PageCount;
    FPreview.ProcName := DrawPageForPreview;
    Printing := False;
    frmCalendarPrintPreview.OnPrintClick := self.Print;
    //FPreview.SetPaperInfo;
    FPreview.ViewWidth := FPreview.PaperWidth;
    FPreview.ViewHeight := FPreview.PaperHeight;

    FPreview.ShowModal;
end;

procedure TCalendarPrinter.Print;
var
    i: integer;
begin
    Printing := true;
    try
        Printer.Title := makeTitle;
        Printer.BeginDoc;
        setup;
        for i:=1 to PageCount do begin
            DrawPage(i);
            if (i < PageCount) then Printer.NewPage;
        end;
        Printer.EndDoc;
    except
        Printer.Abort;
    end;
    Printing := false;
end;



end.
