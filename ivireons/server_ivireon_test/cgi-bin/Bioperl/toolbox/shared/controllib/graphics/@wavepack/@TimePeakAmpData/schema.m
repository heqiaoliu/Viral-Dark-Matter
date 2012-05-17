function schema
%SCHEMA  Defines properties for @TimePeakAmpData class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:27:05 $

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('wavepack'), 'TimePeakAmpData', superclass);

% Public attributes
schema.prop(c, 'Time', 'MATLAB array');         % Time where amplitude peaks
schema.prop(c, 'PeakResponse', 'MATLAB array'); % Amplitude at peak
