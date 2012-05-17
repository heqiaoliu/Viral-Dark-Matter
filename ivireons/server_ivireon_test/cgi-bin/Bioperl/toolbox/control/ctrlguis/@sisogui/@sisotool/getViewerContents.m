function Contents = getViewerContents(this)
%GETVIEWERCONTENTS  Queries current configuration of the SISO Tool LTI Viewer.
%
%   CONTENTS = GETVIEWERCONTENTS(THIS) returns the current configuration
%   of the SISO Tool Viewer.  CONTENTS is a struct array with as many 
%   entries as plot, and fields
%     * PlotType:      a string specifying the plot type (alias)
%     * VisibleModels: the list of visible responses (specified as indices 
%                      relative to LoopViews).

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2005/12/22 17:44:07 $
ViewerObj = this.AnalysisView;
if isempty(ViewerObj) || ~ishandle(ViewerObj)
   Contents = struct('PlotType',cell(0,1),'VisibleModels',[]);
else
   Contents = getContents(ViewerObj);
end