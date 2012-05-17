function lsbxfi = lsb(xfi)
% Embedded MATLAB Library function for @fi/lsb.
%
% LSB(A) will return the lsb of the fi A

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/lsb.m $
% Copyright 2002-2007 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.5 $  $Date: 2007/10/15 22:41:53 $
 
eml_allow_mx_inputs;

% Check for nargin and assert if not 1
eml_assert(nargin==1,'Not enough input arguments.');

if eml_ambiguous_types
    lsbxfi = eml_not_const(zeros(size(xfi)));
    return;
end

eml_assert(isfi(xfi),['Function ''lsb'' is not definead for a first argument of class ',class(xfi)]);

check4scalarInput = true; % non-scalar (vector & matrix) inputs not allowed
                          % for fixed-point FIs
lsbxfi            = eml_fi_eps_lsb(xfi,'lsb',check4scalarInput);

%----------------------------------------------------
