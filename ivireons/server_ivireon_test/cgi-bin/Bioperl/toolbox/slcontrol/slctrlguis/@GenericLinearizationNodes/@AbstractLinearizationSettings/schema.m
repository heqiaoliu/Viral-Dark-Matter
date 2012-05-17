function schema
%  SCHEMA  Defines properties for AbstractLinearizationSettings class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.

% Find parent package
pkg = findpackage('explorer');

% Find parent class (superclass)
supclass = findclass(pkg, 'tasknode');

% Register class (subclass) in package
c = schema.class(findpackage('GenericLinearizationNodes'), 'AbstractLinearizationSettings', supclass);

% Properties
p = schema.prop(c, 'LinearizationSettings', 'MATLAB array');
p.FactoryValue = struct('BlockReduction','on',...
                        'IgnoreDiscreteStates','off',...
                        'SampleTime',-1,...
                        'UseModelPerturbation','off');
                    
% Listeners
p = schema.prop(c, 'OperatingConditionsListeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'LinearizationResultsListeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

% Events
schema.event(c,'AnalysisLabelChanged'); 
