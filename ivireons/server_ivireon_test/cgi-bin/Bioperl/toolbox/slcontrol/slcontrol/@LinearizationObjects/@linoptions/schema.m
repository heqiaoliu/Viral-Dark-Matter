function schema
%SCHEMA  Defines properties for @linoptions class

%  Author(s): John Glass
%  Revised:
%  Copyright 2005-2008 The MathWorks, Inc.
%  $Revision: 1.1.6.15 $ $Date: 2008/10/31 07:35:16 $

% Find the package
pkg = findpackage('LinearizationObjects');

% Register class
c = schema.class(pkg, 'linoptions');

% Generic Linearization Properties
p = schema.prop(c, 'LinearizationAlgorithm', 'string');
p.FactoryValue = 'blockbyblock';
p.SetFunction = @LocalSetValue;
p.Description = 'GenericLinearization';
p = schema.prop(c, 'SampleTime', 'MATLAB array');     
p.FactoryValue = -1;
p.Description = 'GenericLinearization';
p = schema.prop(c, 'UseFullBlockNameLabels', 'on/off');
p.FactoryValue = 'off';
p.Description = 'GenericLinearization';
p = schema.prop(c, 'UseBusSignalLabels', 'on/off');
p.FactoryValue = 'off';
p.Description = 'GenericLinearization';

% Block By Block Linearization Properties
p = schema.prop(c,'RateConversionMethod', 'string');
p.FactoryValue = 'zoh';
p.SetFunction = @LocalSetRateConv;
p.Description = 'BlockByBlockLinearization';
p = schema.prop(c, 'PreWarpFreq', 'MATLAB array');     
p.FactoryValue = 10;
p.Description = 'BlockByBlockLinearization';
p = schema.prop(c, 'BlockReduction', 'on/off');       
p.FactoryValue = 'on';
p.Description = 'BlockByBlockLinearization';
p = schema.prop(c, 'IgnoreDiscreteStates', 'on/off'); 
p.FactoryValue = 'off';
p.Description = 'BlockByBlockLinearization';
p = schema.prop(c, 'UseExactDelayModel', 'on/off'); 
p.FactoryValue = 'off';
p.Description = 'BlockByBlockLinearization';

% Numerical Perturbation Linearization Properties
p = schema.prop(c, 'NumericalPertRel', 'MATLAB array');     
p.FactoryValue = 1e-5;
p.Description = 'NumericalPerturbLinearization';
p = schema.prop(c, 'NumericalXPert', 'MATLAB array');     
p.FactoryValue = [];
p.Description = 'NumericalPerturbLinearization';
p = schema.prop(c, 'NumericalUPert', 'MATLAB array');     
p.FactoryValue = [];
p.Description = 'NumericalPerturbLinearization';

% Operating Point Search Properties
p = schema.prop(c, 'OptimizationOptions', 'MATLAB array');       
opt = LocalGetOptions('graddescent_elim');
% Generic settings
opt.MaxIter = 400;
opt.MaxFunEvals = 600;
opt.Display = 'off';
p.FactoryValue = opt;  
p.Description = 'OperatingPointSearch';

% Set the default optimizer. 
p = schema.prop(c, 'OptimizerType', 'MATLAB array');
p.FactoryValue = 'graddescent_elim';
p.SetFunction = @LocalOptimSet;
p.Description = 'OperatingPointSearch';

% Set the hidden property to by pass the consistency cheching 
p = schema.prop(c, 'ByPassConsistencyCheck', 'on/off');
p.FactoryValue = 'off';
p.Description = 'General';

p = schema.prop(c, 'DisplayReport', 'string');
p.FactoryValue = 'on';
p.Description = 'OperatingPointSearch';

% Event when the data has changed
schema.event(c,'OptimizerTypeChanged'); 

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to check for valid rate conversion methods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NewValue = LocalSetRateConv(this,NewValue)

switch NewValue
    case {'zoh', 'tustin', 'prewarp', 'upsampling_zoh', 'upsampling_tustin', 'upsampling_prewarp'}
        %% No Error
    otherwise
        ctrlMsgUtils.error('Slcontrol:linearize:InvalidRateConversionRoutine')
end    

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Function to check for valid optimization schemes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NewValue = LocalOptimSet(this,NewValue)

switch NewValue
    case {'graddescent_elim','graddescent'}
        if ~any(strcmp(this.OptimizerType,{'graddescent_elim','graddescent'}))
            LocalUpdateOptions(this,NewValue);
            FireOptimizerTypeChanged(this,NewValue)
        end
    case {'simplex'}
        % No error
        LocalUpdateOptions(this,NewValue);
        FireOptimizerTypeChanged(this,NewValue)
    case {'lsqnonlin','fminunc'}
        if ~license('test','Optimization_Toolbox')
            types = 'graddescent_elim, graddescent, or simplex';
            ctrlMsgUtils.error('Slcontrol:findop:InvalidOptimizationRoutine',NewValue,types)
        end
        LocalUpdateOptions(this,NewValue);
    otherwise
        if license('test','Optimization_Toolbox')
            types = 'graddescent_elim, graddescent, simplex, or lsqnonlin';
        else
            types = 'graddescent_elim, graddescent, or simplex';
        end
        ctrlMsgUtils.error('Slcontrol:findop:InvalidOptimizationRoutine',NewValue,types)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateOptions(this,NewValue)
            
oldopt = this.OptimizationOptions;
this.OptimizationOptions = LocalGetOptions(NewValue);
this.OptimizationOptions.MaxIter = oldopt.MaxIter;
this.OptimizationOptions.MaxFunEvals = oldopt.MaxFunEvals;
this.OptimizationOptions.Display = oldopt.Display;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function FireOptimizerTypeChanged(this,NewValue)
eventData = ctrluis.dataevent(this,'OptimizerTypeChanged',NewValue);
send(this,'OptimizerTypeChanged',eventData)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Function to check for valid input arguments 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NewValue = LocalSetValue(this,NewValue)

if (~strcmp(NewValue,'blockbyblock') && ~strcmp(NewValue,'numericalpert'))
    ctrlMsgUtils.error('Slcontrol:linearize:InvalidLinearizationAlgorithm')    
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Create default optimizer options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function opt = LocalGetOptions(optimtype)

switch optimtype
    case {'graddescent_elim','graddescent'}
        opt = scdconstrsh('defaults');
        opt.TolX = 1e-6;
        opt.Jacobian = 'off';
        opt.LargeScale = 'off';
    case 'simplex'
        opt = optimset('fminsearch');
    case 'lsqnonlin'
        opt = optimset('lsqnonlin');
        opt.LargeScale = 'off';
        opt.Algorithm = 'levenberg-marquardt';
    otherwise
        opt = optimset(optimtype);
end


