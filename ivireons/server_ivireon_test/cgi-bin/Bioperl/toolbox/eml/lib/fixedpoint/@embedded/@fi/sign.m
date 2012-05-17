function S = sign(X)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) Complex numbers do not work.
% 2) NaN friendly but not correct.

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/sign.m$
% Copyright 2002-2007 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.6 $  $Date: 2007/10/15 22:43:14 $

eml_assert(nargin==1, ...
    'error','Not enough input arguments.');
eml_assert(isreal(X),'Function ''sign'' is not defined for complex-valued FIs.');

S = zeros(size(X),'int8');

for m = 1:eml_numel(X)
  if isnan(X(m))
    S(m) = 1;
  elseif X(m) > 0
    S(m) = 1;
  elseif X(m) < 0
    S(m) = -1;
  end
end

