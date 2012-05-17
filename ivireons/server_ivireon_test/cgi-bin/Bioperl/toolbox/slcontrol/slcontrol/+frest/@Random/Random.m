classdef Random < frest.AbstractInput
    % FREST.RANDOM Create Random input signal for frequency response estimation
    %
    %   in=frest.Random(sys) creates a Random input signal to
    %   validate the linear system sys. The parameters of Random input in
    %   is automatically determined based on the specified system sys.
    %
    %   in=frest.Random(param1,val1,...) creates the Random input
    %   signal with manually specified parameter values.
    %
    %   Available parameters for sinestream input are:
    %       'Amplitude', The amplitude value of the Random signal.
    %       'Ts', The sample time of the Random signal.
    %       'NumSamples', The number of samples in the Random signal.
    %
    %
    %   See also frest.Sinestream, frest.Random 
    
    %  Author(s): Erman Korkut
    %  Revised:
    % Copyright 1986-2009 The MathWorks, Inc.
    % $Revision: 1.1.10.8 $ $Date: 2010/02/17 19:07:47 $
    
    %% PUBLIC PROPERTIES    
	properties
        Ts
        NumSamples
        Stream       
    end
    properties (Access = private)
        State
    end
        
    %% PUBLIC METHODS    
    methods
        %% Constructor        
        function obj = Random(varargin)
            if nargin ~= 1 % Manual parameter specification
                obj = initializeParams(obj,varargin{:});
            else % Based on LTI object
                obj = determineParams(obj,varargin{1});
            end
        end
        %% Property set API to check validitiy
        function obj = set.Ts(obj,val)
            % Size check
            if ~isscalar(val) || ~isa(val,'double')
                ctrlMsgUtils.error('Slcontrol:frest:InvalidParameterSizeChirpRandom','Ts',...
                    ctrlMsgUtils.message('Slcontrol:frest:LabelRandom'));
            end
            obj.Ts = val;            
        end
        function obj = set.NumSamples(obj,val)
            if ~isscalar(val) || ~isa(val,'double')
                ctrlMsgUtils.error('Slcontrol:frest:InvalidParameterSizeChirpRandom','NumSamples',...
                    ctrlMsgUtils.message('Slcontrol:frest:LabelRandom'));
            end            
            if ~isequal(round(val),val)
                ctrlMsgUtils.error('Slcontrol:frest:RoundingChirpRandom',...
                    ctrlMsgUtils.message('Slcontrol:frest:LabelRandom'),sprintf('%g',val));
            end
            obj.NumSamples = val;            
        end
        function obj = set.Stream(obj,val)
            if ~isa(val,'RandStream')
                ctrlMsgUtils.error('Slcontrol:frest:InvalidRandStream');
            end
            obj.Stream = val;
        end        
        % SET METHOD to set multiple properties at once
        function obj = set(obj,varargin)
            % Parameters and values should be in pairs
            if (rem(nargin-1,2) ~= 0)
                ctrlMsgUtils.error('Slcontrol:frest:SetError');
            end
            % Set the specified parameters
            for ct = 1:length(varargin)/2
                try
                    obj.(varargin{2*ct-1}) = varargin{2*ct};
                catch Me
                    if strcmp(Me.identifier,'MATLAB:noPublicFieldForClass')
                        % Invalid parameter specified
                        ctrlMsgUtils.error('Slcontrol:frest:InvalidParameterSpecification',...
                            ctrlMsgUtils.message('Slcontrol:frest:LabelRandom'),...
                            varargin{2*ct-1},...
                            ctrlMsgUtils.message('Slcontrol:frest:LabelRandom'));
                    else
                        rethrow(Me)
                    end
                end
            end
        end
        % Display method
        function display(obj)
            disp(' ');
            if usejava('Swing') && desktop('-inuse') && feature('hotlinks')
                disp(ctrlMsgUtils.message('Slcontrol:frest:RandomInputSignalWithHelpLink'));
            else
                disp(ctrlMsgUtils.message('Slcontrol:frest:RandomInputSignal'));
            end                
            disp(' ');
            fprintf('      Amplitude  : %s\n',mat2str(obj.Amplitude));
            fprintf('      Ts         : %s (secs)\n',mat2str(obj.Ts));
            fprintf('      NumSamples : %s\n',mat2str(obj.NumSamples));
            fprintf('      Stream     : %s Random stream\n',obj.Stream.Type);
            disp(' ');            
        end
        function disp(obj)
            display(obj)
        end
    end
    %% PROTECTED METHODS
    methods (Access = protected)
        % Parameter initialization using manually specified values and
        % defaults
        function obj = initializeParams(obj,varargin)
            % Set the specified parameters
            for ct = 1:length(varargin)/2
                try
                    obj.(varargin{2*ct-1}) = varargin{2*ct};
                catch Me
                    if strcmp(Me.identifier,'MATLAB:noPublicFieldForClass')
                        % Invalid parameter specified
                        ctrlMsgUtils.error('Slcontrol:frest:InvalidParameterSpecification',...
                            ctrlMsgUtils.message('Slcontrol:frest:LabelRandom'),...
                            varargin{2*ct-1},...
                            ctrlMsgUtils.message('Slcontrol:frest:LabelRandom'));
                    else
                        rethrow(Me)
                    end
                end
            end
            % Set the default values for the remaining parameters
            if isempty(obj.Ts)
                obj.Ts = 1e-3;
            end
            if isempty(obj.NumSamples)
                obj.NumSamples = 1e4;
            end
            if isempty(obj.Amplitude)
                obj.Amplitude = 1e-5; 
            end
            if isempty(obj.Stream)
                obj.Stream = RandStream.getDefaultStream;
            end
            % Store the state of Random stream in construction so
            % that we produce identical sequences.
            if isempty(obj.State)
                obj.State = obj.Stream.State;
            end
        end
        % Parameter initialization given an LTI object
        function obj = determineParams(obj,sys)
            if ~any(strcmp(class(sys),{'ss','tf','zpk'}))
               % Invalid system
               ctrlMsgUtils.error('Slcontrol:frest:InvalidSystemSpecification','Random');
            end
            if hasdelay(sys)
                % Use pade to avoid warnings with zero and pole
                sys = pade(sys);
            end
            if ~isstable(sys)
                % Check stability
                ctrlMsgUtils.error('Slcontrol:frest:UnstableSystemSpecification','Random');
            end
            [A,B,C,D] = ssdata(sys);
            if all(D(:)==0) && ((isempty(C) || all(C(:)==0)) || (isempty(B) || all(B(:)==0)))
                % Create default values
                obj = frest.Random;
                % Throw a warning and return
                ctrlMsgUtils.warning('Slcontrol:frest:ZeroSystemSpecification','Random');
                return;
            end
            % Set amplitude to its default value
            obj.Amplitude = 1e-5;
            % Store the state of Random stream in construction so
            % that we produce identical sequences.
            obj.Stream = RandStream.getDefaultStream;
            obj.State = obj.Stream.State;
            if (sys.Ts == 0)
                % Start by finding a frequency range
                freq = frest.AbstractInput.pickTestFreq({zero(sys)},{pole(sys)},sys.Ts);
                freqrange = [min(freq) max(freq)];
                % Determine Ts based on upper end of the range
                obj.Ts = 2*pi/(5*freqrange(2));
                % Determine number of samples based on lower end of the range
                obj.NumSamples = ceil(1/(obj.Ts*freqrange(1)/2/pi));
            else
                % Discrete system - fix sample rate first
                obj.Ts = sys.Ts;
                % Determine frequency range
                freq = frest.AbstractInput.pickTestFreq({zero(sys)},{pole(sys)},sys.Ts);
                % Limit the maximum frequency to be fs/5.
                freqrange = [min(freq) min(max(freq),unitconv(1/obj.Ts/5,'Hz','rad/s'))];
                % Determine number of samples based on lower end of the range
                obj.NumSamples = ceil(1/(obj.Ts*freqrange(1)/2/pi));
            end
        end        
    end
    
end

