classdef AbstractPowerMeasurement < handle & commmeasure.AbstractWarnResetUtils
    %AbstractPowerMeasurement Defines AbstractPowerMeasurement class for COMMMEASURE package
    
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.10.3 $  $Date: 2009/07/14 03:52:08 $
    
    %===========================================================================
    % Public properties
    %===========================================================================
    properties
        %MaxHold Maximum hold setting control
        %   Specify the maximum hold setting as one of ['On' | {'Off'}]. If this
        %   property is set to 'On', the current estimated power spectral
        %   density vector (obtained with the current input data) is compared to
        %   the previous max-hold accumulated power spectral density vector
        %   (obtained at the previous call to the run method), and the maximum
        %   values at each frequency bin are kept and used to calculate average
        %   power measurements. The max-hold spectrum is cleared after a call to
        %   the reset method.
        %   If this property is set to 'Off', measurements are obtained with
        %   instantaneous power spectral density estimates.
        MaxHold = 'Off';
        %SpectralEstimatorOption Spectral estimator option
        %   Specify the spectral estimator option as one of [{'Default'} | 'User
        %   defined']. If this property is set to 'Default' the power spectral
        %   density estimates are obtained with an internal default Welch
        %   spectral estimator with zero percent overlap, and Hamming window.
        %   The segment length of the Welch estimator is controlled by the
        %   FrequencyResolutionOption, and FrequencyResolution properties. The
        %   user does not have control of the settings of the spectral estimator
        %   when the SpectralEstimatorOption property is set to 'Default'.
        %   If this property is set to 'User defined' several spectral
        %   estimation properties become available for the user to control the
        %   internal Welch spectral estimation settings. These properties are:
        %   SegmentLength, OverlapPercentage, WindowOption, and SidelobeAtten
        %   (this last property is only relevant when WindowOption is set to
        %   'Chebyshev').
        SpectralEstimatorOption = 'Default';
        % FFTLengthOption FFT length option
        %   Specify the number of FFT points to be used by the internal Welch
        %   spectral estimator as one of ['Specify via property' | {'Next power
        %   of 2' } | 'Auto']. If this property is set to 'Specify via property'
        %   then an FFTLength property will become available for the user to
        %   specify the desired FFT length.
        %   If this property is set to 'Next power of 2' then the length of the
        %   FFT will be set to the next power of 2 greater than the segment
        %   length of the spectral estimator or to 256, whichever is greater.
        %   If this property is set to 'Auto' then the length of the FFT will be
        %   set to the segment length of the spectral estimator or to 256,
        %   whichever is greater.
        FFTLengthOption = 'Next power of 2';
    end
    %===========================================================================
    % Dependent, public properties
    %===========================================================================
    properties (Dependent = true)
        %SegmentLength Segment length (in samples) for the spectral estimator
        %   Specify the segment length for the spectral estimator. This property
        %   is irrelevant (i.e. may not be set by the user, and will not be
        %   displayed by the disp method) unless the SpectralEstimatorOption
        %   property is set to 'User defined'. The length of the segment allows
        %   the user to make tradeoffs between resolution and variance. A long
        %   segment length will result in better resolution while a short
        %   segment length will result in more averages, and therefore decrease
        %   the variance.
        %   The default value is 64.
        SegmentLength
        %OverlapPercentage Overlap percentage for the spectral estimator
        %   Specify the percentage of overlap between each segment in the
        %   spectral estimator. This property is irrelevant (i.e. may not be set
        %   by the user, and will not be displayed by the disp method) unless
        %   the SpectralEstimatorOption property is set to 'User defined'. The
        %   OverlapPercentage property must be in the [0 100] interval.
        %   The default value is 0.
        OverlapPercentage
        % WindowOption Window option for the spectral estimator
        %   Specify a window type for the spectral estimator as of ['Bartlett' |
        %   'Bartlett-Hanning' | 'Blackman' | 'Blackman-Harris' | 'Bohman' |
        %   'Chebyshev' | 'Flat Top' | {'Hamming'} | 'Hann' | 'Nuttall' |
        %   'Parzen' | 'Rectangular' | 'Triangular']. This property is
        %   irrelevant (i.e. may not be set by the user, and will not be
        %   displayed by the disp method) unless the SpectralEstimatorOption
        %   property is set to 'User defined'. The default window is a Hamming
        %   window which has a 42.5 dB sidelobe attenuation. This may mask
        %   spectral content below this value (relative to the peak spectral
        %   content). Choosing different windows allows the user to make
        %   tradeoffs between resolution (e.g., using a rectangular window) and
        %   sidelobe attenuation (e.g., using a Hann window).
        WindowOption
        % SidelobeAtten Sidelobe attenuation for Chebyshev windows in dB
        %   This property is irrelevant (i.e. may not be set by the user, and
        %   will not be displayed by the disp method) unless the
        %   SpectralEstimatorOption property is set to 'User defined', and the
        %   WindowOption property is 'Chebyshev'. The SidelobeAtten property
        %   defines the sidelobe attenuation of the 'Chebyshev' window.
        %   The default value is 100 dB.
        SidelobeAtten
        %FrequencyResolutionOption Frequency resolution option
        %   Specify the frequency resolution option as one of [{'Inherit from
        %   input dimensions'} | 'Specify via property']. This property is
        %   irrelevant (i.e. may not be set by the user, and will not be
        %   displayed by the disp method) unless the SpectralEstimatorOption
        %   property is set to 'Default'. When the SpectralEstimatorOption
        %   property is set to 'Default', the specified frequency resolution
        %   automatically determines the segment length of the internal spectral
        %   estimator. When the SpectralEstimatorOption property is set to 'User
        %   defined', FrequencyResolutionOption becomes irrelevant and the
        %   spectral estimator window length is controlled directly by the user
        %   in the SegmentLength property. 
        %   When the FrequencyResolutionOption property is set to 'Inherit from
        %   input dimensions' then, at run time, resolution is set to the
        %   maximum achievable resolution given the data length.
        %   When the FrequencyResolutionOption property is set to 'Specify via
        %   property' then a FrequencyResolution property becomes available for
        %   the user to specify the desired frequency resolution value.
        FrequencyResolutionOption
        %FrequencyResolution Spectral estimator resolution (normalized or in Hz).
        %   Specify the frequency resolution of the spectral estimator. This
        %   property is irrelevant (i.e. may not be set by the user, and will
        %   not be displayed by the disp method) unless the
        %   SpectralEstimatorOption property is set to 'Default', and the
        %   FrequencyResolutionOption property is set to 'Specify via property'.
        %   The FrequencyResolution property will be used to calculate the size
        %   of the data window used in the internal default spectral estimator.
        %   If the SpectralEstimatorOption property is set to 'User defined',
        %   FrequencyResolution becomes irrelevant and the spectral estimator
        %   window length is controlled directly by the user in the
        %   SegmentLength property.
        %   Default value is 1.36/64 when 'NormalizedFrequency' is true, and
        %   1.36*(Fs/2)/64 when 'NormalizedFrequency' is false. .
        FrequencyResolution
        %FFTLength User defined FFT length
        %   Specify an FFT length. This property is irrelevant (i.e. may not be
        %   set by the user, and will not be displayed by the disp method)
        %   unless the FFTLengthOption property is set to 'Specify via
        %   property'. In this case, the FFTLength property defines the number
        %   of FFT points used by the spectral estimator.
        %   Default value is 256.
        FFTLength
    end
    %===========================================================================
    % Abstract, dependent, public properties
    %===========================================================================
    properties (Dependent = true, Abstract = true)
        %NormalizedFrequency Normalized frequency
        NormalizedFrequency
        %Fs sampling frequency
        Fs
    end
    %===========================================================================
    % Protected, hidden properties
    %===========================================================================
    properties (Access = protected, Hidden = true)
        %PrivSpectralEstimator
        %   Holds the spectrum.welch object for spectral analysis.
        PrivSpectralEstimator
        %PrivSpectralEstimatorOpts
        %   Holds the dspopts.spectrum object for spectral analysis.
        PrivSpectralEstimatorOpts
        %PrivPSD Private spectral estimate matrix.
        %   This property keeps instantaneous spectral estimates if the MaxHold
        %   property is set to 'Off', or accumulated max-hold spectral estimates
        %   if the MaxHold property is 'On'. If a measurement filter has been
        %   specified and it is not an all-pass filter, then 'PrivPSD' is a
        %   matrix with each column corresponding to the PSD of the input signal
        %   convolved with a filter response that has been shifted to each of
        %   the specified bands of interest (main channel and adjacent bands).
        PrivPSD = [];
        %PrivFrequencyVector Keep frequency vector of PSD calculations
        PrivFrequencyVector
        %PrivNormalizedFrequency Normalized frequency flag
        %   True if frequency is given in normalized units, false if frequency
        %   is given in Hz.
        PrivNormalizedFrequency
        % PrivFs Sampling frequency.
        PrivFs
        %=======================================================================
        % Protected counterparts of dependent public properties
        %=======================================================================
        PrivFrequencyResolutionOption = 'Inherit from input dimensions';
        PrivFrequencyResolution = 1.36/64;
        PrivFFTLength = 256;
        PrivSegmentLength = 64;
        PrivOverlapPercentage = 0;
        PrivWindowOption = 'Hamming';
        PrivSidelobeAtten = 100;
    end
    %===========================================================================
    % Define Public Methods
    %===========================================================================
    methods
        function set.SpectralEstimatorOption(obj,option)
            %SET SpectralEstimatorOption property
            
            %Check data type (enum)
            validCell = {'Default',...
                'User defined'};
            out = validatestring(option, validCell);
            
            if strcmpi(out,'default')
                resetSpectralEstimator(obj,'Hamming',64,0);
            else
                resetSpectralEstimator(obj,obj.PrivWindowOption,...
                    obj.PrivSegmentLength,obj.PrivOverlapPercentage); %#ok<*MCSUP>
            end
            obj.SpectralEstimatorOption = out;
            %reset object
            checkResetFlagAndReset(obj);
        end
        %=======================================================================
        function set.SegmentLength(obj,sl)
            %SET SegmentLength property
            
            %Check data type (positive integer scalar)
            validateattributes(sl,...
                {'numeric'},...
                {'finite','positive','scalar','integer'}, ...
                'commmeasure.ACPR',...
                'SegmentLength');
            
            %Set private property (SegmentLength is dependent)
            obj.PrivSegmentLength = sl;
            
            %Warn if property is currently irrelevant
            if strcmpi(obj.SpectralEstimatorOption,'Default')
                warnAboutIrrelevantSet(obj,'SegmentLength','commmeasure.ACPR');
            else
                %Set the spectrum.welch property
                obj.PrivSpectralEstimator.SegmentLength = sl;
                %reset object
                checkResetFlagAndReset(obj);
            end
        end
        %=======================================================================
        function sl = get.SegmentLength(obj)
            %GET SegmentLength property
            sl = obj.PrivSegmentLength;
        end
        %=======================================================================
        function set.OverlapPercentage(obj,op)
            %SET OverlapPercentage property
            
            %Check data type (nonnegative double scalar, <100)
            validateattributes(op,...
                {'double'},...
                {'finite','nonnegative','scalar','<',100}, ...
                'commmeasure.ACPR',...
                'OverlapPercentage');
            
            %Set private property (SegmentLength is dependent)
            obj.PrivOverlapPercentage = op;
            
            %Warn if property is currently irrelevant
            if strcmpi(obj.SpectralEstimatorOption,'Default')
                warnAboutIrrelevantSet(obj,'OverlapPercentage',...
                    'commmeasure.ACPR');
            else
                %Set the spectrum.welch property
                obj.PrivSpectralEstimator.OverlapPercent = op;
                %reset object
                checkResetFlagAndReset(obj);
            end
        end
        %=======================================================================
        function op = get.OverlapPercentage(obj)
            %GET OverlapPercentage property
            op = obj.PrivOverlapPercentage;
        end
        %=======================================================================
        function set.WindowOption(obj,wo)
            %SET WindowOption property
            
            %Check data type (enum)
            validCell = {'Bartlett', ...
                'Bartlett-Hanning', ...
                'Blackman', ...
                'Blackman-Harris', ...
                'Bohman', ...
                'Chebyshev', ...
                'Flat Top', ...
                'Hamming', ...
                'Hann', ...
                'Nuttall', ...
                'Parzen', ...
                'Rectangular', ...
                'Triangular'};
            out = validatestring(wo, validCell);
            
            %Set private property (WindowOption is dependent)
            obj.PrivWindowOption = out;
            
            %Warn if property is currently irrelevant
            if strcmpi(obj.SpectralEstimatorOption,'Default')
                warnAboutIrrelevantSet(obj,'WindowOption','commmeasure.ACPR');
            else
                %Set the spectrum.welch property
                obj.PrivSpectralEstimator.WindowName = out;
                %If user had set the 'SidelobeAtten' property while it was
                %irrelevant, set its value now that it has become relevant
                if strcmp(out,'Chebyshev')
                    obj.PrivSpectralEstimator.SidelobeAtten = ...
                        obj.PrivSidelobeAtten;
                end
                %reset object
                checkResetFlagAndReset(obj);
            end
        end
        %=======================================================================
        function wo = get.WindowOption(obj)
            %GET WindowOption property
            wo = obj.PrivWindowOption;
        end
        %=======================================================================
        function set.SidelobeAtten(obj,sa)
            %SET SidelobeAtten property
            
            %Check data type (nonnegative double scalar)
            validateattributes(sa,...
                {'double'},...
                {'finite','nonnegative','scalar'}, ...
                'commmeasure.ACPR',...
                'SidelobeAtten');
            
            %Set private property (SidelobeAtten is dependent)
            obj.PrivSidelobeAtten = sa;
            
            %Warn if property is currently irrelevant
            if strcmpi(obj.SpectralEstimatorOption,'Default') ||...
                    ~strcmpi(obj.PrivWindowOption,'chebyshev')
                warnAboutIrrelevantSet(obj,'SidelobeAtten','commmeasure.ACPR');
            else
                %Set the spectrum.welch property
                obj.PrivSpectralEstimator.SidelobeAtten = sa;
                %reset object
                checkResetFlagAndReset(obj);
            end
        end
        %=======================================================================
        function op = get.SidelobeAtten(obj)
            %GET SidelobeAtten property
            op = obj.PrivSidelobeAtten;
        end
        %=======================================================================
        function set.FrequencyResolutionOption(obj, option)
            %SET FrequencyResolutionOption property
            
            %Check data type (enum)
            validCell = {'Specify via property',...
                'Inherit from input dimensions'};
            out = validatestring(option, validCell);
            
            %Set private property (FrequencyResolutionOption is dependent)
            obj.PrivFrequencyResolutionOption = out;
            
            %Warn if property is currently irrelevant
            if strcmpi(obj.SpectralEstimatorOption,'User defined')
                warnAboutIrrelevantSet(obj,'FrequencyResolutionOption', ...
                    'commmeasure.ACPR');
            else
                %reset object
                checkResetFlagAndReset(obj);
            end
        end
        %=======================================================================
        function fro = get.FrequencyResolutionOption(obj)
            %GET FrequencyResolutionOption property
            fro = obj.PrivFrequencyResolutionOption;
        end
        %=======================================================================
        function set.FrequencyResolution(obj, freqres)
            %SET FrequencyResolution property
            
            %Check data type (nonnegative double scalar)
            validateattributes(freqres,...
                {'double'},...
                {'finite','nonnegative','scalar'}, ...
                'commmeasure.ACPR',...
                'FrequencyResolution');
            
            %Set private property (FrequencyResolution is dependent)
            obj.PrivFrequencyResolution = freqres;
            
            %Warn if property is currently irrelevant
            if strcmpi(obj.SpectralEstimatorOption,'User defined') || ...
                    strcmpi(obj.PrivFrequencyResolutionOption,...
                    'inherit from input dimensions')
                
                warnAboutIrrelevantSet(obj,'FrequencyResolution',...
                    'commmeasure.ACPR');
            else
                %reset object
                checkResetFlagAndReset(obj);
            end
        end
        %=======================================================================
        function fr = get.FrequencyResolution(obj)
            %GET FrequencyResolution property
            fr = obj.PrivFrequencyResolution;
        end
        %=======================================================================
        function set.FFTLengthOption(obj,option)
            %SET FFTLengthOption property
            
            %Check data type (enum)
            validCell = {'Specify via property',...
                'Next power of 2', ...
                'Auto'};
            out = validatestring(option, validCell);
            
            %Set value
            obj.FFTLengthOption = out;
            %reset object
            checkResetFlagAndReset(obj);
        end
        %=======================================================================
        function set.FFTLength(obj,nfft)
            %SET FFTLength property
            
            %Check data type (positive integer scalar)
            validateattributes(nfft,...
                {'numeric'},...
                {'finite','positive','scalar','integer'}, ...
                'commmeasure.ACPR',...
                'FFTLength');
            
            %Set private property (FFTLength is dependent)
            obj.PrivFFTLength = nfft;
            
            %Warn if property is currently irrelevant
            if ~strcmpi(obj.FFTLengthOption,'specify via property')
                warnAboutIrrelevantSet(obj,'FFTLength','commmeasure.ACPR');
            else
                %reset object
                checkResetFlagAndReset(obj);
            end
        end
        %=======================================================================
        function length = get.FFTLength(obj)
            %GET FFTLength property
            length = obj.PrivFFTLength;
        end
        %=======================================================================
        function  set.MaxHold(obj,value)
            %SET MaxHold property
            
            %Check data type (enum)
            validCell = {'On',...
                'Off'};
            out = validatestring(value, validCell);
            
            %Set value
            obj.MaxHold = out;
            %reset object
            checkResetFlagAndReset(obj);
        end
    end%public methods
    %===========================================================================
    % Define Protected Methods
    %===========================================================================
    methods (Access = protected)
        function initSpectralEstimatorSegmentLength(obj,x)
            %initSpectralEstimatorSegmentLength
            %   Initialize spectral estimator segment length according to the
            %   specified FrequencyResolutionOption, and FrequencyResolution
            %   properties. This method is only called when
            %   SpectralEstimatorOption is 'Default'. Input x is a column vector
            %   containing the input data frame.
            
            %Freq Resolution for a Hamming window is 1.36 larger than the
            %rectangular window bandwidth = Fs/WindowLength. Ref: Digital
            %Spectral Analysis, S. Lawrence Marple, page 143.
            term = 1.36;
            str = [];
            if ~obj.PrivNormalizedFrequency
                term = term * obj.PrivFs;
                str = 'Hz';
            end %#ok<*MCNPN>
            
            %If set to 'Inherit from input dimensions' Segment length of the
            %spectral estimator should be equal to data length.
            obj.PrivSpectralEstimator.SegmentLength = length(x);
            ActualResolution = term/obj.PrivSpectralEstimator.SegmentLength;
            
            %Otherwise" If FrequencyResolutionOption is not set to 'Inherit from
            %input dimensions' set the spectral estimator segment length
            %according to the specified frequency resolution value.
            if ~strcmpi(obj.PrivFrequencyResolutionOption, ...
                    'inherit from input dimensions')
                
                %Calculate window length from specified resolution
                wlen = floor(term/obj.PrivFrequencyResolution);
                
                if wlen <= 1
                    %Keep segment length equal to data length
                    warning(generatemsgid('unachievableResolution'),...
                        ['Specified frequency resolution value is too large. ',...
                        'The FrequencyResolution property should be < %f %s. ',...
                        'Spectral estimates will be calculated with a single ',...
                        'segment length equal to the data length. ',...
                        'Note that the FrequencyResolution property has ',...
                        'been set to the resolution value attained by this ',...
                        'full-data segment length.'], term/2,str);
                    obj.PrivFrequencyResolution = ActualResolution;
                    
                elseif  wlen > length(x)
                    %Keep segment length equal to data length
                    warning(generatemsgid('unachievableResolution'),...
                        ['Specified frequency resolution is not attainable with ',...
                        'the input data length. The FrequencyResolution ',...
                        'property should be > %f %s. Spectral estimates will be ',...
                        'calculated with a single segment length equal to ',...
                        'the data length. Note that the FrequencyResolution ',...
                        'property has been set to the resolution value ',...
                        'attained by this full-data segment length.'], term/length(x),str);
                    obj.PrivFrequencyResolution = ActualResolution;
                    
                else
                    %If resolution is achievable, set the spectral estimator's
                    %segment length to wlen
                    obj.PrivSpectralEstimator.SegmentLength = wlen;
                end
            end
        end
        %=======================================================================
        function initSpectralEstimatorOptions(obj,x)
            %initSpectralEstimatorOptions
            %   Instantiate a psd options object. Set FFT length according to
            %   FFTLengthOption, and FFTLength properties. Input x is a column
            %   vector containing the input data frame.
            
            %Calculate the FFT length, this will be used by other methods
            L = obj.PrivSpectralEstimator.SegmentLength;
            if strcmpi(obj.FFTLengthOption,'specify via property')
                NFFT = obj.PrivFFTLength;
            elseif strcmpi(obj.FFTLengthOption,'next power of 2')
                NFFT = max(256,2^nextpow2(L));
            else %'Auto'
                NFFT = max(256,L);
            end
            
            obj.PrivSpectralEstimatorOpts = psdopts(obj.PrivSpectralEstimator,x);
            set(obj.PrivSpectralEstimatorOpts,'SpectrumType','TwoSided', ...
                'CenterDC',true,'NFFT',NFFT);
            if ~obj.PrivNormalizedFrequency, set(obj.PrivSpectralEstimatorOpts, ...
                    'Fs',obj.PrivFs);
            end
        end
        %=======================================================================
        function initPrivPSD(obj,nCol)
            %initPrivPSD Initialize the PrivPSD matrix.
            %   Matrix that holds nCol PSD calculations. If MaxHold is on,
            %   PrivPSD contains the accumulated max hold PSDs. Otherwise, it
            %   contains instantaneous PSDs. nCol defines the number of columns
            %   in the matrix. The number of rows is equal to the current FFT
            %   length.
            
            NFFT = obj.PrivSpectralEstimatorOpts.NFFT;
            obj.PrivPSD = -inf*ones(NFFT, nCol);
        end
        %=======================================================================
        function  resetSpectralEstimator(obj,winName,segLength,ovPerc)
            %resetSpectralEstimator Reset spectral estimator to specified
            %   values.
            %   Inputs:
            %   winName   - window name
            %   segLength - segment length
            %   ovPerc    - overlap percentage
            
            if ~isempty(obj.PrivSpectralEstimator)
                obj.PrivSpectralEstimator.WindowName = winName;
                obj.PrivSpectralEstimator.SegmentLength = segLength;
                obj.PrivSpectralEstimator.OverlapPercent = ovPerc;
                if ~isempty(findprop(obj.PrivSpectralEstimator,'SamplingFlag'));
                    obj.PrivSpectralEstimator.SamplingFlag = 'symmetric';
                end
                if ~isempty(findprop(obj.PrivSpectralEstimator,'SidelobeAtten'));
                    obj.PrivSpectralEstimator.SidelobeAtten = ...
                        obj.PrivSidelobeAtten;
                end
            end
        end
        %=======================================================================
        function  pwr = computeAvgPower(obj,lowerF, higherF,idx)
            %computeAvgPower Compute power measurements.
            %   This method computes the average power within a band defined by
            %   the frequency limits [lowerF higherF]. The average power is
            %   computed using the PSD estimate contained in the idx-th column
            %   of the PrivPSD matrix.
            
            %Set a DSPDATA object with data indexed by idx
            DspData = dspdata.psd(obj.PrivPSD(:,idx),...
                obj.PrivFrequencyVector, ...
                'SpectrumType',obj.PrivSpectralEstimatorOpts.SpectrumType, ...
                'CenterDC',obj.PrivSpectralEstimatorOpts.CenterDc,...
                'Fs',obj.PrivSpectralEstimatorOpts.Fs);
            
            if obj.PrivNormalizedFrequency
                %DspData in a two sided spectrum with Normalized frequencies has
                %a frequency vector whose values go from 0 to 2*pi. Since
                %frequency data in DspData is in radians we have to multiply our
                %frequency limits by pi.
                Fs = 2; %#ok<*PROP>
                normValue = pi;
            else
                %In this case, frequency values in the two sided spectrum in
                %DspData go from 0 to Fs. Frequency values are in Hz so we do
                %not need to multiply our frequency limits by pi.
                Fs = obj.PrivFs;
                normValue = 1;
            end
            
            if abs(higherF) > Fs/2 || abs(lowerF) > Fs/2
                error(generatemsgid('FrequencyValuesOutOfRange'),...
                    (['Specified measurement bands are outside the Nyquist ',...
                      'interval [-Fs/2 Fs/2] if ',...
                      'NormalizedFrequency is false, or [-1 1] ',...
                      'if NormalizedFrequency is true.']));                
            end
            
            if higherF == Fs/2
                higherF = DspData.Frequencies(end)/normValue;
            end
            if lowerF == -Fs/2
                lowerF = DspData.Frequencies(1)/normValue;
            end
            
            pwr = avgpower(DspData, [lowerF higherF]*normValue);
        end
        %=======================================================================
        function computePSD(obj,data)
            %computePSD Compute power spectral density.
            %   Compute PSDs and accumulate maximum hold spectra if MaxHold is
            %   'On'. We calculate a PSD for each column of the input data
            %   matrix 'data'. PSD calculations are saved in the PrivPSD
            %   property.
            
            numPSDs = size(data,2);
            for idx = 1: numPSDs
                hPsd = psd(obj.PrivSpectralEstimator,data(:,idx), ...
                    obj.PrivSpectralEstimatorOpts); %#ok<*FDEPR>
                if strcmpi(obj.MaxHold,'on')
                    obj.PrivPSD(:,idx) = ...
                        max(obj.PrivPSD(:,idx), hPsd.Data);
                else
                    obj.PrivPSD(:,idx) = hPsd.Data;
                end
            end
            obj.PrivFrequencyVector = hPsd.Frequencies;
        end
    end%protected methods
end%classdef