function showViewer(this,ForceFlag)
% showViewer method to display viewer
% if ForceFlag is false then only show viewer if it has current views

%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2006/06/20 20:02:01 $

if nargin == 1
    ForceFlag = true;
end

ViewerObj = this.SISODB.AnalysisView;

% has sisotool viewer been instantiated
ViewerExists = ~isempty(ViewerObj) && ishandle(ViewerObj);

% Build sisotool viewer if required
if ForceFlag && ~ViewerExists
      ViewerObj = viewgui.SisoToolViewer(this.SISODB);
      this.SISODB.AnalysisView = ViewerObj;        
end

% does sisotool viewer have any current views
hasViews = ViewerExists && ~isempty(ViewerObj.getCurrentViews);

if ForceFlag || (~ForceFlag && hasViews)
    this.updateViewer;
    figure(double(this.SISODB.AnalysisView.Figure));
end