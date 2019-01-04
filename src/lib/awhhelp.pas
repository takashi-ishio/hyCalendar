//---------------------------------------------------------------------------------
// Copyright (C) 2001-2002 by Junichi Sakamoto <adelieworks@yahoo.co.jp>
// Ver.2.0
//
// 本ファイルの著作権は坂本純一が保持します。
// 本ファイルは,改版の有無に関わらず,著作者に無断で転載することを禁じます。
// (一切の転載を禁じるもではありません)
// 本ファイルの使用から生ずるいかなる被害・損害も、著作者は一切責任を負いません。
// 本ファイルをそのままあるいは改版の上使用して生成された実行可能なバイナリファイル
// に対して、著作者は著作権を主張しません。本ファイルを改版の上使用することに対して
// 著作者は異議を申し立てません。
// 本ファイルの利用は、上記但書に沿う限り、商用・非商用を問わず可能です。
//
//---------------------------------------------------------------------------------
// 改版履歴
// Ver.2.0
//   1) デストラクタでHH_UNINITIALIZEファンクションを呼び出すのを削除(WinXP対応)
//   2) 設計時はOnHelpイベントをトラップしないよう修正(IDE終了時のアプリケーショ
//      ンエラー対応)
//   3) AutoInstallプロパティを追加、OnHelpイベントハンドラを自動でセットアップ
//      するかしないかを選べるように改良。 
//
// Ver.1.0
//---------------------------------------------------------------------------------

unit awhhelp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ActiveX;

type

  ///////////////////////////////////////////////
  // HTMLヘルプサポートコンポーネント
  THTMLHelp = class(TComponent)
    protected
      FCookie          : Dword;
      FPopupPos        : TPoint;
      FAutoInstall     : Boolean;
      procedure InitHtmlHelp();
    public
      constructor Create(AOwner : TComponent); override;
      function    OnApplicationHelp(Command:Word; Data:longint; var CallHelp:boolean):boolean;
      procedure   Loaded; override;
    published
      property AutoInstall: Boolean read FAutoInstall write FAutoInstall default True;
  end;

  procedure Register;

implementation

type

  ///////////////////////////////////////////////
  // ポップアップ表示パラメータ構造体
  HH_POPUP = record
    cbStruct      : integer;  // sizeof this structure
    hinst         : THandle;  // instance handle for string resource
    idString      : UINT;     // string resource id, or text id if pszFile is specified in HtmlHelp call
    pszText       : LPCTSTR;  // used if idString is zero
    pt            : TPoint;   // top center of popup window
    clrForeground : COLORREF; // use -1 for default
    clrBackground : COLORREF; // use -1 for default
    rcMargins     : TRect;    // amount of space between edges of window and text, -1 for each member to ignore
    pszFont       : LPCTSTR;  // facename, point size, char set, BOLD ITALIC UNDERLINE
  end;

  ///////////////////////////////////////////////
  // エラー情報構造体
  HH_LAST_ERROR = record
    cbStruct    : integer;
    hr          : HRESULT;
    description : PWideChar;
  end;

  ///////////////////////////////////////////////
  // HtmlHelp API プロトタイプ
  function HtmlHelp(
    hwndCaller:HWND; pszFile:PAnsiChar; uCommand:Dword; dwData:Dword):HWND; stdcall; external 'hhctrl.ocx' name 'HtmlHelpA';
  function HtmlHelpA(
    hwndCaller:HWND; pszFile:PAnsiChar; uCommand:Dword; dwData:Dword):HWND; stdcall; external 'hhctrl.ocx' name 'HtmlHelpA';
  function HtmlHelpW(
    hwndCaller:HWND; pszFile:PWideChar; uCommand:Dword; dwData:Dword):HWND; stdcall; external 'hhctrl.ocx' name 'HtmlHelpW';

const
  ///////////////////////////////////////////////
  // HtmlHelp API コマンドID
  HH_INITIALIZE         = $001C;
  HH_UNINITIALIZE       = $001D;
  HH_DISPLAY_TOPIC      = $0000;
  HH_HELP_CONTEXT       = $000F;
  HH_DISPLAY_TEXT_POPUP = $000E;
  HH_GET_LAST_ERROR     = $0014;


///////////////////////////////////////////////
// HTMLヘルプサポートコンポーネントの構築
// Application.OnHelp イベントのハンドラを設定する
constructor THTMLHelp.Create(AOwner : TComponent);
begin
    FCookie := Dword(-1);
    FAutoInstall := True;
    inherited Create(AOwner);
end;

procedure THTMLHelp.Loaded;
begin
    inherited Loaded;
    if( FAutoInstall )then begin
        if( not ( csDesigning in ComponentState ) )then begin
            Application.OnHelp := OnApplicationHelp;
        end;
    end;
end;

///////////////////////////////////////////////
// HTMLヘルプシステムの初期化 (本メソッドは何回呼び出しても良い)
procedure THTMLHelp.InitHtmlHelp();
begin
  if FCookie = Dword(-1) then begin
    HtmlHelp(0,nil,HH_INITIALIZE,Dword(@FCookie) );
  end;
end;

///////////////////////////////////////////////
// Application.OnHelp イベントハンドラ
function THTMLHelp.OnApplicationHelp(Command:Word; Data:longint; var CallHelp:boolean):boolean;
var
  helppath : string;
  popuppath : string;
  hRet    : HWND;
  hOwner  : HWND;
  popup   : HH_POPUP;
  lasterror : HH_LAST_ERROR;
begin
  result    := false;
  InitHtmlHelp();
  hOwner := GetDesktopWindow();

  // ヘルプファイル名を取得/決定
  helppath := Application.CurrentHelpFile;
  if helppath = '' then begin
    helppath := ChangeFileExt(Application.ExeName,'.chm');
  end;

  // 拡張子がchmではない->HTMLヘルプファイルではない場合は既存の実装にまかせる
  if CompareText(ExtractFileExt(helppath),'.chm') <> 0 then exit;
  CallHelp  := false;

  // コマンドに応じてHTMLヘルプAPIを呼び出す
  hRet := HWND(-1);
  case Command of

    HELP_CONTENTS,
    HELP_FINDER:
      begin
        hRet := HtmlHelp(hOwner,PChar(helppath),HH_DISPLAY_TOPIC,0);
      end;

    HELP_CONTEXT:
      begin
        hRet := HtmlHelp(hOwner,PChar(helppath),HH_HELP_CONTEXT,Data);
      end;

    HELP_SETPOPUP_POS:
      begin
        FPopupPos.x := LOWORD(Data);
        FPopupPos.y := HIWORD(Data);
      end;

    HELP_CONTEXTPOPUP:
      begin
        hRet := HtmlHelp(hOwner,PChar(helppath),HH_HELP_CONTEXT,Data);
        if hRet = 0 then begin
          FillChar(popup,sizeof(popup),0);
          popup.cbStruct          := sizeof(popup);
          popup.idString          := Data;
          popup.pt                := FPopupPos;
          popup.clrForeground     := COLORREF(-1);
          popup.clrBackground     := COLORREF(-1);
          popup.rcMargins.left    := -1;
          popup.rcMargins.top     := -1;
          popup.rcMargins.right   := -1;
          popup.rcMargins.bottom  := -1;
          popuppath := helppath+'::/cshelp.txt';
          HtmlHelp(Screen.ActiveForm.Handle,PChar(popuppath),HH_DISPLAY_TEXT_POPUP,DWORD(@popup) );
          exit;
        end;
      end;

  end;

  // エラーメッセージがあればメッセージボックスで表示
  if hRet = 0 then begin
    HtmlHelp(hOwner,nil,HH_GET_LAST_ERROR, DWORD(@lasterror) );
    if( FAILED(lasterror.hr) )and( lasterror.description <> nil )then begin
      Application.MessageBox(PChar(AnsiString(lasterror.description)),PChar(Application.Title),MB_OK+MB_ICONSTOP);
      SysFreeString( lasterror.description );
    end;
  end;

end;


procedure Register;
begin
  RegisterComponents('adelie works', [THTMLHelp]);
end;

end.
