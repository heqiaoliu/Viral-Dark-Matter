function schema
%SCHEMA  Defines properties for @AbstractOperatingPoint class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/10/15 23:28:13 $

% Find the package
pkg = findpackage('opcond');

% Register class
c = schema.class(pkg, 'AbstractOperatingPoint');

% Public attributes
schema.prop(c, 'Model', 'MATLAB array');
schema.prop(c, 'States', 'handle vector');        % Model States
schema.prop(c, 'Inputs', 'handle vector');        % Model Inputs
p = schema.prop(c, 'Time', 'MATLAB array');
p.FactoryValue = 0;
p = schema.prop(c, 'Version', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 0;