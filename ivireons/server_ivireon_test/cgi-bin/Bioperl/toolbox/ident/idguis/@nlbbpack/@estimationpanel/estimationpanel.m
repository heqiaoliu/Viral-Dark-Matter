function this = estimationpanel(h)
% Estimation Panel object.
% h: handle to estimation java panel.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:30:33 $

this = nlbbpack.estimationpanel;

this.jMainPanel = h; %main Model Type panel
this.initialize;

