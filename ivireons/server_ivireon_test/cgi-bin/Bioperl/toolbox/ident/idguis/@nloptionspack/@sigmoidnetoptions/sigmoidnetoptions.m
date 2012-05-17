function this = sigmoidnetoptions(nlarxobj,h)
% Sigmoidnet options panel object.
% h: handle to main java panel containing Sigmoidnet options.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:32:04 $

this = nloptionspack.sigmoidnetoptions;

this.NlarxPanel = nlarxobj;
this.jMainPanel = h; %main Model Type panel
this.initialize;
