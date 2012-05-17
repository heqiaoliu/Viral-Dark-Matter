function restoreTolerances( this, DataRunID, filename)

    % Copyright 2009-2010 The MathWorks, Inc.

    temp = load(filename);
    tsr = Simulink.sdi.SignalRepository;
    
    % exist() does not like structs, so have to use a try/catch
    try
        entry = temp.TolSave.Entry{1};
        if ~strcmp( entry.Key, 'global_tolerance')
            % This is an error: bad Tolerance file
            return;
        end
        if(isfield(entry, 'Content'))
            entry = entry.Content;
        end
        
        this.setToleranceDetailsByRun( int32(DataRunID), entry);
        
        for i = 2 : length( temp.TolSave.Entry)
            entry = temp.TolSave.Entry{i};
            if(isfield(entry, 'Content'))
                entry = entry.Content;
            end
            try
                dataObj = tsr.getSignal( entry.Key);
            catch
                if strcmp( entry.Key, this.GlobalToleranceKey)
                    this.setToleranceDetailsByRun(int32(DataRunID), entry);
                end
                % Probably need a warning here...
                continue;
            end
            
            this.setToleranceDetails( dataObj.DataID, entry);
        end
    catch ME
        rethrow(ME);
    end
end
