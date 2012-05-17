function schema
%SCHEMA  Defines properties for @FreqPeakRespData class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:18:22 $

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('resppack'), 'FreqPeakRespData', superclass);

% Public attributes
schema.prop(c, 'Frequency', 'MATLAB array');     % Frequency where gain peak
schema.prop(c, 'PeakResponse', 'MATLAB array');  % Complex response at peak
