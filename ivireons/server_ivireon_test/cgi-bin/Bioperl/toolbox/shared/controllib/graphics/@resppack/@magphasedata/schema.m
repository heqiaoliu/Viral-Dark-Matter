function schema
%   SCHEMA  Defines properties for @freqdata class

%   Author(s): Bora Eryilmaz
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:21:46 $

% Find parent class (superclass)
supclass = findclass(findpackage('wrfc'), 'data');

% Register class (subclass)
c = schema.class(findpackage('resppack'), 'magphasedata', supclass);

% Public attributes
schema.prop(c, 'Focus', 'MATLAB array');         % Focus (preferred frequency range)
schema.prop(c, 'Frequency', 'MATLAB array');     % Frequency vector, w
p = schema.prop(c, 'FreqUnits', 'string');       % Frequency units
p.FactoryValue = 'rad/sec';
schema.prop(c, 'Magnitude', 'MATLAB array');     % Magnitude data
p = schema.prop(c, 'MagUnits', 'string');        % Magnitude units [{abs}|dB]
p.FactoryValue = 'abs';
schema.prop(c, 'Phase', 'MATLAB array');         % Phase data
p = schema.prop(c, 'PhaseUnits', 'string');      % Phase units [{rad}|deg]
p.FactoryValue = 'rad';
schema.prop(c, 'SoftFocus', 'bool');             % Soft vs hard focus bounds (default=0)
schema.prop(c, 'Ts', 'double');                  % Sample time (for Nyquist frequency)

