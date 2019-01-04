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
     if MessageDlg('�֘A�t�����������Ă�낵���ł����H',
                   mtConfirmation, mbOKCancel, 0)<> mrOK then exit;
     Reg:= TRegistry.create;
     with Reg do begin
          try
             RootKey:= HKEY_CLASSES_ROOT;

             DeleteKey('.cal');
             DeleteKey('hyCalender_CalendarFile'); // �Â��X�y���~�X���폜
             DeleteKey('hyCalendar_CalendarFile');
             MessageDlg('�֘A�t�����������܂����D',mtInformation,[mbOk],0);

          except
             MessageDlg('�֘A�t���̉����Ɏ��s���܂����D',mtError,[mbOk],0);

          end;
         free;
     end;
end;

procedure RegisterFileExtension;
var
   Reg: TRegistry;
begin
     if MessageDlg('.cal �t�@�C�������̃\�t�g�Ɋ֘A�t���܂����H',
                   mtConfirmation, mbOKCancel, 0)<> mrOK then exit;
     Reg:= TRegistry.create;
     with Reg do begin
          try
             RootKey:= HKEY_CLASSES_ROOT;

             OpenKey('.cal', true);
             WriteString('', 'hyCalendar_CalendarFile');
             CloseKey;

             OpenKey('hyCalendar_CalendarFile', true);
             WriteString('', 'hyCalender �X�P�W���[���f�[�^');
             CloseKey;

             OpenKey('hyCalendar_CalendarFile\DefaultIcon', true);
             WriteString('', ParamStr(0)+ ',1');
             CloseKey;

             OpenKey('hyCalendar_CalendarFile\shell\open\command', true);
             WriteString('', ParamStr(0) + ' "%1"');
             CloseKey;

             MessageDlg('�֘A�t�����������܂����D', mtInformation, [mbOk], 0);

          except

             MessageDlg('�֘A�t���Ɏ��s���܂����D', mtError, [mbOk], 0);
          end;

          free;
     end;
end;

end.
 