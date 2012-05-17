function schema
%SCHEMA  Defines properties for @TunedMask class

%  Copyright 1986-2005 The MathWorks, Inc. 
%  $Revision: 1.1.8.2 $  $Date: 2006/01/26 01:46:17 $

% Register class
pkg = findpackage('sisodata');
c = schema.class(pkg, 'TunedMask', findclass(pkg, 'TunedBlock'));

% Class attributes
%%%%%%%%%%%%%%%%%%%
p = schema.prop(c, 'ZPKData','MATLAB array');

% Temp workaround
p = schema.prop(c, 'PZGroup','MATLAB array');

p = schema.prop(c, 'FixedDynamics','MATLAB array');
p.getFunction = {@LocalGetFixedDynamics};

%% Local Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Value = LocalGetFixedDynamics(this,StoredValue)

Value = this.ZPKData;