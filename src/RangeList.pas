unit RangeList;
// 日付区間の管理用リスト．従来の期間予定とは意味が異なる．

interface

uses
  Classes;

type

    TRangeList = class
    private
      FList: TList;

    public
      constructor Create;
      destructor Destroy; override;

      procedure Add(ymd_from, ymd_to: TDateTime);
      procedure Clear;
      function Count: integer;
      function Get(index: integer; var ymd_from, ymd_to: TDateTime): boolean;
    end;

implementation

type
    TRange = record
      ymd_from: TDateTime;
      ymd_to: TDateTime;
    end;
    PRange = ^TRange;


constructor TRangeList.Create;
begin
  FList := TList.Create;
end;

destructor TRangeList.Destroy;
begin
  Clear;
  FList.Free;
end;

function TRangeList.Get(index: integer; var ymd_from, ymd_to: TDateTime): boolean;
var
  p: PRange;
begin
  if (index < 0)or(index >= Count) then begin
    Result := false;
  end else begin
    Result := true;
    p := FList[index];
    ymd_from := p.ymd_from;
    ymd_to := p.ymd_to;
  end;
end;

procedure TRangeList.Add(ymd_from, ymd_to: TDateTime);
var
  p: PRange;
  tmp: TDateTime;
begin
  new(p);

  if ymd_from > ymd_to then begin
    tmp := ymd_to;
    ymd_to := ymd_from;
    ymd_from := tmp;
  end;

  p.ymd_from := ymd_from;
  p.ymd_to := ymd_to;
  FList.Add(p);
end;

procedure TRangeList.Clear;
var
  i: integer;
begin
  for i := 0 to FList.Count - 1 do
    Dispose(FList[i]);
  FList.Clear;
end;

function TRangeList.Count: integer;
begin
  Result := FList.Count;
end;


end.
