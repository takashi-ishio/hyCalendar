unit CalendarActionFactory;

interface

uses
    StrUtils, ClipBrd,
    CalendarAction, CalendarCallback, CalendarDocument, ColorPair;


    function createAppendPasteAction(form: TCalendarCallback; doc: TCalendarDocument; d: TDateTime; replaced: string; clipboard_contents: string): TCalendarAction;
    function createPasteAction(form: TCalendarCallback; doc: TCalendarDocument; d: TDateTime; replaced: string; clipboard_contents: string): TCalendarAction;
    function createCutAction(form: TCalendarCallback; doc: TCalendarDocument; d: TDateTime; cut: string): TCalendarAction;




implementation


type
    TCalendarPasteAction = class(TCalendarAction)
    private
        FDate: TDateTime;
        FDocument: TCalendarDocument;
        FReplaced: string;
        FClipboard: string;
        FWindow: TCalendarCallback;
    public
        constructor Create(form: TCalendarCallback; doc: TCalendarDocument; d: TDateTime; replaced: string; clipboard_contents: string);
        destructor Destroy; override;
        procedure doAction; override;
        procedure undoAction; override;
    end;

    TCalendarAppendPasteAction = class(TCalendarAction)
    private
        FDate: TDateTime;
        FDocument: TCalendarDocument;
        FReplaced: string;
        FClipboard: string;
        FWindow: TCalendarCallback;
    public
        constructor Create(form: TCalendarCallback; doc: TCalendarDocument; d: TDateTime; replaced: string; clipboard_contents: string);
        destructor Destroy; override;
        procedure doAction; override;
        procedure undoAction; override;
    end;

    TCalendarCutAction = class(TCalendarAction)
    private
        FDocument: TCalendarDocument;
        FCut: string;
        FTarget: TDateTime;
        FWindow: TCalendarCallback;
    public
        constructor Create(form: TCalendarCallback; doc: TCalendarDocument; d: TDateTime; cut: string); // item: TCalendarItem; cut: string);
        destructor Destroy; override;
        procedure doAction; override;
        procedure undoAction; override;
    end;


function createAppendPasteAction(form: TCalendarCallback; doc: TCalendarDocument; d: TDateTime; replaced: string; clipboard_contents: string): TCalendarAction;
begin
    Result := TCalendarAppendPasteAction.Create(form, doc, d, replaced, clipboard_contents);
end;

function createPasteAction(form: TCalendarCallback; doc: TCalendarDocument; d: TDateTime; replaced: string; clipboard_contents: string): TCalendarAction;
begin
    Result := TCalendarPasteAction.Create(form, doc, d, replaced, clipboard_contents);
end;

function createCutAction(form: TCalendarCallback; doc: TCalendarDocument; d: TDateTime; cut: string): TCalendarAction;
begin
    Result := TCalendarCutAction.Create(form, doc, d, cut);
end;

destructor TCalendarPasteAction.Destroy;
begin

end;

destructor TCalendarCutAction.Destroy;
begin

end;


constructor TCalendarPasteAction.Create(form: TCalendarCallback; doc: TCalendarDocument; d: TDateTime; replaced: string; clipboard_contents: string);
begin
    FDocument := doc;
    FDate := d;
    FReplaced  := replaced;
    FClipboard := clipboard_contents;
    FWindow := form;
end;

procedure TCalendarPasteAction.doAction;
begin
    FWindow.setEnforceSelectDayWithoutMovePage(true);
    FDocument.setDayText(FDate, FClipboard);
    //FItem.setString(FClipboard);
    FWindow.CalendarRepaint;
    FWindow.setDirty;
    FWindow.MoveDate(FDate);
    //FWindow.MoveDate(Fitem.getDate, false);
    FWindow.setEnforceSelectDayWithoutMovePage(false);
end;

procedure TCalendarPasteAction.undoAction;
begin
    FWindow.setEnforceSelectDayWIthoutMovePage(true);
    FDocument.setDayText(FDate, FReplaced);
    //FItem.setString(Freplaced);
    FWindow.CalendarRepaint;
    FWindow.setDirty;
    FWindow.MoveDate(FDate);
    //FWindow.MoveDate(Fitem.getDate, false);
    FWindow.setEnforceSelectDayWIthoutMovePage(false);
end;



constructor TCalendarCutAction.Create(form: TCalendarCallback; doc: TCalendarDocument; d: TDateTime; cut: string); // item: TCalendarItem; cut: string);
begin
    FDocument  := doc;
    FTarget    := d;
    FCut       := cut;
    FWindow    := form;
end;

procedure TCalendarCutAction.doAction;
begin
    FWindow.setEnforceSelectDayWIthoutMovePage(true);
    Clipboard.AsText := FCut;
    FDocument.setDayText(FTarget, '');
    //FItem.setString('');
    FWindow.CalendarRepaint;
    FWindow.setDirty;
    FWindow.MoveDate(FTarget);
    FWindow.setEnforceSelectDayWIthoutMovePage(false);
end;

procedure TCalendarCutAction.undoAction;
begin
    FWindow.setEnforceSelectDayWIthoutMovePage(true);
    FDocument.setDayText(FTarget, FCut);
    //FItem.setString(FCut);
    FWindow.CalendarRepaint;
    FWindow.setDirty;
    FWindow.MoveDate(FTarget);
    FWindow.setEnforceSelectDayWIthoutMovePage(false);
end;



destructor TCalendarAppendPasteAction.Destroy;
begin

end;

constructor TCalendarAppendPasteAction.Create(form: TCalendarCallback; doc: TCalendarDocument; d: TDateTime; replaced: string; clipboard_contents: string);
begin
    FDocument := doc;
    FDate := d;
    FReplaced  := replaced;
    FClipboard := clipboard_contents;
    FWindow := form;
end;

procedure TCalendarAppendPasteAction.doAction;
var
  s: string;
begin
    FWindow.setEnforceSelectDayWithoutMovePage(true);
    if AnsiEndsStr(#13#10, FReplaced) or (FReplaced = '') then
        s := FReplaced + FClipboard
    else
        s := FReplaced + #13#10 + FClipboard;
    FDocument.setDayText(FDate, s);
    FWindow.CalendarRepaint;
    FWindow.setDirty;
    FWindow.MoveDate(FDate);
    FWindow.setEnforceSelectDayWithoutMovePage(false);
end;

procedure TCalendarAppendPasteAction.undoAction;
begin
    FWindow.setEnforceSelectDayWIthoutMovePage(true);
    FDocument.setDayText(FDate, FReplaced);
    FWindow.CalendarRepaint;
    FWindow.setDirty;
    FWindow.MoveDate(FDate);
    FWindow.setEnforceSelectDayWIthoutMovePage(false);
end;


end.
