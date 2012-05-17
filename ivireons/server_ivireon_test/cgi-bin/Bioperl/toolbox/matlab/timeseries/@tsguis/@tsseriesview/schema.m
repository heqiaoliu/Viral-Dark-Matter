function schema
% Defines properties for @seriesview class which represents
% views of time series as plots or in table form.
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 23:03:58 $

% Register class 
p = findpackage('tsguis');
c = schema.class(p, 'tsseriesview',findclass(p,'viewnode'));


% Public properties
p = schema.prop(c,'Viewstate','string');
p.FactoryValue = 'Plot';
p = schema.prop(c,'Calendar','MATLAB array');

%% Char listener array. Used to keep the characteristic table
%% synced with the char visibility
schema.prop(c,'CharListeners','MATLAB array');


