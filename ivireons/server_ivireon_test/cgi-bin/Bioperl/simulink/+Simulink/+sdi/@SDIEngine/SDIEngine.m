classdef SDIEngine < handle
    
    % DiffRunResult - Read-only property storing the results of the most
    %                 recent difference.
    %
    % Simulink Interface Methods
    % --------------------------
    % RECORD()
    % Starts the recording of Simulink simulations for every model simulated
    %
    % STOP() % Stop recording
    %
    % Run Comparison Methods
    % ----------------------
    % DiffRuns(RunID1, RunID2)
    %
    % SDIEngine Methods
    % -----------------
    % runID = createEmptyRun(runName)
    %   Adds an empty run to the SDI engine.
    %
    % clearRuns
    %   Clears all the Runs from Signal repository. In future, you will be able
    %   to selectively remove Runs belonging to an instance of SDIEngine.
    %
    % out = getRunCount
    %   Returns the number of Runs in the engine.
    %
    % out = getSignalCount
    %   Returns the number of signals, given a valid run id. Throws error if
    %   runID is not valid.
    %
    % out = getSignal
    %   Returns a signal with various fields such as blocksource, model source
    %   etc.
    %   Two types of calls are supported:
    %   sdie = Simulink.sdi.SDIEngine;
    %   sdie.getSignal(signalID)
    %   sdie.getSignal(runID, index)
    %   signalID - signal ID
    %   runID    - run ID
    %   index    - index of the signal in the run
    %
    % deleteRun
    %   Deletes a run, given a run ID.
    %
    % deleteSignal
    %   Deletes a signal. Two types of calls are supported:
    %   sdie.deleteSignal(signalID)
    %   sdie.deleteSignal(runID, index)
    %   signalID - signal ID
    %   runID    - run ID
    %   index    - index of the signal in the run
    %
    % getDateCreated
    %   Returns the date on which a run was created, given a run ID.
    %
    % updateDateCreated
    %   Updates the timestamp of a run, given a run ID.
    %
    % addSignal
    %   Adds a signal to the engine
    %   Parameters:
    %       dataRunName - char
    %       rootSource  - char
    %       timeSource  - char
    %       dataSource  - char
    %       dataValues  - any
    %       blockSource - char
    %       modelSource - char
    %       signalLabel - char
    %       timeDim     - int
    %       sampleDims  - int
    %       portIndex   - int
    %       channel     - int
    %       sID         - char
    %       metaData    - any
    %
    % out = getRunName
    %   Returns the name of a run, given its run ID.
    %
    % out = getRunID
    %   Returns the run ID of a run, given its 'run name' or 'run index'.
    %
    % Copyright 2009-2010 The MathWorks, Inc.
    
    properties (Access = 'private')       
        Listeners;          % Array of listeners for Simulink events, e.g.
        RecordStatus;       % on or off
        CurrentModel;       % Used in createRun and createManualRun fcns.
        
        % Callback issued after a new run is created
        OnCreateRun;
        
        % instance ID
        instanceID;
        
        % repository
        sigRepository;
        
        % version
        sdiVersion;
        
        % simulation status
        simStatus;
    end
    
    properties (Access = 'public')
        % Instance of Simulink.sdi.DiffRunResult used to difference two runs
        DiffRunResult;
        
        % Instance of Simulink.sdi.AlignRuns used to align
        % two runs for comparison
        AlignRuns;
        
        % new run ids
        newRunIDs;
        
        % flag for showing messages if no data is logged
        warnDialogParam;
        
        % map for run id vs run number
        runNumByRunID;
    end
    
    properties (SetObservable, Access = 'public')
        % flag to update the gui
        updateFlag;
    end
    
    methods
        
        function this = SDIEngine()
            this.sigRepository = Simulink.sdi.SignalRepository;
            this.Listeners     = handle.listener('', '', '');
            this.RecordStatus  = false;
            this.DiffRunResult = Simulink.sdi.DiffRunResult;
            this.AlignRuns     = Simulink.sdi.AlignRuns(this);
            this.OnCreateRun   = [];
            
            persistent highWaterMark;
            
            % Initialize high water mark on first call
            if isempty(highWaterMark)
                highWaterMark = uint32(0);
            end
            
            % Increment high water mark
            highWaterMark = highWaterMark + 1;
            this.instanceID = highWaterMark;
            
            % sdi version
            this.sdiVersion = '1.0';
            this.simStatus = true;
            % initialize it to empty. This will be used by GUIMain to throw
            % messages about a model
            this.warnDialogParam = '';
            
            % initialize the runId vs runNum map
            this.runNumByRunID = Simulink.sdi.Map(int32(0), int32(0));
        end
        
        function registerListener(this, func)
            addlistener(this, 'updateFlag', 'PostSet',...
                        func);
        end
        
        function result = GetOnCreateRun(this)
            result = this.OnCreateRun;
        end
        
        function SetOnCreateRun(this, OnCreateRun)
            % DAVID: Need error checking
            this.OnCreateRun = OnCreateRun;
        end
        
        function DoOnCreateRun(this, DataRunID)
            if ~isempty(this.OnCreateRun)
                this.SetOnCreateRun(this, DataRunID);
            end
        end
        
        function saveTolerances( this, DataRunID, filename)
            TolSave.ver = ver('Simulink');
            TolSave.Entry = {};
            first.Key =  'global_tolerance';
            first.Content = this.getToleranceDetailsByRun(int32(DataRunID));
            TolSave.Entry{end + 1} = first;
            
            for i = 1 : this.sigRepository.getSignalCount(int32(DataRunID))
                dataObj = this.sigRepository.getSignal(int32(DataRunID), i);
                if ~this.sigRepository.isToleranceInherited(int32(DataRunID),...
                                                            i)
                    temp.Key = dataObj.DataSource;
                    temp.Content = this.getToleranceDetails(int32(DataRunID),...
                                                            i);
                    TolSave.Entry{end + 1} = temp;
                end
            end
            save( filename, 'TolSave');
        end
        
        function setToleranceDetailsByRun( this, DataRunID, values)
            if isfield( values, 'absolute')
                this.sigRepository.setAbsoluteToleranceByRun(int32(DataRunID),...
                                                             values.absolute);
            end
            if isfield( values, 'relative')
                this.sigRepository.setRelativeToleranceByRun(int32(DataRunID),...
                                                             values.relative);
            end
            if isfield( values, 'fcnCall')
                this.sigRepository.setFcnCallTolByRun(int32(DataRunID),...
                                                      values.fcnCall);
            end
        end
        
        function setToleranceDetails( this, DataID, values)
            if isfield( values, 'absolute')
                this.sigRepository.setAbsoluteTolerance(int32(DataID),...
                                                        values.absolute);
            end
            if isfield( values, 'relative')
                this.sigRepository.setRelativeTolerance(int32(DataID),...
                                                        values.relative);
            end
            if isfield( values, 'fcnCall')
                this.sigRepository.setFcnCallTol(int32(DataID),...
                                                 values.fcnCall);
            end
        end
        
        function delete(this)
            try
                this.clearRuns();
            catch %#ok
                % just in case if the instance id does not exist
            end
                
        end
        
        function clearRuns(this)
            this.sigRepository.deleteInstanceID(this.instanceID);
            this.updateFlag = ' ';
            % initialize the runId vs runNum map again
            this.runNumByRunID = Simulink.sdi.Map(int32(0), int32(0));
        end
        
        function out = getRunCount(this)
            out = length(this.getAllRunIDs());
        end
        
        function result = isRecording(this)
            result = this.RecordStatus;
        end
        
        function out = getSignalCount(this, varargin)
            % handles both the cases: 1) Signals in a run
            % 2) signals in Engine
            if(nargin == 2)
                out = this.sigRepository.getSignalCount(varargin{:});
            else
                count = 0;
                runIDs = this.getAllRunIDs();
                for i = 1:length(runIDs)
                    numSigs = this.getSignalCount(runIDs(i));
                    count = count + numSigs;
                end
                out = count;
            end
        end
        
        function out = getSignal(this,varargin)
            out = this.sigRepository.getSignal(varargin{:});
        end
        
        % delete run
        function deleteRun(this, runID)
            this.sigRepository.removeRun(runID);
        end
        
        % delete signal
        function deleteSignal(this,varargin)
            this.sigRepository.remove(varargin{:});
        end
        
        % get created date
        function out = getDateCreated(this, runID)
            out = this.sigRepository.getDateCreated(runID);
        end
        
        % update date created
        function updateDateCreated(this, runID)
            this.sigRepository.updateDateCreated(runID);
        end
        
        % set date created
        function setDateCreated(this, runID, date)
            this.sigRepository.setDateCreated(runID, date);
        end
        
        % add signal
        function signalID = addSignal(this, varargin)
            signalID = this.sigRepository.add(this,varargin{:});
        end
        
        % get run name
        function out = getRunName(this, runID)
            out = this.sigRepository.getRunName(runID);
        end
        
        function setRunName(this, runID, runName)
            this.sigRepository.setRunName(runID, runName);
        end
        
        % get Run ID by run name or index
        function out = getRunID(this, runNameOrInd)
            out = this.sigRepository.getRunID(runNameOrInd);
        end
        
        % set visibility
        function setVisibility(this, id, flag)
            this.sigRepository.setVisibility(int32(id),flag);
        end
        
        function setLineColor(this, id, r, g, b)
            this.sigRepository.setLineColor(id, r, g, b);
        end
        
        function setLineStyle(this, id, lineStyle)
            this.sigRepository.setLineStyle(id, lineStyle);
        end
        
        function sid = showSourceBlockInModel(this, id)
            data = this.sigRepository.getSignal(int32(id));
            sid = data.SID;
            Simulink.ID.hilite(sid);
        end
        
        function out = getNextRunID(this)
            out = this.sigRepository.getNextRunID();
        end
        
        function out = getAllRunIDs(this)
            out = this.sigRepository.getAllRunIDs(this.instanceID);
        end
        
        function out = getTolerance(this, varargin)
            out = this.sigRepository.getTolerance(varargin{:});
        end
        
        function out = getSyncOptions(this, varargin)
            out = this.sigRepository.getSyncOptions(varargin{:});
        end
        
        function out = getVersion(this)
            out = this.sdiVersion;
        end
        
        function out = copyRun(this, runID)
            out = this.sigRepository.copyRun(runID, this.instanceID);
        end
        
        function setMetaData(this, varargin)
            this.sigRepository.setMetaData(varargin{:});
        end
        
        function startWritingToFile(this)
            this.sigRepository.writeToFile();
        end
        
        function stopWritingToFile(this)
            this.sigRepository.stopWritingToFile();
        end
        
        function deleteBySortCriterion(this, group, sortCriterion)
            if isempty(group)
                group = '';
            end
            
            count = this.sigRepository.getIDCount(group, sortCriterion);
            
            for i = 1 : count
                newCount = this.sigRepository.getIDCount(group, sortCriterion);
                if (newCount > 0)
                    id = this.sigRepository.getIDFromGroup(int32(1), group, sortCriterion);
                    this.deleteSignal(id);
                else
                    break;
                end
            end
        end
        
        function [status, ids, parent] = getChildrenAndParent(this, varargin)
            [status, ids, parent] = this.sigRepository.getChildrenAndParent(varargin{:});
        end
        
        function out = isValidRunID(this, runID)
            out = this.sigRepository.isValidRunID(runID);
        end
        
        function out = getInstanceID(this, varargin)
            if nargin == 1
                out = this.instanceID;
            else
                id = varargin{1};
                out = this.sigRepository.getInstanceID(id);
            end
        end
        
    end % methods - public
    
    methods (Access = 'private')
        
        function values = getToleranceDetailsByRun( this, DataRunID)
            tolStruct = this.sigRepository.getToleranceByRun(int32(DataRunID));
            if tolStruct.toleranceType == 0 % Basic
                values.absolute = tolStruct.absolute;
                values.relative = tolStruct.relative;
            elseif tolStruct.toleranceType == 1 % varying
                values.timeStart = tolStruct.timeStart;
                values.timeEnd = tolStruct.timeEnd;
                values.timeStep = tolStruct.timeStep;
                values.initAbsTolVal = tolStruct.initAbsTolVal;
                values.absStep = tolStruct.absStep;
                values.initRelTolVal = tolStruct.initRelTolVal;
                values.relStep = tolStruct.relStep;
            elseif tolStruct.toleranceType == 2 % fcn
                values.fcnCall = tolStruct.fcnCall;
            end
        end
        
        function values = getToleranceDetails( this, DataRunID, index)
            tolStruct = this.sigRepository.getTolerance(int32(DataRunID),...
                                                        int32(index));
            if tolStruct.toleranceType == 0 % Basic
                values.absolute = tolStruct.absolute;
                values.relative = tolStruct.relative;
            elseif tolStruct.toleranceType == 1 % varying
                values.timeStart = tolStruct.timeStart;
                values.timeEnd = tolStruct.timeEnd;
                values.timeStep = tolStruct.timeStep;
                values.initAbsTolVal = tolStruct.initAbsTolVal;
                values.absStep = tolStruct.absStep;
                values.initRelTolVal = tolStruct.initRelTolVal;
                values.relStep = tolStruct.relStep;
            elseif tolStruct.toleranceType == 2 % fcn
                values.fcnCall = tolStruct.fcnCall;
            end
        end
        
        % Helper Function to get the name to the current model being executed
        % to capture the data that corresponds to this model. Used in record
        % function.
        function getName(this, source, event)%#ok
            this.CurrentModel = source.Name;
        end
        
    end  % methods - private
    
    methods(Static = true)
        % Prototype for comparison function
        [varargout] = compare(ts1, ts2, varargin);
        
        % Prototype for default comparison options
        [tolStruct, syncStruct] = defaultTolAndSyncOptions();
    end % methods - static
    
end % classdef