{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
unit TextUtils;

interface

uses Windows, Graphics;

function GetTextAAdjust(ACanvas: TCanvas; s: string): Integer;

function GetTextCAdjust(ACanvas: TCanvas; s: string): Integer;

type
 TFormatOption = (foJustify, foEven, foRight, foCenter, foKerning);
 // foJustify: ���[����
 // foEven:    �ϓ�����t��
 // foRight:   �E����
 // foCenter:  ��������(�E�����ɗD�悷��)
 // foKerning: �J�[�j���O���s��
 TFormatOptions = set of TFormatOption;

 TDXArray = array of Integer;

function GetTextPosition(
  ws: WideString;                // ������
  FontHeight: Double;           // �t�H���g�̍���(Twips)
  FontHandle: THandle;          // �t�H���g�n���h��
  MaxExtent: Double;            // �ő�\����(Twips)
  PixelsPerInch: Integer;       // �\���p�f�o�C�X�̘_���C���`
  Options: TFormatOptions;      // �I�v�V����
  var Offset: Integer;          // �\���I�t�Z�b�g(�s�N�Z��)
  var FittedChars: Integer;     // �ő�\�����ɕ\���ł��镶����
  var DXs: TDxArray             // �e�����̕������̔z��(�s�N�Z��)
  ): WideString;                // �߂�l�͕\���ł��Ȃ������c��̕�����

implementation

uses SysUtils;

// �����񂪕����Z���̑O�ɂ͂ݏo���������Z�o����
function GetTextAAdjust(ACanvas: TCanvas; s: string): Integer;
var
  FirstChar: DWORD; //������̍ŏ��̕����̃R�[�h
  ABC: TABC;        //ABC���󂯎�郌�R�[�h
  ABCF: TABCFloat;
  tm: TTextMetric;  //�e�L�X�g���g���b�N

  // �ŏ��̕����̕����R�[�h���擾����
  function GetFirstChar(s: string): DWORD;
  var
    NextChar: PChar;
  begin
    NextChar := CharNext(PChar(s));
    if (NextChar - PChar(s)) = 2 then
      Result := Ord(s[1]) * 256 + Ord(S[2])
    else if (NextChar - PChar(s)) = 1 then
      Result := Ord(s[1])
    else
      Result := 0;
  end;
begin
  FirstChar := GetFirstChar(s); // �ŏ��������̃R�[�h�𓾂�
  if FirstChar = 0 then   // �����񒷂��O
  begin
    Result := 0;
    Exit;
  end;

  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    begin
      // �ŏ��̕�����A�������߂�
      GetCharABCWidthsFloat(ACanvas.Handle, FirstChar, FirstChar, ABCF);
      // ���Ȃ炻�̑傫����Ԃ�
      if ABCF.abcfA < 0 then
        Result := -Round(ABCF.abcfA)
      else
        Result := 0
    end;
  end
  else
  begin
    //TrueType���`�F�b�N
    GetTExtMetrics(ACanvas.Handle, tm);
    if (tm.tmPitchAndFamily and TMPF_TRUETYPE) <> 0 then // TrueType
    begin
      // A�������߂�
      GetCharABCWidths(ACanvas.Handle, FirstChar, FirstChar, ABC);
      // ���Ȃ炻�̑傫����Ԃ�
      if ABC.abcA < 0 then
        Result := -ABC.abcA
      else
        Result := 0;
    end
    else
      Result := 0; // ��TrueType�Ȃ� A=0;
  end;
end;

// Canvas.TextWidth ���e�L�X�g���݂͂����ꍇ�A�͂ݏo���傫����Ԃ��B
function GetTextCAdjust(ACanvas: TCanvas; s: string): Integer;
var
  LastChar: DWORD; // �Ō�̕����̕����R�[�h
  ABC: TABC;       // ABC�����󂯎�郌�R�[�h
  ABCF: TABCFloat;
  tm: TTextMetric; // �e�L�X�g���g���b�N

  // �Ō�̕����R�[�h���擾����
  function GetLastChar(s: string): DWORD;
  var
    PrevChar: PChar;
    Len: Integer;
  begin
    Len := Length(s);

    if len = 0 then    // �����񒷂��O�Ȃ�O��Ԃ�
    begin
      Result := 0;
      Exit;
    end;

    // �Ō�̕����̃R�[�h���擾����
    PrevChar := CharPrev(PChar(s), PChar(@s[Len])+1);
    if (PChar(@s[Len])+1 - PrevChar) = 2 then
      Result := Ord(s[Len-1]) * 256 + Ord(s[Len])
    else if (PChar(@s[Len])+1 - PrevChar) = 1 then
      Result := Ord(s[Len])
    else
      Result := 0;
  end;
begin
  // �Ō�̕����̃R�[�h���擾����
  LastChar := GetLastChar(s);
  if LastChar = 0 then  // ������=0
  begin
    Result := 0;
    Exit;
  end;

  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    begin
      // C�����擾����
      GetCharABCWidthsFloat(ACanvas.Handle, LastChar, LastChar, ABCF);
      // C�������Ȃ炻�̑傫����Ԃ�
      if ABCF.abcfC < 0 then
        Result := -Round(ABCF.abcfC)
      else
        Result := 0
    end;
  end
  else
  begin
    // TrueType ���`�F�b�N
    GetTExtMetrics(ACanvas.Handle, tm);
    if (tm.tmPitchAndFamily and TMPF_TRUETYPE) <> 0 then // TrueType
    begin
      // C �����擾����
      GetCharABCWidths(ACanvas.Handle, LastChar, LastChar, ABC);
      // C�������Ȃ炻�̑傫����Ԃ�
      if ABC.abcC < 0 then
        Result := -ABC.abcC
      else
        Result := 0;
    end
    else
      Result := 0;  // TrueType�Ŗ����ꍇ�ATextWidth��C�����܂�ł���
  end;
end;

function GetTextPosition(
  ws: WideString;                // ������
  FontHeight: Double;           // �t�H���g�̍���(Twips)
  FontHandle: THandle;          // �t�H���g�n���h��
  MaxExtent: Double;            // �ő�\����(Twips)
  PixelsPerInch: Integer;       // �\���p�f�o�C�X�̘_���C���`
  Options: TFormatOptions;      // �I�v�V����
  var Offset: Integer;          // �\���I�t�Z�b�g(�s�N�Z��)
  var FittedChars: Integer;     // �ő�\�����ɕ\���ł��镶����
  var DXs: TDXArray             // �e�����̕������̔z��(�s�N�Z��)
  ): WideString;                // �߂�l�͕\���ł��Ȃ������c��̕�����
var
  ACanvas: TCanvas;                 // Canvas;
  cp: Integer;                      // �������̕����̈ʒu
  CharWidth: Integer;               // �������̕����̕�
  CharIndex: Integer;               // �������̕����̃C���f�b�N�X(1�I���W��)
  BreakChars: array of Boolean;     // �u���[�N�\�����������z��
  NumBreakChars: Integer;           // �u���[�N�\�����̑���
  CellDistances: array of Double;   // �Z���̑傫��
  tm: TTextMetric;                  // �e�L�X�g���g���b�N
  SumOfDXs: Integer;                // �Z���ԃX�y�[�X�̘a(���̑傫�����x�[�X)
  SumOfCellDistances: Double;       // �Z���ԃX�y�[�X�̘a(����=4096 ���x�[�X)
  CellAdjust: Double;               // �u���[�N�����̃Z�����̒����l
  LastBreakCharIndex: Integer;      // �������̕������O�̍Ō�̃u���[����
  ProcessedChars: Integer;          // GetTExtPosition ��1�s���̏�������
                                    // ������
  FindNotSpace: Boolean;            // ���ɃX�y�[�X�������������Ƃ�����
  i, j: Integer;
  Kernings: array of array of Integer;  // Kerning ���
  KerningPairs: array of TKerningPair;  // Kerning Pair
  nPairs: Integer;                      // Kerning Pair �̐�
  Kerning: Integer;                     // �J�[�j���O��
  LogFont: TLogFont;                    // �_���t�H���g

  // �������X�y�[�X���ǂ�����Ԃ�
  function IsSPace(w: WideChar): Boolean;
  begin Result := (Ord(w) = $0020) or (Ord(w) = $3000); end;

  // �������u���[�N�������ǂ�����Ԃ�
  function IsBreakable(w: WideChar): Boolean;
  begin
    Result :=  IsSpace(w) or (Ord(w) >= 256);
  end;
begin
  Offset := 0;
  ACanvas := TCanvas.Create;
  try
    ACanvas.Handle := GetDC(0);
    // �t�H���g�̍����� 4096 �ɕύX
    GetObject(FontHandle, SizeOf(TLogFont), @LogFont);
    LogFont.lfHeight := -4096;
    LogFont.lfWidth := 0;
    ACanvas.Font.Handle := CreateFontIndirect(LogFont);

    // �o�b�t�@�m��
    SetLength(DXs, Length(ws));
    SetLength(BreakChars, Length(ws));
    SetLength(CellDistances, Length(ws));

    // Kerning ���s���Ȃ� Kerning ���𓾂�
    if foKerning in Options then begin
      SetLength(Kernings, 128, 128);
      for i := 0 to 127 do for j := 0 to 127 do
        Kernings[i, j] := 0;
      nPairs := GetKerningPairs(ACanvas.Handle, 0, Nil^);
      if nPairs > 0 then begin
        SetLength(KerningPairs, nPairs);
        GetKerningPairs(ACanvas.Handle, nPairs, KerningPairs[0]);
      end;

      // Kerning �͉p�����Ɍ���
      for i := 0 to nPairs-1 do
        if (32 < KerningPairs[i].wFirst) and
           (KerningPairs[i].wFirst < 128) and
           (32 < KerningPairs[i].wSecond) and
           (KerningPairs[i].wSecond < 128) then
          Kernings[KerningPairs[i].wFirst, KerningPairs[i].wSecond] :=
            KerningPairs[i].iKernAmount;
    end;

    // ���݈ʒu�A�����C���f�b�N�X��������
    cp := 0;
    CharIndex := 1;
    LastBreakCharIndex := 0; // �Ō�̃u���[�N�����C���f�b�N�X������
    FindNotSpace := False;   // �X�y�[�X�͂܂��������Ă��Ȃ�

    GetTextMetrics(ACanvas.Handle, tm); // ������Overhang �����߂Ă���

    while CharIndex <= Length(ws) do
    begin
      // �����̕������߂�
      GetCharWidthW(ACanvas.Handle,
                    Ord(ws[CharIndex]), Ord(ws[CharIndex]), CharWidth);
      CharWidth := CharWidth - tm.tmOverHang;

      if (foKerning in Options) and (CharIndex > 1) and
         (Ord(ws[CharIndex-1]) < 128) and (Ord(ws[CharIndex]) < 128) then
        Kerning := Kernings[Ord(ws[CharIndex-1]), Ord(ws[CharIndex])]
      else
        Kerning := 0;

      if (cp + CharWidth + Kerning) >
         (MaxExtent * 4096 / abs(FontHeight)) then
      // �������̐ώZ��MaxExtent ���z�����ꍇ
      begin
        if not IsSpace(ws[CharIndex]) then // �X�y�[�X�Ȃ牽�����Ȃ�
        begin
          // �u���[�N�����������Ȃ�CharIndex�܂ł̕������̗p
          if LastBreakCharIndex = 0 then
          begin
            ProcessedChars := CharIndex-1;
            Break;
          end
          else
          begin
            // �u���[�N����������Ȃ�u���[�N�����܂ō̗p
            CharIndex := LastBreakCharIndex;
            ProcessedChars := CharIndex;
            // �u���[�N�������X�y�[�X�Ȃ�X�y�[�X�Ŗ��������܂ō��
            while BreakChars[CharIndex-1] and IsSpace(ws[CharIndex]) do
              Dec(CharIndex);
            Inc(CharIndex);
            Break;
          end;
        end;
      end;
      cp := cp + Kerning + CharWidth;  // ���̕����ʒu�����߂�
      CellDistances[CharIndex-1] := CharWidth; // �����������߂�
      if CharIndex > 1 then
        CellDistances[CharIndex-2] := CellDistances[CharIndex-2] + Kerning;

      // �s���̃X�y�[�X�̓u���[�N�����Ƃ��Ȃ�
      if IsBreakable(ws[CharIndex]) and (CharIndex > 1) and FindNotSpace then
      begin
        BreakChars[CharIndex-1] := True;
        LastBreakCharIndex := CharIndex;
      end
      else
        BreakChars[CharIndex-1] := False;

      // �X�y�[�X�����ȊO����������L�^
      if not IsSpace(ws[CharIndex]) then FindNotSpace := True;

      Inc(CharIndex); //���̕���
    end;

    // �S���������������ꍇ
    if CharIndex > Length(ws) then ProcessedChars := CharIndex-1;

    SetLength(DXs, CharIndex-1);
    FittedChars := CharIndex-1;

    // FittedChars = 0 �͍Œ�1�����K�v
    if (FittedChars = 0) and (Length(ws) > 0) then
    begin
      FittedChars := 1;
      SetLength(DXs, 1);
      DXs[0] := 0;
    end;

    // ����������͍Œ�1�����K�v
    if (ProcessedChars = 0) and (Length(ws) > 0) then
      ProcessedChars := 1;

    // �������� FittedChars ����������ΐ��񏈗����s��
    if ((FittedChars < Length(ws)) and (FittedChars > 0) and
        (foJustify in Options)) or
       ((foEven in Options) and (FittedChars > 0)) then
    begin
      // �u���[�N�������𓾂�
      if not (foEven in Options) then
      begin
        NumBreakChars := 0;
        for i := 0 to FittedChars-1 do
          if BreakChars[i] then Inc(NumBreakChars);
      end
      else
      begin
        NumBreakChars := FittedChars-1;
        for i := 1 to FittedChars-1 do
          BreakChars[i] := True;
      end;

      // �u���[�N�����̑O�̕����ɕ������̒����l������U��
      if NumBreakChars >= 1 then
      begin
        SumOfCellDistances := 0;
        for i := 0 to FittedChars-1 do
          SumOfCellDistances := SumOfCellDistances + CellDistances[i];
        CellAdjust := (MaxExtent * 4096 / abs(FontHeight)
                       - SumOfCellDistances) / NumBreakChars;
        for i := 1 to FittedChars-1 do
          if BreakChars[i] then
            CellDistances[i-1] := CellDistances[i-1] + CellAdjust;
      end
    end;

    if (FittedChars > 0) and
       ((foRight in Options) or (foCenter in Options)) then
    begin
      SumOfCellDistances := 0;
      for i := 0 to FittedChars-1 do
        SumOfCellDistances := SumOfCellDistances + CellDistances[i];
      Offset := Round((MaxExtent * 4096 / abs(FontHeight)
                       - SumOfCellDistances) * abs(FontHeight) / 4096
                       * PixelsPerInch / 1440);
      if foCenter in Options then Offset := Offset div 2;
    end;

    // �����������̕����̑傫���̂��̂ɕϊ�����
    // �덷���~�ς��Ȃ��悤�ɒ���
    SumOfDXs := 0;
    SumOfCellDistances := 0;
    for i := 0 to FittedChars-1 do
    begin
      SumOfCellDistances := SumOfCellDistances + CellDistances[i];
      DXs[i] := Round(SumOfCellDistances *
                      abs(FontHeight) / 4096 *
                      PixelsPerInch / 1440 - SumOfDXs);
      Inc(SumOfDXs, DXs[i]);
    end;
    // �����ς̕�������͂��ꂽ�������珜�����Ԃ��B
    Delete(ws, 1, ProcessedChars);
    Result := ws;
  finally
    ReleaseDC(0, ACanvas.Handle);
    ACanvas.Free;
  end;
end;

end.
