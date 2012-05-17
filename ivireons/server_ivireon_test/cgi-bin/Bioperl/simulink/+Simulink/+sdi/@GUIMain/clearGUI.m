function  clearGUI(this)

    % Copyright 2010 The MathWorks, Inc.

    % Clear the axes
    cla(this.AxesCompareRunsData, 'reset');
    title(this.AxesCompareRunsData, this.sd.mgSignals);
    cla(this.AxesCompareRunsDiff, 'reset');
    title(this.AxesCompareRunsDiff, this.sd.mgDifference);
    
    cla(this.AxesCompareSignalsData, 'reset');
    title(this.AxesCompareSignalsData, this.sd.mgSignals);
    cla(this.AxesCompareSignalsDiff, 'reset');
    title(this.AxesCompareSignalsDiff, this.sd.mgDifference);
    
    cla(this.AxesInspectSignals, 'reset');
    rowList = javaObjectEDT('java.util.ArrayList');
    this.compareRunsTTModel.setOriginalRows(rowList);
    this.compareRunsTT.TT.repaint();
    this.transferStateToScreen_ColumnVisibleCompareRuns();
    this.compareRunsTT.TT.repaint();
    
    this.commonTableModel.setOriginalRows(rowList);
    this.InspectTT.TT.repaint();
    this.compareSignalsTT.TT.repaint();
    
end