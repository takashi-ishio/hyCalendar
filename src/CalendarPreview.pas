unit CalendarPreview;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PLPREVFRM, Menus, ExtCtrls, ComCtrls, Buttons, ToolWin,
  plSetPrinter, plPrev;

type
  TPrintEvent = procedure of object;

  TfrmCalendarPrintPreview = class(TplPrevForm)
    plPrev1: TplPrev;
    plSetPrinter1: TplSetPrinter;
    procedure PrintBtnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
    { Private êÈåæ }
    FOnPrintClick: TPrintEvent;
  public
    { Public êÈåæ }

    property OnPrintClick: TPrintEvent write FOnPrintClick;
  end;

var
  frmCalendarPrintPreview: TfrmCalendarPrintPreview;

implementation

{$R *.dfm}

procedure TfrmCalendarPrintPreview.PrintBtnClick(Sender: TObject);
begin
    FOnPrintClick;
end;

procedure TfrmCalendarPrintPreview.FormCreate(Sender: TObject);
begin
  inherited;
  self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
  self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;
end;

procedure TfrmCalendarPrintPreview.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = VK_ESCAPE then CloseBtn.Click;
end;

end.
