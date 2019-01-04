{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
unit MetafileUtils;

interface

{$IFDEF ORIGINAL} // 2002.5.22(Ver. 1.1)
uses Graphics;
{$ELSE}
uses Windows, Graphics;
{$ENDIF}

// Canvas のフォントの横幅が指定されていない場合
// 適切な横幅を設定する。
procedure AdjustFont(Canvas: TCanvas);

// メタファイルの物理インチを指定された値に
// 変更する。
// DPIX は横方向の新物理インチ
// DPIY は縦方向の新物理インチ
// DPIX, DPIY を省略すると、DPIX/DPIY には
// スクリーンの論理インチが採用される
procedure AdjustPhysicalInch(Metafile: TMetafile;
                             DPIX: Integer = 0;
                             DPIY: Integer = 0);

{$IFNDEF ORIGINAL} // 追加 2002.5.22(Ver. 1.1)
// メタファイルを Windows 9X/ME でも他のメタファイルに書き込めるように
// 変換する
//   Windows 9X/ME ではバグのため２文字以上の文字列を描画する
//   ExtTextOutA, ExtTextOutW レコードを含むメタファイルを
//   他のメタファイルに正常に描画できないことがあります。
//   このルーチンを使えば、他のメタファイルに正常に描画できる
//   メタファイルを作成できます。
//   このルーチンは NT系のWindows では元のメタファイルと
//   全く同じメタファイルを作ります。
function FixMetafileFor9X(AMetafile: TMetafile; RefDC: HDC): TMetafile;

// Windows 9X/ME でもメタファイルへの描画に使える ExtTextOut
//   Windows 9X/ME ではバグのため ２文字以上の文字列を描画する
//   ExtTextOut はメタファイルに正常に書き込まれないことがあります。
//   このルーチンを使えば正常に書き込めます。
//   このルーチンは NT系のWindows ではパラメータをそのまま
//   ExtTextOut API に渡します。
function DHGLExtTextOut(DC: HDC; x, y: Integer; Option: DWORD;
                        pR: PRect; pString: PChar; cbCount: Integer;
                        lpDX: PInteger): Boolean;

// Windows 9X/ME でも使える ExtTextOutW
//   Windows 9X/ME ではバグのため ExtTextOutW をメタファイルに
//   書き込むとアプリケーションが落ちてしまうことがあります。
//   このルーチンを使えば正常に書き込めます。
//   このルーチンは NT系のWindows ではパラメータをそのまま
//   ExtTextOutW API に渡します。
function DHGLExtTextOutW(DC: HDC; x, y: Integer; Option: DWORD;
                        pR: PRect; pString: PWChar; cbCount: Integer;
                        lpDX: PInteger): Boolean;
{$ENDIF}

implementation

{$IFDEF ORIGINAL} // 2002.5.22(Ver. 1.1)
uses Windows, SysUtils, Classes;
{$ELSE}
uses SysUtils, Classes;
{$ENDIF}

type
  // Win2K のメタファイルをヘッダレコード定義
  PEnhMetaHeaderV5 = ^TEnhMetaHeaderV5;
  TENHMETAHEADERV5 = packed record
    Header: TEnhMetaHeader;
    szlMicroMeters: TSize;
  end;

// Canvas のフォントの横幅が指定されていない場合
// 適切な横幅を設定する。
procedure AdjustFont(Canvas: TCanvas);
var
  tm: TTextMetric;
  lf: TLogFOnt;
begin
  GetObject(Canvas.Font.Handle, SizeOf(lf), @lf);
  if lf.lfWidth = 0 then
  begin
    GetTextMetrics(Canvas.Handle, tm);
    lf.lfWidth := -lf.lfHeight * tm.tmAveCharWidth div tm.tmHeight;
    Canvas.Font.Handle := CreateFontIndirect(lf);
  end;
end;

// AdjustPhysicalInch から EnhMetaFileProc へ渡す
// パラメータブロックの宣言
type
  TParaBlock = record
    MS: TMemoryStream;
    DPIX: Integer;
    DPIY: Integer;
  end;
  PParaBlock = ^TParaBlock;

// メタファイルの変更処理
// メタファイルのヘッダレコードの物理インチを
// DPIX, DPIY で指定された値にする。
// szlDevice は変えず, rclFrame, szlMillimeters
// を修正する。W2k の場合は szlMicroMeters も修正する
function EnhMetaFileProc(
  h: HDC; lpHTable: Pointer; lpEMFR: PEnhMetaHeader;
  nObj: Integer; lpdata: LPARAM): Integer; stdcall;
var
  // 更新後のメタファイルを受け取るメモリストリーム
  MS: TMemoryStream;
  // ヘッダレコードの受け取りバッファ
  Buf: array of Byte;
  // ヘッダレコード用アクセス用ポインタ
  pHead: PENHMETAHEADER;
  // ピクセル単位の境界枠
  PixelWidth, PixelHeight: Int64;
  // 指定された物理インチ
  DPIX, DPIY: Integer;
begin
  // パラメータブロックを受け取る
  MS := PParaBlock(lpdata).MS;
  DPIX := PParaBlock(lpData).DPIX;
  DPIY := PParaBlock(lpdata).DPIY;

  case lpEMFR.iType of
    EMR_HEADER: // ヘッダレコード
      begin
        // ヘッダレコードをコピーする
        SetLength(Buf, lpEMFR.nSize);
        System.Move(lpEMFR^, Buf[0], lpEMFR.nSize);
        pHead := PENHMETAHEADER(Buf);

        // 境界矩形のピクセル単位の幅と高さを得る
        PixelWidth  := Int64(pHead.rclFrame.Right - pHead.rclFrame.Left) *
                       pHead.szlDevice.cx  div
                       pHead.szlMillimeters.cx div 100;
        PixelHeight := Int64(pHead.rclFrame.Bottom - pHead.rclFrame.Top) *
                       pHead.szlDevice.cy  div
                       pHead.szlMillimeters.cy div 100;

        // 境界矩形の幅と高さ(ピクセル)とDPIX, DPIY を使って
        // 境界矩形(0.01mm単位)を再設定する
        pHead.rclFrame.Right := pHead.rclFrame.Left +
                                Round(PixelWidth * 2540 / DPIX);
        pHead.rclFrame.Bottom := pHead.rclFrame.Top +
                                 Round(PixelHeight * 2540 / DPIY);

        // デバイスの大きさ(ピクセル)と DPIX, DPIY を使って
        // デバイスの大きさ(mm単位)を再設定する
        pHead.szlMillimeters.cx := round(pHead.szlDevice.cx * 25.40 /DPIX);
        pHead.szlMillimeters.cy := round(pHead.szlDevice.cy * 25.40 /DPIY);

        // Win2K のヘッダか？
        if LongInt(@PEnhMetaHeaderV5(pHead).szlMicroMeters)
           - LongInt(pHead) < pHead.nSize then
        begin
          // W2K の追加フィールド(szlMillimeters の μメータ版)も
          // 再設定する
          PEnhMetaHeaderV5(pHead).szlMicroMeters.cx :=
            round(Int64(pHead.szlDevice.cx) * 25400 / DPIX);
          PEnhMetaHeaderV5(pHead).szlMicroMeters.cy :=
            round(Int64(pHead.szlDevice.cy) * 25400 /DPIY);
        end;

        // 更新されたヘッダレコードをストリームに書き込む
        MS.WriteBuffer(pHead^, pHead.nSize);
      end;
    else
      // ヘッダレコード以外はストリームに単純コピーする
      MS.WriteBuffer(lpEMFR^, lpEMFR.nSize);
  end;
  Result := 1;
end;

procedure AdjustPhysicalInch(Metafile: TMetafile;
                             DPIX: Integer = 0;
                             DPIY: Integer = 0);
var
  // 更新されたメタファイルを受け取るメモリストリーム
  MS: TMemoryStream;
  R: TRect; // ダミー
  // EnhMetaFileProc　に渡すパラメータブロック
  ParaBlock: TParaBlock;
  // スクリーンの DC
  DC: HDC;
begin
  // DPIX, DPIY が指定されていなければスクリーンの
  // 論理インチを採用する
  DC := GetDC(0);
  try
    if DPIX = 0 then DPIX := GetDeviceCaps(DC, LOGPIXELSX);
    if DPIY = 0 then DPIY := GetDeviceCaps(DC, LOGPIXELSY);
  finally
    ReleaseDC(0, DC);
  end;

  // Enhanced Metafile を受け取るメモリストリームを作る
  MS := TMemoryStream.Create;
  try
    ParaBlock.MS := MS;
    ParaBlock.DPIX := DPIX;
    ParaBlock.DPIY := DPIY;

    // 変更処理
    EnumEnhMetafile(0, Metafile.Handle, @EnhMetafileProc, @ParaBlock, R);

    // 変更処理後のメタファイルのメモリイメージから Enhanced Metafile
    // を作る
    MS.Position := 0;
    Metafile.LoadFromStream(MS);
  finally
    MS.Free;
  end;
end;

{$IFNDEF ORIGINAL} // 追加 2002.5.22(Ver. 1.1)
type
  // EXTTextOut の1文字分のデータを保持するレコード
  TETOChar = record
    FString: string;     // MBCS 1文字分の文字列
    FPosition: Integer;  // 文字列の先頭からの距離
    FWidth: Integer;     // 文字幅(セル長)
  end;

  // ///////////////////////////////////////////
  // ExtTextOut コンバート用クラス
  //   このクラスの役割:
  //     Windows 9X/ME にはメタファイルの文字の扱いに問題がある
  //     まず ExtTextOutW や TextOutW API でメタファイルに文字を
  //     描くとアプリケーションが落ちてしまう。さらに、
  //     複数文字を含む ExtTextOut API で文字列をメタファイルに
  //     描くと、不正な文字間スペーシングが記録されてしまう。
  //     DrawText や TextOut API で描く場合は ExtTextOutA レコード
  //     が記録されるにもかかわらず、問題は起きない。
  //     以上から以下の問題が起きる。
  //     1) メタファイルへの描画に ExtTextOutW や TextOutW が使えない。
  //     2) DrawText や TextOut でメタファイルに文字列を書き込むと
  //        正常なメタファイルができるが、このメタファイルをさらに
  //        他のメタファイルに描くとと、ExtTextOutA レコードが
  //        ExtTextOut API で 描かれるので、文字間スペーシングが
  //        狂ってしまう。つまり Windows 9X/ME では文字列を含む
  //        メタファイルを他のメタファイルに描画できない。
  //  このクラスの対処法：
  //    対処の基本方針は簡単で、複数の文字を含む ExtTextOut や
  //    ExtTextOutW の描画を一文字の ExtTextOutA の列に分解する。
  //    但し、ExtTextOut/ExtTextOutW を複数の ExtTextOutA に分解
  //    するのは、 ETO_OPAQUE フラグや背景モード、文字の表示順
  //    フォントの回転を考慮すると、容易ではない。
  //    しかし TExtTextOut はこれをやってのける。このため長大な
  //    コードになっている。
  //
  //
  //  コンストラクタ
  //      Create:  ExtTextOut のパラメータで TExtTextOut を初期化する。
  //      CreateW: ExtTextOutW のパラメータで TExtTextOut を初期化する。
  //      Create(pRec: PEMREXTTEXTOUT):
  //               メタファイルの EMR_EXTTEXTOUTA, EMT_EXTTEXTOUTW,
  //               EMR_POLYTEXTOUTA, EMR_POLYTEXTOUTW の内容で、
  //               TExtTextOut を初期化する。
  // メソッド
  //      DrawToCanvas:
  //        TExtTextOut の内容を、一文字の ExtTextOut だけを使って
  //        キャンバスに描く
  //      DrawToDC:
  //        TExtTextOut の内容を、一文字の ExtTextOut だけを使って
  //        DCに描く
  //      PlayExtTextOut:
  //        TExtTextOut の内容を、一文字の ExtTextOutAレコード だけを
  //        使って、メタファイルの Canvas に描く
  //        EnumEnhMetafile のコールバックルーチンの中で使う。
  //
  TExtTextOutConverter = class
  private
    // インスタンスが　メタファイルレコードから作られたことを示すフラグ
    FCreatedFromMetafileRecord: Boolean;
    FRclBounds: TRect;       // 図形を囲む矩形(メタファイルレコードから取得)
    FIGraphicsMode: DWORD;   // グラフィックモード(メタファイルレコードから取得)
    FExScale: Single;        // スケールファクタ(メタファイルレコードから取得)
    FEySCale: Single;
    FReference: TPoint;      // 参照点
    FOption: DWORD;          // オプション
    FRect: TRect;            // エリアサイズ
    FText: array of TETOChar;// 文字列

    // ExtTextOutA レコードの作製
    function CreateExtTextOutARecord(x, y: Integer;
                                     Option: DWORD;
                                     Text: string;
                                     R: TRect;
                                     pi: PInteger): PEMREXTTEXTOUT;
    // SaveDC レコードの作製
    function CreateSaveDCRecord: PEMRSAVEDC;
    // RestoreDC レコードの作製
    function CreateRestoreDCRecord: PEMRRESTOREDC;
    // SetBkMode レコードの作製
    function CreateSetBkModeRecord(Mode: Integer): PEMRSetBkMode;
  public
    constructor Create; overload;  //  使用禁止
    // メタファイルレコードを使ってコンストラクト
    constructor Create (x, y: Integer;
                        Option: DWORD;
                        pR: PRect;
                        Text: string;
                        pi: PInteger); overload;
    // ExtTextOutA のパラメータからコンストラクト
    constructor CreateW(x, y: Integer;
                        Option: DWORD;
                        pR: PRect;
                        Text: Widestring;
                        pi: PInteger); overload;
    // ExtTextOutW のパラメータからコンストラクト
    constructor Create(pRec: PEMREXTTEXTOUT); overload;

    // 文字列を描く(メタファイルキャンバス用)
    procedure DrawToCanvas(Canvas: TCanvas);
    procedure DrawToDC(DC: HDC);
    // 文字列を描く(メタファイルレコード生成用)
    procedure PlayExtTextOut(DC: HDC; lpHTable: Pointer; nObj: DWORD);
  end;


// メタファイルに安全に描ける ExtTextOut
function DHGLExtTextOut(DC: HDC; x, y: Integer; Option: DWORD;
                        pR: PRect; pString: PChar; cbCount: Integer;
                        lpDX: PInteger): Boolean;
var
  etoc: TExtTextOutConverter;
  Text: string;
begin
  Result := True;
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result := ExtTextOut(DC, x, y, Option, pR, pString, cbCount, lpDx)
  else
  begin
    try
      SetLength(Text, cbCount);
      System.Move(pString^, Text[1], cbCount);
      etoc := TExtTextOutConverter.Create(x, y, Option, pR,
                                         Text, lpDx);
      try
        etoc.DrawToDC(DC);
      finally
        etoc.Free;
      end;
    except
      Result := False;
    end;
  end;
end;

// メタファイルに安全に描ける ExtTextOutW
function DHGLExtTextOutW(DC: HDC; x, y: Integer; Option: DWORD;
                        pR: PRect; pString: PWChar; cbCount: Integer;
                        lpDX: PInteger): Boolean;
var
  etoc: TExtTextOutConverter;
  TextW: WideString;
begin
  Result := True;
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result := ExtTextOutW(DC, x, y, Option, pR, pString, cbCount, lpDx)
  else
  begin
    try
      SetLength(TextW, cbCount);
      System.Move(pString^, TextW[1], cbCount*2);
      etoc := TExtTextOutConverter.CreateW(x, y, Option, pR,
                                          TextW, lpDx);
      try
        etoc.DrawToDC(DC);
      finally
        etoc.Free;
      end;
    except
      Result := False;
    end;
  end;
end;

{ TExtTextOut }

// ExtTextOut のパラメータからインスタンスを作る
constructor TExtTextOutConverter.Create(x, y: Integer;
                                        Option: DWORD;
                                        pR: PRect;
                                        Text: string;
                                        pi: PInteger);
var
  i: Integer;
  TextLength: Integer;    // テキスト長(Byte)
  CharCount: Integer;     // 文字数
  CType: TMbcsByteType;   // 文字の種別
  Distance: Integer;      // 文字列の先頭位置からの距離
begin
  FReference := Point(x, y);
  FOption := Option;
  if pR = Nil then FRect := Rect(0, 0, 0, 0)
              else FRect := pR^;

  // データ格納場所の確保
  TextLength := Length(Text);
  SetLength(FText, TextLength);

  CharCount := 0;
  Distance := 0;

  i := 1;
  while i <=  TextLength do
  begin
    CType := ByteType(Text, i);
    if CType = mbSingleByte then
    begin // Syngle Byte 文字
      FText[CharCount].FString := Text[i];
      FText[CharCount].FPosition := Distance;
      FText[CharCount].FWidth := pi^;
      Inc(Distance, pi^);
      Inc(pi);
      Inc(i);
      Inc(CharCount);
    end
    else if CType = mbLeadByte then
    begin
      if i >= TextLength then
      begin // Double Byte 文字 だけど　文字列長が足りない
        FText[CharCount].FString := '?';
        FText[CharCount].FPosition := Distance;
        FText[CharCount].FWidth := pi^;
        Inc(Distance, pi^);
        Inc(pi);
        Inc(i);
        Inc(CharCount);
      end
      else
      begin // Double Byte 文字
        FText[CharCount].FString := Text[i] + Text[i+1];
        FText[CharCount].FPosition := Distance;
        FText[CharCount].FWidth := pi^;
        Inc(Distance, pi^);
        Inc(pi);
        FText[CharCount].FWidth := FText[CharCount].FWidth + pi^;
        Inc(Distance, pi^);
        Inc(pi);
        Inc(i, 2);
        Inc(CharCount);
      end;
    end
    else
    begin // ありえないが　一応処理
      FText[CharCount].FString := '?';
      FText[CharCount].FPosition := Distance;
      FText[CharCount].FWidth := pi^;
      Inc(Distance, pi^);
      Inc(pi);
      Inc(i);
      Inc(CharCount);
    end;
  end;
  SetLength(FText, CharCount); // 文字列長を調整
end;

// ExtTextOut レコードから生成
constructor TExtTextOutConverter.Create(pRec: PEMREXTTEXTOUT);
var
  pString: PCHAR;
  Text: String;
  TextW: WideString;
begin
  FCreatedFromMetafileRecord := True;

  // レコードから必要項目をkピー
  FRclBounds := pRec.rclBounds;
  FIGraphicsMode := pRec.iGraphicsMode;
  FExScale := pRec.exScale;
  FEyScale := pRec.eyScale;

  // 文字データの吸い上げ
  pString := PChar(pRec) + pRec.emrtext.offString;

  case pRec.emr.iType of
  EMR_EXTTEXTOUTA, EMR_POLYTEXTOUTA:
    begin
      SetLength(Text, pRec.emrtext.nChars);
      System.Move(pString^, Text[1], pRec.emrtext.nChars);
      // ExtTextOut パラメータ用のコンストラクタを呼ぶ
      Create(pRec.emrtext.ptlReference.x, pRec.emrtext.ptlReference.y,
             pRec.emrtext.fOptions,
             @pRec.emrtext.rcl,
             Text,
             PInteger(PChar(pRec) + pRec.emrtext.offDx));
    end;
  EMR_EXTTEXTOUTW, EMR_POLYTEXTOUTW:
    begin
      SetLength(TextW, pRec.emrtext.nChars);
      System.Move(pString^, TextW[1], pRec.emrtext.nChars * 2);
      // ExtTextOut パラメータ用のコンストラクタを呼ぶ
      CreateW(pRec.emrtext.ptlReference.x, pRec.emrtext.ptlReference.y,
             pRec.emrtext.fOptions,
             @pRec.emrtext.rcl,
             TextW,
             PInteger(PChar(pRec) + pRec.emrtext.offDx));
    end;
  else
    Assert(False);
  end;
end;

constructor TExtTextOutConverter.Create;
begin
  // 使ってはいけない。
  raise Exception.Create('TExtTextOut: Construct Error');
end;

// ExtTextOutA レコードを作る
function TExtTextOutConverter.CreateExtTextOutARecord(
  x, y: Integer; Option: DWORD; Text: string; R: TRect;
  pi: PInteger): PEMREXTTEXTOUT;
var
  RecordSize: Integer;
  p: PChar;
begin
  // レコードをヒープから確保
  RecordSize := SizeOf(EMREXTTEXTOUTA) + Length(Text) +
                 Length(Text) * SizeOf(Integer);
  GetMem(Result, RecordSize);
  try
    Result.emr.iType := EMR_EXTTEXTOUTA;
    Result.emr.nSize := RecordSize;
    Result.rclBounds := FRclBounds;
    Result.iGraphicsMode := FIGraphicsMode;
    Result.exScale := FExScale;
    Result.eyScale := FEyScale;
    Result.emrtext.ptlReference := Point(x, y);
    Result.emrtext.nChars := Length(Text);
    Result.emrtext.fOptions := Option;
    Result.emrtext.rcl := R;
    Result.emrtext.offString := SizeOf(EMREXTTEXTOUTA);
    p := PChar(Result) + SizeOf(EMREXTTEXTOUTA);
    System.Move(Text[1], p^, Length(Text));
    Result.emrtext.offDx := SizeOf(EMREXTTEXTOUTA) + Length(Text);
    p := PChar(Result) + SizeOf(EMREXTTEXTOUTA) + Length(Text);
    System.Move(pi^, p^, Length(Text) * SizeOf(Integer));
  except
    FreeMem(Result);
    raise;
  end;
end;

// RestoreDC レコードを作る
function TExtTextOutConverter.CreateRestoreDCRecord: PEMRRESTOREDC;
begin
  // レコードをヒープから確保
  GetMem(Result, SizeOf(EMRRestoreDC));
  try
    Result.emr.iType := EMR_RESTOREDC;
    Result.emr.nSize := SizeOf(EMRRestoreDC);
    Result.iRelative := -1; // 直前の SaveDC の状態に戻す
  except
    FreeMem(Result);
    raise;
  end;
end;

// SaveDC レコードを作る
function TExtTextOutConverter.CreateSaveDCRecord: PEMRSAVEDC;
begin
  // レコードをヒープから確保
  GetMem(Result, SizeOf(TEMRSaveDC));
  try
    Result.emr.iType := EMR_SAVEDC;
    Result.emr.nSize := SizeOf(TEMRSaveDC);
  except
    FreeMem(Result);
    raise;
  end;
end;

// SetBkMode レコードを作る
function TExtTextOutConverter.CreateSetBkModeRecord(Mode: Integer)
  : PEMRSetBkMode;
begin
  // レコードをヒープから確保
  GetMem(Result, SizeOf(TEMRSetBkMode));
  try
    Result.emr.iType := EMR_SETBKMODE;
    Result.emr.nSize := SizeOf(TEMRSETBKMODE);
    Result.iMode := Mode;
  except
    FreeMem(Result);
    raise;
  end;
end;

// ExtTextOutW のパラメータでインスタンスを作る
constructor TExtTextOutConverter.CreateW(x, y: Integer;
                                         Option: DWORD;
                                         pR: PRect;
                                         Text: Widestring;
                                         pi: PInteger);
var
  TextLength: Integer; // テキスト長(Unicode単位)
  i: Integer;
  Distance: Integer;   // テキストの先頭からの距離
begin
  FReference := Point(x, y);
  FOption := Option;

  if pR = Nil then FRect := Rect(0, 0, 0, 0)
              else FRect := pR^;

  // 文字列格納エリアの確保
  TextLength := Length(Text);
  SetLength(FText, TextLength);

  Distance := 0;
  for i := 1 to  TextLength do
  begin
    FText[i-1].FString := Text[i];
    FText[i-1].FPosition := Distance;
    FText[i-1].FWidth := pi^;
    Inc(Distance, pi^);
    Inc(pi);
  end;
end;

// キャンバスに描く
procedure TExtTextOutConverter.DrawToCanvas(Canvas: TCanvas);
begin
  DrawToDC(Canvas.Handle);
end;

// DC に描く
procedure TExtTextOutConverter.DrawToDC(DC: HDC);
var
  TextLength: Integer;
  i: Integer;
  DXs: array[0..1] of Integer;
  lf: TLogFont;   // 論理フォント
  OldFont: HFont;
  EscapeVectorX, EscapeVectorY: Extended; // 文字の傾きを表す単位ベクタ
  LastCharIndex: Integer; // 最も後ろに位置する文字のインデックス

  // インデックスで指定された1文字だけを描く
  procedure DrawOneChar(i: Integer; Width: Integer; Option: DWord);
  begin
    DXs[0] := Width;
    DXs[1] := 0;
    Win32Check(ExtTextOut(DC,
                 FReference.x + Round(FText[i].FPosition * EscapeVectorX),
                 FReference.y + Round(FText[i].FPosition * EscapeVectorY),
                 Option, @FRect,
                 PChar(FText[i].FString), Length(FText[i].FString), @DXs));
  end;

  // 最も後ろに位置する文字を見つける
  function SelectLastChar: Integer;
  var
    i: Integer;
    RightEdgePos: Integer;
  begin
    Result := 0;
    RightEdgePos := FText[0].FPosition + FText[0].FWidth;

    for i := 1 to TextLength-1 do
      if FText[i].FPosition + FText[i].FWidth > RightEdgePos then
      begin
        Result := i;
        RightEdgePos := FText[i].FPosition + FText[i].FWidth;
      end;
  end;
begin
  TextLength := Length(FText);
  if TextLength = 0 then Exit;

  // 論理フォントを得、文字の傾きを表す単位ベクタを計算する
  OldFont := SelectObject(DC, GetStockObject(SYSTEM_FONT));
  try
    GetObject(OldFont, SizeOf(TLogFont), @lf);
  finally
    SelectObject(DC, OldFont);
  end;
  EscapeVectorX := cos(lf.lfEscapement * pi / 1800);
  EscapeVectorY := -sin(lf.lfEscapement * pi / 1800) *
                   GetDeviceCaps(DC, LOGPIXELSY) /
                   GetDeviceCaps(DC, LOGPIXELSX);

  // 最も後ろの位置の文字を描く
  LastCharIndex := SelectLastChar;
  // 最初の文字を描く
  DrawOneChar(0, FText[LastCharIndex].FPosition + FText[LastCharIndex].FWidth,
              FOption);
  if TextLength > 1 then
  // 文字列長が 1 以上なら 最後の文字を描きETO_OPAQUE フラグを落とし、
  // 背景モードをTRANSPARENT にして全文字を描く
  begin
    DrawOneChar(SelectLastChar, FText[SelectLastChar].FWidth, FOption);
    SaveDC(DC);
    try
      SetBkMode(DC, TRANSPARENT);
      for i := 0 to TextLength-1 do
        DrawOneChar(i, FText[i].FWidth, FOption and not ETO_OPAQUE);
    finally
      RestoreDC(DC, -1);
    end;
  end;
end;

// メタファイルレコードを作って描く
procedure TExtTextOutConverter.PlayExtTextOut(DC: HDC; lpHTable: Pointer;
  nObj: DWORD);
var
  TextLength: Integer;                    // 文字列長
  i: Integer;
  DXs: array[0..1] of Integer;            // 文字セル長
  lf: TLogFont;                           // 論理フォント
  OldFont: HFont;
  EscapeVectorX, EscapeVectorY: Extended; // 文字の傾きを表す単位ベクタ
  LastCharIndex: Integer;                 // 最後に位置する文字のインデックス
  pRec: PENHMETARECORD;                   // レコードポインタ

  // 1文字描く
  procedure DrawOneChar(i: Integer; Width: Integer; Option: DWord);
  var
    pRec: PENHMETARECORD;
  begin
    DXs[0] := Width; // セル長をセット
    DXs[1] := 0;

    // ExtTextOutA レコードを作る
    pRec := PENHMETARECORD(CreateExtTextOutARecord(
       FReference.x + Round(FText[i].FPosition * EscapeVectorX),
       FReference.y + Round(FText[i].FPosition * EscapeVectorY),
       Option, FText[i].FString, FRect, @DXs));
    try
      // 描画
      PlayEnhMetafileRecord(DC, PHandleTable(lpHTable)^, pRec^, nObj);
    finally
      FreeMem(pRec);
    end;
  end;

  // 位置的に最後の文字を求める
  function SelectLastChar: Integer;
  var
    i: Integer;
    RightEdgePos: Integer;
  begin
    Result := 0;
    RightEdgePos := FText[0].FPosition + FText[0].FWidth;

    for i := 1 to TextLength-1 do
      if FText[i].FPosition + FText[i].FWidth > RightEdgePos then
      begin
        Result := i;
        RightEdgePos := FText[i].FPosition + FText[i].FWidth;
      end;
  end;
begin
  Assert(Self.FCreatedFromMetafileRecord);

  TextLength := Length(FText);
  if TextLength = 0 then Exit;

  // 文字の傾きを得、単位ベクタを求める
  OldFont := SelectObject(DC, GetStockObject(SYSTEM_FONT));
  try
    GetObject(OldFont, SizeOf(TLogFont), @lf);
  finally
    SelectObject(DC, OldFont);
  end;
  EscapeVectorX := cos(lf.lfEscapement * pi / 1800);
  EscapeVectorY := -sin(lf.lfEscapement * pi / 1800) *
                   GetDeviceCaps(DC, LOGPIXELSY) /
                   GetDeviceCaps(DC, LOGPIXELSX);

  // 最後の位置の文字を求める
  LastCharIndex := SelectLastChar;

  // 最初の文字を描く
  DrawOneChar(0, FText[LastCharIndex].FPosition + FText[LastCharIndex].FWidth,
              FOption);
  if TextLength > 1 then
  begin
    // 文字列長が 1 以上なら 最後の文字を描きETO_OPAQUE フラグを落とし、
    // 背景モードをTRANSPARENT にして全文字を描く
    DrawOneChar(SelectLastChar, FText[SelectLastChar].FWidth, FOption);
    pRec := PENHMETARECORD(CreateSaveDCRecord);
    try
      PlayEnhMetafileRecord(DC, PHandleTable(lpHTable)^, pRec^, nObj);
    finally
      FreeMem(pRec);
    end;
    try
      pRec := PENHMETARECORD(CreateSetBkModeRecord(TRANSPARENT));
      try
        PlayEnhMetafileRecord(DC, PHandleTable(lpHTable)^, pRec^, nObj);
      finally
        FreeMem(pRec);
      end;
      for i := 0 to TextLength-1 do
        DrawOneChar(i, FText[i].FWidth, FOption and not ETO_OPAQUE);
    finally
      pRec := PENHMETARECORD(CreateRestoreDCRecord);
      try
        PlayEnhMetafileRecord(DC, PHandleTable(lpHTable)^, pRec^, nObj);
      finally
        FreeMem(pRec);
      end;
    end;
  end;
end;

type
  TParaBlockForGetSize = record
    MMWidth, MMHeight: Integer;
  end;
  PParaBlockForGetSize = ^TParaBlockForGetSize;

// メタファイルヘッダから rclFrame の大きさを取得する
function FixMetafileProcForGetSize(
  h: HDC; lpHTable: Pointer; lpEMFR: PEnhMetaRecord;
  nObj: Integer; lpdata: LPARAM): Integer; stdcall;
var
  pPara: PParaBlockForGetSize;
  pHead: PENHMETAHEADER;
begin
  case lpEMFR.iType of
  EMR_HEADER: // ヘッダレコード
    begin
      pPara := PParaBlockForGetSize(lpdata);
      pHead := PENHMETAHEADER(lpEMFR);
      // 大きさを取得
      pPara.MMWidth  := pHead.rclFrame.Right - pHead.rclFrame.Left;
      pPara.MMHeight := pHead.rclFrame.Bottom - pHead.rclFrame.Top;
      Result := 0;
      Exit;
    end;
  end;
  Result := 1;
end;

// メタファイルの変換処理を行う
function FixMetafileProc(
  h: HDC; lpHTable: Pointer; lpEMFR: PEnhMetaRecord;
  nObj: Integer; lpdata: LPARAM): Integer; stdcall;
var
  etoc: TExtTextOutConverter;
begin
  case lpEMFR.iType of
  EMR_EXTTEXTOUTA, EMR_POLYTEXTOUTA, EMR_EXTTEXTOUTW, EMR_POLYTEXTOUTW:
    begin  // ExtTextOutAレコード
      etoc := TExtTextOutConverter.Create(PEMREXTTEXTOUT(lpEMFR));
      try
        // ExtTextOutA を複数の ExtTextOutA に分解して描く
        etoc.PlayExtTextOut(h, lpHTable, nObj);
      finally
        etoc.Free;
      end;
    end;
  else
    PlayEnhMetafileRecord(h, PHandleTable(lpHTable)^, lpEMFR^, nObj);
  end;
  Result := 1;
end;

function FixMetafileFor9X(AMetafile: TMetafile; RefDC: HDC): TMetafile;
var
  R: TRect;                  // 描画先矩形
  MC: TMetafileCanvas;       // 描画先メタファイルのキャンバス
  DC: HDC;                   // 描画先メタファイルのキャンバスのハンドル
  NeedReleaseDC: Boolean;    // スクリーンDC の破棄が必要であることを示す
  Para: TParaBlockForGetSize;// メタファイルサイズ取得用パラメータブロック
  SavedInch: Integer;
begin
  // NT 系なら変更しない
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    Result := TMetafile.Create;
    try
      Result.Assign(AMetafile);
    except
      Result.Free;
      raise;
    end;
    Exit;
  end;

  if (AMetafile.MMWidth = 0) or (AMetafile.MMHeight = 0) then
    raise Exception.Create('FixMetafileFor9X: Metafile has no valid Size');

  // メタファイルの「正しい」大きさを取得する
  Para.MMWidth := 0; Para.MMHeight := 0;
  R := Rect(0, 0, 0, 0);

  EnumEnhMetafile(0, AMetafile.Handle, @FixMetafileProcForGetSize, @Para, R);

  if (Para.MMWidth = 0) or (Para.MMHeight = 0) then
    raise Exception.Create('FixMetafileFor9X: Metafile has no valid Size');

  Result := TMetafile.Create;
  try
    // メタファイルの大きさをセットする
    Result.MMWidth  := Para.MMWidth;
    Result.MMHeight := Para.MMHeight;

    // 描画先矩形の大きさを正しいものにする
    SavedInch := AMetafile.Inch;
    try
      AMetafile.Inch := 0;
      R := Rect(0, 0,
                AMetafile.Width * Result.MMWidth div AMetafile.MMWidth,
                AMetafile.Height * Result.MMHeight div AMetafile.MMHeight);
    finally
      AMetafile.Inch := SavedInch;
    end;

    // 参照デバイスが 0 ならスクリーンデバイスを仮定
    if RefDC = 0 then
    begin
      RefDC := GetDC(0);
      NeedReleaseDC := True;
    end
    else
      NeedReleaseDC := False;
    try
      MC := TMetafileCanvas.Create(Result, RefDC);
      try
        DC := MC.Handle;
        // 変更処理
        EnumEnhMetafile(DC, AMetafile.Handle, @FixMetafileProc, Nil, R);
      finally
        MC.Free;
      end;
    finally
      if NeedReleaseDC then ReleaseDC(0, RefDC);
    end;
    Result.MMWidth := AMetafile.MMWidth;
    Result.MMHeight := AMetafile.MMHeight;
    Result.Inch := AMetafile.Inch;
  except
    Result.Free;
    raise;
  end;
end;
{$ENDIF}

end.
