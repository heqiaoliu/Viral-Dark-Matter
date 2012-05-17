function transferStateToScreen_ColumnVisibleCompareRuns(this)
    
    % Copyright 2010 The MathWorks, Inc.
    
    cols = this.colNamesCompRun;
    sd = this.sd; 
    blk1 = strmatch(sd.mgBlkSrc1, cols);
    blk2   = strmatch(sd.mgBlkSrc2, cols);
    dataSrc1   = strmatch(sd.mgDataSrc1, cols);
    dataSrc2  = strmatch(sd.mgDataSrc2, cols);
    sid1 = strmatch(sd.mgSID1, cols);
    sid2 = strmatch(sd.mgSID2, cols);
    
    id = strmatch(sd.mgID, cols); 
    abstolInd   = strmatch(sd.mgAbsTol1, cols);
    reltolInd   = strmatch(sd.mgRelTol1, cols);
    syncInd     = strmatch(sd.mgSync1, cols);
    interpInd   = strmatch(sd.mgInterp1, cols);                
    channelInd  = strmatch(sd.mgChannel1, cols);
    plotInd     = strmatch(sd.MGInspectColNamePlot, cols);
    
    
    this.setColumnVisibility(blk1-1, this.blkSrcVis1,...
                             this.compareRunsTT.TT);
    this.setColumnVisibility(blk2-1, this.blkSrcVis2,...
                             this.compareRunsTT.TT);
    this.setColumnVisibility(dataSrc1-1, this.dataSrcVis1,...
                             this.compareRunsTT.TT);
    this.setColumnVisibility(dataSrc2-1, this.dataSrcVis2,...
                             this.compareRunsTT.TT);
    this.setColumnVisibility(sid1-1, this.sidVis1,...
                             this.compareRunsTT.TT);
    this.setColumnVisibility(sid2-1, this.sidVis2,...
                             this.compareRunsTT.TT);
    this.setColumnVisibility(abstolInd-1, this.absTolVis,...
                             this.compareRunsTT.TT);
    this.setColumnVisibility(reltolInd-1, this.relTolVis,...
                             this.compareRunsTT.TT);
    this.setColumnVisibility(syncInd-1, this.syncVis,...
                             this.compareRunsTT.TT);
    this.setColumnVisibility(interpInd-1, this.interpVis,...
                             this.compareRunsTT.TT);
    this.setColumnVisibility(channelInd-1, this.channelVis,...
                             this.compareRunsTT.TT);                         
    this.setColumnVisibility(id-1, false, this.compareRunsTT.TT);
    this.setColumnVisibility(plotInd-1, true, this.compareRunsTT.TT);
    this.compareRunsTT.ScrollPane.repaint();      
end

