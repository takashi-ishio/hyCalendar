unit Rokuyo;

interface

uses
    Windows, Controls, SysUtils, Classes,
    CalendarItem, SeriesItem, SeriesItemManager,
    SeriesCallback, AbstractDocument;

type
    TRokuyo = class;

    TRokuyoSeriesItem = class(TSeriesItem)
    private
        FRokuyo: TRokuyo;
    public
        constructor Create(rokuyo: TRokuyo);
        function match(d: TDateTime; callback: TSeriesItemConditionCallback; idx: integer; var ret: string): boolean; override;
    end;

    TNonParamProcedure = procedure; stdcall;
    TFeatureSupportQuery = function: boolean; stdcall;
    TFunctionGetDayName = function(d: TDateTime): PChar; stdcall;
//    TStartupFunction = function: boolean; stdcall;
    TStartupFunction = function(dirname: PAnsiChar): boolean; stdcall;

    TRokuyo = class(TAbstractCalendarDocument)
    private
        module: HModule;

        libStartup : TNonParamProcedure;
        libStartup2: TStartupFunction;
        libCleanup : TNonParamProcedure;
        libSupportDayName: TFeatureSupportQuery;
        libGetDayName: TFunctionGetDayName;

        rokuyoSeries: TSeriesItem;

        FFilename: TFilename;
        FLastErrorString: string;

    protected
        function getFilename: TFilename; override;
    public
        constructor Create;
        destructor Destroy; override;

        function LoadFrom(filename: string): boolean;

        procedure updateSeriesItem(manager: TSeriesItemManager); override;
        function getItem(day: TDate): TCalendarItem; override;

        function getDayName(d: TDateTime; var str: string): boolean;
        property LastErrorString: string read FLastErrorString;
    end;



implementation


constructor TRokuyoSeriesItem.Create(rokuyo: TRokuyo);
begin
    inherited Create;
    FRokuyo := rokuyo;
    IsShownAsDayName := true;
    IsHidden := false;
    IsHoliday := false;
    Name := '六曜';
end;

function TRokuyoSeriesItem.match(d: TDateTime; callback: TSeriesItemConditionCallback; idx: integer; var ret: string): boolean;
begin
    Result := FRokuyo.getDayName(d, ret);
end;

function TRokuyo.getFilename: TFilename;
begin
    Result := FFilename;
end;

constructor TRokuyo.Create;
begin
    inherited Create;
    FLastErrorString := '';
    rokuyoSeries := TRokuyoSeriesItem.Create(self);
end;

function TRokuyo.LoadFrom(filename: string): boolean;
var
    success : boolean;
    b: boolean;
    path: string;
begin
    FFileName := filename;
    Header := ExtractFileName(FFilename);
    module := LoadLibrary(PAnsiChar(filename));
    if module <> 0 then begin
        success := true;
        libStartup := GetProcAddress(Module, 'startup');
        libStartup2 := GetProcAddress(Module, 'startup2');
        success := success and (Assigned(libStartup) or Assigned(libStartup));

        libCleanup := GetProcAddress(Module, 'cleanup');
        success := success and (Assigned(libCleanup));

        libSupportDayName := GetProcAddress(Module, 'supportDayName');
        success := success and (Assigned(libSupportDayName));

        libGetDayName := GetProcAddress(Module, 'getDayName');
        success := success and (Assigned(libGetDayName));

        if not success then begin
            FLastErrorString := 'hyCalendar の外部モジュールとして認識できません．';
            FreeLibrary(module);
            module := 0;
        end else begin

            if Assigned(libStartup2) then begin
                path := ExtractFilePath(FFilename);
                b := libStartup2(PAnsiChar(path));
                if not b then begin
                    FLastErrorString := 'Rokuyo DLL の初期化中にエラーが発生しました．';
                    FreeLibrary(module);
                    module := 0;
                end;
            end else begin
                libStartup;
            end;
        end;
    end else begin
       FLastErrorString := 'ライブラリが見つかりません．'
    end;
    Result := (module <> 0);
end;

destructor TRokuyo.Destroy;
begin
    if module <> 0 then begin
        libCleanup;
        FreeLibrary(module);
    end;
    rokuyoSeries.Free;
    inherited;
end;

function TRokuyo.getItem(day: TDate): TCalendarItem;
begin
    Result := nil;
end;


function TRokuyo.getDayName(d: TDateTime; var str: string): boolean;
var
    p: PChar;
begin
    if (module <> 0) then begin
        p := libGetDayName(d);
        if (p = nil) then begin
            Result := false;
        end else begin
            Result := true;
            str := Copy(p, 1, 4);
        end;
    end else begin
        Result := false;
    end;
end;

procedure TRokuyo.updateSeriesItem(manager: TSeriesItemManager);
begin
    manager.registerItem(rokuyoSeries);
end;



end.
