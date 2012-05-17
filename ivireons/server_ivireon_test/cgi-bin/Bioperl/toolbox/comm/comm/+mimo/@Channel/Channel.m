classdef Channel < mimo.BaseSigProc
    %Channel Return a MIMO channel
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.4 $  $Date: 2009/11/13 04:14:13 $
    
    %===========================================================================
    % Read-Only properties
    properties (SetAccess = private)
        % Type of channel
        ChannelType = 'MIMO';
        % Channel filter delay
        ChannelFilterDelay
        % Number of samples processed
        NumSamplesProcessed = 0;
    end
    
    %===========================================================================
    % Public properties
    properties (Dependent)
        % Doppler spectrum object
        DopplerSpectrum %        p.Description = 'Doppler spectrum object';
        % Average path gains, in dB
        AvgPathGaindB
        % Normalize path gains flag
        NormalizePathGains
        % Transmit correlation matrix.
        TxCorrelationMatrix
        % Receive correlation matrix.
        RxCorrelationMatrix
        % Store history for path gains only
        StorePathGains
        % Line of Sight Doppler shift
        DirectPathDopplerShift
        % Line of Sight initial phase shift
        DirectPathInitPhase
    end
    
    %===========================================================================
    % Public properties
    properties
        % Reset before filtering flag
        ResetBeforeFiltering = 1;
    end
    
    %===========================================================================
    % Private versions of Public Dependent properties.  We use these to
    % avoid firing set methods during load/copy.
    properties (Access = private)
        % Doppler spectrum object
        PrivDopplerSpectrum
        % Average path gains, in dB
        PrivAvgPathGaindB
        % Normalize path gains flag
        PrivNormalizePathGains = 1;
        % Transmit correlation matrix.
        PrivTxCorrelationMatrix
        % Receive correlation matrix.
        PrivRxCorrelationMatrix
        % Store history for path gains only
        PrivStorePathGains
        % Line of Sight Doppler shift
        PrivDirectPathDopplerShift = 0;
        % Line of Sight initial phase shift
        PrivDirectPathInitPhase = 0;
    end
    
    %===========================================================================
    % Public/Observable properties
    properties (SetObservable, Dependent)
        % Number of transmitter antennas
        NumTxAntennas
        % Number of receive antennas
        NumRxAntennas
        % Rician K factor (linear scale)
        KFactor = 0;
    end
    
    %===========================================================================
    % Private versions of Public Dependent properties.  We use these to
    % avoid firing set methods during load/copy.
    properties (Access = private)
        % Number of transmitter antennas
        PrivNumTxAntennas
        % Number of receive antennas
        PrivNumRxAntennas
        % Rician K factor (linear scale)
        PrivKFactor = 0;
    end
    
    %===========================================================================
    % Public, Dependent properties
    properties (Dependent)
        % Input signal sample period
        InputSamplePeriod
        % Maximum Doppler shift
        MaxDopplerShift
        % Multipath component delays
        PathDelays
    end
    
    %===========================================================================
    % Read-only, Dependent properties
    properties (SetAccess = private, Dependent)
        % Path gains
        PathGains
    end
    
    %===========================================================================
    % Private, Transient properties
    properties (SetAccess = private, GetAccess = private, Transient)
        % Listener for NumTxAntennas: when NumTxAntennas changes,
        % TxCorrelationMatrix is reset.
        NumTxAntennasListener
        % Listener for NumRxAntennas: when NumRxAntennas changes,
        % RxCorrelationMatrix is reset.
        NumRxAntennasListener
        % Listener for Doppler spectrum object
        DopplerSpectrumPropertiesListener
        % Listener for Rician K factor: when size of KFactor changes, sizes of
        % DirectPathDopplerShift and DirectPathInitPhase must also change.
        KFactorListener
    end
    
    %===========================================================================
    % Private properties
    properties (SetAccess = private, GetAccess = private)
        % Average path gain vector (modified version of above)
        AvgPathGainVector
        % Use private property to avoid PathGains public set error.
        PathGainsPrivate
    end
    
    %===========================================================================
    % Read-only, hidden properties
    properties (SetAccess = private, Hidden)
        % Last phase offets, used by scalePathGains in looping mode
        LastThetaLOS
        % Number of frames (input vectors) processed
        NumFramesProcessed = 0
        % Rayleigh fading source
        RayleighFading
        % Channel filter
        ChannelFilter
    end
    
    %===========================================================================
    % Public methods
    methods
        function h = Channel(varargin)
            %Channel  Return a MIMO channel
            %
            %  Inputs:
            %    h      - Channel object
            %    Nt     - Number of transmit antennas
            %    Nr     - Number of receive antennas
            %    ts     - Input sample period
            %    fd     - Maximum Diffuse Doppler shift
            %    tau    - Path delay vector
            %    pdb    - Average path gain vector (dB)
            
            error(nargchk(4, 6, nargin));
            
            % Set default values that needs to trigger set functions
            h.NormalizePathGains = 1;
            h.StorePathGains = 0;
            
            initChannel(h, varargin{:})
        end
    end
    
    %===========================================================================
    % Public static methods
    methods (Static)
        function h = loadobj(h)
            
            % Setup listener for Rician K factor
            h.KFactorListener = addlistener(h, ...
                'KFactor', ...
                'PostSet', ...
                @(hSrc, eData) react2kfactor(h));
            
            % Setup listener for NumTxAntennas
            h.NumTxAntennasListener = addlistener(h, ...
                'NumTxAntennas', ...
                'PostSet', ...
                @(hSrc, eData) react2NumTxAntennas(h));
            
            % Setup listener for NumRxAntennas
            h.NumRxAntennasListener = addlistener(h, ...
                'NumRxAntennas', ...
                'PostSet', ...
                @(hSrc, eData) react2NumRxAntennas(h));
            
        end
    end
    
    %===========================================================================
    % Private methods
    methods (Access = private)
        function react2NumTxAntennas(h)
            
            if h.Constructed
                % If NumTxAntennas changes, TxCorrelationMatrix is reset.
                h.TxCorrelationMatrix = eye(h.NumTxAntennas);
            end
        end
        %------------------------
        function react2NumRxAntennas(h)
            
            if h.Constructed
                % If NumRxAntennas changes, RxCorrelationMatrix is reset.
                h.RxCorrelationMatrix = eye(h.NumRxAntennas);
            end
        end
        %------------------------
        function react2kfactor(h)
            
            if h.Constructed
                % If the size of KFactor changes, the size of DirectPathDopplerShift
                % must change accordingly, since a line-of-sight component must exist
                % for the corresponding line-of-sight Doppler shift to exist.
                DirectPathDopplerShiftOld = h.DirectPathDopplerShift;
                h.DirectPathDopplerShift = tailorVector(DirectPathDopplerShiftOld, h.KFactor);
                DirectPathInitPhaseOld = h.DirectPathInitPhase;
                h.DirectPathInitPhase = tailorVector(DirectPathInitPhaseOld, h.KFactor);
            end
        end
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function set.NumTxAntennas(chan, Nt)
            propName = 'NumTxAntennas';
            validateattributes(Nt, {'double'}, {'positive', 'integer'}, ...
                [class(chan) '.' propName], propName);
            
            if (Nt<1) || (Nt>8)
                error('comm:mimo:Channel:NumTxAntennas', ...
                    'NumTxAntennas must be chosen between 1 and 8.');
            end
            
            if chan.Constructed
                Rt = eye(Nt);
                Rr = chan.RxCorrelationMatrix;
                L = length(chan.PathDelays);
                chan.RayleighFading.FiltGaussian.SQRTCorrelationMatrix = computeSQRTCorrelationMatrix(Rt,Rr,L);
                % chan.RayleighFading.InterpFilter is re-initialized (and reset) via
                % setNumLinks
                % chan.RayleighFading.FiltGaussian is re-initialized (and reset) via
                % setNumLinks
                % chan.RayleighFading is re-initialized (and reset) via
                % setNumLinks
                chan.RayleighFading.NumLinks = Nt * chan.NumRxAntennas;
                chan.ChannelFilter.NumLinks = Nt * chan.NumRxAntennas;
                chan.ChannelFilter.NumTxAntennas = Nt;
            end
            
            if chan.Constructed, initialize(chan); end
            
            chan.PrivNumTxAntennas = Nt;
        end
        %--------------------------------------------------------------------------
        function Nt = get.NumTxAntennas(chan)
            Nt = chan.PrivNumTxAntennas;
        end
        %--------------------------------------------------------------------------
        function set.NumRxAntennas(chan, Nr)
            propName = 'NumRxAntennas';
            validateattributes(Nr, {'double'}, {'positive', 'integer'}, ...
                [class(chan) '.' propName], propName);
            
            if (Nr<1) || (Nr>8)
                error('comm:mimo:Channel:NumRxAntennas', ...
                    'NumRxAntennas must be chosen between 1 and 8.');
            end
            
            if chan.Constructed
                Rt = chan.TxCorrelationMatrix;
                Rr = eye(Nr);
                L = length(chan.PathDelays);
                chan.RayleighFading.FiltGaussian.SQRTCorrelationMatrix = computeSQRTCorrelationMatrix(Rt,Rr,L);
                % chan.RayleighFading.InterpFilter is re-initialized (and reset) via
                % setNumLinks
                % chan.RayleighFading.FiltGaussian is re-initialized (and reset) via
                % setNumLinks
                % chan.RayleighFading is re-initialized (and reset) via
                % setNumLinks
                chan.RayleighFading.NumLinks = Nr * chan.NumTxAntennas;
                chan.ChannelFilter.NumLinks = Nr * chan.NumTxAntennas;
                chan.ChannelFilter.NumRxAntennas = Nr;
            end
            
            if chan.Constructed, initialize(chan); end
            
            chan.PrivNumRxAntennas = Nr;
        end
        %--------------------------------------------------------------------------
        function Nr = get.NumRxAntennas(chan)
            Nr = chan.PrivNumRxAntennas;
        end
        %-----------------------------------------------------------------------
        function set.InputSamplePeriod(chan, Ts)
            propName = 'InputSamplePeriod';
            validateattributes(Ts, {'double'}, {'nonnegative'}, ...
                [class(chan) '.' propName], propName);
            
            if Ts<=0
                error('comm:mimo:Channel:InputSamplePeriod', ...
                    'InputSamplePeriod must be greater than zero.');
            end
            if (abs((chan.InputSamplePeriod-Ts)/Ts)<sqrt(eps))
                % Return if insignificant change in sample time.
                return;
            end
            chan.RayleighFading.OutputSamplePeriod = Ts;
            chan.ChannelFilter.InputSamplePeriod = Ts;
            if chan.Constructed, initialize(chan); end
        end
        %-----------------------------------------------------------------------
        function Ts = get.InputSamplePeriod(chan)
            Ts = chan.RayleighFading.OutputSamplePeriod;
        end
        %-----------------------------------------------------------------------
        function set.MaxDopplerShift(chan, fd)
            propName = 'MaxDopplerShift';
            validateattributes(fd, {'double'}, {'nonnegative'}, ...
                [class(chan) '.' propName], propName);
            
            chan.RayleighFading.MaxDopplerShift = fd;
            if chan.Constructed, initialize(chan); end
        end
        %-----------------------------------------------------------------------
        function fd = get.MaxDopplerShift(chan)
            fd = chan.RayleighFading.MaxDopplerShift;
        end
        %-----------------------------------------------------------------------
        function set.DopplerSpectrum(h, dopplerSpectrum)
            propName = 'DopplerSpectrum';
            validateattributes(dopplerSpectrum, {'doppler.baseclass'}, ...
                {'vector'}, ...
                [class(h) '.' propName], propName);
            
            
            if ( size(dopplerSpectrum,1)>1 || ( (length(dopplerSpectrum)> 1) ...
                    && ~isequal(size(dopplerSpectrum,2), size(h.PathDelays,2)) ) )
                error('comm:mimo:Channel:DopplerSpectrum', ...
                    ['DopplerSpectrum must be a single doppler object or a vector' ...
                    ' of doppler objects of the same length as PathDelays.']);
            end
            
            % Uses overloaded copy method from doppler.baseclass
            for i_obj = 1:length(dopplerSpectrum)
                dopplerSpectrum_out(i_obj) = copy(dopplerSpectrum(i_obj));
            end
            
            % If size of DopplerSpectrum changes, sizes internal quantities are reset
            % in order to then change accordingly
            if length(dopplerSpectrum) ~= length(h.DopplerSpectrum)
                h.RayleighFading.FiltGaussian.ImpulseResponseFcn = cell(1);
                h.RayleighFading.CutoffFrequencyFactor = 1.0;
                h.RayleighFading.CutoffFrequencyName = cell(1);
            end
            
            for i_obj = 1:length(dopplerSpectrum)
                spectrumType = dopplerSpectrum_out(i_obj).SpectrumType;
                if strcmpi(spectrumType,'Jakes')
                    h.RayleighFading.FiltGaussian.ImpulseResponseFcn{i_obj} = @jakes;
                    h.RayleighFading.CutoffFrequencyFactor(i_obj) = 1.0;
                    h.RayleighFading.CutoffFrequencyName{i_obj} = 'Maximum Doppler shift';
                elseif strcmpi(spectrumType,'Flat')
                    h.RayleighFading.FiltGaussian.ImpulseResponseFcn{i_obj} = @flat;
                    h.RayleighFading.CutoffFrequencyFactor(i_obj) = 1.0;
                    h.RayleighFading.CutoffFrequencyName{i_obj} = 'Maximum Doppler shift';
                elseif strcmpi(spectrumType,'Rounded')
                    h.RayleighFading.FiltGaussian.ImpulseResponseFcn{i_obj} = @rounded;
                    h.RayleighFading.CutoffFrequencyFactor(i_obj) = 1.0;
                    h.RayleighFading.CutoffFrequencyName{i_obj} = 'Maximum Doppler shift';
                elseif strcmpi(spectrumType,'Bell')
                    h.RayleighFading.FiltGaussian.ImpulseResponseFcn{i_obj} = @bell;
                    h.RayleighFading.CutoffFrequencyFactor(i_obj) = 1.0;
                    h.RayleighFading.CutoffFrequencyName{i_obj} = 'Maximum Doppler shift';
                elseif strcmpi(spectrumType,'RJakes')
                    h.RayleighFading.FiltGaussian.ImpulseResponseFcn{i_obj} = @rJakes;
                    % Do error checking on dopplerSpectrum_out.FreqMinMaxRJakes: need a
                    % minimum frequency separation to ensure that the impulse response is
                    % correctly computed.
                    if ( dopplerSpectrum_out(i_obj).FreqMinMaxRJakes(2) ...
                            - dopplerSpectrum_out(i_obj).FreqMinMaxRJakes(1) <=  1/50 )
                        dopplerSpectrum_out(i_obj).FreqMinMaxRJakes = [0 1];
                        warning('comm:mimo:FreqMinMaxRJakes', ...
                            ['The minimum and maximum frequencies (normalized by the maximum Doppler shift)' ...
                            ' for the RJakes doppler spectrum should be spaced by more than 1/50,' ...
                            ' FreqMinMaxRJakes has been reset to [0 1].'])
                    end
                    h.RayleighFading.CutoffFrequencyFactor(i_obj) = 1.0;
                    h.RayleighFading.CutoffFrequencyName{i_obj} = 'Maximum Doppler shift';
                elseif strcmpi(spectrumType,'AJakes')
                    h.RayleighFading.FiltGaussian.ImpulseResponseFcn{i_obj} = @aJakes;
                    % Do error checking on dopplerSpectrum_out.FreqMinMaxAJakes: need a
                    % minimum frequency separation to ensure that the impulse response is
                    % correctly computed.
                    if ( dopplerSpectrum_out(i_obj).FreqMinMaxAJakes(2) ...
                            - dopplerSpectrum_out(i_obj).FreqMinMaxAJakes(1) <=  1/50 )
                        dopplerSpectrum_out(i_obj).FreqMinMaxAJakes = [0 1]; %#ok<*AGROW>
                        warning('comm:mimo:FreqMinMaxAJakes', ...
                            ['The minimum and maximum frequencies (normalized by the maximum Doppler shift)' ...
                            ' for the AJakes doppler spectrum should be spaced by more than 1/50,' ...
                            ' FreqMinMaxAJakes has been reset to [0 1].'])
                    end
                    h.RayleighFading.CutoffFrequencyFactor(i_obj) = 1.0;
                    h.RayleighFading.CutoffFrequencyName{i_obj} = 'Maximum Doppler shift';
                elseif strcmpi(spectrumType,'Gaussian')
                    h.RayleighFading.FiltGaussian.ImpulseResponseFcn{i_obj} = @gaussian;
                    % Do error checking on dopplerSpectrum_out.SigmaGaussian: should be <
                    % 1/(Noversampling*Ts*fd*sqrt(2*log2(2))) so that the interpolation
                    % factor is greater than 1
                    if ( dopplerSpectrum_out(i_obj).SigmaGaussian >= ...
                            1/(10*sqrt(2*log(2))*h.MaxDopplerShift*h.InputSamplePeriod) )
                        dopplerSpectrum_out(i_obj).SigmaGaussian = 0.99 * ...
                            1/(10*sqrt(2*log(2))*h.MaxDopplerShift*h.InputSamplePeriod);
                        warning('comm:mimo:SigmaGaussian', ...
                            ['SigmaGaussian must be less than 1/(10*sqrt(2*log(2))*fd*Ts),' ...
                            ' where fd is the maximum Doppler shift and Ts is the input sample period.' ...
                            ' It has been set to 0.99 times this value.'])
                    end
                    h.RayleighFading.CutoffFrequencyFactor(i_obj) = dopplerSpectrum_out(i_obj).SigmaGaussian *...
                        sqrt(2*log(2));
                    h.RayleighFading.CutoffFrequencyName{i_obj} = 'Cutoff frequency';
                elseif strcmpi(spectrumType,'BiGaussian')
                    h.RayleighFading.FiltGaussian.ImpulseResponseFcn{i_obj} = @biGaussian;
                    if ( (dopplerSpectrum_out(i_obj).GainGaussian1 == 0) ...
                            && (dopplerSpectrum_out(i_obj).CenterFreqGaussian2 == 0) )
                        % To cover special case where first spectrum has a zero gain and second
                        % spectrum is centered around zero: equivalent to a Gaussian Doppler
                        % spectrum.
                        % The sampling frequency for the filtered Gaussian noise process is
                        % then proportional to the cutoff frequency
                        if ( dopplerSpectrum_out(i_obj).SigmaGaussian2 >= ...
                                1/(10*sqrt(2*log(2))*h.MaxDopplerShift*h.InputSamplePeriod) )
                            dopplerSpectrum_out(i_obj).SigmaGaussian2 = 0.99 * ...
                                1/(10*sqrt(2*log(2))*h.MaxDopplerShift*h.InputSamplePeriod);
                            warning('comm:mimo:SigmaGaussian2', ...
                                ['SigmaGaussian2 must be less than 1/(10*sqrt(2*log(2))*fd*Ts),' ...
                                ' where fd is the maximum Doppler shift and Ts is the input sample period.\n' ...
                                'It has been set to 0.99 times this value.'])
                        end
                        h.RayleighFading.CutoffFrequencyFactor(i_obj) = dopplerSpectrum_out(i_obj).SigmaGaussian2 *...
                            sqrt(2*log(2));
                        h.RayleighFading.CutoffFrequencyName{i_obj} = 'Cutoff frequency';
                    elseif ( (dopplerSpectrum_out(i_obj).GainGaussian2 == 0) ...
                            && (dopplerSpectrum_out(i_obj).CenterFreqGaussian1 == 0) )
                        % To cover special case where second spectrum has a zero gain and first
                        % spectrum is centered around zero: equivalent to a Gaussian Doppler
                        % spectrum.
                        % The sampling frequency for the filtered Gaussian noise process is
                        % then proportional to the cutoff frequency
                        if ( dopplerSpectrum_out(i_obj).SigmaGaussian1 >= ...
                                1/(10*sqrt(2*log(2))*h.MaxDopplerShift*h.InputSamplePeriod) )
                            dopplerSpectrum_out(i_obj).SigmaGaussian1 = 0.99 * ...
                                1/(10*sqrt(2*log(2))*h.MaxDopplerShift*h.InputSamplePeriod);
                            warning('comm:mimo:SigmaGaussian1', ...
                                ['SigmaGaussian1 must be less than 1/(10*sqrt(2*log(2))*fd*Ts),' ...
                                ' where fd is the maximum Doppler shift and Ts is the input sample period.\n' ...
                                'It has been set to 0.99 times this value.'])
                        end
                        h.RayleighFading.CutoffFrequencyFactor(i_obj) = dopplerSpectrum_out(i_obj).SigmaGaussian1 *...
                            sqrt(2*log(2));
                        h.RayleighFading.CutoffFrequencyName{i_obj} = 'Cutoff frequency';
                    elseif ( (dopplerSpectrum_out(i_obj).CenterFreqGaussian1 == 0) ...
                            && (dopplerSpectrum_out(i_obj).CenterFreqGaussian2 == 0) ...
                            && (dopplerSpectrum_out(i_obj).SigmaGaussian1 == dopplerSpectrum_out(i_obj).SigmaGaussian2) )
                        % To cover special case where both spectra are centered around zero and
                        % have the same variance: equivalent to a Gaussian Doppler spectrum.
                        % The sampling frequency for the filtered Gaussian noise process is
                        % then proportional to the cutoff frequency
                        if ( dopplerSpectrum_out(i_obj).SigmaGaussian1 >= ...
                                1/(10*sqrt(2*log(2))*h.MaxDopplerShift*h.InputSamplePeriod) )
                            dopplerSpectrum_out(i_obj).SigmaGaussian1 = 0.99 * ...
                                1/(10*sqrt(2*log(2))*h.MaxDopplerShift*h.InputSamplePeriod);
                            dopplerSpectrum_out(i_obj).SigmaGaussian2 = 0.99 * ...
                                1/(10*sqrt(2*log(2))*h.MaxDopplerShift*h.InputSamplePeriod);
                            warning('comm:mimo:SigmaGaussian12', ...
                                ['SigmaGaussian1 and SigmaGaussian2 must be less than 1/(10*sqrt(2*log(2))*fd*Ts),' ...
                                ' where fd is the maximum Doppler shift and Ts is the input sample period.\n' ...
                                'They have been set to 0.99 times this value.'])
                        end
                        h.RayleighFading.CutoffFrequencyFactor(i_obj) = dopplerSpectrum_out(i_obj).SigmaGaussian1 *...
                            sqrt(2*log(2));
                        h.RayleighFading.CutoffFrequencyName{i_obj} = 'Cutoff frequency';
                    else
                        % "True" bi-Gaussian case, where standard deviations are unequal
                        % and/or center frequencies are nonzero.
                        % The sampling frequency for the filtered Gaussian noise process is
                        % then proportional to the maximum Doppler shift
                        if ( abs(dopplerSpectrum_out(i_obj).CenterFreqGaussian1) ...
                                + dopplerSpectrum_out(i_obj).SigmaGaussian1*sqrt(2*log(2)) > 1 )
                            dopplerSpectrum_out(i_obj).SigmaGaussian1 = ...
                                (1-abs(dopplerSpectrum_out(i_obj).CenterFreqGaussian1))/(sqrt(2*log(2)));
                            warning('comm:mimo:CenterFreqGaussian1SigmaGaussian1', ...
                                ['CenterFreqGaussian1 and SigmaGaussian1 must be chosen such that' ...
                                ' abs(CenterFreqGaussian1) + SigmaGaussian1*sqrt(2*log(2))) <= 1.\n' ...
                                'SigmaGaussian1 has been set to its maximum permissible value, i.e.' ...
                                ' (1-abs(CenterFreqGaussian1))/(sqrt(2*log(2))).']);
                        elseif ( abs(dopplerSpectrum_out(i_obj).CenterFreqGaussian2) ...
                                + dopplerSpectrum_out(i_obj).SigmaGaussian2*sqrt(2*log(2)) > 1 )
                            dopplerSpectrum_out(i_obj).SigmaGaussian2 = ...
                                (1-abs(dopplerSpectrum_out(i_obj).CenterFreqGaussian2))/(sqrt(2*log(2)));
                            warning('comm:mimo:CenterFreqGaussian2SigmaGaussian2', ...
                                ['CenterFreqGaussian2 and SigmaGaussian2 must be chosen such that' ...
                                ' abs(CenterFreqGaussian2) + SigmaGaussian2*sqrt(2*log(2))) <= 1.\n' ...
                                'SigmaGaussian2 has been set to its maximum permissible value, i.e.' ...
                                ' (1-abs(CenterFreqGaussian2))/(sqrt(2*log(2))).']);
                        end
                        h.RayleighFading.CutoffFrequencyFactor(i_obj) = 1.0;
                        h.RayleighFading.CutoffFrequencyName{i_obj} = 'Maximum Doppler shift';
                    end
                else
                    error('comm:mimo:Channel:DopplerSpectrumType', ...
                        'Unsupported Doppler spectrum type.');
                end
            end
            
            % Stores copy of Doppler object in FiltGaussian in order to access
            % its parameters.
            h.RayleighFading.FiltGaussian.DopplerSpectrum = copy(dopplerSpectrum_out);
            
            % Forces re-initialization and reset of h.RayleighFading.FiltGaussian,
            % h.RayleighFading.InterpFilter and h.RayleighFading
            h.RayleighFading.CutoffFrequency = h.MaxDopplerShift * h.RayleighFading.CutoffFrequencyFactor;
            % Necessary to ensure that FiltGaussian is re-initialized even if
            % h.RayleighFading.CutoffFrequency doesn't change.
            h.RayleighFading.FiltGaussian.initialize;
            
            if h.Constructed, initialize(h); end
            
            h.PrivDopplerSpectrum = dopplerSpectrum_out;
        end
        %-----------------------------------------------------------------------
        function set.PrivDopplerSpectrum(h, dopplerSpectrum)
            % Set up listener for changes in properties of DopplerSpectrum
            for i_obj = 1:length(dopplerSpectrum)
                listener_vector(i_obj) = ...
                    handle.listener(dopplerSpectrum(i_obj), ...
                    'DopplerSpectrumPropertiesChanged', ...
                    @(hSrc, eData)updateChannel(h.DopplerSpectrum(i_obj), ...
                    h, i_obj) ); %#ok<MCSUP>
            end
            h.DopplerSpectrumPropertiesListener = listener_vector; %#ok<MCSUP>
            h.PrivDopplerSpectrum = dopplerSpectrum;
        end
        %-----------------------------------------------------------------------
        function dopplerSpectrum = get.DopplerSpectrum(h)
            dopplerSpectrum = h.PrivDopplerSpectrum;
        end
        %-----------------------------------------------------------------------
        function set.PathDelays(chan, tau)
            propName = 'PathDelays';
            validateattributes(tau, {'double'}, {'row', 'finite'}, ...
                [class(chan) '.' propName], propName);
            
            [~, Lt] = size(tau);
            
            LtOld = length(chan.ChannelFilter.PathDelays);
            PdBOld = chan.AvgPathGaindB;
            KFactorOld = chan.KFactor;
            
            chan.ChannelFilter.PathDelays = tau;
            
            if Lt~=LtOld
                % chan.RayleighFading.FiltGaussian and chan.RayleighFading are
                % re-initialized (and reset) later below, when DopplerSpectrum is
                % updated.
                %
                % chan.RayleighFading.FiltGaussian needs to be re-initialized because
                % its reset method uses chan.RayleighFading.FiltGaussian.NumChannels and
                % chan.RayleighFading.FiltGaussian.Statistics needs to be updated using
                % chan.RayleighFading.FiltGaussian.NumChannels .
                %
                % chan.RayleighFading.InterpFilter is re-initialized (and reset) via
                % setNumChannels, because its reset method uses
                % chan.RayleighFading.InterpFilter.NumChannels
                
                chan.RayleighFading.NumChannels = Lt;
                
                chan.AvgPathGaindB = tailorVector(PdBOld, tau);
                
                % This fires up listeners for DirectPathDopplerShift and
                % DirectPathInitPhase, which are also tailored accordingly.
                if (~isscalar(KFactorOld))
                    chan.KFactor = tailorVector(KFactorOld, tau);
                end
                
                % If Tx and Rx correlation arrays are 3-D, adjust them according to
                % length of PathDelays.
                if ndims(chan.TxCorrelationMatrix) == 3
                    if Lt>LtOld
                        % Extend with the default eye matrix.
                        Nt = chan.NumTxAntennas;
                        for i = LtOld+1:Lt
                            chan.TxCorrelationMatrix(:,:,i) = eye(Nt);
                        end
                    elseif Lt<LtOld
                        % Remove excessive correlation matrices.
                        chan.TxCorrelationMatrix = chan.TxCorrelationMatrix(:,:,1:Lt);
                    end
                end
                if ndims(chan.RxCorrelationMatrix) == 3
                    if Lt>LtOld
                        % Extend with the default eye matrix.
                        Nr = chan.NumRxAntennas;
                        for i = LtOld+1:Lt
                            chan.RxCorrelationMatrix(:,:,i) = eye(Nr);
                        end
                    elseif Lt<LtOld
                        % Remove excessive correlation matrices.
                        chan.RxCorrelationMatrix = chan.RxCorrelationMatrix(:,:,1:Lt);
                    end
                end
                
                % If different Doppler spectra per path, adjust vector of Doppler path
                % according to length of PathDelays.
                % Call to setDopplerSpectrum causes chan.RayleighFading.FiltGaussian,
                % and chan.RayleighFading.InterpFilter and chan.RayleighFading to be
                % re-initialized and reset.
                if length(chan.DopplerSpectrum)>1
                    if Lt>LtOld
                        % Extend with the default Jakes Doppler spectrum.
                        % Assign in one shot to avoid
                        % comm:mimo:Channel:DopplerSpectrum error in
                        % setDopplerSpectrum
                        chan.DopplerSpectrum(LtOld+1:Lt) = doppler.jakes;
                    elseif Lt<LtOld
                        % Remove excessive Doppler spectra by reassigning
                        % DopplerSpectrum
                        % Assign in one shot to avoid
                        % comm:mimo:Channel:DopplerSpectrum error in
                        % setDopplerSpectrum
                        chan.DopplerSpectrum = chan.DopplerSpectrum(1:Lt);
                    end
                else
                    % Re-initialize and reset chan.RayleighFading.FiltGaussian
                    % chan.RayleighFading.InterpFilter was re-initialized and reset above
                    % Re-initialize (=reset) chan.RayleighFading
                    if chan.RayleighFading.Constructed
                        chan.RayleighFading.FiltGaussian.initialize;
                        chan.RayleighFading.initialize;
                    end
                end
                
            end
            if chan.Constructed, initialize(chan); end
        end
        %-----------------------------------------------------------------------
        function tau = get.PathDelays(chan)
            tau = chan.ChannelFilter.PathDelays;
        end
        %-----------------------------------------------------------------------
        function set.AvgPathGaindB(chan, PdB)
            propName = 'AvgPathGaindB';
            validateattributes(PdB, {'double'}, {'row', 'finite', 'real'}, ...
                [class(chan) '.' propName], propName);
            
            if ~isequal(size(PdB), size(chan.PathDelays))
                error('comm:mimo:Channel:AvgPathGainsdB', ...
                    ['AvgPathGaindB must be real-valued and the same size' ...
                    ' as PathDelays.']);
            end
            
            chan.AvgPathGainVector = ...
                computePathGainVector(PdB, chan.NormalizePathGains);
            
            chan.PrivAvgPathGaindB = PdB;
        end
        %-----------------------------------------------------------------------
        function PdB = get.AvgPathGaindB(chan)
            PdB = chan.PrivAvgPathGaindB;
        end
        %-----------------------------------------------------------------------
        function set.NormalizePathGains(h, v)
            propName = 'NormalizePathGains';
            validateattributes(v, {'double'}, {'scalar'}, ...
                [class(h) '.' propName], propName);
            
            if (v ~= 0) && (v ~= 1)
                error('comm:mimo:Channel:NormalizePathGains', ...
                    'NormalizePathGains must be scalar boolean.');
            end
            
            h.AvgPathGainVector = computePathGainVector(h.AvgPathGaindB, v);
            
            h.PrivNormalizePathGains = v;
        end
        %-----------------------------------------------------------------------
        function v = get.NormalizePathGains(h)
            v = h.PrivNormalizePathGains;
        end
        %-----------------------------------------------------------------------
        function set.TxCorrelationMatrix(chan, Rt)
            
            L = length(chan.PathDelays);
            
            if chan.Constructed
                Nt = chan.ChannelFilter.NumTxAntennas;
                
                if (Nt==1)
                    if ~isequal(Rt, 1)
                        error('comm:mimo:Channel:TxCorrelationMatrix_nt1', ...
                            'TxCorrelationMatrix must be equal to 1 if NumTxAntennas is 1.');
                    end
                    Rtout = Rt;
                else
                    ndimsRt = ndims(Rt);
                    if (ndimsRt == 2)
                        [nr, nc] = size(Rt);
                        % Check that the matrix has the correct dimensions.
                        if (nr ~= Nt) || (nc ~= Nt)
                            error('comm:mimo:Channel:TxCorrelationMatrix_ndims2', ...
                                'TxCorrelationMatrix is not of size NumTxAntennas x NumTxAntennas.');
                        end
                        % Check that the matrix is a valid correlation matrix
                        % Matrix must be hermitian
                        if any(any(Rt' ~= Rt))
                            error('comm:mimo:Channel:TxCorrelationMatrix_hermitian', ...
                                'TxCorrelationMatrix must have hermitian symmetry.');
                        end
                        % Diagonal elements must be 1
                        if any(diag(Rt)-ones(nr,1))
                            error('comm:mimo:Channel:TxCorrelationMatrix_diag', ...
                                'The diagonal elements of TxCorrelationMatrix must be all ones.');
                        end
                        % Off-diagonal elements must have a magnitude <= 1
                        if any(any(abs(Rt)>1))
                            error('comm:mimo:Channel:TxCorrelationMatrix_offdiag', ...
                                ['The elements of TxCorrelationMatrix must have an absolute',...
                                ' value smaller or equal to 1.']);
                        end
                        Rtout = Rt;
                    elseif (ndimsRt == 3)
                        [nr, nc, np] = size(Rt);
                        % Check that the matrix has the correct dimensions.
                        if (nr ~= Nt) || (nc ~= Nt) || (np > L)
                            error('comm:mimo:Channel:TxCorrelationMatrix_ndims3', ...
                                ['TxCorrelationMatrix is not of size NumTxAntennas x ',...
                                'NumTxAntennas x L, L being the length of PathDelays.']);
                        end
                        % 3-D matrix expansion of TxCorrelationMatrix using previous 2-D value
                        Rtold = chan.TxCorrelationMatrix;
                        ndimsRtold = ndims(Rtold);
                        if ndimsRtold<ndimsRt
                            Rttemp = zeros(Nt, Nt, L);
                            for i = 1:L
                                Rttemp(:,:,i) = Rtold;
                            end
                        end
                        % Assign matrices to TxCorrelationMatrix
                        for i = 1:np
                            % Skip undefined matrices of Rt (which are all zeros)
                            if any(any(squeeze(Rt(:,:,i))))
                                Rttemp(:,:,i) = squeeze(Rt(:,:,i));
                            end
                        end
                        % Do checks on Rt
                        for i = 1:np
                            % Check that the matrix is a valid correlation matrix
                            % Matrix must be hermitian
                            Rt2D = squeeze(Rttemp(:,:,i));
                            if any(any(Rt2D' ~= Rt2D))
                                error('comm:mimo:Channel:TxCorrelationMatrix_hermitian3D', ...
                                    'TxCorrelationMatrix must have hermitian symmetry.');
                            end
                            % Diagonal elements must be 1
                            if any(diag(Rt2D)-ones(nr,1))
                                error('comm:mimo:Channel:TxCorrelationMatrix_diag3D', ...
                                    'The diagonal elements of TxCorrelationMatrix must be all ones.');
                            end
                            % Off-diagonal elements must have a magnitude <= 1
                            if any(any(abs(Rt2D)>1))
                                error('comm:mimo:Channel:TxCorrelationMatrix_offdiag3D', ...
                                    ['The elements of TxCorrelationMatrix must have an ',...
                                    'absolute value smaller or equal to 1.']);
                            end
                        end
                        % Assign Rt to TxCorrelationMatrix
                        Rtout = Rttemp;
                    else
                        error('comm:mimo:Channel:TxCorrelationMatrix_ndims', ...
                            ['TxCorrelationMatrix must be either a matrix or a three-dimensional'...
                            ' array.']);
                    end
                end
            else
                Rtout = Rt;
            end
            
            % Compute square-root correlation matrix
            Rr = chan.RxCorrelationMatrix;
            chan.RayleighFading.FiltGaussian.SQRTCorrelationMatrix = ...
                computeSQRTCorrelationMatrix(Rtout,Rr,L);
            
            chan.PrivTxCorrelationMatrix = Rtout;
        end
        %-----------------------------------------------------------------------
        function Rt = get.TxCorrelationMatrix(chan)
            Rt = chan.PrivTxCorrelationMatrix;
        end
        %-----------------------------------------------------------------------
        function set.RxCorrelationMatrix(chan, Rr)
            
            L = length(chan.PathDelays);
            
            if chan.Constructed
                
                Nr = chan.ChannelFilter.NumRxAntennas;
                
                if (Nr==1)
                    if ~isequal(Rr, 1)
                        error('comm:mimo:Channel:RxCorrelationMatrix_nr1', ...
                            'RxCorrelationMatrix must be equal to 1 if NumRxAntennas is 1.');
                    end
                    Rrout = Rr;
                else
                    ndimsRr = ndims(Rr);
                    if (ndimsRr == 2)
                        [nr, nc] = size(Rr);
                        % Check that the matrix has the correct dimensions.
                        if (nr ~= Nr) || (nc ~= Nr)
                            error('comm:mimo:Channel:RxCorrelationMatrix_ndims2', ...
                                'RxCorrelationMatrix is not of size NumRxAntennas x NumRxAntennas.');
                        end
                        % Check that the matrix is a valid correlation matrix
                        % Matrix must be hermitian
                        if any(any(Rr' ~= Rr))
                            error('comm:mimo:Channel:RxCorrelationMatrix_hermitian', ...
                                'RxCorrelationMatrix must have hermitian symmetry.');
                        end
                        % Diagonal elements must be 1
                        if any(diag(Rr)-ones(nr,1))
                            error('comm:mimo:Channel:RxCorrelationMatrix_diag', ...
                                'The diagonal elements of RxCorrelationMatrix must be all ones.');
                        end
                        % Off-diagonal elements must have a magnitude <= 1
                        if any(any(abs(Rr)>1))
                            error('comm:mimo:Channel:RxCorrelationMatrix_offdiag', ...
                                ['The elements of RxCorrelationMatrix must have an ',...
                                'absolute value smaller or equal to 1.']);
                        end
                        Rrout = Rr;
                    elseif (ndimsRr == 3)
                        [nr, nc, np] = size(Rr);
                        % Check that the matrix has the correct dimensions.
                        if (nr ~= Nr) || (nc ~= Nr) || (np > L)
                            error('comm:mimo:Channel:RxCorrelationMatrix_ndims3', ...
                                ['RxCorrelationMatrix is not of size NumRxAntennas x ',...
                                'NumRxAntennas x L, L being the length of PathDelays.']);
                        end
                        % 3-D matrix expansion of RxCorrelationMatrix using previous 2-D value
                        Rrold = chan.RxCorrelationMatrix;
                        ndimsRrold = ndims(Rrold);
                        if ndimsRrold<ndimsRr
                            Rrtemp = zeros(Nr, Nr, L);
                            for i = 1:L
                                Rrtemp(:,:,i) = Rrold;
                            end
                        end
                        % Assign matrices to TxCorrelationMatrix
                        for i = 1:np
                            % Skip undefined matrices of Rt (which are all zeros)
                            if any(any(squeeze(Rr(:,:,i))))
                                Rrtemp(:,:,i) = squeeze(Rr(:,:,i));
                            end
                        end
                        for i=1:np
                            % Check that the matrix is a valid correlation matrix
                            % Matrix must be hermitian
                            Rr2D = squeeze(Rrtemp(:,:,i));
                            if any(any(Rr2D' ~= Rr2D))
                                error('comm:mimo:Channel:RxCorrelationMatrix_hermitian3D', ...
                                    'RxCorrelationMatrix must have hermitian symmetry.');
                            end
                            % Diagonal elements must be 1
                            if any(diag(Rr2D)-ones(nr,1))
                                error('comm:mimo:Channel:RxCorrelationMatrix_diag3D', ...
                                    'The diagonal elements of RxCorrelationMatrix must be all ones.');
                            end
                            % Off-diagonal elements must have a magnitude <= 1
                            if any(any(abs(Rr2D)>1))
                                error('comm:mimo:Channel:RxCorrelationMatrix_offdiag3D', ...
                                    ['The elements of RxCorrelationMatrix must have an ',...
                                    'absolute value smaller or equal to 1.']);
                            end
                        end
                        % Assign Rr to RxCorrelationMatrix
                        Rrout = Rrtemp;
                    else
                        error('comm:mimo:Channel:RxCorrelationMatrix_ndims', ...
                            'RxCorrelationMatrix must be either a matrix or a three-dimensional array.');
                    end
                end
            else
                Rrout = Rr;
            end
            
            % Compute square-root correlation matrix
            Rt = chan.TxCorrelationMatrix;
            chan.RayleighFading.FiltGaussian.SQRTCorrelationMatrix = computeSQRTCorrelationMatrix(Rt,Rrout,L);
            
            chan.PrivRxCorrelationMatrix = Rrout;
        end
        %-----------------------------------------------------------------------
        function Rr = get.RxCorrelationMatrix(chan)
            Rr = chan.PrivRxCorrelationMatrix;
        end
        %-----------------------------------------------------------------------
        function set.KFactor(h, K)
            propName = 'KFactor';
            if isscalar(K)
                validateattributes(K, {'double'}, ...
                    {'scalar','finite','nonnegative'}, ...
                    [class(h) '.' propName], propName);
            else
                validateattributes(K, {'double'}, ...
                    {'row','finite','real','nonnegative'}, ...
                    [class(h) '.' propName], propName);
            end
            
            if ( ~isscalar(K) && ~isequal(size(K), size(h.PathDelays)) )
                error('comm:mimo:Channel:KFactor', ...
                    ['KFactor must be a scalar or a row vector of the same size' ...
                    ' as PathDelays.']);
            end
            
            h.PrivKFactor = K;
        end
        %-----------------------------------------------------------------------
        function K = get.KFactor(h)
            K = h.PrivKFactor;
        end
        %-----------------------------------------------------------------------
        function set.DirectPathDopplerShift(h, d)
            propName = 'DirectPathDopplerShift';
            validateattributes(d, {'double'}, ...
                {'row','finite','real'}, ...
                [class(h) '.' propName], propName);
            
            if ( ~isequal(size(d), size(h.KFactor)) )
                error('comm:mimo:Channel:DirectPathDopplerShift', ...
                    ['DirectPathDopplerShift must be of the same size' ...
                    ' as KFactor.']);
            end
            if h.Constructed    % To avoid repeating this warning upon constructing object
                if ( (h.MaxDopplerShift == 0) && any(d) )
                    warning('comm:mimo:Channel:DirectPathDopplerShift_fdIs0', ...
                        ['When the maximum Doppler shift is zero, setting DirectPathDopplerShift' ...
                        ' to a non-zero value has no effect on the channel.' ...
                        ' DirectPathDopplerShift should also be set to zero.']);
                end
            end
            
            h.PrivDirectPathDopplerShift = d;
        end
        %-----------------------------------------------------------------------
        function d = get.DirectPathDopplerShift(h)
            d = h.PrivDirectPathDopplerShift;
        end
        %-----------------------------------------------------------------------
        function set.DirectPathInitPhase(h, d)
            propName = 'DirectPathInitPhase';
            validateattributes(d, {'double'}, ...
                {'row','finite','real'}, ...
                [class(h) '.' propName], propName);
            
            if ( ~isequal(size(d), size(h.KFactor)) )
                error('comm:mimo:Channel:DirectPathInitPhase', ...
                    ['DirectPathInitPhase must be of the same size' ...
                    ' as KFactor.']);
            end
            if h.Constructed    % To avoid 'Attempt to reference field of non-structure array.' error
                if ( (h.MaxDopplerShift == 0) && any(d) )
                    warning('comm:mimo:Channel:DirectPathInitPhase_fdIs0', ...
                        ['When the maximum Doppler shift is zero, setting DirectPathInitPhase' ...
                        ' to a non-zero value has no effect on the channel.' ...
                        ' DirectPathInitPhase should also be set to zero.']);
                end
            end
            
            h.PrivDirectPathInitPhase = d;
        end
        %-----------------------------------------------------------------------
        function d = get.DirectPathInitPhase(h)
            d = h.PrivDirectPathInitPhase;
        end
        %-----------------------------------------------------------------------
        function set.LastThetaLOS(s, y)
            s.PrivateData.LastThetaLOS = y;
        end
        %-----------------------------------------------------------------------
        function y = get.LastThetaLOS(s)
            if isfield(s.PrivateData, 'LastThetaLOS')
                y = s.PrivateData.LastThetaLOS;
            end
        end
        %-----------------------------------------------------------------------
        function set.StorePathGains(h, v)
            propName = 'StorePathGains';
            validateattributes(v, {'double','logical'}, {'scalar'}, ...
                [class(h) '.' propName], propName);
            
            if (v ~= 0) && (v ~= 1)
                error('comm:mimo:Channel:StorePathGains', ...
                    'StorePathGains must be scalar boolean.');
            end
            
            if h.Constructed
                st = h.RayleighFading.FiltGaussian.Statistics;
                for i = 1:length(st)
                    st(i).Enable = v;
                end
                % Flushes out values of PathGains and keeps only last one
                if (~v)
                    % Set private property to avoid PathGains public set error.
                    h.PathGainsPrivate = h.PathGains(end, :);
                    for i = 1:length(st)
                        reset(st(i));
                    end
                end
            end
            
            h.PrivStorePathGains = v;
        end
        %-----------------------------------------------------------------------
        function v = get.StorePathGains(h)
            v = h.PrivStorePathGains;
        end
        %-----------------------------------------------------------------------
        function set.PathGains(chan, P)
            % Use private property to avoid PathGains public set error.
            chan.PathGainsPrivate = P;
        end
        %-----------------------------------------------------------------------
        function P = get.PathGains(chan)
            P = chan.PathGainsPrivate;
        end
        %-----------------------------------------------------------------------
        function d = get.ChannelFilterDelay(chan)
            % This property is retained for backward compatibility.
            d = chan.ChannelFilter.FilterDelay;
        end
        %-----------------------------------------------------------------------
        function set.ResetBeforeFiltering(chan, v)
            propName = 'ResetBeforeFiltering';
            validateattributes(v, {'double','logical'}, {'scalar'}, ...
                [class(chan) '.' propName], propName);
            
            if (v ~= 0) && (v ~= 1)
                error('comm:mimo:Channel:ResetBeforeFiltering', ...
                    'ResetBeforeFiltering must be scalar boolean.');
            end
            
            chan.ResetBeforeFiltering = v;
        end
    end
end

%===============================================================================
% Support functions
function P = computePathGainVector(PdB, normPG)
PP = 10.^(PdB/10);
if normPG
    PP = PP/sum(PP);
end
P = sqrt(PP.');
end

%-------------------------------------------------------------------------------
function v = tailorVector(v, ref)
Lref = length(ref);
Lv = length(v);
if Lv<Lref
    v = [v zeros(1, Lref-Lv)];
elseif Lv>Lref
    v = v(1:Lref);
end
end

%-------------------------------------------------------------------------------
function RHstored = computeSQRTCorrelationMatrix(Rt, Rr,L)

% To avoid having a warning for the case RH = ones(length(RH))
s = warning('off', 'MATLAB:sqrtm:SingularMatrix');

ndimsRt = ndims(Rt);
ndimsRr = ndims(Rr);

RHisStored = 0;

% Tx and Rx correlation matrices are specified on a per-path basis.
if ndimsRt==3 && ndimsRr==3
    [nrt, nct, npt] = size(Rt);
    [nrr, ncr, npr] = size(Rr);
    RH = zeros(nrt*nrr,nct*ncr,npt);
    np = min(npt, npr);
    for i = 1:np
        RH(:,:,i) = sqrtm(kron(squeeze(Rt(:,:,i)), squeeze(Rr(:,:,i))));
    end
    % The code below is necessary if the number of paths of the mimo object
    % is modified after channel construction.
    if npt>npr
        for i = np+1:npt
            RH(:,:,i) = sqrtm(kron(squeeze(Rt(:,:,i)), eye(nrr)));
        end
    elseif npt<npr
        for i = np+1:npr
            RH(:,:,i) = sqrtm(kron(eye(nrt), squeeze(Rr(:,:,i))));
        end
    else
    end
    % Only Tx correlation matrix is specified on a per-path basis.
elseif ndimsRt==3 && (ndimsRr==2 || ndimsRr==1)
    [nrt, nct, npt] = size(Rt);
    [nrr, ncr] = size(Rr);
    RH = zeros(nrt*nrr,nct*ncr,npt);
    for i = 1:npt
        RH(:,:,i) = sqrtm(kron(squeeze(Rt(:,:,i)), Rr));
    end
    % Only Rx correlation matrix is specified on a per-path basis.
elseif (ndimsRt==1 || ndimsRt==2) && ndimsRr==3
    [nrt, nct] = size(Rt);
    [nrr, ncr, npr] = size(Rr);
    RH = zeros(nrt*nrr,nct*ncr,npr);
    for i = 1:npr
        RH(:,:,i) = sqrtm(kron(Rt, squeeze(Rr(:,:,i))));
    end
    % Neither Tx or Rx correlation matrices are specified on a per-path basis.
else
    RH = sqrtm(kron(Rt, Rr));
    if isequal(RH, eye(length(RH)))     % Identity matrix
        RHstored = RH;
    else    % Non-identity matrix
        RHstored = repmat(RH,[1 L]);
    end
    RHisStored = 1;
end

if RHisStored == 0
    isEye = true;
    [nr, ~, np] = size(RH);
    for i = 1:np
        isEye = isEye && isequal(squeeze(RH(:,:,i)), eye(np));
    end
    if isEye    % Identity matrix
        RHstored = eye(nr);
    else        % Non-identity matrix
        RHstored = reshape(RH, [nr, np*nr]);
    end
end

warning(s);
end

%EOF