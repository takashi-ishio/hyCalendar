{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$WARNINGS OFF}
//====================================================================
//    ����v���r���[����R���|�[�l���g  TplPrev
//
//    ���̈���v���r���[����R���|�[�l���g�́C����̃R�[�h��`�悷��
//    ���߂�Canvas�ƁC�����ɕ`�悵�����e���v���r���[���邽�߂́C�J�X
//    �^�}�C�Y�\�ȃt�H�[����񋟂�����̂ł��D�v���r���[��ʂŕő�
//    �葀����������s���܂��D
//
//
//  Ver 4.53-> 4.54�ύX�_
//
//  �EDelphi2005(Win32)�Ή��D
//  �E[���]�{�^���Ńv�����^��ύX�������Ɉ���ł��Ȃ��o�O���C���D
//  �EImageVisible�v���p�e�B�ǉ�
//    False�ɂ���ƃv���r���[�t�H�[���͕\�����邪�C�C���[�W�͔�\��
//    �f�t�H���g��True
//  �EImageDrag�v���p�e�B�ǉ�
//    �}�E�X�ɂ��C���[�W�̈ړ��̋��D�f�t�H���g��True
//  �EImageShade�v���p�e�B�ǉ�
//    �p���̉e�̕����̕`��̗L���D�f�t�H���g��True
//  �E�}�E�X�ɂ��C���[�W�̈ړ��͈͂�\���̈�S�̂Ƃ����D
//    �܂����̕����̃R�[�h���C���D
//  �E�v���r���[�t�H�[���̃{�^���\���L���̃R�[�h���C���D
//  �E�t�H�[����Create���Ƀv�����^�ݒ�R���|�̎����I���R�[�h���C��
//    (�����̃v�����^�ݒ�R���|���z�u���Ă���ꍇ�ɍŏ��̃v�����^��
//     ��R���|��I�����Ă��܂�)
//
//  Ver 4.54-> 4.55�ύX�_
//
//  �E�t�H�[������鎞�ɃC���[�W�̉摜���N���A����悤�ɂ����D
//    �N���A���Ȃ��ƁC�����t�H�[���ɕʂ̉摜��\�����鎞�ɑO�̉摜���\
//    ������Ă��܂��D
//
//
//                            2005.01.22  Ver.4.55 �@
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

  {�v���r���[�̕\���`��(�ŕ�,�őS�̂Ȃ�)}
  TplPrevZoomType=(ztWholePage,ztPageWidth,ztOther);

  {��Ǖ����������\��������}
  {�R�[�h��BeginDoc���g�p�����dtCont�ƂȂ�}
  {ProcName�v���p�e�B�ɏ����ނ�dtStat�ƂȂ�}
  TplPrevDrawType=(dtCont,dtStat,dtNone);

  {�e��{�^���\���̐ݒ�}
  TplPrevBtnOption=(boPrintBtn,      //[���]�{�^��
                boPrinterSetBtn, //[�v�����^�E�p��]�{�^��
                boFirstPageBtn,  //[�擪��]�{�^��
                boPriorPageBtn,  //[�O��]�{�^��
                boNextPageBtn,   //[����]�{�^��
                boLastPageBtn,   //[�ŏI��]�{�^��
                boZoomDownBtn,   //[�k��]�{�^��
                boZoomUpBtn,     //[�g��]�{�^��
                boPageWholeBtn,  //[�S��]�{�^��
                boPageWidthBtn,  //[�ŕ�]�{�^��
                boCloseBtn);     //[����]�{�^��
  {�g�p�\�ȃ{�^���ݒ�̏W��}
  TplPrevBtnOptions = set of TplPrevBtnOption;

  {�v���r���[Form�S�̂̕\���`��.Form.WindowStyle��FullScreen��t��}
  TplPrevFormWindowState=(fwNormal,fwMaximized,fwMinimized,fwWorkArea,fwFullScreen);

  {�����\�������̎��̌ďo���[�`����}
  TPrevProc=procedure of Object;

  {�C�x���g�֌W}
  TplPrevPageEvent    = procedure(Sender: TObject; Page: Integer) of object;
  TplPrintButtonEvent = procedure(Sender: TObject; var CanPrint: Boolean) of object;
  TStartDrawEvent     = procedure(Sender:TObject;var YPos:Integer) of object;
  THeaderDrawEvent    = procedure(Sender:TObject;Page:Integer;YPos:Integer) of object;

  TCustomplPrev = class(TComponent)
  private
    FplSetPrinter        : TplSetPrinter;        {�v�����^�ݒ�R���|�[�l���g}
    PaperLO              : Integer;              {�p���̈���\���[(�h�b�g)}
    PaperTO              : Integer;              {�p���̈���\��[(�h�b�g)}

    FDefaultResolution   : Integer;              {�v�����^���Ȃ����̉𑜓x(dpi)}
    FPrinterFlag         : Boolean;              {�v�����^�̗L��(�Ȃ�����False)}
    FBtnOptions          : TplPrevBtnOptions;    {�e��{�^���̕\������}
    FMetaImage           : TMetaFile;            {�P�ŕ��̃��^�t�@�C��}
    MetaImageList        : array of TMetaFile;   {�e�ł̃��^�t�@�C���C���[�W�i�[List}
    FCanvas              : TCanvas;              {�`��p�̃��^�t�@�C���L�����o�X}
    MetaW,MetaH          : Integer;              {�`��p���^�t�@�C���̕��ƒ���}
    fgDisplay            : Boolean;              {�`��҂��t���O}
    FFormDispFlag        : Boolean;              {FormName��FForm���L����}

    FAcrobatOut          : Boolean;              {Acrobat writer�ւ̏o��}
    FProcName            : TPrevProc;            {�����\���̕`�惋�[�`��}
    FCursor              : TCursor;              {�`��̑҂����Ԃɕ\������J�[�\�����}
    FTitle               : String;               {�t�H�[���ƈ���h�L�������g�̃^�C�g��}
    SaveCursor           : TCursor;              {�ۑ��J�[�\��}
    KeyBoardState        : TKeyBoardState;       {�L�[�{�[�h�̏�Ԃ̎擾�p.Acrobat�p}
    DefaultKeyState      : Byte;                 {�f�t�H���g�̃L�[��Ԃ̑ޔ�p.Acrobat�p}
    PrtCompStream        : TFileStream;          {��L�Ŏg�p����Stream}
    PrtCompReader        : TReader;              {�v�����^���̈ꎞ�ۑ��l�̓Ǐo��}
    PrtCompWriter        : TWriter;              {�v�����^���̈ꎞ�ۑ��̏�����}

    FAutoCreateForm      : Boolean;                {��������Form�Ȃ�True}
    FForm                : TForm;                  {�v���r���[�pForm}
    FFormName            : TComponentName;         {�v���r���[�pForm��}
    FFormParent          : TWinControl;            {�v���r���[Form��Parent}
    FFormLeft            : Integer;                {�v���r���[�t�H�[���̍��[}
    FFormTop             : Integer;                {�v���r���[�t�H�[���̏�[}
    FFormWidth           : Integer;                {�v���r���[�t�H�[���̕�}
    FFormHeight          : Integer;                {�v���r���[�t�H�[���̍���}
    FFormWindowState     : TplPrevFormWindowState; {Form��WindowState�v���p�e�B}
    FFormIcon            : TIcon;                  {Form�̃A�C�R��}
    FFormBorderIcons     : TBorderIcons;           {Form��BorderIcons}
    FFormBorderStyle     : TFormBorderStyle;       {Form��BorderStyle}
    FFormPosition        : TPosition;              {Form��Position}
    FFormCanMove         : Boolean;                {Form�̈ړ��\�L���̃t���O}
    FFormCanResize       : Boolean;                {Form�̃T�C�Y�ύX�L���̃t���O}
    FFormStatusBar       : Boolean;                {Form�̃X�e�[�^�X�o�[�\��}
    FStatusBarText       : String;                 {StatusBar�̃e�L�X�g������}
    FFormIconBar         : Boolean;                {Form�̃A�C�R���o�[}
    FFormColor           : TColor;                 {Form�̔w�i�F}
    FDrawType            : TplPrevDrawType;        {��ǂ݂������\��}
    FPaperColor          : TColor;                 {�A���p���̑䎆�̔w�i�F}
    FZoomtype            : TplPrevZoomType;        {��ʂւ̕\�������`��(�ŕ�,�őS�̂Ȃ�)}
    FplPaperWidth        : Integer;                {�p���̕����I�ȉ��h�b�g��}
    FplPaperHeight       : Integer;                {�p���̕����I�ȏc�h�b�g��}
    FplPageWidth         : Integer;                {�p���̈����(�ʏ̕ŕ�}
    FplPageHeight        : Integer;                {�p���̈������(�ʏ̕Œ���)}
    FDesignedPaperWidth  : Integer;                {�݌v���p���T�C�Y�����@}
    FDesignedPaperHeight : Integer;                {�݌v���p���T�C�Y�c���@}
    FXResolution         : Integer;                {�v�����^�̉������𑜓x}
    FYResolution         : Integer;                {�v�����^�̏c�����𑜓x}
    FPaperWidth          : Integer;                {0.1mm�P�ʂɊ��Z�����p����}
    FPageWidth           : Integer;                {0.1mm�P�ʂɊ��Z��������\��}
    FPageHeight          : Integer;                {0.1mm�P�ʂɊ��Z��������\����}
    FPaperHeight         : Integer;                {0.1mm�P�ʂɊ��Z�����p����}

    FTopOffset           : Integer;                {�p����[�I�t�Z�b�g(�h�b�g)}
    FBottomOffset        : Integer;                {�p�����[�I�t�Z�b�g(�h�b�g)}
    FLeftOffset          : Integer;                {�p�����[�I�t�Z�b�g(�h�b�g)}
    FRightOffset         : Integer;                {�p���E�[�I�t�Z�b�g(�h�b�g)}

    FPrintOffsetX        : Integer;                {������̍����I�t�Z�b�g�����p(0.1mm�P��)}
    FPrintOffsetY        : Integer;                {������̏㑤�I�t�Z�b�g�����p(0.1mm�P��)}

    FPrintFromPage       : Integer;                {����J�n�Ŕԍ�}
    FPrintToPage         : Integer;                {����I���Ŕԍ�}

    FPaperRatio          : Double;                 {�p���̏c:���̕����I�Ȕ�}
    FViewPaperRatio      : Double;                 {�v���r���[�̏c����}
    FViewWidth           : Integer;                {�v���r���[�̉���(0.1mm�P��)}
    FViewHeight          : Integer;                {�v���r���[�̏c��������(0,1mm�P��)}
    FViewClip            : Boolean;                {����\�͈͊O�̃v���r���[�L��}
    FPageCount           : Integer;                {����̑��Ő�}
    FPageNumber          : Integer;                {���݂̕Ŕԍ�}

    FImageDrag           : Boolean;                {�C���[�W�̃}�E�X�ɂ��ړ�}
    FImageVisible        : Boolean;                {�C���[�W�̕\��}
    FImageShade          : Boolean;                {�p���̉e�̕`��̗L��}

    {InversePrint��Ver3.4�œ���}
    FInversePrint        : Boolean;  {�t�������(180�x��]���)}

    ScaleMode            : Integer;  {WindowExtEx,ViewPortExtEx��mode}
    FPrinting            : Boolean;  {������̃t���O}
    PrintAbort           : Boolean;  {������~}

    {�e��C�x���g(OnClose��Ver4.0�Œǉ���OnFormClose�ɕύX}
    {OnResize��OnFormResize�ɕύX}
    {OnFormCreate�݂����̂͂Ȃ�(TplPrev������̃v���r���[�t�H�[���L�����s��)}
    FOnFormShow          : TNotifyEvent;        {�v���r���[�t�H�[����OnShow��}
    FOnFormClose         : TCloseEvent;         {�v���r���[�t�H�[�������鎞}
    FOnClose             : TNotifyEvent;        {����(�݊����̂���)}
    FOnFormCloseQuery    : TCloseQueryEvent;    {����}
    FOnFormDestroy       : TNotifyEvent;        {�v���r���[�t�H�[�����j������鎞}
    FOnResize            : TplPrevPageEvent;    {�C���[�W���T�C�Y����}
    FOnPrint             : TplPrevPageEvent;    {�ł�Printer.Canvas�o�͌�}
    FOnPrinterSetupDialog: TNotifyEvent;        {�v�����^�̐ݒ�_�C�A���O�I����}
    FOnPrintButtonClick  : TplPrintButtonEvent; {[���]�{�^�����N���b�N������}
    FOnBeforeView        : TplPrevPageEvent;    {�e�Ńv���r���[���O}
    FOnAfterView         : TplPrevPageEvent;    {�e�Ńv���r���[����}
    FOnNoPrintDraw       : TplPrevPageEvent;    {������Ȃ��R�[�h�����s(Clip�Ȃ�)}

    {OnHeader,OnFooter,OnReportStart,OnReportEnd�͔h���R���|�[�l���g�Ŏ�������}
    {�����̓��e�ɂ���Ă��̃C�x���g�̋L�q�ʒu��ς���K�v�����邽��}
    FOnHeader            : THeaderDrawEvent;    {�w�b�_��}
    FOnFooter            : THeaderDrawEvent;    {�t�b�^��}
    FOnReportStart       : TStartDrawEvent;     {�S�Ă̕`��̑O}
    FOnReportEnd         : THeaderDrawEvent;    {�S�Ă̕`��I����}


    {�㉺���E�̃}�[�W���ƃw�b�_�E�t�b�^�}�[�W��}
    FLeftMargin   : Integer;
    FTopMargin    : Integer;
    FRightMargin  : Integer;
    FBottomMargin : Integer;
    FHeaderMargin : Integer;
    FFooterMargin : Integer;

    {Ver4.3�Œǉ��D��p�v���r���[�t�H�[���ȊO�̃T�u�N���X��}
    {��p�̃v���r���[�t�H�[���ȊO��Form��Close�����o����ViewWidth,ViewHeight��0�ɂ��邽��}
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

    {Ver4.3�Œǉ��D��p�v���r���[�t�H�[���ȊO�̃T�u�N���X��}
    {��p�̃v���r���[�t�H�[���ȊO��Form��Close�����o����ViewWidth,ViewHeight��0�ɂ��邽��}
    procedure FFormSubClassProc(var Message:TMessage);
    procedure SetImageVisible(const Value: Boolean);

  protected
    PrtCompName : String; {�v�����^�ݒ�R���|�̑Ҕ�pFileStream��}
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

    {�݌v���p���T�C�Y�̎w��}
    procedure DesignedPaperSize(W,H:Integer);

    function Roundoff  (X: Double): Integer;
    {������ϊ��֐�}
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
S0='����v���r���[����R���|�[�l���g';
S3='�\�����̃t�H�[�������[�_���\���ŊJ�����Ƃ͂ł��܂���(����)�D�@�@';
S6='Canvas�ւ̕`��R�[�h��������܂���D�@�@';
S7='�v�����^���C���X�g�[������Ă��Ȃ��̂ň���ł��܂���D�@�@';

const
     {�s���֑�����(�s���ɂ�������O�̍s�ɂԂ牺����)}
     BurasageStr:array[1..14] of WideString=(
             ')',']','}','.',',','�',                        {���p6}
             '�j' ,'�n' ,'�p' ,'�D' ,'�C' ,'�v' ,'�B' ,'�A');{�S�p8}
     {�s���֑�����(�s���ɂ������玟�̍s�ɒǏo��)}
     OidashiStr:array[1..8] of WideString=(
             '(','[','{','�',       {���p4}
             '�i','�m','�o','�u');  {�S�p4}

  { TCustomplPrev }

//====================================================================
//   �R���|�[�l���g�̏�����
//====================================================================
constructor TCustomplPrev.Create(AOwner: TComponent);
begin
     inherited;
     FDefaultResolution   := 300;
     FPrinterFlag         := False;
     FAcrobatOut          := False;
     FDrawType            := dtNone;
     FTitle               := '����v���r���[[Mr.XRAY]';
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
//   Loaded�����D���ɂȂ��D�ł���̒ǉ��̂��߂ɏ����Ă������Ƃɂ���
//====================================================================
procedure TCustomplPrev.Loaded;
begin
     inherited Loaded;
end;
//====================================================================
//   �R���|�[�l���g�I������
//====================================================================
destructor TCustomplPrev.Destroy;
begin
     {Form�p�A�C�R���̉��}
     if FFormIcon<>nil then begin
       FFormIcon.Free;
       FFormIcon:=nil;
     end;
     {���^�t�@�C�����X�g�̉��}
     FreeImageList;
     {�v�����^�ݒ�R���|�[�l���g�ݒ�t�@�C���폜}
     try
       DeleteFile(PrtCompName);
     except
     end;
     inherited;
end;
//====================================================================
//   �v�����^�ݒ�R���|�[�l���g���폜���ꂽ���z�u���ꂽ�ꍇ�̏���
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
//   �҂����Ԃɕ\������J�[�\��
//====================================================================
procedure TCustomplPrev.SetCursor(const Value: TCursor);
begin
     if Value<>null then begin
       FCursor := Value;
     end;
end;
//====================================================================
//   �v���r���[Form�̃A�C�R��
//====================================================================
procedure TCustomplPrev.SetFormIcon(const Value: TIcon);
begin
     if Value<>nil then FFormIcon.Assign(Value);
     if Value=nil then FFormIcon:=nil;
end;
//====================================================================
//   ���Ő��̐ݒ�
//   �����\�������Ŏg�p.��Ǖ����ł͕`�惋�[�`���̍Ō�Ō��܂�
//====================================================================
procedure TCustomplPrev.SetPageCount(const Value: Integer);
begin
     if Value<=0 then exit;
     FPageCount  := Value;
end;
//====================================================================
//   �\��������ύX������\���̏c������Čv�Z
//====================================================================
procedure TCustomplPrev.SetViewHeight(const Value: Integer);
begin
     if Value>=0 then begin
       FViewHeight := Value;
       if FViewWidth>0 then FViewPaperRatio:=FViewHeight/FViewWidth;
     end;
end;
//====================================================================
//   �\������ύX������\���̏c������Čv�Z
//====================================================================
procedure TCustomplPrev.SetViewWidth(const Value: Integer);
begin
     if Value>=0 then begin
       FViewWidth := Value;
       if FViewWidth>0 then FViewPaperRatio:=FViewHeight/FViewWidth;
     end;
end;
//====================================================================
//   �`��pCanvas���O�����痘�p���邽�߂̃��\�b�h
//====================================================================
function TCustomplPrev.GetCanvas: TCanvas;
begin
     Result:=FCanvas;
end;
//====================================================================
//   ����Ɏg�p����v�����^�̐ݒ�
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
     {FView...�͋���0��MetaFile�쐬���Ɍ��肷��}
     {0��FView...���ݒ�ς݂��ǂ����̃t���O�ƂȂ��Ă���}
     FViewWidth :=0;
     FViewHeight:=0;
     SetPaperInfo;
end;
//====================================================================
//  �p���̏㉺���E�̗]��(�}�[�W��)�ݒ�
//
//  �eOffset�ȉ��̒l�̎���Offset�Ɠ����l�ɋ����C��(�݌v���̂�)
//  �e�X�̏����̑O�� if Value<>FXXXXX then ��}�����Ēu���Ȃ���Delphi
//  ���Ɨ����Ă��܂�(Create�ŏ��������Ă��Ȃ����߂Ȃ̂�?)
//
//  Index 1 TopMargin
//  Index 2 BottomMargin
//  Index 3 RightMargin
//  Index 4 LeftMargin
//  Index 5 HeaderMargin
//  Index 6 FooterMargin
//
//  ���̏�̗]���l���p���̈���\����Ɠ����ŁC�g�̉��r���̑�������
//  ���ꍇ�C�����̑����ɂ����������Ȃ����Ƃ�����D���̂悤�ȏꍇ�́C
//  ��̗]�����C���Ȃ��Ƃ��r���̑����̔��������傫������D
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
//   �t��������v���p�e�B�̐ݒ�
//====================================================================
procedure TCustomplPrev.SetInversePrint(const Value: Boolean);
begin
     if Value<>FInversePrint then begin
       FInversePrint:=Value;
       SetPaperInfo;
     end;
end;
//====================================================================
//   ���[�`�����̎w��(�����\������)
//   �����\�������̏ꍇ�Ɏg�p����v���V�[�W����
//====================================================================
procedure TCustomplPrev.SetProcName(const Value: TPrevProc);
begin
     FProcName:=Value;
     if not Assigned(ProcName) then exit;

     SetDefaultPrinter;
     SetPaperInfo;

     FreeImageList;                 {�A���g�p�̂��߂�Free���K�v}
     FDrawType      :=dtStat;       {�����\�������ł���}
     CreateMetaCanvas(True);        {���^�L�����o�X�̍쐬}
     ScaleInitialize(FCanvas,True); {�L�����o�X�̃X�P�[�����O}
end;
//====================================================================
//   ������(��ǂݕ���)
//====================================================================
procedure TCustomplPrev.BeginDoc;
begin
     Screen.Cursor:=FCursor;
     SetDefaultPrinter;
     SetPaperInfo;
     {��ǂݕ����̓v�����^�̐ݒ�{�^����\��}
     {�������C�\���̎��ɐݒ肷��Ε\��}
     FBtnOptions:=FBtnOptions-[boPrinterSetBtn];

     FreeImageList;                 {�A���g�p�̂��߂�Free���K�v}
     FDrawType     :=dtCont;        {��ǂݕ����ł���}
     FPageNumber   :=1;             {�ł̏����l��1}
     FPageCount    :=1;             {���Ő��̏����l��1}
     CreateMetaCanvas(True);        {���^�L�����o�X�̍쐬}

     ScaleInitialize(FCanvas,False);{�L�����o�X�̃X�P�[�����O}
end;
//====================================================================
//   �ő�����(��ǂݕ���)   �@�@�@�@�@�@
//   �Ŕԍ����C���N�������g���č쐬�������^�t�@�C����ۑ�����
//
//   Ver4.5�ł̕ύX�_
//   ���^�t�@�C���̍쐬�ƕۑ���TList�ōs���Ă������CTMetaFile�̔z��
//   ���g�p������@�ɕύX�D�܂�TList��Item�Ń��^�t�@�C�����쐬���Ă�
//   ���̂��C�R���|�����ʂ�FMetaImage��Canvas�ɕ`�悵�����̂����ł�
//   �x�ɔz��ɕۑ�����悤�ɂ����D�z���TMetaFile�ɑ������ہC
//   Windows9X�̃o�O��������邽�߂ɁCDHGL��FixMetafile9X���g�p�����D
//====================================================================
procedure TCustomplPrev.NewPage;
var
     TempCanvas : TCanvas;
begin
     {Canvas�̃v���p�e�B�����łɈ��p���悤�ɑޔ�}
     TempCanvas:=TCanvas.Create;
     TempCanvas.Font      :=FCanvas.Font;
     TempCanvas.Pen       :=FCanvas.Pen;
     TempCanvas.Brush     :=FCanvas.Brush;
     TempCanvas.CopyMode  :=FCanvas.CopyMode;
     TempCanvas.TextFlags :=FCanvas.TextFlags;
     {�`��I��}
     FCanvas.Free;

     {�ł𑝉�}
     SetLength(MetaImageList,FPageNumber);
     {���ł̃��^�t�@�C����Windows9X�݊��̃��^�t�@�C���ɕϊ����ĕۑ�}
     if FPrinterFlag then begin
       MetaImageList[FPageNumber-1]:=FixMetafileFor9X(FMetaImage,Printer.Handle);
     end else begin
       MetaImageList[FPageNumber-1]:=FixMetafileFor9X(FMetaImage,0);
     end;
     FPageNumber:=FPageNumber+1;     {�Ŕԍ����C���N�������g}
     CreateMetaCanvas(False);        {���^�L�����o�X�쐬}

     {�O�ł�Canvas�̃v���p�e�B��ݒ�}
     try
       FCanvas.Font      :=TempCanvas.Font;
       fCanvas.Pen       :=TempCanvas.Pen;
       FCanvas.Brush     :=TempCanvas.Brush;
       FCanvas.CopyMode  :=TempCanvas.CopyMode;
       FCanvas.TextFlags :=TempCanvas.TextFlags;
     finally
       TempCanvas.Free;
     end;

     ScaleInitialize(FCanvas,False); {�X�P�[�����O}
end;
//====================================================================
//   ���^�t�@�C���쐬�I�����(��ǂݕ���)
//   �Ō�Ȃ̂Ō��݂̕Ŕԍ������Ő�
//====================================================================
procedure TCustomplPrev.EndDoc;
begin
     FCanvas.Free;  {�ŏI�ō쐬�I��}
     FCanvas:=nil;

     {�ł𑝉�}
     SetLength(MetaImageList,FPageNumber);
     {���ł̃��^�t�@�C����Windows9X�݊��̃��^�t�@�C���ɕϊ����ĕۑ�}
     if FPrinterFlag then begin
       MetaImageList[FPageNumber-1]:=FixMetafileFor9X(FMetaImage,Printer.Handle);
     end else begin
       MetaImageList[FPageNumber-1]:=FixMetafileFor9X(FMetaImage,0);
     end;
     try
       FPageCount  :=FPageNumber;  {�ŏI�ł����Ő�}
       FPageNumber :=1;            {�v���r���[�J�n��}
     finally
       Screen.Cursor :=SaveCursor;
     end;
end;
//====================================================================
//   �h���R���|�[�l���g�Ŏg�p���郁�\�b�h
//   �h�����ł���TCustomplPrev�ł͉������Ȃ�
//====================================================================
function TCustomplPrev.Execute: Boolean;
begin
//
end;
//====================================================================
//  �v�����^�ݒ�R���|�̐ݒ�
//
//  plSetPrinter���ݒ肵�Ă��Ȃ��ꍇ�́C���̏���plSetPrinter�v���p�e
//  �B�̐ݒ�����݂�D����������s�����ꍇ��plSetPrinter�v���p�e�B��
//  �l��nil�ƂȂ�C���̊֐���False��Ԃ��D
//  (1) ���̃R���|�[�l���g�̃I�[�i�̃R���|�[�l���g�̃��X������T���o
//      ���čŏ��Ɍ��������v�����^�ݒ�R���|�[�l���g���g�p����D
//      True��Ԃ��D
//  (2) ���̃R�[�h���Ő������āC���݂̃v�����^�Ƃ��̐ݒ�l���g�p����D
//      ���݂̃v�����^����'Acrobat'���܂܂�Ă����ActrobatOut��Ture
//      �ɂ���D
//
//  ����plSetPrinter�v���p�e�B���ݒ肳��Ă����False��Ԃ��D
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
             {�V�K�ɐݒ�Ȃ̂ňӖ��Ȃ�?}
             {�v�����^�ݒ�R���|�[�l���g�̌��݂̐ݒ��Ǐo��}
             FplSetPrinter.CallSetting;
             break;
           end;
         end;
         {�v�����^�ݒ�R���|�[�l���g���Ȃ��ꍇ�͐���}
         try
           if FplSetPrinter=nil then begin
             FplSetPrinter:=TplSetPrinter.Create(Owner);
             {���݂̃v�����^�̐ݒ�l���擾����}
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
       {Ver4.3�Œǉ�}
       {Ver4.53��GetPrinterInfo(False)����CallSetting�ɏC��}
       FplSetPrinter.CallSetting;
     end;
end;
//====================================================================
//�@�v���r���[�̊J�n�����@���[�_���\��
//====================================================================
procedure TCustomplPrev.ShowModal;
begin
     if FAcrobatOut then begin
       Print;
       exit;
     end;

     FFormDispFlag:=SetOrCreatePrevForm;
     {FormName�v���p�e�B��Form�̗L�����̊m�F}
     if FFormName<>'' then begin
       {�L����Form��Screen�ϐ��ɂ���Ε\�����s}
       if FFormDispFlag then begin
         if (FForm as TplPrevForm).Visible then begin
           {�\������Form��ShowModal�ł͕\���s��(����)}
           Application.MessageBox(PChar(S3),PChar(S0),MB_ICONWARNING);
         end else begin
           Execute;
           (FForm as TplPrevForm).ShowModal;
           {����������Form�̏ꍇ�COnClose��Action��caFree���w�肵�Ă��邪}
           {����caFree��Show���\�b�h�\�����̂ݗL���Ȃ̂�ShowModal�͂�����Release}
           if FAutoCreateForm then (FForm as TplPrevForm).Release;
         end;
       end else begin
         {TplPrevForm�ł͂Ȃ����͒P�ɂ���Form��\�����邾��}
         try
           Execute;
           {From��Close�̓T�u�N���X�őΉ�}
           FFormOriginalProc := FForm.WindowProc;
           FForm.WindowProc  := FFormSubClassProc;
           FForm.ShowModal;
         except
         end;
       end;
     end;
end;
//====================================================================
//�@ �v���r���[�̊J�n�����@���[�h���X�\��
//====================================================================
procedure TCustomplPrev.Show;
begin
     if FAcrobatOut then begin
       Print;
       exit;
     end;

     FFormDispFlag:=SetOrCreatePrevForm;
     {FormName�v���p�e�B��Form�̗L�����̊m�F}
     if FFormName<>'' then begin
       {�L����Form��Screen�ϐ��ɂ���Ε\�����s}
       if FFormDispFlag then begin
         Execute;
         (FForm as TplPrevForm).Show;
       end else begin
         {TplPrevForm�ł͂Ȃ����͒P�ɂ���Form��\�����邾��}
         try
           Execute;
           {From��Close�̓T�u�N���X�őΉ�}
           FFormOriginalProc := FForm.WindowProc;
           FForm.WindowProc  := FFormSubClassProc;
           FForm.Show;
         except
         end;
       end;
     end;
end;
//====================================================================
//  FImageVisible�v���p�e�B�̐ݒ胁�\�b�h
//  �v���r���[�C���[�W�\���̗L��
//  �N�����ɃC���[�W��\���������Ȃ��ꍇ�ȂǂɎg�p����
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
//  �v���r���[�t�H�[���̃`�F�b�N
//
//  FormName���ݒ肵�Ă��Ȃ��ꍇ�́C
//  �v���W�F�N�g�ň���v���r���[�p�̌p���t�H�[�����쐬���Ă���΁C��
//  ������o���Ďg�p����D
//  �Ȃ���΁CTplPrevForm���玩���I�Ɍp���t�H�[����V�K�쐬����D
//  ���̐V�K�p��Form�̖��O��plXRAYPrevForm__+���g�̖��O�Ƃ���D
//  ����Form��TplPrevForm��OnFormClose��Action�v���p�e�B�Ŕj�����w��
//  ���ĉ�����Ă���D
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
         {�h�������t�H�[���̖��O��ύX���Ă���ꍇ������̂�}
         {�p�����̃N���X���Ō�������}
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
       {FormName���ݒ�ς݂Ȃ�Screen��Form����T������plPrev���Z�b�g}
       {����Ńv���r���[�t�H�[������Tplprev���g�p�\�ƂȂ�}
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
//   Ver4.3�Œǉ�
//   ��p(����)�̃v���r���[�t�H�[���ȊO��Form�̃T�u�N���X�֐�
//   Form�������ViewWidth,ViewHeight��0�ɂ���
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
//   ���^�t�@�C�����X�g�̉��
//====================================================================
procedure TCustomplPrev.FreeImageList;
var
     i: Integer;
begin
     if FDrawType=dtCont then begin
       {���^�t�@�C�����X�g�̉��}
       for i:=0 to Length(MetaImageList)-1 do begin
         MetaImageList[i].Free;
       end;
       SetLength(MetaImageList,0);
     end;
     FMetaImage.Free;
     FMetaImage:=nil;
end;
//====================================================================
//   �v���r���[Form����郁�\�b�h
//====================================================================
procedure TCustomplPrev.Close;
begin
     if FAcrobatOut then exit;
     if FForm=nil  then exit;
     (FForm as TplPrevForm).CloseBtnClick(FForm);
end;
//====================================================================
//   �w��ł�\��
//   fgDisplay �\����҂��߂̃t���O
//====================================================================
function TCustomplPrev.Display(Page: Integer): Boolean;
begin
     Result:=False;

     {Form�v���p�e�B���ݒ�̎��͕\�����Ȃ�}
     {Form����\���̏ꍇ��No}
     {�O�̕\�����I����Ă��Ȃ��ꍇ��No}
     if FForm=nil then exit;
     if not((FForm as TplPrevForm).Visible) then exit;
     if fgDisplay=False then exit;

     if (Page>0) and (Page<=FPageCount) then begin
       fgDisplay:=False;
       FPageNumber:=Page;
       try
         {plPrev.pas����DrawMetaImage���g�p���Ă���̂͂�������}
         (FForm as TplPrevForm).DrawMetaImage;
       finally
         Result:=True;
         fgDisplay:=True;
       end;
     end;
end;
//====================================================================
//   ����_�C�A���O��\�����Ĉ��
//   �_�C�A���O��\�����Ȃ��ň�����郁�\�b�h��Print
//   ���̃��\�b�h�̓v���r���[�t�H�[����[���]�{�^�����g�p���Ȃ��󋵂�
//   �z�肵�Ă���D
//   �v���r���[���Ȃ��Œ��ڈ������ꍇ�́CTPrintDialog���g�p���ăv��
//   ���^��ݒ肵��Print���\�b�h���ďo�����@���g�p����D
//====================================================================
procedure TCustomplPrev.PrintDialog;
begin
     if FForm=nil then exit;
     (FForm as TplPrevForm).PrintBtnClick(Self);
end;
//====================================================================
//   �O���v�����^�ւ̏o��
//   ����ݒ�̃_�C�A���O�͕\�����Ȃ��D���̃��\�b�h���g�p����O�ɁC
//   PrintFromPage  ����J�n�Ŕԍ�
//   PrintToPage    ����I���Ŕԍ�
//   ��ݒ肵�Ă���.�f�t�H���g�l��1,PageCount
//
//   plPrevFrm.pas��PrintBtnClick�C�x���g�Ŏg�p���Ă���
//   �v���r���[�Ȃ��Œ��ڈ������ꍇ�́C���̃��\�b�h���g�p����D
//====================================================================
procedure TCustomplPrev.Print;
var
     i,FromPage,ToPage: Integer;
     fgAcrobatOut : Boolean;
     ABitmap : TBitmap;
begin
     {�v���r���[�t�H�[�����\������Ă���ꍇ��[���]�{�^�������Print���\�b�h�ďo�ƌ��Ȃ�}
     {�����łȂ����͔h���R���|�[�l���g��Execute(������)���\�b�h�����s����}
     if FForm=nil then begin
       Execute;
     end else begin
       if FForm.Visible=False then Execute;
     end;

     {�`��R�[�h�Ȃ�}
     if FDrawType=dtNone then begin
       Application.MessageBox(PChar(S6),PChar(S0),MB_ICONWARNING);
       exit;
     end;
     {�����ŉ��߂�plSetPriner�v���p�e�B���m�F}
     {�v�����^�h���C�o��������݂��Ȃ����plSetPrinter�v���p�e�B��nil��Ԃ�}
     {SetDefaultPrinter��BeginDoc��ProcName�Ŏ��s���Ă���̂Ŏ��ۂɂ͕s�v�ł��邪}
     {�{�R���|�̗��p�҂ŁCPrint���\�b�h�̑O�Ńv�����^�̐ݒ��ύX���Ă����������}
     {�̂ŁC���̑΍�}
     SetDefaultPrinter;
     {�v�����^�h���C�o���C���X�g�[������Ă��Ȃ����̏ꍇ}
     if FPrinterFlag=False then begin
       Application.MessageBox(PChar(S7),PChar(' ���'),MB_ICONINFORMATION);
       exit;
     end;

     fgAcrobatOut:=False;
     if FPrintFromPage=0 then FPrintFromPage:=1;
     if FPrintToPage=0   then FPrintToPage:=FPageCount;
     {�󔒕ŏo�͑΍�}
     {����J�n�ł����I���Ŕԍ����������Ƌ󔒕ł��o�͂��邱�Ƃ�����}
     if FPrintFromPage>FPrintToPage then begin
       FromPage:=FPrintToPage;
       ToPage  :=FPrintFromPage;
     end else begin
       FromPage:=FPrintFromPage;
       ToPage  :=FPrintToPage;
     end;
     if ToPage>FPageCount then ToPage:=FPageCount;

     {���߂ėp���̏����擾}
     SetPaperInfo;
     {�v�����^����Acrobat�Ƃ��������񂪂�������}
     if (AnsiPos('ACROBAT',AnsiUpperCase(FplSetPrinter.PrinterName))<>0) or (FAcrobatOut) then begin
       fgAcrobatOut:=True;
       GetKeyBoardState(KeyBoardState);
       DefaultKeyState:=KeyBoardState[VK_CONTROL];
       {�ŏ��ɕۑ���𕷂��Ă��Ȃ��l�ɂ��邽��[Ctrl]�����������Ƃɂ���}
       KeyBoardState[VK_CONTROL]:=$81;
       SetKeyBoardState(KeyBoardState);
     end;

     {���}
     if FTitle='' then begin
       Printer.Title:=Application.Title+'���';
     end else begin
       Printer.Title:=FTitle;
     end;

     Printer.BeginDoc;
     FPrinting:=True;
     Screen.Cursor:=FCursor;

     try
       for i:=FromPage to ToPage do begin
         ScaleInitialize(Printer.Canvas,False);
         {�t����(180�x��])����̃v���p�e�BInversePrint��Ver3.4�œ���}
         {�t������StrechDraw��Win95,98�ł͕���������Ɉ���ł��Ȃ�}
         {DHGL��FixMetafile9X�𗘗p���Ă����̖��͉���ł��Ȃ�}
         {������OS�𔻕ʂ���Win95,98�̏ꍇ�̓r�b�g�}�b�v�ɕϊ����Ĉ������}
         {���̈���R�[�h�̏C����Ver4.0}
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
       {�L�[�̉�����Ԃ����ɖ߂�}
       KeyBoardState[VK_CONTROL]:=DefaultKeyState;
       SetKeyBoardState(KeyBoardState);
     end;
end;
//====================================================================
//   �����g��k���̂��߂̃��\�b�h
//   �݌v���̗p���T�C�Y��ݒ�
//   plPrev���ďo���O�ɂ��̃��\�b�h�ň���R�[�h���쐬�������ɑz�肵
//   ���p���T�C�Y���w�肵�Ă�����,����̍�[���]�_�C�A���O�Őݒ肵��
//   �p���T�C�Y�ɍ��킹�Ċg��,�k��������s��.
//   2002.5.10�ǉ�
//====================================================================
procedure TCustomplPrev.DesignedPaperSize(W, H: Integer);
begin
     if W*H<>0 then begin
       FDesignedPaperWidth  :=W;
       FDesignedPaperHeight :=H;
     end;
end;
//====================================================================
//   ����̍ۂɃv�����^�ݒ肪�ύX���ꂽ�ꍇ�ɔ����ăv�����^�̐ݒ��
//   �t�@�C���X�g���[���ɑҔ�
//
//   �ȉ��Ŏg�p���Ă���
//   PrintBtnClick(����_�C�A���O��\�����Ĉ��)
//   ActionHardCopyExecute(�t�H�[���̃n�[�h�R�s�[)
//
//   plPrev.pas�ɏ����Ă���̂́C���̏ꍇ�����p�̉\��...
//   �Ȃ���(�ꉞpublic�ɂ��Ă���)�D
//   �v�����^�ݒ�R���|�[�l���g�̓��l�̖ړI�ł͑��̃R�[�h���g�p����
//   ���邪(�e�X�g�v���O����)�C������͕ς��Ă݂��D���܂�Ӗ��͂Ȃ�
//   ���������m��Ȃ��D                                              }                                                    }
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
//   �t�@�C���X�g���[���ɑҔ����Ă����v�����^�ݒ�R���|�[�l���g�̐�
//   ���Ǐo���čĐݒ�
//
//   �ȉ��Ŏg�p���Ă���
//   PrintBtnClick(����_�C�A���O��\�����Ĉ��)
//   ActionHardCopyExecute(�t�H�[���̃n�[�h�R�s�[)
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
//  ReadComponents(���̏��ReadPrinterSetting�Ŏg�p)��3�����̒l
//====================================================================
procedure TCustomplPrev.ComponentsProc(Component: TComponent);
begin
     if (PrtCompReader.Position = PrtCompStream.Size) then begin
       PrtCompReader.Position := PrtCompReader.Position - 1;
     end;
end;
//====================================================================
//  �L�����o�X�ւ̕`��I���ƃ��^�t�@�C���̎擾 �@�@
//  �����\�������̏ꍇ�C�����ŏ��߂�MetaCanvas�ɕ`�悷��
//  ��ǂݕ����̏ꍇ�C���łɕ`��ς݂Ȃ̂�MetaImageList����擾
//  ����MetaImageList�z��(TMetaFile)�Ɏ��߂��Ă��郁�^�t�@�C����
//  Windows9X�݊�
//====================================================================
function TCustomplPrev.GetMetaImage(Page: Integer): TMetaFile;
var
     APage: Integer;
begin
     {��ǂݕ���}
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
         {OnBeforeView�C�x���g������ꍇ}
         if Assigned(FOnBeforeView) then FOnBeforeView(Self,APage);
       finally
         FCanvas.Free;
         FCanvas:=nil;
       end;
       Result:=FMetaImage;
     {�����\������}
     {�����\�������̏ꍇ��FPageNumber�̒l��`��Ɏg�p����}
     end else if FDrawType=dtStat then begin
       {�\�ߐݒ肵�����Ő����z���Ă̕`��͋֎~}
       if Page<=0 then begin
         FPageNumber:=1;
       end else if Page>=FPageCount then begin
         FPageNumber:=FPageCount;
       end else begin
         FPageNumber:=Page;
       end;
       {MetaFile��MetaFileCanvas���쐬}
       if Assigned(FCanvas) then FCanvas.Free;
       Screen.Cursor:=FCursor;
       CreateMetaCanvas(False);
       ScaleInitialize(FCanvas,True);
       {�쐬����plCanvas��ProcName���\�b�h�ŕ`��}
       {���ۂɂ͊O���̃v���O���������s����(ProcName�v���p�e�B�Ŏw�肵��)}
       try
         Application.ProcessMessages;
         if Assigned(FProcName) then FProcName;
       finally
         {FCanvas��Free�����MetaFile.Canvas�ւ̕`��I��}
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
//   ���^�t�@�C���ƃ��^�t�@�C���E�L�����o�X�̍쐬
//
//   ���̃��^�t�@�C���ɕ`����e���L�^�����.
//   Flag=True  �V�K�Ƀ��^�t�@�C�����쐬(�v���O�����̊J�n���������s)
//   Flag=False ���݂̃��^�t�@�C�����g�p
//   �v�����^��p���ݒ�̕ύX���������ꍇ��False�ōĐݒ肪�K�v
//====================================================================
procedure TCustomplPrev.CreateMetaCanvas(Flag:Boolean);
begin
     if Flag then begin
       if Assigned(FMetaImage) then FMetaImage.Free;
       FMetaImage:=TMetafile.Create;
       {�V�K�쐬�̏ꍇ�͕\�����ƍ�����p���̂���Ɠ����ɂ���}
       {�������CProcName�ݒ�O�CBeginDoc�̑O�ɐݒ肵�Ă����(0�ȊO�Ȃ�)������g�p}
       if FViewWidth=0  then FViewWidth :=FPaperWidth; {�\�����̃f�t�H���g�͗p����}
       if FViewHeight=0 then FViewHeight:=FPaperHeight;{�\�������̃f�t�H���g�͗p������}
     end;
     FViewPaperRatio:=FViewHeight/FViewWidth;
     {0.01mm�P�ʂɊ��Z}
     FMetaImage.MMWidth :=FViewWidth*10;
     FMetaImage.MMHeight:=FViewHeight*10;

     if FPrinterFlag then begin
       {Meta.Width,Meta.Height���擾���邽�߂Ɉ�xCreate����Free}
       FCanvas:=TMetaFileCanvas.Create(FMetaImage,Printer.Handle);
       FCanvas.Free;
       MetaW:=FMetaImage.Width;
       MetaH:=FMetaImage.Height;
       FCanvas:=TMetaFileCanvas.Create(FMetaImage,Printer.Handle);
     end else begin
       {Meta.Width,Meta.Height���擾���邽�߂Ɉ�xCreate����Free}
       FCanvas:=TMetaFileCanvas.Create(FMetaImage,0);
       FCanvas.Free;
       MetaW:=FMetaImage.Width;
       MetaH:=FMetaImage.Height;
       FCanvas:=TMetaFileCanvas.Create(FMetaImage,0);
     end;
     FCanvas.Font.PixelsPerInch:=FXResolution;

     FCanvas.Font.Height:=-RoundOff(10.5*254.0/72.0);
     Application.ProcessMessages;
     {���̌�ScaleInitialize�����s���邪�CScaleInitialize������P�Ƃ�}
     {���s����ꍇ������̂ŕʃ��[�`���Ƃ��Ă���}
end;
//====================================================================
//   �p���̃o�b�N�J���[(PaperColor�v���p�e�B)�ƘA���p���̑䎆�`��
//   ��ǂݕ����ł̓v���r���[�̎�,���������ł�Canvas�p���ݒ莞��
//   ScaleInitialize���\�b�h���Ōďo���Ď��s���Ă���D
//====================================================================
procedure TCustomplPrev.DrawPaperBack(ACanvas: TCanvas;Xw,Yh: Integer);
var
     X1,Y1: Integer;
     S: String;
begin
     {�v�����^�o�͒��łȂ��������`�悷��}
     if not(FPrinting) then begin
       {�p���w�i���w��F�œh�ׂ�}
       ACanvas.Brush.Color:=FPaperColor;
       ACanvas.FillRect(Rect(0,0,Xw,Yh));
       if Assigned(FOnNoPrintDraw) then begin
         FOnNoPrintDraw(Self,FPageNumber);
       end;
       {�A���p���̏ꍇ}
       if FplSetPrinter<>nil then begin
         S:=ToZenkaku(FplSetPrinter.BinName);
         if Pos('�g���N�^',S)<>0 then begin
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
           {�؎����̔j��}
           ACanvas.Pen.Style:=psDot;
           ACanvas.MoveTo(127,0);
           ACanvas.LineTo(127,Yh);
           ACanvas.MoveTo(Xw-127,0);
           ACanvas.LineTo(Xw-127,Yh);
           {Cavnas�̓h�ׂ��F��A���łȂ��ꍇ�Ɠ����ɂ��Ă���}
           {�������Ȃ��ƘA�����Ƃ����łȂ��ꍇ�ƂŁC���̌�̕`�悪�ς���Ă��܂�}
           ACanvas.Brush.Color:=FPaperColor;
         end;
       end;
     end;
end;
//====================================================================
//   Canvas���W�l(�X�P�[�����O�̐ݒ�)
//   Canvas���쐬�����Ƃ��͕K�����s
//
//   MapMode       �����ݒ�l��MM_TEXT.���̃R���|�ł�MM_ANISOTROPIC
//                 �����g�p���Ȃ�.
//   WindowExtEx   �p���̃X�P�[���͉�FPaperWidth,�c��FPaperHeight
//   ViewPortExtEx ����̕���PaperWidht,������plPaperHeight
//   WindowOrgEx   PrinterOffsetX,PrinterOffsetY�Ŏw�肷��l�����S��
//                 �̈󎚈ʒu�𕽍s�ړ�����D
//   ViewPortOrgEx PaperLO,PaperTO��ݒ肵�Ȃ��ƈ󎚉\���[�̍��W��
//                 PaperLO,PaperTO�����X�Ɉ󎚂��Ȃ�����������
//
//   Ver4.2�ł̏C��
//   ���N�̉ۑ�ł���������ƃv���r���[�̃Y��(�S�̓I��)���C���D
//   SetViewPortOrgEx�̈����̎g�p���@���Ԉ���Ă����D
//   �ɓ��@�_������C�T���X�N�ł��D
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
       {�t��������̏ꍇSetPaperInfo�ŋt�ɂ��Ă���Ŗ߂�(Ver4.0�ŏC��)}
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
       {�X�P�[�����O�̌�ɗp���̐F��A���p���̑䎆�`��}
       if Flag then DrawPaperBack(ACanvas,FViewWidth,FViewHeight);
       if FViewClip then begin
         IntersectClipRect(ACanvas.Handle,FLeftOffset,FTopOffset,FRightOffset,FBottomOffset);
       end;
     end;
     {�������`�悷�鎞�̂��Ƃ��l���Ĕw�i�F���N���A���Ă���}
     ACanvas.Brush.Style :=bsClear;
end;
//====================================================================
//   �p���T�C�Y���̐ݒ�
//
//   �g�p����p�����̒l��ْ��v�����^�ݒ�R���|�[�l���g�̒l����ݒ�
//
//   PaperLO        �p���̈���\���[(�h�b�g)
//   PaperTO        �p���̈���\��[(�h�b�g)
//   PaperRO        �p���̈���\�E�[(�h�b�g)
//   PaperBO        �p���̈���\���[(�h�b�g)
//   ScaleMode      �񓙕��ݒ�DMM_ANISOTROPIC�ɂ��Ȃ���0.1mm�P�ʂ�
//                  �ǂ̔C�ӂ̒P�ʂɐݒ�ł��Ȃ�
//   FPaperRatio    �����̗p���̕����I�ȏc����
//   �C���`�T�C�Y�ݒ�ɂ���ƁC�t�H���g�T�C�Y�̌v�Z���̕ύX���K�v�D
//
//   ����SetPaperInfo�ł�ViewWidth,ViewHeight�v���p�e�B�͎g�p�Ȃ�
//====================================================================
procedure TCustomplPrev.SetPaperInfo;
var
     WRa,HRa,Ratio1,Ratio2: Double;
begin
     if FplSetPrinter=nil then begin
       if Printer.Printers.Count>0 then begin
         {�v�����^�ݒ�R���|���Ȃ����͌��݂̃v�����^�̏����擾}
         FplPaperWidth  :=GetDeviceCaps( Printer.Handle,PHYSICALWIDTH);
         FplPaperHeight :=GetDeviceCaps( Printer.Handle,PHYSICALHEIGHT);
         FplPageWidth   :=GetDeviceCaps( Printer.Handle,HORZRES);
         FplPageHeight  :=GetDeviceCaps( Printer.Handle,VERTRES);
         FXResolution   :=GetDeviceCaps( Printer.Handle,LOGPIXELSX);
         FYResolution   :=GetDeviceCaps( Printer.Handle,LOGPIXELSY);

         {�t��������̏ꍇ�́C�v�����^�̕����I�I�t�Z�b�g�͍��E�㉺�t�ƂȂ�}
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

         {�t��������̏ꍇ�́C�v�����^�̕����I�I�t�Z�b�g�͍��E�㉺�t�ƂȂ�}
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


     {�����k���g��̂��߂̐݌v���p���T�C�Y��0�łȂ����͐ݒ肳��Ă���ƌ��Ȃ�}
     {�{���͏c�T�C�Y�̒l���`�F�b�N���ׂ��ł��邪�ȗ�}
     {�����\�������̂ݑΉ�}
     if FPrinterFlag then begin
       {0.1mm�P�ʂɊ��Z�������Ə�[�̃I�t�Z�b�g}
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
         {�ʏ�̏ꍇ.FDesingedPapeer...�����O�͂��̕�������������}
       end else begin
         {0.1mm�P�ʗp���T�C�Y}
         FPaperWidth   :=Trunc(FplPaperWidth*254 /FXResolution);
         FPaperHeight  :=Trunc(FplPaperHeight*254/FYResolution);
         {0.1mm�P�ʂ̕ŕ��ƍ���(����\�̈�)}
         FPageWidth  :=Trunc(FplPageWidth*254 /FXResolution);
         FPageHeight :=Trunc(FplPageHeight*254/FYResolution);
       end;
     end;

     {�p���̏c���̐��@�����肵���̂ŉE�Ɖ��[�I�t�Z�b�g���v�Z}
     FRightOffset :=FLeftOffset+FPageWidth;
     FBottomOffset:=FTopOffset+FPageHeight;

     ScaleMode    :=MM_ANISOTROPIC;
     FPaperRatio  :=FPaperHeight/FPaperWidth;

     {�e�}�[�W���̐ݒ�}
     {�݌v���̂ݎ�����������}
     if (csDesigning in ComponentState) then begin
       if FTopMargin<FTopOffset     then FTopMargin:=FTopOffset;
       if FLeftMargin<FLeftOffset   then FLeftMargin:=FLeftOffset;
       if FRightMargin<(FPaperWidth-FRightOffset)    then FRightMargin:=FPaperWidth-FRightOffset;
       if FBottomMargin<(FPaperHeight-FBottomOffset) then FBottomMargin:=FPaperHeight-FBottomOffset;
       if FHeaderMargin>FTopMargin    then FHeaderMargin:=FTopMargin;
       if FFooterMargin>FBottomMargin then FFooterMargin:=FBottomMargin;
     end;
end;




       {-------------------  ��͂��܂� ----------------------}
       {-- �`�惁�\�b�h���Ȃɂ��Ȃ��R���|����܂�Ȃ��̂� --}
       {-------------- �ł��R���|�{�̂ł��g�p ----------------}


//====================================================================
//   �l�̌ܓ��֐�
//   �����_�ꌅ�ڂ��l�̌ܓ����Đ����ɂ���D
//   ���̊֐��͓��������Ŏg�p
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
//   ������S�̂����p�����Ɓ|�݂̂𔼊p�ɂ���֐�
//
//   �p������-�����ŁC���̋L���ނ͕ϊ����Ȃ�
//   FDELPHI MES(15) 00102 ��������̃R�[�h�̈ꕔ���ؗp
//   �A�Z���u���̃R�[�h����������(��PC-9801��Graphic�̃R�[�h��....)
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
           {�����ɔ��p�ɂ���������������}
           if Sw='�|' then begin
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
//   ������S��S�Ĕ��p�ɂ���֐�
//
//   �J�^�J�i,�Ђ炪�Ȃ����p�ɂ��Ă��܂��̂Œ���.
//   �e�햽�߂�Win32 API���Q�Ƃ̂���.
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
//   �������S�đS�p�ɂ���                                     �@
//
//   �Z���̈���̎���,�Ԓn�̐�����S�đS�p�ɂ��������߂ɍ쐬
//   �e�햽�߂�Win32 API���Q�Ƃ̂���.
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
//   �t�H���g�T�C�Y
//   ����v���r���[�R���|plPrev�ł͒����̒P�ʂ�0.1mm�ł���
//   �����ł����ł̓t�H���g�T�C�Y(1pt��1/72 inch)��0.1mm�P�ʂ̒�����
//   ���Z���Ă���                  �@�@�@�@�@�@�@�@�@�@
//   254��1inch��0.1mm�P�ʂŕ\�������l
//   1pt=1/72inch=0.3528mm
//=====================================================================
procedure TCustomplPrev.FontSize(S:Double);
begin
     if FCanvas=nil then exit;
     FCanvas.Font.Height:=-RoundOff(S*254.0/72.0);
end;
//====================================================================
//   �t�H���g����
//   FontSize�ł͕��̒l�ɂ��Ă���̂ŕ��̒l���w�肷��Ƃ悢
//====================================================================
procedure TCustomplPrev.FontHeight(V: Integer);
begin
     FCanvas.Font.Height:=V;
end;
//====================================================================
//   �t�H���g��
//   �I�u�W�F�N�g�E�C���X�y�N�^�[�̕\�����R�s�[����Ίm��
//====================================================================
procedure TCustomplPrev.FontName(V:TFontName);
begin
     FCanvas.Font.Name:=V;
end;
//====================================================================
//   �t�H���g�̐F
//   (����:�t�H���g�̓y���ŏ����̂ł͂Ȃ�Font�ŕ`�悷��)
//   �F�̐ݒ�ɂ�,�t�H���g�̐F,���̐F,�h�ׂ��̐F������
//====================================================================
procedure TCustomplPrev.FontColor(V:TColor);
begin
     FCanvas.Font.Color:=V;
end;
//====================================================================
//   �t�H���g�X�^�C���̎w��
//
//   fsBold      �����ɂȂ�
//   fsItalic    �Α̂ɂȂ�
//   fsUnderline �����t���ɂȂ�
//   fsStrikeout �ł��������t���ɂȂ�
//   FontStyle([fsItalic,fsStrikeout]);�̗l�Ɏw�肷��.
//   ���܂܂ł̃X�^�C����������ɂ�FontSytle([])��OK�D
//====================================================================
procedure TCustomplPrev.FontStyle(V:TFontStyles);
begin
     FCanvas.Font.Style:=V;
end;
//====================================================================
//   �t�H���g�̃Z�b�g�C�A�T�C��
//   Ver4.1��Height�̐ݒ��ǉ�
//====================================================================
procedure TCustomplPrev.FontAssign(V: TFont);
begin
     FCanvas.Font.Assign(V);
     FCanvas.Font.Height:=V.Height;
end;
//====================================================================
//   �y���̐F(���̐F)
//   �F�̐ݒ�ɂ́C�t�H���g�̐F�C�y���̐F(���̐F)�C�h�ׂ��̐F������
//====================================================================
procedure TCustomplPrev.PenColor(V: TColor);
begin
     FCanvas.Pen.Color:=V;
end;
//====================================================================
//   ���̐F(���̐F)
//   �F�̐ݒ�ɂ́C�t�H���g�̐F�C�y���̐F(���̐F)�C�h�ׂ��̐F������
//====================================================================
procedure TCustomplPrev.LineColor(V: TColor);
begin
     FCanvas.Pen.Color:=V;
end;
//====================================================================
//   �h�ׂ��̐F
//   �F�̐ݒ�ɂ́C�t�H���g�̐F�C�y���̐F(���̐F)�C�h�ׂ��̐F������
//====================================================================
procedure TCustomplPrev.BrushColor(V:TColor);
begin
     if FCanvas=nil then exit;
     FCanvas.Brush.Color:=V;
end;
//====================================================================
//   ���̃X�^�C��
//
//   ���̃X�^�C���Ȃ̂��y���̃X�^�C���Ȃ̂�?
//   psSolid	   ����
//   psDash	   �j��
//   psDot	   �_��
//   psDashDot	   ��_����
//   psDashDotDot  ��_����
//   psClear	   ���͕`�悵�Ȃ�
//   psInsideFrame �����D������Width��1���傫���ꍇ�ɂ͒��ԐF���g
//                  �p����ꍇ������
//   ����
//   Width �v���p�e�B��1�łȂ��Ƃ��ɂ�psDot�܂���psDash�͎g���Ȃ��D
//====================================================================
procedure TCustomplPrev.LineStyle(V:TPenStyle);
begin
     if FCanvas=nil then exit;
     FCanvas.Pen.Style:=V;
end;
//====================================================================
//   �y���̃X�^�C��(���̃X�^�C���ɓ���)
//
//   ���̃X�^�C���Ȃ̂��y���̃X�^�C���Ȃ̂�?
//   psSolid	   ����
//   psDash	   �j��
//   psDot	   �_��
//   psDashDot	   ��_����
//   psDashDotDot  ��_����
//   psClear	   ���͕`�悵�Ȃ�
//   psInsideFrame �����D������Width��1���傫���ꍇ�ɂ͒��ԐF���g
//                 �p����ꍇ������
//   ����
//   Width �v���p�e�B��1�łȂ��Ƃ��ɂ�psDot�܂���psDash�͎g���Ȃ��D
//====================================================================
procedure TCustomplPrev.PenStyle(V:TPenStyle);
begin
     FCanvas.Pen.Style:=V;
end;
//====================================================================
//   ���̑���(�h�b�g�w��)
//   ���̃R���|�[�l���g�ł�1�h�b�g��0.1mm
//====================================================================
procedure TCustomplPrev.LineWidth(V:Integer);
begin
     FCanvas.Pen.Width:=V;
end;
//====================================================================
//   �y���̑���(�h�b�g�w��.���̑����ɓ���)
//   plPrint�ł͂P�h�b�g��0.1mm�ł���
//====================================================================
procedure TCustomplPrev.PenWidth(V:Integer);
begin
     FCanvas.Pen.Width:=V;
end;
//====================================================================
//   �h�ׂ��̃X�^�C��
//
//   bsSolid      �S�h�ׂ�
//   bsCross      �c���̃N���X�͗l
//   bsClear      ����
//   bsDiagCross  �΂߂̃N���X�͗l
//   bsBDiagonal  �E�オ��̎΂ߐ�
//   bsHorizontal ����
//   bsFDiagonal  �E������̎΂ߐ�
//   bsVertical   �c��
//====================================================================
procedure TCustomplPrev.BrushStyle(V:TBrushStyle);
begin
     FCanvas.Brush.Style:=V;
end;
//====================================================================
//   �y�����ړ�
//
//   ���W(X,Y)�Ƀy�����ړ�
//   plPrint�ł͗]��y���ʒu�����ӎ����Ă��Ȃ���...
//====================================================================
procedure TCustomplPrev.MoveTo(X:Integer;Y:Integer);
begin
     FCanvas.MoveTo(X,Y);
end;
//====================================================================}
//   ��������                                                        }
//                                                                   }
//   ���݂̈ʒu������W(X,Y)�܂ŁC���݂̐��̃X�^�C���ƃy���Ő������� }
//====================================================================}
procedure TCustomplPrev.LineTo(X:Integer;Y:Integer);
begin
     FCanvas.LineTo(X,Y);
end;
//====================================================================
//   �w����W�Ԃɐ�������
//
//   ���W(X1,Y1)��(X2,Y2)�ԂɁC���݂̐��̃X�^�C���ƃy���Ő�������
//   plPrint�ł͈����̍��W��X���W�CY���W�̏��ɂȂ��Ă���̂Œ���
//====================================================================
procedure TCustomplPrev.Line(X1,X2,Y1,Y2:Integer);
begin
     FCanvas.MoveTo(X1,Y1);
     FCanvas.LineTo(X2,Y2);
end;
//====================================================================
//   �h�ׂ��l�p�`�̕`��(�g������)
//
//   BrushColor�Ŏw�肵���F��
//   BurshStyle�Ŏw�肵���X�^�C���Ŏl�p�`����h�ׂ�
//   �g���͌��݂̃y���̐F�ŕ`��
//   �h�ׂ��́C���Ə�̒[�͗̈�Ɋ܂܂�邪�C�E�Ɖ��̒[�͊܂܂�Ȃ��D
//   �����̍��W��X���W�CY���W�̏��ɂȂ��Ă���̂Œ���
//====================================================================
procedure TCustomplPrev.Rectangle(X1,X2,Y1,Y2:Integer);
begin
     FCanvas.Rectangle(X1,Y1,X2,Y2);
end;
//====================================================================
//   �h�ׂ��l�p�`�̕`��(�g���Ȃ�)
//
//   BrushColor�Ŏw�肵���F�Ŏl�p�`����h�ׂ��D
//   �g���͕`�悵�Ȃ��D
//   �h�ׂ��́C���Ə�̒[�͗̈�Ɋ܂܂�邪�C�E�Ɖ��̒[�͊܂܂�Ȃ��D
//   �����̍��W��X���W�CY���W�̏��ɂȂ��Ă���̂Œ���
//====================================================================
procedure TCustomplPrev.FillRect(X1,X2,Y1,Y2:Integer);
begin
     FCanvas.FillRect(Rect(X1,Y1,X2,Y2));
end;
//====================================================================
//   �l�p�`�̕`��
//
//   �l�p�`�̕ӂ������C���݂̃y���̐F�Ƒ������g�p���ĕ`�悷��D
//   �����̍��W��X���W�CY���W�̏��ɂȂ��Ă���̂Œ���
//====================================================================
procedure TCustomplPrev.RectLine(X1,X2,Y1,Y2:Integer);
begin
     FCanvas.Polyline([Point(X1,Y1),Point(X2,Y1),Point(X2,Y2),
                        Point(X1,Y2),Point(X1,Y1)]);
end;
//====================================================================
//   �l�p�`�̕`��(�h�ׂ��Ȃ�)
//   ���݂�FCanvas��Brush�̐ݒ���g�p
//
//   ���W(X1,Y1),(X2,Y2)�Ŏw�肷�钷���`���P�s�N�Z�����ň���
//   �����̍��W��X���W�CY���W�̏��ɂȂ��Ă���̂Œ���
//====================================================================
procedure TCustomplPrev.FrameRect(X1,X2,Y1,Y2:Integer);
begin
     FCanvas.FrameRect(Rect(X1,Y1,X2,Y2));
end;
//====================================================================
//   �~�̕`��
//
//   ���S���W��(X1,Y1)�Œ��aD�̉~���C���݂̃y���̐ݒ�l��p���ĕ`��
//   ����D�O����Pen�̐F�C������Brush�̐F�ƂȂ�D
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
//   �ȉ~�̕`��
//
//   ���S���W��(X1,Y1)��X�������̌a��DX,Y�������̌a��DY�̑ȉ~���C��
//   �݂̃y���̐ݒ�l��p���ĕ`�悷��D�O����Pen�̐F�C������Brush��
//   �F�ƂȂ�D
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
//   ������̕`��
//   X���WX1��������̍��[�CY���WY1��������̏�[�ƂȂ�
//   �����TCanvas��TextOut,���̃R���|��TextOutLT�Ɠ���
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
//   ������̕`��
//   X���WX1��������̍��[�CY���WY1��������̏�[�ƂȂ�
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
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
//   ������̕`��@
//   X���WX1��������̍��[�CY���WY1��������̏㉺�����ƂȂ�
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
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
//   ������̕`��
//   X���WX1��������̍��[�CY���WY1��������̉��[�ƂȂ�
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
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
//   ������̕`��@�@�@�@�@�@�@�@�@�@
//   X���WX1��������̍��E�����CY���WY1��������̏�[�ƂȂ�
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
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
//   ������̕`��
//   X���WX1��������̍��E�����CY���WY1��������̏㉺�����ƂȂ�
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
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
//   ������̕`��
//   X���WX1��������̍��E�����CY���WY1��������̉��[�ƂȂ�
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
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
//   ������̕`��
//   X���WX1��������̉E�[�CY���WY1��������̏�[�ƂȂ�
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
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
//   ������̕`��
//   X���WX1��������̉E�[�CY���WY1��������̂͏㉺�����ƂȂ�
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
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
//   ������̕`��
//   X���WX1��������̉E�[�CY���WY1��������̉��[�ƂȂ�
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
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
//   ������̕`��(�N���b�s���O)
//   ���W(X1,Y1),(X2,Y2)�Ō��܂�l�p�`�̍���ɕ������`�悷��D
//   �l�p�`�͕`�悵�Ȃ��D
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
//   �����̍��W��X���W�CY���W�̏��ɂȂ��Ă���̂Œ���
//   Ver3.0��TextRect..��Win32 API��DrawText���g�p����R�[�h�ɕύX
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
//   ������̕`��(�N���b�s���O)
//   ���W(X1,Y1),(X2,Y2)�Ō��܂�l�p�`�̍��[�̒����ɕ`�悷��D
//   �l�p�`�͕`�悵�Ȃ��D
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
//   �����̍��W��X���W�CY���W�̏��ɂȂ��Ă���̂Œ���
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
//   ������̕`��
//   ���W(X1,Y1),(X2,Y2)�Ō��܂�l�p�`�̍����ŏ㉺�^�񒆂ɕ`�悷��D
//   ������,(X1,X2)�̕��ɕ����񂪎��܂�Ȃ��ꍇ�͋ϓ����t�̃��\�b�h
//   TextRectJust���g�p����.
//   �l�p�`�͕`�悵�Ȃ��D
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
//   �����̍��W��X���W�CY���W�̏��ɂȂ��Ă���̂Œ���
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
//   ������̕`��(�N���b�s���O)
//   ���W(X1,Y1),(X2,Y2)�Ō��܂�l�p�`�̍����ɕ������`�悷��D
//   �l�p�`�͕`�悵�Ȃ��D
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
//   �����̍��W��X���W�CY���W�̏��ɂȂ��Ă���̂Œ���
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
//   ������̕`��(�N���b�s���O)
//   ���W(X1,Y1),(X2,Y2)�Ō��܂�l�p�`�̍��E�̒��Ԃŏ�[�ɕ`�悷��D
//   �l�p�`�͕`�悵�Ȃ��D
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
//   �����̍��W��X���W�CY���W�̏��ɂȂ��Ă���̂Œ���
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
//   ������̕`��(�N���b�s���O)
//   ���W(X1,Y1),(X2,Y2)�Ō��܂�l�p�`�̐^�񒆂ɕ`�悷��D
//   �l�p�`�͕`�悵�Ȃ��D
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
//   �����̍��W��X���W�CY���W�̏��ɂȂ��Ă���̂Œ���
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
//   ������̕`��
//   ���W(X1,Y1),(X2,Y2)�Ō��܂�l�p�`�̐^�񒆂ɕ`�悷��D
//   ������,(X1,X2)�̕��ɕ����񂪎��܂�Ȃ��ꍇ�͋ϓ����t�̃��\�b�h
//   TextRectJust���g�p����.
//   �l�p�`�͕`�悵�Ȃ��D
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
//   �����̍��W��X���W�CY���W�̏��ɂȂ��Ă���̂Œ���
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
//   ������̕`��(�N���b�s���O)
//   ���W(X1,Y1),(X2,Y2)�Ō��܂�l�p�`�̍��E���Ԃ̉��[�ɕ`�悷��D
//   �l�p�`�͕`�悵�Ȃ��D
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
//   �����̍��W��X���W�CY���W�̏��ɂȂ��Ă���̂Œ���
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
//   ������̕`��(�N���b�s���O)
//   ���W(X1,Y1),(X2,Y2)�Ō��܂�l�p�`�̉E��[�ɕ`�悷��D
//   �l�p�`�͕`�悵�Ȃ��D
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
//   �����̍��W��X���W�CY���W�̏��ɂȂ��Ă���̂Œ���
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
//   ������̕`��(�N���b�s���O)
//   ���W(X1,Y1),(X2,Y2)�Ō��܂�l�p�`�̉E�̏㉺�����ɕ`�悷��D
//   �l�p�`�͕`�悵�Ȃ��D
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
//   �����̍��W��X���W�CY���W�̏��ɂȂ��Ă���̂Œ���
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
//   ������̕`��(�N���b�s���O)
//   ���W(X1,Y1),(X2,Y2)�Ō��܂�l�p�`�̉E���ɕ`�悷��D
//   �l�p�`�͕`�悵�Ȃ��D
//
//   ���\�b�h���̌��̑啶���� �@�@�@�@
//   L  Left   ��
//   R  Right  �E
//   T  Top    ��
//   B  Bottom ��
//   C  Center ���E�̒��ԁC�㉺�̐^��
//   �����̍��W��X���W�CY���W�̏��ɂȂ��Ă���̂Œ���
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
//   �X�֔ԍ��g�ƗX�֔ԍ��̕`��  ��^�X�֕��̏ꍇ
//   ����������c�̏ꍇ�͉E���,���̏ꍇ�͉E���Ɉ���@�@�@
//   ������Zip�Ɋ܂܂�鐔�����ȊO�͏������Ă�����
//   ������͂��̃R���|�̃t�H���g�֌W���\�b�h�̎g�p���O��
//
//   Zip         �X�֔ԍ�(-�Ȃǂ̋L���������Ă����̃��\�b�h���ŏ���)
//   PrtOut      �X�֔ԍ��g��������邩���Ȃ����̃t���O
//   OffsetX     �����������.������.
//   OffsetY     �����������.�c����.
//   DispOffsetY �v���r���[�̕\���ʒu����.�c����.+�ŉ����Ƀv���r���[
//               ����������c�̏ꍇ(�܋Ȃ�����ʏ�̎�)�̂ݗL��
//   DispOffsetY��2002.6.20�ǉ�
//   DispOffsetY�̋@�\��������������̏ꍇ���T�|�[�g(Ver3.1)
//====================================================================
procedure TCustomplPrev.ZipOut(Zip: String; OffsetX,OffsetY:Integer;
PrtOut: Boolean;DispOffsetY:Integer=0);
var
     i: Integer;
     ZWidth  : Integer; {�ԍ��g�̕�}
     ZHeight : Integer; {�ԍ��g�̍���}
     ZLen    : Integer; {�ԍ��g�̋���}
     BaseX   : Integer; {�g�̍��[��X}
     BaseY   : Integer; {��[�̏�[��Y}
     Dis     : Integer; {4���ڂ̊J�n�ʒu}
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
     {����ʒu�𒲐�����̂̓v�����^�o�͂̏ꍇ�̂�}
     if FPrinting then begin
       OffsetXX:=OffsetX;
       OffsetYY:=OffsetY;
     end else begin
       OffsetXX:=0;
       OffsetYY:=0;
     end;

     {�g�̕���}
     Port:=False;
     if FPrinterFlag then begin
       if FplSetPrinter.Orientation=poPortrait then Port:=True;
     end else begin
       Port:=True;
     end;
     {����������c}
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
     {�����������}
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

     {�ԍ��̕���}
     FontW:=FCanvas.TextWidth('0');  {�`��ʒu�����p}
     FontH:=FCanvas.TextHeight('0'); {�`��ʒu�����p}
     SZip :=ToHankaku(Zip);
     {����������c}
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
     {�����������}
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
//   �X�֔ԍ��g�ƗX�֔ԍ��̕`��  ��^�O�X�֕��̏ꍇ
//   ����������c�̏ꍇ�͉E���,���̏ꍇ�͉E���Ɉ���@�@�@
//   ������Zip�Ɋ܂܂�鐔�����ȊO�͏������Ă�����
//   ������͂��̃R���|�̃t�H���g�֌W���\�b�h�̎g�p���O��
//
//   Zip         �X�֔ԍ�(-�Ȃǂ̋L���������Ă����̃��\�b�h���ŏ���)
//   PrtOut      �X�֔ԍ��g��������邩���Ȃ����̃t���O
//   OffsetX     �����������.������.
//   OffsetY     �����������.�c����.
//   DispOffsetY �v���r���[�̕\���ʒu����.�c����.+�ŉ����Ƀv���r���[
//               ����������c�̏ꍇ(�܋Ȃ�����ʏ�̎�)�̂ݗL��
//   DispOffsetY��2002.6.20�ǉ�
//   DispOffsetY�̋@�\��������������̏ꍇ���T�|�[�g(Ver3.1)
//====================================================================
procedure TCustomplPrev.ZipOutEx(Zip: String; OffsetX,OffsetY:Integer;
PrtOut: Boolean;DispOffsetY:Integer=0);
var
     i: Integer;
     ZWidth  : Integer; {�ԍ��g�̕�}
     ZHeight : Integer; {�ԍ��g�̍���}
     ZLen    : Integer; {�ԍ��g�̋���}
     BaseX   : Integer; {�g�̍��[��X}
     BaseY   : Integer; {��[�̏�[��Y}
     Dis     : Integer; {4���ڂ̊J�n�ʒu}
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
     {����ʒu�𒲐�����̂̓v�����^�o�͂̏ꍇ�̂�}
     if FPrinting then begin
       OffsetXX:=OffsetX;
       OffsetYY:=OffsetY;
     end else begin
       OffsetXX:=0;
       OffsetYY:=0;
     end;

     {�g�̕���}
     Port:=False;
     if FPrinterFlag then begin
       if FplSetPrinter.Orientation=poPortrait then Port:=True;
     end else begin
       Port:=True;
     end;
     {����������c}
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
     {�����������}
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

     {�ԍ��̕���}
     FontW:=FCanvas.TextWidth('0');  {�`��ʒu�����p}
     FontH:=FCanvas.TextHeight('0'); {�`��ʒu�����p}
     SZip :=ToHankaku(Zip);
     {����������c}
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
     {�����������}
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
//   �f�B�X�N����e�L�X�g�t�@�C����Ǎ���ŕ`��
//   DHGL�̃��[�`����ύX���ė��p
//   ���[�����ŕ`��D�֑�������2�����Œ�.���ő���̏����͂Ȃ�.
//   �ߒl
//   1�s���`�悵�Ȃ������ꍇ��Yt
//   ����ȊO�͎��̍s�̊J�nY���W�l
//
//   Yt       �`��J�nY���W
//   Xl       �`��͈͂̍��[X���W�l
//   Xr       �`��͈͂̉E�[X���W�l
//   RowH     �s�Ԋu
//   FileName �e�L�X�g�t�@�C����
//===================================================================
function TCustomplPrev.TextOutFile(Yt,Xl,Xr,RowH: Integer; FileName: String): Integer;
var
     SL: TStringList;
     Options: TFormatOptions;
     Yb: Integer;
begin
     {�e�L�X�g��ێ�����StringList�쐬}
     SL:=TStringList.Create;
     Options:=[foJustify];
     try
       {StringList�Ƀe�L�X�g��Ǎ���}
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
//   StringList�̃e�L�X�g��������郋�[�`��
//   DHGL�̃��[�`���𗘗p
//   ���ňȍ~�Ɉ�����K�v�ȏꍇ��SL�̎c��𔻒f���Ă��̃��[�`���O��
//   �s���D���[�`�����ŉ��ŏ������s���Ă��܂��Ɛ�ǂݕ�����p�ƂȂ�
//   �Ă��܂��D
//
//   �ߒl
//   1�s���`�悵�Ȃ������ꍇ��Yt
//   ����ȊO�͎��̍s�̊J�nY���W�l
//
//   var SL     �e�L�X�g�����߂�StringList
//              �S�Ẵe�L�X�g�̈�����I�����Ȃ��������͎c��̃e�L�X�g
//              ��Ԃ��D1�s��(���s)�ł̖����������C���f�b�N�X[0]�ɓ���
//              �Ă���D�S�Ă̏o�͂��I�����Ă���΁C���̃��[�`���𔲂�
//              �����SL.Count�̒l��0�ƂȂ��Ă���D
//   Options    DHGL��TextUtlis����GetTextPosition��Options����
//              foJustify   ���[����
//              foEven      �ϓ����t
//              foRight     �E�[����
//              foCenter    ��������(�E�[�������D��)
//              foKerning   �J�[�j���O���s��
//   Yt         �`��J�nY���W
//   Xl         �`��͈͂̍��[X���W�l
//   Xr         �`��͈͂̉E�[X���W�l
//   RowH       �s�Ԋu
//   KinsokuCnt �֑�����������.0�̎��֑͋������Ȃ�.
//              �f�t�H���g��2.
//===================================================================
function TCustomplPrev.StringListOut(var SL: TStringList; Options: TFormatOptions;
     Xl,Xr,Yt,Yb, RowH: Integer; KinsokuCnt:Integer=2): Integer;
var
     ATopMargin   : Integer;   {����J�n��[�ʒu(�h�b�g)}
     LineNumber   : Integer;   {�s�ԍ�}
     WrittenLines : Integer;   {���ɕ`�悵���s��}
     WS, RestWs   : WideString;{1�s���̃e�L�X�g(���s�܂܂ł�)}
     FontHeight   : Double;    {Font Size(Twips)}
     APrintWidth  : Double;    {�󎚕�(Twips)}
     APrintHeight : Integer;   {�󎚍�(Pixels)}
     Offset       : Integer;   {�󎚊J�n�I�t�Z�b�g}
     FittedChars  : Integer;   {������镶����}
     DXs          : TDxArray;  {�����ʒu�z��.TDxArray��TetUtlis�Œ�`}
     KinsokuStr   : WideString;{���o�����֑�������}
     AddKinLen    : Integer;   {�Ԃ牺����ǉ��֑̋�������}
     i,dx         : Integer;   {�����Ԋu�����p�̐��l(�h�b�g)}
     Amaridots    : Integer;   {����.�e�����Ԃɋϓ��ɐU�����Ďc�����h�b�g��}
     Widthdots    : Integer;   {�֑�������̒���(�h�b�g)}
begin
     if SL.Count=0 then begin
       Result:=Yt;
       exit;
     end;

     {�t�H���g�����ƕ`�����v�Z}
     ATopMargin  := Yt;
     FontHeight  := FCanvas.Font.Height*1440/FXResolution;
     APrintHeight:= Abs(Yb-Yt);
     APrintWidth := Abs(Xr-Xl)*1440/FXResolution;

     {����O�͈���ςݍs����0}
     WrittenLines := 0;

     {StringList(SL)�̃e�L�X�g�̏o�͊J�n}
     for LineNumber:=0 to SL.Count-1 do begin
       {1�s��(���s�܂�)�̕��������o��}
       WS := SL[0];
       {������̒�����0�̏ꍇ}
       if Length(WS)=0 then  begin
         {�󔒍s�̏ꍇ}
         if (RowH*WrittenLines)<=APrintHeight then begin
           Inc(WrittenLines);
         end else begin
           break;
         end;
       {������̒�����0�łȂ��ꍇ}
       end else begin
         {1�s���̕�����̒�����0�ɂȂ�܂ŌJ��Ԃ�}
         while Length(WS) > 0 do begin
           if (RowH * WrittenLines)<=APrintHeight then begin
             RestWS:=GetTextPosition(
                   WS,FontHeight,FCanvas.Font.Handle,APrintWidth,
                   FXResolution,Options,Offset,FittedChars,DXs);

             {�֑������͂Ȃ��Ɖ���}
             Widthdots :=0;
             {�s������(�Ǐo������)������΂��̕���������Ɉ�����镶�����}
             {�擪�ɉ�����.���������镶����֑͋������������Ȃ�����}
             {KinsokuStr���Ǐo�����镶����}
             KinsokuStr:=GetOidashiStr(WS,FittedChars,KinsokuCnt);
             AddKinLen:=0;

             if KinsokuStr<>'' then begin
               {�Ǐo�����镶�����擪�ɕt���������񂪎��Ɉ�����镶����}
               RestWS:=KinsokuStr+RestWS;
               {����̍ۂɗ]��h�b�g����Widthdots}
               Widthdots:=FCanvas.TextWidth(KinsokuStr);
             end else begin;
               {�s���֑̋����������񂪂Ȃ���Ύ��̍s�̐擪�֑�������𒲍�����}
               {���o�����֑��������,���������镶����̌��ɒǉ�����}
               {���ۂɂ͈�����镶����FittedChars��ύX����΂悢}
               KinsokuStr:=GetBurasageStr(RestWS,FittedChars,KinsokuCnt);
               AddKinLen:=Length(KinsokuStr);
               if AddKinLen>0 then begin
                 {�֑���������폜���������񂪎��Ɉ�����镶����}
                 Delete(RestWS,1,AddKinLen);
                 {����̍ۂɕs������h�b�g��Widthdots}
                 Widthdots:=-FCanvas.TextWidth(KinsokuStr);
                 SetLength(DXs, FittedChars);

                 {�ǉ������̕����Ԋu��ݒ�}
                 if AddKinLen>1 then begin
                   for i:=AddKinLen downto 2 do begin
                     DXs[High(DXs)-i+1]:=Abs(Widthdots div (AddKinLen));
                   end;
                 end;
               end;
             end;

             {�֑��������̃h�b�g(�s�N�Z��)�̏���}
             if (FittedChars>1) and (Widthdots<>0) then begin
               {�e�����Ԋu�ɐU�蕪���镪��dx}
               dx:=Widthdots div (FittedChars-1-AddKinLen);
               Amaridots:=Widthdots mod (FittedChars-1-AddKinLen);
               {���̃h�b�g��DXs�ɐU�蕪����}
               for i:=Low(DXs) to High(DXs)-AddKinLen-1 do DXs[i]:=DXs[i]+dx;
               {�]�������͐擪�̕����񂩂�1�h�b�g�ÂU������}
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
           {1�s���̏o�͂��I�����Ȃ��ŉ��[�̈���ʒu���z�����ꍇ}
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
//   �s���֑�����
//   ������S�̌��ɋ֑���������(������z��OidashiStr���̕���)�������
//   ����(�Ǐo��)�������Ԃ��֐�.
//
//   S      �������镶����
//   EndPos �������镶����̒���.������ׂ�������̒�����Ԃ�.
//          (���̒��������Ȃ��Ȃ�)
//   Count  ��������֑������̐�.�Ԃ�������̐��̍ő�l.
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
       {�����Ώە�������o��.�ŏ��͍Ō�̕���}
       SubStr:=S[pPos];
       Flag  :=False;
       {�֑�������������������z��̗v�f����������}
       for i:=Low(OidashiStr) to High(OidashiStr) do begin
         if (OidashiStr[i]=SubStr) then begin
           {���ʂ͒Ǐo��������}
           Result:=Result+SubStr;
           Flag  :=True;
           break;
         end;
       end;
       {�֑����������o����Ȃ���ΏI��}
       if Flag=False then break;
       {�֑������������1�O�̕��������ׂ�}
       Dec(pPos);
       Dec(Count);
       if Count=0 then break;
     end;
     EndPos:=EndPos-Length(Result);
end;
//====================================================================
//   �s���֑�����
//   ������S�̐擪�ɋ֑���������(������z��BurasageStr���̕���)�������
//   ����(�O�̕�����̌��ɒǉ�����Ԃ牺��)�������Ԃ��֐�.
//
//   S      �������镶����
//   EndPos �������镶����̒���.������ׂ�������̒�����Ԃ�.
//          (���̒����������Ȃ�)
//   Count  ��������֑������̐�.�Ԃ�������̐��̍ő�l.
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
       {�����Ώە�������o��.�ŏ��͐擪����}
       SubStr:=S[pPos];
       Flag  :=False;
       {�֑�������������������z��̗v�f����������}
       for i:=Low(BurasageStr) to High(BurasageStr) do begin
         if (BurasageStr[i]=SubStr) then begin
           {���ʂ͑O�s�ɂԂ牺���镶����}
           Result:=Result+SubStr;
           Flag  :=True;
           break;
         end;
       end;
       {�֑����������o����Ȃ���ΏI��}
       if Flag=False then break;
       {�֑�����������Ύ��̕��������ׂ�}
       inc(pPos);
       Dec(Count);
       if Count=0 then break;
     end;
     EndPos:=EndPos+Length(Result);
end;
//====================================================================
//   ������̋ϓ����t�`��
//
//   ���W(X1,Y1),(X2,Y2)�Ō��܂�l�p�`�̒��ɕ`�悷��D
//   �l�p�`�͕`�悵�Ȃ��D�Œ�s�b�`�t�H���g�őS�p�̂ݑΉ��D
//   X���W�ɋϓ��Ɋ��t���ĕ`�悷�邪,���肫��Ȃ��Ƃ��͕����̕���
//   �����ċϓ����t������D
//   �����Ԋu�̌v�Z�덷(�ۂߌ덷)�̂��߁C�`��ɂ������덷����������D
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
     {WideString�łȂ��ƑS�p���p�����蕶���񂪂��܂��s���Ȃ�}
     WText:=Text;
     WLen  :=Length(WText); {������}

     {1���������̎���TextRectCC���̗p}
     if WLen<=1 then begin
       TextRectCC(X1,X2,Y1,Y2,Text);
       exit;
     end;

     V:=100;
     Size:=FCanvas.TextExtent(Text);
     {�`��J�nY���W�l}
     YPos:=RoundOff(ABS(Y2+Y1)/2.0-Size.Cy/2.0);
     {������X���W�͈̔͂Ɏ��܂�Ȃ���Ε�����������}
     if ABS(X2-X1)<(Round(Size.Cx*0.85)) then begin
       V:=RoundOff(ABS(X2-X1)/Size.Cx*100);
     end;
     {���ݑI������Ă���t�H���g�̃��g���b�N���w�肳�ꂽ�o�b�t�@�Ɋi�[}
     GetTextMetrics(FCanvas.Handle,TM);
     {�t�H���g�������ݎg�p����Font����擾}
     GetObject(FCanvas.Font.Handle,Sizeof(TLOGFONT),@LogFont);
     {TLogFont�\���̂̈ꕔ��ύX}
     with LogFont do begin
       lfHeight :=FCanvas.Font.Height;
       lfWidth  :=RoundOff(TM.tmAveCharWidth*V/100.0);
       lfQuality:=ANTIALIASED_QUALITY;
     end;
     {�ύX�����t�H���g����p����,�V�����t�H���g�n���h�����쐬}
     NewFont:=CreateFontIndirect(LogFont);
     {�V�����t�H���g�n���h�����f�o�C�X�R���e�L�X�g�ɑI����}
     {����܂őI������Ă����t�H���g�n���h����ۑ�}
     OldFont:=SelectObject(FCanvas.Handle,NewFont);

     {���������x�A�����O���l�����Čv�Z}
     {X1���E�[��X2���E�[�ɒ���}
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

     {�����ԃh�b�g�����v�Z}
     dx:=(AWidth-FCanvas.TextWidth(WText)) div (WLen-1);
     Amaridots:=(AWidth-FCanvas.TextWidth(WText)) mod (WLen-1);
     {1�����Â`��}
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
       {���̃t�H���g�n���h����I�����߂�}
       SelectObject(FCanvas.Handle,OldFont);
       {�쐬�����t�H���g�n���h�����폜}
       DeleteObject(NewFont);
     end;
end;
//====================================================================
//   ������̏c�����ϓ����t�`��
//
//   ���W(X1,Y1),(X2,Y2)�Ō��܂�l�p�`�̒��ɏc�����ŕ`�悷��D
//   �l�p�`�͕`�悵�Ȃ��DY���W�ɋϓ��Ɋ��t���ĕ`�悷�邪,���肫���
//   ���Ƃ��͕����̍����𒲐����ċϓ����t������D�t�H���g���ɏc����
//   �p���w�肷��K�v�͂Ȃ��D�Œ�s�b�`�t�H���g�őS�p�̂ݑΉ��D
//
//   ���l
//   ���� Insert(Char(TM.tmBreakChar,Ws,....);
//        SetTextJustFication(.....);
//   �����g�p�������CPrinter.Canvas�ւ̒��ڏo�͂�WindowsNT/2000�Ŋ�
//   �Ғʂ�̌��ʂ��o�Ȃ��������߂��̃R�[�h�ɕύX����(Windows98�ł�
//   ���Ғʂ�̓��������)
//   �����Ԋu�̌v�Z�덷(�ۂߌ덷)�̂��߁C�`��ɂ������덷����������D
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
     {WideString�łȂ��ƑS�p���p�����蕶���񂪂��܂��s���Ȃ�}
     WText:=Text;
     WLen  :=Length(WText); {������}

     {1���������̎���TextRectCC���̗p}
     if WLen<=1 then begin
       TextRectCC(X1,X2,Y1,Y2,Text);
       exit;
     end;

     V:=100;
     Size:=FCanvas.TextExtent(Text);
     {�`��J�nY���W�l}
     XPos:=RoundOff(ABS(X2+X1)/2.0+Size.Cy/2.0);
     {������Y���W�͈̔͂Ɏ��܂�Ȃ���΍�����Ⴍ����}
     if (ABS(Y2-Y1)-Round(Size.Cx*0.85))<0 then begin
       V:=Ceil(ABS(Y2-Y1)/Size.Cx*100);
     end;

     {���ݑI������Ă���t�H���g�̃��g���b�N���w�肳�ꂽ�o�b�t�@�Ɋi�[}
     GetTextMetrics(FCanvas.Handle,TM);
     {�t�H���g�������ݎg�p����Font����擾}
     GetObject(FCanvas.Font.Handle,Sizeof(TLOGFONT),@LogFont);
     {TLogFont�\���̂̈ꕔ��ύX}
     with LogFont do begin
       lfHeight     :=FCanvas.Font.Height;
       lfWidth      :=RoundOff(TM.tmAveCharWidth*V/100.0);
       lfQuality    :=ANTIALIASED_QUALITY;
       lfEscapement :=2700;
       StrPCopy(lfFaceName,'@'+FCanvas.Font.Name);
     end;
     {�ύX�����t�H���g����p����,�V�����t�H���g�n���h�����쐬}
     NewFont:=CreateFontIndirect(LogFont);
     {�V�����t�H���g�n���h�����f�o�C�X�R���e�L�X�g�ɑI����}
     {����܂őI������Ă����t�H���g�n���h����ۑ�}
     OldFont:=SelectObject(FCanvas.Handle,NewFont);

     AWidth :=Abs(Y1-Y2);
     {�����ԃh�b�g�����v�Z}
     dy:=(AWidth-FCanvas.TextWidth(WText)) div (WLen-1);
     Amaridots:=(AWidth-FCanvas.TextWidth(WText)) mod (WLen-1);
     {1�����Â`��}
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
       {���̃t�H���g�n���h����I�����߂�}
       SelectObject(FCanvas.Handle,OldFont);
       {�쐬�����t�H���g�n���h�����폜}
       DeleteObject(NewFont);
     end;
end;
//====================================================================
//   �w�蕶�����̕�����𓙕����`��
//
//   ���W(X1,Y1),(X2,Y2)�Ō��܂�l�p�`����Cnt�������ĕ`�悷��D
//   ���[�ނ̋��z����X�֔ԍ��ȂǁC�g���w�肳��Ă���ꍇ�Ɏg�p����D
//
//   X1  �l�p�`�̉E�[��X���W
//   X2  �l�p�`�̍��[��X���W
//   Y1  �l�p�`�̏�[��Y���W
//   Y2  �l�p�`�̉��[��Y���W
//   Cnt �l�p�`���̘g�̐�
//   Text �`�悷�镶����D���l�͕�����ɕϊ����ēn��
//   Length(Text)>Cnt�̏ꍇ�͉E���ɂ݂͂����`�悷��
//====================================================================
procedure TCustomplPrev.TextRectFit(X1,X2,Y1,Y2,Cnt:Integer;Text:String);
var
   X,Xl,Xs,Y,i,j :Integer;
begin
     {�P������Xs}
     Xs:=Round(ABS(X2-X1)/Cnt);
     {�擪����̋󔒗��̐�}
     j:=Cnt-Length(Text);
     if j<0 then j:=0;
     {�`��J�nX���W}
     Xl:=X1+RoundOff(Xs/2.0);
     {Y���W}
     Y:=RoundOff((Y1+Y2)/2.0);
     for i:=1 to Length(Text) do begin
       X:=Xl+(j+i-1)*Xs;
       TextOutCC(X,Y,Copy(Text,i,1));
     end;
end;
//====================================================================
//   �����ƕ����w�肵��������
//
//   ���[�v����p�@�̂悤��2�{�p�Ȃǂ̕�����̕`����\
//   X    ������̏o��X���W(�ʏ�̐����ʒuR=0�̂Ƃ������X���W)
//   Y    ������̏o��Y���W(�ʏ�̐����ʒuR=0�̂Ƃ������Y���W)
//   R    1�x�P�ʂ̉�]�p�x.�����v��������.270���Əc����
//   V    �����̕�(�����ʒuR=0�̎�)
//   Text �`�悷�镶����
//====================================================================
procedure TCustomplPrev.TextSpecial(X,Y,R:Integer;V:Integer;Text:String);
var
   LogFont: TLogFont;
   TM     : TTextMetric;
   NewFont: HFont;
   OldFont: HFont;
begin
     {���ݑI������Ă���t�H���g�̃��g���b�N���w�肳�ꂽ�o�b�t�@�Ɋi�[}
     GetTextMetrics(FCanvas.Handle,TM);
     {�t�H���g�������ݎg�p����Font����擾}
     GetObject(FCanvas.Font.Handle,Sizeof(TLOGFONT),@LogFont);
     {TLogFont�\���̂̈ꕔ��ύX}
     with LogFont do begin
       lfHeight    := FCanvas.Font.Height;
       lfWidth     := RoundOff(TM.tmAveCharWidth*V/100.0);
       lfEscapement:= R*10;
       lfQuality   := ANTIALIASED_QUALITY;
     end;

     {�ύX�����t�H���g����p����,�V�����t�H���g�n���h�����쐬}
     NewFont:=CreateFontIndirect(LogFont);
     {�V�����t�H���g�n���h�����f�o�C�X�R���e�L�X�g�ɑI����}
     {����܂őI������Ă����t�H���g�n���h����ۑ�}
     OldFont:=SelectObject(FCanvas.Handle,NewFont);
     try
       FCanvas.Brush.Style:=bsClear;
       FCanvas.TextOut(X,Y,Text);
     finally
       {���̃t�H���g�n���h����I�����߂�}
       SelectObject(FCanvas.Handle,OldFont);
       {�쐬�����t�H���g�n���h�����폜}
       DeleteObject(NewFont);
     end;
end;
//====================================================================
//   �f�B�X�N���̉摜�t�@�C����FCanvas�ɓǍ���ŕ`��
//   EXE���ɖ��ߍ��񂾉摜�ɂ�StretchDrawBitmap,StretchDrawBitmap���g
//   �p�\
//
//   �摜�����̃h�b�g���̂܂�(�c�����)��FCanvas�ɕ`��(Draw)����D
//   �w��g���Ɏ��߂ĕ`�悷��ɂ�StretchDrawPict���g�p����
//   ������̂͊g���q��EMF,BMP,ICO,JPG�̉摜
//
//   X1       �\���ʒu�̍���X���W
//   Y1       �\���ʒu�̍���Y���W
//   FileName �`�悷��摜�t�@�C����
//   FDELPHI MES(16) 00013 �z����̔����Q��
//====================================================================
procedure TCustomplPrev.DrawPict(X1,Y1:Integer;FileName:string);
var
     plPict:TPicture;
     plJpeg:TJpegImage;
     FExt :String;
begin
     {�t�@�C���̊g���q�������擾}
     FExt :=UpperCase(ExtractFileExt(FileName));
     {��ʂ�Picture��Jpeg�̗����ɑΉ����邽�߂�Create}
     plPict:=TPicture.Create;
     plJpeg:=TJpegImage.Create;
     try
       {�g���q��JPG�̂Ƃ���DIBNeeded�Ńr�b�g�}�b�v�ϊ�}
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
       {�K�v�Ȃ��Ȃ�����Free}
       plPict.Free;
       plJpeg.Free;
     end;
end;
//====================================================================
//   �f�B�X�N���̉摜�t�@�C����FCanvas�ɓǍ���ŕ`��
//   EXE���ɖ��ߍ��񂾉摜�ɂ�StretchDrawBitmap,StretchDrawBitmap���g
//   �p�\
//
//   �摜���w�肵���g���Ɏ��߂�FCanvas�ɕ`��(StretchDraw)����D
//   ���̃h�b�g���̂܂ܕ`�悷��ɂ�plDrawPict���g�p����
//   ������̂͊g���q��EMF,BMP,ICO,JPG�̉摜
//
//   X1       �\���g�̍���X���W
//   X2       �\���g�̉E��X���W
//   Y1       �\���g�̍���Y���W
//   Y2       �\���g�̉E��Y���W
//   IsFit    True�̂Ƃ��g�̑傫���ɏc�����ς��ĕ`��
//            False�̂Ƃ��c����͕ς����C�c���̂ǂ��炩�̕��ɍ�����
//            �g��܂��͏k�����ĕ`��
//   FileName �`�悷��摜�t�@�C����
//   FDELPHI MES(16) 00013 �z����̔����Q��
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
     {�t�@�C���̊g���q�������擾}
     FExt:=UpperCase(ExtractFileExt(FileName));
     {��ʂ�Picture��Jpeg�̗����ɑΉ����邽�߂�Create}
     plPict:=TPicture.Create;
     plJpeg:=TJpegImage.Create;
     try
       {�g���q��JPG�̂Ƃ���DIBNeeded�Ńr�b�g�}�b�v�ϊ�}
       Application.ProcessMessages;
       if FExt='.JPG' then begin
         plJPeg.LoadFromFile(FileName);
         plJpeg.DIBNeeded;
         plPict.Assign(plJpeg);
       end else begin
         plPict.LoadFromFile(FileName);
       end;
       Application.ProcessMessages;
       {�g�ɍ��킹�ĕό`����ꍇ�͘g�̍��W�����̂܂܉摜�̑傫��}
       if IsFit=True then begin
         Xl:=X1;
         Yt:=Y1;
         Xr:=X2;
         Yb:=Y2;
       end else begin
         {Ratio1 �g�̏c����}
         {Ratio2 �摜�̏c����}
         Ratio1:=ABS((Y2-Y1)/(X2-X1));
         Ratio2:=plPict.Height/plPict.Width;
         {�g�̏c����̕����傫���ꍇ�͉��̕��ɍ����ĕ\��}
         if Ratio1>Ratio2 then begin
           Xl:=X1;
           Xr:=X2;
           Yw:=RoundOff(ABS(X2-X1)/Ratio2);
           Yt:=Ceil((Y1+Y2)/2.0-Yw/2.0);
           Yb:=Yt+Yw;
         {�摜�̏c����̕����傫���ꍇ�͏c�̒����ɍ����ĕ\��}
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
       {�K�v�Ȃ��Ȃ�����Free}
       plPict.Free;
       plJPeg.Free;
     end;
end;
//====================================================================
//   StrectchDIBs���g�p�����r�b�g�}�b�v�̕`��
//   ��������΍�
//   Pict  : TBitmap
//   ARect : �`��̈�̋�`TRect�\����
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
         {������[�`���̒��Ŏg�p����̂ŕK�v�ȃR�[�h}
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
//   ���^�t�@�C���C���[�W�̕`��
//   Pict  : TMetaFile
//   ARect : �`��̈�̋�`TRect�\����
//====================================================================
procedure TCustomplPrev.StretchDrawMetaFile(ARect: TRect; Pict: TMetaFile);
begin
     if not(Pict is TMetaFile) then exit;
     PlayEnhMetaFile(FCanvas.Handle,Pict.Handle,ARect);
end;


{ TplPrev }

//====================================================================
//  �R���|�[�l���g����
//====================================================================
constructor TplPrev.Create(AOwner: TComponent);
begin
     inherited;
end;
//====================================================================
//  �R���|�[�l���gDestroy
//====================================================================
destructor TplPrev.Destroy;
begin
     inherited Destroy;
end;
//====================================================================
//   Show���\�b�h
//   �h���R���|�[�l���g�ł�Show���\�b�h���g�p�ł��Ȃ����������ꍇ����
//   ��̂�TCustomplPrev��private�ɂ��Ă���DTplPrev�ł�public�ɁD
//====================================================================
procedure TplPrev.Show;
begin
     inherited;
end;
//====================================================================
//   ShowModal���\�b�h
//   �h���R���|�[�l���g�ł͂��̃��\�b�h���g�p�ł��Ȃ����������ꍇ����
//   ��̂�TCustomplPrev��private�ɂ��Ă���DTplPrev�ł�public�ɁD
//====================================================================
procedure TplPrev.ShowModal;
begin
     inherited ShowModal;
end;
//====================================================================
//  BeginDoc���\�b�h
//====================================================================
procedure TplPrev.BeginDoc;
begin
     inherited BeginDoc;
end;
//====================================================================
//  EndDoc���\�b�h
//====================================================================
procedure TplPrev.EndDoc;
begin
     inherited EndDoc;
end;
//====================================================================
//  NewPage���\�b�h
//====================================================================
procedure TplPrev.NewPage;
begin
     inherited NewPage;
end;
//====================================================================
//  ������\�b�h
//====================================================================
procedure TplPrev.Print;
begin
    inherited Print;
end;
//====================================================================
//  �R�[�h�I��
//====================================================================
end.

