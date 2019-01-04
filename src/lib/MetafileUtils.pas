{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
unit MetafileUtils;

interface

{$IFDEF ORIGINAL} // 2002.5.22(Ver. 1.1)
uses Graphics;
{$ELSE}
uses Windows, Graphics;
{$ENDIF}

// Canvas �̃t�H���g�̉������w�肳��Ă��Ȃ��ꍇ
// �K�؂ȉ�����ݒ肷��B
procedure AdjustFont(Canvas: TCanvas);

// ���^�t�@�C���̕����C���`���w�肳�ꂽ�l��
// �ύX����B
// DPIX �͉������̐V�����C���`
// DPIY �͏c�����̐V�����C���`
// DPIX, DPIY ���ȗ�����ƁADPIX/DPIY �ɂ�
// �X�N���[���̘_���C���`���̗p�����
procedure AdjustPhysicalInch(Metafile: TMetafile;
                             DPIX: Integer = 0;
                             DPIY: Integer = 0);

{$IFNDEF ORIGINAL} // �ǉ� 2002.5.22(Ver. 1.1)
// ���^�t�@�C���� Windows 9X/ME �ł����̃��^�t�@�C���ɏ������߂�悤��
// �ϊ�����
//   Windows 9X/ME �ł̓o�O�̂��߂Q�����ȏ�̕������`�悷��
//   ExtTextOutA, ExtTextOutW ���R�[�h���܂ރ��^�t�@�C����
//   ���̃��^�t�@�C���ɐ���ɕ`��ł��Ȃ����Ƃ�����܂��B
//   ���̃��[�`�����g���΁A���̃��^�t�@�C���ɐ���ɕ`��ł���
//   ���^�t�@�C�����쐬�ł��܂��B
//   ���̃��[�`���� NT�n��Windows �ł͌��̃��^�t�@�C����
//   �S���������^�t�@�C�������܂��B
function FixMetafileFor9X(AMetafile: TMetafile; RefDC: HDC): TMetafile;

// Windows 9X/ME �ł����^�t�@�C���ւ̕`��Ɏg���� ExtTextOut
//   Windows 9X/ME �ł̓o�O�̂��� �Q�����ȏ�̕������`�悷��
//   ExtTextOut �̓��^�t�@�C���ɐ���ɏ������܂�Ȃ����Ƃ�����܂��B
//   ���̃��[�`�����g���ΐ���ɏ������߂܂��B
//   ���̃��[�`���� NT�n��Windows �ł̓p�����[�^�����̂܂�
//   ExtTextOut API �ɓn���܂��B
function DHGLExtTextOut(DC: HDC; x, y: Integer; Option: DWORD;
                        pR: PRect; pString: PChar; cbCount: Integer;
                        lpDX: PInteger): Boolean;

// Windows 9X/ME �ł��g���� ExtTextOutW
//   Windows 9X/ME �ł̓o�O�̂��� ExtTextOutW �����^�t�@�C����
//   �������ނƃA�v���P�[�V�����������Ă��܂����Ƃ�����܂��B
//   ���̃��[�`�����g���ΐ���ɏ������߂܂��B
//   ���̃��[�`���� NT�n��Windows �ł̓p�����[�^�����̂܂�
//   ExtTextOutW API �ɓn���܂��B
function DHGLExtTextOutW(DC: HDC; x, y: Integer; Option: DWORD;
                        pR: PRect; pString: PWChar; cbCount: Integer;
                        lpDX: PInteger): Boolean;
{$ENDIF}

implementation

{$IFDEF ORIGINAL} // 2002.5.22(Ver. 1.1)
uses Windows, SysUtils, Classes;
{$ELSE}
uses SysUtils, Classes;
{$ENDIF}

type
  // Win2K �̃��^�t�@�C�����w�b�_���R�[�h��`
  PEnhMetaHeaderV5 = ^TEnhMetaHeaderV5;
  TENHMETAHEADERV5 = packed record
    Header: TEnhMetaHeader;
    szlMicroMeters: TSize;
  end;

// Canvas �̃t�H���g�̉������w�肳��Ă��Ȃ��ꍇ
// �K�؂ȉ�����ݒ肷��B
procedure AdjustFont(Canvas: TCanvas);
var
  tm: TTextMetric;
  lf: TLogFOnt;
begin
  GetObject(Canvas.Font.Handle, SizeOf(lf), @lf);
  if lf.lfWidth = 0 then
  begin
    GetTextMetrics(Canvas.Handle, tm);
    lf.lfWidth := -lf.lfHeight * tm.tmAveCharWidth div tm.tmHeight;
    Canvas.Font.Handle := CreateFontIndirect(lf);
  end;
end;

// AdjustPhysicalInch ���� EnhMetaFileProc �֓n��
// �p�����[�^�u���b�N�̐錾
type
  TParaBlock = record
    MS: TMemoryStream;
    DPIX: Integer;
    DPIY: Integer;
  end;
  PParaBlock = ^TParaBlock;

// ���^�t�@�C���̕ύX����
// ���^�t�@�C���̃w�b�_���R�[�h�̕����C���`��
// DPIX, DPIY �Ŏw�肳�ꂽ�l�ɂ���B
// szlDevice �͕ς���, rclFrame, szlMillimeters
// ���C������BW2k �̏ꍇ�� szlMicroMeters ���C������
function EnhMetaFileProc(
  h: HDC; lpHTable: Pointer; lpEMFR: PEnhMetaHeader;
  nObj: Integer; lpdata: LPARAM): Integer; stdcall;
var
  // �X�V��̃��^�t�@�C�����󂯎�郁�����X�g���[��
  MS: TMemoryStream;
  // �w�b�_���R�[�h�̎󂯎��o�b�t�@
  Buf: array of Byte;
  // �w�b�_���R�[�h�p�A�N�Z�X�p�|�C���^
  pHead: PENHMETAHEADER;
  // �s�N�Z���P�ʂ̋��E�g
  PixelWidth, PixelHeight: Int64;
  // �w�肳�ꂽ�����C���`
  DPIX, DPIY: Integer;
begin
  // �p�����[�^�u���b�N���󂯎��
  MS := PParaBlock(lpdata).MS;
  DPIX := PParaBlock(lpData).DPIX;
  DPIY := PParaBlock(lpdata).DPIY;

  case lpEMFR.iType of
    EMR_HEADER: // �w�b�_���R�[�h
      begin
        // �w�b�_���R�[�h���R�s�[����
        SetLength(Buf, lpEMFR.nSize);
        System.Move(lpEMFR^, Buf[0], lpEMFR.nSize);
        pHead := PENHMETAHEADER(Buf);

        // ���E��`�̃s�N�Z���P�ʂ̕��ƍ����𓾂�
        PixelWidth  := Int64(pHead.rclFrame.Right - pHead.rclFrame.Left) *
                       pHead.szlDevice.cx  div
                       pHead.szlMillimeters.cx div 100;
        PixelHeight := Int64(pHead.rclFrame.Bottom - pHead.rclFrame.Top) *
                       pHead.szlDevice.cy  div
                       pHead.szlMillimeters.cy div 100;

        // ���E��`�̕��ƍ���(�s�N�Z��)��DPIX, DPIY ���g����
        // ���E��`(0.01mm�P��)���Đݒ肷��
        pHead.rclFrame.Right := pHead.rclFrame.Left +
                                Round(PixelWidth * 2540 / DPIX);
        pHead.rclFrame.Bottom := pHead.rclFrame.Top +
                                 Round(PixelHeight * 2540 / DPIY);

        // �f�o�C�X�̑傫��(�s�N�Z��)�� DPIX, DPIY ���g����
        // �f�o�C�X�̑傫��(mm�P��)���Đݒ肷��
        pHead.szlMillimeters.cx := round(pHead.szlDevice.cx * 25.40 /DPIX);
        pHead.szlMillimeters.cy := round(pHead.szlDevice.cy * 25.40 /DPIY);

        // Win2K �̃w�b�_���H
        if LongInt(@PEnhMetaHeaderV5(pHead).szlMicroMeters)
           - LongInt(pHead) < pHead.nSize then
        begin
          // W2K �̒ǉ��t�B�[���h(szlMillimeters �� �ʃ��[�^��)��
          // �Đݒ肷��
          PEnhMetaHeaderV5(pHead).szlMicroMeters.cx :=
            round(Int64(pHead.szlDevice.cx) * 25400 / DPIX);
          PEnhMetaHeaderV5(pHead).szlMicroMeters.cy :=
            round(Int64(pHead.szlDevice.cy) * 25400 /DPIY);
        end;

        // �X�V���ꂽ�w�b�_���R�[�h���X�g���[���ɏ�������
        MS.WriteBuffer(pHead^, pHead.nSize);
      end;
    else
      // �w�b�_���R�[�h�ȊO�̓X�g���[���ɒP���R�s�[����
      MS.WriteBuffer(lpEMFR^, lpEMFR.nSize);
  end;
  Result := 1;
end;

procedure AdjustPhysicalInch(Metafile: TMetafile;
                             DPIX: Integer = 0;
                             DPIY: Integer = 0);
var
  // �X�V���ꂽ���^�t�@�C�����󂯎�郁�����X�g���[��
  MS: TMemoryStream;
  R: TRect; // �_�~�[
  // EnhMetaFileProc�@�ɓn���p�����[�^�u���b�N
  ParaBlock: TParaBlock;
  // �X�N���[���� DC
  DC: HDC;
begin
  // DPIX, DPIY ���w�肳��Ă��Ȃ���΃X�N���[����
  // �_���C���`���̗p����
  DC := GetDC(0);
  try
    if DPIX = 0 then DPIX := GetDeviceCaps(DC, LOGPIXELSX);
    if DPIY = 0 then DPIY := GetDeviceCaps(DC, LOGPIXELSY);
  finally
    ReleaseDC(0, DC);
  end;

  // Enhanced Metafile ���󂯎�郁�����X�g���[�������
  MS := TMemoryStream.Create;
  try
    ParaBlock.MS := MS;
    ParaBlock.DPIX := DPIX;
    ParaBlock.DPIY := DPIY;

    // �ύX����
    EnumEnhMetafile(0, Metafile.Handle, @EnhMetafileProc, @ParaBlock, R);

    // �ύX������̃��^�t�@�C���̃������C���[�W���� Enhanced Metafile
    // �����
    MS.Position := 0;
    Metafile.LoadFromStream(MS);
  finally
    MS.Free;
  end;
end;

{$IFNDEF ORIGINAL} // �ǉ� 2002.5.22(Ver. 1.1)
type
  // EXTTextOut ��1�������̃f�[�^��ێ����郌�R�[�h
  TETOChar = record
    FString: string;     // MBCS 1�������̕�����
    FPosition: Integer;  // ������̐擪����̋���
    FWidth: Integer;     // ������(�Z����)
  end;

  // ///////////////////////////////////////////
  // ExtTextOut �R���o�[�g�p�N���X
  //   ���̃N���X�̖���:
  //     Windows 9X/ME �ɂ̓��^�t�@�C���̕����̈����ɖ�肪����
  //     �܂� ExtTextOutW �� TextOutW API �Ń��^�t�@�C���ɕ�����
  //     �`���ƃA�v���P�[�V�����������Ă��܂��B����ɁA
  //     �����������܂� ExtTextOut API �ŕ���������^�t�@�C����
  //     �`���ƁA�s���ȕ����ԃX�y�[�V���O���L�^����Ă��܂��B
  //     DrawText �� TextOut API �ŕ`���ꍇ�� ExtTextOutA ���R�[�h
  //     ���L�^�����ɂ�������炸�A���͋N���Ȃ��B
  //     �ȏォ��ȉ��̖�肪�N����B
  //     1) ���^�t�@�C���ւ̕`��� ExtTextOutW �� TextOutW ���g���Ȃ��B
  //     2) DrawText �� TextOut �Ń��^�t�@�C���ɕ�������������ނ�
  //        ����ȃ��^�t�@�C�����ł��邪�A���̃��^�t�@�C���������
  //        ���̃��^�t�@�C���ɕ`���ƂƁAExtTextOutA ���R�[�h��
  //        ExtTextOut API �� �`�����̂ŁA�����ԃX�y�[�V���O��
  //        �����Ă��܂��B�܂� Windows 9X/ME �ł͕�������܂�
  //        ���^�t�@�C���𑼂̃��^�t�@�C���ɕ`��ł��Ȃ��B
  //  ���̃N���X�̑Ώ��@�F
  //    �Ώ��̊�{���j�͊ȒP�ŁA�����̕������܂� ExtTextOut ��
  //    ExtTextOutW �̕`����ꕶ���� ExtTextOutA �̗�ɕ�������B
  //    �A���AExtTextOut/ExtTextOutW �𕡐��� ExtTextOutA �ɕ���
  //    ����̂́A ETO_OPAQUE �t���O��w�i���[�h�A�����̕\����
  //    �t�H���g�̉�]���l������ƁA�e�Ղł͂Ȃ��B
  //    ������ TExtTextOut �͂��������Ă̂���B���̂��ߒ����
  //    �R�[�h�ɂȂ��Ă���B
  //
  //
  //  �R���X�g���N�^
  //      Create:  ExtTextOut �̃p�����[�^�� TExtTextOut ������������B
  //      CreateW: ExtTextOutW �̃p�����[�^�� TExtTextOut ������������B
  //      Create(pRec: PEMREXTTEXTOUT):
  //               ���^�t�@�C���� EMR_EXTTEXTOUTA, EMT_EXTTEXTOUTW,
  //               EMR_POLYTEXTOUTA, EMR_POLYTEXTOUTW �̓��e�ŁA
  //               TExtTextOut ������������B
  // ���\�b�h
  //      DrawToCanvas:
  //        TExtTextOut �̓��e���A�ꕶ���� ExtTextOut �������g����
  //        �L�����o�X�ɕ`��
  //      DrawToDC:
  //        TExtTextOut �̓��e���A�ꕶ���� ExtTextOut �������g����
  //        DC�ɕ`��
  //      PlayExtTextOut:
  //        TExtTextOut �̓��e���A�ꕶ���� ExtTextOutA���R�[�h ������
  //        �g���āA���^�t�@�C���� Canvas �ɕ`��
  //        EnumEnhMetafile �̃R�[���o�b�N���[�`���̒��Ŏg���B
  //
  TExtTextOutConverter = class
  private
    // �C���X�^���X���@���^�t�@�C�����R�[�h������ꂽ���Ƃ������t���O
    FCreatedFromMetafileRecord: Boolean;
    FRclBounds: TRect;       // �}�`���͂ދ�`(���^�t�@�C�����R�[�h����擾)
    FIGraphicsMode: DWORD;   // �O���t�B�b�N���[�h(���^�t�@�C�����R�[�h����擾)
    FExScale: Single;        // �X�P�[���t�@�N�^(���^�t�@�C�����R�[�h����擾)
    FEySCale: Single;
    FReference: TPoint;      // �Q�Ɠ_
    FOption: DWORD;          // �I�v�V����
    FRect: TRect;            // �G���A�T�C�Y
    FText: array of TETOChar;// ������

    // ExtTextOutA ���R�[�h�̍쐻
    function CreateExtTextOutARecord(x, y: Integer;
                                     Option: DWORD;
                                     Text: string;
                                     R: TRect;
                                     pi: PInteger): PEMREXTTEXTOUT;
    // SaveDC ���R�[�h�̍쐻
    function CreateSaveDCRecord: PEMRSAVEDC;
    // RestoreDC ���R�[�h�̍쐻
    function CreateRestoreDCRecord: PEMRRESTOREDC;
    // SetBkMode ���R�[�h�̍쐻
    function CreateSetBkModeRecord(Mode: Integer): PEMRSetBkMode;
  public
    constructor Create; overload;  //  �g�p�֎~
    // ���^�t�@�C�����R�[�h���g���ăR���X�g���N�g
    constructor Create (x, y: Integer;
                        Option: DWORD;
                        pR: PRect;
                        Text: string;
                        pi: PInteger); overload;
    // ExtTextOutA �̃p�����[�^����R���X�g���N�g
    constructor CreateW(x, y: Integer;
                        Option: DWORD;
                        pR: PRect;
                        Text: Widestring;
                        pi: PInteger); overload;
    // ExtTextOutW �̃p�����[�^����R���X�g���N�g
    constructor Create(pRec: PEMREXTTEXTOUT); overload;

    // �������`��(���^�t�@�C���L�����o�X�p)
    procedure DrawToCanvas(Canvas: TCanvas);
    procedure DrawToDC(DC: HDC);
    // �������`��(���^�t�@�C�����R�[�h�����p)
    procedure PlayExtTextOut(DC: HDC; lpHTable: Pointer; nObj: DWORD);
  end;


// ���^�t�@�C���Ɉ��S�ɕ`���� ExtTextOut
function DHGLExtTextOut(DC: HDC; x, y: Integer; Option: DWORD;
                        pR: PRect; pString: PChar; cbCount: Integer;
                        lpDX: PInteger): Boolean;
var
  etoc: TExtTextOutConverter;
  Text: string;
begin
  Result := True;
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result := ExtTextOut(DC, x, y, Option, pR, pString, cbCount, lpDx)
  else
  begin
    try
      SetLength(Text, cbCount);
      System.Move(pString^, Text[1], cbCount);
      etoc := TExtTextOutConverter.Create(x, y, Option, pR,
                                         Text, lpDx);
      try
        etoc.DrawToDC(DC);
      finally
        etoc.Free;
      end;
    except
      Result := False;
    end;
  end;
end;

// ���^�t�@�C���Ɉ��S�ɕ`���� ExtTextOutW
function DHGLExtTextOutW(DC: HDC; x, y: Integer; Option: DWORD;
                        pR: PRect; pString: PWChar; cbCount: Integer;
                        lpDX: PInteger): Boolean;
var
  etoc: TExtTextOutConverter;
  TextW: WideString;
begin
  Result := True;
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    Result := ExtTextOutW(DC, x, y, Option, pR, pString, cbCount, lpDx)
  else
  begin
    try
      SetLength(TextW, cbCount);
      System.Move(pString^, TextW[1], cbCount*2);
      etoc := TExtTextOutConverter.CreateW(x, y, Option, pR,
                                          TextW, lpDx);
      try
        etoc.DrawToDC(DC);
      finally
        etoc.Free;
      end;
    except
      Result := False;
    end;
  end;
end;

{ TExtTextOut }

// ExtTextOut �̃p�����[�^����C���X�^���X�����
constructor TExtTextOutConverter.Create(x, y: Integer;
                                        Option: DWORD;
                                        pR: PRect;
                                        Text: string;
                                        pi: PInteger);
var
  i: Integer;
  TextLength: Integer;    // �e�L�X�g��(Byte)
  CharCount: Integer;     // ������
  CType: TMbcsByteType;   // �����̎��
  Distance: Integer;      // ������̐擪�ʒu����̋���
begin
  FReference := Point(x, y);
  FOption := Option;
  if pR = Nil then FRect := Rect(0, 0, 0, 0)
              else FRect := pR^;

  // �f�[�^�i�[�ꏊ�̊m��
  TextLength := Length(Text);
  SetLength(FText, TextLength);

  CharCount := 0;
  Distance := 0;

  i := 1;
  while i <=  TextLength do
  begin
    CType := ByteType(Text, i);
    if CType = mbSingleByte then
    begin // Syngle Byte ����
      FText[CharCount].FString := Text[i];
      FText[CharCount].FPosition := Distance;
      FText[CharCount].FWidth := pi^;
      Inc(Distance, pi^);
      Inc(pi);
      Inc(i);
      Inc(CharCount);
    end
    else if CType = mbLeadByte then
    begin
      if i >= TextLength then
      begin // Double Byte ���� �����ǁ@�����񒷂�����Ȃ�
        FText[CharCount].FString := '?';
        FText[CharCount].FPosition := Distance;
        FText[CharCount].FWidth := pi^;
        Inc(Distance, pi^);
        Inc(pi);
        Inc(i);
        Inc(CharCount);
      end
      else
      begin // Double Byte ����
        FText[CharCount].FString := Text[i] + Text[i+1];
        FText[CharCount].FPosition := Distance;
        FText[CharCount].FWidth := pi^;
        Inc(Distance, pi^);
        Inc(pi);
        FText[CharCount].FWidth := FText[CharCount].FWidth + pi^;
        Inc(Distance, pi^);
        Inc(pi);
        Inc(i, 2);
        Inc(CharCount);
      end;
    end
    else
    begin // ���肦�Ȃ����@�ꉞ����
      FText[CharCount].FString := '?';
      FText[CharCount].FPosition := Distance;
      FText[CharCount].FWidth := pi^;
      Inc(Distance, pi^);
      Inc(pi);
      Inc(i);
      Inc(CharCount);
    end;
  end;
  SetLength(FText, CharCount); // �����񒷂𒲐�
end;

// ExtTextOut ���R�[�h���琶��
constructor TExtTextOutConverter.Create(pRec: PEMREXTTEXTOUT);
var
  pString: PCHAR;
  Text: String;
  TextW: WideString;
begin
  FCreatedFromMetafileRecord := True;

  // ���R�[�h����K�v���ڂ�k�s�[
  FRclBounds := pRec.rclBounds;
  FIGraphicsMode := pRec.iGraphicsMode;
  FExScale := pRec.exScale;
  FEyScale := pRec.eyScale;

  // �����f�[�^�̋z���グ
  pString := PChar(pRec) + pRec.emrtext.offString;

  case pRec.emr.iType of
  EMR_EXTTEXTOUTA, EMR_POLYTEXTOUTA:
    begin
      SetLength(Text, pRec.emrtext.nChars);
      System.Move(pString^, Text[1], pRec.emrtext.nChars);
      // ExtTextOut �p�����[�^�p�̃R���X�g���N�^���Ă�
      Create(pRec.emrtext.ptlReference.x, pRec.emrtext.ptlReference.y,
             pRec.emrtext.fOptions,
             @pRec.emrtext.rcl,
             Text,
             PInteger(PChar(pRec) + pRec.emrtext.offDx));
    end;
  EMR_EXTTEXTOUTW, EMR_POLYTEXTOUTW:
    begin
      SetLength(TextW, pRec.emrtext.nChars);
      System.Move(pString^, TextW[1], pRec.emrtext.nChars * 2);
      // ExtTextOut �p�����[�^�p�̃R���X�g���N�^���Ă�
      CreateW(pRec.emrtext.ptlReference.x, pRec.emrtext.ptlReference.y,
             pRec.emrtext.fOptions,
             @pRec.emrtext.rcl,
             TextW,
             PInteger(PChar(pRec) + pRec.emrtext.offDx));
    end;
  else
    Assert(False);
  end;
end;

constructor TExtTextOutConverter.Create;
begin
  // �g���Ă͂����Ȃ��B
  raise Exception.Create('TExtTextOut: Construct Error');
end;

// ExtTextOutA ���R�[�h�����
function TExtTextOutConverter.CreateExtTextOutARecord(
  x, y: Integer; Option: DWORD; Text: string; R: TRect;
  pi: PInteger): PEMREXTTEXTOUT;
var
  RecordSize: Integer;
  p: PChar;
begin
  // ���R�[�h���q�[�v����m��
  RecordSize := SizeOf(EMREXTTEXTOUTA) + Length(Text) +
                 Length(Text) * SizeOf(Integer);
  GetMem(Result, RecordSize);
  try
    Result.emr.iType := EMR_EXTTEXTOUTA;
    Result.emr.nSize := RecordSize;
    Result.rclBounds := FRclBounds;
    Result.iGraphicsMode := FIGraphicsMode;
    Result.exScale := FExScale;
    Result.eyScale := FEyScale;
    Result.emrtext.ptlReference := Point(x, y);
    Result.emrtext.nChars := Length(Text);
    Result.emrtext.fOptions := Option;
    Result.emrtext.rcl := R;
    Result.emrtext.offString := SizeOf(EMREXTTEXTOUTA);
    p := PChar(Result) + SizeOf(EMREXTTEXTOUTA);
    System.Move(Text[1], p^, Length(Text));
    Result.emrtext.offDx := SizeOf(EMREXTTEXTOUTA) + Length(Text);
    p := PChar(Result) + SizeOf(EMREXTTEXTOUTA) + Length(Text);
    System.Move(pi^, p^, Length(Text) * SizeOf(Integer));
  except
    FreeMem(Result);
    raise;
  end;
end;

// RestoreDC ���R�[�h�����
function TExtTextOutConverter.CreateRestoreDCRecord: PEMRRESTOREDC;
begin
  // ���R�[�h���q�[�v����m��
  GetMem(Result, SizeOf(EMRRestoreDC));
  try
    Result.emr.iType := EMR_RESTOREDC;
    Result.emr.nSize := SizeOf(EMRRestoreDC);
    Result.iRelative := -1; // ���O�� SaveDC �̏�Ԃɖ߂�
  except
    FreeMem(Result);
    raise;
  end;
end;

// SaveDC ���R�[�h�����
function TExtTextOutConverter.CreateSaveDCRecord: PEMRSAVEDC;
begin
  // ���R�[�h���q�[�v����m��
  GetMem(Result, SizeOf(TEMRSaveDC));
  try
    Result.emr.iType := EMR_SAVEDC;
    Result.emr.nSize := SizeOf(TEMRSaveDC);
  except
    FreeMem(Result);
    raise;
  end;
end;

// SetBkMode ���R�[�h�����
function TExtTextOutConverter.CreateSetBkModeRecord(Mode: Integer)
  : PEMRSetBkMode;
begin
  // ���R�[�h���q�[�v����m��
  GetMem(Result, SizeOf(TEMRSetBkMode));
  try
    Result.emr.iType := EMR_SETBKMODE;
    Result.emr.nSize := SizeOf(TEMRSETBKMODE);
    Result.iMode := Mode;
  except
    FreeMem(Result);
    raise;
  end;
end;

// ExtTextOutW �̃p�����[�^�ŃC���X�^���X�����
constructor TExtTextOutConverter.CreateW(x, y: Integer;
                                         Option: DWORD;
                                         pR: PRect;
                                         Text: Widestring;
                                         pi: PInteger);
var
  TextLength: Integer; // �e�L�X�g��(Unicode�P��)
  i: Integer;
  Distance: Integer;   // �e�L�X�g�̐擪����̋���
begin
  FReference := Point(x, y);
  FOption := Option;

  if pR = Nil then FRect := Rect(0, 0, 0, 0)
              else FRect := pR^;

  // ������i�[�G���A�̊m��
  TextLength := Length(Text);
  SetLength(FText, TextLength);

  Distance := 0;
  for i := 1 to  TextLength do
  begin
    FText[i-1].FString := Text[i];
    FText[i-1].FPosition := Distance;
    FText[i-1].FWidth := pi^;
    Inc(Distance, pi^);
    Inc(pi);
  end;
end;

// �L�����o�X�ɕ`��
procedure TExtTextOutConverter.DrawToCanvas(Canvas: TCanvas);
begin
  DrawToDC(Canvas.Handle);
end;

// DC �ɕ`��
procedure TExtTextOutConverter.DrawToDC(DC: HDC);
var
  TextLength: Integer;
  i: Integer;
  DXs: array[0..1] of Integer;
  lf: TLogFont;   // �_���t�H���g
  OldFont: HFont;
  EscapeVectorX, EscapeVectorY: Extended; // �����̌X����\���P�ʃx�N�^
  LastCharIndex: Integer; // �ł����Ɉʒu���镶���̃C���f�b�N�X

  // �C���f�b�N�X�Ŏw�肳�ꂽ1����������`��
  procedure DrawOneChar(i: Integer; Width: Integer; Option: DWord);
  begin
    DXs[0] := Width;
    DXs[1] := 0;
    Win32Check(ExtTextOut(DC,
                 FReference.x + Round(FText[i].FPosition * EscapeVectorX),
                 FReference.y + Round(FText[i].FPosition * EscapeVectorY),
                 Option, @FRect,
                 PChar(FText[i].FString), Length(FText[i].FString), @DXs));
  end;

  // �ł����Ɉʒu���镶����������
  function SelectLastChar: Integer;
  var
    i: Integer;
    RightEdgePos: Integer;
  begin
    Result := 0;
    RightEdgePos := FText[0].FPosition + FText[0].FWidth;

    for i := 1 to TextLength-1 do
      if FText[i].FPosition + FText[i].FWidth > RightEdgePos then
      begin
        Result := i;
        RightEdgePos := FText[i].FPosition + FText[i].FWidth;
      end;
  end;
begin
  TextLength := Length(FText);
  if TextLength = 0 then Exit;

  // �_���t�H���g�𓾁A�����̌X����\���P�ʃx�N�^���v�Z����
  OldFont := SelectObject(DC, GetStockObject(SYSTEM_FONT));
  try
    GetObject(OldFont, SizeOf(TLogFont), @lf);
  finally
    SelectObject(DC, OldFont);
  end;
  EscapeVectorX := cos(lf.lfEscapement * pi / 1800);
  EscapeVectorY := -sin(lf.lfEscapement * pi / 1800) *
                   GetDeviceCaps(DC, LOGPIXELSY) /
                   GetDeviceCaps(DC, LOGPIXELSX);

  // �ł����̈ʒu�̕�����`��
  LastCharIndex := SelectLastChar;
  // �ŏ��̕�����`��
  DrawOneChar(0, FText[LastCharIndex].FPosition + FText[LastCharIndex].FWidth,
              FOption);
  if TextLength > 1 then
  // �����񒷂� 1 �ȏ�Ȃ� �Ō�̕�����`��ETO_OPAQUE �t���O�𗎂Ƃ��A
  // �w�i���[�h��TRANSPARENT �ɂ��đS������`��
  begin
    DrawOneChar(SelectLastChar, FText[SelectLastChar].FWidth, FOption);
    SaveDC(DC);
    try
      SetBkMode(DC, TRANSPARENT);
      for i := 0 to TextLength-1 do
        DrawOneChar(i, FText[i].FWidth, FOption and not ETO_OPAQUE);
    finally
      RestoreDC(DC, -1);
    end;
  end;
end;

// ���^�t�@�C�����R�[�h������ĕ`��
procedure TExtTextOutConverter.PlayExtTextOut(DC: HDC; lpHTable: Pointer;
  nObj: DWORD);
var
  TextLength: Integer;                    // ������
  i: Integer;
  DXs: array[0..1] of Integer;            // �����Z����
  lf: TLogFont;                           // �_���t�H���g
  OldFont: HFont;
  EscapeVectorX, EscapeVectorY: Extended; // �����̌X����\���P�ʃx�N�^
  LastCharIndex: Integer;                 // �Ō�Ɉʒu���镶���̃C���f�b�N�X
  pRec: PENHMETARECORD;                   // ���R�[�h�|�C���^

  // 1�����`��
  procedure DrawOneChar(i: Integer; Width: Integer; Option: DWord);
  var
    pRec: PENHMETARECORD;
  begin
    DXs[0] := Width; // �Z�������Z�b�g
    DXs[1] := 0;

    // ExtTextOutA ���R�[�h�����
    pRec := PENHMETARECORD(CreateExtTextOutARecord(
       FReference.x + Round(FText[i].FPosition * EscapeVectorX),
       FReference.y + Round(FText[i].FPosition * EscapeVectorY),
       Option, FText[i].FString, FRect, @DXs));
    try
      // �`��
      PlayEnhMetafileRecord(DC, PHandleTable(lpHTable)^, pRec^, nObj);
    finally
      FreeMem(pRec);
    end;
  end;

  // �ʒu�I�ɍŌ�̕��������߂�
  function SelectLastChar: Integer;
  var
    i: Integer;
    RightEdgePos: Integer;
  begin
    Result := 0;
    RightEdgePos := FText[0].FPosition + FText[0].FWidth;

    for i := 1 to TextLength-1 do
      if FText[i].FPosition + FText[i].FWidth > RightEdgePos then
      begin
        Result := i;
        RightEdgePos := FText[i].FPosition + FText[i].FWidth;
      end;
  end;
begin
  Assert(Self.FCreatedFromMetafileRecord);

  TextLength := Length(FText);
  if TextLength = 0 then Exit;

  // �����̌X���𓾁A�P�ʃx�N�^�����߂�
  OldFont := SelectObject(DC, GetStockObject(SYSTEM_FONT));
  try
    GetObject(OldFont, SizeOf(TLogFont), @lf);
  finally
    SelectObject(DC, OldFont);
  end;
  EscapeVectorX := cos(lf.lfEscapement * pi / 1800);
  EscapeVectorY := -sin(lf.lfEscapement * pi / 1800) *
                   GetDeviceCaps(DC, LOGPIXELSY) /
                   GetDeviceCaps(DC, LOGPIXELSX);

  // �Ō�̈ʒu�̕��������߂�
  LastCharIndex := SelectLastChar;

  // �ŏ��̕�����`��
  DrawOneChar(0, FText[LastCharIndex].FPosition + FText[LastCharIndex].FWidth,
              FOption);
  if TextLength > 1 then
  begin
    // �����񒷂� 1 �ȏ�Ȃ� �Ō�̕�����`��ETO_OPAQUE �t���O�𗎂Ƃ��A
    // �w�i���[�h��TRANSPARENT �ɂ��đS������`��
    DrawOneChar(SelectLastChar, FText[SelectLastChar].FWidth, FOption);
    pRec := PENHMETARECORD(CreateSaveDCRecord);
    try
      PlayEnhMetafileRecord(DC, PHandleTable(lpHTable)^, pRec^, nObj);
    finally
      FreeMem(pRec);
    end;
    try
      pRec := PENHMETARECORD(CreateSetBkModeRecord(TRANSPARENT));
      try
        PlayEnhMetafileRecord(DC, PHandleTable(lpHTable)^, pRec^, nObj);
      finally
        FreeMem(pRec);
      end;
      for i := 0 to TextLength-1 do
        DrawOneChar(i, FText[i].FWidth, FOption and not ETO_OPAQUE);
    finally
      pRec := PENHMETARECORD(CreateRestoreDCRecord);
      try
        PlayEnhMetafileRecord(DC, PHandleTable(lpHTable)^, pRec^, nObj);
      finally
        FreeMem(pRec);
      end;
    end;
  end;
end;

type
  TParaBlockForGetSize = record
    MMWidth, MMHeight: Integer;
  end;
  PParaBlockForGetSize = ^TParaBlockForGetSize;

// ���^�t�@�C���w�b�_���� rclFrame �̑傫�����擾����
function FixMetafileProcForGetSize(
  h: HDC; lpHTable: Pointer; lpEMFR: PEnhMetaRecord;
  nObj: Integer; lpdata: LPARAM): Integer; stdcall;
var
  pPara: PParaBlockForGetSize;
  pHead: PENHMETAHEADER;
begin
  case lpEMFR.iType of
  EMR_HEADER: // �w�b�_���R�[�h
    begin
      pPara := PParaBlockForGetSize(lpdata);
      pHead := PENHMETAHEADER(lpEMFR);
      // �傫�����擾
      pPara.MMWidth  := pHead.rclFrame.Right - pHead.rclFrame.Left;
      pPara.MMHeight := pHead.rclFrame.Bottom - pHead.rclFrame.Top;
      Result := 0;
      Exit;
    end;
  end;
  Result := 1;
end;

// ���^�t�@�C���̕ϊ��������s��
function FixMetafileProc(
  h: HDC; lpHTable: Pointer; lpEMFR: PEnhMetaRecord;
  nObj: Integer; lpdata: LPARAM): Integer; stdcall;
var
  etoc: TExtTextOutConverter;
begin
  case lpEMFR.iType of
  EMR_EXTTEXTOUTA, EMR_POLYTEXTOUTA, EMR_EXTTEXTOUTW, EMR_POLYTEXTOUTW:
    begin  // ExtTextOutA���R�[�h
      etoc := TExtTextOutConverter.Create(PEMREXTTEXTOUT(lpEMFR));
      try
        // ExtTextOutA �𕡐��� ExtTextOutA �ɕ������ĕ`��
        etoc.PlayExtTextOut(h, lpHTable, nObj);
      finally
        etoc.Free;
      end;
    end;
  else
    PlayEnhMetafileRecord(h, PHandleTable(lpHTable)^, lpEMFR^, nObj);
  end;
  Result := 1;
end;

function FixMetafileFor9X(AMetafile: TMetafile; RefDC: HDC): TMetafile;
var
  R: TRect;                  // �`����`
  MC: TMetafileCanvas;       // �`��惁�^�t�@�C���̃L�����o�X
  DC: HDC;                   // �`��惁�^�t�@�C���̃L�����o�X�̃n���h��
  NeedReleaseDC: Boolean;    // �X�N���[��DC �̔j�����K�v�ł��邱�Ƃ�����
  Para: TParaBlockForGetSize;// ���^�t�@�C���T�C�Y�擾�p�p�����[�^�u���b�N
  SavedInch: Integer;
begin
  // NT �n�Ȃ�ύX���Ȃ�
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    Result := TMetafile.Create;
    try
      Result.Assign(AMetafile);
    except
      Result.Free;
      raise;
    end;
    Exit;
  end;

  if (AMetafile.MMWidth = 0) or (AMetafile.MMHeight = 0) then
    raise Exception.Create('FixMetafileFor9X: Metafile has no valid Size');

  // ���^�t�@�C���́u�������v�傫�����擾����
  Para.MMWidth := 0; Para.MMHeight := 0;
  R := Rect(0, 0, 0, 0);

  EnumEnhMetafile(0, AMetafile.Handle, @FixMetafileProcForGetSize, @Para, R);

  if (Para.MMWidth = 0) or (Para.MMHeight = 0) then
    raise Exception.Create('FixMetafileFor9X: Metafile has no valid Size');

  Result := TMetafile.Create;
  try
    // ���^�t�@�C���̑傫�����Z�b�g����
    Result.MMWidth  := Para.MMWidth;
    Result.MMHeight := Para.MMHeight;

    // �`����`�̑傫���𐳂������̂ɂ���
    SavedInch := AMetafile.Inch;
    try
      AMetafile.Inch := 0;
      R := Rect(0, 0,
                AMetafile.Width * Result.MMWidth div AMetafile.MMWidth,
                AMetafile.Height * Result.MMHeight div AMetafile.MMHeight);
    finally
      AMetafile.Inch := SavedInch;
    end;

    // �Q�ƃf�o�C�X�� 0 �Ȃ�X�N���[���f�o�C�X������
    if RefDC = 0 then
    begin
      RefDC := GetDC(0);
      NeedReleaseDC := True;
    end
    else
      NeedReleaseDC := False;
    try
      MC := TMetafileCanvas.Create(Result, RefDC);
      try
        DC := MC.Handle;
        // �ύX����
        EnumEnhMetafile(DC, AMetafile.Handle, @FixMetafileProc, Nil, R);
      finally
        MC.Free;
      end;
    finally
      if NeedReleaseDC then ReleaseDC(0, RefDC);
    end;
    Result.MMWidth := AMetafile.MMWidth;
    Result.MMHeight := AMetafile.MMHeight;
    Result.Inch := AMetafile.Inch;
  except
    Result.Free;
    raise;
  end;
end;
{$ENDIF}

end.
