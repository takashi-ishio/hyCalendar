unit HintWindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Math, Contnrs, StringSplitter;

const
    MAX_POPUP_COUNT = 32;

type
  THintWindowStack = class;

  TfrmHintWindow = class(TForm)
    CloseButton: TButton;
    HintString: TMemo;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private 宣言 }
    FHintDate: TDate;
    FStack: THintWindowStack;

    FActiveColor, FInactiveColor: TColor;
    FCursorRect: TRect;
    FChild: TfrmHintWindow;

    procedure PanelWndProc(var Message: TMessage);
//  protected
//    procedure CreateParams(var Params: TCreateParams); override;

  public
    { Public 宣言 }
    constructor Create(owner: TCustomForm; stack: THintWindowStack);

    procedure ActivateHint(d: TDate; p: TPoint; s: string; cRect: TRect);
    procedure HideHint;
    procedure calculateSize(s: string; var w, h: integer);
    property HintDate: TDate read FHintDate;
    property CursorRect: TRect read FCursorRect;
  end;

  THintWindowStack = class
  private
    FOwner: TCustomForm;
    FStack: TObjectList;
    FTopIndex: integer;
    FPreventPopupAgain: boolean;
    FStringSplitter: TStringSplitter;

    function getWindow(index: integer): TfrmHintWindow;
  public
    constructor Create(AOwner: TCustomForm);
    destructor Destroy; override;
    procedure HideAllHint;
    procedure hideHint(window: TfrmHintWindow; preventPopup: boolean);
//    procedure hideHintIfInactive(window: TfrmHintWindow);

    procedure popup(d: TDate; p: TPoint; s: string; rect: TRect; window: TCustomForm);
    procedure OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure notifyESC(var key: Word);
    procedure SetFocusToTopHint;
    procedure calculateSize(s: string; var w, h: integer);
    procedure AllowPopup;
    function  TopDate: TDate;

    function PopupTimer: integer;
    property HintWindow[index: integer]: TfrmHintWindow read getWindow;
  end;




implementation

{$R *.dfm}

uses
    Calendar, CalendarConfig;

const
    MARGIN_BETWEEN_LINES = 2;
    MARGIN_SIDE = 20;

constructor THintWindowStack.Create(AOwner: TCustomForm);
begin
    FOwner := AOwner;
    FStack := TObjectList.Create(true);
    FTopIndex := -1;
    FStringSplitter := TStringSplitter.Create;
end;

function THintWindowStack.TopDate: TDate;
begin
    if FTopIndex = -1 then Result := 0
    else Result := HintWindow[FTopIndex].HintDate;
end;

// 再ポップアップ禁止の条項を解除
procedure THintWindowStack.AllowPopup;
begin
    FPreventPopupAgain := false;
end;

//procedure TfrmHintWindow.CreateParams(var Params: TCreateParams);
//begin
//    inherited CreateParams(Params);
//    Params.ExStyle := (Params.ExStyle and not WS_EX_APPWINDOW) or WS_EX_TOOLWINDOW;
//end;

function THintWindowStack.PopupTimer: integer;
begin
    Result := 0;
    if (FOwner is TfrmCalendar) and not (FOwner as TfrmCalendar).PopupNoHideTimeout then
        Result := Application.HintHidePause;
end;

destructor THintWindowStack.Destroy;
begin
    FStack.Free;
    FStringSplitter.Free;
    FOwner := nil;
end;

procedure THintWindowStack.HideAllHint;
begin
    while FTopIndex >= 0 do begin
        HintWindow[FTopIndex].HideHint;
        HintWindow[FTopIndex].Timer1.Interval := 0;
        Dec(FTopIndex);
    end;
end;

procedure THintWindowStack.SetFocusToTopHint;
begin
    if (FTopIndex >=0) then begin
        HintWindow[FTopIndex].Activate;
        HintWindow[FTopIndex].BringToFront;
    end;
end;

function THintWindowStack.getWindow(index: integer): TfrmHintWindow;
begin
    Result := FStack[index] as TfrmHintWindow;
end;

procedure THintWindowStack.hideHint(window: TfrmHintWindow; preventPopup: boolean);
begin
    // window で指定されたウィンドウと，その子ウィンドウを消す．
    while (FStack[FTopIndex] <> window) do begin
        HintWindow[FTopIndex].HideHint;
        Dec(FTopIndex);
    end;
    (FStack[FTopIndex] as TfrmHintWindow).HideHint;
    window.HideHint;
    window.Timer1.Interval := 0;
    Dec(FTopIndex);

    FPreventPopupAgain := preventPopup;
end;

//// window で指定されたウィンドウと，その子ウィンドウがすべて inactive ならウィンドウを消す
//procedure THintWindowStack.hideHintIfInactive(window: TfrmHintWindow);
//var
//  idx: integer;
//begin
//    // window を探す．それまでに active なウィンドウがあれば終了．
//    idx := FTopIndex;
//    while (FStack[idx] <> window) do begin
//        if HintWindow[idx].Active then exit;
//        Dec(idx);
//    end;
//    // window がアクティブでなければ，window とその子ウィンドウを消す
//    if not window.Active then begin
//      hideHint(window, false);
//    end;
//end;

procedure THintWindowStack.notifyESC(var key: Word);
var
    window: TfrmHintWindow;
begin
    if FTopIndex >= 0 then begin
        window := FStack[FTopIndex] as TfrmHintWindow;
        hideHint(window, true);
        Key := 0;

    end;
end;

procedure THintWindowStack.OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);

    function isInside(p: TPoint; rect: TRect): boolean;
    begin
        Result := (rect.Left <= p.X)and(p.X <= rect.Right)and(rect.Top <= p.Y)and(p.Y <= rect.Bottom);
    end;

    function toBeHide(point: TPoint; window: TfrmHintWindow): boolean;
    begin
        Result := not isInside(point, window.CursorRect) and not isInside(point, window.BoundsRect) and not window.Active;
    end;

var
    i: integer;
    p: TPoint;
begin
    p.X := X;
    p.Y := Y;
    p := (Sender as TWinControl).ClientToScreen(p);

    // ESCキーなどで消された後の再表示禁止が，無効にできるなら無効にする
    if (FTopIndex < MAX_POPUP_COUNT) and
       (FStack.Count > FTopIndex + 1) and
       (FStack[FTopIndex+1] <> nil) and
       FPreventPopupAgain and
       not isInside(p, HintWindow[FTopIndex+1].CursorRect) then
       FPreventPopupAgain := false;

    // トップから順に，消せるウィンドウを消す
    for i:= FTopIndex downto 0 do begin
        if toBeHide(p, HintWindow[i]) then begin
            hideHint(HintWindow[i], false);
        end else begin
            Break;
        end;
    end;

    // 消し終わったところで新しいウィンドウ表示の可能性を探る

end;

procedure THintWindowStack.popup(d: TDate; p: TPoint; s: string; rect: TRect; window: TCustomForm);
begin
    if FTopIndex = MAX_POPUP_COUNT then exit;

    // window が足りなければ作成
    if FStack.Count = FTopIndex+1 then begin
        FStack.Add(TfrmHintWindow.Create(FOwner, self));
    end;

    // 上が禁止領域のままなら，ポップアップ見送り
    if FPreventPopupAgain then exit;

    // 既にトップに表示中の日付のポップアップは見送り
    if (FTopIndex >= 0) and (HintWindow[FTopIndex].HintDate = d) then
        Exit;

    // window より子供のヒントウィンドウを閉じる
    // （子ウィンドウがアクティブでない場合のみ）
    while (FTopIndex >=0) and (HintWindow[FTopIndex] <> window) and (not HintWindow[FTopIndex].Active) do begin
        HintWindow[FTopIndex].HideHint;
        Dec(FTopIndex);
    end;

    // 既にトップに表示中の日付のポップアップは見送り
    if (FTopIndex >= 0) and (HintWindow[FTopIndex].HintDate = d) then
        Exit;

    // ポップアップで上に乗られた側のウィンドウのタイムアップを無効にする
    if (FTopIndex >= 0) then HintWindow[FTopIndex].Timer1.Interval := 0;

    // ヒントウィンドウ開く
    HintWindow[FTopIndex + 1].ActivateHint(d, p, s, rect);
    FTopIndex := FTopIndex + 1;

end;

procedure TfrmHintWindow.PanelWndProc(var Message: TMessage);
var
    y : Word;
begin
    if Message.Msg = WM_NCHITTEST then begin
        y := HiWord(Message.LParam);
        if y < HintString.Top + self.Top then begin
            Message.Result := HTCAPTION;
            Message.Msg := 0;
        end else begin
            WndProc(Message);
        end;
    end else begin
        WndProc(Message);
    end;
end;

procedure TfrmHintWindow.ActivateHint(d: TDate; p: TPoint; s: string; cRect: TRect);
var
    //i,
    w, h: integer;
//    lines: integer;
//    lineWidth: integer;
begin
    FHintDate := d;
    FCursorRect:= cRect;

    Left := p.X;
    Top  := p.Y;


//    self.Canvas.Font := HintString.Font;
//    w := 0;
//    FStack.FStringSplitter.setString(s);
//    lines := 0;
//    while FStack.FStringSplitter.hasNext do begin
//        lineWidth := self.Canvas.TextWidth(FStack.FStringSplitter.getLine) + CloseButton.Width + MARGIN_SIDE;
//        w := Max(w, lineWidth);
//        inc(lines, 1 + (lineWidth div Screen.Width)); // Screen.Widthをこえてしまって折り返される行数を含めてカウント
//    end;
//
//    self.Width := Min(w, Screen.Width);
    calculateSize(s, w, h);
    self.Width := w;
    self.Height := h;

    HintString.Text := s;
//    self.Height := Min(Screen.Height, HintString.Top + 4 +
//                   lines * (self.Canvas.TextHeight('A') + MARGIN_BETWEEN_LINES));

    // 画面外にはみ出さないように移動する
    // 注: self.Width, Height は Screen.Width/Height までに範囲を限定してるので，ここで値は最小 0 になる
    if Left + Width > Screen.WorkareaWidth then Left := screen.WorkareaWidth - self.Width;
    if Top + Height > Screen.WorkareaHeight then Top := screen.WorkareaHeight - self.Height;

    // アクティブにしないでウィンドウを表示 --
    // 隠れてる間に HWND_TOP で前面に出してから ShowWindow で表示すると
    // ほぼ確実に前面に出てくれる 
    SetWindowPos(self.Handle, HWND_TOP, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOMOVE);
    ShowWindow(self.Handle, SHOW_OPENNOACTIVATE);

    // 上記のメッセージだけだと Visible と同期が取れなくなる
    Visible := true;

    self.Timer1.Interval := FStack.PopupTimer;

end;

procedure TfrmHintWindow.calculateSize(s: string; var w, h: integer);
var
    lines: integer;
    lineWidth: integer;
begin
    self.Canvas.Font := HintString.Font;
    w := 0;
    FStack.FStringSplitter.setString(s);
    lines := 0;
    while FStack.FStringSplitter.hasNext do begin
        lineWidth := self.Canvas.TextWidth(FStack.FStringSplitter.getLine) + CloseButton.Width + MARGIN_SIDE;
        w := Max(w, lineWidth);
        inc(lines, 1 + (lineWidth div Screen.WorkareaWidth)); // Screen.Widthをこえてしまって折り返される行数を含めてカウント
    end;

    w := Min(w, Screen.WorkareaWidth);
    h := Min(Screen.WorkareaHeight, HintString.Top + 4 +
             lines * (self.Canvas.TextHeight('A') + MARGIN_BETWEEN_LINES));

end;

procedure THintWindowStack.calculateSize(s: string; var w, h: integer);
begin
    if FStack.Count = 0 then begin
        FStack.Add(TfrmHintWindow.Create(FOwner, self));
    end;
    getWindow(0).calculateSize(s, w, h);
end;


constructor TfrmHintWindow.Create(owner: TCustomForm; stack: THintWindowStack);
begin
    inherited Create(owner);
    FStack := stack;
end;

procedure TfrmHintWindow.FormCreate(Sender: TObject);
begin
    self.WindowProc := PanelWndProc;
    FActiveColor := RGB(192, 192, 128);
    FInactiveColor := RGB(228, 228, 192);
    Color := FInactiveColor;
    FChild := nil;
    with HintString do begin
        OnMouseMove := frmCalendar.FreeMemoMouseMove;
        OnMouseDown := frmCalendar.FreeMemoMouseDown;
        OnMouseUp   := frmCalendar.FreeMemoMouseDown; // わざと Down イベントにしている
        OnDblClick  := frmCalendar.FreeMemoDblClick;
    end;
end;

procedure TfrmHintWindow.FormPaint(Sender: TObject);
begin
    self.Canvas.Pen.Color := self.Color;
    self.Canvas.Rectangle(0, 0, self.Width, self.Height);
end;

procedure TfrmHintWindow.FormActivate(Sender: TObject);
begin
    Color := FActiveColor;
    Repaint;
    Timer1.Interval := 0;
end;

procedure TfrmHintWindow.HideHint;
begin
    if Visible then begin
        SetWindowPos(self.Handle, HWND_TOP, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_HIDEWINDOW); // NoActivate でないと一瞬 Active になってしまう
        Visible := false; // SetWindowPos を使うと同期が取れなくなるので手動であわせる

        if Active and not IsIconic((Owner as TCustomForm).Handle) then SetActiveWindow((Owner as TCustomForm).Handle);
    end;
end;

procedure TfrmHintWindow.FormDeactivate(Sender: TObject);
begin
    Color := FInactiveColor;
    Repaint;
end;

procedure TfrmHintWindow.CloseButtonClick(Sender: TObject);
begin
    FStack.hideHint(self, true);
end;

procedure TfrmHintWindow.Timer1Timer(Sender: TObject);
begin
    if self.Visible then FStack.hideHint(self, true);
end;

procedure TfrmHintWindow.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then FStack.hideHint(self, true);
end;

end.
