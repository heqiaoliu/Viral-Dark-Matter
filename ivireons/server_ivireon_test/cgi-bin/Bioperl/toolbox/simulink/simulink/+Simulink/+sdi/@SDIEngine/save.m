function save(this, filename)

    % Copyright 2010 The MathWorks, Inc.
    
    % Use this to overwrite file on first signal write
    firstSignal = true;

    % Prepare version information for descriptor
    SDIDescriptor.SimulinkVersion = ver('simulink');
    SDIDescriptor.SDIVersion      = this.getVersion();

    % Initialize to no signals
    SDIDescriptor.NumSignals = 0;

    % Get number of runs
    sigCount = this.getSignalCount();    
    runCount = this.getRunCount();
    
    if (sigCount == 0 || runCount == 0)        
        DAStudio.warning('SDI:sdi:NoData');
        return;
    end
    
    runIDs = this.getAllRunIDs();

    % Iterate over runs
    for runIndex = 1:runCount
    
        % Get the ID and name for this run
        runID   = runIDs(runIndex);
        runName = this.getRunName(runID);

        % Get the number of signals in this run
        signalCount = this.getSignalCount(runID);

        % Add run data to descriptor
        SDIDescriptor.Runs(runIndex).RunID       = runID;
        SDIDescriptor.Runs(runIndex).RunName     = runName;
        SDIDescriptor.Runs(runIndex).SignalCount = signalCount;

        % Iterate over signals for this run
        for signalIndex = 1:signalCount
        
            % Get all data for this signal
            signal = this.getSignal(runID, signalIndex);

            % Clear the engine field as we don't want to write it
            % signal = rmfield(signal, 'SDIEngine');

            % Update descriptor to reflect signal
            SDIDescriptor.NumSignals = SDIDescriptor.NumSignals + 1;
            

            % Form serialized name of signal            
            signal.varName = ['s' int2str(signal.DataID)];
            
            % get parent
            [~, ~, parent] = this.getChildrenAndParent(runID, signalIndex);
            
            if (parent ~= 0)
                signal.parent = ['s' int2str(parent)];
            else
                signal.parent = [];
            end

            % Repackage the timeseries to factor out
            % the object and leave only the data.  This
            % makes saving much faster.
            signalToCopy.TimeValues = signal.DataValues.Time;
            signalToCopy.DataValues = signal.DataValues.Data;
            
            % Clear the Datavalues field as we don't want to write it
            signal = rmfield(signal, 'DataValues');
            
            % Assign signal name
            eval([signal.varName '=signalToCopy;']);

            % Save this signal to mat
            if firstSignal
                firstSignal = false;
                save(filename, signal.varName, '-v7.3');
            else
                save(filename, '-append', signal.varName, '-v7.3');
            end % if
            
            % Now that the signal is written to disk,
            % clear the local variable.  In other words,
            % the only signal in memory is the one being
            % written
            eval(['clear(''' signal.varName ''');']);
            
            % Add signal metadata to descriptor
            SDIDescriptor.Signals(SDIDescriptor.NumSignals) = signal;
        end % for - signal
    end % for - run
    
    % Now that all signals have been written, write
    % the descriptor
    save(filename, '-append', 'SDIDescriptor', '-v7.3');
end