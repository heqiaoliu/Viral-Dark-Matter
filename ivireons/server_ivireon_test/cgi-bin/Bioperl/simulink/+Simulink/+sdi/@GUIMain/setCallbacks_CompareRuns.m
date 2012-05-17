function setCallbacks_CompareRuns(this)

%   Copyright 2010 The MathWorks, Inc.

    set(this.compareRunAdvancePlus, 'callback', @this.callback_AdvancePlus);
    set(this.advanceOptions, 'buttondownfcn', @this.callback_AdvancePlus);
    set(this.compareRuns, 'callback', @this.callback_CompareRuns);
        
    tableHeader = this.compareRunsTT.TT.getTableHeader();
    tableHeader = handle(tableHeader, 'callbackproperties');
    set(tableHeader, 'MouseClickedCallback',...
        {@this.tableHeaderContextMenuClick_CompareRuns});
    this.compareRunsTT.TableCallback.MouseClickedCallback = ...
        {@this.tableMouseClickedCallback_CompRuns};
end

