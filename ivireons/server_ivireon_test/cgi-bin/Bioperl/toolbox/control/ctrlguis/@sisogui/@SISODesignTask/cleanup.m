function cleanup(this)
% CLEANUP
%
 
% Author(s): John W. Glass 12-Dec-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2007/02/06 19:50:45 $

if ishandle(this.Architecture)
    this.Architecture.cleanup;
end
if ishandle(this.DesignPlotConfig)
    this.DesignPlotConfig.cleanup;
end
if ishandle(this.AnalysisPlotConfig)
    this.AnalysisPlotConfig.cleanup;
end
if ishandle(this.ManualTuning)
    this.ManualTuning.cleanup;
end
if ishandle(this.AutomatedTuning)
    this.AutomatedTuning.cleanup;
end
awtinvoke(this.Handles.TaskTabbedPane,'removeAll()')
