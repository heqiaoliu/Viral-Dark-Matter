function schema
%SCHEMA

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/11/17 13:25:00 $

% Register class 
sisopack = findpackage('sisogui');
c = schema.class(sisopack,'AutomatedTuningPanel');

% Public Properties
schema.prop(c,'Parent','handle');                   % Parent object (@sisotool)
schema.prop(c,'MainPanel','MATLAB array');          % handle to the main panel
schema.prop(c,'Name','string');                     % Name of the tuning method
schema.prop(c,'Desc','string');                     % Description of the tuning method
schema.prop(c,'IsVisible','bool');                  % Visibility of the tuning panel
schema.prop(c,'VisibilityListeners','MATLAB array');% Handles to visibility listeners
schema.prop(c,'MessageDialogTitle','string');   % Title for any dialog launched from this panel