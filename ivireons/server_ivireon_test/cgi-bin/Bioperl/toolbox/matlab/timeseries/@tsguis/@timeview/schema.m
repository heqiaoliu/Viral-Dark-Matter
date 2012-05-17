function schema
% Defines properties for @timedata class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2006/11/29 21:52:47 $


% Register class (subclass)
p = findpackage('tsguis');
pparent = findpackage('wavepack');
c = schema.class(p, 'timeview',findclass(pparent,'timeview'));

%% Selection lines
schema.prop(c, 'SelectionCurves', 'MATLAB array');

%% List of selected observation indices
schema.prop(c, 'SelectedPoints', 'MATLAB array');

%% Selected time intervals
schema.prop(c, 'SelectedTimes', 'MATLAB array');

% Handles of selected time range rectangles
schema.prop(c, 'SelectionPatch', 'MATLAB array');

%% Watermark lines
schema.prop(c, 'WatermarkCurves', 'MATLAB array');

%% Selection context menu handles
p = schema.prop(c, 'Menus', 'MATLAB array');
p.FactoryValue = struct('delete',[],'remove',[],'newevent',[],'keep',[]);







