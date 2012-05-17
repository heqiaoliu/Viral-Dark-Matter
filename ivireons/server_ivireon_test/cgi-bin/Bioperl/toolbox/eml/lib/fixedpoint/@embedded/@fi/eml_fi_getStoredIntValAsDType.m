function y = eml_fi_getStoredIntValAsDType(xfi,returnAsDType)
% Embedded MATLAB library function for the @fi/int8

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/int8.m $
% Copyright 2008 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.3 $  $Date: 2008/05/19 22:53:01 $

eml.extrinsic('upper');
  
eml_allow_mx_inputs;

if isfixed(xfi)
    % FI object with Fixed datatype

    if isreal(xfi)
        y = eml_cast(eml_reinterpret(xfi),returnAsDType);
        
    else
        xfir = real(xfi); xfii = imag(xfi);
        yr   = eml_cast(eml_reinterpret(xfir),returnAsDType);
        yi   = eml_cast(eml_reinterpret(xfii),returnAsDType);
        
        y    = complex(yr,yi);
    end

elseif isfloat(xfi)
    % True Double or True Single FI
    y = eml_cast(xfi,returnAsDType);
else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported(upper(returnAsDType), ...
                                       'fixed-point,double, or single');
end

%--------------------------------------------------------------------------
