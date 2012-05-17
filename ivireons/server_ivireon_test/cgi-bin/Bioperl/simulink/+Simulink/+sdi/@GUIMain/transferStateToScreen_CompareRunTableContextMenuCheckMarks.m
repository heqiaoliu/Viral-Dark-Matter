function transferStateToScreen_CompareRunTableContextMenuCheckMarks(this)
    %   Copyright 2010 The MathWorks, Inc.
    
    ut = Simulink.sdi.Util;
    blk1  = ut.BoolToOnOff(this.blkSrcVis1);
    blk2 = ut.BoolToOnOff(this.blkSrcVis2);
    dataSrc1 = ut.BoolToOnOff(this.dataSrcVis1);
    dataSrc2 = ut.BoolToOnOff(this.dataSrcVis2);
    sid1  = ut.BoolToOnOff(this.sidVis1);
    sid2   = ut.BoolToOnOff(this.sidVis2);
    abstol = ut.BoolToOnOff(this.absTolVis);
    reltol = ut.BoolToOnOff(this.relTolVis);
    sync = ut.BoolToOnOff(this.syncVis);
    interp = ut.BoolToOnOff(this.interpVis);
    channel = ut.BoolToOnOff(this.channelVis);
   
    % Set menu checkmarks
    set(this.tableContextMenuBlkSrc1,  'Checked', blk1);
    set(this.tableContextMenuBlkSrc2, 'Checked', blk2);
    set(this.tableContextMenuDataSrc1, 'Checked', dataSrc1);
    set(this.tableContextMenuDataSrc2, 'Checked', dataSrc2);
    set(this.tableContextMenuSID1,  'Checked', sid1);
    set(this.tableContextMenuSID2,   'Checked', sid2);
    set(this.tableContextMenuCompRunAbsTol,  'Checked', abstol);
    set(this.tableContextMenuCompRunRelTol,  'Checked', reltol);
    set(this.tableContextMenuCompRunSync,  'Checked', sync);
    set(this.tableContextMenuCompRunInterp,  'Checked', interp);
    set(this.tableContextMenuCompRunChannel,  'Checked', channel);        
end
