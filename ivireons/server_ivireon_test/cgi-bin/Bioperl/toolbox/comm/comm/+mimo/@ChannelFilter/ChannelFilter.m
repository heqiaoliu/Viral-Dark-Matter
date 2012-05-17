classdef ChannelFilter < mimo.BaseSigProc
    %ChannelFilter Defines channel filter class for MIMO package
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.4 $  $Date: 2009/11/13 04:14:14 $
    
    %===========================================================================
    % Read-Only properties
    properties (SetAccess = private)
        % Channel filter type
        ChannelFilterType = 'Discrete Multipath';
        % Channel filter alpha matrix.
        AlphaMatrix
        % Alpha matrix indices.
        % These indices indicate the start and stop tap indices for the significant
        % values of each row of AlphaMatrix.  They are used for computational
        % effiency in the channel filtering.
        AlphaIndices
    end
    
    %===========================================================================
    % Read-Only properties
    properties (SetAccess = private, Dependent)
        % Channel filter tap weights.
        TapGains
        % Alpha matrix indices - threshold for truncation in channel filtering
        % computation.
        AlphaTol
        % Channel filter delay.
        FilterDelay
    end
    
    %===========================================================================
    % Public properties
    properties (Dependent)
        % Input signal sample period.
        InputSamplePeriod
        % Multipath component delays.
        PathDelays
        % Number of links
        NumLinks
        % Number of transmit antennas
        NumTxAntennas
        % Number of receive antennas
        NumRxAntennas
        % Autocompute channel filter tap indices.
        AutoComputeTapIndices	%', 'strictbool');
        % Channel filter tap indices.
        TapIndices
        % Channel filter state.
        State
    end
    
    %===========================================================================
    % Public methods
    methods
        function h = ChannelFilter(varargin)
            %ChannelFilter  Construct a channel filter object.
            %
            %   Inputs:
            %     Ts     - Input signal sample period (s).
            %     tau    - Path delay vector (s).
            %     tapidx - Tap gain indices (integers).
            %   If tapidx is specified, auto-computation will be turned off.
            
            error(nargchk(0, 6, nargin));
            
            h.AutoComputeTapIndices = 1;
            
            numParam = length(varargin);
            
            % Initialize private data.
            h.basesigproc_initprivatedata;
            
            pd = h.PrivateData;
            pd.InputSamplePeriod = 1;
            pd.PathDelays = 0;
            pd.TapIndices = 0;
            pd.AutoComputeTapIndices = 1;
            pd.AlphaTol = 0.0;
            pd.State = complex(0);
            pd.NumLinks = 1;
            pd.NumTxAntennas = 1;
            pd.NumRxAntennas = 1;
            pd.TapGains = complex(0);
            
            h.PrivateData = pd;
            
            % Set properties if specified.
            p = {'InputSamplePeriod'
                'PathDelays'
                'NumLinks'
                'NumTxAntennas'
                'NumRxAntennas'
                'TapIndices'};
            set(h, p(1:numParam), varargin);
            
            % Autocompute tap indices if not specified.
            h.AutoComputeTapIndices = ~(numParam>=6);
            
            initialize(h);
            
            h.Constructed = true;
        end
        %-----------------------------------------------------------------------
        function h = copy(this)
            h = mimo.ChannelFilter(this.InputSamplePeriod(1),...
                this.PathDelays(1),this.NumLinks);
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
        function set.InputSamplePeriod(cf, Ts)
            propName = 'InputSamplePeriod';
            validateattributes(Ts, {'double'}, {'nonnegative'}, ...
                [class(cf) '.' propName], propName);
            
            cf.PrivateData.InputSamplePeriod = Ts;
            if cf.Constructed, initialize(cf); end
        end
        %-----------------------------------------------------------------------
        function Ts = get.InputSamplePeriod(cf)
            if isfield(cf.PrivateData, 'InputSamplePeriod')
                Ts = cf.PrivateData.InputSamplePeriod;
            end
        end
        %-----------------------------------------------------------------------
        function set.PathDelays(cf, tau)
            propName = 'PathDelays';
            validateattributes(tau, {'double'}, {'vector'}, ...
                [class(cf) '.' propName], propName);
            
            cf.PrivateData.PathDelays = tau;
            if cf.Constructed, initialize(cf); end
        end
        %-----------------------------------------------------------------------
        function tau = get.PathDelays(cf)
            if isfield(cf.PrivateData, 'PathDelays')
                tau = cf.PrivateData.PathDelays;
            end
        end
        %-----------------------------------------------------------------------
        function set.NumLinks(cf, N)
            propName = 'NumLinks';
            validateattributes(N, {'double'}, {'positive', 'integer', 'scalar'}, ...
                [class(cf) '.' propName], propName);
            
            cf.PrivateData.NumLinks = N;
            if cf.Constructed, initialize(cf); end
        end
        %-----------------------------------------------------------------------
        function N = get.NumLinks(cf)
            if isfield(cf.PrivateData, 'NumLinks')
                N = cf.PrivateData.NumLinks;
            end
        end
        %-----------------------------------------------------------------------
        function set.NumTxAntennas(cf, N)
            propName = 'NumTxAntennas';
            validateattributes(N, {'double'}, {'positive', 'integer', 'scalar'}, ...
                [class(cf) '.' propName], propName);
            
            cf.PrivateData.NumTxAntennas = N;
        end
        %-----------------------------------------------------------------------
        function N = get.NumTxAntennas(cf)
            if isfield(cf.PrivateData, 'NumTxAntennas')
                N = cf.PrivateData.NumTxAntennas;
            end
        end
        %-----------------------------------------------------------------------
        function set.NumRxAntennas(cf, N)
            propName = 'NumRxAntennas';
            validateattributes(N, {'double'}, {'positive', 'integer', 'scalar'}, ...
                [class(cf) '.' propName], propName);
            
            cf.PrivateData.NumRxAntennas = N;
        end
        %-----------------------------------------------------------------------
        function N = get.NumRxAntennas(cf)
            if isfield(cf.PrivateData, 'NumRxAntennas')
                N = cf.PrivateData.NumRxAntennas;
            end
        end
        %-----------------------------------------------------------------------
        function set.AutoComputeTapIndices(cf, v)
            cf.PrivateData.AutoComputeTapIndices = v;
            if cf.Constructed, initialize(cf); end
        end
        %-----------------------------------------------------------------------
        function v = get.AutoComputeTapIndices(cf)
            if isfield(cf.PrivateData, 'AutoComputeTapIndices')
                v = cf.PrivateData.AutoComputeTapIndices;
            end
        end
        %-----------------------------------------------------------------------
        function set.TapIndices(cf, tapidx)
            propName = 'TapIndices';
            validateattributes(tapidx, {'double'}, {'vector'}, ...
                [class(cf) '.' propName], propName);
            
            cf.AutoComputeTapIndices = 0;
            cf.PrivateData.TapIndices = tapidx;
            if cf.Constructed, initialize(cf); end
        end
        %-----------------------------------------------------------------------
        function tapidx = get.TapIndices(cf)
            if isfield(cf.PrivateData, 'TapIndices')
                tapidx = cf.PrivateData.TapIndices;
            end
        end
        %-----------------------------------------------------------------------
        function set.TapGains(cf, v)
            cf.PrivateData.TapGains = v;
        end
        %-----------------------------------------------------------------------
        function v = get.TapGains(cf)
            if isfield(cf.PrivateData, 'TapGains')
                v = cf.PrivateData.TapGains;
            end
        end
        %-----------------------------------------------------------------------
        function set.AlphaTol(cf, v)
            propName = 'AlphaTol';
            validateattributes(v, {'double'}, {'nonnegative'}, ...
                [class(cf) '.' propName], propName);
            
            cf.PrivateData.AlphaTol = v;
            if cf.Constructed, initialize(cf); end
        end
        %-----------------------------------------------------------------------
        function v = get.AlphaTol(cf)
            if isfield(cf.PrivateData, 'AlphaTol')
                v = cf.PrivateData.AlphaTol;
            end
        end
        %-----------------------------------------------------------------------
        function d = get.FilterDelay(h)
            % If the first tap index is negative, then the channel filter delay is
            % positive.  This is the usual case.  But if the first tap index is
            % positive, the channel filter delay is *negative*.  This is an unusual
            % case for which the smallest path delay is much greater than the
            % input signal's sample period.

            % Add the initial delay value.  TapIndices assumes the first
            % delay value is 0.
            d = -h.TapIndices(1) + round(h.PathDelays(1)/h.InputSamplePeriod);

            if d<0
                warning('comm:mimo_getChannelFilterDelay:negativedelay', ...
                    ['Smallest path delay is much greater than ' ...
                    'the input sample period, which causes a ' ...
                    'negative channel filter delay.']);
            end
        end
        %-----------------------------------------------------------------------
        function set.State(cf, v)
            cf.PrivateData.State = v;
        end
        function v = get.State(cf)
            if isfield(cf.PrivateData, 'State')
                v = cf.PrivateData.State;
            end
        end
        %-----------------------------------------------------------------------
    end
end
