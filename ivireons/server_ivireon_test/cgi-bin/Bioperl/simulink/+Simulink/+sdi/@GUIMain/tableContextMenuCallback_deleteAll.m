function tableContextMenuCallback_deleteAll(this, ~, ~)
    
    %   Copyright 2010 The MathWorks, Inc.
    
    choice = questdlg(this.sd.mgDelAll,      ...
                      this.sd.mgDeleteAll,   ...
                      this.sd.Yes,this.sd.No,...
                      this.sd.No);
    % Handle response
    switch choice
        case this.sd.Yes
            this.SDIEngine.clearRuns();
        case this.sd.No
    end
    
    this.clearGUI;
    this.updateInspAxes();
    this.transferStateToScreen_plotUpdateCompareSignals();
    this.helperClearCompareRunsPlot();
    this.dirty = false;
end