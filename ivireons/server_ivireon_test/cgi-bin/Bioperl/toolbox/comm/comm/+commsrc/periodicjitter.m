classdef periodicjitter < commsrc.abstractJitter
%PERIODICJITTER Construct a periodic jitter generator object
%   H = COMMSRC.PERIODICJITTER constructs a default periodic jitter generator
%   object H. 
%
%   A periodic jitter generator object has the following properties.  All the
%   properties are writable unless explicitly stated otherwise.
%
%   Property Name         Description
%   ----------------------------------------------------------------------------
%   Type                - 'Periodic Jitter Generator'.  This is a read-only
%                         property.
%   NumberOfComponents  - Number of sinusoidal components
%   Amplitude           - Amplitude of each sinusoidal component in samples
%   Frequency           - Frequency of each sinusoidal component in cycles per 
%                         symbol
%   Phase               - Phase of each sinusoidal component
%
%   H = COMMSRC.PERIODICJITTER constructs a periodic jitter generator object H
%   with default properties and is equivalent to:
%   H = COMMSRC.PERIODICJITTER('NumberOfComponents', 1, ...
%                              'Amplitude', 0.05, ...
%                              'Frequency', 0.02, ...
%                              'Phase', 0)
%
%   commsrc.periodicjitter methods:
%     generate - Generate periodic jitter samples 
%     reset    - Reset the internal states of the periodic jitter generator
%     disp     - Display periodic jitter generator object properties
%
%   To get detailed help on a method from the command line, type 'help
%   commsrc.periodicjitter/<METHOD>', where METHOD is on of the methods listed
%   above. For instance, 'help commsrc.periodicjitter/generate'.
%
%   Examples:
%
%     % Construct an periodic jitter generator with two sinuoidal components
%     % with amplitudes 4 and 5, and frequencies 2 and 5.
%     h = commsrc.periodicjitter('NumberOfComponents', 2, ...
%                                'Amplitude', [4 5], ...
%                                'Frequency', [2 5])
%
%   See also COMMSRC, COMMSRC.PERIODICJITTER/GENERATE,
%   COMMSRC.PERIODICJITTER/RESET, COMMSRC.PERIODICJITTER/DISP, 
%   COMMSRC.RANDOMJITTER, COMMSRC.DIRACJITTER.  

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2008/10/31 05:54:23 $

    %===========================================================================
    % Public properties
    properties
        % Number of sinusoidal components.
        NumberOfComponents = 1;
        % Amplitude of each sinusoidal component in samples.
        Amplitude = 0.05;
        % Frequency of each sinusoidal component in cycles per symbol.
        Frequency = 0.02;
        % Phase of each sinusoidal component.
        Phase = 0;
    end

    %===========================================================================
    % Private properties
    properties (SetAccess = private, GetAccess = private)
        % Time.  Generate method uses this property to keep track of time.
        t = 0;
    end
    
    %===========================================================================
    % Public methods
    methods
        function this = periodicjitter(varargin)
            % Constructor for periodic jitter generator class.
            
            % Set the type property
            this.Type = 'Periodic Jitter Generator';
            
            if nargin
                % There are input arguments, so initialize with property-value
                % pairs.  
                initPropValuePairs(this, varargin{:});
            end
        end
        %-----------------------------------------------------------------------
        function reset(this)
%RESET   Reset the internal states of an periodic jitter generator object
%   RESET(H) reset the internal states properties of the periodic jitter
%   generator object H.
%
%   See also COMMSRC.PERIODICJITTER, COMMSRC.PERIODICJITTER/GENERATE,
%   COMMSRC.PERIODICJITTER/DISP. 
            if ~this.IsLoading_
                this.t = zeros(1, this.NumberOfComponents);
            end
        end

        %-----------------------------------------------------------------------
        function jitter = generate(this, N)
%GENERATE  Generate periodic jitter samples
%   JITTER = GENERATE(H, N) generates N samples of periodic jitter based on the
%   periodic jitter generator object H.
%
%   See also COMMSRC.PERIODICJITTER, COMMSRC.PERIODICJITTER/RESET,
%   COMMSRC.PERIODICJITTER/DISP. 

            jitter = zeros(N, 1);
            % Loop over all components and generate periodic jitter
            for p=1:this.NumberOfComponents
                % Construct the time vector starting from the saved time
                tStart = this.t(p);
                tVec = tStart:tStart+(N-1);
                
                jitter = jitter + this.Amplitude(p)*...
                    cos(2*pi*this.Frequency(p)*tVec'+this.Phase(p));

                % Save the time
                this.t(p) = mod(tVec(end)+1, 1/this.Frequency(p));
            end

        end
    end

    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function sortedList = getSortedPropDispList(this)  %#ok<MANU>
            % Return the list of properties in the order they chould be
            % displayed.

            sortedList = {...
                'Type', ...
                'NumberOfComponents', ...
                'Amplitude', ...
                'Frequency', ...
                'Phase'};
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
        function set.NumberOfComponents(this, N)
            % Check for validity
            sigdatatypes.checkFinitePosIntScalar(this, 'NumberOfComponents', N);
            
            % If N is a different value than the current value
            if (N ~= this.NumberOfComponents)
                % Set the property
                this.NumberOfComponents = N;

                % Set Amplitude, Frequency, and Phase to default values
                this.Amplitude = 0.05*ones(1, N);
                this.Frequency = 0.02*ones(1, N);
                this.Phase = zeros(1, N);
                
                % Reset
                reset(this);
            end
        end
        %-----------------------------------------------------------------------
        function set.Amplitude(this, amp)
            numOfComponents = this.NumberOfComponents;
            % Check for validity
            sigdatatypes.checkFinitePosDblMat(this, 'Amplitude', amp, ...
                [1 numOfComponents]);
            if (numOfComponents == 1)
                % Check if the difference between two jitter samples will be
                % less than the symbol duration.  The biggest difference will be
                % around zero degrees.  If the number of components is more than
                % 1, we don't have a closed form expression to check this
                % condition.
                maxDeltaAmp = 2*amp.*sin(2*pi*this.Frequency/2);
                if max(maxDeltaAmp) >= 1
                    error('comm:commsrc:periodicjitter:InvalidAmplitude', ...
                        ['The Amplitude property is too high.  Type '...
                        '''doc commsrc.periodicjitter'' for valid '...
                        'amplitude values']);
                end
            end
            
            % Set the property
            this.Amplitude = amp;
        end
        %-----------------------------------------------------------------------
        function set.Frequency(this, f)
            % Check for validity
            sigdatatypes.checkFinitePosDblMat(this, 'Frequency', f, ...
                [1 this.NumberOfComponents]);
            
            % Set the property
            this.Frequency = f;
        end
        %-----------------------------------------------------------------------
        function set.Phase(this, phase)
            % Check for validity
            sigdatatypes.checkFiniteRealDblMat(this, 'Phase', phase, ...
                [1 this.NumberOfComponents]);
            if any((phase>pi) | (phase<=-pi))
                error('comm:commsrc:periodicjitter:InvalidPhase', ...
                    'The Phase property must be in the region (-pi pi]');
            end
            
            % Set the property
            this.Phase = phase;
        end
    end
end