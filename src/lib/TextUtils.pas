{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
unit TextUtils;

interface

uses Windows, Graphics;

function GetTextAAdjust(ACanvas: TCanvas; s: string): Integer;

function GetTextCAdjust(ACanvas: TCanvas; s: string): Integer;

type
 TFormatOption = (foJustify, foEven, foRight, foCenter, foKerning);
 // foJustify: 両端揃え
 // foEven:    均等割り付け
 // foRight:   右揃え
 // foCenter:  中央揃え(右揃えに優先する)
 // foKerning: カーニングを行う
 TFormatOptions = set of TFormatOption;

 TDXArray = array of Integer;

function GetTextPosition(
  ws: WideString;                // 文字列
  FontHeight: Double;           // フォントの高さ(Twips)
  FontHandle: THandle;          // フォントハンドル
  MaxExtent: Double;            // 最大表示幅(Twips)
  PixelsPerInch: Integer;       // 表示用デバイスの論理インチ
  Options: TFormatOptions;      // オプション
  var Offset: Integer;          // 表示オフセット(ピクセル)
  var FittedChars: Integer;     // 最大表示幅に表示できる文字数
  var DXs: TDxArray             // 各文字の文字幅の配列(ピクセル)
  ): WideString;                // 戻り値は表示できなかった残りの文字列

implementation

uses SysUtils;

// 文字列が文字セルの前にはみ出す長さを算出する
function GetTextAAdjust(ACanvas: TCanvas; s: string): Integer;
var
  FirstChar: DWORD; //文字列の最初の文字のコード
  ABC: TABC;        //ABCを受け取るレコード
  ABCF: TABCFloat;
  tm: TTextMetric;  //テキストメトリック

  // 最初の文字の文字コードを取得する
  function GetFirstChar(s: string): DWORD;
  var
    NextChar: PChar;
  begin
    NextChar := CharNext(PChar(s));
    if (NextChar - PChar(s)) = 2 then
      Result := Ord(s[1]) * 256 + Ord(S[2])
    else if (NextChar - PChar(s)) = 1 then
      Result := Ord(s[1])
    else
      Result := 0;
  end;
begin
  FirstChar := GetFirstChar(s); // 最初も文字のコードを得る
  if FirstChar = 0 then   // 文字列長が０
  begin
    Result := 0;
    Exit;
  end;

  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    begin
      // 最初の文字のA幅を求める
      GetCharABCWidthsFloat(ACanvas.Handle, FirstChar, FirstChar, ABCF);
      // 負ならその大きさを返す
      if ABCF.abcfA < 0 then
        Result := -Round(ABCF.abcfA)
      else
        Result := 0
    end;
  end
  else
  begin
    //TrueTypeかチェック
    GetTExtMetrics(ACanvas.Handle, tm);
    if (tm.tmPitchAndFamily and TMPF_TRUETYPE) <> 0 then // TrueType
    begin
      // A幅を求める
      GetCharABCWidths(ACanvas.Handle, FirstChar, FirstChar, ABC);
      // 負ならその大きさを返す
      if ABC.abcA < 0 then
        Result := -ABC.abcA
      else
        Result := 0;
    end
    else
      Result := 0; // 非TrueTypeなら A=0;
  end;
end;

// Canvas.TextWidth よりテキストがはみだす場合、はみ出す大きさを返す。
function GetTextCAdjust(ACanvas: TCanvas; s: string): Integer;
var
  LastChar: DWORD; // 最後の文字の文字コード
  ABC: TABC;       // ABC幅を受け取るレコード
  ABCF: TABCFloat;
  tm: TTextMetric; // テキストメトリック

  // 最後の文字コードを取得する
  function GetLastChar(s: string): DWORD;
  var
    PrevChar: PChar;
    Len: Integer;
  begin
    Len := Length(s);

    if len = 0 then    // 文字列長が０なら０を返す
    begin
      Result := 0;
      Exit;
    end;

    // 最後の文字のコードを取得する
    PrevChar := CharPrev(PChar(s), PChar(@s[Len])+1);
    if (PChar(@s[Len])+1 - PrevChar) = 2 then
      Result := Ord(s[Len-1]) * 256 + Ord(s[Len])
    else if (PChar(@s[Len])+1 - PrevChar) = 1 then
      Result := Ord(s[Len])
    else
      Result := 0;
  end;
begin
  // 最後の文字のコードを取得する
  LastChar := GetLastChar(s);
  if LastChar = 0 then  // 文字列長=0
  begin
    Result := 0;
    Exit;
  end;

  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    begin
      // C幅を取得する
      GetCharABCWidthsFloat(ACanvas.Handle, LastChar, LastChar, ABCF);
      // C幅が負ならその大きさを返す
      if ABCF.abcfC < 0 then
        Result := -Round(ABCF.abcfC)
      else
        Result := 0
    end;
  end
  else
  begin
    // TrueType かチェック
    GetTExtMetrics(ACanvas.Handle, tm);
    if (tm.tmPitchAndFamily and TMPF_TRUETYPE) <> 0 then // TrueType
    begin
      // C 幅を取得する
      GetCharABCWidths(ACanvas.Handle, LastChar, LastChar, ABC);
      // C幅が負ならその大きさを返す
      if ABC.abcC < 0 then
        Result := -ABC.abcC
      else
        Result := 0;
    end
    else
      Result := 0;  // TrueTypeで無い場合、TextWidthはC幅を含んでいる
  end;
end;

function GetTextPosition(
  ws: WideString;                // 文字列
  FontHeight: Double;           // フォントの高さ(Twips)
  FontHandle: THandle;          // フォントハンドル
  MaxExtent: Double;            // 最大表示幅(Twips)
  PixelsPerInch: Integer;       // 表示用デバイスの論理インチ
  Options: TFormatOptions;      // オプション
  var Offset: Integer;          // 表示オフセット(ピクセル)
  var FittedChars: Integer;     // 最大表示幅に表示できる文字数
  var DXs: TDXArray             // 各文字の文字幅の配列(ピクセル)
  ): WideString;                // 戻り値は表示できなかった残りの文字列
var
  ACanvas: TCanvas;                 // Canvas;
  cp: Integer;                      // 処理中の文字の位置
  CharWidth: Integer;               // 処理中の文字の幅
  CharIndex: Integer;               // 処理中の文字のインデックス(1オリジン)
  BreakChars: array of Boolean;     // ブレーク可能文字を示す配列
  NumBreakChars: Integer;           // ブレーク可能文字の総数
  CellDistances: array of Double;   // セルの大きさ
  tm: TTextMetric;                  // テキストメトリック
  SumOfDXs: Integer;                // セル間スペースの和(元の大きさがベース)
  SumOfCellDistances: Double;       // セル間スペースの和(高さ=4096 がベース)
  CellAdjust: Double;               // ブレーク文字のセル幅の調整値
  LastBreakCharIndex: Integer;      // 処理中の文字より前の最後のブレー文字
  ProcessedChars: Integer;          // GetTExtPosition が1行分の処理した
                                    // 文字数
  FindNotSpace: Boolean;            // 既にスペースが見つかったことを示す
  i, j: Integer;
  Kernings: array of array of Integer;  // Kerning 情報
  KerningPairs: array of TKerningPair;  // Kerning Pair
  nPairs: Integer;                      // Kerning Pair の数
  Kerning: Integer;                     // カーニング量
  LogFont: TLogFont;                    // 論理フォント

  // 文字がスペースかどうかを返す
  function IsSPace(w: WideChar): Boolean;
  begin Result := (Ord(w) = $0020) or (Ord(w) = $3000); end;

  // 文字がブレーク文字かどうかを返す
  function IsBreakable(w: WideChar): Boolean;
  begin
    Result :=  IsSpace(w) or (Ord(w) >= 256);
  end;
begin
  Offset := 0;
  ACanvas := TCanvas.Create;
  try
    ACanvas.Handle := GetDC(0);
    // フォントの高さを 4096 に変更
    GetObject(FontHandle, SizeOf(TLogFont), @LogFont);
    LogFont.lfHeight := -4096;
    LogFont.lfWidth := 0;
    ACanvas.Font.Handle := CreateFontIndirect(LogFont);

    // バッファ確保
    SetLength(DXs, Length(ws));
    SetLength(BreakChars, Length(ws));
    SetLength(CellDistances, Length(ws));

    // Kerning を行うなら Kerning 情報を得る
    if foKerning in Options then begin
      SetLength(Kernings, 128, 128);
      for i := 0 to 127 do for j := 0 to 127 do
        Kernings[i, j] := 0;
      nPairs := GetKerningPairs(ACanvas.Handle, 0, Nil^);
      if nPairs > 0 then begin
        SetLength(KerningPairs, nPairs);
        GetKerningPairs(ACanvas.Handle, nPairs, KerningPairs[0]);
      end;

      // Kerning は英文字に限る
      for i := 0 to nPairs-1 do
        if (32 < KerningPairs[i].wFirst) and
           (KerningPairs[i].wFirst < 128) and
           (32 < KerningPairs[i].wSecond) and
           (KerningPairs[i].wSecond < 128) then
          Kernings[KerningPairs[i].wFirst, KerningPairs[i].wSecond] :=
            KerningPairs[i].iKernAmount;
    end;

    // 現在位置、文字インデックスを初期化
    cp := 0;
    CharIndex := 1;
    LastBreakCharIndex := 0; // 最後のブレーク文字インデックス＝無し
    FindNotSpace := False;   // スペースはまだ見つかっていない

    GetTextMetrics(ACanvas.Handle, tm); // 文字のOverhang を求めておく

    while CharIndex <= Length(ws) do
    begin
      // 文字の幅を求める
      GetCharWidthW(ACanvas.Handle,
                    Ord(ws[CharIndex]), Ord(ws[CharIndex]), CharWidth);
      CharWidth := CharWidth - tm.tmOverHang;

      if (foKerning in Options) and (CharIndex > 1) and
         (Ord(ws[CharIndex-1]) < 128) and (Ord(ws[CharIndex]) < 128) then
        Kerning := Kernings[Ord(ws[CharIndex-1]), Ord(ws[CharIndex])]
      else
        Kerning := 0;

      if (cp + CharWidth + Kerning) >
         (MaxExtent * 4096 / abs(FontHeight)) then
      // 文字幅の積算がMaxExtent を越えた場合
      begin
        if not IsSpace(ws[CharIndex]) then // スペースなら何もしない
        begin
          // ブレーク文字が無いならCharIndexまでの文字を採用
          if LastBreakCharIndex = 0 then
          begin
            ProcessedChars := CharIndex-1;
            Break;
          end
          else
          begin
            // ブレーク文字があるならブレーク文字まで採用
            CharIndex := LastBreakCharIndex;
            ProcessedChars := CharIndex;
            // ブレーク文字がスペースならスペースで無い文字まで削る
            while BreakChars[CharIndex-1] and IsSpace(ws[CharIndex]) do
              Dec(CharIndex);
            Inc(CharIndex);
            Break;
          end;
        end;
      end;
      cp := cp + Kerning + CharWidth;  // 次の文字位置を求める
      CellDistances[CharIndex-1] := CharWidth; // 文字幅を求める
      if CharIndex > 1 then
        CellDistances[CharIndex-2] := CellDistances[CharIndex-2] + Kerning;

      // 行頭のスペースはブレーク文字としない
      if IsBreakable(ws[CharIndex]) and (CharIndex > 1) and FindNotSpace then
      begin
        BreakChars[CharIndex-1] := True;
        LastBreakCharIndex := CharIndex;
      end
      else
        BreakChars[CharIndex-1] := False;

      // スペース文字以外を見つけたら記録
      if not IsSpace(ws[CharIndex]) then FindNotSpace := True;

      Inc(CharIndex); //次の文字
    end;

    // 全文字を処理した場合
    if CharIndex > Length(ws) then ProcessedChars := CharIndex-1;

    SetLength(DXs, CharIndex-1);
    FittedChars := CharIndex-1;

    // FittedChars = 0 は最低1文字必要
    if (FittedChars = 0) and (Length(ws) > 0) then
    begin
      FittedChars := 1;
      SetLength(DXs, 1);
      DXs[0] := 0;
    end;

    // 処理文字列は最低1文字必要
    if (ProcessedChars = 0) and (Length(ws) > 0) then
      ProcessedChars := 1;

    // 文字列より FittedChars が小さければ整列処理を行う
    if ((FittedChars < Length(ws)) and (FittedChars > 0) and
        (foJustify in Options)) or
       ((foEven in Options) and (FittedChars > 0)) then
    begin
      // ブレーク文字数を得る
      if not (foEven in Options) then
      begin
        NumBreakChars := 0;
        for i := 0 to FittedChars-1 do
          if BreakChars[i] then Inc(NumBreakChars);
      end
      else
      begin
        NumBreakChars := FittedChars-1;
        for i := 1 to FittedChars-1 do
          BreakChars[i] := True;
      end;

      // ブレーク文字の前の文字に文字幅の調整値を割り振る
      if NumBreakChars >= 1 then
      begin
        SumOfCellDistances := 0;
        for i := 0 to FittedChars-1 do
          SumOfCellDistances := SumOfCellDistances + CellDistances[i];
        CellAdjust := (MaxExtent * 4096 / abs(FontHeight)
                       - SumOfCellDistances) / NumBreakChars;
        for i := 1 to FittedChars-1 do
          if BreakChars[i] then
            CellDistances[i-1] := CellDistances[i-1] + CellAdjust;
      end
    end;

    if (FittedChars > 0) and
       ((foRight in Options) or (foCenter in Options)) then
    begin
      SumOfCellDistances := 0;
      for i := 0 to FittedChars-1 do
        SumOfCellDistances := SumOfCellDistances + CellDistances[i];
      Offset := Round((MaxExtent * 4096 / abs(FontHeight)
                       - SumOfCellDistances) * abs(FontHeight) / 4096
                       * PixelsPerInch / 1440);
      if foCenter in Options then Offset := Offset div 2;
    end;

    // 文字幅を元の文字の大きさのものに変換する
    // 誤差が蓄積しないように注意
    SumOfDXs := 0;
    SumOfCellDistances := 0;
    for i := 0 to FittedChars-1 do
    begin
      SumOfCellDistances := SumOfCellDistances + CellDistances[i];
      DXs[i] := Round(SumOfCellDistances *
                      abs(FontHeight) / 4096 *
                      PixelsPerInch / 1440 - SumOfDXs);
      Inc(SumOfDXs, DXs[i]);
    end;
    // 処理済の文字を入力された文字から除去し返す。
    Delete(ws, 1, ProcessedChars);
    Result := ws;
  finally
    ReleaseDC(0, ACanvas.Handle);
    ACanvas.Free;
  end;
end;

end.
