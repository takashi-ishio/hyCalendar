unit CalendarPrintDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, DateUtils, StrUtils, Math,
  CalendarConfig, Printers, CalendarPrinter,
  plPrev, plSetPrinter, ExtCtrls;

type
  TfrmCalendarPrint = class(TForm)
    RangeGroup: TGroupBox;
    Label1: TLabel;
    StartYearBox: TEdit;
    StartYear: TUpDown;
    StartMonthBox: TEdit;
    StartMonth: TUpDown;
    Label2: TLabel;
    EndYear: TUpDown;
    EndYearBox: TEdit;
    EndMonthBox: TEdit;
    EndMonth: TUpDown;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    PrintDialog1: TPrintDialog;
    PrintBtn: TButton;
    PrinterGroup: TGroupBox;
    PrinterInfoLabel: TLabel;
    PrinterDialogBtn: TButton;
    FreeMemoGroup: TGroupBox;
    Label7: TLabel;
    FreeMemoRatioBox: TEdit;
    FreememoRatioUpDown: TUpDown;
    PrintOrientationCombo: TComboBox;
    Label8: TLabel;
    PreviewBtn: TButton;
    FreeMemoTwoColumns: TCheckBox;
    TodoRatioUpDown: TUpDown;
    TodoRatioBox: TEdit;
    Label9: TLabel;
    HeaderGroup: TGroupBox;
    CaptionTopLeft: TRadioButton;
    Label10: TLabel;
    CaptionBottomLeft: TRadioButton;
    CaptionTopCenter: TRadioButton;
    CaptionBottomCenter: TRadioButton;
    CaptionTopRight: TRadioButton;
    CaptionBottomRight: TRadioButton;
    CaptionFontLabel: TLabel;
    CaptionFontButton: TButton;
    FontDialog1: TFontDialog;
    CaptionNone: TRadioButton;
    LineGroup: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    LineWidthBox: TEdit;
    LineColorBox: TColorBox;
    LineWidthUpDown: TUpDown;
    LayoutGroup: TGroupBox;
    StyleNormal: TRadioButton;
    StyleTwoPart: TRadioButton;
    WeeksPerPage: TComboBox;
    Label13: TLabel;
    FontGroup: TGroupBox;
    PrintFontCombo: TComboBox;
    PrintFontButton: TButton;
    PrintFontLabel: TLabel;
    UsePrintFontCheck: TCheckBox;
    HideOtherMonth: TCheckBox;
    procedure PrintBtnClick(Sender: TObject);
    procedure PrinterDialogBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure StartMonthBoxExit(Sender: TObject);
    procedure StartYearBoxExit(Sender: TObject);
    procedure EndYearBoxExit(Sender: TObject);
    procedure EndMonthBoxExit(Sender: TObject);
    procedure StartMonthChangingEx(Sender: TObject;
      var AllowChange: Boolean; NewValue: Smallint;
      Direction: TUpDownDirection);
    procedure EndMonthChangingEx(Sender: TObject; var AllowChange: Boolean;
      NewValue: Smallint; Direction: TUpDownDirection);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure CaptionFontButtonClick(Sender: TObject);
    procedure StyleTwoPartClick(Sender: TObject);
    procedure PrintFontButtonClick(Sender: TObject);
    procedure PrintFontComboChange(Sender: TObject);
    procedure UsePrintFontCheckClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private 宣言 }
    FConfiguration: TCalendarConfiguration;
    FBaseDate: TDateTime;
    FFilename: string;


    function CanPrint(var StartDate, EndDate: TDateTime): boolean;
    function radioStateToCaptionPosition: TCaptionPosition;
    procedure setRadioStateFromCaptionPosition(pos: TCaptionPosition);

    procedure updateConfiguration;
    procedure setupPrintFontCombo;

  public
    { Public 宣言 }
    function available: boolean;

    property Filename: string write FFilename;
    property Config  : TCalendarConfiguration write FConfiguration;
    property BaseDate: TDateTime write FBaseDate;
  end;

var
  frmCalendarPrint: TfrmCalendarPrint;

implementation

uses
    CalendarPreview, Calendar;

{$R *.dfm}

function TfrmCalendarPrint.available: boolean;
begin
  try
    if frmCalendarPrintPreview = nil then Application.CreateForm(TfrmCalendarPrintPreview, frmCalendarPrintPreview);
  except
    on E: EPrinter do begin
      frmCalendarPrintPreview := nil;
    end;
  end;

  Result := frmCalendarPrintPreview <> nil;
end;

function TfrmCalendarPrint.CanPrint(var StartDate, EndDate: TDateTime): boolean;
var
  tmp: TDateTime;
begin
    if TryEncodeDate(StartYear.Position, StartMonth.Position, 1, StartDate) and
       TryEncodeDate(EndYear.Position, EndMonth.Position, 1, EndDate) then begin
        if StartDate > EndDate then begin
          tmp := StartDate;
          StartDate := EndDate;
          EndDate := tmp;
        end;
        Result := (StartDate <= EndDate);
    end else begin
        Result := false;
    end;
end;

procedure TfrmCalendarPrint.setupPrintFontCombo;
const
  FONTNAMELABEL: array [0..MAX_SCREEN_FONT_INDEX] of string =
    (  '日付メモ ',
       '日付数字 ',
       '曜日 ',
       'ハイパーリンク ',
       'フリーメモ ',
       '期間予定 ',
       '周期予定 ',
       'ToDo ',
       '休日名',
       'ToDo一覧' );
var
    i: integer;
    idx: integer;
begin
    idx := PrintFontCombo.ItemIndex;
    if PrintFontCombo.Items.Count <> MAX_SCREEN_FONT_INDEX+1 then begin
        PrintFontCombo.Items.Clear;
        for i := 0 to MAX_SCREEN_FONT_INDEX do PrintFontCombo.Items.Add('');
    end;

    for i := 0 to MAX_SCREEN_FONT_INDEX do begin
        if FConfiguration.UseScreenFontForPrint(i) then begin
            PrintFontCombo.Items[i] := FONTNAMELABEL[i] + '- 画面と同じ';
        end else begin
            PrintFontCombo.Items[i] := FONTNAMELABEL[i] + '- ' + FConfiguration.Fonts(i + INDEX_PRINT_FONT_OFFSET).Name;
        end;
    end;

    if idx = -1 then begin
        PrintFontCombo.ItemIndex := 0;
        PrintFontComboChange(PrintFontCombo);
    end else begin
        PrintFontCombo.ItemIndex := idx;
    end;
end;

procedure TfrmCalendarPrint.PrintFontButtonClick(Sender: TObject);
begin
    FontDialog1.Font := FConfiguration.Fonts(PrintFontCombo.ItemIndex + INDEX_PRINT_FONT_OFFSET);
    if FontDialog1.Execute then begin
        PrintFontLabel.Font := FontDialog1.Font;
        PrintFontLabel.Caption := PrintFontLabel.Font.Name;
        FConfiguration.Fonts(PrintFontCombo.ItemIndex + INDEX_PRINT_FONT_OFFSET).Assign(FontDialog1.Font);
        FConfiguration.SetUseScreenFontForPrint(PrintFontCombo.ItemIndex, false);
        UsePrintFontCheck.Checked := true;
        setupPrintFontCombo;
    end;
end;

procedure TfrmCalendarPrint.PrintFontComboChange(Sender: TObject);
var
    useScreenFont: boolean;
begin
    useScreenFont := FConfiguration.UseScreenFontForPrint(PrintFontCombo.ItemIndex);
    if useScreenFont then begin
        PrintFontLabel.Font :=  FConfiguration.Fonts(PrintFontCombo.ItemIndex);
    end else begin
        PrintFontLabel.Font :=  FConfiguration.Fonts(PrintFontCombo.ItemIndex + INDEX_PRINT_FONT_OFFSET);
    end;
    PrintFontLabel.Caption := PrintFontLabel.Font.Name;
    UsePrintFontCheck.Checked := not useScreenFont;
end;

procedure TfrmCalendarPrint.UsePrintFontCheckClick(Sender: TObject);
begin
    if FConfiguration.UseScreenFontForPrint(PrintFontCombo.ItemIndex) <> not UsePrintFontCheck.Checked then begin
        FConfiguration.SetUseScreenFontForPrint(PrintFontCombo.ItemIndex, not UsePrintFontCheck.Checked);
        FConfiguration.Fonts(PrintFontCombo.ItemIndex + INDEX_PRINT_FONT_OFFSET).Assign(PrintFontLabel.Font);
        setupPrintFontCombo;
    end;
end;

procedure TfrmCalendarPrint.PrintBtnClick(Sender: TObject);
var
    d1, d2: TDateTime;
    p: TCalendarPrinter;
    orientation: TPrinterOrientation;

begin
    updateConfiguration;
    if CanPrint(d1, d2) then begin
        p := TCalendarPrinter.Create(FConfiguration, frmCalendarPrintPreview.plPrev1);
        p.setCaptionFont(CaptionFontLabel.Font, radioStateToCaptionPosition);
        p.FreeMemoRatio := StrToIntDef(FreeMemoRatioBox.Text, 0);
        p.FreeMemoColumns := IfThen(FreeMemoTwoColumns.Checked, 2, 1);
        p.TodoRatio := StrToIntDef(TodoRatioBox.Text, 0);
        p.LineColor := LineColorBox.Selected;
        p.LineWidth := LineWidthUpDown.Position;
        p.LayoutStyle := IfThen(StyleNormal.Checked, LAYOUT_STYLE_NORMAL, LAYOUT_STYLE_TWO_PART);
        p.AutoWeeks := (WeeksPerPage.ItemIndex = 0);

        orientation := Printer.Orientation; // 印刷向き保存
        if PrintOrientationCombo.ItemIndex = 0 then begin
            Printer.Orientation := poLandscape;
        end;
        frmCalendarPrintPreview.plSetPrinter1.GetPrinterInfo(False);
        try
            p.FileName  := FFilename;
            p.StartDate := d1;
            p.EndDate   := d2;

            if Sender = PrintBtn then p.Print
            else begin
                p.Preview;
                PrinterInfoLabel.Caption := Printer.Printers[Printer.PrinterIndex];
            end;
        except
          on E: Exception do begin
            MessageDlg('印刷処理中にエラーが発生しました．'#13#10 + e.Message, mtError, [mbOK], 0);
          end;
        end;
        Printer.Orientation := orientation; // 復元
        p.Free;

        // 使った設定を保存する
        FConfiguration.PrinterLineColor := LineColorBox.Selected;
        FConfiguration.PrinterLineWidth := LineWidthUpDown.Position;

    end else begin
        MessageDlg('期間予定が不正です．'#13#10'開始年月が終了年月より後に設定されています．', mtError, [mbOK], 0);
    end;
end;

procedure TfrmCalendarPrint.PrinterDialogBtnClick(Sender: TObject);
begin
    if PrintDialog1.Execute then begin
        PrinterInfoLabel.Caption := Printer.Printers[Printer.PrinterIndex];
    end;
end;

procedure TfrmCalendarPrint.FormShow(Sender: TObject);
begin

    try
      LineWidthUpDown.Position := FConfiguration.PrinterLineWidth;
      LineColorBox.Selected := FConfiguration.PrinterLineColor;
      HideOtherMonth.Checked := FConfiguration.OtherMonthPrintSkip;
      CaptionFontLabel.Font.Assign(FConfiguration.Fonts(INDEX_PRINT_HEADERFONT));

      FreeMemoTwoColumns.Checked := FConfiguration.PrintFreememoTwoColumns;
      StyleTwoPart.Checked := FConfiguration.PrintPageTwoColumns;
      StyleNormal.Checked := not FConfiguration.PrintPageTwoColumns;
      FreememoRatioUpDown.Position := FConfiguration.PrintFreememoRatio;
      TodoRatioUpDown.Position := FConfiguration.PrintTodoRatio;
      setRadioStateFromCaptionPosition(IntegerToCaptionPosition(FConfiguration.PrintCaptionPosition));

      PrinterInfoLabel.Caption := Printer.Printers[Printer.PrinterIndex];
      StartYearBox.Text  := IntToStr(YearOf(FBaseDate));
      EndYearBox.Text    := IntToStr(YearOf(FBaseDate));
      StartMonthBox.Text := IntToStr(MonthOf(FBaseDate));
      EndMonthBox.Text   := IntToStr(MonthOf(FBaseDate));
      frmCalendarPrintPreview.plPrev1.plSetPrinter := frmCalendarPrintPreview.plSetPrinter1;
      PrinterDialogBtn.Enabled := true;
      PrintBtn.Enabled := true;
      PreviewBtn.Enabled := true;

      setupPrintFontCombo;
    except
      PrinterInfoLabel.Caption := '(プリンタは現在利用できません)';
      PrinterDialogBtn.Enabled := false;
      PrintBtn.Enabled := false;
      PreviewBtn.Enabled := false;
    end;

end;

procedure TfrmCalendarPrint.CloseBtnClick(Sender: TObject);
begin
    Close;
end;

procedure TfrmCalendarPrint.StartMonthBoxExit(Sender: TObject);
begin
    StartMonthBox.Text := IntToStr(StartMonth.Position);
end;

procedure TfrmCalendarPrint.StartYearBoxExit(Sender: TObject);
begin
    StartYearBox.Text := IntToStr(StartYear.Position);
end;

procedure TfrmCalendarPrint.StyleTwoPartClick(Sender: TObject);
begin
    if StyleTwoPart.Checked and CaptionTopCenter.Checked then begin
        CaptionTopLeft.Checked := true;
    end;
end;



procedure TfrmCalendarPrint.EndYearBoxExit(Sender: TObject);
begin
    EndYearBox.Text := IntToStr(EndYear.Position);
end;

procedure TfrmCalendarPrint.EndMonthBoxExit(Sender: TObject);
begin
    EndMonthBox.Text := IntToStr(EndMonth.Position);
end;

procedure TfrmCalendarPrint.StartMonthChangingEx(Sender: TObject;
  var AllowChange: Boolean; NewValue: Smallint;
  Direction: TUpDownDirection);
begin
    if (StartMonth.Position = 12) and (Direction = updNone) then begin
        StartMonth.Position := 1;
        StartYear.Position := StartYear.Position + 1;
        AllowChange := false;
    end else if (StartMonth.Position = 1) and (Direction = updNone) then begin
        StartMonth.Position := 12;
        StartYear.Position := StartYear.Position - 1;
        AllowChange := false;
    end;
end;

procedure TfrmCalendarPrint.EndMonthChangingEx(Sender: TObject;
  var AllowChange: Boolean; NewValue: Smallint;
  Direction: TUpDownDirection);
begin
    if (EndMonth.Position = 12) and (Direction = updNone) then begin
        EndMonth.Position := 1;
        EndYear.Position := EndYear.Position + 1;
        AllowChange := false;
    end else if (EndMonth.Position = 1) and (Direction = updNone) then begin
        EndMonth.Position := 12;
        EndYear.Position := EndYear.Position - 1;
        AllowChange := false;
    end;
end;

procedure TfrmCalendarPrint.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    frmCalendar.execDialogShortcut(self, Key, Shift);
end;

procedure TfrmCalendarPrint.setRadioStateFromCaptionPosition(pos: TCaptionPosition);
begin
    case pos of
      None:
          CaptionNone.Checked := true;
      TopLeft:
          CaptionTopLeft.Checked := true;
      TopCenter:
          CaptionTopCenter.Checked := true;
      TopRight:
          CaptionTopRight.Checked := true;
      BottomLeft:
          CaptionBottomLeft.Checked := true;
      BottomCenter:
          CaptionBottomCenter.Checked := true;
      BottomRight:
          CaptionBottomRight.Checked := true;
    end;
end;

function TfrmCalendarPrint.radioStateToCaptionPosition: TCaptionPosition;
begin
    if CaptionTopLeft.Checked then
        Result := TopLeft
    else if CaptionTopCenter.Checked then
        Result := TopCenter
    else if CaptionTopRight.Checked then
        Result := TopRight
    else if CaptionBottomLeft.Checked then
        Result := BottomLeft
    else if CaptionBottomCenter.Checked then
        Result := BottomCenter
    else if CaptionBottomRight.Checked then
        Result := BottomRight
    else
        Result := None;
end;

procedure TfrmCalendarPrint.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    updateConfiguration;
end;

procedure TfrmCalendarPrint.FormCreate(Sender: TObject);
begin
    CaptionFontLabel.Caption := CaptionFontLabel.Font.Name;
    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;
end;

procedure TfrmCalendarPrint.CaptionFontButtonClick(Sender: TObject);
begin
    FontDialog1.Font := CaptionFontLabel.Font;
    if FontDialog1.Execute then begin
        CaptionFontLabel.Font := FontDialog1.Font;
        CaptionFontLabel.Caption := CaptionFontLabel.Font.Name;
        FConfiguration.Fonts(INDEX_PRINT_HEADERFONT).Assign(CaptionFontLabel.Font);
    end;
end;

procedure TfrmCalendarPrint.updateConfiguration;
begin
    FConfiguration.OtherMonthPrintSkip := HideOtherMonth.Checked;
    FConfiguration.PrintCaptionPosition :=  CaptionPositionToInteger(radioStateToCaptionPosition);
    FConfiguration.PrintPageTwoColumns := StyleTwoPart.Checked;
    FConfiguration.PrintFreememoRatio := FreememoRatioUpDown.Position;
    FConfiguration.PrintFreememoTwoColumns := FreeMemoTwoColumns.Checked;
    FConfiguration.PrintTodoRatio := TodoRatioUpDown.Position;

end;


end.
