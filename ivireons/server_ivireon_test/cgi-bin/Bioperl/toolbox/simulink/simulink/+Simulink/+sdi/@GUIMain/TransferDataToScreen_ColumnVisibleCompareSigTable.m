function TransferDataToScreen_ColumnVisibleCompareSigTable(this)

    % Copyright 2010 The MathWorks, Inc.
    % this function gets called when a particular column has to be removed
    % or brought back

    % cache column names
    cols = this.colNames;
    
    % cache string dictionary
    sd = this.sd;
        
    color = strmatch(sd.mgLine,cols);
    run   = strmatch(sd.mgRun, cols);
    blk   = strmatch(sd.IGBlockSourceColName, cols);
    plt   = strmatch(sd.MGInspectColNamePlot, cols);
    data  = strmatch(sd.IGDataSourceColName, cols);
    model = strmatch(sd.IGModelSourceColName, cols);
    sigL  = strmatch(sd.mgSigLabel,cols);
    rootInd = strmatch(sd.IGRootSourceColName, cols);
    timeInd = strmatch(sd.IGTimeSourceColName, cols);
    dimInd  = strmatch(sd.mgDimension,cols);
    portInd = strmatch(sd.IGPortIndexColName, cols);
    leaf  = strmatch(sd.mgLeaf, cols);
    abstolInd   = strmatch(sd.mgAbsTol, cols);
    reltolInd   = strmatch(sd.mgRelTol, cols);
    syncInd     = strmatch(sd.mgSyncMethod, cols);
    interpInd   = strmatch(sd.mgInterpMethod, cols);
    channelInd  = strmatch(sd.mgChannel, cols);
    
    this.setColumnVisibility(run-1, this.runVisibleCompSig,...
                                    this.compareSignalsTT.TT);
    this.setColumnVisibility(blk-1, this.blockSrcVisibleCompSig,...
                                    this.compareSignalsTT.TT);
    this.setColumnVisibility(color-1, this.colorVisibleCompSig,...
                                      this.compareSignalsTT.TT);
    this.setColumnVisibility(abstolInd-1, this.absTolVisibleCompSig,...
                             this.compareSignalsTT.TT);
    this.setColumnVisibility(reltolInd-1, this.relTolVisibleCompSig,...
                             this.compareSignalsTT.TT);
    this.setColumnVisibility(syncInd-1, this.syncVisibleCompSig,...
                             this.compareSignalsTT.TT);
    this.setColumnVisibility(interpInd-1, this.interpVisibleCompSig,...
                             this.compareSignalsTT.TT);        
    this.setColumnVisibility(data-1, this.dataSourceVisibleCompSig,...
                                     this.compareSignalsTT.TT);
    this.setColumnVisibility(model-1, this.modelSourceVisibleCompSig,...
                                      this.compareSignalsTT.TT);
    this.setColumnVisibility(sigL-1, this.signalLabelVisibleCompSig,...
                                     this.compareSignalsTT.TT);  
    this.setColumnVisibility(plt-1, false, this.compareSignalsTT.TT);  
    this.setColumnVisibility(leaf-1, false, this.compareSignalsTT.TT); 
    this.setColumnVisibility(rootInd-1, this.rootVisibleCompSig,...
                             this.compareSignalsTT.TT);
    this.setColumnVisibility(timeInd-1, this.timeVisibleCompSig,...
                             this.compareSignalsTT.TT);
    this.setColumnVisibility(portInd-1, this.portVisibleCompSig,...
                             this.compareSignalsTT.TT);
    this.setColumnVisibility(dimInd-1, this.dimVisibleCompSig,...
                             this.compareSignalsTT.TT);
    this.setColumnVisibility(channelInd-1, this.channelVisibleCompSig,...
                             this.compareSignalsTT.TT); 
    this.compareSignalsTT.ScrollPane.repaint();   
        
end