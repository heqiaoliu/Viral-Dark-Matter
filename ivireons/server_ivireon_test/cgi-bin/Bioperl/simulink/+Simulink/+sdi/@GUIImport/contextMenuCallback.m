function contextMenuCallback(this, h, e) %#ok<INUSD>

    % Update column visibility flags
    %
    % Copyright 2010 The MathWorks, Inc.

    RequestColumnIndex   = -1;
    RequestColumnVisible = true;
    switch h
        case this.ContextMenuRootSource
            this.RootSourceVisible = ~this.RootSourceVisible;
            RequestColumnIndex   = 0;
            RequestColumnVisible = this.RootSourceVisible;
        case this.ContextMenuTimeSource
            this.TimeSourceVisible = ~this.TimeSourceVisible;
            RequestColumnIndex   = 1;
            RequestColumnVisible = this.TimeSourceVisible;
        case this.ContextMenuDataSource
            this.DataSourceVisible = ~this.DataSourceVisible;
            RequestColumnIndex   = 2;
            RequestColumnVisible = this.DataSourceVisible;
        case this.ContextMenuBlockSource
            this.BlockSourceVisible = ~this.BlockSourceVisible;
            RequestColumnIndex   = 3;
            RequestColumnVisible = this.BlockSourceVisible;
        case this.ContextMenuModelSource
            this.ModelSourceVisible = ~this.ModelSourceVisible;
            RequestColumnIndex   = 4;
            RequestColumnVisible = this.ModelSourceVisible;
        case this.ContextMenuSignalLabel
            this.SignalLabelVisible = ~this.SignalLabelVisible;
            RequestColumnIndex   = 5;
            RequestColumnVisible = this.SignalLabelVisible;
        case this.ContextMenuSignalDims
            this.SignalDimsVisible = ~this.SignalDimsVisible;
            RequestColumnIndex   = 6;
            RequestColumnVisible = this.SignalDimsVisible;
        case this.ContextMenuPortIndex
            this.PortIndexVisible = ~this.PortIndexVisible;
            RequestColumnIndex   = 7;
            RequestColumnVisible = this.PortIndexVisible;
    end % switch
    
    % Update column visibility
    this.setColumnVisibility(RequestColumnIndex, RequestColumnVisible);
    
    % Update context menu
    this.transferDataToScreen_ContextMenu();
end