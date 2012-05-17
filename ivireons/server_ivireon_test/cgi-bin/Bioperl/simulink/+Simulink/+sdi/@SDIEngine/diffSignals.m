function result = diffSignals(this, LHSRunID, LHSSignalID, RHSRunID, RHSSignalID)

    % DIFFSIGNALS diff two signals from the same or two different runs.
    %
    % Copyright 2009-2010 The MathWorks, Inc.

    % Validate run IDs
    tsr = Simulink.sdi.SignalRepository;
    if ~tsr.isValidRunID(LHSRunID)
        DAStudio.error('SDI:sdi:InvalidRunID');
    end
    if ~tsr.isValidRunID(RHSRunID)
        DAStudio.error('SDI:sdi:InvalidRunID');
    end

    % Is RHS signal empty?
    IsRHSEmpty = isempty(RHSSignalID);

    % Validate signal IDs
    % Note: It is permissible to compare the LHS to nothing.
    %       This is the case of being aligned to nothing.
    if ~tsr.isValidSignalID(int32(LHSRunID), int32(LHSSignalID))
        DAStudio.error('SDI:sdi:InvalidSignalID');
    end
    if ~IsRHSEmpty && ~tsr.isValidSignalID(int32(RHSRunID), int32(RHSSignalID))
        DAStudio.error('SDI:sdi:InvalidSignalID');
    end

    % Resolve LHS signal object
    LHSSignalObj = tsr.getSignal(LHSSignalID);

    % Resolve RHS signal object
    if IsRHSEmpty
        RHSSignalObj = [];
    else
        RHSSignalObj = tsr.getSignal(RHSSignalID);
    end

    tol  = tsr.getTolerance(LHSSignalID);
    sync = tsr.getSyncOptions(LHSSignalID);

    % Create an DiffSignalResult object to store the
    % difference of two individual signals
    result = Simulink.sdi.DiffSignalResult;

    % Diff signals, if both available
    if ~IsRHSEmpty
        [result.Match, ...
         result.Diff,  ...
         result.Sync1, ...
         result.Sync2, ...
         result.Tol] = this.compare(LHSSignalObj.DataValues, ...
                                    RHSSignalObj.DataValues, ...
                                    'tolerance',    tol,     ...
                                    'syncoptions',  sync,    ...
                                    'outputs', {'match',     ...
                                                'diff',      ...
                                                'sync1',     ...
                                                'sync2',     ...
                                                'tol'});
    end

    % Attach meta data, RHS may be empty
    result.LHSSignalID  = LHSSignalID;
    result.RHSSignalID  = RHSSignalID;
    result.LHSSignalObj = LHSSignalObj;
    result.RHSSignalObj = RHSSignalObj;
end % diffSignals