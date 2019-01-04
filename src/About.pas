unit About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmAbout = class(TForm)
    btnOK: TButton;
    memoVersionInfo: TMemo;
    Image1: TImage;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private éŒ¾ }
  public
    { Public éŒ¾ }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.dfm}

procedure TfrmAbout.btnOKClick(Sender: TObject);
begin
    Close;
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
var
  S: string;
  n, Len: DWORD;
  Buf: PChar;
  Value: PChar;

begin

  S := Application.ExeName;
  n := GetFileVersionInfoSize(PChar(S), n);

  if n > 0 then
  begin
    buf := StrAlloc(n);
    if GetFileVersionInfo(PChar(S), 0, n, Buf) then
        if VerQueryValue(Buf, PChar('StringFileInfo\041103A4\FileVersion'), Pointer(Value), Len) then
            MemoVersionInfo.Lines[0] := MemoVersionInfo.Lines[0] + Value;

    StrDispose(buf);
  end;

    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;
  
end;

end.
