function swap(h)
%SWAPRESULTS swap Active and Reference results

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/05 22:16:48 $

if  h.isSDIEnabled
    sdiEngine = h.getSDIEngine;
    active_runID = h.getRunID(0);
    reference_runID = h.getRunID(1);
    % Move the reference to active, if the active run is empty.
    if isempty(active_runID)
        h.move(1,0);
        return;
    end
    % Move the active to reference, if the reference run is empty.
    if isempty(reference_runID)
        h.move(0,1);
        return;
    end

    % Update the RunIDMap to point to the exchanged runs.
    h.RunIDMap.insert(fxptui.run2str(0), reference_runID);
    h.RunIDMap.insert(fxptui.run2str(1), active_runID);
    sdiEngine.setRunName(active_runID, fxptui.run2str(1));
    sdiEngine.setRunName(reference_runID, fxptui.run2str(0));
    for r = 0:1
        results = h.getresults(r);
        runstr = fxptui.run2str(r);
        set(results, 'Run', runstr)
    end
else
    %remove the run hashs for each run
    run_zero = h.simruns.remove(0);
    run_one = h.simruns.remove(1);
    %swap their position
    h.simruns.put(1, run_zero);
    h.simruns.put(0, run_one);
    %update the results Run property
    for r = 0:1
        results = h.getresults(r);
        runstr = fxptui.run2str(r);
        set(results, 'Run', runstr)
    end
end
% [EOF]
