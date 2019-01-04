{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$WARNINGS OFF}
//====================================================================
//  �v�����^�ݒ�R���|�[�l���g  TplSetPrinter
//
//  ����p�̃v���O�����쐬�̍ہC�v�����^�̐ݒ�(�p���T�C�Y��p��������
//  ����Ƀv�����^�̃v���p�e�B�ݒ�_�C�A���O(�v�����^�h���C�o���񋟂�
//  ��)��\�����čs���R���|�[�l���g�D
//  Ver6.0�ł́C�قƂ�ǂ̃v���p�e�B��Ǐ������p�ɂ����D
//  ���������m���ɂȂ����D
//  �܂��d�l�������������ʁC�R�[�h�����X�b�L�������C�Ǝv���Ă���D
//
//  �v���p�e�B�̐ݒ�́C[�v���p�e�B�̐ݒ�]�_�C�A���O�Őݒ肷��̂��m
//  ���ł��邪�CVer6.0�Ŋe�v���p�e�B�̏����݂��\�ɂ����D�������C�v
//  �����^�h���C�o�ɂ���ẮC[�v���p�e�B�̐ݒ�]�_�C�A���O�ɂ͑��݂�
//  �鍀�ڂ��ݒ�ł��Ȃ������肷��̂Œ��ӁD
//
//  �y�ӎ��z
//  Nifty��FDELPHI�̉�c���̔�����Delphi ML�̉ߋ����O�C�����ăl�b�g��
//  �̌f����T�C�g�̓��e���Q�l�܂��͗��p�����Ē��܂����D���ɒ�����j
//  ����̒����ɂ͂����b�ɂȂ�܂����D���ӂ��܂��D
//
//                            2005.01.29  Ver.6.06 �@
//                            Copyright (C) by Mr.XRAY
//                            http://homepage2.nifty.com/Mr_XRAY/
//====================================================================
unit plSetPrinter;

interface

uses
  Windows,SysUtils, Classes,Forms,Printers,Controls,ToolWin,WinSpool,
  StdCtrls,Math,Dialogs;

type
  TplPrtSettings=array[0..0] of Char;         //DevMode�̕ۑ��pChar�z��^�̒�`
  pplPrtSettings=^TplPrtSettings;             //���̃|�C���^�^���`
  TplPrtDialogCloseEvent = procedure(Sender: TObject; ID: Integer) of object;

  TplSetPrinter = class(TComponent)
  private
    { Private �錾}
    {ADeviec�v�����^��,ADriver�h���C�o��,APort�|�[�g����Char�^������}
    ADevice,ADriver,APort: array[0..512] of Char;
    CustomPaperName : String;               //���[�U��`�p����
    hPrtHandle      : THandle;              //�v�����^�f�o�C�X�h���C�o�̃n���h��
    DevMode         : String;               //DevMode�̕ۑ���
    ASettings       : pplPrtSettings;       //�v�����^�̐ݒ�lADevMode�̃R�s�[
    DevSize         : Integer;              //DevMode�\���̂̃T�C�Y.ASettings�ɕK�v

    FPrintersCount  : Integer;              //�C���X�g�[������Ă���v�����^��
    FPrinterName    : String;               //�|�[�g�����܂܂Ȃ��v�����^�̖���
    FPrinterNumber  : Integer;              //�v�����^�ԍ�

    FPrinterList    : TStringList;          //�v�����^���̃��X�g(�\�[�g�ς�)
    FPaperList      : TStringList;          //�p�����̃��X�g
    FBinList        : TStringList;          //�r�����̂̃��X�g

                                            //�݌v���̒l
    FdsPrinterName  : String;               //�|�[�g�����܂܂Ȃ��v�����^�̖���
    FdsOrientation  : TPrinterOrientation;  //���̕���
    FdsPaperName    : String;               //���T�C�Y����
    FdsPaperNumber  : Integer;              //�p���T�C�Y�ԍ�
    FdsBinNumber    : Integer;              //�r���ԍ�
    FdsDriverVersion: Integer;              //�h���C�o�o�[�W�����ԍ�

    FOnDialogClose  : TplPrtDialogCloseEvent;//�_�C�A���O��������̃C�x���g
    FOnPrinterChange: TNotifyEvent;          //�v�����^��ύX�������̃C�x���g

    FOnSetupDialogShow  : TNotifyEvent;
    FOnSetupDialogClose : TNotifyEvent;

    //DevSize�̕ۊǂƓǏo��
    procedure WriteADevSize(Writer: TWriter);
    procedure ReadADevSize(Reader: TReader);
    //DevMode�̕ۊǂƓǏo��
    procedure WriteADev(Writer: TWriter);
    procedure ReadADev(Reader: TReader);
    //�݌v���̒l�̕ۊǂƓǏo��
    procedure WriteDesignValues(Writer: TWriter);
    procedure ReadDesignValues(Reader: TReader);

    function CheckPaperName(UserPaperName:String; var pNo:Integer): Boolean;
    function SetUserPaper95(CustomW,CustomH: Integer): Boolean;
    function SetUserPaperNT(UserPaperName: String; CustomW,CustomH: Integer): Boolean;
    function CheckSetUserPaper(CustomW,CustomH: Integer): Boolean;
    function GetBinList: TStringList;
    function GetPaperList: TStringList;
    function GetPrinterList: TStringList;
    function GetFBinName: String;
    function GetFBinNumber: Integer;
    function GetFColorBit: Integer;
    function GetFDriverVersion: Integer;
    function GetFOrientation: TPrinterOrientation;
    function GetFPaperName: String;
    function GetFPaperNumber: Integer;
    function GetFPrintersCount: Integer;
    function GetDeviceCapsValues(const index: Integer): Integer;
    procedure SetFBinNumber(const Value: Integer);
    procedure SetFPrinterNumber(const Value: Integer);
    procedure SetFOrientation(const Value: TPrinterOrientation);
    procedure SetFPaperName(const Value: String);
    procedure SetFPaperNumber(const Value: Integer);
    procedure SetFBinName(const Value: String);
    procedure SetCopies(const Value: Integer);
    function GetCollate: Integer;
    function GetCopies: Integer;
    procedure SetCollate(const Value: Integer);
    procedure SetColor(const Value: Integer);
    function GetColor: Integer;
    function GetDuplex: Integer;
    procedure SetDuplex(const Value: Integer);
    procedure CopyDevModeToASettings;
    function GetPrinterIndexFromString(Str: String): Integer;
    function GetPrinterNameFromString(Str: String): String;
    function GetPort: String;
    function GetPrinterName: String;
    procedure ModifyAndCopy(Value :PDeviceMode);
  protected
    { Protected �錾 }
    procedure Loaded; override;
    procedure DefineProperties(Filer:TFiler);override;
    procedure SetPrinterName(Value:String);
    procedure SetPrinterInfo(Index: Integer);
    function EditPrinterInfo: Boolean;
    procedure ForSetupDialogOnShow(Sender: TObject);
    procedure ForSetupDialogOnClose(Sender: TObject);
  public
    { Public �錾 }
    constructor Create(AOwner: TComponent);override;
    destructor Destroy; override;
    //�v���p�e�B�l�̒��ɂ�DWORD�̒�`�̂��̂����邪�C�����ł�Integer�Ƃ��Ĉ����@
    property PrintersCount  : Integer             read GetFPrintersCount;
    property Port           : String              read GetPort;
    property PrinterNumber  : Integer             read FPrinterNumber       write SetFPrinterNumber;
    property Orientation    : TPrinterOrientation read GetFOrientation      write SetFOrientation;
    property PaperName      : String              read GetFPaperName        write SetFPaperName;
    property PaperNumber    : Integer             read GetFPaperNumber      write SetFPaperNumber;
    property DriverVersion  : Integer             read GetFDriverVersion;
    property BinName        : String              read GetFBinName          write SetFBinName;
    property BinNumber      : Integer             read GetFBinNumber        write SetFBinNumber;
    property ColorBit       : Integer             read GetFColorBit;
    property Color          : Integer             read GetColor             write SetColor;
    property Collate        : Integer             read GetCollate           write SetCollate;
    property Copies         : Integer             read GetCopies            write SetCopies;
    property Duplex         : Integer             read GetDuplex            write SetDuplex;
    property YResolution    : Integer index 1     read GetDeviceCapsValues;
    property XResolution    : Integer index 2     read GetDeviceCapsValues;
    property PaperWidth     : Integer index 3     read GetDeviceCapsValues;
    property PaperHeight    : Integer index 4     read GetDeviceCapsValues;
    property PageWidth      : Integer index 5     read GetDeviceCapsValues;
    property PageHeight     : Integer index 6     read GetDeviceCapsValues;
    property TopOffset      : Integer index 7     read GetDeviceCapsValues;
    property BottomOffset   : Integer index 8     read GetDeviceCapsValues;
    property LeftOffset     : Integer index 9     read GetDeviceCapsValues;
    property RightOffset    : Integer index 10    read GetDeviceCapsValues;

    property PrinterList          : TStringList read GetPrinterList;
    property PaperList            : TStringList read GetPaperList;
    property BinList              : TStringList read GetBinList;

    property dsPrinterName  :String              read FdsPrinterName;
    property dsOrientation  :TPrinterOrientation read FdsOrientation;
    property dsPaperName    :String              read FdsPaperName;
    property dsPaperNumber  :Integer             read FdsPaperNumber;
    property dsBinNumber    :Integer             read FdsBinNumber;
    property dsDriverVersion:Integer             read FdsDriverVersion;

    {���J���\�b�h}

    {�ݒ�l�̌ďo}
    procedure CallSetting;
    {�v���p�e�B�ݒ�_�C�A���O�̕\��}
    function ShowDialog : Boolean;
    {�v�����^�̐ݒ�����擾���ăR���|�Ɏ捞��}
    procedure GetPrinterInfo(GetFlag:Boolean=False);
    {���[�U��`�p���̓o�^}
    function SetUserPaper(UserPaperName:String;CustomW,CustomH:Integer):Boolean;
    {���[�U��`�p���̍폜}
    function DeleteUserPaper(UserPaperName:String): Boolean;

    {�p�����̐ݒ�(�G���[���o��Boolean�ōs��)���\�b�h}
    function SetPaperName(PaperStr: String): Boolean;
    {�p���ԍ��̐ݒ�(�G���[���o��Boolean�ōs��)���\�b�h��}
    function SetPaperNumber(Index: WORD): Boolean;
    {��������̐ݒ�(�G���[���o��Boolean�ōs��)���\�b�h}
    function SetOrientation(Orient: TPrinterOrientation): Boolean;
    {�������u���̐ݒ�(�G���[���o��Boolean�ōs��)���\�b�h}
    function SetBinName(BinStr: String): Boolean;

    function ShowSetupDialog: Boolean;
    function SaveToFile(AFile: String): Boolean;
    function LoadFromFile(AFile: String): Boolean;

  published
    property PrinterName        : String                 read GetPrinterName      write SetPrinterName;
    property OnDialogClose      : TplPrtDialogCloseEvent read FOnDialogClose      write FOnDialogClose;
    property OnPrinterChange    : TNotifyEvent           read FOnPrinterChange    write FOnPrinterChange;
    property OnSetupDialogShow  : TNotifyEvent           read FOnSetupDialogShow  write FOnSetupDialogShow;
    property OnSetupDialogClose : TNotifyEvent           read FOnSetupDialogClose write FOnSetupDialogClose;
  end;

implementation

//uses DebugWndUnit;

type
  //�v�����^���̐錾
  TPrinterInfo4Array = array[0..10000] of TPrinterInfo4;
  PPrinterInfo4Array = ^TPrinterInfo4Array;
  TPrinterInfo5Array = array[0..10000] of TPrinterInfo5;
  PPrinterInfo5Array = ^TPrinterInfo5Array;

  //�p�������X�g�p�D�p�����̕������̍ő��64}
  TPaperName  =array [0..63] of Char;
  TPaperNames =array[0..0] of TPaperName;
  TPaperNumber=array[0..0] of WORD;
  pPaperName  =^TPaperNames;
  pPaperNumber=^TPaperNumber;

  //�r�����̃��X�g�p�D�r�����̕�����̍ő��24
  TBinName  =array [0..23] of Char;
  TBinNames =array[0..0] of TBinName;
  TBinNumber=array[0..0] of WORD;
  pBinName  =^TBinNames;
  pBinNumber=^TBinNumber;

var
   PrintersInfo: array of Byte; //�v�����^���
   PrinterInfoLevel: Integer;   //�v�����^���̃��x��

{TplSetPrinter}

//====================================================================
//  �R���|�[�l���g�̏����ݒ�
//====================================================================
constructor TplSetPrinter.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     //DevMode�̃R�s�[�̒l���N���A
     ASettings:=nil;
     //DevSize��0��
     DevSize:=0;
     //�v�����^�����擾
     FPrintersCount:=GetFPrintersCount;
     FPrinterNumber:=-1;

     FPrinterList := TStringList.Create;
     FPaperList   := TStringList.Create;
     FBinList     := TStringList.Create;
end;
//====================================================================
//  Loaded����
//  �v���p�e�B�G�f�B�^��SetPrinterName�C���̌��ʁC�����̕K�v������
//  ���Ȃ���(Ver 5.3)�D
//====================================================================
procedure TplSetPrinter.Loaded;
begin
     inherited;
end;
//====================================================================
//  �R���|�[�l���g�̔j��
//  GetMem(ASettings, ...)�Ŋm�ۂ����������͍ŏI�I�ɂ����ŉ��
//====================================================================
destructor TplSetPrinter.Destroy;
begin
     FreeAndNil(FPrinterList);
     FreeAndNil(FPaperList);
     FreeAndNil(FBinList);

     DeleteObject(hPrtHandle);
     if Assigned(ASettings) then FreeMem(ASettings);
     inherited Destroy;
end;
//====================================================================
//  published�v���p�e�B�ȊO�̃v���p�e�B�̕ۊǂƓǏo��
//
//  �ȉ��̃v���p�e�B�̕ۊǂƓǏo�����s��
//  DevSize   DEVMODE�̃T�C�Y�DASettings�̓Ǐo���ɕK�v
//  ASettings �݌v����DEVMODE�̓��e�D�v�����^�̕ύX���������ꍇ��
//            �����Ɏ��߂��v���p�e�B�l�̍Č������݂�D
//  �݌v���̈ȉ��̊e�v���p�e�B
//  ASettings�ł̐ݒ�Ɏ��s�����ꍇ�ȂǁC�݌v���̒l��m��K�v����
//  �鎞�̎Q�Ɨp�D
//  dsPrinterName  : String;              �|�[�g�����܂܂Ȃ��v�����^�̖���
//  dsOrientation  : TPrinterOrientation; �������
//  dsPaperName    : String;              ���T�C�Y����
//  dsPaperNumber  : Integer;             �p���T�C�Y�ԍ�
//  dsBinNumber    : Integer;             �r���ԍ�
//  dsDriverVersion: Integer;             �h���C�o�o�[�W�����ԍ�
//====================================================================
procedure TplSetPrinter.DefineProperties(Filer:TFiler);
begin
     Inherited DefineProperties(Filer);
     //�܂�DevSize��ۊǂ���
     Filer.DefineProperty('DevDataSize',ReadADevSize,WriteADevSize,True);
     //DevSize=0�Ȃ�ۊǂ��Ǐo�����K�v�Ȃ�
     if DevSize>0 then begin
       Filer.DefineProperty('ADevData',ReadADev,WriteADev,True);
       Filer.DefineProperty('DesignValue',ReadDesignValues,WriteDesignValues,True);
     end;
end;
//====================================================================
//    DevSize�̕ۊ�
//====================================================================
procedure TplSetPrinter.WriteADevSize(Writer: TWriter);
begin
     Writer.WriteInteger(DevSize);
end;
//====================================================================
//    DevSize�̓Ǎ���
//====================================================================
procedure TplSetPrinter.ReadADevSize(Reader: TReader);
begin
     DevSize:=Reader.ReadInteger;
end;
//====================================================================
//    ASettings�̕ۊ�
//====================================================================
procedure TplSetPrinter.WriteADev(Writer: TWriter);
var
     i: Integer;
begin
     DevMode:='';
     for i:=0 to DevSize-1 do begin
       DevMode:=DevMode+IntToHex(Integer(ASettings^[i]),2);
     end;
     Writer.WriteString(DevMode);
end;
//====================================================================
//  ASettings�f�[�^�̓Ǐo��
//  �Ǐo������v�����^�̏�����
//  ���̃��[�`���́C���߂Ă��̃R���|��z�u��������DevSiez��0�Ȃ̂Ŏ�
//  ����Ȃ����C����ReadDev�̑O��PrinterName�v���p�e�B�ɒl���Z�b�g��
//  ��̂�SetPriterInfo�͎��s�����D
//
//  �Ǐo���Ɏ��s�Ƃ������Ƃ͍l�����Ȃ���(�v�����^�ԍ��擾�Ƃ���ɂ�
//  ��v�����^�̐ݒ�͍l������)�O�̂��ߎ��s������v�����^�ԍ����f�t
//  �H���g��-1�ɂ��Ă݂�
//  2004.11.5 Ver6.03
//====================================================================
procedure TplSetPrinter.ReadADev(Reader: TReader);
var
     DevByte,i: Integer;
begin
     if Assigned(ASettings) then FreeMem(ASettings);
     DevMode:=Reader.ReadString;
     DevByte:=Length(DevMode) div 2;
     GetMem(ASettings,DevByte+1);
     try
       for i:=0 to DevByte-1 do begin
         ASettings^[i]:=Char(StrToInt('$'+Copy(DevMode,1+i+i,2)));
       end;
       //�v�����^�ԍ����擾
       FPrinterNumber:=GetPrinterIndexFromString(FPrinterName);
     except
       FPrinterNumber:=-1;
     end;
     //ASettings�̒l��p���ăv�����^��ݒ�
     SetPrinterInfo(FPrinterNumber);
end;
//====================================================================
//  �݌v���̊e�v���p�e�B��Ǐo��
//  Ver6.0���O�̃o�[�W�����ł̓R�[�h����ASettings����ǂ�ł������C
//  Ver6.0�ŃX�g���[���ɕۑ�����悤�ɂ����D�O�̃o�[�W�����ɂ͂Ȃ���
//  �őO�̃o�[�W�����ō쐬�����v���W�F�N�g���ŏ��ɓǍ��ގ��ɃG���[��
//  ��������̂ŁCtry�`except�ŉ���D
//====================================================================
procedure TplSetPrinter.ReadDesignValues(Reader : TReader);
var
     Orient: Integer;
begin
     try
       Reader.ReadListBegin;
       FdsPrinterName   :=Reader.ReadString;
       Orient           :=Reader.ReadInteger;
       FdsPaperName     :=Reader.ReadString;
       FdsPaperNumber   :=Reader.ReadInteger;
       FdsBinNumber     :=Reader.ReadInteger;
       FdsDriverVersion :=Reader.ReadInteger;
       Reader.ReadListEnd;
       FdsOrientation:=TPrinterOrientation(Orient);
     except
       Abort;
     end;
end;
//====================================================================
//  �݌v���̃v���p�e�B���X�g���[���ɕۑ�
//====================================================================
procedure TplSetPrinter.WriteDesignValues(Writer: TWriter);
var
     Orient: Integer;
begin
     try
       Orient:=Integer(FdsOrientation);
       Writer.WriteListBegin;
       Writer.WriteString(FdsPrinterName);
       Writer.WriteInteger(Orient);
       Writer.WriteString(FdsPaperName);
       Writer.WriteInteger(FdsPaperNumber);
       Writer.WriteInteger(FdsBinNumber);
       Writer.WriteInteger(FdsDriverVersion);
       Writer.WriteListEnd;
     except
     end;
end;
//====================================================================
//  PrinterCount(�g�p�\�ȃv�����^��)�v���p�e�B�擾
//====================================================================
function TplSetPrinter.GetFPrintersCount: Integer;
var
     Flags     : Integer;  //EnumPrinters �ɓn���t���O
     InfoBytes : DWORD;    //�v�����^���̃o�C�g��
     nPrinters : Cardinal;
begin
     nPrinters := 0;
     //�v�����^���𓾂鏀��
     if Win32Platform = VER_PLATFORM_WIN32_NT then begin
       Flags := PRINTER_ENUM_CONNECTIONS or PRINTER_ENUM_LOCAL;
       PrinterInfoLevel := 4;
     end else begin
       Flags := PRINTER_ENUM_LOCAL;
       PrinterInfoLevel := 5;
     end;
     InfoBytes := 0;
     //�o�b�t�@���𓾂�
     EnumPrinters(Flags, nil, PrinterInfoLevel, nil, 0,InfoBytes, nPrinters);
     if InfoBytes <>0 then begin
       //�o�b�t�@�m��
       SetLength(PrintersInfo, InfoBytes);
       //�v�����^���(Level=4 or 5)���擾
       Win32Check(EnumPrinters(Flags, nil, PrinterInfoLevel,
                               Pointer(PrintersInfo),
                               InfoBytes, InfoBytes, nPrinters));
     end;
     Result:=nPrinters;
end;
//====================================================================
//  PrinterName(�v�����^��)�v���p�e�B�擾
//  Windows2k,XP�ł���΁C�����Ŏ擾���镶�����ADevice�Ɠ����D
//  Windows9X�̏ꍇ�́CADevice��APort���t�����ꂽ���́D
//====================================================================
function TplSetPrinter.GetPrinterName: String;
begin
     if FPrintersCount=0 then begin
       Result:='';
     end else begin
       Result:=GetPrinterNameFromString(FPrinterName);
     end;
end;
//====================================================================
//  PrinterName(�v�����^��)�v���p�e�B�ݒ�
//
//  �v�����^����Printer.Printers[�v�����^�ԍ�]�Ŏ擾�����l�Őݒ�\.
//  ���݂̃v�����^�Ȃ�Printer.Printers[Printer.PrinterIndex].
//  �󕶎���Ƒ��݂��Ȃ��v�����^�����w�肵���ꍇ�̓f�t�H���g�̃v����
//  �^�ɏC���D
//====================================================================
procedure TplSetPrinter.SetPrinterName(Value: String);
begin
     if FPrintersCount=0 then exit;
     if Value<>FPrinterName then begin
       FPrinterName:=Value;
       //�R���|��Reading��Loading�ł͂��̌�DevMode(ASettings)��Ǐo���K�v��
       //����̂Ńv�����^���̃Z�b�g�̂�
       if csReading in ComponentState then exit;
       if csLoading in ComponentState then exit;

       if csDesigning in ComponentState then begin
         FPrinterNumber:=GetPrinterIndexFromString(FPrinterName);
         SetPrinterInfo(FPrinterNumber);
       end else begin;
         FPrinterNumber:=GetPrinterIndexFromString(FPrinterName);
         SetPrinterInfo(FPrinterNumber);
         //OnPrinterChange�C�x���g�̓v�����^���ɕύX���������ꍇ����
         //�h���C�o�������ł��|�[�g���t���ƂȂ��̈Ⴂ�ł��C�x���g����
         if Assigned(FOnPrinterChange) then FOnPrinterChange(Self);
       end;
     end;
end;
//====================================================================
//  PrinterNumber(�v�����^�ԍ�)�v���p�e�B�ݒ�
//  ���݂��Ȃ��v�����^�ԍ��Ɓu�B���ꂽ�v�����^�v���w�肷��Ɓu�ʏ�g
//  �p����v�����^�v�ɋ����I�ɏC��
//====================================================================
procedure TplSetPrinter.SetFPrinterNumber(const Value: Integer);
begin
     if FPrintersCount=0 then exit;
     if Value<>FPrinterNumber then begin
       FPrinterNumber:=Value;
       try
         FPrinterName:=Printer.Printers[FPrinterNumber];
       except
         FPrinterNumber:=-1;
       end;
       SetPrinterInfo(FPrinterNumber);
       //OnPrinterChange�C�x���g�̓v�����^���ɕύX���������ꍇ����
       if Assigned(FOnPrinterChange) then FOnPrinterChange(Self);
     end;
end;
//====================================================================
//  �����̕����񂩂�v�����^�ԍ����擾
//  �����̃v�����^���ɂ̓|�[�g�����܂�ł��Ă�OK
//  ������Ȃ��������Ɓu�B���ꂽ�v�����^�v�̏ꍇ��-1��Ԃ�
//====================================================================
function TplSetPrinter.GetPrinterIndexFromString(Str: String): Integer;
var
     Attributes: DWORD;
     APrinterName: String;
     i: Integer;
     UpperPrinterName: String;
     UpperPrinterStr: String;
begin
     Result:=-1;

     //�o�^����Ă���v�����^�̐���������
     if Str<>'' then begin
       for i := 0 to FPrintersCount-1 do begin
         {�v�����^�̕�������擾}
         if PrinterInfoLevel = 4 then begin
           Attributes := PPrinterInfo4Array(PrintersInfo)[i].Attributes;
           if (Attributes and PRINTER_ATTRIBUTE_HIDDEN)<>0 then Continue;
           APrinterName:=PPrinterInfo4Array(PrintersInfo)[i].pPrinterName;
         end else begin
           Attributes := PPrinterInfo5Array(PrintersInfo)[i].Attributes;
           if (Attributes and PRINTER_ATTRIBUTE_HIDDEN)<>0 then Continue;
           APrinterName:=PPrinterInfo5Array(PrintersInfo)[i].pPrinterName;
         end;
         //�����̕�����ɂ��̕����񂪂���΂��̎���i�̒l��PrinterIndex
         //�����̃v�����^���ɂ̓|�[�g�������Ă���ꍇ������̂ŕ���������Ƃ��Ĕ�r����
         //OS��h���C�o�ɂ��Ⴂ���z�����邽�߂ɑ啶���ɕϊ����Ĕ�r����
         UpperPrinterStr :=AnsiUpperCase(APrinterName);
         UpperPrinterName:=AnsiUpperCase(Str);
         if AnsiPos(UpperPrinterStr,UpperPrinterName)>0 then begin
           Result := i;
           Break;
         end;
       end;
     end;
end;
//====================================================================
//  �����̕����񂩂�|�[�g�����������v�����^�����擾
//  �R�[�h�͕Ԓl���v�����^���ȊO�́CGetPrinterIndexFromStr�Ɠ���
//====================================================================
function TplSetPrinter.GetPrinterNameFromString(Str: String): String;
var
     Attributes: DWORD;
     APrinterName: String;
     i: Integer;
     UpperPrinterName: String;
     UpperPrinterStr: String;
begin
     Result:='';

     if Str<>'' then begin
       for i := 0 to FPrintersCount-1 do begin
         if PrinterInfoLevel = 4 then begin
           Attributes := PPrinterInfo4Array(PrintersInfo)[i].Attributes;
           if (Attributes and PRINTER_ATTRIBUTE_HIDDEN)<>0 then Continue;
           APrinterName:=PPrinterInfo4Array(PrintersInfo)[i].pPrinterName;
         end else begin
           Attributes := PPrinterInfo5Array(PrintersInfo)[i].Attributes;
           if (Attributes and PRINTER_ATTRIBUTE_HIDDEN)<>0 then Continue;
           APrinterName:=PPrinterInfo5Array(PrintersInfo)[i].pPrinterName;
         end;
         UpperPrinterStr :=AnsiUpperCase(APrinterName);
         UpperPrinterName:=AnsiUpperCase(Str);
         if AnsiPos(UpperPrinterStr,UpperPrinterName)>0 then begin
           Result:=APrinterName;
           Break;
         end;
       end;
     end;
end;
//====================================================================
//  Port(�|�[�g��)�v���p�e�B�擾
//====================================================================
function TplSetPrinter.GetPort: String;
begin
     if FPrintersCount=0 then begin
       Result:='';
     end else begin
       Result:=String(APort);
     end;
end;
//====================================================================
//  DriverVersion(�h���C�o�o�[�W����)�v���p�e�B�擾
//====================================================================
function TplSetPrinter.GetFDriverVersion: Integer;
var
     ADevMode : PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         Result:=ADevMode^.dmDriverVersion;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=0;
     end;
end;
//====================================================================
//  PaperName(�p����)�v���p�e�B�擾
//
//  MJ-8000C�̘A�����[�̗p�������擾�s�̂��̂�����D
//  �����̌���,DC_PAPERS�ɂ͏�񂪓����Ă��Ȃ�.�ǂ��ɂ��邩�͕s��.
//
//  DeviceCapabilitie �v�����^�f�o�C�X�h���C�o�̔\�͂��擾����Win32
//  API�֐�DC_PAPERS�ɗp���T�C�Y(����)�̔ԍ��������Ă���.
//  ���̒l��,DEVMODE�\���̂���擾�����p���ԍ�ADevMod^.dmPaperSize
//  ����v�����,���̔ԍ��ڂ�DC_PAPERNAMES���p�����ƂȂ�.
//====================================================================
function TplSetPrinter.GetFPaperName: String;
var
     Count    : Integer;
     pB       : pPaperName;
     pB2      : pPaperNumber;
     i        : integer;
     ASizeNo  : Integer;
begin
     {�Ƃ肠�������O�Ȃ��Ƃ���}
     Result:='';
     if FPrintersCount=0 then exit;
     ASizeNo:=GetFPaperNumber;

     //APort�ɐڑ����Ă���v�����^ADevice�̗p�����̐����擾
     Count:= DeviceCapabilities(ADevice,APort,DC_PAPERNAMES,nil,nil);
     if (Count=-1) or (Count=0) then exit;
     //���̐��������p�����Ɨp���ԍ��̔z��p��������pB,pB2�Ɋm��
     GetMem(pB,Count*sizeof(TPaperName));
     GetMem(pB2,Count*sizeof(TPaperNumber));
     try
       //�m�ۂ����������ɗp�����Ɨp���ԍ�������
       DeviceCapabilities(ADevice,APort,DC_PAPERNAMES,PChar(pB),nil);
       DeviceCapabilities(ADevice,APort,DC_PAPERS,PChar(pB2),nil);
       //���Ԃɗp���ԍ�����v������̂𒲂ׂ�
       for i:=0 to Count-1 do begin
         //DEVMODE�\���̂̔ԍ��ƈ�v�����烋�[�v�𔲂���
         if pB2^[i]=ASizeNo then begin
           Result:=String(pB^[i]);
           break;
         end;
       end;
     finally
       //�����������
       FreeMem(pB2);
       FreeMem(pB);
     end;
end;
//====================================================================
//  PaperName(�p����)�v���p�e�B�ݒ�
//  �p�����́C�����p���T�C�Y�ł��v�����^�h���C�o�ɂ���Ė��̂��Ⴄ��
//  �Ƃ�����̂Œ��ӁD
//====================================================================
procedure TplSetPrinter.SetFPaperName(const Value: String);
var
     PaperIndex : Integer;
begin
     if FPrintersCount=0 then exit;
     //�Y������p����������΂��̗p���ԍ����擾���Ă���Őݒ肷��
     if CheckPaperName(Value,PaperIndex) then begin
       SetFPaperNumber(PaperIndex);
     end;
end;
//====================================================================
//  PaperNumber(�p���T�C�Y�ԍ�)�v���p�e�B�擾
//  ���[�U��`�p���̏ꍇ�́C�����p�����ŃT�C�Y�������ł��v�����^�h��
//  �C�o�ɂ���Ĕԍ����Ⴄ�D
//====================================================================
function TplSetPrinter.GetFPaperNumber: Integer;
var
     ADevMode : PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         try
           Result:=ADevMode^.dmPaperSize;
         except
           CheckPaperName(CustomPaperName,Result);
         end;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=0;
     end;
end;
//====================================================================
//  PaperNumber(�p���T�C�Y�ԍ�)�v���p�e�B�ݒ�
//
//  �y���l�z
//  �e�v���p�e�B�ݒ�̃R�[�h��P�ƂŎg�p����ꍇ�́C
//  var
//  ADevice,ADriver,APort: array[0..512] of Char;
//  hPrtHandle : THandle;
//  �ƒ�`���Ă����C
//  Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//  �����s���Ă��烁�\�b�h���̃R�[�h�����s����D
//  �����̃v���p�e�B�𓯎��ɐݒ肷��ꍇ�́C�ݒ蕔���ɊY���R�[�h���
//  ������D���������̃R���|��p�̃��\�b�hCopyDev...�̕����͕s�v�D
//====================================================================
procedure TplSetPrinter.SetFPaperNumber(const Value: Integer);
var
     ADevMode : PDeviceMode;
begin
     if FPrintersCount=0 then exit;

     CallSetting;
     ADevMode:=GlobalLock(hPrtHandle);
     try
       if (ADevMode^.dmFields and dm_PaperSize)<>0 then begin
         ADevMode^.dmPaperSize:=Value;
         ADevMode^.dmFields:=ADevMode^.dmFields and not(DM_PAPERWIDTH or DM_PAPERLENGTH);
         ModifyAndCopy(ADevMode);
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //DevMode���v���p�e�B�Ƃ���ASettings�ɑ��
     //DevSize��ASettings�̒l���X�V���Ă������Ƃɂ��C���ł��ŐV
     //�̏�ԂƂȂ�C�R���|�[�l���g�Ƃ��ăA�N�Z�X�\(�ۑ��Ǐo����
     //�쓙)�ƂȂ�C�v�����^��ύX���Ă����̃v���p�e�B���L���ɂȂ�D
     CopyDevModeToASettings;
end;
//====================================================================
//  Orientation(����̕���)�v���p�e�B�擾
//====================================================================
function TplSetPrinter.GetFOrientation: TPrinterOrientation;
var
     ADevMode : PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         if ADevMode^.dmOrientation=DMORIENT_PORTRAIT then begin
           Result:=poPortrait;
         end else begin
           Result:=poLandscape;
         end;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=poPortrait;
     end;
end;
//====================================================================
//  Orientation(����̕���)�v���p�e�B�ݒ�
//  �ݒ�\�Ȓl�͈ȉ���2�̂�
//  poPortrait  �c
//  poLandscape ��
//
//  �y���l�z
//  �e�v���p�e�B�ݒ�̃R�[�h��P�ƂŎg�p����ꍇ�́C
//  var
//  ADevice,ADriver,APort: array[0..512] of Char;
//  hPrtHandle : THandle;
//  �ƒ�`���Ă����C
//  Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//  �����s���Ă��烁�\�b�h���̃R�[�h�����s����D
//  �����̃v���p�e�B�𓯎��ɐݒ肷��ꍇ�́C�ݒ蕔���ɊY���R�[�h���
//  ������D
//====================================================================
procedure TplSetPrinter.SetFOrientation(const Value: TPrinterOrientation);
var
     ADevMode : PDeviceMode;
begin
     if FPrintersCount=0 then exit;
     CallSetting;
     ADevMode:=GlobalLock(hPrtHandle);
     try
       if (ADevMode^.dmFields and dm_Orientation)<>0 then begin
         if Value=poPortrait  then ADevMode^.dmOrientation:=DMORIENT_PORTRAIT;
         if Value=poLandscape then ADevMode^.dmOrientation:=DMORIENT_LANDSCAPE;
         ModifyAndCopy(ADevMode);
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //DevMode���v���p�e�B�Ƃ���ASettings�ɑ��
     CopyDevModeToASettings;
end;
//====================================================================
//  BinName(�r����)�v���p�e�B�擾
//====================================================================
function TplSetPrinter.GetFBinName: String;
var
     Count   : Integer;
     pB      : pBinName;
     pB2     : pBinNumber;
     i       : integer;
     ABinNo  : Integer;
begin
     //�Ƃ肠�������O�Ȃ��Ƃ���
     Result:='';
     if FPrintersCount=0 then exit;
     ABinNo:=GetFBinNumber;

     //APort�ɐڑ����Ă���v�����^ADevice�̃r���̐����擾
     Count:= DeviceCapabilities(ADevice,APort,DC_BINS,nil,nil);
     if (Count=-1) or (Count=0) then exit;
     //���̐��������r�����̂ƃr���ԍ��̔z��p��������pB,pB2�Ɋm��
     GetMem(pB,Count*sizeof(TBinName));
     GetMem(pB2,Count*sizeof(TBinNumber));
     try
       //�m�ۂ����������Ƀr�����̂ƃr���ԍ�������
       DeviceCapabilities(ADevice,APort,DC_BINNAMES,PChar(pB),nil);
       DeviceCapabilities(ADevice,APort,DC_BINS,PChar(pB2),nil);
       //���ԂɃr���ԍ�����v������̂𒲂ׂ�
       for i:=0 to Count-1 do begin
         //DEVMODE�\���̂̔ԍ��ƈ�v�����烋�[�v�𔲂���
         if Integer(pB2^[i])=ABinNo then begin
           Result:=String(pB^[i]);
           break;
         end;
       end;
     finally
       //�����������
       FreeMem(pB2);
       FreeMem(pB);
     end;
end;
//====================================================================
//  BinName(�r����)�v���p�e�B�ݒ�
//====================================================================
procedure TplSetPrinter.SetFBinName(const Value: String);
var
     Count   : Integer;
     pB      : pBinName;
     pB2     : pBinNumber;
     i       : integer;
     ABinNum : Integer;
     Flag    : Boolean;
begin
     if FPrintersCount=0 then exit;
     Count:= DeviceCapabilities(ADevice,APort,DC_BINS,nil,nil);
     if (Count=-1) or (Count=0) then exit;
     Flag:=False;
     GetMem(pB,Count*sizeof(TBinName));
     GetMem(pB2,Count*sizeof(TBinNumber));
     try
       DeviceCapabilities(ADevice,APort,DC_BINNAMES,PChar(pB),nil);
       DeviceCapabilities(ADevice,APort,DC_BINS,PChar(pB2),nil);
       for i:=0 to Count-1 do begin
         if Value=String(pB^[i]) then begin
           ABinNum:=pB2^[i];
           Flag:=True;
           break;
         end;
       end;
     finally
       FreeMem(pB2);
       FreeMem(pB);
     end;
     if Flag then SetFBinNumber(ABinNum);
end;
//====================================================================
//  BinNunmbe(�r���ԍ���)�v���p�e�B�擾
//====================================================================
function TplSetPrinter.GetFBinNumber: Integer;
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         Result:=ADevMode^.dmDefaultSource;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=0;
     end;
end;
//====================================================================
//  BinNunmbe(�r���ԍ���)�v���p�e�B�ݒ�
//
//  �y���l�z
//  �e�v���p�e�B�ݒ�̃R�[�h��P�ƂŎg�p����ꍇ�́C
//  var
//  ADevice,ADriver,APort: array[0..512] of Char;
//  hPrtHandle : THandle;
//  �ƒ�`���Ă����C
//  Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//  �����s���Ă��烁�\�b�h���̃R�[�h�����s����D
//  �����̃v���p�e�B�𓯎��ɐݒ肷��ꍇ�́C�ݒ蕔���ɊY���R�[�h���
//  ������D
//====================================================================
procedure TplSetPrinter.SetFBinNumber(const Value: Integer);
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount=0 then exit;
     CallSetting;
     ADevMode:=GlobalLock(hPrtHandle);
     try
       if (ADevMode^.dmFields and dm_DefaultSource)<>0 then begin
         ADevMode^.dmDefaultSource:=Value;
         ModifyAndCopy(ADevMode);
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //DevMode���v���p�e�B�Ƃ���ASettings�ɑ��
     CopyDevModeToASettings;
end;
//====================================================================
//  ColorBit(�J���[�r�b�g��)�v���p�e�B�擾
//  ColorBit�v���p�e�B�͓Ǐo����p
//  �J���[�@�\�������Ă����m�N���ɐݒ肵�Ă����0.�J���[�@�\�Ȃ���0
//====================================================================
function TplSetPrinter.GetFColorBit: Integer;
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         if ADevMode^.dmColor=DMCOLOR_COLOR then begin
           Result:=GetDeviceCaps(Printer.Handle,BITSPIXEL)*GetDeviceCaps(Printer.Handle,PLANES);
         end else begin
           Result:=0;
         end;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=0;
     end;
end;
//====================================================================
//  Color(�J���[�E���m�N��)�v���p�e�B�擾
//  �l�͈ȉ��̂��Âꂩ
//  DMCOLOR_MONOCHROME
//  DMCOLOR_COLOR
//====================================================================
function TplSetPrinter.GetColor: Integer;
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         Result:=ADevMode^.dmColor;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=DMCOLOR_MONOCHROME;
     end;
end;
//====================================================================
//  Color(�J���[�E���m�N��)�v���p�e�B�ݒ�
//  �l�͈ȉ��̂��Âꂩ
//  DMCOLOR_MONOCHROME
//  DMCOLOR_COLOR
//
//  �y���l�z
//  �e�v���p�e�B�ݒ�̃R�[�h��P�ƂŎg�p����ꍇ�́C
//  var
//  ADevice,ADriver,APort: array[0..512] of Char;
//  hPrtHandle : THandle;
//  �ƒ�`���Ă����C
//  Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//  �����s���Ă��烁�\�b�h���̃R�[�h�����s����D
//  �����̃v���p�e�B�𓯎��ɐݒ肷��ꍇ�́C�ݒ蕔���ɊY���R�[�h���
//  ������D
//====================================================================
procedure TplSetPrinter.SetColor(const Value: Integer);
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount=0 then exit;
     CallSetting;
     ADevMode:=GlobalLock(hPrtHandle);
     try
       if (ADevMode^.dmFields and dm_Color)<>0 then begin
         ADevMode^.dmColor:=Value;
         ModifyAndCopy(ADevMode);
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //DevMode���v���p�e�B�Ƃ���ASettings�ɑ��
     CopyDevModeToASettings;
end;
//====================================================================
//  Collate(���P�ʂň��)�v���p�e�B�擾
//  �l�͈ȉ��̂��Âꂩ
//  DMCOLLATE_TRUE
//  DMCOLLATE_FALSE
//====================================================================
function TplSetPrinter.GetCollate: Integer;
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         Result:=ADevMode^.dmCollate;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=DMCOLLATE_FALSE;
     end;
end;
//====================================================================
//  Collate(���P�ʂň��)�v���p�e�B�ݒ�
//  �ݒ�\�Ȓl�͈ȉ��̂��Âꂩ
//  DMCOLLATE_TRUE
//  DMCOLLATE_FALSE
//  ���������1�̎��͐ݒ�s�D���������2�ȏ�̎��͐�Ɉ���������
//  �肵�Ă����D
//
//  �y���l�z
//  �e�v���p�e�B�ݒ�̃R�[�h��P�ƂŎg�p����ꍇ�́C
//  var
//  ADevice,ADriver,APort: array[0..512] of Char;
//  hPrtHandle : THandle;
//  �ƒ�`���Ă����C
//  Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//  �����s���Ă��烁�\�b�h���̃R�[�h�����s����D
//  �����̃v���p�e�B�𓯎��ɐݒ肷��ꍇ�́C�ݒ蕔���ɊY���R�[�h���
//  ������D
//
//  [�v���p�e�B]�̃_�C�A���O�ɂ�[���P�ʂň��]�����邪�CDevMode�ł͓�
//  ���ł��Ȃ��h���C�o������D
//  ���̂悤�ȃv�����^�ł͈���̃��[�`���ŃV�~�����[�g����K�v������D
//====================================================================
procedure TplSetPrinter.SetCollate(const Value: Integer);
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount=0 then exit;
     CallSetting;
     ADevMode:=GlobalLock(hPrtHandle);
     try
       if (ADevMode^.dmFields and dm_Collate)<>0 then begin
         if ADevMode^.dmCopies>=2 then begin
           ADevMode^.dmCollate:=Value;
           ModifyAndCopy(ADevMode);
         end;
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //DevMode���v���p�e�B�Ƃ���ASettings�ɑ��
     CopyDevModeToASettings;
end;
//====================================================================
//  Copies(�������)�v���p�e�B�擾
//====================================================================
function TplSetPrinter.GetCopies: Integer;
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         Result:=ADevMode^.dmCopies;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=1;
     end;
end;
//====================================================================
//  Copies(�������)�v���p�e�B�ݒ�
//
//  �y���l�z
//  �e�v���p�e�B�ݒ�̃R�[�h��P�ƂŎg�p����ꍇ�́C
//  var
//  ADevice,ADriver,APort: array[0..512] of Char;
//  hPrtHandle : THandle;
//  �ƒ�`���Ă����C
//  Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//  �����s���Ă��烁�\�b�h���̃R�[�h�����s����D
//  �����̃v���p�e�B�𓯎��ɐݒ肷��ꍇ�́C�ݒ蕔���ɊY���R�[�h���
//  ������D
//====================================================================
procedure TplSetPrinter.SetCopies(const Value: Integer);
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount=0 then exit;
     CallSetting;
     ADevMode:=GlobalLock(hPrtHandle);
     try
       if (ADevMode^.dmFields and dm_Copies)<>0 then begin
         ADevMode^.dmCopies:=Value;
         //���������1�̎��͕��P�ʂ̈���͖�����
         if Value<=1 then begin
           if (ADevMode^.dmFields and dm_Collate)<>0 then begin
             ADevMode^.dmCollate:=DMCOLLATE_FALSE;
           end;
         end;
         ModifyAndCopy(ADevMode);
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //DevMode���v���p�e�B�Ƃ���ASettings�ɑ��
     CopyDevModeToASettings;
end;
//====================================================================
//  Duplex(���ʈ��)�v���p�e�B�擾
//  �l�͈ȉ��̂��Âꂩ
//  DMDUP_SIMPLEX
//  DMDUP_HORIZONTAL
//  DMDUP_VERTICAL
//====================================================================
function TplSetPrinter.GetDuplex: Integer;
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount>0 then begin
       ADevMode:=GlobalLock(hPrtHandle);
       try
         Result:=ADevMode^.dmDuplex;
       finally
         GlobalUnlock(hPrtHandle);
       end;
     end else begin
       Result:=DMDUP_SIMPLEX;
     end;
end;
//====================================================================
//  Duplex(���ʈ��)�v���p�e�B�ݒ�
//
//  �y���l�z
//  �e�v���p�e�B�ݒ�̃R�[�h��P�ƂŎg�p����ꍇ�́C
//  var
//  ADevice,ADriver,APort: array[0..512] of Char;
//  hPrtHandle : THandle;
//  �ƒ�`���Ă����C
//  Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//  �����s���Ă��烁�\�b�h���̃R�[�h�����s����D
//  �����̃v���p�e�B�𓯎��ɐݒ肷��ꍇ�́C�ݒ蕔���ɊY���R�[�h���
//  ������D
//====================================================================
procedure TplSetPrinter.SetDuplex(const Value: Integer);
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount=0 then exit;
     CallSetting;
     ADevMode:=GlobalLock(hPrtHandle);
     try
       if (ADevMode^.dmFields and dm_Duplex)<>0 then begin
         ADevMode^.dmDuplex:=Value;
         ModifyAndCopy(ADevMode);
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //DevMode���v���p�e�B�Ƃ���ASettings�ɑ��
     CopyDevModeToASettings;
end;
//====================================================================
//  �ȉ��̃v���p�e�B�̎擾�p�̋��ʊ֐�
//
//  1. XResolution(�������𑜓x)�v���p�e�B
//  2. YResolution(�c�����𑜓x)�v���p�e�B
//  3. PeperWidth(�p����)�v���p�e�B
//  4. PagperHeight(�p�������E����)�v���p�e�B
//  5. PageWidth(����\��)�v���p�e�B
//  6. PageHeight(����\�����E����)�v���p�e�B
//  7. TopOffset(��[�I�t�Z�b�g)�v���p�e�B
//  8. BottomOffset(���[�I�t�Z�b�g�l)�v���p�e�B
//  9. LeftOffset(���[�I�t�Z�b�g�l)�v���p�e�B
//  10.RightOffset(�E�[�I�t�Z�b�g)�v���p�e�B
//====================================================================
function TplSetPrinter.GetDeviceCapsValues(const Index: Integer): Integer;
var
     hPrt : THandle;
begin
     if FPrintersCount>0 then begin
       OpenPrinter(ADevice,hPrt,nil);
       try
         case Index of
           //���Əc�����̉𑜓x
           1:  Result := GetDeviceCaps(Printer.Handle,LOGPIXELSX);
           2:  Result := GetDeviceCaps(Printer.Handle,LOGPIXELSY);
           //�p�����ƍ���
           3:  Result := GetDeviceCaps(Printer.Handle,PHYSICALWIDTH);
           4:  Result := GetDeviceCaps(Printer.Handle,PHYSICALHEIGHT);
           //����\�̈�̕��ƍ���
           5:  Result := GetDeviceCaps(Printer.Handle,HORZRES);
           6:  Result := GetDeviceCaps(Printer.Handle,VERTRES);
           //�㉺���E�̃I�t�Z�b�g
           7:  Result := GetDeviceCaps(Printer.Handle,PHYSICALOFFSETY);
           8:  Result := GetDeviceCaps(Printer.Handle,PHYSICALOFFSETY)+GetDeviceCaps(Printer.Handle,VERTRES);
           9:  Result := GetDeviceCaps(Printer.Handle,PHYSICALOFFSETX);
           10: Result := GetDeviceCaps(Printer.Handle,PHYSICALOFFSETX)+GetDeviceCaps(Printer.Handle,HORZRES);
         end;
       finally
         ClosePrinter(hPrt);
       end;
     end else begin
       Result:=0;
     end;
end;
//====================================================================
//  ���s���̃��[�U��`�p���쐬���\�b�h
//
//  ���̃��\�b�h���s��͂����Őݒ肵�����e���v�����^�̃f�t�H���g�̐�
//  ��l�ƂȂ�(�v�����^��ύX���Ă������Őݒ肵���p�����I�������)�D
//
//  2002.3.5 Ver. 4.1����̋@�\�@
//  UserPaperName �p�����X�g�ɕ\������p�����̕�����.���p63�����ȓ�
//  CustomW  �p���̕���0.1mm�P�ʂŎw��
//           (FORM_INFO_1�\���̂ł�1/1000�Ŏw�肷��)
//  CustomH  �p���̍�����0.1mm�P�ʂŎw��(����)
//====================================================================
function TplSetPrinter.SetUserPaper(UserPaperName: String; CustomW,
  CustomH: Integer): Boolean;
begin
     Result:=False;
     if FPrintersCount=0 then exit;

     //WindowsNT,Windows2000
     if Win32Platform=VER_PLATFORM_WIN32_NT then begin
       SetUserPaperNT(UserPaperName,CustomW,CustomH);
       Result:=CheckSetUserPaper(CustomW,CustomH);
     //Windows95,98
     end else begin
       SetUserPaper95(CustomW,CustomH);
       Result:=CheckSetUserPaper(CustomW,CustomH);
     end;
     //DevMode���v���p�e�B�Ƃ���ASettings�ɑ��
     if Result then begin
       if CustomPaperName='' then CustomPaperName:='plCustomPaper';
       CopyDevModeToASettings;
     end else begin
       CustomPaperName:='';
     end;
end;
//====================================================================
//  ���[�U��`�p���쐬�֌W���\�b�h
//
//  �p���̃T�C�Y���Ď擾���ă��[�U��`�p���̐������`�F�b�N
//  �p���������Z�b�g����Ă��Ă��T�C�Y�ݒ�Ɏ��s���Ă���ꍇ�������
//  �ŃT�C�Y�Ŋm�F�D
//====================================================================
function TplSetPrinter.CheckSetUserPaper(CustomW,CustomH: Integer): Boolean;
var
     Temp    : Integer;
     APaperW : Integer;
     APaperH : Integer;
begin
     APaperW:=Ceil(GetDeviceCapsValues(3)*254.0 /GetDeviceCapsValues(1));
     APaperH:=Ceil(GetDeviceCapsValues(4)*254.0/GetDeviceCapsValues(2));

     //����̌��������̎��͏c���t�ƂȂ�
     if GetFOrientation=poLandscape then begin
       Temp   :=APaperW;
       APaperW:=APaperH;
       APaperH:=Temp;
     end;
     //�v���X1�}�C�i�X2�ȓ��������琬���Ƃ���
     Result:=(CustomW<=(APaperW+2)) and (CustomW>=(APaperW-2)) and
             (CustomH<=(APaperH+2)) and (CustomH>=(APaperH-2));
end;
//====================================================================
//  ���[�U��`�p���̍쐬
//  Windows95,Windows98�p�̃��[�`��(WindowsME�͖��m�F)
//
//  Hewlett Packard�Ђ�DeskJet�V���[�Y�̏ꍇ[���[�U��`]�ł͂Ȃ�[�J�X
//  �^��]�ƌ������̂ƂȂ��Ă���,PaperSize��274�ƂȂ��Ă���.������
//  DEVEMODE�\���̂̊e�ϐ���
//         dmPaperSize   :=274;
//         dmPaperLength :=�p������;
//         dmPaperWidth  :=�p����;
//  �̗l�ɐݒ肵�Ă�,���ʂɐݒ肵���T�C�Y���擾�ł��Ȃ�.���݂̒��҂�
//  �m���Ǝ��͂ł͕s��(NEC��PICTY(PaperSize257)�V���[�Y������)
//  dmExtra���̏�񂪂Ȃ��Ɩ���(�\���v���O�������쐬������??)
//====================================================================
function TplSetPrinter.SetUserPaper95(CustomW,CustomH: Integer): Boolean;
var
     ADevMode : PDeviceMode;
     Mode     : DWORD;
     hPrt     : THandle;
begin
     Result:= False;
     ADevMode:=GlobalLock(hPrtHandle);
     try
       try
         //�p���ԍ��ƃT�C�Y��DEVMODE�\���̂ɃZ�b�g
         ADevMode^.dmPaperSize  :=DMPAPER_USER;
         ADevMode^.dmPaperLength:=CustomH;
         ADevMode^.dmPaperWidth :=CustomW;
         ADevMode^.dmFields     :=ADevMode^.dmFields or DM_PAPERSIZE or
                                  DM_PAPERLENGTH or DM_PAPERWIDTH;
         OpenPrinter(ADevice,hPrt,nil);
         Mode:=DM_MODIFY or DM_COPY;
         try
           DocumentProperties(Application.Handle,hPrt,ADriver,ADevMode^,ADevMode^,Mode);
         finally
           ClosePrinter(hPrt);
         end;
       except
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
end;
//====================================================================
//  ���[�U��`�p���̍쐬
//  WindowsNT4(SP6),Windows2000(SP2)�̃��[�`��
//  PowerUser(��ʃ��[�U)�ȏ�łȂ��ƃ��[�U��`�p���̍쐬�͕s��
//  ���Ƀ��[�U��`�p�����쐬�ς݂ł����Users�ł�SetForm���\(����
//  �̃v�����^�ɗp�����X�g��ǉ��\)
//====================================================================
function TplSetPrinter.SetUserPaperNT(UserPaperName: String; CustomW,
  CustomH: Integer): Boolean;
var
     ADevMode  : PDeviceMode;
     Mode      : DWORD;
     hPrt      : THandle;
     pCustName : array[0..63] of char;
     Info_1    : TFORMINFO1;
     pInfo_1   : Pointer;
     Pdef      : PRINTER_DEFAULTS;
     fgPaper   : Boolean;
     SizeNo    : Integer;
begin
     Result   := False;
     if FPrintersCount=0 then exit;

     strPCopy(pCustName,UserPaperName);
     pInfo_1 := @Info_1;

     //WindowsNT,2000�̏ꍇ�A�N�Z�X�����K�v
     //�Ǘ��҂̌����ŃT�[�o�̃v���p�e�B�ɗp������ǉ�
     ZeroMemory(@Pdef,Sizeof(PRINTER_DEFAULTS));
     Pdef.DesiredAccess := PRINTER_ALL_ACCESS;
     OpenPrinter(ADevice,hPrt,@Pdef);
     //�p�����̗L�����`�F�b�N
     fgPaper:=CheckPaperName(UserPaperName,SizeNo);
     try
       Info_1.Flags         := FORM_USER;
       Info_1.pName         := PChar(UserPaperName);
       Info_1.Size.cx       := CustomW*100;
       Info_1.Size.cy       := CustomH*100;
       Info_1.ImageableArea := Rect(0,0,CustomW*100,CustomH*100);
       //�ݒ肷�ׂ��p���T�C�Y�����݂���ꍇ�̓T�C�Y���̂ݐݒ�
       //�ݒ肷�ׂ��p���T�C�Y�����݂���ꍇ�͂�������̂܂܎g�p����l����������
       if fgPaper then begin
         SetForm(hPrt,pCustName,1,pInfo_1);
       //�ݒ肷�ׂ��p���T�C�Y�����݂��Ȃ��ꍇ�͗p�����쐬
       end else begin
         //��x�p���T�C�Y���͈͊O�Őݒ肷��Ƒ��݂���p�����ł����X�g�ɏo�Ȃ�
         //������SetForm�����s����ƕ\�������
         //AddForm��SetForm�����˂Ă���炵��
         if AddForm(hPrt,1,pInfo_1)=False then begin
           SetForm(hPrt,pCustName,1,pInfo_1);
         end;
       end;
     finally
       ClosePrinter(hPrt);
     end;

     //���݂̃v�����^�ɗp������ǉ�
     ADevMode:= GlobalLock(hPrtHandle);
     strPCopy(ADevMode^.dmFormName,UserPaperName);

     //�ǉ����ꂽ�p�����̔ԍ���SizeNo�Ɏ擾
     Result:=CheckPaperName(UserPaperName,SizeNo);
     if Result=False then SizeNo:=DMPAPER_USER;
     try
       try
         //�p���ԍ��ƃT�C�Y��DEVMODE�\���̂ɃZ�b�g
         //dmPaperSize�����̎��_�ŃZ�b�g����Ȃ��h���C�o����������(�쐬���[�v
         //�����^�̐ݒ�]�_�C�A���O�̗p�������ɍ쐬�����p�������I����ԂɂɂȂ�
         //�Ȃ�)�CdmFields�̃t���O��S�ĊO��(�Y�������̃R�[�h���폜)��OK�̂悤
         //�ł���D
         ADevMode^.dmPaperSize  :=SizeNo;
         ADevMode^.dmPaperLength:=CustomH;
         ADevMode^.dmPaperWidth :=CustomW;
         CustomPaperName  :=UserPaperName;
         OpenPrinter(ADevice,hPrt,nil);
         Mode:=DM_MODIFY or DM_COPY;
         try
           DocumentProperties(Application.Handle,hPrt,ADriver,ADevMode^,ADevMode^,Mode);
         finally
           ClosePrinter(hPrt);
         end;
       except
         Result:=False;
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //AddForm�Œǉ����Ă�,���X�g�Ō����Ȃ��p�����͍폜���Ă���
     if Result=False then DeleteUserPaper(UserPaperName);
end;
//====================================================================
//  ���[�U��`�p���̍폜
//  Administrators�łȂ��ƍ폜�s�̗l�ł���
//  Windows96,98�̏ꍇ�͏��True(���ۂɍ폜����킯�ł͂Ȃ�),��`�p��
//  ���Ȃ��ꍇ��True
//====================================================================
function TplSetPrinter.DeleteUserPaper(UserPaperName: String): Boolean;
var
     hPrt    : THandle;
     Pdef    : PRINTER_DEFAULTS;
     fgPaper : Boolean;
     SizeNo  : Integer;
begin
     if FPrintersCount=0 then exit;
     if Win32Platform=VER_PLATFORM_WIN32_NT then begin
       Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
       {WindowsNT,2000�̏ꍇ�A�N�Z�X�����K�v}
       ZeroMemory(@Pdef,Sizeof(PRINTER_DEFAULTS));
       Pdef.DesiredAccess := PRINTER_ALL_ACCESS;

       OpenPrinter(ADevice,hPrt,@Pdef);
       {�p�����̗L�����`�F�b�N}
       fgPaper:=CheckPaperName(UserPaperName,SizeNo);
       try
         if fgPaper then begin
           Result:=DeleteForm(hPrt,PChar(UserPaperName));
         end else begin
           Result:=True;
         end;
       finally
         ClosePrinter(hPrt);
       end;
       Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     end else begin
       Result:=True;
     end;
     if Result then CustomPaperName:='';
end;
//====================================================================
//  ���[�U��`�p���쐬�֌W���\�b�h
//
//  �w��̗p���������邩�̃`�F�b�N
//  SetCustPape�Ŏg�p
//====================================================================
function TplSetPrinter.CheckPaperName(UserPaperName:String; var pNo:Integer): Boolean;
var
      Count,i  : Integer;
      pB       : pPaperName;
      pB2      : pPaperNumber;
      fgPaperName: String;
begin
     Result:=False;
     if FPrintersCount=0 then exit;

     pNo:=-1;
     {�p����}
     fgPaperName:=UserPaperName;
     {APort�ɐڑ����Ă���v�����^ADevice�̗p�����̐����擾}
     Count:= DeviceCapabilities(ADevice,APort,DC_PAPERNAMES,nil,nil);
     {���̐��������p�����Ɨp���ԍ��̔z��p��������pB,pB2�Ɋm��}
     GetMem(pB,Count*sizeof(TPaperName));
     GetMem(pB2,Count*sizeof(TPaperNumber));
     try
       {�m�ۂ����������ɗp�����Ɨp���ԍ�������}
       DeviceCapabilities(ADevice,APort,DC_PAPERNAMES,PChar(pB),nil);
       DeviceCapabilities(ADevice,APort,DC_PAPERS,PChar(pB2),nil);
       {���Ԃɗp��������v������̂𒲂ׂ�}
       for i:=0 to Count-1 do begin
         if fgPaperName=String(pB^[i]) then begin
           Result:=True;
           pNo:=pB2^[i];
           break;
         end;
       end;
     finally
       {�����������}
       FreeMem(pB2);
       FreeMem(pB);
     end;
end;
//====================================================================
//  PritnerList(�Ǐo����p)�v���p�e�B�p
//  �v�����^���ꗗ���擾�D���X�g�̓v�����^�ԍ����ł͂Ȃ�ABC��
//  �v�����^���ꗗ��FPrinterNameList�Ƀv�����^�ԍ����ɃZ�b�g����
//====================================================================
function TplSetPrinter.GetPrinterList: TStringList;
var
     i: Integer;
begin
     //���X�g�����
     FPrinterList.Clear;
     FPrinterList.Sort;

     if FPrintersCount>0 then begin
       {�ꗗ�ɒǉ�}
       for i := 0 to FPrintersCount-1 do begin
         if PrinterInfoLevel = 4 then begin
           if (PPrinterInfo4Array(PrintersInfo)[i].Attributes and
                                  PRINTER_ATTRIBUTE_HIDDEN) = 0 then begin
             FPrinterList.Add(PPrinterInfo4Array(PrintersInfo)[i].pPrinterName);
           end;
         end else begin
           if (PPrinterInfo5Array(PrintersInfo)[i].Attributes and
                                  PRINTER_ATTRIBUTE_HIDDEN) = 0 then begin
             FPrinterList.Add(PPrinterInfo5Array(PrintersInfo)[i].pPrinterName);
           end;
         end;
       end;
     end;
     Result:=FPrinterList;
end;
//====================================================================
//  PaperList(�Ǐo����p)�v���p�e�B�p
//  �p���T�C�Y�ꗗ���擾
//====================================================================
function TplSetPrinter.GetPaperList: TStringList;
var
     Count: Integer;
     pB: pPaperName;
     i: integer;
begin
     //���X�g����ɂ���
     FPaperList.Clear;
     //APort�ɐڑ����Ă���v�����^ADevice�̗p�����̐����擾
     Count:= DeviceCapabilities(ADevice,APort,DC_PAPERNAMES,nil,nil);
     if Count>0 then begin
       //���̐��������p�����Ɨp���ԍ��̔z��p��������pB�Ɋm��
       GetMem(pB,Count*sizeof(TPaperName));
       try
         //�m�ۂ����������ɗp����������
         DeviceCapabilities(ADevice,APort,DC_PAPERNAMES,PChar(pB),nil);
         for i:=0 to Count-1 do begin
           FPaperList.Add(String(pB^[i]));
         end;
       finally
         FreeMem(pB);
       end;
     end;
     Result:=FPaperList;
end;
//====================================================================
//  BinList(�Ǐo����p)�v���p�e�B�p
//  �������u�̈ꗗ���擾
//====================================================================
function TplSetPrinter.GetBinList: TStringList;
var
     Count : Integer;
     pB    : pBinName;
     i     : integer;
begin
     //���X�g����ɂ���
     FBinList.Clear;
     //APort�ɐڑ����Ă���v�����^ADevice�̃r���̐����擾
     Count:= DeviceCapabilities(ADevice,APort,DC_BINS,nil,nil);
     if (Count>0) then begin
       //���̐��������r�����̂ƃr���ԍ��̔z��p��������pB,pB2�Ɋm��
       GetMem(pB,Count*sizeof(TBinName));
       try
         //�m�ۂ����������Ƀr�����̂ƃr���ԍ�������
         DeviceCapabilities(ADevice,APort,DC_BINNAMES,PChar(pB),nil);
         //���ԂɃr�����̂̕���������X�g�ɑ��
         //���̕�����͓����p���ł��h���C�o�ɂ���ĈႤ�ꍇ������
         for i:=0 to Count-1 do begin
           FBinList.Add(String(pB^[i]));
         end;
       finally
         {�����������}
         FreeMem(pB);
       end;
     end;
     Result:=FBinList;
end;
//====================================================================
//  [�v�����^�̐ݒ�]�_�C�A���O(TPrinterSetupDialog)��\��
//  �ʃR���|�[�l���g�ł͂Ȃ��C�����Ő�������悤�ɂ����D
//  [OK]�ŏI������Ɛݒ肵���v�����^�̏����R���|�̏��ɒu���D
//====================================================================
function TplSetPrinter.ShowSetupDialog: Boolean;
var
     ADialog : TPrinterSetupDialog;
begin
     ADialog:=TPrinterSetupDialog.Create(Self);
     ADialog.OnShow :=ForSetupDialogOnShow;
     ADialog.OnClose:=ForSetupDialogOnClose;
     ADialog.Name   :=Self.Name+'SetupDialog';
     try
       Result:=ADialog.Execute;
       if Result then GetPrinterInfo;
     finally
       ADialog.Free;
     end;
end;
//====================================================================
//  [�v�����^�̐ݒ�]�_�C�A���O�\��ShowSetupDialog���\�b�h�p
//  �_�C�A���O��OnShow�C�x���g
//====================================================================
procedure TplSetPrinter.ForSetupDialogOnShow(Sender: TObject);
begin
     if Assigned(FOnSetupDialogShow) then FOnSetupDialogShow(Sender);
end;
//====================================================================
//  [�v�����^�̐ݒ�]�_�C�A���O�\��ShowSetupDialog���\�b�h�p
//  �_�C�A���O��OnClose�C�x���g
//====================================================================
procedure TplSetPrinter.ForSetupDialogOnClose(Sender: TObject);
begin
     if Assigned(FOnSetupDialogClose) then FOnSetupDialogClose(Sender);
end;
//====================================================================
//  �R���|�[�l���g���w��t�@�C���ɕۑ�
//====================================================================
function TplSetPrinter.SaveToFile(AFile: String): Boolean;
var
     AStream: TFileStream;
begin
     AStream:=TFileStream.Create(AFile,fmCreate or fmShareDenyNone);
     try
       try
         AStream.WriteComponent(Self);
         Result:=True;
       except
         Result:=False;
       end;
     finally
       AStream.Free;
     end;
end;
//====================================================================
//  �R���|�[�l���g���t�@�C������Ǐo��
//  ���̃��\�b�h���s��́C���̓Ǐo�������e���R���|�[�l���g�̓��e�D
//====================================================================
function TplSetPrinter.LoadFromFile(AFile: String): Boolean;
var
     AStream: TFileStream;
begin
     Result:=False;
     //�Y���t�@�C�����Ȃ����False�ŏI��
     if not FileExists(AFile) then exit;
     AStream:=TFileStream.Create(AFile,fmOpenRead or fmShareDenyNone);
     try
       try
         //�ȑO��TComponent(Self):=AStream.ReadComponent(Self)�̌`�����g�p
         AStream.ReadComponent(Self);
         Result:=True;
       except
         Result:=False;
       end;
     finally
       AStream.Free;
     end;
end;
//====================================================================
//   ���݂̃v�����^�̏��擾  ���J���\�b�h
//   NkPrinter�ȂǑ��̎�i�ɂ��v�����^�̐ݒ�𗘗p���邽�߂̋@�\�D
//   �ꉞ�f�t�H���g�̒l�̎擾���\�ɂ��Ă������D
//   ���̃��\�b�h���s��́C�擾�����v���p�e�B���f�t�H���g�ƂȂ�C�v��
//   ���^���܂��̓v�����^�ԍ��Ńv�����^���w�肷��ƁC���̃v���p�e�B��
//   �l(DevMode�̓��e)���}�[�W����D�v�����^�h���C�o�ɂ���Ă̓}�[�W��
//   ��������Ƃ͌���Ȃ��D
//
//
//
//   ADevice    �v�����^���@�@�@�@�@�@�@�@�@
//   ADriver    �h���C�o��
//   APort      �|�[�g��
//   hPrtHandle �v�����^�f�o�C�X�h���C�o�̃n���h��
//
//   GetFlag
//   True  �v�����^�̃f�t�H���g�l
//   False �v�����^�̌��݂̐ݒ�l
//
//   �y���l�z
//   �v�����^�̏��擾��3�s�̈Ӗ�
//
//   (1) Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//   (2) Printer.SetPrinter(ADevice,ADriver,APort,0);
//   (3)Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//
//   (1) ������GetPrinter�Ŏ擾�ł���ADevMode�͕ύX�O�̒l
//       ADevec,ADriver�͕ύX��̒l
//   (2) SetPrinter��hPrtHandle��0���w�肷��ƕύX���ADevMode�l����
//       ���ł���
//   (3) SetPrinter�Ŏ擾�����͂���AdevMode�����ۂɎ擾�ł���
//
//   ���̈�A�̓����TPrinter�I�u�W�F�N�g�̎d�l
//====================================================================
procedure TplSetPrinter.GetPrinterInfo(GetFlag:Boolean=False);
var
     ADevMode: PDeviceMode;
begin
     if FPrintersCount=0 then exit;
     //�v�����^�ԍ��Ɩ��O���擾
     FPrinterName  :=Printer.Printers[Printer.PrinterIndex];
     FPrinterNumber:=GetPrinterIndexFromString(FPrinterName);
     if GetFlag then begin
       //���݂̃v�����^�ŏ�����
       Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
       Printer.SetPrinter(ADevice,ADriver,APort,0);
       Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
     end else begin
       Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
     end;

     ADevMode:=GlobalLock(hPrtHandle);
     try
       ModifyAndCopy(ADevMode);
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //DevMode���v���p�e�B�Ƃ���ASettings�ɑ��
     CopyDevModeToASettings;
end;
//====================================================================
//  �v�����^�̐ݒ�(DevMode���}�[�W����)  ����J���\�b�h
//  �{�R���|�̊j�S��
//
//  Win32API�̐����ł�DevSize�̎擾��DocumentProperties��Mode=0 �ɂ�
//  ��L�ڂ����邪�C���݂̂Ƃ���GlobalSize�Ŏ擾����T�C�Y�ƕω��Ȃ�
//  �̂ł�������g�p���Ă���D���̃v���p�e�B�擾���\�b�h������Ɠ���
//  �R�[�h�Ƃ��Ă���D
//  �v�����^�h���C�o�ɂ���Ă̓}�[�W����������Ƃ͌���Ȃ��D
//
//  ADevice    �v�����^���@�@�@�@�@�@�@�@
//  ADriver    �h���C�o��
//  APort      �|�[�g��
//  hPrtHandle �v�����^�h���C�o�̃n���h��
//====================================================================
procedure TplSetPrinter.SetPrinterInfo(Index: Integer);
var
     hPrt       : THandle;
     ADevMode   : PDeviceMode;
     NewDevSize : Integer;
     Mode       : DWORD;
begin
     if FPrintersCount=0 then exit;

     //�v�����^�ԍ��̃v�����^�̃f�t�H���g�l�����߂�
     //���̃f�t�H���g�l�ƃ}�[�W����
     Printer.PrinterIndex:=Index;
     FPrinterNumber:=Printer.PrinterIndex;
     FPrinterName  :=Printer.Printers[FPrinterNumber];
     Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
     Printer.SetPrinter(ADevice,ADriver,APort,0);
     Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);

     //�n���h��hPrtHandle�����b�N,�ŏ��̃o�C�g�̃|�C���^ADevMode���擾
     ADevMode   :=GlobalLock(hPrtHandle);
     NewDevSize :=GlobalSize(hPrtHandle);
     Mode       :=DM_MODIFY or DM_COPY;

     try
       //ASettings�l�������DevMode�����R�s�[
       //�݌v����ASettings�̒l�͍ŏ��ɃR���|��z�u�������͋�ŁC���̌�
       //��CopyDevModeToStettings�ŃX�g���[���ɕۑ������D
       //�݌v���Ƀv�����^��ύX����ƃX�g���[���ɕۑ����ꂽ�O�̃v�����^
       //�̓��e�ƂȂ��Ă��āC���������̌��CopyDev...�Œu�����D
       //���s���͐݌v���̒l�������Ă��邪�C�v���p�e�B��ύX����ƕύX���
       //���e�ƂȂ��Ă���
       //�A�N�Z�X�ᔽ�����h�~(TAK����T���N�X Ver5.1�ŏC���D�w�E����Ă�
       //��Ζ��炩�Ȃ̂ł����C�Ȃ��Ȃ��C�Â��Ȃ����̂ł�)
       if Assigned(ASettings) then begin
         if NewDevSize>DevSize then begin
           System.Move(ASettings^,ADevMode^,DevSize);
         end else begin
           System.Move(ASettings^,ADevMode^,NewDevSize);
         end;
         Application.ProcessMessages;
       end;
       OpenPrinter(ADevice,hPrt,nil);
       try
         //�v�����^�ύX���[�v�����^�̐ݒ�]�_�C�A���O�̕\���̖��
         //Windows2k,XP�̏ꍇ(Application.Handle,...)�łȂ��ƃ_�C�A���O�̕\��
         //���X�V����Ȃ��h���C�o������([�v���p�e�B]�Ŋm�F����Ɛݒ�͔��f��
         //��Ă���)�D�܂��C(Application.Handle,hPrt,...)�̏ꍇ�C�v�����^�̐�
         //���A���e�X�g�̌��ʂŁC�܂�ɗ�O����������D�������ʂł́C����̃v
         //�����^�̏ꍇ�ɔ������Ă���(�e�X�g����PC�ɂ���Ă��Ⴄ)�D�ēx���s��
         //��Ɣ������Ȃ��D�R���p�C�����s�̍ŏ��̂ݔ������Ă���D�����s���D
         //(Application.Handle,0,...)�ł͔������Ȃ��D
         //����CWindows9X�ł́C���̃R�[�h�ł�[�v�����^��������܂���]�̃G��
         //�[���������Ă��܂��D�����ňȉ��̗l�ɏ����𕪂��Ă���D
         //�Ȃ��C(0,hPrt,...)�ł͂قƂ�ǃ_�C�A���O�̕\���͍X�V����Ȃ��D
         //(Application.Handle,0,,,,)�ł����Ă�OpenPrinter�����s���Ȃ��ƁC���
         //��_�C�A���O�̕\�����X�V����Ȃ��h���C�o������D
         try
           if Win32Platform=VER_PLATFORM_WIN32_NT then begin
             DocumentProperties(Application.Handle,0,ADriver,ADevMode^,ADevMode^,Mode);
           end else begin
             DocumentProperties(Application.Handle,hPrt,ADriver,ADevMode^,ADevMode^,Mode);
           end;
         except
           //Assert(ID=0);
           //���s�����狭���I�Ƀ}�[�W�𒆎~
           //���҂̒����͈͂ł͂����ɂ�����̂͌��݂̂Ƃ���Ȃ��D
         end;
       finally
         ClosePrinter(hPrt);
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //�݌v���ɂ�DevMode��ASettings�ɃR�s�[
     if csDesigning in ComponentState then CopyDevModeToASettings;
end;
//====================================================================
//  �R���|�̃v�����^�̃v���p�e�B�ݒ�A���O��\������
//  ���J���\�b�hShowDialog�Ŏg�p
//
//  �����Ŋe��̐ݒ���s��.
//  �݌v���͂����Őݒ肵���v���p�e�B���X�g���[���ɕۑ�
//  (���ꂪ���̃R���|�̔���ł������̂���...�@Ver6.0�łقƂ�ǂ̃v��
//  �p�e�B�������݉\�ɂ��Ă��܂����̂ŁC�Ӗ����Ȃ��Ȃ��Ă��܂�����
//  �����m��Ȃ����C�h���C�o�ŗL�̃v���p�e�B�̐ݒ�͂��̃_�C�A���O��
//  �Ȃ��Ɛݒ�ł��Ȃ�)�D
//  ���s���͈ꎞ�I�ȕύX��v���p�e�B��Ini�t�@�C�����ւ̕ۑ��Ɏg�p
//
//  [OK]�ŕ����True���C[�L�����Z��]�ŕ����False��Ԃ�
//
//  �y���l�z
//  ���̃v�����^�̃v���p�e�B�ݒ�_�C�A���O�̃R�[�h��P�ƂŎg�p�����
//  ���́C
//  var
//  ADevice,ADriver,APort: array[0..512] of Char;
//  hPrtHandle : THandle;
//  �ƒ�`���Ă����C
//  Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
//  �����s���Ă��烁�\�b�h���̃R�[�h�����s����D
//
//  Ver6.04
//  Ver6.00�̎��̏C���Ńe�X�g�̂��ߊO���Ă����R�[�h�����ɖ߂���UP����
//  �����̂��C���D���ꂪ�Ȃ��ƁC�v�����^�̌��݂̐ݒ肪�_�C�A���O�ɔ�
//  �f���Ȃ��D
//====================================================================
function TplSetPrinter.EditPrinterInfo: Boolean;
var
     hPrt     : THandle;
     IDNo     : Integer;
     Mode     : DWORD;
     ADevMode : PDeviceMode;
     ADevSize : Integer;
begin
     if FPrintersCount=0 then exit;

     {�v�����^�ԍ�FPrinterNumber�̃f�t�H���g�l�����߂�}
     Printer.PrinterIndex:=FPrinterNumber;
     Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);
     //GetPrinter�����ł��܂����삷��h���C�o�����邪}
     //�ȉ��̗l�ɂ���DevMode���撼���Ă���}
     Printer.SetPrinter(ADevice,ADriver,APort,0);
     Printer.GetPrinter(ADevice,ADriver,APort,hPrtHandle);

     ADevMode:=GlobalLock(hPrtHandle);
     try
       ADevSize:=GlobalSize(hPrtHandle);
       //*.DFM����Ǐo����DEVMODE�\���̂̃R�s�[��ADevMode�փR�s�[
       if Assigned(ASettings) then begin
         System.Move(ASettings^,ADevMode^,ADevSize);
       end;
       Mode :=DM_PROMPT or DM_MODIFY or DM_COPY;
       OpenPrinter(ADevice,hPrt,nil);
       try
         IDNo:=DocumentProperties(Application.Handle,hPrt,ADevice,ADevMode^,ADevMode^,Mode);
       finally
         ClosePrinter(hPrt);
       end;
     finally
       GlobalUnlock(hPrtHandle);
     end;

     if IDNo=IDOK then begin
       Printer.SetPrinter(ADevice,ADriver,APort,hPrtHandle);
       //DevMode���v���p�e�B�Ƃ���ASettings�ɑ��
       CopyDevModeToASettings;
     end;

     Result:=IDNo=IDOK;
     //[�v�����^�̃v���p�e�B]�̃_�C�A���O���������OnDialogClose�C�x���g����
     //[OK]�ŕ�������IDNo=IDOK
     //[�L�����Z��]�ŕ�������IDNo=IDCANCEL
     //Ver6.0��EditPrinterInof��_���l��Ԃ��֐��ɂ����̂ňӖ����Ȃ��Ȃ���(?)
     if Assigned(FOnDialogClose) then begin
       FOnDialogClose(Self,IDNo);
     end;
end;
//====================================================================
//  ���݂�DevMode�̒l��ASettings�ɃR�s�[
//  DevSize��ASettings�͖{�R���|�̓Ǐ������p�ϐ��D
//  ����ASettings�̗��p�����̃R���|�̔���̂͂��Ȃ̂ł��邪�CVer6.0��
//  �قƂ�ǂ̃v���p�e�B�������݉\�ɂ��Ă��܂����̂ŁC�Ӗ����Ȃ���
//  ���Ă��܂����̂����m��Ȃ��D
//====================================================================
procedure TplSetPrinter.CopyDevModeToASettings;
var
     ADevMode : PDeviceMode;
begin
     //ASettings��DevSize�̒l�͌��݂�hPrtHandle����Ď擾
     if Assigned(ASettings) then FreeMem(ASettings);
     ADevMode:=GlobalLock(hPrtHandle);
     DevSize :=GlobalSize(hPrtHandle);
     try
       GetMem(ASettings,DevSize);
       System.Move(ADevMode^,ASettings^,DevSize);
       Application.ProcessMessages;
     finally
       GlobalUnlock(hPrtHandle);
     end;
     if csDesigning in ComponentState then begin
       FdsPrinterName   := FPrinterName;
       FdsOrientation   := GetFOrientation;
       FdsPaperName     := GetFPaperName;
       FdsPaperNumber   := GetFPaperNumber;
       FdsBinNumber     := GetFBinNumber;
       FdsDriverVersion := GetFDriverVersion;
     end;
end;
//====================================================================
//  DocumentProperties�p�̋��ʃ��\�b�h
//====================================================================
procedure TplSetPrinter.ModifyAndCopy(Value :PDeviceMode);
var
     hPrt : THandle;
     Mode : DWORD;
begin
     OpenPrinter(ADevice,hPrt,nil);
     Mode:=DM_MODIFY or DM_COPY;
     try
       DocumentProperties(Application.Handle,hPrt,ADriver,Value^,Value^,Mode);
     finally
       ClosePrinter(hPrt);
     end;
end;
//====================================================================
//  �p�����̐ݒ�̌��J(����E�Q�l�p)���\�b�h
//  �����̗p�������Z�b�g����Ȃ��ꍇ��False��Ԃ�
//====================================================================
function TplSetPrinter.SetPaperName(PaperStr: String): Boolean;
begin
     SetFPaperName(PaperStr);
     Result:=PaperStr=GetFPaperName;
end;
//====================================================================
//  �p���ԍ��ŗp����ݒ肷����J(����E�Q�l�p)���\�b�h
//  �p���ԍ�(DM_PAPER_A4�Ȃǂ̒萔)�ŗp���T�C�Y��ݒ肷��
//  �����Ŏw�肷��p���ԍ��̗p�����Ȃ��ꍇ��False��Ԃ�
//====================================================================
function TplSetPrinter.SetPaperNumber(Index: WORD): Boolean;
begin
     SetFPaperNumber(Index);
     Result:=Index=GetFPaperNumber;
end;
//====================================================================
//  ���������ݒ肷����J(����E�Q�l�p)���\�b�h
//  ���ۂɂ͗p���̕����́CPrinter.Orientation:=poLandscape; �Ƃ����R
//  �[�h�Őݒ�\�Ȃ̂ŁC���̃��\�b�h�͕s�v�D
//  ����������T�|�[�g���Ă��Ȃ��ꍇ��False��Ԃ�
//====================================================================
function TplSetPrinter.SetOrientation(Orient: TPrinterOrientation): Boolean;
begin
     SetFOrientation(Orient);
     Result:=Orient=GetFOrientation;
end;
//====================================================================
//  �������u��(�r������)��ݒ肷����J(����E�Q�l�p)���\�b�h
//  BinStr�Ŏw�肷��r�����u���ɐݒ肷��
//  �T�|�[�g����Ă��Ȃ��r�����̂�^�����False��Ԃ�
//====================================================================
function TplSetPrinter.SetBinName(BinStr: String): Boolean;
begin
     SetFBinName(BinStr);
     Result:=BinStr=GetFBinName;
end;
//====================================================================
//  �v�����^�̍Đݒ���s�����J���\�b�h
//
//  �����̖{�R���|�𗘗p���鎞�ɁC�����I�ɐ݌v���̐ݒ�ɂ���ꍇ�Ɏg
//  �p����D�v���p�e�B��ύX���Ă���ƕύX��̓��e�Őݒ肳���D
//  NkPrinter��N�C�b�N���|�[�g��ApplySettings���\�b�h�Ɠ��l�̋@�\�D
//  ���̓������O�ɂ��Ȃ���������!?
//  ���̃R���|���쐬���鎞��NkPrinter�Ȃǂ��悭���ׂȂ���������ł��D
//====================================================================
procedure TplSetPrinter.CallSetting;
begin
     SetPrinterInfo(FPrinterNumber);
end;
//====================================================================
//  �v�����^�̃v���p�e�B�ݒ�_�C�A���O��\��.���J���\�b�h
//  [OK]�ŕ����True���C[�L�����Z��]�ŕ����False��Ԃ�
//====================================================================
function TplSetPrinter.ShowDialog: Boolean;
begin
     Result:=EditPrinterInfo;
end;
//====================================================================
//   �R�[�h�I��
//====================================================================
end.

