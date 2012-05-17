function schema
% Defines properties for @DiagramDisplay class

%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2008/12/29 01:47:12 $

% Register class 
c = schema.class(findpackage('sisogui'), 'DiagramDisplay');

% Public
schema.prop(c, 'Figure', 'MATLAB array');        % Dialog figure
schema.prop(c, 'Parent', 'handle');            % Link to SISO Tool database (@sisotool)
schema.prop(c, 'LoopConfig', 'MATLAB array');
schema.prop(c, 'Handles', 'MATLAB array');

schema.prop(c, 'Listeners', 'handle vector');     
