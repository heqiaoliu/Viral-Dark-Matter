function transferStateToScreen_plotUpdateCompareSignals(this, varargin)
    
    %   Copyright 2010 The MathWorks, Inc.

    % Clear the axes
    cla(this.AxesCompareSignalsData, 'reset');
    title(this.AxesCompareSignalsData, this.sd.mgSignals);
    cla(this.AxesCompareSignalsDiff, 'reset');
    title(this.AxesCompareSignalsDiff, this.sd.mgDifference);
    
    if (this.state_SelectedSignalsCompSig(1) > -1 &&...
        this.state_SelectedSignalsCompSig(2) > -1)
        
        try
            lhsID = this.state_SelectedSignalsCompSig(1);        
            ldata = this.SDIEngine.getSignal(int32(lhsID));
        catch %#ok
            this.state_SelectedSignalsCompSig(1) = -1;
            return;
        end
        
        try
            rhsID = this.state_SelectedSignalsCompSig(2);        
            rdata = this.SDIEngine.getSignal(int32(rhsID));
        catch %#ok
            this.state_SelectedSignalsCompSig(2) = -1;
            return;
        end
        % temporarily turn it off
        linkaxes([this.AxesCompareSignalsData this.AxesCompareSignalsDiff], 'off');
        set(this.AxesCompareSignalsData, 'xlimmode', 'auto');
        
        this.HDiffPlot.plotSignals(this.AxesCompareSignalsData, [rdata, ldata],...
                                   this.normCompSigDataAxes,          ...
                                   this.stairLineCompSigDataAxes);
                               
    else
        return;
    end
    

    if (this.state_SelectedSignalsCompSig(1) > -1 &&...
        this.state_SelectedSignalsCompSig(2) > -1)
        lhsID = this.state_SelectedSignalsCompSig(1);
        lhsRunID = ldata.RunID;
        rhsID = this.state_SelectedSignalsCompSig(2);
        rhsRunID = rdata.RunID;
        diffRes = this.SDIEngine.diffSignals(lhsRunID, int32(lhsID),...
                                             rhsRunID, int32(rhsID));
        % Plot the difference
        if ~isempty(diffRes.Diff)
            this.HDiffPlot.plotDiff(this.AxesCompareSignalsDiff,...
                                    diffRes.Diff, diffRes.Tol,  ...
                                    this.normCompSigDiffAxes,   ...
                                    this.stairLineCompSigDiffAxes);
                                
            if ~isempty(diffRes.Diff.Time)
                h = legend(this.AxesCompareSignalsDiff, this.sd.mgDifference,...
                           this.sd.MGInspactColNameTolerance);
                set(h,'Box', 'off');
            end
        else
            this.HDiffPlot.plotZeroDiff(this.AxesCompareSignalsDiff, lhsID);            
        end
        title(this.AxesCompareSignalsDiff, this.sd.mgDifference);
    end
    
    % turn it back on
    linkaxes([this.AxesCompareSignalsData this.AxesCompareSignalsDiff], 'x');

end