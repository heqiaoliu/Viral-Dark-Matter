function [b,idx,jdx] = unique(a,vars,flag)
%UNIQUE Unique observations in a dataset array.
%   B = UNIQUE(A) returns a copy of the dataset A that contains only the
%   sorted unique observations.  A must contain only variables whose class has
%   a UNIQUE method.  These include variables that are numeric, character,
%   logical, categorical, or cell arrays of strings.  For a variable with
%   multiple columns, its class's UNIQUE method must support the 'rows' flag.
%
%   B = UNIQUE(A,VARS) returns a dataset that contains only one observation
%   for each unique combination of values for the variables in A specified in
%   VARS. VARS is a positive integer, a vector of positive integers, a
%   variable name, a cell array containing one or more variable names, or a
%   logical vector. B includes all variables from A.  The values in B for the
%   variables not specified in VARS are taken from the last occurrence among
%   observations in A with each unique combination of values for the variables
%   specified in VARS.
%
%   [B,I,J] = UNIQUE(A) also returns index vectors I and J such that B = A(I,:)
%   and A = B(J,:).
%
%   [...] = UNIQUE(A,VARS,'first') returns the vector I to index the first
%   occurrence of each unique observation in A.  UNIQUE(A,VARS,'last'), the
%   default, returns the vector I to index the last occurrence.  Specify VARS
%   as [] to use the default value of all variables.
%
%   See also DATASET/SORTROWS.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/05/07 18:27:27 $

if nargin < 2 || isempty(vars)
    vars = 1:a.nvars;
else
    vars = getvarindices(a,vars,false);
end

if nargin < 3 || isempty(flag)
    flag = [];
elseif ~ischar(flag) || ~strcmpi(flag,'first') && ~strcmpi(flag,'last')
    error('stats:dataset:unique:UnrecognizedFlag', ...
          'FLAG must be ''first'' or ''last''.');
end

group = zeros(a.nobs,length(vars));
for j = vars
    var_j = a.data{j};
    var_j = var_j(:,:);
    
    % The additional args for each variables unique method include 'rows', if
    % the var is not a single column, and the first/last flag if, it was
    % given.
    args = {};
    if size(var_j,2) > 1, args{end+1} = 'rows'; end
    if ~isempty(flag), args{end+1} = flag; end
    
    try
        [dum,dum,groupj] = unique(var_j,args{:});
    catch ME
        throw(addCause(MException('stats:dataset:unique:VarUniqueMethodFailed', ...
              'Unable to determine unique values for the dataset variable ''%s''.', a.varnames{j}), ME));
    end
    if length(groupj) ~= a.nobs
        error('stats:dataset:unique:VarUniqueMethodFailed', ...
              ['Unable to determine unique values for the dataset variable ''%s''.\n', ...
               'The value returned by the UNIQUE method had the wrong number of rows.'], ...
               a.varnames{j});
    end
    group(:,j) = groupj;
end

if isempty(flag)
    [dum,idx,jdx] = unique(group,'rows');
else
    [dum,idx,jdx] = unique(group,'rows',flag);
end

% Can't use dataset subscripting, do the subsetting explicitly
b = a;
b.nobs = length(idx);
for j = 1:b.nvars
    var_j = b.data{j};
    szOut = size(var_j); szOut(1) = b.nobs;
    b.data{j} = reshape(var_j(idx,:),szOut);
end
if ~isempty(b.obsnames)
    b.obsnames = b.obsnames(idx);
end
