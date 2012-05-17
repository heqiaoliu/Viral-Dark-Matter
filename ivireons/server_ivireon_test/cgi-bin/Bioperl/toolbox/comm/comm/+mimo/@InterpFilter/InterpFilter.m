classdef InterpFilter < mimo.BaseSigProc
    %InterpFilter Returns an interpolation filter for MIMO channels
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.3 $  $Date: 2009/05/23 07:48:35 $
    
    %===========================================================================
    % Read-Only properties
    properties (SetAccess = private)
        % Channel filter type.
        InterpFilterType = 'Polyphase-Linear Hybrid';
        % Number of input samples processed.
    	NumSamplesProcessed
    end
    
    %===========================================================================
    % Read-Only dependent properties
    properties (SetAccess = private, Dependent)
        % Length of each filter in polyphase filter bank.
        SubfilterLength
        % Polyphase filter bank.
        FilterBank
        % Polyphase filter bank phase.
        FilterPhase
    end
    
    %===========================================================================
    % Public dependent properties
    properties (Dependent)
        % Polyphase filter bank interpolation factor.
        PolyphaseInterpFactor
        % Linear interpolation factor.
        LinearInterpFactor
        % Maximum length of each filter in polyphase filter bank.
        MaxSubfilterLength
        % Number of channels (e.g., number of multipath components).
        NumChannels
        % Number of links
        NumLinks
        % Polyphase filter input state.
        FilterInputState
        % Last polyphase filter outputs.
    	LastFilterOutputs
        % Linear interpolation index.
    	LinearInterpIndex
    end
    
    %===========================================================================
    % Public methods
    methods
        function h = InterpFilter(varargin)
            %INTERPFILTER  Construct an interpolating filter object.
            %
            %   Inputs:
            %     N1 - Polyphase filter interpolation factor.
            %     N2 - Linear interpolation factor.
            %     NC - Number of channels (paths).
            %     NL - Number of links.
            
            error(nargchk(0, 4, nargin));
            
            % Initialize private data
            h.basesigproc_initprivatedata;
            
            pd = h.PrivateData;
            
            pd.PolyphaseInterpFactor = 2;
            pd.LinearInterpFactor = 1;
            pd.SubfilterLength = 8;
            pd.MaxSubfilterLength = 8;
            pd.NumChannels = 1; % paths
            pd.NumLinks = 1;
            pd.FilterBank = 1;
            pd.FilterInputState = 1;
            pd.FilterPhase = 1;
            pd.LastFilterOutputs = [0 0];
            pd.LinearInterpIndex = 1;
            
            h.PrivateData = pd;
            
            % Set properties if specified.
            p = {'PolyphaseInterpFactor'
                'LinearInterpFactor'
                'NumChannels'
                'NumLinks'};
            set(h, p(1:length(varargin)), varargin);
            
            % Set polyphase subfilter length to 1 if interpolation factor is 1.
            if nargin>1 && varargin{1}==1
                h.SubfilterLength = 1;
            end
            
            h.initialize;
            
            h.Constructed = true;
        end
        %-----------------------------------------------------------------------
        function h = copy(this)
            h = mimo.InterpFilter(this.PolyphaseInterpFactor, ...
                this.LinearInterpFactor, ...
                this.NumChannels, ...
                this.NumLinks);

            mc = metaclass(h);
            props = mc.Properties;
            
            for p=1:length(props)
                pr = props{p};
                if (~pr.Dependent && ~pr.Transient)
                    h.(pr.Name) = this.(pr.Name);
                end
            end
            
        end
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function set.PolyphaseInterpFactor(f, N)
            if (N ~= f.PrivateData.PolyphaseInterpFactor)
                propName = 'PolyphaseInterpFactor';
                validateattributes(N, {'double'}, {'positive', 'integer'}, ...
                    [class(f) '.' propName], propName);
                
                f.PrivateData.PolyphaseInterpFactor = N;
                if f.Constructed, initialize(f); end
            end
        end
        %-----------------------------------------------------------------------
        function N = get.PolyphaseInterpFactor(f)
            if isfield(f.PrivateData,'PolyphaseInterpFactor')
                N = f.PrivateData.PolyphaseInterpFactor;
            end
        end
        %-----------------------------------------------------------------------
        function set.LinearInterpFactor(f, N)
            if (N ~= f.PrivateData.LinearInterpFactor)
                propName = 'LinearInterpFactor';
                validateattributes(N, {'double'}, {'positive', 'integer'}, ...
                    [class(f) '.' propName], propName);
                
                f.PrivateData.LinearInterpFactor = N;
                if f.Constructed, initialize(f); end
            end
        end
        %-----------------------------------------------------------------------
        function N = get.LinearInterpFactor(f)
            if isfield(f.PrivateData,'LinearInterpFactor')
                N = f.PrivateData.LinearInterpFactor;
            end
        end
        %-----------------------------------------------------------------------
        function set.SubfilterLength(f, N)
            if (N ~= f.PrivateData.SubfilterLength)
                propName = 'SubfilterLength';
                validateattributes(N, {'double'}, {'positive', 'integer'}, ...
                    [class(f) '.' propName], propName);
                
                f.PrivateData.SubfilterLength = N;
                if f.Constructed, initialize(f); end
            end
        end
        %-----------------------------------------------------------------------
        function N = get.SubfilterLength(f)
            if isfield(f.PrivateData,'SubfilterLength')
                N = f.PrivateData.SubfilterLength;
            end
        end
        %-----------------------------------------------------------------------
        function set.MaxSubfilterLength(f, N)
            propName = 'MaxSubfilterLength';
            validateattributes(N, {'double'}, {'positive', 'integer'}, ...
                [class(f) '.' propName], propName);
            
            L = N/2;
            if N~=1 && ~isequal(L, round(L))
                error('comm:mimo:InterpFilter:polyPhaseLength', ...
                    'Maximum polyphase subfilter length must be either even or 1.');
            end
            f.PrivateData.MaxSubfilterLength = N;
            if f.Constructed, initialize(f); end
        end
        %-----------------------------------------------------------------------
        function N = get.MaxSubfilterLength(f)
            if isfield(f.PrivateData,'MaxSubfilterLength')
                N = f.PrivateData.MaxSubfilterLength;
            end
        end
        %-----------------------------------------------------------------------
        function set.NumChannels(f, N)
            propName = 'NumChannels';
            validateattributes(N, {'double'}, {'positive', 'integer'}, ...
                [class(f) '.' propName], propName);
            
            f.PrivateData.NumChannels = N;
            if f.Constructed, initialize(f); end
        end
        %-----------------------------------------------------------------------
        function N = get.NumChannels(f)
            if isfield(f.PrivateData,'NumChannels')
                N = f.PrivateData.NumChannels;
            end
        end
        %-----------------------------------------------------------------------
        function set.NumLinks(f, N)
            propName = 'NumLinks';
            validateattributes(N, {'double'}, {'positive', 'integer'}, ...
                [class(f) '.' propName], propName);
            
            f.PrivateData.NumLinks = N;
            if f.Constructed, initialize(f); end
        end
        %-----------------------------------------------------------------------
        function N = get.NumLinks(f)
            if isfield(f.PrivateData, 'NumLinks')
                N = f.PrivateData.NumLinks;
            end
        end
        %-----------------------------------------------------------------------
        function set.FilterBank(f, N)
            f.PrivateData.FilterBank = N;
        end
        %-----------------------------------------------------------------------
        function N = get.FilterBank(f)
            if isfield(f.PrivateData,'FilterBank')
                N = f.PrivateData.FilterBank;
            end
        end
        %-----------------------------------------------------------------------
        function set.FilterInputState(f, N)
            f.PrivateData.FilterInputState = N;
        end
        %-----------------------------------------------------------------------
        function N = get.FilterInputState(f)
            if isfield(f.PrivateData,'FilterInputState')
                N = f.PrivateData.FilterInputState;
            end
        end
        %-----------------------------------------------------------------------
        function set.FilterPhase(f, N)
            propName = 'FilterPhase';
            validateattributes(N, {'double'}, {}, ...
                [class(f) '.' propName], propName);
            
            f.PrivateData.FilterPhase = N;
        end
        %-----------------------------------------------------------------------
        function N = get.FilterPhase(f)
            if isfield(f.PrivateData,'FilterPhase')
                N = f.PrivateData.FilterPhase;
            end
        end
        %-----------------------------------------------------------------------
        function set.LastFilterOutputs(f, N)
            f.PrivateData.LastFilterOutputs = N;
        end
        %-----------------------------------------------------------------------
        function N = get.LastFilterOutputs(f)
            if isfield(f.PrivateData,'LastFilterOutputs')
                N = f.PrivateData.LastFilterOutputs;
            end
        end
        %-----------------------------------------------------------------------
        function set.LinearInterpIndex(f, N)
            propName = 'LinearInterpIndex';
            validateattributes(N, {'double'}, {}, ...
                [class(f) '.' propName], propName);
            
            f.PrivateData.LinearInterpIndex = N;
        end
        %-----------------------------------------------------------------------
        function N = get.LinearInterpIndex(f)
            if isfield(f.PrivateData,'LinearInterpIndex')
                N = f.PrivateData.LinearInterpIndex;
            end
        end
        %-----------------------------------------------------------------------
        function set.NumSamplesProcessed(f, N)
            propName = 'NumSamplesProcessed';
            validateattributes(N, {'double'}, {'nonnegative'}, ...
                [class(f) '.' propName], propName);
            
            f.NumSamplesProcessed = N;
        end
    end
end
% EOF