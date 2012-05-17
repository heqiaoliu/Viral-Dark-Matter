classdef SystemBasicAPI < testconsole.System
    %SystemBasicAPI Define the SystemBasicAPI abstract class
    %   Template to define a 'unimodular' system under test that may be attached
    %   to a test console for analysis.
    
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.1 $  $Date: 2009/07/14 03:59:41 $    
    
    %======================================================================
    % Define Public Properties
    %======================================================================
    properties
        %Description User defined class description
        Description
    end    
    %======================================================================
    % Define Public Methods
    %====================================================================== 
    methods
        %==================================================================        
        function setup(obj) %#ok<*MANU>
            %SETUP  System setup 
            %   The SETUP method may be overloaded by the concrete class if a
            %   setup routine is required in the system.
            
            %NO OP
        end
        %==================================================================
        function reset(obj)
            %RESET  System reset
            %   The RESET method may be overloaded by the concrete class if a
            %   reset routine is required in the system.
            
            %NO OP
        end
    end    
    %======================================================================
    % Define Abstract Public Methods
    %====================================================================== 
    methods (Abstract)
        %==================================================================
        run(obj)
        %RUN    A RUN method must be implemented by a concrete system class
    end
    %=====================================================================
    % Protected helper methods
    %=====================================================================
    methods (Access = protected)
        function sortedList = getSortedPropDispList(obj)
            %getSortedPropDispList
            %   Get the sorted list of the properties to be displayed. Do not
            %   display irrelevant properties.
            
            sortedList = {'Description'};
            
            %Find user defined properties and display them after the
            %default properties
            f = fieldnames(obj);
            for idx = 1:length(sortedList)
                idxf = strmatch(sortedList(idx),f,'exact');
                f(idxf) = [];
            end            
            sortedList = [sortedList f{:}];
        end
    end%protected methods    
end %classdef









