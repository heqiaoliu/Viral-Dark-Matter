function [splitVec, numTasks] = pctdemo_helper_split_vector(vec, numTasks)
%PCTDEMO_HELPER_SPLIT_VECTOR Returns a segmentation of a vector
%   [splitVec, numTasks] = PCTDEMO_HELPER_SPLIT_VECTOR(vec, numTasks) 
%   divides the vector vec into min(numTasks, length(vec))
%   cells storing vectors of roughly equal length.
%   The value numTasks returned equals min(numTasks, length(vec)).
%  
%   The input argument numTasks must be greater than or equal to zero.  If the
%   input vector vec is not empty, numTasks must be strictly greater than zero.
%   
%   The function is useful when dividing a "parameter sweep" between numTask
%   tasks.  In that case, task i should perform a parameter sweep over
%   splitVec{i}.
%  
%   See also PCTDEMO_HELPER_SPLIT_SCALAR

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:26 $
    
    % Validate the input arguments.
    error(nargchk(2, 2, nargin, 'struct'));
    if ~(isvector(vec) || isempty(vec))
        error('distcomp:demo:InvalidArgument', ...
              'First input argument must be a vector');
    end
    tc = pTypeChecker();
    if ~tc.isIntegerScalar(numTasks, 0, Inf)
        error('distcomp:demo:InvalidArgument', ...
              'Number of tasks must be a non-negative integer');
    end
    if (numTasks == 0 && ~isempty(vec))
        error('distcomp:demo:InvalidArgument', ...
              ['Number of tasks must be greater than 0 if the vector is ' ...
               'not empty']);
    end
    % Input arguments have been validated.
    
    % Find the number of elements that each cell should contain.
    [splitLength, numTasks] = pctdemo_helper_split_scalar(numel(vec), ...
                                                      numTasks);
    % For each cell, find the index of the first element that goes into that 
    % cell.  The vector splitElems will of the length numTasks + 1, and its last
    % element equals numel(vec) + 1.
    splitElems = cumsum([1, splitLength(:)']);
    
    splitVec = cell(numTasks, 1);
    for i = 1:numTasks
        splitVec{i} = vec(splitElems(i):splitElems(i+1) - 1);
    end
end % End of pctdemo_helper_split_vector
