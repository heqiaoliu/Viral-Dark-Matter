function tableContextMenu_CompRuns(this, h, e)
    % Update column visibility flags

%   Copyright 2010 The MathWorks, Inc.

    requestColumnIndex   = -1;
    requestColumnVisible = true;        
    cols = this.colNamesCompRun;
    sd = this.sd;

	blk1 = strmatch(sd.mgBlkSrc1, cols);
    blk2   = strmatch(sd.mgBlkSrc2, cols);
    dataSrc1   = strmatch(sd.mgDataSrc1, cols);
    dataSrc2  = strmatch(sd.mgDataSrc2, cols);
    sid1 = strmatch(sd.mgSID1, cols);
    sid2  = strmatch(sd.mgSID2, cols);	
    abstolInd   = strmatch(sd.mgAbsTol1, cols);
    reltolInd   = strmatch(sd.mgRelTol1, cols);
    syncInd     = strmatch(sd.mgSync1, cols);
    interpInd   = strmatch(sd.mgInterp1, cols);                
    channelInd  = strmatch(sd.mgChannel1, cols);
    
    switch h
        case {this.contextMenuBlkSrc_CompRuns1, this.tableContextMenuBlkSrc1}
            this.blkSrcVis1 = ~this.blkSrcVis1;
            requestColumnIndex   = blk1-1;
            requestColumnVisible = this.blkSrcVis1;
        case {this.contextMenuBlkSrc_CompRuns2, this.tableContextMenuBlkSrc2}
            this.blkSrcVis2 = ~this.blkSrcVis2;
            requestColumnIndex   = blk2-1;
            requestColumnVisible = this.blkSrcVis2;
        case {this.contextMenuDataSrc_CompRuns1, this.tableContextMenuDataSrc1}
            this.dataSrcVis1 = ~this.dataSrcVis1;
            requestColumnIndex   = dataSrc1-1;
            requestColumnVisible = this.dataSrcVis1;
        case {this.contextMenuDataSrc_CompRuns2, this.tableContextMenuDataSrc2}
            this.dataSrcVis2 = ~this.dataSrcVis2;
            requestColumnIndex   = dataSrc2-1;
            requestColumnVisible = this.dataSrcVis2;
        case {this.contextMenuSID_CompRuns1, this.tableContextMenuSID1}
            this.sidVis1 = ~this.sidVis1;
            requestColumnIndex   = sid1-1;
            requestColumnVisible = this.sidVis1;
        case {this.contextMenuSID_CompRuns2, this.tableContextMenuSID2}
            this.sidVis2 = ~this.sidVis2;
            requestColumnIndex   = sid2-1;
            requestColumnVisible = this.sidVis2;
        case {this.contextMenuAbsTol_CompRuns, this.tableContextMenuCompRunAbsTol}
            this.absTolVis = ~this.absTolVis;
            requestColumnIndex   = abstolInd-1;
            requestColumnVisible = this.absTolVis;
        case {this.contextMenuRelTol_CompRuns, this.tableContextMenuCompRunRelTol}
            this.relTolVis = ~this.relTolVis;
            requestColumnIndex   = reltolInd-1;
            requestColumnVisible = this.relTolVis;            
        case {this.contextMenuSync_CompRuns, this.tableContextMenuCompRunSync}
            this.syncVis = ~this.syncVis;
            requestColumnIndex   = syncInd-1;
            requestColumnVisible = this.syncVis;      
        case {this.contextMenuInterp_CompRuns, this.tableContextMenuCompRunInterp}
            this.interpVis = ~this.interpVis;
            requestColumnIndex   = interpInd - 1;
            requestColumnVisible = this.interpVis;                  
        case {this.contextMenuChannel_CompRuns, this.tableContextMenuCompRunChannel}
            this.channelVis = ~this.channelVis;
            requestColumnIndex   = channelInd-1;
            requestColumnVisible = this.channelVis;       
    end % switch

    % Update column visibility
    this.setColumnVisibility(requestColumnIndex, requestColumnVisible,...
                             this.compareRunsTT.TT);
    
    this.setRenderers_CompareRuns();    
    % Update context menu
    this.transferStateToScreen_ContextMenuCompareRuns();
end