function schema
%SCHEMA  Defines properties for @ImportDialog class

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/01/26 01:47:14 $

% Register class 
sisopack = findpackage('sisogui');
c = schema.class(sisopack,'ImportDialog');

% Data properties
p = schema.prop(c,'Design','MATLAB array');    % Handle to @Design objects
p.AccessFlags.AbortSet = 'off';

schema.prop(c,'ImportList','MATLAB array');    % Identifiers to Compensator

schema.prop(c,'Handles', 'MATLAB array');     % Handles to objects of GUI
schema.prop(c,'Parent','MATLAB array');       % Frame of parent
schema.prop(c,'sisodb','handle');             % Parent object (@sisotool)
schema.prop(c,'LoopData', 'handle');


% Private properties
p = schema.prop(c,'Listeners','handle vector');          % Listeners
set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');

