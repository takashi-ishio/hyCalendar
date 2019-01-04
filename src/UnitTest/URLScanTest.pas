unit URLScanTest;

interface

uses
    Classes, SysUtils, TestFrameWork, URLScan;

type
    TURLExtractorTest = class(TTestCase)
    private
      FURLExtractor: TURLExtractor;

    protected
      procedure SetUp; override;

    published
      procedure TestExtractURL;
      procedure TestExtractURL2;

      procedure TestRemoveURLString;
      procedure TestRemoveDateFromString;
      procedure TestExtractURLs;
      procedure TestExtractDate;
      procedure TestIsDateURL;

    end;


implementation

procedure TURLExtractorTest.SetUp;
begin
  inherited;
  FURLExtractor := TURLExtractor.getInstance;
end;

procedure TURLExtractorTest.TestExtractURL;
var
  idx: integer;
  str: string;
begin
  FURLExtractor.extractURL(0, 'http://netail.net/ hoge ftp://netail.net/', idx, str);
  CheckEquals('', str);
  CheckEquals(0, idx);

  FURLExtractor.extractURL(1, 'http://netail.net/ hoge ftp://netail.net/', idx, str);
  CheckEquals('http://netail.net/', str);
  CheckEquals(1, idx);


  FURLExtractor.extractURL(18, 'http://netail.net/ hoge ftp://netail.net/', idx, str);
  CheckEquals('http://netail.net/', str);
  CheckEquals(1, idx);

  FURLExtractor.extractURL(19, 'http://netail.net/ hoge ftp://netail.net/', idx, str);
  CheckEquals('', str);
  CheckEquals(0, idx);

  FURLExtractor.extractURL(24, 'http://netail.net/ hoge ftp://netail.net/', idx, str);
  CheckEquals('', str);
  CheckEquals(0, idx);

  FURLExtractor.extractURL(25, 'http://netail.net/ hoge ftp://netail.net/', idx, str);
  CheckEquals('ftp://netail.net/', str);
  CheckEquals(25, idx);

  FURLExtractor.extractURL(41, 'http://netail.net/ hoge ftp://netail.net/', idx, str);
  CheckEquals('ftp://netail.net/', str);
  CheckEquals(25, idx);

  FURLExtractor.extractURL(42, 'http://netail.net/ hoge ftp://netail.net/', idx, str);
  CheckEquals('', str);
  CheckEquals(0, idx);

  FURLExtractor.extractURL(100, 'http://netail.net/ hoge ftp://netail.net/', idx, str);
  CheckEquals('', str);
  CheckEquals(0, idx);

  FURLExtractor.extractURL(1, '1/1', idx, str);
  CheckEquals('', str);
  CheckEquals(0, idx);
end;

procedure TURLExtractorTest.TestExtractURL2;
var
  idx: integer;
  str: string;
  i: integer;

const
  URL: array [0..5] of string = (
   'http://netail.net/',
   'https://netail.net/',
   'mailto://hoge.com/@query.cgi?param=%20x&param2=y;param3=z',
   'file://C:/Hoge.txt',
   'file:"C:\ひらがな \全角.txt""ダブルクォート２つ続きTEXT"',
   'ftp://netail.net/');

begin
  for i:=0 to 5 do begin
    FURLExtractor.extractURL(1, URL[i], idx, str);
    CheckEquals(URL[i], str);
    CheckEquals(1, idx);
  end;
end;

procedure TURLExtractorTest.TestRemoveURLString;
begin
  CheckEquals('test 2000/01/01', FURLExtractor.RemoveURLString('testhttp://netail.net/ 2000/01/01'));
  CheckEquals('test  test2', FURLExtractor.RemoveURLString('testhttp://netail.net/ file://netail.net/ test2'));
  CheckEquals('全角文字列', FURLExtractor.RemoveURLString('file:"全角文字列".txt全角文字列'));
  CheckEquals('https -test', FURLExtractor.RemoveURLString('httpshttps:URL -test'));
end;

procedure TURLExtractorTest.TestRemoveDateFromString;
begin
  CheckEquals('test 13/23  http://netail.net', FURLExtractor.RemoveDateFromString('test1/2 13/23 1/4 http://netail.net'));
  // 2100年は，妥当な日付とはみなされない
  CheckEquals(' 2100/  test00/1 ', FURLExtractor.RemoveDateFromString('1999/1/1 2100/2/2 2050/2/2 test00/1 1/1/1'));
  CheckEquals('全角文字列', FURLExtractor.RemoveDateFromString('01/01/01全角文字列'));
  CheckEquals('"20"/', FURLExtractor.RemoveDateFromString('"20"/1/1'));
end;

procedure TURLExtractorTest.TestExtractURLs;
var
  urls: TStringList;
  target: string;
  urlpos: TURLPosition;
begin
  urls := TStringList.Create;
  try
    target := 'mailto:test@foo.com http://netail.net/ '#13#10'1/1 2/30 12/100 file:"全角".txtテスト';
    FURLExtractor.extractURLs(target, urls, 2000);

    // 戻ってくる順序はプロトコル種別依存
    CheckEquals(4, urls.Count);
    CheckEquals('http://netail.net/', urls[0]);
    CheckEquals('mailto:test@foo.com', urls[1]);
    CheckEquals('file:"全角".txt', urls[2]);
    CheckEquals('2000/01/01', urls[3]);

    urlpos := urls.Objects[0] as TURLPosition;
    CheckEquals(0, urlpos.line);
    CheckEquals(21, urlpos.col);
    CheckEquals(18, urlpos.len);

    urlpos := urls.Objects[1] as TURLPosition;
    CheckEquals(0, urlpos.line);
    CheckEquals(1, urlpos.col);
    CheckEquals(19, urlpos.len);

    urlpos := urls.Objects[2] as TURLPosition;
    CheckEquals(1, urlpos.line);
    CheckEquals(17, urlpos.col);
    CheckEquals(15, urlpos.len);

    urlpos := urls.Objects[3] as TURLPosition;
    CheckEquals(1, urlpos.line);
    CheckEquals(1, urlpos.col);
    CheckEquals(3, urlpos.len);

    FURLExtractor.cleanupURLs(urls);
    CheckEquals(0, urls.Count);
  finally
    if urls.Count > 0 then FURLExtractor.cleanupURLs(urls);
    urls.Free;
  end;
end;

procedure TURLExtractorTest.TestExtractDate;
var
  idx, len: integer;
  day: TDateTime;
begin
  FURLExtractor.extractDate(1, '1/1', 2000, idx, len, day);
  CheckEquals(StrToDate('2000/1/1'), day);
  CheckEquals(1, idx);
  CheckEquals(3, len);

  FURLExtractor.extractDate(9, '2000/1/1 2000/1/2 2000/1/03 ', 1999, idx, len, day);
  CheckEquals(0, day);
  CheckEquals(0, idx);

  FURLExtractor.extractDate(10, '2000/1/1 2000/1/2 2000/1/03 ', 1999, idx, len, day);
  CheckEquals(StrToDate('2000/1/2'), day);
  CheckEquals(10, idx);
  CheckEquals(8, len);

  FURLExtractor.extractDate(17, '2000/1/1 2000/1/2 2000/1/03 ', 1999, idx, len, day);
  CheckEquals(StrToDate('2000/1/2'), day);
  CheckEquals(10, idx);
  CheckEquals(8, len);

  FURLExtractor.extractDate(18, '2000/1/1 2000/1/2 2000/1/03 ', 1999, idx, len, day);
  CheckEquals(0, day);
  CheckEquals(0, idx);

  FURLExtractor.extractDate(19, '2000/1/1 2000/1/2 2000/1/03 ', 1999, idx, len, day);
  CheckEquals(StrToDate('2000/1/3'), day);
  CheckEquals(19, idx);
  CheckEquals(9, len);
end;

procedure TURLExtractorTest.TestIsDateURL;
begin
  CheckTrue(FURLExtractor.isDateURL('2000/1/1'));
  CheckTrue(FURLExtractor.isDateURL('00/1/1'));
  CheckTrue(FURLExtractor.isDateURL('1/1'));
  CheckFalse(FURLExtractor.isDateURL('2/30'));
  CheckFalse(FURLExtractor.isDateURL('hoge1/1'));
end;

initialization
 TestFramework.RegisterTest(TURLExtractorTest.Suite);

end.
