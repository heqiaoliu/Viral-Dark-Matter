function schema
% Defines properties for @ArchitectureDialog class

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2008/12/29 01:47:11 $

% Register class 
c = schema.class(findpackage('sisogui'), 'ArchitectureDialog');

% Public
schema.prop(c, 'Figure',     'MATLAB array');  % Dialog figure
schema.prop(c, 'Parent', 'handle');            % Link to SISO Tool database (@sisotool)

schema.prop(c, 'ListSelection', 'MATLAB array');  % List Selection box
schema.prop(c, 'DiagramAxes', 'MATLAB array');    % Axes for Block Diagram
schema.prop(c, 'TableModels', 'MATLAB array');    % Table Models

p = schema.prop(c, 'CurrentData', 'MATLAB array'); % Snapshot of current plant/compensator data
p.AccessFlags.AbortSet = 'off';
p = schema.prop(c, 'ConfigData', 'MATLAB array');  % Internal config. data (@sisodata/@initdata)
p.AccessFlags.AbortSet = 'off';

schema.prop(c, 'Listeners', 'handle vector');     
