classdef (Hidden = true) ModelRefCodeInfoUtils < rtw.connectivity.CodeInfoUtils
%MODELREFCODEINFOUTILS provides CodeInfo extensions and utilities tailored
%towards model reference components.
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $
        
    % private properties
    properties (SetAccess = 'private', GetAccess = 'private')
        timingBridgeRequired;
        timingBridgeData;
        subModelCodeInfos;
    end

    methods (Access = 'public')     
        % constructor
        function this = ModelRefCodeInfoUtils(codeInfo)
            error(nargchk(1, 1, nargin, 'struct'));            
            % call super class constructor
            this@rtw.connectivity.CodeInfoUtils(codeInfo);               
            % validate and init internal data
            this.initTimingBridgeData;
        end                        
        
        function [timingBridgeRequired timingBridgeData] = getTimingBridgeInfo(this)
            timingBridgeRequired = this.timingBridgeRequired;
            timingBridgeData = this.timingBridgeData;
        end
        
        function taskCounterRequired = isTaskCounterRequired(this)
            timingBridgeReq = this.getTimingBridgeInfo;
            taskCounterRequired = timingBridgeReq && ~this.isSampleTimeIndependent;
        end
        
        function rateInteractions = getRateInteractions(this)
            % Return all possible rate interactions between 2 periodic rates
            %
            % A row of rateInteractions looks like [0 1] which indicates a
            % possible interaction between tids 0 and 1
            %
            % This function filters out unnecessary interactions such as:
            %
            % [0 0]
            % [1 1]
            % [1 0] (covered by [0 1])
            %
            rateInteractions = [];
            % rate transition data is only required for multitasking
            % scheduling            
            if this.isMultiTasking
                periodicRates = this.getRates('PERIODIC');
                numRates = length(periodicRates);
                
                for i=1:numRates
                    for j=1:numRates
                        if (i~=j) && (j > i)
                            rateInteractions(end+1, :) = [(i-1) (j-1)]; %#ok<AGROW>
                        end
                    end
                end               
            end                                              
        end
        
        function data = getDataFromIdentifier(this, dataIn, id) %#ok<MANU>
            % return empty if not found
            data = [];
            for i=1:length(dataIn)
                currData = dataIn(i);
                if strcmp(currData.Implementation.Identifier, id)
                    % found a match
                    data = currData;
                    break;
                end
            end
        end   
        
        function indices = getModelArgParams(this)
            indices = find(strcmp(get(this.codeInfo.Parameters, ...
                                      'SID'), this.codeInfo.GraphicalPath));                      
        end
        
        function isModelArgParam = isModelArgParam(this, dataInterface)
            isModelArgParam = strcmp(get(dataInterface,'SID'), ...
                                     this.codeInfo.GraphicalPath);
        end
        
        function dispString = getDataInterfaceString(this, dataInterface)
            % resolve to type and index
            type = this.resolveIODataInterface(dataInterface);            
            switch type                
                case 'Parameter'
                    if this.isModelArgParam(dataInterface)
                        graphicalPath = this.getGraphicalPathFromSID(dataInterface.SID);
                        dispString = ['Model argument ' dataInterface.GraphicalName ' in ' graphicalPath]; 
                    else                        
                        % call superclass
                        dispString = getDataInterfaceString@rtw.connectivity.CodeInfoUtils(this, dataInterface);
                    end                                    
                otherwise
                    % call superclass
                    dispString = getDataInterfaceString@rtw.connectivity.CodeInfoUtils(this, dataInterface);
            end
        end   
    end
    
    methods (Access = 'protected')                     
        % get data interfaces for all global data stores that we must
        % process
        function ds = getGlobalDataStoresFromCodeInfo(this)
            % call superclass method to find global data stores accessed
            % by the top-model
            topModelDS = getGlobalDataStoresFromCodeInfo@rtw.connectivity.CodeInfoUtils(this);
            % find global data stores only accessed by sub-models
            subModelDS = this.getSubModelGlobalDataStores;
            % combine
            ds = [topModelDS; subModelDS];
        end   
        
        function throwContinuousTimeError(this)
            % throw an error saying that continuous time is not supported
            % at all
            rtw.pil.ProductInfo.error('pil', 'ModelBlockContinuousTime', ...
                                      this.codeInfo.GraphicalPath);
        end
        
        function validateNumRatesForOutputTasks(this, numOutputTasks)
            if this.isMultiTasking                
                rates = this.getRates('PERIODIC');
                % there must be a task for each rate
                %
                % there is a special case with internal contrinuous times
                % where numOutputTasks will be > numRates
                assert(numOutputTasks >= length(rates), ...
                       'Not at least one output task for each rate.');
            end                  
        end      
    end
        
    methods (Access = 'private')                               
        function initTimingBridgeData(this)            
            % process timingBridge
            this.timingBridgeData = this.getDataFromIdentifier(this.codeInfo.InternalData, 'timingBridge');
            if ~isempty(this.timingBridgeData)
                % check timing bridge needs to be defined
                assert(~this.timingBridgeData.Implementation.isDefined);
                this.timingBridgeRequired = true;
            else
                this.timingBridgeRequired = false;
            end            
            % check that there are no offset sample times
            % they are not supported because the timingBridge setup is more
            % complicated than for regular sample times
            %
            % note: for consistency, offset sample times are not supported
            % regardless of whether or not the timingBridge is required
            %
            % INHERITED sample times that turn out to have an offset are
            % ok - the timingBridge is not used in this case
            rates = this.getRates('PERIODIC');
            for i=1:length(rates)
                rate = rates(i);
                if rate.SampleOffset ~= 0
                    rtw.pil.ProductInfo.error('pil', 'ModelBlockSampleOffset', ...
                        this.codeInfo.GraphicalPath, ...
                        rtw.connectivity.CodeInfoUtils.double2str(rate.SamplePeriod), ...
                        rtw.connectivity.CodeInfoUtils.double2str(rate.SampleOffset));
                end
            end
        end
        
        function codeInfo = getSubModelCodeInfo(this, subModel)
            if isempty(this.subModelCodeInfos)
                % initialize subModelCodeInfos cache
                this.subModelCodeInfos = containers.Map;            
            end            
            % check for a map hit
            if this.subModelCodeInfos.isKey(subModel)
               % return item from map
               codeInfo = this.subModelCodeInfos(subModel); 
            else
               % load and store in map
               %                               
               % Throw an error if subModel is not a valid mdl-file
               %
               % tested by:
               % tpil_datastores:lvlTwo_GlobalDS_In_Submodel_Missing_Model               
               mdlFileValue = 4;
               if exist(subModel, 'file') ~= mdlFileValue
                  rtw.connectivity.ProductInfo.error('target', ...
                                                     'MissingSubmodel', ...
                                                     subModel);    
               end
               bDirInfo = RTW.getBuildDir(subModel);
               codeInfoPath = fullfile(bDirInfo.CodeGenFolder,...
                                       bDirInfo.ModelRefRelativeBuildDir,...
                                       'codeInfo.mat');
               % call static method to load CodeInfo
               %
               % model ref rebuild options could be responsible for a
               % missing CodeInfo
               addRebuildNeverMessage = true;
               codeInfoStruct = rtw.pil.SILPILInterface.loadCodeInfo(codeInfoPath, ...
                                                                     addRebuildNeverMessage);      
               codeInfo = codeInfoStruct.codeInfo;
               this.subModelCodeInfos(subModel) = codeInfo;
            end            
        end                
        
        % find global data stores only accessed by sub-models
        function subModelDS = getSubModelGlobalDataStores(this)
            % look for DataStores where the SID is a model name:
            %
            % - These DataStores are only accessed by a sub-model.
            % - We must load the sub-model CodeInfo in order to get a
            % data interface containing valid implementation details                        
            subModelDS = [];
            allSIDs = get(this.codeInfo.DataStores, 'SID');            
            % find indices that could correspond to a root model
            SIDdelim = ':';
            possibleRootModelIndices = strcmp(allSIDs, strtok(allSIDs, SIDdelim));
            % filter out empty SID's
            nonEmptyIndices = ~strcmp(allSIDs, '');
            % find intersection
            indices = nonEmptyIndices & possibleRootModelIndices;
            dsToProcess = this.codeInfo.DataStores(indices);
            if length(dsToProcess) > 1
                % check for uniqueness
                graphicalNames = get(dsToProcess, 'GraphicalName');
                assert(iscell(graphicalNames), ...
                    'Must have cell array of GraphicalNames');
                uniqueDSNames = unique(graphicalNames);
                assert(length(dsToProcess) == ...
                    length(uniqueDSNames), ...
                    'Submodel global ds names must be unique')
            end
            % process each ds
            for dsIdx = 1:length(dsToProcess)
               ds = dsToProcess(dsIdx);
               assert(isempty(ds.Implementation), ...
                   'Implementation of data store accessed only in sub-model must be empty.');
               subModelCodeInfo = this.getSubModelCodeInfo(ds.SID);                              
               % find global data stores
               subModelGlobalDSIdx = ...
                   strcmp(get(subModelCodeInfo.DataStores, 'SID'), '');
               % find data stores with matching GraphicalName
               subModelGraphicalNameMatchIdx = ...
                   strcmp(get(subModelCodeInfo.DataStores, 'GraphicalName'), ds.GraphicalName);
               % find intersection
               subModelDSIdx = subModelGlobalDSIdx & subModelGraphicalNameMatchIdx;
               newSubModelDS = subModelCodeInfo.DataStores(subModelDSIdx);              
               assert(isscalar(newSubModelDS), ...
                   'Number of matching submodel global data stores must be 1');               
               subModelDS = [subModelDS; newSubModelDS]; %#ok<AGROW>               
            end                        
        end
    end
end
