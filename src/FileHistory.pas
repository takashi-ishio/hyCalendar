unit FileHistory;

interface

uses Classes;

type
    TFileHistory = class
    private
        files: TStringList; // ファイル名，新しいものほど末尾に格納

        procedure setSize(new_size: integer);
        function getSize: integer;
    public
        constructor Create;
        destructor Destroy; override;
        procedure Add(filename: string);
        procedure Clear;
        function getFilename(idx: integer): string;
        function isEnable(idx: integer): boolean;  // そのエントリが有効かどうか
        function hasEntry: boolean;
        property Size: integer read getSize write setSize;
    end;


implementation

constructor TFileHistory.Create;
begin
    files := TStringList.Create;
end;

destructor TFileHistory.Destroy;
begin
    files.Free;
end;

function TFileHistory.hasEntry: boolean;
var
    i: integer;
    b: boolean;
begin
    b := false;
    for i:=0 to files.Count-1 do begin
        b := b or isEnable(i);
    end;
    Result := b;
end;

function TFileHistory.isEnable(idx: integer): boolean;
begin
    Result := getFilename(idx) <> '';
end;

function TFileHistory.getFilename(idx: integer): string;
begin
    // idx 番目に新しい（末尾からidx番目)のファイル名を返す．
    Result := files[files.Count - 1 - idx];
end;

procedure TFileHistory.Add(filename: string);
var
    idx: integer;
begin
    if Size = 0 then exit;
    // ファイル名がリストに含まれていればそれを削除
    // そうでない場合は先頭（一番古いエントリ）を削除
    idx := files.IndexOf(filename);
    if (idx >= 0)and(idx<files.Count) then files.Delete(idx)
    else files.Delete(0);

    // ファイルの末尾にアイテムに追加．
    files.Add(filename);
end;

procedure TFileHistory.setSize(new_size: integer);
begin
    if new_size < files.Count then begin
        // 余分なエントリを削除
        while files.Count > new_size do files.Delete(0);
    end;
    if new_size > files.Count then begin
        // 足りないエントリを空で埋める
        while files.Count < new_size do files.Insert(0, '');
    end;
end;

function TFileHistory.getSize: integer;
begin
    Result := files.Count;
end;

procedure TFileHistory.Clear;
var
    i: integer;
begin
    for i:=0 to files.Count-1 do begin
        files[i] := '';
    end;
end;


end.
