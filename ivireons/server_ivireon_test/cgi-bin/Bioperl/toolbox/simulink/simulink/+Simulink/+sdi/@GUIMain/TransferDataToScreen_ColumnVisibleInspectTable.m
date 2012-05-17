function TransferDataToScreen_ColumnVisibleInspectTable(this)

%   Copyright 2010 The MathWorks, Inc.

    cols = this.colNames;
	sd = this.sd;

    color = strmatch(sd.mgLine, cols);
    run   = strmatch(sd.mgRun, cols);
    blk   = strmatch(sd.IGBlockSourceColName, cols);
    plt   = strmatch(sd.MGInspectColNamePlot, cols);
    data  = strmatch(sd.IGDataSourceColName, cols);
    model = strmatch(sd.IGModelSourceColName, cols);
    sigL  = strmatch(sd.mgSigLabel, cols);
    left  = strmatch(sd.mgLeft, cols);
    right = strmatch(sd.mgRight, cols);
    rootInd = strmatch(sd.IGRootSourceColName, cols);   
    timeInd = strmatch(sd.IGTimeSourceColName, cols);   
    dimInd  = strmatch(sd.mgDimensions, cols);   
    portInd = strmatch(sd.IGPortIndexColName, cols); 
    leaf  = strmatch(sd.mgLeaf, cols);
    abstolInd   = strmatch(sd.mgAbsTol, cols);
    reltolInd   = strmatch(sd.mgRelTol, cols);
    syncInd     = strmatch(sd.mgSyncMethod, cols);
    interpInd   = strmatch(sd.mgInterpMethod, cols);  
    channelInd  = strmatch(sd.mgChannel, cols);  
    
    this.setColumnVisibility(run-1, this.runVisibleInsp,...
                             this.InspectTT.TT);
    this.setColumnVisibility(blk-1, this.blockSrcVisibleInsp,...
                             this.InspectTT.TT);
    this.setColumnVisibility(plt-1, this.plotVisibleInsp,...
                             this.InspectTT.TT);
    this.setColumnVisibility(color-1, this.colorVisibleInsp,...
                             this.InspectTT.TT);
    this.setColumnVisibility(data-1, this.dataSourceVisibleInsp,...
                             this.InspectTT.TT);
    this.setColumnVisibility(model-1, this.modelSourceVisibleInsp,...
                             this.InspectTT.TT);
    this.setColumnVisibility(sigL-1, this.signalLabelVisibleInsp,...
                             this.InspectTT.TT);
    this.setColumnVisibility(left-1, false, this.InspectTT.TT);
    this.setColumnVisibility(right-1, false, this.InspectTT.TT);
    this.setColumnVisibility(leaf-1, false, this.InspectTT.TT); 
    this.setColumnVisibility(rootInd-1, this.rootVisibleInsp,...
                             this.InspectTT.TT);
    this.setColumnVisibility(timeInd-1, this.timeVisibleInsp,...
                             this.InspectTT.TT);
    this.setColumnVisibility(portInd-1, this.portVisibleInsp,...
                             this.InspectTT.TT);
    this.setColumnVisibility(dimInd-1, this.dimVisibleInsp,...
                             this.InspectTT.TT);
    this.setColumnVisibility(abstolInd-1, this.absTolVisibleInsp,...
                             this.InspectTT.TT);
    this.setColumnVisibility(reltolInd-1, this.relTolVisibleInsp,...
                             this.InspectTT.TT);
    this.setColumnVisibility(syncInd-1, this.syncVisibleInsp,...
                             this.InspectTT.TT);
    this.setColumnVisibility(interpInd-1, this.interpVisibleInsp,...
                             this.InspectTT.TT);
    this.setColumnVisibility(channelInd-1, this.channelVisibleInsp,...
                             this.InspectTT.TT);
                         
    this.InspectTT.ScrollPane.repaint();
end

