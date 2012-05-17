function schema
%SCHEMA  Defines properties for @OperatingSpec class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/04/25 03:19:54 $

% Find the package
pkg = findpackage('opcond');

% Find parent class (superclass)
supclass = findclass(pkg, 'AbstractOperatingPoint');

% Register class
c = schema.class(pkg, 'OperatingSpec',supclass);

% Public attributes
schema.prop(c, 'Outputs', 'MATLAB array');        % Model Outputs
p = schema.prop(c, 'Version', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 0;
