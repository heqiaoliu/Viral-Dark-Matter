function addresult(h, runNumber, result)
%ADDRESULT   

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/04/05 22:16:21 $

if h.isSDIEnabled
    
    
    sdiEngine = getSDIEngine(h);
    runID = getRunID(h, runNumber);
    signalID = sdiEngine.addSignalByNamesAndValues('runID',runID,'metaData',result);
      
    % Add the signal name to the block object map since it's the only way to
    % track all signals belonging to a block. Use block handles as keys in the Signals4Blk
    % map since we cannot store objects as keys.
    runDataMaps = h.RunDataMap.getDataByKey(runID);
    signals4blkJHash = getDataByKey(runDataMaps,'Signals4Blk');
    % signals4blk is a Java LinkedHashMap
    if signals4blkJHash.containsKey(result.daobject)
        pathItemIDJMap = get(signals4blkJHash, result.daobject);
    else
        % Initialize a java LinkedHashMap instead of a SDI Map since we
        % need to store this in another java.LinkedHashMap
        pathItemIDJMap = java.util.LinkedHashMap;
     end
     % Store the corresponding signalID that was returned by the engine
     % when the result was added.
     pathItemIDJMap.put(result.PathItem,signalID);
     signals4blkJHash.put(result.daobject,pathItemIDJMap);
else
    if(isempty(result)); return; end
    jresult = java(result);
    jresult.acquireReference;
    %get the run hash for this runNumber
    runHash = h.simruns.get(runNumber);
    %get the hash containing blocks as keys
    allblocksHash = runHash.get('blocks');
    %get the hash for this block
    blockHash = allblocksHash.get(result.daobject);
    if(isempty(blockHash)); blockHash = java.util.LinkedHashMap; end
    %put this path item in this block's hash. this maps the result to
    %blk-pathitem accommodating blocks with multiple outputs and/or multiple
    %fxpt quantities
    blockHash.put(result.PathItem, jresult);
    %put this block's hash back in all blocks hash
    allblocksHash.put(result.daobject, blockHash);
end
% [EOF]
