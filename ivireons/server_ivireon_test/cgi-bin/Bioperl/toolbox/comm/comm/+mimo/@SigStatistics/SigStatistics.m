classdef SigStatistics < mimo.BaseClass
    %SigStatistics definition for MIMO package
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2009/02/13 15:11:05 $
    
    % Note that many properties are integers, e.g., buffer size, indices.
    % We do not employ data type checking for speed.

    %===========================================================================
    % Hidden properties
    properties (Hidden)
        % Private data in structure (for fast porting to C-MEX).
        % No special data types allowed here (so it can be read by C).
        % See buffer_initprivatedata.
        PrivateData = struct('NumChannels', 1, 'BufferSize', 1);
    end
    
    %===========================================================================
    % Public dependent properties
    properties (Dependent)
        % Buffer size
        BufferSize
        % Number of channels
        NumChannels
    end
    
    %===========================================================================
    % Public properties
    properties
        % Buffer enable
        Enable = 0;
        % Sampling period of signal
        SamplePeriod = 1;
        % Number of delay samples for autocorrelation
        NumDelays = 1024;
        % Number of frequencies for power spectrum
        NumFrequencies = 1024;
        % Domain for power spectrum
        FrequencyDomain
        % Power spectrum
        PowerSpectrum
        % Autocorrelation
        Autocorrelation
    end
    
    %===========================================================================
    % Rread-only Properties
    properties (SetAccess = private)
        % Buffer
        Buffer = 0;
        % Buffer index
        IdxNext = 1;
        % Number of new samples processed
        NumNewSamples = 0;
        % Number of samples processed (since reset)
        NumSamplesProcessed = 0;
        % Statistics ready flag
        Ready = 0;
        % Statistics count (for running means)
        Count = 0;
    end
    
    %===========================================================================
    % Public methods
    methods
        function h = SigStatistics(varargin)
            %SigStatistics  Construct a signal statistics object.
            %
            %  Inputs:
            %    h    - Signal statistics object
            %    Ts   - Sample period
            %    NB   - Signal buffer size
            %    NC   - Number of channels
            %    NF   - Number of frequencies for power spectrum
            
            error(nargchk(0, 4, nargin));
            
            % Initialize private data
            pd = h.PrivateData;
            pd.BufferSize = 1;
            pd.NumChannels = 1;
            h.PrivateData = pd;
            
            h.Autocorrelation = mimo.SigResponse;
            h.PowerSpectrum = mimo.SigResponse;
            
            % Set parameters if specified.
            if nargin
                p = {'SamplePeriod'
                    'BufferSize'
                    'NumChannels'
                    'NumFrequencies'};
                set(h, p(1:length(varargin)), varargin);
            end
            
            h.initialize;
            
            h.Constructed = true;
        end
        %-----------------------------------------------------------------------
        function h = copy(this)
            mc = metaclass(this(1));
            props = mc.Properties;
                
            for q=1:length(this)
                h(q) = mimo.SigStatistics; %#ok<AGROW>

                for p=1:length(props)
                    pr = props{p};
                    if (~pr.Dependent && ~pr.Transient)
                        h(q).(pr.Name) = this(q).(pr.Name); %#ok<AGROW>
                    end
                end
                
                % Copy buffer objects.
                h(q).Autocorrelation = copy(this(q).Autocorrelation);
                h(q).PowerSpectrum = copy(this(q).PowerSpectrum);
            end
        end
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function N = get.BufferSize(h)
            N = h.PrivateData.BufferSize;
        end
        %-----------------------------------------------------------------------
        function set.BufferSize(h, N)
            h.PrivateData.BufferSize = N;
            if h.Constructed, initialize(h); end
        end
        %-----------------------------------------------------------------------
        function N = get.NumChannels(h)
            N = h.PrivateData.NumChannels;
        end
        %-----------------------------------------------------------------------
        function set.NumChannels(h, N)
            h.PrivateData.NumChannels = N;
            if h.Constructed, initialize(h); end
        end
        %-----------------------------------------------------------------------
    end
end
