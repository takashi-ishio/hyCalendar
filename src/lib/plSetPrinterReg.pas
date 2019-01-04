{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$WARNINGS OFF}
//====================================================================
//   プリンタ設定コンポーネント  TplSetPrinter
//   コンポーネント登録及びプロパティエディタ関係
//
//   印刷用のプログラム作成の際，プリンタの設定(用紙サイズや用紙向き
//   等を主にプリンタのプロパティ設定ダイアログ(プリンタドライバが提
//   供する)を表示して行うコンポーネント．
//
//   このプロパティエディタ関係のコードは，
//   DelphiがVer5から，DSGNINTF.DCUがDelphi に付属しなくなり，コンポ
//   ーネント開発者は設計時コードをランタイムコードから別々のユニット
//   に分離する必要が生じたための処置．
//
//
//                            2005.01.29  Ver.6.06　
//                            Copyright (C) by Mr.XRAY
//                            http://homepage2.nifty.com/Mr_XRAY/
//====================================================================
unit plSetPrinterReg;

interface

uses

  {$IFDEF VER130}
  plSetPrinter,Windows,SysUtils, Classes,Forms,Controls,ToolWin,
  Printers,WinSpool,DsgnIntf,StdCtrls;
  {$ELSE}
  plSetPrinter,Windows,SysUtils, Classes,Forms,Controls,ToolWin,
  Printers,WinSpool,DesignIntf,StdCtrls,DesignEditors;
  {$ENDIF}

type
  {プリンタ情報の宣言}
  TplPrinterInfo4Array = array[0..10000] of TPrinterInfo4;
  plPPrinterInfo4Array = ^TplPrinterInfo4Array;
  TplPrinterInfo5Array = array[0..10000] of TPrinterInfo5;
  plPPrinterInfo5Array = ^TplPrinterInfo5Array;

//====================================================================
//     プリンタ名プロパティクラス関係
//====================================================================
TPrinterNameProperty = class(TStringProperty)
public
      function GetAttributes: TPropertyAttributes; override;
      procedure GetValues(Proc: TGetStrProc); override;
      function GetValue: String;override;
      procedure SetValue(const Value: String); override;
end;
//====================================================================
//  プリンタのプロパティのダイアログ関係
//  メソッドはEditのみ
//
//  1999.7.31追加
//  ExecuteVerb,GetVerb,GetVerbCountを追加してマウス右クリックでプ
//  ロパティの設定を可能にした.
//  Ver5.3でこれは廃止した．
//====================================================================
TPrinterProperty = class(TComponentEditor)
public
      procedure Edit; override;
end;

procedure Register;

implementation

var
   PrintersInfo        : array of Byte;  {プリンタ情報}
   nPrinters           : DWORD;          {プリンタの数}
   PrinterInfoLevel    : Integer;        {プリンタ情報のレベル}
   PrinterNameList     : TStringList;    {プリンタ名のリスト}

{TPrinterNameProperty}

//====================================================================
//  プリンタ名プロパティ
//  オブジェクトインスペクタでの属性
//  リストからの選択方式とするため,読出し専用.
//====================================================================
function TPrinterNameProperty.GetAttributes: TPropertyAttributes;
begin
     Result:=[paValueList];
end;
//====================================================================
//  プリンタ名プロパティ
//  オブジェクトインスペクタ用にプリンタ名のリストを作成
//====================================================================
procedure TPrinterNameProperty.GetValues(Proc: TGetStrProc);
var
     Flags: Integer;    {EnumPrinters に渡すフラグ}
     InfoBytes: DWORD;  {プリンタ情報のバイト数}
     i: Integer;
     APrtName: String;
begin
     nPrinters := 0;
     PrinterNameList.Clear;
     {プリンタ情報を得る準備}
     if Win32Platform = VER_PLATFORM_WIN32_NT then begin
       Flags := PRINTER_ENUM_CONNECTIONS or PRINTER_ENUM_LOCAL;
       PrinterInfoLevel := 4;
     end else begin
       Flags := PRINTER_ENUM_LOCAL;
       PrinterInfoLevel := 5;
     end;

     InfoBytes := 0;
     {バッファ長を得る}
     EnumPrinters(Flags, nil, PrinterInfoLevel, nil, 0,InfoBytes, nPrinters);

     if InfoBytes<>0 then begin
       {バッファ確保}
       SetLength(PrintersInfo, InfoBytes);
       {プリンタ情報(Level=4 or 5)を取得}
       Win32Check(EnumPrinters(Flags, nil, PrinterInfoLevel,
                               Pointer(PrintersInfo),
                               InfoBytes, InfoBytes, nPrinters));
       {一覧に追加}
       for i := 0 to nPrinters-1 do begin
         if PrinterInfoLevel = 4 then begin
           if (plPPrinterInfo4Array(PrintersInfo)[i].Attributes and
                                  PRINTER_ATTRIBUTE_HIDDEN) = 0 then begin
             APrtName:=plPPrinterInfo4Array(PrintersInfo)[i].pPrinterName;
             PrinterNameList.Add(APrtName);
           end;
         end else begin
           if (plPPrinterInfo5Array(PrintersInfo)[i].Attributes and
                                  PRINTER_ATTRIBUTE_HIDDEN) = 0 then begin
             APrtName:=plPPrinterInfo5Array(PrintersInfo)[i].pPrinterName;
             PrinterNameList.Add(APrtName);
           end;
         end;
       end;
       PrinterNameList.Sort;
       for i:=0 to PrinterNameList.Count-1 do begin
         Proc(PrinterNameList[i]);
       end;
     end;
end;
//====================================================================
//  プリンタ名プロパティ
//  オブジェクトインスペクタに表示する時に呼出す関数
//  空文字の場合(これは本コンポをFormに初めて配置した時)はプリンタ番
//  号がデフォルトのものをセットしている．Windows2000,XPではプリンタ
//  名にポート名が付加されていないので，これでよい．
//  (本コンポの動作確認開発環境はWindows2000,XP)
//====================================================================
function TPrinterNameProperty.GetValue: String;
var
     PrtName: String;
     pt:TplSetPrinter;
begin
     pt:=GetComponent(0) as TplSetPrinter;
     if GetStrValue='' then begin
       Printer.PrinterIndex:=-1;
       PrtName:=Printer.Printers[Printer.PrinterIndex];
       Result:=PrtName;
       pt.PrinterName:=PrtName;
     end else begin
       Result:=GetStrValue;
     end;
end;
//====================================================================
//  プリンタ名プロパティ
//  オブジェクトインスペクタにプリンタ名がセットされると呼ばれる.
//====================================================================
procedure TPrinterNameProperty.SetValue(const Value: String);
begin
     SetStrValue(Value);
end;

{TPrinterProperty}

//====================================================================
//  プリンタのプロパテイのダイアログを表示
//
//  フォーム上のコンポーネントをダブルクリックするとプリンタのプロ
//  パティの設定ダイアログを表示する.このダイアログはプリンタドライ
//  バが提供している.つまり,プリンタの製造会社,ドライバのバージョン
//  によって異なる.
//====================================================================
procedure TPrinterProperty.Edit;
var
     pt:TplSetPrinter;
begin
     pt:=(Component as TplSetPrinter);
     {プリンタのプロパティのダイアログを表示}
     pt.ShowDialog;
     {これがないとPaperNum,Orient,DevSizeが更新保存されない}
     Designer.Modified;
end;
//====================================================================
//  コンポーネントの登録関係の設定
//
//  ここでは[plXRAY]タブに登録するようにしてある.
//  登録パレットの変更は以下のいずれかで...
//  (1)'Samples'の名前を変更する．
//     存在しないパレットを指定すると，そのパレットが作成される
//  (2)このまま登録し，[コンポーネント][パレットの設定]で変更する
//
//  前のバージョンで登録パレットを変更している場合は登録先のパレット
//  に変更はない．
//====================================================================
procedure Register;
begin
     RegisterComponents     ('plXRAY', [TplSetPrinter]);
     RegisterPropertyEditor (TypeInfo(String),TplSetPrinter,'PrinterName',
                             TPrinterNameProperty);
     RegisterComponentEditor(TplSetPrinter,TPrinterProperty);
end;
//====================================================================
//    プロパティエディタの初期化と終了処理
//    プリンタ名のリスト用のTStringListの作成と破棄
//====================================================================
initialization
     PrinterNameList := TStringList.Create;
finalization
     PrinterNameList.Free;
//====================================================================
//   コード終了
//====================================================================
end.

