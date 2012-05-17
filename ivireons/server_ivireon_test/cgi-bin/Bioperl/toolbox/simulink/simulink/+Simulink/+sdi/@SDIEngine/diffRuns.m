function diffRuns(this, lhsRunID, rhsRunID, varargin)

    % DIFFRUNS diff two runs
    %
    % Copyright 2009-2010 The MathWorks, Inc.

    % Cache convenience variable
    drr = this.DiffRunResult;
    
    % Clear any prior results
    drr.clear();

    % Validate run IDs

    tsr = Simulink.sdi.SignalRepository;
    if ~tsr.isValidRunID(lhsRunID)
        DAStudio.error('SDI:sdi:InvalidRunID');
    end
    if ~tsr.isValidRunID(rhsRunID)
        DAStudio.error('SDI:sdi:InvalidRunID');
    end

    % Align the two runs
    this.AlignRuns.clear();
    this.AlignRuns.setLHSDataRunID(lhsRunID);
    this.AlignRuns.setRHSDataRunID(rhsRunID);
    
    if nargin > 3
        algorithms = varargin{1};
    else
        algorithms = [Simulink.sdi.AlignType.BlockPath
                      Simulink.sdi.AlignType.DataSource
                      Simulink.sdi.AlignType.SID
                      Simulink.sdi.AlignType.SignalName];
    end
    szAlgos = max(size(algorithms));
    this.AlignRuns.applyUnset
    for i = 1:szAlgos
        switch algorithms(i)
            case Simulink.sdi.AlignType.DataSource
                this.AlignRuns.applyDataSrc();
            case Simulink.sdi.AlignType.BlockPath
                this.AlignRuns.applyPath();
            case Simulink.sdi.AlignType.SID
                this.AlignRuns.applySID();            
            case Simulink.sdi.AlignType.SignalName
                this.AlignRuns.applySignal();
        end                    
    end

    % Set IDs of two runs to be compared
    drr.setLHSDataRunID(lhsRunID);
    drr.setRHSDataRunID(rhsRunID);

    for i = 1 : this.AlignRuns.getCount()
        % Get the ID of the ith LHS and RHS signals
        LHSSignalID = this.AlignRuns.getLHSValueByIndex(i);
        RHSSignalID = this.AlignRuns.getRHSValueByIndex(i);

        % Diff Signals and create DiffSignalResult object
        dsr = this.diffSignals(lhsRunID, LHSSignalID, ...
                               rhsRunID, RHSSignalID);

        % Archive signal difference results
        drr.addResult(dsr);
    end % for

end % diffRuns