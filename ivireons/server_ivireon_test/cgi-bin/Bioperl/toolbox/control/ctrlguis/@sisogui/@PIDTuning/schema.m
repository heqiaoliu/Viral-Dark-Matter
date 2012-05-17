function schema
%SCHEMA

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/08 21:28:11 $

% Register class 
sisopack = findpackage('sisogui');
c = schema.class(sisopack,'PIDTuning',findclass(sisopack,'AutomatedCompensatorTuning'));

% private properties
schema.prop(c,'ControllerTypesRRT','MATLAB array'); % pid type
schema.prop(c,'ControllerTypesRule','MATLAB array'); % pid type
schema.prop(c,'TuningMethods','MATLAB array'); % tuning methods
schema.prop(c,'Formula','MATLAB array'); % rule based formula
schema.prop(c,'DesignObjRRT','MATLAB array'); % rule based formula
schema.prop(c,'DeleteListener','MATLAB array'); % rule based formula