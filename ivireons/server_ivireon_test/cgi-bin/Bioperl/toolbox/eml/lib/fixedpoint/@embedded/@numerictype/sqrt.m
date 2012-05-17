function y = sqrt(x,var1,var2)
% SQRT Overloaded sqrt for embedded.numerictype that passes
% the control to the floating point sqrt

% Copyright 2006-2007 The MathWorks, Inc.
%#eml
    
% This function accepts mxArray input argument
eml_allow_mx_inputs;

% Error if incorrect number of inputs
eml_assert(nargin >= 1 && nargin <= 3,'Incorrect number of inputs');

% Error if complex, or slope bias or negative
eml_assert(isreal(x),'The sqrt function is not supported for complex fi.');

% Call the floating point sqrt 
y = sqrt(x);

%------------------------------------------------------------------------------

