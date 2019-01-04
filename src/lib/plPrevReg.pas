//====================================================================
//    ����v���r���[����R���|�[�l���g  TplPrev
//    �R���|�[�l���g�o�^�ƃv���p�e�B�G�f�B�^�֌W
//
//    ���̈���v���r���[����R���|�[�l���g�́C����̃R�[�h��`�悷��
//    ���߂�Canvas�ƁC�����ɕ`�悵�����e���v���r���[���邽�߂́C�J�X
//    �^�}�C�Y�\�ȃt�H�[����񋟂�����̂ł��D�v���r���[��ʂŕő�
//    �葀����������s���܂��D
//
//                            2005.02.19  Ver.4.56 �@
//                            Copyright (C) Mr.XRAY
//                            http://homepage2.nifty.com/Mr_XRAY/
//====================================================================
unit plPrevReg;

interface

uses
  {$IFDEF VER130}
  Windows, SysUtils, Classes,DsgnIntf,Exptintf;
  {$ELSE}
  Windows, SysUtils, Classes, DesignIntf,DesignEditors,Exptintf;
  {$ENDIF}

type

//====================================================================
//  FormName�v���p�e�B�̐ݒ�p
//====================================================================
  TFormNameProperty = class(TStringProperty)
  public
    procedure GetValues(Proc: TGetStrProc); override;
    function GetAttributes: TPropertyAttributes; override;
    procedure SetValue(const Value: String); override;
  end;

procedure Register;

implementation

uses plPrev;

var
   FormNameList: TStringList;

//====================================================================
//  �A�v���P�[�V������Form�̃��X�g�쐬
//  ���݂̃v���W�F�N�g��Form�̃��X�g���擾����
//  ���O��plPrevForm���̂��̂͏��O(�v���r���[�t�H�[���͌p�����Ďg�p
//  ���邱�Ƃ�O��Ƃ��Ă��邽�߁D
//====================================================================
function EnumProc(Param: Pointer; const FileName, UnitName,
  FormName: string): Boolean stdcall;
begin
     if FormName <> '' then begin
       if FormName<>'plPrevForm' then FormNameList.Add(FormName);
     end;
     Result := True;
end;

{ TFormNameProperty }

//====================================================================
//  �I�u�W�F�N�g�C���X�y�N�^�ł̑I����@�̎w��
//====================================================================
function TFormNameProperty.GetAttributes: TPropertyAttributes;
begin
     Result := [paValueList, paSortList];
end;
//====================================================================
//  �I�u�W�F�N�g�C���X�y�N�^�ɕ\�����镶���񃊃X�g�쐬
//====================================================================
procedure TFormNameProperty.GetValues(Proc: TGetStrProc);
var
     i: Integer;
begin
     FormNameList.Clear;
     ToolServices.EnumProjectUnits(EnumProc, Self);
     for i := 0 to FormNameList.Count - 1 do begin
       Proc(FormNameList[i]);
     end;
end;
//====================================================================
//  �I�u�W�F�N�g�C���X�y�N�^�ɑI������Form�����Z�b�g
//====================================================================
procedure TFormNameProperty.SetValue(const Value: String);
begin
     SetStrValue(Value);
end;
//====================================================================
//  �R���|�[�l���g�̓o�^�֌W�̐ݒ�
//
//  �����ł�[plXRAY]�^�u�ɓo�^����悤�ɂ��Ă���.
//  �o�^�p���b�g�̕ύX�͈ȉ��̂����ꂩ��...
//  (1)'Samples'�̖��O��ύX����D
//     ���݂��Ȃ��p���b�g���w�肷��ƁC���̃p���b�g���쐬�����
//  (2)���̂܂ܓo�^���C[�R���|�[�l���g][�p���b�g�̐ݒ�]�ŕύX����
//  �O�̃o�[�W�����œo�^�p���b�g��ύX���Ă���ꍇ�͓o�^��̃p���b�g
//  �ɕύX�͂Ȃ��D
//====================================================================
procedure Register;
begin
     RegisterComponents ('plXRAY', [TplPrev]);
     RegisterPropertyEditor(TypeInfo(TComponentName),
                            TplPrev,'FormName',TFormNameProperty);
end;
//====================================================================
//    �v���p�e�B�G�f�B�^�̏������ƏI������
//    Form���̃��X�g�p��TStringList�̍쐬�Ɣj��
//====================================================================
initialization
     FormNameList := TStringList.Create;
finalization
     FormNameList.Free;
//====================================================================
//   �R�[�h�I��
//====================================================================
end.

