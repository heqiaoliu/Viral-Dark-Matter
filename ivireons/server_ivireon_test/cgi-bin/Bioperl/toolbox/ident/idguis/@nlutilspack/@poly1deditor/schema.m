function schema
%SCHEMA Schema for poly1deditor class

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2008/05/19 23:05:06 $

% Construct class
hCreateInPackage   = findpackage('nlutilspack');
c = schema.class(hCreateInPackage, 'poly1deditor');

% UIs
schema.prop(c,'Handles','MATLAB array');

% Parameters to be used by nlgui
p = schema.prop(c,'Parameters','MATLAB array');
p.FactoryValue = struct('Coefficients',[],'Panel',[],'Index',1,'isInput',true);

p = schema.prop(c,'Degree','double');
p.FactoryValue = 2;

