unit ImportTest;

interface

uses
    SysUtils, TestFrameWork, ImportText;

type

    TImportTextTest = class(TTestCase)
    private
        importText: TImportText;
    protected
        procedure TearDown; override;

    published
        procedure TestImport;
        procedure TestImportItemCount;
        procedure TestImportFileNotfound;
        procedure TestImportErr;
        procedure TestImportSortedItem;
    end;

implementation

uses StrUtils;

procedure TImportTextTest.TearDown;
begin
  inherited;
  if Assigned(importText) then importText.Free;
end;

procedure TImportTextTest.TestImport;
begin
    importText := TImportText.Create('import.txt');
    Check(importText.hasError, '�P�s�ڂ̃G���[���N���Ă��Ȃ�');
    Check(('�G���[: (1�s��) ���t�f�[�^�Ɗ֘A�t�����Ă��Ȃ��f�[�^�s' = importText.ErrorItems[0]), '�P�s�ڂ̃G���[���N���Ă��Ȃ�');
end;

procedure TImportTextTest.TestImportErr;
begin
    importText := TImportText.Create('import-err.txt');
    Check(importText.hasError, '�G���[���N���Ă��Ȃ�');
    Check(importText.ErrorItems.Count = 51, '�G���[��');
end;

procedure TImportTextTest.TestImportSortedItem;
begin
    importText := TImportText.Create('import-reorder.txt');
    Check(importText.ItemCount = 12, '�f�[�^�����Ɍ��');
    Check(importText.GetItem(0).Date = StrToDateTime('2005/1/1'), '�P���ړ��t');
    Check(importText.GetItem(1).Date = StrToDateTime('2005/1/3'), '�Q���ړ��t');
    Check(importText.GetItem(2).Date = StrToDateTime('2005/1/6'), '�R���ړ��t');
    Check(importText.GetItem(3).Date = StrToDateTime('2005/1/8'), '�S���ړ��t');
    Check(importText.GetItem(4).Date = StrToDateTime('2005/1/9'), '�T���ړ��t');
    Check(importText.GetItem(5).Date = StrToDateTime('2005/1/10'), '�U���ړ��t');
    Check(importText.GetItem(6).Date = StrToDateTime('2005/1/12'), '�V���ړ��t');
    Check(importText.GetItem(7).Date = StrToDateTime('2005/1/14'), '�W���ړ��t');
    Check(importText.GetItem(8).Date = StrToDateTime('2005/1/15'), '�X���ړ��t');
    Check(importText.GetItem(9).Date = StrToDateTime('2005/1/16'), '�P�O���ړ��t');
    Check(importText.GetItem(10).Date = StrToDateTime('2005/1/19'), '�P�P���ړ��t');
    Check(importText.GetItem(11).Date = StrToDateTime('2005/1/20'), '�P�Q���ړ��t');
end;

procedure TImportTextTest.TestImportItemCount;
begin
    importText := TImportText.Create('import.txt');
    Check(importText.GetItem(0).Date = StrToDateTime('2005/2/1'), '�P���ړ��t');
    Check(importText.GetItem(1).Date = StrToDateTime('2005/2/2'), '�Q���ړ��t');
    Check(importText.GetItem(2).Date = StrToDateTime('2005/2/5'), '�R���ړ��t');
    Check(importText.ItemCount = 3, '�f�[�^�����Ɍ��');

    Check(importText.GetItem(0).LineCount = 1, '�P���ڍs��');
    Check(importText.GetItem(1).LineCount = 4, '�Q���ڍs��');
    Check(importText.GetItem(2).LineCount = 8, '�R���ڍs��');
end;

procedure TImportTextTest.TestImportFileNotfound;
begin
    importText := TImportText.Create('NOT-EXIST.FILE');
    Check(importText.hasError, '�t�@�C���J���Ȃ������G���[������');
    Check('�G���[: �t�@�C�����J���܂���D' = importText.ErrorItems[0], '�t�@�C�����J���Ȃ������G���[���b�Z�[�W�o��');
end;

initialization
 TestFramework.RegisterTest(TImportTextTest.Suite);

end.
