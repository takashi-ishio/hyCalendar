unit Hyperlinks;

interface

uses
    Menus, StdCtrls, SysUtils, StrUtils, ShellAPI, Forms, Classes, Windows,
    Dialogs,
    DateFormat, DateValidation, URLSCan;

type
    THyperlink = class

    private
        FHyperlinks: TStringList;

    public

        constructor Create;
        destructor Destroy; override;

        procedure HyperLinkDblClick(Sender: TObject);
        procedure OpenHyperLink(url: string);

        procedure registerHyperLink(list: TStringList);

    end;

implementation

uses
    Calendar;

constructor THyperlink.Create;
begin
    FHyperlinks := TStringList.Create;
end;

destructor THyperlink.Destroy;
begin
    FHyperlinks.Free;
end;

// ���j���[���ォ�� Tag �l�ŎQ�Ƃł��� URL ��o�^����
procedure THyperlink.registerHyperLink(list: TStringList);
var
  i: integer;
begin
    FHyperlinks.Clear;
    for i := 0 to List.Count - 1 do
      FHyperlinks.Add(list[i]);
end;

procedure THyperlink.HyperLinkDblClick(Sender: TObject);
var
    filename :string;
    idx: integer;
begin
    if Sender is TStaticText then filename := TStaticText(Sender).Caption
    else if Sender is TMenuItem then begin
      idx := TMenuItem(Sender).Tag;
      if idx >= FHyperlinks.Count then exit;
      filename := FHyperlinks[ idx ];
    end else exit;
    openHyperLink(filename);
end;



procedure THyperlink.OpenHyperLink(url: string);
var
    path: string;
    parameter: string;
    d: TDateTime;
    i: integer;
begin
    for i:=0 to MAX_PROTOCOL_INDEX do begin
        if AnsiPos(PROTOCOLS[i], url) = 1 then begin
            url := StringReplace(url, Quotation, '', [rfReplaceAll]);

            // file: �̏ꍇ�́C file: ���폜���Ȃ��� "C:\dir" �^�C�v���J���Ȃ��D C:/Home �`���� file: �Ȃ��ŊJ����D
            if AnsiStartsStr(PROTOCOL_FILE, url) then url := StringReplace(url, PROTOCOL_FILE, '', []);
            
            parameter := '';
            path := GetCurrentDir;
            ShellExecute(Application.Handle, 'Open', PChar(url), PChar(parameter), PChar(path), 1);
            exit;
        end;
    end;

    // �ǂ̃v���g�R���ł��Ȃ������t�̂͂�
    try
        d := DateFormat.parseDate(url);
        if not isValid(d) then exit;

        if IsIconic(Application.Handle) then begin
            // Acivate Application ���Ă����A���Ȃ��̂� SW_RESTORE �ŋ������A
            frmCalendar.ActivateApplication;
            ShowWindow(Application.Handle, SW_RESTORE);
        end;

        frmCalendar.MoveDateDefault(d);

    except
        on EConvertError do;
    end;
end;

end.
