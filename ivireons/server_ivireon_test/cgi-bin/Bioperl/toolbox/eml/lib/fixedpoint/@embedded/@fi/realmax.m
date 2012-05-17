function yfi = realmax(xfi)
% Embedded MATLAB Library function for @fi/realmax.
%
% REALMAX(A) will return true if A is signed, fase  if unsigned.

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/realmax.m $
% Copyright 2002-2007 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.4 $  $Date: 2007/10/15 22:43:12 $

 
eml_allow_mx_inputs;
if eml_ambiguous_types
    yfi = eml_not_const(0);
    return;
end

yfi = upperbound(xfi);

%----------------------------------------------------