function [b,idx] = sortrows(a,vars,mode)
%SORTROWS Sort rows of a dataset array.
%   B = SORTROWS(A) returns a copy of the dataset A, with the observations
%   sorted in ascending order by all of the variables in A.  The observations
%   in B are sorted first by the first variable, next by the second variable,
%   and so on.  The variables in A must be scalar-valued, i.e. column vectors,
%   and be from a class for which a SORT method exists.
%
%   B = SORTROWS(A,VARS) sorts the observations in A by the variables
%   specified by VARS.  VARS is a positive integer, a vector of positive
%   integers, a variable name, a cell array containing one or more variable
%   names, or a logical vector.
%
%   B = SORTROWS(A,'obsnames') sorts the observations in A by the observation
%   names.
%
%   B = SORTROWS(A,VARS,MODE) sorts in the direction specified by MODE.  MODE
%   is 'ascend' (the default) or 'descend'.  Specify VARS as [] to sort using
%   all variables.
%
%   [B,IDX] = SORTROWS(A, ...) also returns an index vector IDX such that
%   B = A(IDX,:).
%
%   See also DATASET/UNIQUE.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:57 $

if nargin < 2 || isempty(vars)
    vars = 1:a.nvars;
end
if nargin < 3 || isempty(mode)
    descend = false;
elseif strcmpi(mode,'ascend')
    descend = false;
elseif strcmpi(mode,'descend')
    descend = true;
else
    error('stats:dataset:sortrows:UnrecognizedMode', ...
          'MODE must be ''ascend'' or ''descend''.');
end

% Sort on each index variable, last to first.  Since sort is stable, the
% result is as if they were sorted all together.
if isequal(vars,'obsnames')
    if isempty(a.obsnames)
        warning('stats:dataset:srotrows:EmptyObsNames', ...
                'No observation names, returning A unsorted.');
    else
        [dum,idx] = sort(a.obsnames);
    end
else
    vars = getvarindices(a,vars,false);
    idx = (1:a.nobs)';
    for j = fliplr(vars)
        var_j = a.data{j}(idx);
        if ~isvector(var_j) || (size(var_j,2) ~= 1)
            error('stats:dataset:sortrows:NonvectorVar', ...
                  'Dataset variable must be column vectors to sort on them.');
        end
        [dum,ord] = sort(var_j);
        idx = idx(ord);
    end
end
if descend, idx = flipud(idx); end

% Can't use dataset subscripting, do the reordering explicitly
b = a;
for j = 1:b.nvars
    var_j = b.data{j};
    szOut = size(var_j);
    b.data{j} = reshape(var_j(idx,:),szOut);
end
if ~isempty(b.obsnames)
    b.obsnames = b.obsnames(idx);
end
