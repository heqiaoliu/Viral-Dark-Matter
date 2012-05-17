function iA = stripscaling(A)
% Embedded MATLAB library function for the @fi/stripscaling

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/stripscaling $
% Copyright 2002-2009 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.7 $  $Date: 2009/03/30 23:29:51 $
  
eml_allow_mx_inputs;

% Check for correct number of input arguments i.e. 1
eml_assert(nargin==1,'Incorrect number of inputs.');

if eml_ambiguous_types
    temp = eml_not_const(zeros(size(A)));
    if ~isreal(A)
        iA = complex(temp,temp);
    else
        iA = temp;
    end
    return;
end

if isfixed(A)
    % FI objects with Fixed datatype

    % Get the word length of & signedness of A
    Ta        = numerictype(A);
    Tout = numerictype('Scaling','BinaryPoint', 'Signed',Ta.Signed, 'Wordlength', Ta.WordLength,'FractionLength',0);
    if ~isreal(A)
        Ar   = real(A); Ai = imag(A);
        iAr  = eml_fimathislocal(eml_reinterpret(Ar,Tout),eml_fimathislocal(A)); iAi = eml_fimathislocal(eml_reinterpret(Ai,Tout),eml_fimathislocal(A));
        iA = complex(iAr,iAi);
    else
        iA = eml_fimathislocal(eml_reinterpret(A,Tout),eml_fimathislocal(A));
    end

elseif isfloat(A)
    % True Double or True Single FI
    iA = A;
else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('STRIPSCALING','fixed-point,double, or single');
end

%--------------------------------------------------------------------------
