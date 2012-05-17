function this = nlhwpanel(h)
% Model Type panel object.
% h: handle to Model Type java panel.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:31:21 $
% Written by Rajiv Singh.

this = nlbbpack.nlhwpanel;

this.jMainPanel = h; %main Model Type panel
this.initialize;

