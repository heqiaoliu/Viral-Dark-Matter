function schema
%SCHEMA  Defines properties for @StepRiseTimeView class

%   Author(s): Craig Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/04/11 20:36:26 $

% Register class (subclass)
pkg = findpackage('wrfc');
c = schema.class(findpackage('resppack'), 'UncertainTimeView', findclass(pkg,'view'));

% Public attributes
schema.prop(c, 'UncertainPatch', 'MATLAB array');    % Handles of Patch 
schema.prop(c, 'UncertainLines', 'MATLAB array');    % Handles of Lines
p = schema.prop(c, 'UncertainType', 'MATLAB array');    % Uncertain Type: Bounds, Systems
p.FactoryValue = 'Systems';
