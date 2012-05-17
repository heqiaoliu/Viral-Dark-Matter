function iA = uint32(A)
% Embedded MATLAB library function for the @fi/uint32

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/uint32.m $
% Copyright 2002-2007 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.4 $  $Date: 2007/10/15 22:43:21 $

eml_allow_mx_inputs;
iA = eml_fi_getStoredIntValAsDType(A,'uint32');

%-------------------------------------------------------------------------------