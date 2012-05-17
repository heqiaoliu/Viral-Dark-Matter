function schema
%SCHEMA  Defines properties for @StepRiseTimeView class

%   Author(s): Craig Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:37:18 $

% Register class (subclass)
pkg = findpackage('wrfc');
c = schema.class(findpackage('resppack'), 'UncertainBodeView', findclass(pkg,'view'));

% Public attributes
schema.prop(c, 'UncertainMagPatch', 'MATLAB array');    % Handles of Patch
schema.prop(c, 'UncertainPhasePatch', 'MATLAB array');    % Handles of Patch 
schema.prop(c, 'UncertainMagLines', 'MATLAB array');    % Handles of Lines
schema.prop(c, 'UncertainPhaseLines', 'MATLAB array');    % Handles of Lines
p = schema.prop(c, 'UncertainType', 'MATLAB array');    % Uncertain Type: Bounds, Systems
p.FactoryValue = 'Systems';
