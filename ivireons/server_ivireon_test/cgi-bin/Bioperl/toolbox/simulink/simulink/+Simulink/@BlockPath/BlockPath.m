% SIMULINK.BLOCKPATH creates a BlockPath object
%
% The Simulink.BlockPath object represents a fully-specified Simulink block
% path.
% 
% Simulink.BlockPath() creates an empty block path.
%
% Simulink.BlockPath(blockpath) creates a copy of the block path of the
% specified BlockPath object.
%
% Simulink.BlockPath(paths) creates a block path from the given cell array of
% strings. Each string represents a path at a level of model hierarchy; the full
% block path is built based on the strings.
%
% To create a valid block path when specifying a cell array of strings, specify
% each string in order, from the top model to the specific block for which you
% are creating a block path.
%
% Each string must be a path to:
% - A block in a single model
% - A Model block, except for the last string, which may be a block other than a
%   Model block
% - A block that is in a model that is referenced by the previous strings Model
%   block, except for the first string
%
% Simulink performs no validity checking when constructing block paths.  Use the
% validate method on Simulink.BlockPath objects to ensure the block path object
% points to a block.
%
% See also Simulink.SimulationData.BlockPath

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.3.2.1 $

classdef BlockPath < Simulink.SimulationData.BlockPath
    
    % Public Methods
    methods (Access = 'public')
        
        function obj = BlockPath(varargin)
            obj = obj@Simulink.SimulationData.BlockPath(varargin{:});
        end
        
        function validate(this)
            function blocktype = loc_checkPath(model, path)
                try
                    load_system(model);
                catch me
                    errID = 'Simulink:util:InvalidBlockPathCouldNotLoadModel';
                    newError = MException(errID, DAStudio.message(errID, model, path));
                    newError = newError.addCause(me);
                    throw(newError);
                end
                
                try
                    blocktype = get_param(path, 'BlockType');
                catch me
                    errID = 'Simulink:util:InvalidBlockPathInvalidBlock';
                    newError = MException(errID, DAStudio.message(errID, path));
                    newError = newError.addCause(me);
                    throw(newError);
                end   
            end

            if length(this) ~= 1
                DAStudio.error('Simulink:util:InvalidBlockPathArray');
            end           
            if(getLength(this) == 0)
                errID = 'Simulink:util:BlockPathCannotBeEmpty';
                DAStudio.error(errID);
            end
            
            for i = 1:(getLength(this) - 1)
                % All but the last element must
                %  1) Be valid model blocks
                %  2) Reference the model of the next element
                
                currPath  = getBlock(this, i);
                currModel = getModelNameForPath(this, currPath);
                nextModel = getModelNameForPath(this, getBlock(this, i+1));
                
                currBlockType = loc_checkPath(currModel, currPath);
                
                if(~isequal(currBlockType, 'ModelReference'))
                    DAStudio.error('Simulink:util:InvalidBlockPathNotModelBlock',...
                    currPath, nextModel);
                else
                    slInternal('determineActiveVariant', currPath);
                    if(isequal(get_param(currPath, 'ProtectedModel'), 'on'))
                        DAStudio.error('Simulink:util:InvalidBlockPathProtectedModel', currPath);
                    end
                    
                    refModel = get_param(currPath, 'ModelName');
                    if(~isequal(refModel, nextModel))
                        DAStudio.error('Simulink:util:InvalidBlockPathIncorrectReference',...
                            currPath, get_param(currPath, 'ModelName'), nextModel);
                    end
                end
            end
            
            % The last element must point at a block
            lastPath  = getBlock(this, getLength(this));
            lastModel = getModelNameForPath(this, lastPath);
            loc_checkPath(lastModel, lastPath);
        end
    end

    
    methods (Access = 'public', Hidden = true)
        function model = getModelNameForPath(~, blockpath)
            indexes   = strfind(blockpath, '/');
            
            if(isempty(indexes))
                model = blockpath;
            else
                index = indexes(1);
                model = blockpath(1:(index - 1));
            end
        end
    end
    
    methods (Access = 'public', Hidden = true)
        function toReturn = getAsString(this)
            
            if length(this) ~= 1
                DAStudio.error('Simulink:util:InvalidBlockPathArray');
            end
            
            toReturn = '{';
            needsSeparator = false;
            
            for i = 1:getLength(this)
                currBlock = getBlock(this, i);
                
                if(needsSeparator) 
                    toReturn = [toReturn, ', ']; %#ok<AGROW>
                else
                    needsSeparator = true;
                end
                
                toReturn = [toReturn, '''', currBlock, '''']; %#ok<AGROW>
            end
            
            toReturn = [toReturn, '}'];
        end
    end
end
