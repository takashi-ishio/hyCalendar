unit SeriesItemProeprtyEditDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  SeriesItem, DateTimePickerEnhance;

type
  TfrmSeriesItemPropertyEditDialog = class(TForm)
    GroupBox1: TGroupBox;
    ItemIsHidden: TCheckBox;
    SeriesItemNameBox: TEdit;
    ItemIsShownAsDayName: TCheckBox;
    ItemIsHoliday: TCheckBox;
    Label1: TLabel;
    OKBtn: TButton;
    Button2: TButton;
    FontColorBox: TColorBox;
    UseColorBox: TCheckBox;
    SpecifyBaseDateCheck: TCheckBox;
    BaseDatePicker: TDateTimePicker;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
    procedure setSeriesItem(item: TSeriesItem);
    procedure getSeriesItem(item: TSeriesItem);
  end;

var
  frmSeriesItemPropertyEditDialog: TfrmSeriesItemPropertyEditDialog;

implementation

{$R *.dfm}

procedure TfrmSeriesItemPropertyEditDialog.setSeriesItem(item: TSeriesItem);
begin
    if item <> nil then begin
        SeriesItemNameBox.Text := item.Name;
        ItemIsHidden.Checked := item.IsHidden;
        ItemIsShownAsDayName.Checked := item.IsShownAsDayName;
        ItemIsHoliday.Checked := item.IsHoliday;
        UseColorBox.Checked := item.UseColor;
        FontColorBox.Selected := item.Color;
        SpecifyBaseDateCheck.Checked := item.SpecifyBaseDate;
        if item.SpecifyBaseDate then
            BaseDatePicker.Date := item.BaseDate
        else
            BaseDatePicker.Date := Date;
        OKBtn.Caption := 'çXêV';
    end else begin
        SeriesItemNameBox.Text := '';
        ItemIsHidden.Checked := false;
        ItemIsShownAsDayName.Checked := false;
        ItemIsHoliday.Checked := false;
        UseColorBox.Checked := false;
        FontColorBox.Selected := clBlack;
        SpecifyBaseDateCheck.Checked := false;
        BaseDatePicker.Date := Date;
        OKBtn.Caption := 'í«â¡';
    end;
end;

procedure TfrmSeriesItemPropertyEditDialog.getSeriesItem(item: TSeriesItem);
begin
    item.Name := SeriesItemNameBox.Text;
    item.IsHidden := ItemIsHidden.Checked;
    item.IsShownAsDayName := ItemIsShownAsDayName.Checked;
    item.IsHoliday := ItemIsHoliday.Checked;
    item.UseColor := UseColorBox.Checked;
    item.Color := FontColorBox.Selected;
    item.SpecifyBaseDate := SpecifyBaseDateCheck.Checked;
    item.BaseDate := BaseDatePicker.Date;
end;


procedure TfrmSeriesItemPropertyEditDialog.FormCreate(Sender: TObject);
begin
    DateTimePickerEnhance.enhancePicker(BaseDatePicker);
    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;
end;

procedure TfrmSeriesItemPropertyEditDialog.FormShow(Sender: TObject);
begin
    SeriesItemNameBox.SetFocus;
end;

end.
