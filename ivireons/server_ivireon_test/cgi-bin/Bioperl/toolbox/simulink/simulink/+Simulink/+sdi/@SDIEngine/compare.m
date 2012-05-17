function [varargout] = compare(ts1, ts2, varargin)

    % COMPARE compares two MATLAB timeseries objects.
    %
    % Basic Form
    % ----------
    % match = compare(timeseries1, timeseries2)
    %
    % In this basic form two timeseries objects are compared.  The function returns
    % TRUE if both timeseries objects match at each (time, value) point.  Otherwise,
    % the function returns false.
    %
    %
    % Absolute and Relative Tolerance Options
    % ---------------------------------------
    % match = compare(timeseries1, timeseries2, 'ABS', abstol, 'REL', reltol)
    %
    % In this form two timeseries objects are compared with an absolute ('ABS') and
    % relative ("REL") tolerance.  The function returns true if both timeseries
    % objects match at each time point and their values match per the tolerance
    % parameters specified.
    %
    % For example, assume the time vectors for timeseries1 and timeseries2 are
    % equivalent and pick arbitrary time "Ti".  Then assume the respective values
    % are:
    %
    %   "ts1Value", the timeseries1 value at Ti
    %   "ts2Value", the timeseries2 value at Ti;
    %
    % Then the two timeseries objects equal at time Ti if the following holds
    %
    %      max(abstol, reltol * ts1Value) <= |ts1Value - ts2Value|
    %
    %
    % Synchroization and Interpolation Options
    % ----------------------------------------
    % match = compare(timeseries1, timeseries2,               ...
    %                 'SynchronizeMethod', synchronizeMethod, ...
    %                 'InterpMethod',      interpMathod)
    %
    % In this form two timeseries objects are compared with a synchronization
    % method ('SynchronizeMethod') and an interpolation method ('InterpMethod').
    % The synchronization method can be one of the following:
    %
    %   'Union'        ? Resample timeseries objects using a time vector that is
    %                    a union of the time vectors of ts1 and ts2 on the time
    %                    range where the two time vectors overlap.
    %
    %   'Intersection' ? Resample timeseries objects on a time vector that is
    %                    the intersection of the time vectors of ts1 and ts2.
    %
    %   'Uniform'      ? Requires an additional 'Interval' argument.  This
    %                    method resamples time series on a uniform time vector,
    %                    where value 'Interval' specifies the time interval
    %                    between the two samples.  The uniform time vector is the
    %                    overlap of the time vectors of timeseries1 and
    %                    timeseries2.  The interval units are assumed to be the
    %                    smaller units of timeseries1 and timeseries2.
    %
    % The interpolation method can be one of the following:
    %
    %   'linear - Linear interpolation.
    %
    %   'zoh'   - zero-order hold
    %
    %
    % Output Options
    % --------------
    % [match diff sync1 sync2 tol] = compare(timeseries1, timeseries2, ...
    %                                        'OutputOptions',          ...
    %                                        {'match', 'diff',         ...
    %                                         'sync1', 'sync2', 'tol'})
    %
    % The compare function optionally returns details of the time series
    % comparison.  These details are specified through the 'OutputOptions'
    % parameter.  Options available are:
    %
    %   'match' - Do the two timeseries match.
    %
    %   'diff'  - Difference between timeseries1 and timeseries2 as a
    %             timeseries object.
    %
    %   'sync1' - timeseries1 after time synchronization applied.
    %
    %   'sync2' - timeseries2 after time synchronization applied.
    %
    %   'tol'   - Tolerance applied to value comparisons as a timeseries
    %             object.
    %
    % NOTE: Output data structures are not created unless requested.  Limiting
    %       use of output options reduces processing time and memory.
    %
    % Copyright 2009-2010 The MathWorks, Inc.

    % Output Initialization
    match = false;
    Diff  = [];
    Sync1 = [];
    Sync2 = [];
    Tol   = [];

    % Input initialization.
    validatedlReqOutputs = {'match'}; % Default output.
    tolStruct  = []; %tolerance structure
    syncStruct = []; % sync options structure

    % Internal state Initialization.
    validatedAbsTolVal  = []; % We validate type and value.
    validatedRelTolVal  = []; % We validate type and value.
    validatedSyncMtd    = []; % We validate its union, inter., or uniform.
    validatedInterval   = []; % We validate the interval for sync.
    validatedInterpMtd  = []; % We validate its linear or zoh.
    NumFixedArgs        = 2; % ts1 and ts2.
    legalOutputsInOrder = {'match', 'diff', 'sync1', 'sync2', 'tol'};
    
    % Validate the number of inputs.
    if nargin < 2
        DAStudio.error('SDI:sdi:NumInputMismatch');
    end

    % Validate Timeseries inputs.
    if( ~isa(ts1,'timeseries') && ~isa(ts2, 'timeseries') && ~isempty(ts1)...
         && ~isempty(ts2))
        DAStudio.error('SDI:sdi:ValidateTSInputs');
    end

    % Parse inputs
    paramCount = nargin - NumFixedArgs;
    paramIndex = 1;
    while(paramIndex <= paramCount)
        
        % Name-Values param
        nameParam = varargin{paramIndex};
        
        % Check that the name in the name-value pairs is a string.
        if(~ischar(nameParam))
            DAStudio.error('SDI:sdi:NameValPair');
        end
        
        % Check that the last value from the last name-value pair exist.
        if(paramIndex+1 > paramCount)
            DAStudio.error('SDI:sdi:MissingVal', nameParam);
        end
        
        % Name-Values param
        valueParam = varargin{paramIndex+1};
        
        % Set the inputs
        switch lower(nameParam)
            case 'abs'
                validatedAbsTolVal = ...
                    Simulink.sdi.Util.validateTolerance(valueParam);
            case 'rel'
                validatedRelTolVal = ...
                    Simulink.sdi.Util.validateTolerance(valueParam);
            case 'synchronizemethod'
                validatedSyncMtd = ...
                Simulink.sdi.Util.validateSyncMethod(valueParam);
            case 'interval'
                validatedInterval = ...
                    Simulink.sdi.Util.validateInterval(valueParam);
            case 'interpmethod'
                validatedInterpMtd = ...
                    Simulink.sdi.Util.validateInterpMethod(valueParam);
            case 'tolerance'
                tolStruct = valueParam; % error checking
            case 'syncoptions'
                syncStruct = valueParam; % error checking to be done
            case 'outputs'
                validatedlReqOutputs = validateOutputOption(valueParam,          ...
                                                            legalOutputsInOrder, ...
                                                            nargout);
            otherwise
                DAStudio.error('SDI:sdi:WrongName', nameParam);
        end
        paramIndex = paramIndex + 2;
    end % While

    % Quick check: Are the timeseries equal?
    % If Timeseries are equal, no need to synchronize. The code here will
    % check if the timeseries are equal before doing any expensive operation
    % such as timeseries synchronization.
    %
    % Note: when comparing timeseries, a short circuit comparison is done:
    % Check first the timeseries length before doing expensive isequal
    % operations. If lengths are not equal, then the timeseries are not equal
    % and the code will jump directly to the compare section.

    % Note: Using directly isequalwithequalnans is 1123 times faster on an
    % array of 4 millions elements than iterating over with a for loop.
    if (~isempty(ts1) && ~isempty(ts2))
        if (ts1.Length == ts2.Length ) && isequalwithequalnans(ts1, ts2)
            
            % Set the outputs:
            
            % Assign match as true. In this case, when the two timeseries are
            % identical, then the rest of the output arguments:
            % ('Diff', 'Sync1', 'Sync2','Tol')are
            % passed as empty to save memory, e.g. when they are identical having a
            % Diff timeseries with 100.000 "zeros" uses to much unnecessary
            % memory.
            match = true;
            
        else
            
            % Start the synchonization
            
            % If the user passed a absTol name-value pair and a name-value
            % criterion, then the absTol name-value will be used for tolerance.
            if  (   ~isempty(validatedAbsTolVal) ...
                    || ~isempty(validatedRelTolVal) ...
                    ) ...
                    && ~isempty(tolStruct)
                DAStudio.warning('SDI:sdi:PassedTolAndCriterion');
            end
            
            if isempty(tolStruct)
                [tolStruct,~] = Simulink.sdi.SDIEngine.defaultTolAndSyncOptions();
            end
            
            if isempty(syncStruct)
                [~,syncStruct] = Simulink.sdi.SDIEngine.defaultTolAndSyncOptions();
            end
            
            % Get the interpolation method.
            if isempty(validatedInterpMtd)
                tsInterpMethod = syncStruct.InterpMethod;
            else
                tsInterpMethod = validatedInterpMtd;
            end
            
            % Assign interpolation method.
            ts1.DataInfo.Interpolation = tsdata.interpolation(tsInterpMethod);
            ts2.DataInfo.Interpolation = tsdata.interpolation(tsInterpMethod);
            
            % If the user did not passed a absTol/rel name-value pair, then use the
            % criterion tolerances.
            if isempty(validatedAbsTolVal)
                validatedAbsTolVal = tolStruct.absolute;
            end
            if isempty(validatedRelTolVal)
                validatedRelTolVal = tolStruct.relative;
            end
            
            % Define the sync Options.
            if isempty(validatedSyncMtd)
                tsSyncMethod = syncStruct.SyncMethod;
            else
                tsSyncMethod = validatedSyncMtd;
            end
            
            if strcmpi(tsSyncMethod, 'Uniform')
                validatedInterval = syncStruct.UniformTimeInterval;
                % Check that an interval was passed.
                if( isempty(validatedInterval) )
                    DAStudio.error('SDI:sdi:EmptyInterval');
                else
                    % Synchronize.
                    [Sync1 Sync2] = synchronize(ts1, ts2, tsSyncMethod,...
                                                'Interval', validatedInterval);
                end
            else
                % Synchronize.
                [Sync1 Sync2] = synchronize(ts1, ts2, tsSyncMethod);
            end
            
            % Clear unused data to save memory.
            ts1 = [];%#ok<NASGU>
            ts2 = [];%#ok<NASGU>
                                    
            % complex arithmetic on integers not supported
            if ~isreal(Sync1.data) && isinteger(Sync1.data)
                Sync1.data = single(Sync1.data);
                if isinteger(Sync2.data)
                    Sync2.data = single(Sync2.data); 
                end
            end
            
            if ~isreal(Sync2.data) && isinteger(Sync2.data)
               Sync2.data = single(Sync2.data); 
               if isinteger(Sync1.data)
                    Sync1.data = single(Sync1.data); 
               end
            end
            
            % integers can be compared only with integers            
            if (isinteger(Sync1.data) ...
                && ~strcmp(class(Sync1.data), class(Sync2.data)))
                Sync1.data = single(Sync1.data);      
            end
            
            if (isinteger(Sync2.data) ...
                && ~strcmp(class(Sync1.data), class(Sync2.data)))
                Sync2.data = single(Sync2.data);      
            end                    
            
            % Compare.
            DiffData = Sync1.data - Sync2.data;
            % Note: max performs a scalar expansion when a scalar and
            %       a vector ispassed.
            TolData = max(validatedAbsTolVal, validatedRelTolVal * Sync1.data);
            
            % Element wise comparison. e.g. [4 2 4]>=[3 3 3] produces [ 1 0 1 ]
            % If all elements are equal then the condition is true.
            if TolData >= abs(DiffData)
                match = true;
            end
            
            % TimeSeries are being created for differences and tolerances
            % If they are not requested in the outputs, no need to calculate them.
            % Check that diff is specified in the outputs before calculating it.
            doCalc = any(ismember(validatedlReqOutputs, 'diff'));
            if doCalc
                Diff = timeseries(DiffData, Sync1.time);
            end
            
            % Check that diff is specified in the outputs before calculating it.
            doCalc = any(ismember(validatedlReqOutputs, 'tol'));
            if doCalc
                Tol = timeseries(TolData, Sync1.time);
            end
            
        end % if isequal length
    end

    % Set the Outputs

    % Default behavior:
    % Used when no output arguments are passed (the "output" option)
    varargout{1} = match;

    % Custom behavior:
    % When outputs argutment are passed(the "output" option).
    % Note: Outputs are sorted in alphabetical order(via unique).
    % Keep the output order as:
    % 'match','diff','sync','sync','tol'
    % Note: ismember(A, S) returns an array the same size as A, containing
    % logical 1 (true) where the elements of A are in the set S, and logical
    % 0 (false) elsewhere.
    legalIndexArray       = ismember(legalOutputsInOrder, validatedlReqOutputs);
    legalRequestedOutputs = legalOutputsInOrder(legalIndexArray);

    for i = 1 : length(legalRequestedOutputs)
        % Note: There is no "other" case, and there is no need for one.
        % The array is already validate.
        switch legalRequestedOutputs{i}
            case 'match', varargout{i} = match;
            case 'diff',  varargout{i} = Diff;
            case 'sync1', varargout{i} = Sync1;
            case 'sync2', varargout{i} = Sync2;
            case 'tol',   varargout{i} = Tol;
        end
    end
end % compare

% Validate outputs options
function validatedOutputOpts = validateOutputOption(value,               ...
                                                   legalOutputsInOrder, ...
                                                   nargoutVal)
    
    % Initialize Outputs.
    validatedOutputOpts = {'match'};%#ok<NASGU>
    
    if iscell(value)
        % Make sure to avoid dups use unique. Unique also sorts it in
        % alphabetical order.
        validatedOutputOpts = lower(unique(value));
        
        % Check that the number of outputs matches the number specified
        % in the "outputs" option.
        if ~isequal(nargoutVal,length(validatedOutputOpts))
            DAStudio.error('SDI:sdi:ValidateNumOfOutputs');
        end
        
        % Check that the outputs parameters are one of this:
        % {'booleanMatch', 'Diff', 'Sync1', 'Sync2', 'Tol'}
        % otherwise error.
        strMsg = '';
        for j = 1 : length(validatedOutputOpts)
            if ~ismember(legalOutputsInOrder,  validatedOutputOpts{j})
                strMsg = [strMsg validatedOutputOpts{j} ' '];
            end
        end
        if ~isempty(strMsg)
            DAStudio.error('SDI:sdi:NonMemberOutputs', strMsg);
        end
        
    % If the output is not a cell
    else
        DAStudio.error('SDI:sdi:ValidateDataType', 'outputs', 'cell');
    end %if
end % validateOutputOption

% If not instructed otherwise, this is how SDI
% aligns and compares two signals
function [tolStruct, syncStruct] = defaultTolAndSyncOptions()
    tolStruct.toleranceType        = 0;
    tolStruct.absolute             = 0;
    tolStruct.relative             = 0;
    tolStruct.timeStart            = 0;
    tolStruct.timeEnd              = 0;
    tolStruct.timeStep             = 0;
    tolStruct.initAbsTolVal        = 0;
    tolStruct.absStep              = 0;
    tolStruct.initRelTolVal        = 0;
    tolStruct.relStep              = 0;
    tolStruct.fcnCall              = '' ;
    syncStruct.SyncMethod          = 'union';
    syncStruct.InterpMethod        = 'zoh';
    syncStruct.UniformTimeInterval = 0.0100;
    syncStruct.customSyncMethod    = '';
    syncStruct.syncType            = 0;
end