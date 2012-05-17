function datatype = eml_fi_getDType(xfi)
% Embedded MATLAB Library function to determine floating point data type of
% the input
%
% EML_FI_GETDTYPE(A) will return 'double' or 'single' if input fi A is fi
% double or fi single, respectively. Otherwise, it will assert.

% Copyright 2007 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:42:28 $
 
eml_allow_mx_inputs;

if isdouble(xfi)
    datatype = eml_const('double');
elseif issingle(xfi)
    datatype = eml_const('single');
else
    datatype = '';
    eml_assert(false, 'FI object has invalid datatype.');
end

%----------------------------------------------------

