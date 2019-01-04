unit SeriesItemEditDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, SeriesItem, ToolWin, Menus, Math, StdCtrls,
  Buttons, SeriesItemCondition, DayConditionPropertyEditDialog, ImgList,
  LogicalExprNode, DayConditionNode, Imm,
  SeriesItemUtil;


type
  TfrmSeriesItemEditDialog = class(TForm)
    SeriesItemTree: TTreeView;
    ToolBar1: TToolBar;
    SeriesItemPopup: TPopupMenu;
    mnuNewSeries: TMenuItem;
    ToolButton3: TToolButton;
    ConditionAddBtn: TBitBtn;
    ItemAddBtn: TBitBtn;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ImageList1: TImageList;
    AddNewExprBtn: TBitBtn;
    ToolBar2: TToolBar;
    EditNodeBtn: TBitBtn;
    DeleteConditionBtn: TBitBtn;
    MoveUpBtn: TBitBtn;
    MoveDownBtn: TBitBtn;
    MoveLeftBtn: TBitBtn;
    MoveRightBtn: TBitBtn;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton9: TToolButton;
    CopyNodeBtn: TBitBtn;
    ToolButton1: TToolButton;
    procedure mnuAddNewSeriesClick(Sender: TObject);
    procedure SeriesItemTreeContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure mnuAddNewConditionClick(Sender: TObject);
    procedure DeleteConditionBtnClick(Sender: TObject);
    procedure SeriesItemTreeChange(Sender: TObject; Node: TTreeNode);
    procedure MoveLeftBtnClick(Sender: TObject);
    procedure MoveRightBtnClick(Sender: TObject);
    procedure MoveUpBtnClick(Sender: TObject);
    procedure MoveDownBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SeriesItemTreeDblClick(Sender: TObject);
    procedure mnuEditItemClick(Sender: TObject);
    procedure mnuAddNewExprClick(Sender: TObject);
    procedure SeriesItemTreeStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure SeriesItemTreeMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SeriesItemTreeDragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure SeriesItemTreeDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure CopyNodeBtnClick(Sender: TObject);
    procedure EditNodeBtnClick(Sender: TObject);
    procedure AddNewExprBtnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
  private
    { Private �錾 }
    FItemList: TSeriesItemList;
    FAfterDblClick: boolean;
    FInitialized: boolean;

    procedure extractListToTree;
    procedure updateTreeToList;
    procedure setItemList(list: TSeriesItemList);
    function SelectedSeriesItem: TSeriesItem;

    procedure setImageIndex(node: TTreeNode);
    function isSeriesNode(node: TTreeNode): boolean;
    function isConditionNode(node: TTreeNode): boolean;
    function isExprNode(node: TTreeNode): boolean;
    procedure duplicateNode(src, dest: TTreeNode);

    function getSeriesItem(node: TTreeNode): TSeriesItem;
    function getSeriesItemCondition(node: TTreeNode): TSeriesItemCondition;
    function getLogicalExprNode(node: TTreeNode): TLogicalExprNode;
    function getDayConditionNode(node: TTreeNode): TDayConditionNode;

    procedure updateConditionProperty(item: TDayConditionNode);

  public
    { Public �錾 }
    procedure ShowModalWithSelectNode(item: TSeriesItem);
    procedure updateTree;

    function AddDateToSomeItem(date: TDateTime): boolean;
    function AddYoubiToSomeItem(date: TDateTime; youbi: integer): boolean;
    function AddExcludedDateToSelectedItem(date: TDateTime; index: integer): boolean;

    property SeriesItemList: TSeriesItemList read FItemList write setItemList;
  end;

var
  frmSeriesItemEditDialog: TfrmSeriesItemEditDialog;

implementation

uses SeriesItemProeprtyEditDialog, LogicalExprPropertyEditDialog,
  DocumentManager,
 Calendar, Contnrs, SeriesItemSelectDialog;

const
    crDragCopyCursor = 1;
    crDragMoveCursor = 2;

//    IMAGE_SERIESITEM = 0;
    IMAGE_CONDITION  = 0;
    IMAGE_CONDITION_DISABLED = 1;
    IMAGE_NORMAL_SERIES = 2;
    IMAGE_HOLIDAY_SERIES = 4;
    IMAGE_NORMAL_DAYNAME_SERIES = 6;
    IMAGE_HOLIDAY_DAYNAME_SERIES = 8;
    IMAGE_NORMAL_HIDDEN_SERIES = 3;
    IMAGE_HOLIDAY_HIDDEN_SERIES = 10;
    IMAGE_EXPR = 12;
    IMAGE_EXPR_DISABLED = 13;

type
    TTreeDragObject = class(TDragObjectEx)
    private
        FNode : TTreeNode;
        FCopy : boolean;
    protected
        function GetDragCursor(Accepted: Boolean; X, Y: Integer): TCursor; override;
    public
        property Node : TTreeNode read FNode write FNode;
        property Copy : boolean read FCopy write FCopy;
    end;


{$R *.dfm}

function TfrmSeriesItemEditDialog.getSeriesItem(node: TTreeNode): TSeriesItem;
begin
    Result := TObject(node.Data) as TSeriesItem;
end;

function TfrmSeriesItemEditDialog.getSeriesItemCondition(node: TTreeNode): TSeriesItemCondition;
begin
    Result := TObject(node.Data) as TSeriesItemCondition;
end;

function TfrmSeriesItemEditDialog.getLogicalExprNode(node: TTreeNode): TLogicalExprNode;
begin
    Result := TObject(node.Data) as TLogicalExprNode;
end;

function TfrmSeriesItemEditDialog.getDayConditionNode(node: TTreeNode): TDayConditionNode;
begin
    Result := TObject(node.Data) as TDayConditionNode;
end;

procedure TfrmSeriesItemEditDialog.updateTree;
begin
    extractListToTree;
end;

function TfrmSeriesItemEditDialog.AddYoubiToSomeItem(date: TDateTime; youbi: integer): boolean;
var
  seriesItem: TSeriesItem;
begin
  result := false;
    if frmSeriesItemSelectDialog = nil then  Application.CreateForm(TfrmSeriesItemSelectDialog, frmSeriesItemSelectDialog);
    seriesItem := frmSeriesItemSelectDialog.Execute(SeriesItemList, true);
    if seriesItem <> nil then begin
        // �c���[���A�b�v�f�[�g
        SeriesItemUtil.AddIncludedYoubi(seriesItem, date, Youbi);
        updateTree;
        ShowModalWithSelectNode(seriesItem);
        Result := true;
    end;
end;

// ���ݕ\�����̃A�C�e�����X�g���Q�Ƃ���̂ŁC�ҏW�����[�h�ɓ����Ă��瓮�삵�Ȃ����Ƃɒ���
function TfrmSeriesItemEditDialog.AddExcludedDateToSelectedItem(date: TDateTime; index: integer): boolean;
var
    seriesItem: TSeriesItem;
    l: TStringList;
begin
    Result := false;
    // �|�b�v�A�b�v�������t������t���X�g�����
    l := TStringList.Create;
    TDocumentManager.getInstance.getEditableSeriesItems(date, l);

    if index < l.Count then begin
        seriesItem := l.Objects[index] as TSeriesItem;
        if MessageDlg('���̓��t�������\��u' + seriesItem.Name + '�v���珜�O���܂��D'#13#10 +
                      '��낵���ł����H'#13#10 +
                      '�i���O�ݒ�͎����\��Ǘ��_�C�A���O��������ł��܂��j', mtConfirmation,
                      [mbYes, mbNo], 0) = mrYes then begin
            SeriesItemUtil.addExcludedDay(seriesItem, date);
            frmSeriesItemEditDialog.updateTree;
            Result := true;
            TDocumentManager.getInstance.updateSeriesItems;
        end;
    end;
    l.Free;
end;

function TfrmSeriesItemEditDialog.AddDateToSomeItem(date: TDateTime): boolean;
var
    SeriesItem: TSeriesItem;
begin
  result := false;
    // �_�C�A���O��\�����Ď����\���I�ԁi���邢�͍쐬����j
    if frmSeriesItemSelectDialog = nil then  Application.CreateForm(TfrmSeriesItemSelectDialog, frmSeriesItemSelectDialog);
    seriesItem := frmSeriesItemSelectDialog.Execute(SeriesItemList, true);
    if seriesItem <> nil then begin
        // �c���[���A�b�v�f�[�g
        SeriesItemUtil.addIncludedDay(SeriesItem, date);
        updateTree;
        ShowModalWithSelectNode(seriesItem);
        result := true;
    end;
end;

procedure TfrmSeriesItemEditDialog.ShowModalWithSelectNode(item: TSeriesItem);
var
    node: TTreeNode;

begin
    node := SeriesItemTree.Items.GetFirstNode;
    while node <> nil do begin
        if (getSeriesItem(node) = item) then begin
            node.Selected := true;
            node.Expand(false);
        end;
        node := node.getNextSibling;
    end;
    ShowModal;
end;

procedure TfrmSeriesItemEditDialog.setImageIndex(node: TTreeNode);
var
    item: TSeriesItem;
begin
    if isSeriesNode(node) then begin
        item := getSeriesItem(node);
        if item.IsHidden then begin
            node.ImageIndex := IfThen(item.IsHoliday, IMAGE_HOLIDAY_HIDDEN_SERIES, IMAGE_NORMAL_HIDDEN_SERIES);
        end else if item.IsShownAsDayName then begin
            node.ImageIndex := ifThen(item.IsHoliday, IMAGE_HOLIDAY_DAYNAME_SERIES, IMAGE_NORMAL_DAYNAME_SERIES);
        end else begin
            node.ImageIndex := ifThen(item.IsHoliday, IMAGE_HOLIDAY_SERIES, IMAGE_NORMAL_SERIES);
        end;
    end else if isConditionNode(node) then begin
        node.ImageIndex    := IfThen(getSeriesItemCondition(node).Disabled, IMAGE_CONDITION_DISABLED, IMAGE_CONDITION);
    end else if isExprNode(node) then begin
        node.ImageIndex := IfThen(getLogicalExprNode(node).Disabled, IMAGE_EXPR_DISABLED, IMAGE_EXPR);
    end;
    node.SelectedIndex := node.ImageIndex;
end;

function TfrmSeriesItemEditDialog.isSeriesNode(node: TTreeNode): boolean;
begin
    Result := (TObject(node.Data) is TSeriesItem);
end;

function TfrmSeriesItemEditDialog.isConditionNode(node: TTreeNode): boolean;
begin
    Result := (TObject(node.Data) is TDayConditionNode);
end;

function TfrmSeriesItemEditDialog.isExprNode(node: TTreeNode): boolean;
begin
    Result := (TObject(node.Data) is TLogicalExprNode);
end;

procedure TfrmSeriesItemEditDialog.setItemList(list: TSeriesItemList);
begin
    FItemList := list;
    extractListToTree;
end;

function TfrmSeriesItemEditDialog.SelectedSeriesItem: TSeriesItem;
var
    node: TTreeNode;
begin
    Result := nil;
    node := SeriesItemTree.Selected;
    if (node <> nil)and isSeriesNode(node) then Result := getSeriesItem(node);
end;


procedure TfrmSeriesItemEditDialog.extractListToTree;
// FItemList �̒��g�� TreeView �ɓW�J
var
    i, j: integer;
    node, child: TTreeNode;
    item: TSeriesItem;

    procedure expandChildCondition(node: TTreeNode; item: TLogicalExprNode);
    var
        i: integer;
        child: TTreeNode;
    begin
        for i:=0 to item.ConditionCount-1 do begin
            child := SeriesItemTree.Items.AddChildObject(node, item.Conditions[i].asString, item.Conditions[i]);
            setImageIndex(child);
            if item.Conditions[i] is TLogicalExprNode then begin
                expandChildCondition(child, TLogicalExprNode(item.Conditions[i]));
            end;
        end;
    end;
begin
    SeriesItemTree.Items.Clear;
    SeriesItemTree.Items.BeginUpdate;
    for i:=0 to FItemList.Count-1 do begin
        item := FItemList.Items[i];
        node := seriesItemTree.Items.AddObject(nil, item.Name, item);
        setImageIndex(node);

        for j:=0 to item.ConditionCount-1 do begin
            if item.Conditions[j].Rank = 0 then begin
                child := SeriesItemTree.Items.AddChildObject(node, item.Conditions[j].asString, item.Conditions[j]);
                setImageIndex(child);
                if item.Conditions[j] is TLogicalExprNode then expandChildCondition(child, TLogicalExprNode(item.Conditions[j]));
            end;
        end;
    end;
    SeriesItemTree.Items.EndUpdate;
end;

procedure TfrmSeriesItemEditDialog.updateTreeToList;
var
    SeriesItemIndex: integer;
    node: TTreeNode;
    child: TTreeNode;

    procedure parseChildren(parent: TTreeNode);
    var
        node: TTreeNode;
    begin
        node := parent.getFirstChild;
        while node <> nil do begin
            if isExprNode(node) then parseChildren(node);
            getLogicalExprNode(parent).addChild(getSeriesItemCondition(node));
            node := node.getNextSibling;
        end;
    end;

begin
    // FItemList �́C���Ԃ͈���Ă��ŐV�̃A�C�e�����X�g��ێ����Ă���
    // �\��I�u�W�F�N�g����בւ��āC�q����S���N���A���Ă���
    SeriesItemIndex := 0;
    node := SeriesItemTree.Items.GetFirstNode;
    while node <> nil do begin
        if isSeriesNode(node) then begin
            FItemList.Exchange(SeriesItemIndex, FItemList.IndexOf(getSeriesItem(node)));
            FItemList[SeriesItemIndex].clearCondition;
            inc(SeriesItemIndex);
        end else if isExprNode(node) then begin
            getLogicalExprNode(node).clearChildren;
        end;
        node := node.GetNext;
    end;
    // �c���[���p�[�X���ă��X�g���X�V
    node := SeriesItemTree.Items.GetFirstNode;
    while node <> nil do begin
        child := node.getFirstChild;
        while child <> nil do begin
            if isExprNode(child) then parseChildren(child);
            getSeriesItem(node).addCondition(getSeriesItemCondition(child));
            child := child.getNextSibling;
        end;
        node := node.GetNextSibling;
    end;
    //TDocumentManager.getInstance.updateHolidayManager;
    //FItemList.updateHolidayManager;
end;


procedure TfrmSeriesItemEditDialog.mnuAddNewConditionClick(Sender: TObject);
// �V�����������C�I�����ꂽ�m�[�h�̔z���ɒǉ�
// TLogicalExpr �z���ɒǉ����邱�Ƃ��\�ɂ���
var
    new_condition: TDayConditionNode;
    node : TTreeNode;
begin

    if (SeriesItemTree.Selected <> nil) then begin

        updateConditionProperty(nil);

        if frmDayConditionPropertyEditDialog.ShowModal = mrOK then begin

            node := SeriesItemTree.Selected;
            new_condition := TDayConditionNode.Create;
            frmDayConditionPropertyEditDialog.getConditionProperty(new_condition);

            if isConditionNode(node) then node := node.Parent;

            node := SeriesItemTree.Items.AddChildObject(node, new_condition.asString, new_condition);
            setImageIndex(node);
            SeriesItemTree.Selected := node;
            SeriesItemTree.SetFocus;

            frmCalendar.setDirty;
        end;
    end;
end;

procedure TfrmSeriesItemEditDialog.mnuAddNewExprClick(Sender: TObject);
var
    expr: TLogicalExprNode;
    node : TTreeNode;
begin

    if (SeriesItemTree.Selected <> nil) then begin

        frmLogicalExprPropertyEditDialog.setLogicalExpr(nil);
        if frmLogicalExprPropertyEditDialog.ShowModal = mrOK then begin

            node := SeriesItemTree.Selected;
            expr := TLogicalExprNode.Create;
            frmLogicalExprPropertyEditDialog.getLogicalExpr(expr);

            if isConditionNode(node) then node := node.Parent;

            node := SeriesItemTree.Items.AddChildObject(node, expr.asString, expr);
            setImageIndex(node);
            SeriesItemTree.Selected := node;
            SeriesItemTree.SetFocus;

            frmCalendar.setDirty;
        end;
    end;
end;

procedure TfrmSeriesItemEditDialog.mnuAddNewSeriesClick(Sender: TObject);
var
    item: TSeriesItem;
    node: TTreeNode;
begin
    frmSeriesItemPropertyEditDialog.setSeriesItem(nil);
    if frmSeriesItemPropertyEditDialog.ShowModal = mrOK then begin
        item := FItemList.Add;
        frmSeriesItemPropertyEditDialog.getSeriesItem(item);
        node := SeriesItemTree.Items.AddObject(nil, item.Name, item);
        setImageIndex(node);
        SeriesItemTree.Selected := node;
        SeriesItemTree.SetFocus;

        frmCalendar.setDirty;

    end;
end;


procedure TfrmSeriesItemEditDialog.SeriesItemTreeContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
// �E�N���b�N���ꂽ��m�[�h�̎�ނɍ��킹�ă��j���[��ύX
// (�E�N���b�N���m�[�h�I�������j
var
    node: TTreeNode;

    procedure addItem(caption: string; event: TNotifyEvent; shortcut: string);
    var
        mnu: TMenuItem;
    begin
        mnu := TMenuItem.Create(self);
        mnu.Caption := caption;
        mnu.OnClick := event;
        mnu.ShortCut := TextToShortCut(shortcut);
        SeriesItemPopup.Items.Add(mnu);
    end;

begin

    SeriesItemPopup.Items.Clear;

    node := SeriesItemTree.GetNodeAt(MousePos.X, MousePos.Y);
    if (node <> nil) then begin
        SeriesItemTree.Selected := node;
        addItem('�ҏW(&E)', mnuEditItemClick, 'Enter');
        addItem('�����̒ǉ�(&C)', mnuAddNewConditionClick, '');
        addItem('�������̒ǉ�(&G)', mnuAddNewExprClick, '');
        addItem('�����\��̒ǉ�(&A)', mnuAddNewSeriesClick, 'Ctrl+N');
        addItem('-', nil, '');
        addItem('�m�[�h�̕���(&D)', CopyNodeBtnClick, '');
        addItem('-', nil, '');
        addItem('�폜', DeleteConditionBtnClick, 'Del');
    end else begin
        addItem('�����\��̒ǉ�(&A)', mnuAddNewSeriesClick, 'Ctrl+N');
    end;

end;

procedure TfrmSeriesItemEditDialog.DeleteConditionBtnClick(Sender: TObject);
var
    condition: TSeriesItemCondition;
    node: TTreeNode;
begin
    node := SeriesItemTree.Selected;
    if node = nil then exit;
    if MessageDlg(node.Text + ' ���폜���܂��D��낵���ł����H', mtConfirmation, mbOKCancel, 0) = mrOK then begin

        // �폜�̂Ƃ��́C�c���[�ƃA�C�e���̑Ή������ĂȂ��Ƃ܂����̂ŃA�b�v�f�[�g
        updateTreeToList;

        if isSeriesNode(node) then begin
            FItemList.Delete(FItemList.IndexOf(getSeriesItem(node)));
        end else begin
            condition := getSeriesItemCondition(node);
            if isExprNode(node.Parent) then
                getLogicalExprNode(node.Parent).removeChild(condition)
            else
                getSeriesItem(node.Parent).removeCondition(condition);
            condition.Free;
        end;

        SeriesItemTree.Items.Delete(SeriesItemTree.Selected);
        SeriesItemTree.SetFocus;
        frmCalendar.setDirty;
    end;

end;

procedure TfrmSeriesItemEditDialog.SeriesItemTreeChange(Sender: TObject;
  Node: TTreeNode);
begin
    // Clear �r���ȂǂɌĂ΂ꂽ�ꍇ��
    // Node �������Ȓl��ێ����Ă���̂ŁC������ʉ߂��Ȃ��悤�ɂ���
    if not Self.Visible then exit;

    if Node <> nil then begin
        MoveUpBtn.Enabled := true;
        MoveDownBtn.Enabled := true;

        if isSeriesNode(node) then begin
            MoveLeftBtn.Enabled := false;
            MoveRightBtn.Enabled := false;
        end else if isExprNode(node) or isConditionNode(node) then begin
            MoveLeftBtn.Enabled := (Node.Parent <> nil) and isExprNode(Node.Parent); // �m�[�h�����̔z��
            MoveRightBtn.Enabled := (Node.getPrevSibling <> nil) and isExprNode(Node.getPrevSibling);
        end;
    end;

end;

procedure TfrmSeriesItemEditDialog.MoveLeftBtnClick(Sender: TObject);
var
    node: TTreeNode;
    parent_node: TTreeNode;
begin
    node := SeriesItemTree.Selected;
    parent_node := node.Parent;

    if (parent_node <> nil) and isExprNode(parent_node) then begin
        // �e�̌Z�� -- �e�̐e�̎q�ɂȂ�悤�Ɉړ�
        if parent_node.getNextSibling <> nil then begin
            node.MoveTo(parent_node.getNextSibling, naInsert);
        end else begin
            node.MoveTo(parent_node, naAdd);
        end;
        SeriesItemTree.Selected := node;
        SeriesItemTree.SetFocus;
        SeriesItemTreeChange(Sender, node);
        frmCalendar.setDirty;
    end;
end;

procedure TfrmSeriesItemEditDialog.MoveRightBtnClick(Sender: TObject);
var
    node: TTreeNode;
    sibling: TTreeNode;
begin
    node := SeriesItemTree.Selected;
    sibling := node.getPrevSibling;
    if (node <> nil) and (sibling <> nil)and isExprNode(sibling) then begin
        node.MoveTo(sibling, naAddChild);

        SeriesItemTree.Selected := node;
        SeriesItemTree.SetFocus;
        SeriesItemTreeChange(Sender, node);
        frmCalendar.setDirty;
    end;

end;

procedure TfrmSeriesItemEditDialog.MoveUpBtnClick(Sender: TObject);
var
    node: TTreeNode;
    parent: TTreeNode;

begin
    node := SeriesItemTree.Selected;
    if node = nil then exit;

    // �\��Ȃ珇������ւ�����
    if isSeriesNode(node) then begin
        if node.getPrevSibling <> nil then begin
            node.MoveTo(node.getPrevSibling, naInsert)
        end;
    end else begin
        // �����Ȃ�����Ԉړ�
        parent := node.Parent;
        if node.getPrevSibling <> nil then begin
            // �ʏ�͌Z�����ֈړ�
            node.MoveTo(node.getPrevSibling, naInsert);
        end else begin
            // ��[�̂Ƃ��́C�e�̌Z�ɂȂ�D
            if isSeriesNode(parent) then begin
                // �������C�e��SeriesItem �̂Ƃ��́C[����]��[�\��]�ɂȂ�Ȃ��̂�
                // �ׂ�[�\��]�̍Ō�̎q�Ƃ��ĉ����
                if parent.GetPrevSibling <> nil then
                    node.MoveTo(parent.getPrevSibling, naAddChild);
            end else begin
                // �e�̌Z�ֈړ�
                node.MoveTo(parent, naInsert);

            end;
        end;
    end;

    SeriesItemTree.Selected := node;
    SeriesItemTree.SetFocus;
    SeriesItemTreeChange(Sender, node);
    frmCalendar.setDirty;
end;

procedure TfrmSeriesItemEditDialog.MoveDownBtnClick(Sender: TObject);
var
    node: TTreeNode;
    parent: TTreeNode;

begin
    node := SeriesItemTree.Selected;
    if isSeriesNode(node) then begin
        // �\��Ȃ��̎��ֈړ��i�킪���Ȃ��ꍇ�͈ړ����Ȃ��j
        if node.getNextSibling <> nil then begin
            if (node.getNextSibling.getNextSibling <> nil) then node.MoveTo(node.getNextSibling.getNextSibling, naInsert)
            else node.MoveTo(node.getNextSibling, naAdd);
        end;
    end else begin
        // �q�m�[�h���ړ�����ꍇ��
        parent := node.Parent;
        // �킪����ꍇ�͒�̎��ֈړ�
        if node.getNextSibling <> nil then begin
            if (node.getNextSibling.getNextSibling <> nil) then node.MoveTo(node.getNextSibling.getNextSibling, naInsert)
            else node.MoveTo(node.getNextSibling, naAdd);
        end else begin
            // �킪���Ȃ��ꍇ�C�e�̒�ɂȂ�

            if isSeriesNode(parent) then begin
                // �������C�e��SeriesItem �̂Ƃ��́C[����]��[�\��]�ɂȂ�Ȃ��̂�
                // �ׂ�[�\��]�̍ŏ��̎q�Ƃ��ĉ����
                if parent.getNextSibling <> nil then begin
                    node.MoveTo(parent.getNextSibling, naAddChildFirst);
                end;
            end else begin
                // �e�̒�(��������Ȃ�)�ֈړ�
                if parent.getNextSibling <> nil then begin
                    if parent.getNextSibling.getNextSibling <> nil then node.MoveTo(node.getNextSibling.getNextSibling, naInsert)
                    else node.MoveTo(parent, naAdd);
                end;
            end;

        end;
    end;

    SeriesItemTree.Selected := node;
    SeriesItemTree.SetFocus;
    SeriesItemTreeChange(Sender, node);
    frmCalendar.setDirty;
end;


procedure TfrmSeriesItemEditDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    updateTreeToList;
end;

procedure TfrmSeriesItemEditDialog.SeriesItemTreeDblClick(Sender: TObject);
begin
    if isConditionNode(SeriesItemTree.Selected) then begin
        mnuEditItemClick(Sender);
        FAfterDblClick := true;
    end;
end;

procedure TfrmSeriesItemEditDialog.mnuEditItemClick(Sender: TObject);
var
    item: TSeriesItem;
    condition: TDayConditionNode;
    expr: TLogicalExprNode;
begin
    if SeriesItemTree.Selected = nil then exit;

    if isSeriesNode(SeriesItemTree.Selected) then begin
        item := SelectedSeriesItem;
        frmSeriesItemPropertyEditDialog.setSeriesItem(item);
        if frmSeriesItemPropertyEditDialog.ShowModal = mrOK then begin
            frmSeriesItemPropertyEditDialog.getSeriesItem(item);
            SeriesItemTree.Selected.Text := item.Name;
            setImageIndex(SeriesItemTree.Selected);
            frmCalendar.setDirty;
        end;
    end else if isConditionNode(SeriesItemTree.Selected) then begin
        condition := getDayConditionNode(SeriesItemTree.Selected);
        updateConditionProperty(condition);
        if frmDayConditionPropertyEditDialog.ShowModal = mrOK then begin
            frmDayConditionPropertyEditDialog.getConditionProperty(condition);
            SeriesItemTree.Selected.Text := condition.asString;
            setImageIndex(SeriesItemTree.Selected);
            frmCalendar.setDirty;
        end;
    end else if isExprNode(SeriesItemTree.Selected) then begin
        expr := getLogicalExprNode(SeriesItemTree.Selected);
        frmLogicalExprPropertyEditDialog.setLogicalExpr(expr);
        if frmLogicalExprPropertyEditDialog.ShowModal = mrOK then begin
            frmLogicalExprPropertyEditDialog.getLogicalExpr(expr);
            SeriesItemTree.Selected.Text := expr.asString;
            setImageIndex(SeriesItemTree.Selected);
            frmCalendar.setDirty;
        end;
    end;
end;

procedure TfrmSeriesItemEditDialog.SeriesItemTreeStartDrag(Sender: TObject;
  var DragObject: TDragObject);
var
    dragNode : TTreeDragObject;
begin
    // �h���b�O�J�n�m�[�h���L��
    DragNode := TTreeDragObject.Create;
    DragNode.Node := SeriesItemTree.Selected;
    DragObject := DragNode;
end;

procedure TfrmSeriesItemEditDialog.SeriesItemTreeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
    node : TTreeNode;
begin

    if FAfterDblClick then begin
        FAfterDblClick := false;
        exit;
    end;

    node := SeriesItemTree.GetNodeAt(X, Y);
    if node = nil then exit;

    if (Button = mbLeft) then begin
        // �h���b�O�\�ȃm�[�h�Ȃ�h���b�O�J�n!
        if isConditionNode(node) or isExprNode(node) then begin
            SeriesItemTree.Selected := node;
            SeriesItemTree.BeginDrag(false);
        end;
    end;
end;

procedure TfrmSeriesItemEditDialog.SeriesItemTreeDragOver(Sender,
  Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
    DroppedNode : TTreeNode;
    DropTarget  : TTreeNode;

    node : TTreeNode;
begin

    // �J�[�\���ɂ��킹�ăX�N���[��
    if (Y > SeriesItemTree.Height - 24) then begin
        node := SeriesItemTree.TopItem.GetNextVisible;
        if node <> nil then begin
            SeriesItemTree.TopItem := SeriesItemTree.TopItem.GetNextVisible;
            SeriesItemTree.Repaint;
        end;
    end;
    if (Y < 24) then begin
        node := SeriesItemTree.TopItem.GetPrevVisible;
        if node <> nil then begin
            SeriesItemTree.TopItem := SeriesItemTree.TopItem.GetPrevVisible;
            SeriesItemTree.Repaint;
        end;
    end;

    // �h���b�O�悪�R���e�i�m�[�h�Ȃ�h���b�v����
    DroppedNode := TTreeDragObject(Source).Node;
    DropTarget  := SeriesItemTree.GetNodeAt(X, Y);
    TTreeDragObject(Source).Copy := (ssCtrl in KeyboardStateToShiftState);

    Accept := (DropTarget <> nil)and
              ( isSeriesNode(DropTarget) or
                isExprNode(DropTarget) or
                isConditionNode(DropTarget) )and
              (DropTarget <> DroppedNode);
end;


procedure TfrmSeriesItemEditDialog.duplicateNode(src, dest: TTreeNode);
var
    node: TTreeNode;
    ditem: TDayConditionNode;
    expr: TLogicalExprNode;
    item: TSeriesItem;
begin
    if isConditionNode(src) then begin
        // �����m�[�h�Ȃ畁�ʂɃR�s�[���ďI��
        updateConditionProperty(getDayConditionNode(src));
        ditem := TDayConditionNode.Create;
        frmDayConditionPropertyEditDialog.getConditionProperty(ditem);
        dest.Text := ditem.asString;
        dest.Data := ditem;
        setImageIndex(dest);
        frmCalendar.setDirty;
    end else if isExprNode(src) then begin
        // ���m�[�h�Ȃ�C�R�s�[���Ă���q�����R�s�[
        frmLogicalExprPropertyEditDialog.setLogicalExpr(getLogicalExprNode(src));
        expr := TLogicalExprNode.Create;
        frmLogicalExprPropertyEditDialog.getLogicalExpr(expr);
        dest.Text := expr.asString;
        dest.Data := expr;
        setImageIndex(dest);
        node := src.getFirstChild;
        while (node <> nil) do begin
            duplicateNode(node, SeriesItemTree.Items.AddChild(dest, ''));
            node := node.getNextSibling;
        end;
        frmCalendar.setDirty;
    end else if isSeriesNode(src) then begin
        // �\��m�[�h�Ȃ�C�R�s�[���Ă���q�����R�s�[
        item := FItemList.Add;
        frmSeriesItemPropertyEditDialog.setSeriesItem(getSeriesItem(src));
        frmSeriesItemPropertyEditDialog.getSeriesItem(item);
        dest.Data := item;
        dest.Text := item.Name;
        setImageIndex(dest);
        node := src.getFirstChild;
        while (node <> nil) do begin
            duplicateNode(node, SeriesItemTree.Items.AddChild(dest, ''));
            node := node.getNextSibling;
        end;
        frmCalendar.setDirty;
    end;
end;


procedure TfrmSeriesItemEditDialog.SeriesItemTreeDragDrop(Sender,
  Source: TObject; X, Y: Integer);
var
    DroppedNode : TTreeNode;
    DropTarget  : TTreeNode;
    node: TTreeNode;


begin
    DroppedNode := TTreeDragObject(Source).Node;
    DropTarget  := SeriesItemTree.GetNodeAt(X, Y);

    if TTreeDragObject(Source).Copy then begin
        // �K�؂ȏꏊ�Ƀm�[�h��V�K�쐬
        if isConditionNode(DropTarget) then begin
            node := SeriesItemTree.Items.Add(DropTarget, '');
        end else begin
            node := SeriesItemTree.Items.AddChildFirst(DropTarget, '');
        end;
        // �f�[�^���R�s�[
        duplicateNode(DroppedNode, node);

        setImageIndex(node);
        SeriesItemTree.Selected := node;
        SeriesItemTree.SetFocus;

    end else begin
        // �ʏ�́C�h���b�v��փm�[�h���ړ�������
        if isConditionNode(DropTarget) then begin
            if DropTarget.getNextSibling <> nil then
                DroppedNode.MoveTo(DropTarget.getNextSibling, naInsert)
            else DroppedNode.MoveTo(DropTarget, naAdd);
        end else begin
            DroppedNode.MoveTo(DropTarget, naAddChildFirst);
        end;
    end;
    frmCalendar.setDirty;
end;


function TTreeDragObject.GetDragCursor(Accepted: Boolean; X, Y: Integer): TCursor;
begin
    if Accepted and not FCopy then
        Result := crDragMoveCursor
    else if not Accepted then
        Result := crNoDrop
    else Result := crDragCopyCursor;
end;

procedure TfrmSeriesItemEditDialog.FormCreate(Sender: TObject);
begin
    Screen.Cursors[crDragCopyCursor] := LoadCursor(HInstance, 'COPY_CURSOR');
    Screen.Cursors[crDragMoveCursor] := LoadCursor(HInstance, 'MOVE_CURSOR');
    ImmAssociateContext(SeriesItemTree.Handle, 0);
    self.Left := (Screen.WorkAreaWidth - self.Width) div 2;
    self.Top  := (Screen.WorkAreaHeight - self.Height) div 2;
end;


procedure TfrmSeriesItemEditDialog.CopyNodeBtnClick(Sender: TObject);
var
    node: TTreeNode;
begin
    if SeriesItemTree.Selected = nil then exit;

    if SeriesItemTree.Selected.getNextSibling <> nil then begin
        node := SeriesItemTree.Items.Insert(SeriesItemTree.Selected.getNextSibling, '');
    end else begin
        node := SeriesItemTree.Items.Add(SeriesItemTree.Selected, '');
    end;
    duplicateNode(SeriesItemTree.Selected, node);
    setImageIndex(node);
    SeriesItemTree.Selected := node;
    SeriesItemTree.SetFocus;

end;

procedure TfrmSeriesItemEditDialog.EditNodeBtnClick(Sender: TObject);
begin
    mnuEditItemClick(Sender);
    SeriesItemTree.SetFocus;
end;

procedure TfrmSeriesItemEditDialog.AddNewExprBtnClick(Sender: TObject);
begin
    mnuAddNewExprClick(Sender);
    SeriesItemTree.SetFocus;
end;

procedure TfrmSeriesItemEditDialog.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
    case Key of
    VK_DELETE:
        DeleteConditionBtnClick(Sender);
    VK_RETURN:
        EditNodeBtnClick(Sender);
    Ord('N'):
        if ssCtrl in Shift then mnuAddNewSeriesClick(Sender);

    else
        frmCalendar.execDialogShortcut(Self, Key, Shift);
    end;

end;

procedure TfrmSeriesItemEditDialog.FormShow(Sender: TObject);
begin
    if not FInitialized then begin
      Application.CreateForm(TfrmDayConditionPropertyEditDialog, frmDayConditionPropertyEditDialog);
      Application.CreateForm(TfrmSeriesItemPropertyEditDialog, frmSeriesItemPropertyEditDialog);
      Application.CreateForm(TfrmLogicalExprPropertyEditDialog, frmLogicalExprPropertyEditDialog);
      FInitialized := true;
    end;
end;

procedure TfrmSeriesItemEditDialog.updateConditionProperty(item: TDayConditionNode);
var
    node: TTreeNode;
    list: TStrings;
begin
    list := TStringList.Create;
    node := SeriesItemTree.Items.GetFirstNode;
    while (node <> nil) do begin
        if isSeriesNode(node) then begin
            list.AddObject(getSeriesItem(node).Name, getSeriesItem(node));
        end;
        node := node.getNextSibling;
    end;
    frmDayConditionPropertyEditDialog.setSeriesItemList(list);
    list.Free;

    frmDayConditionPropertyEditDialog.setConditionProperty(item);
end;

procedure TfrmSeriesItemEditDialog.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);

    function validateReferences(var msg: string): boolean;
    var
        node: TTreeNode;
        cond: TDayConditionNode;
        available_items: TObjectList;
        last_item: TSeriesItem;
    begin
        Result := true;
        available_items := TObjectList.Create(false);
        node := SeriesItemTree.Items.GetFirstNode;
        last_item := nil;
        while node <> nil do begin
            if isSeriesNode(node) then begin
                last_item := getSeriesItem(node);
                available_items.add(last_item);
            end;

            if isConditionNode(node) then begin
                cond := getDayConditionNode(node);
                if (cond.ReferItem <> nil) and
                   ((available_items.IndexOf(cond.ReferItem) = -1) or
                    (cond.ReferItem = last_item )) then begin      // ��r������ cond.getOwner �͎g���Ă��Ȃ� (duplicate���ȂǁC�������ݒ肳��Ă��Ȃ�����)
                    msg := msg + '���ځu' + last_item.Name + '�v�̏����u' + cond.asString + '�v���u' + cond.ReferItem.Name + '�v'#13#10#13#10;
                    Result := false;
                end;
            end;

            node := node.GetNext;
        end;
        available_items.Free;
    end;

var
    msg: string;
begin
    msg := '';
    if validateReferences(msg) then CanClose := true
    else begin
        CanClose := false;
        MessageDlg('�ȉ��̍��ڂ��C�������D��x�����̗\��C�������͎������g���Q�Ƃ��Ă��܂��D�Q�Ƃ���鑤�̗\��́C�Q�Ƃ��鑤�̗\������c���[�̕��я��ŏ㑤�ɐݒ肵�Ă��������D'#13#10#13#10 + msg, mtInformation, [mbOK], 0);
    end;
end;


end.


