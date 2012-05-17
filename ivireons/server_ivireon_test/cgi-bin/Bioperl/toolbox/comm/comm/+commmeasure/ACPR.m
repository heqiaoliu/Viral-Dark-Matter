classdef (Sealed) ACPR <   commmeasure.AbstractPowerMeasurement & sigutils.sorteddisp & sigutils.pvpairs
    %ACPR Adjacent Channel Power Ratio measurements
    %   H = commmeasure.ACPR returns a default adjacent channel power ratio
    %   (ACPR) object H. The ACPR object can be used to measure ACPR, as well
    %   as main and adjacent channel powers.
    %
    %   H = commmeasure.ACPR('PropertyName',PropertyValue,...) returns an ACPR
    %   object H, with property values set to PropertyValues.  See properties
    %   list below for valid PropertyNames.
    %
    %   commmeasure.ACPR methods:
    %       run                           - Obtain ACPR and power measurements
    %       reset                         - Reset the ACPR object
    %       disp                          - Display relevant ACPR properties
    %       copy                          - Copy the ACPR object
    %
    %   commmeasure.ACPR properties:
    %       Type                          - 'ACPR Measurements'. Read-only.
    %       NormalizedFrequency           - Normalized frequency flag.
    %       Fs                            - Sampling frequency of input data.
    %       MainChannelFrequency          - Main channel's center frequency.
    %       MainChannelMeasBW             - Measurement bandwidth for main channel.
    %       AdjacentChannelOffset         - Adjacent channel frequency offsets.
    %       AdjacentChannelMeasBW         - Measurement bandwidths for adjacent channels.
    %       MeasurementFilter             - Measurement filter.
    %       SpectralEstimatorOption       - Spectral estimator control option.
    %       SegmentLength                 - Segment length for the spectral estimator.
    %       OverlapPercentage             - Overlap percentage for the spectral estimator.
    %       WindowOption                  - Window option for the  spectral estimator.
    %       SidelobeAtten                 - Sidelobe attenuation for Chebyshev windows.
    %       FrequencyResolutionOption     - Frequency resolution control option.
    %       FrequencyResolution           - Frequency resolution.
    %       FFTLengthOption               - FFT length control option.
    %       FFTLength                     - FFT length for the spectral estimator.
    %       MaxHold                       - Maximum-hold control.
    %       PowerUnits                    - Power units.
    %       FrameCount                    - Number of processed signal frames. Read-only.
    %
    %    Example:
    %       % Measure ACPR of a 16-QAM signal with symbol rate of 3.84 Msps at
    %       % -5 and +5 MHz frequency offsets. Set all measurement bandwidths
    %       % to 3.84 MHz. Sampling frequency is set to 8 samples per symbol.
    %       Fs = 3.84e6*8;                              % 8 samples per symbol
    %       M  = 16;                                    % Alphabet size
    %       x  = randi([0 M-1],5000,1);                 % Message signal
    %       hMod = modem.qammod(M);                     % Use 16-QAM modulation.
    %       y = modulate(hMod,x);                       % Modulate the signal
    %       yPulse = rectpulse(y,8);                    % Rectangular pulse shaping.
    %       h = commmeasure.ACPR(...
    %              'MainChannelFrequency',0,...
    %              'MainChannelMeasBW',3.84e6, ...
    %              'AdjacentChannelOffset',[-5e6 5e6],...
    %              'AdjacentChannelMeasBW',3.84e6, ...
    %              'Fs',Fs)
    %      [ACPR mainChnlPwr adjChnlPwr] = run(h,yPulse)
    %
    %   See also commmeasure
    
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.10.4 $  $Date: 2009/07/27 20:09:29 $
    
    %===========================================================================
    % Read-only properties
    %===========================================================================
    properties (SetAccess = private)
        %Type   Measurement type. This is read-only.
        %   The type is ACPR Measurement object.
        Type = 'ACPR Measurement';
        %FrameCount Frame count. This is read-only.
        %   Number of processed signal frames. This property is cleared when
        %   calling the 'reset' method.
        FrameCount = 0;
    end
    %===========================================================================
    % Public properties
    %===========================================================================
    properties
        %MainChannelFrequency Main channel's center frequency (normalized or in Hz).
        %   The main channel's power will be measured in a specified bandwidth
        %   centered at the MainChannelFrequency value. 
        %   Default value is 0.
        MainChannelFrequency = 0;
        %MainChannelMeasBW Main channel's measurement bandwidth (normalized or in Hz).
        %   The main channel's power will be measured within the specified
        %   MainChannelMeasBW bandwidth centered at the main channel's
        %   frequency. 
        %   Default value is 0.1 when NormalizedFrequency is true, and 0.1*Fs/2
        %   when NormalizedFrequency is false.
        MainChannelMeasBW = 0.1;
        %AdjacentChannelOffset Adjacent channel frequency offsets (normalized or in Hz).
        %   The AdjacentChannelOffset property is a vector of frequency offsets
        %   that will define the location of adjacent channels of interest. The
        %   offsets indicate the distance between the main channel's center
        %   frequency and the adjacent channels' center frequency. Positive
        %   offsets correspond to adjacent channels located to the right of the
        %   main channel's spectrum, and negative offsets correspond to adjacent
        %   channels located at frequencies below the main channel's center
        %   frequency.
        %   Default value is [-0.2 0.2] when NormalizedFrequency is true, and
        %   [-0.2 0.2]*Fs/2 when NormalizedFrequency is false.
        AdjacentChannelOffset = [-0.2 0.2];
        % AdjacentChannelMeasBW Measurement bandwidths for adjacent channels (normalized or in Hz).
        %   Power for each adjacent channel will be measured within the
        %   bandwidth specified in the AdjacentChannelMeasBW property. Each
        %   bandwidth will be centered at the frequency defined by the
        %   corresponding frequency offset in AdjacentChannelOffset.
        %   AdjacentChannelMeasBW may be a single value or a vector of length
        %   equal to the number of specified offsets in AdjacentChannelOffset.
        %   In the former case, all power measurements will be obtained within
        %   equal measurement bandwidths. 
        %   Default value is 0.1 when NormalizedFrequency is true, and 0.1*Fs/2
        %   when NormalizedFrequency is false.
        AdjacentChannelMeasBW = 0.1;
        %PowerUnits Power units.
        %   Specify power measurement units as one of [{'dBm'} | 'dBW' |
        %   'linear']. If this property is set to 'dBm', or 'dBW', then ACPR
        %   measurements are given in dBc (adjacent channel power referenced to
        %   main channel's power). If this property is set to linear, then ACPR
        %   measurements are given in linear units.
        PowerUnits = 'dBm';
        %MeasurementFilter Measurement filter
        %   Handle for a user-specified dfilt object. The user may specify a
        %   measurement filter that will be applied to the main channel and each
        %   of the adjacent channel bands prior to measuring the average power.
        %   The default filter is an all pass filter that will have no effects
        %   on the input data. The specified filter must be an FIR filter
        %   contained in a dfilt object and its response must be centered at DC.
        %   The filter response will be automatically shifted and applied at
        %   each of the specified main and adjacent channel center frequencies
        %   prior to obtaining the average power measurements.
        %   NOTE: when a filter is specified, power is still measured within the
        %   specified bandwidths in the MainChannelMeasBW, and
        %   AdjacentChannelMeasBW properties.
        MeasurementFilter
    end
    %===========================================================================
    % Dependent, public properties
    %===========================================================================
    properties (Dependent = true)
        %NormalizedFrequency Normalized frequency
        %   The NormalizedFrequency property will be true after construction if
        %   the user has not provided a value for the Fs property. In this
        %   scenario it is assumed that input/output frequency values are
        %   normalized (in the [-1 1] range). The Fs property is irrelevant
        %   (i.e. it may not be set and will not be displayed by the disp
        %   method) unless NormalizedFrequency is set to false. When
        %   NormalizedFrequency is toggled from true to false, Fs defaults to
        %   the last value it was set to (unity if the user did not input an Fs
        %   value). After construction, toggling NormalizedFrequency from false
        %   to true will cause all frequency-related properties in the
        %   commmeasure.ACPR object to be normalized by the current value of Fs.
        %   Toggling NormalizedFrequency from true to false will cause all
        %   frequency properties to be un-normalized by the last value of Fs.
        NormalizedFrequency
        %FS     Sampling frequency
        %   This property holds the input signal sampling frequency. This
        %   property is irrelevant (i.e. may not be set by the user, and will
        %   not be displayed by the disp method) unless the NormalizedFrequency
        %   property is set to false. When NormalizedFrequency is toggled from
        %   true to false, Fs defaults to the last value it was set to.
        %   Fs defaults to unity if the user did not input an Fs value.
        Fs
    end
    %===========================================================================
    % Private, hidden properties
    %===========================================================================
    properties (Access = private, Hidden = true)
        %PrivDataLength
        %   This property keeps track of the input data length for the current
        %   set of measurements. If data length changes from one call to the run
        %   method to the next without a prior call to the reset method, then a
        %   warning is sent and a reset is forced.
        PrivDataLength = 0;
        %PrivMultiBandFilter handle for a commmeasure.MultiBandFilter object
        PrivMultiBandFilter
    end
    %===========================================================================
    % Define Public Methods
    %===========================================================================
    methods
        %=======================================================================
        function obj = ACPR(varargin)
            %ACPR constructor
            
            %Set defaults
            obj.PrivMultiBandFilter = commmeasure.MultiBandFilter;
            obj.MeasurementFilter = dfilt.dffir(1);
            obj.PrivResetFlag = true;
            obj.PrivNormalizedFrequency = true;
            obj.PrivFs = 1;
            
            %Initialize spectral estimator
            %Set PrivSpectralEstimator to a default Welch Estimator
            obj.PrivSpectralEstimator = spectrum.welch;
            resetSpectralEstimator(obj,'Hamming',64,0);
            
            if nargin
                % There are input arguments, so initialize with
                % property-value pairs.
                checkValidPropertyValues(obj, varargin{:});
                initPropValuePairs(obj, varargin{:});
            end
            
            obj.PrivMultiBandFilter.DcCenteredFilter = copy(obj.MeasurementFilter);
            %Initialize filters
            if ~isallpass(obj.MeasurementFilter)
                %Set correct value for Fs
                Fs = 2;
                if ~obj.NormalizedFrequency
                    Fs = obj.Fs;
                end
                filterOffsets = [obj.MainChannelFrequency ...
                    obj.MainChannelFrequency+obj.AdjacentChannelOffset]/(Fs/2);
                computeShiftedTF(obj.PrivMultiBandFilter,filterOffsets);
            end
        end
        %=======================================================================
        function varargout = run(obj, x)
            %RUN Get a new set of measurements from input data column vector X.
            %   ACPR = RUN(H,X) returns a vector of adjacent channel power ratio
            %   measurements, ACPR, obtained from the input data column vector,
            %   X, at the specified frequency bands of interest.
            %   [ACPR, MAINPOW] = RUN(H,X) returns the measured main channel
            %   power, MAINPOW.
            %   [ACPR, MAINPOW, ADJPOW] = RUN(H,X) returns a vector with
            %   measured adjacent channel powers, ADJPOW.
            %   Frame count, max-hold spectrum, and filter states inside the
            %   commmeasure.ACPR object will be updated and saved at each call
            %   to RUN(H,X) until the RESET(H) method is called.
            %   ACPR measurements are defined as:
            %
            %            ADJPOW * MainChannelMeasBW
            %   ACPR = --------------------------------
            %          MAINPOW * AdjacentChannelMeasBW
            %
            %   See also commmeasure.ACPR, commmeasure.ACPR/reset,
            %   commmeasure.ACPR/disp, commmeasure.ACPR/copy
            
            %validate datatype for input x
            validateattributes(x,...
                {'double'},...
                {'finite','column','vector'}, ...
                'commmeasure.ACPR/run',...
                'X');
            
            %Length of AdjacentChannelMeasBW can only be 1 or equal to length
            %of AdjacentChannelOffset
            if ~(length(obj.AdjacentChannelMeasBW) == 1 || ...
                    length(obj.AdjacentChannelMeasBW) == ...
                    length(obj.AdjacentChannelOffset))
                error(generatemsgid('invalidAdjacentChannelMeasBWLength'),...
                    (['Length of AdjacentChannelMeasBW property can only be ',...
                    '1 or equal to length of AdjacentChannelOffset.']));
            end
            %Initialize all ACPR object components if run is being called for
            %the first time or if we come from a reset state
            if obj.PrivResetFlag
                
                %Get current data length
                obj.PrivDataLength = length(x);
                
                initAll(obj,x);
                
                %set PrivResetFlag to false until next reset or if object is re
                %instantiated
                obj.PrivResetFlag = false;
            else
                %Warn and reset object if:
                % 1) Data vector length changes from one call to the run metod
                %    to another.
                % 2) Filter has changed
                
                if ~isequal(obj.PrivDataLength,length(x)) ||...
                        ~isequal(get(obj.MeasurementFilter), ...
                        get(obj.PrivMultiBandFilter.DcCenteredFilter))
                    
                    obj.PrivDataLength = length(x);
                    
                    warnAboutInvalidStateChange(obj,'commmeasure.ACPR');
                    
                    initAll(obj,x);
                    obj.FrameCount = 0;
                end
            end
            
            %Filter data if not an all-pass filter
            if isallpass(obj.MeasurementFilter)
                data = x;
            else
                data = filterData(obj.PrivMultiBandFilter,x);
            end
            
            %Get PSD and save it in PrivPSD
            computePSD(obj,data);
            
            %Compute power measurements in the bands of interest Initialize
            %variables
            numOffsets = length(obj.AdjacentChannelOffset);
            ACPR = zeros(1,numOffsets);
            adjacentChannelPower = zeros(1,numOffsets);
            
            %Index the data in PrivPSD If we have an all-pass filter case, then
            %PrivPSD contains a single data column and all power measurements
            %will be obtained with this data. If filter is not all-pass, then
            %first column of PrivPSD contains data filtered with a filter
            %shifted to the main channel center frequency. The rest of the
            %columns contain data filtered with filters shifted to the adjacent
            %channel center frequencies.
            dataIdx = ones(numOffsets,1);
            if size(data,2)> 1
                dataIdx = 2:numOffsets+1;
            end
            
            %Main channel power
            %Data for main channel is always in the first column of PrivPSD
            %regardless of the filter type (all-pass or not all-pass)
            lowerF = obj.MainChannelFrequency - obj.MainChannelMeasBW/2;
            higherF = lowerF + obj.MainChannelMeasBW;
            
            %Compute average power
            mainChannelPower = computeAvgPower(obj,lowerF, higherF,1); %linear
            
            %Adjacent channel powers
            %User may have specified only one value for AdjacentChannelMeasBW
            thisAdjacentChannelMeasBW = obj.AdjacentChannelMeasBW;
            if length(thisAdjacentChannelMeasBW)==1
                thisAdjacentChannelMeasBW = ...
                    ones(1,numOffsets)*thisAdjacentChannelMeasBW;
            end
            
            for adjIdx = 1:numOffsets
                lowerF = obj.MainChannelFrequency + ...
                    obj.AdjacentChannelOffset(adjIdx)- ...
                    thisAdjacentChannelMeasBW(adjIdx)/2;
                higherF = lowerF + thisAdjacentChannelMeasBW(adjIdx);
                
                %Compute average power
                adjacentChannelPower(adjIdx) = computeAvgPower(obj,lowerF, ...
                    higherF, dataIdx(adjIdx)); %linear
                
                %Normalize power measurements according to measure BW
                normFactor = ...
                    obj.MainChannelMeasBW/thisAdjacentChannelMeasBW(adjIdx);
                ACPR(adjIdx) = ...
                    normFactor*(adjacentChannelPower(adjIdx)/mainChannelPower);
            end
            
            %Convert to desired units
            if strcmpi(obj.PowerUnits,'dbw') || strcmpi(obj.PowerUnits,'dbm')
                mainChannelPower = 10*log10(mainChannelPower); %dBW
                adjacentChannelPower = 10*log10(adjacentChannelPower); %dBW
                if  strcmpi(obj.PowerUnits,'dbm')
                    mainChannelPower = mainChannelPower + 30; %dBm
                    adjacentChannelPower = adjacentChannelPower + 30; %dBm
                end
                ACPR = 10*log10(ACPR); %dBc
            end
            
            obj.FrameCount = obj.FrameCount + 1;                        
            
            if nargout > 3
                error(generatemsgid('tooManyOutputArguments'),...
                    ('Too many output arguments.'));
            else
                varargout{1} = ACPR;
                if nargout > 1
                    varargout{2} = mainChannelPower;
                    if nargout > 2
                        varargout{3} = adjacentChannelPower;
                    end
                end                
            end
        end
        %=======================================================================
        function reset(obj)
            %RESET Reset the ACPR object H.
            %   RESET(H) clears the max-hold spectrum (relevant if obtaining
            %   measurements with the MaxHold property set to 'On'), clears the
            %   FrameCount property, initializes the shifted filter transfer
            %   functions, and initializes the internal spectral estimator
            %   according to the user specifications.
            %
            %   See also commmeasure.ACPR, commmeasure.ACPR/run,
            %   commmeasure.ACPR/disp,commmeasure.ACPR/copy.
            
            obj.PrivResetFlag = true;
            obj.FrameCount = 0;
        end
        %=======================================================================
        function h = copy(obj)
            %COPY Copy the ACPR object
            %   HCOPY = COPY(H) copy the ACPR object H and return in HCOPY. H
            %   and HCOPY are independent but identical objects, i.e. modifying
            %   the H object does not affect HCOPY object.
            %
            %   See also commmeasure.ACPR, commmeasure.ACPR/run,
            %   commmeasure.ACPR/disp,commmeasure.ACPR/reset.
            
            for p=1:length(obj)
                
                hTemp = commmeasure.ACPR;
                
                %visible
                hTemp.PrivNormalizedFrequency = obj.PrivNormalizedFrequency;
                hTemp.PrivFs = obj.PrivFs;
                hTemp.MainChannelFrequency = obj.MainChannelFrequency;
                hTemp.MainChannelMeasBW = obj.MainChannelMeasBW;
                hTemp.AdjacentChannelOffset = obj.AdjacentChannelOffset;
                hTemp.AdjacentChannelMeasBW = obj.AdjacentChannelMeasBW;
                hTemp.MeasurementFilter = copy(obj.MeasurementFilter);
                hTemp.SpectralEstimatorOption = obj.SpectralEstimatorOption;
                hTemp.PrivSegmentLength = obj.PrivSegmentLength;
                hTemp.PrivOverlapPercentage = obj.PrivOverlapPercentage;
                hTemp.PrivWindowOption = obj.PrivWindowOption;
                hTemp.PrivSidelobeAtten = obj.PrivSidelobeAtten;
                hTemp.PrivFrequencyResolutionOption = ...
                    obj.PrivFrequencyResolutionOption;
                hTemp.PrivFrequencyResolution = obj.PrivFrequencyResolution;
                hTemp.FFTLengthOption = obj.FFTLengthOption;
                hTemp.PrivFFTLength = obj.PrivFFTLength;
                hTemp.MaxHold = obj.MaxHold;
                hTemp.PowerUnits = obj.PowerUnits;
                hTemp.FrameCount = obj.FrameCount;
                
                %Hidden
                hTemp.PrivSpectralEstimator = copy(obj.PrivSpectralEstimator);
                if ~isempty(obj.PrivSpectralEstimatorOpts)
                    hTemp.PrivSpectralEstimatorOpts = ...
                        copy(obj.PrivSpectralEstimatorOpts);
                end
                hTemp.PrivResetFlag = obj.PrivResetFlag;
                hTemp.PrivPSD = obj.PrivPSD;
                hTemp.PrivDataLength = obj.PrivDataLength;
                hTemp.PrivFrequencyVector = obj.PrivFrequencyVector;
                hTemp.PrivMultiBandFilter = copy(obj.PrivMultiBandFilter);
                
                h(p) = hTemp; %#ok<AGROW>
            end
        end
        %=======================================================================
        % Get/Set methods
        %=======================================================================
        function  set.NormalizedFrequency(obj,value)
            %SET NormalizedFrequency property
            
            %Check data type - logical scalar
            validateattributes(value,{'logical'},...
                {'scalar'},...
                'commmeasure.ACPR',...
                'NormalizedFrequency');
            
            %Normalize other properties of NormalizedFrequency has been set to
            %true.
            Fs = obj.PrivFs;
            if value && ~obj.PrivNormalizedFrequency
                obj.MainChannelFrequency = obj.MainChannelFrequency/(Fs/2);
                obj.MainChannelMeasBW = obj.MainChannelMeasBW/(Fs/2);
                obj.AdjacentChannelOffset = obj.AdjacentChannelOffset/(Fs/2);
                obj.AdjacentChannelMeasBW = obj.AdjacentChannelMeasBW/(Fs/2);
                obj.PrivFrequencyResolution = obj.PrivFrequencyResolution/(Fs/2);
            end
            if ~value && obj.PrivNormalizedFrequency
                obj.MainChannelFrequency = obj.MainChannelFrequency*(Fs/2);
                obj.MainChannelMeasBW = obj.MainChannelMeasBW*(Fs/2);
                obj.AdjacentChannelOffset = obj.AdjacentChannelOffset*(Fs/2);
                obj.AdjacentChannelMeasBW = obj.AdjacentChannelMeasBW*(Fs/2);
                obj.PrivFrequencyResolution = obj.PrivFrequencyResolution*(Fs/2);
            end
            
            %Set private property (NormalizedFrequency is dependent)
            obj.PrivNormalizedFrequency = value;
            
            %if not instantiating an ACPR object then reset it
            checkResetFlagAndReset(obj);
        end
        %=======================================================================
        function  nf = get.NormalizedFrequency(obj)
            %GET NormalizedFrequency property
            nf = obj.PrivNormalizedFrequency;
        end
        %=======================================================================
        function set.Fs(obj, fs)
            %SET Fs property
            
            %Check data type (positive double scalar)
            validateattributes(fs,{'double'},...
                {'finite','positive','scalar'},...
                'commmeasure.ACPR',...
                'Fs');
            
            %Set private property (Fs is dependent)
            obj.PrivFs = fs;
            
            %Warn if property is currently irrelevant
            if obj.NormalizedFrequency
                warnAboutIrrelevantSet(obj,'Fs','commmeasure.ACPR');
            else
                %if not instantiating an ACPR object then reset it
                checkResetFlagAndReset(obj);
            end
        end
        %=======================================================================
        function fs= get.Fs(obj)
            %GET Fs property
            fs = obj.PrivFs;
        end
        %=======================================================================
        function set.MeasurementFilter(obj, filtObj)
            %SET MeasurementFilter property
            
            %Check that object is a dfilt and FIR
            if ~isa(filtObj,'dfilt.dffir')
                error(generatemsgid('invalidFilterObject'),...
                    ('Measurement filter must be a dfilt.dffir object'));
            end
            %Set property
            obj.MeasurementFilter = filtObj;
            
            %if not instantiating an ACPR object then reset it
            checkResetFlagAndReset(obj);
        end
        %=======================================================================
        function  set.MainChannelFrequency(obj,mainfreq)
            %SET MainChannelFrequency property
            
            %Check data type (double scalar)
            validateattributes(mainfreq,{'double'},...
                {'finite','scalar','real'}, ...
                'commmeasure.ACPR', ...
                'MainChannelFrequency');
            
            %Set property
            obj.MainChannelFrequency =  mainfreq;
            
            %if not instantiating an ACPR object then reset it
            checkResetFlagAndReset(obj);
        end
        %=======================================================================
        function  set.MainChannelMeasBW(obj,measBw)
            %SET MainChannelMeasBW property
            
            %Check data type (positive double scalar)
            validateattributes(measBw,{'double'},...
                {'finite','positive','scalar'},...
                'commmeasure.ACPR',...
                'MainChannelMeasBW');
            
            %Set property
            obj.MainChannelMeasBW =  measBw;
            
            %if not instantiating an ACPR object then reset it
            checkResetFlagAndReset(obj);
        end
        %=======================================================================
        function  set.AdjacentChannelOffset(obj,adjoffset)
            %SET AdjacentChannelOffset property
            
            %Check data type (finite double row vector)
            validateattributes(adjoffset,{'double'},...
                {'finite','row','vector','real'},...
                'commmeasure.ACPR',...
                'AdjacentChannelOffset');
            
            %Set property
            obj.AdjacentChannelOffset =  adjoffset;
            
            %if not instantiating an ACPR object then reset it
            checkResetFlagAndReset(obj);
        end
        %=======================================================================
        function  set.AdjacentChannelMeasBW(obj,adjchnlbw)
            %SET AdjacentChannelMeasBW property
            
            %Check data type (finite double row vector)
            validateattributes(adjchnlbw,{'double'},...
                {'finite','positive','row','vector'},...
                'commmeasure.ACPR',...
                'AdjacentChannelMeasBW');
            
            %Set property
            obj.AdjacentChannelMeasBW =  adjchnlbw;
            
            %if not instantiating an ACPR object then reset it
            checkResetFlagAndReset(obj);
        end
        %=======================================================================
        function set.PowerUnits(obj,value)
            %SET PowerUnits property
            
            %Check data type (enum)
            validCell = {'dBm',...
                'dBW', ...
                'linear'};
            out = validatestring(value, validCell);
            
            obj.PowerUnits = out;
        end
    end %public methods
    %===========================================================================
    % Define Private Methods
    %===========================================================================
    methods (Access = private)
        function initAll(obj,x)
            %initAll Initialize all the components of the ACPR object
            
            %Initialize spectral estimator
            %Initialize window length of default spectral estimator
            if strcmpi(obj.SpectralEstimatorOption,'default')
                initSpectralEstimatorSegmentLength(obj,x);
            end
            %Initialize a dspopts.spectrum object
            initSpectralEstimatorOptions(obj,x);
            
            %Initialize filters only when filter is not an all-pass filter, call
            %this initialization only if the filter changed. Also initialize the
            %PrivPSD matrix with nCol columns.
            if ~isallpass(obj.MeasurementFilter)
                if ~isequal(get(obj.MeasurementFilter), ...
                        get(obj.PrivMultiBandFilter.DcCenteredFilter))
                    obj.PrivMultiBandFilter.DcCenteredFilter = ...
                        copy(obj.MeasurementFilter);
                    %Calculate offsets where the filter will be shifted
                    %Set correct value for Fs
                    Fs = 2;
                    if ~obj.NormalizedFrequency %#ok<*MCNPN>
                        Fs = obj.Fs;
                    end
                    filterOffsets = [obj.MainChannelFrequency ...
                        obj.MainChannelFrequency+obj.AdjacentChannelOffset]/(Fs/2);
                    computeShiftedTF(obj.PrivMultiBandFilter,filterOffsets);
                else
                    resetShiftedTF(obj.PrivMultiBandFilter);
                end
                %If we enter this case, it means we are dealing with a
                %non-all-pass filter so set the number of columns for PrivPSD
                %according to number of offsets. The i-th column of PrivPSD will
                %contain a PSD estimate for the i-th band of interest calculated
                %with data filtered with a filter shifted to this band. The
                %first column corresponds to the main channel's band. The rest
                %of the columns correspond to the adjacent bands in the order
                %they were specified in AdjacentChannelOffset.
                nCol =  length(obj.AdjacentChannelOffset)+1;
            else
                if ~isequal(get(obj.MeasurementFilter), ...
                        get(obj.PrivMultiBandFilter.DcCenteredFilter))
                    obj.PrivMultiBandFilter.DcCenteredFilter = ...
                        copy(obj.MeasurementFilter);
                end
                nCol = 1; %number of columns in PrivPSD for all-pass case
            end
            
            %Initialize the PSD buffer
            initPrivPSD(obj,nCol);
        end
        %=======================================================================
        function checkValidPropertyValues(obj,varargin)
            %checkValidPropertyValues Check inputs at construct time.
            %   Validate some input pairs, set NormalizedFrequency to false if
            %   the user specified an Fs value, and set default values for
            %   frequency related properties.
            
            nPropValue = length(varargin);
            if floor(nPropValue/2) ~= nPropValue/2
                error(generatemsgid('InvalidParamValue'), ['Number of ' ...
                    'values must be same as number of properties.']);
            end
            
            if ~iscellstr(varargin(1:2:end))
                error(generatemsgid('InvalidPropValue'), ...
                    ['Property names must be strings.  Type '...
                    '"help %s" for proper usage.'], class(obj));
            end
            
            %Check if Fs is being set and change NormalizedFrequency to false.
            %Check if Fs has been specified and if one or more of the following
            %properties has not been specified, set its default value, to a
            %value congruent with Fs: MainChannelMeasBW, AdjacentChannelOffset,
            %AdjacentChannelMeasBW. Check if normalized frequency was not set to
            %true while simultaneously setting Fs to some value. Then Fs should
            %be forced to 1.
            idxNF = strmatch('NormalizedFrequency',varargin(1:2:end),'exact');
            if ~isempty(idxNF)
                NFval = varargin{2*idxNF};
            else
                NFval = false;
            end
            
            idxFs = strmatch('Fs',varargin(1:2:end),'exact');
            
            if ~isempty(idxFs)
                if NFval
                    %user did specify NormalizedFrequency as true so force Fs
                    %to 2
                    Fs = 2;
                else
                    %The user did specify Fs and did not specify
                    %'NormalizedFrequency', or specified 'NormalizedFrequency'
                    %as false so we can set obj.NormalizedFrequency to false and
                    %Fs to the specified value.
                    obj.PrivNormalizedFrequency = false;
                    Fs = varargin{2*idxFs};
                    %Check Fs data type or an invalid Fs will cause an error
                    %while setting another frequency related property in the
                    %operations below and the error message will not provide
                    %correct information of the error cause.
                    validateattributes(Fs,{'double'},...
                        {'finite','positive','scalar'},...
                        'commmeasure.ACPR',...
                        'Fs');
                end
            else %user did not specify Fs
                Fs = 2;
            end
            %set default values according to Fs
            idx = strmatch('AdjacentChannelOffset',varargin(1:2:end),'exact');
            if isempty(idx)
                obj.AdjacentChannelOffset = obj.AdjacentChannelOffset*(Fs/2);
            end
            idx = strmatch('AdjacentChannelMeasBW',varargin(1:2:end),'exact');
            if isempty(idx)
                obj.AdjacentChannelMeasBW = obj.AdjacentChannelMeasBW*(Fs/2);
            end
            idx = strmatch('MainChannelMeasBW',varargin(1:2:end),'exact');
            if isempty(idx)
                obj.MainChannelMeasBW = obj.MainChannelMeasBW *(Fs/2);
            end
            idx = strmatch('FrequencyResolution',varargin(1:2:end),'exact');
            if isempty(idx)
                obj.PrivFrequencyResolution = obj.PrivFrequencyResolution*(Fs/2);
            end
        end
    end %private methods
    %===========================================================================
    % Define Protected Methods
    %===========================================================================
    methods (Access = protected)
        function sortedList = getSortedPropDispList(obj)
            % getSortedPropDispList
            %   Get the sorted list of the properties to be displayed.
            %   Do not display irrelevant properties.
            sortedList = {...
                'Type', ...
                'NormalizedFrequency', ...
                'Fs', ...
                'MainChannelFrequency', ...
                'MainChannelMeasBW', ...
                'AdjacentChannelOffset', ...
                'AdjacentChannelMeasBW', ...
                'MeasurementFilter',...
                'SpectralEstimatorOption',...
                'SegmentLength', ...
                'OverlapPercentage',...
                'WindowOption',...
                'SidelobeAtten',...
                'FrequencyResolutionOption',...
                'FrequencyResolution', ...
                'FFTLengthOption', ...
                'FFTLength',...
                'MaxHold', ...
                'PowerUnits', ...
                'FrameCount'};
            
            idx = [];
            %Do not display Fs when NormalizedFrequency = true
            if obj.NormalizedFrequency
                idx = [idx strmatch('Fs',sortedList,'exact')];
            end
            
            %Display options controlled by values in 'SpectralEstimatorOption'
            if strcmpi(obj.SpectralEstimatorOption,'default')
                
                idx = [idx strmatch('SegmentLength',sortedList,'exact')];
                idx = [idx strmatch('OverlapPercentage',sortedList,'exact')];
                idx = [idx strmatch('WindowOption',sortedList,'exact')];
                idx = [idx strmatch('SidelobeAtten',sortedList,'exact')];
                
                %Do not display FrequencyResolution if
                %FrequencyResolutionOption is equal to 'Inherit from input
                %dimensions'
                if strcmpi(obj.PrivFrequencyResolutionOption, ...
                        'inherit from input dimensions')
                    idx = [idx strmatch('FrequencyResolution',sortedList,'exact')];
                end
            else
                %Do not display FrequencyResolutionOption, and
                %FrequencyResolution if SpectralEstimatorOption = 'User defined
                idx = [idx strmatch('FrequencyResolutionOption',sortedList,'exact')];
                idx = [idx strmatch('FrequencyResolution',sortedList,'exact')];
                
                %Do not display SidelobeAtten is WindowOption is not
                %'Chebyshev'
                if ~strcmpi(obj.PrivWindowOption,'chebyshev')
                    idx = [idx strmatch('SidelobeAtten',sortedList,'exact')];
                end
            end
            
            %Do not display FFTLength if FFTLengthOption is not set to 'Specify
            %via property'
            if ~strcmpi(obj.FFTLengthOption,'specify via property')
                idx = [idx strmatch('FFTLength',sortedList,'exact')];
            end
            sortedList(idx) = [];
        end
        %=======================================================================
        function sortedList = getSortedPropInitList(obj) %#ok<MANU>
            % GETSORTEDPROPINITLIST returns a list of properties in the order
            %   in which the properties must be initialized.  If order is not
            %   important, returns an empty cell array.
            
            %Give priority to option properties to avoid warnings at
            %construction time when setting values to the properties they
            %enable.
            sortedList = {'NormalizedFrequency',...
                'Fs',...
                'SpectralEstimatorOption', ...
                'WindowOption',...
                'FrequencyResolutionOption',...
                'FFTLengthOption'};
        end
    end %protected methods
end %class definition

%[EOF]