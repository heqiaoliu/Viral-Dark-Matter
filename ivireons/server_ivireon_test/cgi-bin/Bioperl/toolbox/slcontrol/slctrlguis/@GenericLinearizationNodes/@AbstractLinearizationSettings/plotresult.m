function plotresult(this,resultnode)
% PLOTRESULT  Plot the linearization result in the LTI Viewer
%
 
% Author(s): John W. Glass 16-Aug-2006
%   Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2009/07/09 20:57:19 $

% Get the explorer frame handle
ExplorerFrame = slctrlexplorer;

% Get the user selected lti plot type
plottype = this.LTIPlotType;

% Check to see if a new view is needed to be added
%  The first check is to be sure that there is at least one set of I/O
sys = resultnode.LinearizedModel;

% Convert to gridded model if the model is uncertain
if ~isa(sys,'ss')
    Name = sys.Name;
    sys = usample(sys,20);
    sys.Name = Name;
end

[nu,ny] = size(sys(:,:,1));

if nu*ny == 0 && (~strcmp(plottype,'None'))
    str = ctrlMsgUtils.message('Slcontrol:linearizationtask:LinearizationResultNoIONotShownInLTIViewer');
    warndlg(str, 'Simulink Control Design')
else
    if (~strcmp(plottype,'None')) && (~isa(this.LTIViewer,'viewgui.ltiviewer'))
        ExplorerFrame.postText(ctrlMsgUtils.message('Slcontrol:linearizationtask:LaunchingLTIViewerStatus'))
        % Launch the LTI Viewer
        [Viewer,vh] = ltiview(plottype,sys);        
        % Set the title
        set(Viewer,'Name',ctrlMsgUtils.message('Slcontrol:linearizationtask:LTIViewerTitle'))
        % Store the viewer handle
        this.LTIViewer = vh;
        ExplorerFrame.postText(ctrlMsgUtils.message('Slcontrol:linearizationtask:LTIViewerReadyStatus'))
    elseif isa(this.LTIViewer,'viewgui.ltiviewer') && (~strcmp(plottype,'None'))
        % Get the current available views and add a new view if needed
        currentviews = get(this.LTIViewer.getCurrentViews,{'Tag'});
        ExplorerFrame.postText(ctrlMsgUtils.message('Slcontrol:linearizationtask:LTIViewUpdatingStatus'))
        if ~any(strcmp(currentviews,plottype))
            currentviews = {plottype};
            this.LTIViewer.setCurrentViews(currentviews);
        end
        this.LTIViewer.importsys(sprintf('%s',resultnode.Label),sys);
        ExplorerFrame.postText(ctrlMsgUtils.message('Slcontrol:linearizationtask:LTIViewerReadyStatus'))
    end
end
