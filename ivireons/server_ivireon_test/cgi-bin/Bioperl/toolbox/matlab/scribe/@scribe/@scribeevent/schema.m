function schema()
%SCHEMA Plotting function done event schema

%   Copyright 1984-2007 The MathWorks, Inc. 

classPkg = findpackage('scribe');
basePkg = findpackage('handle');
baseCls = basePkg.findclass('EventData');

%define class
hClass = schema.class(classPkg , 'scribeevent', baseCls);
hClass.description = 'A high-level plot-edit event';

schema.prop(hClass, 'ObjectsCreated', 'MATLAB array');
schema.prop(hClass, 'SelectedObjects', 'MATLAB array');