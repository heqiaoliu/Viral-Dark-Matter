classdef randomjitter < commsrc.abstractJitter
%RANDOMJITTER Construct a random jitter generator object
%   H = COMMSRC.RANDOMJITTER constructs a default random jitter generator object
%   H. 
%
%   A random jitter generator object has the following properties.  All the
%   properties are writable unless explicitly stated otherwise.
%
%   Property Name      Description
%   ----------------------------------------------------------------------------
%   Type             - 'Random Jitter Generator'.  This is a read-only property.
%   Std              - Standard deviation of the random jitter in samples
%
%   H = COMMSRC.RANDOMJITTER constructs a random jitter generator object H with
%   default properties and is equivalent to:
%   H = COMMSRC.RANDOMJITTER('Std', 0.01)
%
%   commsrc.randomjitter methods:
%     generate - Generate random jitter samples 
%     disp     - Display random jitter generator object properties
%
%   To get detailed help on a method from the command line, type 'help
%   commsrc.randomjitter/<METHOD>', where METHOD is on of the methods listed
%   above. For instance, 'help commsrc.randomjitter/generate'.
%
%   Examples:
%
%     % Construct an random jitter generator with standard deviation 1e-5 sec.
%     % Assume that the sampling frequency, Fs, is 10 kHz.
%     Fs = 10000;
%     h = commsrc.randomjitter('Std', 1e-5*Fs)
%
%   See also COMMSRC, COMMSRC.RANDOMJITTER/GENERATE, COMMSRC.RANDOMJITTER/DISP,
%   COMMSRC.PERIODICJITTER, COMMSRC.DIRACJITTER. 

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2008/10/31 05:54:24 $

    %===========================================================================
    % Public properties
    properties
        % Standard deviation of the random jitter in samples
        Std = 0.01;
    end

    %===========================================================================
    % Public methods
    methods
        function this = randomjitter(varargin)
            % Constructor for random jitter generator class.
            
            % Set the type property
            this.Type = 'Random Jitter Generator';
            
            if nargin
                % There are input arguments, so initialize with property-value
                % pairs.  
                initPropValuePairs(this, varargin{:});
            end
        end
        %-----------------------------------------------------------------------
        function jitter = generate(this, N)
%GENERATE  Generate random jitter samples
%   JITTER = GENERATE(H, N) generates N samples of random jitter based on the
%   random jitter generator object H.
%
%   See also COMMSRC.RANDOMJITTER, COMMSRC.RANDOMJITTER/DISP.

            jitter = this.Std * randn(N, 1);

        end
    end

    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function sortedList = getSortedPropDispList(this) %#ok
            % Return the list of properties in the order they chould be
            % displayed.

            sortedList = {...
                'Type', ...
                'Std'};
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
        function set.Std(this, val)
            % Check for validity
            sigdatatypes.checkFiniteNonNegDblScalar(this, 'Std', val);
            if ( val > 0.2 )
                warning('comm:commsrc:randomjitter:StdTooLarge', ['The '...
                    'standard deviation value is too large and may result '...
                    'in nonrealizable jitter values']);
            end
            
            % Set the property
            this.Std = val;
        end
    end
end