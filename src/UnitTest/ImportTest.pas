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
    Check(importText.hasError, '１行目のエラーが起きていない');
    Check(('エラー: (1行目) 日付データと関連付けられていないデータ行' = importText.ErrorItems[0]), '１行目のエラーが起きていない');
end;

procedure TImportTextTest.TestImportErr;
begin
    importText := TImportText.Create('import-err.txt');
    Check(importText.hasError, 'エラーが起きていない');
    Check(importText.ErrorItems.Count = 51, 'エラー個数');
end;

procedure TImportTextTest.TestImportSortedItem;
begin
    importText := TImportText.Create('import-reorder.txt');
    Check(importText.ItemCount = 12, 'データ件数に誤り');
    Check(importText.GetItem(0).Date = StrToDateTime('2005/1/1'), '１件目日付');
    Check(importText.GetItem(1).Date = StrToDateTime('2005/1/3'), '２件目日付');
    Check(importText.GetItem(2).Date = StrToDateTime('2005/1/6'), '３件目日付');
    Check(importText.GetItem(3).Date = StrToDateTime('2005/1/8'), '４件目日付');
    Check(importText.GetItem(4).Date = StrToDateTime('2005/1/9'), '５件目日付');
    Check(importText.GetItem(5).Date = StrToDateTime('2005/1/10'), '６件目日付');
    Check(importText.GetItem(6).Date = StrToDateTime('2005/1/12'), '７件目日付');
    Check(importText.GetItem(7).Date = StrToDateTime('2005/1/14'), '８件目日付');
    Check(importText.GetItem(8).Date = StrToDateTime('2005/1/15'), '９件目日付');
    Check(importText.GetItem(9).Date = StrToDateTime('2005/1/16'), '１０件目日付');
    Check(importText.GetItem(10).Date = StrToDateTime('2005/1/19'), '１１件目日付');
    Check(importText.GetItem(11).Date = StrToDateTime('2005/1/20'), '１２件目日付');
end;

procedure TImportTextTest.TestImportItemCount;
begin
    importText := TImportText.Create('import.txt');
    Check(importText.GetItem(0).Date = StrToDateTime('2005/2/1'), '１件目日付');
    Check(importText.GetItem(1).Date = StrToDateTime('2005/2/2'), '２件目日付');
    Check(importText.GetItem(2).Date = StrToDateTime('2005/2/5'), '３件目日付');
    Check(importText.ItemCount = 3, 'データ件数に誤り');

    Check(importText.GetItem(0).LineCount = 1, '１件目行数');
    Check(importText.GetItem(1).LineCount = 4, '２件目行数');
    Check(importText.GetItem(2).LineCount = 8, '３件目行数');
end;

procedure TImportTextTest.TestImportFileNotfound;
begin
    importText := TImportText.Create('NOT-EXIST.FILE');
    Check(importText.hasError, 'ファイル開けなかったエラーが存在');
    Check('エラー: ファイルが開けません．' = importText.ErrorItems[0], 'ファイルが開けなかったエラーメッセージ出力');
end;

initialization
 TestFramework.RegisterTest(TImportTextTest.Suite);

end.
