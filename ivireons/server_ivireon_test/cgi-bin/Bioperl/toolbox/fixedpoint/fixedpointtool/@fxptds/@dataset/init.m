function init(h)
% DATASET constructor
%

%   Author(s): V. Srinivasan
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/04/05 22:16:40 $


if  h.isSDIEnabled
    if isempty(h.SDIEngine)
        h.SDIEngine = Simulink.sdi.SDIEngine;
        % Initialize the DataMap to contain a character key and integer value.
        h.RunIDMap = Simulink.sdi.Map(char('a'),uint32(0));
         
        % Initialize the Map to store any Run related information.
        h.RunDataMap = Simulink.sdi.Map(uint32(0),?handle);
    end
    for run = 0:1
        h.initHashMap4Run(run);
    end
else
    h.simruns = java.util.LinkedHashMap;
    for run = 0:1
        runHash = java.util.LinkedHashMap;
        h.simruns.put(run, runHash);
        h.initHashMap4Run(run);
    end
end
h.listeners = handle.listener(h, 'ObjectBeingDestroyed', @(s,e) clearresults(h));
if isa(h.rootmdl,'Simulink.BlockDiagram')
    % Listeners to track the previous simulation status, update the runtime and clear scaling data.
    h.listeners(end+1) = handle.listener(h.rootmdl, 'EngineSimStatusInitializing',  @(s,e)locStart(h));
    h.listeners(end+1) = handle.listener(h.rootmdl, 'EngineSimStatusRunning',  @(s,e)locContinue(h));
    h.listeners(end+1) = handle.listener(h.rootmdl, 'EngineSimStatusPaused',  @(s,e)locPause(h));
    h.listeners(end+1) = handle.listener(h.rootmdl, 'EngineCompFailed',  @(s,e)locCompFailed(h));
    h.listeners(end+1) = handle.listener(h.rootmdl,'EngineSimStatusTerminating', @(s,e)locTerminate(h));
    h.listeners(end+1) = handle.listener(h.rootmdl,'EngineSimStatusStopped', @(s,e)locStop(h));
end

%-------------------------------------------------------
function locStart(h)
% Keep track of the simulation status for use in the Terminate & Stop callbacks.
if(strcmpi('done', h.simStatus))
  h.simStatus = 'initializing';
end

%--------------------------------------------------------
function locPause(h)
% Keep track of the simulation status for use in the Terminate & Stop callbacks.
if strcmpi(h.simStatus,'running')
  h.simStatus = 'paused';
end

%-----------------------------------------------------
function locCompFailed(h)
% Keep track of the simulation status for use in the Terminate & Stop callbacks.
h.simStatus = 'compfailed';

%--------------------------------------------------------
function locContinue(h)
% Keep track of the simulation status for use in the Terminate & Stop callbacks.
switch h.simStatus
  case {'initializing', 'paused'}
     h.simStatus = 'running';
    otherwise
end
%--------------------------------------------------------
function locStop(h)
% clear the proposals on the results at the end of simulation.
if(~strcmp('normal', h.rootmdl.SimulationMode)); return; end
switch h.simStatus
  case {'running', 'paused'}
    runNumber = getRunNumber(h);
    res = h.getresults(runNumber);
    for i = 1:length(res)
        res(i).clearscalingdata;
    end
  otherwise
end
h.simStatus = 'done';

%--------------------------------------------------------
function locTerminate(h)
if(~strcmp('normal', h.rootmdl.SimulationMode)); return; end
% Upate the runtime before any data is added to it at the end of
% simulation.
switch h.simStatus
  case {'running', 'paused'}
    if h.isSDIEnabled
        runNumber = getRunNumber(h);
        runID = getRunID(h,runNumber);
        % If the run does not exist, create the run and update the
        % timestamp.
        if isempty(runID)
            h.initHashMap4Run(runNumber);
            runID = getRunID(h, runNumber);
        end
        updateDateCreated(h.getSDIEngine,runID);
    else
        runNumber = getRunNumber(h);
        h.setmetadata(runNumber, 'RunTime', cputime);
    end
  otherwise
end

%-------------------------------------------------------
function runNumber = getRunNumber(h)
% Get the run number that points to the results that are stored in the
% ResultLocation.

autoscalesupport = SimulinkFixedPoint.getApplicationData(h.rootmdl.getFullName);
runNumber = autoscalesupport.ResultsLocation;

%-------------------------------------------------------

% [EOF]
