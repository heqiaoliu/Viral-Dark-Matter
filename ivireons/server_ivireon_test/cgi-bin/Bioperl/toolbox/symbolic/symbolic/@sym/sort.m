function [Y,I] = sort(X,dim,mode)
%SORT Sort symbolic arrays.
%   Y = SORT(X) sorts the elements of a symbolic vector X
%   in numerical or lexicographic order.
%   For matrices, SORT(X) sorts each column of X in ascending order.
%
%   [Y,I] = SORT(X) sorts X and returns the array I such that X(I)=Y.
%   If X is a vector, then Y = X(I).  
%   If X is an m-by-n matrix and DIM=1, then
%       for j = 1:n, Y(:,j) = X(I(:,j),j); end
%
%   Y = SORT(X,DIM,MODE)
%   has two optional parameters.  
%   DIM selects a dimension along which to sort.
%   MODE selects the direction of the sort
%      'ascend' results in ascending order
%      'descend' results in descending order
%   The result is in Y which has the same shape and type as X.
%
%   Examples:
%      syms a b c d e x
%      sort([a c e b d]) = [a b c d e]
%      sort([a c e b d]*x.^(0:4).') = 
%         d*x^4 + b*x^3 + e*x^2 + c*x + a
%
%   See also SYM/SYM2POLY, SYM/COEFFS.

%   Copyright 1993-2010 The MathWorks, Inc.

if builtin('numel',X) ~= 1,  X = normalizesym(X);  end
if isa(X.s,'maplesym')
    Y = sym(sort(X.s));
else
    if nargout > 1
        inds = 'TRUE';
    else
        inds = 'FALSE';
    end
    gotModeAsSecondInput = false;
    if nargin == 2 && ~isa(dim,'double')
        mode = dim;
        gotModeAsSecondInput = true;
        dim = 'Auto';
    elseif nargin < 2 
        dim = 'Auto';
    else
        dim = num2str(dim);
    end
    if nargin < 3 && ~gotModeAsSecondInput
        mode = 'TRUE';
    elseif strcmpi(mode,'descend')
        mode = 'FALSE';
    elseif strcmpi(mode,'ascend')
        mode = 'TRUE';
    else
        error('symbolic:sort:UnknownMode','Mode must be ''ascend'' or ''descend''.');
    end
    [Y,Isym] = mupadmexnout('symobj::sort',X,dim,mode,inds);
    if nargout > 1
        I = double(Isym);
    end
end
