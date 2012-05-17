function schema
%SCHEMA Schema for deadsateditor class

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2007/06/07 14:42:09 $

% Construct class
hCreateInPackage   = findpackage('nlutilspack');
c = schema.class(hCreateInPackage, 'deadsateditor');

% UIs % all buttons, Dialog (main) and Owner
p = schema.prop(c,'Handles','MATLAB array');

% Parameters to be used by nlgui
p = schema.prop(c,'Parameters','MATLAB array');
p.FactoryValue = struct('low',[],'up',[],'Index',1,'isInput',true);

% is Saturation?
schema.prop(c,'isSat','bool');

% panel object
schema.prop(c,'Panel','MATLAB array');

%radio buttons data management
p = schema.prop(c,'isTwo','bool'); %two sided saturation selected
p.FactoryValue = true;
schema.prop(c,'isUp','bool'); %one sided saturation with upper limit selected
p.FactoryValue = true;
