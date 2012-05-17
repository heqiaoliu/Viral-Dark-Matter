function schema
%SCHEMA  Defines properties for @TimeEvent class

%  Author(s): John Glass
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/31 07:34:05 $

% Find the package
pkg = findpackage('LinearizationObjects');

% Find parent class (superclass)
supclass = findclass(pkg, 'OperPointSnapShotEvent');

% Register class
c = schema.class(pkg, 'LinearizationSnapShotEvent', supclass);

% Public attributes
schema.prop(c, 'LinData', 'MATLAB array');
schema.prop(c, 'iostructfcn', 'MATLAB array');