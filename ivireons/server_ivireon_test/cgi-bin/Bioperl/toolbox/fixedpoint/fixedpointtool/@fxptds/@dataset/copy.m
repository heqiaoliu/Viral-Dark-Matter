function copy(h, from, to)
%COPY copy data from one run to another 

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/05 22:16:28 $

if h.isSDIEnabled
    sdiEngine = h.getSDIEngine;
    %Get the runHash of the source run.
    runID_from = h.getRunID(from);
    if (sdiEngine.getSignalCount(runID_from <= 0)); return; end % There are no results to copy.
        
    
    %Copy the runObject excluding MetaData.
    runID_copy = sdiEngine.copyRun(runID_from);
    
    runID_to = h.getRunID(to);
    % delete existing signals in the destination run before mapping the new runID.
    if ~isempty(runID_to)
        h.clearresults(to);
    end
    
    % Move the new run copy to the final destination run. Map destination
    % run to the copied runID.
    h.RunIDMap.insert(fxptui.run2str(to),runID_copy);
    addMetaDataToRun(h, runID_copy)
   
    runID_to = runID_copy;
    sdiEngine.setRunName(runID_to,fxptui.run2str(to))
    runDataMap_from = h.RunDataMap.getDataByKey(runID_from);
    runDataMap_to = h.RunDataMap.getDataByKey(runID_to);
    
    % If the signal count is not equal after copying the run, delete all
    % the signals from the destination run. This should never be the case,
    % but we will protect againt it anyways.
    isSignalLengthEqual = isequal(sdiEngine.getSignalCount(runID_to),...
                sdiEngine.getSignalCount(runID_from));
            
    if ~isSignalLengthEqual
       for i = 1:sdiEngine.getSignalCount(runID_to)
          sdiEngine.deleteSignal(runID_to, i); 
       end
    end
    
    % Signals4Blk is a Java LinkedHashMaps
    Signals4blkJHashMap_to = runDataMap_to.getDataByKey('Signals4Blk');
    runstr = fxptui.run2str(to);
    for i = 1:sdiEngine.getSignalCount(runID_from)
        signal_from = sdiEngine.getSignal(runID_from, i);
        % Copy the MetaData that contains the results.
        result = signal_from.MetaData;
        % make a deep copy of the object.
        resCopy = copyObj(result,h);
        resCopy.Run = runstr;

        % Add results to the destination run. 
        if isSignalLengthEqual
            signal_to = sdiEngine.getSignal(runID_to, i);
            sdiEngine.setMetaData(signal_to.DataID, resCopy);
                     
            % If addresult wasn't invoked, then we need to also copy over the
            % Signals4blk map.
            if Signals4blkJHashMap_to.containsKey(resCopy.daobject)
                pathItemIDJHashMap = get(Signals4blkJHashMap_to,resCopy.daobject);
            else
                % Initialize a java LinkedHash Map.
                pathItemIDJHashMap = java.util.LinkedHashMap;
            end
            % Store the corresponding signalID that was returned by the engine
            % when the result was added.
            pathItemIDJHashMap.put(resCopy.PathItem,signal_to.DataID);
            Signals4blkJHashMap_to.put(resCopy.daobject,pathItemIDJHashMap);
        else
            addresult(h,runID_to, resCopy);
        end
    end
    
    % Copy over the list4id and blklist4src Maps contained in the source
    % run MetaData to the destination run. The signals4blk Map gets
    % re-created when the results are added to the destination run above.
    
    list4id_fromMap = runDataMap_from.getDataByKey('list4id');
    % Create a new data map and copy the list4id DataMap object.
    % Initialize the DataMap to contain a character key and a UDD object as value.
    runDataMap_to.deleteDataByKey('list4id');
    list4id_toMap = Simulink.sdi.Map(char('a'),?handle);

    % Make a deep copy of the result object contained in the Map.
    for i = 1:list4id_fromMap.getCount
        result_list = list4id_fromMap.getDataByIndex(i);
        for m = 1:length(result_list)
           resultCopy(m) = copyObj(result_list(m),h); %#ok<AGROW>
        end
        list4id_toMap.insert(list4id_fromMap.getKeyByIndex(i),resultCopy);
    end
    runDataMap_to.insert('list4id',list4id_toMap);
    
    
    % Copy the blklist4src Data Map.
    blklist4src_fromMap = runDataMap_from.getDataByKey('blklist4src');
    % Initialize the DataMap to contain the block handle as key and a UDD
    % object as value.
    runDataMap_to.deleteDataByKey('blklist4src');
%     blklist4src_toMap =  Simulink.sdi.Map(double(0),?handle);
%     for idx = 1:blklist4src_fromMap.getCount
%         blklist4src_toMap.insert(blklist4src_fromMap.getKeyByIndex(idx),blklist4src_fromMap.getDataByIndex(idx));
%     end 
    runDataMap_to.insert('blklist4src',blklist4src_fromMap);
 
else
    %Get the runHash of the source run.
    runHash_from = h.simruns.get(from);
    if isempty(runHash_from); return; end % There are no results to copy.
    
    %Get the runHash of the destination run
    runHash_to = h.simruns.get(to);
    if isempty(runHash_to)
        h.initHashMap4Run(to);
        runHash_to = h.simruns.get(to);
    end
    
    %Copy the data.
    runTime = runHash_from.get('metadata').get('RunTime');
    h.setmetadata(to,'RunTime',runTime);
    result = h.getresults(from);
    runstr = fxptui.run2str(to);
    for i = 1:length(result)
        % make a deep copy of the object.
        res = copyObj(result(i),h);
        res.Run = runstr;
        h.addresult(to,res);
    end
    runHash_to.put('list4id',runHash_from.get('list4id'));
    runHash_to.put('blklist4src',runHash_from.get('blklist4src'));
end
