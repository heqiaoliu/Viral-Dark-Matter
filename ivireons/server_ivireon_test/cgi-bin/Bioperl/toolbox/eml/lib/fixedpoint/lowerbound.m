function lbxfi = lowerbound(xfi)
% Embedded MATLAB Library function for @fi/lowerbound.
%
% LOWERBOUND(A) will return true if A is signed, fase  if unsigned.

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/lowerbound.m $
% Copyright 2002-2008 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.9 $  $Date: 2008/11/13 17:53:30 $

eml_allow_mx_inputs;

% Check for nargin and assert if not 1
eml_assert(nargin==1,'Not enough input arguments.');

if eml_ambiguous_types
    lbxfi = eml_not_const(0);
    return;
end

eml_assert(isfi(xfi),['Function ''lowerbound'' is not defined for a first argument of class ',class(xfi)]);

Tx = eml_typeof(xfi);
Fx = eml_fimath(xfi);

if isfixed(xfi)
    % Fixed FI
    outHasLocalFimath = eml_const(eml_fimathislocal(xfi));
    if issigned(xfi)
        lbxfi1 = eml_dress(0,Tx,Fx);
        lbxfi2 = stripscaling(lbxfi1);
        lbxfi3 = bitset(lbxfi2,Tx.wordlength);
        lbxfi = eml_fimathislocal(eml_dress(lbxfi3,Tx,Fx),outHasLocalFimath);
    else % is unsigned
        lbxfi = eml_fimathislocal(eml_dress(0,Tx,Fx),outHasLocalFimath);
    end
elseif isfloat(xfi)
    % True Double or True Single FI
    dType    = eml_fi_getDType(xfi);
    lbxfi    = eml_cast(-realmax(dType),Tx,Fx);
else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('LOWERBOUND','fixed-point,double, or single');
end

%----------------------------------------------------
