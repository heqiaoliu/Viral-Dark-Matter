classdef combinedjitter <  sigutils.sorteddisp & sigutils.pvpairs ...
        & dynamicprops & sigutils.SaveLoad
%COMBINEDJITTER Construct a combined jitter generator object
%   H = COMMSRC.COMBINEDJITTER constructs a default combined jitter generator
%   object H.
%
%   A combined jitter generator object has the following properties.  All the
%   properties are writable unless explicitly stated otherwise.
%
%   Property Name         Description
%   ----------------------------------------------------------------------------
%   Type                - 'Combined Jitter Generator'.  This is a read-only
%                         property.
%   RandomJitter        - Flag to determine if the random jitter generator is
%                         active
%   RandomStd           - Standard deviation of the random jitter in seconds 
%   PeriodicJitter      - Flag to determine if the random jitter generator is
%                         active
%   PeriodicNumber      - Number of sinusoidal components
%   PeriodicAmplitude   - Amplitude of each sinusoidal component of the periodic
%                         jitter in symbol seconds 
%   PeriodicFrequency   - Frequency of each sinusoidal component of the periodic
%                         jitter in Hz
%   PeriodicPhase       - Phase of each sinusoidal component of the periodic
%                         jitter
%   DiracJitter         - Flag to determine if the random jitter generator is
%                         active
%   DiracNumber         - Number of Dirac components
%   DiracDelta          - Time delay of each Dirac component in seconds 
%   DiracProbability    - Probability of each Dirac component.  Sum must be one.
%
%   H = COMMSRC.COMBINEDJITTER constructs a combined jitter generator object H
%   with default properties and is equivalent to:
%   H = COMMSRC.COMBINEDJITTER('RandomJitter', 'off', ...
%                              'PeriodicJitter', 'off', ...
%                              'DiracJitter', 'off')
%   When activated, individual jitter generators have the following default
%   values:
%   H = COMMSRC.COMBINEDJITTER('RandomJitter', 'on', ...
%                              'RandomStd', 1e-4, ...
%                              'PeriodicJitter', 'on', ...
%                              'PeriodicNumber, 1, ...
%                              'PeriodicAmplitude', 5e-4, ...
%                              'PeriodicFrequency', 2, ...
%                              'PeriodicPhase', 0, ...
%                              'DiracJitter', 'on', ...
%                              'DiracNumber', 2, ...
%                              'DiracDelta', [-5e-4 5e-4], ...
%                              'DiracProbability', [0.5 0.5])
%
%   commsrc.combinedjitter methods:
%     generate - Generate jitter samples for a combination of jitter types
%     reset    - Reset the internal states of the combined jitter generator
%     disp     - Display combined jitter generator object properties
%
%   To get detailed help on a method from the command line, type 'help
%   commsrc.combinedjitter/<METHOD>', where METHOD is on of the methods listed
%   above. For instance, 'help commsrc.combinedjitter/generate'.
%
%   Examples:
%
%     % Construct a Dual-Dirac jitter generator with two components at time
%     % delay values -1e-4 and 1e-4 seconds, and with 0.2 and 0.8 probabilities,
%     % respectively.  The random jitter component should have a standard
%     % deviation of 1 milliseconds.  
%     h = commsrc.combinedjitter('RandomJitter', 'on', ...
%                                'RandomStd', 1e-3, ...
%                                'DiracJitter', 'on', ...
%                                'DiracNumber', 2, ...
%                                'DiracDelta', [-1e-4 1e-4], ...
%                                'DiracProbability', [0.2 0.8])
%
%   See also COMMSRC, COMMSRC.COMBINEDJITTER/GENERATE,
%   COMMSRC.COMBINEDJITTER/RESET, COMMSRC.COMBINEDJITTER/DISP,
%   COMMSRC.COMBINEDJITTER/SETSYMBOLRATE, COMMSRC.COMBINEDJITTER/GETSYMBOLRATE,
%   COMMSRC.RANDOMJITTER, COMMSRC.PERIODICJITTER,  COMMSRC.DIRACJITTER.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2008/10/31 05:54:21 $

    %===========================================================================
    % Public properties
    properties
        % State of the random jitter generator.
        RandomJitter = 'off';
        % State of the periodic jitter generator.
        PeriodicJitter = 'off';
        % State of the periodic jitter generator.
        DiracJitter = 'off';
    end

    %===========================================================================
    % Protected properties
    properties (SetAccess = protected)
        Type;   % Type of the class.  Read-only property.  Must be set at the 
                % construction time by the subclass.
    end

    %===========================================================================
    % Protected properties
    properties (SetAccess = protected, GetAccess = protected)
        % State of the random jitter generator in Boolean.
        RandomState = 0;
        % State of the periodic jitter generator in Boolean.
        PeriodicState = 0;
        % State of the periodic jitter generator in Boolean.
        DiracState = 0;
        % Handle of the random jitter generator.
        RandomJitterGen
        % Handle of the periodic jitter generator.
        PeriodicJitterGen
        % Handle of the periodic jitter generator.
        DiracJitterGen
        % Assumed symbol rate of the target signal.  This value is used to
        % convert seconds into symbol durations.
        SymbolRate = 100;
    end

    %===========================================================================
    % Public methods
    methods
        function this = combinedjitter(varargin)
            % Constructor for Dirac jitter generator class.

            % Set the type property
            this.Type = 'Combined Jitter Generator';

            % Initialize jitter generators
            this.RandomJitterGen = commsrc.randomjitter;
            this.PeriodicJitterGen = commsrc.periodicjitter;
            this.DiracJitterGen = commsrc.diracjitter;

            % Add dynamic properties for random jitter
            p = this.addprop('RandomStd');
            p.SetMethod = @setRandomStd;
            p.GetMethod = @getRandomStd;
            p.SetAccess = 'protected';
            p.GetAccess = 'protected';

            % Add dynamic properties for periodic jitter
            p = this.addprop('PeriodicNumber');
            p.SetMethod = @setPeriodicNumber;
            p.GetMethod = @getPeriodicNumber;
            p.SetAccess = 'protected';
            p.GetAccess = 'protected';

            p = this.addprop('PeriodicAmplitude');
            p.SetMethod = @setPeriodicAmplitude;
            p.GetMethod = @getPeriodicAmplitude;
            p.SetAccess = 'protected';
            p.GetAccess = 'protected';

            p = this.addprop('PeriodicFrequency');
            p.SetMethod = @setPeriodicFrequency;
            p.GetMethod = @getPeriodicFrequency;
            p.SetAccess = 'protected';
            p.GetAccess = 'protected';

            p = this.addprop('PeriodicPhase');
            p.SetMethod = @setPeriodicPhase;
            p.GetMethod = @getPeriodicPhase;
            p.SetAccess = 'protected';
            p.GetAccess = 'protected';

            % Add dynamic properties for Dirac jitter
            p = this.addprop('DiracNumber');
            p.SetMethod = @setDiracNumber;
            p.GetMethod = @getDiracNumber;
            p.SetAccess = 'protected';
            p.GetAccess = 'protected';

            p = this.addprop('DiracDelta');
            p.SetMethod = @setDiracDelta;
            p.GetMethod = @getDiracDelta;
            p.SetAccess = 'protected';
            p.GetAccess = 'protected';

            p = this.addprop('DiracProbability');
            p.SetMethod = @setDiracProbability;
            p.GetMethod = @getDiracProbability;
            p.SetAccess = 'protected';
            p.GetAccess = 'protected';

            if nargin
                % There are input arguments, so initialize with property-value
                % pairs.  Note that, we do not need to explicitly call
                % calcPulse, since it will be called when a property is changed.
                initPropValuePairs(this, varargin{:});
            end
        end
        %-----------------------------------------------------------------------
        function jitter = generate(this, N)
%GENERATE  Generate combined jitter samples
%   JITTER = GENERATE(H, N) generates N samples of combined jitter based on the
%   combined jitter generator object H.
%
%   See also COMMSRC.COMBINEDJITTER, COMMSRC.COMBINEDJITTER/RESET,
%   COMMSRC.COMBINEDJITTER/DISP, COMMSRC.COMBINEDJITTER/SETSYMBOLRATE,
%   COMMSRC.COMBINEDJITTER/GETSYMBOLRATE. 

            jitter = zeros(N, 1);

            % If random jitter is active, generate random jitter samples and add
            % to the combined jitter.
            if ( this.RandomState )
                dummy = generate(this.RandomJitterGen, N);
                jitter = jitter + dummy;
            end
            % If random jitter is active, generate periodic jitter samples and
            % add to the combined jitter.
            if ( this.PeriodicState )
                dummy = generate(this.PeriodicJitterGen, N);
                jitter = jitter + dummy;
            end
            % If random jitter is active, generate Dirac jitter samples and add
            % to the combined jitter.
            if ( this.DiracState )
                dummy = generate(this.DiracJitterGen, N);
                jitter = jitter + dummy;
            end
            
            % Convert jitter values from symbol durations to seconds
            jitter = jitter / this.SymbolRate;

        end

        %-----------------------------------------------------------------------
        function reset(this)
%RESET  Reset combined jitter object internal states
%   RESET(H) resets the internal states of the combined jitter generator object
%   H.
%
%   See also COMMSRC.COMBINEDJITTER, COMMSRC.COMBINEDJITTER/GENERATE,
%   COMMSRC.COMBINEDJITTER/DISP, COMMSRC.COMBINEDJITTER/SETSYMBOLRATE,
%   COMMSRC.COMBINEDJITTER/GETSYMBOLRATE. 
            if ~this.IsLoading_
                reset(this.PeriodicJitterGen);
            end
        end
    end

    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function sortedList = getSortedPropDispList(this)
            % Return the list of properties in the order they chould be
            % displayed.

            sortedList = {...
                'Type', ...
                'RandomJitter'};
            if this.RandomState
                sortedList = [sortedList {'RandomStd'}];
            end
            sortedList = [sortedList {'PeriodicJitter'}];
            if this.PeriodicState
                sortedList = [sortedList {'PeriodicNumber', ...
                    'PeriodicAmplitude', ...
                    'PeriodicFrequency', ...
                    'PeriodicPhase'}];
            end
            sortedList = [sortedList {'DiracJitter'}];
            if this.DiracState
                sortedList = [sortedList {'DiracNumber',...
                    'DiracDelta', ...
                    'DiracProbability'}];
            end
        end
        %-----------------------------------------------------------------------
        function s = localSaveobj(this)
            % localSaveobj return a structure of protected data to be saved

            mc = metaclass(this);
            props = mc.Properties;

            % Add all protected properties
            s = struct;
            for p=1:length(props)
                pr = props{p};
                if (strcmp(pr.SetAccess, 'protected') ...
                        || strcmp(pr.GetAccess, 'protected'))
                    s.(pr.Name) = this.(pr.Name);
                end
            end
            
            % Add dynamic properties
            s.RandomStd = this.RandomStd;
            s.PeriodicNumber = this.PeriodicNumber;
            s.PeriodicAmplitude = this.PeriodicAmplitude;
            s.PeriodicFrequency = this.PeriodicFrequency;
            s.PeriodicPhase = this.PeriodicPhase;
            s.DiracNumber = this.DiracNumber;
            s.DiracDelta = this.DiracDelta;
            s.DiracProbability = this.DiracProbability;
        end
        %-----------------------------------------------------------------------
        function this = localLoadobj(this, s)
            % localLoadobj load protected or any other data
            props = fieldnames(s);
            for p=1:length(props)
                set(this, props{p}, s.(props{p}));
            end
        end
    end

    %===========================================================================
    % Set/Get methods
    methods
        function set.RandomJitter(this, state)
            % Check for validity
            sigdatatypes.checkOnOff(this, 'RandomJitter', state);

            % If state is a different value than the current value
            if ~strncmpi(state, this.RandomJitter, 2)
                if strncmpi(state, 'on', 2)
                    % Activate the random jitter generator.
                    this.RandomState = 1;

                    % We need to make the RandomStd property public.
                    p = findprop(this, 'RandomStd');
                    p.SetAccess = 'public';
                    p.GetAccess = 'public';
                else
                    % Deactivate the random jitter generator.
                    this.RandomState = 0;

                    % We need to make the RandomStd property protected.
                    p = findprop(this, 'RandomStd');
                    p.SetAccess = 'protected';
                    p.GetAccess = 'protected';
                end
                % Set the property
                this.RandomJitter = state;
            end
        end
        %-----------------------------------------------------------------------
        function set.PeriodicJitter(this, state)
            % Check for validity
            sigdatatypes.checkOnOff(this, 'PeriodicJitter', state);

            % If state is a different value than the current value
            if ~strncmpi(state, this.PeriodicJitter, 2)
                if strncmpi(state, 'on', 2)
                    % Activate the periodic jitter generator.
                    this.PeriodicState = 1;

                    % We need to make the PeriodicNumber, PeriodicAmplitude,
                    % PeriodicFrequency, and PeriodicPhase properties public.
                    p = findprop(this, 'PeriodicNumber');
                    p.SetAccess = 'public';
                    p.GetAccess = 'public';

                    p = findprop(this, 'PeriodicAmplitude');
                    p.SetAccess = 'public';
                    p.GetAccess = 'public';

                    p = findprop(this, 'PeriodicFrequency');
                    p.SetAccess = 'public';
                    p.GetAccess = 'public';

                    p = findprop(this, 'PeriodicPhase');
                    p.SetAccess = 'public';
                    p.GetAccess = 'public';
                else
                    % Deactivate the periodic jitter generator.
                    this.PeriodicState = 0;

                    % We need to make the PeriodicNumber, PeriodicAmplitude,
                    % PeriodicFrequency, and PeriodicPhase properties protected.
                    p = findprop(this, 'PeriodicNumber');
                    p.SetAccess = 'protected';
                    p.GetAccess = 'protected';

                    p = findprop(this, 'PeriodicAmplitude');
                    p.SetAccess = 'protected';
                    p.GetAccess = 'protected';

                    p = findprop(this, 'PeriodicFrequency');
                    p.SetAccess = 'protected';
                    p.GetAccess = 'protected';

                    p = findprop(this, 'PeriodicPhase');
                    p.SetAccess = 'protected';
                    p.GetAccess = 'protected';
                end
                % Set the property
                this.PeriodicJitter = state;
            end
        end
        %-----------------------------------------------------------------------
        function set.DiracJitter(this, state)
            % Check for validity
            sigdatatypes.checkOnOff(this, 'DiracJitter', state);

            % If state is a different value than the current value
            if ~strncmpi(state, this.DiracJitter, 2)
                if strncmpi(state, 'on', 2)
                    % Activate the Dirac jitter generator.
                    this.DiracState = 1;

                    % We need to make the DiracNumber, DiracDelta,
                    % DiracProbability properties public.
                    p = findprop(this, 'DiracNumber');
                    p.SetAccess = 'public';
                    p.GetAccess = 'public';

                    p = findprop(this, 'DiracDelta');
                    p.SetAccess = 'public';
                    p.GetAccess = 'public';

                    p = findprop(this, 'DiracProbability');
                    p.SetAccess = 'public';
                    p.GetAccess = 'public';
                else
                    % Deactivate the periodic jitter generator.
                    this.DiracState = 0;

                    % We need to make the DiracNumber, DiracDelta,
                    % DiracProbability properties protected.
                    p = findprop(this, 'DiracNumber');
                    p.SetAccess = 'protected';
                    p.GetAccess = 'protected';

                    p = findprop(this, 'DiracDelta');
                    p.SetAccess = 'protected';
                    p.GetAccess = 'protected';

                    p = findprop(this, 'DiracProbability');
                    p.SetAccess = 'protected';
                    p.GetAccess = 'protected';
                end
                % Set the property
                this.DiracJitter = state;
            end
        end
        %-----------------------------------------------------------------------
        function setSymbolRate(this, value)
%SETSYMBOLRATE  Set the symbol rate of the combined jitter generator
%   SETSYMBOLRATE(H, RS) Set the symbol rate of the combined jitter generator
%   object H to RS.  Symbol rate information is used to convert jitter
%   parameters from seconds to symbol durations.
%
%   See also COMMSRC.COMBINEDJITTER, COMMSRC.COMBINEDJITTER/GENERATE,
%   COMMSRC.COMBINEDJITTER/RESET, COMMSRC.COMBINEDJITTER/DISP,
%   COMMSRC.COMBINEDJITTER/GETSYMBOLRATE.

            % Update the protected jitter generator objects' properties to keep
            % the values in seconds the same.  Note that the jitter generator
            % objects' properties are defined in terms symbol duration.

            % Check for validity
            sigdatatypes.checkFinitePosDblScalar(this, 'SymbolRate', value);

            % First store all the properties that needs to be converted.
            periodicFrequency = getPeriodicFrequency(this);
            periodicAmplitude = getPeriodicAmplitude(this);
            diracDelta = getDiracDelta(this);
            randomStd = getRandomStd(this);

            % Update the symbol rate
            this.SymbolRate = value;

            % Try to set the jitter parameters maintaining the values in seconds
            % the same.  If an exception occurs, it measn that the new symbol
            % rate resulted in an unrealizable jitter value.  This condition
            % occurs if the symbol rate increases, causing the symbol duration
            % to become small as compared to the jitter values.  We need to set
            % the jitter parameter to a realizable value and warn the user about
            % this change. 
            try 
                % Set the periodic frequency with the new symbol rate
                setPeriodicFrequency(this, periodicFrequency);
                % Set the periodic amplitude with the new symbol rate
                setPeriodicAmplitude(this, periodicAmplitude);
            catch exception
                % Exception occurred.  Warn the user and set the maximum value to
                % 1/10th the symbol duration.
                periodicAmplitude = (1/(10*value))*...
                    (periodicAmplitude/max(periodicAmplitude));
                setPeriodicAmplitude(this, periodicAmplitude);
                if this.PeriodicState
                    warning(exception.identifier, ['The symbol rate is too '...
                        'high to realize the specified periodic jitter.  '...
                        'Resetting the periodic jitter amplitude to a '...
                        'realizable value.']);
                end
            end
            try 
                % Set the Dirac delta with the new symbol rate
                setDiracDelta(this, diracDelta);
            catch exception
                % Exception occurred.  Warn the user and set the maximum
                % separation will be 1/10th the symbol duration.
                maxSep = max(diracDelta) - min(diracDelta);
                diracDelta = (1/(10*value)) * (diracDelta/maxSep);
                setDiracDelta(this, diracDelta);
                if this.DiracState
                    warning(exception.identifier, ['The symbol rate is too '...
                        'high to realize the specified Dirac jitter.  '...
                        'Resetting the Dirac jitter delta to a realizable '...
                        'value.']);
                end
            end
            
            % Turn the StdTooLarge warning off, store the last warning, and
            % reset the last warning
            warnState = warning('off', 'comm:commsrc:randomjitter:StdTooLarge');
            [lastWarnMsg, lastWarnId] = lastwarn;
            lastwarn('');

            % Set the random standard deviation with the new symbol rate
            setRandomStd(this, randomStd);
            
            % Check if there was a warning.
            [warnMsg, warnId] = lastwarn; %#ok<ASGLU>
            if strncmp(warnId, 'comm:commsrc:randomjitter:StdTooLarge', 36)
                % Warning occurred.  Warn the user.

                % Restore the warning state
                warning(warnState);
                
                % Display warning only if the random jitter is enabled
                if this.RandomState
                    warning(warnId, ['The symbol rate may be too '...
                        'high to realize the specified random jitter.']);
                else
                    % Restore the last warning
                    lastwarn(lastWarnMsg, lastWarnId);
                end
            else
                % Restore the warning state and last warning
                lastwarn(lastWarnMsg, lastWarnId);
                warning(warnState);
            end
        end
        %-----------------------------------------------------------------------
        function value = getSymbolRate(this)
%GETSYMBOLRATE  Get the symbol rate of the combined jitter generator
%   RS = GETSYMBOLRATE(H) returns the symbol rate, RS, of the combined jitter
%   generator object H.  Symbol rate information is used to convert jitter
%   parameters from seconds to symbol durations.
%
%   See also COMMSRC.COMBINEDJITTER, COMMSRC.COMBINEDJITTER/GENERATE,
%   COMMSRC.COMBINEDJITTER/RESET, COMMSRC.COMBINEDJITTER/DISP,
%   COMMSRC.COMBINEDJITTER/SETSYMBOLRATE.

            value = this.SymbolRate;
        end
    end
end

%===========================================================================
% Set/Get methods for dynamic properties

function setRandomStd(this, value)
% RandomStd is a phantom property of the underlying
% commsrc.randomjitter object's Std property.  This function directs
% the set request to the jitter generator object after converting
% the value from seconds to samples.
this.RandomJitterGen.Std = value*this.SymbolRate;
end

%-----------------------------------------------------------------------
function value = getRandomStd(this)
% RandomStd is a phantom property of the underlying
% commsrc.randomjitter object's Std property.  This function directs
% the get request to the pulse generator object and converts the
% value from samples to seconds.
value = this.RandomJitterGen.Std/this.SymbolRate;
end

%-----------------------------------------------------------------------
function setPeriodicNumber(this, value)
% PeriodicNumber is a phantom property of the underlying
% commsrc.periodicjitter object's NumberOfComponents property.  This
% function directs the set request to the jitter generator object.
this.PeriodicJitterGen.NumberOfComponents = value;
end

%-----------------------------------------------------------------------
function value = getPeriodicNumber(this)
% PeriodicNumber is a phantom property of the underlying
% commsrc.periodicjitter object's NumberOfComponents property.  This
% function directs the get request to the jitter generator object.
value = this.PeriodicJitterGen.NumberOfComponents;
end

%-----------------------------------------------------------------------
function setPeriodicAmplitude(this, value)
% PeriodicAmplitude is a phantom property of the underlying
% commsrc.periodicjitter object's Amplitude property.  This function
% directs the set request to the jitter generator object after
% converting the value from seconds to samples.
this.PeriodicJitterGen.Amplitude = value*this.SymbolRate;
end

%-----------------------------------------------------------------------
function value = getPeriodicAmplitude(this)
% PeriodicAmplitude is a phantom property of the underlying
% commsrc.periodicjitter object's Amplitude property.  This function
% directs the get request to the jitter generator object and
% converts the value from samples to seconds.
value = this.PeriodicJitterGen.Amplitude/this.SymbolRate;
end

%-----------------------------------------------------------------------
function setPeriodicFrequency(this, value)
% PeriodicFrequency is a phantom property of the underlying
% commsrc.periodicjitter object's Frequency property.  This function
% directs the set request to the jitter generator object after
% converting the value from seconds to symbol durations.
this.PeriodicJitterGen.Frequency = value/this.SymbolRate;
end

%-----------------------------------------------------------------------
function value = getPeriodicFrequency(this)
% PeriodicFrequency is a phantom property of the underlying
% commsrc.periodicjitter object's Frequency property.  This function
% directs the get request to the jitter generator object and
% converts the value from symbol durations to seconds.
value = this.PeriodicJitterGen.Frequency*this.SymbolRate;
end

%-----------------------------------------------------------------------
function setPeriodicPhase(this, value)
% PeriodicPhase is a phantom property of the underlying
% commsrc.periodicjitter object's Phase property.  This function
% directs the set request to the jitter generator object.
this.PeriodicJitterGen.Phase = value;
end

%-----------------------------------------------------------------------
function value = getPeriodicPhase(this)
% PeriodicPhase is a phantom property of the underlying
% commsrc.periodicjitter object's Phase property.  This function
% directs the get request to the jitter generator object.
value = this.PeriodicJitterGen.Phase;
end

%-----------------------------------------------------------------------
function setDiracNumber(this, value)
% DiracNumber is a phantom property of the underlying
% commsrc.diracjitter object's NumberOfComponents property.  This
% function directs the set request to the jitter generator object.
this.DiracJitterGen.NumberOfComponents = value;
end

%-----------------------------------------------------------------------
function value = getDiracNumber(this)
% DiracNumber is a phantom property of the underlying
% commsrc.diracjitter object's NumberOfComponents property.  This
% function directs the get request to the jitter generator object.
value = this.DiracJitterGen.NumberOfComponents;
end

%-----------------------------------------------------------------------
function setDiracDelta(this, value)
% DiracDelta is a phantom property of the underlying
% commsrc.diracjitter object's Delta property.  This function
% directs the set request to the jitter generator object after
% converting the value from seconds to samples.
this.DiracJitterGen.Delta = value*this.SymbolRate;
end

%-----------------------------------------------------------------------
function value = getDiracDelta(this)
% DiracDelta is a phantom property of the underlying
% commsrc.diracjitter object's Delta property.  This function
% directs the get request to the jitter generator object and
% converts the value from samples to seconds.
value = this.DiracJitterGen.Delta/this.SymbolRate;
end

%-----------------------------------------------------------------------
function setDiracProbability(this, value)
% DiracProbability is a phantom property of the underlying
% commsrc.diracjitter object's Amplitude property.  This function
% directs the set request to the jitter generator object.
this.DiracJitterGen.Probability = value;
end

%-----------------------------------------------------------------------
function value = getDiracProbability(this)
% DiracProbability is a phantom property of the underlying
% commsrc.periodicjitter object's Amplitude property.  This function
% directs the get request to the jitter generator object.
value = this.DiracJitterGen.Probability;
end

%-------------------------------------------------------------------------------
% [EOF]
