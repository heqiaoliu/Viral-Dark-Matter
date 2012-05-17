function move(h, from, to)
%MOVE move data from one run to another overwriting existing data

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/04/05 22:16:42 $

if h.isSDIEnabled
 
    sdiEngine = h.getSDIEngine;
    % Delete the destination run from the dataset.
    h.clearresults(to);
    
    % Update the name on the source run.
    runstr = fxptui.run2str(to);
    
    results = h.getresults(from);
    for rIdx = 1:numel(results)
        results(rIdx).Run = runstr;
    end
    % Update the runmap to point the destination run to the correct run
    % number.
    runID_from = h.getRunID(from);
    sdiEngine.setRunName(runID_from,runstr);

    h.RunIDMap.insert(runstr,runID_from);
    h.RunIDMap.deleteDataByKey(fxptui.run2str(from));
else
    fromRunHash = h.simruns.remove(from);
    h.clearresults(to);
    toRunHash = h.simruns.remove(to);
    h.simruns.put(to, fromRunHash);
    h.simruns.put(from, toRunHash);
    results = h.getresults(to);
    runstr = fxptui.run2str(to);
    for rIdx = 1:numel(results)
        results(rIdx).Run = runstr;
    end
end
% [EOF]
