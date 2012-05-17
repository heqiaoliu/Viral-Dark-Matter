function schema
%SCHEMA Schema for pwlineareditor class

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2007/06/07 14:42:19 $

% Construct class
hCreateInPackage   = findpackage('nlutilspack');
c = schema.class(hCreateInPackage, 'pwlineareditor');

% UIs
schema.prop(c,'Handles','MATLAB array');

%{
p.FactoryValue = struct('ApplyBtn',[],'CloseBtn',[],'HelpBtn',[],'XEdit',[],...
    'YEdit',[],'RadioGroup',[]);
%}

% Parameters to be used by nlgui
p = schema.prop(c,'Parameters','MATLAB array');
p.FactoryValue = struct('x',[],'y',[],'Panel',[],'Index',1,'isInput',true);

p = schema.prop(c,'NumUnits','double');
p.FactoryValue = 10;

p = schema.prop(c,'isXonly','bool'); 
p.FactoryValue = true;
