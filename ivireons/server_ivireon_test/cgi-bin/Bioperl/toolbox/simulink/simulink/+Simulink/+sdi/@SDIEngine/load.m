function validSDIMatFile = load(this, filename)

    % Copyright 2010 The MathWorks, Inc.
    
    % Is this a valid SDI mat file?
    validSDIMatFile = isValidSDIMatFile(filename);
    signalIDMap = Simulink.sdi.Map(char(' '), int32(0));

    if validSDIMatFile
        % Load descriptor
        descriptor = load(filename, 'SDIDescriptor');
        descriptor = descriptor.SDIDescriptor;

        % Create new runs to accomodate signals
        % in file.  Return a mapping between the
        % run IDs in the file and those created.
        runIDMap = resolveRuns(this, descriptor);
        
        runIDs = zeros(descriptor.NumSignals, 1);

        % Add signals to their respective runs
        for i = 1:descriptor.NumSignals
            % Get descriptor of i'th signal
            signal = descriptor.Signals(i);

            % Get new run ID for run on disk
            newRunID = runIDMap(signal.RunID);
            % store the run ids in an array. 
            runIDs(i) = newRunID;

            % Load this signals timeseries root
            dataRoot = load(filename, signal.varName); %#ok<NASGU>
            dataRoot = eval(['dataRoot.' signal.varName]);

            % Construct timeseries object
            dataTimeseries = timeseries(dataRoot.DataValues, dataRoot.TimeValues);
            
            parent = signal.parent;
            
            if isempty(parent)
                parent = 0;
            else
                parent = signalIDMap.getDataByKey(parent);
            end
            
            % Add signal to engine
            newSignalID =                       ...
            this.addSignal(newRunID,            ...
                           signal.RootSource,   ...
                           signal.TimeSource,   ...
                           signal.DataSource,   ...
                           dataTimeseries,      ...
                           signal.BlockSource,  ...
                           signal.ModelSource,  ...
                           signal.SignalLabel,  ...
                           signal.TimeDim,      ...
                           signal.SampleDims,   ...
                           signal.PortIndex,    ...
                           signal.Channel,      ...
                           signal.SID,          ...
                           signal.MetaData,     ...
                           parent,              ...
                           signal.rootDataSrc);
            this.setLineStyle(newSignalID, signal.LineDashed);
            this.setLineColor(newSignalID, signal.LineColor(1),...
                              signal.LineColor(2),             ...
                              signal.LineColor(3));
            signalIDMap.insert(signal.varName, newSignalID);
        end % for
        
        % find the unique run ids
        uniqueRunIDs = unique(runIDs);
        this.newRunIDs = uniqueRunIDs;
        count = length(uniqueRunIDs);
        runName = this.getRunName(int32(uniqueRunIDs(count)));
        this.updateFlag = runName;
    else
        % error
    end
end

function result = isValidSDIMatFile(filename)
    % Check for existence of descriptor
    descriptor = whos('-file', filename, 'SDIDescriptor');
    result     = ~isempty(descriptor);
end

function result = resolveRuns(engine, descriptor)

    % Assume descriptor contains no runs
    result = [];

    % Get number of runs
    runCount = length(descriptor.Runs);
    
    for i = 1:runCount
        % Get i'th run ID and name
        fileRunID   = descriptor.Runs(i).RunID;
        fileRunName = descriptor.Runs(i).RunName;
        
        % Create a new run
        newRunID = engine.createRun(fileRunName);
        
        % Associate file run ID with new run ID
        result(fileRunID) = newRunID;
        
        runCount = engine.runNumByRunID.getCount();
        
        if runCount > 0
            maxRunNumber = engine.runNumByRunID.getDataByIndex(runCount);
        else
            maxRunNumber = 0;
        end
        
        engine.runNumByRunID.insert(newRunID, maxRunNumber+1);
    end
end