function varargout = cellfun(varargin)
%CELLFUN Apply a function to each cell of a codistributed cell array
%   A = CELLFUN(FUN, C)
%   A = CELLFUN(FUN, B, C, ...)
%   [A, B, ...] = CELLFUN(FUN, C,  ..., 'Param1', val1, ...)
%   
%   Example:
%   spmd
%       N = 1000;
%       C = codistributed.cell(N)
%       T = cellfun(@isempty,C)
%       classC = classUnderlying(C)
%       classT = classUnderlying(T)
%   end
%   
%   returns a N-by-N codistributed logical matrix T the same as
%   codistributed.true(N).
%   classC is 'cell' while classT is 'logical'.
%   
%   See also  CELLFUN, CODISTRIBUTED, CODISTRIBUTED/CELL.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/08/29 08:23:35 $

    error(nargchk(2, Inf, nargin));
    
    [fcn, cellArgs, trailingArgs] = iParseInputArgs(varargin);
    
    % Determine which cells are distributed.
    isDistributedCells = cellfun(@(x) iscodistributed(x), cellArgs);
    
    if ~any(isDistributedCells)
        % None of the cells are distributed, and all of the other arguments
        % have been gathered.  We can call the built-in cellfun now.
        [varargout{1:nargout}] = cellfun(fcn, cellArgs{:}, trailingArgs{:});
        return
    end
    
    iVerifyCellConsistency(cellArgs);

    [cellLPs, targetDist] = codistributed.pRedistSameSizeToSingleDist(cellArgs); %#ok<DCUNK>
    
    procFcn = @(x) targetDist.hCellfunImpl(fcn, x, trailingArgs, nargout);
    cellLPs = distributedutil.syncOnError(procFcn, cellLPs);
    
    for i = 1:nargout
           varargout{i} = codistributed.pDoBuildFromLocalPart(cellLPs{i}, targetDist); %#ok<DCUNK>
    end 
end % End of cellfun

%------------------------------------
function [fcn, cellArgs, trailingArgs] = iParseInputArgs(inputArgs)    
    % Separates inputArgs into its component types

    isValidFcn = any(strcmp(iReturnClass(inputArgs{1}), ...
                            {'function_handle', 'char'}));
    if ~isValidFcn
        error('distcomp:codistributed:cellfun:InvalidInput',...
              'The first input to CELLFUN must be a function handle.');
    end
    
    fcn = inputArgs{1};
    
    % Gather fcn if necessary
    fcn = distributedutil.CodistParser.gatherIfCodistributed(fcn);
    
    % Handle backward compatibility syntax for 'size' and 
    % 'isclass' separately and return 
    if any(strcmp(fcn, {'size', 'isclass'}))
        cellArgs = inputArgs(2:end - 1);
        trailingArgs = inputArgs(end);
        
        % Gather trailingArgs if necessary
        trailingArgs = distributedutil.CodistParser.gatherElements(trailingArgs);
        return
    end
          
    % We search through the inputArgs array to find where the trailing 
    % arguments to cellfun (if any) begin.
    cellContainsChar = cellfun(@(x) strcmp(iReturnClass(x), 'char'), ...
                               inputArgs(2:end));
    firstPVPair = find(cellContainsChar, 1);
   
    % Split the inputArgs into cellArgs and trailingArgs
    if isempty(firstPVPair)
        cellArgs = inputArgs(2:end);
        trailingArgs = {};
    else
        cellArgs = inputArgs(2:firstPVPair);
        trailingArgs = inputArgs(firstPVPair + 1:end);
    end
   
    % Gather trailingArgs if necessary
    trailingArgs = distributedutil.CodistParser.gatherElements(trailingArgs);    
end % End of iParseInputArgs

%------------------------------------
function objClass = iReturnClass(obj)
    if iscodistributed(obj)
        objClass = classUnderlying(obj);
    else
        objClass = class(obj);
    end
end % End of iReturnClass

%------------------------------------
function iVerifyCellConsistency(inputCells)
% Perform error checking:  inputCells must all be cells of the same size.  

    allAreCells = cellfun(@(x) strcmp(iReturnClass(x), 'cell'), inputCells);
    
    if ~all(allAreCells)
        firstNonCell = find(~allAreCells, 1); 
        % inputCells is not comprised entirely of cells, so throw an error.
        error('distcomp:codistributed:cellfun:NotACell',...
              'CELLFUN received a %s input, instead of a cell array.', ...
              iReturnClass(inputCells{firstNonCell}));
    end
    
    % If there is more than one cell, each cell must be of the same size.
    if numel(inputCells) > 1
        szCells = cellfun(@size, inputCells, 'UniformOutput', false);
        
        if ~isequal(szCells{:})
            % The input cells have incompatible sizes, so throw an error. 
            error('distcomp:codistributed:cellfun:InvalidInput',...
                  'CELLFUN expects all cell inputs to be of the same size.'); 
        end
    end
end % End of iVerifyCellConsistency.
