function signalIDs = addToRunSOEOutput(this, runID, soeOutput)
    
    % Copyright 2010 The MathWorks, Inc.

    % No signals added yet
    signalIDs = [];
    parentID = [];

    % Lower output
    loweredOutput = Simulink.sdi.SimOutputLower.lower(soeOutput);
        
    if max(size(loweredOutput)) > 1
        loweredOutput = reshape(loweredOutput, numel(loweredOutput), 1);
        ithOut = loweredOutput(1);
        parentID = this.sigRepository.add(this, runID,             ...
                                         ithOut.RootSource,        ...
                                         ithOut.TimeSource,        ...
                                         ithOut.DataSource,        ...
                                         ithOut.DataValues,        ...
                                         ithOut.BlockSource,       ...
                                         ithOut.ModelSource,       ...
                                         ithOut.SignalLabel,       ...
                                         int32(ithOut.TimeDim),    ...
                                         int32(ithOut.SampleDims), ...
                                         int32(ithOut.PortIndex),  ...
                                         int32(ithOut.Channel),    ...
                                         ithOut.SID,               ...
                                         [],                       ...
                                         [],                       ...
                                         ithOut.rootDataSrc); 

    end
           
    for i = 1:length(loweredOutput)
        if (max(size(loweredOutput)) > 1 && i == 1)
            continue;
        end
        % Cache ith output
        ithOut = loweredOutput(i);

        % Add to repository
        newSignalID = this.sigRepository.add(this, runID,              ...
                                             ithOut.RootSource,        ...
                                             ithOut.TimeSource,        ...
                                             ithOut.DataSource,        ...
                                             ithOut.DataValues,        ...
                                             ithOut.BlockSource,       ...
                                             ithOut.ModelSource,       ...
                                             ithOut.SignalLabel,       ...
                                             int32(ithOut.TimeDim),    ...
                                             int32(ithOut.SampleDims), ...
                                             int32(ithOut.PortIndex),  ...
                                             int32(ithOut.Channel),    ...
                                             ithOut.SID,               ...
                                             [],                       ...
                                             parentID,                 ...
                                             ithOut.rootDataSrc); 

        
        % Append to new IDs
        signalIDs = [signalIDs newSignalID];
    end % for
end