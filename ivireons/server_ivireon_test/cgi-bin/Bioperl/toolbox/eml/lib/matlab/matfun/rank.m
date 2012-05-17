function r = rank(A,tol)
%Embedded MATLAB Library Function

%   Copyright 1984-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 1, 'Not enough input arguments.');
eml_assert(isa(A,'float'), ['Function ''rank'' is not defined for values of class ''' class(A) '''.']);
r = 0;
if isempty(A)
    return
end
s = svd(A);
if nargin == 1
    tol = length(A)*eps(s(1));
else
    eml_assert(isa(tol,'float'), ['Function ''rank'' is not defined for values of class ''' class(tol) '''.']);
    eml_assert(isscalar(tol), 'If supplied, tol must be a scalar.');
end
for k = 1:eml_numel(s)
    if s(k) > tol
        r = r + 1;
    else
        break
    end
end
