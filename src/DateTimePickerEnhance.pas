unit DateTimePickerEnhance;

interface

uses
    Classes, ComCtrls, CommCtrl,
    CalendarConfig, Windows;


type


    TDateTimePickerEnhance = class
    private
        FConfiguration: TCalendarConfiguration;
        constructor Create;
        procedure onDropDown(Sender: TObject);
    public
        class function getInstance: TDateTimePickerEnhance;
    end;

    procedure enhancePicker(picker: TDateTimePicker);
    procedure setConfigurationForPicker(config: TCalendarConfiguration);


implementation

var
    theInstance: TDateTimePickerEnhance;

procedure enhancePicker(picker: TDateTimePicker);
begin
    assert(not Assigned(picker.OnDropDown), 'DateTimePicker.OnDropDown には既にイベントハンドラがセットされています.');
    picker.OnDropDown := TDateTimePickerEnhance.getInstance.onDropDown;
end;

procedure setConfigurationForPicker(config: TCalendarConfiguration);
begin
  TDateTimePickerEnhance.getInstance.FConfiguration := config;
end;


class function TDateTimePickerEnhance.getInstance: TDateTimePickerEnhance;
begin
    if (theInstance = nil) then begin
        theInstance := TDateTimePickerEnhance.Create;
    end;
    Result := theInstance;
end;


constructor TDateTimePickerEnhance.Create;
begin

end;



procedure TDateTimePickerEnhance.onDropDown(Sender: TObject);
var
    handle: THandle;
begin
    if (FConfiguration <> nil) and FConfiguration.StartFromMonday then begin
        handle := TDateTimePicker(Sender).Perform(DTM_GETMONTHCAL, 0, 0);
        if (handle <> 0) then begin
            // 月曜始まりのときはドロップダウンも月曜始まり
            SendMessage(handle, MCM_SETFIRSTDAYOFWEEK, 0, 0);
        end;
    end;
end;

end.
