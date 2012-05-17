function schema
%SCHEMA  Defines properties for @OperatingReport class

%%  Author(s): John Glass
%%  Revised:
%   Copyright 1986-2005 The MathWorks, Inc.
%% $Revision: 1.1.6.4 $ $Date: 2007/04/25 03:19:47 $

%% Find the package
pkg = findpackage('opcond');

%% Register class
c = schema.class(pkg, 'OperatingReport');

%% Public attributes
schema.prop(c, 'Model', 'MATLAB array');         % Model Name
schema.prop(c, 'Inputs', 'MATLAB array');        % Model Inputs
schema.prop(c, 'Outputs', 'MATLAB array');       % Model Outputs
schema.prop(c, 'States', 'MATLAB array');        % Model States
schema.prop(c, 'Time', 'MATLAB array');          % Time
schema.prop(c, 'TerminationString', 'MATLAB array'); % Termination String
schema.prop(c, 'OptimizationOutput', 'MATLAB array'); % Optimization Output
p = schema.prop(c, 'Version', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 0;
