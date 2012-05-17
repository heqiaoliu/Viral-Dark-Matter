function schema
%SCHEMA  Schema for the Nichols Plot Editor.

%   Author(s): Bora Eryilmaz
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $ $Date: 2010/04/11 20:30:14 $

% Find parent package
sisopack = findpackage('sisogui');

% Find parent class (superclass)
sisoclass = findclass(sisopack, 'grapheditor');

% Register class (subclass)
c = schema.class(sisopack, 'nicholseditor', sisoclass);

% Editor data and units
schema.prop(c, 'Frequency', 'MATLAB array');      % Frequency vector (always in rad/sec)
schema.prop(c, 'FrequencyUnits', 'string');       % Frequency units (in use by editor)
schema.prop(c, 'Magnitude', 'MATLAB array');      % Magnitude vector
schema.prop(c, 'Phase', 'MATLAB array');          % Phase vector 

% Plot attributes
schema.prop(c, 'ShowSystemPZ', 'on/off');         % Visibility of poles/zeros
p = schema.prop(c, 'MarginVisible', 'on/off');          % Stability margin
set(p, 'AccessFlags.Init', 'on', 'FactoryValue', 'on'); % visibility

% Frequency focus (private)
p = schema.prop(c,'FreqFocus','MATLAB array');  % Optimal frequency focus (rad/sec)
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

% Uncertainty Bounds
p = schema.prop(c,'UncertainBounds','MATLAB array');
p = schema.prop(c,'UncertainData','MATLAB array');

% Frequency Data in rad/sec for multimodel display
p = schema.prop(c,'MultiModelFrequency','MATLAB array'); 