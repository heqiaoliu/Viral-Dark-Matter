function this = fdatool
%SESSION  Constructor for an FDATool session object.
%
%   Inputs:
%      hFig - Handle to the figure corresponding to the session.
%
%   Outputs:
%      h - Handle to the instance of the class.

%   Author(s): R. Losada
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.27.4.7 $  $Date: 2009/07/14 04:03:43 $

this = sigtools.fdatool;

% Set properties
set(this,'sessionType','default');
set(this,'filename', 'untitled.fda');
set(this,'version',1.1);
set(this,'LaunchedBySPTool', 0);

set(this,'filterMadeBy','');

addlistener(this, 'NewAnalysis', @newanalysis_eventcb, this);

% ---------------------------------------------------
function newanalysis_eventcb(this, eventData)
%NEWANALYSIS_EVENTCB Listener to the NewAnalysis Event

h           = gethandles(this);
analysisStr = get(eventData, 'Data');

hTitle = h.analysis.frame(2);
origUnits = get(hTitle, 'units');
set(hTitle, 'String', analysisStr, 'Units', 'Pixels');
uiExtent = get (hTitle, 'Extent');
pos = get(hTitle, 'Position');
pos(3) = uiExtent(3);
set(hTitle,'Position', pos, 'String', analysisStr, 'Units', origUnits);

% We want to ignore all zooming warnings
w = warning('off');

setzoomstate(this.FigureHandle);

warning(w);

% [EOF]
