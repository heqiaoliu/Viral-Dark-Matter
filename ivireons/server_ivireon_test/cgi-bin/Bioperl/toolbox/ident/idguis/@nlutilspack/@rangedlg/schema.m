function schema
%SCHEMA Schema for rangedlg class

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:55:15 $

% Construct class
hCreateInPackage = findpackage('nlutilspack');
c = schema.class(hCreateInPackage, 'rangedlg');

schema.prop(c,'Dialog','handle');

% UIs
p = schema.prop(c,'UIs','MATLAB array');
p.FactoryValue = struct('ApplyBtn',[],'CloseBtn',[],'HelpBtn',[],...
    'EditBox',[],'TopLabel',[]);

% Type: time, frequency, nonlinear
p = schema.prop(c,'Type','string');
p.FactoryValue = 'nonlinear';

% plot object where vakues are inserted
schema.prop(c,'PlotObj','MATLAB array');
