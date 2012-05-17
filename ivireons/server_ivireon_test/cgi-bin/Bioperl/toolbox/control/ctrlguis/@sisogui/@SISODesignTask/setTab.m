function setTab(this,TargetTab)

%   Author(s): C. Buhr
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2007/12/14 14:29:16 $


switch TargetTab
    case 'Architecture' % Architecture Panel
        awtinvoke(this.Handles.TaskTabbedPane,'setSelectedIndex(I)',0)
        
    case 'PZEditor' % Manual Tunning
        awtinvoke(this.Handles.TaskTabbedPane,'setSelectedIndex(I)',1)
        
    case 'DesignPlot' % Design Plot Configuration
        awtinvoke(this.Handles.TaskTabbedPane,'setSelectedIndex(I)',2)
        
    case 'AnalysisPlot' % Analysis Plot Configuration
        awtinvoke(this.Handles.TaskTabbedPane,'setSelectedIndex(I)',3)
        
    case 'SROTuning' % Automated Tuning
        awtinvoke(this.Handles.TaskTabbedPane,'setSelectedIndex(I)',4)
        
    otherwise
        ctrlMsgUtils.error('Controllib:general:UnexpectedError',[TargetTab, ' is an unspecified tab.']) 
end


