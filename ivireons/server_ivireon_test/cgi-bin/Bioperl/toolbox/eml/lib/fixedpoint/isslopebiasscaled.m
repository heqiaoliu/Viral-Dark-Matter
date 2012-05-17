function flag = isslopebiasscaled(T)
% EML library function that returns true if T is slope-bias scaled

% Copyright 2006-2008 The MathWorks, Inc.
%#eml
    
% This function accepts mxArray input argument
eml_allow_mx_inputs;      
    
eml_assert(nargin==1,'Incorrect number of inputs');    
eml_assert(isnumerictype(T),'Input must be a numerictype');

safT = eml_const(get(T,'SlopeAdjustMentFactor'));
biasT = eml_const(get(T,'Bias'));
flag = ~isequal(safT,1.0) || ~isequal(biasT,0.0);
