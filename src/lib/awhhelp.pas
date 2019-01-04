//---------------------------------------------------------------------------------
// Copyright (C) 2001-2002 by Junichi Sakamoto <adelieworks@yahoo.co.jp>
// Ver.2.0
//
// �{�t�@�C���̒��쌠�͍�{���ꂪ�ێ����܂��B
// �{�t�@�C����,���ł̗L���Ɋւ�炸,����҂ɖ��f�œ]�ڂ��邱�Ƃ��ւ��܂��B
// (��؂̓]�ڂ��ւ�����ł͂���܂���)
// �{�t�@�C���̎g�p���琶���邢���Ȃ��Q�E���Q���A����҂͈�ؐӔC�𕉂��܂���B
// �{�t�@�C�������̂܂܂��邢�͉��ł̏�g�p���Đ������ꂽ���s�\�ȃo�C�i���t�@�C��
// �ɑ΂��āA����҂͒��쌠���咣���܂���B�{�t�@�C�������ł̏�g�p���邱�Ƃɑ΂���
// ����҂ً͈c��\�����Ă܂���B
// �{�t�@�C���̗��p�́A��L�A���ɉ�������A���p�E�񏤗p���킸�\�ł��B
//
//---------------------------------------------------------------------------------
// ���ŗ���
// Ver.2.0
//   1) �f�X�g���N�^��HH_UNINITIALIZE�t�@���N�V�������Ăяo���̂��폜(WinXP�Ή�)
//   2) �݌v����OnHelp�C�x���g���g���b�v���Ȃ��悤�C��(IDE�I�����̃A�v���P�[�V��
//      ���G���[�Ή�)
//   3) AutoInstall�v���p�e�B��ǉ��AOnHelp�C�x���g�n���h���������ŃZ�b�g�A�b�v
//      ���邩���Ȃ�����I�ׂ�悤�ɉ��ǁB 
//
// Ver.1.0
//---------------------------------------------------------------------------------

unit awhhelp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ActiveX;

type

  ///////////////////////////////////////////////
  // HTML�w���v�T�|�[�g�R���|�[�l���g
  THTMLHelp = class(TComponent)
    protected
      FCookie          : Dword;
      FPopupPos        : TPoint;
      FAutoInstall     : Boolean;
      procedure InitHtmlHelp();
    public
      constructor Create(AOwner : TComponent); override;
      function    OnApplicationHelp(Command:Word; Data:longint; var CallHelp:boolean):boolean;
      procedure   Loaded; override;
    published
      property AutoInstall: Boolean read FAutoInstall write FAutoInstall default True;
  end;

  procedure Register;

implementation

type

  ///////////////////////////////////////////////
  // �|�b�v�A�b�v�\���p�����[�^�\����
  HH_POPUP = record
    cbStruct      : integer;  // sizeof this structure
    hinst         : THandle;  // instance handle for string resource
    idString      : UINT;     // string resource id, or text id if pszFile is specified in HtmlHelp call
    pszText       : LPCTSTR;  // used if idString is zero
    pt            : TPoint;   // top center of popup window
    clrForeground : COLORREF; // use -1 for default
    clrBackground : COLORREF; // use -1 for default
    rcMargins     : TRect;    // amount of space between edges of window and text, -1 for each member to ignore
    pszFont       : LPCTSTR;  // facename, point size, char set, BOLD ITALIC UNDERLINE
  end;

  ///////////////////////////////////////////////
  // �G���[���\����
  HH_LAST_ERROR = record
    cbStruct    : integer;
    hr          : HRESULT;
    description : PWideChar;
  end;

  ///////////////////////////////////////////////
  // HtmlHelp API �v���g�^�C�v
  function HtmlHelp(
    hwndCaller:HWND; pszFile:PAnsiChar; uCommand:Dword; dwData:Dword):HWND; stdcall; external 'hhctrl.ocx' name 'HtmlHelpA';
  function HtmlHelpA(
    hwndCaller:HWND; pszFile:PAnsiChar; uCommand:Dword; dwData:Dword):HWND; stdcall; external 'hhctrl.ocx' name 'HtmlHelpA';
  function HtmlHelpW(
    hwndCaller:HWND; pszFile:PWideChar; uCommand:Dword; dwData:Dword):HWND; stdcall; external 'hhctrl.ocx' name 'HtmlHelpW';

const
  ///////////////////////////////////////////////
  // HtmlHelp API �R�}���hID
  HH_INITIALIZE         = $001C;
  HH_UNINITIALIZE       = $001D;
  HH_DISPLAY_TOPIC      = $0000;
  HH_HELP_CONTEXT       = $000F;
  HH_DISPLAY_TEXT_POPUP = $000E;
  HH_GET_LAST_ERROR     = $0014;


///////////////////////////////////////////////
// HTML�w���v�T�|�[�g�R���|�[�l���g�̍\�z
// Application.OnHelp �C�x���g�̃n���h����ݒ肷��
constructor THTMLHelp.Create(AOwner : TComponent);
begin
    FCookie := Dword(-1);
    FAutoInstall := True;
    inherited Create(AOwner);
end;

procedure THTMLHelp.Loaded;
begin
    inherited Loaded;
    if( FAutoInstall )then begin
        if( not ( csDesigning in ComponentState ) )then begin
            Application.OnHelp := OnApplicationHelp;
        end;
    end;
end;

///////////////////////////////////////////////
// HTML�w���v�V�X�e���̏����� (�{���\�b�h�͉���Ăяo���Ă��ǂ�)
procedure THTMLHelp.InitHtmlHelp();
begin
  if FCookie = Dword(-1) then begin
    HtmlHelp(0,nil,HH_INITIALIZE,Dword(@FCookie) );
  end;
end;

///////////////////////////////////////////////
// Application.OnHelp �C�x���g�n���h��
function THTMLHelp.OnApplicationHelp(Command:Word; Data:longint; var CallHelp:boolean):boolean;
var
  helppath : string;
  popuppath : string;
  hRet    : HWND;
  hOwner  : HWND;
  popup   : HH_POPUP;
  lasterror : HH_LAST_ERROR;
begin
  result    := false;
  InitHtmlHelp();
  hOwner := GetDesktopWindow();

  // �w���v�t�@�C�������擾/����
  helppath := Application.CurrentHelpFile;
  if helppath = '' then begin
    helppath := ChangeFileExt(Application.ExeName,'.chm');
  end;

  // �g���q��chm�ł͂Ȃ�->HTML�w���v�t�@�C���ł͂Ȃ��ꍇ�͊����̎����ɂ܂�����
  if CompareText(ExtractFileExt(helppath),'.chm') <> 0 then exit;
  CallHelp  := false;

  // �R�}���h�ɉ�����HTML�w���vAPI���Ăяo��
  hRet := HWND(-1);
  case Command of

    HELP_CONTENTS,
    HELP_FINDER:
      begin
        hRet := HtmlHelp(hOwner,PChar(helppath),HH_DISPLAY_TOPIC,0);
      end;

    HELP_CONTEXT:
      begin
        hRet := HtmlHelp(hOwner,PChar(helppath),HH_HELP_CONTEXT,Data);
      end;

    HELP_SETPOPUP_POS:
      begin
        FPopupPos.x := LOWORD(Data);
        FPopupPos.y := HIWORD(Data);
      end;

    HELP_CONTEXTPOPUP:
      begin
        hRet := HtmlHelp(hOwner,PChar(helppath),HH_HELP_CONTEXT,Data);
        if hRet = 0 then begin
          FillChar(popup,sizeof(popup),0);
          popup.cbStruct          := sizeof(popup);
          popup.idString          := Data;
          popup.pt                := FPopupPos;
          popup.clrForeground     := COLORREF(-1);
          popup.clrBackground     := COLORREF(-1);
          popup.rcMargins.left    := -1;
          popup.rcMargins.top     := -1;
          popup.rcMargins.right   := -1;
          popup.rcMargins.bottom  := -1;
          popuppath := helppath+'::/cshelp.txt';
          HtmlHelp(Screen.ActiveForm.Handle,PChar(popuppath),HH_DISPLAY_TEXT_POPUP,DWORD(@popup) );
          exit;
        end;
      end;

  end;

  // �G���[���b�Z�[�W������΃��b�Z�[�W�{�b�N�X�ŕ\��
  if hRet = 0 then begin
    HtmlHelp(hOwner,nil,HH_GET_LAST_ERROR, DWORD(@lasterror) );
    if( FAILED(lasterror.hr) )and( lasterror.description <> nil )then begin
      Application.MessageBox(PChar(AnsiString(lasterror.description)),PChar(Application.Title),MB_OK+MB_ICONSTOP);
      SysFreeString( lasterror.description );
    end;
  end;

end;


procedure Register;
begin
  RegisterComponents('adelie works', [THTMLHelp]);
end;

end.
