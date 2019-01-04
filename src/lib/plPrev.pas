{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$WARNINGS OFF}
//====================================================================
//    印刷プレビュー制御コンポーネント  TplPrev
//
//    この印刷プレビュー制御コンポーネントは，印刷のコードを描画する
//    ためのCanvasと，そこに描画した内容をプレビューするための，カス
//    タマイズ可能なフォームを提供するものです．プレビュー画面で頁送
//    り操作や印刷を実行します．
//
//
//  Ver 4.53-> 4.54変更点
//
//  ・Delphi2005(Win32)対応．
//  ・[印刷]ボタンでプリンタを変更した時に印刷できないバグを修正．
//  ・ImageVisibleプロパティ追加
//    Falseにするとプレビューフォームは表示するが，イメージは非表示
//    デフォルトはTrue
//  ・ImageDragプロパティ追加
//    マウスによるイメージの移動の許可．デフォルトはTrue
//  ・ImageShadeプロパティ追加
//    用紙の影の部分の描画の有無．デフォルトはTrue
//  ・マウスによるイメージの移動範囲を表示領域全体とした．
//    またこの部分のコードを修正．
//  ・プレビューフォームのボタン表示有無のコードを修正．
//  ・フォームのCreate時にプリンタ設定コンポの自動選択コードを修正
//    (複数のプリンタ設定コンポが配置している場合に最初のプリンタ設
//     定コンポを選択してしまう)
//
//  Ver 4.54-> 4.55変更点
//
//  ・フォームを閉じる時にイメージの画像をクリアするようにした．
//    クリアしないと，同じフォームに別の画像を表示する時に前の画像が表
//    示されてしまう．
//
//
//                            2005.01.22  Ver.4.55 　
//                            Copyright (C) Mr.XRAY
//                            http://homepage2.nifty.com/Mr_XRAY/
//====================================================================
unit plPrev;

interface

uses
  {$IFDEF VER130}
  Windows, Messages, SysUtils, Classes, Graphics, Controls,Forms,Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, Printers,Math,ToolWin,plSetPrinter,
  JPEG,Clipbrd, Buttons, Menus,DsgnIntf,Exptintf,TextUtils;
  {$ELSE}
  Windows, Messages, SysUtils, Classes, Graphics, Controls,Forms,Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, Printers,Math,ToolWin,plSetPrinter,
  JPEG,Clipbrd, Buttons, Menus,Variants,TextUtils;
  {$ENDIF}


type

  {プレビューの表示形式(頁幅,頁全体など)}
  TplPrevZoomType=(ztWholePage,ztPageWidth,ztOther);

  {先読方式か逐次表示方式か}
  {コードにBeginDocを使用するとdtContとなる}
  {ProcNameプロパティに書込むとdtStatとなる}
  TplPrevDrawType=(dtCont,dtStat,dtNone);

  {各種ボタン表示の設定}
  TplPrevBtnOption=(boPrintBtn,      //[印刷]ボタン
                boPrinterSetBtn, //[プリンタ・用紙]ボタン
                boFirstPageBtn,  //[先頭頁]ボタン
                boPriorPageBtn,  //[前頁]ボタン
                boNextPageBtn,   //[次頁]ボタン
                boLastPageBtn,   //[最終頁]ボタン
                boZoomDownBtn,   //[縮小]ボタン
                boZoomUpBtn,     //[拡大]ボタン
                boPageWholeBtn,  //[全体]ボタン
                boPageWidthBtn,  //[頁幅]ボタン
                boCloseBtn);     //[閉じる]ボタン
  {使用可能なボタン設定の集合}
  TplPrevBtnOptions = set of TplPrevBtnOption;

  {プレビューForm全体の表示形式.Form.WindowStyleにFullScreenを付加}
  TplPrevFormWindowState=(fwNormal,fwMaximized,fwMinimized,fwWorkArea,fwFullScreen);

  {逐次表示方式の時の呼出ルーチン名}
  TPrevProc=procedure of Object;

  {イベント関係}
  TplPrevPageEvent    = procedure(Sender: TObject; Page: Integer) of object;
  TplPrintButtonEvent = procedure(Sender: TObject; var CanPrint: Boolean) of object;
  TStartDrawEvent     = procedure(Sender:TObject;var YPos:Integer) of object;
  THeaderDrawEvent    = procedure(Sender:TObject;Page:Integer;YPos:Integer) of object;

  TCustomplPrev = class(TComponent)
  private
    FplSetPrinter        : TplSetPrinter;        {プリンタ設定コンポーネント}
    PaperLO              : Integer;              {用紙の印刷可能左端(ドット)}
    PaperTO              : Integer;              {用紙の印刷可能上端(ドット)}

    FDefaultResolution   : Integer;              {プリンタがない時の解像度(dpi)}
    FPrinterFlag         : Boolean;              {プリンタの有無(ない時はFalse)}
    FBtnOptions          : TplPrevBtnOptions;    {各種ボタンの表示制御}
    FMetaImage           : TMetaFile;            {１頁分のメタファイル}
    MetaImageList        : array of TMetaFile;   {各頁のメタファイルイメージ格納List}
    FCanvas              : TCanvas;              {描画用のメタファイルキャンバス}
    MetaW,MetaH          : Integer;              {描画用メタファイルの幅と長さ}
    fgDisplay            : Boolean;              {描画待ちフラグ}
    FFormDispFlag        : Boolean;              {FormNameとFFormが有効か}

    FAcrobatOut          : Boolean;              {Acrobat writerへの出力}
    FProcName            : TPrevProc;            {逐次表示の描画ルーチン}
    FCursor              : TCursor;              {描画の待ち時間に表示するカーソル種類}
    FTitle               : String;               {フォームと印刷ドキュメントのタイトル}
    SaveCursor           : TCursor;              {保存カーソル}
    KeyBoardState        : TKeyBoardState;       {キーボードの状態の取得用.Acrobat用}
    DefaultKeyState      : Byte;                 {デフォルトのキー状態の退避用.Acrobat用}
    PrtCompStream        : TFileStream;          {上記で使用するStream}
    PrtCompReader        : TReader;              {プリンタ情報の一時保存値の読出し}
    PrtCompWriter        : TWriter;              {プリンタ情報の一時保存の書込み}

    FAutoCreateForm      : Boolean;                {自動生成FormならTrue}
    FForm                : TForm;                  {プレビュー用Form}
    FFormName            : TComponentName;         {プレビュー用Form名}
    FFormParent          : TWinControl;            {プレビューFormのParent}
    FFormLeft            : Integer;                {プレビューフォームの左端}
    FFormTop             : Integer;                {プレビューフォームの上端}
    FFormWidth           : Integer;                {プレビューフォームの幅}
    FFormHeight          : Integer;                {プレビューフォームの高さ}
    FFormWindowState     : TplPrevFormWindowState; {FormのWindowStateプロパティ}
    FFormIcon            : TIcon;                  {Formのアイコン}
    FFormBorderIcons     : TBorderIcons;           {FormのBorderIcons}
    FFormBorderStyle     : TFormBorderStyle;       {FormのBorderStyle}
    FFormPosition        : TPosition;              {FormのPosition}
    FFormCanMove         : Boolean;                {Formの移動可能有無のフラグ}
    FFormCanResize       : Boolean;                {Formのサイズ変更有無のフラグ}
    FFormStatusBar       : Boolean;                {Formのステータスバー表示}
    FStatusBarText       : String;                 {StatusBarのテキスト文字列}
    FFormIconBar         : Boolean;                {Formのアイコンバー}
    FFormColor           : TColor;                 {Formの背景色}
    FDrawType            : TplPrevDrawType;        {先読みか逐次表示}
    FPaperColor          : TColor;                 {連続用紙の台紙の背景色}
    FZoomtype            : TplPrevZoomType;        {画面への表示初期形式(頁幅,頁全体など)}
    FplPaperWidth        : Integer;                {用紙の物理的な横ドット数}
    FplPaperHeight       : Integer;                {用紙の物理的な縦ドット数}
    FplPageWidth         : Integer;                {用紙の印刷幅(通称頁幅}
    FplPageHeight        : Integer;                {用紙の印刷高さ(通称頁長さ)}
    FDesignedPaperWidth  : Integer;                {設計時用紙サイズ横寸法}
    FDesignedPaperHeight : Integer;                {設計時用紙サイズ縦寸法}
    FXResolution         : Integer;                {プリンタの横方向解像度}
    FYResolution         : Integer;                {プリンタの縦方向解像度}
    FPaperWidth          : Integer;                {0.1mm単位に換算した用紙幅}
    FPageWidth           : Integer;                {0.1mm単位に換算した印刷可能幅}
    FPageHeight          : Integer;                {0.1mm単位に換算した印刷可能長さ}
    FPaperHeight         : Integer;                {0.1mm単位に換算した用紙長}

    FTopOffset           : Integer;                {用紙上端オフセット(ドット)}
    FBottomOffset        : Integer;                {用紙下端オフセット(ドット)}
    FLeftOffset          : Integer;                {用紙左端オフセット(ドット)}
    FRightOffset         : Integer;                {用紙右端オフセット(ドット)}

    FPrintOffsetX        : Integer;                {印刷時の左側オフセット調整用(0.1mm単位)}
    FPrintOffsetY        : Integer;                {印刷時の上側オフセット調整用(0.1mm単位)}

    FPrintFromPage       : Integer;                {印刷開始頁番号}
    FPrintToPage         : Integer;                {印刷終了頁番号}

    FPaperRatio          : Double;                 {用紙の縦:横の物理的な比}
    FViewPaperRatio      : Double;                 {プレビューの縦横比}
    FViewWidth           : Integer;                {プレビューの横幅(0.1mm単位)}
    FViewHeight          : Integer;                {プレビューの縦方向長さ(0,1mm単位)}
    FViewClip            : Boolean;                {印刷可能範囲外のプレビュー有無}
    FPageCount           : Integer;                {印刷の総頁数}
    FPageNumber          : Integer;                {現在の頁番号}

    FImageDrag           : Boolean;                {イメージのマウスによる移動}
    FImageVisible        : Boolean;                {イメージの表示}
    FImageShade          : Boolean;                {用紙の影の描画の有無}

    {InversePrintはVer3.4で導入}
    FInversePrint        : Boolean;  {逆方向印刷(180度回転印刷)}

    ScaleMode            : Integer;  {WindowExtEx,ViewPortExtExのmode}
    FPrinting            : Boolean;  {印刷中のフラグ}
    PrintAbort           : Boolean;  {印刷中止}

    {各種イベント(OnCloseはVer4.0で追加のOnFormCloseに変更}
    {OnResizeはOnFormResizeに変更}
    {OnFormCreateみたいのはない(TplPrev生成後のプレビューフォーム有無が不定)}
    FOnFormShow          : TNotifyEvent;        {プレビューフォームのOnShow時}
    FOnFormClose         : TCloseEvent;         {プレビューフォームが閉じる時}
    FOnClose             : TNotifyEvent;        {同上(互換性のため)}
    FOnFormCloseQuery    : TCloseQueryEvent;    {同上}
    FOnFormDestroy       : TNotifyEvent;        {プレビューフォームが破棄される時}
    FOnResize            : TplPrevPageEvent;    {イメージリサイズ直後}
    FOnPrint             : TplPrevPageEvent;    {頁をPrinter.Canvas出力後}
    FOnPrinterSetupDialog: TNotifyEvent;        {プリンタの設定ダイアログ終了時}
    FOnPrintButtonClick  : TplPrintButtonEvent; {[印刷]ボタンをクリックした時}
    FOnBeforeView        : TplPrevPageEvent;    {各頁プレビュー直前}
    FOnAfterView         : TplPrevPageEvent;    {各頁プレビュー直後}
    FOnNoPrintDraw       : TplPrevPageEvent;    {印刷しないコードを実行(Clipなし)}

    {OnHeader,OnFooter,OnReportStart,OnReportEndは派生コンポーネントで実装する}
    {処理の内容によってこのイベントの記述位置を変える必要があるため}
    FOnHeader            : THeaderDrawEvent;    {ヘッダ部}
    FOnFooter            : THeaderDrawEvent;    {フッタ部}
    FOnReportStart       : TStartDrawEvent;     {全ての描画の前}
    FOnReportEnd         : THeaderDrawEvent;    {全ての描画終了後}


    {上下左右のマージンとヘッダ・フッタマージン}
    FLeftMargin   : Integer;
    FTopMargin    : Integer;
    FRightMargin  : Integer;
    FBottomMargin : Integer;
    FHeaderMargin : Integer;
    FFooterMargin : Integer;

    {Ver4.3で追加．専用プレビューフォーム以外のサブクラス化}
    {専用のプレビューフォーム以外のFormでCloseを検出してViewWidth,ViewHeightを0にするため}
    FFormOriginalProc :TWndMethod;

    procedure FreeImageList;
    procedure CreateMetaCanvas(Flag:Boolean);
    function  GetCanvas: TCanvas;
    procedure SetplSetPrinter(const Value: TplSetPrinter);
    procedure SetCursor(const Value: TCursor);
    procedure SetPageCount(const Value: Integer);
    procedure SetProcName(const Value: TPrevProc);
    procedure SetFormIcon(const Value: TIcon);
    procedure SetViewHeight(const Value: Integer);
    procedure SetViewWidth(const Value: Integer);
    procedure DrawPaperBack(ACanvas:TCanvas;Xw,Yh:Integer);
    procedure ComponentsProc(Component: TComponent);
    function GetOidashiStr(S:WideString; var EndPos:Integer;Count:Integer=2): WideString;
    function GetBurasageStr(S:WideString; var EndPos: Integer; Count: Integer=2): WideString;
    procedure SetInversePrint(const Value: Boolean);
    procedure SetPrintMargin(const Index, Value: Integer);

    {Ver4.3で追加．専用プレビューフォーム以外のサブクラス化}
    {専用のプレビューフォーム以外のFormでCloseを検出してViewWidth,ViewHeightを0にするため}
    procedure FFormSubClassProc(var Message:TMessage);
    procedure SetImageVisible(const Value: Boolean);

  protected
    PrtCompName : String; {プリンタ設定コンポの待避用FileStream名}
    procedure Notification(AComponent: TComponent;
                           Operation: TOperation); Override;
    procedure Loaded; override;
    procedure BeginDoc; virtual;
    procedure NewPage; virtual;
    procedure EndDoc; virtual;
    procedure ShowModal; virtual;
    procedure Show; virtual;
    procedure Print; virtual;
    function Execute: Boolean ; virtual;
    procedure PrintDialog; virtual;
    function SetOrCreatePrevForm: Boolean;

    procedure ScaleInitialize(ACanvas: TCanvas; Flag:Boolean);
    procedure SavePrinterSetting;
    procedure ReadPrinterSetting;
    procedure SetPaperInfo;
    function SetDefaultPrinter: Boolean;

    property plSetPrinter      : TplSetPrinter     read FplSetPrinter      write SetplSetPrinter;
    property DefaultResolution : Integer           read FDefaultResolution write FDefaultResolution;
    property PrinterFlag       : Boolean           read FPrinterFlag       write FPrinterFlag;
    property BtnOptions        : TplPrevBtnOptions read FBtnOptions        write FBtnOptions;
    property FormDispFlag      : Boolean           read FFormDispFlag      write FFormDispFlag;
    property Canvas            : TCanvas           read GetCanvas;
    property AcrobatOut        : Boolean           read FAcrobatOut;
    property DrawType          : TplPRevDrawType   read FDrawType;
    property MetaImage         : TMetaFile         read FMetaImage         write FMetaImage;
    property ProcName          : TPrevProc         read FProcName          write SetProcName;
    property Form              : TForm             read FForm              write FForm;
    property FormParent        : TWinControl       read FFormParent        write FFormParent;
    property XResolution       : Integer           read FXResolution       write FXResolution;
    property YResolution       : Integer           read FYResolution       write FYResolution;
    property ViewPaperRatio    : Double            read FViewPaperRatio    write FViewPaperRatio;
    property PrintFromPage     : Integer           read FPrintFromPage     write FPrintFromPage;
    property PrintToPage       : Integer           read FPrintToPage       write FPrintToPage;
    property PaperWidth        : Integer           read FPaperWidth;
    property PaperHeight       : Integer           read FPaperHeight;
    property PageWidth         : Integer           read FPageWidth;
    property PageHeight        : Integer           read FPageHeight;
    property ViewWidth         : Integer           read FViewWidth         write SetViewWidth;
    property ViewHeight        : Integer           read FViewHeight        write SetViewHeight;
    property TopOffset         : Integer           read FTopOffset;
    property BottomOffset      : Integer           read FBottomOffset;
    property RightOffset       : Integer           read FRightOffset;
    property LeftOffset        : Integer           read FLeftOffset;
    property PaperRatio        : Double            read FPaperRatio;
    property Printing          : Boolean           read FPrinting;

    property TopMargin         : Integer Index 1 read FTopMargin        write SetPrintMargin;
    property BottomMargin      : Integer Index 2 read FBottomMargin     write SetPrintMargin;
    property LeftMargin        : Integer Index 3 read FLeftMargin       write SetPrintMargin;
    property RightMargin       : Integer Index 4 read FRightMargin      write SetPrintMargin;
    property HeaderMargin      : Integer Index 5 read FHeaderMargin     write SetPrintMargin;
    property FooterMargin      : Integer Index 6 read FFooterMargin     write SetPrintMargin;

    property Title           : String           read FTitle           write FTitle;
    property Cursor          : TCursor          read FCursor          write SetCursor;

    property AutoCreateForm  : Boolean                read FAutoCreateForm  write FAutoCreateForm;
    property FormName        : TComponentName         read FFormName        write FFormName;
    property FormLeft        : Integer                read FFormLeft        write FFormLeft;
    property FormTop         : Integer                read FFormTop         write FFormTop;
    property FormWidth       : Integer                read FFormWidth       write FFormWidth;
    property FormHeight      : Integer                read FFormHeight      write FFormHeight;
    property FormIcon        : TIcon                  read FFormIcon        write SetFormIcon;
    property FormBorderIcons : TBorderIcons           read FFormBorderIcons write FFormBorderIcons;
    property FormBorderStyle : TFormBorderStyle       read FFormBorderStyle write FFormBorderStyle;
    property FormPosition    : TPosition              read FFormPosition    write FFormPosition;
    property FormCanMove     : Boolean                read FFormCanMove     write FFormCanMove;
    property FormCanResize   : Boolean                read FFormCanResize   write FFormCanResize;
    property FormWindowState : TplPrevFormWindowState read FFormWindowState write FFormWindowState;
    property FormStatusBar   : Boolean          read FFormStatusBar   write FFormStatusBar;
    property StatusBarText   : String           read FStatusBarText   write FStatusBarText;
    property FormIconBar     : Boolean          read FFormIconBar     write FFormIconBar;
    property PaperColor      : TColor           read FPaperColor      write FPaperColor;
    property ViewClip        : Boolean          read FViewClip        write FViewClip;
    property PrintOffsetX    : Integer          read FPrintOffsetX    write FPrintOffsetX;
    property PrintOffsetY    : Integer          read FPrintOffsetY    write FPrintOffsetY;
    property PageCount       : Integer          read FPageCount       write SetPageCount;
    property PageNumber      : Integer          read FPageNumber      write FPageNumber;
    property ZoomType        : TplPrevZoomType  read FZoomType        write FZoomType;
    property InversePrint    : Boolean          read FInversePrint    write SetInversePrint;

    property OnFormShow          : TNotifyEvent        read FOnFormShow           write FOnFormShow;
    property OnPrinterSetupDialog: TNotifyEvent        read FOnPrinterSetupDialog write FOnPrinterSetupDialog;
    property OnFormClose         : TCloseEvent         read FOnFormClose          write FOnFormClose;
    property OnClose             : TNotifyEvent        read FOnClose              write FOnClose;
    property OnFormCloseQuery    : TCloseQueryEvent    read FOnFormCloseQuery     write FOnFormCloseQuery;
    property OnFormDestroy       : TNotifyEvent        read FOnFormDestroy        write FOnFormDestroy;
    property OnBeforeView        : TplPrevPageEvent    read FOnBeforeView         write FOnBeforeView;
    property OnAfterView         : TplPrevPageEvent    read FOnAfterView          write FOnAfterView;
    property OnResize            : TplPrevPageEvent    read FOnResize             write FOnResize;
    property OnPrint             : TplPrevPageEvent    read FOnPrint              write FOnPrint;
    property OnPrintButtonClick  : TplPrintButtonEvent read FOnPrintButtonClick   write FOnPrintButtonClick;
    property OnFooter            : THeaderDrawEvent    read FOnFooter             write FOnFooter;
    property OnHeader            : THeaderDrawEvent    read FOnHeader             write FOnHeader;
    property OnReportEnd         : THeaderDrawEvent    read FOnReportEnd          write FOnReportEnd;
    property OnReportStart       : TStartDrawEvent     read FOnReportStart        write FOnReportStart;
    property OnNoPrintDraw       : TplPrevPageEvent    read FOnNoPrintDraw        write FOnNoPrintDraw;
  public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;

    function  Display(Page: Integer): Boolean; virtual;
    function  GetMetaImage(Page: Integer): TMetaFile; virtual;
    procedure Close; virtual;

    {設計時用紙サイズの指定}
    procedure DesignedPaperSize(W,H:Integer);

    function Roundoff  (X: Double): Integer;
    {文字列変換関数}
    function ToZenkaku (S: String): String;
    function ToHankaku (S: String): String;
    function AlpToHank (S: String): string;

    procedure FontSize   (S:Double);
    procedure FontHeight (V: Integer);
    procedure FontName   (V: TFontName);
    procedure FontColor  (V: TColor);
    procedure FontStyle  (V: TFontStyles);
    procedure FontAssign (V:TFont);

    procedure PenColor   (V:TColor);
    procedure LineColor  (V:TColor);
    procedure LineStyle  (V:TPenStyle);
    procedure PenStyle   (V:TPenStyle);
    procedure LineWidth  (V:Integer);
    procedure PenWidth   (V:Integer);
    procedure BrushColor (V:TColor);
    procedure BrushStyle (V:TBrushStyle);
    procedure Circle     (X,Y,D: Integer);
    procedure Ellipse    (X,Y,DX,DY: Integer);

    procedure MoveTo    (X:Integer;Y:Integer);
    procedure LineTo    (X:Integer;Y:Integer);
    procedure Line      (X1,X2,Y1,Y2:Integer);
    procedure Rectangle (X1,X2,Y1,Y2:Integer);
    procedure FillRect  (X1,X2,Y1,Y2:Integer);
    procedure RectLine  (X1,X2,Y1,Y2:Integer);
    procedure FrameRect  (X1,X2,Y1,Y2:Integer);

    procedure TextOut      (X1,Y1:Integer;Text:String);
    procedure TextOutLT    (X1,Y1:Integer;Text:String);
    procedure TextOutCT    (X1,Y1:Integer;Text:String);
    procedure TextOutRT    (X1,Y1:Integer;Text:String);
    procedure TextOutLC    (X1,Y1:Integer;Text:String);
    procedure TextOutCC    (X1,Y1:Integer;Text:String);
    procedure TextOutRC    (X1,Y1:Integer;Text:String);
    procedure TextOutLB    (X1,Y1:Integer;Text:String);
    procedure TextOutCB    (X1,Y1:Integer;Text:String);
    procedure TextOutRB    (X1,Y1:Integer;Text:String);

    procedure TextRectLT   (X1,X2,Y1,Y2:Integer;Text:String);
    procedure TextRectCT   (X1,X2,Y1,Y2:Integer;Text:String);
    procedure TextRectRT   (X1,X2,Y1,Y2:Integer;Text:String);
    procedure TextRectLC   (X1,X2,Y1,Y2:Integer;Text:String);
    procedure TextRectLCEx (X1,X2,Y1,Y2:Integer;Text:String);
    procedure TextRectCC   (X1,X2,Y1,Y2:Integer;Text:String);
    procedure TextRectCCEx (X1,X2,Y1,Y2:Integer;Text:String);
    procedure TextRectRC   (X1,X2,Y1,Y2:Integer;Text:String);
    procedure TextRectLB   (X1,X2,Y1,Y2:Integer;Text:String);
    procedure TextRectCB   (X1,X2,Y1,Y2:Integer;Text:String);
    procedure TextRectRB   (X1,X2,Y1,Y2:Integer;Text:String);
    procedure ZipOut       (Zip: String;OffsetX,OffsetY:Integer;PrtOut: Boolean;DispOffsetY:Integer=0);
    procedure ZipOutEx     (Zip: String;OffsetX,OffsetY:Integer; PrtOut: Boolean;DispOffsetY:Integer=0);

    function  TextOutFile         (Yt,Xl,Xr,RowH: Integer; FileName: String):Integer;
    procedure TextRectJust        (X1,X2,Y1,Y2:Integer;Text:String);
    procedure TextRectJustTate    (X1,X2,Y1,Y2:Integer;Text:String);
    procedure TextSpecial         (X,Y,R:Integer;V:Integer;Text:String);
    procedure TextRectFit         (X1,X2,Y1,Y2,Cnt:Integer;Text:String);
    procedure DrawPict            (X1,Y1:Integer;FileName:string);
    procedure StretchDrawPict     (X1,X2,Y1,Y2:Integer;IsFit:Boolean;FileName:string);
    procedure StretchDrawBitmap   (ARect:TRect; Pict:TBitmap);
    procedure StretchDrawMetaFile (ARect:TRect; Pict:TMetaFile);
    function StringListOut (var SL: TStringList; Options: TFormatOptions;
              Xl,Xr,Yt,Yb,RowH: Integer; KinsokuCnt:Integer=2): Integer;
    property ImageVisible : Boolean read FImageVisible write SetImageVisible default True;
  published
    property ImageDrag    : Boolean      read FImageDrag    write FImageDrag  default True;
    property ImageShade   : Boolean      read FImageShade   write FImageShade default True;
    property FormColor    : TColor       read FFormColor    write FFormColor  default clBtnFace;
  end;

  TplPrev = class(TCustomplPrev)
  private
  protected
  public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;

    procedure BeginDoc; override;
    procedure NewPage;  override;
    procedure EndDoc; override;
    procedure Show; override;
    procedure ShowModal; override;
    procedure Print; override;

    property Canvas;
    property AcrobatOut;
    property ProcName;
    property Form;
    property FormParent;
    property ViewPaperRatio;
    property PaperRatio;

    property PrintFromPage;
    property PrintToPage;

    property PageNumber;

    property PaperWidth;
    property PaperHeight;
    property PageWidth;
    property PageHeight;
    property ViewWidth;
    property ViewHeight;
    property TopOffset;
    property BottomOffset;
    property RightOffset;
    property LeftOffset;
    property Printing;
    property OnClose;
  published
    property LeftMargin;
    property TopMargin;
    property RightMargin;
    property BottomMargin;
    property HeaderMargin;
    property FooterMargin;

    property PageCount;

    property plSetPrinter;
    property BtnOptions;
    property Title;
    property Cursor;
    property FormLeft;
    property FormTop;
    property FormWidth;
    property FormHeight;
    property FormName;
    property FormIcon;
    property FormIconBar;
    property FormBorderIcons;
    property FormBorderStyle;
    property FormPosition;
    property FormCanMove;
    property FormCanResize;
    property FormWindowState;
    property FormStatusBar;
    property StatusBarText;
    property PaperColor;
    property ViewClip;
    property PrintOffsetX;
    property PrintOffsetY;
    property ZoomType;
    property InversePrint;
    
    property OnFormShow;
    property OnFormClose;
    property OnFormCloseQuery;
    property OnFormDestroy;
    property OnBeforeView;
    property OnAfterView;
    property OnResize;
    property OnPrint;
    property OnNoPrintDraw;
    property OnPrinterSetupDialog;
    property OnPrintButtonClick;
  end;

implementation

uses plPrevfrm,MetafileUtils;

const
S0='印刷プレビュー制御コンポーネント';
S3='表示中のフォームをモーダル表示で開くことはできません(矛盾)．　　';
S6='Canvasへの描画コードが見つかりません．　　';
S7='プリンタがインストールされていないので印刷できません．　　';

const
     {行頭禁則処理(行頭にあったら前の行にぶら下げる)}
     BurasageStr:array[1..14] of WideString=(
             ')',']','}','.',',','｣',                        {半角6}
             '）' ,'］' ,'｝' ,'．' ,'，' ,'」' ,'。' ,'、');{全角8}
     {行末禁則処理(行末にあったら次の行に追出す)}
     OidashiStr:array[1..8] of WideString=(
             '(','[','{','｢',       {半角4}
             '（','［','｛','「');  {全角4}

  { TCustomplPrev }

//====================================================================
//   コンポーネントの初期化
//====================================================================
constructor TCustomplPrev.Create(AOwner: TComponent);
begin
     inherited;
     FDefaultResolution   := 300;
     FPrinterFlag         := False;
     FAcrobatOut          := False;
     FDrawType            := dtNone;
     FTitle               := '印刷プレビュー[Mr.XRAY]';
     FViewClip            := True;
     FZoomType            := ztWholePage;
     FPaperColor          := clWhite;
     FPageCount           := 1;
     FPageNumber          := 1;
     FPrintFromPage       := 0;
     FPrintToPage         := 0;
     FPaperWidth          := 2100;
     FPaperHeight         := 2970;
     FPageWidth           := FPaperWidth;
     FPageHeight          := FPaperHeight;
     FLeftOffset          := 0;
     FRightOffset         := FPaperWidth;
     FTopOffset           := 0;
     FBottomOffset        := FPaperHeight;
     FViewWidth           := 0;
     FViewHeight          := 0;
     fgDisplay            := True;
     FFormDispFlag        := False;
     FAutoCreateForm      := False;
     FForm                := nil;
     FFormName            := '';
     FFormParent          := nil;
     FFormPosition        := poDefault;
     FFormLeft            := 20;
     FFormTop             := 20;
     FFormWidth           := Screen.Width*2 div 3;
     FFormHeight          := Screen.Height*2 div 3;
     FFormIcon            := TIcon.Create;
     FFormBorderIcons     := [biSystemMenu, biMinimize, biMaximize];
     FFormBorderStyle     := bsSizeable;
     FFormCanMove         := True;
     FFormCanResize       := True;
     FFormIconBar         := True;
     FFormStatusBar       := True;
     FFormColor           := clBtnFace;
     FStatusBarText       := '';
     FInversePrint        := False;
     PrintAbort           := False;
     FCursor              := crHourGlass;

     FImageDrag           := True;
     FImageVisible        := True;
     FImageShade          := True;
     
     SaveCursor           := Screen.cursor;
     FDesignedPaperWidth  := 0;
     FDesignedPaperHeight := 0;
     FBtnOptions          := [boPrintBtn,boFirstPageBtn,boPriorPageBtn,boNextPageBtn,
                              boNextPageBtn,boLastPageBtn,boZoomDownBtn,boZoomUpBtn,
                              boPageWholeBtn,boPageWidthBtn,boCloseBtn];
     SetPaperInfo;
end;
//====================================================================
//   Loaded処理．特になし．でも後の追加のために書いておくことにする
//====================================================================
procedure TCustomplPrev.Loaded;
begin
     inherited Loaded;
end;
//====================================================================
//   コンポーネント終了処理
//====================================================================
destructor TCustomplPrev.Destroy;
begin
     {Form用アイコンの解放}
     if FFormIcon<>nil then begin
       FFormIcon.Free;
       FFormIcon:=nil;
     end;
     {メタファイルリストの解放}
     FreeImageList;
     {プリンタ設定コンポーネント設定ファイル削除}
     try
       DeleteFile(PrtCompName);
     except
     end;
     inherited;
end;
//====================================================================
//   プリンタ設定コンポーネントが削除された時配置された場合の処理
//====================================================================
procedure TCustomplPrev.Notification(AComponent: TComponent; Operation: TOperation);
begin
     inherited Notification(AComponent,Operation);
     if (AComponent Is TplSetPrinter) then begin
       if (Operation=opRemove) then begin
         FplSetPrinter:=nil;
       end else if (Operation=opInsert) then begin
         if csDesigning in ComponentState then begin
           FplSetPrinter:=AComponent as TplSetPrinter;
         end;
       end;
     end;
end;
//====================================================================
//   待ち時間に表示するカーソル
//====================================================================
procedure TCustomplPrev.SetCursor(const Value: TCursor);
begin
     if Value<>null then begin
       FCursor := Value;
     end;
end;
//====================================================================
//   プレビューFormのアイコン
//====================================================================
procedure TCustomplPrev.SetFormIcon(const Value: TIcon);
begin
     if Value<>nil then FFormIcon.Assign(Value);
     if Value=nil then FFormIcon:=nil;
end;
//====================================================================
//   総頁数の設定
//   逐次表示方式で使用.先読方式では描画ルーチンの最後で決まる
//====================================================================
procedure TCustomplPrev.SetPageCount(const Value: Integer);
begin
     if Value<=0 then exit;
     FPageCount  := Value;
end;
//====================================================================
//   表示高さを変更したら表示の縦横比も再計算
//====================================================================
procedure TCustomplPrev.SetViewHeight(const Value: Integer);
begin
     if Value>=0 then begin
       FViewHeight := Value;
       if FViewWidth>0 then FViewPaperRatio:=FViewHeight/FViewWidth;
     end;
end;
//====================================================================
//   表示幅を変更したら表示の縦横比も再計算
//====================================================================
procedure TCustomplPrev.SetViewWidth(const Value: Integer);
begin
     if Value>=0 then begin
       FViewWidth := Value;
       if FViewWidth>0 then FViewPaperRatio:=FViewHeight/FViewWidth;
     end;
end;
//====================================================================
//   描画用Canvasを外部から利用するためのメソッド
//====================================================================
function TCustomplPrev.GetCanvas: TCanvas;
begin
     Result:=FCanvas;
end;
//====================================================================
//   印刷に使用するプリンタの設定
//====================================================================
procedure TCustomplPrev.SetplSetPrinter(const Value: TplSetPrinter);
begin
     if Value<>nil then begin
       if Value.PrinterName='' then begin
         FplSetPrinter:=nil;
       end else begin
         FplSetPrinter:=Value;
         if AnsiPos('ACROBAT',AnsiUpperCase(Value.PrinterName))<>0 then begin
           FAcrobatOut:=True;
         end else begin
           FAcrobatOut:=False;
         end;
         FplSetPrinter.CallSetting;
         Value.FreeNotification(Self);
       end;
     end;
     {FView...は共に0でMetaFile作成時に決定する}
     {0がFView...が設定済みかどうかのフラグとなっている}
     FViewWidth :=0;
     FViewHeight:=0;
     SetPaperInfo;
end;
//====================================================================
//  用紙の上下左右の余白(マージン)設定
//
//  各Offset以下の値の時はOffsetと同じ値に強制修正(設計時のみ)
//  各々の処理の前に if Value<>FXXXXX then を挿入して置かないとDelphi
//  ごと落ちてしまう(Createで初期化していないためなのか?)
//
//  Index 1 TopMargin
//  Index 2 BottomMargin
//  Index 3 RightMargin
//  Index 4 LeftMargin
//  Index 5 HeaderMargin
//  Index 6 FooterMargin
//
//  この上の余白値が用紙の印刷可能上限と同じで，枠の横罫線の太さが太
//  い場合，半分の太さにしか印刷されないことがある．そのような場合は，
//  上の余白を，少なくとも罫線の太さの半分だけ大きくする．
//====================================================================
procedure TCustomplPrev.SetPrintMargin(const Index, Value: Integer);
begin
     case Index of
     1: {TopMargin}
     begin
       if Value<>FTopMargin then begin
         FTopMargin:=Value;
         if (csDesigning in ComponentState) then begin
           if Value<FTopOffset         then FTopMargin:=FTopOffset;
           if FHeaderMargin>FTopMargin then FHeaderMargin:=FTopMargin;
         end;
       end;
     end;
     2: {BottomMargin}
     begin
       if Value<>FBottomMargin then begin
         FBottomMargin:=Value;
         if (csDesigning in ComponentState) then begin
           if Value<(FPaperHeight-FBottomOffset) then FBottomMargin:=FPaperHeight-FBottomOffset;
           if FFooterMargin>FBottomMargin        then FFooterMargin:=FBottomMargin;
         end;
       end;
     end;
     3: {LeftMargin}
     begin
       if Value<>FLeftMargin then begin
         FLeftMargin:=Value;
         if (csDesigning in ComponentState) then begin
           if Value<FLeftOffset then FLeftMargin:=FLeftOffset;
         end;
       end;
     end;
     4: {RightMargin}
     begin
       if Value<>FRightMargin then begin
         FRightMargin:=Value;
         if (csDesigning in ComponentState) then begin
           if Value<(FPaperWidth-FRightOffset) then FRightMargin:=FPaperWidth-FRightOffset;
         end;
       end;
     end;
     5: {HeaderMargin}
     begin
       if Value<>FHeaderMargin then begin
         FHeaderMargin:=Value;
         if (csDesigning in ComponentState) then begin
           if Value>FTopMargin then FHeaderMargin:=FTopMargin;
         end;
       end;
     end;
     6: {FooterMargin}
     begin
       if Value<>FFooterMargin then begin
         FFooterMargin:=Value;
         if (csDesigning in ComponentState) then begin
           if Value>FBottomMargin then FFooterMargin:=FBottomMargin;
         end;
       end;
     end;
     end;
end;
//====================================================================
//   逆方向印刷プロパティの設定
//====================================================================
procedure TCustomplPrev.SetInversePrint(const Value: Boolean);
begin
     if Value<>FInversePrint then begin
       FInversePrint:=Value;
       SetPaperInfo;
     end;
end;
//====================================================================
//   ルーチン名の指定(逐次表示方式)
//   逐次表示方式の場合に使用するプロシージャ名
//====================================================================
procedure TCustomplPrev.SetProcName(const Value: TPrevProc);
begin
     FProcName:=Value;
     if not Assigned(ProcName) then exit;

     SetDefaultPrinter;
     SetPaperInfo;

     FreeImageList;                 {連続使用のためにFreeが必要}
     FDrawType      :=dtStat;       {逐次表示方式である}
     CreateMetaCanvas(True);        {メタキャンバスの作成}
     ScaleInitialize(FCanvas,True); {キャンバスのスケーリング}
end;
//====================================================================
//   初期化(先読み方式)
//====================================================================
procedure TCustomplPrev.BeginDoc;
begin
     Screen.Cursor:=FCursor;
     SetDefaultPrinter;
     SetPaperInfo;
     {先読み方式はプリンタの設定ボタン非表示}
     {ただし，表示の時に設定すれば表示}
     FBtnOptions:=FBtnOptions-[boPrinterSetBtn];

     FreeImageList;                 {連続使用のためにFreeが必要}
     FDrawType     :=dtCont;        {先読み方式である}
     FPageNumber   :=1;             {頁の初期値は1}
     FPageCount    :=1;             {総頁数の初期値も1}
     CreateMetaCanvas(True);        {メタキャンバスの作成}

     ScaleInitialize(FCanvas,False);{キャンバスのスケーリング}
end;
//====================================================================
//   頁送り作業(先読み方式)   　　　　　　
//   頁番号をインクリメントして作成したメタファイルを保存する
//
//   Ver4.5での変更点
//   メタファイルの作成と保存をTListで行っていたが，TMetaFileの配列
//   を使用する方法に変更．またTListのItemでメタファイルを作成してい
//   たのを，コンポ内共通のFMetaImageのCanvasに描画したものを改頁の
//   度に配列に保存するようにした．配列のTMetaFileに代入する際，
//   Windows9Xのバグを回避するために，DHGLのFixMetafile9Xを使用した．
//====================================================================
procedure TCustomplPrev.NewPage;
var
     TempCanvas : TCanvas;
begin
     {Canvasのプロパティを次頁に引継ぐように退避}
     TempCanvas:=TCanvas.Create;
     TempCanvas.Font      :=FCanvas.Font;
     TempCanvas.Pen       :=FCanvas.Pen;
     TempCanvas.Brush     :=FCanvas.Brush;
     TempCanvas.CopyMode  :=FCanvas.CopyMode;
     TempCanvas.TextFlags :=FCanvas.TextFlags;
     {描画終了}
     FCanvas.Free;

     {頁を増加}
     SetLength(MetaImageList,FPageNumber);
     {現頁のメタファイルをWindows9X互換のメタファイルに変換して保存}
     if FPrinterFlag then begin
       MetaImageList[FPageNumber-1]:=FixMetafileFor9X(FMetaImage,Printer.Handle);
     end else begin
       MetaImageList[FPageNumber-1]:=FixMetafileFor9X(FMetaImage,0);
     end;
     FPageNumber:=FPageNumber+1;     {頁番号をインクリメント}
     CreateMetaCanvas(False);        {メタキャンバス作成}

     {前頁のCanvasのプロパティを設定}
     try
       FCanvas.Font      :=TempCanvas.Font;
       fCanvas.Pen       :=TempCanvas.Pen;
       FCanvas.Brush     :=TempCanvas.Brush;
       FCanvas.CopyMode  :=TempCanvas.CopyMode;
       FCanvas.TextFlags :=TempCanvas.TextFlags;
     finally
       TempCanvas.Free;
     end;

     ScaleInitialize(FCanvas,False); {スケーリング}
end;
//====================================================================
//   メタファイル作成終了作業(先読み方式)
//   最後なので現在の頁番号が総頁数
//====================================================================
procedure TCustomplPrev.EndDoc;
begin
     FCanvas.Free;  {最終頁作成終了}
     FCanvas:=nil;

     {頁を増加}
     SetLength(MetaImageList,FPageNumber);
     {現頁のメタファイルをWindows9X互換のメタファイルに変換して保存}
     if FPrinterFlag then begin
       MetaImageList[FPageNumber-1]:=FixMetafileFor9X(FMetaImage,Printer.Handle);
     end else begin
       MetaImageList[FPageNumber-1]:=FixMetafileFor9X(FMetaImage,0);
     end;
     try
       FPageCount  :=FPageNumber;  {最終頁が総頁数}
       FPageNumber :=1;            {プレビュー開始頁}
     finally
       Screen.Cursor :=SaveCursor;
     end;
end;
//====================================================================
//   派生コンポーネントで使用するメソッド
//   派生元であるTCustomplPrevでは何もしない
//====================================================================
function TCustomplPrev.Execute: Boolean;
begin
//
end;
//====================================================================
//  プリンタ設定コンポの設定
//
//  plSetPrinterが設定していない場合は，次の順でplSetPrinterプロパテ
//  ィの設定を試みる．いずれも失敗した場合はplSetPrinterプロパティの
//  値はnilとなり，この関数はFalseを返す．
//  (1) このコンポーネントのオーナのコンポーネントのリスかから探し出
//      して最初に見つかったプリンタ設定コンポーネントを使用する．
//      Trueを返す．
//  (2) このコード内で生成して，現在のプリンタとその設定値を使用する．
//      現在のプリンタ名に'Acrobat'が含まれていればActrobatOutをTure
//      にする．
//
//  既にplSetPrinterプロパティが設定されているとFalseを返す．
//====================================================================
function TCustomplPrev.SetDefaultPrinter: Boolean;
var
     i: Integer;
     ACompo: TComponent;
begin
     Result:=False;
     if FplSetPrinter=nil then begin
       if Printer.Printers.Count>0 then begin
         for i:=0 to Owner.ComponentCount-1 do begin
           ACompo:=Owner.Components[i];
           if ACompo.ClassName='TplSetPrinter' then begin
             FplSetPrinter:=(ACompo as TplSetPrinter);
             {新規に設定なので意味なし?}
             {プリンタ設定コンポーネントの現在の設定を読出す}
             FplSetPrinter.CallSetting;
             break;
           end;
         end;
         {プリンタ設定コンポーネントがない場合は生成}
         try
           if FplSetPrinter=nil then begin
             FplSetPrinter:=TplSetPrinter.Create(Owner);
             {現在のプリンタの設定値を取得する}
             FplSetPrinter.GetPrinterInfo(False);
           end;
           Result:=True;
           if AnsiPos('ACROBAT',AnsiUpperCase(FplSetPrinter.PrinterName))<>0 then begin
             FAcrobatOut:=True;
           end else begin
             FAcrobatOut:=False;
           end;
         except
         end;
       end;
     end else begin
       {Ver4.3で追加}
       {Ver4.53でGetPrinterInfo(False)からCallSettingに修正}
       FplSetPrinter.CallSetting;
     end;
end;
//====================================================================
//　プレビューの開始準備　モーダル表示
//====================================================================
procedure TCustomplPrev.ShowModal;
begin
     if FAcrobatOut then begin
       Print;
       exit;
     end;

     FFormDispFlag:=SetOrCreatePrevForm;
     {FormNameプロパティとFormの有効性の確認}
     if FFormName<>'' then begin
       {有効なFormがScreen変数にあれば表示実行}
       if FFormDispFlag then begin
         if (FForm as TplPrevForm).Visible then begin
           {表示中のFormをShowModalでは表示不可(矛盾)}
           Application.MessageBox(PChar(S3),PChar(S0),MB_ICONWARNING);
         end else begin
           Execute;
           (FForm as TplPrevForm).ShowModal;
           {自動生成のFormの場合，OnCloseでActionにcaFreeを指定しているが}
           {このcaFreeはShowメソッド表示時のみ有効なのでShowModalはここでRelease}
           if FAutoCreateForm then (FForm as TplPrevForm).Release;
         end;
       end else begin
         {TplPrevFormではない時は単にそのFormを表示するだけ}
         try
           Execute;
           {FromのCloseはサブクラスで対応}
           FFormOriginalProc := FForm.WindowProc;
           FForm.WindowProc  := FFormSubClassProc;
           FForm.ShowModal;
         except
         end;
       end;
     end;
end;
//====================================================================
//　 プレビューの開始準備　モードレス表示
//====================================================================
procedure TCustomplPrev.Show;
begin
     if FAcrobatOut then begin
       Print;
       exit;
     end;

     FFormDispFlag:=SetOrCreatePrevForm;
     {FormNameプロパティとFormの有効性の確認}
     if FFormName<>'' then begin
       {有効なFormがScreen変数にあれば表示実行}
       if FFormDispFlag then begin
         Execute;
         (FForm as TplPrevForm).Show;
       end else begin
         {TplPrevFormではない時は単にそのFormを表示するだけ}
         try
           Execute;
           {FromのCloseはサブクラスで対応}
           FFormOriginalProc := FForm.WindowProc;
           FForm.WindowProc  := FFormSubClassProc;
           FForm.Show;
         except
         end;
       end;
     end;
end;
//====================================================================
//  FImageVisibleプロパティの設定メソッド
//  プレビューイメージ表示の有無
//  起動時にイメージを表示したくない場合などに使用する
//====================================================================
procedure TCustomplPrev.SetImageVisible(const Value: Boolean);
begin
     if Value<>FImageVisible then begin
       FImageVisible := Value;
       if FImageVisible then begin
         (FForm as TplPrevForm).Image1.Visible:=True;
         (FForm as TplPrevForm).Shape1.Visible:=True;
         if FImageShade then (FForm as TplPrevForm).Shape2.Visible:=True;
         Display(FPageNumber);
       end else begin
         if FForm<>nil then begin
           (FForm as TplPrevForm).Image1.Visible:=False;
           (FForm as TplPrevForm).Shape1.Visible:=False;
           (FForm as TplPrevForm).Shape2.Visible:=False;
         end;
       end;
     end;
end;
//====================================================================
//  プレビューフォームのチェック
//
//  FormNameが設定していない場合は，
//  プロジェクトで印刷プレビュー用の継承フォームを作成していれば，そ
//  れを検出して使用する．
//  なければ，TplPrevFormから自動的に継承フォームを新規作成する．
//  この新規継承Formの名前はplXRAYPrevForm__+自身の名前とする．
//  このFormはTplPrevFormのOnFormCloseのActionプロパティで破棄を指定
//  して解放している．
//====================================================================
function TCustomplPrev.SetOrCreatePrevForm: Boolean;
var
     i: Integer;
     ACompo : TComponent;
begin
     Result:=False;
     if FFormName='' then begin
       for i:=0 to Application.ComponentCount-1 do begin
         ACompo:=Application.Components[i];
         {派生したフォームの名前を変更している場合があるので}
         {継承元のクラス名で検査する}
         if ACompo.ClassParent.ClassNameIs('TplPrevForm') then begin
           FForm:=(ACompo as TplPrevForm);
           FFormName:=ACompo.Name;
           (FForm as TplPrevForm).plPrev:=Self;
           Result:=True;
         end;
       end;
       if Result=False then begin
         FAutoCreateForm:=True;
         FForm     :=TplPrevForm.Create(Owner);
         FFormName :=FForm.Name+'__'+Self.Name;
         (FForm as TplPrevForm).plPrev:=Self;
         Result:=True;
       end;
     end else begin
       {FormNameが設定済みならScreenのFormから探しだしplPrevをセット}
       {これでプレビューフォームからTplprevが使用可能となる}
       for i:=0 to Screen.FormCount-1 do begin
         if FFormName=Screen.Forms[i].Name then begin
           FForm:=Screen.Forms[i];
           if (FForm is TplPrevForm) then begin
             (FForm as TplPrevForm).plPrev:=Self;
             Result:=True;
             break;
           end;
         end;
       end;
     end;
end;
//====================================================================
//   Ver4.3で追加
//   専用(附属)のプレビューフォーム以外のFormのサブクラス関数
//   Formを閉じたらViewWidth,ViewHeightを0にする
//====================================================================
procedure TCustomplPrev.FFormSubClassProc(var Message: TMessage);
begin
     FFormOriginalProc(Message);
     case Message.Msg of
     WM_CLOSE:
       begin
         FViewWidth :=0;
         FViewHeight:=0;
       end;
     end;
end;
//====================================================================
//   メタファイルリストの解放
//====================================================================
procedure TCustomplPrev.FreeImageList;
var
     i: Integer;
begin
     if FDrawType=dtCont then begin
       {メタファイルリストの解放}
       for i:=0 to Length(MetaImageList)-1 do begin
         MetaImageList[i].Free;
       end;
       SetLength(MetaImageList,0);
     end;
     FMetaImage.Free;
     FMetaImage:=nil;
end;
//====================================================================
//   プレビューFormを閉じるメソッド
//====================================================================
procedure TCustomplPrev.Close;
begin
     if FAcrobatOut then exit;
     if FForm=nil  then exit;
     (FForm as TplPrevForm).CloseBtnClick(FForm);
end;
//====================================================================
//   指定頁を表示
//   fgDisplay 表示を待つためのフラグ
//====================================================================
function TCustomplPrev.Display(Page: Integer): Boolean;
begin
     Result:=False;

     {Formプロパティ未設定の時は表示しない}
     {Formが非表示の場合もNo}
     {前の表示が終わっていない場合もNo}
     if FForm=nil then exit;
     if not((FForm as TplPrevForm).Visible) then exit;
     if fgDisplay=False then exit;

     if (Page>0) and (Page<=FPageCount) then begin
       fgDisplay:=False;
       FPageNumber:=Page;
       try
         {plPrev.pas内でDrawMetaImageを使用しているのはここだけ}
         (FForm as TplPrevForm).DrawMetaImage;
       finally
         Result:=True;
         fgDisplay:=True;
       end;
     end;
end;
//====================================================================
//   印刷ダイアログを表示して印刷
//   ダイアログを表示しないで印刷するメソッドはPrint
//   このメソッドはプレビューフォームの[印刷]ボタンを使用しない状況を
//   想定している．
//   プレビューしないで直接印刷する場合は，TPrintDialogを使用してプリ
//   ンタを設定してPrintメソッドを呼出す方法を使用する．
//====================================================================
procedure TCustomplPrev.PrintDialog;
begin
     if FForm=nil then exit;
     (FForm as TplPrevForm).PrintBtnClick(Self);
end;
//====================================================================
//   外部プリンタへの出力
//   印刷設定のダイアログは表示しない．このメソッドを使用する前に，
//   PrintFromPage  印刷開始頁番号
//   PrintToPage    印刷終了頁番号
//   を設定しておく.デフォルト値は1,PageCount
//
//   plPrevFrm.pasのPrintBtnClickイベントで使用している
//   プレビューなしで直接印刷する場合は，このメソッドを使用する．
//====================================================================
procedure TCustomplPrev.Print;
var
     i,FromPage,ToPage: Integer;
     fgAcrobatOut : Boolean;
     ABitmap : TBitmap;
begin
     {プレビューフォームが表示されている場合は[印刷]ボタンからのPrintメソッド呼出と見なす}
     {そうでない時は派生コンポーネントのExecute(初期化)メソッドを実行する}
     if FForm=nil then begin
       Execute;
     end else begin
       if FForm.Visible=False then Execute;
     end;

     {描画コードなし}
     if FDrawType=dtNone then begin
       Application.MessageBox(PChar(S6),PChar(S0),MB_ICONWARNING);
       exit;
     end;
     {ここで改めてplSetPrinerプロパティを確認}
     {プリンタドライバが一つも存在しなければplSetPrinterプロパティにnilを返す}
     {SetDefaultPrinterはBeginDocとProcNameで実行しているので実際には不要であるが}
     {本コンポの利用者で，Printメソッドの前でプリンタの設定を変更している方がいた}
     {ので，その対策}
     SetDefaultPrinter;
     {プリンタドライバがインストールされていない環境の場合}
     if FPrinterFlag=False then begin
       Application.MessageBox(PChar(S7),PChar(' 印刷'),MB_ICONINFORMATION);
       exit;
     end;

     fgAcrobatOut:=False;
     if FPrintFromPage=0 then FPrintFromPage:=1;
     if FPrintToPage=0   then FPrintToPage:=FPageCount;
     {空白頁出力対策}
     {印刷開始頁よりも終了頁番号が小さいと空白頁を出力することがある}
     if FPrintFromPage>FPrintToPage then begin
       FromPage:=FPrintToPage;
       ToPage  :=FPrintFromPage;
     end else begin
       FromPage:=FPrintFromPage;
       ToPage  :=FPrintToPage;
     end;
     if ToPage>FPageCount then ToPage:=FPageCount;

     {改めて用紙の情報を取得}
     SetPaperInfo;
     {プリンタ名にAcrobatという文字列があったら}
     if (AnsiPos('ACROBAT',AnsiUpperCase(FplSetPrinter.PrinterName))<>0) or (FAcrobatOut) then begin
       fgAcrobatOut:=True;
       GetKeyBoardState(KeyBoardState);
       DefaultKeyState:=KeyBoardState[VK_CONTROL];
       {最初に保存先を聞いてこない様にするため[Ctrl]を押したことにする}
       KeyBoardState[VK_CONTROL]:=$81;
       SetKeyBoardState(KeyBoardState);
     end;

     {印刷}
     if FTitle='' then begin
       Printer.Title:=Application.Title+'印刷';
     end else begin
       Printer.Title:=FTitle;
     end;

     Printer.BeginDoc;
     FPrinting:=True;
     Screen.Cursor:=FCursor;

     try
       for i:=FromPage to ToPage do begin
         ScaleInitialize(Printer.Canvas,False);
         {逆方向(180度回転)印刷のプロパティInversePrintはVer3.4で導入}
         {逆方向のStrechDrawはWin95,98では文字が正常に印刷できない}
         {DHGLのFixMetafile9Xを利用してもこの問題は回避できない}
         {そこでOSを判別してWin95,98の場合はビットマップに変換して印刷する}
         {この印刷コードの修正はVer4.0}
         if FInversePrint then begin
           {Windows95,98,ME}
           if Win32Platform=VER_PLATFORM_WIN32_WINDOWS then begin
             ABitmap:=TBitmap.Create;
             ABitmap.HandleType :=bmDIB;
             ABitmap.PixelFormat:=pf24bit;
             try
               ABitmap.Width :=FMetaImage.Width;
               ABitmap.Height:=FMetaImage.Height;
               ABitmap.Canvas.Draw(0,0,GetMetaImage(i));
               StretchDrawBitmap(Rect(FViewWidth,FViewHeight,0,0),ABitmap);
             finally
               ABitmap.Free;
             end;
           {WindowsNT4,2000,XP}
           end else begin
             Printer.Canvas.StretchDraw(Rect(FViewWidth,FViewHeight,0,0),GetMetaImage(i));
           end;
         end else begin
           Printer.Canvas.StretchDraw(Rect(0,0,FViewWidth,FViewHeight),GetMetaImage(i));
         end;
         Application.ProcessMessages;
         if Assigned(FOnPrint) then FOnPrint(Self,i);
         if i<ToPage           then Printer.NewPage;
       end;
     finally
       SetMapMode(Printer.Canvas.Handle,MM_TEXT);
       Printer.EndDoc;
       Application.ProcessMessages;
       FPrinting:=False;
       Screen.Cursor:=SaveCursor;
     end;
     if fgAcrobatOut then begin
       {キーの押下状態を元に戻す}
       KeyBoardState[VK_CONTROL]:=DefaultKeyState;
       SetKeyBoardState(KeyBoardState);
     end;
end;
//====================================================================
//   自動拡大縮小のためのメソッド
//   設計時の用紙サイズを設定
//   plPrevを呼出す前にこのメソッドで印刷コードを作成した時に想定し
//   た用紙サイズを指定しておくと,印刷の際[印刷]ダイアログで設定した
//   用紙サイズに合わせて拡大,縮小印刷を行う.
//   2002.5.10追加
//====================================================================
procedure TCustomplPrev.DesignedPaperSize(W, H: Integer);
begin
     if W*H<>0 then begin
       FDesignedPaperWidth  :=W;
       FDesignedPaperHeight :=H;
     end;
end;
//====================================================================
//   印刷の際にプリンタ設定が変更された場合に備えてプリンタの設定を
//   ファイルストリームに待避
//
//   以下で使用している
//   PrintBtnClick(印刷ダイアログを表示して印刷)
//   ActionHardCopyExecute(フォームのハードコピー)
//
//   plPrev.pasに書いてあるのは，他の場合も利用の可能性...
//   ないか(一応publicにしてある)．
//   プリンタ設定コンポーネントの同様の目的では他のコードを使用して
//   いるが(テストプログラム)，こちらは変えてみた．あまり意味はなか
//   ったかも知れない．                                              }                                                    }
//====================================================================
procedure TCustomplPrev.SavePrinterSetting;
begin
     if FPrinterFlag=False then exit;

     PrtCompName  :=ChangeFileExt(Application.ExeName,'.plv');
     PrtCompStream:=TFileStream.Create(PrtCompName, fmCreate);
     try
       {TStream.WriteDescendent}
       PrtCompWriter:=TWriter.Create(PrtCompStream,4096);
       try
         {TWriter.WriteDescendent}
         PrtCompWriter.RootAncestor := nil;
         PrtCompWriter.Ancestor := nil;
         PrtCompWriter.Root := Owner;
         PrtCompWriter.WriteSignature;
         PrtCompWriter.WriteComponent(FplSetPrinter);
         PrtCompWriter.WriteListEnd;
       finally
         PrtCompWriter.Free;
       end;
     finally
       PrtCompStream.Free;
     end;
end;
//====================================================================
//   ファイルストリームに待避していたプリンタ設定コンポーネントの設
//   定を読出して再設定
//
//   以下で使用している
//   PrintBtnClick(印刷ダイアログを表示して印刷)
//   ActionHardCopyExecute(フォームのハードコピー)
//====================================================================
procedure TCustomplPrev.ReadPrinterSetting;
var
     AOwner,AParent: TComponent;
     S: String;
begin
     if FPrinterFlag=False then exit;
     
     try
       S:=FplSetPrinter.Name;
       if S<>'' then begin
         PrtCompName  :=ChangeFileExt(Application.ExeName,'.plv');
         PrtCompStream:=TFileStream.Create(PrtCompName,fmOpenRead);
         PrtCompReader:=TReader.Create(PrtCompStream,4096);
         AOwner       :=TComponent(FplSetPrinter).Owner;
         AParent      :=TComponent(FplSetPrinter);
         try
           FplSetPrinter.Name:='';
           PrtCompReader.ReadComponents(AOwner,AParent,ComponentsProc);
         finally
           PrtCompReader.Free;
           PrtCompStream.Free;
           FplSetPrinter.GetPrinterInfo(False);
           SetPaperInfo;
         end;
       end;
     except
       FplSetPrinter.Name:=S;
     end;
end;
//====================================================================
//  ReadComponents(この上のReadPrinterSettingで使用)第3引数の値
//====================================================================
procedure TCustomplPrev.ComponentsProc(Component: TComponent);
begin
     if (PrtCompReader.Position = PrtCompStream.Size) then begin
       PrtCompReader.Position := PrtCompReader.Position - 1;
     end;
end;
//====================================================================
//  キャンバスへの描画終了とメタファイルの取得 　　
//  逐次表示方式の場合，ここで初めてMetaCanvasに描画する
//  先読み方式の場合，すでに描画済みなのでMetaImageListから取得
//  このMetaImageList配列(TMetaFile)に収められているメタファイルは
//  Windows9X互換
//====================================================================
function TCustomplPrev.GetMetaImage(Page: Integer): TMetaFile;
var
     APage: Integer;
begin
     {先読み方式}
     if FDrawType=dtCont then begin
       if Page<=0 then begin
         APage:=1;
       end else if Page>=FPageCount then begin
         APage:=FPageCount;
       end else begin
         APage:=Page;
       end;
       CreateMetaCanvas(False);
       ScaleInitialize(FCanvas,not(FPrinting));
       try
         FCanvas.StretchDraw(Rect(0,0,FViewWidth,FViewHeight),MetaImageList[APage-1]);
         {OnBeforeViewイベントがある場合}
         if Assigned(FOnBeforeView) then FOnBeforeView(Self,APage);
       finally
         FCanvas.Free;
         FCanvas:=nil;
       end;
       Result:=FMetaImage;
     {逐次表示方式}
     {逐次表示方式の場合はFPageNumberの値を描画に使用する}
     end else if FDrawType=dtStat then begin
       {予め設定した総頁数を越えての描画は禁止}
       if Page<=0 then begin
         FPageNumber:=1;
       end else if Page>=FPageCount then begin
         FPageNumber:=FPageCount;
       end else begin
         FPageNumber:=Page;
       end;
       {MetaFileとMetaFileCanvasを作成}
       if Assigned(FCanvas) then FCanvas.Free;
       Screen.Cursor:=FCursor;
       CreateMetaCanvas(False);
       ScaleInitialize(FCanvas,True);
       {作成したplCanvasにProcNameメソッドで描画}
       {実際には外部のプログラムを実行する(ProcNameプロパティで指定した)}
       try
         Application.ProcessMessages;
         if Assigned(FProcName) then FProcName;
       finally
         {FCanvasをFreeすればMetaFile.Canvasへの描画終了}
         FCanvas.Free;
         FCanvas:=nil;
         Screen.Cursor:=SaveCursor;
       end;
       Result:=FMetaImage;
     end else begin
       Result:=nil;
     end;
end;
//====================================================================
//   メタファイルとメタファイル・キャンバスの作成
//
//   このメタファイルに描画内容が記録される.
//   Flag=True  新規にメタファイルを作成(プログラムの開始時だけ実行)
//   Flag=False 現在のメタファイルを使用
//   プリンタや用紙設定の変更があった場合はFalseで再設定が必要
//====================================================================
procedure TCustomplPrev.CreateMetaCanvas(Flag:Boolean);
begin
     if Flag then begin
       if Assigned(FMetaImage) then FMetaImage.Free;
       FMetaImage:=TMetafile.Create;
       {新規作成の場合は表示幅と高さを用紙のそれと同じにする}
       {ただし，ProcName設定前，BeginDocの前に設定してあれば(0以外なら)それを使用}
       if FViewWidth=0  then FViewWidth :=FPaperWidth; {表示幅のデフォルトは用紙幅}
       if FViewHeight=0 then FViewHeight:=FPaperHeight;{表示高さのデフォルトは用紙長さ}
     end;
     FViewPaperRatio:=FViewHeight/FViewWidth;
     {0.01mm単位に換算}
     FMetaImage.MMWidth :=FViewWidth*10;
     FMetaImage.MMHeight:=FViewHeight*10;

     if FPrinterFlag then begin
       {Meta.Width,Meta.Heightを取得するために一度CreateしてFree}
       FCanvas:=TMetaFileCanvas.Create(FMetaImage,Printer.Handle);
       FCanvas.Free;
       MetaW:=FMetaImage.Width;
       MetaH:=FMetaImage.Height;
       FCanvas:=TMetaFileCanvas.Create(FMetaImage,Printer.Handle);
     end else begin
       {Meta.Width,Meta.Heightを取得するために一度CreateしてFree}
       FCanvas:=TMetaFileCanvas.Create(FMetaImage,0);
       FCanvas.Free;
       MetaW:=FMetaImage.Width;
       MetaH:=FMetaImage.Height;
       FCanvas:=TMetaFileCanvas.Create(FMetaImage,0);
     end;
     FCanvas.Font.PixelsPerInch:=FXResolution;

     FCanvas.Font.Height:=-RoundOff(10.5*254.0/72.0);
     Application.ProcessMessages;
     {この後ScaleInitializeを実行するが，ScaleInitializeだけを単独で}
     {実行する場合もあるので別ルーチンとしている}
end;
//====================================================================
//   用紙のバックカラー(PaperColorプロパティ)と連続用紙の台紙描画
//   先読み方式ではプレビューの時,逐次方式ではCanvas用紙設定時で
//   ScaleInitializeメソッド内で呼出して実行している．
//====================================================================
procedure TCustomplPrev.DrawPaperBack(ACanvas: TCanvas;Xw,Yh: Integer);
var
     X1,Y1: Integer;
     S: String;
begin
     {プリンタ出力中でない時だけ描画する}
     if not(FPrinting) then begin
       {用紙背景を指定色で塗潰す}
       ACanvas.Brush.Color:=FPaperColor;
       ACanvas.FillRect(Rect(0,0,Xw,Yh));
       if Assigned(FOnNoPrintDraw) then begin
         FOnNoPrintDraw(Self,FPageNumber);
       end;
       {連続用紙の場合}
       if FplSetPrinter<>nil then begin
         S:=ToZenkaku(FplSetPrinter.BinName);
         if Pos('トラクタ',S)<>0 then begin
           X1:=40;
           Y1:=40;
           ACanvas.Pen.Width:=0;
           ACanvas.Pen.Color:=clSilver;
           while True do begin
             ACanvas.Brush.Color:=clBtnFace;
             ACanvas.Ellipse(X1,Y1,X1+40,Y1+40);
             ACanvas.Ellipse(Xw-X1,Y1,Xw-X1-40,Y1+40);
             if Y1>=Yh then break;
             Y1:=Y1+127;
           end;
           {切取り線の破線}
           ACanvas.Pen.Style:=psDot;
           ACanvas.MoveTo(127,0);
           ACanvas.LineTo(127,Yh);
           ACanvas.MoveTo(Xw-127,0);
           ACanvas.LineTo(Xw-127,Yh);
           {Cavnasの塗潰し色を連続でない場合と同じにしておく}
           {そうしないと連続紙とそうでない場合とで，この後の描画が変わってしまう}
           ACanvas.Brush.Color:=FPaperColor;
         end;
       end;
     end;
end;
//====================================================================
//   Canvas座標値(スケーリングの設定)
//   Canvasを作成したときは必ず実行
//
//   MapMode       初期設定値はMM_TEXT.このコンポではMM_ANISOTROPIC
//                 しか使用しない.
//   WindowExtEx   用紙のスケールは横FPaperWidth,縦がFPaperHeight
//   ViewPortExtEx 印刷の幅はPaperWidht,長さはplPaperHeight
//   WindowOrgEx   PrinterOffsetX,PrinterOffsetYで指定する値だけ全体
//                 の印字位置を平行移動する．
//   ViewPortOrgEx PaperLO,PaperTOを設定しないと印字可能左端の座標か
//                 PaperLO,PaperTOだけ更に印字しない部分が発生
//
//   Ver4.2での修正
//   長年の課題であった印刷とプレビューのズレ(全体的な)を修正．
//   SetViewPortOrgExの引数の使用方法が間違っていた．
//   伊藤　浩昭さん，サンスクです．
//====================================================================
procedure TCustomplPrev.ScaleInitialize(ACanvas: TCanvas; Flag:Boolean);
var
     ALeftOffset: Integer;
     ATopOffset : Integer;
begin
     if ACanvas=Printer.Canvas then begin
       SetMapMode       (ACanvas.Handle,ScaleMode);
       SetWindowExtEx   (ACanvas.Handle,FPaperWidth,FPaperHeight,nil);
       SetViewPortExtEx (ACanvas.Handle,FplPaperWidth,FplPaperHeight,nil);
       {逆方向印刷の場合SetPaperInfoで逆にしているで戻す(Ver4.0で修正)}
       if FInversePrint then begin
         ALeftOffset:=FplPaperWidth -FplPageWidth -PaperLO;
         ATopOffset :=FplPaperHeight-FplPageHeight-PaperTO;
         SetWindowOrgEx   (ACanvas.Handle,FPrintOffsetX,FPrintOffsetY,nil);
         SetViewPortOrgEx (ACanvas.Handle,-ALeftOffset,-ATopOffset,nil);
       end else begin
         SetWindowOrgEx   (ACanvas.Handle,-FPrintOffsetX,-FPrintOffsetY,nil);
         SetViewPortOrgEx (ACanvas.Handle,-PaperLO,-PaperTO,nil);
       end;
     end else begin
       SetMapMode       (ACanvas.Handle,ScaleMode);
       SetWindowExtEx   (ACanvas.Handle,FViewWidth,FViewHeight,nil);
       SetViewPortExtEx (ACanvas.Handle,MetaW,MetaH,nil);
       {スケーリングの後に用紙の色や連続用紙の台紙描画}
       if Flag then DrawPaperBack(ACanvas,FViewWidth,FViewHeight);
       if FViewClip then begin
         IntersectClipRect(ACanvas.Handle,FLeftOffset,FTopOffset,FRightOffset,FBottomOffset);
       end;
     end;
     {文字列を描画する時のことを考えて背景色をクリアしておく}
     ACanvas.Brush.Style :=bsClear;
end;
//====================================================================
//   用紙サイズ等の設定
//
//   使用する用紙等の値を拙著プリンタ設定コンポーネントの値から設定
//
//   PaperLO        用紙の印刷可能左端(ドット)
//   PaperTO        用紙の印刷可能上端(ドット)
//   PaperRO        用紙の印刷可能右端(ドット)
//   PaperBO        用紙の印刷可能下端(ドット)
//   ScaleMode      非等方設定．MM_ANISOTROPICにしないと0.1mm単位な
//                  どの任意の単位に設定できない
//   FPaperRatio    現実の用紙の物理的な縦横比
//   インチサイズ設定にすると，フォントサイズの計算式の変更が必要．
//
//   このSetPaperInfoではViewWidth,ViewHeightプロパティは使用なし
//====================================================================
procedure TCustomplPrev.SetPaperInfo;
var
     WRa,HRa,Ratio1,Ratio2: Double;
begin
     if FplSetPrinter=nil then begin
       if Printer.Printers.Count>0 then begin
         {プリンタ設定コンポがない時は現在のプリンタの情報を取得}
         FplPaperWidth  :=GetDeviceCaps( Printer.Handle,PHYSICALWIDTH);
         FplPaperHeight :=GetDeviceCaps( Printer.Handle,PHYSICALHEIGHT);
         FplPageWidth   :=GetDeviceCaps( Printer.Handle,HORZRES);
         FplPageHeight  :=GetDeviceCaps( Printer.Handle,VERTRES);
         FXResolution   :=GetDeviceCaps( Printer.Handle,LOGPIXELSX);
         FYResolution   :=GetDeviceCaps( Printer.Handle,LOGPIXELSY);

         {逆方向印刷の場合は，プリンタの物理的オフセットは左右上下逆となる}
         if FInversePrint then begin
           PaperLO :=FplPaperWidth -GetDeviceCaps( Printer.Handle,PHYSICALOFFSETX);
           PaperTO :=FplPaperHeight-GetDeviceCaps( Printer.Handle,PHYSICALOFFSETY);
         end else begin
           PaperLO :=GetDeviceCaps( Printer.Handle,PHYSICALOFFSETX);
           PaperTO :=GetDeviceCaps( Printer.Handle,PHYSICALOFFSETY);
         end;
         FPrinterFlag:=True;
       end else begin
         FXResolution   :=FDefaultResolution;
         FYResolution   :=FDefaultResolution;
         FPrinterFlag   :=False;
       end;
     end else begin
       if FplSetPrinter.PrintersCount>0 then begin
         FplPaperWidth  :=FplSetPrinter.PaperWidth;
         FplPaperHeight :=FplSetPrinter.PaperHeight;

         {逆方向印刷の場合は，プリンタの物理的オフセットは左右上下逆となる}
         if FInversePrint then begin
           PaperLO :=FplPaperWidth -FplSetPrinter.RightOffset;
           PaperTO :=FplPaperHeight-FplSetPrinter.BottomOffset;
         end else begin
           PaperLO :=FplSetPrinter.LeftOffset;
           PaperTO :=FplSetPrinter.TopOffset;
         end;
         FXResolution  :=FplSetPrinter.XResolution;
         FYResolution  :=FplSetPrinter.YResolution;
         FplPageWidth  :=FplSetPrinter.PageWidth;
         FplPageHeight :=FplSetPrinter.PageHeight;
         FPrinterFlag  :=True;
       end else begin
         FXResolution   :=FDefaultResolution;
         FYResolution   :=FDefaultResolution;
         FPrinterFlag   :=False;
       end;
     end;


     {自動縮小拡大のための設計時用紙サイズが0でない時は設定されていると見なす}
     {本当は縦サイズの値もチェックすべきであるが省略}
     {逐次表示方式のみ対応}
     if FPrinterFlag then begin
       {0.1mm単位に換算した左と上端のオフセット}
       FLeftOffset   :=Ceil (PaperLO*254/FXResolution);
       FTopOffset    :=Ceil (PaperTO*254/FYResolution);

       if (FDesignedPaperWidth>0) and (FDrawType=dtStat) then begin
         Ratio1:=FDesignedPaperWidth/FDesignedPaperHeight;
         Ratio2:=FPaperWidth/FPaperHeight;
         if ((Ratio1>1) and (Ratio2>1)) or ((Ratio1<1) and (Ratio2<1)) then begin
           WRa :=FDesignedPaperWidth /FPaperWidth;
           HRa :=FDesignedPaperHeight/FPaperHeight;
           FPaperWidth   :=FDesignedPaperWidth;
           FPaperHeight  :=FDesignedPaperHeight;
         end else begin
           WRa :=FDesignedPaperHeight/FPaperWidth;
           HRa :=FDesignedPaperWidth /FPaperHeight;
           FPaperWidth  :=FDesignedPaperHeight;
           FPaperHeight :=FDesignedPaperWidth;
         end;
         FPageWidth  :=Trunc(FplPageWidth*254*WRa /FXResolution);
         FPageHeight :=Trunc(FplPageHeight*254*HRa/FYResolution);
         {通常の場合.FDesingedPapeer...導入前はこの部分だけだった}
       end else begin
         {0.1mm単位用紙サイズ}
         FPaperWidth   :=Trunc(FplPaperWidth*254 /FXResolution);
         FPaperHeight  :=Trunc(FplPaperHeight*254/FYResolution);
         {0.1mm単位の頁幅と高さ(印刷可能領域)}
         FPageWidth  :=Trunc(FplPageWidth*254 /FXResolution);
         FPageHeight :=Trunc(FplPageHeight*254/FYResolution);
       end;
     end;

     {用紙の縦横の寸法が決定したので右と下端オフセットを計算}
     FRightOffset :=FLeftOffset+FPageWidth;
     FBottomOffset:=FTopOffset+FPageHeight;

     ScaleMode    :=MM_ANISOTROPIC;
     FPaperRatio  :=FPaperHeight/FPaperWidth;

     {各マージンの設定}
     {設計時のみ自動調整する}
     if (csDesigning in ComponentState) then begin
       if FTopMargin<FTopOffset     then FTopMargin:=FTopOffset;
       if FLeftMargin<FLeftOffset   then FLeftMargin:=FLeftOffset;
       if FRightMargin<(FPaperWidth-FRightOffset)    then FRightMargin:=FPaperWidth-FRightOffset;
       if FBottomMargin<(FPaperHeight-FBottomOffset) then FBottomMargin:=FPaperHeight-FBottomOffset;
       if FHeaderMargin>FTopMargin    then FHeaderMargin:=FTopMargin;
       if FFooterMargin>FBottomMargin then FFooterMargin:=FBottomMargin;
     end;
end;




       {-------------------  後はおまけ ----------------------}
       {-- 描画メソッドがなにもないコンポじゃつまらないので --}
       {-------------- でもコンポ本体でも使用 ----------------}


//====================================================================
//   四捨五入関数
//   小数点一桁目を四捨五入して整数にする．
//   この関数は内部だけで使用
//====================================================================
function TCustomplPrev.Roundoff(X: Double): Integer;
begin
     if X>=0 then begin
       Result:=Trunc(X+0.5)
     end else begin
       Result:=Trunc(X-0.5);
     end;
end;
//====================================================================
//   文字列Sのうち英数字と－のみを半角にする関数
//
//   英数字と-だけで，他の記号類は変換しない
//   FDELPHI MES(15) 00102 瑠瓏さんのコードの一部を借用
//   アセンブラのコードが懐かしい(昔PC-9801でGraphicのコードを....)
//====================================================================
function TCustomplPrev.AlpToHank(S: String): string;
var
     W:word;
     Sw:String;
  function SJisToJis(N:WORD):WORD; assembler;
  asm
      shl  ah,1;
      sub  al,1fh;
      js   @1
      cmp  al,61h;
      adc  al,0deh;
      @1:
      add  ax,1fa1h;
      and  ax,7f7fh;
  end;
  function CharToWord(S:string):Word;
  begin
    Result:=(Ord(s[1]) shl 8) + Ord(s[2]);
  end;
begin
     Result:='';
     while Length(S)>0 do begin
       if S[1] in [#$81..#$9f,#$e0..#$fc] then begin
         W:=CharToWord(s+'@');
         if Hi(SJisToJis(W))=$23 then begin
           Result:=Result+Char(lo(SJisToJis(W)));
           Delete(S,1,2)
         end else begin
           Sw:=Copy(S,1,2);
           {ここに半角にしたい文字を書く}
           if Sw='－' then begin
             Result:=Result+'-';
           end else begin
             Result:=Result+Sw;
           end;
           Delete(S,1,2)
         end;
       end else begin
         Result:=Result+S[1];
         Delete(S,1,1)
       end;
     end;
end;
//====================================================================
//   文字列Sを全て半角にする関数
//
//   カタカナ,ひらがなも半角にしてしまうので注意.
//   各種命令はWin32 APIを参照のこと.
//====================================================================
function TCustomplPrev.ToHankaku(S: String): String;
var
     DestStr: PChar;
     DestSize: Integer;
     mode: DWORD;
begin
     mode:=LCMAP_HALFWIDTH;
     Result:=S;
     DestSize:=LCMapString(LOCALE_SYSTEM_DEFAULT,mode,
                           PChar(S),Length(S),Nil,0);
     if DestSize=0 then exit;
     DestStr:=AllocMem(DestSize+1);
     try
       DestSize:=LCMapString(LOCALE_SYSTEM_DEFAULT,mode,
                             PChar(S),Length(S),DestStr,DestSize);
       if DestSize<>0 then begin
         Result:=StrPas(DestStr);
       end;
     finally
       FreeMem(DestStr);
     end;
end;
//====================================================================
//   文字列を全て全角にする                                     　
//
//   住所の印刷の時に,番地の数字を全て全角にしたいために作成
//   各種命令はWin32 APIを参照のこと.
//====================================================================
function TCustomplPrev.ToZenkaku(S: String): String;
var
     DestStr :PChar;
     DestSize:Integer;
     mode    :DWORD;
begin
     mode:=LCMAP_FULLWIDTH;
     Result:=S;
     DestSize:=LCMapString(LOCALE_SYSTEM_DEFAULT,mode,
                           PChar(S),Length(S),Nil,0);
     if DestSize=0 then exit;
     DestStr:=AllocMem(DestSize+1);
     try
       DestSize:=LCMapString(LOCALE_SYSTEM_DEFAULT,mode,
                             PChar(S),Length(S),DestStr,DestSize);
       if DestSize<>0 then begin
         Result:=StrPas(DestStr);
       end;
     finally
       FreeMem(DestStr);
     end;
end;
//====================================================================
//   フォントサイズ
//   印刷プレビューコンポplPrevでは長さの単位が0.1mmである
//   そこでここではフォントサイズ(1ptは1/72 inch)を0.1mm単位の長さに
//   換算している                  　　　　　　　　　　
//   254は1inchを0.1mm単位で表した数値
//   1pt=1/72inch=0.3528mm
//=====================================================================
procedure TCustomplPrev.FontSize(S:Double);
begin
     if FCanvas=nil then exit;
     FCanvas.Font.Height:=-RoundOff(S*254.0/72.0);
end;
//====================================================================
//   フォント高さ
//   FontSizeでは負の値にしているので負の値を指定するとよい
//====================================================================
procedure TCustomplPrev.FontHeight(V: Integer);
begin
     FCanvas.Font.Height:=V;
end;
//====================================================================
//   フォント名
//   オブジェクト・インスペクターの表示をコピーすれば確実
//====================================================================
procedure TCustomplPrev.FontName(V:TFontName);
begin
     FCanvas.Font.Name:=V;
end;
//====================================================================
//   フォントの色
//   (注意:フォントはペンで書くのではなくFontで描画する)
//   色の設定には,フォントの色,線の色,塗潰しの色がある
//====================================================================
procedure TCustomplPrev.FontColor(V:TColor);
begin
     FCanvas.Font.Color:=V;
end;
//====================================================================
//   フォントスタイルの指定
//
//   fsBold      太字になる
//   fsItalic    斜体になる
//   fsUnderline 下線付きになる
//   fsStrikeout 打ち消し線付きになる
//   FontStyle([fsItalic,fsStrikeout]);の様に指定する.
//   いままでのスタイルを取消すにはFontSytle([])でOK．
//====================================================================
procedure TCustomplPrev.FontStyle(V:TFontStyles);
begin
     FCanvas.Font.Style:=V;
end;
//====================================================================
//   フォントのセット，アサイン
//   Ver4.1でHeightの設定を追加
//====================================================================
procedure TCustomplPrev.FontAssign(V: TFont);
begin
     FCanvas.Font.Assign(V);
     FCanvas.Font.Height:=V.Height;
end;
//====================================================================
//   ペンの色(線の色)
//   色の設定には，フォントの色，ペンの色(線の色)，塗潰しの色がある
//====================================================================
procedure TCustomplPrev.PenColor(V: TColor);
begin
     FCanvas.Pen.Color:=V;
end;
//====================================================================
//   線の色(線の色)
//   色の設定には，フォントの色，ペンの色(線の色)，塗潰しの色がある
//====================================================================
procedure TCustomplPrev.LineColor(V: TColor);
begin
     FCanvas.Pen.Color:=V;
end;
//====================================================================
//   塗潰しの色
//   色の設定には，フォントの色，ペンの色(線の色)，塗潰しの色がある
//====================================================================
procedure TCustomplPrev.BrushColor(V:TColor);
begin
     if FCanvas=nil then exit;
     FCanvas.Brush.Color:=V;
end;
//====================================================================
//   線のスタイル
//
//   線のスタイルなのかペンのスタイルなのか?
//   psSolid	   実線
//   psDash	   破線
//   psDot	   点線
//   psDashDot	   一点鎖線
//   psDashDotDot  二点鎖線
//   psClear	   線は描画しない
//   psInsideFrame 実線．ただしWidthが1より大きい場合には中間色を使
//                  用する場合がある
//   注意
//   Width プロパティが1でないときにはpsDotまたはpsDashは使えない．
//====================================================================
procedure TCustomplPrev.LineStyle(V:TPenStyle);
begin
     if FCanvas=nil then exit;
     FCanvas.Pen.Style:=V;
end;
//====================================================================
//   ペンのスタイル(線のスタイルに同じ)
//
//   線のスタイルなのかペンのスタイルなのか?
//   psSolid	   実線
//   psDash	   破線
//   psDot	   点線
//   psDashDot	   一点鎖線
//   psDashDotDot  二点鎖線
//   psClear	   線は描画しない
//   psInsideFrame 実線．ただしWidthが1より大きい場合には中間色を使
//                 用する場合がある
//   注意
//   Width プロパティが1でないときにはpsDotまたはpsDashは使えない．
//====================================================================
procedure TCustomplPrev.PenStyle(V:TPenStyle);
begin
     FCanvas.Pen.Style:=V;
end;
//====================================================================
//   線の太さ(ドット指定)
//   このコンポーネントでは1ドットは0.1mm
//====================================================================
procedure TCustomplPrev.LineWidth(V:Integer);
begin
     FCanvas.Pen.Width:=V;
end;
//====================================================================
//   ペンの太さ(ドット指定.線の太さに同じ)
//   plPrintでは１ドットは0.1mmである
//====================================================================
procedure TCustomplPrev.PenWidth(V:Integer);
begin
     FCanvas.Pen.Width:=V;
end;
//====================================================================
//   塗潰しのスタイル
//
//   bsSolid      全塗潰し
//   bsCross      縦横のクロス模様
//   bsClear      透明
//   bsDiagCross  斜めのクロス模様
//   bsBDiagonal  右上がりの斜め線
//   bsHorizontal 横線
//   bsFDiagonal  右下がりの斜め線
//   bsVertical   縦線
//====================================================================
procedure TCustomplPrev.BrushStyle(V:TBrushStyle);
begin
     FCanvas.Brush.Style:=V;
end;
//====================================================================
//   ペンを移動
//
//   座標(X,Y)にペンを移動
//   plPrintでは余りペン位置情報を意識していないが...
//====================================================================
procedure TCustomplPrev.MoveTo(X:Integer;Y:Integer);
begin
     FCanvas.MoveTo(X,Y);
end;
//====================================================================}
//   線を引く                                                        }
//                                                                   }
//   現在の位置から座標(X,Y)まで，現在の線のスタイルとペンで線を引く }
//====================================================================}
procedure TCustomplPrev.LineTo(X:Integer;Y:Integer);
begin
     FCanvas.LineTo(X,Y);
end;
//====================================================================
//   指定座標間に線を引く
//
//   座標(X1,Y1)と(X2,Y2)間に，現在の線のスタイルとペンで線を引く
//   plPrintでは引数の座標がX座標，Y座標の順になっているので注意
//====================================================================
procedure TCustomplPrev.Line(X1,X2,Y1,Y2:Integer);
begin
     FCanvas.MoveTo(X1,Y1);
     FCanvas.LineTo(X2,Y2);
end;
//====================================================================
//   塗潰し四角形の描画(枠線あり)
//
//   BrushColorで指定した色と
//   BurshStyleで指定したスタイルで四角形内を塗潰す
//   枠線は現在のペンの色で描画
//   塗潰しは，左と上の端は領域に含まれるが，右と下の端は含まれない．
//   引数の座標がX座標，Y座標の順になっているので注意
//====================================================================
procedure TCustomplPrev.Rectangle(X1,X2,Y1,Y2:Integer);
begin
     FCanvas.Rectangle(X1,Y1,X2,Y2);
end;
//====================================================================
//   塗潰し四角形の描画(枠線なし)
//
//   BrushColorで指定した色で四角形内を塗潰す．
//   枠線は描画しない．
//   塗潰しは，左と上の端は領域に含まれるが，右と下の端は含まれない．
//   引数の座標がX座標，Y座標の順になっているので注意
//====================================================================
procedure TCustomplPrev.FillRect(X1,X2,Y1,Y2:Integer);
begin
     FCanvas.FillRect(Rect(X1,Y1,X2,Y2));
end;
//====================================================================
//   四角形の描画
//
//   四角形の辺だけを，現在のペンの色と太さを使用して描画する．
//   引数の座標がX座標，Y座標の順になっているので注意
//====================================================================
procedure TCustomplPrev.RectLine(X1,X2,Y1,Y2:Integer);
begin
     FCanvas.Polyline([Point(X1,Y1),Point(X2,Y1),Point(X2,Y2),
                        Point(X1,Y2),Point(X1,Y1)]);
end;
//====================================================================
//   四角形の描画(塗潰しなし)
//   現在のFCanvasのBrushの設定を使用
//
//   座標(X1,Y1),(X2,Y2)で指定する長方形を１ピクセル幅で引く
//   引数の座標がX座標，Y座標の順になっているので注意
//====================================================================
procedure TCustomplPrev.FrameRect(X1,X2,Y1,Y2:Integer);
begin
     FCanvas.FrameRect(Rect(X1,Y1,X2,Y2));
end;
//====================================================================
//   円の描画
//
//   中心座標が(X1,Y1)で直径Dの円を，現在のペンの設定値を用いて描画
//   する．外周はPenの色，内部はBrushの色となる．
//====================================================================
procedure TCustomplPrev.Circle(X,Y,D: Integer);
var
     R,X1,Y1,X2,Y2: Integer;
begin
     R:=RoundOff(D/2.0);
     X1:=X-R;
     Y1:=Y-R;
     X2:=X+R;
     Y2:=Y+R;
     SetBkMode(FCanvas.Handle,TRANSPARENT);
     FCanvas.Ellipse(X1,Y1,X2,Y2);
end;
//====================================================================
//   楕円の描画
//
//   中心座標が(X1,Y1)でX軸方向の径がDX,Y軸方向の径がDYの楕円を，現
//   在のペンの設定値を用いて描画する．外周はPenの色，内部はBrushの
//   色となる．
//====================================================================
procedure TCustomplPrev.Ellipse(X,Y,DX,DY: Integer);
var
     R,X1,Y1,X2,Y2: Integer;
begin
     R:=RoundOff(DX/2.0);
     X1:=X-R;
     X2:=X+R;
     R:=RoundOff(DY/2.0);
     Y1:=Y-R;
     Y2:=Y+R;
     SetBkMode(FCanvas.Handle,TRANSPARENT);
     FCanvas.Ellipse(X1,Y1,X2,Y2);
end;
//====================================================================
//   文字列の描画
//   X座標X1が文字列の左端，Y座標Y1が文字列の上端となる
//   動作はTCanvasのTextOut,このコンポのTextOutLTと同じ
//====================================================================
procedure TCustomplPrev.TextOut(X1,Y1:Integer;Text:String);
var
     AAdjust: Integer;
begin
     AAdjust := GetTextAAdjust(FCanvas, Text);
     FCanvas.Brush.Style:=bsClear;
     FCanvas.TextOut(X1+AAdjust,Y1,Text);
end;
//====================================================================
//   文字列の描画
//   X座標X1が文字列の左端，Y座標Y1が文字列の上端となる
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//====================================================================
procedure TCustomplPrev.TextOutLT(X1,Y1:Integer;Text:String);
var
     AAdjust: Integer;
begin
     AAdjust := GetTextAAdjust(FCanvas, Text);
     FCanvas.Brush.Style:=bsClear;
     FCanvas.TextOut(X1+AAdjust,Y1,Text);
end;
//====================================================================
//   文字列の描画　
//   X座標X1が文字列の左端，Y座標Y1が文字列の上下中央となる
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//====================================================================
procedure TCustomplPrev.TextOutLC(X1,Y1:Integer;Text:String);
var
     X,Y: Integer;
     AAdjust: Integer;
begin
     AAdjust := GetTextAAdjust(FCanvas, Text);
     X:=X1+AAdjust;
     Y:=Y1-Ceil(FCanvas.TextHeight('Hg')/2.0);
     FCanvas.Brush.Style:=bsClear;
     FCanvas.TextOut(X,Y,Text);
end;
//====================================================================
//   文字列の描画
//   X座標X1が文字列の左端，Y座標Y1が文字列の下端となる
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//====================================================================
procedure TCustomplPrev.TextOutLB(X1,Y1:Integer;Text:String);
var
     X,Y: Integer;
     AAdjust: Integer;
begin
     AAdjust := GetTextAAdjust(FCanvas, Text);
     X:=X1+AAdjust;
     Y:=Y1-FCanvas.TextHeight('Hg');
     FCanvas.Brush.Style:=bsClear;
     FCanvas.TextOut(X,Y,Text);
end;
//====================================================================
//   文字列の描画　　　　　　　　　　
//   X座標X1が文字列の左右中央，Y座標Y1が文字列の上端となる
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//====================================================================
procedure TCustomplPrev.TextOutCT(X1,Y1:Integer;Text:String);
var
     X,Y: Integer;
begin
     X:=X1-Ceil(FCanvas.TextWidth(Text)/2);
     Y:=Y1;
     FCanvas.Brush.Style:=bsClear;
     FCanvas.TextOut(X,Y,Text);
end;
//====================================================================
//   文字列の描画
//   X座標X1が文字列の左右中央，Y座標Y1が文字列の上下中央となる
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//====================================================================
procedure TCustomplPrev.TextOutCC(X1,Y1:Integer;Text:String);
var
     X,Y: Integer;
begin
     X:=X1-Ceil(FCanvas.TextWidth(Text)/2);
     Y:=Y1-Ceil(FCanvas.TextHeight('Hg')/2.0);
     FCanvas.Brush.Style:=bsClear;
     FCanvas.TextOut(X,Y,Text);
end;
//====================================================================
//   文字列の描画
//   X座標X1が文字列の左右中央，Y座標Y1が文字列の下端となる
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//====================================================================
procedure TCustomplPrev.TextOutCB(X1,Y1:Integer;Text:String);
var
     X,Y: Integer;
begin
     X:=X1-Ceil(FCanvas.TextWidth(Text)/2);
     Y:=Y1-FCanvas.TextHeight('Hg');
     FCanvas.Brush.Style:=bsClear;
     FCanvas.TextOut(X,Y,Text);
end;
//====================================================================
//   文字列の描画
//   X座標X1が文字列の右端，Y座標Y1が文字列の上端となる
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//====================================================================
procedure TCustomplPrev.TextOutRT(X1,Y1:Integer;Text:String);
var
     X,Y: Integer;
     CAdjust: Integer;
begin
     CAdjust:=GetTextCAdjust(FCanvas,Text);
     X:=X1-CAdjust-FCanvas.TextWidth(Text);
     Y:=Y1;
     FCanvas.Brush.Style:=bsClear;
     FCanvas.TextOut(X,Y,Text);
end;
//====================================================================
//   文字列の描画
//   X座標X1が文字列の右端，Y座標Y1が文字列のは上下中央となる
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//====================================================================
procedure TCustomplPrev.TextOutRC(X1,Y1:Integer;Text:String);
var
     X,Y: Integer;
     CAdjust: Integer;
begin
     CAdjust:=GetTextCAdjust(FCanvas,Text);
     X:=X1-CAdjust-FCanvas.TextWidth(Text);
     Y:=Y1-Ceil(FCanvas.TextHeight('Hg')/2.0);
     FCanvas.Brush.Style:=bsClear;
     FCanvas.TextOut(X,Y,Text);
end;
//====================================================================
//   文字列の描画
//   X座標X1が文字列の右端，Y座標Y1が文字列の下端となる
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//====================================================================
procedure TCustomplPrev.TextOutRB(X1,Y1:Integer;Text:String);
var
     X,Y: Integer;
     CAdjust: Integer;
begin
     CAdjust:=GetTextCAdjust(FCanvas,Text);
     X:=X1-CAdjust-FCanvas.TextWidth(Text);
     Y:=Y1-FCanvas.TextHeight('Hg');
     FCanvas.Brush.Style:=bsClear;
     FCanvas.TextOut(X,Y,Text);
end;
//====================================================================
//   文字列の描画(クリッピング)
//   座標(X1,Y1),(X2,Y2)で決まる四角形の左上に文字列を描画する．
//   四角形は描画しない．
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//   引数の座標がX座標，Y座標の順になっているので注意
//   Ver3.0でTextRect..をWin32 APIのDrawTextを使用するコードに変更
//====================================================================
procedure TCustomplPrev.TextRectLT(X1,X2,Y1,Y2:Integer;Text:String);
var
     uFormat: UINT;
     ARect: TRect;
     AAdjust: Integer;
begin
     uFormat:=DT_SINGLELINE or DT_LEFT or DT_TOP;
     AAdjust:=GetTextAAdjust(FCanvas,Text);
     ARect  :=Rect(X1+AAdjust,Y1,X2,Y2);
     SetBkMode(FCanvas.Handle,TRANSPARENT);
     DrawText(FCanvas.Handle,PChar(Text),-1,ARect,uFormat);
end;
//====================================================================
//   文字列の描画(クリッピング)
//   座標(X1,Y1),(X2,Y2)で決まる四角形の左端の中央に描画する．
//   四角形は描画しない．
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//   引数の座標がX座標，Y座標の順になっているので注意
//====================================================================
procedure TCustomplPrev.TextRectLC(X1,X2,Y1,Y2:Integer;Text:String);
var
     uFormat: UINT;
     ARect: TRect;
     AAdjust: Integer;
begin
     uFormat:=DT_SINGLELINE or DT_LEFT or DT_VCENTER;
     AAdjust:=GetTextAAdjust(FCanvas,Text);
     ARect  :=Rect(X1+AAdjust,Y1,X2,Y2);
     SetBkMode(FCanvas.Handle,TRANSPARENT);
     DrawText(FCanvas.Handle,PChar(Text),-1,ARect,uFormat);
end;
//====================================================================
//   文字列の描画
//   座標(X1,Y1),(X2,Y2)で決まる四角形の左側で上下真ん中に描画する．
//   ただし,(X1,X2)の幅に文字列が収まらない場合は均等割付のメソッド
//   TextRectJustを使用する.
//   四角形は描画しない．
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//   引数の座標がX座標，Y座標の順になっているので注意
//====================================================================
procedure TCustomplPrev.TextRectLCEx(X1, X2, Y1, Y2: Integer; Text: String);
var
     TextW: Integer;
begin
      TextW:=FCanvas.TextWidth(Text);
      if TextW<ABS(X2-X1) then begin
        TextRectLC(X1,X2,Y1,Y2,Text);
      end else begin
        TextRectJust(X1,X2,Y1,Y2,Text);
      end;
end;
//====================================================================
//   文字列の描画(クリッピング)
//   座標(X1,Y1),(X2,Y2)で決まる四角形の左下に文字列を描画する．
//   四角形は描画しない．
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//   引数の座標がX座標，Y座標の順になっているので注意
//====================================================================
procedure TCustomplPrev.TextRectLB(X1,X2,Y1,Y2:Integer;Text:String);
var
     uFormat: UINT;
     ARect: TRect;
     AAdjust: Integer;
begin
     uFormat:=DT_SINGLELINE or DT_LEFT or DT_BOTTOM;
     AAdjust:=GetTextAAdjust(FCanvas,Text);
     ARect  :=Rect(X1+AAdjust,Y1,X2,Y2);
     SetBkMode(FCanvas.Handle,TRANSPARENT);
     DrawText(FCanvas.Handle,PChar(Text),-1,ARect,uFormat);
end;
//====================================================================
//   文字列の描画(クリッピング)
//   座標(X1,Y1),(X2,Y2)で決まる四角形の左右の中間で上端に描画する．
//   四角形は描画しない．
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//   引数の座標がX座標，Y座標の順になっているので注意
//====================================================================
procedure TCustomplPrev.TextRectCT(X1,X2,Y1,Y2:Integer;Text:String);
var
     uFormat: UINT;
     ARect: TRect;
begin
     uFormat:=DT_SINGLELINE or DT_CENTER or DT_TOP;
     ARect  :=Rect(X1,Y1,X2,Y2);
     SetBkMode(FCanvas.Handle,TRANSPARENT);
     DrawText(FCanvas.Handle,PChar(Text),-1,ARect,uFormat);
end;
//====================================================================
//   文字列の描画(クリッピング)
//   座標(X1,Y1),(X2,Y2)で決まる四角形の真ん中に描画する．
//   四角形は描画しない．
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//   引数の座標がX座標，Y座標の順になっているので注意
//====================================================================
procedure TCustomplPrev.TextRectCC(X1,X2,Y1,Y2:Integer;Text:String);
var
     uFormat: UINT;
     ARect: TRect;
begin
     uFormat:=DT_SINGLELINE or DT_CENTER or DT_VCENTER;
     ARect  :=Rect(X1,Y1,X2,Y2);
     SetBkMode(FCanvas.Handle,TRANSPARENT);
     DrawText(FCanvas.Handle,PChar(Text),-1,ARect,uFormat);
end;
//====================================================================
//   文字列の描画
//   座標(X1,Y1),(X2,Y2)で決まる四角形の真ん中に描画する．
//   ただし,(X1,X2)の幅に文字列が収まらない場合は均等割付のメソッド
//   TextRectJustを使用する.
//   四角形は描画しない．
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//   引数の座標がX座標，Y座標の順になっているので注意
//====================================================================
procedure TCustomplPrev.TextRectCCEx(X1, X2, Y1, Y2: Integer; Text: String);
var
     TextW: Integer;
begin
      TextW:=FCanvas.TextWidth(Text);
      if TextW<ABS(X2-X1) then begin
        TextRectCC(X1,X2,Y1,Y2,Text);
      end else begin
        TextRectJust(X1,X2,Y1,Y2,Text);
      end;
end;
//====================================================================
//   文字列の描画(クリッピング)
//   座標(X1,Y1),(X2,Y2)で決まる四角形の左右中間の下端に描画する．
//   四角形は描画しない．
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//   引数の座標がX座標，Y座標の順になっているので注意
//====================================================================
procedure TCustomplPrev.TextRectCB(X1,X2,Y1,Y2:Integer;Text:String);
var
     uFormat: UINT;
     ARect: TRect;
begin
     uFormat:=DT_SINGLELINE or DT_CENTER or DT_BOTTOM;
     ARect  :=Rect(X1,Y1,X2,Y2);
     SetBkMode(FCanvas.Handle,TRANSPARENT);
     DrawText(FCanvas.Handle,PChar(Text),-1,ARect,uFormat);
end;
//====================================================================
//   文字列の描画(クリッピング)
//   座標(X1,Y1),(X2,Y2)で決まる四角形の右上端に描画する．
//   四角形は描画しない．
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//   引数の座標がX座標，Y座標の順になっているので注意
//====================================================================
procedure TCustomplPrev.TextRectRT(X1,X2,Y1,Y2:Integer;Text:String);
var
     uFormat: UINT;
     ARect: TRect;
     CAdjust: Integer;
begin
     uFormat:=DT_SINGLELINE or DT_RIGHT or DT_TOP;
     CAdjust:=GetTextCAdjust(FCanvas,Text);
     ARect  :=Rect(X1,Y1,X2-CAdjust,Y2);
     SetBkMode(FCanvas.Handle,TRANSPARENT);
     DrawText(FCanvas.Handle,PChar(Text),-1,ARect,uFormat);
end;
//====================================================================
//   文字列の描画(クリッピング)
//   座標(X1,Y1),(X2,Y2)で決まる四角形の右の上下中央に描画する．
//   四角形は描画しない．
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//   引数の座標がX座標，Y座標の順になっているので注意
//====================================================================
procedure TCustomplPrev.TextRectRC(X1,X2,Y1,Y2:Integer;Text:String);
var
     uFormat: UINT;
     ARect: TRect;
     CAdjust: Integer;
begin
     uFormat:=DT_SINGLELINE or DT_RIGHT or DT_VCENTER;
     CAdjust:=GetTextCAdjust(FCanvas,Text);
     ARect  :=Rect(X1,Y1,X2-CAdjust,Y2);
     SetBkMode(FCanvas.Handle,TRANSPARENT);
     DrawText(FCanvas.Handle,PChar(Text),-1,ARect,uFormat);
end;
//====================================================================
//   文字列の描画(クリッピング)
//   座標(X1,Y1),(X2,Y2)で決まる四角形の右下に描画する．
//   四角形は描画しない．
//
//   メソッド名の後ろの大文字は 　　　　
//   L  Left   左
//   R  Right  右
//   T  Top    上
//   B  Bottom 下
//   C  Center 左右の中間，上下の真ん中
//   引数の座標がX座標，Y座標の順になっているので注意
//====================================================================
procedure TCustomplPrev.TextRectRB(X1,X2,Y1,Y2:Integer;Text:String);
var
     uFormat: UINT;
     ARect: TRect;
     CAdjust: Integer;
begin
     uFormat:=DT_SINGLELINE or DT_RIGHT or DT_BOTTOM;
     CAdjust:=GetTextCAdjust(FCanvas,Text);
     ARect  :=Rect(X1,Y1,X2-CAdjust,Y2);
     SetBkMode(FCanvas.Handle,TRANSPARENT);
     DrawText(FCanvas.Handle,PChar(Text),-1,ARect,uFormat);
end;
//====================================================================
//   郵便番号枠と郵便番号の描画  定型郵便物の場合
//   印刷方向が縦の場合は右上に,横の場合は右下に印刷　　　
//   文字列Zipに含まれる数文字以外は除去してから印刷
//   文字列はこのコンポのフォント関係メソッドの使用が前提
//
//   Zip         郵便番号(-などの記号があってもこのメソッド内で除去)
//   PrtOut      郵便番号枠を印刷するかしないかのフラグ
//   OffsetX     文字印刷調整.横方向.
//   OffsetY     文字印刷調整.縦方向.
//   DispOffsetY プレビューの表示位置調整.縦方向.+で下方にプレビュー
//               印刷方向が縦の場合(折曲げが画面上の時)のみ有効
//   DispOffsetYは2002.6.20追加
//   DispOffsetYの機能を印刷方向が横の場合もサポート(Ver3.1)
//====================================================================
procedure TCustomplPrev.ZipOut(Zip: String; OffsetX,OffsetY:Integer;
PrtOut: Boolean;DispOffsetY:Integer=0);
var
     i: Integer;
     ZWidth  : Integer; {番号枠の幅}
     ZHeight : Integer; {番号枠の高さ}
     ZLen    : Integer; {番号枠の距離}
     BaseX   : Integer; {枠の左端のX}
     BaseY   : Integer; {上端の上端のY}
     Dis     : Integer; {4桁目の開始位置}
     X,Y     : Integer;
     SZip    : String;
     S0,S,S1,S2 : String;
     FontW,FontH: Integer;
     OffX,OffY  : Integer;
     OffsetXX,OffsetYY : Integer;
     Port: Boolean;
begin
     ZLen    :=70;
     Dis     :=216;
     if PrtOut then PenColor(clRed) else PenColor($00AAAAFF);
     PenStyle(psSolid);
     PenWidth(5);
     {印刷位置を調整するのはプリンタ出力の場合のみ}
     if FPrinting then begin
       OffsetXX:=OffsetX;
       OffsetYY:=OffsetY;
     end else begin
       OffsetXX:=0;
       OffsetYY:=0;
     end;

     {枠の部分}
     Port:=False;
     if FPrinterFlag then begin
       if FplSetPrinter.Orientation=poPortrait then Port:=True;
     end else begin
       Port:=True;
     end;
     {印刷方向が縦}
     if Port then begin
       ZWidth  :=60;
       ZHeight :=85;
       BaseX   :=FViewWidth-552+OffsetXX;
       BaseY   :=120+OffsetYY+DispOffsetY;
       if not(FPrinting) or (PrtOut) then begin
         X :=BaseX;
         Y :=BaseY;
         for i:=1 to 3 do begin
           RectLine(X,X+ZWidth,Y,Y+ZHeight);
           X:=X+ZLen;
         end;
         Line(X-10,X+4,BaseY+40,BaseY+40);
         PenWidth(2);
         X:=BaseX+Dis;
         for i:=1 to 4 do begin
           RectLine(X,X+ZWidth,Y,Y+ZHeight);
           X:=X+ZLen;
         end;
       end;
     {印刷方向が横}
     end else begin
       ZWidth  :=85;
       ZHeight :=60;
       BaseX   :=FViewWidth-120-ZWidth+OffsetXX+DispOffsetY;
       BaseY   :=FViewHeight-552+OffsetYY;
       if not(FPrinting) or (PrtOut) then begin
         X :=BaseX;
         Y :=BaseY;
         for i:=1 to 3 do begin
           RectLine(X,X+ZWidth,Y,Y+ZHeight);
           Y:=Y+ZLen;
         end;
         Line(X+40,X+40,Y-10,Y+5);
         PenWidth(2);
         Y:=BaseY+Dis;
         for i:=1 to 4 do begin
           RectLine(X,X+ZWidth,Y,Y+ZHeight);
           Y:=Y+ZLen;
         end;
       end;
     end;

     {番号の部分}
     FontW:=FCanvas.TextWidth('0');  {描画位置調整用}
     FontH:=FCanvas.TextHeight('0'); {描画位置調整用}
     SZip :=ToHankaku(Zip);
     {印刷方向が縦}
     if Port then begin
       S0:='';
       for i:=0 to Length(SZip)-1 do begin
         S:=Copy(SZip,i+1,1);
         if (S>='0') and (S<='9') then S0:=S0+S;
       end;
       S1:=Copy(S0,1,3);
       Insert(Copy(S0,4,Length(S0)-3),S2,1);
       X:=BaseX;
       Y:=BaseY;
       for i:=1 to 3 do begin
         TextRectCC(X,X+ZWidth,Y,Y+ZHeight,Copy(S1,i,1));
         X:=X+ZLen;
       end;
       X:=BaseX+Dis;
       for i:=1 to 4 do begin
         TextRectCC(X,X+ZWidth,Y,Y+ZHeight,Copy(S2,i,1));
         X:=X+ZLen;
       end;
     {印刷方向が横}
     end else begin
       OffX:=Trunc(ZWidth/2+FontH/2);
       OffY:=Trunc(ZHeight/2-FontW/2);
       S0:='';
       for i:=0 to Length(SZip)-1 do begin
         S:=Copy(SZip,i+1,1);
         if (S>='0') and (S<='9') then S0:=S0+S;
       end;
       S1:=Copy(S0,1,3);
       Insert(Copy(S0,4,Length(S0)-3),S2,1);
       X:=BaseX+OffX+3;
       Y:=BaseY+OffY;
       for i:=1 to 3 do begin
         TextSpecial(X,Y,270,100,Copy(S1,i,1));
         Y:=Y+ZLen;
       end;
       Y:=BaseY+Dis+OffY;
       for i:=1 to 4 do begin
         TextSpecial(X,Y,270,100,Copy(S2,i,1));
         Y:=Y+ZLen;
       end;
     end;
end;
//====================================================================
//   郵便番号枠と郵便番号の描画  定型外郵便物の場合
//   印刷方向が縦の場合は右上に,横の場合は右下に印刷　　　
//   文字列Zipに含まれる数文字以外は除去してから印刷
//   文字列はこのコンポのフォント関係メソッドの使用が前提
//
//   Zip         郵便番号(-などの記号があってもこのメソッド内で除去)
//   PrtOut      郵便番号枠を印刷するかしないかのフラグ
//   OffsetX     文字印刷調整.横方向.
//   OffsetY     文字印刷調整.縦方向.
//   DispOffsetY プレビューの表示位置調整.縦方向.+で下方にプレビュー
//               印刷方向が縦の場合(折曲げが画面上の時)のみ有効
//   DispOffsetYは2002.6.20追加
//   DispOffsetYの機能を印刷方向が横の場合もサポート(Ver3.1)
//====================================================================
procedure TCustomplPrev.ZipOutEx(Zip: String; OffsetX,OffsetY:Integer;
PrtOut: Boolean;DispOffsetY:Integer=0);
var
     i: Integer;
     ZWidth  : Integer; {番号枠の幅}
     ZHeight : Integer; {番号枠の高さ}
     ZLen    : Integer; {番号枠の距離}
     BaseX   : Integer; {枠の左端のX}
     BaseY   : Integer; {上端の上端のY}
     Dis     : Integer; {4桁目の開始位置}
     X,Y     : Integer;
     SZip    : String;
     S0,S,S1,S2 : String;
     FontW,FontH: Integer;
     OffX,OffY  : Integer;
     OffsetXX,OffsetYY : Integer;
     Port : Boolean;
begin
     ZLen    :=120;
     Dis     :=370;
     if PrtOut then PenColor(clRed) else PenColor($00AAAAFF);
     PenStyle(psSolid);
     PenWidth(7);
     {印刷位置を調整するのはプリンタ出力の場合のみ}
     if FPrinting then begin
       OffsetXX:=OffsetX;
       OffsetYY:=OffsetY;
     end else begin
       OffsetXX:=0;
       OffsetYY:=0;
     end;

     {枠の部分}
     Port:=False;
     if FPrinterFlag then begin
       if FplSetPrinter.Orientation=poPortrait then Port:=True;
     end else begin
       Port:=True;
     end;
     {印刷方向が縦}
     if Port then begin
       ZWidth  :=105;
       ZHeight :=138;
       BaseX   :=FViewWidth-1007+OffsetXX;
       BaseY   :=185+OffsetYY+DispOffsetY;
       if not(FPrinting) or (PrtOut) then begin
         X :=BaseX;
         Y :=BaseY;
         for i:=1 to 3 do begin
           RectLine(X,X+ZWidth,Y,Y+ZHeight);
           X:=X+ZLen;
         end;
         Line(X-15,X+8,BaseY+65,BaseY+65);
         PenWidth(3);
         X:=BaseX+Dis;
         for i:=1 to 4 do begin
           RectLine(X,X+ZWidth,Y,Y+ZHeight);
           X:=X+ZLen;
         end;
       end;
     {印刷方向が横}
     end else begin
       ZWidth  :=138;
       ZHeight :=105;
       BaseX   :=FViewWidth-185-ZWidth+OffsetXX+DispOffsetY;
       BaseY   :=FViewHeight-1007+OffsetYY;
       if not(FPrinting) or (PrtOut) then begin
         X :=BaseX;
         Y :=BaseY;
         for i:=1 to 3 do begin
           RectLine(X,X+ZWidth,Y,Y+ZHeight);
           Y:=Y+ZLen;
         end;
         Line(X+65,X+65,Y-15,Y+7);
         PenWidth(3);
         Y:=BaseY+Dis;
         for i:=1 to 4 do begin
           RectLine(X,X+ZWidth,Y,Y+ZHeight);
           Y:=Y+ZLen;
         end;
       end;
     end;

     {番号の部分}
     FontW:=FCanvas.TextWidth('0');  {描画位置調整用}
     FontH:=FCanvas.TextHeight('0'); {描画位置調整用}
     SZip :=ToHankaku(Zip);
     {印刷方向が縦}
     if Port then begin
       S0:='';
       for i:=0 to Length(SZip)-1 do begin
         S:=Copy(SZip,i+1,1);
         if (S>='0') and (S<='9') then S0:=S0+S;
       end;
       S1:=Copy(S0,1,3);
       Insert(Copy(S0,4,Length(S0)-3),S2,1);
       X:=BaseX;
       Y:=BaseY+2;
       for i:=1 to 3 do begin
         TextRectCC(X,X+ZWidth,Y,Y+ZHeight,Copy(S1,i,1));
         X:=X+ZLen;
       end;
       X:=BaseX+Dis;
       for i:=1 to 4 do begin
         TextRectCC(X,X+ZWidth,Y,Y+ZHeight,Copy(S2,i,1));
         X:=X+ZLen;
       end;
     {印刷方向が横}
     end else begin
       OffX:=Trunc(ZWidth/2+FontH/2);
       OffY:=Trunc(ZHeight/2-FontW/2);
       S0:='';
       for i:=0 to Length(SZip)-1 do begin
         S:=Copy(SZip,i+1,1);
         if (S>='0') and (S<='9') then S0:=S0+S;
       end;
       S1:=Copy(S0,1,3);
       Insert(Copy(S0,4,Length(S0)-3),S2,1);
       X:=BaseX+OffX+3;
       Y:=BaseY+OffY;
       for i:=1 to 3 do begin
         TextSpecial(X,Y,270,100,Copy(S1,i,1));
         Y:=Y+ZLen;
       end;
       Y:=BaseY+Dis+OffY;
       for i:=1 to 4 do begin
         TextSpecial(X,Y,270,100,Copy(S2,i,1));
         Y:=Y+ZLen;
       end;
     end;
end;
//====================================================================
//   ディスクからテキストファイルを読込んで描画
//   DHGLのルーチンを変更して利用
//   両端揃えで描画．禁則処理は2文字固定.次頁送りの処理はなし.
//   戻値
//   1行も描画しなかった場合はYt
//   それ以外は次の行の開始Y座標値
//
//   Yt       描画開始Y座標
//   Xl       描画範囲の左端X座標値
//   Xr       描画範囲の右端X座標値
//   RowH     行間隔
//   FileName テキストファイル名
//===================================================================
function TCustomplPrev.TextOutFile(Yt,Xl,Xr,RowH: Integer; FileName: String): Integer;
var
     SL: TStringList;
     Options: TFormatOptions;
     Yb: Integer;
begin
     {テキストを保持するStringList作成}
     SL:=TStringList.Create;
     Options:=[foJustify];
     try
       {StringListにテキストを読込む}
       SL.LoadFromFile(FileName);
       if SL.Count>0 then begin
         Yb:=FPaperHeight-FBottomMargin;
         Result:=StringListOut(SL,Options,Xl,Xr,Yt,Yb,RowH,2);
       end else begin
         Result:=Yt;
       end;
     finally
       SL.Free;
     end;
end;
//====================================================================
//   StringListのテキストを印刷するルーチン
//   DHGLのルーチンを利用
//   次頁以降に印刷が必要な場合はSLの残りを判断してこのルーチン外で
//   行う．ルーチン内で改頁処理を行ってしまうと先読み方式専用となっ
//   てしまう．
//
//   戻値
//   1行も描画しなかった場合はYt
//   それ以外は次の行の開始Y座標値
//
//   var SL     テキストを収めたStringList
//              全てのテキストの印刷が終了しなかった時は残りのテキスト
//              を返す．1行分(改行)での未処理分がインデックス[0]に入っ
//              ている．全ての出力が終了していれば，このルーチンを抜け
//              た後のSL.Countの値が0となっている．
//   Options    DHGLのTextUtlis内のGetTextPositionのOptions引数
//              foJustify   両端揃え
//              foEven      均等割付
//              foRight     右端揃え
//              foCenter    中央揃え(右端揃えより優先)
//              foKerning   カーニングを行う
//   Yt         描画開始Y座標
//   Xl         描画範囲の左端X座標値
//   Xr         描画範囲の右端X座標値
//   RowH       行間隔
//   KinsokuCnt 禁則処理文字数.0の時は禁則処理なし.
//              デフォルトは2.
//===================================================================
function TCustomplPrev.StringListOut(var SL: TStringList; Options: TFormatOptions;
     Xl,Xr,Yt,Yb, RowH: Integer; KinsokuCnt:Integer=2): Integer;
var
     ATopMargin   : Integer;   {印刷開始上端位置(ドット)}
     LineNumber   : Integer;   {行番号}
     WrittenLines : Integer;   {既に描画した行数}
     WS, RestWs   : WideString;{1行分のテキスト(改行ままでの)}
     FontHeight   : Double;    {Font Size(Twips)}
     APrintWidth  : Double;    {印字幅(Twips)}
     APrintHeight : Integer;   {印字高(Pixels)}
     Offset       : Integer;   {印字開始オフセット}
     FittedChars  : Integer;   {印刷する文字数}
     DXs          : TDxArray;  {文字位置配列.TDxArrayはTetUtlisで定義}
     KinsokuStr   : WideString;{検出した禁則文字列}
     AddKinLen    : Integer;   {ぶら下げる追加の禁則文字数}
     i,dx         : Integer;   {文字間隔調整用の数値(ドット)}
     Amaridots    : Integer;   {同上.各文字間に均等に振分けて残ったドット数}
     Widthdots    : Integer;   {禁則文字列の長さ(ドット)}
begin
     if SL.Count=0 then begin
       Result:=Yt;
       exit;
     end;

     {フォント高さと描画域を計算}
     ATopMargin  := Yt;
     FontHeight  := FCanvas.Font.Height*1440/FXResolution;
     APrintHeight:= Abs(Yb-Yt);
     APrintWidth := Abs(Xr-Xl)*1440/FXResolution;

     {印刷前は印刷済み行数は0}
     WrittenLines := 0;

     {StringList(SL)のテキストの出力開始}
     for LineNumber:=0 to SL.Count-1 do begin
       {1行分(改行まで)の文字列を取出す}
       WS := SL[0];
       {文字列の長さが0の場合}
       if Length(WS)=0 then  begin
         {空白行の場合}
         if (RowH*WrittenLines)<=APrintHeight then begin
           Inc(WrittenLines);
         end else begin
           break;
         end;
       {文字列の長さが0でない場合}
       end else begin
         {1行分の文字列の長さが0になるまで繰り返す}
         while Length(WS) > 0 do begin
           if (RowH * WrittenLines)<=APrintHeight then begin
             RestWS:=GetTextPosition(
                   WS,FontHeight,FCanvas.Font.Handle,APrintWidth,
                   FXResolution,Options,Offset,FittedChars,DXs);

             {禁則処理はなしと仮定}
             Widthdots :=0;
             {行末処理(追出し文字)があればその文字列を次に印刷する文字列の}
             {先頭に加える.今回印刷する文字列は禁則文字数分少なくする}
             {KinsokuStrが追出しする文字列}
             KinsokuStr:=GetOidashiStr(WS,FittedChars,KinsokuCnt);
             AddKinLen:=0;

             if KinsokuStr<>'' then begin
               {追出しする文字列を先頭に付けた文字列が次に印刷する文字列}
               RestWS:=KinsokuStr+RestWS;
               {印刷の際に余るドット数がWidthdots}
               Widthdots:=FCanvas.TextWidth(KinsokuStr);
             end else begin;
               {行末の禁則処理文字列がなければ次の行の先頭禁則文字列を調査して}
               {検出した禁則文字列を,今回印刷する文字列の後ろに追加する}
               {実際には印刷する文字列数FittedCharsを変更すればよい}
               KinsokuStr:=GetBurasageStr(RestWS,FittedChars,KinsokuCnt);
               AddKinLen:=Length(KinsokuStr);
               if AddKinLen>0 then begin
                 {禁則文字列を削除した文字列が次に印刷する文字列}
                 Delete(RestWS,1,AddKinLen);
                 {印刷の際に不足するドット数Widthdots}
                 Widthdots:=-FCanvas.TextWidth(KinsokuStr);
                 SetLength(DXs, FittedChars);

                 {追加文字の文字間隔を設定}
                 if AddKinLen>1 then begin
                   for i:=AddKinLen downto 2 do begin
                     DXs[High(DXs)-i+1]:=Abs(Widthdots div (AddKinLen));
                   end;
                 end;
               end;
             end;

             {禁則文字分のドット(ピクセル)の処理}
             if (FittedChars>1) and (Widthdots<>0) then begin
               {各文字間隔に振り分ける分がdx}
               dx:=Widthdots div (FittedChars-1-AddKinLen);
               Amaridots:=Widthdots mod (FittedChars-1-AddKinLen);
               {このドットをDXsに振り分ける}
               for i:=Low(DXs) to High(DXs)-AddKinLen-1 do DXs[i]:=DXs[i]+dx;
               {余った分は先頭の文字列から1ドットづつ振分ける}
               for i:=Low(DXs) to High(DXs)-AddKinLen-1 do begin
                 if Widthdots>0 then begin
                   inc(DXs[i]);
                   Dec(Amaridots);
                 end else begin
                   Dec(DXs[i]);
                   inc(Amaridots);
                 end;
                if Amaridots=0 then break;
               end;
             end;

             SetBkMode(FCanvas.Handle,TRANSPARENT);
             DHGLExtTextOutW(
                   FCanvas.Handle,Xl+Offset,
                   ATopMargin+WrittenLines*RowH,0,nil,
                   PWideChar(WS),FittedChars,PInteger(DXs));
             Inc(WrittenLines);
             WS := RestWS;
           {1行分の出力が終了しないで下端の印刷位置を越えた場合}
           end else begin
             SL[0]:=WS;
             exit;
           end;
         end;
       end;
       SL.Delete(0);
     end;
     Result:=ATopMargin+WrittenLines*RowH;
end;
//====================================================================
//   行末禁則処理
//   文字列Sの後ろに禁則処理文字(文字列配列OidashiStr内の文字)があれば
//   その(追出し)文字列を返す関数.
//
//   S      検査する文字列
//   EndPos 検査する文字列の長さ.印刷すべき文字列の長さを返す.
//          (元の長さか少なくなる)
//   Count  検査する禁則文字の数.返す文字列の数の最大値.
//====================================================================
function TCustomplPrev.GetOidashiStr(S: WideString; var EndPos:Integer;
   Count: Integer): WideString;
var
     SubStr: WideString;
     pPos,i: Integer;
     Flag  : Boolean;
begin
     Result:='';
     if S='' then exit;
     if Count=0 then exit;
     pPos  :=EndPos;
     while True do begin
       {検査対象文字を取出す.最初は最後の文字}
       SubStr:=S[pPos];
       Flag  :=False;
       {禁則文字が入った文字列配列の要素分検査する}
       for i:=Low(OidashiStr) to High(OidashiStr) do begin
         if (OidashiStr[i]=SubStr) then begin
           {結果は追出し文字列}
           Result:=Result+SubStr;
           Flag  :=True;
           break;
         end;
       end;
       {禁則文字が検出されなければ終了}
       if Flag=False then break;
       {禁則文字があれば1つ前の文字も調べる}
       Dec(pPos);
       Dec(Count);
       if Count=0 then break;
     end;
     EndPos:=EndPos-Length(Result);
end;
//====================================================================
//   行頭禁則処理
//   文字列Sの先頭に禁則処理文字(文字列配列BurasageStr内の文字)があれば
//   その(前の文字列の後ろに追加するぶら下げ)文字列を返す関数.
//
//   S      検査する文字列
//   EndPos 検査する文字列の長さ.印刷すべき文字列の長さを返す.
//          (元の長さか長くなる)
//   Count  検査する禁則文字の数.返す文字列の数の最大値.
//====================================================================
function TCustomplPrev.GetBurasageStr(S: WideString; var EndPos: Integer;
     Count: Integer): WideString;
var
     SubStr : WideString;
     pPos,i : Integer;
     Flag   : Boolean;
begin
     Result:='';
     if S='' then exit;
     if Count=0 then exit;
     pPos  :=1;
     while True do begin
       {検査対象文字を取出す.最初は先頭文字}
       SubStr:=S[pPos];
       Flag  :=False;
       {禁則文字が入った文字列配列の要素分検査する}
       for i:=Low(BurasageStr) to High(BurasageStr) do begin
         if (BurasageStr[i]=SubStr) then begin
           {結果は前行にぶら下げる文字列}
           Result:=Result+SubStr;
           Flag  :=True;
           break;
         end;
       end;
       {禁則文字が検出されなければ終了}
       if Flag=False then break;
       {禁則文字があれば次の文字も調べる}
       inc(pPos);
       Dec(Count);
       if Count=0 then break;
     end;
     EndPos:=EndPos+Length(Result);
end;
//====================================================================
//   文字列の均等割付描画
//
//   座標(X1,Y1),(X2,Y2)で決まる四角形の中に描画する．
//   四角形は描画しない．固定ピッチフォントで全角のみ対応．
//   X座標に均等に割付けて描画するが,入りきらないときは文字の幅を調
//   整して均等割付けする．
//   文字間隔の計算誤差(丸め誤差)のため，描画にも多少誤差が発生する．
//====================================================================
procedure TCustomplPrev.TextRectJust(X1,X2,Y1,Y2:Integer;Text:String);
var
   LogFont   : TLogFont;
   NewFont   : HFont;
   OldFont   : HFont;
   TM        : TTextMetric;
   WText     : WideString;
   WLen      : Integer;
   AWidth    : Integer;
   dx        : Integer;
   Amaridots : Integer;
   Size      : TSize;
   V         : Integer;
   CAdjust   : Integer;
   AAdjust   : Integer;
   XPos      : Integer;
   YPos      : Integer;
   i         : Integer;
begin
     {WideStringでないと全角半角混じり文字列がうまく行かない}
     WText:=Text;
     WLen  :=Length(WText); {文字数}

     {1文字だけの時はTextRectCCを採用}
     if WLen<=1 then begin
       TextRectCC(X1,X2,Y1,Y2,Text);
       exit;
     end;

     V:=100;
     Size:=FCanvas.TextExtent(Text);
     {描画開始Y座標値}
     YPos:=RoundOff(ABS(Y2+Y1)/2.0-Size.Cy/2.0);
     {文字列がX座標の範囲に収まらなければ幅を狭くする}
     if ABS(X2-X1)<(Round(Size.Cx*0.85)) then begin
       V:=RoundOff(ABS(X2-X1)/Size.Cx*100);
     end;
     {現在選択されているフォントのメトリックを指定されたバッファに格納}
     GetTextMetrics(FCanvas.Handle,TM);
     {フォント情報を現在使用中のFontから取得}
     GetObject(FCanvas.Font.Handle,Sizeof(TLOGFONT),@LogFont);
     {TLogFont構造体の一部を変更}
     with LogFont do begin
       lfHeight :=FCanvas.Font.Height;
       lfWidth  :=RoundOff(TM.tmAveCharWidth*V/100.0);
       lfQuality:=ANTIALIASED_QUALITY;
     end;
     {変更したフォント情報を用いて,新しいフォントハンドルを作成}
     NewFont:=CreateFontIndirect(LogFont);
     {新しいフォントハンドルをデバイスコンテキストに選択し}
     {それまで選択されていたフォントハンドルを保存}
     OldFont:=SelectObject(FCanvas.Handle,NewFont);

     {文字幅をベアリングを考慮して計算}
     {X1を右端にX2を右端に直す}
     AAdjust:=GetTextAAdjust(FCanvas,WText);
     CAdjust:=GetTextCAdjust(FCanvas,WText);
     if X1<X2 then begin
       X1:=X1+AAdjust;
       X2:=X2-CAdjust;
     end else begin
       X1:=X2+AAdjust;
       X2:=X1-CAdjust;
     end;
     AWidth :=Abs(X1-X2);

     {文字間ドット数を計算}
     dx:=(AWidth-FCanvas.TextWidth(WText)) div (WLen-1);
     Amaridots:=(AWidth-FCanvas.TextWidth(WText)) mod (WLen-1);
     {1文字づつ描画}
     XPos:=X1;
     try
       for i:=1 to WLen do begin
         SetBkMode(FCanvas.Handle,TRANSPARENT);
         FCanvas.TextOut(XPos,YPos,Copy(WText,i,1));
         XPos:=XPos+FCanvas.TextWidth(Copy(WText,i,1))+dx;
         if Amaridots>0 then begin
           Inc(XPos);
           Dec(Amaridots);
         end else if Amaridots<0 then begin
           Dec(XPos);
           Inc(Amaridots);
         end;
       end;
     finally
       {元のフォントハンドルを選択し戻す}
       SelectObject(FCanvas.Handle,OldFont);
       {作成したフォントハンドルを削除}
       DeleteObject(NewFont);
     end;
end;
//====================================================================
//   文字列の縦書き均等割付描画
//
//   座標(X1,Y1),(X2,Y2)で決まる四角形の中に縦書きで描画する．
//   四角形は描画しない．Y座標に均等に割付けて描画するが,入りきらな
//   いときは文字の高さを調整して均等割付けする．フォント名に縦書き
//   用を指定する必要はない．固定ピッチフォントで全角のみ対応．
//
//   備考
//   当初 Insert(Char(TM.tmBreakChar,Ws,....);
//        SetTextJustFication(.....);
//   等を使用したが，Printer.Canvasへの直接出力でWindowsNT/2000で期
//   待通りの結果が出なかったためこのコードに変更した(Windows98では
//   期待通りの動作をする)
//   文字間隔の計算誤差(丸め誤差)のため，描画にも多少誤差が発生する．
//====================================================================
procedure TCustomplPrev.TextRectJustTate(X1,X2,Y1,Y2:Integer;Text:String);
var
   LogFont   : TLogFont;
   NewFont   : HFont;
   OldFont   : HFont;
   TM        : TTextMetric;
   WText     : WideString;
   WLen      : Integer;
   AWidth    : Integer;
   dy        : Integer;
   Amaridots : Integer;
   Size      : TSize;
   V         : Integer;
   XPos      : Integer;
   YPos      : Integer;
   i         : Integer;
begin
     {WideStringでないと全角半角混じり文字列がうまく行かない}
     WText:=Text;
     WLen  :=Length(WText); {文字数}

     {1文字だけの時はTextRectCCを採用}
     if WLen<=1 then begin
       TextRectCC(X1,X2,Y1,Y2,Text);
       exit;
     end;

     V:=100;
     Size:=FCanvas.TextExtent(Text);
     {描画開始Y座標値}
     XPos:=RoundOff(ABS(X2+X1)/2.0+Size.Cy/2.0);
     {文字列がY座標の範囲に収まらなければ高さを低くする}
     if (ABS(Y2-Y1)-Round(Size.Cx*0.85))<0 then begin
       V:=Ceil(ABS(Y2-Y1)/Size.Cx*100);
     end;

     {現在選択されているフォントのメトリックを指定されたバッファに格納}
     GetTextMetrics(FCanvas.Handle,TM);
     {フォント情報を現在使用中のFontから取得}
     GetObject(FCanvas.Font.Handle,Sizeof(TLOGFONT),@LogFont);
     {TLogFont構造体の一部を変更}
     with LogFont do begin
       lfHeight     :=FCanvas.Font.Height;
       lfWidth      :=RoundOff(TM.tmAveCharWidth*V/100.0);
       lfQuality    :=ANTIALIASED_QUALITY;
       lfEscapement :=2700;
       StrPCopy(lfFaceName,'@'+FCanvas.Font.Name);
     end;
     {変更したフォント情報を用いて,新しいフォントハンドルを作成}
     NewFont:=CreateFontIndirect(LogFont);
     {新しいフォントハンドルをデバイスコンテキストに選択し}
     {それまで選択されていたフォントハンドルを保存}
     OldFont:=SelectObject(FCanvas.Handle,NewFont);

     AWidth :=Abs(Y1-Y2);
     {文字間ドット数を計算}
     dy:=(AWidth-FCanvas.TextWidth(WText)) div (WLen-1);
     Amaridots:=(AWidth-FCanvas.TextWidth(WText)) mod (WLen-1);
     {1文字づつ描画}
     YPos:=Y1;
     try
       for i:=1 to WLen do begin
         SetBkMode(FCanvas.Handle,TRANSPARENT);
         FCanvas.TextOut(XPos,YPos,Copy(WText,i,1));
         YPos:=YPos+FCanvas.TextWidth(Copy(WText,i,1))+dy;
         if Amaridots>0 then begin
           Inc(YPos);
           Dec(Amaridots);
         end else if Amaridots<0 then begin
           Dec(YPos);
           Inc(Amaridots);
         end;
       end;
     finally
       {元のフォントハンドルを選択し戻す}
       SelectObject(FCanvas.Handle,OldFont);
       {作成したフォントハンドルを削除}
       DeleteObject(NewFont);
     end;
end;
//====================================================================
//   指定文字数の文字列を等分割描画
//
//   座標(X1,Y1),(X2,Y2)で決まる四角形内にCnt等分して描画する．
//   帳票類の金額欄や郵便番号など，枠が指定されている場合に使用する．
//
//   X1  四角形の右端のX座標
//   X2  四角形の左端のX座標
//   Y1  四角形の上端のY座標
//   Y2  四角形の下端のY座標
//   Cnt 四角形内の枠の数
//   Text 描画する文字列．数値は文字列に変換して渡す
//   Length(Text)>Cntの場合は右側にはみだし描画する
//====================================================================
procedure TCustomplPrev.TextRectFit(X1,X2,Y1,Y2,Cnt:Integer;Text:String);
var
   X,Xl,Xs,Y,i,j :Integer;
begin
     {１桁分はXs}
     Xs:=Round(ABS(X2-X1)/Cnt);
     {先頭からの空白欄の数}
     j:=Cnt-Length(Text);
     if j<0 then j:=0;
     {描画開始X座標}
     Xl:=X1+RoundOff(Xs/2.0);
     {Y座標}
     Y:=RoundOff((Y1+Y2)/2.0);
     for i:=1 to Length(Text) do begin
       X:=Xl+(j+i-1)*Xs;
       TextOutCC(X,Y,Copy(Text,i,1));
     end;
end;
//====================================================================
//   方向と幅を指定した文字列
//
//   ワープロ専用機のような2倍角などの文字列の描画も可能
//   X    文字列の出力X座標(通常の水平位置R=0のとき左上のX座標)
//   Y    文字列の出力Y座標(通常の水平位置R=0のとき左上のY座標)
//   R    1度単位の回転角度.反時計方向が正.270だと縦書き
//   V    文字の幅(水平位置R=0の時)
//   Text 描画する文字列
//====================================================================
procedure TCustomplPrev.TextSpecial(X,Y,R:Integer;V:Integer;Text:String);
var
   LogFont: TLogFont;
   TM     : TTextMetric;
   NewFont: HFont;
   OldFont: HFont;
begin
     {現在選択されているフォントのメトリックを指定されたバッファに格納}
     GetTextMetrics(FCanvas.Handle,TM);
     {フォント情報を現在使用中のFontから取得}
     GetObject(FCanvas.Font.Handle,Sizeof(TLOGFONT),@LogFont);
     {TLogFont構造体の一部を変更}
     with LogFont do begin
       lfHeight    := FCanvas.Font.Height;
       lfWidth     := RoundOff(TM.tmAveCharWidth*V/100.0);
       lfEscapement:= R*10;
       lfQuality   := ANTIALIASED_QUALITY;
     end;

     {変更したフォント情報を用いて,新しいフォントハンドルを作成}
     NewFont:=CreateFontIndirect(LogFont);
     {新しいフォントハンドルをデバイスコンテキストに選択し}
     {それまで選択されていたフォントハンドルを保存}
     OldFont:=SelectObject(FCanvas.Handle,NewFont);
     try
       FCanvas.Brush.Style:=bsClear;
       FCanvas.TextOut(X,Y,Text);
     finally
       {元のフォントハンドルを選択し戻す}
       SelectObject(FCanvas.Handle,OldFont);
       {作成したフォントハンドルを削除}
       DeleteObject(NewFont);
     end;
end;
//====================================================================
//   ディスク内の画像ファイルをFCanvasに読込んで描画
//   EXE内に埋め込んだ画像にはStretchDrawBitmap,StretchDrawBitmapが使
//   用可能
//
//   画像を元のドット数のまま(縦横比も)でFCanvasに描画(Draw)する．
//   指定枠内に収めて描画するにはStretchDrawPictを使用する
//   扱えるのは拡張子がEMF,BMP,ICO,JPGの画像
//
//   X1       表示位置の左上X座標
//   Y1       表示位置の左上Y座標
//   FileName 描画する画像ファイル名
//   FDELPHI MES(16) 00013 凛さんの発言参照
//====================================================================
procedure TCustomplPrev.DrawPict(X1,Y1:Integer;FileName:string);
var
     plPict:TPicture;
     plJpeg:TJpegImage;
     FExt :String;
begin
     {ファイルの拡張子部分を取得}
     FExt :=UpperCase(ExtractFileExt(FileName));
     {一般のPictureとJpegの両方に対応するためにCreate}
     plPict:=TPicture.Create;
     plJpeg:=TJpegImage.Create;
     try
       {拡張子がJPGのときはDIBNeededでビットマップ変換}
       if FExt='.JPG' then begin
         plJPeg.LoadFromFile(FileName);
         plJpeg.DIBNeeded;
         plPict.Assign(plJpeg);
       end else begin
         plPict.LoadFromFile(Filename);
       end;
       Application.ProcessMessages;
       SetBkMode(FCanvas.Handle,TRANSPARENT);
       FCanvas.Draw(X1,Y1,plPict.Graphic);
       Application.ProcessMessages;
     finally
       {必要なくなったらFree}
       plPict.Free;
       plJpeg.Free;
     end;
end;
//====================================================================
//   ディスク内の画像ファイルをFCanvasに読込んで描画
//   EXE内に埋め込んだ画像にはStretchDrawBitmap,StretchDrawBitmapが使
//   用可能
//
//   画像を指定した枠内に収めてFCanvasに描画(StretchDraw)する．
//   元のドット数のまま描画するにはplDrawPictを使用する
//   扱えるのは拡張子がEMF,BMP,ICO,JPGの画像
//
//   X1       表示枠の左上X座標
//   X2       表示枠の右下X座標
//   Y1       表示枠の左上Y座標
//   Y2       表示枠の右下Y座標
//   IsFit    Trueのとき枠の大きさに縦横比を変えて描画
//            Falseのとき縦横比は変えず，縦横のどちらかの幅に合せて
//            拡大または縮小して描画
//   FileName 描画する画像ファイル名
//   FDELPHI MES(16) 00013 凛さんの発言参照
//====================================================================
procedure TCustomplPrev.StretchDrawPict(X1,X2,Y1,Y2:Integer;IsFit:Boolean;
                            FileName:string);
var
     plPict:TPicture;
     plJpeg:TJpegImage;
     FExt: String;
     Ratio1,Ratio2: extended;
     Xl,Xr,Yt,Yb,Xw,Yw: Integer;
begin
     {ファイルの拡張子部分を取得}
     FExt:=UpperCase(ExtractFileExt(FileName));
     {一般のPictureとJpegの両方に対応するためにCreate}
     plPict:=TPicture.Create;
     plJpeg:=TJpegImage.Create;
     try
       {拡張子がJPGのときはDIBNeededでビットマップ変換}
       Application.ProcessMessages;
       if FExt='.JPG' then begin
         plJPeg.LoadFromFile(FileName);
         plJpeg.DIBNeeded;
         plPict.Assign(plJpeg);
       end else begin
         plPict.LoadFromFile(FileName);
       end;
       Application.ProcessMessages;
       {枠に合わせて変形する場合は枠の座標がそのまま画像の大きさ}
       if IsFit=True then begin
         Xl:=X1;
         Yt:=Y1;
         Xr:=X2;
         Yb:=Y2;
       end else begin
         {Ratio1 枠の縦横比}
         {Ratio2 画像の縦横比}
         Ratio1:=ABS((Y2-Y1)/(X2-X1));
         Ratio2:=plPict.Height/plPict.Width;
         {枠の縦横比の方が大きい場合は横の幅に合せて表示}
         if Ratio1>Ratio2 then begin
           Xl:=X1;
           Xr:=X2;
           Yw:=RoundOff(ABS(X2-X1)/Ratio2);
           Yt:=Ceil((Y1+Y2)/2.0-Yw/2.0);
           Yb:=Yt+Yw;
         {画像の縦横比の方が大きい場合は縦の長さに合せて表示}
         end else begin
           Xw:=RoundOff(ABS(Y2-Y1)/Ratio2);
           Xl:=Ceil((X1+X2)/2.0-Xw/2.0);
           Xr:=Xl+Xw;
           Yt:=Y1;
           Yb:=Y2;
         end;
       end;
       SetBkMode(FCanvas.Handle,TRANSPARENT);
       if (plPict.Graphic is TBitmap) then begin
         StretchDrawBitmap(Rect(Xl,Yt,Xr,Yb),plPict.Bitmap);
       end else if (plPict.Graphic is TMetaFile) then begin
         StretchDrawMetaFile(Rect(X1,Yt,Xr,Yb),plPict.Metafile);
       end else begin
         FCanvas.StretchDraw(Rect(Xl,Yt,Xr,Yb),plPict.Graphic);
       end;
       Application.ProcessMessages;
     finally
       {必要なくなったらFree}
       plPict.Free;
       plJPeg.Free;
     end;
end;
//====================================================================
//   StrectchDIBsを使用したビットマップの描画
//   印刷落ち対策
//   Pict  : TBitmap
//   ARect : 描画領域の矩形TRect構造体
//====================================================================
procedure TCustomplPrev.StretchDrawBitmap(ARect: TRect; Pict: TBitmap);
var
    InfoHeaderSize: DWord;
    ImageSize     : DWord;
    Info     : PBitmapInfo;
    Image    : Pointer;
    AHandle  : THandle;
begin
     if not (Pict is TBitmap) then exit;
     Info := nil;
     Image:= nil;
     try
       GetDIBSizes(TBitmap(Pict).Handle,InfoHeaderSize,ImageSize);
       GetMem(Info, InfoHeaderSize);
       GetMem(Image, ImageSize);
       GetDIB(TBitmap(Pict).Handle, TBitmap(Pict).Palette, Info^,
                 Image^);
       with ARect do begin
         {印刷ルーチンの中で使用するので必要なコード}
         if FPrinting then AHandle:=Printer.Canvas.Handle else AHandle:=FCanvas.Handle;
         StretchDIBits(AHandle,
                       Left, Top, Right - Left, Bottom - Top,
                       0, 0, Info^.bmiHeader.biWidth,Info^.bmiHeader.biHeight,
                       Image,Info^,DIB_RGB_COLORS,SRCCOPY);
       end;
     finally
       if Image <> nil then FreeMem(Image, ImageSize);
       if Info <> nil then FreeMem(Info, InfoHeaderSize);
     end;
end;
//====================================================================
//   メタファイルイメージの描画
//   Pict  : TMetaFile
//   ARect : 描画領域の矩形TRect構造体
//====================================================================
procedure TCustomplPrev.StretchDrawMetaFile(ARect: TRect; Pict: TMetaFile);
begin
     if not(Pict is TMetaFile) then exit;
     PlayEnhMetaFile(FCanvas.Handle,Pict.Handle,ARect);
end;


{ TplPrev }

//====================================================================
//  コンポーネント生成
//====================================================================
constructor TplPrev.Create(AOwner: TComponent);
begin
     inherited;
end;
//====================================================================
//  コンポーネントDestroy
//====================================================================
destructor TplPrev.Destroy;
begin
     inherited Destroy;
end;
//====================================================================
//   Showメソッド
//   派生コンポーネントではShowメソッドを使用できない方がいい場合もあ
//   るのでTCustomplPrevでprivateにしている．TplPrevではpublicに．
//====================================================================
procedure TplPrev.Show;
begin
     inherited;
end;
//====================================================================
//   ShowModalメソッド
//   派生コンポーネントではこのメソッドを使用できない方がいい場合もあ
//   るのでTCustomplPrevでprivateにしている．TplPrevではpublicに．
//====================================================================
procedure TplPrev.ShowModal;
begin
     inherited ShowModal;
end;
//====================================================================
//  BeginDocメソッド
//====================================================================
procedure TplPrev.BeginDoc;
begin
     inherited BeginDoc;
end;
//====================================================================
//  EndDocメソッド
//====================================================================
procedure TplPrev.EndDoc;
begin
     inherited EndDoc;
end;
//====================================================================
//  NewPageメソッド
//====================================================================
procedure TplPrev.NewPage;
begin
     inherited NewPage;
end;
//====================================================================
//  印刷メソッド
//====================================================================
procedure TplPrev.Print;
begin
    inherited Print;
end;
//====================================================================
//  コード終了
//====================================================================
end.

