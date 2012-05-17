%DataStoreMemory  Create a DataStoreMemory object.
%   The Simulink.SimulationData.DataStoreMemory object is used to store
%   logging information from Data Store Memory (DSM) blocks during 
%   simulation.
%
%   Properties:
%                Name : String containing the name of the Data Store   
%                       Memory to which the object relates.
%           BlockPath : Block path to the DSM block. For local DSMs generated 
%                       from Signal objects, block path of the Model block that 
%                       DSM is local to or empty if local to the top model. 
%                       For global DSMs, this is empty.
%               Scope : 'local' or 'global'
% DSMWriterBlockPaths : Array whose length equals the number of blocks 
%                       that can write to the DSM.  Each element contains the 
%                       full block path of one writer block.
%          DSMWriters : Integer vector whose length is the number of writes in 
%                       the DSM.  The n’th element of DSMWriters contains the 
%                       index of the element in DSMWriterBlockPaths that contains 
%                       the block path of the writer that performed the n’th 
%                       write to Values.
%              Values : Timeseries containing data store write values.
%
%   See also Simulink.SimulationData.Dataset, timeseries

% Copyright 2009-2010 The MathWorks, Inc.

classdef DataStoreMemory < Simulink.SimulationData.BlockData

    %% Read-Only Properties
    properties (SetAccess = private, GetAccess = public)
        Scope = 'local';
        DSMWriterBlockPaths = [];
        DSMWriters = [];
    end % Public Properties
    
    
    %% Public Methods
    methods                                                             
        
        function this = DataStoreMemory(name, bpath,scope,writePaths,writers,values)
        % Constructor for DataStoreMemory object        
            if nargin > 0                
                % NAME (checked in base class SET function)
                this.Name = name;
                
                % BLOCK PATH (checked in base class SET function)
                this.BlockPath = bpath;
                
                % SCOPE
                if ~strcmp(scope,'local') && ~strcmp(scope,'global')
                    DAStudio.error('Simulink:util:InvalidDSMscope');  
                end
                this.Scope = scope;
                
                % VALUES must be a timeseries
                if ~isa(values, 'timeseries')
                    DAStudio.error('Simulink:util:InvalidDSMvalues');  
                end
                this.Values = values;
                
                % WRITER BLOCK PATHS
                sz = size(writePaths);
                if sz(2) ~= 1 || length(sz) ~= 2 || ...
                   ~isa(writePaths,'Simulink.SimulationData.BlockPath')
                        DAStudio.error('Simulink:util:InvalidDSMwriterPaths');  
                end
                this.DSMWriterBlockPaths = writePaths;
                num_writers = sz(1);
                
                % WRITERS
                sz = size(writers);
                num_time_pts = length(values.Time);
                if length(sz) ~= 2 || sz(1) ~= num_time_pts || sz(2) ~= 1 || ~isa(writers,'double')
                    DAStudio.error('Simulink:util:InvalidDSMwriters');  
                end
                errors = or(writers > num_writers, writers < 1);
                if ~isequal(errors, zeros(size(writers)))
                    DAStudio.error('Simulink:util:InvalidDSMwriterIdx', num_writers);  
                end                                                
                this.DSMWriters = writers;
            end        
        end
       %-------------------------------------------------------------------
        
        function disp(this)
        % Display function for DataStoreMemory objects.
        
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
            ps.Scope = this.Scope;
            ps.DSMWriterBlockPaths = this.DSMWriterBlockPaths;
            ps.DSMWriters = this.DSMWriters;
            ps.Values = this.Values;
            disp(ps);

            % Print links for methods and superclasses
            if feature('hotlinks')
                fprintf('\n  <a href="matlab: methods(''%s'')">Methods</a>, ', mc.Name);
                fprintf('<a href="matlab: superclasses(''%s'')">Superclasses</a>\n', mc.Name);
            end

        end
       %-------------------------------------------------------------------
       
    end % Public methods
    
    
    %% Hidden Methods
    methods (Hidden = true)        
        
        function this = utSetScope(this, val)
        % Hidden utility function to set the Scope properties. Note that no
        % checks are performed in this function for efficiency        
            this.Scope = val;
        end
        %------------------------------------------------------------------        
        
        function this = utSetWriters(this, writers)
        % Hidden utility function to set all writers using a cell array of
        % string cell arrays. Note that no checks are performed in this
        % function for efficiency.
        
            if(isempty(writers))                
                this.DSMWriterBlockPaths = [];
            else
                this.DSMWriterBlockPaths = ...
                    Simulink.SimulationData.BlockPath(writers{1});
                for idx = 2 : length(writers)
                    this.DSMWriterBlockPaths(idx) = ...
                        Simulink.SimulationData.BlockPath(writers{idx});
                end
            end
        end
        %------------------------------------------------------------------
        
        function this = utSetWriterIndices(this, val)
        % Hidden utility function to set the DSMWriters properties. Note 
        % that no checks are performed in this function for efficiency        
            this.DSMWriters = val;
        end
        %------------------------------------------------------------------
        
        function res = convertWriterPathsToCell(this)
        % Get cell array of block paths for writers. This function is only
        % needed for testing.
        
            % Cell array is Nx1 or 0x0
            res = cell(length(this.DSMWriterBlockPaths), ...
                       ~isempty(this.DSMWriterBlockPaths));
            
            for idx = 1 : length(this.DSMWriterBlockPaths)
                res{idx} = this.DSMWriterBlockPaths(idx).convertToCell();
            end

        end
        %------------------------------------------------------------------
        
    end % Hidden Methods
    
end
