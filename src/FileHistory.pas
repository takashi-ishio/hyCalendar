unit FileHistory;

interface

uses Classes;

type
    TFileHistory = class
    private
        files: TStringList; // �t�@�C�����C�V�������̂قǖ����Ɋi�[

        procedure setSize(new_size: integer);
        function getSize: integer;
    public
        constructor Create;
        destructor Destroy; override;
        procedure Add(filename: string);
        procedure Clear;
        function getFilename(idx: integer): string;
        function isEnable(idx: integer): boolean;  // ���̃G���g�����L�����ǂ���
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
    // idx �ԖڂɐV�����i��������idx�Ԗ�)�̃t�@�C������Ԃ��D
    Result := files[files.Count - 1 - idx];
end;

procedure TFileHistory.Add(filename: string);
var
    idx: integer;
begin
    if Size = 0 then exit;
    // �t�@�C���������X�g�Ɋ܂܂�Ă���΂�����폜
    // �����łȂ��ꍇ�͐擪�i��ԌÂ��G���g���j���폜
    idx := files.IndexOf(filename);
    if (idx >= 0)and(idx<files.Count) then files.Delete(idx)
    else files.Delete(0);

    // �t�@�C���̖����ɃA�C�e���ɒǉ��D
    files.Add(filename);
end;

procedure TFileHistory.setSize(new_size: integer);
begin
    if new_size < files.Count then begin
        // �]���ȃG���g�����폜
        while files.Count > new_size do files.Delete(0);
    end;
    if new_size > files.Count then begin
        // ����Ȃ��G���g������Ŗ��߂�
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
