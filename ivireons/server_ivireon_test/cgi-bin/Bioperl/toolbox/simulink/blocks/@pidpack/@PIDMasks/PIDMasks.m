function this = PIDMasks(block)

% PIDMasks This is the constructor for the class that manages the dialogs
% of the PID blocks.

%   Author(s): Murad Abu-Khalaf , December 17, 2008
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2009/12/28 04:38:18 $

this = pidpack.PIDMasks(block);
blk = handle(block);

%% Controller
Controller = blk.getPropAllowedValues('Controller');
if strcmp(blk.Controller,Controller{1})
    this.Controller = 0;
elseif strcmp(blk.Controller,Controller{2})
    this.Controller = 1;
elseif strcmp(blk.Controller,Controller{3})
    this.Controller = 2;
elseif strcmp(blk.Controller,Controller{4})
    this.Controller = 3;
elseif strcmp(blk.Controller,Controller{5})
    this.Controller = 4;     
end

%% TimeDomain
TimeDomain = blk.getPropAllowedValues('TimeDomain');
if strcmp(blk.TimeDomain,TimeDomain{1})
    this.TimeDomain = 0;
elseif strcmp(blk.TimeDomain,TimeDomain{2})
    this.TimeDomain = 1;
end

%% SampleTime
this.SampleTime = blk.SampleTime;

%% IntegratorMethod
IntegratorMethod = blk.getPropAllowedValues('IntegratorMethod');
if strcmp(blk.IntegratorMethod,IntegratorMethod{1})
    this.IntegratorMethod = 0;
elseif strcmp(blk.IntegratorMethod,IntegratorMethod{2})
    this.IntegratorMethod = 1;
elseif strcmp(blk.IntegratorMethod,IntegratorMethod{3})
    this.IntegratorMethod = 2;
end

%% FilterMethod
FilterMethod = blk.getPropAllowedValues('FilterMethod');
if strcmp(blk.FilterMethod,FilterMethod{1})
    this.FilterMethod = 0;
elseif strcmp(blk.FilterMethod,FilterMethod{2})
    this.FilterMethod = 1;
elseif strcmp(blk.FilterMethod,FilterMethod{3})
    this.FilterMethod = 2;
end

%% Form
form = blk.getPropAllowedValues('form');
if strcmp(blk.form,form{1})
    this.form = 0;
elseif strcmp(blk.form,form{2})
    this.form = 1;
elseif strcmp(blk.form,form{3})
    this.form = 2;
end


%% P, I, D, N, b, c
this.P = blk.P;
this.I = blk.I;
this.D = blk.D;
this.N = blk.N;
if strcmp(blk.MaskType,'PID 2dof')
    this.b = blk.b;
    this.c = blk.c;
end

%% InitialConditionSource
InitialConditionSource = blk.getPropAllowedValues('InitialConditionSource');
if strcmp(blk.InitialConditionSource,InitialConditionSource{1})
    this.InitialConditionSource = 0;
elseif strcmp(blk.InitialConditionSource,InitialConditionSource{2})
    this.InitialConditionSource = 1;
else
    this.InitialConditionSource = 2;
end

%% InitialConditionForIntegrator, InitialConditionForFilter
this.InitialConditionForIntegrator = blk.InitialConditionForIntegrator;
this.InitialConditionForFilter = blk.InitialConditionForFilter;

%% ExternalReset
ExternalReset = blk.getPropAllowedValues('ExternalReset');
if strcmp(blk.ExternalReset,ExternalReset{1})
    this.ExternalReset = 0;
elseif strcmp(blk.ExternalReset,ExternalReset{2})
    this.ExternalReset = 1;
elseif strcmp(blk.ExternalReset,ExternalReset{3})
    this.ExternalReset = 2;
elseif strcmp(blk.ExternalReset,ExternalReset{4})
    this.ExternalReset = 3;
elseif strcmp(blk.ExternalReset,ExternalReset{5})
    this.ExternalReset = 4;
elseif strcmp(blk.ExternalReset,ExternalReset{6})
    this.ExternalReset = 5;
end
 
%% LimitOutput, LowerSaturationLimit, UpperSaturationLimit, LinearizeAsGain
if strcmp(blk.LimitOutput,'on')
    this.LimitOutput = true;
elseif strcmp(blk.LimitOutput,'off')
    this.LimitOutput = false;
end
this.LowerSaturationLimit = blk.LowerSaturationLimit;
this.UpperSaturationLimit = blk.UpperSaturationLimit;

%% AntiWindupMode, Kb
if strcmp(blk.LinearizeAsGain,'on')
    this.LinearizeAsGain = true;
elseif strcmp(blk.LinearizeAsGain,'off')
    this.LinearizeAsGain = false;
end
AntiWindupMode = blk.getPropAllowedValues('AntiWindupMode');
if strcmp(blk.AntiWindupMode,AntiWindupMode{1})
    this.AntiWindupMode = 0;
elseif strcmp(blk.AntiWindupMode,AntiWindupMode{2})
    this.AntiWindupMode = 1;
elseif strcmp(blk.AntiWindupMode,AntiWindupMode{3})
    this.AntiWindupMode = 2;     
end
this.Kb = blk.Kb;

%% TrackingMode, Kt
if strcmp(blk.TrackingMode,'on')
    this.TrackingMode = true;
elseif strcmp(blk.TrackingMode,'off')
    this.TrackingMode = false;
end
this.Kt = blk.Kt;

%% Data types
this.PParamMin = blk.PParamMin;
this.PParamMax = blk.PParamMax;
this.IParamMin = blk.IParamMin;
this.IParamMax = blk.IParamMax;
this.DParamMin = blk.DParamMin;
this.DParamMax = blk.DParamMax;
this.NParamMin = blk.NParamMin;
this.NParamMax = blk.NParamMax;
if strcmp(blk.MaskType,'PID 2dof')
    this.bParamMin = blk.bParamMin;
    this.bParamMax = blk.bParamMax;
    this.cParamMin = blk.cParamMin;
    this.cParamMax = blk.cParamMax;
end
this.KbParamMin = blk.KbParamMin;
this.KbParamMax = blk.KbParamMax;
this.KtParamMin = blk.KtParamMin;
this.KtParamMax = blk.KtParamMax;
this.POutMin = blk.POutMin;
this.POutMax = blk.POutMax;
this.IOutMin = blk.IOutMin;
this.IOutMax = blk.IOutMax;
this.DOutMin = blk.DOutMin;
this.DOutMax = blk.DOutMax;
this.NOutMin = blk.NOutMin;
this.NOutMax = blk.NOutMax;
if strcmp(blk.MaskType,'PID 2dof')
    this.bOutMin = blk.bOutMin;
    this.bOutMax = blk.bOutMax;
    this.cOutMin = blk.cOutMin;
    this.cOutMax = blk.cOutMax;
end
this.KbOutMin = blk.KbOutMin;
this.KbOutMax = blk.KbOutMax;
this.KtOutMin = blk.KtOutMin;
this.KtOutMax = blk.KtOutMax;

this.IntegratorOutMin = blk.IntegratorOutMin;
this.IntegratorOutMax = blk.IntegratorOutMax;
this.FilterOutMin = blk.FilterOutMin;
this.FilterOutMax = blk.FilterOutMax;

this.SumOutMin = blk.SumOutMin;
this.SumOutMax = blk.SumOutMax;
if strcmp(blk.MaskType,'PID 2dof')
    this.Sum1OutMin = blk.Sum1OutMin;
    this.Sum1OutMax = blk.Sum1OutMax;
    this.Sum2OutMin = blk.Sum2OutMin;
    this.Sum2OutMax = blk.Sum2OutMax;
    this.Sum3OutMin = blk.Sum3OutMin;
    this.Sum3OutMax = blk.Sum3OutMax;
end
this.SumI1OutMin = blk.SumI1OutMin;
this.SumI1OutMax = blk.SumI1OutMax;
this.SumI2OutMin = blk.SumI2OutMin;
this.SumI2OutMax = blk.SumI2OutMax;
this.SumI3OutMin = blk.SumI3OutMin;
this.SumI3OutMax = blk.SumI3OutMax;
this.SumDOutMin = blk.SumDOutMin;
this.SumDOutMax = blk.SumDOutMax;

this.SaturationOutMin = blk.SaturationOutMin;
this.SaturationOutMax = blk.SaturationOutMax;

this.PParamDataTypeStr = blk.PParamDataTypeStr;
this.IParamDataTypeStr = blk.IParamDataTypeStr;
this.DParamDataTypeStr = blk.DParamDataTypeStr;
this.NParamDataTypeStr = blk.NParamDataTypeStr;

this.POutDataTypeStr = blk.POutDataTypeStr;
this.IOutDataTypeStr = blk.IOutDataTypeStr;
this.DOutDataTypeStr = blk.DOutDataTypeStr;
this.NOutDataTypeStr = blk.NOutDataTypeStr;

if strcmp(blk.MaskType,'PID 2dof')
    this.bParamDataTypeStr = blk.bParamDataTypeStr;
    this.bOutDataTypeStr = blk.bOutDataTypeStr;
    this.cParamDataTypeStr = blk.cParamDataTypeStr;
    this.cOutDataTypeStr = blk.cOutDataTypeStr;
end
this.KbParamDataTypeStr = blk.KbParamDataTypeStr;
this.KbOutDataTypeStr = blk.KbOutDataTypeStr;
this.KtParamDataTypeStr = blk.KtParamDataTypeStr;
this.KtOutDataTypeStr = blk.KtOutDataTypeStr;

this.IntegratorOutDataTypeStr = blk.IntegratorOutDataTypeStr;
this.FilterOutDataTypeStr = blk.FilterOutDataTypeStr;

this.SumOutDataTypeStr = blk.SumOutDataTypeStr;
this.SumAccumDataTypeStr = blk.SumAccumDataTypeStr;
if strcmp(blk.MaskType,'PID 2dof')
    this.Sum1OutDataTypeStr = blk.Sum1OutDataTypeStr;
    this.Sum1AccumDataTypeStr = blk.Sum1AccumDataTypeStr;
    this.Sum2OutDataTypeStr = blk.Sum2OutDataTypeStr;
    this.Sum2AccumDataTypeStr = blk.Sum2AccumDataTypeStr;
    this.Sum3OutDataTypeStr = blk.Sum3OutDataTypeStr;
    this.Sum3AccumDataTypeStr = blk.Sum3AccumDataTypeStr;
end
this.SumI1OutDataTypeStr = blk.SumI1OutDataTypeStr;
this.SumI1AccumDataTypeStr = blk.SumI1AccumDataTypeStr;
this.SumI2OutDataTypeStr = blk.SumI2OutDataTypeStr;
this.SumI2AccumDataTypeStr = blk.SumI2AccumDataTypeStr;
this.SumI3OutDataTypeStr = blk.SumI3OutDataTypeStr;
this.SumI3AccumDataTypeStr = blk.SumI3AccumDataTypeStr;
this.SumDOutDataTypeStr = blk.SumDOutDataTypeStr;
this.SumDAccumDataTypeStr = blk.SumDAccumDataTypeStr;
this.SaturationOutDataTypeStr = blk.SaturationOutDataTypeStr;


%% SaturateOnIntegerOverflow, LockScale, RndMeth, ZeroCross, Ignore reset
if strcmp(blk.SaturateOnIntegerOverflow,'on')
    this.SaturateOnIntegerOverflow = true;
elseif strcmp(blk.SaturateOnIntegerOverflow,'off')
    this.SaturateOnIntegerOverflow = false;
end

if strcmp(blk.LockScale,'on')
    this.LockScale = true;
elseif strcmp(blk.LockScale,'off')
    this.LockScale = false;
end
if strcmp(blk.ZeroCross,'on')
    this.ZeroCross = true;
elseif strcmp(blk.ZeroCross,'off')
    this.ZeroCross = false;
end
if strcmp(blk.IgnoreLimit,'on')
    this.IgnoreLimit = true;
elseif strcmp(blk.IgnoreLimit,'off')
    this.IgnoreLimit = false;
end
RndMeth = blk.getPropAllowedValues('RndMeth');
if strcmp(blk.RndMeth,RndMeth{1})
    this.RndMeth = 0;
elseif strcmp(blk.RndMeth,RndMeth{2})
    this.RndMeth = 1;
elseif strcmp(blk.RndMeth,RndMeth{3})
    this.RndMeth = 2;
elseif strcmp(blk.RndMeth,RndMeth{4})
    this.RndMeth = 3;
elseif strcmp(blk.RndMeth,RndMeth{5})
    this.RndMeth = 4;
elseif strcmp(blk.RndMeth,RndMeth{6})
    this.RndMeth = 5;
elseif strcmp(blk.RndMeth,RndMeth{7})
    this.RndMeth = 6;
end

%% Integrator State Attributes
this.IntegratorContinuousStateAttributes = blk.IntegratorContinuousStateAttributes;
this.IntegratorStateIdentifier = blk.IntegratorStateIdentifier;
if strcmp(blk.IntegratorStateMustResolveToSignalObject,'on')
    this.IntegratorStateMustResolveToSignalObject = true;
elseif strcmp(blk.IntegratorStateMustResolveToSignalObject,'off')
    this.IntegratorStateMustResolveToSignalObject = false;
end
this.IntegratorRTWStateStorageClass = blk.IntegratorRTWStateStorageClass;
this.IntegratorRTWStateStorageTypeQualifier = blk.IntegratorRTWStateStorageTypeQualifier;

%% Filter State Attributes
this.FilterContinuousStateAttributes = blk.FilterContinuousStateAttributes;
this.FilterStateIdentifier = blk.FilterStateIdentifier;
if strcmp(blk.FilterStateMustResolveToSignalObject,'on')
    this.FilterStateMustResolveToSignalObject = true;
elseif strcmp(blk.FilterStateMustResolveToSignalObject,'off')
    this.FilterStateMustResolveToSignalObject = false;
end
this.FilterRTWStateStorageClass = blk.FilterRTWStateStorageClass;
this.FilterRTWStateStorageTypeQualifier = blk.FilterRTWStateStorageTypeQualifier;
