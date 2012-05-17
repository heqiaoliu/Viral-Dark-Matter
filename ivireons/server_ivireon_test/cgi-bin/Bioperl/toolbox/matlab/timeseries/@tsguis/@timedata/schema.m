function schema
% Defines properties for @timedata class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2005/06/27 23:01:01 $


% Register class (subclass)
p = findpackage('tsguis');
pparent = findpackage('wavepack');
c = schema.class(p, 'timedata',findclass(pparent,'timedata'));

% Register class 
schema.prop(c, 'Watermarkdata', 'MATLAB array'); 
schema.prop(c, 'Watermarktime', 'MATLAB array');

%% Offset property used to map absolute time vectors to a relative scale
%% for plotting. Needed to avoid numericl problems when very short time
%% series have reference dates
schema.prop(c, 'Offset', 'MATLAB array');

%% Reference property used to map subsets of data to the base timeseries.
%% Used when subsetting is enabled for long time series.
schema.prop(c, 'Reference', 'MATLAB array');

%p = schema.prop(c, 'Timeseries', 'handle');
% p = schema.prop(c, 'Min', 'MATLAB array'); 
% p.GetFunction = @getMin;
% p = schema.prop(c, 'Max', 'MATLAB array'); 
% p.GetFunction = @getMax;






