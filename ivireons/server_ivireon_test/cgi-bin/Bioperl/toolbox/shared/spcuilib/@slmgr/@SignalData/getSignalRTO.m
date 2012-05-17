function [SL_info, errMsg, errType] = getSignalRTO(this, hSignalSelectMgr)
%GETSIGNALRTO Setup run-time objects and return info struct.
%   Simulink model must be running for this to return without error.
%
%   Fields of info structure:
%         .numSignals: integer
%            Examples
%               N single-signals: N (for N signals selected)
%               1 bus: N (for N signals in bus)
%               1 bus-expansion: N (for N signals in expansion)
%
%         .drivers
%            .porth
%            .portIdx
%            .porttype:  string, 'outport','inport','trigger', etc
%            .blkh
%            .rto
%
%         .sizes(N)
%            .dims
%            .dtype
%            .cplx
%            .Ts
%
%   Returns non-empty errMsg string if error occurred.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/08 21:44:04 $

SL_info = [];
errType = 0;  % error type: 0=must disconnect, 1=leave connected

% Get array of runtime objects
%
%[driver,errMsg] = runtimeObjects(this.signalSelectObj);
[driver,errMsg] = runtimeObjects(hSignalSelectMgr);
if ~isempty(errMsg)
    errType = 0;  % 0=must disconnect
    return
end

% Gather info
%
numSignals = numel(driver);
for j=1:numSignals    % # separate signals user selected
    keep_info = [];
    dj = driver(j);
    
    % # components in this signal (is it a bus? > 1)
    numDrivers = numel(dj.rto);
    
    if numDrivers==0
        % Loop assignment will fail if numDrivers==0
        % ("keep" will be empty, sizes(j)=keep will fail)
        % And, if numDrivers==0, we lost our connection:
        errMsg = 'Driver block not found - disconnecting.';
        errType = 0;  % 0=must disconnect
        return
    end
    
    for i=1:numDrivers
        thisRTO = dj.rto{i};  % still may be a vector
        thisIdx = dj.portIdx{i};
        
        numD2=numel(thisRTO);
        if numD2==0
            % This situation should have been caught by the
            % call to RuntimeObjects.  We're double-checking
            % this here for no good reason:
            %
            errMsg = {'No data available for signal.  Consider turning off ', ...
                      'Block reduction optimization for the model.', ...
                      '', ...
                      'Block reduction optimization may be found in the model', ...
                      'Configuration Parameters dialog, under Optimizations.'};
            errType = 1;  % 1=leave connected
            return
        end
        
        for k=1:numD2
            % driving signal could be a mux/bus-expanded
            RTOk = thisRTO(k);
            hPort = OutputPort(RTOk, thisIdx);

            % Get characteristics
            sig_info.dims  = hPort.dimensions;
            sig_info.dtype = hPort.datatype;
            sig_info.cplx  = ~strcmpi(hPort.complexity,'real');
            % Guard against complex data
            if sig_info.cplx
                errMsg = {'Complex-valued signals','are not supported.'};
                errType=1; % no disconnection when returning this error
                return
            end
            % Guard against continuous time
            sig_info.Ts    = RTOk.SampleTimes;
            if sig_info.Ts(1) == 0
                errMsg = {'Continuous-time signals','are not supported.'};
                errType=1; % no disconnection when returning this error
                return
            end

            % For 2nd and later signals, confirm that they have
            % identical characteristics:
            if i==1
                sig_info.BusExpansion = (numD2>1);
                keep_info = sig_info;
            else % i>1
                if ~isequal(sig_info,keep_info),
                    errMsg = 'All driver signals must have identical attributes';
                    errType = 1;  % 1=leave connected                    
                    return
                end
            end
        end  % k-loop
    end % i-loop
    sizes(j) = keep_info; %#ok
end % j-loop

% Create return struct
%
SL_info.numSignals = numSignals;
SL_info.sizes      = sizes;
SL_info.driver     = driver;

% [EOF]
