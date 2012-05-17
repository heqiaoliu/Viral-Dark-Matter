function this = modeltypepanel(h)
% Model Type panel object.
% h: handle to Model Type java panel.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:30:44 $

this = nlbbpack.modeltypepanel;

% Initialize nonlinearity estimators for idnlarx and idnlhw models
%this.NlarxOptions.setCurrentNonlinType;
%this.NlhwOptions.setCurrentNonlinTypes;

this.jMainPanel = h; %main Model Type panel
this.initialize;

