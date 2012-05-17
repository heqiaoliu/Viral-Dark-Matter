function flag = issigned(xfi)
% Embedded MATLAB Library function for @fi/issigned.
%
% ISSIGNED(A) will return true if A is signed, fase  if unsigned.

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/issigned.m $
% Copyright 2002-2008 The MathWorks, Inc.
%#eml
% $Revision $  $Date: 2008/11/13 17:53:27 $

eml_allow_mx_inputs;

% Check for nargin and assert if not 1
eml_assert(nargin==1,'Not enough input arguments.');

if eml_ambiguous_types
    flag = 1;
    return;
end

eml_assert(isfi(xfi),['Function ''issigned'' is not definead for a first argument of class ',class(xfi)]);
    
Tx = eml_typeof(xfi);
flag = eml_const(get(Tx,'Signed'));

%----------------------------------------------------
