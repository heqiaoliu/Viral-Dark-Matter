function y = abs(x,var1,var2)
%ABS    Overloaded abs for numerictype that passes on to floating point abs

% Copyright 2007 The MathWorks, Inc.
%#eml
    
% This function accepts mxArray input argument
eml_allow_mx_inputs;

% Error if incorrect number of inputs
eml_assert(nargin >= 2 && nargin <= 3,'Incorrect number of inputs.');

eml_assert(((nargin ~= 3)||(isfimath(var2))),'This syntax is not supported by the abs function.');

eml_assert(~isfimath(x),'This syntax is not supported by the abs function.');
% Call the floating point abs 
y = abs(x);

%------------------------------------------------------------------------------



