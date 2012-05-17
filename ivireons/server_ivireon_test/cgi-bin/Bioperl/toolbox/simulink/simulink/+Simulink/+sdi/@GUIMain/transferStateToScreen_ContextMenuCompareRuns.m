function transferStateToScreen_ContextMenuCompareRuns(this)
    % Convert bools to "on" and "off" strings

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
    set(this.contextMenuBlkSrc_CompRuns1,  'Checked', blk1);
    set(this.contextMenuBlkSrc_CompRuns2, 'Checked', blk2);
    set(this.contextMenuDataSrc_CompRuns1, 'Checked', dataSrc1);
    set(this.contextMenuDataSrc_CompRuns2, 'Checked', dataSrc2);
    set(this.contextMenuSID_CompRuns1,  'Checked', sid1);
    set(this.contextMenuSID_CompRuns2,   'Checked', sid2);
    set(this.contextMenuAbsTol_CompRuns,  'Checked', abstol);
    set(this.contextMenuRelTol_CompRuns,  'Checked', reltol);
    set(this.contextMenuSync_CompRuns,  'Checked', sync);
    set(this.contextMenuInterp_CompRuns,  'Checked', interp);
    set(this.contextMenuChannel_CompRuns,  'Checked', channel);

    this.transferStateToScreen_CompareRunTableContextMenuCheckMarks();
end

