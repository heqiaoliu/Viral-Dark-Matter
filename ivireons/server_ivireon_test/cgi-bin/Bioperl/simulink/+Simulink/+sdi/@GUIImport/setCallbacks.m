function setCallbacks(this)

    % Common dialog callbacks
    %
    % Copyright 2010 The MathWorks, Inc.

    set(this.HDialog,      'ResizeFcn',       @this.callback_DialogResize);
    set(this.HDialog,      'CloseRequestFcn', @this.dialogCloseCallback);
    set(this.OKButton,     'Callback',        @this.callback_OKButton);
    set(this.CancelButton, 'Callback',        @this.callback_CancelButton);
    set(this.HelpButton,   'Callback',        @this.callback_HelpButton);
    
    % "Import from" callbacks
    set(this.ImportFromBaseRadio, 'Callback', @this.callback_importRadio);
    set(this.ImportFromMATRadio,  'Callback', @this.callback_importRadio);
    set(this.ImportFromMATButton,  ...
        'ActionPerformedCallback', ...
        @this.importFromMATButtonCallback);
    
    % "Import to" callbacks
    set(this.ImportToNewRadio,   'Callback', @this.callback_importRadio);
    set(this.ImportToExistRadio, 'Callback', @this.callback_importRadio);
    
    % "Import variable" callbacks - Table
    tableHeader = this.ImportVarsTT.getTableHeader();
    tableHeader = handle(tableHeader, 'callbackproperties');
    importVarsTT = handle(this.ImportVarsTT, 'callbackproperties');
    set(tableHeader, 'MouseClickedCallback',    @this.tableHeaderContextMenuClick);
    set(importVarsTT, 'MouseClickedCallback',    @this.tableBodyContextMenuClick);
    set(this.RefreshButton,   'ActionPerformedCallback', @this.callback_RefreshButton);
    set(this.SelectAllButton, 'ActionPerformedCallback', @this.callback_SelectAllButton);
    set(this.ClearAllButton,  'ActionPerformedCallback', @this.callback_ClearAllButton);
    
    % "Import variable" callbacks - Context menu
    set(this.ContextMenuRootSource,  'Callback', @this.contextMenuCallback);
    set(this.ContextMenuTimeSource,  'Callback', @this.contextMenuCallback);
    set(this.ContextMenuDataSource,  'Callback', @this.contextMenuCallback);
    set(this.ContextMenuBlockSource, 'Callback', @this.contextMenuCallback);
    set(this.ContextMenuModelSource, 'Callback', @this.contextMenuCallback);
    set(this.ContextMenuSignalLabel, 'Callback', @this.contextMenuCallback);
    set(this.ContextMenuSignalDims,  'Callback', @this.contextMenuCallback);
    set(this.ContextMenuPortIndex,   'Callback', @this.contextMenuCallback);
end