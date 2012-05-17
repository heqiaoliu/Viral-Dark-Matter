classdef rz < commsrc.abstractPulse
%RZ Construct a Return-to-Zero (RZ) pulse generator object
%   H = COMMSRC.RZ constructs a default RZ pulse generator object H.
%
%   An RZ pulse generator object has the following properties.  All the
%   properties are writable unless explicitly stated otherwise.
%
%   Property Name      Description
%   ----------------------------------------------------------------------------
%   Type             - 'RZ Pulse Generator'.  This is a read-only property.
%   OutputLevels     - Amplitude level that corresponds to the data bit 1 input.
%   SymbolDuration   - Number of samples used to represent a symbol.  Note that
%                      this property must be an integer number.
%   PulseDuration    - Number of samples used to represent the 50% pulse 
%                      duration.  Note that this property can be a non-integer
%                      number.
%   DutyCycle        - Duty cycle of the pulse.  This is a read-only property.
%   RiseTime         - 10%-90% rise time of the pulse normalized by sampling
%                      time, i.e. in samples.  Note that this property can be a
%                      non-integer number.
%   FallTime         - 90%-10% fall time of the pulse normalized by sampling
%                      time, i.e. in samples.  Note that this property can be a
%                      non-integer number.
%
%   H = COMMSRC.RZ constructs an RZ pulse generator object H with default
%   properties and is equivalent to:
%   H = COMMSRC.RZ('OutputLevels', 1, ...
%                  'SymbolDuration', 100, ...
%                  'PulseDuration', 50, ...
%                  'DutyCycle', 50, ...
%                  'RiseTime', 0, ...
%                  'FallTime', 0)
%
%   commsrc.rz methods:
%     generate - Generate a modulated signal based on the pulse definition and
%                the input data.  If jitter is specified also inject jitter. 
%     reset    - Reset the RZ pulse generator internal states
%     disp     - Display RZ pulse generator object properties
%
%   To get detailed help on a method from the command line, type 'help
%   commsrc.rz/<METHOD>', where METHOD is on of the methods listed above.
%   For instance, 'help commsrc.rz/generate'.
%
%   Examples:
%
%     % Construct an RZ pulse generator with 'on' level 2, rise time 10 samples, 
%     % and fall time 20 samples.
%     h = commsrc.rz('OutputLevels', 2, 'RiseTime', 10, 'FallTime', 20)
%
%   See also COMMSRC, COMMSRC.RZ/GENERATE, COMMSRC.RZ/RESET, COMMSRC.RZ/DISP,
%   COMMSRC.NRZ. 

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2008/10/31 05:54:27 $

    %===========================================================================
    % Public properties
    properties
        % Amplitude level that corresponds to the data bit 1 input.
        OutputLevels = 1;           % Mandated by abstractPulse superclass
        % Number of samples used to represent the 50% pulse duration.  Note that
        % this property can be a non-integer number. 
        PulseDuration = 50;
    end

    %===========================================================================
    % Read-onyl properties
    properties (SetAccess = private, Dependent)
        % Duty cycle of the pulse.  This is a read-only property.
        DutyCycle
    end

    %===========================================================================
    % Private properties
    properties (SetAccess = private, GetAccess = private)
        NumRiseSamps         % 0-100% rise time in samples
        NumFallSamps         % 100-0% fall time in samples
    end

    %===========================================================================
    % Private properties
    properties (SetAccess = private, GetAccess = private)
        % Duration of the 'on' state in samples.  This property can be a
        % non-integer number.
        OnDuration;
    end

    %===========================================================================
    % Private methods
    methods (Access = protected)
        calcPulse(this)         % Mandated by abstractPulse superclass.  
                                % Defined in a separate file.

        %-----------------------------------------------------------------------
        function sortedList = getSortedPropDispList(this)  %#ok<MANU>
            % Return the list of properties in the order they chould be
            % displayed.

            sortedList = {...
                'Type', ...
                'OutputLevels', ...
                'SymbolDuration', ...
                'PulseDuration', ...
                'DutyCycle', ...
                'RiseTime', ...
                'FallTime'};
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
    % Public methods
    methods
        function this = rz(varargin)
            % Constructor for RZ pulse generator class.
            
            % Set the type property
            this.Type = 'RZ Pulse Generator';
            
            if nargin
                % There are input arguments, so initialize with property-value
                % pairs.  Note that, we do not need to explicitly call
                % calcPulse, since it will be called when a property is changed.
                initPropValuePairs(this, varargin{:});
            else
                % Calculate pulse parameters.  Note that the initial values set
                % in the classdef does not trigger the set functions, so we need
                % to call calcPulse explicitly.
                calcPulse(this);
            end
        end
        %-----------------------------------------------------------------------
        function reset(this)
%RESET   Reset the internal states of an RZ pulse generator object
%   RESET(H) reset the internal states properties of the RZ pulse generator
%   object H.
%
%   See also COMMSRC.RZ, COMMSRC.RZ/GENERATE, COMMSRC.RZ/DISP.

            if ~this.IsLoading_
                reset@commsrc.abstractPulse(this);
            end
        end

        %-----------------------------------------------------------------------
        out = generate(this, data, varargin)
        % Mandated by abstractPulse superclass.  Defined in a separate file.
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function set.OutputLevels(this, outLevels)
            % Check for validity
            sigdatatypes.checkFiniteRealDblScalar(this, 'OutputLevels', ...
                outLevels);
            
            % Set the property
            this.OutputLevels = outLevels;
            
            % Recalculate pulse.  Since there are no restrictions on output
            % levels, calcPulse should not error out.
            calcPulse(this);
        end
        %-----------------------------------------------------------------------
        function set.PulseDuration(this, Tpulse)
            % Check for validity
            sigdatatypes.checkFinitePosDblScalar(this, 'PulseDuration', Tpulse);

            % Store the old value in case calcPulse errors out, then set.
            oldValue = this.PulseDuration;
            this.PulseDuration = Tpulse;
            
            % Recalculate pulse.  If calcPulse errors out, then restore to the
            % original value and error out from this function.
            try
                calcPulse(this);
            catch exception
                this.PulseDuration = oldValue;
                throw(exception)
            end
        end
        %-----------------------------------------------------------------------
        function value = get.DutyCycle(this)
            % DutyCycle is a dependent property.  Its value is calculated based
            % on rise time, fall time, and pulse duration.
            
            Ton = (this.NumRiseSamps + this.NumFallSamps)/2 + this.OnDuration;
            value = 100 * Ton / this.SymbolDuration;
        end
    end
end
%-------------------------------------------------------------------------------
% [EOF]