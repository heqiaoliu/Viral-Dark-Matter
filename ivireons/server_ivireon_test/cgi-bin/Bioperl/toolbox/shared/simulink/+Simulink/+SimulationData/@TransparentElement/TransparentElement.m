%TransparentElement  Create a TransparentElement object.
%   The Simulink.SimulationData.TransparentElement object is used to store
%   arrays and bus data (a structure with timeseries as leaves) within a data
%   structure. Because a Dataset requires each element to have a "name", it
%   is not possible to add arrays and structs directly to a dataset. To allow
%   this, this class is a thin wrapper to hold the structure and the name
%   of the array/structure. For example,
%
%   >> data.a = timeseries();
%   >> data.b = timeseries();
%   >> dataset.addElement(data);
%
%   When adding this element, a TransparentElement object will be constructed
%   to store the structure with the name "data". This structure is then
%   accessed directly:
%
%   >> data = dataset.find('data')
%   >> class(data)
%   ans =
%   struct
%
%   See also Simulink.SimulationData.Dataset,
%   Simulink.SimulationData.Element, timeseries

% Copyright 2010 The MathWorks, Inc.

classdef TransparentElement < Simulink.SimulationData.Element
    
    %% Public Properties
    properties (Access = 'public')
        Values = [];
    end               
      
    %% Public Methods
    methods  
        function elementVal = find(this,~, ~) %#ok<MANU>
            elementVal = [];
        end 
    end
end
