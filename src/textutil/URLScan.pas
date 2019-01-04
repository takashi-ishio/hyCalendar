unit URLScan;

interface

uses Classes, SysUtils, DateUtils, Constants,
  StrUtils, StringSplitter;



const
    PROTOCOL_HTTP = 'http:';
    PROTOCOL_HTTPS = 'https:';
    PROTOCOL_MAIL = 'mailto:';
    PROTOCOL_FILE = 'file:';
    PROTOCOL_FTP = 'ftp:';

    Quotation = '"';

    MAX_PROTOCOL_INDEX = 4;
    PROTOCOLS: array[0..MAX_PROTOCOL_INDEX] of string = (PROTOCOL_HTTP, PROTOCOL_HTTPS, PROTOCOL_MAIL, PROTOCOL_FILE, PROTOCOL_FTP);

type
    TURLPosition = class
    public
        line: integer;
        col: integer;
        len: integer;

        visible: boolean;
        top: integer;
        left: integer;
        right: integer;
        bottom: integer;

        constructor Create;
    end;

    TURLExtractor = class
    private
        FSplitter: TStringSplitter;
        FDateChar : set of char;
        FMaxDateLength : integer;

        constructor Create;

    public
        class function getInstance: TURLExtractor;
        destructor Destroy; override;

        procedure extractURL(key_pos: integer; target: string;
                            var idx: integer; var url: string);

        function removeURLString(s: string): string;
        function removeDateFromString(s: string): string;

        procedure extractURLs(target: string; urls: TStrings; default_year: integer );
        procedure cleanupURLs(urls: TStrings);

        procedure extractDate(key_pos: integer; target: string; default_year: integer; var idx, len: integer; var day: TDateTime);

        function isDateURL(s: string): boolean;

    end;



implementation

uses
    DateFormat;

var
    extractor: TURLExtractor;

const
    WebUrlChar = ['0'..'9','A'..'Z','a'..'z','%',':','-','.','/','~','_', '@', '#', '&', '=', '$', '?', '+', ',', ';'];
    CRLFChar = [#13, #10];



constructor TURLPosition.Create;
begin
    line := 0;
    col := 0;
    len := 0;
end;



class function TURLExtractor.getInstance: TURLExtractor;
begin
    if extractor = nil then begin
        extractor := TURLExtractor.Create;
    end;
    Result := extractor;
end;

constructor TURLExtractor.Create;
begin
    FSplitter := TStringSplitter.Create;
    FDateChar := ['0'..'9', DateFormat.SAVE_DATE_SEPARATOR ];
    FMaxDateLength := 10;
end;

destructor TURLExtractor.Destroy;
begin
    FSplitter.Free;
end;

// idx �� URL �̊J�n�ʒu�Curl �ɕ����������D
// ���݂��Ȃ��ꍇ�� idx = 0, url = '' ��Ԃ�
procedure TURLExtractor.extractURL(key_pos: integer; target: string; var idx: integer; var url: string);
var
  S1, S2: string;
  P: integer;
  i: integer;
  quoted: boolean;
begin
  P := key_pos;
  url:= '';
  idx:=0;
  S1:= target;
  repeat                  //���[�v�����ŕ����������������� protocol �̎n�܂�ʒu������
    if (P = 0) then Exit; //or not (S1[P] in WebURLChar)

    S2:= Copy(S1, P, Length(S1));
    for i:=0 to MAX_PROTOCOL_INDEX do begin
        if AnsiStartsStr(PROTOCOLS[i], S2) then begin
            idx:=P;
        end;
    end;
    if idx > 0 then break;
    Dec(P);
  until False; // �������[�v

  // http: �Ȃǂ̎n�܂�ʒu����C���邾���̕������������� URL ����
  // WebURLChar ���C�������̓p�X���̑S�p�����͋���
  P:= 1;
  quoted := false;
  while ((S2[P] in WebURLChar) or  //(ByteType(S2, P) <> mbSingleByte)
        (S2[P] = Quotation) or
        (quoted and not(S2[P] in CRLFChar))) and
        (P <= Length(S2)) do begin
      if S2[P] = Quotation then quoted := not quoted;
      Inc(P);
  end;
  url := Copy(S2, 1, P-1);
  if (idx + P-1 <= key_pos) then begin   // ���邾���Ƃ��āC�����ʒu�ɓ͂��Ȃ�������O��
    url := '';
    idx := 0;
  end;
end;



procedure TURLExtractor.extractURLs(target: string; urls: TStrings; default_year: integer);
var
    s: string;
    i: integer;
    line :integer;
    urlpos : TURLPosition;

    procedure testURL(protocol: string; target: string);
    var
        idx: integer;
        url: string;
        head: integer;
        parsed: string;
    begin
        parsed := '';
        idx := AnsiPos(protocol, target);
        while idx > 0 do begin
            extractURL(idx, target, head, url);
            urlpos := TURLPosition.Create;
            urlpos.line := line;
            urlpos.col := Length(parsed)+head;
            urlpos.len := Length(url);
            urls.AddObject(url, urlpos);
            parsed := parsed + Copy(target, 1, head + Length(url) );
            target := Copy(target, head + Length(url) + 1, Length(target));
            idx := AnsiPos(protocol, target);
        end
    end;

    procedure testDate(target: string);
    var
        idx: integer;
        i,len: integer;
        d: TDateTime;
        s, parsed : string;
    begin
        s := target;
        idx := AnsiPos(DateSeparator, s);
        while idx > 0 do begin
            extractDate(idx+Length(parsed), target, default_year, i, len, d);
            if d > 0 then begin
                parsed := Copy(target, 1, i+len);
                s := Copy(target, i+len+1, Length(target));
                urlpos := TURLPosition.Create;
                urlpos.line := line;
                urlpos.col := i;
                urlpos.len := len;
                urls.AddObject(DateFormat.unparseDate(d), urlpos);
            end else begin
                parsed := parsed + Copy(s, 1, idx);
                s := Copy(s, idx+1, Length(s));
            end;
            idx := AnsiPos(DateSeparator, s);
        end;
    end;

begin
    cleanupURLs(urls);

    line := 0;
    FSplitter.setString(target);
    while FSplitter.hasNext do begin
        s := FSplitter.getLine;
        for i:=0 to MAX_PROTOCOL_INDEX do begin
            testURL(PROTOCOLS[i], s);
        end;
        testDate(s);
        inc(line);
    end;
end;


procedure TURLExtractor.cleanupURLs(urls: TStrings);
var
    i : integer;
begin
    for i:=0 to urls.Count-1 do begin
        urls.Objects[i].Free;
    end;
    urls.Clear;
end;


function TURLExtractor.removeURLString(s: string): string;
var
    idx : integer;
    idx2: integer;
    url : string;

    function findURLHead: integer;
    var
        i: integer;
        j: integer;
    begin
        for i:=0 to MAX_PROTOCOL_INDEX do begin
            j := AnsiPos(PROTOCOLS[i], s);
            if j>0 then begin
                Result := j;
                exit;
            end;
        end;
        Result := 0;
    end;

begin
    idx := findURLHead;
    while idx > 0 do begin
        extractURL(idx, s, idx2, url);
        s := Copy(s, 1, idx2-1) + Copy(s, idx2 + Length(URL), Length(s));
        idx := findURLHead;
    end;
    Result := s;
end;


procedure TURLExtractor.extractDate(key_pos: integer; target: string; default_year: integer; var idx, len: integer; var day: TDateTime);
var
    i: integer;
    P, L: integer;
    S1: string;
    d1, d2, d3: integer;
    pivot: integer;
begin
  idx:=0;
  day:=0;

  // P:= DateChar ������Q�̐擪(������̐擪�܂Ŗ߂��Ă���)
  P := key_pos;
  if not (target[P] in FDateChar) then Exit;
  while (P >= 1) do begin
    if not (target[P] in FDateChar) then begin
        P:=P + 1;
        break;
    end;
    Dec(P);
  end;
  if P=0 then P:=1;
  if not (target[P] in FDateChar) or (target[P] = DateSeparator) then exit;

  // L:= DateChar ������̒���
  L := 0;
  while target[P + L] in FDateChar do Inc(L);
  if L > FMaxDateLength then exit;

    //
    S1 := Copy(target, P, L);
    i := AnsiPos(DateSeparator, S1);
    if (i <= 1)or(i>5) then exit;
    d1 := StrToIntDef(Copy(S1, 1, i-1), -1);
    S1 := Copy(S1, i+1, Length(S1));

    i := AnsiPos(DateSeparator, S1);
    if i = 1 then exit
    else if i = 0 then begin
      // m/d �`�� �̂͂�
      if d1>12 then exit;
      if Length(S1) > 2 then exit;
      d2 := StrToIntDef(S1, -1);
      idx := P;
      len := L;
      if not TryEncodeDate(default_year, d1, d2, day) then begin
        idx := 0;
        day := 0;
        exit;
      end;
    end else begin
      d2 := StrToIntDef(Copy(S1, 1, i-1), -1);
      S1 := Copy(S1, i+1, Length(S1));

      // �Q���̔N�̏ꍇ�C�S���ɒ����Ĕ���
      if d1 < 100 then begin
          pivot := default_year - TwoDigitYearCenturyWindow;
          if (pivot mod 100) > d1 then d1 := d1 + (default_year div 100)*100
          else d1 := d1 - 100 + (default_year div 100)*100;
      end;

      if ((d1>MAX_YEAR)or(d1<MIN_YEAR)) then exit;

      if (d2>12) then exit;
      if Length(S1) > 2 then exit;

      i := AnsiPos(DateSeparator, S1);
      if i <> 0 then exit;
      d3 := StrToIntDef(S1, -1);

      idx := P;
      len := L;
      if not TryEncodeDate(d1, d2, d3, day) then begin
          idx := 0;
          day := 0;
          exit;
      end;
    end;
end;


// URL �����t���ǂ������`�F�b�N����
// �C��: ���̊֐��� PROTOCOLS �Ɋ܂܂�Ă���URL �ł͂Ȃ����Ƃ���ʂ��邾���ŁC
// �����ɓ��t�`���ł��邱�Ƃ𔻒肵�Ă��Ȃ�����
function TURLExtractor.isDateURL(s: string): boolean;
var
    d: TDateTime;
begin
    Result := TryStrToDate(s, d);
end;

function TURLExtractor.removeDateFromString(s: string): string;
var
    idx: integer;
    i,len: integer;
    d: TDateTime;
    parsed : string;
    default_year: Integer;
begin
    default_year := 2000; // ���ۂɂ͌��ʂ̒l���g��Ȃ��̂ŁC�Ӗ����Ȃ�

    idx := AnsiPos(DateSeparator, s);
    while idx > 0 do begin
        extractDate(idx, s, default_year, i, len, d);
        if d > 0 then begin
            parsed := parsed + Copy(s, 1, i-1);
            s := Copy(s, i+len, Length(s));
        end else begin
            parsed := parsed + Copy(s, 1, idx);
            s := Copy(s, idx+1, Length(s));
        end;
        idx := AnsiPos(DateSeparator, s);
    end;
    Result := parsed + s;
end;


initialization
    extractor := nil;

finalization
    extractor.Free;


end.
