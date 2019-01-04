unit CellRenderer;

interface

uses Graphics, Classes, Controls, Types, SysUtils,
    Math, DateUtils,
    RangeItem, WIndows, URLScan, StrUtils, Grids,
    CalendarItem, StringSplitter, CalendarConfig,
    DocumentManager, RangeItemReferenceList,
    CalendarFont, ColoredStringList;

const
    WINDOWS_PEN_STYLE_PERIOD = 24; // 24�|�C���g�ŁCWindows �y���̃p�^�[���͈������
    DAY_PER_WEEK = 7;

type

    // �J�����_�[�̃Z����`�悷�邽�߂̃N���X
    // �p��F BaseDate -- �`�悵�悤�Ƃ��Ă���P�����̐擪�̓��D
    //        �������J�����_�[�͂P�������L���͈͂�`�����߁C
    //        draw ���\�b�h���̂�BaseDate���O�̓��Ȃǂ��w�肳�ꂤ��D
    TCellRenderer = class
    private

        FMarkingString : string;
        FMarkingMode : integer;
        FDayNameBackColor: TColor;
        FCellBackColor: TColor;      // �Z���w�i�F�i������͔��ɐݒ肳���j
        FGridLineWidth : integer;

        FSplitter : TStringSplitter; // �����R�X�g�ȗ����̂��߂Ƀ����o�ϐ�
        FTextAttrSplitter: TStringSplitter;

        FDocumentManager: TDocumentManager;

        FConfiguration: TCalendarConfiguration;
        FFonts: TFontMap;


        FDrawSizeRatio: integer;  // �\���g�嗦�D�ʏ�͂P�C ������̓v�����^�ɉ����đ傫���Ȃ�
        FIndicateToday: boolean;  // false �̂Ƃ��́u�����v�J�[�\����\�����Ȃ�

        // �ʒu�����p
        FMarginX : integer;
        FMarginY : integer;
        FTextMargin: integer;
        FMaximumArrowHeight: integer;

        // �u���̌��̃f�[�^�v�`�惂�[�h��L���ɂ���
        FOtherMonthFlag: boolean;

        function ArrowHeadSize(penWidth: integer): integer;
        function MidPos(left, right, width: integer): integer;

        procedure drawCursor(rect: TRect; color: TColor; width: integer);
        procedure drawString(x, y, width: integer; text: string; var clipped: boolean);
        procedure drawArrowHead(x, y: integer; isLeftSide: boolean; PenWidth: integer);

        function drawTodoItems(rect: TRect; y: integer; day: TDateTime; var clipped: boolean): integer;
        function drawSeriesItems(rect: TRect; y: integer; day: TDateTime; var clipped: boolean): integer;
        function drawRangeItems(rect: TRect; y: integer; base, day: TDate; Ranges: TRangeItemReferenceList; backcolor: TColor; var clipped: boolean): integer;
        procedure drawRangeItem(rect: TRect; y: integer; backcolor: TColor; base, day: TDate; range: TRangeItem; var clipped: boolean);
        function drawCellText(rect: TRect; y: integer; dayItem: TStringList; var clipped: boolean): integer;
        function drawCellHead(rect: TRect; day, base: TDate; var clipped: boolean): integer;

        procedure outputWrapText(s: string; rect: TRect; start_left, dy: integer; var x, y: integer; var clipped: boolean);

        procedure setDrawSizeRatio(new_value: integer);

        procedure setOtherMonthFlag(d: TDate; base: TDate);
        procedure resetOtherMonthFlag;
        procedure setFontMap(fonts: TFontMap);

    protected
        FCanvas: TCanvas;
        procedure ensureOtherMonthColor;
        function isVisibleDay(baseDate: TDateTime; day: TDateTime): boolean; virtual;
        function createRgn(left, top, right, bottom: integer): HRGN; virtual;

        property Configuration: TCalendarConfiguration read FConfiguration;
    public
        constructor Create(canvas:TCanvas; dayname_backcolor, cell_backcolor: TColor; fonts: TCalendarConfiguration);
        destructor Destroy; override;
        procedure draw(rect: TRect; base: TDate; day: TDate; cellSelected: boolean; var clipped: boolean);
        procedure drawNameOfDay(rect: TRect; col: integer);
        procedure drawClippedMark(rect: TRect);

        function getTextOffset: integer;
        property DrawSizeRatio: integer read FDrawSizeRatio write setDrawSizeRatio;
        property Marking: string read FMarkingString write FMarkingString;
        property MarkingMode: integer read FMarkingMode write FMarkingMode;
        property IndicateToday: boolean read FIndicateToday write FIndicateToday;
        function ConvertPosToDay(BaseDate: TDateTime; BaseDateBack: integer; ACol, ARow: integer): TDateTime;
        procedure ConvertDayToPos(BaseDate, Target: TDateTime; BaseDateBack: integer; var ACol, ARow: integer);


        procedure setFont(font: TFont); virtual;
        procedure setFontColor(cl: TColor); virtual;
        procedure setDayFontColor(cl: TColor); virtual;

        function findURL(x, y: integer; day: TDateTime; var position: TRect): string;

        property Canvas : TCanvas write FCanvas;
        property CellBackColor: TColor read FCellBackColor write FCellBackColor;
        property FontMap: TFontMap read FFonts write setFontMap;
    end;

    function compareURLPos(Item1, Item2: Pointer): Integer;


implementation

uses DateValidation, TodoList;


function TCellRenderer.ConvertPosToDay(BaseDate: TDateTime; BaseDateBack: integer; ACol, ARow: integer): TDateTime;
begin
    // ���̌��̂P���ڂ��܂񂾏T�� ���j(�������͎w�肵���j��) ��
    // ����̃Z���ɂȂ�悤�ɒ��������ꍇ�́C�Z���̈ʒu�ɑ����������t��Ԃ��D
    // StartOfTheWeek(BaseDate)�͌��j��Ԃ��i��: ISO 8601 �K�i�ł́C���j����n�܂�j
    Result := IncDay(StartOfTheWeek(BaseDate),  // ���̌��̂P���ڂ��܂񂾏T�̌��j����_�ɂ���
                     - BaseDateBack +
                     (ARow - 1 - IfThen((FConfiguration.StartFromMonday)
                                        and(StartOfTheWeek(BaseDate)=BaseDate), 1, 0)
                     ) * DAY_PER_WEEK +
                      (ACol-(2-FConfiguration.StartOfWeek)) );   // ���j��0���. StartOfWeek �͓��j�Ȃ�1�C���j�Ȃ�2��Ԃ�
end;

// �t�H���g�ݒ�DCanvas �Ƀt�H���g�𒼐ڐݒ�ł��Ȃ��ꍇ�ɃI�[�o�[���C�h����
procedure TCellRenderer.setFont(font: TFont);
begin
    FCanvas.Font := Font;
    ensureOtherMonthColor;
end;

procedure TCellRenderer.setFontColor(cl: TColor);
begin
    FCanvas.Font.Color := cl;
    ensureOtherMonthColor;
end;

procedure TCellRenderer.setDayFontColor(cl: TColor);
begin
    FCanvas.Font.Color := cl;
    // Don't use other month color.  cl already reflects the property.
end;

procedure TCellRenderer.setFontMap(fonts: TFontMap);
var
    oldFonts: TFontMap;
begin
    oldFonts := FFonts;
    FFonts := fonts;
    oldFonts.Free;
end;


// �`�悵�����Ȃ������q�N���X�ŃI�[�o�[���C�h����D
function TCellRenderer.isVisibleDay(baseDate: TDateTime; day: TDateTime): boolean;
begin
    Result := true;
end;


// ���̌��̃f�[�^��`�悷��ۂɃt�H���g�̐F���D�F������葱���D
// ���̌���`�悵�Ă��邩�ǂ�����FOtherMonthFlag
procedure TCellRenderer.ensureOtherMonthColor;
begin
    if FConfiguration.UseOtherMonthColorForContents and FOtherMonthFlag then
        FCanvas.Font.Color := FConfiguration.OtherMonthColor;
end;

// ���̌��̃f�[�^��`�悵�Ă��邩�ǂ����̃t���O�ݒ�
procedure TCellRenderer.setOtherMonthFlag(d: TDate; base: TDate);
begin
    FOtherMonthFlag := (d < StartOfTheMonth(base))or(d > EndOfTheMonth(base));
end;

procedure TCellRenderer.resetOtherMonthFlag;
begin
    FOtherMonthFlag := false;
end;


procedure TCellRenderer.ConvertDayToPos(BaseDate, Target: TDateTime; BaseDateBack: integer; var ACol, ARow: integer);
var
    i: integer;
begin
    i := BaseDateBack + DaysBetween(IncDay(StartOfTheWeek(BaseDate), FConfiguration.StartOfWeek-2), Target);
    ARow := 1 + i div 7 - IfThen((FConfiguration.StartFromMonday)and(StartOfTheWeek(BaseDate)=BaseDate), -1, 0);
    ACol := i mod 7;
end;


constructor TCellRenderer.Create(canvas:TCanvas; dayname_backcolor, cell_backcolor: TColor; fonts: TCalendarConfiguration);
begin
    FDocumentManager := TDocumentManager.getInstance;
    FCanvas := canvas;
    FConfiguration := fonts;
    FSplitter := TStringSplitter.Create;
    FTextAttrSplitter := TStringSplitter.Create(FConfiguration.TextAttrTag);
    FDayNameBackColor := dayname_backcolor;
    FCellBackColor := cell_backcolor;
    FGridLineWidth := 1;
    FIndicateToday := true;
    FFonts := TFontMap.Create(fonts);

    DrawSizeRatio:= 1;

end;

destructor TCellRenderer.Destroy;
begin
    FSplitter.Free;
    FTextAttrSplitter.Free;
    FFonts.Free;
end;

function TCellRenderer.MidPos(left, right, width: integer): integer;
begin
    Result := left + Floor((right - left - width) / 2);
end;


procedure TCellRenderer.setDrawSizeRatio(new_value: integer);
begin
    FDrawSizeRatio := new_value;
    FMarginX := 2 * FDrawSizeRatio;
    FMarginY := 2 * FDrawSizeRatio;
    FTextMargin := 6 * FDrawSizeRatio;  // ���ԗ\��̕�����̍��E�[�̃}�[�W��
    FMaximumArrowHeight := 1 + 2 * ArrowHeadSize(5); // ���ԗ\��̂P�s�̏c��
end;

function TCellRenderer.ArrowHeadSize(penWidth: integer): integer;
begin
    // ���̐�[�T�C�Y���y�����ɏ]���Ē����i��ʏ�ł͌Œ�l�j
    // 2 * ArrowHeadSize + 1  = ���̍����D
    // penWidth * FDrawSizeRatio = �v�����^�ł̒��������̍���
    if FDrawSizeRatio = 1 then Result := 4
    else Result := Max(2 * FDrawSizeRatio, Round(0.8 * penWidth * FDrawSizeRatio));
end;


procedure TCellRenderer.drawNameOfDay(rect: TRect; col: integer);
var
    x, y: integer;
    DayOfWeek: integer;
begin
    DayOfWeek := ((Col + (FConfiguration.StartOfWeek - 1)) mod 7)+1;
    setFont(FFonts.DayNameFont);

    FCanvas.Brush.Color := FDayNameBackColor;
    FCanvas.FillRect(rect);

    x := midPos(Rect.Left, Rect.Right , FCanvas.TextWidth(ShortDayNames[DayOfWeek]));
    y := midPos(Rect.Top,  Rect.Bottom, FCanvas.TextHeight(ShortDayNames[DayOfWeek]));
    // ShortDayNames �́CISO 8601 �ƈقȂ邽�� DaySunday �萔�͎g���Ă��Ȃ�
    if (DayOfWeek = 1) then setFontColor(FConfiguration.SundayColor)
    else if (DayOfWeek = 7) then setFontColor(FConfiguration.SaturdayColor);

    FCanvas.TextOut(x, y, ShortDayNames[DayOfWeek]);
end;

function TCellRenderer.createRgn(left, top, right, bottom: integer): HRGN;
begin
    Result := CreateRectRgn(left, top, right, bottom);
end;

procedure TCellRenderer.draw(rect: TRect; base: TDate; day: TDate; cellSelected: boolean; var clipped: boolean);
var
    dy: integer;
    items: TStringList;

    Region: HRGN;

    backcolor: TColor;
    Ranges: TRangeItemReferenceList;
begin
    if not isVisibleDay(base, day) then Exit;
    

    clipped := false;

    // �Z���̔w�i��h��Ԃ�
    if isValid(day) then begin
        backcolor := FDocumentManager.BackColor(day);
        if backcolor = clDefault then backcolor := FCellBackColor;
        if ((day < base)or(day>=IncMonth(base,1))) and (FConfiguration.OtherMonthBackColor <> clDefault) then begin
            backcolor := FConfiguration.OtherMonthBackColor;
        end;

    end else begin
        backcolor := FCellBackColor;
    end;

    setOtherMonthFlag(day, base);

    FCanvas.Brush.Color := backcolor;

    FCanvas.FillRect(Rect);

    Region := createRgn(Rect.Left + 1, Rect.Top + 1, Rect.Right - 1, Rect.Bottom - 1);

    if isValid(day) then begin

        // �����ɊY������Ȃ� background �`��
        if FDocumentManager.TextMatch(day, Marking, MarkingMode) then begin
            backColor := FConfiguration.MarkingColor;
            FCanvas.Brush.Color := FConfiguration.MarkingColor;
            FCanvas.FillRect(Rect);
        end;

        // ���ݓ��C�I����̃J�[�\���\��
        if FIndicateToday and (day = Date) then drawCursor(rect, FConfiguration.TodayCursorColor, FConfiguration.TodayCursorWidth);
        if cellSelected then drawCursor(rect, FConfiguration.SelectCursorColor, FConfiguration.SelectCursorWidth);

        // ���t�\��
        SelectClipRgn(FCanvas.Handle, Region);
        dy := drawCellHead(rect, day, base, clipped);
        SelectClipRgn(FCanvas.Handle, 0);


        // ���t�̒��g�\��
        ranges := FDocumentManager.getRangeItems(day);
        if ranges <> nil then begin
            dy := drawRangeItems(rect, dy, base, day, ranges, backColor, clipped);
        end else begin
            dy := dy + FMarginY;
        end;

        SelectClipRgn(FCanvas.Handle, Region);

        dy := drawTodoItems(rect, dy, day, clipped);

        dy := drawSeriesItems(rect, dy, day, clipped);

        setFont(FFonts.TextFont);
        FCanvas.Pen.Color := FFonts.TextFont.Color;

        items := FDocumentManager.getDayItems(day);
        drawCellText(rect, dy, items, clipped);
        FDocumentManager.cleanupDayItems(items);

        if clipped then drawClippedMark(rect);

        SelectClipRgn(FCanvas.Handle, 0);

    end else begin
        // ���ݓ��C�I����̃J�[�\���\��
        if FIndicateToday and (day = Date) then drawCursor(rect, FConfiguration.TodayCursorColor, FConfiguration.TodayCursorWidth);
        if cellSelected then drawCursor(rect, FConfiguration.SelectCursorColor, FConfiguration.SelectCursorWidth);

    end;
    DeleteObject(Region);

    resetOtherMonthFlag;


end;

function TCellRenderer.drawRangeItems(rect: TRect; y: integer; base, day: TDate; Ranges: TRangeItemReferenceList; backcolor: TColor; var clipped: boolean): integer;
var
    text_h : integer;
    region : HRGN;
    dy  : integer;
    offset : integer;
    i : integer;
begin

    // �����ʒu�v�Z
    setFont(FFonts.DayFont);

    // ���ԗ\��̃t�H���g�ɐݒ�
    setFont(FFonts.RangeItemFont);
    text_h := max(FCanvas.TextHeight('A'), FMaximumArrowHeight);
    offset := y + FMarginY; // * 2 + FCanvas.TextHeight('A');
    dy := offset;

    // ���ԗ\��p�N���b�s���O

    Region := CreateRgn(Rect.Left, Rect.Top + 1,
                         Rect.Right+ FGridLineWidth, Rect.Bottom - 1);
    SelectClipRgn(FCanvas.Handle, Region);

    for i:=0 to Ranges.Count-1 do begin
        if FDocumentManager.IsVisibleDocument(Ranges[i].Owner) then begin // ���͂����CVisible �Ȃ��̂������X�g�ɒǉ����ĂȂ��̂ňӖ��Ȃ�
            y := offset + Ranges[i].Rank * text_h;
            drawRangeItem(rect, y, backcolor, base, day, Ranges[i], clipped);
            dy := Max(y + text_h, dy);
        end;
    end;

    SelectClipRgn(FCanvas.Handle, 0); // Clipping ����
    DeleteObject(Region);

    Result := dy;
end;


procedure TCellRenderer.drawCursor(rect: TRect; color: TColor; width: integer);
begin
    FCanvas.Brush.Style := bsClear;
    FCanvas.Pen.Color := color;
    FCanvas.Pen.Style := psInsideFrame;
    FCanvas.Pen.Width := width;
    FCanvas.Rectangle(Rect);
end;



// ���t��`�悷��
function TCellRenderer.drawCellHead(rect: TRect; day, base: TDate; var clipped: boolean): integer;
const DAYNAME_SEPARATOR = '�C';
var
    headrect: TRect;
    s: string;
    daynames: TColoredStringList;
    i: integer;
    x: integer;  // �e�L�X�g�`��ʒu
    cl : TColor;
    y: integer;

    function getDayNameColor(day, base: TDateTime; dayFontColor: TColor): TColor;
    begin
        // ���E�j���ɂ��F�ݒ�
        Result := dayFontColor;
        if (day < StartOfTheMonth(base))or(day>EndOfTheMonth(base)) then begin
            if FDocumentManager.isHoliday(day) then Result := FConfiguration.OtherMonthSundayColor
            else Result := FConfiguration.OtherMonthColor;
        end else if FDocumentManager.isHoliday(day) then begin
            Result := FConfiguration.SundayColor;
        end else if DayOfTheWeek(day) = DaySaturday then begin
            Result := FConfiguration.SaturdayColor;
        end;
    end;

begin
    setFont(FFonts.DayFont);

    // ���t������̍쐬
    if (day < base)or(day>=IncMonth(base,1)) then
        s := FormatDateTime('m/d', day)
    else s := FormatDateTime('d', day);

    cl := getDayNameColor(day, base, FFonts.DayFont.Color);

    // ���t�����ɐF��h��
    FCanvas.Brush.Color := FDocumentManager.HeadColor(day);
    if FCanvas.Brush.Color = clDefault then FCanvas.Brush.Style := bsClear;
    if ((day < base)or(day >= IncMonth(base, 1))) and
        (FConfiguration.OtherMonthBackColor <> clDefault) then
            FCanvas.Brush.Style := bsClear; // �w�i���łɓh���Ă���̂ŁC�����ł͉����h��Ȃ�
    
    headrect.Top  := rect.Top;
    headRect.Left := rect.Left;
    headRect.Right := Rect.Left + FMarginX + FCanvas.TextWidth(s);
    headRect.Bottom := Rect.Top + FMarginY + FCanvas.TextHeight(s);
    FCanvas.FillRect(headrect);
    FCanvas.Brush.Color := FCellBackColor;
    FCanvas.Brush.Style := bsClear;

    // ���t�̐�����`��
    setDayFontColor(cl);
    x := Rect.Left + FMarginX;
    drawString(x, Rect.Top + FMarginY, Rect.Right - Rect.Left - 2 * FMarginX, s, clipped);
    x := x + FCanvas.TextWidth(s);
    x := x + FCanvas.TextWidth(' ');
    y := Rect.Top + FMarginY + FCanvas.TextHeight(s);

    // ���t�̎��̍s�� y ���W���v�Z���Ė߂�l�Ƃ���
    setFont(FFonts.HolidayNameFont);
    Result := Max(y, Rect.Top + FMarginY + FCanvas.TextHeight('A'));

    // ���t����`��
    daynames := FDocumentManager.DayNames(day, base, clDefault);
    for i:=0 to daynames.Count-1 do begin
      if dayNames.isUserColor(i) then setFontColor(daynames.Color(i))
      else setDayFontColor(getDayNameColor(day, base, FFonts.HolidayNameFont.Color));

      drawString(x, Rect.Top + FMarginY, Rect.Right - Rect.Left - 2 * FMarginX, daynames.Text(i), clipped);
      // ���͕��ʂɐi�߂�
      x := x + FCanvas.TextWidth(daynames.Text(i));

      // �܂���������Ȃ�C�Z�p���[�^����
      if (i < daynames.Count-1) then begin
        drawString(x, Rect.Top + FMarginY, Rect.Right - x - FMarginX, DAYNAME_SEPARATOR, clipped);
        x := x + FCanvas.TextWidth(DAYNAME_SEPARATOR);
      end;
      if clipped then break;

    end;
    daynames.Free;
end;


// ���ԗ\��̂P�̃A�C�e����`��
procedure TCellRenderer.drawRangeItem(rect: TRect; y: integer; backcolor: TColor; base, day: TDate; range: TRangeItem; var clipped: boolean);
var
    height: integer;
    center: integer;
    leftmargin, rightmargin : integer;

    width : integer;

    i : integer;
    lx, rx, ly: integer;

    // �_���̊J�n�ʒu������v�Z
    function getLineStartOffset(day, start_date: TDate; Rect: TRect): integer;
    var
        width : integer; // �Z����
        cycle : integer;
    begin
        if (day = start_date) then begin
          Result := 0;
          exit;
        end;
        width := Rect.Right - Rect.Left + 1;
        cycle := WINDOWS_PEN_STYLE_PERIOD * getDeviceCaps(FCanvas.Handle,LOGPIXELSX); // �P�����̃s�N�Z����(�Q�S�_���C���`�łP���[�v�j
        if cycle = 0 then cycle := WINDOWS_PEN_STYLE_PERIOD;
        Result :=  -((width - ArrowHeadSize(range.PenWidth) ) mod cycle)  // 1���ڂ� ARROW_HEAD_SIZE �������
                   - (((width mod cycle) * ((DaysBetween(range.StartDate, day)-1)mod cycle)) mod cycle)   ;  // 2���ڈȍ~�͌Œ蕝�ł���Ă���(mod cycle �̓I�[�o�[�t���[�h�~)

    end;

    function isFirstColumn(d: TDateTime): boolean;
    begin
        Result := (not FConfiguration.StartFromMonday and
                   (DayOfTheWeek(day)=daySunday)) or
                  (FConfiguration.StartFromMonday and
                   (DayOfTheWeek(day)=dayMonday));
    end;

    function isSkipped(d: TDateTime): boolean;
    begin
        Result := range.SkipYoubi[DayOfWeek(d)] or
                  (range.SkipHoliday and FDocumentManager.isActualHoliday(d));
    end;

    function LeftArrowIsDrawn(d: TDateTime): boolean;
    begin
        Result := ( (range.StartDate = d) or isSkipped(IncDay(d, -1)) ) and
                  ( (range.ArrowType = ARROWTYPE_BOTH) or ((range.ArrowType = ARROWTYPE_LEFT_ONLY)) ) ;
    end;

    function RightArrowIsDrawn(d: TDateTime): boolean;
    begin
        Result := ( (range.EndDate = d) or isSkipped(IncDay(d, 1)) ) and
                  ( (range.ArrowType = ARROWTYPE_BOTH) or ((range.ArrowType = ARROWTYPE_RIGHT_ONLY)) ) ;
    end;

    function CaptionIsDrawn(d: TDateTime): boolean;
    var
        yesterday: TDateTime;
    begin
        yesterday := IncDay(d, -1);
       Result := (range.StartDate = d) or
                 isFirstColumn(d) or
                 isSkipped(yesterday) or
                 not isVisibleDay(base, yesterday);
    end;

begin

    setFont(FFonts.RangeItemFont);
    FCanvas.Pen.Color := Range.Color;
    FCanvas.Pen.Style := psSolid;
    height := FCanvas.TextHeight('A');
    center := y+(height div 2);

    // �͂ݏo�����疳��
    if y + height >= rect.Bottom then begin
        clipped := true;
        exit;
    end;

    if isSkipped(day) then begin
        exit;
    end;

    // ���ԗ\��̒����`��: �_���̏ꍇ�ł��O�̃Z���̏I�_���炫����ƌq�����Č�����悤�ɂ���
    FCanvas.Pen.Style := Range.LineStyle;
    lx := Rect.Left;
    if LeftArrowIsDrawn(day) then lx := lx + ArrowHeadSize(range.PenWidth)
    else lx := lx + getLineStartOffset(day, range.StartDate, rect);
    rx := Rect.Right + FGridLineWidth;
    if RightArrowIsDrawn(day) then rx := rx - ArrowHeadSize(range.PenWidth);

    FCanvas.Pen.Width := 1;

    for i:=1 to range.PenWidth * FDrawSizeRatio do begin
        ly := center + IfThen(Odd(i), ((i-1) div 2), -(i div 2));
        FCanvas.Brush.Color := backColor;
        FCanvas.Pen.Color := clBlack;
        FCanvas.Pen.Mode  := pmMask;
        FCanvas.Pen.Style := Range.LineStyle;
        FCanvas.MoveTo(lx, ly);
        FCanvas.LineTo(rx, ly);

        FCanvas.Brush.Color := clBlack;
        FCanvas.Pen.Color := Range.Color;
        if FConfiguration.UseOtherMonthColorForContents and FOtherMonthFlag then
            FCanvas.Pen.Color := FConfiguration.OtherMonthColor;
        
        FCanvas.Pen.Mode  := pmMerge;
        FCanvas.Pen.Style := Range.LineStyle;
        FCanvas.MoveTo(lx, ly);
        FCanvas.LineTo(rx, ly);

    end;

    // ���ԗ\��̍��E�[�̖��`��
    FCanvas.Pen.Mode := pmCopy;
    FCanvas.Pen.Style := psSolid;
    FCanvas.Pen.Color := Range.Color;
    FCanvas.Brush.Color := Range.Color;
    if FConfiguration.UseOtherMonthColorForContents and FOtherMonthFlag then begin
        FCanvas.Pen.Color := FConfiguration.OtherMonthColor;
        FCanvas.Brush.Color := FConfiguration.OtherMonthColor;
    end;

    leftmargin := FTextMargin;
    rightmargin := FTextMargin;

    if LeftArrowIsDrawn(day) then begin
        drawArrowHead(Rect.Left, center, true, range.PenWidth);
        leftmargin := FTextMargin + ArrowHeadSize(range.PenWidth);
    end;
    if RightArrowIsDrawn(day) then begin
        drawArrowHead(Rect.Right-1, center, false, range.PenWidth);
        rightmargin := FTextMargin + ArrowHeadSize(range.PenWidth);
    end;

    FCanvas.Brush.Color := backColor;

    width := Rect.Right - rightmargin - Rect.Left - leftmargin;

    // �������`��
    if CaptionIsDrawn(day) then begin

        if range.IsDayTextColor then setFontColor(FFonts.RangeItemFont.Color)
        else setFontColor(Range.TextColor);

        drawString(Rect.Left + leftmargin, y, width, range.Text, clipped);

    end;

end;


// TODO ���X�g�̂������t�������̂�`��
function TCellRenderer.drawTodoItems(rect: TRect; y: integer; day: TDateTime; var clipped: boolean): integer;
var
    i: integer;
    //matcher: TTodoMatcher;
    matchResult: TStringList;
    x: integer;

    function removeDateFromString(s: string): string;
    begin
        if FConfiguration.HideDaystringTodoOnCalendar then begin
            Result := URLSCan.TURLExtractor.getInstance.removeDateFromString(s);
        end else begin
            Result := s;
        end;
    end;

begin
    if not FConfiguration.ShowTodoItems then begin
        Result := y;
        exit;
    end;

    setFont(FFonts.TodoFont);

    matchResult := FDocumentManager.matchTodo(day);

    if FConfiguration.CalendarItemWordWrap then begin
        for i:=0 to matchResult.Count-1 do begin
            x := rect.Left + FMarginX;
            outputWrapText(removeDateFromString(matchResult[i]), rect, x, FCanvas.TextHeight('A'), x, y, clipped);
            y := y + FCanvas.TextHeight('A');
        end;
    end else begin
        for i:=0 to matchResult.Count-1 do begin
            drawString(rect.Left + FMarginX, y, rect.Right - FMarginX * 2 - rect.Left, removeDateFromString(matchResult[i]), clipped);
            y := y + FCanvas.TextHeight('A');
        end;
    end;

    if y > Rect.Bottom then clipped := true;
    Result := y;
end;

// �����\��̒��g��`��
function TCellRenderer.drawSeriesItems(rect: TRect; y: integer; day: TDateTime; var clipped: boolean): integer;
var
    i: integer;
    x: integer;
    items: TColoredStringList;
begin
    items := FDocumentManager.DayText(day, FFonts.SeriesPlanItemFont.Color);
    for i:=0 to items.Count-1 do begin
        setFont(FFonts.SeriesPlanItemFont);
        setFontColor(items.Color(i));
        if FConfiguration.CalendarItemWordWrap then begin
            x := rect.Left + FMarginX;
            outputWrapText(items.Text(i), rect, x, FCanvas.TextHeight('A'), x, y, clipped);
        end else begin
            drawString(rect.Left + FMarginX, y, rect.Right - FMarginX * 2 - rect.Left, items.Text(i), clipped);
        end;
        y := y + FCanvas.TextHeight('A');
        if y > rect.Bottom then begin
          clipped := true;
          break;
        end;
    end;
    Result := y;
    items.Free;
end;


procedure TCellRenderer.drawArrowHead(x, y: integer; isLeftSide: boolean; penwidth: integer);
var
    points: array[0..2] of TPoint;
    arrow: integer;
begin
    arrow := IfThen(isLeftSide, ArrowHeadSize(PenWidth), -ArrowHeadSize(PenWidth));
    points[0].X := x;
    points[0].Y := y;
    points[1].X := x + arrow;
    points[1].Y := y - arrow;
    points[2].X := x + arrow;
    points[2].Y := y + arrow;
    FCanvas.Polygon(points);
end;

procedure TCellRenderer.drawString(x, y, width: integer; text: string; var clipped: boolean);
var
    len: integer;
    s  : string;
begin
    // ������͂ݏo���Ă���Ƃ��͖����� "..." �ɒu��������
    len := FCanvas.TextWidth('...');

    if FCanvas.TextWidth(text) > width then begin
        s := Text;
        while (FCanvas.TextWidth(s) + len > width)and(Length(WideString(s))>0) do begin
            s := LeftStr(s, Length(WideString(s))-1);
        end;
        s := s + '...';
        FCanvas.TextOut(x, y, s);
        clipped := true;
    end else begin
        FCanvas.TextOut(x, y, Text);
    end;

end;

procedure TCellRenderer.drawClippedMark(rect: TRect);
var
    points: array [0..2] of TPoint;

    procedure setTriangle(base, size: integer);
    begin
        points[0].X := Rect.Right - base - size;
        points[0].Y := Rect.Bottom - base;
        points[1].X := Rect.Right - base;
        points[1].Y := Rect.Bottom - base;
        points[2].X := Rect.Right - base;
        points[2].Y := Rect.Bottom - base - size;
    end;

begin
    FCanvas.Brush.Color := FCellBackColor;
    FCanvas.Pen.Width := 1;
    FCanvas.Pen.Color := FCellBackColor;
    FCanvas.Pen.Style := psSolid;
    setTriangle(2 + 1 * (DrawSizeRatio-1), 10 + 3 * (DrawSizeRatio-1));
    if (points[0].X < Rect.Left) or (points[2].Y < Rect.Top) then exit;
    FCanvas.Polygon(points);
    FCanvas.Pen.Color := FConfiguration.ClippedMarkColor;
    FCanvas.Brush.Color := FConfiguration.ClippedMarkColor;
    setTriangle(3 + 2 * (DrawSizeRatio-1), 6 + 3 * (DrawSizeRatio-1));
    FCanvas.Polygon(points);
    FCanvas.Brush.Color := FCellBackColor;
end;


// �܂�Ԃ��������`��
// ������ �`�悵����������C�`��͈�(rect)�C
// �������ʒu(start_left)�C���s��(dy)�C
// �`��J�n�ʒu�ix, y: ���̕`��J�n�ʒu�֍X�V�����j�C
// �N���b�s���O�ΏۂƂȂ������ǂ����̋L�^�ϐ�
procedure TCellRenderer.outputWrapText(s: string; rect: TRect; start_left, dy: integer; var x, y: integer; var clipped: boolean);
var
    r: integer;
    s2: string;
    idx: integer;

    function findWrapPoint(x: integer; s: string; idx, diff: integer): integer;
    var
        r: integer;
        w: integer;
    begin
        r := x + FCanvas.TextWidth(AnsiLeftStr(s, idx));
        w := FCanvas.TextWidth(AnsiMidStr(s, idx+1, 1));
        if (idx = 0)and(r > rect.Right) then Result := 0
        else if (idx >= Length(WideString(s)))and(r <= rect.Right) then result := idx
        else if (r <= rect.Right) and (r + w > rect.Right) then Result := idx
        else if (r <= rect.Right) then begin
           idx := idx + diff;
           diff := Max(diff div 2, 1);
           result := findWrapPoint(x, s, idx, diff);
        end else begin
           idx := idx - diff;
           diff := Max(diff div 2, 1);
           result := findWrapPoint(x, s, idx, diff);
        end;
    end;

begin
    r := x + FCanvas.TextWidth(s);
    if r > rect.Right then begin
        if FConfiguration.CalendarItemWordWrap then begin
            // �K�؂ȒP�ʂŕ�����𕪊�
            idx := Length(WideString(s)) div 2;
            idx := findWrapPoint(x, s, idx, Max(idx div 2, 1));

            s2 := AnsiRightStr(s, Length(WideString(s)) - idx);
            s  := AnsiLeftStr(s, idx);
            FCanvas.TextOut(x, y, s);
            x := start_left;
            y := y + dy;
            outputWrapText(s2, rect, start_left, dy, x, y, clipped);
            if y >= Rect.Bottom then clipped := true; 
            exit;
        end else begin
            clipped := true;
        end;
    end;
    FCanvas.TextOut(x, y, s);
    x := r;
end;



function TCellRenderer.drawCellText(rect: TRect; y: integer; dayItem: TStringList; var clipped: boolean): integer;
const
    MAX_LINK = 16;
var
    start_left : integer;

    s: string;
    i: integer;
    line: integer;
    urlpos: TURLPosition;

    hyperlinks : TStrings;

    idx: integer;

    x : integer;
    c : integer;
    urls : TList;
    url: string;

    dy : integer;

    fontSize: integer;
    fontStyle: TFontStyles;
    fontColor: TColor;
    activeAttr: TTextAttribute;

    procedure storeFont;
    begin
        fontSize := FCanvas.Font.Size;
        fontStyle := FCanvas.Font.Style;
        fontColor := FCanvas.Font.Color;
    end;
    procedure restoreFont;
    begin
        FCanvas.Font.Size := fontSize;
        FCanvas.Font.Style := fontStyle;
        FCanvas.Font.Color := fontColor;
    end;


    procedure drawColoredText(line: string; var x, y: integer; var lastAttribute: TTextAttribute);
    var
        attr, attr2 : TTextAttribute;
        skipnext: boolean;
        s: string;

    begin
        skipnext := false;

        if FTextAttrSplitter.separator <> FConfiguration.TextAttrTag then FTextAttrSplitter.resetSeparator(FConfiguration.TextAttrTag);

        FTextAttrSplitter.setString(line);

        while FTextAttrSplitter.hasNext do begin
            if skipnext then begin
                // ����������̎��� FConfiguration.TextAttrTag �܂ł͒ʏ핶����
                outputWrapText(FTextAttrSplitter.getLine, rect, start_left, dy, x, y, clipped);
                skipnext := false;
            end else begin
                s := FTextAttrSplitter.getLine;
                if FTextAttrSplitter.isFirst then begin
                    // �ŏ���COLOR_TAG���O�͒ʏ핶����
                    outputWrapText(s, rect, start_left, dy, x, y, clipped);
                    //output(s);
                end else if not FTextAttrSplitter.hasNext then begin
                    // �Ō��TAG����͒ʏ핶����
                    outputWrapText(FConfiguration.TextAttrTag + s, rect, start_left, dy, x, y, clipped);
                    //output(FConfiguration.TextAttrTag + s);
                end else begin
                    attr := FConfiguration.GetTextAttribute(s);
                    if attr <> nil then begin
                        // �K�p���ꂽ�����o���Ă����i�n�C�p�[�����N�ɉe����^���邩�ǂ����`�F�b�N�p�j
                        lastAttribute := attr;

                        // ����������̌��ʓK�p
                        if (attr.Color <> clDefault) then setFontColor(attr.Color)
                        else setFontColor(FFonts.TextFont.Color);
                        FCanvas.Font.Style := attr.Style;
                        skipnext := true; // TAG �̎��̕�����͕K���ʏ핶����
                        // ������������u�\������v�Ȃ炻�̂܂ܕ\��

                        attr2 := FConfiguration.GetPredefinedTextAttribute(s);
                        if FConfiguration.HidePredefinedTextAttrOnDayItem and FConfiguration.HideTextAttrOnDayItem and
                           (attr2 <> nil) and (attr2 = attr) then begin // predefined �� User-defined �ŃI�[�o�[���C�h�����\��������
                           skipnext := true;
                        end else if (not FConfiguration.HidePredefinedTextAttrOnDayItem) and FConfiguration.HideTextAttrOnDayItem and (attr <> nil) then begin
                            skipnext := true;
                        end else begin
                            outputWrapText(FConfiguration.TextAttrTag + s + FConfiguration.TextAttrTag, rect, start_left, dy, x, y, clipped);
                        end;


                    end else begin
                        // ����������łȂ��ꍇ�CCOLOR_TAG ���g���o��
                        outputWrapText(FConfiguration.TextAttrTag + s, rect, start_left, dy, x, y, clipped);
                    end;


                end;
            end;
        end;
    end;

begin
    urls := TList.Create;

    for idx := 0 to dayItem.Count-1 do begin

        hyperlinks := dayItem.Objects[idx] as TStrings;

        line := 0;
        FSplitter.setString(dayItem[idx]);
        while FSplitter.hasNext do begin

            s := FSplitter.getLine;

            // URL��\���ł���URL�����Ȃ��s�̏ꍇ�C���̍s��
            if FConfiguration.HideHyperlinkString and
               (TURLExtractor.getInstance.removeURLString(s) = '') then begin

                if hyperlinks <> nil then begin
                    for i:=0 to hyperlinks.Count-1 do begin
                        urlpos := TURLPosition(hyperLinks.Objects[i]);
                        if (urlpos <> nil) and (line = urlpos.line) then urlpos.visible := false;
                    end;
                end;
                inc(line);
                continue; // ���̍s�֐i��
            end;


            // URL �̃����N����Ă��镔���𒊏o
            urls.Clear;
            if hyperlinks <> nil then begin
                for i:=0 to hyperLinks.Count-1 do begin
                    urlpos := TURLPosition(hyperLinks.Objects[i]);
                    if (urlpos <> nil) and (line = urlpos.line) then begin
                        urls.Add(urlpos);
                        urlpos.visible := false;
                    end;
                end;
                urls.Sort(compareURLPos);
            end;

            // �`��J�n�ʒu�Ɖ��s���̐ݒ�
            start_left := Rect.Left + FMarginX;
            setFont(FFonts.TextFont);
            dy := FCanvas.TextHeight(s);
            setFont(FFonts.HyperlinkFont);
            dy := IfThen(dy < FCanvas.TextHeight(s), FCanvas.TextHeight(s), dy);
            dy := dy + IfThen(DrawSizeRatio > 1, DrawSizeRatio, 0); // ������́C���s���̕�������𑽏��傫�߂ɐݒ�
            setFont(FFonts.TextFont);

            // �擪����`��J�n
            activeAttr := nil;
            i := 0;
            c := 1;
            x := start_left;
            while c <= Length(s) do begin
                if i < urls.Count then urlpos := TURLPosition(urls[i])
                else urlpos := nil;

                if (urlpos = nil)or(c < urlpos.col) then begin

                    setFont(FFonts.TextFont);
                    if urlpos = nil then begin
                        // �����܂ŏo��
                        drawColoredText(Copy(s, c, Length(s)), x, y, activeAttr);
                        c := Length(s) + 1;
                    end else begin
                        // ���̃t�H���g�ω��ʒu�܂ŏo��
                        drawColoredText(Copy(s, c, urlpos.col - c), x, y, activeAttr);
                        c := urlpos.col;
                    end;
                end else begin
                    // ���̃t�H���g�ω��ʒu�܂Ńn�C�p�[�����N��������o��
                    url := Copy(s, urlpos.col, urlpos.len);
                    if not FConfiguration.HideHyperlinkString or TURLExtractor.getInstance.isDateURL(url) then begin
                        storeFont; // �����Ńt�H���g����ޔ�

                        if (activeAttr = nil) or (not FConfiguration.TextAttrOverrideHyperlinkFont) then
                            setFont(FFonts.HyperlinkFont);

                        urlpos.left := x;
                        urlpos.top := y;

                        FCanvas.TextOut(x, y, url);
                        x := x + FCanvas.TextWidth(url);

                        if (x > Rect.Right) then clipped := true;

                        urlpos.right := ifthen(x < rect.Right, x, rect.Right);
                        urlpos.bottom := urlpos.top + FCanvas.TextHeight(url);
                        urlpos.bottom := IfThen(urlPos.bottom < rect.Bottom, urlpos.bottom, rect.Bottom);
                        urlpos.visible := (urlpos.Left < rect.Right)and(urlpos.Top < rect.Bottom);

                        restoreFont; // �����Ńt�H���g���𕜋�
                    end;
                    c := urlpos.col + urlpos.len;
                    inc (i);
                end;;
            end;

            // ���s
            y := y + dy;

            // �݂͂����L�^
            if  (x > Rect.Right)or(y > Rect.Bottom) then begin
                clipped := true;
            end;

            inc(line);
        end;

    end;
    urls.Free;

    Result := y;
end;

function compareURLPos(Item1, Item2: Pointer): Integer;
var
    pos1, pos2: TURLPosition;
begin
    pos1 := TURLPosition(Item1);
    pos2 := TURLPosition(Item2);
    Result := pos1.col - pos2.col + IfThen(pos1.col = pos2.col, pos1.len - pos2.len );
end;

function TCellRenderer.getTextOffset: integer;
begin
    setFont(FFonts.TextFont);
    Result := FCanvas.TextHeight('A');
end;


function TCellRenderer.findURL(x, y: integer; day: TDateTime; var position: TRect): string;
var
    urlpos : TURLPosition;
    url : string;
    i: integer;
    hyperlinks: TStrings;

begin
    // CellRenderer �� TURLPosition �Ɋ��蓖�Ă����W�𒲂ׂ� URL ��������
    Result := '';

    // 1.0 ���: ������ getItem �̂����� DocumentManager �ɖ₢���킹��
    hyperlinks := TDocumentManager.getInstance.getHyperlinks(day);

    for i:=0 to hyperLinks.Count-1 do begin
        urlpos := TURLPosition(hyperLinks.Objects[i]);
        if (urlpos <> nil )and (urlpos.visible) and (urlpos.top <= y) and
           (y <= urlpos.bottom) and (urlpos.left <= x) and (x <= urlpos.right) then begin
            url := hyperLinks.Strings[i];
            Result := url;

            position.Left := urlpos.left;
            position.Top  := urlpos.top;
            position.Right := urlpos.right;
            position.Bottom := urlpos.bottom;
        end;
    end;

    TDocumentManager.getInstance.cleanupHyperlinks(hyperlinks);
end;

end.
