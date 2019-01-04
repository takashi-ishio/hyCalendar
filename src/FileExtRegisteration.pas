unit FileExtRegisteration;


interface

uses Windows, Dialogs, Controls, Registry;

    procedure UnregisterFileExtension;
    procedure RegisterFileExtension;

implementation

procedure UnregisterFileExtension;
var
   Reg: TRegistry;
begin
     if MessageDlg('関連付けを解除してよろしいですか？',
                   mtConfirmation, mbOKCancel, 0)<> mrOK then exit;
     Reg:= TRegistry.create;
     with Reg do begin
          try
             RootKey:= HKEY_CLASSES_ROOT;

             DeleteKey('.cal');
             DeleteKey('hyCalender_CalendarFile'); // 古いスペルミスを削除
             DeleteKey('hyCalendar_CalendarFile');
             MessageDlg('関連付けを解除しました．',mtInformation,[mbOk],0);

          except
             MessageDlg('関連付けの解除に失敗しました．',mtError,[mbOk],0);

          end;
         free;
     end;
end;

procedure RegisterFileExtension;
var
   Reg: TRegistry;
begin
     if MessageDlg('.cal ファイルをこのソフトに関連付けますか？',
                   mtConfirmation, mbOKCancel, 0)<> mrOK then exit;
     Reg:= TRegistry.create;
     with Reg do begin
          try
             RootKey:= HKEY_CLASSES_ROOT;

             OpenKey('.cal', true);
             WriteString('', 'hyCalendar_CalendarFile');
             CloseKey;

             OpenKey('hyCalendar_CalendarFile', true);
             WriteString('', 'hyCalender スケジュールデータ');
             CloseKey;

             OpenKey('hyCalendar_CalendarFile\DefaultIcon', true);
             WriteString('', ParamStr(0)+ ',1');
             CloseKey;

             OpenKey('hyCalendar_CalendarFile\shell\open\command', true);
             WriteString('', ParamStr(0) + ' "%1"');
             CloseKey;

             MessageDlg('関連付けが完了しました．', mtInformation, [mbOk], 0);

          except

             MessageDlg('関連付けに失敗しました．', mtError, [mbOk], 0);
          end;

          free;
     end;
end;

end.
 