function schema
%  SCHEMA  Defines properties for @timedata class

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:27:24 $

% Find parent class (superclass)
supclass = findclass(findpackage('wrfc'), 'data');

% Register class (subclass)
c = schema.class(findpackage('wavepack'), 'timedata', supclass);

% Public attributes
schema.prop(c, 'Focus', 'MATLAB array');         % Focus (preferred time range)
schema.prop(c, 'Amplitude',      'MATLAB array');   % Amplitude Y(t)
schema.prop(c, 'AmplitudeUnits', 'string');         % Amplitude units
schema.prop(c, 'Time',        'MATLAB array');      % Time vector, t
p = schema.prop(c, 'TimeUnits',   'string');        % Time units
p.FactoryValue = 'sec';
schema.prop(c, 'Ts',   'double');                   % Sample time (for continuous vs. discrete)
