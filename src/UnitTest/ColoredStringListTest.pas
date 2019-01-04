unit ColoredStringListTest;

interface

uses
    Graphics, SysUtils, TestFrameWork, ColoredStringList;

type

    TColoredStringListTest = class(TTestCase)
    private
        list: TColoredStringList;
        font: TFont;
    protected
        procedure SetUp; override;
        procedure TearDown; override;

    published
        procedure TestClear;
        procedure TestAdd;
    end;

implementation

procedure TColoredStringListTest.SetUp;
begin
  inherited;
  list := TColoredStringList.Create;
  font := TFont.Create;
  font.Name := '‚l‚r ‚oƒSƒVƒbƒN';
  font.Color := clGreen;
end;

procedure TColoredStringListTest.TearDown;
begin
  inherited;
  list.Free;
  font.Free;
end;

procedure TColoredStringListTest.TestClear;
begin
  CheckEquals(0, list.Count);
  list.Add('Hoge', clDefault, font);
  CheckEquals(1, list.Count);
  list.Add('Fuga', clBlack, font);
  CheckEquals(2, list.Count);
  list.Add('Fuga', clBlack, font);
  CheckEquals(3, list.Count);
  list.Clear;
  CheckEquals(0, list.Count);
end;

procedure TColoredStringListTest.TestAdd;
begin
  list.Add('Hoge', clDefault, font);
  list.Add('Fuga', clBlack, font);
  list.Add('Fuga', clBlack, font);
  CheckEquals(3, list.Count);
  CheckEquals('Hoge', list.Text(0), 'list text 0');
  CheckEquals('Fuga', list.Text(1), 'list text 1');
  CheckEquals('Fuga', list.Text(2), 'list text 2');
  CheckEquals(clDefault, list.Color(0), 'list color 0');
  CheckEquals(clBlack, list.Color(1), 'list color 1');
  CheckEquals(clBlack, list.Color(2), 'list color 2');
  CheckEquals('‚l‚r ‚oƒSƒVƒbƒN', list.Font(0).Name, 'list font 0');
  Check(font = list.Font(1), 'list font 1');
  Check(font = list.Font(2), 'list font 2');
  CheckEquals(clGreen, font.Color, 'font color changed');
end;


initialization

 TestFramework.RegisterTest(TColoredStringListTest.Suite);


end.
