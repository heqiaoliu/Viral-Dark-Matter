function [errMsg, errType] = CacheAttribsAndRTO(this, hSignalSelectMgr)
%CacheAttribsAndRTO Get run-time object and cache attributes.
%  Get run-time object and basic Simulink signal attributes
%  Could throw an error.  Use AttachToModel method as the
%  driver to call this method.
%
%  Model must be running for this to return without error.
%
%  Returns an error message string, as appropriate.  No
%  error dialogs are launched.  errMsg is a string message.
%  errType is either 0 (connection failure) or 1 (attribute error).
%  Type 0 errors will disconnect data source, Type 1 will not.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/05/20 03:08:13 $

% Check that a single system handle has been selected
if numel(hSignalSelectMgr.getSystemHandle) ~= 1
    errMsg = 'All signals must originate from the same Simulink model';
    errType = 0;  % disconnect on error
    return
end

% Check if model is running
% Assumes scalar system handle
stat = hSignalSelectMgr.getSystemHandle.SimulationStatus;
if strcmpi(stat,'stopped'),
    % This code path won't normally happen, since this is not an error
    % for persistent connections - this method should only get called when
    % the model is running
    errMsg = 'Simulink model must be running or paused when connecting';
    errType = 1; % no disconnection when returning this error
    return
end

% Get runtime object info
%
[RTO_info,errMsg,errType] = getSignalRTO(this, hSignalSelectMgr);
if ~isempty(errMsg)
    return
end

% Aggregate all necessary signal attributes
%
errMsg = DeriveSignalInfo(this, RTO_info, hSignalSelectMgr);
if ~isempty(errMsg)
    % xxx float/persist: DeriveSignalInfo should return errType to classify
    %     the different types of errors it returns
    %
    errType = 0;  % disconnect on error
    return  % error occurred
end

% Check Simulink signal attributes
%
% Could be multiple signals, but we do guarantee
% that all attributes are identical coming out
% of DeriveVideoInfo
%
% We use RTO_info nevertheless, since it retains
% complexity info (attributes we won't retain in
% slSD, since we expect the signals to NOT have
% these attributes!  they're ERRORS...)
one_signal_info = RTO_info.sizes(1);
%
% Guard against continuous time
if one_signal_info.Ts(1) == 0
    errMsg = {'Continuous-time signals','are not supported.'};
    errType=1; % no disconnection when returning this error
    return
end
%
% Guard against complex data
if one_signal_info.cplx
    errMsg = {'Complex-valued signals','are not supported.'};
    errType=1; % no disconnection when returning this error
    return
end

% --------------------------------------------------------
function errMsg = DeriveSignalInfo(slSD, RTO_info, hSignalSelectMgr)
%
% Fields set in slSD:
%
%  .numComponents (scalar #)
%  .dtype      (string)
%  .dims       (vector dims)
%  .period     (scalar)
%  .rto        (vector of objects)
%  .portIdx (vector)
%
% If an error occurs, return with slSD properties set as follows:
%   errMsg = non-empty string
%   .numComponents=0
%
% Note:
%   This function will modify slSD.signalSelectObj.blkh
%   in order to merge multiple signals, as appropriate.

errMsg = '';

% Setup for return with failure:
slSD.numComponents = 0;

% Attempt to merge multiple signals into one signal
%
% Can only do this if the signals are 'simple' (non-bus)
% and all from the same block (how else to sort out R,G,B?)
%
% Sorts multiple signals into "predictable" order for
% color components
%
% Note: getSignalRTO already verifies identical
%       attributes within one signal
%
if RTO_info.numSignals > 1
    portIdx = hSignalSelectMgr.getPortIndices;
    [RTO_info,errMsg] = merge_multiple_signals(RTO_info,portIdx);
    if ~isempty(errMsg)
        return  % error occurred
    end
    % Note that RTO_info.driver now contains only one struct, not
    % an array of structs (that was the whole point of merge!)

    %
    % Now we fall-through to the "single signal" case
    %
end

% At this point, no matter what:
% just one signal remains, with possibly multiple components
%
if RTO_info.sizes.BusExpansion
    % One signal, bus expansion

    % Scalar-expand the portIdx, if bus-expansion
    N = numel(RTO_info.driver.rto{1});

    slSD.rto = RTO_info.driver.rto{1};
    
    % Scalar-expand the rto port index so that we have
    % one port index for each RTO --- even though they're
    % all the same port index here
    slSD.portIdx = RTO_info.driver.portIdx{1}(ones(N,1));
    
    slSD.numComponents = N;
    slSD.dtype  = RTO_info.sizes.dtype;
    slSD.dims   = RTO_info.sizes.dims;
    slSD.period = RTO_info.sizes.Ts(1);
%     slSD.blkh   = hSignalSelectMgr.getBlockHandle;  % RTO_info.driver.blkh{1}
else
    % One signal, no bus expansion
    % Handles single simple (single-component) signal
    %
    % Also handles output of bus creator block,
    %   (potentially a multi-component signal)
    %   which holds multiple RTO's in a cell-array of scalar rto's
    %   ditto for portIdx ... so we burst the cell-array and concat

    slSD.rto     = cat(1,RTO_info.driver.rto{:});
    slSD.portIdx = cat(1,RTO_info.driver.portIdx{:});
    
    % Must work for single-component intensity,
    % and multi-component non-bus (multi-signal select) color:
    %
    slSD.numComponents = numel(slSD.rto); % numel(RTO_info.driver.rto);
    
    slSD.dtype   = RTO_info.sizes.dtype;
    slSD.dims    = RTO_info.sizes.dims;
    slSD.period  = RTO_info.sizes.Ts(1);
end

% ------------------------------------------------------
function [y,errMsg] = merge_multiple_signals(RTO_info,portIdx)
% Attempt to merge multiple signals
%
% Returns updated RTO_info
% May change slSD as appropriate for merging signal info
%
% Types of RTO_info inputs that may appear here
%  1. Multiple non-bus signals
%  2. One or more bus (and zero or more non-bus) signals
%
% Types of inputs we allow
%  - multiple non-bus signals with identical attributes
%    and originating from the same graphical source
%    (actual non-virtual signal sources could differ)
%        (subset of case 1)
%    Sorts entries in RTO, etc, by port number for
%    predictable color component ordering
%
% Types of inputs for which we throw errors
%  - multiple non-bus signals with differing attributes
%        (subset of case 1)
%  - multiple distinct graphical block sources are selected
%        (could happen for case 1 or case 2)
%        (indeterminate assignment of color components)
%  - multiple drivers (busses) on at least one of multiple
%    selected signals
%        (case 2 - too darn complicated)
%
% Takes
%   RTO_info
%      .numSignals
%      .sizes
%      .driver
%
% Returns new RTO_info and updates slSD
%   RTO_info
%      .numSignals = 1 (guaranteed, if no error thrown)
%      .sizes  - scalar structure since there's only one signal now
%      .driver - (ditto)
%          .rto

y=[]; errMsg='';
Ndrivers = RTO_info.numSignals;

% If only 1 signal, nothing to do;
if Ndrivers == 1
    y = RTO_info;
    return
end

% At least 2 or more RTO's
%
% If any are busses, throw error since we cannot merge multiple distinct
% signals that are not all simple (non-bus) signals
%  
% If not all from same "source" (graphical) block, throw error
% Note that the actual (non-virtual) sources may still derive
%       from multiple distinct source blocks.
%
for i=2:Ndrivers
    if numel(RTO_info.driver(i).blkh)>1
        errMsg = 'Cannot merge multiple signals where one or more are signal busses';
        return
    end
end

% Update slSD (SLSignalData object)
%
% Sort port indices to get predictable color component order
% Source output ports could have been, say, port 1,2,3 
% But, they could be ports 2,3,4, or 1,5,6 ... could be anything
% We just presume the order is R,G,B (etc)
%
% Collect port indices
% - all from common originating block at this point
% - all are from non-bus signals (single port each)
%
[portIdx, sort_idx] = sort(portIdx);

% Check for common attributes and non-bus sources
%
first_sj = [];
for j = 1:RTO_info.numSignals
    % Get next driver signal attrib, in sort-order
    dj = RTO_info.driver(sort_idx(j));

    % get all rto into thisRTO
    thisRTO = [];
    thisIdx = [];
    thisBlkh = [];
    for i=1:numel(dj.rto)
        if numel(dj.rto{i})>1
            for n=1:numel(dj.rto{i})
                thisRTO = [thisRTO, dj.rto{i}(n)];  % could have been a muxed signal itself
            end
        else
            thisRTO = [thisRTO, dj.rto{i}];
        end
        thisIdx = [thisIdx, dj.portIdx{i}];
        thisBlkh = [thisBlkh, dj.blkh{i}];
    end       

    sj = RTO_info.sizes(sort_idx(j));
    
    % For 2nd and later signals, confirm that they have
    % identical characteristics:
    if j==1,
        % First component
        first_sj = sj;
        
        % Create initial output struct
        y.numSignals = RTO_info.numSignals; % consider N-signal selections
        y.driver = dj;
        y.sizes  = sj;
        
        % Clear out fields that no longer make sense after a merge
        %y.driver.blkh=[];
    else
        % Subsequent component
        if ~isequal(first_sj.dims, sj.dims)
            errMsg = 'Selected signals have different dimensions.';
        elseif ~isequal(first_sj.dtype, sj.dtype)
            errMsg = 'Selected signals have different data types.';
        elseif ~isequal(first_sj.Ts, sj.Ts)
            errMsg = 'Selected signals have different frame rates.';
        end
        if ~isempty(errMsg)
            y=[];
            return
        end
        % Update outputs
        y.driver.rto     = {cat(1, y.driver.rto{:}, thisRTO')};
        y.driver.portIdx = {cat(1, y.driver.portIdx{:}, thisIdx)};
        y.driver.blkh = {cat(1, y.driver.blkh{:}, thisBlkh)};
    end
end % j-loop



% [EOF]
