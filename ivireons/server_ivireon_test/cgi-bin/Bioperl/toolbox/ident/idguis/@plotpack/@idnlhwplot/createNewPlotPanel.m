function createNewPlotPanel(this)
% create a new panel and put a new plot on it

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:15 $

u2 = uipanel('parent',this.Figure,'units','norm','pos',[0,0,1,0.75]);
this.setTag(u2);
this.MainPanels(end+1) = handle(u2);
