%Element  Create an Element object.
%   The Simulink.SimulationData.Element object is used to store logged data
%   within a Simulink.SimulationData.Dataset. This abstract class contains
%   a Name and provides searching capabilities.
%
%   See also Simulink.SimulationData.Dataset
%
% Copyright 2009 The MathWorks, Inc.

classdef Element
  
    %% Public Properties
    properties (Access = 'public')
        Name = '';
    end % Public properties
    
    %% Public Methods
    methods
        
        function this = set.Name(this, val)
        % Name SET function
        
            if ischar(val)
                this.Name = val;
            else
                DAStudio.error('Simulink:util:InvalidDatasetElementName');
            end
        end
        %------------------------------------------------------------------
        
    end % Public methods
    
    %% Abstract Methods
    methods (Abstract)        
    
        elementVal = find(this,searchArg, varargin)
        
    end % Abstract methods
    
end