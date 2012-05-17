function clearblocks(h, run)
%CLEARBLOCKS clear all blocks for the specified run

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/05 22:16:24 $

if h.isSDIEnabled
    sdiEngine = h.getSDIEngine;
    runID = h.getRunID(run);
    if ~isempty(runID)
        if isKey(h.RunDataMap, runID)
            runDataMaps = h.RunDataMap.getDataByKey(runID);
            %signals4blkJHash is a Java LinkedHashMap
            signals4blkJHash = runDataMaps.getDataByKey('Signals4Blk');
            pathItemIDJHashMap = signals4blkJHash.values.toArray;
            for idx = 1:length(pathItemIDJHashMap)
                % The value is a Java Linked Hash Map
                signalID = pathItemIDJHashMap(idx).values.toArray;
                % The java hash map return a double, but the SDI engine
                % expects an integer
                dataObj = sdiEngine.getSignal(int32(signalID(1)));
                if ~isempty(dataObj) && ~isempty(dataObj.MetaData)
                    result = dataObj.MetaData;
                    result.deletefigures;
                    delete(result);
                end
                sdiEngine.deleteSignal(int32(signalID(1)));
            end
            signals4blkJHash.clear;
        end
    end
else
    runHash = h.simruns.get(run);
    blocksHash = runHash.get('blocks');
    %use values collection. keys may no longer exist and we still need to
    %release references to all values
    blocks = blocksHash.values.toArray;
    for blkIdx = 1:length(blocks)
        blkHash = blocks(blkIdx);
        if(~isempty(blkHash))
            h.clearpathitems(blkHash);
        end
    end
    blocksHash.clear;
end

% [EOF]
