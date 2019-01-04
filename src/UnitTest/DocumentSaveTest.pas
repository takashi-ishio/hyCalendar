unit DocumentSaveTest;

interface

uses
    Windows, Classes, SysUtils, TestFrameWork, CalendarDocument;

type

    TDocumentSaveTest = class(TTestCase)
    private
      FDocument: TCalendarDocument;

      function CompareTwoFiles(filename1, filename2: TFilename): boolean;
      procedure CleanupFiles;

    protected
      procedure SetUp; override;
      procedure TearDown; override;

    published
      procedure TestSaveLoad;
    end;

const
  TestDir = 'C:\Home\sdoc\devel\Calendar\testdata\';

implementation

procedure TDocumentSaveTest.SetUp;
begin
end;

procedure TDocumentSaveTest.CleanupFiles;
var
  f: TSearchRec;
  err: integer;
begin
  err := FindFirst(TestDir + '*.cal.copy', 0, f);
  while err = 0 do begin
    DeleteFile(TestDir + f.Name);
    err := FindNext(f);
  end;
  FindClose(f);
end;

procedure TDocumentSaveTest.TearDown;
begin
  FDocument := nil;
  CleanupFiles;
end;

function TDocumentSaveTest.CompareTwoFiles(filename1, filename2: TFilename): boolean;
var
  file1, file2: TStringList;
  i: integer;
  equal: boolean;
begin
  Result := false;
  file1 := TStringList.Create;
  file2 := TStringList.Create;
  try
      try
        file1.LoadFromFile(filename1);
        file2.LoadFromFile(filename2);
        if file1.Count = file2.Count then begin
          equal := true;
          i := 0;
          while equal and (i<file1.Count) do begin
            equal := file1[i] = file2[i];
            inc(i);
          end;
          Result := equal and (i = file1.Count);
        end;
      except
        on E: Exception do begin
            Fail(E.Message);
        end;
      end;
  finally
      file1.Free;
      file2.Free;
  end;
end;

procedure TDocumentSaveTest.TestSaveLoad;

  procedure processFile(filename: TFilename);
  begin
    FDocument := TCalendarDocument.Create;
    FDocument.LoadFrom(TestDir + filename);
    FDocument.SaveAs(TestDir + filename + '.copy');
    FDocument.Free;
    CheckTrue(CompareTwoFiles(TestDir + filename, TestDir + filename + '.copy'));
  end;

begin
  processFile('for_manual.cal');
  processFile('base.cal');
  processFile('base2.cal');
  processFile('reference.cal');
  processFile('seriesitems.cal');
  processFile('schedule_for_test.cal');
  processFile('schedule20060104.cal');
  processFile('schedule20060707.cal');
end;

initialization
 TestFramework.RegisterTest(TDocumentSaveTest.Suite);

end.
