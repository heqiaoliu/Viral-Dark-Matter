function scopext(ext) 
% SCOPEXT common check block scope extensions
%
 
% Author(s): A. Stothert 17-Dec-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/05/10 17:38:03 $
 
%% Sources
r = ext.add('Sources', 'SimulinkEvent', 'checkpack.SrcSLEvent', 'Connect to simulink event');
r.Visible = false;

%% Visuals
r = ext.add('Visuals', 'TimeVisual', 'checkpack.TimeVisual', 'Time visualization');
r.Visible = false;

%% Tools
r = ext.add('Tools', 'Requirement viewer', 'checkpack.RequirementTool', 'Display and edit requirements on the scope');
r.Visible = false;
r = ext.add('Tools', 'Check block zoom', 'checkpack.CheckVisualZoom', 'Zoom widgets for check block visualizations');
r.Visible = false;

%% Scope specific information (DataHandlers)

