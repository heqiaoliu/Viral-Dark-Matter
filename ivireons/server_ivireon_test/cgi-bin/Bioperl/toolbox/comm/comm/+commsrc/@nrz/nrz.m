classdef nrz < commsrc.abstractPulse
%NRZ Construct a Non-Return-to-Zero (NRZ) pulse generator object
%   H = COMMSRC.NRZ constructs a default NRZ pulse generator object H.
%
%   An NRZ pulse generator object has the following properties.  All the
%   properties are writable unless explicitly stated otherwise.
%
%   Property Name      Description
%   ----------------------------------------------------------------------------
%   Type             - 'NRZ Pulse Generator'.  This is a read-only property.
%   OutputLevels     - Amplitude levels that correspond to the logical low and
%                      high values.  First element of the 1x2 vector corresponds
%                      to the 0th symbol and the second element corresponds to
%                      the 1st symbol.
%   SymbolDuration   - Number of samples used to represent a symbol.  Note that
%                      this property must be an integer number.
%   RiseTime         - 10%-90% rise time of the pulse normalized by sampling
%                      time, i.e. in samples.  Note that this property can be a
%                      non-integer number.
%   FallTime         - 90%-10% fall time of the pulse normalized by sampling
%                      time, i.e. in samples.  Note that this property can be a
%                      non-integer number.
%
%   H = COMMSRC.NRZ constructs an NRZ pulse generator object H with default
%   properties and is equivalent to:
%   H = COMMSRC.NRZ('OutputLevels', [-1 1], ...
%                   'SymbolDuration', 100, ...
%                   'RiseTime', 0, ...
%                   'FallTime', 0)
%
%   commsrc.nrz methods:
%     generate - Generate a modulated signal based on the pulse definition and
%                the input data.  If jitter is specified also inject jitter. 
%     reset    - Reset the NRZ pulse generator internal states
%     disp     - Display NRZ pulse generator object properties
%
%   To get detailed help on a method from the command line, type 'help
%   commsrc.nrz/<METHOD>', where METHOD is on of the methods listed above.
%   For instance, 'help commsrc.nrz/generate'.
%
%   Examples:
%
%     % Construct an NRZ pulse generator with output levels 2 for input data bit
%     % 0 and -2 for input data bit 1.
%     h = commsrc.nrz('OutputLevels', [2 -2])
%
%   See also COMMSRC, COMMSRC.NRZ/GENERATE, COMMSRC.NRZ/RESET, COMMSRC.NRZ/DISP,
%   COMMSRC.RZ.  

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2008/10/31 05:54:25 $

    %===========================================================================
    % Public properties
    properties
        OutputLevels = [-1 1];  % Amplitude levels in a vector for symbol 
                                % values 0:M-1.  Mandated by abstractPulse
                                % superclass
    end

    %===========================================================================
    % Private properties
    properties (SetAccess = private, GetAccess = private)
        NumRiseSamps      % 0-100% rise time in samples
        NumFallSamps      % 100-0% fall time in samples
        LowLevel          % Low output level
        HighLevel         % High output level
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
        function this = nrz(varargin)
            % Constructor for NRZ pulse generator class.
            
            % Set the type property
            this.Type = 'NRZ Pulse Generator';
            
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
%RESET   Reset the internal states of an NRZ pulse generator object
%   RESET(H) reset the internal states properties of the NRZ pulse generator
%   object H.
%
%   See also COMMSRC.NRZ, COMMSRC.NRZ/GENERATE, COMMSRC.NRZ/DISP.

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
            sigdatatypes.checkFiniteRealDblMat(this, 'OutputLevels', ...
                outLevels, [1 2]);
            if (outLevels(1)-outLevels(2)) == 0
                error('comm:commsrc:nrz:EqualOutputLevels', ['OutputLevels '...
                    'must be distinct values.']);
            end
            
            % Set the property
            this.OutputLevels = outLevels;
            
            % Recalculate pulse.  Since there are no restrictions on output
            % levels, calcPulse should not error out.
            calcPulse(this);
        end
    end
end
%---------------------------------------------------------------------------
% [EOF]