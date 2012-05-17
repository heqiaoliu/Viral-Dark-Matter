function scopext(ext) 
% SCOPEXT register frequency domain check block scope extensions
%
 
% Author(s): A. Stothert 03-Nov-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:54:24 $

%% Sources

%% Visuals
r = ext.add('Visuals', 'BodeVisual', 'slctrlblkdlgs.BodeVisual', 'Bode visualization');
r.Visible = false;
r = ext.add('Visuals', 'PZMapVisual', 'slctrlblkdlgs.PZMapVisual', 'PZMap visualization');
r.Visible = false;
r = ext.add('Visuals', 'NicholsVisual', 'slctrlblkdlgs.NicholsVisual', 'Nichols visualization');
r.Visible = false;
r = ext.add('Visuals', 'MarginsVisual', 'slctrlblkdlgs.MarginsVisual', 'Gain & Phase margin visualization');
r.Visible = false;
r = ext.add('Visuals', 'SigmaVisual', 'slctrlblkdlgs.SigmaVisual', 'Maximum Singular Value visualization');
r.Visible = false;
r = ext.add('Visuals', 'LinearStepVisual', 'slctrlblkdlgs.LinStepVisual', 'Linear Step Response visualization');
r.Visible = false;

%% Tools

%% Scope specific information (DataHandlers)

