%BlockData  Create a BlockData object.
%   The Simulink.SimulationData.BlockData object stores Simulink logging
%   information for signals related to a single block.  In addition to an
%   Element Name, the BlockData object contains the BlockPath of the
%   related Simulink block and Values stored as a timeseries object.
%
%   See also BlockData/find, Simulink.SimulationData.Dataset,
%   Simulink.SimulationData.Signal,
%   Simulink.SimulationData.DataStoreMemory,
%   Simulink.SimulationData.BlockPath, timeseries

% Copyright 2009 The MathWorks, Inc.

classdef BlockData < Simulink.SimulationData.Element
  
    %% Public Properties
    properties (Access = 'public')
        BlockPath = Simulink.SimulationData.BlockPath({});
        Values = [];
    end %Public properties
    
    %% Public Methods
    methods       
        
        function this = set.BlockPath(this, val)
        % BlockPath SET function
        
            if(isa(val, 'Simulink.SimulationData.BlockPath'))
                this.BlockPath = val;
            else
                this.BlockPath = Simulink.SimulationData.BlockPath(val);
            end
        end
       %-------------------------------------------------------------------        
        
        function this = set.Values(this, val)
        % Values SET function
           
            % Timeseries or structure data
            if Simulink.SimulationData.utValidSignalOrCompositeData(val)
               
                this.Values = val;            
                
            % Otherwise, invalid type
            else
                DAStudio.error('Simulink:util:InvalidBlockDataValues');
            end
        end 
       %-------------------------------------------------------------------
        
        function elementVal = find(this,~, ~) %#ok<MANU>
        % find must return an Element or Dataset of a contained element.
        % Because this class contains no objects of type Element, we return
        % empty. Note that bus data is stored in structure format and
        % therefore using find to return a part of the bus is not useful.
        % For example, to find element "c" in the bus:
        %   >> ds.find('my_bus').a.b.c

            elementVal = [];

        end
       %-------------------------------------------------------------------                  
       
        function disp(this)
        % Display function for BlockData objects.
        
            % See if this a collection
            if length(this) > 1
                Simulink.SimulationData.utNonScalarDisp(this);
                return;
            end
            
            % Print the class name
            mc = metaclass(this);
            if feature('hotlinks')
                fprintf('  <a href="matlab: help %s">%s</a>\n', mc.Name, mc.Name);
            else
                fprintf('  %s\n', mc.Name);
            end

            % Print the package name
            fprintf('  Package: %s\n\n', mc.ContainingPackage.Name);

            % Print properties using a struct so we can re-order display
            fprintf('  Properties:\n');
            ps.Name = this.Name;
            ps.BlockPath = this.BlockPath;
            ps.Values = this.Values;
            disp(ps);

            % Print links for methods and superclasses
            if feature('hotlinks')
                fprintf('\n  <a href="matlab: methods(''%s'')">Methods</a>, ', mc.Name);
                fprintf('<a href="matlab: superclasses(''%s'')">Superclasses</a>\n', mc.Name);
            end

        end
       %-------------------------------------------------------------------
       
    end %public methods   
    
    %% Hidden Methods
    methods(Hidden = true)
        
        function ret = isFromBlock(this,bpath)
        % Compare a BlockPath object to the block that generated this
        % data. Return TRUE if the block is equal or FALSE otherwise.

            if ~isa(bpath, 'Simulink.SimulationData.BlockPath')
                DAStudio.error('Simulink:util:InvalidBlockDataFromBlock');
            end

            ret = this.BlockPath.pathIsLike(bpath);
        end
       %-------------------------------------------------------------------
       
    end %Hidden methods
end