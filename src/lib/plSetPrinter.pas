{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$WARNINGS OFF}
//====================================================================
//  プリンタ設定コンポーネント  TplSetPrinter
//
//  印刷用のプログラム作成の際，プリンタの設定(用紙サイズや用紙向き等
//  を主にプリンタのプロパティ設定ダイアログ(プリンタドライバが提供す
//  る)を表示して行うコンポーネント．
//  Ver6.0では，ほとんどのプロパティを読書き両用にした．
//  動作も安定確実になった．
//  また仕様を見直した結果，コードがよりスッキリした，と思っている．
//
//  プロパティの設定は，[プロパティの設定]ダイアログで設定するのが確
//  実であるが，Ver6.0で各プロパティの書込みを可能にした．ただし，プ
//  リンタドライバによっては，[プロパティの設定]ダイアログには存在す
//  る項目が設定できなかったりするので注意．
//
//  【謝辞】
//  NiftyのFDELPHIの会議室の発言やDelphi MLの過去ログ，そしてネット上
//  の掲示板やサイトの内容を参考または利用させて頂ました．特に中村拓男
//  さんの著書にはお世話になりました．感謝します．
//
//                            2005.01.29  Ver.6.06 　
//                            Copyright (C) by Mr.XRAY
//                            http://homepage2.nifty.com/Mr_XRAY/
//====================================================================
unit plSetPrinter;

interface

uses
  Windows,SysUtils, Classes,Forms,Printers,Controls,ToolWin,WinSpool,
  StdCtrls,Math,Dialogs;

type
  TplPrtSettings=array[0..0] of Char;         //DevModeの保存用Char配列型の定義
  pplPrtSettings=^TplPrtSettings;             //そのポインタ型を定義
  TplPrtDialogCloseEvent = procedure(Sender: TObject; ID: Integer) of object;

  TplSetPrinter = class(TComponent)
  private
    { Private 宣言}
    {ADeviecプリンタ名,ADriverドライバ名,APortポート名のChar型文字列}
    ADevice,ADriver,APort: array[0..512] of Char;
    CustomPaperName : String;               //ユーザ定義用紙名
    hPrtHandle      : THandle;              //プリンタデバイスドライバのハンドル
    DevMode         : String;               //DevModeの保存名
    ASettings       : pplPrtSettings;       //プリンタの設定値ADevModeのコピー
    DevSize         : Integer;              //DevMode構造体のサイズ.ASettingsに必要

    FPrintersCount  : Integer;              //インストールされているプリンタ数
    FPrinterName    : String;               //ポート名を含まないプリンタの名称
    FPrinterNumber  : Integer;              //プリンタ番号

    FPrinterList    : TStringList;          //プリンタ名のリスト(ソート済み)
    FPaperList      : TStringList;          //用紙名のリスト
    FBinList        : TStringList;          //ビン名称のリスト

                                            //設計時の値
    FdsPrinterName  : String;               //ポート名を含まないプリンタの名称
    FdsOrientation  : TPrinterOrientation;  //紙の方向
    FdsPaperName    : String;               //紙サイズ名称
    FdsPaperNumber  : Integer;              //用紙サイズ番号
    FdsBinNumber    : Integer;              //ビン番号
    FdsDriverVersion: Integer;              //ドライババージョン番号

    FOnDialogClose  : TplPrtDialogCloseEvent;//ダイアログを閉じた時のイベント
    FOnPrinterChange: TNotifyEvent;          //プリンタを変更した時のイベント

    FOnSetupDialogShow  : TNotifyEvent;
    FOnSetupDialogClose : TNotifyEvent;

    //DevSizeの保管と読出し
    procedure WriteADevSize(Writer: TWriter);
    procedure ReadADevSize(Reader: TReader);
    //DevModeの保管と読出し
    procedure WriteADev(Writer: TWriter);
    procedure ReadADev(Reader: TReader);
    //設計時の値の保管と読出し
    procedure WriteDesignValues(Writer: TWriter);
    procedure ReadDesignValues(Reader: TReader);

    function CheckPaperName(UserPaperName:String; var pNo:Integer): Boolean;
    function SetUserPaper95(CustomW,CustomH: Integer): Boolean;
    function SetUserPaperNT(UserPaperName: String; CustomW,CustomH: Integer): Boolean;
    function CheckSetUserPaper(CustomW,CustomH: Integer): Boolean;
    function GetBinList: TStringList;
    function GetPaperList: TStringList;
    function GetPrinterList: TStringList;
    function GetFBinName: String;
    function GetFBinNumber: Integer;
    function GetFColorBit: Integer;
    function GetFDriverVersion: Integer;
    function GetFOrientation: TPrinterOrientation;
    function GetFPaperName: String;
    function GetFPaperNumber: Integer;
    function GetFPrintersCount: Integer;
    function GetDeviceCapsValues(const index: Integer): Integer;
    procedure SetFBinNumber(const Value: Integer);
    procedure SetFPrinterNumber(const Value: Integer);
    procedure SetFOrientation(const Value: TPrinterOrientation);
    procedure SetFPaperName(const Value: String);
    procedure SetFPaperNumber(const Value: Integer);
    procedure SetFBinName(const Value: String);
    procedure SetCopies(const Value: Integer);
    function GetCollate: Integer;
    function GetCopies: Integer;
    procedure SetCollate(const Value: Integer);
    procedure SetColor(const Value: Integer);
    function GetColor: Integer;
    function GetDuplex: Integer;
    procedure SetDuplex(const Value: Integer);
    procedure CopyDevModeToASettings;
    function GetPrinterIndexFromString(Str: String): Integer;
    function GetPrinterNameFromString(Str: String): String;
    function GetPort: String;
    function GetPrinterName: String;
    procedure ModifyAndCopy(Value :PDeviceMode);
  protected
    { Protected 宣言 }
    procedure Loaded; override;
    procedure DefineProperties(Filer:TFiler);override;
    procedure SetPrinterName(Value:String);
    procedure SetPrinterInfo(Index: Integer);
    function EditPrinterInfo: Boolean;
    procedure ForSetupDialogOnShow(Sender: TObject);
    procedure ForSetupDialogOnClose(Sender: TObject);
  public
    { Public 宣言 }
    constructor Create(AOwner: TComponent);override;
    destructor Destroy; override;
    //プロパティ値の中にはDWORDの定義のものもあるが，ここではIntegerとして扱う　
    property PrintersCount  : Integer             read GetFPrintersCount;
    property Port           : String              read GetPort;
    property PrinterNumber  : Integer             read FPrinterNumber       write SetFPrinterNumber;
    property Orientation    : TPrinterOrientation read GetFOrientation      write SetFOrientation;
    property PaperName      : String              read GetFPaperName        write SetFPaperName;
    property PaperNumber    : Integer             read GetFPaperNumber      write SetFPaperNumber;
    property DriverVersion  : Integer             read GetFDriverVersion;
    property BinName        : String              read GetFBinName          write SetFBinName;
    property BinNumber      : Integer             read GetFBinNumber        write SetFBinNumber;
    property ColorBit       : Integer             read GetFColorBit;
    property Color          : Integer             read GetColor             write SetColor;
    property Collate        : Integer             read GetCollate           write SetCollate;
    property Copies         : Integer             read GetCopies            write SetCopies;
    property Duplex         : Integer             read GetDuplex            write SetDuplex;
    property YResolution    : Integer index 1     read GetDeviceCapsValues;
    property XResolution    : Integer index 2     read GetDeviceCapsValues;
    property PaperWidth     : Integer index 3     read GetDeviceCapsValues;
    property PaperHeight    : Integer index 4     read GetDeviceCapsValues;
    property PageWidth      : Integer index 5     read GetDeviceCapsValues;
    property PageHeight     : Integer index 6     read GetDeviceCapsValues;
    property TopOffset      : Integer index 7     read GetDeviceCapsValues;
    property BottomOffset   : Integer index 8     read GetDeviceCapsValues;
    property LeftOffset     : Integer index 9     read GetDeviceCapsValues;
    property RightOffset    : Integer index 10    read GetDeviceCapsValues;

    property PrinterList          : TStringList read GetPrinterList;
    property PaperList            : TStringList read GetPaperList;
    property BinList              : TStringList read GetBinList;

    property dsPrinterName  :String              read FdsPrinterName;
    property dsOrientation  :TPrinterOrientation read FdsOrientation;
    property dsPaperName    :String              read FdsPaperName;
    property dsPaperNumber  :Integer             read FdsPaperNumber;
    property dsBinNumber    :Integer             read FdsBinNumber;
    property dsDriverVersion:Integer             read FdsDriverVersion;

    {公開メソッド}

    {設定値の呼出}
    procedure CallSetting;
    {プロパティ設定ダイアログの表示}
    function ShowDialog : Boolean;
    {プリンタの設定情報を取得してコンポに取込む}
    procedure GetPrinterInfo(GetFlag:Boolean=False);
    {ユーザ定義用紙の登録}
    function SetUserPaper(UserPaperName:String;CustomW,CustomH:Integer):Boolean;
    {ユーザ定義用紙の削除}
    function DeleteUserPaper(UserPaperName:String): Boolean;

    {用紙名の設定(エラー検出をBooleanで行う)メソッド}
    function SetPaperName(PaperStr: String): Boolean;
    {用紙番号の設定(エラー検出をBooleanで行う)メソッドに}
    function SetPaperNumber(Index: WORD): Boolean;
    {印刷方向の設定(エラー検出をBooleanで行う)メソッド}
    function SetOrientation(Orient: TPrinterOrientation): Boolean;
    {給紙装置名の設定(エラー検出をBooleanで行う)メソッド}
    function SetBinName(BinStr: String): Boolean;

    function ShowSetupDialog: Boolean;
    function SaveToFile(AFile: String): Boolean;
    function LoadFromFile(AFile: String): Boolean;

  published
    property PrinterName        : String                 read GetPrinterName      write SetPrinterName;
    property OnDialogClose      : TplPrtDialogCloseEvent read FOnDialogClose      write FOnDialogClose;
    property OnPrinterChange    : TNotifyEvent           read FOnPrinterChange    write FOnPrinterChange;
    property OnSetupDialogShow  : TNotifyEvent           read FOnSetupDialogShow  write FOnSetupDialogShow;
    property OnSetupDialogClose : TNotifyEvent           read FOnSetupDialogClose write FOnSetupDialogClose;
  end;

implementation

//uses DebugWndUnit;

type
  //プリンタ情報の宣言
  TPrinterInfo4Array = array[0..10000] of TPrinterInfo4;
  PPrinterInfo4Array = ^TPrinterInfo4Array;
  TPrinterInfo5Array = array[0..10000] of TPrinterInfo5;
  PPrinterInfo5Array = ^TPrinterInfo5Array;

  //用紙名リスト用．用紙名の文字数の最大は64}
  TPaperName  =array [0..63] of Char;
  TPaperNames =array[0..0] of TPaperName;
  TPaperNumber=array[0..0] of WORD;
  pPaperName  =^TPaperNames;
  pPaperNumber=^TPaperNumber;

  //ビン名称リスト用．ビン名称文字列の最大は24
  TBinName  =array [0..23] of Char;
  TBinNames =array[0..0] of TBinName;
  TBinNumber=array[0..0] of WORD;
  pBinName  =^TBinNames;
  pBinNumber=^TBinNumber;

var
   PrintersInfo: array of Byte; //プリンタ情報
   PrinterInfoLevel: Integer;   //プリンタ情報のレベル

{TplSetPrinter}

//====================================================================
//  コンポーネントの初期設定
//====================================================================
constructor TplSetPrinter.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     //DevModeのコピーの値をクリア
     ASettings:=nil;
     //DevSizeは0に
     DevSize:=0;
     //プリンタ数を取得
     FPrintersCount:=GetFPrintersCount;
     FPrinterNumber:=-1;

     FPrinterList := TStringList.Create;
     FPaperList   := TStringList.Create;
     FBinList     := TStringList.Create;
end;
//====================================================================
//  Loaded処理
//  プロパティエディタとSetPrinterName修正の結果，処理の必要性がな
//  くなった(Ver 5.3)．
//====================================================================
procedure TplSetPrinter.Loaded;
begin
     inherited;
end;
//====================================================================
//  コンポーネントの破棄
//  GetMem(ASettings, ...)で確保したメモリは最終的にここで解放
//====================================================================
destructor TplSetPrinter.Destroy;
begin
     FreeAndNil(FPrinterList);
     FreeAndNil(FPaperList);
     FreeAndNil(FBinList);

     DeleteObject(hPrtHandle);
     if Assigned(ASettings) then FreeMem(ASettings);
     inherited Destroy;
end;
//====================================================================
//  publishedプロパティ以外のプロパティの保管と読出し
//
//  以下のプロパティの保管と読出しを行う
//  DevSize   DEVMODEのサイズ．ASettingsの読出しに必要
//  ASettings 設計時のDEVMODEの内容．プリンタの変更があった場合に
//            ここに収めたプロパティ値の再現を試みる．
//  設計時の以下の各プロパティ
//  ASettingsでの設定に失敗した場合など，設計時の値を知る必要があ
//  る時の参照用．
//  dsPrinterName  : String;              ポート名を含まないプリンタの名称
//  dsOrientation  : TPrinterOrientation; 印刷方向
//  dsPaperName    : String;              紙サイズ名称
//  dsPaperNumber  : Integer;             用紙サイズ番号
//  dsBinNumber    : Integer;             ビン番号
//  dsDriverVersion: Integer;             ドライババージョン番号
//====================================================================
procedure TplSetPrinter.DefineProperties(Filer:TFiler);
begin
     Inherited DefineProperties(Filer);
     //まずDevSizeを保管する
     Filer.DefineProperty('DevDataSize',ReadADevSize,WriteADevSize,True);
     //DevSize=0なら保管も読出しも必要ない
     if DevSize>0 then begin
       Filer.DefineProperty('ADevData',ReadADev,WriteADev,True);
       Filer.DefineProperty('DesignValue',ReadDesignValues,WriteDesignValues,True);
     end;
end;
//====================================================================
//    DevSizeの保管
//====================================================================
procedure TplSetPrinter.WriteADevSize(Writer: TWriter);
begin
     Writer.WriteInteger(DevSize);
end;
//====================================================================
//    DevSizeの読込み
//====================================================================
procedure TplSetPrinter.ReadADevSize(Reader: TReader);
begin
     DevSize:=Reader.ReadInteger;
end;
//====================================================================
//    ASettingsの保管
//====================================================================
procedure TplSetPrinter.WriteADev(Writer: TWriter);
var
     i: Integer;
begin
     DevMode:='';
     for i:=0 to DevSize-1 do begin
       DevMode:=DevMode+IntToHex(Integer(ASettings^[i]),2);
     end;
     Writer.WriteString(DevMode);
end;
//====================================================================
//  ASettingsデータの読出し
//  読出したらプリンタの初期化
//  このルーチンは，初めてこのコンポを配置した時はDevSiezが0なので実
//  されないが，このReadDevの前にPrinterNameプロパティに値がセットさ
//  れのでSetPriterInfoは実行される．
//
//  読出しに失敗ということは考えられないが(プリンタ番号取得とそれによ
//  るプリンタの設定は考えられる)念のため失敗したらプリンタ番号をデフ
//  ォルトの-1にしてみる
//  2004.11.5 Ver6.03
//====================================================================
procedure TplSetPrinter.ReadADev(Reader: TReader);
var
     DevByte,i: Integer;
begin
     if Assigned(ASettings) then FreeMem(ASettings);
     DevMode:=Reader.ReadString;
     DevByte:=Length(DevMode) div 2;
     GetMem(ASettings,DevByte+1);
     try
       for i:=0 to DevByte-1 do begin
         ASettings^[i]:=Char(StrToInt('$'+Copy(DevMode,1+i+i,2)));
       end;
       //プリンタ番号を取得
       FPrinterNumber:=GetPrinterIndexFromString(FPrinterName);
     except
       FPrinterNumber:=-1;
     end;
     //ASettingsの値を用いてプリンタを設定
     SetPrinterInfo(FPrinterNumber);
end;
//====================================================================
//  設計時の各プロパティを読出す
//  Ver6.0より前のバージョンではコード内でASettingsから読んでいたが，
//  Ver6.0でストリームに保存するようにした．前のバージョンにはないの
//  で前のバージョンで作成したプロジェクトを最初に読込む時にエラーが
//  発生するので，try～exceptで回避．
//====================================================================
procedure TplSetPrinter.ReadDesignValues(Reader : TReader);
var
     Orient: Integer;
begin
     try
       Reader.ReadListBegin;
       FdsPrinterName   :=Reader.ReadString;
       Orient           :=Reader.ReadInteger;
       FdsPaperName     :=Reader.ReadString;
       FdsPaperNumber   :=Reader.ReadInteger;
       FdsBinNumber     :=Reader.ReadInteger;
       FdsDriverVersion :=Reader.ReadInteger;
       Reader.ReadListEnd;
       FdsOrientation:=TPrinterOrientation(Orient);
     except
       Abort;
     end;
end;
//====================================================================
//  設計時のプロパティをストリームに保存
//====================================================================
procedure TplSetPrinter.WriteDesignValues(Writer: TWriter);
var
     Orient: Integer;
begin
     try
       Orient:=Integer(FdsOrientation);
       Writer.WriteListBegin;
       Writer.WriteString(FdsPrinterName);
       Writer.WriteInteger(Orient);
       Writer.WriteString(FdsPaperName);
       Writer.WriteInteger(FdsPaperNumber);
       Writer.WriteInteger(FdsBinNumber);
       Writer.WriteInteger(FdsDriverVersion);
       Writer.WriteListEnd;
     except
     end;
end;
//====================================================================
//  PrinterCount(使用可能なプリンタ数)プロパティ取得
//====================================================================
function TplSetPrinter.GetFPrintersCount: Integer;
var
     Flags     : Integer;  //EnumPrinters に渡すフラグ
     InfoBytes : DWORD;    //プリンタ情報のバイト数
     nPrinters : Cardinal;
begin
     nPrinters := 0;
     //プリンタ情報を得る準備
     if Win32Platform = VER_PLATFORM_WIN32_NT then begin
       Flags := PRINTER_ENUM_CONNECTIONS or PRINTER_ENUM_LOCAL;
       PrinterInfoLevel := 4;
     end else begin
       Flags := PRINTER_ENUM_LOCAL;
       PrinterInfoLevel := 5;
     end;
     InfoBytes := 0;
     //バッファ長を得る
     EnumPrinters(Flags, nil, PrinterInfoLevel, nil, 0,InfoBytes, nPrinters);
     if InfoBytes <>0 then begin
       //バッファ確保
       SetLength(PrintersInfo, InfoBytes);
       //プリンタ情報(Level=4 or 5)を取得
       Win32Check(EnumPrinters(Flags, nil, PrinterInfoLevel,
                               Pointer(PrintersInfo),
                               InfoBytes, InfoBytes, nPrinters));
     end;
     Result:=nPrinters;
end;
//====================================================================
//  PrinterName(プリンタ名)プロパティ取得
//  Windows2k,XPであれば，ここで取得する文字列はADeviceと同じ．
//  Windows9Xの場合は，ADeviceにAPortが付加されたもの．
//====================================================================
function TplSetPrinter.GetPrinterName: String;
begin
     if FPrintersCount=0 then begin
       Result:='';
     end else begin
       Result:=GetPrinterNameFromString(FPrinterName);
     end;
end;
//====================================================================
//  PrinterName(プリンタ名)プロパティ設定
//
//  プリンタ名はPrinter.Printers[プリンタ番号]で取得した値で設定可能.
//  現在のプリンタならPrinter.Printers[Printer.PrinterIndex].
//  空文字列と存在しないプリンタ名を指定した場合はデフォルトのプリン
//  タに修正．
//====================================================================
procedure TplSetPrinter.SetPrinterName(Value: String);
begin
     if FPrintersCount=0 then exit;
     if Value<>FPrinterName then begin
       FPrinterName:=Value;
       //コンポのReadingとLoadingではこの後DevMode(ASettings)を読出す必要が
       //あるのでプリンタ名のセットのみ
       if csReading in ComponentState then exit;
       if csLoading in ComponentState then exit;

       if csDesigning in ComponentState then begin
         FPrinterNumber:=GetPrinterIndexFromString(FPrinterName);
         SetPrinterInfo(FPrinterNumber);
       end else begin;
         FPrinterNumber:=GetPrinterIndexFromString(FPrinterName);
         SetPrinterInfo(FPrinterNumber);
         //OnPrinterChangeイベントはプリンタ名に変更があった場合発生
         //ドライバが同じでもポート名付加となしの違いでもイベント発生
         if Assigned(FOnPrinterChange) then FOnPrinterChange(Self);
       end;
     end;
end;
//====================================================================
//  PrinterNumber(プリンタ番号)プロパティ設定
//  存在しないプリンタ番号と「隠されたプリンタ」を指定すると「通常使
//  用するプリンタ」に強制的に修正
//====================================================================
procedure TplSetPrinter.SetFPrinterNumber(const Value: Integer);
begin
     if FPrintersCount=0 then exit;
     if Value<>FPrinterNumber then begin
       FPrinterNumber:=Value;
       try
         FPrinterName:=Printer.Printers[FPrinterNumber];
       except
         FPrinterNumber:=-1;
       end;
       SetPrinterInfo(FPrinterNumber);
       //OnPrinterChangeイベントはプリンタ名に変更があった場合発生
       if Assigned(FOnPrinterChange) then FOnPrinterChange(Self);
     end;
end;
//====================================================================
//  引数の文字列からプリンタ番号を取得
//  引数のプリンタ名にはポート名が含んでいてもOK
//  見つからなかった時と「隠されたプリンタ」の場合は-1を返す
//====================================================================
function TplSetPrinter.GetPrinterIndexFromString(Str: String): Integer;
var
     Attributes: DWORD;
     APrinterName: String;
     i: Integer;
     UpperPrinterName: String;
     UpperPrinterStr: String;
begin
     Result:=-1;

     //登録されているプリンタの数だけ調査
     if Str<>'' then begin
       for i := 0 to FPrintersCount-1 do begin
         {プリンタの文字列を取得}
         if PrinterInfoLevel = 4 then begin
           Attributes := PPrinterInfo4Array(PrintersInfo)[i].Attributes;
           if (Attributes and PRINTER_ATTRIBUTE_HIDDEN)<>0 then Continue;
           APrinterName:=PPrinterInfo4Array(PrintersInfo)[i].pPrinterName;
         end else begin
           Attributes := PPrinterInfo5Array(PrintersInfo)[i].Attributes;
           if (Attributes and PRINTER_ATTRIBUTE_HIDDEN)<>0 then Continue;
           APrinterName:=PPrinterInfo5Array(PrintersInfo)[i].pPrinterName;
         end;
         //引数の文字列にその文字列があればその時のiの値がPrinterIndex
         //引数のプリンタ名にはポート名がついている場合があるので部分文字列として比較する
         //OSやドライバによる違いを吸収するために大文字に変換して比較する
         UpperPrinterStr :=AnsiUpperCase(APrinterName);
         UpperPrinterName:=AnsiUpperCase(Str);
         if AnsiPos(UpperPrinterStr,UpperPrinterName)>0 then begin
           Result := i;
           Break;
         end;
       end;
     end;
end;
//====================================================================
//  引数の文字列からポート名を除いたプリンタ名を取得
//  コードは返値がプリンタ名以外は，GetPrinterIndexFromStrと同じ
//====================================================================
function TplSetPrinter.GetPrinterNameFromString(Str: String): String;
var
     Attributes: DWORD;
     APrinterName: String;
     i: Integer;
     UpperPrinterName: String;
     UpperPrinterStr: String;
begin
     Result:='';

     if Str<>'' then begin
       for i := 0 to FPrintersCount-1 do begin
         if PrinterInfoLevel = 4 then begin
           Attributes := PPrinterInfo4Array(PrintersInfo)[i].Attributes;
           if (Attributes and PRINTER_ATTRIBUTE_HIDDEN)<>0 then Continue;
           APrinterName:=PPrinterInfo4Array(PrintersInfo)[i].pPrinterName;
         end else begin
           Attributes := PPrinterInfo5Array(PrintersInfo)[i].Attributes;
           if (Attributes and PRINTER_ATTRIBUTE_HIDDEN)<>0 then Continue;
           APrinterName:=PPrinterInfo5Array(PrintersInfo)[i].pPrinterName;
         end;
         UpperPrinterStr :=AnsiUpperCase(APrinterName);
         UpperPrinterName:=AnsiUpperCase(Str);
         if AnsiPos(UpperPrinterStr,UpperPrinterName)>0 then begin
           Result:=APrinterName;
           Break;
         end;
       end;
     end;
end;
//====================================================================
//  Port(ポート名)プロパティ取得
//====================================================================
function TplSetPrinter.GetPort: String;
begin
     if FPrintersCount=0 then begin
       Result:='';
     end else begin
       Result:=String(APort);
     end;
end;
//====================================================================
//  DriverVersion(ドライババージョン)プロパティ取得
//====================================================================
function TplSetPrinter.GetFDriverVersion: Integer;
var
     ADevMode : PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         Result:=ADevMode^.dmDriverVersion;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=0;
     end;
end;
//====================================================================
//  PaperName(用紙名)プロパティ取得
//
//  MJ-8000Cの連続帳票の用紙名が取得不可のものがある．
//  調査の結果,DC_PAPERSには情報が入っていない.どこにあるかは不明.
//
//  DeviceCapabilitie プリンタデバイスドライバの能力を取得するWin32
//  API関数DC_PAPERSに用紙サイズ(名称)の番号が入っている.
//  この値と,DEVMODE構造体から取得した用紙番号ADevMod^.dmPaperSize
//  が一致すれば,その番号目のDC_PAPERNAMESが用紙名となる.
//====================================================================
function TplSetPrinter.GetFPaperName: String;
var
     Count    : Integer;
     pB       : pPaperName;
     pB2      : pPaperNumber;
     i        : integer;
     ASizeNo  : Integer;
begin
     {とりあえず名前なしとする}
     Result:='';
     if FPrintersCount=0 then exit;
     ASizeNo:=GetFPaperNumber;

     //APortに接続しているプリンタADeviceの用紙名の数を取得
     Count:= DeviceCapabilities(ADevice,APort,DC_PAPERNAMES,nil,nil);
     if (Count=-1) or (Count=0) then exit;
     //その数分だけ用氏名と用紙番号の配列用メモリをpB,pB2に確保
     GetMem(pB,Count*sizeof(TPaperName));
     GetMem(pB2,Count*sizeof(TPaperNumber));
     try
       //確保したメモリに用紙名と用紙番号がある
       DeviceCapabilities(ADevice,APort,DC_PAPERNAMES,PChar(pB),nil);
       DeviceCapabilities(ADevice,APort,DC_PAPERS,PChar(pB2),nil);
       //順番に用紙番号が一致するものを調べる
       for i:=0 to Count-1 do begin
         //DEVMODE構造体の番号と一致したらループを抜けて
         if pB2^[i]=ASizeNo then begin
           Result:=String(pB^[i]);
           break;
         end;
       end;
     finally
       //メモリを解放
       FreeMem(pB2);
       FreeMem(pB);
     end;
end;
//====================================================================
//  PaperName(用紙名)プロパティ設定
//  用紙名は，同じ用紙サイズでもプリンタドライバによって名称が違うこ
//  とがあるので注意．
//====================================================================
procedure TplSetPrinter.SetFPaperName(const Value: String);
var
     PaperIndex : Integer;
begin
     if FPrintersCount=0 then exit;
     //該当する用紙名があればその用紙番号を取得してそれで設定する
     if CheckPaperName(Value,PaperIndex) then begin
       SetFPaperNumber(PaperIndex);
     end;
end;
//====================================================================
//  PaperNumber(用紙サイズ番号)プロパティ取得
//  ユーザ定義用紙の場合は，同じ用紙名でサイズも同じでもプリンタドラ
//  イバによって番号が違う．
//====================================================================
function TplSetPrinter.GetFPaperNumber: Integer;
var
     ADevMode : PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         try
           Result:=ADevMode^.dmPaperSize;
         except
           CheckPaperName(CustomPaperName,Result);
         end;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=0;
     end;
end;
//====================================================================
//  PaperNumber(用紙サイズ番号)プロパティ設定
//
//  【備考】
//  各プロパティ設定のコードを単独で使用する場合は，
//  var
//  ADevice,ADriver,APort: array[0..512] of Char;
//  hPrtHandle : THandle;
//  と定義しておき，
//  Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//  を実行してからメソッド内のコードを実行する．
//  複数のプロパティを同時に設定する場合は，設定部分に該当コードを追
//  加する．ただしこのコンポ専用のメソッドCopyDev...の部分は不要．
//====================================================================
procedure TplSetPrinter.SetFPaperNumber(const Value: Integer);
var
     ADevMode : PDeviceMode;
begin
     if FPrintersCount=0 then exit;

     CallSetting;
     ADevMode:=GlobalLock(hPrtHandle);
     try
       if (ADevMode^.dmFields and dm_PaperSize)<>0 then begin
         ADevMode^.dmPaperSize:=Value;
         ADevMode^.dmFields:=ADevMode^.dmFields and not(DM_PAPERWIDTH or DM_PAPERLENGTH);
         ModifyAndCopy(ADevMode);
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //DevModeをプロパティとしてASettingsに代入
     //DevSizeとASettingsの値を更新しておくことにより，いつでも最新
     //の状態となり，コンポーネントとしてアクセス可能(保存読出し操
     //作等)となり，プリンタを変更してもこのプロパティが有効になる．
     CopyDevModeToASettings;
end;
//====================================================================
//  Orientation(印刷の方向)プロパティ取得
//====================================================================
function TplSetPrinter.GetFOrientation: TPrinterOrientation;
var
     ADevMode : PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         if ADevMode^.dmOrientation=DMORIENT_PORTRAIT then begin
           Result:=poPortrait;
         end else begin
           Result:=poLandscape;
         end;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=poPortrait;
     end;
end;
//====================================================================
//  Orientation(印刷の方向)プロパティ設定
//  設定可能な値は以下の2つのみ
//  poPortrait  縦
//  poLandscape 横
//
//  【備考】
//  各プロパティ設定のコードを単独で使用する場合は，
//  var
//  ADevice,ADriver,APort: array[0..512] of Char;
//  hPrtHandle : THandle;
//  と定義しておき，
//  Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//  を実行してからメソッド内のコードを実行する．
//  複数のプロパティを同時に設定する場合は，設定部分に該当コードを追
//  加する．
//====================================================================
procedure TplSetPrinter.SetFOrientation(const Value: TPrinterOrientation);
var
     ADevMode : PDeviceMode;
begin
     if FPrintersCount=0 then exit;
     CallSetting;
     ADevMode:=GlobalLock(hPrtHandle);
     try
       if (ADevMode^.dmFields and dm_Orientation)<>0 then begin
         if Value=poPortrait  then ADevMode^.dmOrientation:=DMORIENT_PORTRAIT;
         if Value=poLandscape then ADevMode^.dmOrientation:=DMORIENT_LANDSCAPE;
         ModifyAndCopy(ADevMode);
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //DevModeをプロパティとしてASettingsに代入
     CopyDevModeToASettings;
end;
//====================================================================
//  BinName(ビン名)プロパティ取得
//====================================================================
function TplSetPrinter.GetFBinName: String;
var
     Count   : Integer;
     pB      : pBinName;
     pB2     : pBinNumber;
     i       : integer;
     ABinNo  : Integer;
begin
     //とりあえず名前なしとする
     Result:='';
     if FPrintersCount=0 then exit;
     ABinNo:=GetFBinNumber;

     //APortに接続しているプリンタADeviceのビンの数を取得
     Count:= DeviceCapabilities(ADevice,APort,DC_BINS,nil,nil);
     if (Count=-1) or (Count=0) then exit;
     //その数分だけビン名称とビン番号の配列用メモリをpB,pB2に確保
     GetMem(pB,Count*sizeof(TBinName));
     GetMem(pB2,Count*sizeof(TBinNumber));
     try
       //確保したメモリにビン名称とビン番号がある
       DeviceCapabilities(ADevice,APort,DC_BINNAMES,PChar(pB),nil);
       DeviceCapabilities(ADevice,APort,DC_BINS,PChar(pB2),nil);
       //順番にビン番号が一致するものを調べる
       for i:=0 to Count-1 do begin
         //DEVMODE構造体の番号と一致したらループを抜ける
         if Integer(pB2^[i])=ABinNo then begin
           Result:=String(pB^[i]);
           break;
         end;
       end;
     finally
       //メモリを解放
       FreeMem(pB2);
       FreeMem(pB);
     end;
end;
//====================================================================
//  BinName(ビン名)プロパティ設定
//====================================================================
procedure TplSetPrinter.SetFBinName(const Value: String);
var
     Count   : Integer;
     pB      : pBinName;
     pB2     : pBinNumber;
     i       : integer;
     ABinNum : Integer;
     Flag    : Boolean;
begin
     if FPrintersCount=0 then exit;
     Count:= DeviceCapabilities(ADevice,APort,DC_BINS,nil,nil);
     if (Count=-1) or (Count=0) then exit;
     Flag:=False;
     GetMem(pB,Count*sizeof(TBinName));
     GetMem(pB2,Count*sizeof(TBinNumber));
     try
       DeviceCapabilities(ADevice,APort,DC_BINNAMES,PChar(pB),nil);
       DeviceCapabilities(ADevice,APort,DC_BINS,PChar(pB2),nil);
       for i:=0 to Count-1 do begin
         if Value=String(pB^[i]) then begin
           ABinNum:=pB2^[i];
           Flag:=True;
           break;
         end;
       end;
     finally
       FreeMem(pB2);
       FreeMem(pB);
     end;
     if Flag then SetFBinNumber(ABinNum);
end;
//====================================================================
//  BinNunmbe(ビン番号名)プロパティ取得
//====================================================================
function TplSetPrinter.GetFBinNumber: Integer;
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         Result:=ADevMode^.dmDefaultSource;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=0;
     end;
end;
//====================================================================
//  BinNunmbe(ビン番号名)プロパティ設定
//
//  【備考】
//  各プロパティ設定のコードを単独で使用する場合は，
//  var
//  ADevice,ADriver,APort: array[0..512] of Char;
//  hPrtHandle : THandle;
//  と定義しておき，
//  Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//  を実行してからメソッド内のコードを実行する．
//  複数のプロパティを同時に設定する場合は，設定部分に該当コードを追
//  加する．
//====================================================================
procedure TplSetPrinter.SetFBinNumber(const Value: Integer);
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount=0 then exit;
     CallSetting;
     ADevMode:=GlobalLock(hPrtHandle);
     try
       if (ADevMode^.dmFields and dm_DefaultSource)<>0 then begin
         ADevMode^.dmDefaultSource:=Value;
         ModifyAndCopy(ADevMode);
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //DevModeをプロパティとしてASettingsに代入
     CopyDevModeToASettings;
end;
//====================================================================
//  ColorBit(カラービット数)プロパティ取得
//  ColorBitプロパティは読出し専用
//  カラー機能があってもモノクロに設定してあれば0.カラー機能なしも0
//====================================================================
function TplSetPrinter.GetFColorBit: Integer;
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         if ADevMode^.dmColor=DMCOLOR_COLOR then begin
           Result:=GetDeviceCaps(Printer.Handle,BITSPIXEL)*GetDeviceCaps(Printer.Handle,PLANES);
         end else begin
           Result:=0;
         end;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=0;
     end;
end;
//====================================================================
//  Color(カラー・モノクロ)プロパティ取得
//  値は以下のいづれか
//  DMCOLOR_MONOCHROME
//  DMCOLOR_COLOR
//====================================================================
function TplSetPrinter.GetColor: Integer;
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         Result:=ADevMode^.dmColor;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=DMCOLOR_MONOCHROME;
     end;
end;
//====================================================================
//  Color(カラー・モノクロ)プロパティ設定
//  値は以下のいづれか
//  DMCOLOR_MONOCHROME
//  DMCOLOR_COLOR
//
//  【備考】
//  各プロパティ設定のコードを単独で使用する場合は，
//  var
//  ADevice,ADriver,APort: array[0..512] of Char;
//  hPrtHandle : THandle;
//  と定義しておき，
//  Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//  を実行してからメソッド内のコードを実行する．
//  複数のプロパティを同時に設定する場合は，設定部分に該当コードを追
//  加する．
//====================================================================
procedure TplSetPrinter.SetColor(const Value: Integer);
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount=0 then exit;
     CallSetting;
     ADevMode:=GlobalLock(hPrtHandle);
     try
       if (ADevMode^.dmFields and dm_Color)<>0 then begin
         ADevMode^.dmColor:=Value;
         ModifyAndCopy(ADevMode);
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //DevModeをプロパティとしてASettingsに代入
     CopyDevModeToASettings;
end;
//====================================================================
//  Collate(部単位で印刷)プロパティ取得
//  値は以下のいづれか
//  DMCOLLATE_TRUE
//  DMCOLLATE_FALSE
//====================================================================
function TplSetPrinter.GetCollate: Integer;
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         Result:=ADevMode^.dmCollate;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=DMCOLLATE_FALSE;
     end;
end;
//====================================================================
//  Collate(部単位で印刷)プロパティ設定
//  設定可能な値は以下のいづれか
//  DMCOLLATE_TRUE
//  DMCOLLATE_FALSE
//  印刷部数が1の時は設定不可．印刷部数が2以上の時は先に印刷部数を設
//  定しておく．
//
//  【備考】
//  各プロパティ設定のコードを単独で使用する場合は，
//  var
//  ADevice,ADriver,APort: array[0..512] of Char;
//  hPrtHandle : THandle;
//  と定義しておき，
//  Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//  を実行してからメソッド内のコードを実行する．
//  複数のプロパティを同時に設定する場合は，設定部分に該当コードを追
//  加する．
//
//  [プロパティ]のダイアログには[部単位で印刷]があるが，DevModeでは読
//  書できないドライバがある．
//  このようなプリンタでは印刷のルーチンでシミュレートする必要がある．
//====================================================================
procedure TplSetPrinter.SetCollate(const Value: Integer);
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount=0 then exit;
     CallSetting;
     ADevMode:=GlobalLock(hPrtHandle);
     try
       if (ADevMode^.dmFields and dm_Collate)<>0 then begin
         if ADevMode^.dmCopies>=2 then begin
           ADevMode^.dmCollate:=Value;
           ModifyAndCopy(ADevMode);
         end;
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //DevModeをプロパティとしてASettingsに代入
     CopyDevModeToASettings;
end;
//====================================================================
//  Copies(印刷部数)プロパティ取得
//====================================================================
function TplSetPrinter.GetCopies: Integer;
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         Result:=ADevMode^.dmCopies;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=1;
     end;
end;
//====================================================================
//  Copies(印刷部数)プロパティ設定
//
//  【備考】
//  各プロパティ設定のコードを単独で使用する場合は，
//  var
//  ADevice,ADriver,APort: array[0..512] of Char;
//  hPrtHandle : THandle;
//  と定義しておき，
//  Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//  を実行してからメソッド内のコードを実行する．
//  複数のプロパティを同時に設定する場合は，設定部分に該当コードを追
//  加する．
//====================================================================
procedure TplSetPrinter.SetCopies(const Value: Integer);
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount=0 then exit;
     CallSetting;
     ADevMode:=GlobalLock(hPrtHandle);
     try
       if (ADevMode^.dmFields and dm_Copies)<>0 then begin
         ADevMode^.dmCopies:=Value;
         //印刷部数が1の時は部単位の印刷は無効に
         if Value<=1 then begin
           if (ADevMode^.dmFields and dm_Collate)<>0 then begin
             ADevMode^.dmCollate:=DMCOLLATE_FALSE;
           end;
         end;
         ModifyAndCopy(ADevMode);
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //DevModeをプロパティとしてASettingsに代入
     CopyDevModeToASettings;
end;
//====================================================================
//  Duplex(両面印刷)プロパティ取得
//  値は以下のいづれか
//  DMDUP_SIMPLEX
//  DMDUP_HORIZONTAL
//  DMDUP_VERTICAL
//====================================================================
function TplSetPrinter.GetDuplex: Integer;
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         Result:=ADevMode^.dmDuplex;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=DMDUP_SIMPLEX;
     end;
end;
//====================================================================
//  Duplex(両面印刷)プロパティ設定
//
//  【備考】
//  各プロパティ設定のコードを単独で使用する場合は，
//  var
//  ADevice,ADriver,APort: array[0..512] of Char;
//  hPrtHandle : THandle;
//  と定義しておき，
//  Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//  を実行してからメソッド内のコードを実行する．
//  複数のプロパティを同時に設定する場合は，設定部分に該当コードを追
//  加する．
//====================================================================
procedure TplSetPrinter.SetDuplex(const Value: Integer);
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount=0 then exit;
     CallSetting;
     ADevMode:=GlobalLock(hPrtHandle);
     try
       if (ADevMode^.dmFields and dm_Duplex)<>0 then begin
         ADevMode^.dmDuplex:=Value;
         ModifyAndCopy(ADevMode);
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //DevModeをプロパティとしてASettingsに代入
     CopyDevModeToASettings;
end;
//====================================================================
//  以下のプロパティの取得用の共通関数
//
//  1. XResolution(横方向解像度)プロパティ
//  2. YResolution(縦方向解像度)プロパティ
//  3. PeperWidth(用紙幅)プロパティ
//  4. PagperHeight(用紙高さ・長さ)プロパティ
//  5. PageWidth(印刷可能幅)プロパティ
//  6. PageHeight(印刷可能高さ・長さ)プロパティ
//  7. TopOffset(上端オフセット)プロパティ
//  8. BottomOffset(下端オフセット値)プロパティ
//  9. LeftOffset(左端オフセット値)プロパティ
//  10.RightOffset(右端オフセット)プロパティ
//====================================================================
function TplSetPrinter.GetDeviceCapsValues(const Index: Integer): Integer;
var
     hPrt : THandle;
begin
     if FPrintersCount>0 then begin
       OpenPrinter(ADevice,hPrt,nil);
       try
         case Index of
           //横と縦方向の解像度
           1:  Result := GetDeviceCaps(Printer.Handle,LOGPIXELSX);
           2:  Result := GetDeviceCaps(Printer.Handle,LOGPIXELSY);
           //用紙幅と高さ
           3:  Result := GetDeviceCaps(Printer.Handle,PHYSICALWIDTH);
           4:  Result := GetDeviceCaps(Printer.Handle,PHYSICALHEIGHT);
           //印刷可能領域の幅と高さ
           5:  Result := GetDeviceCaps(Printer.Handle,HORZRES);
           6:  Result := GetDeviceCaps(Printer.Handle,VERTRES);
           //上下左右のオフセット
           7:  Result := GetDeviceCaps(Printer.Handle,PHYSICALOFFSETY);
           8:  Result := GetDeviceCaps(Printer.Handle,PHYSICALOFFSETY)+GetDeviceCaps(Printer.Handle,VERTRES);
           9:  Result := GetDeviceCaps(Printer.Handle,PHYSICALOFFSETX);
           10: Result := GetDeviceCaps(Printer.Handle,PHYSICALOFFSETX)+GetDeviceCaps(Printer.Handle,HORZRES);
         end;
       finally
         ClosePrinter(hPrt);
       end;
     end else begin
       Result:=0;
     end;
end;
//====================================================================
//  実行時のユーザ定義用紙作成メソッド
//
//  このメソッド実行後はここで設定した内容がプリンタのデフォルトの設
//  定値となる(プリンタを変更してもここで設定した用紙が選択される)．
//
//  2002.3.5 Ver. 4.1からの機能　
//  UserPaperName 用紙リストに表示する用紙名の文字列.半角63文字以内
//  CustomW  用紙の幅を0.1mm単位で指定
//           (FORM_INFO_1構造体では1/1000で指定する)
//  CustomH  用紙の高さを0.1mm単位で指定(同上)
//====================================================================
function TplSetPrinter.SetUserPaper(UserPaperName: String; CustomW,
  CustomH: Integer): Boolean;
begin
     Result:=False;
     if FPrintersCount=0 then exit;

     //WindowsNT,Windows2000
     if Win32Platform=VER_PLATFORM_WIN32_NT then begin
       SetUserPaperNT(UserPaperName,CustomW,CustomH);
       Result:=CheckSetUserPaper(CustomW,CustomH);
     //Windows95,98
     end else begin
       SetUserPaper95(CustomW,CustomH);
       Result:=CheckSetUserPaper(CustomW,CustomH);
     end;
     //DevModeをプロパティとしてASettingsに代入
     if Result then begin
       if CustomPaperName='' then CustomPaperName:='plCustomPaper';
       CopyDevModeToASettings;
     end else begin
       CustomPaperName:='';
     end;
end;
//====================================================================
//  ユーザ定義用紙作成関係メソッド
//
//  用紙のサイズを再取得してユーザ定義用紙の成功をチェック
//  用紙名だけセットされていてもサイズ設定に失敗している場合があるの
//  でサイズで確認．
//====================================================================
function TplSetPrinter.CheckSetUserPaper(CustomW,CustomH: Integer): Boolean;
var
     Temp    : Integer;
     APaperW : Integer;
     APaperH : Integer;
begin
     APaperW:=Ceil(GetDeviceCapsValues(3)*254.0 /GetDeviceCapsValues(1));
     APaperH:=Ceil(GetDeviceCapsValues(4)*254.0/GetDeviceCapsValues(2));

     //印刷の向きが横の時は縦が逆となる
     if GetFOrientation=poLandscape then begin
       Temp   :=APaperW;
       APaperW:=APaperH;
       APaperH:=Temp;
     end;
     //プラス1マイナス2以内だったら成功とする
     Result:=(CustomW<=(APaperW+2)) and (CustomW>=(APaperW-2)) and
             (CustomH<=(APaperH+2)) and (CustomH>=(APaperH-2));
end;
//====================================================================
//  ユーザ定義用紙の作成
//  Windows95,Windows98用のルーチン(WindowsMEは未確認)
//
//  Hewlett Packard社のDeskJetシリーズの場合[ユーザ定義]ではなく[カス
//  タム]と言う名称となっていて,PaperSizeが274となっている.しかし
//  DEVEMODE構造体の各変数に
//         dmPaperSize   :=274;
//         dmPaperLength :=用紙長さ;
//         dmPaperWidth  :=用紙幅;
//  の様に設定しても,結果に設定したサイズを取得できない.現在の著者の
//  知識と実力では不可(NECのPICTY(PaperSize257)シリーズも同じ)
//  dmExtra部の情報がないと無理(表示プログラムを作成したが??)
//====================================================================
function TplSetPrinter.SetUserPaper95(CustomW,CustomH: Integer): Boolean;
var
     ADevMode : PDeviceMode;
     Mode     : DWORD;
     hPrt     : THandle;
begin
     Result:= False;
     ADevMode:=GlobalLock(hPrtHandle);
     try
       try
         //用紙番号とサイズをDEVMODE構造体にセット
         ADevMode^.dmPaperSize  :=DMPAPER_USER;
         ADevMode^.dmPaperLength:=CustomH;
         ADevMode^.dmPaperWidth :=CustomW;
         ADevMode^.dmFields     :=ADevMode^.dmFields or DM_PAPERSIZE or
                                  DM_PAPERLENGTH or DM_PAPERWIDTH;
         OpenPrinter(ADevice,hPrt,nil);
         Mode:=DM_MODIFY or DM_COPY;
         try
           DocumentProperties(Application.Handle,hPrt,ADriver,ADevMode^,ADevMode^,Mode);
         finally
           ClosePrinter(hPrt);
         end;
       except
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
end;
//====================================================================
//  ユーザ定義用紙の作成
//  WindowsNT4(SP6),Windows2000(SP2)のルーチン
//  PowerUser(一般ユーザ)以上でないとユーザ定義用紙の作成は不可
//  既にユーザ定義用紙が作成済みであればUsersでもSetFormが可能(現在
//  のプリンタに用紙リストを追加可能)
//====================================================================
function TplSetPrinter.SetUserPaperNT(UserPaperName: String; CustomW,
  CustomH: Integer): Boolean;
var
     ADevMode  : PDeviceMode;
     Mode      : DWORD;
     hPrt      : THandle;
     pCustName : array[0..63] of char;
     Info_1    : TFORMINFO1;
     pInfo_1   : Pointer;
     Pdef      : PRINTER_DEFAULTS;
     fgPaper   : Boolean;
     SizeNo    : Integer;
begin
     Result   := False;
     if FPrintersCount=0 then exit;

     strPCopy(pCustName,UserPaperName);
     pInfo_1 := @Info_1;

     //WindowsNT,2000の場合アクセス権が必要
     //管理者の権限でサーバのプロパティに用紙名を追加
     ZeroMemory(@Pdef,Sizeof(PRINTER_DEFAULTS));
     Pdef.DesiredAccess := PRINTER_ALL_ACCESS;
     OpenPrinter(ADevice,hPrt,@Pdef);
     //用紙名の有無をチェック
     fgPaper:=CheckPaperName(UserPaperName,SizeNo);
     try
       Info_1.Flags         := FORM_USER;
       Info_1.pName         := PChar(UserPaperName);
       Info_1.Size.cx       := CustomW*100;
       Info_1.Size.cy       := CustomH*100;
       Info_1.ImageableArea := Rect(0,0,CustomW*100,CustomH*100);
       //設定すべき用紙サイズが存在する場合はサイズ情報のみ設定
       //設定すべき用紙サイズが存在する場合はそれをそのまま使用する考え方もある
       if fgPaper then begin
         SetForm(hPrt,pCustName,1,pInfo_1);
       //設定すべき用紙サイズが存在しない場合は用紙を作成
       end else begin
         //一度用紙サイズが範囲外で設定すると存在する用紙名でもリストに出ない
         //ここでSetFormを実行すると表示される
         //AddFormはSetFormも兼ねているらしい
         if AddForm(hPrt,1,pInfo_1)=False then begin
           SetForm(hPrt,pCustName,1,pInfo_1);
         end;
       end;
     finally
       ClosePrinter(hPrt);
     end;

     //現在のプリンタに用紙名を追加
     ADevMode:= GlobalLock(hPrtHandle);
     strPCopy(ADevMode^.dmFormName,UserPaperName);

     //追加された用紙名の番号をSizeNoに取得
     Result:=CheckPaperName(UserPaperName,SizeNo);
     if Result=False then SizeNo:=DMPAPER_USER;
     try
       try
         //用紙番号とサイズをDEVMODE構造体にセット
         //dmPaperSizeがこの時点でセットされないドライバがあったが(作成後に[プ
         //リンタの設定]ダイアログの用紙名欄に作成した用紙名が選択状態にになら
         //ない)，dmFieldsのフラグを全て外す(該当部分のコードを削除)とOKのよう
         //である．
         ADevMode^.dmPaperSize  :=SizeNo;
         ADevMode^.dmPaperLength:=CustomH;
         ADevMode^.dmPaperWidth :=CustomW;
         CustomPaperName  :=UserPaperName;
         OpenPrinter(ADevice,hPrt,nil);
         Mode:=DM_MODIFY or DM_COPY;
         try
           DocumentProperties(Application.Handle,hPrt,ADriver,ADevMode^,ADevMode^,Mode);
         finally
           ClosePrinter(hPrt);
         end;
       except
         Result:=False;
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //AddFormで追加しても,リストで見られない用紙名は削除しておく
     if Result=False then DeleteUserPaper(UserPaperName);
end;
//====================================================================
//  ユーザ定義用紙の削除
//  Administratorsでないと削除不可の様である
//  Windows96,98の場合は常にTrue(実際に削除するわけではない),定義用紙
//  がない場合もTrue
//====================================================================
function TplSetPrinter.DeleteUserPaper(UserPaperName: String): Boolean;
var
     hPrt    : THandle;
     Pdef    : PRINTER_DEFAULTS;
     fgPaper : Boolean;
     SizeNo  : Integer;
begin
     if FPrintersCount=0 then exit;
     if Win32Platform=VER_PLATFORM_WIN32_NT then begin
       Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
       {WindowsNT,2000の場合アクセス権が必要}
       ZeroMemory(@Pdef,Sizeof(PRINTER_DEFAULTS));
       Pdef.DesiredAccess := PRINTER_ALL_ACCESS;

       OpenPrinter(ADevice,hPrt,@Pdef);
       {用紙名の有無をチェック}
       fgPaper:=CheckPaperName(UserPaperName,SizeNo);
       try
         if fgPaper then begin
           Result:=DeleteForm(hPrt,PChar(UserPaperName));
         end else begin
           Result:=True;
         end;
       finally
         ClosePrinter(hPrt);
       end;
       Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     end else begin
       Result:=True;
     end;
     if Result then CustomPaperName:='';
end;
//====================================================================
//  ユーザ定義用紙作成関係メソッド
//
//  指定の用紙名があるかのチェック
//  SetCustPapeで使用
//====================================================================
function TplSetPrinter.CheckPaperName(UserPaperName:String; var pNo:Integer): Boolean;
var
      Count,i  : Integer;
      pB       : pPaperName;
      pB2      : pPaperNumber;
      fgPaperName: String;
begin
     Result:=False;
     if FPrintersCount=0 then exit;

     pNo:=-1;
     {用紙名}
     fgPaperName:=UserPaperName;
     {APortに接続しているプリンタADeviceの用紙名の数を取得}
     Count:= DeviceCapabilities(ADevice,APort,DC_PAPERNAMES,nil,nil);
     {その数分だけ用氏名と用紙番号の配列用メモリをpB,pB2に確保}
     GetMem(pB,Count*sizeof(TPaperName));
     GetMem(pB2,Count*sizeof(TPaperNumber));
     try
       {確保したメモリに用紙名と用紙番号がある}
       DeviceCapabilities(ADevice,APort,DC_PAPERNAMES,PChar(pB),nil);
       DeviceCapabilities(ADevice,APort,DC_PAPERS,PChar(pB2),nil);
       {順番に用紙名が一致するものを調べる}
       for i:=0 to Count-1 do begin
         if fgPaperName=String(pB^[i]) then begin
           Result:=True;
           pNo:=pB2^[i];
           break;
         end;
       end;
     finally
       {メモリを解放}
       FreeMem(pB2);
       FreeMem(pB);
     end;
end;
//====================================================================
//  PritnerList(読出し専用)プロパティ用
//  プリンタ名一覧を取得．リストはプリンタ番号順ではなくABC順
//  プリンタ名一覧をFPrinterNameListにプリンタ番号順にセットする
//====================================================================
function TplSetPrinter.GetPrinterList: TStringList;
var
     i: Integer;
begin
     //リストを空に
     FPrinterList.Clear;
     FPrinterList.Sort;

     if FPrintersCount>0 then begin
       {一覧に追加}
       for i := 0 to FPrintersCount-1 do begin
         if PrinterInfoLevel = 4 then begin
           if (PPrinterInfo4Array(PrintersInfo)[i].Attributes and
                                  PRINTER_ATTRIBUTE_HIDDEN) = 0 then begin
             FPrinterList.Add(PPrinterInfo4Array(PrintersInfo)[i].pPrinterName);
           end;
         end else begin
           if (PPrinterInfo5Array(PrintersInfo)[i].Attributes and
                                  PRINTER_ATTRIBUTE_HIDDEN) = 0 then begin
             FPrinterList.Add(PPrinterInfo5Array(PrintersInfo)[i].pPrinterName);
           end;
         end;
       end;
     end;
     Result:=FPrinterList;
end;
//====================================================================
//  PaperList(読出し専用)プロパティ用
//  用紙サイズ一覧を取得
//====================================================================
function TplSetPrinter.GetPaperList: TStringList;
var
     Count: Integer;
     pB: pPaperName;
     i: integer;
begin
     //リストを空にする
     FPaperList.Clear;
     //APortに接続しているプリンタADeviceの用紙名の数を取得
     Count:= DeviceCapabilities(ADevice,APort,DC_PAPERNAMES,nil,nil);
     if Count>0 then begin
       //その数分だけ用氏名と用紙番号の配列用メモリをpBに確保
       GetMem(pB,Count*sizeof(TPaperName));
       try
         //確保したメモリに用紙名がある
         DeviceCapabilities(ADevice,APort,DC_PAPERNAMES,PChar(pB),nil);
         for i:=0 to Count-1 do begin
           FPaperList.Add(String(pB^[i]));
         end;
       finally
         FreeMem(pB);
       end;
     end;
     Result:=FPaperList;
end;
//====================================================================
//  BinList(読出し専用)プロパティ用
//  給紙装置の一覧を取得
//====================================================================
function TplSetPrinter.GetBinList: TStringList;
var
     Count : Integer;
     pB    : pBinName;
     i     : integer;
begin
     //リストを空にする
     FBinList.Clear;
     //APortに接続しているプリンタADeviceのビンの数を取得
     Count:= DeviceCapabilities(ADevice,APort,DC_BINS,nil,nil);
     if (Count>0) then begin
       //その数分だけビン名称とビン番号の配列用メモリをpB,pB2に確保
       GetMem(pB,Count*sizeof(TBinName));
       try
         //確保したメモリにビン名称とビン番号がある
         DeviceCapabilities(ADevice,APort,DC_BINNAMES,PChar(pB),nil);
         //順番にビン名称の文字列をリストに代入
         //この文字列は同じ用紙でもドライバによって違う場合がある
         for i:=0 to Count-1 do begin
           FBinList.Add(String(pB^[i]));
         end;
       finally
         {メモリを解放}
         FreeMem(pB);
       end;
     end;
     Result:=FBinList;
end;
//====================================================================
//  [プリンタの設定]ダイアログ(TPrinterSetupDialog)を表示
//  別コンポーネントではなく，内部で生成するようにした．
//  [OK]で終了すると設定したプリンタの情報をコンポの情報に置換．
//====================================================================
function TplSetPrinter.ShowSetupDialog: Boolean;
var
     ADialog : TPrinterSetupDialog;
begin
     ADialog:=TPrinterSetupDialog.Create(Self);
     ADialog.OnShow :=ForSetupDialogOnShow;
     ADialog.OnClose:=ForSetupDialogOnClose;
     ADialog.Name   :=Self.Name+'SetupDialog';
     try
       Result:=ADialog.Execute;
       if Result then GetPrinterInfo;
     finally
       ADialog.Free;
     end;
end;
//====================================================================
//  [プリンタの設定]ダイアログ表示ShowSetupDialogメソッド用
//  ダイアログのOnShowイベント
//====================================================================
procedure TplSetPrinter.ForSetupDialogOnShow(Sender: TObject);
begin
     if Assigned(FOnSetupDialogShow) then FOnSetupDialogShow(Sender);
end;
//====================================================================
//  [プリンタの設定]ダイアログ表示ShowSetupDialogメソッド用
//  ダイアログのOnCloseイベント
//====================================================================
procedure TplSetPrinter.ForSetupDialogOnClose(Sender: TObject);
begin
     if Assigned(FOnSetupDialogClose) then FOnSetupDialogClose(Sender);
end;
//====================================================================
//  コンポーネントを指定ファイルに保存
//====================================================================
function TplSetPrinter.SaveToFile(AFile: String): Boolean;
var
     AStream: TFileStream;
begin
     AStream:=TFileStream.Create(AFile,fmCreate or fmShareDenyNone);
     try
       try
         AStream.WriteComponent(Self);
         Result:=True;
       except
         Result:=False;
       end;
     finally
       AStream.Free;
     end;
end;
//====================================================================
//  コンポーネントをファイルから読出す
//  このメソッド実行後は，この読出した内容がコンポーネントの内容．
//====================================================================
function TplSetPrinter.LoadFromFile(AFile: String): Boolean;
var
     AStream: TFileStream;
begin
     Result:=False;
     //該当ファイルがなければFalseで終了
     if not FileExists(AFile) then exit;
     AStream:=TFileStream.Create(AFile,fmOpenRead or fmShareDenyNone);
     try
       try
         //以前はTComponent(Self):=AStream.ReadComponent(Self)の形式を使用
         AStream.ReadComponent(Self);
         Result:=True;
       except
         Result:=False;
       end;
     finally
       AStream.Free;
     end;
end;
//====================================================================
//   現在のプリンタの情報取得  公開メソッド
//   NkPrinterなど他の手段によるプリンタの設定を利用するための機能．
//   一応デフォルトの値の取得も可能にしておいた．
//   このメソッド実行後は，取得したプロパティがデフォルトとなり，プリ
//   ンタ名またはプリンタ番号でプリンタを指定すると，このプロパティの
//   値(DevModeの内容)をマージする．プリンタドライバによってはマージが
//   成功するとは限らない．
//
//
//
//   ADevice    プリンタ名　　　　　　　　　
//   ADriver    ドライバ名
//   APort      ポート名
//   hPrtHandle プリンタデバイスドライバのハンドル
//
//   GetFlag
//   True  プリンタのデフォルト値
//   False プリンタの現在の設定値
//
//   【備考】
//   プリンタの情報取得の3行の意味
//
//   (1) Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//   (2) Printer.SetPrinter(ADevice,ADriver,APort,0);
//   (3)Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//
//   (1) ここのGetPrinterで取得できるADevModeは変更前の値
//       ADevec,ADriverは変更後の値
//   (2) SetPrinterでhPrtHandleに0を指定すると変更後のADevMode値が取
//       得できる
//   (3) SetPrinterで取得したはずのAdevModeを実際に取得できる
//
//   この一連の動作はTPrinterオブジェクトの仕様
//====================================================================
procedure TplSetPrinter.GetPrinterInfo(GetFlag:Boolean=False);
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount=0 then exit;
     //プリンタ番号と名前を取得
     FPrinterName  :=Printer.Printers[Printer.PrinterIndex];
     FPrinterNumber:=GetPrinterIndexFromString(FPrinterName);
     if GetFlag then begin
       //現在のプリンタで初期化
       Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
       Printer.SetPrinter(ADevice,ADriver,APort,0);
       Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
     end else begin
       Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
     end;

     ADevMode:=GlobalLock(hPrtHandle);
     try
       ModifyAndCopy(ADevMode);
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //DevModeをプロパティとしてASettingsに代入
     CopyDevModeToASettings;
end;
//====================================================================
//  プリンタの設定(DevModeをマージする)  非公開メソッド
//  本コンポの核心部
//
//  Win32APIの説明ではDevSizeの取得にDocumentPropertiesのMode=0 にす
//  る記載があるが，現在のところGlobalSizeで取得するサイズと変化ない
//  のでこちらを使用している．他のプロパティ取得メソッドもこれと同じ
//  コードとしている．
//  プリンタドライバによってはマージが成功するとは限らない．
//
//  ADevice    プリンタ名　　　　　　　　
//  ADriver    ドライバ名
//  APort      ポート名
//  hPrtHandle プリンタドライバのハンドル
//====================================================================
procedure TplSetPrinter.SetPrinterInfo(Index: Integer);
var
     hPrt       : THandle;
     ADevMode   : PDeviceMode;
     NewDevSize : Integer;
     Mode       : DWORD;
begin
     if FPrintersCount=0 then exit;

     //プリンタ番号のプリンタのデフォルト値を求める
     //このデフォルト値とマージする
     Printer.PrinterIndex:=Index;
     FPrinterNumber:=Printer.PrinterIndex;
     FPrinterName  :=Printer.Printers[FPrinterNumber];
     Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
     Printer.SetPrinter(ADevice,ADriver,APort,0);
     Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);

     //ハンドルhPrtHandleをロック,最初のバイトのポインタADevModeを取得
     ADevMode   :=GlobalLock(hPrtHandle);
     NewDevSize :=GlobalSize(hPrtHandle);
     Mode       :=DM_MODIFY or DM_COPY;

     try
       //ASettings値があればDevMode情報をコピー
       //設計時のASettingsの値は最初にコンポを配置した時は空で，この後
       //のCopyDevModeToStettingsでストリームに保存される．
       //設計時にプリンタを変更するとストリームに保存された前のプリンタ
       //の内容となっていて，同じくこの後のCopyDev...で置換わる．
       //実行時は設計時の値が入っているが，プロパティを変更すると変更後の
       //内容となっている
       //アクセス違反発生防止(TAKさんサンクス Ver5.1で修正．指摘されてみ
       //れば明らかなのですが，なかなか気づかないものです)
       if Assigned(ASettings) then begin
         if NewDevSize>DevSize then begin
           System.Move(ASettings^,ADevMode^,DevSize);
         end else begin
           System.Move(ASettings^,ADevMode^,NewDevSize);
         end;
         Application.ProcessMessages;
       end;
       OpenPrinter(ADevice,hPrt,nil);
       try
         //プリンタ変更後の[プリンタの設定]ダイアログの表示の問題
         //Windows2k,XPの場合(Application.Handle,...)でないとダイアログの表示
         //が更新されないドライバがある([プロパティ]で確認すると設定は反映さ
         //れている)．また，(Application.Handle,hPrt,...)の場合，プリンタの切
         //換連続テストの結果で，まれに例外が発生する．実験結果では，特定のプ
         //リンタの場合に発生している(テストしたPCによっても違う)．再度実行す
         //ると発生しない．コンパイル実行の最初のみ発生している．原因不明．
         //(Application.Handle,0,...)では発生しない．
         //一方，Windows9Xでは，このコードでは[プリンタが見つかりません]のエラ
         //ーが発生してしまう．そこで以下の様に処理を分けている．
         //なお，(0,hPrt,...)ではほとんどダイアログの表示は更新されない．
         //(Application.Handle,0,,,,)であってもOpenPrinterを実行しないと，やは
         //りダイアログの表示が更新されないドライバがある．
         try
           if Win32Platform=VER_PLATFORM_WIN32_NT then begin
             DocumentProperties(Application.Handle,0,ADriver,ADevMode^,ADevMode^,Mode);
           end else begin
             DocumentProperties(Application.Handle,hPrt,ADriver,ADevMode^,ADevMode^,Mode);
           end;
         except
           //Assert(ID=0);
           //失敗したら強制的にマージを中止
           //著者の調査範囲ではここにくるものは現在のところなし．
         end;
       finally
         ClosePrinter(hPrt);
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //設計時にはDevModeをASettingsにコピー
     if csDesigning in ComponentState then CopyDevModeToASettings;
end;
//====================================================================
//  コンポのプリンタのプロパティ設定アログを表示する
//  公開メソッドShowDialogで使用
//
//  ここで各種の設定を行う.
//  設計時はここで設定したプロパティをストリームに保存
//  (これがこのコンポの売りであったのだが...　Ver6.0でほとんどのプロ
//  パティを書込み可能にしてしまったので，意味がなくなってしまったの
//  かも知れないが，ドライバ固有のプロパティの設定はこのダイアログで
//  ないと設定できない)．
//  実行時は一時的な変更やプロパティのIniファイル等への保存に使用
//
//  [OK]で閉じるとTrueを，[キャンセル]で閉じるとFalseを返す
//
//  【備考】
//  このプリンタのプロパティ設定ダイアログのコードを単独で使用する場
//  合は，
//  var
//  ADevice,ADriver,APort: array[0..512] of Char;
//  hPrtHandle : THandle;
//  と定義しておき，
//  Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//  を実行してからメソッド内のコードを実行する．
//
//  Ver6.04
//  Ver6.00の時の修正でテストのため外していたコードを元に戻さずUPして
//  いたのを修正．これがないと，プリンタの現在の設定がダイアログに反
//  映しない．
//====================================================================
function TplSetPrinter.EditPrinterInfo: Boolean;
var
     hPrt     : THandle;
     IDNo     : Integer;
     Mode     : DWORD;
     ADevMode : PDeviceMode;
     ADevSize : Integer;
begin
     if FPrintersCount=0 then exit;

     {プリンタ番号FPrinterNumberのデフォルト値を求める}
     Printer.PrinterIndex:=FPrinterNumber;
     Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //GetPrinterだけでうまく動作するドライバもあるが}
     //以下の様にしてDevModeを取直している}
     Printer.SetPrinter(ADevice,ADriver,APort,0);
     Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);

     ADevMode:=GlobalLock(hPrtHandle);
     try
       ADevSize:=GlobalSize(hPrtHandle);
       //*.DFMから読出したDEVMODE構造体のコピーをADevModeへコピー
       if Assigned(ASettings) then begin
         System.Move(ASettings^,ADevMode^,ADevSize);
       end;
       Mode :=DM_PROMPT or DM_MODIFY or DM_COPY;
       OpenPrinter(ADevice,hPrt,nil);
       try
         IDNo:=DocumentProperties(Application.Handle,hPrt,ADevice,ADevMode^,ADevMode^,Mode);
       finally
         ClosePrinter(hPrt);
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;

     if IDNo=IDOK then begin
       Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
       //DevModeをプロパティとしてASettingsに代入
       CopyDevModeToASettings;
     end;

     Result:=IDNo=IDOK;
     //[プリンタのプロパティ]のダイアログを閉じた時にOnDialogCloseイベント発生
     //[OK]で閉じた時はIDNo=IDOK
     //[キャンセル]で閉じた時はIDNo=IDCANCEL
     //Ver6.0でEditPrinterInofを論理値を返す関数にしたので意味がなくなった(?)
     if Assigned(FOnDialogClose) then begin
       FOnDialogClose(Self,IDNo);
     end;
end;
//====================================================================
//  現在のDevModeの値をASettingsにコピー
//  DevSizeとASettingsは本コンポの読書き両用変数．
//  このASettingsの利用がこのコンポの売りのはずなのであるが，Ver6.0で
//  ほとんどのプロパティを書込み可能にしてしまったので，意味がなくな
//  ってしまったのかも知れない．
//====================================================================
procedure TplSetPrinter.CopyDevModeToASettings;
var
     ADevMode : PDeviceMode;
begin
     //ASettingsとDevSizeの値は現在のhPrtHandleから再取得
     if Assigned(ASettings) then FreeMem(ASettings);
     ADevMode:=GlobalLock(hPrtHandle);
     DevSize :=GlobalSize(hPrtHandle);
     try
       GetMem(ASettings,DevSize);
       System.Move(ADevMode^,ASettings^,DevSize);
       Application.ProcessMessages;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     if csDesigning in ComponentState then begin
       FdsPrinterName   := FPrinterName;
       FdsOrientation   := GetFOrientation;
       FdsPaperName     := GetFPaperName;
       FdsPaperNumber   := GetFPaperNumber;
       FdsBinNumber     := GetFBinNumber;
       FdsDriverVersion := GetFDriverVersion;
     end;
end;
//====================================================================
//  DocumentProperties用の共通メソッド
//====================================================================
procedure TplSetPrinter.ModifyAndCopy(Value :PDeviceMode);
var
     hPrt : THandle;
     Mode : DWORD;
begin
     OpenPrinter(ADevice,hPrt,nil);
     Mode:=DM_MODIFY or DM_COPY;
     try
       DocumentProperties(Application.Handle,hPrt,ADriver,Value^,Value^,Mode);
     finally
       ClosePrinter(hPrt);
     end;
end;
//====================================================================
//  用紙名の設定の公開(後悔・参考用)メソッド
//  引数の用紙名がセットされない場合はFalseを返す
//====================================================================
function TplSetPrinter.SetPaperName(PaperStr: String): Boolean;
begin
     SetFPaperName(PaperStr);
     Result:=PaperStr=GetFPaperName;
end;
//====================================================================
//  用紙番号で用紙を設定する公開(後悔・参考用)メソッド
//  用紙番号(DM_PAPER_A4などの定数)で用紙サイズを設定する
//  引数で指定する用紙番号の用紙がない場合はFalseを返す
//====================================================================
function TplSetPrinter.SetPaperNumber(Index: WORD): Boolean;
begin
     SetFPaperNumber(Index);
     Result:=Index=GetFPaperNumber;
end;
//====================================================================
//  印刷方向を設定する公開(後悔・参考用)メソッド
//  実際には用紙の方向は，Printer.Orientation:=poLandscape; というコ
//  ードで設定可能なので，このメソッドは不要．
//  印刷方向をサポートしていない場合はFalseを返す
//====================================================================
function TplSetPrinter.SetOrientation(Orient: TPrinterOrientation): Boolean;
begin
     SetFOrientation(Orient);
     Result:=Orient=GetFOrientation;
end;
//====================================================================
//  給紙装置名(ビン名称)を設定する公開(後悔・参考用)メソッド
//  BinStrで指定するビン装置名に設定する
//  サポートされていないビン名称を与えるとFalseを返す
//====================================================================
function TplSetPrinter.SetBinName(BinStr: String): Boolean;
begin
     SetFBinName(BinStr);
     Result:=BinStr=GetFBinName;
end;
//====================================================================
//  プリンタの再設定を行う公開メソッド
//
//  複数の本コンポを利用する時に，明示的に設計時の設定にする場合に使
//  用する．プロパティを変更していると変更後の内容で設定される．
//  NkPrinterやクイックレポートのApplySettingsメソッドと同様の機能．
//  何故同じ名前にしなかったっんだ!?
//  このコンポを作成する時にNkPrinterなどをよく調べなかったからです．
//====================================================================
procedure TplSetPrinter.CallSetting;
begin
     SetPrinterInfo(FPrinterNumber);
end;
//====================================================================
//  プリンタのプロパティ設定ダイアログを表示.公開メソッド
//  [OK]で閉じるとTrueを，[キャンセル]で閉じるとFalseを返す
//====================================================================
function TplSetPrinter.ShowDialog: Boolean;
begin
     Result:=EditPrinterInfo;
end;
//====================================================================
//   コード終了
//====================================================================
end.

