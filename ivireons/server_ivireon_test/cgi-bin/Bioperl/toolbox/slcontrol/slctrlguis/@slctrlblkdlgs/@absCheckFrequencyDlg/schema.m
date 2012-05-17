function schema

%   Author: A. Stothert
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2010/05/10 17:58:11 $

%% Class Definition
%
% Abstract parent class for all frequency check dialog classes.
%
hParentPkg = findpackage('checkpack');
hParent    = findclass(hParentPkg, 'absCheckDlg');
hPackage   = findpackage('slctrlblkdlgs');
hThisClass = schema.class(hPackage, 'absCheckFrequencyDlg', hParent);

%% Class Methods
% callbackLogging
m = schema.method(hThisClass,'callbackLogging');
m.Signature.varargin = 'off';
m.Signature.InputTypes={'handle','string','handle'};
m.Signature.OutputTypes={};
% callbackLinearize
m = schema.method(hThisClass,'callbackLinearize');
m.Signature.varargin = 'off';
m.Signature.InputTypes={'handle','string','handle'};
m.Signature.OutputTypes={};
% configBlk
m = schema.method(hThisClass,'configBlk','Static');
m.Signature.varargin = 'off';
m.Signature.InputTypes = {'handle'};
m.Signature.OutputType = {};
% getCoreBlock
m = schema.method(hThisClass,'getCoreBlock','Static');
m.Signature.varargin = 'off';
m.Signature.InputTypes = {'handle'};
m.Signature.OutputType = {'handle'};
% createBlockScope
m = schema.method(hThisClass,'createBlockScope','Static');
m.Signature.varargin = 'off';
m.Signature.InputTypes = {'mxArray','mxArray','mxArray'};
m.Signature.OutputType = {};
% copyBlkFcn
m = schema.method(hThisClass,'copyBlkFcn','Static');
m.Signature.varargin = 'off';
m.Signature.InputTypes = {'string'};
m.Signature.OutputTypes={};
% loadBlkFcn
m = schema.method(hThisClass,'loadBlkFcn','Static');
m.Signature.varargin = 'off';
m.Signature.InputTypes = {'string'};
m.Signature.OutputTypes={};

%% Class Properties
%Properties relating to linearization
if isempty( findtype('slctrlblkdlgs_enumLinearizeAt') )
  schema.EnumType('slctrlblkdlgs_enumLinearizeAt', {'SnapshotTimes','ExternalTrigger'});
end
if isempty( findtype('slctrlblkdlgs_enumLinearizeTriggerType') )
  schema.EnumType('slctrlblkdlgs_enumLinearizeTriggerType', {'rising','falling'});
end
if isempty( findtype('slctrlblkdlgs_enumRateConversionMethod') )
   schema.EnumType('slctrlblkdlgs_enumRateConversionMethod', ...
   {'zoh', 'tustin', 'prewarp', 'upsampling_zoh', 'upsampling_tustin', 'upsampling_prewarp'});
end
schema.prop(hThisClass,'LinearizationIOs','mxArray');        %Linearization data 
schema.prop(hThisClass,'LinearizeAt','slctrlblkdlgs_enumLinearizeAt');
schema.prop(hThisClass,'SnapshotTimes','string');
schema.prop(hThisClass,'TriggerType','slctrlblkdlgs_enumLinearizeTriggerType');
schema.prop(hThisClass,'ZeroCross','bool');
schema.prop(hThisClass,'SampleTime','string');
schema.prop(hThisClass,'RateConversionMethod','slctrlblkdlgs_enumRateConversionMethod');
schema.prop(hThisClass,'PreWarpFreq','string');
schema.prop(hThisClass,'UseExactDelayModel','bool');
schema.prop(hThisClass,'UseFullBlockNameLabels','bool');
schema.prop(hThisClass,'UseBusSignalLabels','bool');
schema.prop(hThisClass,'hSigSelector','mxArray');           %Signal selector widget 
schema.prop(hThisClass,'hIOTreeListener','mxArray');        %Listener for signal selector events
schema.prop(hThisClass,'showSigSelector','bool');
schema.prop(hThisClass,'isIOModifiedByDlg','bool');        
%Properties relating to logging
schema.prop(hThisClass,'SaveToWorkspace','bool');
schema.prop(hThisClass,'SaveName','string');
%Properties relating to units
schema.prop(hThisClass,'FrequencyUnits','string');
schema.prop(hThisClass,'MagnitudeUnits','string');
schema.prop(hThisClass,'PhaseUnits','string');
