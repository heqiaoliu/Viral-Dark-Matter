function schema
% Defines properties for @ExtModeTransports class.
%
%   Copyright 1986-2006 The MathWorks, Inc.

%
% Because this is used by the Customization Manager, we add mlock to avoid
% warnings when attempting to clear classes from matlab command line
%
mlock;

%
% find the Simulink package that this class extends
%
slPkg = findpackage('Simulink');

%
% create the 'ExtModeTransports' class that belongs to the 'Simulink' package
%
c = schema.class(slPkg, 'ExtModeTransports');

%
% add the properties ('left, 'top', 'right', 'bottom')
%
schema.prop(c, 'targets',    'mxArray');
schema.prop(c, 'transports', 'mxArray');
schema.prop(c, 'mexfiles',   'mxArray');
schema.prop(c, 'interfaces', 'mxArray');

m = schema.method(c,'get');
m.signature.varargin = 'off';
m.signature.inputTypes={'handle'};
m.signature.outputTypes={'mxArray' 'mxArray' 'mxArray' 'mxArray'};

m = schema.method(c,'add');
m.signature.varargin = 'off';
m.signature.inputTypes={'handle' 'string' 'string' 'string' 'string'};
m.signature.outputTypes={};

m = schema.method(c,'clear');
m.signature.varargin = 'off';
m.signature.inputTypes={'handle'};
m.signature.outputTypes={};