function iAmin = intmin(A)
% Embedded MATLAB library function for the @fi/intmin

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/intmin.m $
% Copyright 2002-2008 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.4 $  $Date: 2008/11/13 17:54:01 $
  
eml_allow_mx_inputs;

% Check for correct number of input arguments i.e. 1
eml_assert(nargin==1,'Incorrect number of inputs.');

if isfixed(A)
    % Fixed point FI

    % Get the word length of & signedness of A
    Ta  = numerictype(A);
    Fa = eml_fimath(A);
    wlA = eml_const(get(Ta,'WordLength'));
    isSignedA = eml_const(get(Ta,'Signed'));

    if isSignedA
        Tout = numerictype(1,wlA,0);
        iTemp = eml_cast(-2^(wlA-1),Tout,Fa);
    else
        Tout = numerictype(0,wlA,0);
        iTemp = eml_cast(0,Tout,Fa);
    end

    if ~eml_const(eml_fimathislocal(A))
        iAmin = eml_fimathislocal(iTemp,false);
    else
        iAmin = iTemp;
    end
    
elseif isfloat(A)
    % True Double or True Single FI
    iAmin = lowerbound(A);
else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('INTMIN', 'fixed-point,double, or single');
end

%--------------------------------------------------------------------------
