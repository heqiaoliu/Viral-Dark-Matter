function this = mlnetoptions(nlarxobj,h)
% neuralnet options panel object.
% h: handle to main java panel containing mlnet options.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:54:31 $

this = nloptionspack.mlnetoptions;

this.NlarxPanel = nlarxobj;
this.jMainPanel = h; %main Model Type panel
this.initialize;
