function iA = int(A)
% Embedded MATLAB library function for the @fi/int

% $INCLUDE(DOC) toolbox/eml/lib/fixedpoint/@embedded/@fi/int.m $
% Copyright 2002-2007 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.4 $  $Date: 2007/10/15 22:41:39 $
  
eml_allow_mx_inputs;

% Check for ambiguous types and return with the correct size output
if eml_ambiguous_types
    iA = eml_not_const(zeros(size(A)));
    return;
end

% Check for correct number of input arguments i.e. 1
eml_assert(nargin==1,'Incorrect number of inputs.');

if isfixed(A)
    % FI object with Fixed datatype

    % Get the word length of  & signedness of A
    Ta  = numerictype(A);
    wlA = eml_const(get(Ta,'WordLength'));
    isSignedA = eml_const(get(Ta,'Signed'));

    % Switch on the wordlength & signedness and return
    % the correct int
    if isSignedA
        if wlA <= 8
            iA = int8(A);
        elseif wlA <= 16
            iA = int16(A);
        elseif wlA <= 32
            iA = int32(A);
        else 
            eml_assert(0, 'Wordlength must be <= 32.')         
        end
    else
        if wlA <= 8
            iA = uint8(A);
        elseif wlA <= 16
            iA = uint16(A);
        elseif wlA <= 32
            iA = uint32(A);
        else 
            eml_assert(0, 'Wordlength must be <= 32.')   
        end
    end

elseif isfloat(A)
    % True Double or True Single FI

    dType = eml_fi_getDType(A);
    iA    = eml_cast(A,dType);
    
else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('INT','fixed-point,double, or single');

end

%--------------------------------------------------------------------------
