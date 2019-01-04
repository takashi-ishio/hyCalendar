{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$WARNINGS OFF}
//====================================================================
//   �v�����^�ݒ�R���|�[�l���g  TplSetPrinter
//   �R���|�[�l���g�o�^�y�уv���p�e�B�G�f�B�^�֌W
//
//   ����p�̃v���O�����쐬�̍ہC�v�����^�̐ݒ�(�p���T�C�Y��p������
//   ������Ƀv�����^�̃v���p�e�B�ݒ�_�C�A���O(�v�����^�h���C�o����
//   ������)��\�����čs���R���|�[�l���g�D
//
//   ���̃v���p�e�B�G�f�B�^�֌W�̃R�[�h�́C
//   Delphi��Ver5����CDSGNINTF.DCU��Delphi �ɕt�����Ȃ��Ȃ�C�R���|
//   �[�l���g�J���҂͐݌v���R�[�h�������^�C���R�[�h����ʁX�̃��j�b�g
//   �ɕ�������K�v�����������߂̏��u�D
//
//
//                            2005.01.29  Ver.6.06�@
//                            Copyright (C) by Mr.XRAY
//                            http://homepage2.nifty.com/Mr_XRAY/
//====================================================================
unit plSetPrinterReg;

interface

uses

  {$IFDEF VER130}
  plSetPrinter,Windows,SysUtils, Classes,Forms,Controls,ToolWin,
  Printers,WinSpool,DsgnIntf,StdCtrls;
  {$ELSE}
  plSetPrinter,Windows,SysUtils, Classes,Forms,Controls,ToolWin,
  Printers,WinSpool,DesignIntf,StdCtrls,DesignEditors;
  {$ENDIF}

type
  {�v�����^���̐錾}
  TplPrinterInfo4Array = array[0..10000] of TPrinterInfo4;
  plPPrinterInfo4Array = ^TplPrinterInfo4Array;
  TplPrinterInfo5Array = array[0..10000] of TPrinterInfo5;
  plPPrinterInfo5Array = ^TplPrinterInfo5Array;

//====================================================================
//     �v�����^���v���p�e�B�N���X�֌W
//====================================================================
TPrinterNameProperty = class(TStringProperty)
public
      function GetAttributes: TPropertyAttributes; override;
      procedure GetValues(Proc: TGetStrProc); override;
      function GetValue: String;override;
      procedure SetValue(const Value: String); override;
end;
//====================================================================
//  �v�����^�̃v���p�e�B�̃_�C�A���O�֌W
//  ���\�b�h��Edit�̂�
//
//  1999.7.31�ǉ�
//  ExecuteVerb,GetVerb,GetVerbCount��ǉ����ă}�E�X�E�N���b�N�Ńv
//  ���p�e�B�̐ݒ���\�ɂ���.
//  Ver5.3�ł���͔p�~�����D
//====================================================================
TPrinterProperty = class(TComponentEditor)
public
      procedure Edit; override;
end;

procedure Register;

implementation

var
   PrintersInfo        : array of Byte;  {�v�����^���}
   nPrinters           : DWORD;          {�v�����^�̐�}
   PrinterInfoLevel    : Integer;        {�v�����^���̃��x��}
   PrinterNameList     : TStringList;    {�v�����^���̃��X�g}

{TPrinterNameProperty}

//====================================================================
//  �v�����^���v���p�e�B
//  �I�u�W�F�N�g�C���X�y�N�^�ł̑���
//  ���X�g����̑I������Ƃ��邽��,�Ǐo����p.
//====================================================================
function TPrinterNameProperty.GetAttributes: TPropertyAttributes;
begin
     Result:=[paValueList];
end;
//====================================================================
//  �v�����^���v���p�e�B
//  �I�u�W�F�N�g�C���X�y�N�^�p�Ƀv�����^���̃��X�g���쐬
//====================================================================
procedure TPrinterNameProperty.GetValues(Proc: TGetStrProc);
var
     Flags: Integer;    {EnumPrinters �ɓn���t���O}
     InfoBytes: DWORD;  {�v�����^���̃o�C�g��}
     i: Integer;
     APrtName: String;
begin
     nPrinters := 0;
     PrinterNameList.Clear;
     {�v�����^���𓾂鏀��}
     if Win32Platform = VER_PLATFORM_WIN32_NT then begin
       Flags := PRINTER_ENUM_CONNECTIONS or PRINTER_ENUM_LOCAL;
       PrinterInfoLevel := 4;
     end else begin
       Flags := PRINTER_ENUM_LOCAL;
       PrinterInfoLevel := 5;
     end;

     InfoBytes := 0;
     {�o�b�t�@���𓾂�}
     EnumPrinters(Flags, nil, PrinterInfoLevel, nil, 0,InfoBytes, nPrinters);

     if InfoBytes<>0 then begin
       {�o�b�t�@�m��}
       SetLength(PrintersInfo, InfoBytes);
       {�v�����^���(Level=4 or 5)���擾}
       Win32Check(EnumPrinters(Flags, nil, PrinterInfoLevel,
                               Pointer(PrintersInfo),
                               InfoBytes, InfoBytes, nPrinters));
       {�ꗗ�ɒǉ�}
       for i := 0 to nPrinters-1 do begin
         if PrinterInfoLevel = 4 then begin
           if (plPPrinterInfo4Array(PrintersInfo)[i].Attributes and
                                  PRINTER_ATTRIBUTE_HIDDEN) = 0 then begin
             APrtName:=plPPrinterInfo4Array(PrintersInfo)[i].pPrinterName;
             PrinterNameList.Add(APrtName);
           end;
         end else begin
           if (plPPrinterInfo5Array(PrintersInfo)[i].Attributes and
                                  PRINTER_ATTRIBUTE_HIDDEN) = 0 then begin
             APrtName:=plPPrinterInfo5Array(PrintersInfo)[i].pPrinterName;
             PrinterNameList.Add(APrtName);
           end;
         end;
       end;
       PrinterNameList.Sort;
       for i:=0 to PrinterNameList.Count-1 do begin
         Proc(PrinterNameList[i]);
       end;
     end;
end;
//====================================================================
//  �v�����^���v���p�e�B
//  �I�u�W�F�N�g�C���X�y�N�^�ɕ\�����鎞�Ɍďo���֐�
//  �󕶎��̏ꍇ(����͖{�R���|��Form�ɏ��߂Ĕz�u������)�̓v�����^��
//  �����f�t�H���g�̂��̂��Z�b�g���Ă���DWindows2000,XP�ł̓v�����^
//  ���Ƀ|�[�g�����t������Ă��Ȃ��̂ŁC����ł悢�D
//  (�{�R���|�̓���m�F�J������Windows2000,XP)
//====================================================================
function TPrinterNameProperty.GetValue: String;
var
     PrtName: String;
     pt:TplSetPrinter;
begin
     pt:=GetComponent(0) as TplSetPrinter;
     if GetStrValue='' then begin
       Printer.PrinterIndex:=-1;
       PrtName:=Printer.Printers[Printer.PrinterIndex];
       Result:=PrtName;
       pt.PrinterName:=PrtName;
     end else begin
       Result:=GetStrValue;
     end;
end;
//====================================================================
//  �v�����^���v���p�e�B
//  �I�u�W�F�N�g�C���X�y�N�^�Ƀv�����^�����Z�b�g�����ƌĂ΂��.
//====================================================================
procedure TPrinterNameProperty.SetValue(const Value: String);
begin
     SetStrValue(Value);
end;

{TPrinterProperty}

//====================================================================
//  �v�����^�̃v���p�e�C�̃_�C�A���O��\��
//
//  �t�H�[����̃R���|�[�l���g���_�u���N���b�N����ƃv�����^�̃v��
//  �p�e�B�̐ݒ�_�C�A���O��\������.���̃_�C�A���O�̓v�����^�h���C
//  �o���񋟂��Ă���.�܂�,�v�����^�̐������,�h���C�o�̃o�[�W����
//  �ɂ���ĈقȂ�.
//====================================================================
procedure TPrinterProperty.Edit;
var
     pt:TplSetPrinter;
begin
     pt:=(Component as TplSetPrinter);
     {�v�����^�̃v���p�e�B�̃_�C�A���O��\��}
     pt.ShowDialog;
     {���ꂪ�Ȃ���PaperNum,Orient,DevSize���X�V�ۑ�����Ȃ�}
     Designer.Modified;
end;
//====================================================================
//  �R���|�[�l���g�̓o�^�֌W�̐ݒ�
//
//  �����ł�[plXRAY]�^�u�ɓo�^����悤�ɂ��Ă���.
//  �o�^�p���b�g�̕ύX�͈ȉ��̂����ꂩ��...
//  (1)'Samples'�̖��O��ύX����D
//     ���݂��Ȃ��p���b�g���w�肷��ƁC���̃p���b�g���쐬�����
//  (2)���̂܂ܓo�^���C[�R���|�[�l���g][�p���b�g�̐ݒ�]�ŕύX����
//
//  �O�̃o�[�W�����œo�^�p���b�g��ύX���Ă���ꍇ�͓o�^��̃p���b�g
//  �ɕύX�͂Ȃ��D
//====================================================================
procedure Register;
begin
     RegisterComponents     ('plXRAY', [TplSetPrinter]);
     RegisterPropertyEditor (TypeInfo(String),TplSetPrinter,'PrinterName',
                             TPrinterNameProperty);
     RegisterComponentEditor(TplSetPrinter,TPrinterProperty);
end;
//====================================================================
//    �v���p�e�B�G�f�B�^�̏������ƏI������
//    �v�����^���̃��X�g�p��TStringList�̍쐬�Ɣj��
//====================================================================
initialization
     PrinterNameList := TStringList.Create;
finalization
     PrinterNameList.Free;
//====================================================================
//   �R�[�h�I��
//====================================================================
end.

