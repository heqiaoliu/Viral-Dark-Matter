function tableContextMenu_Inspect(this, h, e)
    % Update column visibility flags

%   Copyright 2010 The MathWorks, Inc.

    RequestColumnIndex   = -1;
    RequestColumnVisible = true;
    
    cols = this.colNames;
    sd = this.sd;
    
    color = strmatch(sd.mgLine, cols);
    run   = strmatch(sd.mgRun, cols);
    data  = strmatch(sd.IGDataSourceColName, cols);
    model = strmatch(sd.IGModelSourceColName, cols);
    sigL  = strmatch(sd.mgSigLabel,cols);
    rootInd     = strmatch(sd.IGRootSourceColName, cols);   
    timeInd     = strmatch(sd.IGTimeSourceColName, cols);   
    dimInd      = strmatch(sd.mgDimension,cols);   
    portInd     = strmatch(sd.IGPortIndexColName, cols); 
    abstolInd   = strmatch(sd.mgAbsTol, cols);
    reltolInd   = strmatch(sd.mgRelTol, cols);
    syncInd     = strmatch(sd.mgSyncMethod, cols);
    interpInd   = strmatch(sd.mgInterpMethod, cols);                
    channelInd  = strmatch(sd.mgChannel, cols);
    
    switch h
        case {this.contextMenuRun, this.tableContextMenuRun}
            this.runVisibleInsp = ~this.runVisibleInsp;
            RequestColumnIndex   = run-1;
            RequestColumnVisible = this.runVisibleInsp;
        case {this.contextMenuColor, this.tableContextMenuColor}
            this.colorVisibleInsp = ~this.colorVisibleInsp;
            RequestColumnIndex   = color-1;
            RequestColumnVisible = this.colorVisibleInsp;
        case {this.contextMenuAbsTol, this.tableContextMenuAbsTol}
            this.absTolVisibleInsp = ~this.absTolVisibleInsp;
            RequestColumnIndex   = abstolInd-1;
            RequestColumnVisible = this.absTolVisibleInsp;
        case {this.contextMenuRelTol, this.tableContextMenuRelTol}
            this.relTolVisibleInsp = ~this.relTolVisibleInsp;
            RequestColumnIndex   = reltolInd-1;
            RequestColumnVisible = this.relTolVisibleInsp;            
        case {this.contextMenuSync, this.tableContextMenuSync}
            this.syncVisibleInsp = ~this.syncVisibleInsp;
            RequestColumnIndex   = syncInd-1;
            RequestColumnVisible = this.syncVisibleInsp;      
        case {this.contextMenuInterp, this.tableContextMenuInterp}
            this.interpVisibleInsp = ~this.interpVisibleInsp;
            RequestColumnIndex   = interpInd - 1;
            RequestColumnVisible = this.interpVisibleInsp;                  
        case {this.contextMenuChannel, this.tableContextMenuChannel}
            this.channelVisibleInsp = ~this.channelVisibleInsp;
            RequestColumnIndex   = channelInd-1;
            RequestColumnVisible = this.channelVisibleInsp;   
        case {this.contextMenuDataSource, this.tableContextMenuDataSource}
            this.dataSourceVisibleInsp = ~this.dataSourceVisibleInsp;
            RequestColumnIndex   = data-1;
            RequestColumnVisible = this.dataSourceVisibleInsp;
        case {this.contextMenuModelSource, this.tableContextMenuModelSource}
            this.modelSourceVisibleInsp = ~this.modelSourceVisibleInsp;
            RequestColumnIndex   = model-1;
            RequestColumnVisible = this.modelSourceVisibleInsp;
        case {this.contextMenuSignalLabel, this.tableContextMenuSignalLabel}
            this.signalLabelVisibleInsp = ~this.signalLabelVisibleInsp;
            RequestColumnIndex   = sigL-1;
            RequestColumnVisible = this.signalLabelVisibleInsp;
        case {this.contextMenuRoot, this.tableContextMenuRoot}
            this.rootVisibleInsp = ~this.rootVisibleInsp;
            RequestColumnIndex   = rootInd-1;
            RequestColumnVisible = this.rootVisibleInsp;
        case {this.contextMenuTimeSource,this.tableContextMenuTimeSource}
            this.timeVisibleInsp = ~this.timeVisibleInsp;
            RequestColumnIndex   = timeInd-1;
            RequestColumnVisible = this.timeVisibleInsp;
        case {this.contextMenuPort,  this.tableContextMenuPort}
            this.portVisibleInsp = ~this.portVisibleInsp;
            RequestColumnIndex   = portInd-1;
            RequestColumnVisible = this.portVisibleInsp;
        case {this.contextMenuDim,  this.tableContextMenuDim}
            this.dimVisibleInsp = ~this.dimVisibleInsp;
            RequestColumnIndex   = dimInd-1;
            RequestColumnVisible = this.dimVisibleInsp;           
    end % switch
    
    % Update column visibility
    this.setColumnVisibility(RequestColumnIndex, RequestColumnVisible,...
                             this.InspectTT.TT);
    this.setRenderers_Inspect();
    % Update context menu
    this.TransferDataToScreen_ContextMenuInspect();
end