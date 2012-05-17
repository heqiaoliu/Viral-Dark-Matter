function schema
%   SCHEMA  Defines properties for @sigmadata class

%   Author(s): Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:24:01 $

% Find parent class (superclass)
supclass = findclass(findpackage('wrfc'), 'data');

% Register class (subclass)
c = schema.class(findpackage('resppack'), 'sigmadata', supclass);

% Public attributes
schema.prop(c, 'Focus', 'MATLAB array');         % Focus (preferred frequency range)
schema.prop(c, 'Frequency', 'MATLAB array');     % Frequency vector, w
p = schema.prop(c, 'FreqUnits', 'string');  % Frequency units
p.FactoryValue = 'rad/sec';
schema.prop(c, 'SingularValues', 'MATLAB array');     % Singular Values data
p = schema.prop(c, 'MagUnits', 'string');        % Magnitude units
p.FactoryValue = 'abs';
schema.prop(c, 'SoftFocus', 'bool');             % Soft vs hard focus bounds (default=0)
schema.prop(c, 'Ts', 'double');                  % Sample time for Nyquist Frequency 
