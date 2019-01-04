unit StringSplitter;

interface

uses
    Classes, SysUtils;

type
    TStringSplitter = class
    private
        s: string;
        CRLF: string;
        FBeforeFirst: boolean;
        FIsFirst : boolean;
        FhasNext : boolean;
    public
        constructor Create; overload;
        constructor Create(separator: string); overload;
        destructor Destroy; override;
        procedure setString(text: string);
        function getLine: string;
        procedure resetSeparator(separator: string);
        property separator: string read CRLF;
        property hasNext: boolean read FhasNext;
        property isFirst: boolean read FIsFirst; // ç≈èâÇÃÉAÉCÉeÉÄÇ getLine ÇµÇΩå„ÇæÇØ True
    end;


implementation


constructor TStringSplitter.Create;
begin
    Create(#13#10);
end;

constructor TStringSplitter.Create(separator: string);
begin
    s := '';
    CRLF := separator;
end;

destructor TStringSplitter.Destroy;
begin
  inherited;
end;

procedure TStringSplitter.setString(text: string);
begin
    s := text;
    FBeforeFirst := true;
    FIsFirst := false;
    FhasNext := (s <> '');
end;

procedure TStringSplitter.resetSeparator(separator: string);
begin
    CRLF := separator;
end;

function TStringSplitter.getLine: string;
var
    idx : integer;
begin
    idx := AnsiPos( CRLF, s );
    if idx > 0 then begin
        Result := Copy(s, 1, idx-1);
        s := Copy(s, idx+Length(CRLF), Length(s));
    end else begin
        Result := s;
        s := '';
        FhasNext := false;
    end;
    FIsFirst := FBeforeFirst;
    FBeforeFirst := false;
end;

end.
