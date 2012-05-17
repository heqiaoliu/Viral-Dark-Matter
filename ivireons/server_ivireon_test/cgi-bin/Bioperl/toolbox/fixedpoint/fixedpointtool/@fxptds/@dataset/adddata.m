function h = adddata(h, runNumber, dataObj)
% ADDDATA  adds data to the dataset
%   ADDDATA(H, RUNNUMBER, DATA) adds DATA to H at RUNNUMBER. If DATA exists
%   it is overwritten

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/04/05 22:16:20 $

error(nargchk(3,3,nargin));
%get the data to store
data = dataObj.getdata;
runTime = getruntime(h, runNumber);
for i = 1:numel(data)
  [data(i), blk] = getblock(h,data(i));
  if(isempty(blk)); continue; end
  result = getresults(h,runNumber, blk, data(i).PathItem);
  if(isempty(result))
    result = createresult(blk,data(i));
    updatename(result, data(i));
    init(result, blk,h);
    update(result, runTime, runNumber, data(i));
    addresult(h,runNumber, result);
  else
    update(result, runTime, runNumber, data(i));
  end
end

%--------------------------------------------------------------------------
function runTime = getruntime(h, runNumber)
% if results for the desired run aren't initialized, initialize it now.
if h.isSDIEnabled
    % If there is no run-number for the runID, then create one before getting the runTime.
    runID = h.getRunID(runNumber);
    if isempty(runID)
         h.initHashMap4Run(runNumber);
    end
    runID = h.getRunID(runNumber);
    % get the run Object for the runID. 
    runTime = h.SDIEngine.getDateCreated(runID);
else
    if ~h.simruns.keySet.contains(runNumber)
        h.initHashMap4Run(runNumber);
    end
    runTime = h.getmetadata(runNumber, 'RunTime');
    if(isempty(runTime))
        runTime = cputime;
        h.setmetadata(runNumber, 'RunTime', runTime);
    end
end

%--------------------------------------------------------------------------
function result = createresult(blk, d)
result = [];
% use isa() instead of fxptds.isa() to improve performance. We don't have any need to use the package method here.
if(isa(blk, 'Simulink.Scope') || ...
   isa(blk, 'Simulink.ToWorkspace') || ...
   isa(blk, 'Simulink.Outport'))
    result = fxptui.towsresult;
    return;
end
if(isfield(d, 'isMdlRef') && d.isMdlRef)
    result = fxptui.mdlrefresult;
    result.mdlref = d.ModelReference;
    return;
end
if(isa(blk, 'Stateflow.Chart') || isa(blk, 'Stateflow.EMChart'))
    result = fxptui.sfchartresult;
    return;
end
if(isa(blk, 'Stateflow.Object'))
    result = fxptui.sfresult;
    return;
end
if(isa(blk, 'Simulink.Signal'))
    result = fxptui.sdoresult;
    return;
end
if(isa(blk, 'Simulink.Object'))
    result = fxptui.simresult;
    return;
end

% [EOF]
