classdef Chirp < frest.AbstractInput
    % FREST.CHIRP Create chirp input signal for frequency response estimation
    %
    %   in=frest.Chirp(sys) creates a Chirp input signal to
    %   validate the linear system sys. The parameters of Chirp input in
    %   is automatically determined based on the specified system sys.
    %
    %   in=frest.Chirp(param1,val1,...) creates the Chirp input
    %   signal with manually specified parameter values.
    %
    %   Available parameters for sinestream input are:
    %       'FreqRange', The frequency range that will be swept as a
    %       two-element vector as in "[w1 w2]" or as two-element cell
    %       array as in {w1 w2}.   
    %       'Amplitude', The amplitude value of the Chirp signal.
    %       'Ts', The sample time of the Chirp signal.
    %       'NumSamples', The number of samples in the Chirp signal.
    %       'FreqUnits', The units of the frequencies ('rad/s' or 'Hz').
    %       'SweepMethod', The method how instantenous frequency evolves.
    %       'InitialPhase', The initial phase of the Chirp signal.
    %       'Shape', The shape of sweeping for quadratic sweep
    %       (convex,concave). For all other sweeping methods (linear and
    %       logarithmic), it has to be unspecified.
    %
    %
    %   See also frest.Sinestream, frest.Random
    
    %  Author(s): Erman Korkut
    %  Revised:
%   Copyright 1986-2010 The MathWorks, Inc.
    % $Revision: 1.1.10.8 $ $Date: 2010/02/17 19:07:46 $
    
    %% PUBLIC PROPERTIES    
	properties (Access = public, Dependent)
        FreqRange
        Ts
        NumSamples
        FreqUnits
        SweepMethod
        InitialPhase
        Shape
    end
    %% PRIVATE PROPERTIES
    % Raw data, not get/set methods. Methods interact with these properties
    % rather than public counterparts.
    properties (Access = protected)
        FreqRange_
        Ts_
        NumSamples_
        FreqUnits_
        SweepMethod_
        InitialPhase_
        Shape_
    end
    properties (Hidden = true)
        Version
    end
    %% PUBLIC METHODS    
    methods
        %% Constructor
        function obj = Chirp(varargin)
            obj.Version = 2;
            if nargin ~= 1 % Manual parameter specification
                obj = initializeParams(obj,varargin{:});
            else % Based on LTI object
                obj = determineParams(obj,varargin{1});
            end
        end
        %% PROPERTY GET/SET API
        % FreqUnits
        function val = get.FreqUnits(obj)
            val = obj.FreqUnits_;
        end
        function obj = set.FreqUnits(obj,val)
            if ~any(strcmp(val,{'rad/s','Hz'}))
                ctrlMsgUtils.error('Slcontrol:frest:InvalidFreqUnits',...
                    ctrlMsgUtils.message('Slcontrol:frest:LabelChirp'));
            end
            obj.FreqUnits_ = val;
            if obj.CrossValidation_
                checkNyquistCriterion(obj);
                checkNumSamplesSufficieny(obj);
            end
        end
        % SweepMethod
        function val = get.SweepMethod(obj)
            val = obj.SweepMethod_;
        end
        function obj = set.SweepMethod(obj,val)
            if ~any(strcmp(val,{'linear','quadratic','logarithmic'}))
                ctrlMsgUtils.error('Slcontrol:frest:InvalidSweepMethodChirp');
            end
            obj.SweepMethod_ = val;
            if obj.CrossValidation_
                checkShapeConsistency(obj);
            end
        end
        % FreqRange
        function val = get.FreqRange(obj)
            val = obj.FreqRange_;
        end
        function obj = set.FreqRange(obj,val)
            % First, convert from cell if cell
            if iscell(val)
                val = cell2mat(val);
            end
            % Check type/size
            if (~isa(val,'double') || ~isvector(val) || (numel(val)>2) || isequal(val(1),val(2)))
                ctrlMsgUtils.error('Slcontrol:frest:InvalidFreqRangeChirp');
            end
            obj.FreqRange_ = val;
            if obj.CrossValidation_
                checkNyquistCriterion(obj);
                checkNumSamplesSufficieny(obj);
            end
        end
        % Ts
        function val = get.Ts(obj)
            val = obj.Ts_;
        end
        function obj = set.Ts(obj,val)
            % Type
            if ~isscalar(val) || ~isa(val,'double')
                ctrlMsgUtils.error('Slcontrol:frest:InvalidParameterSizeChirpRandom','Ts',...
                    ctrlMsgUtils.message('Slcontrol:frest:LabelChirp'));
            end
            obj.Ts_ = val;
            if obj.CrossValidation_
                checkNyquistCriterion(obj);
                checkNumSamplesSufficieny(obj);
            end
        end
        % NumSamples
        function val = get.NumSamples(obj)
            val = obj.NumSamples_;
        end
        function obj = set.NumSamples(obj,val)
            % Type
            if ~isscalar(val) || ~isa(val,'double')
                ctrlMsgUtils.error('Slcontrol:frest:InvalidParameterSizeChirpRandom','NumSamples',...
                    ctrlMsgUtils.message('Slcontrol:frest:LabelChirp'));
            end
            % Integer
            if ~isequal(round(val),val)
                ctrlMsgUtils.error('Slcontrol:frest:RoundingChirpRandom',...
                    ctrlMsgUtils.message('Slcontrol:frest:LabelChirp'),sprintf('%g',val));
            end
            obj.NumSamples_ = val;
            if obj.CrossValidation_
                checkNyquistCriterion(obj);
                checkNumSamplesSufficieny(obj);
            end
        end
        % InitialPhase
        function val = get.InitialPhase(obj)
            val = obj.InitialPhase_;
        end
        function obj = set.InitialPhase(obj,val)
            if ~isscalar(val) || ~isa(val,'double')
                ctrlMsgUtils.error('Slcontrol:frest:InvalidParameterSizeChirpRandom','InitialPhase',...
                    ctrlMsgUtils.message('Slcontrol:frest:LabelChirp'));
            end
            obj.InitialPhase_ = val;
        end
        % Shape
        function val = get.Shape(obj)
            val = obj.Shape_;
        end
        function obj = set.Shape(obj,val)
            if ~any(strcmp(val,{'convex','concave',''}))
                ctrlMsgUtils.error('Slcontrol:frest:InvalidShapeChirp');
            end
            obj.Shape_ = val;
            if obj.CrossValidation_
                checkShapeConsistency(obj);
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
                            ctrlMsgUtils.message('Slcontrol:frest:LabelChirp'),...
                            varargin{2*ct-1},...
                            ctrlMsgUtils.message('Slcontrol:frest:LabelChirp'));
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
        function checkNyquistCriterion(obj)
            if (1/obj.Ts_)<=2*unitconv(max(obj.FreqRange_),obj.FreqUnits_,'Hz')
                ctrlMsgUtils.error('Slcontrol:frest:NyquistNotSatisfiedChirp',sprintf('%g',1/(2*unitconv(max(obj.FreqRange_),obj.FreqUnits_,'Hz'))));
            end
        end
        function checkNumSamplesSufficieny(obj)
            fl = unitconv(min(obj.FreqRange_),obj.FreqUnits_,'Hz');
            if (1/obj.Ts_/obj.NumSamples_ > fl + sqrt(eps))
                ctrlMsgUtils.warning('Slcontrol:frest:InsufficientNumSamplesChirp',obj.NumSamples_);
            end
        end
        function checkShapeConsistency(obj)
            % Convex/concave is only defined for quadratic
            if ~strcmp(obj.Shape_,'') && ~strcmp(obj.SweepMethod_,'quadratic')
                ctrlMsgUtils.error('Slcontrol:frest:InvalidShapeConvexChirp');
            end
        end
        function checkConsistency(obj)
            % Nyquist check
            checkNyquistCriterion(obj);
            % Convex/concave only for quadratic
            checkShapeConsistency(obj)
            % Check the insufficient samples warning
            checkNumSamplesSufficieny(obj);
        end
        % Display method
        function display(obj)
            disp(' ');
            if usejava('Swing') && desktop('-inuse') && feature('hotlinks')
                disp(ctrlMsgUtils.message('Slcontrol:frest:ChirpInputSignalWithHelpLink'));
            else
                disp(ctrlMsgUtils.message('Slcontrol:frest:ChirpInputSignal'));
            end
            disp(' ');
            fprintf('      FreqRange              : %s (%s)\n',mat2str(obj.FreqRange),obj.FreqUnits);
            fprintf('      Amplitude              : %s\n',mat2str(obj.Amplitude));
            fprintf('      Ts                     : %s (sec)\n',mat2str(obj.Ts));
            fprintf('      NumSamples             : %s\n',mat2str(obj.NumSamples));
            fprintf('      InitialPhase           : %s (deg)\n',mat2str(obj.InitialPhase));
            fprintf('      FreqUnits (rad/s or Hz): %s\n',obj.FreqUnits);
            fprintf('      SweepMethod(linear/    : %s\n',obj.SweepMethod);
            fprintf('                  quadratic/\n');
            fprintf('                  logarithmic)\n');
            if strcmp(obj.SweepMethod,'quadratic')
                fprintf('      Shape         (concave/: %s\n',obj.Shape);
                fprintf('                       convex)\n');
            end
            disp(' ');
        end
        function disp(obj)
            display(obj)
        end
        function timeins = TranslateFromFrequencyToTime(obj,freq)
            tf = (obj.Ts*(obj.NumSamples-1));
            f1 = obj.FreqRange(1);f2 = obj.FreqRange(2);
            switch obj.SweepMethod
                case 'linear'
                    timeins = tf.*(freq-f1)./(f2-f1);
                case 'quadratic'
                    % For 'convex-upsweep' and 'concave-downsweep' modes
                    if ((f1<f2) && strcmpi(obj.Shape,'convex')) || ((f1>f2) &&...
                            strcmpi(obj.Shape,'concave'))
                        timeins = zeros(size(freq));
                        for ct = 1:numel(freq)
                            % Find roots of polynomial expression. The
                            % polynomial coefficient are obtained by
                            % finding the polynomial that passes through
                            % (0,f1), (tf,f2) and has zero derivative at tf
                            a = -1*(f2-f1)/(tf^2);b = -2*a*tf;c = f1-freq(ct);
                            timeins_cand = roots([a b c]);
                            timeins(ct) = unique(timeins_cand(timeins_cand >= 0 & timeins_cand <= tf));
                        end
                    else
                        beta = (f2-f1)/(tf^2);
                        timeins = sqrt((freq-f1)./beta);
                    end
                case 'logarithmic'
                    beta = (f2/f1)^(1/tf);
                    timeins = log(freq./f1)/log(beta);
            end
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
                            ctrlMsgUtils.message('Slcontrol:frest:LabelChirp'),...
                            varargin{2*ct-1},...
                            ctrlMsgUtils.message('Slcontrol:frest:LabelChirp'));
                    else
                        rethrow(Me)
                    end
                end
            end
            % Set the default values for the remaining parameters
            if isempty(obj.FreqUnits_)
                obj.FreqUnits_ = 'rad/s';
            end            
            if isempty(obj.FreqRange_)
                obj.FreqRange = [1 1000];
            end
            if isempty(obj.Ts_)
                % 5 Times the upper frequency range
                obj.Ts_ = 1/(5*unitconv(max(obj.FreqRange_),obj.FreqUnits_,'Hz'));
            end
            if isempty(obj.NumSamples_)
                obj.NumSamples_ = ceil(1/(obj.Ts_*unitconv(min(obj.FreqRange_),obj.FreqUnits_,'Hz')));
            end
            if isempty(obj.Amplitude_)
                obj.Amplitude_ = 1e-5; 
            end
            if isempty(obj.SweepMethod_)
                obj.SweepMethod_ = 'linear';
            end
            if isempty(obj.InitialPhase_)
                obj.InitialPhase_ = 270;
            end
            if isempty(obj.Shape_)
                if strcmp(obj.SweepMethod_,'quadratic')
                    if obj.FreqRange_(1) > obj.FreqRange_(2)
                        obj.Shape_ = 'convex';
                    else
                        obj.Shape_ = 'concave';
                    end
                else
                    obj.Shape_ = '';
                end
            end
            checkConsistency(obj);
            obj.CrossValidation_ = true;
        end
        % Parameter initialization given an LTI object
        function obj = determineParams(obj,sys)
            if ~any(strcmp(class(sys),{'ss','tf','zpk'}))
               % Invalid system
               ctrlMsgUtils.error('Slcontrol:frest:InvalidSystemSpecification','Chirp');
            end
            if hasdelay(sys)
                % Use pade to avoid warnings with zero and pole
                sys = pade(sys);
            end
            if ~isstable(sys)
                % Check stability
                ctrlMsgUtils.error('Slcontrol:frest:UnstableSystemSpecification','Chirp');
            end
            [~,B,C,D] = ssdata(sys);
            if all(D(:)==0) && ((isempty(C) || all(C(:)==0)) || (isempty(B) || all(B(:)==0)))
                % Create default values
                obj = frest.Chirp;
                % Throw a warning and return
                ctrlMsgUtils.warning('Slcontrol:frest:ZeroSystemSpecification','Chirp');
                return;
            end
            % Set those parameters that do not depend on sys
            obj.Amplitude_ = 1e-5;
            obj.FreqUnits_ = 'rad/s';
            obj.SweepMethod_ = 'linear';
            obj.Shape_ = '';
            obj.InitialPhase_ = 270;
            if (sys.Ts == 0)
                % Start by determining the frequency range
                freq = frest.AbstractInput.pickTestFreq({zero(sys)},{pole(sys)},sys.Ts);
                obj.FreqRange_ = [min(freq) max(freq)];
                % Determine Ts based on upper end of the range
                obj.Ts_ = 2*pi/(5*obj.FreqRange_(2));
                % Determine number of samples based on lower end of the range
                obj.NumSamples_ = ceil(1/(obj.Ts_*obj.FreqRange_(1)/2/pi));
            else
                % Discrete system - first fix the sample rate
                obj.Ts_ = sys.Ts;
                % Determine frequency range
                freq = frest.AbstractInput.pickTestFreq({zero(sys)},{pole(sys)},sys.Ts);
                % Limit the maximum frequency to be fs/5.
                obj.FreqRange_ = [min(freq) min(max(freq),unitconv(1/obj.Ts_/5,'Hz','rad/s'))];
                % Determine number of samples based on lower end of the range
                obj.NumSamples_ = ceil(1/(obj.Ts_*obj.FreqRange_(1)/2/pi));
            end
        end     
    end
        %% STATIC METHODS
    methods(Static = true)
        function obj = loadobj(data)
            if isa(data,'struct')
                % Loading from a previous version
                % When loading from R2009b MAT-files, make sure property values
                % are placed in raw hidden properties.
                obj = frest.Chirp;
                if ~isfield(data,'Version')
                    % When loading from R2009b MAT-files, make sure property values
                    % are placed in raw hidden properties.
                    % No need to run cross validation during data transfer
                    obj.CrossValidation_ = false;
                    obj.FreqRange_ = data.FreqRange;
                    obj.Ts_ = data.Ts;
                    obj.NumSamples_ = data.NumSamples;
                    obj.FreqUnits_ = data.FreqUnits;
                    obj.SweepMethod_ = data.SweepMethod;
                    obj.InitialPhase_ = data.InitialPhase;
                    obj.Shape_ = data.Shape;
                    obj.Amplitude_ = data.Amplitude;
                end
            elseif isa(data,'frest.Chirp')
                % Current version
                obj = data;
            end
            obj.CrossValidation_ = true;
        end
    end
end


