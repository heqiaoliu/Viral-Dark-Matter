function schema
% Defines properties for derived corrplot class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2005/11/27 22:41:53 $

% Register class 
p = findpackage('tsguis');
pparent = findpackage('resppack');
% Register class as a subclass of @respplot in order to get multiple
% columns as well as rows
c = schema.class(p,'corrplot',findclass(pparent,'respplot'));

%% Store parent @tsseriesnode. This is needed so that context menus 
%% can invoke dialogs which are aware of sibling nodes in the htree
schema.prop(c, 'Parent', 'handle');
schema.prop(c, 'State', 'MATLAB array');
schema.prop(c, 'PropEditor','MATLAB array');

p = schema.prop(c,'Lags','MATLAB array');
p.FactoryValue = [-10:10];

%% Time property defaults used by merge/resample dialog
p = schema.prop(c,'Absolutetime','on/off');
p.FactoryValue = 'off';
p = schema.prop(c,'Timeunits','string');
p.FactoryValue = 'seconds';

