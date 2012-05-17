classdef RayleighFading < mimo.BaseSigProc
    %RayleighFading Returns a Rayleigh fading channel MIMO systems
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.3 $  $Date: 2009/05/23 07:48:36 $

    %===========================================================================
    % Public properties
    properties
        % Cutoff frequency factor.
        CutoffFrequencyFactor = 1.0;
        % String associated with cutoff frequency. This is used by parent
        % objects to rename the cutoff frequency in error messages.  For
        % example, a parent multipath channel object might want to call it
        % 'Maximum Doppler shift'.
        CutoffFrequencyName = {'Cutoff frequency'};
        % Maximum block length (for the filter method)
        MaxBlockLength = 1000;
        % Filtered Gaussian source object
        FiltGaussian
        % Interpolating filter object
        InterpFilter
    end

    %===========================================================================
    % Private properties
    properties (Access = private)
        % Maximum Doppler shift.
        PrivMaxDopplerShift = 0;
    end
    
    %===========================================================================
    % Public dependent properties
    properties (Dependent)
        % Maximum Doppler shift.
        MaxDopplerShift
        % Output signal sample period
        OutputSamplePeriod
        % Cutoff frequency
        CutoffFrequency
        % Number of channels (paths)
        NumChannels
        % Number of links
        NumLinks
        % Target filtered-Gaussian oversampling factor
        TargetFGOversampleFactor
    end

    %===========================================================================
    % Public methods
    methods
        function h = RayleighFading(varargin)
            %RAYLEIGHFADING  Construct rayleighfading (interpolating-filtered Gaussian) source object.
            %
            %  Inputs:
            %     Ts    - Output sampling period (s)
            %     fc    - Cutoff frequency (Hz)
            %     NC    - Number of channels (paths)
            %     NL    - Number of links
            %     fcStr - Cutoff frequency name (string)
            
            error(nargchk(0, 5, nargin));
            numParam = length(varargin);
            
            % Initialize private data.
            h.basesigproc_initprivatedata;
            
            pd = h.PrivateData;
            pd.TargetFGOversampleFactor = 10;
            h.PrivateData = pd;
            
            % Create structure storing argument values and default values.
            p = {'OutputSamplePeriod', 'CutoffFrequency', 'NumChannels', 'NumLinks'...
                'CutoffFrequencyName'};
            v = {1, 0, 1, 1, 'Cutoff frequency'};  % Default values
            v(1:numParam) = varargin;  % Assign argument values.
            s = cell2struct(v, p, 2);
            
            % Sample period and cutoff frequency.
            Ts = s.OutputSamplePeriod;
            fc = s.CutoffFrequency;
            fcStr = {s.CutoffFrequencyName};
            
            % Calculate interpolating factors.
            [KI, N] = intfiltgaussian_intfactor(Ts, fc, h.TargetFGOversampleFactor, ...
                fcStr{:});
            
            % Sample period for filtgaussian source.
            if (fc>0)
                fgTs = 1/(N*fc);
            else
                fgTs = Ts;
            end
            
            % Cutoff frequency name
            h.CutoffFrequencyName = fcStr;
            
            % Filtered Gaussian and interpolating filter objects
            h.FiltGaussian = mimo.FiltGaussian(fgTs, fc, s.NumChannels, s.NumLinks);
            h.InterpFilter = mimo.InterpFilter(KI(2), KI(3), s.NumChannels, s.NumLinks);
            
            h.initialize;
            
            h.Constructed = true;
        end
        %-----------------------------------------------------------------------
        function h = copy(this)
            h = mimo.RayleighFading(this.OutputSamplePeriod);

            mc = metaclass(h);
            props = mc.Properties;
            
            for p=1:length(props)
                pr = props{p};
                if (~pr.Dependent && ~pr.Transient)
                    h.(pr.Name) = this.(pr.Name);
                end
            end
            
            % Make copies of objects
            h.FiltGaussian = copy(this.FiltGaussian);
            h.InterpFilter = copy(this.InterpFilter);
        end
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function set.OutputSamplePeriod(h, Ts)
            propName = 'OutputSamplePeriod';
            validateattributes(Ts, {'double'}, {'nonnegative', 'scalar'}, ...
                [class(h) '.' propName], propName);
            
            setRates(h, Ts, h.CutoffFrequency);
        end
        %-----------------------------------------------------------------------
        function Ts = get.OutputSamplePeriod(h)
            
            fg = h.FiltGaussian;
            intf = h.InterpFilter;
            fc = fg.CutoffFrequency;
            N = fg.OversamplingFactor;
            K1 = intf.PolyphaseInterpFactor;
            K2 = intf.LinearInterpFactor;
            [fcmax, ifcmax] = max(fc);
            if fc>0
                % Use cutoff frequency and oversampling factor of fading process
                % with the highest bandwidth, as well as the corresponding
                % interpolation factors.
                Ts = 1/(K1*K2*N(ifcmax)*fcmax);
            else
                Ts = max(fg.OutputSamplePeriod);
            end
        end
        %-----------------------------------------------------------------------
        function set.CutoffFrequencyFactor(h, v)
            propName = 'CutoffFrequencyFactor';
            validateattributes(v, {'double'}, {'vector'}, ...
                [class(h) '.' propName], propName);
            
            h.CutoffFrequencyFactor = v;
        end
        %-----------------------------------------------------------------------
        function set.MaxDopplerShift(h, fd)
            propName = 'MaxDopplerShift';
            validateattributes(fd, {'double'}, {'nonnegative', 'scalar'}, ...
                [class(h) '.' propName], propName);
            
            h.CutoffFrequency = fd * h.CutoffFrequencyFactor;
            h.PrivMaxDopplerShift = fd;
        end
        %-----------------------------------------------------------------------
        function fd = get.MaxDopplerShift(h)
            fd = h.PrivMaxDopplerShift;
        end
        %-----------------------------------------------------------------------
        % Note: it can be a problem if the user directly changes CutoffFrequency
        % or OversamplingFactor of the filtered Gaussian source (same for
        % interpolating factors of interpolating filter).  Ts will get
        % automatically updated to account for these changes.  The correct
        % approach is to change CutoffFrequency via rayleighfading object
        % property.
        function set.CutoffFrequency(h, fc)
            if any(size(h.CutoffFrequency) ~= size(fc)) || ...
                    (all(size(h.CutoffFrequency) == size(fc)) ...
                    && any(h.CutoffFrequency ~= fc))
                propName = 'CutoffFrequency';
                validateattributes(fc, {'double'}, {'vector'}, ...
                    [class(h) '.' propName], propName);
                
                setRates(h, h.OutputSamplePeriod, fc);
            end
        end
        %-----------------------------------------------------------------------
        function fc = get.CutoffFrequency(h)
            
            fc = h.FiltGaussian.CutoffFrequency;
        end
        %-----------------------------------------------------------------------
        function set.NumChannels(h, N)
            propName = 'NumChannels';
            validateattributes(N, {'double'}, {'positive', 'integer', 'scalar'}, ...
                [class(h) '.' propName], propName);
            
            h.FiltGaussian.NumChannels = N;
            h.InterpFilter.NumChannels = N;
        end
        %-----------------------------------------------------------------------
        function N = get.NumChannels(h)
            
            N = h.FiltGaussian.NumChannels;
        end
        %-----------------------------------------------------------------------
        function set.NumLinks(h, N)
            propName = 'NumLinks';
            validateattributes(N, {'double'}, {'positive', 'integer', 'scalar'}, ...
                [class(h) '.' propName], propName);
            
            h.FiltGaussian.NumLinks = N;
            h.InterpFilter.NumLinks = N;
            if h.Constructed, initialize(h); end
        end
        %-----------------------------------------------------------------------
        function N = get.NumLinks(h)
            N = h.FiltGaussian.NumLinks;
        end
        %-----------------------------------------------------------------------
        function set.MaxBlockLength(h, N)
            propName = 'MaxBlockLength';
            validateattributes(N, {'double'}, {'positive', 'integer', 'scalar'}, ...
                [class(h) '.' propName], propName);
            
            h.MaxBlockLength = N;
        end
        %-----------------------------------------------------------------------
        function set.TargetFGOversampleFactor(h, N)
            propName = 'TargetFGOversampleFactor';
            validateattributes(N, {'double'}, {'positive', 'integer', 'scalar'}, ...
                [class(h) '.' propName], propName);
            
            h.PrivateData.TargetFGOversampleFactor = N;
            setRates(h, h.OutputSamplePeriod, h.CutoffFrequency);
        end
        %-----------------------------------------------------------------------
        function N = get.TargetFGOversampleFactor(h)
            
            N = h.PrivateData.TargetFGOversampleFactor;
        end
        %-----------------------------------------------------------------------
        function set.FiltGaussian(h, v)
            propName = 'FiltGaussian';
            validateattributes(v, {'mimo.FiltGaussian'}, {'scalar'}, ...
                [class(h) '.' propName], propName);

            h.FiltGaussian = v;
        end
        %-----------------------------------------------------------------------
        function set.InterpFilter(h, v)
            propName = 'InterpFilter';
            validateattributes(v, {'mimo.InterpFilter'}, {'scalar'}, ...
                [class(h) '.' propName], propName);

            h.InterpFilter = v;
        end
    end
end
