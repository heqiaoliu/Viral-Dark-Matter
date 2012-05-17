function tableContextMenu_CompareSignals(this, h, e)
    % Update column visibility flags

%   Copyright 2010 The MathWorks, Inc.

    RequestColumnIndex   = -1;
    RequestColumnVisible = true;
    sd = this.sd;
    cols = this.colNames;
    
    color = strmatch(sd.mgLine, cols);
    run   = strmatch(sd.mgRun, cols);  
    data  = strmatch(sd.IGDataSourceColName, cols);
    model = strmatch(sd.IGModelSourceColName, cols);
    sigL  = strmatch(sd.mgSigLabel, cols);
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
        case {this.contextMenuRunCompSig, this.tableContextMenuRun}
            this.runVisibleCompSig = ~this.runVisibleCompSig;
            RequestColumnIndex   = run-1;
            RequestColumnVisible = this.runVisibleCompSig;
        case {this.contextMenuColorCompSig, this.tableContextMenuColor}
            this.colorVisibleCompSig = ~this.colorVisibleCompSig;
            RequestColumnIndex   = color-1;
            RequestColumnVisible = this.colorVisibleCompSig;
        case {this.contextMenuAbsTolCompSig, this.tableContextMenuAbsTol}
            this.absTolVisibleCompSig = ~this.absTolVisibleCompSig;
            RequestColumnIndex   = abstolInd-1;
            RequestColumnVisible = this.absTolVisibleCompSig;
        case {this.contextMenuRelTolCompSig, this.tableContextMenuRelTol}
            this.relTolVisibleCompSig = ~this.relTolVisibleCompSig;
            RequestColumnIndex   = reltolInd-1;
            RequestColumnVisible = this.relTolVisibleCompSig;            
        case {this.contextMenuSyncCompSig, this.tableContextMenuSync}
            this.syncVisibleCompSig = ~this.syncVisibleCompSig;
            RequestColumnIndex   = syncInd-1;
            RequestColumnVisible = this.syncVisibleCompSig;      
        case {this.contextMenuInterpCompSig, this.tableContextMenuInterp}
            this.interpVisibleCompSig = ~this.interpVisibleCompSig;
            RequestColumnIndex   = interpInd - 1;
            RequestColumnVisible = this.interpVisibleCompSig;                  
        case {this.contextMenuChannelCompSig, this.tableContextMenuChannel}
            this.channelVisibleCompSig = ~this.channelVisibleCompSig;
            RequestColumnIndex   = channelInd-1;
            RequestColumnVisible = this.channelVisibleCompSig;                           
        case {this.contextMenuDataSourceCompSig, this.tableContextMenuDataSource}
            this.dataSourceVisibleCompSig = ~this.dataSourceVisibleCompSig;
            RequestColumnIndex   = data-1;
            RequestColumnVisible = this.dataSourceVisibleCompSig;
        case {this.contextMenuModelSourceCompSig, this.tableContextMenuModelSource}
            this.modelSourceVisibleCompSig = ~this.modelSourceVisibleCompSig;
            RequestColumnIndex   = model-1;
            RequestColumnVisible = this.modelSourceVisibleCompSig;
        case {this.contextMenuSignalLabelCompSig, this.tableContextMenuSignalLabel}
            this.signalLabelVisibleCompSig = ~this.signalLabelVisibleCompSig;
            RequestColumnIndex   = sigL-1;
            RequestColumnVisible = this.signalLabelVisibleCompSig;
        case {this.contextMenuRootCompSig, this.tableContextMenuRoot}
            this.rootVisibleCompSig = ~this.rootVisibleCompSig;
            RequestColumnIndex   = rootInd-1;
            RequestColumnVisible = this.rootVisibleCompSig;
        case {this.contextMenuTimeSourceCompSig,this.tableContextMenuTimeSource}
            this.timeVisibleCompSig = ~this.timeVisibleCompSig;
            RequestColumnIndex   = timeInd-1;
            RequestColumnVisible = this.timeVisibleCompSig;
        case {this.contextMenuPortCompSig,  this.tableContextMenuPort}
            this.portVisibleCompSig = ~this.portVisibleCompSig;
            RequestColumnIndex   = portInd-1;
            RequestColumnVisible = this.portVisibleCompSig;
        case {this.contextMenuDimCompSig,  this.tableContextMenuDim}
            this.dimVisibleCompSig = ~this.dimVisibleCompSig;
            RequestColumnIndex   = dimInd-1;
            RequestColumnVisible = this.dimVisibleCompSig;           
    end % switch
    
    % Update column visibility
    this.setColumnVisibility(RequestColumnIndex, RequestColumnVisible,...
                             this.compareSignalsTT.TT);
    
    this.setRenderers_CompareSignals();
    % Update context menu
    this.TransferDataToScreen_ContextMenuCompareSig();
end