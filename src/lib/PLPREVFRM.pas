{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$WARNINGS OFF}
//====================================================================
//    印刷プレビュー制御コンポーネント
//    プレビューフォームユニット
//    リポジトリに登録後，継承して利用するのが便利．
//
//    このフォームは，TplPrevのFormNameプロパティを指定しなければ，
//    自動的に継承フォームを作成する．この時，継承フォームに対する操
//    は，TplPrevのFormプロパティを使用する．
//
//    Ver4.0でコンポーネントの内部構成を変更した．
//    まずDelphiのVCLと同様に，基本クラスCustomplPrevを作成して，そこ
//    から派生するクラスとして実装した．
//    Ver4.0より前は，このフォームのイベントが必要な場合は，継承フォ
//    ームでイベントを作成する必要があったが，TplPrevにイベントを実装
//    して，フォームのイベントを直接作成しなくても済むようにした．
//
//                            2005.02.19  Ver.4.56
//                            Copyright (C) Mr.XRAY
//                            http://homepage2.nifty.com/Mr_XRAY/
//====================================================================
unit PLPREVFRM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,Forms,Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, Printers,Math,ToolWin,plSetPrinter,
  JPEG,Clipbrd, Buttons, Menus,plPrev;

type
  TplPrevForm = class(TForm)
    IconBar: TToolBar;
    PrintBtn: TSpeedButton;
    PrinterSetBtn: TSpeedButton;
    FirstPageBtn: TSpeedButton;
    PriorPageBtn: TSpeedButton;
    NextPageBtn: TSpeedButton;
    LastPageBtn: TSpeedButton;
    Space20: TSpeedButton;
    ZoomDownBtn: TSpeedButton;
    ZoomUpBtn: TSpeedButton;
    PageWholeBtn: TSpeedButton;
    PageWidthBtn: TSpeedButton;
    Space30: TSpeedButton;
    CloseBtn: TSpeedButton;
    StatusBar: TStatusBar;
    DisplayPanel: TPanel;
    ScrollBox1: TScrollBox;
    Image1: TImage;
    PrintDialog1: TPrintDialog;
    PrinterSetupDialog1: TPrinterSetupDialog;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    Shape1: TShape;
    Shape2: TShape;
    Space10: TSpeedButton;
    procedure PrintBtnClick(Sender: TObject);
    procedure FirstPageBtnClick(Sender: TObject);
    procedure PriorPageBtnClick(Sender: TObject);
    procedure NextPageBtnClick(Sender: TObject);
    procedure LastPageBtnClick(Sender: TObject);
    procedure ZoomDownBtnClick(Sender: TObject);
    procedure ZoomUpBtnClick(Sender: TObject);
    procedure PageWholeBtnClick(Sender: TObject);
    procedure PageWidthBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ActionDispCopyExecute(Sender: TObject);
    procedure ActionHardCopyExecute(Sender: TObject);
    procedure ActionPageCopyExecute(Sender: TObject);
    procedure ScrollBox1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormConstrainedResize(Sender: TObject; var MinWidth,
      MinHeight, MaxWidth, MaxHeight: Integer);
    procedure FormCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure PrinterSetBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Image1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Image1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
  private
    FplPrev          : TCustomplPrev;
    fgView           : Boolean;    {Form表示のフラグ.表示済みならTrue}
    fgStart          : Boolean;    {一番最初の表示か}
    ImgTop           : Integer;    {Image1の上端}
    ImgLeft          : Integer;    {Image1の左端}
    ImgWidth         : Integer;    {Image1の幅}
    ImgHeight        : Integer;    {Image1の高さ}
    MouseDownX       : Integer;    {MouseDown時のマウスX座標値}
    MouseDownY       : Integer;    {MouseDown時のマウスY座標値}
    ImageDragFlag    : Boolean;    {イメージのドラッグ中かのフラグ}
    procedure SetFormPosition;
    procedure DrawPaperShadow;
    procedure SetplPrev(const Value: TCustomplPrev);
    procedure WMSysCommand(var Msg: TWMSysCommand);message WM_SYSCOMMAND;
    {フォーム表示終了メッセージ}
    procedure CMShowingChanged(var Msg:TWMNoParams);Message CM_SHOWINGCHANGED;
    procedure SetBtnOptionsDisplay;
  public
    procedure DrawMetaImage;
    procedure Show;
    function ShowModal: Integer; override;
    property plPrev :TCustomplPrev read FplPrev write SetplPrev;
  end;

var
   plPrevForm: TplPrevForm;
   
implementation

uses  MetafileUtils;

{TCustomplPrevのprotectedメソッドを使用するために}
{このplPrevFormunitで一時的に定義するCustomplPrevのクラス}
type
   TTempplPrev = class(TCustomplPrev);


const
S0='印刷プレビュー制御コンポーネント';
S7='プリンタがインストールされていないので印刷できません．　　';
S8='プリンタがインストールされていないので設定できません．　　';


{$R *.DFM}

//====================================================================
//   Form作成時の設定
//   この処理は継承プレビューフォーム上に印刷プレビュー制御コンポが
//   配置してある場合に必要．
///  プレビューフォームにTplPrevを配置すると強制的にこの配置した
//   TplPrevを使用する．つまり，TplPrevのFormNameプロパティは無効．
//====================================================================
procedure TplPrevForm.FormCreate(Sender: TObject);
var
     i: Integer;
     AComp : TComponent;
begin
     inherited;

     {タックシールなどで画面にちらっと表示されてしまう現象の修正のため}
     Image1.Visible:=False;

     FplPrev :=nil;   {使用する制御コンポはなしとするTplPrevのFormNameで設定する}
     fgView  :=False; {フォームは未だ表示されていない}

     {このフォーム上に配置してある印刷プレビュー制御コンポを検索して設定}
     {ClassParentは一つ上位のクラス}
     for i:=0 to Self.ComponentCount-1 do begin
       AComp:=Self.Components[i];
       if AComp.ClassParent.ClassNameIs('TCustomplPrev') then begin
         FplPrev:=(Self.Components[i] as TCustomplPrev);
         TTempplPrev(FplPrev).FormName:=Self.Name;
         TTempplPrev(FplPrev).Form    :=Self;
         break;
       end;
     end;
     if FplPrev<>nil then begin
       {次にこのフォーム上のプリンタ設定コンポを探す}
       {こちらは検出に is を使用してみた}
       if TTempplPrev(FplPrev).plSetPrinter=nil then begin
         for i:=0 to Self.ComponentCount-1 do begin
           if (Self.Components[i] is TplSetPrinter) then begin
             TTempplPrev(FplPrev).plSetPrinter:=(Self.Components[i] as TplSetPrinter);
             break;
           end;
         end;
         TTempplPrev(FplPrev).SetDefaultPrinter;
       end;
       {フォームのサイズと位置を設定}
       TTempplPrev(FplPrev).Execute;
       SetFormPosition;
     end;
end;
//====================================================================
//    Formから印刷プレビュー制御コンポーネントにアクセス可能にする
//====================================================================
procedure TplPrevForm.SetplPrev(const Value: TCustomplPrev);
begin
     if Value=nil then exit;
     {印刷プレビュー制御コンポ関連づけ}
     FplPrev :=Value;
     {印刷プレビュー制御コンポ内にアクセス可能に}
     TTempplPrev(FplPrev).Form:=Self;

     {表示中なら設定しない}
     if Self.Visible then exit;
     SetFormPosition;
end;
//====================================================================
//   FplPrevの各プロパティに基づいてフォームの位置とサイズを設定
//   FormPositonがpoDesignedの時は位置とサイズは
//   FormLeft,FormTop,FormWidth,FormHeightの設定値となる．
//====================================================================
procedure TplPrevForm.SetFormPosition;
var
    WorkRect : TRect;
begin
     {タスクバーを除いた画面のワークエリアを取得}
     SystemParametersInfo(SPI_GETWORKAREA,0,@WorkRect,0);
     if TTempplPrev(FplPrev).Title='' then TTempplPrev(FplPrev).Title:='印刷プレビュー';
     Self.Caption           :=TTempplPrev(FplPrev).Title;
     Self.BorderIcons       :=TTempplPrev(FplPrev).FormBorderIcons;
     Self.StatusBar.Visible :=TTempplPrev(FplPrev).FormStatusBar;
     Self.IconBar.Visible   :=TTempplPrev(FplPrev).FormIconBar;
     Self.Icon              :=TTempplPrev(FplPrev).FormIcon;
     Self.BorderStyle       :=TTempplPrev(FplPrev).FormBorderStyle;
     if ScrollBox1.Color=clBtnFace then begin
       ScrollBox1.Color:=TTempplPrev(FplPrev).FormColor;
     end;

     {起動時のフォームの位置とサイズ}
     if TTempplPrev(FplPrev).FormWindowState=fwWorkArea  then begin
       {ワークエリア全体に表示}
       Self.Position:=poDesigned;
       Self.SetBounds(WorkRect.Left,WorkRect.Top,WorkRect.Right-WorkRect.Left,WorkRect.Bottom-WorkRect.Top);
     end else if TTempplPrev(FplPrev).FormWindowState=fwFullScreen then begin
       {画面全体に表示}
       {FullScreenはBorderStyleをSingleにしないとタスクバーを表示してしまう}
       Self.BorderStyle:=bsSingle;
       Self.SetBounds(0,0,Screen.Width,Screen.Height);
     end else if TTempplPrev(FplPrev).FormWindowState=fwMinimized then begin
       {最小化で表示}
       Self.WindowState:=wsMinimized;
     end else if TTempplPrev(FplPrev).FormWindowState=fwMaximized then begin
       {最大化で表示}
       Self.WindowState :=wsMaximized;
     end else begin
       if TTempplPrev(FplPrev).FormPosition=poDesigned then begin
         {poDesignedの時はTplPrevのFormLest,FormTop,FormWidht,FormHeightの値で表示}
         Self.Position   :=poDesigned;
         Self.WindowState:=wsNormal;
         Self.SetBounds(TTempplPrev(FplPrev).FormLeft,
                        TTempplPrev(FplPrev).FormTop,
                        TTempplPrev(FplPrev).FormWidth,
                        TTempplPrev(FplPrev).FormHeight);
       end else begin
         {その他の場合は以下のプロパティの設定に従う}
         Self.Position:=TTempplPrev(FplPrev).FormPosition;
       end;
     end;
     SetBtnOptionsDisplay;
end;
//====================================================================
//    Formをモーダルで表示する前の処理
//====================================================================
function TplPrevForm.ShowModal: Integer;
begin
     inherited ShowModal;
     Result:=ModalResult;
end;
//====================================================================
//    Formをモードレスで表示する前の処理
//====================================================================
procedure TplPrevForm.Show;
begin
     inherited Show;
end;
//====================================================================
//  フォーム表示の際の処理　
//====================================================================
procedure TplPrevForm.FormShow(Sender: TObject);
begin
     inherited;
     if FplPrev=nil then exit;
     if Assigned(TTempplPrev(FplPrev).OnFormShow) then begin
       TTempplPrev(FplPrev).OnFormShow(Self);
     end;
end;
//====================================================================
//  ボタン表示有無の設定
//====================================================================
procedure TplPrevForm.SetBtnOptionsDisplay;
begin
     {各ボタン類の表示有無を設定}
     PrintBtn.Visible     :=boPrintBtn      in TTempplPrev(FplPrev).BtnOptions;
     if TTempplPrev(FplPrev).DrawType=dtCont then begin
       PrinterSetBtn.Visible:=False;
     end else begin
       PrinterSetBtn.Visible:=boPrinterSetBtn in TTempplPrev(FplPrev).BtnOptions;
     end;
     FirstPageBtn.Visible :=boFirstPageBtn  in TTempplPrev(FplPrev).BtnOptions;
     PriorPageBtn.Visible :=boPriorPageBtn  in TTempplPrev(FplPrev).BtnOptions;
     NextPageBtn.Visible  :=boNextPageBtn   in TTempplPrev(FplPrev).BtnOptions;
     LastPageBtn.Visible  :=boLastPageBtn   in TTempplPrev(FplPrev).BtnOptions;
     ZoomDownBtn.Visible  :=boZoomDownBtn   in TTempplPrev(FplPrev).BtnOptions;
     ZoomUpBtn.Visible    :=boZoomUpBtn     in TTempplPrev(FplPrev).BtnOptions;
     PageWholeBtn.Visible :=boPageWholeBtn  in TTempplPrev(FplPrev).BtnOptions;
     PageWidthBtn.Visible :=boPageWidthBtn  in TTempplPrev(FplPrev).BtnOptions;
     CloseBtn.Visible     :=boCloseBtn      in TTempplPrev(FplPrev).BtnOptions;
end;
//====================================================================
//  フォームの表示終了
//  フォームの表示が終了したらメタファイルを表示
//  先読み方式   フォーム表示終了時点がメタファイルができている
//  逐次表示方式 最初の頁のみ描画コードを実行してメタファイル作成
//====================================================================
procedure TplPrevForm.CMShowingChanged(var Msg:TWMNoParams);
begin
     {イメージのドラッグはなし}
     ImageDragFlag:=False;
     if FplPrev=nil then begin
       inherited;
       fgView:=True;
       exit;
     end else begin
       {FromParentプロパティが有効ならばそこにalClientで表示}
       if TTempplPrev(FplPrev).FormParent<>nil then begin
         Self.Parent:=TTempplPrev(FplPrev).FormParent;
         Self.Align :=alClient;
       end;
     end;

     {通常のCMShowingChangedを継承}
     inherited;
     if Self.Visible=False then exit;

     {描画のチラツキを防止するためのダブルバッファリング．メモリは食う}
     ScrollBox1.DoubleBuffered:=True;

     {CMShowingが呼ばれたらFormは表示された.表示フラグをセット}
     fgView:=True;
     {念のため再設定}
     Image1.Anchors:=[akLeft,akTop];
     Image1.Stretch:=True;

     Self.Caption:=TTempplPrev(FplPrev).Title;
     if FplPrev.GetMetaImage(TTempplPrev(FplPrev).PageNumber)<>nil then begin
       fgStart :=True;
       {サイズ変更でメタファイルもサイズ変更}
       ScrollBox1.AutoScroll:=True;
       ScrollBox1.VertScrollBar.Margin:=10;
       ScrollBox1.HorzScrollBar.Margin:=10;

       {ここでImage1を表示}
       Image1.Visible:=TTempplPrev(FplPrev).ImageVisible;
       {表示サイズに応じて表示}
       if TTempplPrev(FplPrev).ZoomType=ztPageWidth then begin
         PageWidthBtnClick(Self);
         DrawMetaImage;
       end else begin
         PageWholeBtnClick(Self);
         DrawMetaImage;
       end;
       Application.ProcessMessages;
       fgStart:=False;
     end;
end;
//====================================================================
//   フォームの移動コマンドの処理
//   FormCanMove(published)がTrueの時は移動可能に
//                            Falseの時は移動不可の処理
//====================================================================
procedure TplPrevForm.WMSysCommand(var Msg: TWMSysCommand);
begin
     if FplPrev=nil then begin
       inherited;
       exit;
     end;
     {SC_MOVE(移動)の時は無効}
     if (TTempplPrev(FplPrev).FormCanMove=False) and
        ((Msg.CmdType and $FFF0)=SC_MOVE) then begin
       Msg.Result:=0;
     {それ以外はデフォルト動作}
     end else begin
       inherited;
     end;
end;
//====================================================================
//   描画用メタファイルを作成また取得してImage1に描画
//   表示頁が変更となった時に実行するメソッド
//   このメソッドを呼ぶ前にImageのサイズを決定している
//   頁が変わると時はOnBeforeView,OnFormResize,OnAfterView順番に発生
//   (Ver3.0でOnResizeとOnAfterの順番を変更
//
//   参考
//   Image1.Picture.Assign(FplPrev.MetaImage);
//   Image1.Picture.MetaFile:=FplPrev.MetaImage;
//      Image1.Canvasへの描画は不可(にすることが可能)
//      拡大･縮小の表示サイズ変更で再実行の必要がない
//   Image1.StretchDraw(Image1.ClientRect,FplPrev,MetaImage);
//      ビットマップで表示されるため拡大･縮小の度に呼出す必要がある
//      TImage.Canvasへの描画が可能なので,イメージの重ね描画も可能
//      ただし，用紙サイズの変更などがあった場合の調整が面倒．
//====================================================================
procedure TplPrevForm.DrawMetaImage;
var
     S: String;
     PaperName: String;
     PaperWStr,PaperHStr: String;
begin
     {逐次表示方式ではOnFormResizeとOnAfterVeiwが使用できるが，実際問題としては}
     {描画用メソッド内にコードを書くのであまり必要性はないが...}
     if Image1.Visible then begin
       LockWindowUpdate(Handle);
       Application.ProcessMessages;
       {該当頁のメタファイルの画像を取得または作成してImage1に描画}
       Image1.Picture.Assign(TTempplPrev(FplPrev).GetMetaImage(TTempplPrev(FplPrev).PageNumber));

       {用紙枠線と影.2002.6.20.OnAfterViewの前に移動}
       Shape1.Visible:=True;
       if TTempplPrev(FplPrev).ImageShade then begin
         Shape2.Visible:=True;
       end else begin
         Shape2.Visible:=False;
       end;

       DrawPaperShadow;
       {描画直後のイベント処理}
       if (Assigned(TTempplPrev(FplPrev).OnAfterView)) then begin
         TTempplPrev(FplPrev).OnAfterView(Self,TTempplPrev(FplPrev).PageNumber);
       end;
       Application.ProcessMessages;

       {各種ボタンの有効設定}
       PrintBtn.Enabled     :=(TTempplPrev(FplPrev).PageNumber>0);
       PrinterSetBtn.Enabled:=(TTempplPrev(FplPrev).PageNumber>0);
       PageWholeBtn.Enabled :=(TTempplPrev(FplPrev).PageNumber>0);
       PageWidthBtn.Enabled :=(TTempplPrev(FplPrev).PageNumber>0);
       ZoomDownBtn.Enabled  :=(TTempplPrev(FplPrev).PageNumber>0);
       ZoomUpBtn.Enabled    :=(TTempplPrev(FplPrev).PageNumber>0);
       {頁送りボタンの表示制御}
       FirstPageBtn.Enabled:=(TTempplPrev(FplPrev).PageNumber>1);
       PriorPageBtn.Enabled:=(TTempplPrev(FplPrev).PageNumber>1);
       NextPageBtn.Enabled :=(TTempplPrev(FplPrev).PageNumber<TTempplPrev(FplPrev).PageCount);
       LastPageBtn.Enabled :=(TTempplPrev(FplPrev).PageNumber<TTempplPrev(FplPrev).PageCount);

       {総頁数と現在の頁番号と用紙名サイズを表示}
       S:='';
       PaperWStr:=FormatFloat('##0.0',TTempplPrev(FplPrev).ViewWidth /10);
       PaperHStr:=FormatFloat('##0.0',TTempplPrev(FplPrev).ViewHeight/10);
       S:=' Page  '+IntToStr(TTempplPrev(FplPrev).PageNumber)+'/'+IntToStr(TTempplPrev(FplPrev).PageCount);
       if TTempplPrev(FplPrev).plSetPrinter=nil then begin
         S:=S+'  '+' ( '+PaperWStr+' x '+PaperHStr+' mm )';
       end else begin
         PaperName:=TTempplPrev(FplPrev).plSetPrinter.PaperName;
         S:=S+'  '+TTempplPrev(FplPrev).plSetPrinter.PaperName+
            ' ( '+PaperWStr+' x '+PaperHStr+' mm )';
       end;
       StatusBar.Panels[0].Text:=S;
       if TTempplPrev(FplPrev).StatusBarText<>'' then begin
         StatusBar.Panels[1].Text:=TTempplPrev(FplPrev).StatusBarText;
       end;
       LockWindowUpdate(0);
     end;
end;
//====================================================================
//    用紙の枠線と影の描画
//    表示サイズが拡大縮小・頁幅・頁全体などで変更となった時に実行す
//    るメソッド
//    引数のFlagはVer3.0で不要になったので削除
//
//    頁が変わる時とリサイズの際に実行
//    頁が変わると時はOnBeforeView,OnAfterView,OnResizeの3つが発生．
//    リサイズの場合はこのDrawPaperShadowのみ
//====================================================================
procedure TplPrevForm.DrawPaperShadow;
var
     Bw,Bh: Integer;
     Xl,Yt,Xw,Yw: Integer;
begin
     Bw:=2;
     Bh:=2;
     Xl:=Image1.Left;
     Yt:=Image1.Top;
     Xw:=Image1.Width;
     Yw:=Image1.Height;
     if Image1.Visible then begin
       Shape2.SetBounds(Xl+Bw,Yt+Bw,Xw+Bh,Yw+Bh);
       Shape1.Pen.Color:=clBlack;
       Shape1.SetBounds(Xl-1,Yt-1,Xw+1,Yw+1);
       {イメージのリサイズ後のイベント処理}
       if (Assigned(TTempplPrev(FplPrev).OnResize)) then begin
         TTempplPrev(FplPrev).OnResize(Self,TTempplPrev(FplPrev).PageNumber);
       end;
     end;
end;
//====================================================================
//    印刷ダイアログを表示して印刷
//
//    頁指定は現在の頁だけを印刷可能な表示としてある.
//    ダイアログでプロパティの設定を変更しても印刷時みの有効
//    (通常のアプリケーションと同じ動作)
//
//    印刷開始と終了頁は以下のプロパティを使用する
//    PrintFromPage  印刷開始頁番号
//    PrintToPage    印刷終了頁
//====================================================================
procedure TplPrevForm.PrintBtnClick(Sender: TObject);
var
     PageNum: Integer;
     CanPrint: Boolean;
begin
     {プリンタまたはプリンタ設定コンポなし}
     if TTempplPrev(FplPrev).PrinterFlag=False then begin
       Application.MessageBox(PChar(S7),PChar('　印刷'),MB_ICONINFORMATION);
       exit;
     end;

     CanPrint:=True;
     if Assigned(TTempplPrev(FplPrev).OnPrintButtonClick) then begin
       TTempplPrev(FplPrev).OnPrintButtonClick(Self,CanPrint);
       if CanPrint=False then exit;
     end;

     {現在の頁番号を退避}
     PageNum:=TTempplPrev(FplPrev).PageNumber;
     {印刷開始頁と最終頁の初期値は0とする}
     TTempplPrev(FplPrev).PrintFromPage :=0;
     TTempplPrev(FplPrev).PrintToPage   :=0;
     {設定関係の順番を変えるとダイアログが表示されないことがある}
     {また各頁設定の最初の0,1の意味にも注意}
     PrintDialog1.Options  :=[poPageNums];
     PrintDialog1.FromPage :=TTempplPrev(FplPrev).PageNumber;
     PrintDialog1.MinPage  :=1;
     PrintDialog1.ToPage   :=1;
     PrintDialog1.MaxPage  :=TTempplPrev(FplPrev).PageCount;
     PrintDialog1.ToPage   :=TTempplPrev(FplPrev).PageNumber;

     {プリンタ設定コンポーネントの設定を保存しておく}
     TTempplPrev(FplPrev).SavePrinterSetting;
     if (PrintDialog1.Execute) then begin
       PrintBtn.Enabled:=False;
       TTempplPrev(FplPrev).plSetPrinter.GetPrinterInfo(False);
       {ダイアログで全ての頁を選択した場合}
       if PrintDialog1.PrintRange=prAllPages then begin
         TTempplPrev(FplPrev).PrintFromPage  :=PrintDialog1.MinPage;
         TTempplPrev(FplPrev).PrintToPage    :=PrintDialog1.MaxPage;
       {頁範囲を指定した場合}
       end else if PrintDialog1.PrintRange=prPageNums then begin
         TTempplPrev(FplPrev).PrintFromPage :=PrintDialog1.FromPage;
         TTempplPrev(FplPrev).PrintToPage   :=PrintDialog1.ToPage;
       end;

       try
         {印刷実行}
         TTempplPrev(FplPrev).Print;
       finally
         {保存しておいたプリンタ設定コンポーネントの設定を読出す}
         TTempplPrev(FplPrev).ReadPrinterSetting;
         {現在の頁を元に戻す}
         TTempplPrev(FplPrev).PageNumber:=PageNum;
         {特に逐次表示方式の場合は印刷しない部分があるので頁を再描画}
         DrawMetaImage;
         Screen.Cursor:=crDefault;
         Self.Update;
       end;
     end;
end;
//====================================================================
//    プリンタ設定ダイアログを表示
//    ViewWidth,ViewHeightの値はここで用紙のサイズに戻ってしまう
//    2000,4.30 逐次表示方式で,プリンタ設定ダイアログ
//    (TPrinterSetupDialog)の設定内容をプレビュー反映するように変更
//
//    Ver3.0修正
//    Senderにnilを渡した場合,ダイアログを表示せずに設定が可能に.
//    ただし,逐次表示方式のみ.
//
//    OnPrinterSetupDialogはダイアログをOKで終了した場合のみ発生
//====================================================================
procedure TplPrevForm.PrinterSetBtnClick(Sender: TObject);
begin
     if FplPrev=nil then exit;
     if TTempplPrev(FplPrev).DrawType=dtCont then exit;
     {プリンタまたはプリンタ設定コンポなし}
     if TTempplPrev(FplPrev).PrinterFlag=False then begin
       Application.MessageBox(PChar(S8),PChar('　プリンタと用紙の設定'),MB_ICONINFORMATION);
       exit;
     end;

     if (Sender=nil) or (PrinterSetupDialog1.Execute) then begin
       try
         PrinterSetBtn.Enabled:=False;
         {設定した内容をプリンタ設定コンポに送る}
         TTempplPrev(FplPrev).plSetPrinter.GetPrinterInfo(False);
         TTempplPrev(FplPrev).SetPaperInfo;
         TTempplPrev(FplPrev).ViewWidth :=TTempplPrev(FplPrev).PaperWidth; {表示幅のデフォルトは用紙幅}
         TTempplPrev(FplPrev).ViewHeight:=TTempplPrev(FplPrev).PaperHeight;{表示高さのデフォルトは用紙長さ}
         if Assigned(TTempplPrev(FplPrev).OnPrinterSetupDialog) then begin
           TTempplPrev(FplPrev).OnPrinterSetupDialog(Self);
         end;
         DrawMetaImage;
       finally
         PageWholeBtnClick(nil);
        end;
      end;
end;
//====================================================================
//   先頭頁を表示
//====================================================================
procedure TplPrevForm.FirstPageBtnClick(Sender: TObject);
begin
     if TTempplPrev(FplPrev).PageNumber=1 then exit;
     FirstPageBtn.Enabled:=False;
     PriorPageBtn.Enabled:=False;
     TTempplPrev(FplPrev).PageNumber:=1;
     DrawMetaImage;
end;
//====================================================================
//   前の頁を表示
//====================================================================
procedure TplPrevForm.PriorPageBtnClick(Sender: TObject);
begin
     if TTempplPrev(FplPrev).PageNumber=1 then exit;
     PriorPageBtn.Enabled:=False;
     TTempplPrev(FplPrev).PageNumber:=TTempplPrev(FplPrev).PageNumber-1;
     DrawMetaImage;
end;
//====================================================================
//   次の頁を表示
//====================================================================
procedure TplPrevForm.NextPageBtnClick(Sender: TObject);
begin
     if TTempplPrev(FplPrev).PageNumber=TTempplPrev(FplPrev).PageCount then exit;
     NextPageBtn.Enabled:=False;
     TTempplPrev(FplPrev).PageNumber:=TTempplPrev(FplPrev).PageNumber+1;
     DrawMetaImage;
end;
//====================================================================
//   最終頁を表示
//====================================================================
procedure TplPrevForm.LastPageBtnClick(Sender: TObject);
begin
     if TTempplPrev(FplPrev).PageNumber=TTempplPrev(FplPrev).PageCount then exit;
     LastPageBtn.Enabled:=False;
     NextPageBtn.Enabled:=False;
     TTempplPrev(FplPrev).PageNumber:=TTempplPrev(FplPrev).PageCount;
     DrawMetaImage;
end;
//====================================================================
//   プレビュー表示を縮小
//====================================================================
procedure TplPrevForm.ZoomDownBtnClick(Sender: TObject);
begin
     ZoomDownBtn.Enabled:=False;

     TTempplPrev(FplPrev).ZoomType:=ztOther;
     with ScrollBox1 do begin
       VertScrollBar.Visible :=True;
       HorzScrollBar.Visible :=True;
     end;
     if Image1.Width<=100 then begin
       ZoomDownBtn.Enabled:=False;
     end else begin
       ImgWidth :=Trunc(ImgWidth*90.0/100.0);
       ImgHeight:=Trunc(ImgWidth*TTempplPrev(FplPrev).ViewPaperRatio);
       Image1.SetBounds(ImgLeft,ImgTop,ImgWidth,ImgHeight);
       DrawPaperShadow;
       Application.ProcessMessages;
       ZoomDownBtn.Enabled:=True;
     end;
     ZoomUpBtn.Enabled  :=True;
end;
//====================================================================
//    プレビュー表示を拡大
//    メタファイルの描画はしない.Imageの大きさの変更をするだけ
//====================================================================
procedure TplPrevForm.ZoomUpBtnClick(Sender: TObject);
begin
     ZoomUpBtn.Enabled:=False;

     TTempplPrev(FplPrev).ZoomType:=ztOther;
     with ScrollBox1 do begin
       VertScrollBar.Visible :=True;
       HorzScrollBar.Visible :=True;
     end;
     if (Image1.Width>=Screen.Width*2) or
        (Image1.Height>=Screen.Height*3) then begin
        ZoomUpBtn.Enabled:=False;
     end else begin
       ImgLeft:=Image1.Left;
       ImgTop :=Image1.Top;
       {拡大は10%}
       ImgWidth :=Trunc(ImgWidth*100.0/90.0);
       ImgHeight:=Trunc(ImgWidth*TTempplPrev(FplPrev).ViewPaperRatio);
       Image1.SetBounds(ImgLeft,ImgTop,ImgWidth,ImgHeight);
       DrawPaperShadow;
       Application.ProcessMessages;
       ZoomUpBtn.Enabled:=True;
     end;
     ZoomDownBtn.Enabled:=True;
end;
//====================================================================
//    頁全体を表示
//    頁全体がスクロールボックスの中に入る様に表示.
//    メタファイルの描画はしない.Imageの大きさの変更をするだけ
//====================================================================
procedure TplPrevForm.PageWholeBtnClick(Sender: TObject);
var
     CrtRatio: Double;
begin
     TTempplPrev(FplPrev).ZoomType:=ztWholePage;
     with ScrollBox1 do begin
       VertScrollBar.Visible :=False;
       HorzScrollBar.Visible :=False;
     end;
     ScrollBox1.VertScrollBar.Visible:=False;
     ScrollBox1.HorzScrollBar.Visible:=False;
     CrtRatio:=ScrollBox1.Height/ScrollBox1.Width;
     {用紙の縦横比がScrollBoxの縦横比より大きい.縦方向を先に決める}
     if TTempplPrev(FplPrev).ViewPaperRatio>CrtRatio then begin
       ImgTop   :=15;
       ImgHeight:=ScrollBox1.Height-30;
       ImgWidth :=Trunc(ImgHeight/TTempplPrev(FplPrev).ViewPaperRatio);
       ImgLeft  :=Trunc((ScrollBox1.Width-ImgWidth)/2.0);
     {用紙の縦横比がScrollBoxの縦横比より小さい.横方向を先に決める}
     end else begin
       ImgLeft  :=15;
       ImgWidth :=ScrollBox1.Width-30;
       ImgHeight:=Trunc(ImgWidth*TTempplPrev(FplPrev).ViewPaperRatio);
       ImgTop   :=Trunc((ScrollBox1.Height-ImgHeight)/2.0);
     end;
     Image1.Setbounds(ImgLeft,ImgTop,ImgWidth,ImgHeight);
     DrawPaperShadow;
     Application.ProcessMessages;
     {表示倍率ボタンの表示制御}
     if TTempplPrev(FplPrev).ImageVisible then ZoomUpBtn.Enabled  :=True;
     if TTempplPrev(FplPrev).ImageVisible then ZoomDownBtn.Enabled:=True;
end;
//====================================================================
//    用紙幅を基準にしたプレビュー
//    スクロールボックスの幅の中に,用紙の横幅が入る様に表示.
//    メタファイルの描画はしない.Imageの大きさの変更をするだけ
//====================================================================
procedure TplPrevForm.PageWidthBtnClick(Sender: TObject);
begin
     TTempplPrev(FplPrev).ZoomType:=ztPageWidth;
     with ScrollBox1 do begin
       VertScrollBar.Visible :=True;
       HorzScrollBar.Visible :=True;
       VertScrollBar.Position:=0;
       HorzScrollBar.Position:=0;
     end;
     {上と左右の余白を設定}
     ImgTop :=15;
     ImgLeft:=15;
     {表示サイズの縦横比からImage1の縦横を設定}
     ImgWidth :=ScrollBox1.ClientWidth-30;
     ImgHeight:=Trunc(ImgWidth*TTempplPrev(FplPrev).ViewPaperRatio);
     Image1.Setbounds(ImgLeft,ImgTop,ImgWidth,ImgHeight);
     if ScrollBox1.VertScrollBar.Visible then begin
       ImgWidth :=ScrollBox1.ClientWidth-30;
       ImgHeight:=Trunc(ImgWidth*TTempplPrev(FplPrev).ViewPaperRatio);
       Image1.Setbounds(ImgLeft,ImgTop,ImgWidth,ImgHeight);
     end;
     DrawPaperShadow;
     Application.ProcessMessages;
     {表示倍率ボタンの表示制御}
     if TTempplPrev(FplPrev).ImageVisible then ZoomUpBtn.Enabled  :=True;
     if TTempplPrev(FplPrev).ImageVisible then ZoomDownBtn.Enabled:=True;
end;
//====================================================================
//    フォームのリサイズプロパティの処理
//====================================================================
procedure TplPrevForm.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
     if FplPrev=nil then exit;
     Resize:=TTempplPrev(FplPrev).FormCanResize;
     if TTempplPrev(FplPrev).FormCanResize=False then begin
       {ステータスバーのグリップを非表示}
       Self.StatusBar.SizeGrip:=False;
     end;
end;
//====================================================================
//    フォームのリサイズ動作
//    フォームの大きさに対応してイメージも追従して変化
//    メタファイルの描画はしない.Imageの大きさの変更をするだけ
//====================================================================
procedure TplPrevForm.FormResize(Sender: TObject);
begin
     if FplPrev=nil then exit;
     if not(fgView) then exit;
     {頁全体と頁幅表示の場合のみ.拡大縮小の時は何もしない}
     if TTempplPrev(FplPrev).ZoomType=ztWholePage then begin
       PageWholeBtnClick(Self);
     end else if TTempplPrev(FplPrev).ZoomType=ztPageWidth then begin
       PageWidthBtnClick(Self);
     end;
end;
//====================================================================
//    フォームの大きさを制限する
//    縮小の場合のみの制限
//====================================================================
procedure TplPrevForm.FormConstrainedResize(Sender: TObject; var MinWidth,
  MinHeight, MaxWidth, MaxHeight: Integer);
begin
     MinWidth:=300;
     MinHeight:=300;
end;
//====================================================================
//    マウスホイールによるスクロール
//====================================================================
procedure TplPrevForm.ScrollBox1MouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
     Handled:=True;
     Self.ScrollBox1.VertScrollBar.Position:=
                   Self.ScrollBox1.VertScrollBar.Position-WheelDelta div 5;
end;
//====================================================================
//    ポップアップメニューの処理
//    プレビュー画面でマウスボタンの右クリックした時のメニューの表示
//    位置を指定
//====================================================================
procedure TplPrevForm.Image1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     MouseDownX:=X;
     MouseDownY:=Y;
     if Button=mbRight then begin
       PopupMenu1.AutoHotkeys:=maManual;
       if TTempplPrev(FplPrev).PrinterFlag=False then begin
         PopupMenu1.Items[1].Enabled:=False;
         PopupMenu1.Items[2].Enabled:=False;
       end;
       if Sender=Image1 then begin
         with ClientToScreen(Point(X,Y)) do begin
           PopupMenu1.Popup(X+Image1.Left,Y+Image1.Top+ScrollBox1.Top);
         end;
       end else if Sender=ScrollBox1 then begin
         with ClientToScreen(Point(X,Y+ScrollBox1.Top)) do begin
           PopupMenu1.Popup(X,Y);
         end;
       end;
     {左ボタンではドラッグによるイメージ部分の移動を可能にする}  
     end else if Button=mbLeft then begin
       if TTempplPrev(FplPrev).ImageDrag and TTempplPrev(FplPrev).ImageVisible then begin
         TImage(Sender).BeginDrag(True);
         ScrollBox1.VertScrollBar.Visible:=True;
         ScrollBox1.HorzScrollBar.Visible:=True;
         ScrollBox1.AutoScroll:=True;
         ImageDragFlag:=True;
       end;
     end;
end;
//====================================================================
//   イメージのドラッグ中の処理
//====================================================================
procedure TplPrevForm.Image1DragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
     if ImageDragFlag=False then exit;
     Accept := Source is TImage;
     if Accept then begin
       with Source as TImage do begin
         Left := Left+X-MouseDownX;
         Top  := Top +Y-MouseDownY;
         Shape1.Left:=Shape1.Left+X-MouseDownX;
         Shape1.Top :=Shape1.Top +Y-MouseDownY;
         Shape2.Left:=Shape2.Left+X-MouseDownX;
         Shape2.Top :=Shape2.Top +Y-MouseDownY;
         ScrollBox1.Update;
       end;
     end;
end;
//====================================================================
//   イメージのドラッグ終了時の処理
//====================================================================
procedure TplPrevForm.Image1DragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
     if ImageDragFlag=False then exit;
     if (Sender = Source) then begin
       with Source as TImage do begin
         Left := Left+X-MouseDownX;
         Top  := Top +Y-MouseDownY;
         Shape1.Left:=Shape1.Left+X-MouseDownX;
         Shape1.Top :=Shape1.Top +Y-MouseDownY;
         Shape2.Left:=Shape2.Left+X-MouseDownX;
         Shape2.Top :=Shape2.Top +Y-MouseDownY;
         EndDrag(true);
         ImageDragFlag:=False;
      end;
     end;
end;
//====================================================================
//    表示中の頁全体をメタファイルとしてクリップボードへ
//    実際に表示中のMetaFileをそのままの寸法でクリップボードに送る.
//====================================================================
procedure TplPrevForm.ActionPageCopyExecute(Sender: TObject);
begin
     if TTempplPrev(FplPrev).MetaImage<>nil then begin
       Clipboard.Clear;
       Clipboard.Assign(TTempplPrev(FplPrev).GetMetaImage(TTempplPrev(FplPrev).PageNumber));
       Application.ProcessMessages
     end;
end;
//====================================================================
//    プレビューフォームのハードコピー
//
//    ポップアップメニューから[画面ハードコピー]で動作
//    印刷ダイアログを表示する.キャンセルすると中止.
//    Keybd_Eventでアクティブウインドゥをクリップボードにコピーして
//    それをBitmapに代入してこれをプリンタに出力する．
//
//    画面のプロパティの効果で[アニメーション]を有効にしているとポッ
//    プアップメニュー の一部もコピーしてしまうので注意．
//====================================================================
procedure TplPrevForm.ActionHardCopyExecute(Sender: TObject);
var
     OSver        : TOSVERSIONINFO;
     Flags1       : Word;
     Flags2       : Word;
     ABitmap      : TBitmap;
     Xl,Xr,Yt,Yb  : Integer;
     BitmapRatio  : Double;
     PWidth       : Integer;
begin
     {プリンタ設定コンポーネントの設定を保存しておく}
     TTempplPrev(FplPrev).SavePrinterSetting;

     Flags1:=KEYEVENTF_EXTENDEDKEY;
     Flags2:=KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP;
     {OSの種類を取得}
     OSver.dwOSVersionInfoSize:=SizeOf(OSver);
     GetVersionEx(OSver);
     {現在アクティブなウインドゥ画面をクリップボードへ}
     case  OSver.dwPlatformId of
     {Windows95,98}
     VER_PLATFORM_WIN32_WINDOWS:
       begin
         keybd_event(VK_SNAPSHOT,0,Flags1,0);
         keybd_event(VK_SNAPSHOT,0,Flags2,0);
       end;
     {WindowsNT,Windows2000}
     VER_PLATFORM_WIN32_NT:
       begin
         keybd_event(VK_LMENU,$56,Flags1,0) ;
         keybd_event(VK_SNAPSHOT,$79,Flags1,0) ;
         keybd_event(VK_LMENU,$56,Flags2,0) ;
         keybd_event(VK_SNAPSHOT,$79,Flags2,0)
       end;
     else
       begin
         exit;
       end;
     end;
     Application.ProcessMessages;
     {ビットマップオブジェクトを作成}
     ABitmap:=TBitmap.Create;

     {クリップボートの内容をビットマップに代入}
     ABitmap.Assign(Clipboard);
     {任意の枠に同じ縦横比で拡大縮小するための画像の縦横比を計算}
     BitmapRatio:=ABitmap.Height/ABitmap.Width;
     {用紙の左端から用紙幅の10%分の位置から印刷．印刷結果を綴じる場合を考えて}
     {用紙の上端は左端と同じ寸法だけ空ける}
     {印刷位置の下端は画像の縦横比から計算}
     try
       if (PrintDialog1.Execute) then begin
         TTempplPrev(FplPrev).plSetPrinter.GetPrinterInfo(False);
         {プリンタ名にAcrobatという文字列があったら出力しない}
         if (AnsiPos('ACROBAT',AnsiUpperCase(TTempplPrev(FplPrev).plSetPrinter.PrinterName))=0) then begin
           PWidth:=Printer.PageWidth;
           Xl:=PWidth div 10;
           Yt:=Xl div 2;
           Xr:=PWidth-Xl;
           Yb:=Yt+Round((Xr-Xl)*BitmapRatio);
           {2003.09.10 try～finally使用}
           try
             Printer.BeginDoc;
             Printer.Canvas.StretchDraw(Rect(Xl,Yt,Xr,Yb),ABitmap);
             Application.ProcessMessages;
           finally
             Printer.EndDoc;
           end;
         end;
       end;
     finally
       ABitmap.Free;
       {保存しておいたプリンタ設定コンポーネントの設定を読出す}
       TTempplPrev(FplPrev).ReadPrinterSetting;
       DrawMetaImage;
       Application.ProcessMessages;
     end;
end;
//====================================================================
//    プレビューフォームをクリップボートに
//
//    ポップアップメニューから[画面コピー]で動作.
//    ワープロソフトに貼付けて，説明用の文書を作成する場合等に使用
//    画面のプロパティの効果で[アニメーション]を有効にしているとポッ
//    プアップメニューの一部もコピーしてしまうので注意．
//====================================================================
procedure TplPrevForm.ActionDispCopyExecute(Sender: TObject);
var
     OSver : TOSVERSIONINFO;
     Flags1: Word;
     Flags2: Word;
begin
     Flags1:=KEYEVENTF_EXTENDEDKEY;
     Flags2:=KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP;
     {OSの種類を取得}
     OSver.dwOSVersionInfoSize:=SizeOf(OSver);
     GetVersionEx(OSver);
     {現在アクティブなウインドゥ画面をクリップボードへ}
     case  OSver.dwPlatformId of
     {Windows95,98}
     VER_PLATFORM_WIN32_WINDOWS:
       begin
         keybd_event(VK_SNAPSHOT,0,Flags1,0);
         keybd_event(VK_SNAPSHOT,0,Flags2,0);
       end;
     {WindowsNT,Windows2000}
     VER_PLATFORM_WIN32_NT:
       begin
         keybd_event(VK_LMENU,$56,Flags1,0) ;
         keybd_event(VK_SNAPSHOT,$79,Flags1,0) ;
         keybd_event(VK_LMENU,$56,Flags2,0) ;
         keybd_event(VK_SNAPSHOT,$79,Flags2,0);
       end;
     else
       exit;
     end;
     Application.ProcessMessages;
end;
//====================================================================
//    閉じるボタン
//====================================================================
procedure TplPrevForm.CloseBtnClick(Sender: TObject);
begin
     Close;
end;
//====================================================================
//    CloseQuery処理
//====================================================================
procedure TplPrevForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
     if FplPrev<>nil then begin
       if Assigned(TTempplPrev(FplPrev).OnFormCloseQuery) then begin
         TTempplPrev(FplPrev).OnFormCloseQuery(Self,CanClose);
       end;
       {Ver4.3で以下2行追加}
       if CanClose then begin
         TTempplPrev(FplPrev).ViewWidth :=0;
         TTempplPrev(FplPrev).ViewHeight:=0;
       end;
     end;
end;
//====================================================================
//  閉じる処理
//  自動生成シたフォームはActionの値は常にcaFreeになる
//  OnCloseは廃止．代わりにOnFormCloseを使用する．
//====================================================================
procedure TplPrevForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     if FplPrev<>nil then begin
       if Assigned(TTempplPrev(FplPrev).OnFormClose) then begin
         TTempplPrev(FplPrev).OnFormClose(Self,Action);
       end;
       //Ver4.55で追加
       //フォームを閉じる時にはイメージの画像をクリア
       Shape1.Visible:=False;
       Shape2.Visible:=False;
       Image1.Picture.Assign(nil);
       {このフォームが自動生成したものであるなら}
       if TTempplPrev(FplPrev).AutoCreateForm then begin
         TTempplPrev(FplPrev).AutoCreateForm:=False;
         TTempplPrev(FplPrev).FormDispFlag  :=False;
         TTempplPrev(FplPrev).FormName      :='';
         {caFreeが有効なのはShowの時のみ}
         Action:=caFree;
       end;
     end;
end;
//====================================================================
//    Destroy処理
//====================================================================
procedure TplPrevForm.FormDestroy(Sender: TObject);
begin
     if FplPrev<>nil then begin
       if Assigned(TTempplPrev(FplPrev).OnFormDestroy) then begin
         TTempplPrev(FplPrev).OnFormDestroy(Self);
       end;
     end;
end;
//====================================================================
//    コード終了
//====================================================================
end.
