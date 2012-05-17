function results = getresults(h,varargin)
%GETRESULTS

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2010/04/05 22:16:37 $

results = [];
runs = [0 1];
blk = '';
pathitem = '';

if ~h.hasresults; return; end

%h, run, blk, pathitem
if(nargin > 3); pathitem = varargin{3}; end

%h, run, blk
if(nargin > 2); blk = varargin{2};
    if(ischar(blk))
        blk = get_param(blk, 'Object');
    end
end

%h, run
if(nargin > 1)
    if(~isempty(varargin{1})); runs = varargin{1}; end
end

results = getresultsforpathitem(h, runs, blk, pathitem);


%--------------------------------------------------------------------------
function results = getresultsforruns(h,runs)
if h.isSDIEnabled
    indx = 1;
    %Pre-allocation of memory.
    run_sz = zeros(numel(runs),1);
    for i = 1:numel(runs)
        runID = getRunID(h,runs(i));
        if isempty(runID); continue; end
        % get the number of blocks stored in a run.
        runMaps = h.RunDataMap.getDataByKey(runID);
        % Signals4blk is a Java LinkedHashMap
        Signals4blkJHashMap = getDataByKey(runMaps,'Signals4Blk');
        run_sz(i) = Signals4blkJHashMap.size;
    end
    num_sigs = max(run_sz) * numel(runs) * 2;
    if num_sigs > 0
        results(1:num_sigs) = fxptui.simresult;
        maxResultsLength = num_sigs;
    else
        results = [];
        maxResultsLength = 0;
    end
    sdiEngine = h.getSDIEngine;
    for i = 1:numel(runs)
        % Get the run ID.
        runID = getRunID(h,runs(i));
        if isempty(runID); continue; end
        for m = 1:sdiEngine.getSignalCount(runID)
            dataObj = getSignal(sdiEngine, runID, m);
            % protect against hidden blocks that only appear during compile
            % time.
            if ~isempty(dataObj.MetaData) && isa(dataObj.MetaData.daobject,'DAStudio.Object')
                % check if we are growing beyond the allocated memory. If we are, then pre-allocate
                % twice the current size to improve performance.
                if (indx > maxResultsLength)
                    results(indx:indx*2) = fxptui.simresult;
                    maxResultsLength = indx*2;
                end
                results(indx) = dataObj.MetaData;
                indx = indx+1;
            end
        end
    end
else
    % code to preallocate memory
    len_run = zeros(length(runs),1);
    for i = 1:numel(runs)
        runHash = h.simruns.get(runs(i));
        if isempty(runHash); continue; end;
        blkHash =  runHash.get('blocks');
        if isempty(blkHash); continue; end
        len_run(i) = blkHash.keySet.size;
    end
    % Get the number of blocks in datset, the number of runs for which the data
    % is stored and multiply that by 2 to accommodate blocks that have multiple path items. This is done to increase performance.
    num_sigs = max(len_run) * numel(runs) * 2;
    if num_sigs > 0
        results(1:num_sigs) = fxptui.simresult;
        maxResultsLength = num_sigs;
    else
        results = [];
        maxResultsLength = 0;
    end
    
    %loop over through the specified runs
    indx = 1;
    for r = 1:numel(runs)
        runHash = h.simruns.get(runs(r));
        if isempty(runHash); continue; end;
        blocksHash = runHash.get('blocks');
        if isempty(blocksHash); continue; end;
        blk_keys = blocksHash.keySet.toArray;
        for blkIdx = 1:length(blk_keys)
            blkHash = blocksHash.get(blk_keys(blkIdx));
            if(isempty(blkHash)); continue; end
            item_keys = blkHash.keySet.toArray;
            for idx = 1:numel(item_keys)
                jfxpblk = blkHash.get(item_keys(idx));
                thisresult = handle(jfxpblk);
                % check if we are growing beyond the allocated memory. If we are, then pre-allocate
                % twice the current size to improve performance.
                if (indx > maxResultsLength)
                    results(indx:indx*2) = fxptui.simresult;
                    maxResultsLength = indx*2;
                end
                results(indx) = thisresult;
                indx = indx+1;
            end
        end
    end
end
% length of results can be greater than the actual number of entries added. The
% result is retrieved after adding each data result and since the number
% of results being added incrementally can be less than the total signals
% till all results are created and added, we need to clear the extra memory.
results(indx:end) = [];


%--------------------------------------------------------------------------
function results = getresultsforblk(h,runs,blk)
if(isempty(blk))
    results = getresultsforruns(h,runs);
    return;
end

% preallocation of memory for performance
% A block can have at the most 8 pathitems (SOS structure in the filter
% block is an example).
num_sigs = numel(runs) * 8;
results(1:num_sigs) = fxptui.simresult;

if h.isSDIEnabled
    indx = 1;
    for i = 1:numel(runs)
        runID = getRunID(h, runs(i));
        if isempty(runID); continue;end;
        runDataMaps = h.RunDataMap.getDataByKey(runID);
        % Signals4blk is a Java LinkedHashMap
        signals4blkJHashMap = getDataByKey(runDataMaps,'Signals4Blk');
        if signals4blkJHashMap.containsKey(blk)
            pathItemIDJHashMap = signals4blkJHashMap.get(blk);
            pathIDkeyArray = pathItemIDJHashMap.keySet.toArray;
            % get the values in the map which are the IDs to the data Objects for each path item.
            for j = 1:length(pathIDkeyArray)
                % The java hash map return a double, but the SDI engine
                % expects an integer
                pathItemID = int32(pathItemIDJHashMap.get(pathIDkeyArray(j)));
                dataObj = getSignal(h.getSDIEngine, pathItemID);
                if isempty(dataObj) || isempty(dataObj.MetaData);continue; end
                % protect against hidden blocks that only appear during compile
                % time.
                if isa(dataObj.MetaData.daobject,'DAStudio.Object')
                    results(indx) = dataObj.MetaData;
                    indx = indx+1;
                end
            end
        end
    end
else
    indx = 1;
    %loop over through the specified runs
    for r = 1:numel(runs)
        runHash = h.simruns.get(runs(r));
        if isempty(runHash); continue; end;
        blocksHash = runHash.get('blocks');
        if isempty(blocksHash); continue; end;
        blkHash = blocksHash.get(blk);
        if(isempty(blkHash)); continue; end
        item_keys = blkHash.keySet.toArray;
        for idx = 1:numel(item_keys)
            jfxpblk = blkHash.get(item_keys(idx));
            thisresult = handle(jfxpblk);
            results(indx) = thisresult;
            indx = indx+1;
        end
    end
end
% length of results can be greater than the actual number of entries added. The
% result is retrieved after adding each data result and since the number
% of results being added incrementally can be less than the total signals
% till all results are created and added, we need to delete the extra
% indices.
results(indx:end) = [];

%--------------------------------------------------------------------------
function results = getresultsforpathitem(h, runs, blk, pathitem)
if(isempty(pathitem))
    results = getresultsforblk(h,runs,blk);
    return;
end

results(1:numel(runs)) = fxptui.simresult;
cnt = 1;
if h.isSDIEnabled
    sdiEngine = h.getSDIEngine;
    for i = 1:numel(runs)
        runID = getRunID(h, runs(i));
        if isempty(runID); continue; end
        runDataMaps = h.RunDataMap.getDataByKey(runID);
        % Signals4blk is a Java LinkedHAshMap
        signals4blkJHashMap = getDataByKey(runDataMaps, 'Signals4Blk');
        if ~(signals4blkJHashMap.containsKey(blk)); continue;
        else
            pathItemIDJHashMap = signals4blkJHashMap.get(blk);
        end
        if isempty(pathItemIDJHashMap) || ~(pathItemIDJHashMap.containsKey(pathitem));
            continue;
        else
            % The java hash map return a double, but the SDI engine
            % expects an integer
            pathItemID = int32(pathItemIDJHashMap.get(pathitem));
        end
        if isempty(pathItemID);continue;end
        dataObj = sdiEngine.getSignal(pathItemID);
        if isempty(dataObj) || isempty(dataObj.MetaData); continue; end
        % protect against hidden blocks that only appear during compile
        % time.
        if ~isempty(dataObj.MetaData) && isa(dataObj.MetaData.daobject,'DAStudio.Object')
            results(cnt) = dataObj.MetaData;
            cnt = cnt+1;
        end
    end
else
    %loop over through the specified runs
    for r = 1:numel(runs)
        runHash = h.simruns.get(runs(r));
        if isempty(runHash); continue; end;
        blocksHash = runHash.get('blocks');
        if isempty(blocksHash); continue; end;
        blkHash = blocksHash.get(blk);
        if(isempty(blkHash)); continue; end
        jfxpblk = blkHash.get(pathitem);
        if(isempty(jfxpblk));continue; end
        result = handle(jfxpblk);
        results(cnt) = result;
        cnt = cnt+1;
    end
end
% Remove additional entries.
results(cnt:end) = [];
% [EOF]
