//====================================================================
//    印刷プレビュー制御コンポーネント  TplPrev
//    コンポーネント登録とプロパティエディタ関係
//
//    この印刷プレビュー制御コンポーネントは，印刷のコードを描画する
//    ためのCanvasと，そこに描画した内容をプレビューするための，カス
//    タマイズ可能なフォームを提供するものです．プレビュー画面で頁送
//    り操作や印刷を実行します．
//
//                            2005.02.19  Ver.4.56 　
//                            Copyright (C) Mr.XRAY
//                            http://homepage2.nifty.com/Mr_XRAY/
//====================================================================
unit plPrevReg;

interface

uses
  {$IFDEF VER130}
  Windows, SysUtils, Classes,DsgnIntf,Exptintf;
  {$ELSE}
  Windows, SysUtils, Classes, DesignIntf,DesignEditors,Exptintf;
  {$ENDIF}

type

//====================================================================
//  FormNameプロパティの設定用
//====================================================================
  TFormNameProperty = class(TStringProperty)
  public
    procedure GetValues(Proc: TGetStrProc); override;
    function GetAttributes: TPropertyAttributes; override;
    procedure SetValue(const Value: String); override;
  end;

procedure Register;

implementation

uses plPrev;

var
   FormNameList: TStringList;

//====================================================================
//  アプリケーションのFormのリスト作成
//  現在のプロジェクトのFormのリストを取得する
//  名前がplPrevFormそのものは除外(プレビューフォームは継承して使用
//  することを前提としているため．
//====================================================================
function EnumProc(Param: Pointer; const FileName, UnitName,
  FormName: string): Boolean stdcall;
begin
     if FormName <> '' then begin
       if FormName<>'plPrevForm' then FormNameList.Add(FormName);
     end;
     Result := True;
end;

{ TFormNameProperty }

//====================================================================
//  オブジェクトインスペクタでの選択方法の指定
//====================================================================
function TFormNameProperty.GetAttributes: TPropertyAttributes;
begin
     Result := [paValueList, paSortList];
end;
//====================================================================
//  オブジェクトインスペクタに表示する文字列リスト作成
//====================================================================
procedure TFormNameProperty.GetValues(Proc: TGetStrProc);
var
     i: Integer;
begin
     FormNameList.Clear;
     ToolServices.EnumProjectUnits(EnumProc, Self);
     for i := 0 to FormNameList.Count - 1 do begin
       Proc(FormNameList[i]);
     end;
end;
//====================================================================
//  オブジェクトインスペクタに選択したForm名をセット
//====================================================================
procedure TFormNameProperty.SetValue(const Value: String);
begin
     SetStrValue(Value);
end;
//====================================================================
//  コンポーネントの登録関係の設定
//
//  ここでは[plXRAY]タブに登録するようにしてある.
//  登録パレットの変更は以下のいずれかで...
//  (1)'Samples'の名前を変更する．
//     存在しないパレットを指定すると，そのパレットが作成される
//  (2)このまま登録し，[コンポーネント][パレットの設定]で変更する
//  前のバージョンで登録パレットを変更している場合は登録先のパレット
//  に変更はない．
//====================================================================
procedure Register;
begin
     RegisterComponents ('plXRAY', [TplPrev]);
     RegisterPropertyEditor(TypeInfo(TComponentName),
                            TplPrev,'FormName',TFormNameProperty);
end;
//====================================================================
//    プロパティエディタの初期化と終了処理
//    Form名のリスト用のTStringListの作成と破棄
//====================================================================
initialization
     FormNameList := TStringList.Create;
finalization
     FormNameList.Free;
//====================================================================
//   コード終了
//====================================================================
end.

