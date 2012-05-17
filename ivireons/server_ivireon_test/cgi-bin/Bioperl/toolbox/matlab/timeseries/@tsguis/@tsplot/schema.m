function schema
% Defines properties for derived specplot class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2006/06/27 23:12:04 $

% Register class 
p = findpackage('tsguis');
pparent = findpackage('wavepack');
% Register class 
c = schema.class(p,'tsplot',findclass(pparent,'waveplot'));

%% Store parent @viewnode. This is needed so that context menus 
%% can invoke dialogs which are aware of sibling nodes in the htree
schema.prop(c, 'Parent', 'handle');

%% Property defining the waves for whom a selection operation is in
%% progress
schema.prop(c, 'SelectedWaves','MATLAB array');

%% Interval selection mode
if isempty(findtype('tsIntervalSelectionMode'))
    schema.EnumType('tsIntervalSelectionMode', ...
        {'None','IntervalSelect','IntervalSelecting'});
end
p = schema.prop(c,'State','tsIntervalSelectionMode');
p.FactoryValue = 'None';

%% Selection structure
schema.prop(c,'selectionStruct','MATLAB array');

%% Property editor handle
schema.prop(c, 'PropEditor','MATLAB array');

%% Link prop for time axies
schema.prop(c,'xaxeslink','MATLAB array');

p = schema.prop(c,'Absolutetime','on/off');
p.FactoryValue = 'off';
p = schema.prop(c,'Timeunits','string');
p.FactoryValue = 'seconds';