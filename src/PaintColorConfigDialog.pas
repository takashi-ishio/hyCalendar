unit PaintColorConfigDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ColorManager, ColorPair, Buttons;

type
  TfrmPaintColorConfig = class(TForm)
    Label1: TLabel;
    BackColorBox: TColorBox;
    Label2: TLabel;
    HeadColorBox: TColorBox;
    Label3: TLabel;
    SelectedColorPaintBox: TPaintBox;
    PaintColorBox1: TPaintBox;
    PaintColorBox2: TPaintBox;
    PaintColorBox3: TPaintBox;
    PaintColorBox4: TPaintBox;
    PaintColorBox5: TPaintBox;
    PaintColorBox6: TPaintBox;
    ReadBtn: TBitBtn;
    WriteBtn: TBitBtn;
    BackColorDefault: TCheckBox;
    HeadColorDefault: TCheckBox;
    SameHeadColor: TCheckBox;
    Label4: TLabel;
    procedure PaintColorBoxPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintColorBoxClick(Sender: TObject);
    procedure ReadBtnClick(Sender: TObject);
    procedure WriteBtnClick(Sender: TObject);
    procedure SameHeadColorClick(Sender: TObject);
    procedure HeadColorDefaultClick(Sender: TObject);
  private
    { Private êÈåæ }
    FColorManager: TPaintColorManager;

    FColorBoxIndex: integer;
    FColorBox: array [-1..COLOR_BOX_COUNT-1] of TPaintBox;
  public
    { Public êÈåæ }
    property ColorManager: TPaintColorManager read FColorManager write FColorManager;
  end;

var
  frmPaintColorConfig: TfrmPaintColorConfig;

implementation

{$R *.dfm}

procedure TfrmPaintColorConfig.PaintColorBoxPaint(Sender: TObject);
const
    MARGIN = 2;
var
    box: TPaintBox;
    rect: TRect;
begin
    box := Sender as TPaintBox;

    if box.Tag = FColorBoxIndex then
        box.Canvas.Brush.Color := clNavy
    else
        box.Canvas.Brush.Color := self.Color;

    box.Canvas.FillRect(box.Canvas.ClipRect);

    rect := box.Canvas.ClipRect;
    rect.Left := rect.Left + MARGIN;
    rect.Top  := rect.Top  + MARGIN;
    rect.Bottom := rect.Bottom - MARGIN;
    rect.Right  := rect.right  - MARGIN;

    ColorManager.paintColorBox(box.Tag, box.Canvas, rect);
end;

procedure TfrmPaintColorConfig.FormCreate(Sender: TObject);
var
    i: integer;
begin
    FColorBoxIndex := -1;
    FColorBox[-1]:= SelectedColorPaintBox;
    FColorBox[0] := PaintColorBox1;
    FColorBox[1] := PaintColorBox2;
    FColorBox[2] := PaintColorBox3;
    FColorBox[3] := PaintColorBox4;
    FColorBox[4] := PaintColorBox5;
    FColorBox[5] := PaintColorBox6;
    for i:=-1 to COLOR_BOX_COUNT-1 do begin
        FColorBox[i].OnClick := PaintColorBoxClick;
        FColorBox[i].OnPaint := PaintColorBoxPaint;
    end;
    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;
end;

procedure TfrmPaintColorConfig.PaintColorBoxClick(Sender: TObject);
var
    i: integer;
begin
    FColorBoxIndex := (Sender as TPaintBox).Tag;
    for i:=-1 to COLOR_BOX_COUNT-1 do begin
        FColorBox[i].Repaint;
    end;
end;

procedure TfrmPaintColorConfig.ReadBtnClick(Sender: TObject);
var
    cl: TCellColorConfig;
begin
    cl := ColorManager.getColor(FColorBoxIndex);
    HeadColorBox.Selected := cl.Head;
    BackColorBox.Selected := cl.Back;
    SameHeadColor.Checked := (cl.Head = cl.Back);
    HeadColorDefault.Checked := (cl.Head = clDefault);
    BackColorDefault.Checked := (cl.Back = clDefault)and(not SameHeadColor.Checked);
end;

procedure TfrmPaintColorConfig.WriteBtnClick(Sender: TObject);
var
    cl: TCellColorConfig;
begin
    cl.Head := HeadColorBox.Selected;
    cl.Back := BackColorBox.Selected;
    if HeadColorDefault.Checked then cl.Head := clDefault;
    if BackColorDefault.Checked then cl.Back := clDefault;
    if SameHeadColor.Checked then cl.Head := cl.Back;
    ColorManager.setColor(FColorBoxIndex, cl);
    FColorBox[FColorBoxIndex].Repaint;
end;

procedure TfrmPaintColorConfig.SameHeadColorClick(Sender: TObject);
begin
    HeadColorDefault.OnClick := nil;
    HeadColorDefault.Checked := false;
    HeadColorDefault.OnClick := HeadColorDefaultClick;
end;

procedure TfrmPaintColorConfig.HeadColorDefaultClick(Sender: TObject);
begin
    SameHeadColor.OnClick := nil;
    SameHeadColor.Checked := false;
    SameHeadColor.OnClick := SameHeadColorClick;
end;

end.
