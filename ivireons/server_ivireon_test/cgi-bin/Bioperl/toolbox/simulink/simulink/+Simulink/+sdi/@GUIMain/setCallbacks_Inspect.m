function setCallbacks_Inspect(this)

    % Copyright 2009-2010 The MathWorks, Inc.
    
    TableHeader = this.InspectTT.TT.getTableHeader();
    TableHeader = handle(TableHeader, 'callbackproperties');
    set(TableHeader, 'MouseClickedCallback',       ...
        {@this.tableHeaderContextMenuClick_Inspect,...
        this.InspectTT});
    hInspectTT = handle(this.InspectTT.TT, 'callbackproperties');
    set(hInspectTT, 'KeyPressedCallback', @this.dialogKeyPress);

    % Color cell editor
    this.hColorEditorInsp = handle(this.colorEditorInsp, 'callbackproperties');
    this.hColorEditorInsp.EditingStoppedCallback = {@(s,e)this.updateColorPlotInsp};

