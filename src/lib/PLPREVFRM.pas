{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$WARNINGS OFF}
//====================================================================
//    ����v���r���[����R���|�[�l���g
//    �v���r���[�t�H�[�����j�b�g
//    ���|�W�g���ɓo�^��C�p�����ė��p����̂��֗��D
//
//    ���̃t�H�[���́CTplPrev��FormName�v���p�e�B���w�肵�Ȃ���΁C
//    �����I�Ɍp���t�H�[�����쐬����D���̎��C�p���t�H�[���ɑ΂��鑀
//    �́CTplPrev��Form�v���p�e�B���g�p����D
//
//    Ver4.0�ŃR���|�[�l���g�̓����\����ύX�����D
//    �܂�Delphi��VCL�Ɠ��l�ɁC��{�N���XCustomplPrev���쐬���āC����
//    ����h������N���X�Ƃ��Ď��������D
//    Ver4.0���O�́C���̃t�H�[���̃C�x���g���K�v�ȏꍇ�́C�p���t�H
//    �[���ŃC�x���g���쐬����K�v�����������CTplPrev�ɃC�x���g������
//    ���āC�t�H�[���̃C�x���g�𒼐ڍ쐬���Ȃ��Ă��ςނ悤�ɂ����D
//
//                            2005.02.19  Ver.4.56
//                            Copyright (C) Mr.XRAY
//                            http://homepage2.nifty.com/Mr_XRAY/
//====================================================================
unit PLPREVFRM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,Forms,Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, Printers,Math,ToolWin,plSetPrinter,
  JPEG,Clipbrd, Buttons, Menus,plPrev;

type
  TplPrevForm = class(TForm)
    IconBar: TToolBar;
    PrintBtn: TSpeedButton;
    PrinterSetBtn: TSpeedButton;
    FirstPageBtn: TSpeedButton;
    PriorPageBtn: TSpeedButton;
    NextPageBtn: TSpeedButton;
    LastPageBtn: TSpeedButton;
    Space20: TSpeedButton;
    ZoomDownBtn: TSpeedButton;
    ZoomUpBtn: TSpeedButton;
    PageWholeBtn: TSpeedButton;
    PageWidthBtn: TSpeedButton;
    Space30: TSpeedButton;
    CloseBtn: TSpeedButton;
    StatusBar: TStatusBar;
    DisplayPanel: TPanel;
    ScrollBox1: TScrollBox;
    Image1: TImage;
    PrintDialog1: TPrintDialog;
    PrinterSetupDialog1: TPrinterSetupDialog;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    Shape1: TShape;
    Shape2: TShape;
    Space10: TSpeedButton;
    procedure PrintBtnClick(Sender: TObject);
    procedure FirstPageBtnClick(Sender: TObject);
    procedure PriorPageBtnClick(Sender: TObject);
    procedure NextPageBtnClick(Sender: TObject);
    procedure LastPageBtnClick(Sender: TObject);
    procedure ZoomDownBtnClick(Sender: TObject);
    procedure ZoomUpBtnClick(Sender: TObject);
    procedure PageWholeBtnClick(Sender: TObject);
    procedure PageWidthBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ActionDispCopyExecute(Sender: TObject);
    procedure ActionHardCopyExecute(Sender: TObject);
    procedure ActionPageCopyExecute(Sender: TObject);
    procedure ScrollBox1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormConstrainedResize(Sender: TObject; var MinWidth,
      MinHeight, MaxWidth, MaxHeight: Integer);
    procedure FormCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure PrinterSetBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Image1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Image1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
  private
    FplPrev          : TCustomplPrev;
    fgView           : Boolean;    {Form�\���̃t���O.�\���ς݂Ȃ�True}
    fgStart          : Boolean;    {��ԍŏ��̕\����}
    ImgTop           : Integer;    {Image1�̏�[}
    ImgLeft          : Integer;    {Image1�̍��[}
    ImgWidth         : Integer;    {Image1�̕�}
    ImgHeight        : Integer;    {Image1�̍���}
    MouseDownX       : Integer;    {MouseDown���̃}�E�XX���W�l}
    MouseDownY       : Integer;    {MouseDown���̃}�E�XY���W�l}
    ImageDragFlag    : Boolean;    {�C���[�W�̃h���b�O�����̃t���O}
    procedure SetFormPosition;
    procedure DrawPaperShadow;
    procedure SetplPrev(const Value: TCustomplPrev);
    procedure WMSysCommand(var Msg: TWMSysCommand);message WM_SYSCOMMAND;
    {�t�H�[���\���I�����b�Z�[�W}
    procedure CMShowingChanged(var Msg:TWMNoParams);Message CM_SHOWINGCHANGED;
    procedure SetBtnOptionsDisplay;
  public
    procedure DrawMetaImage;
    procedure Show;
    function ShowModal: Integer; override;
    property plPrev :TCustomplPrev read FplPrev write SetplPrev;
  end;

var
   plPrevForm: TplPrevForm;
   
implementation

uses  MetafileUtils;

{TCustomplPrev��protected���\�b�h���g�p���邽�߂�}
{����plPrevFormunit�ňꎞ�I�ɒ�`����CustomplPrev�̃N���X}
type
   TTempplPrev = class(TCustomplPrev);


const
S0='����v���r���[����R���|�[�l���g';
S7='�v�����^���C���X�g�[������Ă��Ȃ��̂ň���ł��܂���D�@�@';
S8='�v�����^���C���X�g�[������Ă��Ȃ��̂Őݒ�ł��܂���D�@�@';


{$R *.DFM}

//====================================================================
//   Form�쐬���̐ݒ�
//   ���̏����͌p���v���r���[�t�H�[����Ɉ���v���r���[����R���|��
//   �z�u���Ă���ꍇ�ɕK�v�D
///  �v���r���[�t�H�[����TplPrev��z�u����Ƌ����I�ɂ��̔z�u����
//   TplPrev���g�p����D�܂�CTplPrev��FormName�v���p�e�B�͖����D
//====================================================================
procedure TplPrevForm.FormCreate(Sender: TObject);
var
     i: Integer;
     AComp : TComponent;
begin
     inherited;

     {�^�b�N�V�[���Ȃǂŉ�ʂɂ�����ƕ\������Ă��܂����ۂ̏C���̂���}
     Image1.Visible:=False;

     FplPrev :=nil;   {�g�p���鐧��R���|�͂Ȃ��Ƃ���TplPrev��FormName�Őݒ肷��}
     fgView  :=False; {�t�H�[���͖����\������Ă��Ȃ�}

     {���̃t�H�[����ɔz�u���Ă������v���r���[����R���|���������Đݒ�}
     {ClassParent�͈��ʂ̃N���X}
     for i:=0 to Self.ComponentCount-1 do begin
       AComp:=Self.Components[i];
       if AComp.ClassParent.ClassNameIs('TCustomplPrev') then begin
         FplPrev:=(Self.Components[i] as TCustomplPrev);
         TTempplPrev(FplPrev).FormName:=Self.Name;
         TTempplPrev(FplPrev).Form    :=Self;
         break;
       end;
     end;
     if FplPrev<>nil then begin
       {���ɂ��̃t�H�[����̃v�����^�ݒ�R���|��T��}
       {������͌��o�� is ���g�p���Ă݂�}
       if TTempplPrev(FplPrev).plSetPrinter=nil then begin
         for i:=0 to Self.ComponentCount-1 do begin
           if (Self.Components[i] is TplSetPrinter) then begin
             TTempplPrev(FplPrev).plSetPrinter:=(Self.Components[i] as TplSetPrinter);
             break;
           end;
         end;
         TTempplPrev(FplPrev).SetDefaultPrinter;
       end;
       {�t�H�[���̃T�C�Y�ƈʒu��ݒ�}
       TTempplPrev(FplPrev).Execute;
       SetFormPosition;
     end;
end;
//====================================================================
//    Form�������v���r���[����R���|�[�l���g�ɃA�N�Z�X�\�ɂ���
//====================================================================
procedure TplPrevForm.SetplPrev(const Value: TCustomplPrev);
begin
     if Value=nil then exit;
     {����v���r���[����R���|�֘A�Â�}
     FplPrev :=Value;
     {����v���r���[����R���|���ɃA�N�Z�X�\��}
     TTempplPrev(FplPrev).Form:=Self;

     {�\�����Ȃ�ݒ肵�Ȃ�}
     if Self.Visible then exit;
     SetFormPosition;
end;
//====================================================================
//   FplPrev�̊e�v���p�e�B�Ɋ�Â��ăt�H�[���̈ʒu�ƃT�C�Y��ݒ�
//   FormPositon��poDesigned�̎��͈ʒu�ƃT�C�Y��
//   FormLeft,FormTop,FormWidth,FormHeight�̐ݒ�l�ƂȂ�D
//====================================================================
procedure TplPrevForm.SetFormPosition;
var
    WorkRect : TRect;
begin
     {�^�X�N�o�[����������ʂ̃��[�N�G���A���擾}
     SystemParametersInfo(SPI_GETWORKAREA,0,@WorkRect,0);
     if TTempplPrev(FplPrev).Title='' then TTempplPrev(FplPrev).Title:='����v���r���[';
     Self.Caption           :=TTempplPrev(FplPrev).Title;
     Self.BorderIcons       :=TTempplPrev(FplPrev).FormBorderIcons;
     Self.StatusBar.Visible :=TTempplPrev(FplPrev).FormStatusBar;
     Self.IconBar.Visible   :=TTempplPrev(FplPrev).FormIconBar;
     Self.Icon              :=TTempplPrev(FplPrev).FormIcon;
     Self.BorderStyle       :=TTempplPrev(FplPrev).FormBorderStyle;
     if ScrollBox1.Color=clBtnFace then begin
       ScrollBox1.Color:=TTempplPrev(FplPrev).FormColor;
     end;

     {�N�����̃t�H�[���̈ʒu�ƃT�C�Y}
     if TTempplPrev(FplPrev).FormWindowState=fwWorkArea  then begin
       {���[�N�G���A�S�̂ɕ\��}
       Self.Position:=poDesigned;
       Self.SetBounds(WorkRect.Left,WorkRect.Top,WorkRect.Right-WorkRect.Left,WorkRect.Bottom-WorkRect.Top);
     end else if TTempplPrev(FplPrev).FormWindowState=fwFullScreen then begin
       {��ʑS�̂ɕ\��}
       {FullScreen��BorderStyle��Single�ɂ��Ȃ��ƃ^�X�N�o�[��\�����Ă��܂�}
       Self.BorderStyle:=bsSingle;
       Self.SetBounds(0,0,Screen.Width,Screen.Height);
     end else if TTempplPrev(FplPrev).FormWindowState=fwMinimized then begin
       {�ŏ����ŕ\��}
       Self.WindowState:=wsMinimized;
     end else if TTempplPrev(FplPrev).FormWindowState=fwMaximized then begin
       {�ő剻�ŕ\��}
       Self.WindowState :=wsMaximized;
     end else begin
       if TTempplPrev(FplPrev).FormPosition=poDesigned then begin
         {poDesigned�̎���TplPrev��FormLest,FormTop,FormWidht,FormHeight�̒l�ŕ\��}
         Self.Position   :=poDesigned;
         Self.WindowState:=wsNormal;
         Self.SetBounds(TTempplPrev(FplPrev).FormLeft,
                        TTempplPrev(FplPrev).FormTop,
                        TTempplPrev(FplPrev).FormWidth,
                        TTempplPrev(FplPrev).FormHeight);
       end else begin
         {���̑��̏ꍇ�͈ȉ��̃v���p�e�B�̐ݒ�ɏ]��}
         Self.Position:=TTempplPrev(FplPrev).FormPosition;
       end;
     end;
     SetBtnOptionsDisplay;
end;
//====================================================================
//    Form�����[�_���ŕ\������O�̏���
//====================================================================
function TplPrevForm.ShowModal: Integer;
begin
     inherited ShowModal;
     Result:=ModalResult;
end;
//====================================================================
//    Form�����[�h���X�ŕ\������O�̏���
//====================================================================
procedure TplPrevForm.Show;
begin
     inherited Show;
end;
//====================================================================
//  �t�H�[���\���̍ۂ̏����@
//====================================================================
procedure TplPrevForm.FormShow(Sender: TObject);
begin
     inherited;
     if FplPrev=nil then exit;
     if Assigned(TTempplPrev(FplPrev).OnFormShow) then begin
       TTempplPrev(FplPrev).OnFormShow(Self);
     end;
end;
//====================================================================
//  �{�^���\���L���̐ݒ�
//====================================================================
procedure TplPrevForm.SetBtnOptionsDisplay;
begin
     {�e�{�^���ނ̕\���L����ݒ�}
     PrintBtn.Visible     :=boPrintBtn      in TTempplPrev(FplPrev).BtnOptions;
     if TTempplPrev(FplPrev).DrawType=dtCont then begin
       PrinterSetBtn.Visible:=False;
     end else begin
       PrinterSetBtn.Visible:=boPrinterSetBtn in TTempplPrev(FplPrev).BtnOptions;
     end;
     FirstPageBtn.Visible :=boFirstPageBtn  in TTempplPrev(FplPrev).BtnOptions;
     PriorPageBtn.Visible :=boPriorPageBtn  in TTempplPrev(FplPrev).BtnOptions;
     NextPageBtn.Visible  :=boNextPageBtn   in TTempplPrev(FplPrev).BtnOptions;
     LastPageBtn.Visible  :=boLastPageBtn   in TTempplPrev(FplPrev).BtnOptions;
     ZoomDownBtn.Visible  :=boZoomDownBtn   in TTempplPrev(FplPrev).BtnOptions;
     ZoomUpBtn.Visible    :=boZoomUpBtn     in TTempplPrev(FplPrev).BtnOptions;
     PageWholeBtn.Visible :=boPageWholeBtn  in TTempplPrev(FplPrev).BtnOptions;
     PageWidthBtn.Visible :=boPageWidthBtn  in TTempplPrev(FplPrev).BtnOptions;
     CloseBtn.Visible     :=boCloseBtn      in TTempplPrev(FplPrev).BtnOptions;
end;
//====================================================================
//  �t�H�[���̕\���I��
//  �t�H�[���̕\�����I�������烁�^�t�@�C����\��
//  ��ǂݕ���   �t�H�[���\���I�����_�����^�t�@�C�����ł��Ă���
//  �����\������ �ŏ��̕ł̂ݕ`��R�[�h�����s���ă��^�t�@�C���쐬
//====================================================================
procedure TplPrevForm.CMShowingChanged(var Msg:TWMNoParams);
begin
     {�C���[�W�̃h���b�O�͂Ȃ�}
     ImageDragFlag:=False;
     if FplPrev=nil then begin
       inherited;
       fgView:=True;
       exit;
     end else begin
       {FromParent�v���p�e�B���L���Ȃ�΂�����alClient�ŕ\��}
       if TTempplPrev(FplPrev).FormParent<>nil then begin
         Self.Parent:=TTempplPrev(FplPrev).FormParent;
         Self.Align :=alClient;
       end;
     end;

     {�ʏ��CMShowingChanged���p��}
     inherited;
     if Self.Visible=False then exit;

     {�`��̃`���c�L��h�~���邽�߂̃_�u���o�b�t�@�����O�D�������͐H��}
     ScrollBox1.DoubleBuffered:=True;

     {CMShowing���Ă΂ꂽ��Form�͕\�����ꂽ.�\���t���O���Z�b�g}
     fgView:=True;
     {�O�̂��ߍĐݒ�}
     Image1.Anchors:=[akLeft,akTop];
     Image1.Stretch:=True;

     Self.Caption:=TTempplPrev(FplPrev).Title;
     if FplPrev.GetMetaImage(TTempplPrev(FplPrev).PageNumber)<>nil then begin
       fgStart :=True;
       {�T�C�Y�ύX�Ń��^�t�@�C�����T�C�Y�ύX}
       ScrollBox1.AutoScroll:=True;
       ScrollBox1.VertScrollBar.Margin:=10;
       ScrollBox1.HorzScrollBar.Margin:=10;

       {������Image1��\��}
       Image1.Visible:=TTempplPrev(FplPrev).ImageVisible;
       {�\���T�C�Y�ɉ����ĕ\��}
       if TTempplPrev(FplPrev).ZoomType=ztPageWidth then begin
         PageWidthBtnClick(Self);
         DrawMetaImage;
       end else begin
         PageWholeBtnClick(Self);
         DrawMetaImage;
       end;
       Application.ProcessMessages;
       fgStart:=False;
     end;
end;
//====================================================================
//   �t�H�[���̈ړ��R�}���h�̏���
//   FormCanMove(published)��True�̎��͈ړ��\��
//                            False�̎��͈ړ��s�̏���
//====================================================================
procedure TplPrevForm.WMSysCommand(var Msg: TWMSysCommand);
begin
     if FplPrev=nil then begin
       inherited;
       exit;
     end;
     {SC_MOVE(�ړ�)�̎��͖���}
     if (TTempplPrev(FplPrev).FormCanMove=False) and
        ((Msg.CmdType and $FFF0)=SC_MOVE) then begin
       Msg.Result:=0;
     {����ȊO�̓f�t�H���g����}
     end else begin
       inherited;
     end;
end;
//====================================================================
//   �`��p���^�t�@�C�����쐬�܂��擾����Image1�ɕ`��
//   �\���ł��ύX�ƂȂ������Ɏ��s���郁�\�b�h
//   ���̃��\�b�h���ĂԑO��Image�̃T�C�Y�����肵�Ă���
//   �ł��ς��Ǝ���OnBeforeView,OnFormResize,OnAfterView���Ԃɔ���
//   (Ver3.0��OnResize��OnAfter�̏��Ԃ�ύX
//
//   �Q�l
//   Image1.Picture.Assign(FplPrev.MetaImage);
//   Image1.Picture.MetaFile:=FplPrev.MetaImage;
//      Image1.Canvas�ւ̕`��͕s��(�ɂ��邱�Ƃ��\)
//      �g�奏k���̕\���T�C�Y�ύX�ōĎ��s�̕K�v���Ȃ�
//   Image1.StretchDraw(Image1.ClientRect,FplPrev,MetaImage);
//      �r�b�g�}�b�v�ŕ\������邽�ߊg�奏k���̓x�Ɍďo���K�v������
//      TImage.Canvas�ւ̕`�悪�\�Ȃ̂�,�C���[�W�̏d�˕`����\
//      �������C�p���T�C�Y�̕ύX�Ȃǂ��������ꍇ�̒������ʓ|�D
//====================================================================
procedure TplPrevForm.DrawMetaImage;
var
     S: String;
     PaperName: String;
     PaperWStr,PaperHStr: String;
begin
     {�����\�������ł�OnFormResize��OnAfterVeiw���g�p�ł��邪�C���ۖ��Ƃ��Ă�}
     {�`��p���\�b�h���ɃR�[�h�������̂ł��܂�K�v���͂Ȃ���...}
     if Image1.Visible then begin
       LockWindowUpdate(Handle);
       Application.ProcessMessages;
       {�Y���ł̃��^�t�@�C���̉摜���擾�܂��͍쐬����Image1�ɕ`��}
       Image1.Picture.Assign(TTempplPrev(FplPrev).GetMetaImage(TTempplPrev(FplPrev).PageNumber));

       {�p���g���Ɖe.2002.6.20.OnAfterView�̑O�Ɉړ�}
       Shape1.Visible:=True;
       if TTempplPrev(FplPrev).ImageShade then begin
         Shape2.Visible:=True;
       end else begin
         Shape2.Visible:=False;
       end;

       DrawPaperShadow;
       {�`�撼��̃C�x���g����}
       if (Assigned(TTempplPrev(FplPrev).OnAfterView)) then begin
         TTempplPrev(FplPrev).OnAfterView(Self,TTempplPrev(FplPrev).PageNumber);
       end;
       Application.ProcessMessages;

       {�e��{�^���̗L���ݒ�}
       PrintBtn.Enabled     :=(TTempplPrev(FplPrev).PageNumber>0);
       PrinterSetBtn.Enabled:=(TTempplPrev(FplPrev).PageNumber>0);
       PageWholeBtn.Enabled :=(TTempplPrev(FplPrev).PageNumber>0);
       PageWidthBtn.Enabled :=(TTempplPrev(FplPrev).PageNumber>0);
       ZoomDownBtn.Enabled  :=(TTempplPrev(FplPrev).PageNumber>0);
       ZoomUpBtn.Enabled    :=(TTempplPrev(FplPrev).PageNumber>0);
       {�ő���{�^���̕\������}
       FirstPageBtn.Enabled:=(TTempplPrev(FplPrev).PageNumber>1);
       PriorPageBtn.Enabled:=(TTempplPrev(FplPrev).PageNumber>1);
       NextPageBtn.Enabled :=(TTempplPrev(FplPrev).PageNumber<TTempplPrev(FplPrev).PageCount);
       LastPageBtn.Enabled :=(TTempplPrev(FplPrev).PageNumber<TTempplPrev(FplPrev).PageCount);

       {���Ő��ƌ��݂̕Ŕԍ��Ɨp�����T�C�Y��\��}
       S:='';
       PaperWStr:=FormatFloat('##0.0',TTempplPrev(FplPrev).ViewWidth /10);
       PaperHStr:=FormatFloat('##0.0',TTempplPrev(FplPrev).ViewHeight/10);
       S:=' Page  '+IntToStr(TTempplPrev(FplPrev).PageNumber)+'/'+IntToStr(TTempplPrev(FplPrev).PageCount);
       if TTempplPrev(FplPrev).plSetPrinter=nil then begin
         S:=S+'  '+' ( '+PaperWStr+' x '+PaperHStr+' mm )';
       end else begin
         PaperName:=TTempplPrev(FplPrev).plSetPrinter.PaperName;
         S:=S+'  '+TTempplPrev(FplPrev).plSetPrinter.PaperName+
            ' ( '+PaperWStr+' x '+PaperHStr+' mm )';
       end;
       StatusBar.Panels[0].Text:=S;
       if TTempplPrev(FplPrev).StatusBarText<>'' then begin
         StatusBar.Panels[1].Text:=TTempplPrev(FplPrev).StatusBarText;
       end;
       LockWindowUpdate(0);
     end;
end;
//====================================================================
//    �p���̘g���Ɖe�̕`��
//    �\���T�C�Y���g��k���E�ŕ��E�őS�̂ȂǂŕύX�ƂȂ������Ɏ��s��
//    �郁�\�b�h
//    ������Flag��Ver3.0�ŕs�v�ɂȂ����̂ō폜
//
//    �ł��ς�鎞�ƃ��T�C�Y�̍ۂɎ��s
//    �ł��ς��Ǝ���OnBeforeView,OnAfterView,OnResize��3�������D
//    ���T�C�Y�̏ꍇ�͂���DrawPaperShadow�̂�
//====================================================================
procedure TplPrevForm.DrawPaperShadow;
var
     Bw,Bh: Integer;
     Xl,Yt,Xw,Yw: Integer;
begin
     Bw:=2;
     Bh:=2;
     Xl:=Image1.Left;
     Yt:=Image1.Top;
     Xw:=Image1.Width;
     Yw:=Image1.Height;
     if Image1.Visible then begin
       Shape2.SetBounds(Xl+Bw,Yt+Bw,Xw+Bh,Yw+Bh);
       Shape1.Pen.Color:=clBlack;
       Shape1.SetBounds(Xl-1,Yt-1,Xw+1,Yw+1);
       {�C���[�W�̃��T�C�Y��̃C�x���g����}
       if (Assigned(TTempplPrev(FplPrev).OnResize)) then begin
         TTempplPrev(FplPrev).OnResize(Self,TTempplPrev(FplPrev).PageNumber);
       end;
     end;
end;
//====================================================================
//    ����_�C�A���O��\�����Ĉ��
//
//    �Ŏw��͌��݂̕ł���������\�ȕ\���Ƃ��Ă���.
//    �_�C�A���O�Ńv���p�e�B�̐ݒ��ύX���Ă�������݂̗L��
//    (�ʏ�̃A�v���P�[�V�����Ɠ�������)
//
//    ����J�n�ƏI���ł͈ȉ��̃v���p�e�B���g�p����
//    PrintFromPage  ����J�n�Ŕԍ�
//    PrintToPage    ����I����
//====================================================================
procedure TplPrevForm.PrintBtnClick(Sender: TObject);
var
     PageNum: Integer;
     CanPrint: Boolean;
begin
     {�v�����^�܂��̓v�����^�ݒ�R���|�Ȃ�}
     if TTempplPrev(FplPrev).PrinterFlag=False then begin
       Application.MessageBox(PChar(S7),PChar('�@���'),MB_ICONINFORMATION);
       exit;
     end;

     CanPrint:=True;
     if Assigned(TTempplPrev(FplPrev).OnPrintButtonClick) then begin
       TTempplPrev(FplPrev).OnPrintButtonClick(Self,CanPrint);
       if CanPrint=False then exit;
     end;

     {���݂̕Ŕԍ���ޔ�}
     PageNum:=TTempplPrev(FplPrev).PageNumber;
     {����J�n�łƍŏI�ł̏����l��0�Ƃ���}
     TTempplPrev(FplPrev).PrintFromPage :=0;
     TTempplPrev(FplPrev).PrintToPage   :=0;
     {�ݒ�֌W�̏��Ԃ�ς���ƃ_�C�A���O���\������Ȃ����Ƃ�����}
     {�܂��e�Őݒ�̍ŏ���0,1�̈Ӗ��ɂ�����}
     PrintDialog1.Options  :=[poPageNums];
     PrintDialog1.FromPage :=TTempplPrev(FplPrev).PageNumber;
     PrintDialog1.MinPage  :=1;
     PrintDialog1.ToPage   :=1;
     PrintDialog1.MaxPage  :=TTempplPrev(FplPrev).PageCount;
     PrintDialog1.ToPage   :=TTempplPrev(FplPrev).PageNumber;

     {�v�����^�ݒ�R���|�[�l���g�̐ݒ��ۑ����Ă���}
     TTempplPrev(FplPrev).SavePrinterSetting;
     if (PrintDialog1.Execute) then begin
       PrintBtn.Enabled:=False;
       TTempplPrev(FplPrev).plSetPrinter.GetPrinterInfo(False);
       {�_�C�A���O�őS�Ă̕ł�I�������ꍇ}
       if PrintDialog1.PrintRange=prAllPages then begin
         TTempplPrev(FplPrev).PrintFromPage  :=PrintDialog1.MinPage;
         TTempplPrev(FplPrev).PrintToPage    :=PrintDialog1.MaxPage;
       {�Ŕ͈͂��w�肵���ꍇ}
       end else if PrintDialog1.PrintRange=prPageNums then begin
         TTempplPrev(FplPrev).PrintFromPage :=PrintDialog1.FromPage;
         TTempplPrev(FplPrev).PrintToPage   :=PrintDialog1.ToPage;
       end;

       try
         {������s}
         TTempplPrev(FplPrev).Print;
       finally
         {�ۑ����Ă������v�����^�ݒ�R���|�[�l���g�̐ݒ��Ǐo��}
         TTempplPrev(FplPrev).ReadPrinterSetting;
         {���݂̕ł����ɖ߂�}
         TTempplPrev(FplPrev).PageNumber:=PageNum;
         {���ɒ����\�������̏ꍇ�͈�����Ȃ�����������̂ŕł��ĕ`��}
         DrawMetaImage;
         Screen.Cursor:=crDefault;
         Self.Update;
       end;
     end;
end;
//====================================================================
//    �v�����^�ݒ�_�C�A���O��\��
//    ViewWidth,ViewHeight�̒l�͂����ŗp���̃T�C�Y�ɖ߂��Ă��܂�
//    2000,4.30 �����\��������,�v�����^�ݒ�_�C�A���O
//    (TPrinterSetupDialog)�̐ݒ���e���v���r���[���f����悤�ɕύX
//
//    Ver3.0�C��
//    Sender��nil��n�����ꍇ,�_�C�A���O��\�������ɐݒ肪�\��.
//    ������,�����\�������̂�.
//
//    OnPrinterSetupDialog�̓_�C�A���O��OK�ŏI�������ꍇ�̂ݔ���
//====================================================================
procedure TplPrevForm.PrinterSetBtnClick(Sender: TObject);
begin
     if FplPrev=nil then exit;
     if TTempplPrev(FplPrev).DrawType=dtCont then exit;
     {�v�����^�܂��̓v�����^�ݒ�R���|�Ȃ�}
     if TTempplPrev(FplPrev).PrinterFlag=False then begin
       Application.MessageBox(PChar(S8),PChar('�@�v�����^�Ɨp���̐ݒ�'),MB_ICONINFORMATION);
       exit;
     end;

     if (Sender=nil) or (PrinterSetupDialog1.Execute) then begin
       try
         PrinterSetBtn.Enabled:=False;
         {�ݒ肵�����e���v�����^�ݒ�R���|�ɑ���}
         TTempplPrev(FplPrev).plSetPrinter.GetPrinterInfo(False);
         TTempplPrev(FplPrev).SetPaperInfo;
         TTempplPrev(FplPrev).ViewWidth :=TTempplPrev(FplPrev).PaperWidth; {�\�����̃f�t�H���g�͗p����}
         TTempplPrev(FplPrev).ViewHeight:=TTempplPrev(FplPrev).PaperHeight;{�\�������̃f�t�H���g�͗p������}
         if Assigned(TTempplPrev(FplPrev).OnPrinterSetupDialog) then begin
           TTempplPrev(FplPrev).OnPrinterSetupDialog(Self);
         end;
         DrawMetaImage;
       finally
         PageWholeBtnClick(nil);
        end;
      end;
end;
//====================================================================
//   �擪�ł�\��
//====================================================================
procedure TplPrevForm.FirstPageBtnClick(Sender: TObject);
begin
     if TTempplPrev(FplPrev).PageNumber=1 then exit;
     FirstPageBtn.Enabled:=False;
     PriorPageBtn.Enabled:=False;
     TTempplPrev(FplPrev).PageNumber:=1;
     DrawMetaImage;
end;
//====================================================================
//   �O�̕ł�\��
//====================================================================
procedure TplPrevForm.PriorPageBtnClick(Sender: TObject);
begin
     if TTempplPrev(FplPrev).PageNumber=1 then exit;
     PriorPageBtn.Enabled:=False;
     TTempplPrev(FplPrev).PageNumber:=TTempplPrev(FplPrev).PageNumber-1;
     DrawMetaImage;
end;
//====================================================================
//   ���̕ł�\��
//====================================================================
procedure TplPrevForm.NextPageBtnClick(Sender: TObject);
begin
     if TTempplPrev(FplPrev).PageNumber=TTempplPrev(FplPrev).PageCount then exit;
     NextPageBtn.Enabled:=False;
     TTempplPrev(FplPrev).PageNumber:=TTempplPrev(FplPrev).PageNumber+1;
     DrawMetaImage;
end;
//====================================================================
//   �ŏI�ł�\��
//====================================================================
procedure TplPrevForm.LastPageBtnClick(Sender: TObject);
begin
     if TTempplPrev(FplPrev).PageNumber=TTempplPrev(FplPrev).PageCount then exit;
     LastPageBtn.Enabled:=False;
     NextPageBtn.Enabled:=False;
     TTempplPrev(FplPrev).PageNumber:=TTempplPrev(FplPrev).PageCount;
     DrawMetaImage;
end;
//====================================================================
//   �v���r���[�\�����k��
//====================================================================
procedure TplPrevForm.ZoomDownBtnClick(Sender: TObject);
begin
     ZoomDownBtn.Enabled:=False;

     TTempplPrev(FplPrev).ZoomType:=ztOther;
     with ScrollBox1 do begin
       VertScrollBar.Visible :=True;
       HorzScrollBar.Visible :=True;
     end;
     if Image1.Width<=100 then begin
       ZoomDownBtn.Enabled:=False;
     end else begin
       ImgWidth :=Trunc(ImgWidth*90.0/100.0);
       ImgHeight:=Trunc(ImgWidth*TTempplPrev(FplPrev).ViewPaperRatio);
       Image1.SetBounds(ImgLeft,ImgTop,ImgWidth,ImgHeight);
       DrawPaperShadow;
       Application.ProcessMessages;
       ZoomDownBtn.Enabled:=True;
     end;
     ZoomUpBtn.Enabled  :=True;
end;
//====================================================================
//    �v���r���[�\�����g��
//    ���^�t�@�C���̕`��͂��Ȃ�.Image�̑傫���̕ύX�����邾��
//====================================================================
procedure TplPrevForm.ZoomUpBtnClick(Sender: TObject);
begin
     ZoomUpBtn.Enabled:=False;

     TTempplPrev(FplPrev).ZoomType:=ztOther;
     with ScrollBox1 do begin
       VertScrollBar.Visible :=True;
       HorzScrollBar.Visible :=True;
     end;
     if (Image1.Width>=Screen.Width*2) or
        (Image1.Height>=Screen.Height*3) then begin
        ZoomUpBtn.Enabled:=False;
     end else begin
       ImgLeft:=Image1.Left;
       ImgTop :=Image1.Top;
       {�g���10%}
       ImgWidth :=Trunc(ImgWidth*100.0/90.0);
       ImgHeight:=Trunc(ImgWidth*TTempplPrev(FplPrev).ViewPaperRatio);
       Image1.SetBounds(ImgLeft,ImgTop,ImgWidth,ImgHeight);
       DrawPaperShadow;
       Application.ProcessMessages;
       ZoomUpBtn.Enabled:=True;
     end;
     ZoomDownBtn.Enabled:=True;
end;
//====================================================================
//    �őS�̂�\��
//    �őS�̂��X�N���[���{�b�N�X�̒��ɓ���l�ɕ\��.
//    ���^�t�@�C���̕`��͂��Ȃ�.Image�̑傫���̕ύX�����邾��
//====================================================================
procedure TplPrevForm.PageWholeBtnClick(Sender: TObject);
var
     CrtRatio: Double;
begin
     TTempplPrev(FplPrev).ZoomType:=ztWholePage;
     with ScrollBox1 do begin
       VertScrollBar.Visible :=False;
       HorzScrollBar.Visible :=False;
     end;
     ScrollBox1.VertScrollBar.Visible:=False;
     ScrollBox1.HorzScrollBar.Visible:=False;
     CrtRatio:=ScrollBox1.Height/ScrollBox1.Width;
     {�p���̏c���䂪ScrollBox�̏c������傫��.�c�������Ɍ��߂�}
     if TTempplPrev(FplPrev).ViewPaperRatio>CrtRatio then begin
       ImgTop   :=15;
       ImgHeight:=ScrollBox1.Height-30;
       ImgWidth :=Trunc(ImgHeight/TTempplPrev(FplPrev).ViewPaperRatio);
       ImgLeft  :=Trunc((ScrollBox1.Width-ImgWidth)/2.0);
     {�p���̏c���䂪ScrollBox�̏c�����菬����.���������Ɍ��߂�}
     end else begin
       ImgLeft  :=15;
       ImgWidth :=ScrollBox1.Width-30;
       ImgHeight:=Trunc(ImgWidth*TTempplPrev(FplPrev).ViewPaperRatio);
       ImgTop   :=Trunc((ScrollBox1.Height-ImgHeight)/2.0);
     end;
     Image1.Setbounds(ImgLeft,ImgTop,ImgWidth,ImgHeight);
     DrawPaperShadow;
     Application.ProcessMessages;
     {�\���{���{�^���̕\������}
     if TTempplPrev(FplPrev).ImageVisible then ZoomUpBtn.Enabled  :=True;
     if TTempplPrev(FplPrev).ImageVisible then ZoomDownBtn.Enabled:=True;
end;
//====================================================================
//    �p��������ɂ����v���r���[
//    �X�N���[���{�b�N�X�̕��̒���,�p���̉���������l�ɕ\��.
//    ���^�t�@�C���̕`��͂��Ȃ�.Image�̑傫���̕ύX�����邾��
//====================================================================
procedure TplPrevForm.PageWidthBtnClick(Sender: TObject);
begin
     TTempplPrev(FplPrev).ZoomType:=ztPageWidth;
     with ScrollBox1 do begin
       VertScrollBar.Visible :=True;
       HorzScrollBar.Visible :=True;
       VertScrollBar.Position:=0;
       HorzScrollBar.Position:=0;
     end;
     {��ƍ��E�̗]����ݒ�}
     ImgTop :=15;
     ImgLeft:=15;
     {�\���T�C�Y�̏c���䂩��Image1�̏c����ݒ�}
     ImgWidth :=ScrollBox1.ClientWidth-30;
     ImgHeight:=Trunc(ImgWidth*TTempplPrev(FplPrev).ViewPaperRatio);
     Image1.Setbounds(ImgLeft,ImgTop,ImgWidth,ImgHeight);
     if ScrollBox1.VertScrollBar.Visible then begin
       ImgWidth :=ScrollBox1.ClientWidth-30;
       ImgHeight:=Trunc(ImgWidth*TTempplPrev(FplPrev).ViewPaperRatio);
       Image1.Setbounds(ImgLeft,ImgTop,ImgWidth,ImgHeight);
     end;
     DrawPaperShadow;
     Application.ProcessMessages;
     {�\���{���{�^���̕\������}
     if TTempplPrev(FplPrev).ImageVisible then ZoomUpBtn.Enabled  :=True;
     if TTempplPrev(FplPrev).ImageVisible then ZoomDownBtn.Enabled:=True;
end;
//====================================================================
//    �t�H�[���̃��T�C�Y�v���p�e�B�̏���
//====================================================================
procedure TplPrevForm.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
     if FplPrev=nil then exit;
     Resize:=TTempplPrev(FplPrev).FormCanResize;
     if TTempplPrev(FplPrev).FormCanResize=False then begin
       {�X�e�[�^�X�o�[�̃O���b�v���\��}
       Self.StatusBar.SizeGrip:=False;
     end;
end;
//====================================================================
//    �t�H�[���̃��T�C�Y����
//    �t�H�[���̑傫���ɑΉ����ăC���[�W���Ǐ]���ĕω�
//    ���^�t�@�C���̕`��͂��Ȃ�.Image�̑傫���̕ύX�����邾��
//====================================================================
procedure TplPrevForm.FormResize(Sender: TObject);
begin
     if FplPrev=nil then exit;
     if not(fgView) then exit;
     {�őS�̂ƕŕ��\���̏ꍇ�̂�.�g��k���̎��͉������Ȃ�}
     if TTempplPrev(FplPrev).ZoomType=ztWholePage then begin
       PageWholeBtnClick(Self);
     end else if TTempplPrev(FplPrev).ZoomType=ztPageWidth then begin
       PageWidthBtnClick(Self);
     end;
end;
//====================================================================
//    �t�H�[���̑傫���𐧌�����
//    �k���̏ꍇ�݂̂̐���
//====================================================================
procedure TplPrevForm.FormConstrainedResize(Sender: TObject; var MinWidth,
  MinHeight, MaxWidth, MaxHeight: Integer);
begin
     MinWidth:=300;
     MinHeight:=300;
end;
//====================================================================
//    �}�E�X�z�C�[���ɂ��X�N���[��
//====================================================================
procedure TplPrevForm.ScrollBox1MouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
     Handled:=True;
     Self.ScrollBox1.VertScrollBar.Position:=
                   Self.ScrollBox1.VertScrollBar.Position-WheelDelta div 5;
end;
//====================================================================
//    �|�b�v�A�b�v���j���[�̏���
//    �v���r���[��ʂŃ}�E�X�{�^���̉E�N���b�N�������̃��j���[�̕\��
//    �ʒu���w��
//====================================================================
procedure TplPrevForm.Image1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     MouseDownX:=X;
     MouseDownY:=Y;
     if Button=mbRight then begin
       PopupMenu1.AutoHotkeys:=maManual;
       if TTempplPrev(FplPrev).PrinterFlag=False then begin
         PopupMenu1.Items[1].Enabled:=False;
         PopupMenu1.Items[2].Enabled:=False;
       end;
       if Sender=Image1 then begin
         with ClientToScreen(Point(X,Y)) do begin
           PopupMenu1.Popup(X+Image1.Left,Y+Image1.Top+ScrollBox1.Top);
         end;
       end else if Sender=ScrollBox1 then begin
         with ClientToScreen(Point(X,Y+ScrollBox1.Top)) do begin
           PopupMenu1.Popup(X,Y);
         end;
       end;
     {���{�^���ł̓h���b�O�ɂ��C���[�W�����̈ړ����\�ɂ���}  
     end else if Button=mbLeft then begin
       if TTempplPrev(FplPrev).ImageDrag and TTempplPrev(FplPrev).ImageVisible then begin
         TImage(Sender).BeginDrag(True);
         ScrollBox1.VertScrollBar.Visible:=True;
         ScrollBox1.HorzScrollBar.Visible:=True;
         ScrollBox1.AutoScroll:=True;
         ImageDragFlag:=True;
       end;
     end;
end;
//====================================================================
//   �C���[�W�̃h���b�O���̏���
//====================================================================
procedure TplPrevForm.Image1DragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
     if ImageDragFlag=False then exit;
     Accept := Source is TImage;
     if Accept then begin
       with Source as TImage do begin
         Left := Left+X-MouseDownX;
         Top  := Top +Y-MouseDownY;
         Shape1.Left:=Shape1.Left+X-MouseDownX;
         Shape1.Top :=Shape1.Top +Y-MouseDownY;
         Shape2.Left:=Shape2.Left+X-MouseDownX;
         Shape2.Top :=Shape2.Top +Y-MouseDownY;
         ScrollBox1.Update;
       end;
     end;
end;
//====================================================================
//   �C���[�W�̃h���b�O�I�����̏���
//====================================================================
procedure TplPrevForm.Image1DragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
     if ImageDragFlag=False then exit;
     if (Sender = Source) then begin
       with Source as TImage do begin
         Left := Left+X-MouseDownX;
         Top  := Top +Y-MouseDownY;
         Shape1.Left:=Shape1.Left+X-MouseDownX;
         Shape1.Top :=Shape1.Top +Y-MouseDownY;
         Shape2.Left:=Shape2.Left+X-MouseDownX;
         Shape2.Top :=Shape2.Top +Y-MouseDownY;
         EndDrag(true);
         ImageDragFlag:=False;
      end;
     end;
end;
//====================================================================
//    �\�����̕őS�̂����^�t�@�C���Ƃ��ăN���b�v�{�[�h��
//    ���ۂɕ\������MetaFile�����̂܂܂̐��@�ŃN���b�v�{�[�h�ɑ���.
//====================================================================
procedure TplPrevForm.ActionPageCopyExecute(Sender: TObject);
begin
     if TTempplPrev(FplPrev).MetaImage<>nil then begin
       Clipboard.Clear;
       Clipboard.Assign(TTempplPrev(FplPrev).GetMetaImage(TTempplPrev(FplPrev).PageNumber));
       Application.ProcessMessages
     end;
end;
//====================================================================
//    �v���r���[�t�H�[���̃n�[�h�R�s�[
//
//    �|�b�v�A�b�v���j���[����[��ʃn�[�h�R�s�[]�œ���
//    ����_�C�A���O��\������.�L�����Z������ƒ��~.
//    Keybd_Event�ŃA�N�e�B�u�E�C���h�D���N���b�v�{�[�h�ɃR�s�[����
//    �����Bitmap�ɑ�����Ă�����v�����^�ɏo�͂���D
//
//    ��ʂ̃v���p�e�B�̌��ʂ�[�A�j���[�V����]��L���ɂ��Ă���ƃ|�b
//    �v�A�b�v���j���[ �̈ꕔ���R�s�[���Ă��܂��̂Œ��ӁD
//====================================================================
procedure TplPrevForm.ActionHardCopyExecute(Sender: TObject);
var
     OSver        : TOSVERSIONINFO;
     Flags1       : Word;
     Flags2       : Word;
     ABitmap      : TBitmap;
     Xl,Xr,Yt,Yb  : Integer;
     BitmapRatio  : Double;
     PWidth       : Integer;
begin
     {�v�����^�ݒ�R���|�[�l���g�̐ݒ��ۑ����Ă���}
     TTempplPrev(FplPrev).SavePrinterSetting;

     Flags1:=KEYEVENTF_EXTENDEDKEY;
     Flags2:=KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP;
     {OS�̎�ނ��擾}
     OSver.dwOSVersionInfoSize:=SizeOf(OSver);
     GetVersionEx(OSver);
     {���݃A�N�e�B�u�ȃE�C���h�D��ʂ��N���b�v�{�[�h��}
     case  OSver.dwPlatformId of
     {Windows95,98}
     VER_PLATFORM_WIN32_WINDOWS:
       begin
         keybd_event(VK_SNAPSHOT,0,Flags1,0);
         keybd_event(VK_SNAPSHOT,0,Flags2,0);
       end;
     {WindowsNT,Windows2000}
     VER_PLATFORM_WIN32_NT:
       begin
         keybd_event(VK_LMENU,$56,Flags1,0) ;
         keybd_event(VK_SNAPSHOT,$79,Flags1,0) ;
         keybd_event(VK_LMENU,$56,Flags2,0) ;
         keybd_event(VK_SNAPSHOT,$79,Flags2,0)
       end;
     else
       begin
         exit;
       end;
     end;
     Application.ProcessMessages;
     {�r�b�g�}�b�v�I�u�W�F�N�g���쐬}
     ABitmap:=TBitmap.Create;

     {�N���b�v�{�[�g�̓��e���r�b�g�}�b�v�ɑ��}
     ABitmap.Assign(Clipboard);
     {�C�ӂ̘g�ɓ����c����Ŋg��k�����邽�߂̉摜�̏c������v�Z}
     BitmapRatio:=ABitmap.Height/ABitmap.Width;
     {�p���̍��[����p������10%���̈ʒu�������D������ʂ�Ԃ���ꍇ���l����}
     {�p���̏�[�͍��[�Ɠ������@�����󂯂�}
     {����ʒu�̉��[�͉摜�̏c���䂩��v�Z}
     try
       if (PrintDialog1.Execute) then begin
         TTempplPrev(FplPrev).plSetPrinter.GetPrinterInfo(False);
         {�v�����^����Acrobat�Ƃ��������񂪂�������o�͂��Ȃ�}
         if (AnsiPos('ACROBAT',AnsiUpperCase(TTempplPrev(FplPrev).plSetPrinter.PrinterName))=0) then begin
           PWidth:=Printer.PageWidth;
           Xl:=PWidth div 10;
           Yt:=Xl div 2;
           Xr:=PWidth-Xl;
           Yb:=Yt+Round((Xr-Xl)*BitmapRatio);
           {2003.09.10 try�`finally�g�p}
           try
             Printer.BeginDoc;
             Printer.Canvas.StretchDraw(Rect(Xl,Yt,Xr,Yb),ABitmap);
             Application.ProcessMessages;
           finally
             Printer.EndDoc;
           end;
         end;
       end;
     finally
       ABitmap.Free;
       {�ۑ����Ă������v�����^�ݒ�R���|�[�l���g�̐ݒ��Ǐo��}
       TTempplPrev(FplPrev).ReadPrinterSetting;
       DrawMetaImage;
       Application.ProcessMessages;
     end;
end;
//====================================================================
//    �v���r���[�t�H�[�����N���b�v�{�[�g��
//
//    �|�b�v�A�b�v���j���[����[��ʃR�s�[]�œ���.
//    ���[�v���\�t�g�ɓ\�t���āC�����p�̕������쐬����ꍇ���Ɏg�p
//    ��ʂ̃v���p�e�B�̌��ʂ�[�A�j���[�V����]��L���ɂ��Ă���ƃ|�b
//    �v�A�b�v���j���[�̈ꕔ���R�s�[���Ă��܂��̂Œ��ӁD
//====================================================================
procedure TplPrevForm.ActionDispCopyExecute(Sender: TObject);
var
     OSver : TOSVERSIONINFO;
     Flags1: Word;
     Flags2: Word;
begin
     Flags1:=KEYEVENTF_EXTENDEDKEY;
     Flags2:=KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP;
     {OS�̎�ނ��擾}
     OSver.dwOSVersionInfoSize:=SizeOf(OSver);
     GetVersionEx(OSver);
     {���݃A�N�e�B�u�ȃE�C���h�D��ʂ��N���b�v�{�[�h��}
     case  OSver.dwPlatformId of
     {Windows95,98}
     VER_PLATFORM_WIN32_WINDOWS:
       begin
         keybd_event(VK_SNAPSHOT,0,Flags1,0);
         keybd_event(VK_SNAPSHOT,0,Flags2,0);
       end;
     {WindowsNT,Windows2000}
     VER_PLATFORM_WIN32_NT:
       begin
         keybd_event(VK_LMENU,$56,Flags1,0) ;
         keybd_event(VK_SNAPSHOT,$79,Flags1,0) ;
         keybd_event(VK_LMENU,$56,Flags2,0) ;
         keybd_event(VK_SNAPSHOT,$79,Flags2,0);
       end;
     else
       exit;
     end;
     Application.ProcessMessages;
end;
//====================================================================
//    ����{�^��
//====================================================================
procedure TplPrevForm.CloseBtnClick(Sender: TObject);
begin
     Close;
end;
//====================================================================
//    CloseQuery����
//====================================================================
procedure TplPrevForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
     if FplPrev<>nil then begin
       if Assigned(TTempplPrev(FplPrev).OnFormCloseQuery) then begin
         TTempplPrev(FplPrev).OnFormCloseQuery(Self,CanClose);
       end;
       {Ver4.3�ňȉ�2�s�ǉ�}
       if CanClose then begin
         TTempplPrev(FplPrev).ViewWidth :=0;
         TTempplPrev(FplPrev).ViewHeight:=0;
       end;
     end;
end;
//====================================================================
//  ���鏈��
//  ���������V���t�H�[����Action�̒l�͏��caFree�ɂȂ�
//  OnClose�͔p�~�D�����OnFormClose���g�p����D
//====================================================================
procedure TplPrevForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     if FplPrev<>nil then begin
       if Assigned(TTempplPrev(FplPrev).OnFormClose) then begin
         TTempplPrev(FplPrev).OnFormClose(Self,Action);
       end;
       //Ver4.55�Œǉ�
       //�t�H�[������鎞�ɂ̓C���[�W�̉摜���N���A
       Shape1.Visible:=False;
       Shape2.Visible:=False;
       Image1.Picture.Assign(nil);
       {���̃t�H�[�������������������̂ł���Ȃ�}
       if TTempplPrev(FplPrev).AutoCreateForm then begin
         TTempplPrev(FplPrev).AutoCreateForm:=False;
         TTempplPrev(FplPrev).FormDispFlag  :=False;
         TTempplPrev(FplPrev).FormName      :='';
         {caFree���L���Ȃ̂�Show�̎��̂�}
         Action:=caFree;
       end;
     end;
end;
//====================================================================
//    Destroy����
//====================================================================
procedure TplPrevForm.FormDestroy(Sender: TObject);
begin
     if FplPrev<>nil then begin
       if Assigned(TTempplPrev(FplPrev).OnFormDestroy) then begin
         TTempplPrev(FplPrev).OnFormDestroy(Self);
       end;
     end;
end;
//====================================================================
//    �R�[�h�I��
//====================================================================
end.
