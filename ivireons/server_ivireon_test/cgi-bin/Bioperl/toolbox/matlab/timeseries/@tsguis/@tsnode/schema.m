function schema
% Defines properties for @tsnode class.
%
%   Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2008/08/20 23:00:19 $


%% Register class (subclass)
pparent = findpackage('tsexplorer');
c = schema.class(findpackage('tsguis'), 'tsnode', findclass(pparent,'node'));

%% Public properties
schema.prop(c,'Timeseries','handle');

%% @timetable handle for time series edit and display
schema.prop(c,'Tstable','handle');

%% Handle to the Calendar view
schema.prop(c,'Calendar','handle');

%% Property used to record the source of the @timeseries for display
%% on the @tsnode panel
schema.prop(c,'History','string');

%% EventListeners are used to modify the position of events existing in the
%% table. They are separate from the datachange listeners because a faster
%% response is needed to react to adjustement of CursorBar position
schema.prop(c,'EventListeners','handle vector');

%% Handle to the DataChange listener which updates the @tsnode when the
%% @timeseries data changes. Broken out so that is can be disabled
%% to avoid recursion  
schema.prop(c,'Tslistener','handle');

%% Handle to the view chnage listeners which keep the context menus in
%% synch with the available views
schema.prop(c,'Viewlisteners','handle vector');

%% Handle to the Reset Time panel
schema.prop(c,'TimeResetPanel','MATLAB array');

%% Handle to the New Plot Panel
schema.prop(c,'NewPlotPanel','MATLAB array');



