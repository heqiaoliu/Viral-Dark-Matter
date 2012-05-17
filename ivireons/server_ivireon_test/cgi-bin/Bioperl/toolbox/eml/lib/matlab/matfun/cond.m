function c = cond(A,p)
%Embedded MATLAB Library Function

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml 

eml_assert(nargin >= 1, 'Not enough input arguments.');
eml_assert(isa(A,'float'), ['Function ''cond'' is not defined for values of class ''' class(A) '''.']);
eml_assert(nargin == 1 || ((isscalar(p) && isa(p,'numeric')) || ischar(p)), ...
    'The only matrix norms available are 1, 2, inf, and ''fro''.');
eml_lib_assert(ndims(A) == 2, 'EmbeddedMATLAB:cond:inputMustBe2D', ...
    'Input matrix must be 2-D.');
if nargin == 1
    p = 2;
end
if isempty(A)
    c = zeros(class(A));
elseif isequal(p,2)
   s = svd(A);
   if s(end) == 0 
       % Handle singular matrix
       c = eml_guarded_inf(class(A));
   else
       c = eml_rdivide(s(1),s(end));
   end
elseif size(A,1) ~= size(A,2)
   eml_error('MATLAB:cond:normMismatchSizeA', 'A is rectangular.  Use the 2 norm.');
   % For RTW execution continues, so go ahead and follow our own advice.
   c = cond(A,2); 
else
   % We'll let NORM pick up any invalid p argument.
   c = norm(A,p) * norm(inv(A),p);
end
