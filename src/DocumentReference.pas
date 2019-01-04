unit DocumentReference;

interface

uses
    Controls, CalendarItem, SysUtils;

const
    SEPARATOR_REFERENCE_FILENAME = '|';

type

  TDocumentReference = class
  private
    FHeader: string;
    FStatus: string;
    FVisible: Boolean;
  protected
    constructor Create;
    function getFilename: TFilename; virtual; abstract;
  public
    function getItem(day: TDate): TCalendarItem; virtual; abstract;
    function FilenameWithProperties: string;
    property Header: string read FHeader write FHeader;
    property Visible: boolean read FVisible write FVisible;
    property Filename: TFilename read getFilename;
    property Status: string read FStatus write FStatus;
  end;


implementation

constructor TDocumentReference.Create;
begin
    inherited;
    FHeader := '';
    FStatus := '';
    FVisible := true;
end;

function TDocumentReference.FilenameWithProperties: string;
begin
    if FVisible then
        Result := getFilename
    else
        Result := getFilename + SEPARATOR_REFERENCE_FILENAME + BoolToStr(FVisible, true);
end;

end.
