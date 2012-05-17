function schema
% Defines properties for @recorder class.

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2006/06/27 23:10:59 $

% Register class 
c = schema.class(findpackage('tsguis'),'recorder');

%% Recorder class is overloaded ctrluis.recorder to be a singleston and to
%% store the status of the M code recorder

%% Public properties

%% Stack properties
schema.prop(c, 'History', 'MATLAB array');   % Event history (text)
schema.prop(c, 'Redo', 'handle vector');     % Redo stack
schema.prop(c, 'Undo', 'handle vector');     % Undo stack

%% M/MAT File path
schema.prop(c,'Path','String');

%% M File storing logged code
schema.prop(c,'Filename','String'); 

%% Flag indicating if data has been saved in this logging session
p = schema.prop(c,'Saveddata','on/off'); 
p.FactoryValue = 'off';

%% Current recording status
schema.prop(c, 'Recording','on/off');

%% Dialog handle
schema.prop(c,'Dialog','MATLAB array'); 

%% List of variable (time series) names to be passed into the generated
%% function
schema.prop(c,'TimeseriesIn','MATLAB array'); 

%% List of output variable (time series) names to be passed from the generated
%% function
schema.prop(c,'TimeseriesOut','MATLAB array'); 

%% Current transaction
schema.prop(c,'CurrentTransaction','MATLAB array'); 
