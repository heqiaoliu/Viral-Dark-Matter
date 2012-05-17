classdef AbstractInput
    %
    
	% Class definition for @AbstractInput - the ancestor of all frest
	% inputs
    
    %  Author(s): Erman Korkut
    %  Revised:
    % Copyright 1986-2009 The MathWorks, Inc.
    % $Revision: 1.1.10.5 $ $Date: 2009/10/16 06:45:43 $
    
    %% PUBLIC PROPERTIES    
	properties (Access = public, Dependent)
        Amplitude        
    end
    properties (Access = protected)
        Amplitude_
    end
    properties (Access = protected, Transient)
        % Setting CrossValidation=false defers all consistency checks in
        % the SET methods for public properties. Other types of data validation
        % (e.g., enforcing the correct datatype) are not affected. This flag
        % is needed to support multi-property SET operations.
        CrossValidation_ = true;
    end
    
    %% PUBLIC METHODS
    methods
        % Amplitude
        function val = get.Amplitude(obj)
            val = obj.Amplitude_;
        end
        function obj = set.Amplitude(obj,val)
            if ~isempty(val)
                if isa(obj,'frest.Sinestream') && ~isa(val,'double')
                    ctrlMsgUtils.error('Slcontrol:frest:NonDoubleParameterForSinestream','Amplitude');
                end
                if isa(obj,'frest.Chirp') && (~isscalar(val) || ~isa(val,'double'))
                    ctrlMsgUtils.error('Slcontrol:frest:InvalidParameterSizeChirpRandom','Amplitude',...
                        ctrlMsgUtils.message('Slcontrol:frest:LabelChirp'));
                end
                if isa(obj,'frest.Random') && ~isscalar(val)
                    ctrlMsgUtils.error('Slcontrol:frest:InvalidParameterSizeChirpRandom','Amplitude',...
                        ctrlMsgUtils.message('Slcontrol:frest:LabelRandom'));                    
                end
            end            
            if obj.CrossValidation_ && isa(obj,'frest.Sinestream')
                % Check the size against frequency
                checkSizeAgainstFrequency(obj,val,'Amplitude');
            end
            obj.Amplitude_ = val;            
        end
        function plot(obj) % Implement plot for chirp and random here, sinestream will override
            plot(generateTimeseries(obj));
        end
    end
    %% Static methods
    methods(Static)
        w = pickTestFreq(z,p,Ts,UserDefOptions)        
    end

    %% ABSTRACT METHODS
    % PUBLIC
    methods (Abstract = true)        
        generateTimeseries(obj)
        set(obj,varargin)        
    end
    % PRIVATE
    methods (Abstract = true, Access = protected)
        obj = initializeParams(obj,varargin) % Setting default values
        obj = determineParams(obj,sys) % Automatic determination based on a LTI system
    end    

end

