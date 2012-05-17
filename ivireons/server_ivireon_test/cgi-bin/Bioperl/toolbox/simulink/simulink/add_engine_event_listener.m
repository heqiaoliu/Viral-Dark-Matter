function add_engine_event_listener(model, eventType, listenerCallback)
%
%    'EnginePreCompStart'
%    'EnginePostCompStart'
%    'EnginePostLibraryLinkResolve'
%    'EnginePostModelRefUpdate'
%    'EnginePreParameterEval'
%    'EnginePostParamEval'
%    'EnginePostSizeProp'
%    'EnginePostSampleTimeProp'
%    'EnginePostTypeProp'
%    'EnginePostProp'
%    'EnginePostRateTransInsert'
%    'EnginePostBlock'
%    'EnginePostHiddenBufInsert'
%    'EnginePostCEDPropagation'
%    'EnginePostSortedList'
%    'EnginePostHiddenSubsysInsert'
%    'EnginePostCallGraph'
%    'EnginePostFullCanIO'
%    'EnginePostFullCanPrm'
%    'EnginePostCompChecksum'
%    'EnginePostCompReuseInfo'
%    'EnginePostCanIO'
%    'EnginePostCanPrm'
%    'EnginePostBufferAlloc'
%    'EnginePostDWorkAlloc'
%    'EngineCompFailed'
%    'EngineCompPassed'
%    'EnginePostRTWIndices'
%    'EnginePreRTWData'
%    'EnginePostRTWData'
%    'EnginePostRTWCompFileNames'
%    'EngineRTWGenFailed'
%    'EngineRTWGenPassed'
%    'EngineSimStatusStopped'
%    'EngineSimStatusPaused'
%    'EngineSimStatusUpdating'
%    'EngineSimStatusInitializing'
%    'EngineSimStatusRunning'
%    'EngineSimStatusTerminating'
%    'EngineSimStatusExternal'
%

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $

%
% the requisite nargin checking...
%
if nargin ~= 3,
    DAStudio.error('Simulink:utility:NumInputMismatch', 3);
end

bdh = get_param(model, 'UDDObject');

if isempty(bdh)
    DAStudio.error('Simulink:utility:BDNotExecuting');
end

bdh = handle(bdh);

%
% 
%
p = findprop(bdh, 'Listener_Storage_');
if isempty(p)
  p = schema.prop(bdh, 'Listener_Storage_', 'handle vector');
  p.Visible = 'off';
end

%
% Make sure that the listener isn't already attached
%
bdListeners = bdh.Listener_Storage_;
for i=1:length(bdListeners)
  if isequal(bdListeners(i).callback, listenerCallback)
    return;
  end
end

%
% Create a new listener and attach it to the block diagram
%
hl = handle.listener(bdh, eventType, listenerCallback);
hl = [bdh.Listener_Storage_; hl];
bdh.Listener_Storage_ = hl;
  
%% [EOF] add_engine_listener.m
