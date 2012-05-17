function h = clearresults(h, varargin)
%CLEARRESULTS clear results

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/04/05 22:16:27 $

blk = [];
runs = h.getrunnumbers;
switch nargin
  case 3
    runs = varargin{1};
    blk = varargin{2};
  case 2
    %if there are 2 args the first is run the second is the block. this gets
    %called from simresult.destroy and is used to remove all results associated
    %with a block that isn't in a referenced model
    if isnumeric(varargin{1})
      runs = varargin{1};
    else
      blk = varargin{1};
    end
end
if(isresult(blk))
  clearpathitems(h, runs, blk);
else
  if(isempty(blk))
    clearruns(h, runs);
  else
    clearblocks(h, runs, blk);
  end
end

%--------------------------------------------------------------------------
function clearruns(h, runs)
for r = 1:numel(runs)
  run = runs(r);
  h.clearmetadata(run);
  h.clearblocks(run);
  if h.isSDIEnabled
      % Get the run ID
      runID = h.getRunID(run);
      % delete the run from the SDI engine
      h.SDIEngine.deleteRun(runID);
      % Delete the entry in the RunMap.
      h.RunIDMap.deleteDataByKey(fxptui.run2str(run));
      % Delete the data maps for the run.
      if isKey(h.RunDataMap, runID)
          h.RunDataMap.deleteDataByKey(runID);
      end
  end
end

%--------------------------------------------------------------------------
function clearblocks(h, runs, blk)
if h.isSDIEnabled
    sdiEngine = h.getSDIEngine;
    for r = 1:numel(runs)
        runID = h.getRunID(runs(r));
        if isKey(h.RunDataMap, runID)
            runDataMaps = h.RunDataMap.getDataByKey(runID);
            % get the java hash that maps blocks to its signals.
            signals4blkJHash = runDataMaps.getDataByKey('Signals4Blk');
            if signals4blkJHash.containsKey(blk)
                % Get the signals associated with the blk. This is a Java
                % Linked Hash Map.
                pathItemIDJHashMap = signals4blkJHash.get(blk);
                pathIDkeyArray = pathItemIDJHashMap.keySet.toArray;
                % get the number of pathitems for the block.
                for idx = 1:length(pathIDkeyArray)
                    % Get the ID of the data object for the pathitem
                    pathItemID = int32(pathItemIDJHashMap.get(pathIDkeyArray(idx)));
                    % The java Hash Map returns the value as a double. The
                    % SDI engine expects an integer type.
                    dataObj = sdiEngine.getSignal(pathItemID);
                    if ~isempty(dataObj)
                        result = dataObj.MetaData;
                        result.deletefigures;
                        delete(result);
                    end
                    % Delete data object from the run after deleting the result.
                    sdiEngine.deleteSignal(pathItemID);
                end
                signals4blkJHash.remove(blk);
            end
        end
    end
else
    for r = 1:numel(runs)
        blocksHash = h.simruns.get(runs(r)).get('blocks');
        blkHash = blocksHash.remove(blk);
        if(~isempty(blkHash))
            h.clearpathitems(blkHash);
        end
    end
end

%--------------------------------------------------------------------------
function clearpathitems(h, runs, result)
for r = 1:numel(runs)
  if h.isSDIEnabled
      runID = h.getRunID(runs(r));
      runDataMaps = h.RunDataMap.getDataByKey(runID);
      result.deletefigures;
      % signals4blk is a Java LinkedHashMap
      signals4blkJHash = runDataMaps.getDataByKey('Signals4Blk');
      % remove the pathitem from the signal list for the block.
      pathItemIDJHashMap = signals4blkJHash.get(result.daobject);
      pathItemID = pathItemIDJHashMap.get(result.PathItem);
      if ~isempty(pathItemIDMap)
          pathItemIDJHashMap.remove(result.PathItem);
      end
      % Delete the result for the path item from the run object. The java
      % hash map returns a double value, but the SDI Engine expects an
      % integer.
      h.SDIEngine.deleteSignal(int32(pathItemID));
      delete(result);
  else
      blocksHash = h.simruns.get(runs(r)).get('blocks');
      if(blocksHash.size == 0); continue; end
      blkHash = blocksHash.get(result.daobject);
      if(~isempty(blkHash))
          jfxpblk = blkHash.remove(result.PathItem);
          h.destroypathitem(jfxpblk);
      end
  end
end

%--------------------------------------------------------------------------
function b = isresult(blk)
b = ~isempty(blk) && isa(blk, 'fxptui.abstractresult');

% [EOF]
