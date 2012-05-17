function y = conj(x)
% Embedded MATLAB Library function for @fi/conj.
%
% CONJ(A) will return the complex conjugate of A

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/conj.m $
% Copyright 2002-2007 The MathWorks, Inc.
%#eml
% $Revision $  $Date: 2007/10/15 22:42:22 $

eml_assert(isreal(x) || ~eml_isslopebiasscaled(x), ...
           'Function ''conj'' is not defined for complex-value FI objects with slope and bias scaling.')

% If x is real, simple return x as y
if isreal(x)
  y = x;
else
  y = complex(real(x),-imag(x));
end

