function yfi = realmin(xfi)
% Embedded MATLAB Library function for @fi/realmin.
%
% REALMIN(A) will return true if A is signed, fase  if unsigned.

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/realmin.m $
% Copyright 2002-2009 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.6 $  $Date: 2009/05/14 16:52:41 $
 
eml_allow_mx_inputs;
if eml_ambiguous_types
    yfi = eml_not_const(0);
    return;
end

if isfixed(xfi)
    % Fixed FI
    yfi   = eps(xfi(1));
elseif isfloat(xfi)
    % True Double or True Single FI
    Tx    = eml_typeof(xfi);
    Fx    = eml_fimath(xfi);
    dType = eml_fi_getDType(xfi);
    yfi   = eml_fimathislocal(eml_cast(realmin(dType),Tx,Fx),eml_fimathislocal(xfi));
else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('REALMIN','fixed-point,double, or single');
end

%----------------------------------------------------