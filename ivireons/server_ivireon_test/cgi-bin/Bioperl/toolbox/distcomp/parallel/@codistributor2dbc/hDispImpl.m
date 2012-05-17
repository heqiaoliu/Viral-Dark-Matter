function [header, matrix] = hDispImpl(codistr, LP, varName, maxStrLen) %#ok<INUSD> Don't use maxStrLen.
; %#ok<NOSEM> % Undocumented
%hDispImpl Implementation for codistributor2dbc.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/14 03:53:42 $

if isempty(LP)
    header = sprintf('This lab does not store any elements of %s.', varName);
    matrix = '';
else
    indexExpr = getIndexExpr(codistr);
    if isempty(indexExpr)
        header = sprintf('This lab stores all the values of %s.', varName);
    else
        header = sprintf('This lab stores %s%s.', varName, indexExpr);
    end
    dispFcn = @() disp(struct('LocalPart', {LP}, 'Codistributor', {codistr})); %#ok<NASGU>
    matrix = evalc('dispFcn()');
end
end % End of hDispImpl.

%--------------
function str = getIndexExpr(codistr)
%getIndexExpr  Returns the indexing expression that represents this lab's 
%    local part.  
if numlabs == 1
    % Entire array resides on this worker, so index not needed.
    str = '';
    return;
end
dimIndex = cell(1, 2);
for dim = 1:2
    dimIndex{dim} = getIndexExprInDim(codistr, dim);
end
if all(strcmp(dimIndex, ':'))
    % The entire local part resides on this worker, so index not needed;
    str = '';
    return;
end
str = sprintf('(%s, %s)', dimIndex{1}, dimIndex{2});

end % End of getIndexExpr.

%--------------
function str = getIndexExprInDim(codistr, dim)
%getIndexExprInDim Returns an indexing expression that represents the global 
%    indices into the local part in a particular dimension.
%    Returned as a string in one of the following formats:
%    'a'
%    ':'
%    'a:b'
%    '[a1:b1 a2:b2 ... an:bn]'

globalLen = codistr.Cached.GlobalSize(dim);
localLen = codistr.hLocalSize;
localLen = localLen(dim);
if globalLen == localLen
    % We have the entire length in this dimension.
    str = ':';
    return;
end

[first, last] = codistr.globalIndices(dim, labindex);
if isscalar(first) && first == last
    % We only store one index in this dimension.
    str = sprintf('%d', first);
else
    % Create list of segments of the form first(i):last(i) and separate them by
    % space, as in 1:64 129:193.
    idx = arrayfun(@(a,b) sprintf('%d:%d', a, b), first, last, ...
                  'UniformOutput', false);
    if length(idx) > 1
        % Put the space between the segments:
        idx(1:end-1) = strcat(idx(1:end-1), {' '});
        % Surround the regments with brackets.
        idx = [{'['}, idx, {']'}];
    end
    % Concatenate all the segments into one long string representation of 
    % the index.
    str = [idx{:}];
end

end % End of getIndexExprInDim.
