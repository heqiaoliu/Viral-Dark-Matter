function epsxfi = eps(xfi)
% Embedded MATLAB Library function for @fi/eps.
%
% EPS(A) will return the eps of the fi A

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/eps.m $
% Copyright 2002-2009 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.7 $  $Date: 2009/03/30 23:30:02 $

eml_allow_mx_inputs;

% Check for nargin and assert if not 1
eml_assert(nargin==1,'Not enough input arguments.');

if eml_ambiguous_types
    epsxfi = eml_not_const(0);
    return;
end

check4scalarInput = true; % non-scalar (vector & matrix) inputs not allowed
                          % for fixed-point and scaled double FIs
epsxfi = eml_fi_eps_lsb(xfi,'eps',check4scalarInput);

%----------------------------------------------------

