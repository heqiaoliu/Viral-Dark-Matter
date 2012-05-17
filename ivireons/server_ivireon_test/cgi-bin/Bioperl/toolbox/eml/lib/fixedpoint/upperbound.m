function ubxfi = upperbound(xfi)
% Embedded MATLAB Library function for @fi/upperbound.
%
% UPPERBOUND(A) will return true if A is signed, false if unsigned.

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/upperbound.m $
% Copyright 2002-2009 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.10 $  $Date: 2009/05/14 16:52:34 $

eml_allow_mx_inputs;

% Check for nargin and assert if not 1
eml_assert(nargin==1,'Not enough input arguments.');

if eml_ambiguous_types
    ubxfi = eml_not_const(0);
    return;
end

eml_assert(isfi(xfi),['Function ''upperbound'' is not defined for a first argument of class ',class(xfi)]);
    
Tx = eml_typeof(xfi);
Fx = eml_fimath(xfi);

if isfixed(xfi)
    % Fixed FI
    outHasLocalFimath = eml_fimathislocal(xfi);
    ubxfi1 = eml_dress(0,Tx,Fx);
    ubxfi2 = stripscaling(ubxfi1);
    if issigned(xfi)
        ubxfi3 = bitset(ubxfi2,Tx.wordlength);
        ubxfi4 = bitcmp(ubxfi3);
        ubxfi = eml_fimathislocal(eml_dress(ubxfi4,Tx,Fx),outHasLocalFimath);

    else % is unsigned
        ubxfi3 = bitcmp(ubxfi2);
        ubxfi = eml_fimathislocal(eml_dress(ubxfi3,Tx,Fx),outHasLocalFimath);
    end
    %if ~eml_const(eml_fimathislocal(xfi))
    %    ubxfi = eml_fimathislocal(ubxfitemp,false);
    %else
    %    ubxfi = ubxfitemp;
    %end
elseif isfloat(xfi)
    % True Double or True Single FI
    dType    = eml_fi_getDType(xfi);
    ubxfi    = eml_fimathislocal(eml_cast(realmax(dType),Tx,Fx),eml_fimathislocal(xfi));
else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('UPPERBOUND','fixed-point,double, or single');
end

%----------------------------------------------------
