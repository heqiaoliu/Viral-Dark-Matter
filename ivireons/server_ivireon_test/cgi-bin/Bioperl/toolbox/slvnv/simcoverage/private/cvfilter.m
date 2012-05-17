function filteredCv = cvfilter(originalCvstruct, metricNames)
%CVFILTER - Filter out the unwanted objects in coverage report.
%   Li Tan
%   Copyright 1990-2008 The MathWorks, Inc.

    % Global vars for coverage metrics
    global cvStructFilt;
    
    if ~isempty(cvStructFilt)
    	cachedCvStructFilt = cvStructFilt;
   	else
   		cachedCvStructFilt = [];
   	end
   	
    cvStructFilt=originalCvstruct;
    if (length(cvStructFilt.system)>0)
        filterSubSystem(1,metricNames);
    end;
    % now we remove the unwanted block and systems
    keepSystem = [cvStructFilt.system.keep];
    cvStructFilt.system(~keepSystem) = [];
    filteredCv=cvStructFilt;
    if ~isempty(cachedCvStructFilt)
    	 cvStructFilt = cachedCvStructFilt;
    else
        clear('global','cvStructFilt');
   	end
   	
function [totalChanges, keepSystem]=filterSubSystem(subsysIdx, metricNames)
	% need to parse for each children
	% check if there is child.
	global cvStructFilt;

	persistent sfIsa;

	if isempty(sfIsa)
		sfIsa.trans =    sf('get','default','trans.isa');
		sfIsa.state =    sf('get','default','state.isa');
		sfIsa.junction = sf('get','default','junction.isa');
		sfIsa.data =     sf('get','default','data.isa');
		sfIsa.chart =    sf('get','default','chart.isa');
	end

	cvStructFilt.system(subsysIdx).delete=0;
	totalChanges=struct('condTotalCnts', 0, ...
	                    'condOutCnts', 0, ...
	                    'decTotalCnts', 0, ...
	                    'decOutCnts', 0, ...
                        'mcdcTotalCnts',0, ...
                        'mcdcOutCnts',0);
	localChanges=struct('condTotalCnts', 0, ...
	                    'condOutCnts', 0, ...
	                    'decTotalCnts', 0, ...
	                    'decOutCnts', 0, ...
                        'mcdcTotalCnts',0, ...
                        'mcdcOutCnts',0);
	                

    % Invoke the parse before recursing to the children
    cvId = cvStructFilt.system(subsysIdx).cvId;
	[origin,refClass,sfId] = cv('get',cvId,'.origin','.refClass','.handle');
    if origin==2
        switch(refClass)
            case sfIsa.chart
            sf('Parse',sfId);
        end
    end

	if (isfield(cvStructFilt.system(subsysIdx),'subsystemCvId')&& ~isempty(cvStructFilt.system(subsysIdx).subsystemCvId))
	  deleteChildren=[];
	  for childCvId=cvStructFilt.system(subsysIdx).subsystemCvId(:)'
	        % now we need to search system
	        for testChildIdx=1:length(cvStructFilt.system)
                if (cvStructFilt.system(testChildIdx).cvId==childCvId)
					[subsystemChanges, keepSystem]=filterSubSystem(testChildIdx, metricNames);
					%now traverse subsystems.
	                for metric=metricNames(:)'
	                    if (strcmp(metric,'condition'))
	                        totalChanges.condTotalCnts=totalChanges.condTotalCnts+subsystemChanges.condTotalCnts;
	                        totalChanges.condOutCnts=totalChanges.condOutCnts+subsystemChanges.condOutCnts;
	                    elseif (strcmp(metric,'decision'))    
	                        totalChanges.decTotalCnts=totalChanges.decTotalCnts+subsystemChanges.decTotalCnts;
	                        totalChanges.decOutCnts=totalChanges.decOutCnts+subsystemChanges.decOutCnts; 
                        elseif (strcmp(metric,'mcdc'))    
	                        totalChanges.mcdcTotalCnts=totalChanges.mcdcTotalCnts+subsystemChanges.mcdcTotalCnts;
	                        totalChanges.mcdcOutCnts=totalChanges.mcdcOutCnts+subsystemChanges.mcdcOutCnts; 
	                    end
	                end;
	                if (keepSystem==0)
	                    deleteChildren=[deleteChildren,childCvId];
	                end
	                break;
                end
	        end;
	 	end;
	    % adjust children
	    for removeChild=deleteChildren(:)'
	        removeChildIdx=find(removeChild==cvStructFilt.system(subsysIdx).subsystemCvId);
	        cvStructFilt.system(subsysIdx).subsystemCvId(removeChildIdx) = [];
	    end
	end;

	if (isfield(cvStructFilt.system(subsysIdx),'blockIdx') && ~isempty(cvStructFilt.system(subsysIdx).blockIdx))
	    deleteBlocks=[];
	    for childBlockId=cvStructFilt.system(subsysIdx).blockIdx(:)'
	        % now we filter block
	        [blockChanges, keepBlock]=filterBlock(childBlockId, metricNames);
	        for metric=metricNames(:)'
                if (strcmp(metric,'condition'))
	       		    totalChanges.condTotalCnts=totalChanges.condTotalCnts+blockChanges.condTotalCnts;
	           	    totalChanges.condOutCnts=totalChanges.condOutCnts+blockChanges.condOutCnts;
	            elseif (strcmp(metric,'decision'))    
	                totalChanges.decTotalCnts=totalChanges.decTotalCnts+blockChanges.decTotalCnts;
	                totalChanges.decOutCnts=totalChanges.decOutCnts+blockChanges.decOutCnts;    
                elseif (strcmp(metric,'mcdc'))    
	                totalChanges.mcdcTotalCnts=totalChanges.mcdcTotalCnts+blockChanges.mcdcTotalCnts;
	                totalChanges.mcdcOutCnts=totalChanges.mcdcOutCnts+blockChanges.mcdcOutCnts;    
                end
	        end
	        if (keepBlock==0)
	            deleteBlocks=[deleteBlocks,childBlockId];
	        end
	    end
	    for removeBlock=deleteBlocks(:)'
	        removeBlockIdx=find(removeBlock==cvStructFilt.system(subsysIdx).blockIdx);
	        cvStructFilt.system(subsysIdx).blockIdx(removeBlockIdx) = [];
	    end
	end
	
	% now we shall examine the local changes.
	subsystemCvId=cvStructFilt.system(subsysIdx).cvId;
	[filtCondCvIds, filtDecCvIds,numFiltMCDCEntries]=cv_filter_object(subsystemCvId, metricNames);
	for metric=metricNames(:)'
        if (strcmp(metric,'condition')&& ~isempty(filtCondCvIds))
	    	subsysCondCvIds = [cvStructFilt.conditions(cvStructFilt.system(subsysIdx).condition.conditionIdx).cvId];
	        for filteredCondCvId=filtCondCvIds(:)'
	            % now we need to remove this condition object
	            condSubsysIdx=find(filteredCondCvId==subsysCondCvIds);
                removeIdx=[];
	            if (~isempty(condSubsysIdx))
	                filteredCondIdx=cvStructFilt.system(subsysIdx).condition.conditionIdx(condSubsysIdx);
                    removeIdx=[removeIdx,condSubsysIdx];
	                % here is the change that should be made.
	                localChanges.condTotalLocalCnts=localChanges.condTotalLocalCnts+cvStructFilt.conditions(filteredCondIdx).numOutcomes;
	                localChanges.condOutLocalCnts=localChanges.condOutLocalCnts+cvStructFilt.conditions(filteredCondIdx).outCnts;
	            end;
                cvStructFilt.system(subsysIdx).condition.conditionIdx(removeIdx)=0;
	        end;
        elseif (strcmp(metric,'decision')&& ~isempty(filtDecCvIds))
	    	subsysDecCvIds = [cvStructFilt.decisions(cvStructFilt.system(subsysIdx).decision.decisionIdx).cvId];
	        for filteredDecCvId=filtDecCvIds(:)'
	            % now we need to remove this decision object
	            decSubsysIdx=find(filteredDecCvId==subsysDecCvIds);
	            if (~isempty(decSubsysIdx))
	            	filteredDecIdx = cvStructFilt.system(subsysIdx).decision.decisionIdx(decSubsysIdx);
	                cvStructFilt.system(subsysIdx).decision.decisionIdx(decSubsysIdx) = [];
	                localChanges.decTotalCnts=localChanges.decTotalCnts+cvStructFilt.decisions(filteredDecIdx).numOutcomes;
	                localChanges.decOutCnts=localChanges.decOutCnts+cvStructFilt.decisions(filteredDecIdx).outCnts;
	            end
	        end
        elseif (strcmp(metric,'mcdc')&& ~isempty(numFiltMCDCEntries)&&~isempty(cvStructFilt.system(subsysIdx).mcdc)...
                &&~isempty(cvStructFilt.system(subsysIdx).mcdc.mcdcIndex))
            subsysMCDCIdx=cvStructFilt.system(subsysIdx).mcdc.mcdcIndex;
            for removing=1:numFiltMCDCEntries
                localChanges.mcdcTotalCnts=localChanges.mcdcTotalCnts+1;
                cvStructFilt.mcdc(subsysMCDCIdx).numPreds=cvStructFilt.mcdc(subsysMCDCIdx).numPreds-1;
	            localChanges.mcdcOutCnts=localChanges.mcdcOutCnts+cvStructFilt.mcdc(subsysMCDCIdx).predicate(removing).achieved;
                cvStructFilt.mcdc(subsysMCDCIdx).covered=cvStructFilt.mcdc(subsysMCDCIdx).covered-cvStructFilt.mcdc(subsysMCDCIdx).predicate(removing).achieved;
            end
            cvStructFilt.mcdc(subsysMCDCIdx).predicate(1:numFiltMCDCEntries)=[];
            if (isempty(cvStructFilt.mcdc(subsysMCDCIdx).predicate))
                cvStructFilt.system(subsysIdx).mcdc.mcdcIndex=[];
            end
        end
	end
	
	% We adjust the counters.
	keepSystem=0;
	for metric=metricNames(:)'
	    if (strcmp(metric,'condition'))
	        
	        totalChanges.condTotalCnts=totalChanges.condTotalCnts+localChanges.condTotalCnts;
	        totalChanges.condOutCnts=totalChanges.condOutCnts+localChanges.condOutCnts;
	        if (~isempty(cvStructFilt.system(subsysIdx).condition))
	            keepSystem=keepSystem+1;
	            cvStructFilt.system(subsysIdx).condition.totalCnt=cvStructFilt.system(subsysIdx).condition.totalCnt-totalChanges.condTotalCnts;
	            cvStructFilt.system(subsysIdx).condition.totalHits=cvStructFilt.system(subsysIdx).condition.totalHits-totalChanges.condOutCnts;
	            cvStructFilt.system(subsysIdx).condition.localCnt=cvStructFilt.system(subsysIdx).condition.localCnt-localChanges.condTotalCnts;
	            cvStructFilt.system(subsysIdx).condition.localHits=cvStructFilt.system(subsysIdx).condition.localHits-localChanges.condOutCnts;    
	            if cvStructFilt.system(subsysIdx).condition.totalCnt==0
	                keepSystem=keepSystem-1;
	            end
	        end
	    elseif (strcmp(metric,'decision'))
	        totalChanges.decTotalCnts=totalChanges.decTotalCnts+localChanges.decTotalCnts;
	        totalChanges.decOutCnts=totalChanges.decOutCnts+localChanges.decOutCnts;
	        if (~isempty(cvStructFilt.system(subsysIdx).decision))
	            keepSystem=keepSystem+1;
	            cvStructFilt.system(subsysIdx).decision.totalTotalCnts=cvStructFilt.system(subsysIdx).decision.totalTotalCnts-totalChanges.decTotalCnts;
	            cvStructFilt.system(subsysIdx).decision.outTotalCnts=cvStructFilt.system(subsysIdx).decision.outTotalCnts-totalChanges.decOutCnts;
	            cvStructFilt.system(subsysIdx).decision.totalLocalCnts=cvStructFilt.system(subsysIdx).decision.totalLocalCnts-localChanges.decTotalCnts;
	            cvStructFilt.system(subsysIdx).decision.outlocalCnts=cvStructFilt.system(subsysIdx).decision.outlocalCnts-localChanges.decOutCnts; 
	            if cvStructFilt.system(subsysIdx).decision.totalTotalCnts==0
	                keepSystem=keepSystem-1;
	            end
	        end
        elseif (strcmp(metric,'mcdc'))
	        totalChanges.mcdcTotalCnts=totalChanges.mcdcTotalCnts+localChanges.mcdcTotalCnts;
	        totalChanges.mcdcOutCnts=totalChanges.mcdcOutCnts+localChanges.mcdcOutCnts;
            if (~isempty(cvStructFilt.system(subsysIdx).mcdc))
	            keepSystem=keepSystem+1;
	            cvStructFilt.system(subsysIdx).mcdc.totalCnt=cvStructFilt.system(subsysIdx).mcdc.totalCnt-totalChanges.mcdcTotalCnts;
	            cvStructFilt.system(subsysIdx).mcdc.totalHits=cvStructFilt.system(subsysIdx).mcdc.totalHits-totalChanges.mcdcOutCnts;
	            cvStructFilt.system(subsysIdx).mcdc.localCnt=cvStructFilt.system(subsysIdx).mcdc.localCnt-localChanges.mcdcTotalCnts;
	            cvStructFilt.system(subsysIdx).mcdc.localHits=cvStructFilt.system(subsysIdx).mcdc.localHits-localChanges.mcdcOutCnts; 
	            if cvStructFilt.system(subsysIdx).mcdc.totalCnt==0
	                keepSystem=keepSystem-1;
	            end
            end
        elseif (strcmp(metric,'tableExec'))
	        if (~isempty(cvStructFilt.system(subsysIdx).tableExec))
	            keepSystem=keepSystem+1;
	            if cvStructFilt.system(subsysIdx).tableExec.totalCnt==0
	                keepSystem=keepSystem-1;
	            end
	        end
	    end
	end
	cvStructFilt.system(subsysIdx).keep=keepSystem;
	
	
function [changes, keepBlock]=filterBlock(blockIdx, metricNames)
    global cvStructFilt;
    changes=struct( 'condTotalCnts',    0, ...
                    'condOutCnts',      0, ...
                    'decTotalCnts',     0, ...
                    'decOutCnts',       0, ...
                    'mcdcTotalCnts',0, ...
                    'mcdcOutCnts',0);
     
    % now we shall examine the local changes.
    subblockCvId=cvStructFilt.block(blockIdx).cvId;
    [filtCondCvIds, filtDecCvIds,numFiltMCDCEntries]=cv_filter_object(subblockCvId, metricNames);
    for metric=metricNames(:)'
        if (strcmp(metric,'condition') && ~isempty(filtCondCvIds))
        	subblockCondCvIds=[cvStructFilt.conditions(cvStructFilt.block(blockIdx).condition.conditionIdx).cvId];
            % now we need to remove this condition object
            removeCondCvIds=[];
            for filteredCondCvId=filtCondCvIds(:)'
                condSubblockIdx=find(filteredCondCvId==subblockCondCvIds);
                if (~isempty(condSubblockIdx))
                	filteredCondIdx=cvStructFilt.block(blockIdx).condition.conditionIdx(condSubblockIdx);
                    removeCondCvIds=[removeCondCvIds, condSubblockIdx]; %cvStructFilt.block(blockIdx).condition.conditionIdx(condSubblockIdx)=[];
                    changes.condTotalCnts=changes.condTotalCnts+2;
                    changes.condOutCnts=changes.condOutCnts + (cvStructFilt.conditions(filteredCondIdx).trueCnts>0) + ...
                                                        (cvStructFilt.conditions(filteredCondIdx).falseCnts>0);
                end
            end;
            cvStructFilt.block(blockIdx).condition.conditionIdx(removeCondCvIds)=[];
        elseif (strcmp(metric,'decision') && ~isempty(filtDecCvIds))
        	subblockDecCvIds=[cvStructFilt.decisions(cvStructFilt.block(blockIdx).decision.decisionIdx).cvId];    
            for filteredDecIdx=filtDecCvIds(:)'
                % now we need to remove this decision object
                decSubblockIdx=find(filteredDecIdx==subblockDecCvIds);
                if (~isempty(decSubblockIdx))
                    filteredDecIdx=cvStructFilt.block(blockIdx).decision.decisionIdx(decSubblockIdx);
                    cvStructFilt.block(blockIdx).decision.decisionIdx(decSubblockIdx)=[];
                    changes.decTotalCnts=changes.decTotalCnts+cvStructFilt.decisions(filteredDecIdx).numOutcomes;
                    changes.decOutCnts=changes.decOutCnts+cvStructFilt.decisions(filteredDecIdx).outCnts;
                end
            end
        elseif (strcmp(metric,'mcdc')&& ~isempty(numFiltMCDCEntries)&& ~isempty(cvStructFilt.block(blockIdx).mcdc))
            blockMCDCIdx=cvStructFilt.block(blockIdx).mcdc.mcdcIndex;
            for (removing=1:numFiltMCDCEntries)
                changes.mcdcTotalCnts=changes.mcdcTotalCnts+1;
                cvStructFilt.mcdcentries(blockMCDCIdx).numPreds=cvStructFilt.mcdcentries(blockMCDCIdx).numPreds-1;
	            changes.mcdcOutCnts=changes.mcdcOutCnts+cvStructFilt.mcdcentries(blockMCDCIdx).predicate(removing).achieved;
                cvStructFilt.mcdcentries(blockMCDCIdx).covered=cvStructFilt.mcdcentries(blockMCDCIdx).covered-cvStructFilt.mcdcentries(blockMCDCIdx).predicate(removing).achieved;
            end
            cvStructFilt.mcdcentries(blockMCDCIdx).predicate(1:numFiltMCDCEntries)=[];
            if (isempty(cvStructFilt.mcdcentries(blockMCDCIdx).predicate))
                cvStructFilt.block(blockIdx).mcdc.mcdcIndex=[];
            end
        end
    end
    % We adjust the counters.
    keepBlock=0;
    for metric=metricNames(:)'
        if (strcmp(metric,'condition') && ~isempty(cvStructFilt.block(blockIdx).condition))
            keepBlock=keepBlock+1;
            cvStructFilt.block(blockIdx).condition.localCnt=cvStructFilt.block(blockIdx).condition.localCnt-changes.condTotalCnts;
            cvStructFilt.block(blockIdx).condition.localHits=cvStructFilt.block(blockIdx).condition.localHits-changes.condOutCnts;
            if (cvStructFilt.block(blockIdx).condition.localCnt==0)
                keepBlock=keepBlock-1;
            end
        elseif (strcmp(metric,'decision') && ~isempty(cvStructFilt.block(blockIdx).decision))
            keepBlock=keepBlock+1;
            cvStructFilt.block(blockIdx).decision.totalCnts=cvStructFilt.block(blockIdx).decision.totalCnts-changes.decTotalCnts;
            cvStructFilt.block(blockIdx).decision.outHitCnts=cvStructFilt.block(blockIdx).decision.outHitCnts-changes.decOutCnts;    
            if (cvStructFilt.block(blockIdx).decision.totalCnts==0)
                keepBlock=keepBlock-1;
            end
        elseif (strcmp(metric,'mcdc') && ~isempty(cvStructFilt.block(blockIdx).mcdc))
            keepBlock=keepBlock+1;
	        cvStructFilt.block(blockIdx).mcdc.localCnt=cvStructFilt.block(blockIdx).mcdc.localCnt-changes.mcdcTotalCnts;
            cvStructFilt.block(blockIdx).mcdc.localHits=cvStructFilt.block(blockIdx).mcdc.localHits-changes.mcdcOutCnts; 
            if cvStructFilt.block(blockIdx).mcdc.localCnt==0
	            keepBlock=keepBlock-1;
            end 
        elseif (strcmp(metric,'tableExec'))
	        if (~isempty(cvStructFilt.block(blockIdx).tableExec))
	            keepBlock=keepBlock+1;
	            if cvStructFilt.block(blockIdx).tableExec.totalCnt==0
	                keepBlock=keepBlock-1;
	            end
	        end
        end
    end
    cvStructFilt.block(blockIdx).keep=keepBlock;

