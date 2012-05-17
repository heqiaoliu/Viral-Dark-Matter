function cv_append_autoscale_data(covData)

% Copyright 2003-2010 The MathWorks, Inc.

% Cache metric names


% Cache signal range
sigRange = covData.metrics.sigrange;

% Cache signal range isa enum
srIsa = cv('get','default','sigranger.isa');

% Cache top of coverage tree
topCov = cv('get', covData.rootID, '.topSlsf');

% Order the set of coverage IDs
metricEnum = cvi.MetricRegistry.getEnum('sigrange');
[allIds, depths] = cv('DfsOrder', topCov, 'require', metricEnum ); %#ok<NASGU>
origins          = cv('get', allIds, 'slsfobj.origin');

for i = 1 : length(allIds)
	[srID, isaVal] = cv('MetricGet', allIds(i), metricEnum , '.id', '.isa');

	% If data originates from Stateflow and is range data
    if (origins(i) == 2) && (isaVal == srIsa)
		sfChartID   = cv('get', allIds(i), '.handle');
        sfBlockID   = cv('get', cv('get', allIds(i), '.treeNode.parent'), '.handle');
		[dataNames, dataWidths, dataNumbers, dataIDs] = cv_sf_chart_data(sfChartID);

		% Sort the data items based on their number and
		% make the numbers contiguous from 0 to permit 
		% charts that contain temporary data.
        [~,sortI] = sort(dataNumbers);
     	varCnt = length(dataNames);
     	dataNumbers = 0:(varCnt-1);
     	dataNames = dataNames(sortI);
     	dataWidths = dataWidths(sortI);
     	dataIDs = dataIDs(sortI);
 
		% Compute offset into signal range vector
		[portSizes, baseIndex] = cv('get', srID, '.cov.allWidths', '.cov.baseIdx');
		startIndex             = [1 cumsum(2 * portSizes) + 1];

        dataBlockName   = getfullname(sfBlockID);
        dataSystem      = bdroot(dataBlockName);
        dataChartName   = strrep(dataBlockName, '/', '_');

		% When we find a stateflow chart we need to create entries for each
		% of the data  objects within the chart
        for dataIndex = 1 : length(dataNames)
            
			% Log only data _defined_ as fixpt type.
			% NOTE: The actual data type may have been overridden
    		dataName       = dataNames{dataIndex};
            dataID         = dataIDs(dataIndex);
            dataSignalName = [dataChartName '_' dataName '_' num2str(dataID)];
            dataParsedInfo = sf('DataParsedInfo', dataID, sfBlockID);

            if dataParsedInfo.type.fixpt.isFixpt
    			% Cache data ID and data type
	    		dataTypeActual  = dataParsedInfo.type.baseStr;
                dataTypeDefined = 'fixpt';

                % Cache fixpt type attributes
                dataFixExp = dataParsedInfo.type.fixpt.exponent;
                dataSlope = dataParsedInfo.type.fixpt.slope;
                dataBias = dataParsedInfo.type.fixpt.bias;
                dataNumBits = dataParsedInfo.type.fixpt.wordLength;
                dataIsSigned = dataParsedInfo.type.fixpt.isSigned;
                
            else % dataParsedInfo.type.fixpt.isFixpt false
    			% Cache data ID and data type
	    		dataTypeActual  = dataParsedInfo.type.baseStr;
                switch dataTypeActual
                    case {'double', 'single'}
                        dataTypeDefined = dataTypeActual;
                        dataobj = fixdt(dataTypeActual);
                    case {'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32'}
                        dataTypeDefined = 'fixpt';
                        dataobj = fixdt(dataTypeActual);                        
                        dataTypeActual = 'fixpt';
                    otherwise
                        % the data type should not report any logging
                        break; 
                end
                % Cache fixpt type attributes
                
                dataFixExp = dataobj.FractionLength;
                dataSlope = dataobj.Slope;
                dataBias = dataobj.Bias;
                dataNumBits = dataobj.WordLength;
                dataIsSigned = dataobj.SignednessBool;
            end % if fixpt data type
            
            % Cache data min/max
            dataRange = sigRange(baseIndex...
                + startIndex(dataNumbers(dataIndex) + 1)...
                + (0 : (2 * dataWidths(dataIndex) - 1)), :);
            dataMin = dataRange(1);
            dataMax = dataRange(2);
            
            
            % Get archive mode
            dataArchiveModeStr = get_param(dataSystem, 'MinMaxOverflowArchiveMode');
            
            % Log data
            cv('AutoscaleLog',...
                dataSignalName,...
                dataBlockName,...
                dataName,...
                dataTypeDefined,...
                dataTypeActual,...
                dataID,...
                dataMin,...
                dataMax,...
                dataSlope,...
                dataBias,...
                dataFixExp,...
                dataNumBits,...
                dataIsSigned,...
                dataArchiveModeStr);
        end % For each data in sf chart
    end % If data originates from Stateflow and is range data
end
