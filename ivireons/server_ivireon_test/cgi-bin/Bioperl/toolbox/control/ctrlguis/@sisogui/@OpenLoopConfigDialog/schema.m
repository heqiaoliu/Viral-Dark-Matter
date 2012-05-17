function schema
%SCHEMA  Defines properties for @OpenLoopConfigDialog class

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:41:50 $

% Register class 
sisopack = findpackage('sisogui');
c = schema.class(sisopack,'OpenLoopConfigDialog');

% Data properties
schema.prop(c, 'LoopData', 'handle');

schema.prop(c, 'FeedbackLoops', 'MATLAB array'); % tunedloops that are feedback

schema.prop(c, 'Target', 'MATLAB array');

schema.prop(c, 'LoopConfig', 'MATLAB array'); %Local copy of Loop config

schema.prop(c, 'Dialog', 'MATLAB array');

schema.prop(c, 'Handles', 'MATLAB array');


