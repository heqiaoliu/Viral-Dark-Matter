classdef Sinestream < frest.AbstractInput
    % FREST.SINESTREAM Create sinestream input signal for frequency response
    % estimation
    %
    %   in=frest.Sinestream(sys) creates a sinestream input signal to
    %   validate the linear system sys. The parameters of sinestream input in
    %   is automatically determined based on the specified system sys.
    %
    %   in=frest.Sinestream(param1,val1,...) creates the sinestream input
    %   signal with manually specified parameter values.
    %
    %   Available parameters for Sinestream input are:
    %       'Frequency', The frequencies that will exist in Sinestream signal.
    %       'Amplitude', The amplitude value(s) of the frequencies.
    %       'NumPeriods', The number of periods of the frequencies.
    %       'SamplesPerPeriod', The number of samples for each period for the frequencies.
    %       'FreqUnits', The units of the frequencies ('rad/s' or 'Hz').
    %       'RampPeriods', The number of periods for linear ramping portion.
    %       'SimulationOrder', The order how the frequencies will be simulated,
    %       'Sequential' or 'OneAtATime'.
    %       'SettlingPeriods', The number of periods it takes to reach
    %       steady state. At the eventual frequency estimation, only those
    %       periods after settling periods will be used.
    %       'ApplyFilteringInFRESTIMATE', Enable frequency-selective
    %       filtering in frequency response estimation in order to minimize
    %       the effects of lower and higher frequencies. 
    %
    %
    %   See also frest.Chirp, frest.Random
    
    %  Author(s): Erman Korkut
    %  Revised:
%   Copyright 1986-2010 The MathWorks, Inc.
    % $Revision: 1.1.10.9 $ $Date: 2010/02/08 23:04:21 $
    
    %% PUBLIC PROPERTIES    
	properties (Access = public, Dependent)
        Frequency
        NumPeriods
        SamplesPerPeriod
        RampPeriods                
        SettlingPeriods
        ApplyFilteringInFRESTIMATE
        SimulationOrder
        FreqUnits
    end
    properties (Hidden = true)
        FixedTs
        Version
    end
    %% PRIVATE PROPERTIES
    % Raw data, not get/set methods. Methods interact with these properties
    % rather than public counterparts.
    properties (Access = protected)
        Frequency_
        NumPeriods_
        SamplesPerPeriod_
        RampPeriods_
        FreqUnits_
        SimulationOrder_
        SettlingPeriods_
        ApplyFilteringInFRESTIMATE_ = 'on'                
    end
    %% PUBLIC METHODS    
    methods
        %% Constructor
        function obj = Sinestream(varargin)
            obj.Version = 2;
            if nargin ~= 1 % Manual parameter specification
                obj = initializeParams(obj,varargin{:});
            else % Based on LTI object
                obj = determineParams(obj,varargin{1});
            end        
        end
        %% PROPERTY GET/SET API
        % ApplyFilteringInFRESTIMATE
        function val = get.ApplyFilteringInFRESTIMATE(obj)
            val = obj.ApplyFilteringInFRESTIMATE_;
        end
        function obj = set.ApplyFilteringInFRESTIMATE(obj,val)
            if ~any(strcmp(val,{'on','off'}))
                ctrlMsgUtils.error('Slcontrol:frest:InvalidFilteringSinestream');
            end
            obj.ApplyFilteringInFRESTIMATE_ = val;                        
        end
        % FreqUnits
        function val = get.FreqUnits(obj)
            val = obj.FreqUnits_;
        end
        function obj = set.FreqUnits(obj,val)
            if ~any(strcmp(val,{'rad/s','Hz'}))
                ctrlMsgUtils.error('Slcontrol:frest:InvalidFreqUnits',...
                    ctrlMsgUtils.message('Slcontrol:frest:LabelSinestream'));
            end
            obj.FreqUnits_ = val;
            if obj.CrossValidation_                
                checkFixedTsConsistency(obj);
            end
        end
        % SimulationOrder
        function val = get.SimulationOrder(obj)
            val = obj.SimulationOrder_;
        end
        function obj = set.SimulationOrder(obj,val)
            if ~any(strcmp(val,{'Sequential','OneAtATime'}))
                ctrlMsgUtils.error('Slcontrol:frest:InvalidSimulationOrderSinestream');
            end
            obj.SimulationOrder_ = val;
        end
        % Frequency
        function val = get.Frequency(obj)
            val = obj.Frequency_;
        end
        function obj = set.Frequency(obj,val)
            % Frequency values should be a double vector with unique values
            if (~isa(val,'double') || ~isvector(val) || ~isequal(length(val),length(unique(val))))
                ctrlMsgUtils.error('Slcontrol:frest:NonUniqueFrequencyInSinestream');
            end
            % Frequency values should consist of positive values
            if ~all(val > 0)
                ctrlMsgUtils.error('Slcontrol:frest:NonPositiveFrequencyInSinestream');
            end
            obj.Frequency_ = val;
            if obj.CrossValidation_
                % Number of frequencies should match with number of other
                % parameters                
                checkSizeConsistency(obj);
                checkFixedTsConsistency(obj);
            end
        end
        % NumPeriods
        function val = get.NumPeriods(obj)
            val = obj.NumPeriods_;
        end
        function obj = set.NumPeriods(obj,val)
            % Check that it is a double
            if ~isa(val,'double')
                ctrlMsgUtils.error('Slcontrol:frest:NonDoubleParameterForSinestream','NumPeriods');
            end
            % Check if it is integer-valued
            if ~isequal(round(val),val)
                ctrlMsgUtils.error('Slcontrol:frest:RoundingSinestream','NumPeriods');
            end
            obj.NumPeriods_ = val;
            if obj.CrossValidation_
                % Check size against frequency
                checkSizeAgainstFrequency(obj,val,'NumPeriods');
                % Check that that are enough cycles at the steady state
                checkEnoughCyclesAtSteadyState(obj);
                % Warn if not all steady state cycles are full amplitude.
                checkAllSSCyclesFullAmplitude(obj);
            end
        end
        % SamplesPerPeriod
        function val = get.SamplesPerPeriod(obj)
            val = obj.SamplesPerPeriod_;
        end
        function obj = set.SamplesPerPeriod(obj,val)
            % Check that it is a double
            if ~isa(val,'double')
                ctrlMsgUtils.error('Slcontrol:frest:NonDoubleParameterForSinestream','SamplesPerPeriod');
            end
            % Check if it is integer-valued
            if ~isequal(round(val),val)
                ctrlMsgUtils.error('Slcontrol:frest:RoundingSinestream','SamplesPerPeriod');
            end
            % Nyquist criterion check - SamplesPerPeriod should be greater than 2 for
            % each frequency
            if ~all(val>2)
                ctrlMsgUtils.error('Slcontrol:frest:NyquistNotSatisfiedSinestream');
            end
            obj.SamplesPerPeriod_ = val; 
            if obj.CrossValidation_
                % Check size against frequency
                checkSizeAgainstFrequency(obj,val,'SamplesPerPeriod');                
                checkFixedTsConsistency(obj)                       
            end
        end
        % RampPeriods
        function val = get.RampPeriods(obj)
            val = obj.RampPeriods_;
        end
        function obj = set.RampPeriods(obj,val)
            % Check that it is a double
            if ~isa(val,'double')
                ctrlMsgUtils.error('Slcontrol:frest:NonDoubleParameterForSinestream','RampPeriods');
            end
            % Check if it is integer-valued
            if ~isequal(round(val),val)
                ctrlMsgUtils.error('Slcontrol:frest:RoundingSinestream','RampPeriods');
            end
            obj.RampPeriods_ = val;
            if obj.CrossValidation_
                % Check size against frequency
                checkSizeAgainstFrequency(obj,val,'RampPeriods');                
                % Check that that are enough cycles at the steady state
                checkEnoughCyclesAtSteadyState(obj);
                % Warn if not all steady state cycles are full amplitude.
                checkAllSSCyclesFullAmplitude(obj);                
            end
        end
        % SettlingPeriods
        function val = get.SettlingPeriods(obj)
            val = obj.SettlingPeriods_;
        end
        function obj = set.SettlingPeriods(obj,val)
            % Check that it is a double
            if ~isa(val,'double')
                ctrlMsgUtils.error('Slcontrol:frest:NonDoubleParameterForSinestream','SettlingPeriods');
            end
            % Check if it is integer-valued
            if ~isequal(round(val),val)
                ctrlMsgUtils.error('Slcontrol:frest:RoundingSinestream','SettlingPeriods');
            end
            obj.SettlingPeriods_ = val;
            if obj.CrossValidation_
                % Check size against frequency
                checkSizeAgainstFrequency(obj,val,'SettlingPeriods');
                % Check that that are enough cycles at the steady state
                checkEnoughCyclesAtSteadyState(obj);
                % Warn if not all steady state cycles are full amplitude.
                checkAllSSCyclesFullAmplitude(obj);
            end
        end
        % SET METHOD to set multiple properties at once
        function obj = set(obj,varargin)
            % Parameters and values should be in pairs
            if (rem(nargin-1,2) ~= 0)
                ctrlMsgUtils.error('Slcontrol:frest:SetError');
            end
            obj.CrossValidation_ = false;
            % Set the specified parameters
            for ct = 1:length(varargin)/2
                try
                    obj.(varargin{2*ct-1}) = varargin{2*ct};
                catch Me
                    if strcmp(Me.identifier,'MATLAB:noPublicFieldForClass')
                        % Invalid parameter specified
                        ctrlMsgUtils.error('Slcontrol:frest:InvalidParameterSpecification',...
                            ctrlMsgUtils.message('Slcontrol:frest:LabelSinestream'),...
                            varargin{2*ct-1},ctrlMsgUtils.message('Slcontrol:frest:LabelSinestream'));
                    else
                        rethrow(Me)
                    end
                end
            end
            obj.CrossValidation_ = true;
            % Run a consistency check
            checkConsistency(obj);
        end
        %% SET/GET API HELPER METHODS FOR CHECKS
        function checkSizeAgainstFrequency(obj,val,publicname)
            len = length(obj.Frequency_);
            if ~(isscalar(val) || (isvector(val)&&(length(val) == len)))
                ctrlMsgUtils.error('Slcontrol:frest:IncompatibleSizeForSinestream',publicname,'Frequency');
            end
        end
        function checkSizeConsistency(obj)
            % Check if sizes of individual properties are compatible with
            % size of frequency.
            if ~isempty(obj.Amplitude_),checkSizeAgainstFrequency(obj,obj.Amplitude_,'Amplitude'); end;
            if ~isempty(obj.NumPeriods_),checkSizeAgainstFrequency(obj,obj.NumPeriods_,'NumPeriods'); end;
            if ~isempty(obj.SamplesPerPeriod_),checkSizeAgainstFrequency(obj,obj.SamplesPerPeriod_,'SamplesPerPeriod'); end;
            if ~isempty(obj.RampPeriods_),checkSizeAgainstFrequency(obj,obj.RampPeriods_,'RampPeriods'); end;
            if ~isempty(obj.SettlingPeriods_),checkSizeAgainstFrequency(obj,obj.SettlingPeriods_,'SettlingPeriods'); end;            
        end
        function checkEnoughCyclesAtSteadyState(obj)
            % Check that there exist enough periods at steady state. The frequency
            % response estimation algorithm in FRESTIMATE requires that there should be
            % at least 3 periods where 2 of them are full cycles, not ramping cycles if
            % "ApplyFilteringInFRESTIMATE" is 'on'. If it is off, there should be at
            % least 1 period at steady state and it should be a full cycle.
            % Scalar expand relevant parameters
            ramp = obj.RampPeriods_.*ones(size(obj.Frequency_));
            nump = obj.NumPeriods_.*ones(size(obj.Frequency_));
            ssper = obj.SettlingPeriods_.*ones(size(obj.Frequency_));
            for ct = 1:numel(obj.Frequency_)
                if strcmp(obj.ApplyFilteringInFRESTIMATE_,'on')
                    minsscycles = 3;
                    minfullcycles = 2;
                    strfilt = 'on';
                else
                    minsscycles = 1;
                    minfullcycles = 1;
                    strfilt = 'off';
                end
                % Check steady state
                if nump(ct)+ramp(ct)-ssper(ct) < minsscycles
                    ctrlMsgUtils.error('Slcontrol:frest:InsufficientCyclesSinestream',...
                        strfilt,minsscycles,sprintf('%g',obj.Frequency_(ct)),ct);
                end
                % Check full cycles
                if nump(ct) < minfullcycles
                    ctrlMsgUtils.error('Slcontrol:frest:InsufficientFullCyclesSinestream',...
                        strfilt,minfullcycles,minfullcycles,sprintf('%g',obj.Frequency_(ct)),ct);
                end
            end            
        end
        function checkAllSSCyclesFullAmplitude(obj)
            % Check that all the cycles that are going to be considered as
            % steady state in FRESTIMATE is of full amplitude and throw a
            % warning otherwise.
            % Scalar expand relevant parameters
            ramp = obj.RampPeriods_.*ones(size(obj.Frequency_));
            nump = obj.NumPeriods_.*ones(size(obj.Frequency_));
            ssper = obj.SettlingPeriods_.*ones(size(obj.Frequency_));
            numsscycles = ramp+nump-ssper;
            if strcmp(obj.ApplyFilteringInFRESTIMATE_,'on')
                alloweddiff = 1;                
            else
                alloweddiff = 0;               
            end
            % Loop through frequencies and report the first frequency that
            % does not satisfy this condition.
            for ct = 1:numel(obj.Frequency_)
                if (nump(ct)+alloweddiff) < numsscycles(ct)
                    ctrlMsgUtils.warning('Slcontrol:frest:NotAllSSCyclesFullSinestream',...
                        sprintf('%g',obj.Frequency_(ct)),ct);
                    break;
                end
            end
                
        end
        function checkFixedTsConsistency(obj)
            % Fixed sample time check
            if obj.FixedTs ~= -2
                % Compute sample times
                ts = 1./unitconv(obj.Frequency_,obj.FreqUnits_,'Hz')./obj.SamplesPerPeriod_;
                if any(diff(ts) > sqrt(eps)) || any(abs(ts-obj.FixedTs) > sqrt(eps))
                    ctrlMsgUtils.error('Slcontrol:frest:InvalidFreqSamplesPerPeriodCombinationFixedTs');
                end
            end            
        end
        function checkConsistency(obj,varargin)
            checkSizeConsistency(obj);        
            checkEnoughCyclesAtSteadyState(obj);
            checkFixedTsConsistency(obj);
            checkAllSSCyclesFullAmplitude(obj);
        end                
        %% HORZCAT/VERTCAT for merging two Sinestream objects
        function out = horzcat(obj,varargin)
            out = obj;
            for ct = 1:length(varargin)
                next_in = varargin{ct};
                % Make sure it is a Sinestream input too
                if ~isa(next_in,'frest.Sinestream')
                    ctrlMsgUtils.error('Slcontrol:frest:TypeMismatchConcatenateSinestream',class(next_in));
                end
                % Check that no frequency exists already
                mergedfreq = [out.Frequency_(:);next_in.Frequency_(:)];
                if ~isequal(numel(mergedfreq),numel(unique(mergedfreq)))
                    ctrlMsgUtils.error('Slcontrol:frest:FreqExistsConcatenateSinestream');
                end
                if ~strcmp(next_in.FreqUnits_,obj.FreqUnits_)
                    ctrlMsgUtils.error('Slcontrol:frest:DifferentUnitsConcatenateSinestream');
                end
                % Merge other per-frequency parameters
                out = concatenateProps(out,'Amplitude_',next_in);
                out = concatenateProps(out,'NumPeriods_',next_in);                    
                out = concatenateProps(out,'SamplesPerPeriod_',next_in);
                out = concatenateProps(out,'RampPeriods_',next_in);
                out = concatenateProps(out,'SettlingPeriods_',next_in);
                out.Frequency = mergedfreq(:)';
            end
        end
        function out = vertcat(obj,varargin)
            out = horzcat(obj,varargin{:});
        end
        function obj = concatenateProps(obj,property,next)
            origprop = obj.(property);
            nextprop = next.(property);
            % If both scalar, handle the situation
            if isscalar(nextprop) && isscalar(origprop)
                if nextprop == origprop
                    % Nothing to do
                    return;
                else
                    % Scalar expand both and append
                    origprop = origprop*ones(size(obj.Frequency_));
                    nextprop = nextprop*ones(size(next.Frequency_));
                    obj.(property) = [origprop(:);nextprop(:)]';
                    return;
                end
            else
                % Scalar expand if necessary
                if isscalar(nextprop)
                    nextprop = nextprop*ones(size(next.Frequency_));
                end
                if isscalar(origprop)
                    origprop = origprop*ones(size(obj.Frequency_));
                end
                % Append
                obj.(property) = [origprop(:);nextprop(:)]';
                return;
            end
        end
        %% OTHER UTILITY METHODS
        % Display
        function display(obj)
            numElem = 5;
            prec = 5;
            disp(' ');
            if usejava('Swing') && desktop('-inuse') && feature('hotlinks')
                disp(ctrlMsgUtils.message('Slcontrol:frest:SinestreamInputSignalWithHelpLink'));
            else
                disp(ctrlMsgUtils.message('Slcontrol:frest:SinestreamInputSignal'));
            end
            disp(' ');            
            % Display only first 4 frequency
            if length(obj.Frequency) < numElem
                str = mat2str(obj.Frequency,prec);
            else
                str = mat2str(obj.Frequency(1:numElem-1),prec);
                str(end:end+4) = ' ...]';
            end
            fprintf('      Frequency           : %s (%s)\n',str,obj.FreqUnits);
            if length(obj.Amplitude) < numElem
                str = mat2str(obj.Amplitude);
            else
                str = mat2str(obj.Amplitude(1:numElem-1),prec);
                str(end:end+4) = ' ...]';
            end
            fprintf('      Amplitude           : %s\n',str);
            if length(obj.SamplesPerPeriod) < numElem
                str = mat2str(obj.SamplesPerPeriod);
            else
                str = mat2str(obj.SamplesPerPeriod(1:numElem-1));
                str(end:end+4) = ' ...]';                
            end
            fprintf('      SamplesPerPeriod    : %s\n',str);
            if length(obj.NumPeriods) < numElem                
                str = mat2str(obj.NumPeriods);
            else
                str = mat2str(obj.NumPeriods(1:numElem-1));
                str(end:end+4) = ' ...]';
            end
            fprintf('      NumPeriods          : %s\n',str);
            if length(obj.RampPeriods) < numElem
                str = mat2str(obj.RampPeriods);
            else
                str = mat2str(obj.RampPeriods(1:numElem-1));
                str(end:end+4) = ' ...]';                
            end            
            fprintf('      RampPeriods         : %s\n',str);
            fprintf('      FreqUnits (rad/s,Hz): %s\n',obj.FreqUnits);
            if length(obj.SettlingPeriods) < numElem
                str = mat2str(obj.SettlingPeriods,prec);
            else
                str = mat2str(obj.SettlingPeriods(1:numElem-1),prec);
                str(end:end+4) = ' ...]';                
            end
            fprintf('      SettlingPeriods     : %s\n',str);
            fprintf('      ApplyFilteringInFRESTIMATE (on/off)    : %s\n',obj.ApplyFilteringInFRESTIMATE);
            fprintf('      SimulationOrder (Sequential/OneAtATime): %s\n',obj.SimulationOrder);
            disp(' ');
        end
        % Disp - simply call display
        function disp(obj)
            display(obj)
        end
        % Computing frequency and steady state swtich points in the Sinestream signal
        function [freqswitchpoints,ssswitchpoints] = computeSwitchPoints(obj)
            numSamples = (obj.NumPeriods_+obj.RampPeriods_).*obj.SamplesPerPeriod_;
            if isscalar(numSamples)
                numSamples = numSamples*ones(size(obj.Frequency_));
            end
            freqswitchpoints = cumsum(numSamples);
            freqswitchpoints = freqswitchpoints(:);
            ssswitchpoints = obj.SettlingPeriods_.*obj.SamplesPerPeriod_;
            ssswitchpoints = ssswitchpoints(:) + [0;freqswitchpoints(1:end-1)];
        end                
    end
    %% PROTECTED METHODS
    methods (Access = protected)
        % Parameter initialization using manually specified values and
        % defaults
        function obj = initializeParams(obj,varargin)
            obj.CrossValidation_ = false;
            % Set the specified parameters
            for ct = 1:length(varargin)/2
                try
                    obj.(varargin{2*ct-1}) = varargin{2*ct};
                catch Me
                    if strcmp(Me.identifier,'MATLAB:noPublicFieldForClass')
                        % Invalid parameter specified
                        ctrlMsgUtils.error('Slcontrol:frest:InvalidParameterSpecification',...
                            ctrlMsgUtils.message('Slcontrol:frest:LabelSinestream'),...
                            varargin{2*ct-1},...
                            ctrlMsgUtils.message('Slcontrol:frest:LabelSinestream'));
                    else
                        rethrow(Me)
                    end
                end
            end
            % Set the default values for the remaining parameters
            if isempty(obj.FreqUnits_)
                obj.FreqUnits_ = 'rad/s';
            end
            if isempty(obj.Frequency_)
                if strcmp(obj.FreqUnits_,'rad/s')
                    obj.Frequency_ = logspace(1,3,30);
                else
                    obj.Frequency_ = linspace(10,1000,30);
                end
            end
            % At this point, only sizes should be check among specified
            % values. If we dont check here and the sizes are not matching,
            % we might end up with errors in NumPeriods computation below.
            checkSizeConsistency(obj);
            if isempty(obj.SettlingPeriods_)
                obj.SettlingPeriods_ = 1;
            end
            if isempty(obj.RampPeriods_)
                obj.RampPeriods_ = 0;
            end
            if isempty(obj.NumPeriods_)
                % Guaranteeing at least 3 periods after settling periods
                % and at least 2 full periods
                obj.NumPeriods_ = max(3-obj.RampPeriods_+obj.SettlingPeriods_,2);
            end
            if isempty(obj.SimulationOrder_)
                obj.SimulationOrder_ = 'Sequential';
            end
            if isempty(obj.Amplitude_)
                obj.Amplitude_ = 1e-5;
            end
            if isempty(obj.SamplesPerPeriod_)
                obj.SamplesPerPeriod_ = 40;
            end
            % Set the hidden parameter FixedTs
            if isempty(obj.FixedTs)
                obj.FixedTs = -2;
            end
            checkConsistency(obj);
            obj.CrossValidation_ = true;
        end
        % Parameter initialization given an LTI object
        function obj = determineParams(obj,sys)
            if ~any(strcmp(class(sys),{'ss','tf','zpk'}))
               % Invalid system
               ctrlMsgUtils.error('Slcontrol:frest:InvalidSystemSpecification','Sinestream');
            end
            if hasdelay(sys)
                % Use pade to avoid warnings with zero and pole
                sys = pade(sys);
            end
            if ~isstable(sys)
                % Check stability
                ctrlMsgUtils.error('Slcontrol:frest:UnstableSystemSpecification','Sinestream');
            end
            % Check against linearizations of zero: Use default values and
            % throw a warning
            % Get the state space data
            [A,B,C,D] = ssdata(sys);
            if all(D(:)==0) && ((isempty(C) || all(C(:)==0)) || (isempty(B) || all(B(:)==0)))
                % Create default values
                obj = frest.Sinestream;
                % Throw a warning and return
                ctrlMsgUtils.warning('Slcontrol:frest:ZeroSystemSpecification','Sinestream');
                return;                
            end
            if (sys.Ts == 0)
                % For continuous systems, come up with a regular
                % variable-sample time Sinestream
                % Set the items that do not depend on system
                obj.FreqUnits_ = 'rad/s';
                obj.SamplesPerPeriod_ = 40;
                obj.RampPeriods_ = 0;
                obj.Amplitude_ = 1e-5;
                obj.SimulationOrder_ = 'Sequential';
                obj.FixedTs = -2;
                % Start by finding frequencies
                obj.Frequency_ = unique(frest.AbstractInput.pickTestFreq({zero(sys)},{pole(sys)},sys.Ts));
                % Define the gap between the amplitude response at steady state
                % and the decayed transient.
                w = obj.Frequency_;
                G = freqresp(sys,w);
                per_settle = 1;
                gap_desired = abs(G)*per_settle/100;
                % Define the frequency cutoff
                cutoff_factor = 1000;                
                % Get the scaled state space data
                Ts = sys.Ts;
                [A,B,C] = xscale(A,B,C,D,[],Ts);
                % Compute the settle time
                obj.SettlingPeriods_ = frest.Sinestream.computeSineSettleCycles(...
                        A,B,C,Ts,gap_desired,w,cutoff_factor);
                % Compute NumPeriods to be 3 cycles more than settling
                % periods
                obj.NumPeriods_ = 3+obj.SettlingPeriods_;
            else
                % Use createFixedTsSinestream utility for discrete systems
                obj = frest.createFixedTsSinestream(sys.Ts,sys);                
            end
        end
    end
    %% STATIC METHODS
    methods(Static = true)
        Ncycles = computeSineSettleCycles(A,B,C,Ts,thresh,w,varargin)
        filt = designFIRFilter(tssig,N)
        function obj = loadobj(data)
            if isa(data,'struct')
                obj = frest.Sinestream;
                % Loading from a previous version            
                % When loading from R2009b MAT-files, make sure property values
                % are placed in raw hidden properties.
                if ~isfield(data,'Version')
                    % R2009b version
                    obj.Frequency_ = data.Frequency;
                    obj.NumPeriods_ = data.NumPeriods;
                    obj.SamplesPerPeriod_ = data.SamplesPerPeriod;
                    obj.RampPeriods_ = data.RampPeriods;
                    obj.FreqUnits_ = data.FreqUnits;
                    obj.SimulationOrder_ = data.SimulationOrder;
                    obj.SettlingPeriods_ = data.SettlingPeriods;
                    obj.ApplyFilteringInFRESTIMATE_ = data.ApplyFilteringInFRESTIMATE;
                    obj.FixedTs = data.FixedTs;
                    obj.Amplitude_ = data.Amplitude;
                end
            elseif isa(data,'frest.Sinestream')
                % Current version
                obj = data;
            end               
            obj.CrossValidation_ = true;
            checkConsistency(obj);
        end
    end        
end






    


