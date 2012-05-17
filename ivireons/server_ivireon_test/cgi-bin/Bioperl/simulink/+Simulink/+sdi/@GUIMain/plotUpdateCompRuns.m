function plotUpdateCompRuns(this, stateVariable)
    
    % Copyright 2009-2010 The MathWorks, Inc.
    
    % Clear the axes
    this.helperClearCompareRunsPlot(); 
   
    if(stateVariable == -1)
        return;
    end
    
    try
        lhsSignalID = stateVariable;

        rhsSignalID = this.SDIEngine.AlignRuns.getAlignedID(lhsSignalID);

        if isempty(rhsSignalID)
            return;
        end

        ldata = this.SDIEngine.getSignal(int32(lhsSignalID));
        rdata = this.SDIEngine.getSignal(int32(rhsSignalID));
        
        % turn off link axes
        linkaxes([this.AxesCompareRunsData this.AxesCompareRunsDiff], 'off');	
        set(this.AxesCompareRunsData, 'xlimmode', 'auto');
        
        this.HDiffPlot.plotSignals(this.AxesCompareRunsData, [ldata, rdata],...
                                   this.normCompRunsDataAxes,      ...
                                   this.stairLineCompRunsDataAxes);

        if (~isempty(ldata.DataValues) && ~isempty(rdata.DataValues))
            h = legend(this.AxesCompareRunsData, this.sd.mgLeft, this.sd.mgRight);
            set(h,'Box', 'off');
        end

        try
            result = this.SDIEngine.DiffRunResult.lookupResult(lhsSignalID,...
                                                               rhsSignalID);
        catch %#ok
            result = [];
        end

        % Plot the difference
        if ~isempty(result)
            if ~isempty(result.Diff)
                this.HDiffPlot.plotDiff(this.AxesCompareRunsDiff, ...
                                        result.Diff, result.Tol,  ...
                                        this.normCompRunsDiffAxes,...
                                        this.stairLineCompRunsDiffAxes);
                if ~isempty(result.Diff.Time)
                    h = legend(this.AxesCompareRunsDiff, this.sd.mgDifference,...
                               this.sd.MGInspactColNameTolerance);
                    set(h,'Box', 'off');
                end
            else
                this.HDiffPlot.plotZeroDiff(this.AxesCompareRunsDiff, lhsSignalID);            
            end 
            title(this.AxesCompareRunsDiff, this.sd.mgDifference);
        end
        % link axes
        linkaxes([this.AxesCompareRunsData this.AxesCompareRunsDiff], 'x');	
    
    catch %#ok        
        this.state_SelectedSignalCompRun = -1;
        % link axes
        linkaxes([this.AxesCompareRunsData this.AxesCompareRunsDiff], 'x');	
    end