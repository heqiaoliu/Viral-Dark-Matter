% SIMULINK.SIMULATIONDATA.BLOCKPATH creates a BlockPath object
%
% The Simulink.SimulationData.BlockPath object represents a 
% fully-specified Simulink block path. 
% 
% Simulink.SimulationData.BlockPath() creates an empty block path.
%
% SimulinkSimulationData.BlockPath(blockpath) creates a copy of the block
% path of the specified BlockPath object.
%
% Simulink.SimulationData.BlockPath(paths) creates a block path from the
% given cell array of strings. Each string represents a path at a level of
% model hierarchy; the full block path is built based on the strings.
%
% To create a valid block path when specifying a cell array of strings,  
% specify each string in order, from the top model to the specific block
% for which you are creating a block path.
%
% Each string should be a path to:
% - A block in a single model
% - A Model block, except for the last string, which may be a block other
%   than a Model block
% - A block that is in a model that is referenced by the previous string’s
%   Model block, except for the first string
%
% Note that the Simulink.SimulationData.Blockpath may be used independently
% from Simulink and performs no validity checking that the specified path
% points to a valid block.
%
% See also BlockPath/getBlock, BlockPath/getLength, BlockPath/convertToCell

% Copyright 2009-2010 The MathWorks, Inc.

classdef BlockPath
    
    %% Public Methods
    methods (Access = 'public')
        
        function obj = BlockPath(bpath)
            
            % No parameters
            if(nargin == 0)
                obj.path = {};
                
            % Another BlockPath object
            elseif(isa(bpath, 'Simulink.SimulationData.BlockPath') && ...
                   length(bpath) == 1)
                obj = bpath;
                
            % Cell array of strings (1xN or Nx1)
            elseif(iscellstr(bpath))
                if isempty(bpath)
                    obj.path = {};
                elseif ndims(bpath) ~= 2
                    DAStudio.error('Simulink:util:InvalidBlockPathParamsDims');
                else
                    sz = size(bpath);
                    if sz(1) == 1
                        obj.path = Simulink.SimulationData.BlockPath.manglePath(bpath);
                    elseif sz(2) == 1
                        % Convert to a row vector if necessary
                        obj.path = Simulink.SimulationData.BlockPath.manglePath(bpath');
                    else
                        DAStudio.error('Simulink:util:InvalidBlockPathParamsDims');
                    end
                end
            
            % Character array
            elseif ischar(bpath)
                
                obj.path = {Simulink.SimulationData.BlockPath.manglePath(bpath)};
                
                
            % Otherwise, invalid
            else
                DAStudio.error('Simulink:util:InvalidBlockPathParams');
            end
        end
       %-------------------------------------------------------------------                        
        
        function res = convertToCell(this)
        % Convert a block path to a cell-array of strings. This cell array
        % is ordered from top to bottom, where the first element represents
        % the block path in the top-most model and the last element
        % represents the block path in the lowest-level reference model.

            % Only supported for single objects
            if length(this) ~= 1
                DAStudio.error('Simulink:util:InvalidBlockPathArray');
            end
            
            % Transpose this to return a column vector to avoid a 
            % backwards incompatibility
            res = this.path';
        end 
       %-------------------------------------------------------------------
                
        function disp(this)
        % Display function for BlockPath objects.

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

            % Print block path
            fprintf('  Block Path:\n');
            if isempty(this.path)
                fprintf('    ''''\n');
            else
                for idx = 1 : length(this.path)
                    indentStr = repmat('  ', 1, idx);
                    fprintf('  %s''%s''\n', indentStr, this.path{idx});
                end
            end
            
            % Print links for methods
            if feature('hotlinks')
                fprintf('\n  <a href="matlab: methods(''%s'')">Methods</a>\n', mc.Name);
            end

        end
       %-------------------------------------------------------------------
        
        function res = getBlock(this, idx)
        % Get a single block path in the hierarchy. For example, if there
        % are 3 levels in the model reference hierarchy, you might get
        % something like this:
        %
        %    bpath.getBlock(1) --> 'top/ModelA'
        %    bpath.getBlock(2) --> 'refModelA/ModelB'
        %    bpath.getBlock(3) --> 'refModelB/Block C'
        
            % Only supported for single objects
            if length(this) ~= 1
                DAStudio.error('Simulink:util:InvalidBlockPathArray');
            end
            
            try
                res = this.path{idx};
            catch me
                DAStudio.error('Simulink:util:InvalidBlockPathBlockIndex');
            end
        end
       %-------------------------------------------------------------------
                
        function len = getLength(this)
        % Get the length of the block path. This length corresponds to the
        % number of levels in the model reference hierarchy.
        
            % Only supported for single objects
            if length(this) ~= 1
                DAStudio.error('Simulink:util:InvalidBlockPathArray');
            end
            
            len = length(this.path);
        end
       %-------------------------------------------------------------------
                
        function res = isequal(this, rhs)
        % Determine equality of the block path to another object. This may
        % be used to compare a BlockPath to a string or cell array of
        % strings.
        
            if(isa(rhs, 'Simulink.SimulationData.BlockPath'))
            % BLOCKPATH OBJECT COMPARISON
                            
                numEls = length(this);
                if numEls ~= length(rhs)
                % Length of object arrays must be equal
                    res = false;
                elseif numEls > 1
                % Object array comparison                    
                    for idx = 1:numEls
                        if ~isequal(this(idx), rhs(idx))
                            res = false;
                            return;
                        end
                    end
                    res = true;
                else
                % Single object comparison
                    res = isequal(this.path, rhs.path);    
                end
                
            elseif(iscellstr(rhs))
            % CELL-ARRAY COMPARISON
            
                % Comparison not allowed if this is an array
                if length(this) ~= 1
                    res = false;
                    return;
                end
                
                % rhs could be a row vector or a column vector.  Transpose
                % if necessary to make a row vector
                sizes = size(rhs);
                if(sizes(2) == 1)
                    rhs = rhs';
                end
                
                res = isequal(this.path, rhs);
                
            elseif ischar(rhs) && length(this) == 1
            % SIGNAL STRING COMPARISON
            
                res = isequal(this.path, {rhs});
            
            else
            % UNSUPPORTED COMPARISON TYPE
                res = false;
            end
        end
       %-------------------------------------------------------------------                
       
    end % Public Methods
    
    %% Hidden Methods
    methods (Hidden = true)
        
        function res = pathIsLike(this, rhs)
        % Compare to BlockPath objects. This comparison does not require
        % the full model-reference hierarchy to be specified in the search
        % parameter. Instead, you may search from the bottom of the
        % hierarchy up.  For example,
        %
        % my_path.pathIsLike(BlockPath('model/bpath'))
        %   returns TRUE for all blocks with path 'model/bpath'
        %
        % my_path.pathIsLike(BlockPath({'mid_model/Model','model/bpath'})
        %   returns TRUE only for blocks with path 'model/bpath' 
        %   referenced from 'mid_model/Model'.
        
            if ~isa(rhs, 'Simulink.SimulationData.BlockPath') || ...
               length(this) ~= 1 || length(rhs) ~= 1
                DAStudio.error('Simulink:util:InvalidBlockPathPathLike');
            end
            
            % If RHS is empty path, paths are only equal if this is empty
            if isempty(rhs.path)
                res = isempty(this.path);
                
            % If length of RHS is greater than us, we are not equal
            elseif length(this.path) < length(rhs.path)
                res = false;
                
            % Otherwise, compare
            else
                sizeDif = length(this.path) - length(rhs.path);
                compPath = this.path(1 + sizeDif : end);
                res = isequal(compPath, rhs.path);
            end
        end
       %-------------------------------------------------------------------
       
    end % Hidden Methods
    
    %% Hidden Static Methods
    methods (Hidden = true, Static = true)
        function res = manglePath(pathStr)
        % BPATH mangles names by replacing line endings with space.
        % We will do the same here to make sure if the user
        % constructs this object from functions such as gcb (which
        % does not replace), they can still find blocks.
            
            % Character arrays
            if(ischar(pathStr) || iscellstr(pathStr))
                res = strrep(pathStr, sprintf('\n'), ' ');                
                
            % Unsupported
            else
                res = [];
            end
        end
        %-------------------------------------------------------------------       

       
        function this = loadobj(obj)
            this = obj;

            % BlockPaths were originally stored as column vectors.  For
            % saving into an MDL file, only row vectors are supported, thus
            % the internal representation had to change.  If we are loading
            % an old "column vector" BlockPath, convert it to a row
            % vector.
            sizes = size(this.path);
            if(sizes(2) == 1)
                this.path = this.path';
            end
        end
        %-------------------------------------------------------------------       
       
    end % Hidden Static Methods
    
    %% Private Data
    properties (Access = 'protected')
        path = {};
    end
    
end
