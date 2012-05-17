function slblkCheckFreqChar(block)
% SLBLKCHECKFREQCHAR m-s-function for all frequency domain check blocks

%   Author: A. Stothert
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/05/10 17:58:15 $

setup(block)
end

function setup(block)

% Register number of port
block.NumInputPorts  = 1;
block.NumOutputPorts = 1;

% Override input port properties
block.InputPort(1).Dimensions   = 1;
block.InputPort(1).DatatypeID   = 8;  %bool
block.InputPort(1).Complexity   = 'Real';
block.InputPort(1).SamplingMode = 0;  %Non-Frame based

% Override output port properties
block.OutputPort(1).Dimensions   = 1;
block.OutputPort(1).DatatypeID   = 0; % double
block.OutputPort(1).Complexity   = 'Real';
block.OutputPort(1).SamplingMode = 0;  %Non-Frame based

% Register parameters
block.NumDialogPrms     = 0;
% Specify the block SimStateCompliance
block.SimStateCompliance = 'HasNoSimState';

%Set block sample time to fixed in minor time step
block.SampleTimes = [0 1];

%Get the block parent (the check block), the model the block is in, and the 
%top level model. Find the top level model from the 
%ModelReferenceNormalModeCallback which is set on the model EnginePostLibraryLinkResolve 
%event.
parent = get_param(block.BlockHandle,'Parent');
model  = strtok(parent,'/');
MdlRefCpy = get_param(model,'ModelReferenceNormalModeCallback');
if ~isempty(MdlRefCpy)
   modelTop  = MdlRefCpy.ParameterManager.Model;
else
   %Protect against case where NormalModeCallback has not been set.
   modelTop = model;
end

%Perform any block parameter checks
[SnapTimes,SampleTime,PrewarpFreq] = localCheckParameters(parent);
if strcmp(get_param(parent,'LinearizeAt'),'SnapshotTimes')
   linAtZero = any(SnapTimes == 0);
else
   linAtZero = false;
end
linios = getlinio(parent);
if isempty(linios)
   ctrlMsgUtils.warning('Slcontrol:slctrlblkdlgs:warnNoLinIOs',parent);
else
   %May need to re-label model ios as we're in a normal mode multi-instance
   %model reference
   localCheckIOs(model,parent,linios);
end

%Get all bounds defined in the block
hReqs = getbounds(parent);
%Collapse bounds into a vector of requirement objects
hReq = [];
for ct = 1:numel(hReqs)
   hReq = vertcat(hReq,hReqs{ct}(:)); %#ok<AGROW>
end
if ~isempty(hReq)
   %Only evaluate enabled bounds
   hReq = hReq(hReq.isEnabled);
end

%Check if the visualization is open and does not have unapplied changes
hView = getappdata(handle(block.BlockHandle),'BlockVisualization');
haveView = isa(hView,'uiscopes.Framework');
if haveView
   hR = hView.getExtInst('Tools:Requirement Viewer');
   if hR.isDirty
       error('SLControllib:checkpack:errVisualizationHasUnappliedChanges', ...
          DAStudio.message('SLControllib:checkpack:errVisualizationHasUnappliedChanges',hView.getAppName))
   end   
end

%Determine if we need to compute the linearization at all. It is  only worth
%computing if we need to log the linear system, display the results on a
%block visualization, or check an assertion.
logResults = strcmp(get_param(parent,'SaveToWorkspace'),'on') && ...
   strcmp(get_param(model,'SignalLogging'),'on');
checkAssertion = ~isempty(hReq) && (strcmp(get_param(parent,'enabled'),'on') || ...
   strcmp(get_param(parent,'export'),'on'));
plotResult = haveView && strcmp(get(hView.Parent,'Visible'),'on');
doWork = ~isempty(linios) && (logResults || checkAssertion || plotResult);

%Throw an error if we need to do the linearization but are not in normal
%mode simulation
simMode = get_param(model,'SimulationMode');
if doWork && ~strcmp(simMode,'normal')
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errSimMode',simMode)
end
if doWork
   block.SetAccelRunOnTLC(false);
else
   % Run accelerator on TLC, has trivial implementation which sets block
   % output to 1
   block.SetAccelRunOnTLC(true);
end
if doWork && strcmp(simMode,'normal')
   %Register a function to generate RTW code. This should only get
   %exercised when we try generate code for the block, in which case we
   %should error.
   block.RegBlockMethod('WriteRTW', @(block) ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errSimMode','RTW-Build'));
end

%Get a linearization engine object and prepare the model for linearization,
%note that the same linearization engine object is shared by all frequency
%domain check blocks in the model
if strcmp(get_param(model,'SimulationStatus'),'initializing')
   %Only initialize model for if we are  going to simulate.
   if doWork
      %Get a linearization engine for the top level model. 
      LinEng = linearize.CheckBlkExecutionManager.getInstance(modelTop);
      LinEng.enablePorts(linios);
      if(logResults)
         LinEng.enableLogging(parent);
      end
      
      %Collect all the data needed in the block execution
      %methods
      ExecData = linearize.CheckBlkLinearizationData(...
         'LinEngine',    LinEng, ...
         'LinAtZero',    linAtZero, ...
         'hPorts',       linios, ...
         'hReqs',        hReq, ...
         'hViewData',    getappdata(handle(block.BlockHandle),'BlockVisualizationData'), ...
         'CachedOutput', 1, ...
         'Options',      struct(...
         'SampleTime', SampleTime, ...
         'RateConversionMethod', get_param(parent,'RateConversionMethod'), ...
         'PreWarpFreq', PrewarpFreq, ...
         'UseExactDelayModel', get_param(parent,'UseExactDelayModel'), ...
         'UseFullBlockNameLabels', get_param(parent,'UseFullBlockNameLabels'), ...
         'UseBusSignalLabels', get_param(parent,'UseBusSignalLabels')), ...
         'SaveInfo',     struct(...
         'SaveToWorkspace',get_param(parent,'SaveToWorkspace'), ...
         'Name', get_param(parent, 'SaveName'), ...
         'BlkName', parent, ...
         'Log', []));
      
      % Set the required model execution methods
      block.RegBlockMethod('Start', @(block) localStart(block,ExecData));
      block.RegBlockMethod('Outputs', @(block) localOutputs(block,ExecData));
      block.RegBlockMethod('Terminate', @(block) localTerminate(block,ExecData));
   else
      %Do not want to linearize at all, simply set the block output 
      block.RegBlockMethod('Outputs', @(block) localTrivialOutputs(block));
   end
end
end

function localStart(block,ExecData)

parent = get_param(block.BlockHandle,'Parent');

%If required check that ios of SISO system are single channel
cls = get_param(parent,'DialogControllerArgs');
if ~feval(strcat(cls,'.supportsMIMO'))
   ios = ExecData.hPorts;
   ct = 1;
   ok = true;
   while ok && ct <= numel(ios)
      hPorts = get_param(ios(ct).Block,'PortHandles');
      portDims = get_param(hPorts.Outport(ios(ct).PortNumber),'CompiledPortDimensions');
      if ~all(portDims==1)
         ok = false;
      end
      ct = ct + 1;
   end
   if ~ok
      ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errNotSISO',parent)
   end
end

%If the block has logging enabled, check logging settings
if strcmp(get_param(parent,'SaveToWorkspace'),'on')
   ExecData.LinEngine.checkLogging;
end
end

function localOutputs(block,ExecData)
%This output function is used when the block needs to compute a linear
%system

if block.InputPort(1).Data || ...
      ((block.CurrentTime == 0) && ExecData.LinAtZero)
   %Schedule linearization for the block, we will evaluate block output once
   %the linearization has been computed
   ExecData.CurrentTime = block.CurrentTime;
   ExecData.LinEngine.scheduleLinearization(block,ExecData);
end

%Set the block output port value based on the cached output value. Note
%the cached output value is computed in localProcessJacobian which is
%scheduled for the end of the major integration step. This implies the
%output value is one step behind.
block.OutputPort(1).Data = ExecData.CachedOutput;

%Reset the cached output value
ExecData.CachedOutput = 1;
end

function localTrivialOutputs(block)
%This output function is used when the block does not need to compute any
%linear system and simply outputs an assertion satisfied signal.

block.OutputPort(1).Data = 1;
end

function localTerminate(block,ExecData) %#ok<INUSL>

%Write any logging 
if strcmp(ExecData.SaveInfo.SaveToWorkspace,'on')
   mdl = bdroot(ExecData.SaveInfo.BlkName);
   if strcmp(get_param(mdl,'SignalLogging'),'on')
      assignin('base', ExecData.SaveInfo.Name, ExecData.SaveInfo.Log)
   end
end
end

function localCheckIOs(model,parent,ios)
% Helper function to check that the IOs specified by the block are valid

[~, invalidIO] = linearize.checkModelIOPoints({model},ios);
nIO = numel(invalidIO);
if nIO > 0
   str = sprintf('%s:%d', invalidIO(1).Block, invalidIO(1).PortNumber);
   for ct=2:nIO
     str = sprintf('%s, %s:%s', str, invalidIO(ct).Block, invalidIO(ct).PortNumber); 
   end
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errLinIOs',parent,str)
end

%If the block does not support MIMO, check that the IOs define a SISO
%system
cls = get_param(parent,'DialogControllerArgs');
if ~feval(strcat(cls,'.supportsMIMO'))
   %For SISO system must have one of:
   % - 1 io with type 'in', 1 io with type 'out'
   % - 1 io with type 'inout'
   % - 1 io with type 'outin'
   %
   % Also each IO must specify a single width channel. The io-channel 
   % check is delayed until the block start function as compiled port
   % widths are needed.
   
   %Check have correct number of io objects
   nio = numel(ios);
   if nio < 3
      ioType = get(ios,{'Type'});
      if nio == 1
         ok = strcmp(ioType,'inout') ||  strcmp(ioType,'outin');
      else
         ok = any(strcmp(ioType,'in')) && any(strcmp(ioType,'out'));
      end
   else
      ok = false;
   end
   
   if ~ok
      ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errNotSISO',parent)
   end
end
end

function [SnapTimes,SampleTime,PrewarpFreq] = localCheckParameters(parent)
%Helper function to check and return various block parameters

needSnapshot = strcmp(get_param(parent,'LinearizeAt'),'SnapshotTimes');
%Check block snapshot time setting
try
   SnapTimes = slResolve(get_param(parent,'SnapshotTimes'),parent);
catch E %#ok<NASGU>
   if needSnapshot
      ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropFiniteReal','SnapshotTimes',parent);
   else
      %Use a dummy value
      SnapTimes = 1;
   end
end
if ~isreal(SnapTimes) || any(~isfinite(SnapTimes))
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropFiniteReal','SnapshotTimes',parent)
end
%Check block SampleTime setting
try
   strVal = get_param(parent,'SampleTime');
   if strcmpi(strVal,'auto')
      SampleTime = -1;
   else
      SampleTime = slResolve(strVal,parent);
   end
catch E
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropFiniteRealScalar','SampleTime',parent);
end
if ~isreal(SampleTime) || ~isscalar(SampleTime) || ~isfinite(SampleTime) || ...
      (SampleTime < 0 && SampleTime ~= -1)
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropFiniteRealScalar','SampleTime',parent);
end
%Check block prewarp frequency setting
needPrewarp = any(strcmp(get_param(parent,'RateConversionMethod'),{'prewarp', 'upsample_prewarp'}));
try
   PrewarpFreq = slResolve(get_param(parent,'PreWarpFreq'),parent);
catch E %#ok<NASGU>
   if needPrewarp
      ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPosFiniteRealScalar','PreWarpFreq',parent);
   else
      %Use dummy value
      PrewarpFreq = 10;
   end
end
if needPrewarp && ...
      (~isreal(PrewarpFreq) || ~isscalar(PrewarpFreq) || ~isfinite(PrewarpFreq) || ...
      PrewarpFreq <= 0)
   ctrlMsgUtils.error('Slcontrol:slctrlblkdlgs:errBlockPropPosFiniteRealScalar','PreWarpFreq',parent);
end
end