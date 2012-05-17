classdef FiltGaussian < mimo.BaseSigProc
    %FILTGAUSSIAN Defines filtgaussian class for MIMO package
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.3 $  $Date: 2009/05/23 07:48:34 $

    %===========================================================================
    % Read-Only properties
    properties (SetAccess = private)
        % Filter's autocorrelation function
        Autocorrelation
        % Filter's power spectrum
        PowerSpectrum
        % Statistics
        Statistics
    end

    %===========================================================================
    % Read-Only dependent properties
    properties (SetAccess = private, Dependent)
        % Filter state
        State
    end
    
    %===========================================================================
    % Read-Only hidden properties
    properties (SetAccess = private, Hidden)
        % Lock flag for impulse response and time domain
        LockImpulseResponse = true; %', 'strictbool');
    end
    
    %===========================================================================
    % Public dependent properties
    properties (Dependent)
        % Filter impulse response
        ImpulseResponse
        % Number of channels
        NumChannels
        % Number of links
        NumLinks
        % Square-root correlation matrix.
        SQRTCorrelationMatrix
        % Last outputs
        % This is initialized to (M*NL)x2, i.e., last two outputs for each
        % path/link combination.
        LastOutputs
        % White gaussian noise state
        WGNState
        % Output sample period
        OutputSamplePeriod
        % Cutoff frequency
        CutoffFrequency
        % Oversampling factor: N = 1/(fc*Ts)
        OversamplingFactor  = NaN;
        % Impulse response function (function handle)
        ImpulseResponseFcn
        % Time domain of filter response
        TimeDomain
        % Number of frequencies for spectra
        NumFrequencies
    end
    
    %===========================================================================
    % Public properties
    properties
        % Quasi-static flag
        QuasiStatic = true;
        % Doppler spectrum object
        DopplerSpectrum %', 'doppler.baseclass vector');
    end
    
    %===========================================================================
    % Public methods
    methods
        function h = FiltGaussian(varargin)
            %FiltGaussian  Construct a filtered Gaussian source object.
            %
            % See construct method for information on arguments.
            
            error(nargchk(0, 4, nargin));
            
            % Initialize private data.
            h.basesigproc_initprivatedata;
            
            pd = h.PrivateData;
            
            pd.NumChannels = 1; % paths
            pd.NumLinks = 1;
            pd.SQRTCorrelationMatrix = 1;
            pd.ImpulseResponse = 0;
            pd.LastOutputs = 0;
            pd.State = 0;
            pd.WGNState = 0;
            pd.OutputSamplePeriod = 1;
            pd.CutoffFrequency = 0;
            pd.OversamplingFactor = NaN;
            pd.ImpulseResponseFcn{1} = @jakes;
            pd.TimeDomain = zeros(size(pd.ImpulseResponse));
            pd.NumFrequencies = 1024;
            
            h.PrivateData = pd;
            
            % Initialize Statistics property.
            % This needs to be done first because set_numchannels uses it.
            h.Statistics = mimo.SigStatistics;
            
            % Set properties if specified.
            numParams = length(varargin);
            if (numParams>=2)
                setRates(h, varargin{1}, varargin{2});
            end
            p = {'NumChannels'
                'NumLinks'
                'NumFrequencies'};
            numExtraParams = numParams - 2;
            set(h, {p{1:numExtraParams}}, {varargin{3:end}});
            
            % Initialize SigResponse objects.
            h.PowerSpectrum = mimo.SigResponse;
            h.Autocorrelation = mimo.SigResponse;
            
            h.initialize;
            
            h.Constructed = true;
        end
        %-----------------------------------------------------------------------
        function h = copy(this)
            h = mimo.FiltGaussian(this.OutputSamplePeriod(1),...
                this.CutoffFrequency(1),this.NumChannels);

            mc = metaclass(h);
            props = mc.Properties;
            
            for p=1:length(props)
                pr = props{p};
                if (~pr.Dependent && ~pr.Transient)
                    h.(pr.Name) = this.(pr.Name);
                end
            end
            
            % Make copies of objects
            h.DopplerSpectrum = copy(this.DopplerSpectrum);
            h.Statistics = copy(this.Statistics);
            h.Autocorrelation = copy(this.Autocorrelation);
            h.PowerSpectrum = copy(this.PowerSpectrum);
        end
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function set.ImpulseResponse(s, IR)
            s.PrivateData.ImpulseResponse = IR;
        end
        %-----------------------------------------------------------------------
        function h = get.ImpulseResponse(s)
            if isfield(s.PrivateData, 'ImpulseResponse')
                h = s.PrivateData.ImpulseResponse;
            end
        end
        %-----------------------------------------------------------------------
        function set.NumChannels(s, N)
            propName = 'NumChannels';
            validateattributes(N, {'double'}, {'positive', 'integer'}, ...
                [class(s) '.' propName], propName);

            s.PrivateData.NumChannels = N;
            if length(s.Statistics)==1
                % One Statistics object for all channels, containing N channels
                s.Statistics.NumChannels = N;
            else
                % One Statistics object per channel, each one containing one channel
            end
        end
        %-----------------------------------------------------------------------
        function N = get.NumChannels(s)
            if isfield(s.PrivateData, 'NumChannels')
                N = s.PrivateData.NumChannels;
            end
        end
        %-----------------------------------------------------------------------
        function set.NumLinks(s, N)
            if s.PrivateData.NumLinks ~= N
                propName = 'NumLinks';
                validateattributes(N, {'double'}, {'positive', 'integer'}, ...
                [class(s) '.' propName], propName);
                
                s.PrivateData.NumLinks = N;
                if s.Constructed, initialize(s); end
            end
        end
        %----------------------------------------------------------------------
        function N = get.NumLinks(s)
            if isfield(s.PrivateData, 'NumLinks')
                N = s.PrivateData.NumLinks;
            end
        end
        %----------------------------------------------------------------------
        function set.SQRTCorrelationMatrix(s, R)
            s.PrivateData.SQRTCorrelationMatrix = R;
        end
        %----------------------------------------------------------------------
        function R = get.SQRTCorrelationMatrix(s)
            if isfield(s.PrivateData, 'SQRTCorrelationMatrix')
                R = s.PrivateData.SQRTCorrelationMatrix;
            end
        end
        %----------------------------------------------------------------------
        function set.LastOutputs(s, y)
            s.PrivateData.LastOutputs = y;
        end
        %----------------------------------------------------------------------
        function y = get.LastOutputs(s)
            if isfield(s.PrivateData, 'LastOutputs')
                y = s.PrivateData.LastOutputs;
            end
        end
        %----------------------------------------------------------------------
        function set.State(s, u)
            s.PrivateData.State = u;
        end
        %----------------------------------------------------------------------
        function u = get.State(s)
            if isfield(s.PrivateData, 'State')
                u = s.PrivateData.State;
            end
        end
        %----------------------------------------------------------------------
        function set.WGNState(s, u)
            sizeu = size(u);
            if ~isequal(sizeu, [1 1]) && ~isequal(sizeu, [2 1]) ...
                    || ~isreal(u),
                error('comm:mimo_filtgaussian:RandState', ...
                    'RandState must be a real scalar or 2-element column vector.');
            end
            s.PrivateData.WGNState = u(:);
        end
        %----------------------------------------------------------------------
        function u = get.WGNState(s)
            if isfield(s.PrivateData, 'WGNState')
                u = s.PrivateData.WGNState;
            end
        end
        %----------------------------------------------------------------------
        function set.QuasiStatic(s, v)
            propName = 'QuasiStatic';
            validateattributes(v, {'logical'}, {}, ...
                [class(s) '.' propName], propName);
            
            s.QuasiStatic = v;
        end
        %----------------------------------------------------------------------
        function set.OutputSamplePeriod(h, v)
            if h.OutputSamplePeriod ~= v
                propName = 'OutputSamplePeriod';
                validateattributes(v, {'double'}, {'vector'}, ...
                [class(h) '.' propName], propName);
                
                setRates(h, v, h.CutoffFrequency);
            end
        end
        %----------------------------------------------------------------------
        function v = get.OutputSamplePeriod(h)
            if isfield(h.PrivateData, 'OutputSamplePeriod')
                v = h.PrivateData.OutputSamplePeriod;
            end
        end
        %----------------------------------------------------------------------
        function set.CutoffFrequency(h, v)
            if h.CutoffFrequency ~= v
                propName = 'CutoffFrequency';
                validateattributes(v, {'double'}, {'vector'}, ...
                [class(h) '.' propName], propName);
                
                setRates(h, h.OutputSamplePeriod, v);
            end
        end
        %----------------------------------------------------------------------
        function v = get.CutoffFrequency(h)
            if isfield(h.PrivateData, 'CutoffFrequency')
                v = h.PrivateData.CutoffFrequency;
            end
        end
        %----------------------------------------------------------------------
        function set.OversamplingFactor(h, v)
            if h.OversamplingFactor ~= v
                propName = 'OversamplingFactor';
                validateattributes(v, {'double'}, {'vector'}, ...
                    [class(h) '.' propName], propName);
                
                if ~(h.QuasiStatic)
                    if (v<=0)
                        error('comm:mimo:FiltGaussian:setOversamplingFactorGreaterThanZero', ...
                            'Oversampling factor must be greater than zero.');
                    end
                    fc = h.CutoffFrequency;
                    Ts = 1./(v.*fc);
                    setRates(h, Ts, fc);
                else
                    if ~isnan(v)
                        warning('comm:mimo_filtgaussian:setOversamplingFactorQuasiStatic', ...
                            'Cannot set oversampling factor for quasi-static source.');
                    end
                end
            end
        end
        %----------------------------------------------------------------------
        function v = get.OversamplingFactor(h)
            if isfield(h.PrivateData, 'OversamplingFactor')
                v = h.PrivateData.OversamplingFactor;
            end
        end
        %----------------------------------------------------------------------
        function set.ImpulseResponseFcn(h, v)
            h.PrivateData.ImpulseResponseFcn = v;
        end
        %----------------------------------------------------------------------
        function v = get.ImpulseResponseFcn(h)
            if isfield(h.PrivateData, 'ImpulseResponseFcn')
                v = h.PrivateData.ImpulseResponseFcn;
            end
        end
        %----------------------------------------------------------------------
        function set.DopplerSpectrum(s, v)
            propName = 'DopplerSpectrum';
             validateattributes(v, {'doppler.baseclass'}, {'vector'}, ...
                [class(s) '.' propName], propName);
            
            s.DopplerSpectrum = v;
        end
        %----------------------------------------------------------------------
        function set.TimeDomain(h, v)
            if h.LockImpulseResponse
                error('comm:mimo_filtgaussian:setTimeDomain', ...
                    'TimeDomain must be set via registered impulse response function (ImpulseResponseFcn).');
            end
            if ~isequal(size(v), size(h.PrivateData.ImpulseResponse))
                error('comm:mimo_filtgaussian:setTimeDomainSize', ...
                    'Sizes of time domain and impulse response must be the same.');
            end
            h.PrivateData.TimeDomain = v;
        end
        %----------------------------------------------------------------------
        function v = get.TimeDomain(h)
            if isfield(h.PrivateData, 'TimeDomain')
                v = h.PrivateData.TimeDomain;
            end
        end
        %----------------------------------------------------------------------
        function set.NumFrequencies(h, v)
            if h.NumFrequencies ~= v
                propName = 'NumFrequencies';
                validateattributes(v, {'double'}, {'positive', 'integer'}, ...
                    [class(h) '.' propName], propName);
                
                h.PrivateData.NumFrequencies = v;
                if h.Constructed, initialize(h); end
            end
        end
        %----------------------------------------------------------------------
        function v = get.NumFrequencies(h)
            if isfield(h.PrivateData, 'NumFrequencies')
                v = h.PrivateData.NumFrequencies;
            end
        end
    end
end
