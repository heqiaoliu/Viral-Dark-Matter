function schema
% Defines properties for derived xyplot class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2005/12/15 20:58:33 $

% Register class 
p = findpackage('tsguis');
pparent = findpackage('resppack');
% Register class as a subclass of @respplot in order to get multiple
% columns as well as rows
c = schema.class(p,'xyplot',findclass(pparent,'respplot'));

schema.prop(c, 'State', 'string');

%% Store parent @tsseriesnode. This is needed so that context menus 
%% can invoke dialogs which are aware of sibling nodes in the htree
schema.prop(c, 'Parent', 'handle');
schema.prop(c, 'PropEditor','MATLAB array');

%% Time property defaults used by merge/resample dialog
p = schema.prop(c,'Absolutetime','on/off');
p.FactoryValue = 'off';
p = schema.prop(c,'Timeunits','string');
p.FactoryValue = 'seconds';

%% Listener for selection context menu (which does not get disabled when
%% adding/removing time series)
schema.prop(c, 'ContextMenuListener','MATLAB array');

%% Link prop for panning
schema.prop(c, 'Xaxeslink','MATLAB array');
schema.prop(c, 'Yaxeslink','MATLAB array');



