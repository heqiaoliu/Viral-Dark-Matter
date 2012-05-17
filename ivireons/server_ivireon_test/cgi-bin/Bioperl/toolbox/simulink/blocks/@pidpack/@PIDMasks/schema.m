function schema

%   Author(s): Murad Abu-Khalaf , December 17, 2008
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2009/12/28 04:38:28 $

%% =========================================================================
% Class Definition
% =========================================================================

hParentPkg = findpackage('Simulink');
hParent  = findclass(hParentPkg, 'SLDialogSource');
hPackage = findpackage('pidpack');
hThisClass = schema.class(hPackage, 'PIDMasks', hParent);

%% Class Methods

% getDialogSchema
m = schema.method(hThisClass, 'getDialogSchema');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string'};
s.OutputTypes = {'mxArray'};

% getPIDDDG
m = schema.method(hThisClass, 'getPIDDDG');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle','handle'};
s.OutputTypes = {'mxArray'};

% callbackPreApplyPID
m = schema.method(hThisClass,'callbackPreApplyPID');
m.Signature.varargin = 'off';
m.Signature.InputTypes={'handle','handle'};
m.Signature.OutputTypes={'bool','string'};

% callbackPostApplyPID
m = schema.method(hThisClass,'callbackPostApplyPID');
m.Signature.varargin = 'off';
m.Signature.InputTypes={'handle','handle'};
m.Signature.OutputTypes={'bool','string'};

% callbackDialogDDG
m = schema.method(hThisClass,'callbackDialogDDG');
m.Signature.varargin = 'off';
m.Signature.InputTypes={'handle','string','handle'};
m.Signature.OutputTypes={};


%% Class Properties

schema.prop(hThisClass, 'Controller', 'int');
schema.prop(hThisClass, 'TimeDomain', 'int');
schema.prop(hThisClass, 'SampleTime', 'string');
schema.prop(hThisClass, 'IntegratorMethod', 'int');
schema.prop(hThisClass, 'FilterMethod', 'int');

schema.prop(hThisClass, 'Form', 'int');
schema.prop(hThisClass, 'P', 'string');
schema.prop(hThisClass, 'I', 'string');
schema.prop(hThisClass, 'D', 'string');
schema.prop(hThisClass, 'N', 'string');
schema.prop(hThisClass, 'b', 'string');
schema.prop(hThisClass, 'c', 'string');

schema.prop(hThisClass, 'InitialConditionSource', 'int');
schema.prop(hThisClass, 'InitialConditionForIntegrator', 'string');
schema.prop(hThisClass, 'InitialConditionForFilter', 'string');

schema.prop(hThisClass, 'ExternalReset', 'int');
schema.prop(hThisClass, 'IgnoreLimit', 'bool');
schema.prop(hThisClass, 'ZeroCross', 'bool');

schema.prop(hThisClass, 'LimitOutput', 'bool');
schema.prop(hThisClass, 'LowerSaturationLimit', 'string');
schema.prop(hThisClass, 'UpperSaturationLimit', 'string');
schema.prop(hThisClass, 'LinearizeAsGain', 'bool');
schema.prop(hThisClass, 'AntiWindupMode', 'int');
schema.prop(hThisClass, 'Kb', 'string');
schema.prop(hThisClass, 'TrackingMode', 'bool');
schema.prop(hThisClass, 'Kt', 'string');

schema.prop(hThisClass, 'LockScale', 'bool');
schema.prop(hThisClass, 'SaturateOnIntegerOverflow', 'bool');
schema.prop(hThisClass, 'RndMeth', 'int');

schema.prop(hThisClass, 'PParamDataTypeStr', 'string');
schema.prop(hThisClass, 'PParamMin', 'string');
schema.prop(hThisClass, 'PParamMax', 'string');

schema.prop(hThisClass, 'IParamDataTypeStr', 'string');
schema.prop(hThisClass, 'IParamMin', 'string');
schema.prop(hThisClass, 'IParamMax', 'string');

schema.prop(hThisClass, 'DParamDataTypeStr', 'string');
schema.prop(hThisClass, 'DParamMin', 'string');
schema.prop(hThisClass, 'DParamMax', 'string');

schema.prop(hThisClass, 'NParamDataTypeStr', 'string');
schema.prop(hThisClass, 'NParamMin', 'string');
schema.prop(hThisClass, 'NParamMax', 'string');

schema.prop(hThisClass, 'bParamDataTypeStr', 'string');
schema.prop(hThisClass, 'bParamMin', 'string');
schema.prop(hThisClass, 'bParamMax', 'string');

schema.prop(hThisClass, 'cParamDataTypeStr', 'string');
schema.prop(hThisClass, 'cParamMin', 'string');
schema.prop(hThisClass, 'cParamMax', 'string');

schema.prop(hThisClass, 'KbParamDataTypeStr', 'string');
schema.prop(hThisClass, 'KbParamMin', 'string');
schema.prop(hThisClass, 'KbParamMax', 'string');

schema.prop(hThisClass, 'KtParamDataTypeStr', 'string');
schema.prop(hThisClass, 'KtParamMin', 'string');
schema.prop(hThisClass, 'KtParamMax', 'string');

schema.prop(hThisClass, 'POutDataTypeStr', 'string');
schema.prop(hThisClass, 'POutMin', 'string');
schema.prop(hThisClass, 'POutMax', 'string');

schema.prop(hThisClass, 'IOutDataTypeStr', 'string');
schema.prop(hThisClass, 'IOutMin', 'string');
schema.prop(hThisClass, 'IOutMax', 'string');

schema.prop(hThisClass, 'DOutDataTypeStr', 'string');
schema.prop(hThisClass, 'DOutMin', 'string');
schema.prop(hThisClass, 'DOutMax', 'string');

schema.prop(hThisClass, 'NOutDataTypeStr', 'string');
schema.prop(hThisClass, 'NOutMin', 'string');
schema.prop(hThisClass, 'NOutMax', 'string');

schema.prop(hThisClass, 'bOutDataTypeStr', 'string');
schema.prop(hThisClass, 'bOutMin', 'string');
schema.prop(hThisClass, 'bOutMax', 'string');

schema.prop(hThisClass, 'cOutDataTypeStr', 'string');
schema.prop(hThisClass, 'cOutMin', 'string');
schema.prop(hThisClass, 'cOutMax', 'string');

schema.prop(hThisClass, 'KbOutDataTypeStr', 'string');
schema.prop(hThisClass, 'KbOutMin', 'string');
schema.prop(hThisClass, 'KbOutMax', 'string');

schema.prop(hThisClass, 'KtOutDataTypeStr', 'string');
schema.prop(hThisClass, 'KtOutMin', 'string');
schema.prop(hThisClass, 'KtOutMax', 'string');

schema.prop(hThisClass, 'IntegratorOutDataTypeStr', 'string');
schema.prop(hThisClass, 'IntegratorOutMin', 'string');
schema.prop(hThisClass, 'IntegratorOutMax', 'string');

schema.prop(hThisClass, 'FilterOutDataTypeStr', 'string');
schema.prop(hThisClass, 'FilterOutMin', 'string');
schema.prop(hThisClass, 'FilterOutMax', 'string');

schema.prop(hThisClass, 'SumOutDataTypeStr', 'string');
schema.prop(hThisClass, 'SumOutMin', 'string');
schema.prop(hThisClass, 'SumOutMax', 'string');
schema.prop(hThisClass, 'SumAccumDataTypeStr', 'string');

schema.prop(hThisClass, 'Sum1OutDataTypeStr', 'string');
schema.prop(hThisClass, 'Sum1OutMin', 'string');
schema.prop(hThisClass, 'Sum1OutMax', 'string');
schema.prop(hThisClass, 'Sum1AccumDataTypeStr', 'string');

schema.prop(hThisClass, 'Sum2OutDataTypeStr', 'string');
schema.prop(hThisClass, 'Sum2OutMin', 'string');
schema.prop(hThisClass, 'Sum2OutMax', 'string');
schema.prop(hThisClass, 'Sum2AccumDataTypeStr', 'string');

schema.prop(hThisClass, 'Sum3OutDataTypeStr', 'string');
schema.prop(hThisClass, 'Sum3OutMin', 'string');
schema.prop(hThisClass, 'Sum3OutMax', 'string');
schema.prop(hThisClass, 'Sum3AccumDataTypeStr', 'string');

schema.prop(hThisClass, 'SumI1OutDataTypeStr', 'string');
schema.prop(hThisClass, 'SumI1OutMin', 'string');
schema.prop(hThisClass, 'SumI1OutMax', 'string');
schema.prop(hThisClass, 'SumI1AccumDataTypeStr', 'string');

schema.prop(hThisClass, 'SumI2OutDataTypeStr', 'string');
schema.prop(hThisClass, 'SumI2OutMin', 'string');
schema.prop(hThisClass, 'SumI2OutMax', 'string');
schema.prop(hThisClass, 'SumI2AccumDataTypeStr', 'string');

schema.prop(hThisClass, 'SumI3OutDataTypeStr', 'string');
schema.prop(hThisClass, 'SumI3OutMin', 'string');
schema.prop(hThisClass, 'SumI3OutMax', 'string');
schema.prop(hThisClass, 'SumI3AccumDataTypeStr', 'string');

schema.prop(hThisClass, 'SumDOutDataTypeStr', 'string');
schema.prop(hThisClass, 'SumDOutMin', 'string');
schema.prop(hThisClass, 'SumDOutMax', 'string');
schema.prop(hThisClass, 'SumDAccumDataTypeStr', 'string');

schema.prop(hThisClass, 'SaturationOutDataTypeStr', 'string');
schema.prop(hThisClass, 'SaturationOutMin', 'string');
schema.prop(hThisClass, 'SaturationOutMax', 'string');

schema.prop(hThisClass, 'IntegratorContinuousStateAttributes', 'string');
schema.prop(hThisClass, 'IntegratorStateIdentifier', 'string');
schema.prop(hThisClass, 'IntegratorStateMustResolveToSignalObject', 'bool');
schema.prop(hThisClass, 'IntegratorRTWStateStorageClass', 'string');
schema.prop(hThisClass, 'IntegratorRTWStateStorageTypeQualifier', 'string');

schema.prop(hThisClass, 'FilterContinuousStateAttributes', 'string');
schema.prop(hThisClass, 'FilterStateIdentifier', 'string');
schema.prop(hThisClass, 'FilterStateMustResolveToSignalObject', 'bool');
schema.prop(hThisClass, 'FilterRTWStateStorageClass', 'string');
schema.prop(hThisClass, 'FilterRTWStateStorageTypeQualifier', 'string');

