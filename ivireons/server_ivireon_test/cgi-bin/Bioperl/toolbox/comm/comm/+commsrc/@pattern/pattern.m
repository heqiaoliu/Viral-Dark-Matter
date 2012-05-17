classdef pattern < commdevice.abstractDevice  & sigutils.sorteddisp ...
        & sigutils.pvpairs & dynamicprops & sigutils.SaveLoad
%PATTERN Construct a pattern generator object
%   H = COMMSRC.PATTERN constructs a default pattern generator object H.
%
%   A pattern generator object has the following properties.  All the properties
%   are writable unless explicitly stated otherwise.
%
%   Property Name         Description
%   ----------------------------------------------------------------------------
%   Type              - 'Pattern Generator'.  This is a read-only property.
%   SamplingFrequency - Sampling frequency of the input signal in Hz
%   SamplesPerSymbol  - Number of samples used to represent a symbol
%   SymbolRate        - Number of symbols per second.  Symbol rate is a
%                       read-only property and it is calculated based on
%                       SamplingFrequency and SamplesPerSymbol. 
%   PulseType         - Type of the pulse used to modulate data symbols.  The
%                       choices are:
%                       'NRZ' - Non-Return-to-Zero pulse
%                       'RZ'  - Return-to-Zero pulse
%   OutputLevels      - Amplitude levels that correspond to the symbol indices.
%                       For an NRZ pulse, this is a 1x2 vector, where the first
%                       element of the 1x2 vector corresponds to the 0th symbol
%                       (data bit value 0) and the second element corresponds to
%                       the 1st symbol (data bit value 1). For an RZ pulse, this
%                       is a scalar and the value corresponds to the data bit
%                       value 1.
%   PulseDuration     - Number of samples used to represent the 'on' duration of
%                       the pulse.  Note that this property must be an integer
%                       number.  This property is available only for RZ pulse
%                       type.
%   RiseTime          - 10%-90% rise time of the pulse in seconds
%   FallTime          - 90%-10% fall time of the pulse in seconds
%   DutyCycle         - Duty cycle of the RZ pulse.  This is a read-only
%                       property.  This property is available only for RZ pulse
%                       type.
%   DataPattern       - The type of the data pattern to be used.  Choices are:
%                       'PRBS5' to 'PRBS15 - Pseudorandom binary sequences of
%                                            length 5 to 15 
%                       'PRBS23'           - Pseudorandom binary sequences of
%                                            length 23 
%                       'PRBS31'           - Pseudorandom binary sequences of
%                                            length 31 
%                       'User Defined'     - User defined binary data sequence
%   UserDataPattern   - The binary sequence supplied by the user.  This property
%                       is available only when 'User Defined' is selected as the
%                       data pattern.
%   Jitter            - Jitter object that defines jitter properties.  For
%                       detailed help on this property type 'help
%                       commsrc.combinedjitter'.
%
%   H = COMMSRC.PATTERN constructs a pattern generator object H with default
%   properties and is equivalent to:
%   H = COMMSRC.PATTERN('SamplingFrequency', 10000, ...
%                       'SamplesPerSymbol', 100, ...
%                       'PulseType', 'NRZ', ...
%                       'OutputLevels', [-1 1], ...
%                       'RiseTime', 0, ...
%                       'FallTime', 0, ...
%                       'DataPattern', 'PRBS7', ...
%                       'Jitter', commsrc.combinedjitter)
%   For default value of the Jitter property, type 'help
%   commsrc.combinedjitter'.
%
%   commsrc.pattern methods:
%     generate      - Generate a modulated pattern.
%     idealtostd181 - Convert ideal pulse parameters to IEEE STD-181 pulse
%                     parameters.
%     std181toideal - Convert IEEE STD-181 pulse parameters to ideal pulse
%                     parameters.
%     computedcd    - Compute the duty cycle distortion (DCD).
%     reset         - Reset the pattern generator internal states.
%     disp          - Display pattern generator object properties.
%
%   To get detailed help on a method from the command line, type 'help
%   commsrc.pattern/<METHOD>', where METHOD is one of the methods listed
%   above. For instance, 'help commsrc.pattern/generate'.
%
%   Examples:
%
%     % Construct a pattern generator object for RZ pulse with rise time 1e-4
%     % sec. and fall time 2e-4 sec.  Also, inject random jitter with standard 
%     % deviation 2e-4 sec.
%     hJitter = commsrc.combinedjitter('RandomJitter', 'on', ...
%                                      'RandomStd', 2e-4)
%     h = commsrc.pattern('PulseType', 'RZ', ...
%                         'RiseTime', 1e-4, ...
%                         'FallTime', 2e-4, ...
%                         'Jitter', hJitter)
%
%   See also COMMSRC, COMMSRC.PATTERN/GENERATE, COMMSRC.PATTERN/IDEALTOSTD181,
%   COMMSRC.PATTERN/STD181TOIDEAL, COMMSRC.PATTERN/COMPUTEDCD,
%   COMMSRC.PATTERN/RESET, COMMSRC.PATTERN/DISP, COMMSRC.COMBINEDJITTER.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2009/01/05 17:45:25 $

    %===========================================================================
    % Public properties
    properties
        % Amplitude levels that correspond to the symbol indices.  For an NRZ
        % pulse, this is a 1x2 vector, where the first element of the 1x2 vector
        % corresponds to the 0th symbol (data bit value 0) and the second
        % element corresponds to the 1st symbol (data bit value 1). For an RZ
        % pulse, this is a scalar and the value corresponds to the data bit
        % value 1.
        OutputLevels
        % 10%-90% rise time of the pulse in seconds
        RiseTime
        % 90%-10% fall time of the pulse in seconds
        FallTime
        % Type of the pulse used to modulate data symbols.  The choices are:
        %   'NRZ' - Non-Return-to-Zero pulse
        %   'RZ'  - Return-to-Zero pulse
        PulseType
        % Jitter specifications.  For detailed help on this property type 'help
        % commsrc.combinedjitter'. 
        Jitter
        % The type of the data pattern to be used.  Choices are:
        %   'PRBS5' to 'PRBS15 - Pseudorandom binary sequences of length 5 to 15  
        %	'PRBS23'           - Pseudorandom binary sequences of length 23 
        %	'PRBS31'           - Pseudorandom binary sequences of length 31 
        %   'User Defined'     - User defined binary data sequence        
        DataPattern
    end

    %===========================================================================
    % Protected properties
    properties (SetAccess = protected)
        Type;   % Type of the class.  Read-only property.  Must be set at the 
                % construction time by the subclass.
    end

    %===========================================================================
    % Private properties
    properties (SetAccess = protected, GetAccess = protected, Hidden)
        % Stores the pulse generator object.  It has to be an object of a
        % subclass of abstractPulse.
        PulseGenerator
        % Stores the previously selected NRZ pulse.  If none was selected, it is
        % set to [].
        PrevNRZPulseGen
        % Stores the previously selected RZ pulse.  If none was selected, it is
        % set to [].
        PrevRZPulseGen
        % Stores the data pattern generator object.  It has to be a pn sequence
        % generator.
        DataPatternGen
        % Stores the counter for the user data.
        UserDataCnt;
    end

    %===========================================================================
    % Public methods
    methods
        function this = pattern(varargin)
            % Constructor for pattern generator class.

            % Set the type property
            this.Type = 'Pattern Generator';

            % Initialize the jitter generators.  Do this first, since set method
            % of each property calls the reset method and the reset method
            % resets the jitter components. 
            this.Jitter = commsrc.combinedjitter;

            % Set the defaults that need their set function to be called.
            this.PulseType = 'NRZ';

            % Initialize the data pattern.  This will call the set function.
            this.DataPattern = 'PRBS7';

            % Add UserData property
            p = addprop(this, 'UserDataPattern');
            this.UserDataPattern = [0 1];
            p.SetMethod = @setUserDataPattern;
            p.SetAccess = 'protected';
            p.GetAccess = 'protected';

            if nargin
                % There are input arguments, so initialize with property-value
                % pairs.
                initPropValuePairs(this, varargin{:});
            end
        end
        %-----------------------------------------------------------------------
        function y = generate(this, N)
%GENERATE  Generate a modulated pattern
%   Y = GENERATE(H, N) generates an N symbol modulated pattern based on the
%   pattern generator object H.
%
%   See also COMMSRC.PATTERN, COMMSRC.PATTERN/STD181TOIDEAL,
%   COMMSRC.PATTERN/IDEALTOSTD181, COMMSRC.PATTERN/RESET,
%   COMMSRC.PATTERN/COMPUTEDCD, COMMSRC.PATTERN/DISP. 

            % Check input arguments
            error(nargchk(2, 2, nargin, 'struct'));
            sigdatatypes.checkFinitePosIntScalar('GENERATE', 'N', N);

            % Get data bits
            if strncmp(this.DataPattern, 'U', 1)
                % Get bits from user data
                
                % Get data vector and counter
                userDataPattern = this.UserDataPattern(:);
                cnt = this.UserDataCnt;
                len = length(userDataPattern);
                
                if len < N
                    % Length of user data is less than requested length
                    data = repmat(userDataPattern, ceil((N+cnt)/len), 1);
                    data = data(cnt:cnt+N-1);
                else
                    % Length of user data is greater than or equal to the
                    % requested length 
                    if (cnt+N) > len
                        data = [userDataPattern(cnt:end); ...
                            userDataPattern(1:N+cnt-len-1)];
                    else
                        data = userDataPattern(cnt:cnt+N-1);
                    end
                end
                
                % Update counter
                this.UserDataCnt = mod(cnt + N - 1, len) + 1;
            else
                % Get bits from PRBS generator
                hDataGen = this.DataPatternGen;
                hDataGen.NumBitsOut = N;
                data = generate(hDataGen);
            end

            % Generate jitter samples
            jitter = generate(this.Jitter, N);
            
            % Generate the jitter injected pulse.  Note that the pulse generator
            % requires jitter values to be in samples.
            y = generate(this.PulseGenerator, data, ...
                jitter*this.SamplingFrequency);
        end
        %-----------------------------------------------------------------------
        function reset(this)
%RESET  Reset the internal states of the pattern generator
%   RESET(H) resets the internal states of the pattern generator object H.
%
%   See also COMMSRC.PATTERN, COMMSRC.PATTERN/GENERATE,
%   COMMSRC.PATTERN/STD181TOIDEAL, COMMSRC.PATTERN/IDEALTOSTD181,
%   COMMSRC.PATTERN/COMPUTEDCD, COMMSRC.PATTERN/DISP.  

            if ~this.IsLoading_
                % Set the symbol duration of the pulse generator and reset
                this.PulseGenerator.SymbolDuration = this.SamplesPerSymbol;
                reset(this.PulseGenerator);

                % Set the symbol rate of the jitter generator properties and reset
                setSymbolRate(this.Jitter, this.SymbolRate);
                reset(this.Jitter);

                if strncmp(this.DataPattern, 'U', 1)
                    % If user defined data pattern is selected, reset user data
                    % counter
                    this.UserDataCnt = 1;
                else
                    % Reset data pattern generator
                    reset(this.DataPatternGen);
                end
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
                'SamplingFrequency', ...
                'SamplesPerSymbol', ...
                'SymbolRate', ...
                'PulseType',...
                'OutputLevels'};

            if strncmpi(this.PulseType, 'N', 1)
                sortedList = [sortedList ...
                    {'RiseTime', ...
                    'FallTime', ...
                    'DataPattern'}];
            else
                sortedList = [sortedList ...
                    {'PulseDuration',...
                    'RiseTime', ...
                    'FallTime',...
                    'DutyCycle', ...
                    'DataPattern'}];
            end

            if strncmpi(this.DataPattern, 'U', 1)
                sortedList = [sortedList {'UserDataPattern'}];
            end

            sortedList = [sortedList {'Jitter'}];
        end
        %-----------------------------------------------------------------------
        function sortedList = getSortedPropInitList(this) %#ok<MANU>
            % GETSORTEDPROPINITLIST returns a list of properties in the order in
            % which the properties must be initialized.

            sortedList = {...
                'SamplingFrequency', ...
                'SamplesPerSymbol'...
                'PulseType', ...
                'RiseTime', ...
                'FallTime', ...
                'OutputLevels', ...
                'Jitter', ...
                'DataPattern', ...
                };
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
            s.UserDataPattern = this.UserDataPattern;
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
        function set.OutputLevels(this, value)
            % Since OutputLevels is a phantom property of the underlying
            % commsrc.abstractPulse object's OutputLevels property, this
            % function directs the set request to the appropriate object.
            this.PulseGenerator.OutputLevels = value;
            reset(this);
        end
        %-----------------------------------------------------------------------
        function value = get.OutputLevels(this)
            % Since OutputLevels is a phantom property of the underlying
            % commsrc.abstractPulse object's OutputLevels property, this
            % function directs the get request to the appropriate object.
            value = this.PulseGenerator.OutputLevels;
        end
        %-----------------------------------------------------------------------
        function set.RiseTime(this, value)
            % RiseTime is a phantom property of the underlying
            % commsrc.abstractPulse object's RiseTime property.  This function
            % directs the set request to the pulse generator object after
            % converting the value from seconds to samples.
            this.PulseGenerator.RiseTime = value*this.SamplingFrequency;
            reset(this);
        end
        %-----------------------------------------------------------------------
        function value = get.RiseTime(this)
            % RiseTime is a phantom property of the underlying
            % commsrc.abstractPulse object's RiseTime property.  This function
            % directs the get request to the pulse generator object and converts
            % the value from samples to seconds.
            value = this.PulseGenerator.RiseTime/this.SamplingFrequency;
        end
        %-----------------------------------------------------------------------
        function set.FallTime(this, value)
            % FallTime is a phantom property of the underlying
            % commsrc.abstractPulse object's FallTime property.  This function
            % directs the set request to the pulse generator object after
            % converting the value from seconds to samples.
            this.PulseGenerator.FallTime = value*this.SamplingFrequency;
            reset(this);
        end
        %-----------------------------------------------------------------------
        function value = get.FallTime(this)
            % FallTime is a phantom property of the underlying
            % commsrc.abstractPulse object's FallTime property.  This function
            % directs the get request to the pulse generator object and converts
            % the value from samples to seconds.
            value = this.PulseGenerator.FallTime/this.SamplingFrequency;
        end
        %-----------------------------------------------------------------------
        function set.PulseGenerator(this, value)
            sigdatatypes.checkIsA(this, 'PulseGenerator', value, ...
                'commsrc.abstractPulse');
            this.PulseGenerator = value;
            reset(this);
        end
        %-----------------------------------------------------------------------
        function set.PulseType(this, value)
            sigdatatypes.checkEnum(this, 'PulseType', value, ...
                {'NRZ', 'RZ'});

            % If value is the same as the current value of the PulseType, then
            % do not execute this function.
            if strncmpi(this.PulseType, value, 1)
                return
            end

            % Save current generator in a temporary location.
            dummyGen = this.PulseGenerator;

            if strncmpi(value, 'N', 1)
                % Requested type is NRZ.  Just in case, complete the spelling.
                value = 'NRZ';

                if isempty(this.PrevNRZPulseGen)
                    % This is the first time NRZ is requested.
                    this.PulseGenerator = commsrc.nrz;
                else
                    % A previous NRZ pulse generator was stored.  Use the stored
                    % one.
                    this.PulseGenerator = this.PrevNRZPulseGen;
                end

                % If exists, remove the DutyCycle property
                p = this.findprop('DutyCycle');
                if ~isempty(p)
                    delete(p);
                end

                % If exists, remove the PulseDuration property
                p = this.findprop('PulseDuration');
                if ~isempty(p)
                    delete(p);
                end
            else
                % Requested type is RZ.  Just in case, complete the spelling.
                value = 'RZ';

                if isempty(this.PrevRZPulseGen)
                    % This is the first time RZ is requested.
                    this.PulseGenerator = commsrc.rz;
                else
                    % A previous RZ pulse generator was stored.  Use the stored
                    % one.
                    this.PulseGenerator = this.PrevRZPulseGen;
                end

                % Add the PulseDuration property
                p = this.addprop('PulseDuration');
                p.SetMethod = @setPulseDuration;
                p.GetMethod = @getPulseDuration;

                % Add the DutyCycle property
                p = this.addprop('DutyCycle');
                p.SetAccess = 'private';
                p.Transient = true;
                p.GetMethod = @getDutyCycle;
            end

            % Store the previous generator
            if strncmpi(this.PulseType, 'N', 1)
                % Previous pulse type is NRZ
                this.PrevNRZPulseGen = dummyGen;
            else
                % Previous pulse type is RZ
                this.PrevRZPulseGen = dummyGen;
            end

            % Set the property to the new value.
            this.PulseType = value;

            reset(this);
        end
        %-----------------------------------------------------------------------
        function set.DataPattern(this, value)
            % Check validity
            sigdatatypes.checkEnum(this, 'Pattern', value, {'PRBS5', ...
                'PRBS6', 'PRBS7', 'PRBS8', 'PRBS9', 'PRBS10', 'PRBS11', ...
                'PRBS12', 'PRBS13', 'PRBS14', 'PRBS15', 'PRBS23', 'PRBS31', ...
                'User Defined'});

            if ~strncmpi(value, 'U', 1)
                if strncmpi(this.DataPattern, 'User Defined', 9)
                    % Make the UserDataPattern property private
                    p = findprop(this, 'UserDataPattern');
                    p.SetAccess = 'protected';
                    p.GetAccess = 'protected';
                end

                % Initiate the PRBS pattern generator object
                switch value
                    case 'PRBS5'
                        this.DataPatternGen = commsrc.pn('GenPoly', ...
                            [1 1 0 1 1 1]);
                    case 'PRBS6'
                        this.DataPatternGen = commsrc.pn('GenPoly', ...
                            [1 1 0 1 1 0 1]);
                    case 'PRBS7'
                        this.DataPatternGen = commsrc.pn('GenPoly', ...
                            [1 1 0 0 0 0 0 1]);
                    case 'PRBS8'
                        this.DataPatternGen = commsrc.pn('GenPoly', ...
                            [1 1 0 0 0 1 1 0 1]);
                    case 'PRBS9'
                        this.DataPatternGen = commsrc.pn('GenPoly', ...
                            [1 0 0 0 1 0 0 0 0 1]);
                    case 'PRBS10'
                        this.DataPatternGen = commsrc.pn('GenPoly', ...
                            [1 0 0 1 0 0 0 0 0 0 1]);
                    case 'PRBS11'
                        this.DataPatternGen = commsrc.pn('GenPoly', ...
                            [1 0 1 0 0 0 0 0 0 0 0 1]);
                    case 'PRBS12'
                        this.DataPatternGen = commsrc.pn('GenPoly', ...
                            [1 0 0 1 1 0 0 1 0 0 0 0 1]);
                    case 'PRBS13'
                        this.DataPatternGen = commsrc.pn('GenPoly', ...
                            [1 1 0 1 1 0 0 0 0 0 0 0 0 1]);
                    case 'PRBS14'
                        this.DataPatternGen = commsrc.pn('GenPoly', ...
                            [1 1 0 0 1 1 0 0 0 0 0 0 1 1 1]);
                    case 'PRBS15'
                        this.DataPatternGen = commsrc.pn('GenPoly', ...
                            [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1]);
                    case 'PRBS23'
                        this.DataPatternGen = commsrc.pn('GenPoly', ...
                            [1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1]);
                    case 'PRBS31'
                        this.DataPatternGen = commsrc.pn('GenPoly', ...
                            [1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ...
                            0 0 0 0 0 0 0 1]);
                end
            else
                value = 'User Defined';
                
                % Make the UserDataPattern property public
                p = findprop(this, 'UserDataPattern');
                p.SetAccess = 'public';
                p.GetAccess = 'public';
            end

            % Set the property
            this.DataPattern = value;

            reset(this);
        end
        %-----------------------------------------------------------------------
        function set.Jitter(this, value)
            % Check validity
            sigdatatypes.checkIsA(this, 'Jitter', value, ...
                'commsrc.combinedjitter');
            
            % Set the symbol rate of the jitter object
            setSymbolRate(value, this.SymbolRate);
            
            % Set the property
            this.Jitter = value;
        end
    end
end

%===============================================================================
% Set/Get methods for dynamic properties

function value = getDutyCycle(this)
% DutyCycle is a phantom property of the underlying
% commsrc.RZ object's DutyCycle property.  This function
% directs the get request to the pulse generator object.
value = this.PulseGenerator.DutyCycle;
end

%-------------------------------------------------------------------------------
function setPulseDuration(this, value)
% PulseDuration is a phantom property of the underlying
% commsrc.rz object's PulseDuration property.  This function
% directs the set request to the pulse generator object after
% converting the value from seconds to samples.
this.PulseGenerator.PulseDuration = value*this.SamplingFrequency;
reset(this);
end

%-------------------------------------------------------------------------------
function value = getPulseDuration(this)
% PulseDuration is a phantom property of the underlying
% commsrc.rz object's PulseDuration property.  This function
% directs the get request to the pulse generator object and converts
% the value from samples to seconds.
value = this.PulseGenerator.PulseDuration/this.SamplingFrequency;
end

%-------------------------------------------------------------------------------
function setUserDataPattern(this, value)
% Check validity
sigdatatypes.checkBinaryVec(this, 'UserDataPattern', value)

% Set the user data and reset the pattern generator
this.UserDataPattern = value;
reset(this);
end

%-------------------------------------------------------------------------------
% [EOF]