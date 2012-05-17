function listener_stairLine(this, src, ~)

    % Copyright 2010 The MathWorks, Inc.

    switch src.Name % switch on the property name
        case 'stairLineInspectAxes'
            xLim = get(this.AxesInspectSignals, 'xlim');
            yLim = get(this.AxesInspectSignals, 'ylim');
            this.updateInspAxes();
            set(this.AxesInspectSignals, 'xlim', xLim, 'ylim', yLim);
        case {'stairLineCompSigDataAxes', 'stairLineCompSigDiffAxes' }
            xLim1 = get(this.AxesCompareSignalsData, 'xlim');
            yLim1 = get(this.AxesCompareSignalsData, 'ylim');
            xLim2 = get(this.AxesCompareSignalsDiff, 'xlim');
            yLim2 = get(this.AxesCompareSignalsDiff, 'ylim');
            this.transferStateToScreen_plotUpdateCompareSignals();
            set(this.AxesCompareSignalsData, 'xlim', xLim1, 'ylim', yLim1);
            set(this.AxesCompareSignalsDiff, 'xlim', xLim2, 'ylim', yLim2);
        case {'stairLineCompRunsDataAxes', 'stairLineCompRunsDiffAxes'} 
            xLim1 = get(this.AxesCompareRunsData, 'xlim');
            yLim1 = get(this.AxesCompareRunsData, 'ylim');
            xLim2 = get(this.AxesCompareRunsDiff, 'xlim');
            yLim2 = get(this.AxesCompareRunsDiff, 'ylim');
            this.plotUpdateCompRuns(this.state_SelectedSignalCompRun);
            set(this.AxesCompareRunsData, 'xlim', xLim1, 'ylim', yLim1);
            set(this.AxesCompareRunsDiff, 'xlim', xLim2, 'ylim', yLim2);
    end        
end


        
        