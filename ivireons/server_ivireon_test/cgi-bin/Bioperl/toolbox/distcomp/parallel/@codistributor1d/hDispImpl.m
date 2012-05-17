function [header, matrix] = hDispImpl(codistr, LP, varName, maxStrLen)  %#ok<INUSD> Don't use maxStrLen.
; %#ok<NOSEM> % Undocumented
%hDispImpl Implementation for codistributor1d.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 22:59:40 $

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
    str = ''; % Entire array resides on this worker, so index not needed.
    return;
end
ndims = length(codistr.Cached.GlobalSize);
isvec = ndims == 2 && any(codistr.Cached.GlobalSize == 1);
if isvec
      idx = {getIndexExprInDistrDim(codistr)};
else % Displaying a matrix.
    % Build up the index vector
    idx = repmat({':'}, 1, ndims);
    dim = codistr.Dimension;
    distrIndex = getIndexExprInDistrDim(codistr);
    if strcmp(distrIndex, ':')
        % The entire local part resides on this worker, so index not needed;
        str = '';
        return;
    end
    idx{dim} = distrIndex;
    % Append commas to all indices except the last one.
    idx(1:end-1) = strcat(idx(1:end-1), {','});
end
% Concatenate all the indices to get a single index expression.
str = sprintf('(%s)', [idx{:}]);
end % End of getIndexExpr.

%--------------
function str = getIndexExprInDistrDim(codistr)
%getIndexExprInDistrDim Returns an indexing expression that represents the global
%    indices into the local part in the distribution dimension.
%    Returned as a string in one of the following formats:
%    'a'
%    ':'
%    'a:b'

dim = codistr.Dimension;
[e, f] = codistr.globalIndices(dim, labindex);
ndims = length(codistr.Cached.GlobalSize);
% This function is only called if the local part is non-empty.  We therefore
% know that if we reach this point and the distribution dimension exceeds the
% number of dimensions of the array, we store the entire array.
ownAllInDim = dim > ndims || (e == 1 && f == codistr.Cached.GlobalSize(dim));
if ownAllInDim
    str = ':';
elseif e == f
    str = sprintf('%d', e);
else
    str = sprintf('%d:%d', e, f);
end

end % End of getIndexExprInDistrDim.
