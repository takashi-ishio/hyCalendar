unit CalendarDocument;
// .cal ファイル１個に対応
// 日付メモ，フリーメモ，期間予定，周期予定をファイル単位で管理する
// 表示する際は，TDocumentManager によって，
// フリーメモ，期間予定，周期予定それぞれ別個に管理される

interface

uses DateUtils, SysUtils, Classes, CalendarItem,  Controls, Graphics, Types,
    Contnrs, RangeItemList, StrUtils, SeriesItem, Constants, TodoList,
    RangeItem, StringSplitter, ColorManager, AbstractDocument,
    SeriesItemSerialize, SeriesItemManager, CountdownItem, Windows;

type

  CalendarLoadException = class(Exception);

  TCalendarDocument = class(TAbstractCalendarDocument)
  private
    FFilename: TFilename;
    FDocumentLock: THandle;

    // ファイルの中身
    FItems: array [MIN_YEAR..MAX_YEAR, 1..12] of TCalendarItemMonth; // 日付メモ
    FRangeItems: TRangeItemList;                                     // 期間予定
    FSeriesItems: TSeriesItemList;                                   // 周期予定
    FTodoItems: TTodoList;                                           // TODOリスト
    FFreeMemo: TStrings;                                             // フリーメモ
    FColorManager: TPaintColorManager;                               // 着色情報
    FCountdownItems: TObjectList;

    FDirty: boolean;
    FMaxDate: TDate;
    FMinDate: TDate;
    FLastErrorString: string;

    procedure clear;
    procedure parseColor(text: string; var cl1, cl2: TColor; var secondIsDisable: boolean );
    procedure setFilename(name: TFilename);

    procedure ReadDayItem(var idx: integer; f: TStrings);
    procedure ReadRangeItem(var idx: integer; f: TStrings);
    procedure ReadCountdownItem(var idx: integer; f: TStrings);

    procedure LockFile(filename: string);
    procedure UnlockFile;


  protected
    function getFilename: TFilename; override;

  public

    constructor Create;
    destructor Destroy; override;

    function createRangeItem(start_date, end_date: TDate; caption: string; color: TColor; textcolor: TColor; isDayTextColor: boolean; penWidth, penStyle, arrowType, skipDays: integer): TRangeItem;
    procedure freeRangeItem(item: TRangeItem);

    procedure addCountdownItem(item: TCountdownItem);
    procedure freeCountdownItem(item: TCountdownItem);
    procedure exchangeCountdownItem(idx1, idx2: integer);
    function getCountdownItem(idx: integer): TCountdownItem;
    function getCountdownItemCount: integer;
    procedure validateCountdownItems;

    procedure updateSeriesItem(manager: TSeriesItemManager); override;

    procedure setItem(item: TCalendarItem);
    function getItem(day: TDate): TCalendarItem; override;
    function getItemOrCreate(day: TDate): TCalendarItem;

    procedure SaveAs(filename: TFileName);
    function LoadFrom(filename: TFileName): boolean; virtual;

    function FindText(s: string; base: TDateTime; direction: Integer; and_or: integer; CaseSensitive: boolean; var ret: TDateTime): boolean;

    function locked: boolean;

    function getDayText(day: TDate): string;
    procedure setDayText(day: TDate; s: string);

    property RangeItems: TRangeItemList read FRangeItems;
    property TodoItems: TTodoList read FTodoItems;
    property SeriesItems: TSeriesItemList read FSeriesItems;
    property FreeMemo : TStrings read FFreeMemo write FFreeMemo;
    property ColorManager: TPaintColorManager read FColorManager;
    property Dirty : boolean read FDirty write FDirty;
    property MaxDate: TDate read FMaxDate;
    property MinDate: TDate read FMinDate;
    property LastErrorString: string read FLastErrorString;


  end;





implementation

uses
    JclDebug,
    DateFormat, DateValidation;


const
    HEADER_STRING = 'hyCALENDAR DATAFILE';
    RANGEITEM_HEADER = '__RANGEITEM_HEADER__';
    SERIESITEM_HEADER = '__SERIESITEM_HEADER__';
    FREEMEMO_HEADER = '__FREEMEMO_HEADER__';
    TODO_HEADER = '__TODO_HEADER__';
    COLOR_HEADER = '__COLOR_HEADER__';
    COUNTDOWN_HEADER = '__COUNTDOWN_HEADER__';

    COLOR_DELIMITER = ',';

    DELIMITER_STRING = #12;

    NO_TITLE_RANGE_ITEM = '(無題)'; // バグで発生した名前なしの期間予定への対応

type
    THeaderKind = (hkRange, hkSeries, hkTodo, hkColor, hkCountdown, hkFreeMemo, hkNone);

function isHeaderString(line: string): THeaderKind;
begin
    if AnsiStartsStr('__', line) then begin
      if RANGEITEM_HEADER = line then Result := hkRange
      else if SERIESITEM_HEADER = line then Result := hkSeries
      else if COLOR_HEADER = line then Result := hkColor
      else if TODO_HEADER = line then Result := hkTodo
      else if COUNTDOWN_HEADER = line then Result := hkCountdown
      else if FREEMEMO_HEADER = line then Result := hkFreeMemo
      else Result := hkNone;
    end else Result := hkNone;
end;


constructor TCalendarDocument.Create;
begin
    inherited;
    FRangeItems := TRangeItemList.Create;
    FSeriesItems := TSeriesItemList.Create;
    FTodoItems := TTodoList.Create;
    FColorManager := TPaintColorManager.Create;
    FCountdownItems := TObjectList.Create(TRUE);
    setFilename('');
    FFreeMemo := TStringList.Create;
    FMaxDate := 0;
    FMinDate := Date;
end;

procedure TCalendarDocument.UnlockFile;
begin
    if FDocumentLock <> 0 then begin
        CloseHandle(FDocumentLock);
        FDocumentLock := 0;
    end;
end;

function TCalendarDocument.locked: boolean;
begin
    Result := FDocumentLock <> 0;
end;

procedure TCalendarDocument.LockFile(filename: string);
begin
    if (filename <> '') then begin
        UnlockFile;
        FDocumentLock := CreateFile(PAnsiChar(filename),
                                    GENERIC_READ or GENERIC_WRITE,
                                    FILE_SHARE_READ,
                                    nil,
                                    OPEN_ALWAYS,
                                    FILE_ATTRIBUTE_NORMAL,
                                    0);
        if (GetLastError <> NOERROR) and (GetLastError <> ERROR_ALREADY_EXISTS) then begin
            // ロック失敗; 既に他のプロセスがこのファイルをロックしているなどの場合
            FDocumentLock := 0;
        end;
    end;
end;

procedure TCalendarDocument.clear;
var
    y, m : integer;
begin
    FSeriesItems.Clear;
    FTodoItems.Clear;
    FRangeItems.FreeAllItems;
    FColorManager.Clear;
    FFreeMemo.Clear;
    FCountdownItems.Clear;
    for y:=MIN_YEAR to MAX_YEAR do begin
        for m:=1 to 12 do begin
            if FItems[y, m] <> nil then begin
                FItems[y, m].Free;
                FItems[y, m] := nil;
            end;
        end;
    end;
    FDirty := false;
    FMaxDate := 0;
    FMinDate := Date;
end;


destructor TCalendarDocument.Destroy;
begin
    UnlockFile;
    Clear;
    FRangeItems.Free;
    FSeriesItems.Free;
    FTodoItems.Free;
    FColorManager.Free;
    FFreeMemo.Free;
    FCountdownItems.Free;
end;


function TCalendarDocument.FindText(s: string; base: TDateTime; direction: Integer; and_or: integer; CaseSensitive: boolean; var ret: TDateTime): boolean;
var
  item: TCalendarItem;
  d: TDateTime;
begin
    Result := False;
    if not isValid(base) then exit;

    d := base;
    while (MinDate <= d)and(d <= MaxDate) do begin
        item := getItem(d);
        if item <> nil then begin
            if item.match(s, and_or, CaseSensitive) then begin
              ret := d;
              Result := true;
              Exit;
            end;
        end;
        d := IncDay(d, direction);
    end;
end;

procedure TCalendarDocument.setItem(item: TCalendarItem);
// 註: setItem では Dirty にはならない
// -- 空の item 生成が Dirty にならないようにするため．
var
    y, m: Word;
begin
    y := YearOf(item.getDate);
    m := MonthOf(item.getDate);
    if FItems[y, m] = nil then FItems[y, m] := TCalendarItemMonth.Create;
    FItems[y, m].setItem(item);
    if FMaxDate < item.getDate then FMaxDate := item.getDate;
    if FMinDate > item.getDate then FMinDate := item.getDate;
end;

function TCalendarDocument.getDayText(day: TDate): string;
var
  item: TCalendarItem;
begin
  item := getItem(day);
  if item <> nil then Result := item.getString
  else Result := '';
end;

function TCalendarDocument.getItemOrCreate(day: TDate): TCalendarItem;
var
    item: TCalendarItem;
begin
    if not isValid(day) then begin
        Result := nil;
        exit;
    end;
    item := getItem(day);
    if (item = nil) then begin
        item := TCalendarItem.Create(day);
        setItem(item);
    end;
    Result := item;
end;

function TCalendarDocument.getItem(day: TDate): TCalendarItem;
var
    y, m: Word;
begin
    Result := nil;
    y := YearOf(day);
    m := MonthOf(day);
    if (y>=MIN_YEAR)and(y<=MAX_YEAR)and(FItems[y, m] <> nil) then
        Result := FItems[y, m].Items[DayOf(day)];
end;


function TCalendarDocument.createRangeItem(start_date, end_date: TDate; caption: string; color: TColor; textcolor: TColor; isDayTextColor: boolean; penwidth, penstyle, arrowType, skipDays: integer): TRangeItem;
var
    item: TRangeItem;
begin
    item := TRangeItem.Create(start_date, end_date, self.Filename);
    if caption = '' then caption := NO_TITLE_RANGE_ITEM;
    item.Text := caption;
    item.Color := color;
    item.TextColor := textcolor;
    item.IsDayTextColor := isDayTextColor;
    item.PenWidth := PenWidth;
    item.PenStyle := PenStyle;
    item.ArrowType := arrowType;
    item.EncodedSkipDays := skipDays;
    FRangeItems.Add(item);
    Result := item;
    FDirty := true;
end;

procedure TCalendarDocument.freeRangeItem(item: TRangeItem);
begin
    FRangeItems.Remove(item);
    item.Free;
    FDirty := true;
end;

procedure TCalendarDocument.parseColor(text: string; var cl1, cl2: TColor; var secondIsDisable: boolean );
var
    i: integer;
begin
    i := AnsiPos(COLOR_DELIMITER, text);
    if i > 0 then begin
       cl1 := StringToColor(Copy(text, 1, i-1));
       cl2 := StringToColor(Copy(text, i+1, Length(text)));
       secondIsDisable := false;
    end else begin
       cl1 := StringToColor(text);
       cl2 := cl1;
       secondIsDisable := true;
    end;

end;



procedure TCalendarDocument.setDayText(day: TDate; s: string);
var
  item: TCalendarItem;
begin
  item := getItemOrCreate(day);
  if item <> nil then item.setString(s);
end;



procedure TCalendarDocument.SaveAs(filename: TFileName);
var
    f: TStringList;
    y, m, idx: integer;
    item : TCalendarItem;
    countdownitem: TCountdownItem;
    stream: THandleStream;
begin
    f := TStringList.Create;
    try
        f.Add(HEADER_STRING);
        for y:=MIN_YEAR to MAX_YEAR do begin
            for m:=1 to 12 do begin
                if FItems[y, m] <> nil then begin
                    for idx:=1 to 31 do begin
                        item := FItems[y, m].Items[idx];
                        if (item <> nil) and (item.getString <> '') then begin
                            f.Add(DateFormat.unparseDate(item.getDate));
                            f.Add(item.getString);
                            f.Add(DELIMITER_STRING);
                        end;
                    end;
                end;
            end;
        end;
        f.Add(RANGEITEM_HEADER);
        for idx:=0 to FRangeItems.Count-1 do begin
            f.Add(DateFormat.unparseDate(FRangeItems[idx].StartDate));
            f.Add(DateFormat.unparseDate(FRangeItems[idx].EndDate));
            if FRangeItems[idx].IsDayTextColor then begin
                f.Add(ColorToString(FRangeItems[idx].Color));
            end else begin
                f.Add(ColorToString(FRangeItems[idx].Color) + COLOR_DELIMITER + ColorToString(FRangeItems[idx].TextColor));
            end;
            f.Add(FRangeItems[idx].Text);
            f.Add(IntToStr(FRangeItems[idx].PenWidth));
            f.Add(IntToStr(FRangeItems[idx].PenStyle));
            f.Add(IntToStr(FRangeItems[idx].EncodedSkipDays));
            f.Add(IntToStr(FRangeItems[idx].ArrowType));
            f.Add(DELIMITER_STRING);
        end;
        f.Add(SERIESITEM_HEADER);
        SeriesItemSerialize.SerializeSeriesItemList(FSeriesItems, f);
        f.Add(TODO_HEADER);
        FTodoItems.serialize(f);
        f.Add(COLOR_HEADER);
        FColorManager.serialize(f);
        f.Add(COUNTDOWN_HEADER);
        for idx := 0 to getCountdownItemCount - 1 do begin
            countdownItem := getCountdownItem(idx);
            f.Add(BoolToStr(countdownItem.ReferSeries));
            f.Add(DateFormat.unparseDate(countdownItem.SpecifiedDate));
            f.Add(IntToStr(SeriesItems.IndexOf(countdownItem.SeriesItem)));
            f.Add(IntToStr(countdownItem.ActiveLimit));
            f.Add(BoolToStr(countdownItem.Disabled));
            f.Add(BoolToStr(countdownItem.UseCaption));
            f.add(countdownItem.Caption);
            f.Add(DELIMITER_STRING);
        end;
        f.Add(FREEMEMO_HEADER);
        if FFreeMemo <> nil then f.AddStrings(FFreeMemo);

        if (FDocumentLock <> 0) and (FFilename = filename) then begin
            stream := THandleStream.Create(FDocumentLock);
            stream.Size := 0;         // 最初から（データを消して）書き直し
            f.SaveToStream(stream);
            stream.Free;
        end else if (FFilename <> filename) then begin
            f.SaveToFile(filename);
            LockFile(filename);
            setFilename(filename);
        end else begin // (FDocumentLock=0)and(FFilename = filename) 
            raise Exception.Create('ファイル "' + filename +
                                   '" に対しては現在書き込みできません．'#13#10 +
                                   '変更を保存したい場合は「名前を付けて保存」を，'#13#10+
                                   '変更を破棄してよい場合は「ファイルを保存せずに終了」を選んでください．');
        end;
        FDirty := false;

    finally
        f.Free;
    end;

end;

procedure TCalendarDocument.ReadDayItem(var idx: integer; f: TStrings);
var
  day: TDateTime;
  str: string;
  item: TCalendarItem;
  is_first_line: boolean;
begin
    if DateFormat.TryParseDate(f[idx], day) then begin
        inc(idx);
        str := '';
        is_first_line := true;
        while (idx<f.Count) and (f[idx]<>DELIMITER_STRING) do begin
            if is_first_line then
              is_first_line := false
            else
              str := str + #13#10;
            str := str + f[idx];
            inc(idx);
        end;
        inc(idx); // skip a delimiter

        item := getItemOrCreate(day);
        if item = nil then begin
            // 取り扱える範囲外の日付が設定されている
            raise CalendarLoadException.Create(FormatDateTime(ShortDateFormat, day) + ' の日付メモは取り扱いの範囲外です．');
        end;
        item.setString(str);
        setItem(item);
    end else begin
        // 日付以外のデータがあった
        raise CalendarLoadException.Create('ファイル内の文字列 ' + f[idx] +' は日付メモの日付として取り扱えませんでした．');
    end;
end;

procedure TCalendarDocument.ReadRangeItem(var idx: integer; f: TStrings);
var
  day: TDateTime;
  end_day: TDateTime;
  color, textColor: TColor;
  isDayTextColor : boolean;
  str: string;
    penWidth : integer;
    penStyle : integer;
    skipDays : integer;
    arrowType: integer;
begin
    // 期間予定を読む
    if not DateFormat.TryParseDate(f[idx], day) then begin
        raise CalendarLoadException.Create('ファイル内の文字列 ' + f[idx] +' は期間予定の日付として取り扱えませんでした．');
    end;
    inc(idx);
    if not DateFormat.TryParseDate(f[idx], end_day) then begin
        raise CalendarLoadException.Create('ファイル内の文字列 ' + f[idx] +' は期間予定の日付として取り扱えませんでした．');
    end;
    inc(idx);

    parseColor(f[idx], color, textColor, isDayTextColor);
    inc(idx);

    str := f[idx];
    inc(idx);

    if not isValid(day) then raise CalendarLoadException.Create('期間予定 ' + QuotedStr(str) + ' の開始日 ' +  FormatDateTime(ShortDateFormat, day) + ' は取り扱いの範囲外です．');
    if not isValid(end_day) then raise CalendarLoadException.Create('期間予定 ' + QuotedStr(str) + ' の終了日 ' +  FormatDateTime(ShortDateFormat, end_day) + ' は取り扱いの範囲外です．');
    if day > end_day then raise CalendarLoadException.Create('期間予定 ' + QuotedStr(str) + 'は開始日より終了日が早く設定されています．');

    penWidth := 1;
    penStyle := 0;
    skipDays := 0;
    arrowType:= 0;
    if f[idx] <> DELIMITER_STRING then begin
        penWidth := StrToIntDef(f[idx], 1);
        inc(idx);

        if f[idx] <> DELIMITER_STRING then begin
            penStyle := StrToIntDef(f[idx], 0);
            inc(idx);

            if f[idx] <> DELIMITER_STRING then begin
                skipDays := StrToIntDef(f[idx], 0);
                inc(idx);

                if f[idx] <> DELIMITER_STRING then begin
                    arrowType := StrToIntDef(f[idx], 0);
                    inc(idx);
                end;
            end;
        end;

    end;

    while (idx<f.Count)and(f[idx]<>DELIMITER_STRING) do begin
        // skip invalid lines
        inc(idx);
    end;
    inc(idx); // skip a delimiter
    createRangeItem(day, end_day, str, color, textcolor, isDayTextColor, PenWidth, PenStyle, arrowType, skipDays);

end;

procedure TCalendarDocument.ReadCountdownItem(var idx: integer; f: TStrings);
var
    item: TCountdownItem;
    referSeriesItem: boolean;
    day: TDateTime;
    seriesItemIndex: integer;
    activeLimit: integer;
    disabled: boolean;
    useCaption: boolean;
    caption: string;
    everyYear: boolean;
begin
    referSeriesItem := StrToBoolDef(f[idx], false);
    inc(idx);
    if f[idx] = DELIMITER_STRING then begin
        inc(idx);
        exit;
    end;

    if not DateFormat.TryParseDate(f[idx], day) then begin
        day := Date;
    end;
    inc(idx);

    seriesItemIndex := StrToIntDef(f[idx], -1);
    inc(idx);
    if f[idx] = DELIMITER_STRING then begin
        inc(idx);
        exit;
    end;

    activeLimit := StrToIntDef(f[idx], 100);
    inc(idx);
    if f[idx] = DELIMITER_STRING then begin
        inc(idx);
        exit;
    end;

    disabled := StrToBoolDef(f[idx], false);
    inc(idx);

    // 1.5.0 beta 互換のデータの場合，以下の項目は存在しないので飛ばす
    useCaption := false;
    everyYear := false;
    Caption := '';
    if f[idx] <> DELIMITER_STRING then begin
        useCaption := StrToBoolDef(f[idx], false);
        inc(idx);
        if f[idx] <> DELIMITER_STRING then begin
            caption := f[idx];
            inc(idx);

            if f[idx] <> DELIMITER_STRING then begin
                everyYear := StrToBoolDef(f[idx], false);
                inc(idx);
            end;
        end;
    end;

    while (idx<f.Count)and(f[idx]<>DELIMITER_STRING) do begin
        // skip invalid lines
        inc(idx);
    end;
    inc(idx); // skip a delimiter


    item := TCountdownItem.Create;
    item.ReferSeries := referSeriesItem;
    item.SpecifiedDate := day;
    if (seriesItemIndex = -1)or(seriesItemIndex>=SeriesItems.Count) then
        item.SeriesItem := nil
    else
        item.SeriesItem := SeriesItems.Items[seriesItemIndex];
    item.ActiveLimit := activeLimit;
    item.Disabled := disabled;
    item.UseCaption := useCaption;
    item.Caption := caption;
    item.EveryYear := everyYear;
    addCountdownItem(item);

end;

function TCalendarDocument.LoadFrom(filename: TFileName): boolean;
var
    f: TStringList;
    i, j: integer;
    hk: THeaderKind;
    errorlog: TStringList;


    // 書き込みモードで既に開かれているかもしれないファイルを読む
    // 書き込みモードを許す SHARE_WRITE をセットして読み込みモードで開く必要がある．
    procedure readFile(f: TStringList);
    var
        fileHandle: THandle;
        stream: THandleStream;
    begin
        fileHandle := CreateFile(PAnsiChar(filename),
                      GENERIC_READ,
                      FILE_SHARE_READ or FILE_SHARE_WRITE,
                      nil,
                      OPEN_ALWAYS,
                      FILE_ATTRIBUTE_NORMAL,
                      0);
        if (GetLastError <> NOERROR) and (GetLastError <> ERROR_ALREADY_EXISTS) then begin
            raise CalendarLoadException.Create('ファイルの読み取りができません．');
        end else begin
            stream := THandleStream.Create(fileHandle);
            f.LoadFromStream(stream);
            stream.Free;
            CloseHandle(fileHandle);
        end;
    end;
begin
    f := TStringList.Create;
    try
        Clear;
        if FFreeMemo <> nil then FFreeMemo.Clear;
        if filename = '' then begin
            Result := true;
            FDirty := false;
            setFilename('');
        end else if FileExists(filename) then begin

            readFile(f);

            if f[0] = HEADER_STRING then begin
                i := 1;

                while (i<f.Count) and (isHeaderString(f[i])=hkNone) do begin
                    ReadDayItem(i, f);
                end;

                while (i<f.Count) do begin

                    hk := isHeaderString(f[i]);
                    if (hk = hkRange) then begin
                        inc(i); // skip a header

                        while (i<f.Count) and (isHeaderString(f[i])=hkNone) do begin
                            ReadRangeItem(i, f);
                        end;

                    end else if (hk = hkSeries) then begin
                        inc(i);
                        j := i;
                        while (j < f.Count) and (isHeaderString(f[j]) = hkNone) do inc(j);
                        FSeriesItems.Free;
                        FSeriesItems := SeriesItemSerialize.DeserializeSeriesItemList(f, i, j-1);
                        i := j;
                    end else if (hk = hkTodo) then begin
                        inc(i);
                        j := i;
                        while (j < f.Count) and (isHeaderString(f[j])=hkNone) do inc(j);
                        FTodoItems.Free;
                        FTodoItems := TodoList.deserialize(f, i, j-1);

                        i := j;
                    end else if (hk = hkColor) then begin
                        inc(i);
                        j := i;
                        while (j < f.Count) and (isHeaderString(f[j]) = hkNone) do inc(j);

                        ColorManager.Clear;
                        ColorManager.deserialize(f, i, j-1);

                        i := j;
                    end else if (hk = hkCountdown) then begin
                        inc(i);
                        while (i<f.Count) and (isHeaderString(f[i])=hkNone) do begin
                            ReadCountdownItem(i, f);
                        end;

                    end else if (isHeaderString(f[i])=hkFreeMemo) then begin
                        // 1行読み飛ばし
                        inc(i);
                        FFreeMemo.Clear;
                        while (i<f.Count)  do begin
                            FFreeMemo.Add(f[i]);
                            i:=i+1;
                        end;
                    end;
                end;
                Result := true;
                FDirty := false;
                setFilename(filename);
                FLastErrorString := '';

            end else begin
                // Header Not Found
                Result := false;
                FDirty := false;
                setFileName('');
                FLastErrorString := 'ファイル形式が違います．データを読み取れません．';
                Clear;
            end;

        end else begin
            // File Not Found
            Result := false;
            FDirty := false;
            setFileName('');
            FLastErrorString := 'ファイルが見つからない，または読み取り権限がありません．';
            Clear;
        end;

    except
        on E: CalendarLoadException do begin
            errorlog := TStringList.Create;
            JclLastExceptStackListToStrings(errorlog, true, true, true, false);
            FLastErrorString := E.Message + #13#10 + errorlog.Text;
            errorlog.Free;
            Result := false;
            Clear;
            if FFreeMemo <> nil then FFreeMemo.Clear;
            setFilename('');
        end;
        on E: Exception do begin
            errorlog := TStringList.Create;
            JclLastExceptStackListToStrings(errorlog, true, true, true, false);
            FLastErrorString := '読み込み途中での予期せぬエラー: ' + E.Message + #13#10 + errorlog.Text;
            errorlog.Free;
            Result := false;
            Clear;
            if FFreeMemo <> nil then FFreeMemo.Clear;
            setFilename('');
        end;
    end;
    f.Free;
    Header := ExtractFileName(FFilename);
    LockFile(FFilename);
end;


function TCalendarDocument.getFilename: TFilename;
begin
    Result := FFilename;
end;

procedure TCalendarDocument.setFilename(name: TFilename);
var
  i:integer;
begin
  FFilename := name;
  for i:=0 to RangeItems.Count-1 do begin
    RangeItems.getItem(i).Owner := FFilename;
  end;
end;

procedure TCalendarDocument.addCountdownItem(item: TCountdownItem);
begin
    FCountdownItems.Add(item);
end;

procedure TCalendarDocument.freeCountdownItem(item: TCountdownItem);
begin
    FCountdownItems.Remove(item); // Remove automatically releases item.
end;

function TCalendarDocument.getCountdownItem(idx: integer): TCountdownItem;
begin
    Result := TCountdownItem(FCountdownItems[idx]);
end;

function TCalendarDocument.getCountdownItemCount: integer;
begin
    Result := FCountdownItems.Count;
end;

procedure TCalendarDocument.validateCountdownItems;
var
  i: integer;
begin
    for i := 0 to getCountdownItemCount - 1 do begin
        if SeriesItems.IndexOf(getCountdownItem(i).SeriesItem) = -1 then begin
            getCountdownItem(i).SeriesItem := nil;
        end;
    end;
end;

procedure TCalendarDocument.exchangeCountdownItem(idx1: Integer; idx2: Integer);
begin
    FCountdownItems.Exchange(idx1, idx2);
end;

procedure TCalendarDocument.updateSeriesItem(manager: TSeriesItemManager);
begin
  manager.registerItems(FSeriesItems);
end;


end.
