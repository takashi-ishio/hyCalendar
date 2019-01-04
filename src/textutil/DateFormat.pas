unit DateFormat;
// ���P�[����ˑ��ȕ�����֐���񋟂���D
// StrToDate �̂����� parseDate
// DateToStr �̂����� unparseDate

// -- �Ƃ����Ă��C���ۂɂ̓��P�[���ˑ��ȃO���[�o���ϐ���ϊ��̂�
//    �Đݒ肵�Ă��邾�������C�ł��ȕւȎ����Ȃ̂ł�����̗p���Ă���D
//    �iShortDateFormat �Ȃǂ̃O���[�o���ϐ��� Windows �̐ݒ肪�ς���
//      �����ɒl���ς��j

interface

const
    SAVE_DATE_FORMAT = 'yyyy/mm/dd'; // �V�X�e���� 'yyyy/MM/dd' �ɑ���
    SAVE_DATE_SEPARATOR = '/';


    //procedure saveOriginalDateFormat;

    //function getOriginalDateSeparator: char;
    function TryParseDate(s: string; var d: TDateTime): boolean;
    function parseDate(str: string): TDateTime;
    function parseDateDef(str: string; default: TDateTime): TDateTime;

    function unparseDate(d: TDateTime): string;

implementation

uses SysUtils;

//var
//    originalDateFormat : string;
//    originalDateSeparator : char;

procedure selectSaveDateFormat;
begin
    ShortDateFormat := SAVE_DATE_FORMAT;
    DateSeparator := SAVE_DATE_SEPARATOR;
end;


function TryParseDate(s: string; var d: TDateTime): boolean;
begin
    selectSaveDateFormat;
    Result := TryStrToDate(s, d);
end;

function parseDate(str: string): TDateTime;
begin
    selectSaveDateFormat;
    Result := StrToDate(str);
end;

function parseDateDef(str: string; default: TDateTime): TDateTime;
begin
    selectSaveDateFormat;
    Result := StrToDateDef(str, default);
end;

function unparseDate(d: TDateTime): string;
begin
    selectSaveDateFormat;
    Result := FormatDateTime(ShortDateFormat, d);
end;

//function getOriginalDateSeparator: char;
//begin
//    Result := originalDateSeparator;
//end;

//procedure saveOriginalDateFormat;
//begin
//    originalDateFormat := ShortDateFormat;
//    originalDateSeparator := DateSeparator;
//    DateSeparator := SAVE_DATE_SEPARATOR;
//    ShortDateFormat := SAVE_DATE_FORMAT;
//end;

//initialization
//    originalDateSeparator := #0;


end.
