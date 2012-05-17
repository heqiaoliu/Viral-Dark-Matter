function c = sub(f,a0,b0)
% Embedded MATLAB add function for fixed-point inputs

% Copyright 2002-2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2008/11/13 17:53:34 $
%#eml
    
eml_allow_mx_inputs;
eml_assert(nargin==3,'Incorrect number of input arguments.');
eml_assert(eml_const((isscalar(a0))||(isscalar(b0))||(isequal(size(a0),size(b0)))),'Matrix dimensions must agree.')

% Check for ambiguous types and return with the correct size output
if eml_ambiguous_types
    numelA = prod(size(a0)); numelB = prod(size(b0)); %#ok
    isrealC = isreal(a0) && isreal(b0);
    if numelA > numelB
        ctemp = eml_not_const(zeros(size(a0)));
    else
        ctemp = eml_not_const(zeros(size(b0)));
    end
    if isrealC
        c = ctemp;
    else
        c = complex(ctemp,ctemp);
    end
    return;
else
    eml_assert(0,['Undefined function or method ''sub'' for input arguments of type ',class(f),'.']);
end
