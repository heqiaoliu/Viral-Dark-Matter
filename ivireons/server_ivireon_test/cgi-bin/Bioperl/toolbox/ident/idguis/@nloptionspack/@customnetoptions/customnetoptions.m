function this = customnetoptions(nlarxobj,h)
% customnet options panel object.
% h: handle to main java panel containing customnet options.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:31:50 $

this = nloptionspack.customnetoptions;
this.NlarxPanel = nlarxobj;
this.jMainPanel = h; %main Model Type panel
this.initialize;
