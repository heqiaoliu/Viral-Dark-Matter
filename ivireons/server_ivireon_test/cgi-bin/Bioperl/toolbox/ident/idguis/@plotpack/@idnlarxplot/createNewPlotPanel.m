function createNewPlotPanel(this)
% create a new panel and put a new plot on it

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:55:45 $

u2 = uipanel('parent',this.Figure,'units','char');
this.setTag(u2);
this.MainPanels(end+1) = handle(u2);
