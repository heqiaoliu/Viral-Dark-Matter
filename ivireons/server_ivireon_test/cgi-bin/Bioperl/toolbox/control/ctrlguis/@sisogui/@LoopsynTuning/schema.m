function schema
%SCHEMA LoopsynTuning


%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/12/27 20:34:18 $

%% Register class 
sisopack = findpackage('sisogui');
c = schema.class(sisopack,'LoopsynTuning',findclass(sisopack,'AutomatedCompensatorTuning'));



%% Properties

%% Tuning Preference
p = schema.prop(c,'TuningPreference','MATLAB array'); 
p.FactoryValue = {};

%% Data for Target Loop Shape
p = schema.prop(c,'TargetLoopShapeData','MATLAB array');
p.FactoryValue = struct( ...
    'TargetLoopShape', 'tf(1,[1,1])', ...
    'TargetOrder', inf, ...
    'UseSpecifiedFreqRange', true, ...
    'SpecifiedFreqRange', '[0,inf]');

%% Data for Target Bandwidth
p = schema.prop(c,'TargetBandwidthData','MATLAB array');
p.FactoryValue = struct( ...
    'TargetBandwidth', '10', ...
    'TargetOrder', inf);

%% Testing hook to show Robust Toolbox Required Panel
p = schema.prop(c,'TestRobustLicense','MATLAB array');
p.FactoryValue = true;