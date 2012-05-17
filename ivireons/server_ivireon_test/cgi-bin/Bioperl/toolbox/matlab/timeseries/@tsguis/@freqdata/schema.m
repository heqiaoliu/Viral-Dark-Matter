function schema
%  SCHEMA  Defines properties for @freqdata class

%  Author(s):  
%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.5 $ $Date: 2006/06/27 23:10:21 $

% Register class (subclass)
superclass = findclass(findpackage('resppack'), 'freqdata');
c = schema.class(findpackage('tsguis'),'freqdata',superclass);

% Class attributes
p = schema.prop(c, 'Accumulated', 'on/off');
schema.prop(c, 'Watermarkdata', 'MATLAB array'); 
schema.prop(c, 'Watermarkfreq', 'MATLAB array');

%% Reference property used to map subsets of data to the base timeseries.
%% Used when subsetting is enabled for long time series.
schema.prop(c, 'Reference', 'MATLAB array');

%% Nyquist frequency for this wave. Used to determine the extent.
schema.prop(c, 'NyquistFreq', 'MATLAB array');
