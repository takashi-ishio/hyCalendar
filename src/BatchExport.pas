unit BatchExport;

interface

  procedure exportCalendarFile(exeName, param: string);

implementation

uses
   Classes, SysUtils,
   CalendarConfig,
   DateFormat, StringSplitter, DocumentManager;


const
    KEY_INPUT = 'i';    // ���̓t�@�C�����D�t���܂��͑��΃p�X
    KEY_OUTPUT = 'o';   // �o�̓e�L�X�g�t�@�C�����D
    KEY_RANGE = 'r';    // �o�͔͈́D [���t1]-[���t2]�D���t1�́@yyyymmdd �܂��� yyyymmdd+15 �̂悤�ȑ��Βl�w��
    KEY_FORMAT = 'f';   // Format. txt, csv, tab �̂����ꂩ�D
    KEY_DAYSTYLE = 'd'; // ���t�o�̓X�^�C���D"ymmdd", "ymd", "mmdd", "md" �Ɛ擪�� 'j' �������́C'jg' ��������
    KEY_MISC = 'm';     // ���̑��I�v�V���� VALUE_OPT

    VALUE_FORMAT: array [0..2] of string  = ('txt', 'csv', 'tab');

    DAYSTYLE_COUNT = 10;
    VALUE_DAYSTYLE: array [0..DAYSTYLE_COUNT-1] of string = (
       'ymmdd', 'ymd', 'mmdd', 'md',
       'jymmdd', 'jymd', 'jmmdd', 'jmd', 'jgmmdd', 'jgmd' );

    DAYSTYLE: array [0..DAYSTYLE_COUNT-1] of string = (
       'yyyy/mm/dd', 'yyyy/m/d', 'mm/dd', 'm/d',
       'yyyy''�N''mm''��''dd''��''',
       'yyyy''�N''m''��''d''��''',
       'mm''��''dd''��''',
       'm''��''d''��''',
       'gge''�N''mm''��''dd''��''',
       'gge''�N''m''��''d''��'''
    );

    VALUE_OPT_DAYNAME = 'N'; // �j�����t����
    VALUE_OPT_ALL = 'A';     // ���ԂȂǑS���o��
    VALUE_OPT_REF = 'R';     // �Q�ƃt�@�C���o��
    VALUE_OPT_EMPTY = 'E';   // �\�肪��̓����o��
    VALUE_OPT_CSV = 'C';     // CSV�ɂ�����e�s�ւ̓��t�ǉ�

type
    TExportParam = record
       inputFile: string;
       outputFile: string;
       startDate: TDateTime;
       endDate: TDateTime;
       dayStyle: string;
       outputFormat: TExportStyle;
       miscOptions: TExportSettings;
       error: boolean;
       errorMsg: string;
    end;


function parseRelativeDate(param: string): TDateTime;
var
    plus: integer;
    diff: integer;
    d: TDateTime;
    s: string;
begin
    plus := Pos('+', param);
    if plus > 0 then begin
        d := parseDateDef(Copy(param, 1, plus-1), Date);

        s := Copy(param, plus+1, Length(param));
        if Pos('~', s) = 1 then diff := - StrToIntDef(Copy(s, 2, Length(s)), 0)
        else diff := StrToIntDef(s, 0);
    end else begin
        d := parseDateDef(param, Date);
        diff := 0;
    end;
    Result := d + diff;
end;

procedure parseParam(param: string; var exportOption: TExportParam);
var
    splitter: TStringSplitter;
    keyvalueSplitter: TStringSplitter;
    key, value: string;
    i, idx: integer;
begin
    exportOption.inputFile := '';
    exportOption.outputFile := '';
    exportOption.startDate := Date;
    exportOption.endDate := Date;
    exportOption.dayStyle := DAYSTYLE[0];
    exportOption.outputFormat := expsText;
    exportOption.miscOptions := [];
    exportOption.error := false;
    exportOption.errorMsg := '';

    keyvalueSplitter := TStringSplitter.Create('=');
    splitter := TStringSplitter.Create(',');
    splitter.setString(param);
    while splitter.hasNext do begin
        keyvalueSplitter.setString(splitter.getLine);
        if keyvalueSplitter.hasNext then begin
            key := keyvalueSplitter.getLine;
            if keyvalueSplitter.hasNext then begin
                value := keyvalueSplitter.getLine;

                if key = KEY_INPUT then exportOption.inputFile := value
                else if key = KEY_OUTPUT then exportOption.outputFile := value
                else if key = KEY_RANGE then begin
                    // "-" �̑O��ɂ킯�āC���ꂼ����t�Ƃ��ĔF��
                    idx := Pos('-', value);
                    if idx = 0 then begin
                        exportOption.error := true;
                        exportOption.errorMsg := 'Invalid date format: ' + value;
                    end else begin
                        exportOption.startDate := parseRelativeDate(Copy(value, 1, idx-1));
                        exportOption.endDate   := parseRelativeDate(Copy(value, idx+1, Length(value)));
                    end;
                end else if key = KEY_FORMAT then begin
                    // TXT, CSV, TAB �̂ǂꂩ������
                    if value = VALUE_FORMAT[0] then exportOption.outputFormat := expsText
                    else if value = VALUE_FORMAT[1] then exportOption.outputFormat := expsCSV
                    else if value = VALUE_FORMAT[2] then exportOption.outputFormat := expsTab
                    else begin
                        exportOption.error := true;
                        exportOption.errorMsg := 'Unsupported format type: ' + value;
                    end;
                end else if key = KEY_DAYSTYLE then begin
                    // ���t�t�H�[�}�b�g�̎w��
                    i := 0;
                    while i < DAYSTYLE_COUNT do begin
                        if value = VALUE_DAYSTYLE[i] then begin
                            exportOption.dayStyle := DAYSTYLE[i];
                            break;
                        end;
                        inc(i);
                    end;
                    if i = DAYSTYLE_COUNT then begin
                        exportOption.error := true;
                        exportOption.errorMsg := 'Unsupported daystyle type: ' + value;
                    end;
                end else if key = KEY_MISC then begin
                    // ���̑��I�v�V����
                    if Pos(VALUE_OPT_DAYNAME, value) > 0 then exportOption.miscOptions := exportOption.miscOptions + [expYoubi];
                    if Pos(VALUE_OPT_ALL, value) > 0 then exportOption.miscOptions := exportOption.miscOptions + [expRangeSeriesTodo];
                    if Pos(VALUE_OPT_REF, value) > 0 then exportOption.miscOptions := exportOption.miscOptions + [expReferences];
                    if Pos(VALUE_OPT_EMPTY, value) > 0 then exportOption.miscOptions := exportOption.miscOptions + [expEmptyItem];
                    if Pos(VALUE_OPT_CSV, value) > 0 then exportOption.miscOptions := exportOption.miscOptions + [expCSVWithDateHead];
                end else begin
                    exportOption.error := true;
                    exportOption.errorMsg := 'Unknown key: ' + key;
                end;
            end;
        end;
        if exportOption.error then begin
            splitter.Free;
            keyvalueSplitter.Free;
            Exit;
        end;
    end;
    Splitter.Free;
    keyvalueSplitter.Free;
end;

procedure exportCalendarFile(exeName, param: string);
var
    params: TExportParam;
    text: TStringList;
    config: TCalendarConfiguration;

begin
    config := TCalendarConfiguration.Create( ExtractFilePath(exeName) + 'hycalendar.ini', nil);
    config.ReadIniFile;
    TDocumentManager.getInstance.Configuration := config;


    parseParam(param, params);
    if (params.inputFile = '') or (params.outputFile = '') then Exit;

    text := TStringList.Create;
    if not params.error then begin
        try
            if TDocumentManager.getInstance.loadFrom(params.inputFile) then begin
                text := TStringList.Create;
                TDocumentManager.getInstance.makeExportText(params.startDate,
                    params.endDate, params.dayStyle, params.outputFormat,
                    params.miscOptions, text);
            end else begin
                text.Add('ERROR: Failed to load a file: ' + params.inputFile);
            end;
        except
            on e: Exception do begin
               text.Add('ERROR: Failed to export a file: ' + params.inputFile);
               text.Add(e.Message);
            end;
        end;
    end else begin
        text.add('ERROR: Failed to parse a parameter: ' + param);
        text.add(params.errorMsg);
    end;
    try
        text.SaveToFile(params.outputFile);
    except
    end;
    text.Free;
end;



end.
