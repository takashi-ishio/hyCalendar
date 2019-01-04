unit ColoredStringList;

interface

uses
  Classes, Graphics;

type
  TColoredStringList = class
  private
    FList: TList;

  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Add(text: string; color: TColor; userColor: boolean);
    function Count: integer;
    function Text(idx: Integer): string;
    function Color(idx: Integer): TColor;
    function IsUserColor(idx: integer): boolean;
  end;

implementation

type
  TColoredString = record
    text: string;
    color: TColor;
    userColor: boolean;
  end;
  PColoredString = ^TColoredString;

constructor TColoredStringList.Create;
begin
  FList := TList.Create;
end;

procedure TColoredStringList.Clear;
var
  i: integer;
begin
  for i:=0 to Count-1 do begin
    dispose(FList[i]);
  end;
  FList.Clear;
end;

destructor TColoredStringList.Destroy;
begin
  Clear;
  FList.Free;
end;

procedure TColoredStringList.Add(text: string; color: TColor; userColor: boolean);
var
  p: PColoredString;
begin
  new(p);
  p.text := text;
  p.color := color;
  p.userColor := userColor;
  FList.Add(p);
end;

function TColoredStringList.Count: integer;
begin
  Result := FList.Count;
end;

function TColoredStringList.Text(idx: Integer): string;
begin
  Result := PColoredString(FList[idx]).text;
end;

function TColoredStringList.Color(idx: Integer): TColor;
begin
  Result := PColoredString(FList[idx]).Color;
end;

function TColoredStringList.IsUserColor(idx: integer): boolean;
begin
  Result := PColoredString(FList[idx]).userColor;
end;


end.
