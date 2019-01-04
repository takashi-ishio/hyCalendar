unit DocumentManager;

interface

uses DateUtils, SysUtils, Classes, CalendarItem,  Controls, Graphics, Types,
    Contnrs, StrUtils,  Dialogs,
    SeriesItem, TodoList,
    RangeItem, RangeItemReferenceList, RangeItemManager,
    StringSplitter, CalendarConfig, ColorManager, DocumentReference,
    CalendarDocument,
    ComCtrls,
    Windows, Messages, Math, SearchResult, URLScan,
    ColoredStringList, SeriesItemManager,
    Rokuyo;

const
    MAX_SEARCH_KEYWORD = 31;
    HINT_NO_ITEM = '(予定はありません)';


type
  TExportStyle = (expsText, expsCSV, expsTab);

  TFindSetting = (findDayItem, findRangeItem, findSeriesItem, findTodoItem, findReferences, findDayName, findWithStartDate, findWithEndDate);
  TFindSettings = set of TFindSetting;

  TExportSetting = (expReferences, expEmptyItem, expRangeSeriesTodo, expCSVWithDateHead, expYoubi);
  TExportSettings = set of TExportSetting;

    TDocumentManager = class
    private

        FConfiguration: TCalendarConfiguration;
        FDocument: TCalendarDocument;
        FReferences: TObjectList;

        FVisibleReferences: TObjectList;
        FRangeItemManager: TRangeItemManager;
        FTodoMatcherTemp: TTodoMatcher;
        FTodoMatchResult: TStringList;

        FSeriesItemManager: TSeriesItemManager;

        FReferredFreeMemoLength: integer;
        FLastSearchResult : TSearchResult;

        function getReference(index: integer): TDocumentReference;
        function getReferenceCount: integer;

        function getVisibleReference(idx: integer): TDocumentReference;
        function getVisibleReferenceCount: integer;

        procedure getMinMaxDate(searchReferences: boolean; var minDate, maxDate: TDateTime);


        constructor Create;

        procedure splitReferenceFilenameToProperties(filename: string; var actual_filename: string; var visible: boolean);
        procedure filterSeriesItem(l: TStrings);

    public
        destructor Destroy; override;
        class function getInstance: TDocumentManager;
        class procedure Cleanup;

        procedure ClearReference;
        procedure SaveReferenceList;

        procedure updateVisibleReferences;
        function LoadFrom(filename: TFileName): boolean;
        procedure ReloadReferences;

        procedure getEditableSeriesItems(day: TDateTime; l: TStrings);

        procedure checkoutFreeMemo(memo: TRichEdit);
        procedure checkinFreeMemo(memo: TRichEdit);
        procedure findVisibleFreeMemo(memo: TStringList);

        function getItem(day: TDate): TCalendarItem;
        function getItemOrCreate(day: TDate): TCalendarItem;
        function getHintString(day: TDate): string;

        procedure getRangeNames(day: TDate; result: TStringList);
        function getRangeItems(day: TDate): TRangeItemReferenceList;

        function getDayItems(day: TDate): TStringList;
        procedure cleanupDayItems(items: TStrings);
        function getHyperlinks(day: TDate): TStringList;
        procedure cleanupHyperlinks(items: TStrings);

        function FreeMemo : TStrings;
        function ColorManager: TPaintColorManager;
        function LastErrorString: string;

        // 周期予定関連
        procedure updateSeriesItems;
        procedure getNameList(day: TDateTime; matched: TStrings);
        procedure getDayNameList(day: TDateTime; matched: TStrings);

        // 検索関連
        procedure searchText(text: string; and_or: integer; caseSensitive: boolean; start_date, end_date: TDateTime; settings: TFindSettings);

        function makeExportText(start_date, end_date: TDateTime; dateOutputFormat: string; style: TExportStyle; settings: TExportSettings; var text: TStringList): integer;

        // TODO 管理
        function matchTodo(day: TDateTime): TStringList;

        function getDayNameAsString(day: TDateTime): string;

        // 参照管理
        function AddReference(filename: string): boolean;
        procedure RemoveReference(index: integer);

        function IsVisibleDocument(filename: string): boolean;
        function IsReferenceDocument(filename: string): boolean;
        function IsMainDocument(filename: string): boolean;

        property MainDocument: TCalendarDocument read FDocument;

        property References[index: integer]: TDocumentReference read getReference;
        property ReferenceCount: integer read getReferenceCount;
        property VisibleReferences[index: integer]: TDocumentReference read getVisibleReference;
        property VisibleReferenceCount: integer read getVisibleReferenceCount;

        property Configuration : TCalendarConfiguration read FConfiguration write FConfiguration;

        property LastSearchResult: TSearchResult read FLastSearchResult;

        function createRangeItem(start_date, end_date: TDate; caption: string; color: TColor; textcolor: TColor; isDayTextColor: boolean; penWidth, penStyle, arrowType, skipDays: integer): TRangeItem;
        procedure updateRangeItem(item: TRangeItem; start_date, end_date: TDateTime; caption: string; color: TColor; textcolor: TColor; isDayTextColor: boolean; penWidth, penStyle, arrowType, skipDays: integer);
        procedure freeRangeItem(item: TRangeItem);

        function hasStartupError: boolean;

        function countDate(item: TSeriesItem; from: TDate; limit: integer): integer;

        // for RENDERER
        function BackColor(day: TDateTime): TColor;
        function HeadColor(day: TDateTime): TColor;
        function isHoliday(day: TDateTime): boolean;
        function isActualHoliday(day: TDateTime): boolean;
        function DayNames(day, base: TDateTime; dayFontColor: TColor): TColoredStringList; // base: その月の表示
        function DayText(day: TDateTime; seriesPlanItemFontColor: TColor): TColoredStringList;
        function TextMatch(day: TDateTime; search: string; mode: integer): boolean;

        procedure BeginEditSeriesItems;

//TScheduleModel.DayTextCount(day)
//TScheduleModel.DayText(day, idx)
//TScheduleModel.DayTextStyle(day, idx): -> usually return FConfiguration.DayTextColor OR SeriesItemStyle OR TodoStyle
//
//TScheduleModel.RangeItemCount(day)
//TScheduleModel.RangeColor(day, idx)
//TScheduleModel.RangeLineStyle(day, idx) -- Pen.Color, Pen.Style を両方備えさせてもよいかも...
//TScheduleModel.RangeTextStyle(day, idx) -- Font 設定と色設定を返す!
//TScheduleModel.RangeText(day, idx)
//TScheduleModel.RangeIsStartDate(day, idx)
//TScheduleModel.RangeIsEndDate(day, idx)



    end;

    TInaccessibleReference = class(TDocumentReference)
    private
        FFilename: TFilename;
    protected
        function getFilename: TFilename; override;
    public
        function getItem(day: TDate): TCalendarItem; override;
        constructor Create(filename: TFilename);
    end;


implementation

uses
    Constants, AbstractDocument;

const
    REFERENCE_LIST_SUFFIX = '.references';
    Quotation = '"';

var
    theInstance: TDocumentManager;


procedure TDocumentManager.filterSeriesItem(l: TStrings);
var
      i: integer;
begin
      i := 0;
      while i < l.Count do begin
        if MainDocument.SeriesItems.IndexOf(l.Objects[i] as TSeriesItem) = -1 then
          l.Delete(i)
        else
          inc(i);
      end;
end;

function filenameToURL(filename: string): string;
var
    path: string;
begin
    path := StringReplace(filename, '\', '/', [rfReplaceAll]);
    result := 'file://' + Quotation + path + Quotation;
end;


class function TDocumentManager.getInstance: TDocumentManager;
begin
    if (theInstance = nil) then begin
        theInstance := TDocumentManager.Create;
    end;
    Result := theInstance;
end;

class procedure TDocumentManager.Cleanup;
begin
    if theInstance <> nil then begin
        theInstance.Free;
        theInstance := nil;
    end;
end;

function TDocumentManager.IsReferenceDocument(filename: string): boolean;
var
  i: integer;
begin
  Result := false;
  for i:=0 to getVisibleReferenceCount-1 do begin
    if getReference(i).Filename = filename then begin
      Result := true;
      break;
    end;
  end;
end;

function TDocumentManager.IsVisibleDocument(filename: string): boolean;
var
  i: integer;
begin
  Result := false;
  if IsMainDocument(filename) then Result := MainDocument.Visible
  else begin
    for i:=0 to getVisibleReferenceCount-1 do begin
      if VisibleReferences[i].Filename = filename then begin
        Result := true;
        break;
      end;
    end;
  end;
end;

function TDocumentManager.IsMainDocument(filename: string): boolean;
begin
  Result := MainDocument.Filename = filename;
end;

function TDocumentManager.getDayNameAsString(day: TDateTime): string;
var
  s: string;
  daynames: TStringList;
  i: integer;
begin
  dayNames := TStringList.Create;
  getDayNameList(day, dayNames);
  s := '';
  for i:=0 to dayNames.Count-1 do begin
    s := s + dayNames[i];
    if i < dayNames.Count-1 then s := s + ', ';
  end;
  dayNames.Free;
  Result := s;
end;


procedure TDocumentManager.getRangeNames(day: TDate; result: TStringList);
var
  ranges: TRangeItemReferenceList;
  i: integer;
begin
  result.Clear;
  ranges := getRangeItems(day);
  for i:=0 to ranges.Count-1 do begin
    if IsMainDocument(Ranges[i].Owner) then
      result.Add(Ranges[i].Text)
    else
      result.Add('');  // 空なぶんは後でフィルタしてる

  end;
end;

constructor TDocumentManager.Create;
begin
    FConfiguration     := nil;
    FReferences := TObjectList.Create;
    FVisibleReferences := TObjectList.Create(false); // 可視かどうかが変化しただけではオブジェクトを削除したりしない
    FDocument   := TCalendarDocument.Create;
    FRangeItemManager:= TRangeItemManager.Create;
    FTodoMatcherTemp:= TTodoMatcher.Create;
    FTodoMatchResult:=TStringList.Create;
    FReferredFreeMemoLength := 0;
    FLastSearchResult := nil;
    FSeriesItemManager := TSeriesItemManager.Create;
end;

function TDocumentManager.hasStartupError: boolean;
begin
  Result := FSeriesItemManager.ErrorForHolidayFile.Count > 0;
end;

destructor TDocumentManager.Destroy;
begin
    FSeriesItemManager.Free;
    FReferences.Free;
    FDocument.Free;
    FVisibleReferences.Free;
    FRangeItemManager.Free;

    if FLastSearchResult <> nil then FLastSearchResult.Free;
end;

function TDocumentManager.getVisibleReference(idx: integer): TDocumentReference;
begin
    Result := FVisibleReferences[idx] as TDocumentReference;
end;

procedure TDocumentManager.getEditableSeriesItems(day: TDateTime; l: TStrings);
begin
  FSeriesItemManager.getSeries(day, l);
  FSeriesItemManager.getDayNameList(day, l);
  filterSeriesItem(l);
end;

// Visibleなアイテムだけが表示・検索の対象になるように Visible List を作成する
// 同時に RangeItem, SeriesItem をリストに登録
procedure TDocumentManager.updateVisibleReferences;
var
    i: integer;
    start_date, end_date: TDateTime;
begin
    FVisibleReferences.Clear;
    FRangeItemManager.Clear;
    start_date := LAST_DATE;
    end_date := FIRST_DATE;

    MainDocument.RangeItems.registerLink(FRangeItemManager, start_date, end_date);

    for i:=0 to ReferenceCount-1 do begin

        if getReference(i).Visible then begin
          FVisibleReferences.Add(getReference(i));

          // 期間予定を登録
          if getReference(i) is TCalendarDocument then begin
            (getReference(i) as TCalendarDocument).RangeItems.registerLink(FRangeItemManager, start_date, end_date);
          end;

        end;
    end;
    // 期間予定のランク割付
    if start_date <= end_date then // 期間予定が存在しない場合は start_date > end_Date
      FRangeItemManager.negotiateRanks(start_date, end_date);

    // 周期予定リストも更新
    updateSeriesItems;

end;

procedure TDocumentManager.freeRangeItem(item: TRangeItem);
// 編集ダイアログから呼ばれること前提．unregisterLink つき
var
  start_date, end_date: TDateTime;
begin
  start_date := item.StartDate;
  end_date := item.EndDate;
  FRangeItemManager.unregisterRangeLink(item);
  MainDocument.freeRangeItem(item);
  FRangeItemManager.negotiateRanks(start_date, end_date);
end;

function TDocumentManager.createRangeItem(start_date, end_date: TDate; caption: string; color: TColor; textcolor: TColor; isDayTextColor: boolean; penWidth, penStyle, arrowType, skipDays: integer): TRangeItem;
// 編集ダイアログから呼ばれること前提．registerLink　つき
var
    item: TRangeItem;
begin
  item := mainDocument.createRangeItem(start_date, end_date, caption, color, textcolor, isDayTextColor, penWidth, penStyle, arrowType, skipDays);
  FRangeItemManager.registerRangeLink(item);
  FRangeItemManager.negotiateRanks(start_date, end_date);
  Result := item;
end;

procedure TDocumentManager.updateRangeItem(item: TRangeItem; start_date, end_date: TDateTime; caption: string; color: TColor; textcolor: TColor; isDayTextColor: boolean; penWidth, penStyle, arrowType, skipDays: integer);
var
  old_start: TDateTime;
  old_end: TDateTime;
begin
  old_start := item.StartDate;
  old_end := item.EndDate;
  FRangeItemManager.unregisterRangeLink(item);

  item.Text := caption;
  item.StartDate := start_date;
  item.EndDate := end_date;
  item.Color := color;
  item.TextColor := textcolor;
  item.IsDayTextColor := isDayTextColor;
  item.PenWidth := PenWidth;
  item.PenStyle := PenStyle;
  item.ArrowType := ArrowType;
  item.EncodedSkipDays := skipDays;

  FRangeItemManager.registerRangeLink(item);
  FRangeItemManager.negotiateRanks(Min(start_date, old_start), Max(end_date, old_end));
end;


function TDocumentManager.LoadFrom(filename: TFileName): boolean;
var
    Loaded: boolean;
    files: TStringList;
    i: integer;
begin
    Loaded := FDocument.LoadFrom(filename);
    ClearReference;
    if FileExists(filename + REFERENCE_LIST_SUFFIX) then begin
        files := TStringList.Create;
        files.LoadFromFile(filename + REFERENCE_LIST_SUFFIX);
        for i:=0 to files.Count-1 do begin
            AddReference(files[i])
        end;
    end;
    updateVisibleReferences;
    Result := Loaded;
end;



procedure TDocumentManager.cleanupDayItems(items: TStrings);
begin
    items.Free;
end;

function TDocumentManager.getDayItems(day: TDate): TStringList;
var
    idx: integer;
    items: TStringList;

    procedure addItem(doc: TDocumentReference);
    var
        item: TCalendarItem;
    begin
        item := doc.getItem(day);
        if item <> nil then items.AddObject(item.getString, item.getHyperLinks);
    end;

begin
    items := TStringList.Create;
    addItem(FDocument);

    for idx := 0 to FVisibleReferences.Count-1 do begin
        addItem(getVisibleReference(idx));
    end;
    Result := items;
end;

function TDocumentManager.getHyperlinks(day: TDate): TStringList;
var
    idx: integer;
    items, dayItems: TStringList;
begin
    items := TStringList.Create;
    items.Sorted := true;

    dayItems := TDocumentManager.getInstance.getDayItems(day);
    for idx:=0 to dayItems.Count-1 do begin
        items.AddStrings(dayItems.Objects[idx] as TStrings);
    end;
    cleanupDayItems(dayItems);

    Result := items;
end;

procedure TDocumentManager.cleanupHyperlinks(items: TStrings);
begin
    items.Free;
end;

function TDocumentManager.getItem(day: TDate): TCalendarItem;
begin
    Result := FDocument.getItem(day); // オブジェクト代表１個を返す
end;

function TDocumentManager.getItemOrCreate(day: TDate): TCalendarItem;
begin
    Result := FDocument.getItemOrCreate(day);
end;

function TDocumentManager.getHintString(day: TDate): string;
var
    l: TStringList;
    range: string;
    s: string;
    todos: TStringList;
    items: TStringList;
    todoMatcher: TTodoMatcher;
    i: integer;

    function isEmptyList(list: TStrings): boolean;
    var i: integer;
        b: boolean;
    begin
        i := 0;
        b := true;
        while b and (i< list.Count) do begin
            if list[i] <> '' then b := false;
            inc(i);
        end;
        Result := b;
    end;

    function extractStringWithoutTextAttr(text: string): string;
    var
        line, lines: TStringSplitter;
        output, out_line : string;
        term: string;
        skipnext: boolean;
        attr, attr2: TTextAttribute;
    begin
        lines := TStringSplitter.Create;
        line  := TStringsplitter.Create(Configuration.TextAttrTag);
        lines.setString(text);
        output := '';
        while lines.hasNext do begin
            line.setString(lines.getLine);
            skipnext := false;
            out_line := '';
            while line.hasNext do begin
                if skipnext then begin
                    // TextAttr の次の config.TextAttrTag は無視される
                    out_line := out_line + line.getLine;
                    skipnext := false;
                end else begin
                    term := line.getLine;
                    if line.isFirst then out_line := out_line + term
                    else if not line.hasNext then out_line := out_line + Configuration.TextAttrTag + term
                    else begin
                        attr := Configuration.GetPredefinedTextAttribute(term);
                        attr2 := Configuration.GetTextAttribute(term);
                        if Configuration.HidePredefinedTextAttrOnPopup and
                           (attr <> nil) and (attr2 = attr) then begin // predefined は User-defined でオーバーライドされる可能性がある
                           skipnext := true;
                        end else if (not Configuration.HidePredefinedTextAttrOnPopup) and (attr2 <> nil) then begin
                            skipnext := true;
                        end else begin
                            out_line := out_line + Configuration.TextAttrTag + term;
                        end;
                    end;
                end;
            end;
            if not lines.isFirst then output := output + #$D#$A;
            output := output + out_line;

        end;
        Result := output;
        lines.Free;
        line.Free;
    end;

begin
    // 周期予定の取得
    l := TStringList.Create;
    FSeriesItemManager.getSeries(day, l);

    // 期間予定の取得
    range := FRangeItemManager.getSortedRangeItems(day).toString;

    // TODO の取得
    todos := TStringList.Create;
    if Configuration.ShowTodoItems then begin
        todoMatcher := TTodoMatcher.Create;
        todoMatcher.TodoList := MainDocument.TodoItems;
        todoMatcher.match(day, Configuration, todos);
        for i:=0 to FVisibleReferences.Count-1 do begin
            if (getVisibleReference(i) is TCalendarDocument) then begin
                todoMatcher.TodoList := (getVisibleReference(i) as TCalendarDocument).TodoItems;
                todoMatcher.match(day, Configuration, todos);
            end;
        end;
        todoMatcher.Free;
    end;

    // s = 日付名称
    s := getDayNameAsString(day);
    s := FormatDateTime(ShortDateFormat, day) + ' ' + s;



    items := TDocumentManager.getInstance.getDayItems(day);

    if (range = '')and isEmptyList(todos) and isEmptyList(l) and isEmptyList(items) then
        Result := s + #$D#$A + HINT_NO_ITEM
    else
        Result := s + #$D#$A + range +
                  IfThen(Configuration.HideDaystringTodoOnCalendar, URLScan.TURLExtractor.getInstance.removeDateFromString(todos.Text), todos.Text)
                  + l.Text
                  + IfThen(Configuration.HideTextAttrOnPopup, extractStringWithoutTextAttr(items.Text), items.Text);

    TDocumentManager.getInstance.cleanupDayItems(items);

    todos.Free;
    l.Free;
end;

function TDocumentManager.FreeMemo : TStrings;
begin
    Result := FDocument.FreeMemo;
end;

function TDocumentManager.ColorManager: TPaintColorManager;
begin
    Result := FDocument.ColorManager;
end;

function TDocumentManager.LastErrorString: string;
begin
    Result := FDocument.LastErrorString;
end;

function TDocumentManager.getReference(index: integer): TDocumentReference;
begin
    Result := FReferences[index] as TDocumentReference;
end;

procedure TDocumentManager.ClearReference;
begin
    while FReferences.Count > 0 do RemoveReference(0);
end;

// filename （後ろに設定文字列つき） → ファイル名と属性に分割
procedure TDocumentManager.splitReferenceFilenameToProperties(filename: string; var actual_filename: string; var visible: boolean);
var
  idx: integer;
begin
    idx := AnsiPos(SEPARATOR_REFERENCE_FILENAME, filename);
    if idx = 0 then begin
        actual_filename := filename;
        visible := true;
    end else begin
        actual_filename := Copy(filename, 1, idx-1);
        visible := StrToBoolDef(Copy(filename, idx+1, Length(filename)), true);
    end;
end;

function TDocumentManager.AddReference(filename: string): boolean;
var
    doc: TCalendarDocument;
    module: TRokuyo;
    failure: TInaccessibleReference;

    tmp_filename, ext: string;
    visible: boolean;

    function IsAlreadyReferred(filename: string): boolean;
    var
      i: integer;
    begin
      Result := false;
      for i:=0 to getReferenceCount-1 do begin
        if References[i].Filename = filename then begin
          Result := true;
          break;
        end;
      end;
    end;
begin
    splitReferenceFilenameToProperties(filename, tmp_filename, visible);
    filename := tmp_filename;
    ext := ExtractFileExt(filename);

    if IsMainDocument(filename) or IsAlreadyReferred(filename) then begin
      Result := false;
      exit;
    end;

    if FileExists(filename) then begin
        if ext = '.dll' then begin
            // Read as External Module
            module := TRokuyo.Create;
            if module.LoadFrom(filename) then begin
                module.Visible := true;
                module.Status := '';
                FReferences.add(module);
            end else begin
                failure := TInaccessibleReference.Create(filename);
                failure.Status := module.LastErrorString;
                failure.Visible := visible;
                module.Free;
                FReferences.Add(failure);
            end;
        end else begin
            // Read as Calendar File
            doc := TCalendarDocument.Create;
            if doc.LoadFrom(filename) then begin
                doc.Visible := visible;
                FReferences.Add(doc);
            end else begin
                failure := TInaccessibleReference.Create(filename);
                failure.Status := doc.LastErrorString;
                failure.Visible := visible;
                doc.Free;
                FReferences.Add(failure);
            end;
        end;
    end else begin
        failure := TInaccessibleReference.Create(filename);
        failure.Status := 'ファイルが見つかりません';
        failure.Visible := visible;
        FReferences.Add(failure);
    end;
    Result := true;
end;


function TDocumentManager.getReferenceCount: integer;
begin
    Result := FReferences.Count;
end;

function TDocumentManager.getVisibleReferenceCount: integer;
begin
    Result := FVisibleReferences.Count;
end;

procedure TDocumentManager.RemoveReference(index: integer);
begin
    if (FReferences[index] as TDocumentReference).Visible then FVisibleReferences.Remove(FReferences[index]);
    FReferences.Delete(index);
end;

function TDocumentManager.getRangeItems(day: TDate): TRangeItemReferenceList;
begin
    Result := FRangeItemManager.getRangeItems(day);
end;


// 複数のフリーメモの情報を memo に add する．
//  checkout と異なり，書式等の操作がない
procedure TDocumentManager.findVisibleFreeMemo(memo: TStringList);
var
    i: integer;
    doc: TCalendarDocument;
begin
    memo.Clear;
    memo.AddStrings(FDocument.FreeMemo);
    for i:=0 to FVisibleReferences.Count-1 do begin
        if FVisibleReferences[i] is TCalendarDocument then begin
            doc := FVisibleReferences[i] as TCalendarDocument;
            if  (doc.FreeMemo.Text <> '') then begin
                memo.Add('-- 以下，参照ファイル: ' + filenameToURL(doc.Filename));
                memo.AddStrings(doc.FreeMemo);
            end;
        end;
    end;
end;

// 複数のフリーメモの情報を，１フリーメモ欄にマージして表示する
// あとで checkin されるときに必要な情報も保持
procedure TDocumentManager.checkoutFreeMemo(memo: TRichEdit);
var
    i: integer;
    doc: TCalendarDocument;
    pos: integer;
    selEnd: integer;
    wPos, wEnd: integer;


    // オリジナル色よりちょっと明るい or ちょっと暗い色を返す
    function getColorVariant(cl: TColor): TColor;
    var r, g, b: byte;
    begin
        r := GetRValue(cl);
        g := GetGValue(cl);
        b := GetBValue(cl);

        r := IfThen(r > 48, r - 48, IfThen(r < 208, r + 48, 255));
        g := IfThen(g > 48, g - 48, IfThen(g < 208, g + 48, 255));
        b := IfThen(b > 48, b - 48, IfThen(b < 208, b + 48, 255));

        Result := RGB(r, g, b);
    end;
begin

    memo.lines.Clear;
    memo.SelAttributes.Protected := false;
    memo.SelAttributes.Color := memo.Font.Color;

    memo.lines.AddStrings(FDocument.FreeMemo);
    pos := Length(memo.Lines.text);
    wPos := Length(WideString(memo.Lines.Text));
    for i:=0 to FVisibleReferences.Count-1 do begin
        if FVisibleReferences[i] is TCalendarDocument then begin
            doc := FVisibleReferences[i] as TCalendarDocument;
            if  (doc.FreeMemo.Text <> '') then begin
                memo.lines.Add('-- 以下，参照ファイル: ' + filenameToURL(doc.Filename));
                memo.lines.AddStrings(doc.FreeMemo);
            end;
        end;
    end;
    selEnd := Length(memo.Lines.text);
    wEnd := Length(WideString(memo.Lines.text));
    if (pos < selEnd) then begin
        memo.SelStart := pos;
        memo.SelLength := selEnd - pos + 2; // +2 は最終行の改行コードぶん

        memo.SelAttributes.Color := getColorVariant(memo.Font.Color); // もし参照データの色を変えるならここをいじる
        memo.SelAttributes.Protected := true;
        FReferredFreeMemoLength := wEnd-wPos; // 長さを記憶しておく（保存時に切り落とすため）
    end else begin
        FReferredFreeMemoLength := 0;
    end;
    memo.SelStart := 0;
    memo.SelLength := 0;
    memo.SelAttributes.Protected := false;

    // メモの先頭にスクロールしておく
    memo.Perform(EM_LINESCROLL, 0, - memo.Perform(EM_GETFIRSTVISIBLELINE, 0, 0));
end;

// フリーメモ欄の情報のうち，本体の情報だけを取り出して Document オブジェクトに移動する
procedure TDocumentManager.checkinFreeMemo(memo: TRichEdit);
begin
    // 全角文字だと長さがずれるので WideString 上ですべての長さを測っている
    FDocument.FreeMemo.Text := AnsiLeftStr(WideString(memo.Text), Length(WideString(memo.Text)) - FReferredFreeMemoLength);
end;


procedure TDocumentManager.BeginEditSeriesItems;
begin
    FSeriesItemManager.Clear;
    FDocument.SeriesItems.BeginEdit;
end;

// 周期予定編集ダイアログの編集後などに結果をまとめて反映するために使用
procedure TDocumentManager.updateSeriesItems;
var
    i: integer;
    doc: TAbstractCalendarDocument;
begin
    FDocument.SeriesItems.EndEdit;
    FDocument.validateCountdownItems;
    FSeriesItemManager.Clear;
    FDocument.updateSeriesItem(FSeriesItemManager);
    for i:=0 to FVisibleReferences.Count-1 do begin
        if FVisibleReferences[i] is TAbstractCalendarDocument then begin
            doc := FVisibleReferences[i] as TAbstractCalendarDocument;
            doc.updateSeriesItem(FSeriesItemManager);
        end;
    end;
end;

procedure TDocumentManager.getNameList(day: TDateTime; matched: TStrings);
begin
  FSeriesItemManager.getSeries(day, matched);
end;

procedure TDocumentManager.getDayNameList(day: TDateTime; matched: TStrings);
begin
  FSeriesItemManager.getDayNameList(day, matched);
end;

// CellRenderer から利用されることを前提とした処理．
// TodoMatcher, Todo を処理高速化のため保存している
function TDocumentManager.matchTodo(day: TDateTime): TStringList;
var
    i: integer;
begin
    FTodoMatchResult.Clear;
    FTodoMatcherTemp.TodoList := FDocument.TodoItems;
    FTodoMatcherTemp.match(day, FConfiguration, FTodoMatchResult);
    for i:=0 to FVisibleReferences.Count-1 do begin
        if (getVisibleReference(i) is TCalendarDocument) then begin
            FTodoMatcherTemp.TodoList := (getVisibleReference(i) as TCalendarDocument).TodoItems;
            FTodoMatcherTemp.match(day, FConfiguration, FTodoMatchResult);
        end;
    end;
    Result := FTodoMatchResult;
end;

procedure TDocumentManager.ReloadReferences;
var
    i: integer;
    filenames: TStringList;
begin
    filenames := TStringList.Create;
    // Copy reference filenames to temporary list
    for i:=0 to ReferenceCount-1 do begin
        filenames.Add(References[i].FilenameWithProperties);
    end;

    // Release all files
    while ReferenceCount > 0 do RemoveReference(0);

    // Add references again
    for i:=0 to filenames.Count-1 do begin
        AddReference(filenames[i]);
    end;
    filenames.Free;
    updateVisibleReferences;
end;

procedure TDocumentManager.SaveReferenceList;
var
    referenceListFilename: string;
    referenceList: TStringList;
    i: integer;
begin
    if MainDocument.Filename = '' then exit;

    referenceListFilename := MainDocument.Filename + REFERENCE_LIST_SUFFIX;
    if FReferences.Count = 0 then begin
        if FileExists(referenceListFilename) then
            SysUtils.DeleteFile(referenceListFilename);

    end else begin

        referenceList := TStringList.Create;
        try
            for i:=0 to FReferences.Count-1 do begin
                referenceList.Add((FReferences[i] as TDocumentReference).FilenameWithProperties);
            end;
            referenceList.SaveToFile(referenceListFilename);
        finally
            referenceList.Free;
        end;
    end;

end;

procedure TDocumentManager.getMinMaxDate(searchReferences: boolean; var minDate, maxDate: TDateTime);
var
    i: integer;
    doc: TCalendarDocument;
begin
    minDate := FDocument.MinDate;
    maxDate := FDocument.MaxDate;
    if searchReferences then begin
        for i:=0 to ReferenceCount-1 do begin
            if References[i] is TCalendarDocument then begin
                doc := References[i] as TCalendarDocument;
                minDate := Min(minDate, doc.MinDate);
                maxDate := Max(maxDate, doc.MaxDate);
            end;
        end;
    end;
end;

// 文字列検索
procedure TDocumentManager.searchText(text: string; and_or: integer; caseSensitive: boolean; start_date, end_date: TDateTime; settings: TFindSettings);
var
    // 集計用変数
    used_keywords: Integer;
    intermediateResult: TSearchResult;
    keywords: TStringList;


    // キーワード文字列を，文字列集合に変換
    function makeKeywords: TStringList;
    var
        words: TStringList;
        splitter: TStringSplitter;
        s: string;
    begin
        words := TStringList.Create;
        words.Duplicates := dupIgnore;
        splitter:= TStringSplitter.Create(' ');
        splitter.setString(text);
        while (splitter.hasNext) do begin
            s := splitter.getLine;
            if s <> '' then words.Add(s);
        end;
        splitter.Free;
        Result := words;
    end;

    // 全部のキーワードが使われたかどうかテスト
    function keywordsAllUsed: boolean;
    begin
        // 全部のキーワードが使われた場合，
        // used_keywords = 00,,,0011,,,11 となっているはず．
        // +1 して 00..00100..00 としたとき，keywords + 1 個目のビットが 1 になっている．
        Result := (used_keywords + 1) = (1 shl keywords.Count);
    end;

    // キーワードマッチ処理
    function match(keyword, target: string): boolean;
    begin
        // 仮定: keyword は事前に upper case になっている
        if caseSensitive then Result := AnsiContainsStr(target, keyword)
        else Result := AnsiContainsStr(AnsiUpperCase(target), keyword);
    end;

    procedure matchKeywords(keywords: TStringList; target: string; kind: string; d: TDateTime; line_num: integer);
    var
        i: integer;
        matched : boolean;
    begin
        matched := false;
        for i:=0 to keywords.Count-1 do begin
            if match(keywords[i], target) then begin
                matched := true;
                used_keywords := used_keywords or (1 shl i); // 使われたキーワードを ON に
            end;
        end;
        if matched then intermediateResult.Add(d, kind, target, line_num + 1);
    end;

    // 複数キーワードを複数文字列に当てる
    procedure matchStrings(target: TStringList; keywords: TStringList; kind: string; d: TDateTime; base_line_num: integer);
    var
        i: integer;
    begin
        for i:=0 to target.Count-1 do begin
            matchKeywords(keywords, target[i], kind, d, i+base_line_num);
        end;
    end;

    // 期間予定のみ，行数の扱いが異なるので別関数
    procedure matchRangeItem(item: TRangeItem; keywords: TStringList; d: TDateTime);
    begin
        matchKeywords(keywords, item.Text, '期間予定', d, item.Rank);
    end;


var
    d: TDateTime;
    target: TStringList;
    item: TCalendarItem;
    minDate, maxDate: TDateTime;
    idx: integer;
    ranges: TRangeItemReferenceList;
    base_line_num: integer;                 // "N 行目" の表示で，他のファイルの行数を足しこむのに使用
    todoMatcher: TTodoMatcher;

begin
    if FLastSearchResult = nil then FLastSearchResult := TSearchResult.Create;

    intermediateResult := TSearchResult.Create;
    todoMatcher := TTodoMatcher.Create;

    if not caseSensitive then begin
        text := AnsiUpperCase(text);
    end;

    // 予定が記入されている最初の日・最後の日を取得
    getMinMaxDate(findReferences in settings, minDate, maxDate);

    // もし検索範囲が指定されていたら調整
    minDate := ifThen(findWithStartDate in settings, start_date, minDate);
    maxDate := ifThen(findWithEndDate in settings, end_date, maxDate);

    keywords := makeKeywords;

    // 検索結果を初期化
    FLastSearchResult.Clear;

    // キーワード 0 個なら結果は空として終了
    if keywords.Count = 0 then exit;
    while keywords.Count > MAX_SEARCH_KEYWORD do keywords.Delete(MAX_SEARCH_KEYWORD+1);

    target := TStringList.Create;

    // 検索本体
    d := minDate;
    while d <= maxDate do begin

        used_keywords := 0;

        // 日付メモのマッチ処理
        if findDayItem in settings then begin  // 日付メモが検索対象の場合に限り
            base_line_num := 0;
            item := FDocument.getItem(d);
            if item <> nil then begin
                target.Text := item.getString;
                matchStrings(target, keywords, '日付メモ', d, base_line_num);
                base_line_num := base_line_num + target.Count;
            end;
            if findReferences in settings then begin
                for idx := 0 to FVisibleReferences.Count-1 do begin
                    item := (FVisibleReferences[idx] as TDocumentReference).getItem(d);
                    if item <> nil then begin
                        target.Text := item.getString;
                        matchStrings(target, keywords, '日付メモ', d, base_line_num);
                        base_line_num := base_line_num + target.Count;
                    end;
                end;
            end;
        end;

        // 期間予定のマッチ
        if findRangeItem in settings then begin
            ranges := getRangeItems(d);
            for idx:=0 to ranges.Count-1 do begin
                if (findReferences in settings) or IsMainDocument(ranges[idx].Owner) then begin
                    matchRangeItem(ranges[idx], keywords, d);
                end;
            end;
        end;

        // 日付名称＆周期予定（日付名）のマッチ
        if findSeriesItem in settings then begin

            base_line_num := 0;

            // 日付名周期予定を取得
            target.Clear;
            FSeriesItemManager.getDayNameList(d, target);
            if not (findReferences in settings) then begin
              filterSeriesItem(target);
            end;

            // マッチ処理
            matchStrings(target, keywords, '周期予定(日付名)', d, base_line_num);

            // 日付名以外の周期予定取得
            base_line_num := 0;
            target.Clear;
            FSeriesItemManager.getSeries(d, target);
            if not (findReferences in settings) then begin
              filterSeriesItem(target);
            end;
            matchStrings(target, keywords, '周期予定', d, base_line_num);
        end;

        // 日付入りTODOのマッチ
        if findTodoItem in settings then begin
            base_line_num := 0;
            target.Clear;
            todoMatcher.TodoList := FDocument.TodoItems;
            todoMatcher.match(d, FConfiguration, target);
            matchStrings(target, keywords, '日付入りTODO', d, base_line_num);
            base_line_num := base_line_num + target.Count;
            if findReferences in settings then begin
                for idx:=0 to FVisibleReferences.Count-1 do begin
                    if FVisibleReferences[idx] is TCalendarDocument then begin
                        target.Clear;
                        todoMatcher.TodoList := (FVisibleReferences[idx] as TCalendarDocument).TodoItems;
                        todoMatcher.match(d, FConfiguration, target);
                        matchStrings(target, keywords, '日付入りTODO', d, base_line_num);
                        base_line_num := base_line_num + target.Count;
                    end;
                end;
            end;
        end;

        // 日付名でのマッチ
        if findDayName in settings then begin
            matchKeywords(keywords, FSeriesItemManager.getPublicHolidayName(d), '祝日名', d, 0);
        end;

        // AND 条件の場合，全部のキーワードが使われたかどうか検査してから，結果を追加
        if (and_or = MARKING_OR) or keywordsAllUsed then FLastSearchResult.Concat(intermediateResult);
        intermediateResult.Clear;

        d := IncDay(d, 1);

    end;

    keywords.Free;
    intermediateResult.Free;

end;


// Export 用の文字列構築．出力した日付データの数を返す
function TDocumentManager.makeExportText(start_date, end_date: TDateTime; dateOutputFormat: string; style: TExportStyle; settings: TExportSettings; var text: TStringList): integer;
var
    d: TDateTime;
    s, s2: string;
    target: TStringList;
    item: TCalendarItem;
    idx: integer;
    i: integer;
    ranges: TRangeItemReferenceList;
    todoMatcher: TTodoMatcher;
    dataCount: integer;
    emptyCount: integer; // 日付名以外の内容が Temporary の中に入ってるかどうか

    temporary: TStringlist;
    separator: string;

    function QuoteIfNeeded(s, separator: string): string;
    begin
        if AnsiContainsStr(s, separator) then
            Result := QuotedStr(s)
        else
            Result := s;
    end;

    procedure swapDate;
    var
        t: TDateTime;
    begin
        t := start_date;
        start_date := end_date;
        end_date := t;
    end;
begin
    todoMatcher := TTodoMatcher.Create;
    target := TStringList.Create;
    temporary := TStringList.Create;
    dataCount := 0;

    if start_date > end_date then begin
        swapDate;
    end;

    d := start_date;
    while d <= end_date do begin

        // 結果 = 日付名, 期間, TODO, 周期, 日付メモの順番

        temporary.Clear;

        // 日付
        emptyCount := 0;
        if expRangeSeriesTodo in settings then begin
            s := getDayNameAsString(d);
            s2 := FSeriesItemManager.getPublicHolidayName(d);
            if (s = s2) and (s <> '') then begin
                emptyCount := 1; // Temporary に入っているのは本当の祝日名のみなので，他にデータがなければ空とみなされる
                Temporary.Add(s);
            end else begin
                emptyCount := 0;  // １つでもユーザ定義祝日とかが入ってればこっち
                if s <> '' then Temporary.Add(s);
            end;
        end else begin
            s := FSeriesItemManager.getPublicHolidayName(d);
            if s <> '' then begin
              emptyCount := 1; // Temporary に入っているのは本当の祝日名のみなので，他にデータがなければ空とみなされる
              Temporary.Add(s);
            end;
        end;

        if expRangeSeriesTodo in settings then begin
            // 期間予定
            ranges := getRangeItems(d);
            for idx:=0 to ranges.Count-1 do begin
                if (expReferences in settings) or IsMainDocument(ranges[idx].Owner) then begin
                    Temporary.Add(Ranges[idx].toString);
                end;
            end;

            // 周期予定
            target.Clear;
            FSeriesItemManager.getSeries(d, target);
            if not (expReferences in settings) then begin
              filterSeriesItem(target);
            end;
            Temporary.addStrings(target);

            // 日付付きTODO
            target.Clear;
            todoMatcher.TodoList := FDocument.TodoItems;
            todoMatcher.match(d, FConfiguration, target);
            if FConfiguration.HideDaystringTodoOnCalendar then begin
                for i:=0 to target.Count-1 do begin
                    target[i] := URLScan.TURLExtractor.getInstance.removeDateFromString(target[i]);
                end;
            end;
            Temporary.AddStrings(target);
            if expReferences in settings then begin
                for idx:=0 to FVisibleReferences.Count-1 do begin
                    if FVisibleReferences[idx] is TCalendarDocument then begin
                        target.Clear;
                        todoMatcher.TodoList := (FVisibleReferences[idx] as TCalendarDocument).TodoItems;
                        todoMatcher.match(d, FConfiguration, target);
                        if FConfiguration.HideDaystringTodoOnCalendar then begin
                            for i:=0 to target.Count-1 do begin
                                target[i] := URLScan.TURLExtractor.getInstance.removeDateFromString(target[i]);
                            end;
                        end;
                        Temporary.AddStrings(target);
                    end;
                end;
            end;
        end;

        // 日付メモ
        item := FDocument.getItem(d);
        if item <> nil then begin
            target.Text := item.getString;
            Temporary.AddStrings(target);
        end;
        if expReferences in settings then begin
            for idx := 0 to FVisibleReferences.Count-1 do begin
                item := (FVisibleReferences[idx] as TDocumentReference).getItem(d);
                if item <> nil then begin
                    target.Text := item.getString;
                    Temporary.addStrings(target);
                end;
            end;
        end;

        if (Temporary.Count > emptyCount) or (expEmptyItem in settings) then begin
            inc(dataCount);

            s := FormatDateTime(dateOutputFormat, d);

            if expYoubi in settings then begin
              s := s + ' (' + ShortDayNames[DayOfWeek(d)] + ')';
            end;

            if Style = expsText then begin
                if Text.Count > 0 then Text.Add(''); // 日付間に空行を１行挟む
                Text.Add(s);
                Text.AddStrings(temporary);
            end else begin
                // データがなくても「空アイテムも出力」ならアイテムを作る
                if (Temporary.Count = 0)and(expEmptyItem in settings) then Temporary.Add('');

                separator := IfThen(Style = expsCSV, ',', #9);

                if expCSVWithDateHead in settings then begin
                    Text.Add(s + separator + QuoteIfNeeded(Temporary[0], separator));
                    for idx:=1 to Temporary.Count-1 do begin
                        Text.Add(separator + QuoteIfNeeded(Temporary[idx], separator));
                    end;
                end else begin
                    for idx:=0 to Temporary.Count-1 do begin
                        Text.Add(s + separator + QuoteIfNeeded(Temporary[idx], separator));
                    end;
                end;
            end;

        end;

        d := IncDay(d, 1);

    end;

    temporary.Free;
    target.Free;
    todoMatcher.Free;

    Result := dataCount;

end;

function TDocumentManager.TextMatch(day: TDateTime; search: string; mode: integer): boolean;
var
  item: TCalendarItem;
begin
  item := getItem(day);
  if (item <> nil)and(search <> '') then begin
    Result := item.match(search, mode, FConfiguration.MarkingCaseSensitive);
  end else begin
    Result := false;
  end;
end;

function TDocumentManager.BackColor(day: TDateTime): TColor;
begin
    Result := ColorManager.getBackColor(day);
end;

function TDocumentManager.HeadColor(day: TDateTime): TColor;
begin
    Result := ColorManager.getHeadColor(day);
end;

function TDocumentManager.isHoliday(day: TDateTime): boolean;
begin
  // 日曜でも休日を返すタイプの isHoliday
  Result := FSeriesItemManager.isHolidayColor(day);
end;

function TDocumentManager.isActualHoliday(day: TDateTime): boolean;
begin
  // 祝日のときだけ true を返すタイプの isHoliday
  Result := FSeriesItemManager.isActualHoliday(day);
end;



// 日付名とその色を返す; NOTE: 戻り値のオブジェクトは，呼び出し側で解放すること!
function TDocumentManager.DayNames(day, base: TDateTime; dayFontColor: TColor): TColoredStringList;
var
  daynames: TColoredStringList;
  match: TStringList;
  i: integer;
  item: TSeriesItem;
  defaultColor, cl: TColor;

begin
    daynames := TColoredStringList.Create;
    defaultColor := dayFontColor; //getDayNameColor(day, base, dayFontColor);

    // 編集中の SeriesItem は SeriesItemManager から除去されてるから，普通に処理してよい
    match := TStringList.Create;
    getDayNameList(day, match);
    for i:=0 to match.Count-1 do begin
        item := match.Objects[i] as TSeriesItem;
        if (item <> nil) and item.UseColor then cl := item.Color
        else cl := defaultColor;
        daynames.Add(match[i], cl, item.UseColor);
    end;
    match.Free;

    Result := daynames;
end;

function TDocumentManager.DayText(day: TDateTime; seriesPlanItemFontColor: TColor): TColoredStringList;
var
  daynames: TColoredStringList;
  l: TStringList;
  i: integer;
  item: TSeriesItem;

begin
  daynames := TColoredStringList.Create;
  l := TStringList.Create;
  getNameList(day, l);
  for i:=0 to l.Count-1 do begin
    item := l.Objects[i] as TSeriesItem;
    if item.UseColor then daynames.Add(l[i], item.Color, item.UseColor)
    else daynames.Add(l[i], seriesPlanItemFontColor, item.UseColor);
  end;
  l.Free;
  Result := daynames;
end;

function TInaccessibleReference.getFilename: TFilename;
begin
    Result := FFilename;
end;

constructor TInaccessibleReference.Create(filename: TFilename);
begin
    inherited Create;
    FFilename := filename;
    Header    := ExtractFilename(filename);
    Status    := '見つかりません';
end;

function TInaccessibleReference.getItem(day: TDate): TCalendarItem;
begin
    Result := nil;
end;

function TDocumentManager.countDate(item: TSeriesItem; from: TDate; limit: integer): integer;
begin
    Result := FSeriesItemManager.findFirstMatchDay(item, from, limit);
end;



end.
