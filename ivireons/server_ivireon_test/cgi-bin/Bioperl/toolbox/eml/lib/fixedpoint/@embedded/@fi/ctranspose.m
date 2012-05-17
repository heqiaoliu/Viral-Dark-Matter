function y = ctranspose(x)
% Fixed-point EML library function for complex conjugate transpose (Y = X')

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2009/05/14 16:52:38 $

%#eml
eml_assert(ndims(x)<=2,'Transpose on ND array is not defined.');
eml_assert(isreal(x) || ~eml_isslopebiasscaled(x), ...
           'Function ''ctranspose'' is not defined for complex-value FI objects with slope and bias scaling.')


if isreal(x)
  y = eml_fimathislocal(x.',eml_fimathislocal(x));
else
  y = eml_fimathislocal((conj(x)).',eml_fimathislocal(x));
end
