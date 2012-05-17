function rowList = populateTableColumns(this, sortCriterion, colNameList,...
                                        order, varargin)
    
    % Copyright 2009-2010 The MathWorks, Inc.
    
    % Total number of columns
    numOfColumns = length(colNameList) + 3;
    
    % Signal Repository
    tsr = Simulink.sdi.SignalRepository;
    
    % get number of groupings
    len = tsr.getGroupCount(sortCriterion);
    rowList = javaObjectEDT('java.util.ArrayList');
    
    % cahce string dictionary
    sd = this.sd;
    
    % Column indices
    runInd      = strmatch(sd.mgRun, colNameList);
    blockInd    = strmatch(sd.IGBlockSourceColName, colNameList);
    plotInd     = strmatch(sd.MGInspectColNamePlot, colNameList);
    colorInd    = strmatch(sd.mgLine, colNameList);
    dataInd     = strmatch(sd.IGDataSourceColName, colNameList);
    modelInd    = strmatch(sd.IGModelSourceColName, colNameList);
    sigLabelInd = strmatch(sd.mgSigLabel, colNameList);
    leftInd     = strmatch(sd.mgLeft, colNameList);
    rightInd    = strmatch(sd.mgRight, colNameList);
    abstolInd   = strmatch(sd.mgAbsTol, colNameList);
    reltolInd   = strmatch(sd.mgRelTol, colNameList);
    syncInd     = strmatch(sd.mgSyncMethod, colNameList);
    interpInd   = strmatch(sd.mgInterpMethod, colNameList);                
    rootInd     = strmatch(sd.IGRootSourceColName, colNameList);
    timeInd     = strmatch(sd.IGTimeSourceColName, colNameList);
    dimInd      = strmatch(sd.mgDimensions, colNameList);
    portInd     = strmatch(sd.IGPortIndexColName, colNameList);
    channelInd  = strmatch(sd.mgChannel, colNameList);
    mgLeaf      = strmatch(sd.mgLeaf, colNameList);
    this.leftInd = leftInd;
    this.rightInd = rightInd;
    
    runIDs = this.SDIEngine.getAllRunIDs();
    
    % for populating specific run ids
    if ~isempty(varargin) && length(varargin) > 1
        toPopulateRunIDs = varargin{2};
        len = length(toPopulateRunIDs);        
    end
    
    % populate table
    for i = 1 : len        
        
        if strcmpi(sortCriterion, 'GRUNNAME')
            try
                % for populating specific run ids
                if ~isempty(varargin) && length(varargin) > 1
                    group = int32(toPopulateRunIDs(i));
                else
                    group = this.SDIEngine.getRunID(i);
                end
                
                if (~isempty(varargin) && ~isempty(runIDs) && group ~= runIDs(end)...
                     && varargin{1})
                    continue;
                end
            catch %#ok
                continue; % not in this SDIEngine
            end
            
            count = this.SDIEngine.getSignalCount(group);
            runCount = this.SDIEngine.getRunCount();
            % No need to populate if there is no signal
            if (count == 0 || runCount == 0)
                continue;
            else
                % Create row heading
                rowHeading = this.SDIEngine.getRunName(group);
            end
        else
            group = tsr.getGroup(int32(i), sortCriterion, order);
            count = tsr.getIDCount(group, sortCriterion);
            % No need to populate if there is no signal
            if (count == 0)
                continue;
            end
            % Create row heading
            sortCriterionName = getSortCriterion(this.sd, sortCriterion);
            rowHeading = [sortCriterionName ' : ' group];
        end
        % Create root row
        rootRow = javaObjectEDT                         ...
                  ('com.mathworks.toolbox.sdi.sdi.Row', ...
                  numOfColumns, 0);
        
        % set same row heading for all columns for root row
        for k = 0:numOfColumns-2
            rootRow.setValueAt(rowHeading,k);
        end
        
        % store group name for other operations
        rootRow.setValueAt(group,numOfColumns - 1);
        % Store '-1' for root rows. It is used in Java classes
        rootRow.setValueAt('-1', mgLeaf);
        instID = this.SDIEngine.getInstanceID();
        
        % Populate leaf rows
        for j = 1 : count
            if strcmpi(sortCriterion, 'GRUNNAME')
                % get signal structure
                dataObj = this.SDIEngine.getSignal(group, j);
                % get signal id
                id = dataObj.DataID;
                
                % Do not populate if it does not belong to this instance
                instanceID = this.SDIEngine.getInstanceID(id);
                
                if(instID ~= instanceID)
                    continue;
                end
            else
                % get signal id from grouping
                id = tsr.getIDFromGroup(int32(j), group, sortCriterion);                
                
                % Do not populate if it does not belong to this instance
                instanceID = this.SDIEngine.getInstanceID(id);
                
                if(instID ~= instanceID)
                    continue;
                end
                
                % get signal structure
                dataObj = tsr.getSignal(id);
            end
            
            % Status = do we need to populate this?
            % ids = vector of signals IDs of children signals
            [status, ids] = this.SDIEngine.getChildrenAndParent(id);
                        
            if (~status)
                continue;
            else
                % Create leaf row
                leafRow = javaObjectEDT                         ...
                          ('com.mathworks.toolbox.sdi.sdi.Row', ...
                          numOfColumns);
                % populate root leaf row
		        status =                                                           ...
                helperPopulate(this, runInd, blockInd, plotInd, colorInd, dataInd, ...
                               modelInd, sigLabelInd, leftInd, rightInd, abstolInd,...
                               reltolInd, syncInd, interpInd, rootInd, timeInd,    ...
                               dimInd, portInd, leafRow, id, tsr, dataObj,         ...
                               numOfColumns, channelInd, group);
				
                if ~status
                    continue;
                end
                
                if ~isempty(ids)
                    % number of ids
                    sz = length(ids);                    
                    % Set values at various columns for root leaf row
                    leafRow.setValueAt('-1', mgLeaf);
                    leafRow.setValueAt(' ', colorInd-1);
                    leafRow.setValueAt(' ', plotInd-1);
                    leafRow.setValueAt(' ', leftInd-1);
                    leafRow.setValueAt(' ', rightInd-1);
                    leafRow.setValueAt(' ', dataInd-1);
                    leafRow.setValueAt(' ', channelInd-1);
                    leafRow.setValueAt(' ', rootInd-1);
                    secondLeafRow = javaObjectEDT                        ...
                                   ('com.mathworks.toolbox.sdi.sdi.Row', ...
                                    numOfColumns, 2);
		            status =                                                           ...
                    helperPopulate(this, runInd, blockInd, plotInd, colorInd, dataInd, ...
                                   modelInd, sigLabelInd, leftInd, rightInd, abstolInd,...
                                   reltolInd, syncInd, interpInd, rootInd, timeInd,    ...
                                   dimInd, portInd, secondLeafRow, id, tsr, dataObj,   ...
                                   numOfColumns, channelInd, group);
                    if status
                        leafRow.addChild(secondLeafRow);
                    end
                    
                    for z = 1:sz
                        % Populate leaves
                        secondLeafRow = javaObjectEDT                        ...
                                       ('com.mathworks.toolbox.sdi.sdi.Row', ...
                                        numOfColumns, 2);
                        dataOb = this.SDIEngine.getSignal(int32(ids(z)));
			            status =                                                           ...
                        helperPopulate(this, runInd, blockInd, plotInd, colorInd, dataInd, ...
                                       modelInd, sigLabelInd, leftInd, rightInd, abstolInd,...
                                       reltolInd, syncInd, interpInd, rootInd, timeInd,    ...
                                       dimInd, portInd, secondLeafRow, int32(ids(z)), tsr, ...
                                       dataOb, numOfColumns, channelInd, group);
                        if status
                            % add leaf
                            leafRow.addChild(secondLeafRow);
                        end
                    end
                end
            end
            rootRow.addChild(leafRow); % for adding leafRows
        end
        
        childCount = rootRow.getChildrenCount;
        if(childCount ~= 0)
            rowList.add(rootRow);            
        end           
    end % for adding rootRows
    
end  % populateTable(this)


% Helper function for populating rows
function status =  helperPopulate(this, runInd, blockInd, plotInd, colorInd, dataInd, ...
                                  modelInd, sigLabelInd, leftInd, rightInd, abstolInd,...
                                  reltolInd, syncInd, interpInd, rootInd, timeInd,    ...
                                  dimInd, portInd, leafRow, id, tsr, dataObj,         ...
                                  numOfColumns, channelInd, group)
    
	try
        % Run ID
        if ~isempty(runInd)
            leafRow.setValueAt(tsr.getRunName(dataObj.RunID), runInd-1);
        end
        
        % Plot column
        if ~isempty(plotInd)
            % get the visibility of signals
            status = tsr.getVisibility(id);
            leafRow.setValueAt(status, plotInd-1);
        end
        
        tol = tsr.getTolerance(id);
        sync = tsr.getSyncOptions(id);        
        
	catch %#ok
	    status = false;
        return;
	end
	
	% Block source
    if ~isempty(blockInd)
        leafRow.setValueAt(dataObj.BlockSource, blockInd-1);
    end
    
    % Channel
    if ~isempty(channelInd)
        leafRow.setValueAt(num2str(dataObj.Channel), channelInd-1);
    end
    
    % Line style and color
    if ~isempty(colorInd)
        sf = javaObjectEDT('com.mathworks.toolbox.sdi.sdi.ColorStyleStrokeFactory');
        ds = javaMethodEDT('getColorStyleStroke', sf, dataObj.LineDashed);
        lColor = dataObj.LineColor;
        color = javaObjectEDT( 'java.awt.Color',...
                               lColor(1),       ...
                               lColor(2),       ...
                               lColor(3) );
        colorStyleLine = javaObjectEDT                                  ...
                        ('com.mathworks.toolbox.sdi.sdi.ColorStyleLine',...
                         color, ds, dataObj.LineDashed);
        leafRow.setValueAt(colorStyleLine, colorInd-1);
    end
    
    % Tolerances
    if ~isempty(abstolInd)
        leafRow.setValueAt(num2str(tol.absolute), abstolInd-1);
    end
    
    if ~isempty(reltolInd)
        leafRow.setValueAt(num2str(tol.relative), reltolInd-1);
    end
    
    if ~isempty(syncInd)
        leafRow.setValueAt(sync.SyncMethod, syncInd-1);
    end
    
    if ~isempty(interpInd)
        leafRow.setValueAt(sync.InterpMethod, interpInd-1);
    end
    
    % Data Source
    if ~isempty(dataInd)
        leafRow.setValueAt(dataObj.DataSource, dataInd-1);
    end
    
    % Model Source
    if ~isempty(modelInd)
        leafRow.setValueAt(dataObj.ModelSource, modelInd-1);
    end
    
    % Signal Label
    if ~isempty(sigLabelInd)
        leafRow.setValueAt(dataObj.SignalLabel, sigLabelInd-1);
    end
    
    % Sig 1
    if (~isempty(leftInd))
        if(this.state_SelectedSignalsCompSig(1) == dataObj.DataID)
            leafRow.setValueAt(true, leftInd-1);
        else
            leafRow.setValueAt(false, leftInd-1);
        end
    end
    
    % Sig 2
    if (~isempty(rightInd))
        if(this.state_SelectedSignalsCompSig(2) == dataObj.DataID)
            leafRow.setValueAt(true, rightInd-1);
        else
            leafRow.setValueAt(false, rightInd-1);
        end
    end
    
    % Root Source
    if ~isempty(rootInd)
        leafRow.setValueAt(dataObj.RootSource, rootInd-1);
    end
    
    % Time Source
    if ~isempty(timeInd)
        leafRow.setValueAt(dataObj.TimeSource, timeInd-1);
    end
    
    % Dimensions
    if ~isempty(dimInd)
        leafRow.setValueAt(num2str(dataObj.SampleDims), dimInd-1);
    end
    
    % Port
    if ~isempty(portInd)
        leafRow.setValueAt(num2str(dataObj.PortIndex), portInd-1);
    end
    
    % Data ID
    leafRow.setValueAt(dataObj.DataID, numOfColumns-2);
    % Group
    leafRow.setValueAt(group, numOfColumns-1);
	status = true;
end

function out = getSortCriterion(sd, sortCriterion)
    switch sortCriterion
        case 'GRUNNAME'
            out = sd.mgRunName;
        case 'GBLOCKPATH'
            out = sd.IGBlockSourceColName;
        case 'GDATASOURCE'
            out = sd.IGDataSourceColName;
        case 'GMODEL'
            out = sd.IGModelSourceColName;
        case 'GSIGNALNAME'
            out = sd.mgSigLabel;
    end
end


