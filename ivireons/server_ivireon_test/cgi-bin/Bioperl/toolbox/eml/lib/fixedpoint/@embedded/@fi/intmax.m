function iAmax = intmax(A)
% Embedded MATLAB library function for the @fi/intmax

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/intmax.m $
% Copyright 2002-2008 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.5 $  $Date: 2008/11/13 17:54:00 $
  
eml_allow_mx_inputs;

% Check for correct number of input arguments i.e. 1
eml_assert(nargin==1,'Incorrect number of inputs.');

if isfixed(A)
    % Fixed FI

    % Get the word length & signedness of A
    Ta  = numerictype(A);
    Fa = eml_fimath(A);
    wlA = Ta.WordLength;
    isSignedA = Ta.Signed;
    
    % Create the output fi. If A is unsigned then it is enough to create
    % an initial input of all zeros and then to a bitcmp. If A is signed, then doing bitset of the MSB 
    % only and then the bitcmp will return the intmax value.
    Tout = numerictype(isSignedA,wlA,0);
    iTemp = eml_cast(0,Tout,Fa);
    if ~eml_const(eml_fimathislocal(A))
        iAmax = eml_fimathislocal(iTemp,false);
    else
        iAmax = iTemp;
    end
    if isSignedA
        iAmax = bitset(iAmax,wlA);
    end
    iAmax = bitcmp(iAmax);
elseif isfloat(A)
    % True Double or True Single FI
    iAmax = upperbound(A);
else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('INTMAX', 'fixed-point,double, or single');
end

%--------------------------------------------------------------------------
