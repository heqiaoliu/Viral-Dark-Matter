function schema
%SCHEMA  Defines properties for @simplot class (simulation data)

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:53 $

% Find parent package
pkg = findpackage('resppack');

% Register class (subclass)
c = schema.class(pkg, 'simplot', findclass(pkg, 'timeplot'));

% Properties
schema.prop(c, 'Input', 'handle vector');    % Driving input (waveform with Nu or 1 subwaves)
schema.prop(c, 'InputDialog', 'handle');     % lsimgui handle
% Rendering style for input data [{tiled}|paired]
% Tiled  -> all input channels shown on every plot
% Paired -> first input with first output, second input with second output,...
p = schema.prop(c, 'InputStyle', 'string');  
p.FactoryValue = 'tiled';
