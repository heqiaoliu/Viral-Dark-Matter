classdef diracjitter < commsrc.abstractJitter
%DIRACJITTER Construct a Dirac jitter generator object
%   H = COMMSRC.DIRACJITTER constructs a default Dirac jitter generator
%   object H. 
%
%   A Dirac jitter generator object has the following properties.  All the
%   properties are writable unless explicitly stated otherwise.
%
%   Property Name         Description
%   ----------------------------------------------------------------------------
%   Type                - 'Dirac Jitter Generator'.  This is a read-only
%                         property.
%   NumberOfComponents  - Number of Dirac components
%   Delta               - Time delay of each Dirac component in symbol duration
%   Probability         - Probability of each Dirac component.  Sum must be
%                         one.
%
%   H = COMMSRC.DIRACJITTER constructs a Dirac jitter generator object H
%   with default properties and is equivalent to:
%   H = COMMSRC.DIRACJITTER('NumberOfComponents', 2, ...
%                           'Delta', [-0.05 0.05], ...
%                           'Probability', [0.5 0.5])
%
%   commsrc.diracjitter methods:
%     generate - Generate Dirac jitter samples 
%     disp     - Display Dirac jitter generator object properties
%
%   To get detailed help on a method from the command line, type 'help
%   commsrc.diracjitter/<METHOD>', where METHOD is on of the methods listed
%   above. For instance, 'help commsrc.diracjitter/generate'.
%
%   Examples:
%
%     % Construct a Dirac jitter generator with three components at time delay
%     % values -0.02, 0.01, and 0.05 symbol durations, with probability 0.3,
%     % 0.1, and 0.6, respectively. 
%     h = commsrc.diracjitter('NumberOfComponents', 3, ...
%                              'Probability', [0.3 0.1 0.6], ...
%                              'Delta', [-0.02 0.01 0.05])
%
%   See also COMMSRC, COMMSRC.DIRACJITTER/GENERATE, COMMSRC.DIRACJITTER/DISP, 
%   COMMSRC.RANDOMJITTER, COMMSRC.PERIODICJITTER.  

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2008/10/31 05:54:22 $

    %===========================================================================
    % Public properties
    properties
        % Number of sinusoidal components.
        NumberOfComponents = 2;
        % Probability of each Dirac component.  Sum must be one.
        Probability = [0.5 0.5];
        % Time delay of each Dirac component in symbol duration.
        Delta = [-0.05 0.05];
    end

    %===========================================================================
    % Public methods
    methods
        function this = diracjitter(varargin)
            % Constructor for Dirac jitter generator class.
            
            % Set the type property
            this.Type = 'Dirac Jitter Generator';
            
            if nargin
                % There are input arguments, so initialize with property-value
                % pairs.  
                initPropValuePairs(this, varargin{:});
            end
        end
        %-----------------------------------------------------------------------
        function jitter = generate(this, N)
%GENERATE  Generate Dirac jitter samples
%   JITTER = GENERATE(H, N) generates N samples of Dirac jitter based on the
%   Dirac jitter generator object H.
%
%   See also COMMSRC.DIRACJITTER, COMMSRC.DIRACJITTER/RESET,
%   COMMSRC.DIRACJITTER/DISP. 

            jitter = randsrc(N, 1, [this.Delta ;this.Probability]);

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
                'NumberOfComponents', ...
                'Delta', ...
                'Probability'};
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

                % Set Probability and Delta to default values
                this.Probability = 1/N*ones(1, N);
                this.Delta = linspace(-1, 1, N)*0.05;
            end
        end
        %-----------------------------------------------------------------------
        function set.Probability(this, prob)
            % Check for validity
            sigdatatypes.checkFiniteNonNegDblMat(this, 'Probability', prob, ...
                [1 this.NumberOfComponents]);
            if abs(sum(prob) - 1) > sqrt(eps)
                error('comm:commsrc:diracjitter:InvalidProbability', ...
                    'The sum of Probability values must be one.');
            end
            
            % Set the property
            this.Probability = prob;
        end
        %-----------------------------------------------------------------------
        function set.Delta(this, t)
            % Check for validity
            sigdatatypes.checkFiniteRealDblMat(this, 'Delta', t, ...
                [1 this.NumberOfComponents]);
            % Check if the difference between to jitter samples will be less
            % than the symbol duration.
            maxDeltaT = max(t)-min(t);
            if maxDeltaT >= 1
                error('comm:commsrc:diracjitter:InvalidDelta', ...
                    ['The difference between the maximum Delta value and '...
                    'the minimum delta value must be less than one symbol '...
                    'duration.']);
            end
            
            % Set the property
            this.Delta = t;
        end
    end
end