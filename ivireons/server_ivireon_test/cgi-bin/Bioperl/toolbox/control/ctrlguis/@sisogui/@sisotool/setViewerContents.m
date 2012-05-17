function setViewerContents(this,Contents)
%SETVIEWERCONTENTS  Configures the SISO Tool LTI Viewer.
%
%   SETVIEWERCONTENTS(SISODB,CONTENTS) opens and configures the LTI Viewer to 
%   show the responses specified in CONTENTS.  CONTENTS is a struct 
%   array with as many entries as plot, and fields
%     * PlotType:      a string specifying the plot type (alias)
%     * VisibleModels: the list of visible loop transfers (specified as
%                      indices relative to SystemInfo).

%   Author(s): K. Gondoly and P. Gahinet
%   Revised  : Kamesh Subbarao
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.27.4.2 $  $Date: 2005/12/22 17:44:12 $
ViewerObj = this.AnalysisView;

if ~isempty(Contents)
   % If no Viewer is opened yet, open one
   if isempty(ViewerObj) || ~ishandle(ViewerObj)
      ViewerObj = viewgui.SisoToolViewer(this);
      this.AnalysisView = ViewerObj;
   end
   
   % Set contents
   ViewerObj.setContents(Contents);
   
   % Make it visible
   % RE: Beware that listener to figure visibility always gets fired
   if strcmp(get(ViewerObj.Figure,'Visible'),'off')
      set(ViewerObj.Figure,'Visible','on')
   end
elseif ~isempty(ViewerObj) && ishandle(ViewerObj)
   % Clear contents
  % ViewerObj.setContents(Contents);
   
   % Hide viewer
   if strcmp(get(ViewerObj.Figure,'Visible'),'on')
      set(ViewerObj.Figure,'Visible','off')
   end
end
